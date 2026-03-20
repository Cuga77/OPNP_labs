#
#  presampler/tokparser2.rb
#  v 1.40  2008/09/01
#
#  == разбор списка токенов, сборка "дерева" структуры программы:
#
#    - TokenParser2 [class]
#      - getProgramSGModel
#        == генерирование списка Токенов для SAMPLEирования 
#            уже Блокированного текста
#        == создание УГП программы

require 'strscan'
require "objects/samplevel_graph/model"
require "presampler/tokparser"
          


#===================================================================
#  Разбор сборка "дерева" структуры программы.
#===================================================================

class TokenParser2 < TokenParser

public

  def initialize(tokStream, _firstID = 0)
    super(tokStream)
    @sampleID = @topID = _firstID
  end

#-----------------------------------------------------------
# Генерирование списка Токенов для НАЧАЛЬНОГО SAMPLEирования текста ++
# ++ создание Простейшей УГП программы (одна дуга)
# !!! Используется дерево, построенное по Исходному тексту программы
#-----------------------------------------------------------
  def getProgramSGModel()
    samplesArray = Array.new

    #!! - Нас вызвали извне для Всей программы
    # тут мы знаем:
    # 1) текст программы - БЛОКированный
    # 2) => дерево 1го уровня == [[Parent], [BlockNode]]
    # 3) => вся программа сосредоточена в @progTree[1].linkBody
    tree = @progTree[1].linkBody
    model = Graphs::SamplevelGraph::Model.new("Sample")

    begTok = @progTree[1].begOp

    # начальная КТ - после первой скобки { программы
    samplesArray.push(InsertedBlock.
        new(:typeNode  => :sample ,
            :token => begTok ,
            :pos   => :after ,
            :sid   => curSampleID = incSampleID() ))
    tCur = model.appendNode
              
    # конечная КТ - перед последней скобкой } программы
    endTok = @progTree[1].endOp
    samplesArray.push(InsertedBlock.
        new(:typeNode  => :sample ,
            :token => endTok ,
            :pos   => :before , 
            :sid   => endSampleID = incSampleID() ))
    tEnd = model.appendNode

      
    link = model.appendLink(tCur,tEnd)
    link.setLinkInfo(
        :info => "simpleOp",
        :up => [[curSampleID, endSampleID]]
    )
    link.isEndLevel = isSimpleBlock(tree) ? 0 : 1
  

    # сортируем по положению в тексте программы
    samplesArray.sort! do |x,y|
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
    
    model.lastSampleID = sampleID
    
    return samplesArray, model
  end # def getProgramSGModel
 
#=========================================================================================================
# == "дерево Простое", т.е. соответствует строго линейному участку программы
#=========================================================================================================
  def isSimpleBlock(tree)
    return tree.select do |node| 
              !([:parentNode, :simpleOpNode].include? node.typeNode)
            end == []
  end # def isSimpleBlock(tree)

#=========================================================================================================
# Создание УГП блока кода (дерево которого - внутри экземпляра парсера),
# далее замена дуги deletedArc модели modelна на сформированную УГП ++
# Генерирование списка Токенов для SAMPLEирования блока кода
#=========================================================================================================
  def getCodeblockModelAndInsertToSGModel(model, deletedArc)  
  #FIXME
  #TODO
    samplesArray = Array.new

    tSrc = deletedArc.source
    tDst = deletedArc.dest
    
    # К этим вершинам прицепим сгенерируемый подграф куска программы
    tCur = tSrc
    tEnd = tDst 
      
    #!! - Нас вызвали извне для Куска программы
      # тут мы знаем:
      # 1) текст программы - на 1 уровень БЛОКированный
      # 2) => дерево 1го уровня == [[Parent], [<? Node>] {,[<? Node>]}]

#FIXME !!!

    infoStr, topStr, downStr = deletedArc.info, deletedArc.up, deletedArc.down
    topVal  =  topStr.split("->").collect!{|x| x.to_i}
    nSample1, nSample2 =  topVal[0], topVal[1]

    curSampleID, endSampleID = nSample1, nSample2 
    @sampleID = model.lastSampleID    
#    p "curSampleID = #{curSampleID}"
#    p "endSampleID = #{endSampleID}"
#    p "@sampleID   = #{@sampleID}"

    @model = model
    tree = @progTree
    
    
