#
#  presampler/tokens.rb
#  v 1.40  2008/09/01
#
#  == работа с токенами:
#    - PosToken [class]
#      == токен и его положение в исходном тексте программы
#    - findFucnNames(tokStream, funcBounds, src_prg)
#      ==  Поиск имен функций в границах определения функций
#    - findFunctionBounds(tokStream)
#      == Поиск границ определения функций
#    - src2tokens(src_prg)
#      == Получение потока токенов из текста программы

# символы токенов - сопоставляются существенным лексемам текста программы
Tokens  =[:if, :else, :while, :for, :do, :semicolon, :lparen, :rparen,
          :begblock, :endblock, :remline, :begrem, :endrem, :sample, :ctrpnt, :timing]

# таблица описания токенов, формат таблицы:
# токен => [<RegExp для поиска | nil>, <строковое представление лексемы>]
TokensInfo = {
  :if    => [/\bif\b/, "if"],
  :else  => [/\belse\b/, "else"],
  :while => [/\bwhile\b/, "while"],
  :for   => [/\bfor\b/,"for"],
  :do    => [/\bdo\b/,"do"],
  :semicolon => [nil, ";"],
  :lparen    => [nil, "("],
  :rparen    => [nil, ")"],
  :begblock  => [nil, "{"],
  :endblock  => [nil, "}"],
  :remline   => [nil, "//"],
  :begrem    => [nil, "/*"],
  :endrem    => [nil, "*/"],

  :comma     => [nil, ","],

  :sample    => [nil, "CTRPOINT"],
  :ctrpnt    => [nil, "SAMPLE"],
  :timing    => [nil, "TIMING"]
}

#=========================================================================================================
#          Токен и его положение в исходном тексте программы
#=========================================================================================================
 class PosToken
  attr_accessor :tok    # символ токена
  attr_accessor :tokStr # лексема - строковое представление токена (дублирует tokensInfo)
  attr_accessor :line   # номер строки, где расположена лексема
  attr_accessor :pos    # позиция начала лексемы в строке

  def initialize(tok, tokStr, line, pos)
    @tok, @tokStr, @line, @pos = tok, tokStr, line, pos
  end

  def eql?(other)
    (@tok == other.tok) && (@line == other.line) && (@pos == other.pos)
  end

  def to_s
    "#{@tokStr}<#{@line},#{@pos}>  "
  end

  def inspect
    to_s
  end
end # class PosToken

#=========================================================================================================
#               Получение потока токенов из текста программы
#=========================================================================================================
  def src2tokens(src_prg)
    tokar = Array.new   # список списков токенов по строкам программы
    lnnb = -1           # номер текущей строки
    resSrc_prg = Array.new
    # Очистка исходного текста от строк и комментариев
    processText = clearTextFromNoise(src_prg)
#    p "CLEAR TEXT"
#    p src_prg
    # Получение потока токенов из текста программы и запись в tokar
    processText.each do |s|
      lnnb += 1;
      tokar[lnnb] = Array.new
      # бежим по всем возможным символам токенов
      Tokens.each do |tok|
        tokinfo = TokensInfo[tok]
        tokStr = tokinfo[1]
        rx = (tokinfo[0].nil?) ? tokStr : tokinfo[0]

        ss = StringScanner.new(s);
        while ss.scan_until(Regexp.union(rx))
          tokar[lnnb].push(PosToken.new(tok, tokStr, lnnb, ss.pos - tokStr.size))
        end
      end
      # сортируем токены в списке по месту нахождения в текущей строке
      tokar[lnnb] = tokar[lnnb].sort_by {|tok| tok.pos}
   end
   tokar.delete_if {|x| x.length==0} # - удаление пустых строк без токенов
   commentSamples(tokar,src_prg);
  end # def src2tokens(src_prg)

