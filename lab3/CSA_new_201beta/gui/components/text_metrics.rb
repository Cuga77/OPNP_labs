#
# gui/components/text_metrics.rb - Text formatting utility
#
# $Id: text_metrics.rb,v 1.3 2005/10/04 09:42:11 pac Exp $
#

module GUI

   # Класс TextMetrics, который умеет форматировать текст и выдавать параметры для диалогов.
   class TextMetrics

      # Атрибуты полученного текста
      attr_reader    :rows
      attr_reader    :cols

      attr_reader    :height
      attr_reader    :width

      # Конструктор, для создания метрик нужно передать text и ограничение по ширине текста
      def initialize(text, limit=nil, font=nil)
         # Предобработка входных данных
         text = text.split("\n")
         text[0] = " " if text.empty?
         font  = FXApp::instance.getNormalFont unless font
         wchar = font.getTextWidth(" ")

         # Сначала - инициализируем в базовые значения
         @rows   = text.length
         @cols   = text.collect { |s| s.length }.max
         @height = font.getTextHeight(text.first)     # Пока побудет высота одного столбца
         widths  = text.collect { |s| font.getTextWidth(s) }
         @width  = widths.max

         return if limit.nil? or @width < limit

         # Выпали за предел, нужно пересчитать размеры
         @width = limit
         @cols  = limit / wchar

         text.each do |str|
            width = font.getTextWidth(str)
            next if width <= limit

            # Длинная строка, которую нужно раскромсать
            width = 0
            str.split.each do |word|
               word_width = font.getTextWidth(word)
               if (width + word_width + wchar) <= limit
                  # Пока замечательно влазим
                  width += (word_width + wchar)
               elsif word_width <= limit
                  # Не влазим из-за того, что строка заполнилась
                  width  = word_width
                  @rows += 1
               else
                  # Не влазим из-за длинного слова
                  width = 0
                  word.split(//).each do |char|
                     char_width = font.getTextWidth(char)
                     if width + char_width <= limit
                        width += char_width
                     else
                        width = char_width
                        @rows += 1
                     end
                  end
               end
            end # each word
         end # each line

         @height *= @rows
      end # initialize

   end # class TextMetrics

end # module GUI