# Здесь такая вот ситуация, откуда бы мы сюда ни попали:
# 1) Это тело блока (программы или конструкции)
# 2) Уже расставлены КТ по ВНУТРЕННЫИ границам ...
# 3) Уже созданы вершины графа tCur и tEnd
# 4) Сейчас будем расставлять КТ и строить подграф внутренности блока
# начиная с tCur, далее соединим конец подграфа с tEnd

 # Если на 1м уровне больше 2х элементов, то это - список узлов
  if tree.size > 2 then
    tree.each_index do |index|
      node, nextNode = tree[index], tree[index+1]
      
      next if node.typeNode == :parentNode 
      
      
      # Ищем, куда бы вставить следующую КТ и вершину графа
      # результат в формате: [токен КТ, номер КТ, вершина_графа]
      res = if nextNode.nil? then
              p "nextNode.nil?"
              # наш оператор последний на данном уровне дерева
              # => замыкаем с окончанием блока, КТ уже есть
              [nil, endSampleID, tEnd] 
            elsif (nextNode.typeNode == :simpleOpNode) &&
                  (node.typeNode == :simpleOpNode) then
              # дальше будет тоже простой оператор 
              # => продолжаем линейный участок, ничего не делаем
              [ nil, nil, nil ]
            elsif ([:whileNode, :ifNode, :doNode, :forNode].include? nextNode.typeNode) ||
                  ( (nextNode.typeNode == :simpleOpNode) && 
                    (    node.typeNode != :simpleOpNode)    ) then
              # встаем после текущей конструкции
              [
                InsertedBlock.new(
                        :typeNode  => :sample ,
                        :token => node.endOp ,
                        :pos   => :after , 
                        :sid   => incSampleID() ),
                sampleID,
                @model.appendNode
              ]
            else 
            #FixMe НЕ ОБРАБАТЫВАЕТСЯ автономный блок "{...}"
              p     "====ERROR getCodeblockModelAndInsertToSGModel -> node.typeNode == :simpleOpNode, ELSE!!!============"
              raise "====ERROR getCodeblockModelAndInsertToSGModel-> node.typeNode == :simpleOpNode, ELSE!!!============"
      end # res = if nextNode.nil? then ...

      nextInsSample, nextSampleID, tNext = res[0], res[1], res[2]
      

      unless nextInsSample.nil?
        samplesArray.push(nextInsSample)
      else 
        if [:while, :ifNode, :doNode, :forNode].include? node.typeNode then
      #FixMe НЕ ОБРАБАТЫВАЕТСЯ автономный блок "{...}"
          msg = "====ERROR getCodeblockModelAndInsertToSGModel -> typeNode == " +
                  node.typeNode.to_s + ", ELSE!!!============"
          p msg
          # raise msg
        end
      end      


#############################################################################
#TODO
      unless tNext.nil?
        link = @model.appendLink(tCur,tNext)
        link.setLinkInfo(
                          :info => "simpleOp",
                          :up => [[curSampleID, nextSampleID]]
                         )
        link.isEndLevel = (node.typeNode == :simpleOpNode) ? 0 : 1
        
        tCur, curSampleID = tNext, nextSampleID
      end
    end # tree.each_index 
