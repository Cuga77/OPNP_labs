#
#  presampler/tokparser.rb
#  v 1.40  2008/09/01
#
#   
#  == разбор списка токенов, сборка "дерева" структуры программы:
#
#    - TokenParser [class]
#      - parse_program
#        = разбор списка токенов, сборка "дерева" структуры программы.
#      - getInsertedBlocks
#        == генерирование списка Токенов для БЛОКирования текста
#      - printProgTree
#        == печать дерева структуры программы
#
#    - ParseNode [class]
#      == узел в дереве структуры программы
#      
#    - InsertedBlock [class]
#      == токен для для БЛОКирования исходного текста 
#         т.е. вставки лексем "{" и "}"

require 'strscan'
require "objects/sampler_graph/model"
          

#NodeTypes = [:parentNode, :seqNode, :blockNode, :ifNode, :elseNode,
#             :whileNode,  :doNode, :forNode, :blockNode, :simpleOpNode]


#=========================================================================================================
#               Узел в дереве структуры программы
#=========================================================================================================

class ParseNode
  attr_accessor :typeNode       # тип узла
  # токены границ участка - позиции в списке токенов
  attr_accessor :begOp,     # начало оператора
                :endOp,     # конец  оператора
                :begBody,   # начало тела оператора
                :endBody,   # конец  тела оператора
                :begElse,   # начало тела ветви else
                :endElse,   # конец  тела ветви else
                :updateOp   # начало проверки условия цикла for
  # ссылки на поддеревья - вложенные участки оператора
  attr_accessor :linkBody,  # ссылка на тело оператора
                :linkElse   # ссылка на тело ветви else

 
  # !!! Хеш на входе 
  def initialize(arg)
    @begOp     = arg[:begOp]
    @endOp     = arg[:endOp]
    @begBody   = arg[:begBody]
    @endBody   = arg[:endBody]
    @begElse   = arg[:begElse]
    @endElse   = arg[:endElse]
    @linkBody  = arg[:linkBody]
    @linkElse  = arg[:linkElse]
    @typeNode  = arg[:typeNode]
  end

  def to_s
      "["+@typeNode.to_s+"->"+@begOp.to_s+"-> "+@endOp.to_s+
      " ( "+ @begBody.to_s+"<-> "+@endBody.to_s + ")" +
        if @begElse.nil? then "]"
        else " else( "+ @begElse.to_s+"<-> "+@endElse.to_s + ")]"
        end
  end

  def inspect
    to_s
  end
end # class ParseNode


#===================================================================
#===================================================================
#===================================================================


#===================================================================
#  Разбор списка токенов, сборка "дерева" структуры программы.
#===================================================================

class TokenParser
    # входной список токенов
  attr_accessor :tokStream    
    # наращиваемое дерево структуры программы
  attr_accessor :progTree     
    # предыдущий считанный токен при парсинге
  attr_accessor :prevToken    
    # наращиваемый список Токенов для БЛОКирования текста
  attr_accessor :blocksArray  

    # формируемая модель программы в виде ГНД
  attr_accessor :model
  
    # формируемая модель программы в виде ГНД
  attr_accessor :isMultiLevel

  
  
private
    # ID контрольной точки (в текст впишется "Sampler(<ID>);")
  attr_reader   :sampleID
   def incSampleID
    @sampleID += 1
  end
  
public

  def initialize(tokStream)
    @tokStream = tokStream
    @progTree  = Array.new
    @curTree   = Array.new
    @tokQueue  = nil
    @isMultiLevel = true    
  end

#-------------------------------------------
# Печать дерева структуры программы
#-------------------------------------------
  def printProgTree(level = 1, tree = nil)
    ln = "=="
    tree = @progTree if level == 1
    tree.each do |node|
      if node.typeNode != :parentNode then
        print ln*level + node.to_s + "\n"
        printProgTree(level+1, node.linkBody) unless node.linkBody.nil?
        begin
          print ln*(level) + "ELSE\n"
          printProgTree(level+1, node.linkElse)
        end unless node.linkElse.nil?
      end # if
    end # each
  end # def printProgTree

