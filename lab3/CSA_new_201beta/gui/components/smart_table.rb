#
# gui/components/smart_table.rb - Компонент таблица с управлением отрисовкой, редактированием и контролем.
#
# $Id: smart_table.rb,v 1.1 2005/11/15 14:33:05 pac Exp $
#

require "gui/fox"

module GUI

   require "gui/components/fast_table"

   # Класс SmartTable умеет редактировать ячейки, котролировать введенное значение,
   # и поддерживает расчитываемые ячейки после редактирования указанной.
   # Для ускорения обработки все расширенные операции над ячейками выполняются только как реакция на ввод пользователя.
   class SmartTable < FastTable
      include Responder

      # Дополнительные данные для заголовка, где храняться дополнительные данные и пользовательские функции обработки.
      class Control

         # Дополнительные данные пользователя, связанные с данным элементом заголовка
         attr_accessor  :data

         # Установите значение этого элемента в true, если хотите, чтобы значения столбца можно было редактировать
         attr_accessor  :editable

         # Стиль редактора ячейки по умолчанию FRAME_NONE|LAYOUT_EXPLICIT|TEXTFIELD_NORMAL,
         # можно также устанавливать флаги TEXTFIELD_REAL или TEXTFIELD_INTEGER.
         attr_accessor  :style

         # Метод, вызваемый для создания редактора ячейки с параметрами row, col и item.
         # Для уточнения смотрите SmartTable#createItemEditor
         attr_accessor  :createEditor

         # Метод, вызываемый для проверки редактора ячейки с параметрами row, col и editor.
         # В случае проблем, данный метод должен вернуть false, если все в порядке - true
         # Для уточнения смотрите SmartTable#validateItemEditor
         attr_accessor  :validateEditor

         # Метод, необходимый для перекладывания данных из редактора обратно в ячейку.
         # Вызывается с параметрами row, col, editor, item.
         # Должен вернуть true если значение изменилось и false если осталось прежним.
         # Для уточнения смотрите SmartTable#postItemEditor
         attr_accessor  :postEditor

         # Метод, вызываемый после того, как новые данные помещены в ячейку.
         # Вызывается с параметрами row, col, item.
         # Для уточнения смотрите SmartTable#itemEdited
         attr_accessor  :itemEdited

      end # Class Control

      # "Умный" элемент для отрисовки в режиме view/edit
      class Item < FXTableItem
         def drawContent(table, dc, x, y, w, h)
            super(table, dc, x, y, w, h) unless table.drawItemContent(self, dc, x, y, w, h)
         end # drawContent
      end # FXTableItem


      # Атрибут, в котором храниться метод onClick для переключения по нажатию на левую кнопку мыши
      # Вызывается с параметрами таблица, строка, столбец и объект-событие
      attr_accessor  :onLeftClick

      # Атрибут, в котором храниться метод onRightClick, для реакции по нажатию на правую кнопку мыши
      # Вызывается с параметрами таблица, строка, столбец и объект-событие
      attr_accessor  :onRightClick

      # Атрибут, в котором храниться метод onDoubleClick для реакции по нажатию на левую кнопку мыши
      # Вызывается с параметрами таблица, строка и столбец
      attr_accessor  :onDoubleClick


      # Конструктор таблицы, с указанием параметров по умолчанию
      def initialize(owner, tgt=nil, sel=0, opts=0, x=0, y=0, w=0, h=0, pl=MARGIN, pr=MARGIN, pt=MARGIN, pb=MARGIN)
         super(owner, tgt, sel, opts, x, y, w, h, pl, pr, pt, pb)

         # Создаем поле для хранения редактора текущей ячейки
         @editor = nil

         # Привязка событий на их обработчики
         FXMAPFUNC(SEL_LEFTBUTTONPRESS,   0, :onMyLeftBtnPress)
         FXMAPFUNC(SEL_RIGHTBUTTONRELEASE,0, :onMyRightBtnRelease)
         FXMAPFUNC(SEL_DOUBLECLICKED,     0, :onMyDoubleClicked)
         FXMAPFUNC(SEL_KEYPRESS,          0, :onMyKeyPress)
         FXMAPFUNC(SEL_KEYRELEASE,        0, :onMyKeyRelease)
         FXMAPFUNC(SEL_FOCUSOUT,          0, :onMyFocusOut)
      end # initialize


      # Перегруженный метод для задания размеров таблицы. Автоматически создает контролы, если они не созданы.
      def setTableSize(new_rows, new_cols)
         # Делаем как раньше
         super(new_rows, new_cols)

         # Теперь создаем контролы
         header = getColumnHeader
         new_cols.times { |col| createControl(col) unless header.getItemData(col) }
      end # setTableSize


      # Метод для получения всех объектов управления данной таблицы
      def controls
         header = getColumnHeader
         result = Array.new(header.numItems)
         result.each_index { |col| result[col] = header.getItemData(col) }
         return result
      end # controls

      # Метод доступа к элементу управления
      def control(col)
         getColumnHeader.getItemData(col)
      end # control

      # Проверка, является ли данная таблица редактируемой. Вернем true если хотя бы одно поле является редактируемым.
      # Если control для поля не задан, считается что поле может быть изменено.
      def editable?
         self.controls.find { |c| c.nil? or c.editable }
      end # editable?

      # Перегруженный метод для создания нового элемента таблицы
      def createItem(text, icon=nil, ptr=nil)
         Item.new(text, icon, ptr)
      end # createItem

      # Метод отрисовки ячейки, рисующий редактор на месте ячейки
      def drawItemContent(item, dc, x, y, w, h)
         return (@editor and item == @editor.item and @editor.drawPosition(x, y, w, h))
      end # drawItemContent

      # Перегруженный метод перерисовки модифицированных ячеек
      def drawRange(dc, rlo, rhi, clo, chi)
         return unless 0 == @updateCounter

         super(dc, rlo, rhi, clo, chi)
         if @editor
            # Проверяем, лежит ли ячейка в диапазоне отрисовки
            ch = getColumnHeader
            rh = getRowHeader
            xl = ch.getItem(@editor.col).getPos
            xr = ch.getItem(@editor.col).getSize + xl
            yt = rh.getItem(@editor.row).getPos
            yb = rh.getItem(@editor.row).getSize + yt
            x0 = ch.getPosition
            y0 = rh.getPosition

            loseFocus unless 0 <= x0 + xl and 0 <= y0 + yt and x0 + xr <= ch.getWidth and y0 + yb <= rh.getHeight
         end
      end # drawRange

      # Перегруженный метод для установки текущей ячейки
      def setCurrentItem(r, c, notify=FALSE)
         loseFocus if @editor
         super(r, c, notify)
      end # setCurrentItem

   public

      # Обработчик нажатия на левую кнопку мыши. По этому событию мы переходим в режим редактирования.
      def onMyLeftBtnPress(sender, sel, event)
         # Обработка по умолчанию
         onLeftBtnPress(sender, sel, event)

         # Выясняем текущую ячейку и определяем место, куда кликнули
         row = rowAtY(event.win_y)
         col = colAtX(event.win_x)

         # Теперь вызываем метод смены фокуса
         gainFocus(row, col)

         # Нужно ли что-нибудь пользователю?
         @onLeftClick.call(self, row, col, event) if @onLeftClick

         return TRUE
      end # onMyLeftBtnPress

      # Обработчик нажатия на правую кнопку мыши.
      def onMyRightBtnRelease(sender, sel, event)
         loseFocus
         # Обработка по умолчанию
         onRightBtnRelease(sender, sel, event)

         # Если пользовательский метод задан, то обрабатываем его
         if @onRightClick
            # Выясняем текущую ячейку и определяем место, куда кликнули
            row = rowAtY(event.win_y)
            col = colAtX(event.win_x)

            # Нужно ли что-нибудь пользователю?
            @onRightClick.call(self, row, col, event)
         end

         return TRUE
      end # onMyRightBtnRelease

      # Обработчик двойного нажатия на левую кнопку мыши.
      def onMyDoubleClicked(sender, sel, event)
         # Нужно ли что-нибудь пользователю?
         @onDoubleClick.call(self, event.row, event.col) if @onDoubleClick
         return TRUE
      end # onMyDoubleClicked

      # Обработчик нажатия на кнопку
      
      #FIXME double onKeyPress in SmartTable::onMyKeyPress
      def onMyKeyPress(sender, sel, event)
         if @editor
            # Перенаправим нажатие в поле для редактирования
            #return TRUE if TRUE == @editor.edit.onKeyPress(sender, sel, event)
         end
         # Обработчик по умолчанию
         return onKeyPress(sender, sel, event)
      end # onMyKeyPress

      # Обработчик отжатия кнопки
      def onMyKeyRelease(sender, sel, event)
         if @editor
            # Перенаправим отжатие в поле для редактирования
            return TRUE if TRUE == @editor.edit.onKeyRelease(sender, sel, event)
         end
         # Обработчик по умолчанию
         return onKeyRelease(sender, sel, event)
      end # onKeyRelease

      # Обработчик потери фокуса, если у нас ячейка редактировалась, то мы должны отработать сохранение данных.
      def onMyFocusOut(sender, sel, event)
         loseFocus
         return onFocusOut(sender, sel, event)
      end # onMyFocusOut

   protected   # Методы, необходимые для создания более продвинутых таблиц

      # Стиль для редактора по умолчанию
      DEFAULT_EDITOR_STYLE = FRAME_NONE|LAYOUT_EXPLICIT|TEXTFIELD_NORMAL

      # Класс ItemEditor необходим для реализации отрисовки ячейки в режиме редактирования.
      # Он перенаправляет все события в объект-редактор.
      class ItemEditor

         attr_reader    :item
         attr_reader    :edit

         attr_reader    :row
         attr_reader    :col

         # Конструктор
         def initialize(table, item, edit, row, col)
            @item, @edit, @row, @col = item, edit, row, col
            @hgrid = table.isHorzGridShown ? 1 : 0
            @vgrid = table.isVertGridShown ? 1 : 0
            @edit.show
            @edit.setFocus
         end # initialize

         # Перегруженный метод для отрисовки содержимого ячейки
         def drawPosition(x, y, w, h)
            @edit.position(x + @hgrid, y + @vgrid, w - @hgrid, h - @vgrid)
            return true
         end # drawPosition

         # Метод для проверки, ту ли мы ячейку редактируем
         def position?(row, col)
            (@row == row and @col == col)
         end # postion?

         # Метод для перехода в режим просмотра
         def view
            @edit.hide
         end # view

      end # ItemEditor

      # Метод для создания новых данных управления поведением поля.
      # Данные автоматически привязываются к указанному столбцу.
      # Возвращает указатель на созданные данные.
      def createControl(col)
         item = getColumnHeader.getItem(col)
         ctrl = Control.new
         ctrl.data     = item.data
         ctrl.editable = true
         ctrl.style    = DEFAULT_EDITOR_STYLE
         # Поля createEditor, validateEditor, postEditor и itemEdited остаются nil,
         # что означает использование методов по умолчанию
         item.data = ctrl
         return ctrl
      end # createControl

      # Возвращает true, если указанная ячейка таблицы является редактируемой
      def editableItem?(row, col)
         if row < 0 or row >= numRows or col < 0 or col >= numColumns
            return false
         else
            ctrl = control(col)
            return (ctrl.nil? or ctrl.editable)
         end
      end # editableItem?

      # Возвращает редактор по умолчанию редактирования ячейки
      def createItemEditor(row, col, item)
         ctrl   = control(col)
         editor = FXTextField.new(self, 2, nil, 0, FRAME_NONE|LAYOUT_EXPLICIT)
         editor.hide
         editor.textStyle = (ctrl ? ctrl.style : DEFAULT_EDITOR_STYLE)
         editor.text = item.text
         editor.create
         return editor
      end # createItemEditor

      # Метод, вызываемый для проверки редактора ячейки.
      # В случае проблем, данный метод должен вернуть false, если все в порядке - true
      def validateItemEditor(row, col, editor)
         true
      end # validateItemEditor

      # Метод, необходимый для перекладывания данных из редактора обратно в ячейку.
      def postItemEditor(row, col, editor, item)
         if item.text == editor.text
            return false
         else
            item.text = editor.text
            return true
         end
      end # postItemEditor

      # Метод, вызываемый после того, как новые данные помещены в ячейку.
      def itemEdited(row, col, item)
      end # itemEdited

      def gainFocus(row, col)
         # Смотрим, можно ли эту ячейку редактировать
         return false unless editableItem?(row, col)

         # Проверим редактируема ли данная ячейка
         return true if @editor and @editor.position?(row,col)

         # Переходим к редактированию новой ячейки
         setCurrentItem(row, col, TRUE)

         ctrl = control(col)
         item = getItem(row, col)
         edit = (ctrl and ctrl.createEditor ? ctrl.createEditor.call(row, col, item) : createItemEditor(row, col, item))

         @editor = ItemEditor.new(self, item, edit, row, col)
         updateItem(row, col)

         return true
      end # gainFocus

      def loseFocus
         return unless @editor

         # Сохраняем редактор для блокировки повторного входа
         editor  = @editor
         @editor = nil

         # Посылаем событие редактору о завершении редактирования
         editor.edit.handle(self, FXSEL(SEL_COMMAND, SEL_FOCUSOUT), nil)

         row   = editor.row
         col   = editor.col
         ctrl  = control(col)
         # Проверяем содержимое на корректность
         valid = (ctrl.validateEditor ? ctrl.validateEditor.call(row, col, editor.edit) : validateItemEditor(row, col, editor.edit))

         # Выполняем действия по завершению редактирования
         if valid
            # Сбрасываем содержимое в ячейку назад
            changed = (ctrl.postEditor ? ctrl.postEditor.call(row, col, editor.edit, editor.item) : postItemEditor(row, col, editor.edit, editor.item))

            # Вызвываем функцию post если значение ячейки менялось
            if changed
               if ctrl.itemEdited
                  ctrl.itemEdited.call(row, col, editor.item)
               else
                  itemEdited(row, col, editor.item)
               end
            end
         end

         # Переходим в режим просмотра
         editor.view

         updateItem(row, col)
      end # loseFocus

   end # Class SmartTable