#############################################################################
#############################################################################
#############################################################################
#############################################################################
#############################################################################
    
 # это - одна конструкция
  else # if tree.size > 2
      node = tree[1]

      tNext        = tEnd
      nextSampleID = endSampleID 

    #################################################
    ####  //#\\  #  #\   /#  ###\\  #     ####   ####
    ####  #         #\\ //#  #   #  #     #      ####
    ####  \\#\\  #  # \#/ #  ###//  #     ###    ####
    ####      #  #  #     #  #      #     #      ####
    ####  \\#//  #  #     #  #      ####  ####   ####
    #################################################
      if (node.typeNode == :simpleOpNode) then
        link = @model.appendLink(tCur,tNext)
        link.setLinkInfo(
                          :info => "simpleOp",
                          :up => [[curSampleID, nextSampleID]]
                        )
        tCur, curSampleID = tNext, nextSampleID
      end # if (node.typeNode == :simpleOpNode)
      
      
    #################################################
    ####   #     #   #  #   #   #      ####      ####
    ####   #     #   #  #       #      #         ####
    ####   #  #  #   ####   #   #      ###       ####
    ####   #  #  #   #  #   #   #      #         ####
    ####   \\/ \//   #  #   #   ####   ####      ####
    #################################################
      if (node.typeNode == :whileNode) then
        # Делаем метку в начале Тела цикла
        samplesArray.push(InsertedBlock.
            new(:typeNode  => :sample ,
                :token => node.begBody ,
                :pos   => :after , 
                :sid   => begBodySampleID = incSampleID() ))
        tBegBody = @model.appendNode

        # Делаем метку в конце Тела цикла
        samplesArray.push(InsertedBlock.
            new(:typeNode  => :sample ,
                :token => node.endBody ,
                :pos   => :before , 
                :sid   => endBodySampleID = incSampleID() ))
        tEndBody = tCur

        # Кидаем дугу в начало Тела цикла
        @model.appendLink(tCur, tBegBody).setLinkInfo(
            :info => "while-body",
            :up => [
                [curSampleID,     begBodySampleID],
                [endBodySampleID, begBodySampleID]],
            :down => [
                [curSampleID,     nextSampleID],
                [endBodySampleID, nextSampleID]]
        )

        # Кидаем дугу ЧЕРЕЗ ТЕЛО цикла
        link = @model.appendLink(tBegBody, tEndBody)
        link.setLinkInfo(
                          :info => "body",
                          :up => [[begBodySampleID, endBodySampleID]]
                        )
        subTree = node.linkBody[1].linkBody
        link.isEndLevel = isSimpleBlock(subTree) ? 0 : 1
        
        # Кидаем дугу на Выход из цикла
        @model.appendLink(tCur, tNext).setLinkInfo(
            :info => "while-end",
            :up => [
                [curSampleID,     nextSampleID],
                [endBodySampleID, nextSampleID]],
            :down => [
                [curSampleID,     begBodySampleID],
                [endBodySampleID, begBodySampleID]]
        )
      
        tCur, curSampleID = tNext, nextSampleID
      end # if (node.typeNode == :whileNode)


    ###########################
    ####   ##    ######    ####
    ####         ##        ####
    ####   ##    #####     ####
    ####   ##    ##        ####
    ####   ##    ##        ####
    ###########################
      if (node.typeNode == :ifNode) then

        # Делаем метку в начале then-Тела 
        samplesArray.push(InsertedBlock.
            new(:typeNode  => :sample ,
                :token => node.begBody ,
                :pos   => :after , 
                :sid   => begBodySampleID = incSampleID() ))
        tBegBody = @model.appendNode
        
        # Делаем метку в конце then-Тела
        samplesArray.push(InsertedBlock.
            new(:typeNode  => :sample ,
                :token => node.endBody ,
                :pos   => :before , 
                :sid   => endBodySampleID = incSampleID() ))
        tEndBody = @model.appendNode

        # !!!! - Это сделаем в конце: "кидаем дугу в начало then-Тела"

        # Кидаем дугу ЧЕРЕЗ ТЕЛО then
        link = @model.appendLink(tBegBody, tEndBody)
        link.setLinkInfo(
                          :info => "then-body",
                          :up => [[begBodySampleID, endBodySampleID]]
                        )
        subTree = node.linkBody[1].linkBody
        link.isEndLevel = isSimpleBlock(subTree) ? 0 : 1

       
        # Кидаем дугу на Выход из then-Тела
        @model.appendLink(tEndBody, tNext).setLinkInfo(
            :info => "then-end",
            :up => [[endBodySampleID, nextSampleID]]
        )
        
       
        if node.linkElse.nil? then
           # Кидаем дугу на Выход в обход then-Тела
           @model.appendLink(tCur, tNext).setLinkInfo(
               :info => "if-end",
               :up   => [[curSampleID, nextSampleID]],
               :down => [[curSampleID, begBodySampleID]]
           )
        else
          # Делаем метку в начале else-Тела 
          samplesArray.push(InsertedBlock.
              new(:typeNode  => :sample ,
                  :token => node.begElse ,
                  :pos   => :after , 
                  :sid   => begElseSampleID = incSampleID() ))
          tBegElse = @model.appendNode
          
          # Делаем метку в конце else-Тела
          samplesArray.push(InsertedBlock.
              new(:typeNode  => :sample ,
                  :token => node.endElse ,
                  :pos   => :before , 
                  :sid   => endElseSampleID = incSampleID() ))
          tEndElse = @model.appendNode

          # Кидаем дугу в начало else-Тела 
          @model.appendLink(tCur, tBegElse).setLinkInfo(
              :info => "if-else",
              :up   => [[curSampleID, begElseSampleID]],
              :down => [[curSampleID, begBodySampleID]]   
          )

        # Кидаем дугу ЧЕРЕЗ ТЕЛО else
        link = @model.appendLink(tBegElse, tEndElse)
        link.setLinkInfo(
                          :info => "else-body",
                          :up => [[begElseSampleID, endElseSampleID]]
                        )
        subTree = node.linkElse[1].linkBody
        link.isEndLevel = isSimpleBlock(subTree) ? 0 : 1

         
          # Кидаем дугу на Выход из else-Тела
          @model.appendLink(tEndElse, tNext).setLinkInfo(
              :info => "else-end",
              :up => [[endElseSampleID, nextSampleID]]
          )
        end
        
        
        # Кидаем дугу в начало then-Тела 
        @model.appendLink(tCur, tBegBody).setLinkInfo(
            :info => "if-then",
            :up   => [[curSampleID, begBodySampleID]],
            :down => if node.linkElse.nil? 
                 then [[curSampleID, nextSampleID]]
                 else [[curSampleID, begElseSampleID]] end
        )
        
        
        tCur, curSampleID = tNext, nextSampleID
      end # if (node.typeNode == :ifNode)

    ###############################
    ####   #####\     /###\    ####
    ####   ##   \\   ##   ##   ####
    ####   ##   ##   ##   ##   ####
    ####   ##   ##   ##   ##   ####
    ####   ######/    \###/    ####
    ###############################
      if (node.typeNode == :doNode) then
         # Делаем метку в начале Тела цикла
        samplesArray.push(InsertedBlock.
            new(:typeNode  => :sample ,
                :token => node.begBody ,
                :pos   => :after , 
                :sid   => begBodySampleID = incSampleID() ))
        tBegBody = @model.appendNode
        
        # Кидаем дугу в начало Тела цикла
        @model.appendLink(tCur, tBegBody).setLinkInfo(
          :info => "do-null",:up => [[curSampleID, begBodySampleID]])
 

        # Делаем метку в конце Тела цикла
        samplesArray.push(InsertedBlock.
            new(:typeNode  => :sample ,
                :token => node.endBody ,
                :pos   => :before , 
                :sid   => endBodySampleID = incSampleID() ))
        tEndBody = @model.appendNode

        # Кидаем дугу ЧЕРЕЗ ТЕЛО then
        link = @model.appendLink(tBegBody, tEndBody)
        link.setLinkInfo(
                          :info => "body",
                          :up => [[begBodySampleID, endBodySampleID]]
                        )
        subTree = node.linkBody[1].linkBody
        link.isEndLevel = isSimpleBlock(subTree) ? 0 : 1


        # Кидаем дугу на новую итерацию из конца тела цикла
        @model.appendLink(tEndBody, tBegBody).setLinkInfo(
             :info => "do-body",
             :up   => [[endBodySampleID, begBodySampleID]],
             :down => [[endBodySampleID, nextSampleID]]
        )


        # Кидаем дугу на Выход из цикла
        @model.appendLink(tEndBody, tNext).setLinkInfo(
            :info => "do-end",
            :up   => [[endBodySampleID, nextSampleID]],
            :down => [[endBodySampleID, begBodySampleID]]
        )
        
        tCur, curSampleID = tNext, nextSampleID
      end # if (node.typeNode == :doNode)

    #################################################
    ####         ######   ####    ####           ####
    ####         ##      ##  ##   ## ##          ####
    ####         #####   ##  ##   ####           ####
    ####         ##      ##  ##   ## ##          ####
    ####         ##       ####    ##  ##         ####
    #################################################