#-----------------------------------------------------------
# Генерирование списка Токенов для БЛОКирования текста
# !!! Используется дерево, построенное по ИСХОДНОМУ тексту программы
#-----------------------------------------------------------
  def getInsertedBlocks (level = 1, tree = nil)
    tree = @progTree if level == 1
#    p "LEVEL = "+level.to_s
    blocksArray = Array.new

    tree.each do |node|
      next if node.typeNode == :parentNode
  
      if [:whileNode, :doNode, :ifNode, :forNode].include? node.typeNode then
        child = node.linkBody[1]

        # Если Тело - НЕ блок, добавим скобочки по границам
        if child.typeNode != :blockNode then
          blocksArray.
            push(InsertedBlock.
              new(:typeNode  => :begblock ,
                  :token => node.begBody ,
                  :pos   => :after )).
            push(InsertedBlock.
              new(:typeNode  => :endblock ,
                  :token => node.endBody ,
                  :pos   => :after ))
        end  # if child.typeNode != :blockNode
        
      end  # if [:whileNode].include? node.typeNode then
      
      if @isMultiLevel then
        blocksArray += 
          getInsertedBlocks(level+1, node.linkBody) unless (node.linkBody.nil? || blocksArray.nil? )
      end
      # Сделаем то же для тела Else
      if ([:ifNode].include? node.typeNode) && (!node.linkElse.nil?) then
        child = node.linkElse[1]
        if child.typeNode != :blockNode then
          blocksArray.
            push(InsertedBlock.
              new(:typeNode  => :begblock ,
                  :token => node.begElse ,
                  :pos   => :after )).
            push(InsertedBlock.
              new(:typeNode  => :endblock ,
                  :token => node.endElse ,
                  :pos   => :after ))
        end  # if child.typeNode != :blockNode

      if @isMultiLevel then
        blocksArray += getInsertedBlocks(level+1, node.linkElse) unless ( blocksArray.nil? )
      end
      end  # if [:whileNode].include? node.typeNode then
    end # tree.each do |node|


    # сортируем по положению в тексте программы
    blocksArray.sort! do |x,y|
      xT = x.token; yT = y.token
      if xT.line != yT.line then
        xT.line <=> yT.line
      elsif xT.pos  != yT.pos
        (xT.pos  <=> yT.pos)
      else
        # Фокус работает, но только для пары :after/:before
        y.pos.to_s <=> x.pos.to_s
      end
    end

    blocksArray

  end # def getInsertedBlocks


#-------------------------------------------------------------
# Разбор списка токенов, сборка "дерева" структуры программы
#  (косвенная рекурсия)
#-------------------------------------------------------------

  def parse_program
    @progTree = Array.new
    @progTree.push(ParseNode.new(:typeNode => :parentNode))
    @curTree = @progTree

    @tokQueue = tokStream.dup
    until @tokQueue.empty?
      parse_ops
    end
  end # def parse_program

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
private 
  
  def parse_seq
    p "Begin parse_seq"
    until @tokQueue.first.tok == :endblock
        parse_ops
    end
    @prevToken = @tokQueue.shift
    p "shift }:" + prevToken.tok.to_s
    p "TheEnd of parse_seq"
  end # def parse_program
#-------------------------------------------
  def parse_ops
    p "Begin parse_ops"
    p token = @tokQueue.first
    case token.tok
      when :while
        @curTree.push(ParseNode.
                          new(:typeNode => :whileNode,
                              :begOp    => token))
        @curTree.last.linkBody = Array.new.
               push(ParseNode.new(:typeNode  => :parentNode,
                                  :linkBody  => @curTree,
                                  :begOp     => @curTree.length-1))
        @curTree = @curTree.last.linkBody

        @prevToken = @tokQueue.shift
        parse_while

        beg = @curTree.first.begOp
        @curTree = @curTree.first.linkBody
        @curTree[beg].endOp   = @prevToken
        @curTree[beg].endBody = @prevToken