end # GUI

# Тестируем скорость обновления таблицы.
# Левый click добавляет ROWS_COUNT элементов без beginUpdate/endUpdate, правый click - с beginUpdate/endUpdate

if __FILE__ == $0

   include Fox
   include GUI

   # Пример вывода
   #
   # Минимум/Среднее/Максимум: 2.545749/5.040214/11.143921
   #
   # Минимум/Среднее/Максимум: 2.516529/4.997629/11.025927
   #
   # Вывод: Улучшение достигло 1.1%, но лучше контроль за рисованием + меньше мерцаний

   class SmartTableWindow < FXMainWindow

      # Количество строк, добавляемых по клику
      ROWS_COUNT = 10000
      COLS_COUNT = 5

      def initialize(app)
         # Запускаем конструктор базового класса
         super(app, "Smart Table", nil, nil, DECOR_ALL, 0, 0, 800, 600)

         # Создаем шрифт по умолчанию
         getApp.normalFont = FXFont.new(getApp(), "modern", 8, FONTWEIGHT_NORMAL, FONTSLANT_REGULAR, FONTENCODING_KOI8_R)

         # Menubar along the top
         menubar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

         # File menu
         filemenu = FXMenuPane.new(self)
         FXMenuCommand.new(filemenu, "Выход\tCtl-Q", nil, getApp(), FXApp::ID_QUIT)
         FXMenuTitle.new(menubar, "Файл", nil, filemenu)

         # Табличка для теста
         @table = SmartTable.new(self, nil, FXMainWindow::ID_LAST, LAYOUT_FILL|TABLE_COL_SIZABLE|TABLE_ROW_SIZABLE) do |t|
            t.setTableSize(0, COLS_COUNT)
            t.setRowHeaderWidth(0)

            COLS_COUNT.times do |col|
                t.setColumnWidth(col, 100)
                t.setColumnText(col, "Столбец #{col}")
            end
            t.createControls

            # Пример функции, отслеживающей модифицированные элементы
            t.controls.each do |c|
               c.style |= TEXTFIELD_REAL
               c.itemEdited = proc { |r,c,i| puts "Изменился элемент [#{r}, #{c}] = #{i}" }
            end

            t.control(0).editable = false
            t.control(1).editable = false
         end
         addTestRows
      end # initialize

      def create
         super
         show(PLACEMENT_SCREEN)
      end # create

      def addTestRows
         @table.updateTable do |t|
            rowCount = t.numRows
            t.insertRows(rowCount, ROWS_COUNT)
            rowCount.upto(t.numRows - 1) do |row|
               COLS_COUNT.times { |col| t.setItemFloat(row, col, rand * row) }
            end
         end
      end # addTestRows
      private :addTestRows

   end # class SmartTableWindow

   # А вот теперь создаем приложение и запускаем его
   FXApp.new("Тест SmartTable", "НИЦ СПбГЭТУ") do |theApp|
      SmartTableWindow.new(theApp)
      theApp.create
      theApp.run
   end

end # if testing