#FIXME  FOR
      if (node.typeNode == :forNode) then
        # Делаем метку перед оператором обновления условия цикла
        samplesArray.push(InsertedBlock.
            new(:typeNode => :sample ,
                :token => node.updateOp ,
                :pos   => :after,
                :sid   => updateOpSampleID = incSampleID(),
                :forUpdate => true))
        tUpdateOp = @model.appendNode#("t" + incTopID())
        
        # Делаем метку в начале Тела цикла
        samplesArray.push(InsertedBlock.
            new(:typeNode  => :sample ,
                :token => node.begBody ,
                :pos   => :after , 
                :sid   => begBodySampleID = incSampleID() ))
        tBegBody = @model.appendNode#( "t"+incTopID() )

        # Делаем метку в конце Тела цикла
        samplesArray.push(InsertedBlock.
            new(:typeNode  => :sample ,
                :token => node.endBody ,
                :pos   => :before , 
                :sid   => endBodySampleID = incSampleID() ))
        tEndBody = @model.appendNode#( "t"+incTopID() )

        # Кидаем дугу в начало обновления условия (init)
        @model.appendLink(tCur, tUpdateOp).setLinkInfo(
                :info =>  "for-init",
                :up   => [[curSampleID,     updateOpSampleID]
              ])
        
        #Кидаем дугу из обновления условия в начало оператора (cond)
        @model.appendLink(tUpdateOp, tBegBody).setLinkInfo(
                :info => "for-cond",
                :up   => [[updateOpSampleID, begBodySampleID]],
                :down => [[updateOpSampleID, nextSampleID]])

        #Кидаем дугу через тело for
        link = @model.appendLink(tBegBody, tEndBody)
        link.setLinkInfo(
                :info => "for-body",
                :up   => [[begBodySampleID, endBodySampleID]])
        subTree = node.linkBody[1].linkBody
        print "LINK = #{link}"
        link.isEndLevel = isSimpleBlock(subTree) ? 0 : 1
        
        # Кидаем дугу на обновление условия
        @model.appendLink(tEndBody, tUpdateOp).setLinkInfo(
                :info => "for-update",
                :up     => [[endBodySampleID, updateOpSampleID]]
              )
        # Кидаем дугу на Выход из цикла
        @model.appendLink(tUpdateOp, tNext).setLinkInfo(
              :info   =>  "for-exit",
              :up     => [[updateOpSampleID, nextSampleID]],
              :down   => [[updateOpSampleID, begBodySampleID]]
              )
      
        tCur, curSampleID = tNext, nextSampleID
      end # if (node.typeNode == :whileNode)

  end # if tree.size > 2
  
 

    # сортируем по положению в тексте программы
    samplesArray.sort! do |x,y|
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
    
    model.current = deletedArc
    model.remove
  
     
    model.lastSampleID = @sampleID 
  
  
    return samplesArray
    
  end #getCodeblockModelAndInsertToSGModel
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end # class TokenParser2