#.............................................................
      when :begblock
        @curTree.push(ParseNode.
                          new(:typeNode => :blockNode,
                              :begOp    => token))
        @curTree.last.linkBody = Array.new.
               push(ParseNode.new(:typeNode  => :parentNode,
                                  :linkBody  => @curTree,
                                  :begOp     => @curTree.length-1))
        @curTree = @curTree.last.linkBody

        @prevToken = @tokQueue.shift
        parse_seq

        @curTree.first.linkBody[@curTree.first.begOp].endOp = @prevToken
        @curTree = @curTree.first.linkBody
#.............................................................
      when :if
        @curTree.push(ParseNode.
                          new(:typeNode      => :ifNode,
                              :begOp    => token))
        @curTree.last.linkBody = Array.new.
               push(ParseNode.new(:typeNode      => :parentNode,
                                  :linkBody  => @curTree,
                                  :begOp    => @curTree.length-1))
        @curTree = @curTree.last.linkBody

        @prevToken = @tokQueue.shift
        parse_if

        beg = @curTree.first.begOp
        @curTree = @curTree.first.linkBody
        @curTree[beg].endOp = @prevToken
        unless @curTree[beg].linkElse.nil?
          @curTree[beg].endElse = @prevToken
        end
#.............................................................
      when :do
        @curTree.push(ParseNode.
                          new(:typeNode     => :doNode,
                              :begOp    => token,
                              :begBody  => token))
        @curTree.last.linkBody = Array.new.
               push(ParseNode.new(:typeNode      => :parentNode,
                                  :linkBody  => @curTree,
                                  :begOp     => @curTree.length-1))
        @curTree = @curTree.last.linkBody

        @prevToken = @tokQueue.shift
        parse_do

        beg = @curTree.first.begOp
        @curTree = @curTree.first.linkBody
        @curTree[beg].endOp   = @prevToken
#.............................................................
      when :semicolon
        @curTree.push(ParseNode.
                          new(:typeNode      => :simpleOpNode,
                              :begOp    => token,
                              :endOp    => token))

        @prevToken = @tokQueue.shift
#.............................................................
      when :for
        @curTree.push(ParseNode.
                            new(:typeNode   => :forNode,
                                :begOp    => token))
        @curTree.last.linkBody = Array.new.
              push(ParseNode.new(:typeNode => :parentNode,
                                 :linkBody => @curTree,
                                 :begOp => @curTree.length - 1))
        @curTree = @curTree.last.linkBody
        @prevToken = @tokQueue.shift
        parse_for
        
        beg = @curTree.first.begOp
        @curTree = @curTree.first.linkBody
        @curTree[beg].endOp = @prevToken
#.............................................................
      else
        @prevToken = @tokQueue.shift
        p "ERROR parse_ops (else)"
    end
    p "TheEnd of parse_ops"
  end # def parse_ops
#-------------------------------------------
#-------------------------------------------
  def parse_if
    p "Begin parse_if"
    parse_expr

    parentNode = @curTree.first.linkBody[@curTree.first.begOp]
    parentNode.begBody = @prevToken

    parse_ops

    if @curTree.last.typeNode == :blockNode
      parentNode.begBody = @curTree.last.begOp
    end
    parentNode.endBody = @curTree.last.endOp

    if (!@tokQueue.empty?) && (@tokQueue.first.tok == :else)
      p "ELSE block!!!"
      @prevToken = @tokQueue.shift

      parentNode.begElse = @prevToken

      @curTree = @curTree.first.linkBody
      @curTree.last.linkElse = Array.new.
             push(ParseNode.new(:typeNode      => :parentNode,
                                :linkBody  => @curTree,
                                :begOp     => @curTree.length-1))
      @curTree = @curTree.last.linkElse

      parse_ops

      if @curTree.last.typeNode == :blockNode
        parentNode.begElse = @curTree.last.begOp
      end
      parentNode.endElse = @curTree.last.endOp

    end
    
    p "TheEnd of parse_if"
  end # def parse_if
