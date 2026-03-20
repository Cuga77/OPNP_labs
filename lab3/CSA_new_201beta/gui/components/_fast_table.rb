#
# gui/components/fast_table.rb - Компонент таблица с управлением отрисовкой и сеткой.
#
# $Id: fast_table.rb,v 1.1 2005/11/15 14:33:05 pac Exp $
#

require "../fox"

module GUI

   # Класс FastTable умеет контролировать обновления для ускорения заполнения.
   # При необходимости возможно выключение сетки таблицы.
   # Таблица не является редактируемой.
   class FastTable < FXTable
      include Responder

      # Константа для обозначения границы по умолчанию
      MARGIN = FXTable::DEFAULT_MARGIN

      # Количество знаков после запятой для округления, по умолчанию округляем до 5-ти знаков
      FLOAT_PRECISION = 5

      # Атрибут, хранящий значение маски для округления чисел с плавающей запятой
      attr_accessor  :precision

      # Конструктор таблицы, с указанием параметров по умолчанию
      def initialize(owner, tgt=nil, sel=0, opts=0, x=0, y=0, w=0, h=0, pl=MARGIN, pr=MARGIN, pt=MARGIN, pb=MARGIN)
         super(owner, tgt, sel, opts, x, y, w, h, pl, pr, pt, pb)

         # Привязываемся к событию перерисовки
         FXMAPFUNC(SEL_PAINT, 0, :onMyPaint)

         # Создаем переменную с хранением обновления
         @updateCounter = 0

         # Создаем округление по умолчанию
         @precision = FLOAT_PRECISION
      end # initialize

      # Перегруженный метод для задания размеров таблицы. Автоматически центрирует заголовки.
      def setTableSize(new_rows, new_cols)
         # Делаем как раньше
         super(new_rows, new_cols)

         # Теперь устанавливаем выравнивание
         header = getColumnHeader
         new_cols.times { |col| header.setItemJustify(col,FXTableItem::CENTER_X) }
      end # setTableSize

      # Перегруженный метод для установки текущей ячейки, чтобы отрабатывать выходы за пределы.
      def setCurrentItem(row, col, notify=FALSE)
         limit = getNumRows
         return if limit <= 0
         if row < 0
            row = 0
         elsif row >= limit
            row = limit - 1
         end

         limit = getNumColumns
         return if limit <= 0
         if col < 0
            col = 0
         elsif col >= limit
            col = limit - 1
         end

         super(row, col, notify)
      end # setCurrentItem

      # Выведение в таблицу значения с указанным числом знаками после запятой
      def setItemFloat(row, col, value)
         setItemText(row, col, value)
      end # setItemFloat

      # Вызов данного метода блокирует перерисовки и сокращает время на изменения данных
      def beginUpdate
         @updateCounter += 1
      end # beginUpdate

      # Вызов данного метода разблокирует перерисовки
      def endUpdate
         @updateCounter -= 1 if @updateCounter > 0
         self.update if 0 == @updateCounter
      end # endUpdate

      # Проверка, находимся ли мы в состоянии обновления
      def update?
         (@updateCounter > 0)
      end # update?

      # Выполнение некоторого метода под контролем beginUpdate/endUpdate
      def updateTable
         begin
            beginUpdate
            yield(self)
         ensure
            endUpdate
         end
      end # updateTable

      # Перегруженные методы рисования, чтобы избежать излишных нагрузок
      def drawCell(dc, rlo, rhi, clo, chi)
         super(dc, rlo, rhi, clo, chi) if 0 == @updateCounter
      end # drawCell

      def drawRange(dc, rlo, rhi, clo, chi)
         super(dc, rlo, rhi, clo, chi) if 0 == @updateCounter
      end # drawRange

      # Перегруженный метод update, чтобы избежать излишных отрисовок
      def update(x=nil, y=nil, w=nil, h=nil)
         if 0 == @updateCounter
            if x
               super(x,y,w,h)
            else
               super()
            end
         end
      end # update

      # Перегруженный метод repaint, чтобы избежать излишных отрисовок
      def repaint(x=nil, y=nil, w=nil, h=nil)
         if 0 == @updateCounter
            if x
               super(x,y,w,h)
            else
               super()
            end
         end
      end # repaint

      def onMyPaint(sender, sel, event)
         return TRUE unless 0 == @updateCounter
         event.rect = FXRectangle.new(0, 0, width, height)
         return onPaint(sender, sel, event)
      end # onMyPaint

   end # Class FastTable

end # GUI

# Тестируем скорость обновления таблицы.
# Левый click добавляет SIZE элементов без beginUpdate/endUpdate, правый click - с beginUpdate/endUpdate

