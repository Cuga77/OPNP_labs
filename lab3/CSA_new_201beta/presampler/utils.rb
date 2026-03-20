#
#  presampler/utils.rb
#  v 1.40  2008/09/01
#
#  == разные полезные методы работы с текстом программы и токенами

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# БЛОКирование исходного текста программы
# Вход:  1) src_prg == исходный текст
# 2) insertedBlocks == упорядоченный по возрастанию
#                      список Токенов для БЛОКирования текста
# Выход: БЛОКированный текст
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

def insertBlocksToSrc(src_prg, insertedBlocks)
  insertedBlocks.reverse.each do |insTok|

    token = insTok.token
    tokStr = TokensInfo[insTok.typeNode][1]
    line   = token.line
    begPos = token.pos
    endPos = begPos + insTok.token.tokStr.size

    if insTok.pos == :after then
      src_prg[line] = src_prg[line].insert(endPos, tokStr)
    else
      raise "insertSamplesToSrc: ELSE"
    end

  end
  src_prg
end # def insertBlocksToSrc(src_prg, insertedBlocks)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# SAMPLEирование исходного текста программы
# Вход:  1) bl_prg  == БЛОКированный текст
# 2) insertedSamples == упорядоченный по возрастанию
#                      список Токенов для SAMPLEирования текста
# Выход: SAMPLEированный текст
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

def insertSamplesToSrc(bl_prg, insertedSamples)
  # Тут и дальше - тупохиртая акробатика с Enter-ами
  # Удалим лишние Enter-ы, потом вставим Sampl-ы, а затем снова вернем Enter-ы
  bl_prg = bl_prg.map do |s|
    s.gsub("\n",'')
  end
  insertedSamples.reverse.each { |insTok|
    #p "TOKEN = " + insTok.token.to_s
    #p "forUpdate = " + insTok.forUpdate.to_s
  }
  delimiter = "%@%@%@%@%"

  insertedSamples.reverse.each do |insTok|
    token = insTok.token
    line   = token.line
    begPos = token.pos
    #p "TOKEN = " + insTok.token.to_s
    tokStr = delimiter + TokensInfo[insTok.typeNode][1] +
                "(" + insTok.sid.to_s + ")" +
               (insTok.forUpdate ? "," : ";") + delimiter

    if insTok.pos == :after then
      endPos = begPos + insTok.token.tokStr.size
      bl_prg[line] = bl_prg[line].insert(endPos, tokStr)
    elsif insTok.pos == :before
      endPos = begPos
      bl_prg[line] = bl_prg[line].insert(endPos, tokStr)
    else
      raise "insertSamplesToSrc: ELSE"
    end
  end

  bl_prg = bl_prg.map do |s|
    s.split(delimiter)
  end.flatten.map do |s|
    s.gsub("\n",'') + "\n"
  end

  bl_prg
end # def insertSamplesToSrc(src_prg, insertedBlocks)