#=========================================================================================================
#               Поиск границ определения функций
#=========================================================================================================
  def findFunctionBounds(tokStream)
    # номера столбцов для символов токенов
    tok2col = {:lparen => 0, :rparen => 1, :begblock =>2, :endblock=>3}
    # номер столбца для символа "other"
    othercol = 4
    # управляющая таблица Конечного Автомата поиска
    findFuncAutomat = [
     # "("   ")"   "{"   "}"  other
      [ ], # 0 == Error
      [ 2,    1,    1,    1,   1 ], # 1 == начало поиска, ждем "("
      [ 2,    3,    2,    2,   2 ], # 2 == нашли "(", ждем ")"
      [ 3,    3,    4,    3,   3 ], # 3 == нашли ")", ждем "{"
      [ 4,    4,    5,    1,   4 ], # 4 == нашли "{", ждем "}", но можем получить еще "{"
      [ 5,    5,    5,    5,   5 ], # 5 == циклимся по "{" и по "}" при count>1
    ]

    curState = 1
    countLParen = 0     #  уровень вложенности блоковых скобок "{" и "}"
    inFinding = false   # = выполняется поиск
    lboundTok= nil      # левая  граница функции == токен "("
    begTok  = nil       # начало  тела   функции == токен "{"
    endTok = nil        # правая граница функции == токен "}
    funcBounds = Array.new

#    p "Tok Stream:"
#    print tokStream

    # Поиск ограничивающих токенов
    tokStream.each do |token|
      col = tok2col[token.tok]
      col = othercol if col.nil?
      nextState = findFuncAutomat[curState][col]
      case nextState
        when 1 then
          if inFinding
          # значит мы сюда попали из предыдущего поиска, пора зафиксировать границы
            endTok = token.dup
            funcBounds.push({:lboundTok => lboundTok, :begTok => begTok, :endTok => endTok})
            inFinding = false
            lboundTok = begTok = nil
          end
        when 2 then
          if lboundTok.nil?
            lboundTok = token.dup
            inFinding = true
          end
        when 4 then
          countLParen = 1;
          if begTok.nil?
            begTok = token.dup
            inFinding = true
          end
        when 5 then
          countLParen+=1 if token.tok==:begblock
          countLParen-=1 if token.tok==:endblock
          if countLParen==1
            nextState=4
          end
      end
      curState = nextState
    end
    return funcBounds
  end # def findFunctionBounds(tokStream)


#=========================================================================================================
#               Поиск имен функций в границах определения функций
#=========================================================================================================
## Побочный эффект: удаляет из tokStream нефункциональные скобки, те которые используются при перечислении
#                  аргументов функции
#=========================================================================================================
  def findFucnNames(tokStream, funcBounds, src_prg)
  # Поиск имени функции в тексте программы левее левых границ
#  p "Source:"
#  print src_prg
  funcBounds.each do |bound|
    rx =  /[a-zA-Z_]\w*/  # "идентификатор" == <буква><буква/цифра *>
    rx2 = /\w*[a-zA-Z_]/  # реверс "идентификатор"-а

    # ищем "имя функции" (идентификатор) в левой части строки, где найдено начало функции
    # если не нашли в первой строке, то продолжаем искать "имя функции" в предыдущих строках
    lbound = bound[:lboundTok]
    line, pos = lbound.line, lbound.pos
#    p line, pos
    s = src_prg[line][0...pos]
#    p s
    begin
      if str = StringScanner.new(s.reverse).scan_until(rx2)
         str = StringScanner.new(str.reverse).scan_until(rx)
      end
      s = src_prg[line-=1]
    end while str.nil? && (line>=0)
    bound[:tokStr] = str unless str.nil?
  end
  findAndDelFuncCalls(tokStream, funcBounds).each { |x|
      tokStream.delete(x);
    }
#  p "CLEAR TOKSTREAM = "
#  p tokStream
  return funcBounds
end # def findFucnNames(tokStream, funcBounds, src_prg)