if __FILE__ == $0

   include Fox
   include GUI

   # Пример вывода
   #
   # Найдена и используется библиотека FXRuby версии 1.2.2
   # Добавляем 10000 строк без блокировки
   # ==> 2.945698 seconds
   # Добавляем 10000 строк без блокировки
   # ==> 4.558855 seconds
   # Добавляем 10000 строк без блокировки
   # ==> 2.932859 seconds
   # Добавляем 10000 строк без блокировки
   # ==> 8.648223 seconds
   # Добавляем 10000 строк без блокировки
   # ==> 2.780867 seconds
   # Добавляем 10000 строк без блокировки
   # ==> 3.913043 seconds
   # Добавляем 10000 строк без блокировки
   # ==> 11.143921 seconds
   # Добавляем 10000 строк без блокировки
   # ==> 6.843035 seconds
   # Добавляем 10000 строк без блокировки
   # ==> 2.545749 seconds
   # Добавляем 10000 строк без блокировки
   # ==> 4.08989 seconds
   # Минимум/Среднее/Максимум: 2.545749/5.040214/11.143921
   #
   # Найдена и используется библиотека FXRuby версии 1.2.2
   # Добавляем 10000 строк с блокировкой
   # ==> 2.919821 seconds
   # Добавляем 10000 строк с блокировкой
   # ==> 4.532147 seconds
   # Добавляем 10000 строк с блокировкой
   # ==> 2.922379 seconds
   # Добавляем 10000 строк с блокировкой
   # ==> 8.618086 seconds
   # Добавляем 10000 строк с блокировкой
   # ==> 2.745384 seconds
   # Добавляем 10000 строк с блокировкой
   # ==> 3.86355 seconds
   # Добавляем 10000 строк с блокировкой
   # ==> 11.025927 seconds
   # Добавляем 10000 строк с блокировкой
   # ==> 6.77454 seconds
   # Добавляем 10000 строк с блокировкой
   # ==> 2.516529 seconds
   # Добавляем 10000 строк с блокировкой
   # ==> 4.05793 seconds
   # Минимум/Среднее/Максимум: 2.516529/4.997629/11.025927
   #
   # Вывод: Улучшение достигло 1.1%, но лучше контроль за рисованием + меньше мерцаний

   class FastTableWindow < FXMainWindow

      # Количество строк, добавляемых по клику
      ROWS_COUNT = 10000
      COLS_COUNT = 5

      def initialize(app)
         # Запускаем конструктор базового класса
         super(app, "Fast Table", nil, nil, DECOR_ALL, 0, 0, 800, 600)

         # Создаем шрифт по умолчанию
         getApp.normalFont = FXFont.new(getApp(), "modern", 8, FONTWEIGHT_NORMAL, FONTSLANT_REGULAR, FONTENCODING_KOI8_R)

         # Menubar along the top
         menubar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)

         # File menu
         filemenu = FXMenuPane.new(self)
         FXMenuCommand.new(filemenu, "Выход\tCtl-Q", nil, getApp(), FXApp::ID_QUIT)
         FXMenuTitle.new(menubar, "Файл", nil, filemenu)

         # Табличка для теста
         @table = FastTable.new(self, self, FXMainWindow::ID_LAST, LAYOUT_FILL|TABLE_COL_SIZABLE|TABLE_ROW_SIZABLE) do |t|
            t.setTableSize(0, COLS_COUNT)
            t.setRowHeaderWidth(50)

            COLS_COUNT.times do |col|
                t.setColumnWidth(col, 100)
                t.setColumnText(col, "Столбец #{col}")
            end

            # Привязка нажатий кнопочек на таблице
            t.connect(SEL_LEFTBUTTONPRESS,  method(:addWithoutBlocking))
            t.connect(SEL_RIGHTBUTTONPRESS, method(:addWithBlocking))
         end
      end # initialize

      def create
         super
         show(PLACEMENT_SCREEN)
      end # create

      private

         def measure(text)
            puts text
            tm = Time.now
            yield
            tm = Time.now - tm
            puts "==> #{tm} seconds"
         end # measure

         def addTestRows
            rowCount = @table.numRows
            @table.insertRows(rowCount, ROWS_COUNT)
            
            #header = @table.getColumnHeader
            header = @table.getRowHeader
            p "sux" if header==nil
            header.setItemText(0,"1")
            
            rowCount.upto(@table.numRows - 1) do |row|
               COLS_COUNT.times { |col| @table.setItemText(row, col, "0");  }
               #@table.setItemText(row, 0, "1")

             end
             
             #meth =  @table.methods.sort
             #0.upto(meth.size-1) {|i| p meth[i]}
         end # addTestRows

         def addWithoutBlocking(sender, selector, data)
            Thread.new do
               measure("Добавляем #{ROWS_COUNT} строк без блокировки") do
                  addTestRows
               end
            end
            return 1
         end # addWithoutBlocking

         def addWithBlocking(sender, selector, data)
            Thread.new do
               measure("Добавляем #{ROWS_COUNT} строк с блокировкой") do
                  @table.updateTable { addTestRows }
               end
            end
            return 1
         end # addWithBlocking

   end # class FastTableWindow

   # А вот теперь создаем приложение и запускаем его
   FXApp.new("Тест FastTable", "НИЦ СПбГЭТУ") do |theApp|
      FastTableWindow.new(theApp)
      theApp.create
      theApp.run
   end

end # if testing