#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#=========================================================================================================
#               ///
#FIXME tokparx
#=========================================================================================================
  def getSampledBlockInSRC(src_prg, nSample1, nSample2)
    joinSymbol = "\t"*20
    linedSrc = src_prg.join(joinSymbol)
  
    n1_end, n2_beg = getBoundsOfSampledBlockInSRC(linedSrc, nSample1, nSample2)
    
    return nil if (n1_end.nil? || n2_beg.nil?)
  
    return linedSrc[n1_end...n2_beg].split(joinSymbol)
  end # def getSampledBlockInSRC

#=========================================================================================================
#               ///
#FIXME tokparx
#=========================================================================================================
def setSampledBlockToSRC(src_prg, nSample1, nSample2, codeblock)
  joinSymbol = "\t"*20
  linedSrc        = src_prg.join(joinSymbol)
    
  n1_end, n2_beg = getBoundsOfSampledBlockInSRC(linedSrc, nSample1, nSample2)
  
  return src_prg if (n1_end.nil? || n2_beg.nil?)

  linedCodeblock  = codeblock.join(joinSymbol)
  linedSrc[n1_end...n2_beg] = linedCodeblock 

  src_prg = linedSrc.split(joinSymbol)
  return src_prg 
end # def setSampledBlockToSRC


#=========================================================================================================
#               ///
#FIXME tokparx
#=========================================================================================================
def getBoundsOfSampledBlockInSRC(linedSrc, nSample1, nSample2)
  pointTxt = TokensInfo[:sample][1]
  str1 = pointTxt+'[\s]*\([\s]*'+"#{nSample1}"+'[\s]*\)[\s]*;'
  rx1 = Regexp.compile(str1)
  str2 = pointTxt+'[\s]*\([\s]*'+"#{nSample2}"+'[\s]*\)[\s]*;'
  rx2 = Regexp.compile(str2)

  n1_beg = rx1 =~ linedSrc
  n2_beg = rx2 =~ linedSrc

  ss = StringScanner.new(linedSrc);
  ss.scan_until(Regexp.union(rx1))
  n1_end = ss.pos
  ss.scan_until(Regexp.union(rx2))
  n2_end = ss.pos

  if !(n1_end.nil? || n2_beg.nil?) && (n1_end < n2_beg)
    return n1_end, n2_beg
  end
  return nil, nil

end