#=========================================================================================================
#               Поиск вызовов функций из текста программы (удаление лишних "(" ")" )
#=========================================================================================================
  def findAndDelFuncCalls(tokStream, funcBounds)
  #ищем открывающие скобки, чтобы их удалить из списка токенов
  #если перед открывающей скобкой не while, if, for, <определение функции>, то
  #то нужно удалить эту открывающую скобу и все токены, которые между ней и её закрывающей
    structArray = Array.new
    [:while, :if, :for].each { |x| structArray.push(TokensInfo[x][1])}
    lastTok = nil
    parensArr = Array.new;
    depthLevel = 0;
    tokStream.each do |tok|
      if tok.tok == :rparen
        if depthLevel == 0
          lastTok = tok
        else
          parensArr.push(tok);
          depthLevel -= 1
          lastTok = tok
          next
        end
      elsif tok.tok != :lparen
        lastTok = tok
        next
      else
        is_bound = false
        #текущий токен - (. Ищем скобку в массиве границ функций
        funcBounds.each do |bound|
            is_bound = bound[:lboundTok].eql?(tok)
            break if is_bound
        end
        if is_bound
          lastTok = tok
          next
        end
        if lastTok and structArray.include?(lastTok.tokStr)
          lastTok = tok
          next
        end
        lastTok = tok
        parensArr.push(tok);
        depthLevel += 1
      end #if tok.tok == :rparen
    end #tokStream.each
    parensArr
  end


#=========================================================================================================
#               Изменение строк содержащих контрольные точки
#=========================================================================================================
#   Вход:  массив токенов исходной программы, исходный текст программы
#   Выход: Массив токенов без тех, которые обозначают вызовы КТ; измененный текст программы
#=========================================================================================================
def commentSamples(tokArr, srcPrg)
  resArr = Array.new;
  resSrcPrg = Array.new;
  inSample = 0;
  tokArr.each { |tokLine|
    tokLine.each { |tok|
      if (tok.tok == :sample) | (tok.tok == :ctrpnt) | (tok.tok == :timing)
        newStr = "/*"+ srcPrg[tok.line][tok.pos..srcPrg[tok.line].length-1];
        newStr = srcPrg[tok.line][0..tok.pos-1]+newStr if (tok.pos!=0)
        srcPrg[tok.line].replace(newStr)
        inSample = 1;
        #FixMe
      elsif (tok.tok == :semicolon) & (inSample == 1)
        newStr = srcPrg[tok.line][0..tok.pos+2]+"*/"+
          srcPrg[tok.line][tok.pos+2+tok.tokStr.length..srcPrg[tok.line].length-1];
        srcPrg[tok.line].replace(newStr)
        inSample = 0;
      elsif (tok.tok == :lparen) | (tok.tok == :rparen)
        resArr.push(tok) unless inSample == 1;
      else
        resArr.push(tok);
      end
    }
  }
#  p "Clear Tokens from SAMPLES ="
#  p resArr
#  p "Text with coomment = "
#  p srcPrg
  return resArr
end

#=========================================================================================================
#               Очистка исходного текста программы от шума (строк и комментариев)
#=========================================================================================================
  def clearTextFromNoise(srcPrg)
#    p "SOURCE TEXT"
#    p srcPrg
    clearText = Array.new
##    srcPrg.each {|line| clearText.push(line)}
##    clearText = srcPrg.clone
    inComment = false
    srcPrg.each { |st|
      s = st.dup
      clearText.push(s)
  #если текущая строка - продолжение коммментария, то надо определить конец комментария
    if inComment
        tempS = ""
        if s =~ /\*\//
          tempS = "#"*$`.length + "##" + $'
          s.replace(tempS)
          inComment = false
        else
          s.replace("#"*s.length)
          next
        end
    end
  # зачистка двойных кавычек или экранирования кавычек
    s.gsub!(/(\"\")|(\\\")/,'##')
  #  зачистка строк
    s.gsub!(/\".*\"/) {|part| part.replace "#"*part.length }
  # зачистка строчных комментариев
    s.gsub!(/\/\/.*/) {|part| part.replace "#"*part.length }
  # зачистка многострочный комментариев
    tempS = ""
    while  s =~ /\/\*/
      tempS += $` + "##"
      if $' =~ /\*\//
        tempS += "#"*($`.length + 2) + $'
      else
        inComment = true
        tempS += "#"*(s.length - s.index(/\/\*/) - 1)
        s.replace(tempS)
        break
      end
      s.replace(tempS)
      tempS = ""
    end
  } #each
#  p "SOURCE TEXT1"
#    p srcPrg
#  p "CLEAR TEXT:"
#    p clearText
  clearText
  end #clearTextFromNoise(srcPrg)