#-------------------------------------------
  def parse_do
    p "Begin parse_do"
    parse_ops

    parentNode = @curTree.first.linkBody[@curTree.first.begOp]
    if @curTree.last.typeNode == :blockNode
      parentNode.begBody = @curTree.last.begOp
    end
    parentNode.endBody = @curTree.last.endOp

    if @tokQueue.first.tok != :while
      p     "====ERROR parse_do -> :while expected!!!============"
      raise "====ERROR parse_do -> :while expected!!!============"
    else
      @prevToken = @tokQueue.shift
      parse_expr

      if @tokQueue.first.tok != :semicolon
        p     "====ERROR parse_do -> :semicolon expected!!!============"
        raise "====ERROR parse_do -> :semicolon expected!!!============"
      else
        @prevToken = @tokQueue.shift
        p @prevToken
      end
      p "TheEnd of parse_do"
    end
  end # def parse_do
#-------------------------------------------
  def parse_while
    p "Begin parse_while"
    parse_expr

    parentNode = @curTree.first.linkBody[@curTree.first.begOp]
    parentNode.begBody = @prevToken

    parse_ops

    if @curTree.last.typeNode == :blockNode
      parentNode.begBody = @curTree.last.begOp
    end

    p "TheEnd of parse_while"
  end # def parse_while
#-------------------------------------------
  def parse_expr
    p "Begin parse_expr"

    @prevToken = @tokQueue.shift
    if @prevToken.tok != :lparen then
      p     "====ERROR parse_expr!!!============"
      raise "====ERROR parse_expr!!!============"
      return
    end
    countLParen = 1;
    while countLParen > 0 do
      @prevToken = @tokQueue.shift
      tok = @prevToken.tok
      if tok == :lparen
        countLParen+=1
      elsif tok == :rparen
        countLParen-=1
      else
        p "other = "+tok.to_s
      end
    end
    p "TheEnd of parse_expr"
  end # def parse_expr
#-------------------------------------------
  def parse_for
#TODO 
  #Обработка цикла for
  #Известен синтаксис для записи цикла:
  # 0.  слово for (Обработано ранее)
  # 1.  открывающая круглая скобка 
  # 2.  точка с запятой
  # 3.  точка с запятой
  # 4.  закрывающая круглая скобка
    p "Begin parse_for"
   # parse_expr
    
    parentNode = @curTree.first.linkBody[@curTree.first.begOp]
    
    @prevToken = @tokQueue.shift
    if @prevToken.tok != :lparen then
      p     "====ERROR parse_for !!!============"
      raise "====ERROR parse_for !!!============"
      return
    end 
    2.downto(1) {
        |n|
        p "LINE = "+@prevToken.line.to_s
        @prevToken = @tokQueue.shift
        if @prevToken.tok != :semicolon then
          p     "====ERROR parse_for !!!============"
          raise "====ERROR parse_for !!!============"
          return
        end 
          parentNode.updateOp = @prevToken   if n==2
    }

    @prevToken = @tokQueue.shift
    if @prevToken.tok != :rparen then
      p     "====ERROR parse_for !!!============"
      raise "====ERROR parse_for !!!============"
      return
    end 
    
    parentNode.begBody = @prevToken
   
    parse_ops
    if @curTree.last.typeNode == :blockNode
      parentNode.begBody = @curTree.last.begOp
    end
    parentNode.endBody = @curTree.last.endOp
    p "TheEnd of parse_for"
  end #parse_for
#-------------------------------------------
  def parse_stub
    p "it`s STUB!"
    @prevToken = @tokQueue.shift
  end
#-------------------------------------------
#-------------------------------------------
end # class PosToken


#=========================================================================================================
# Токен для БЛОКирования исходного текста 
#    т.е. вставки лексем "{" и "}"
#=========================================================================================================

class InsertedBlock
  # границы участка - позиции в списке токенов
  attr_accessor :token, # - ближайший токен
                :pos,   # = :after или :before
                :typeNode,   # = :begblock или :endblock или :sample
                :sid,    # - номер вставляемого sample
                :forUpdate  # - вставить этот сэмпл внутри условия цикла for. После него нужна запятая
  # !!! Хеш на входе 
  def initialize(arg)
    @token    = arg[:token]
    @pos      = arg[:pos]
    @typeNode = arg[:typeNode]
    @sid      = arg[:sid]
    @forUpdate = arg[:forUpdate]
  end

  def to_s
      if @pos == :after then "*>>" else "<<*" end +
      token.to_s
  end

  def inspect
    to_s
  end
end # class InsertedBlock