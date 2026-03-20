#
# gui/components/very_smart_table.rb - Компонент таблица с возможностью установки стиля редактирования в каждой ячейке.
#
# $Id: very_smart_table.rb,v 1.1 2005/11/21 08:22:00 pac Exp $
#

require "gui/fox"

module GUI

   require "gui/components/smart_table"

   class VerySmartTable < SmartTable
      include Responder

      # Конструктор таблицы, с указанием параметров по умолчанию
      def initialize(owner, tgt=nil, sel=0, opts=0, x=0, y=0, w=0, h=0, pl=MARGIN, pr=MARGIN, pt=MARGIN, pb=MARGIN)
         super(owner, tgt, sel, opts, x, y, w, h, pl, pr, pt, pb)

         # Создаем поле для хранения редактора текущей ячейки
         @styles = {}
      end # initialize

      def setItemEditorStyle(row, col, style)
         @styles["#{row}:#{col}"] = style
      end # setItemStyle

      # Возвращает редактор по умолчанию редактирования ячейки
      def createItemEditor(row, col, item)
         ctrl       = control(col)
         ctrl.style = @styles["#{row}:#{col}"]

         editor = FXTextField.new(self, 2, nil, 0, FRAME_NONE|LAYOUT_EXPLICIT)
         editor.hide
         editor.textStyle = (ctrl ? ctrl.style : DEFAULT_EDITOR_STYLE)
         editor.text = item.text
         editor.create
         return editor
      end # createItemEditor

   end # Class VerySmartTable

end # GUI
