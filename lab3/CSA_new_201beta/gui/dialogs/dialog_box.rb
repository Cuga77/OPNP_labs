#
# gui/dialogs/dialog_box.rb - Base dialog box definition
#
# $Id: dialog_box.rb,v 1.3 2005/10/04 09:42:11 pac Exp $
#

module GUI

   module Dialogs

      class DialogBox < FXDialogBox
         require "gui/icon"
         require "gui/components/text_metrics"

         # Символы для доступа к параметрам
         TITLE  = :TITLE
         TEXT   = :TEXT
         ICON   = :ICON
         ACCEPT = :ACCEPT
         CANCEL = :CANCEL
         CLOSE  = :CLOSE
         LIST   = :LIST
         VALUE  = :VALUE
         FIELD_TYPE = :FIELD_TYPE

         # Конструктор объекта на основе хэша
         def initialize(settings)
            super(FXApp::instance.getRootWindow, settings[TITLE], DECOR_TITLE|DECOR_BORDER|DECOR_CLOSE, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4)

            content = FXVerticalFrame.new(self, LAYOUT_FILL)
            data = FXVerticalFrame.new(content, LAYOUT_FILL, 0, 0, 0, 0, 8, 8, 4, 4);
            # Поле для сообщения
            info = FXHorizontalFrame.new(data, LAYOUT_SIDE_LEFT, 0, 0, 0, 0, 0, 0, 0, 0, 20);
            # Иконка (если надо)
            if settings[ICON]
               icon = FXLabel.new(info, nil, nil, ICON_BEFORE_TEXT|LAYOUT_FILL)
               icon.setIcon(Icon.load(settings[ICON]))
            end

            # Само сообщение
            @txt = FXText.new(info, nil, 0, TEXT_READONLY|TEXT_WORDWRAP|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|JUSTIFY_RIGHT|LAYOUT_CENTER_Y) do |t|
               metrics = calcMetrics(settings[TEXT])
               t.backColor = getApp.getBaseColor
               t.setMarginTop(0)
               t.setMarginBottom(0)
               t.setMarginLeft(0)
               t.setMarginRight(0)
               t.text      = settings[TEXT]
               w = metrics.width + 20
               t.width     = w > 150 ? w : 150
               t.height    = metrics.height
               t.setVisibleRows(metrics.rows)
            end

            # Разделитель
            FXHorizontalSeparator.new(content, SEPARATOR_GROOVE|LAYOUT_FILL_X)
            # Поле для кнопок
            buttons = FXHorizontalFrame.new(content, LAYOUT_FILL_X|PACK_UNIFORM_WIDTH, 0, 0, 0, 0, 10, 10, 10, 10, 8)

            # Сначала проверяем и создаем список, если он не определен - текст для редактирования
            @list = nil
            @text = nil

            if settings.include?(LIST)
               @list = FXListBox.new(data, nil, 0, FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X|LISTBOX_NORMAL)
               @list.setNumVisible(5)
               settings[LIST].each { |str| @list.appendItem(str.kind_of?(String) ? str : str.name) }
               @list.setCurrentItem(settings[VALUE]) if settings.include?(VALUE)
            elsif settings.include?(VALUE)
               opts = TEXTFIELD_ENTER_ONLY|FRAME_SUNKEN|FRAME_THICK|LAYOUT_FILL_X|(settings[FIELD_TYPE] ? settings[FIELD_TYPE] : 0)
               @text = FXTextField.new(data, 20, self, ID_ACCEPT, opts)
               @text.text = settings[VALUE] if settings[VALUE]
            end

            # Теперь проверяем кнопочки и создаем каждую
            addCancelButton(buttons) if settings.include?(CANCEL)
            addAcceptButton(buttons) if settings.include?(ACCEPT)
            addCloseButton(buttons)  if settings.include?(CLOSE)
         end # initialize

         # Возвращает результат для INPUT_TEXT_STYLE и INPUT_LIST_STYLE если есть
         def value
            return @list.getCurrentItem if @list
            return @text.text if @text
            return nil
         end # value

         def execute(placement = PLACEMENT_SCREEN)
            super(placement)
         end # execute

         # Конструкторы для различных типов диалогов
         def DialogBox.message(title, text)
            DialogBox.new( {TITLE => title, TEXT => text, CLOSE => true } )
         end # DialogBox.message

         def DialogBox.error(title, text)
            DialogBox.new( {TITLE => title, TEXT => text, ICON => Icon::ERROR_ICON, CLOSE => true } )
         end # DialogBox.error

         def DialogBox.info(title, text)
            DialogBox.new( {TITLE => title, TEXT => text, ICON => Icon::INFORMATION_ICON, CLOSE => true } )
         end # DialogBox.info

         def DialogBox.confirm(title, text)
            DialogBox.new( {TITLE => title, TEXT => text, ICON => Icon::QUESTION_ICON, CANCEL => true, ACCEPT => true } )
         end # DialogBox.confirm

         def DialogBox.warn(title, text)
            DialogBox.new( {TITLE => title, TEXT => text, ICON => Icon::WARNING_ICON, CLOSE => true } )
         end # DialogBox.warn

         def DialogBox.input(title, text, value)
            DialogBox.new( {TITLE => title, TEXT => text, VALUE => value, CANCEL => true, ACCEPT => true } )
         end # DialogBox.input

         def DialogBox.inputFloat(title, text, value)
            DialogBox.new( {TITLE => title, TEXT => text, VALUE => value, FIELD_TYPE => TEXTFIELD_REAL, CANCEL => true, ACCEPT => true } )
         end # DialogBox.inputFloat

         def DialogBox.inputInteger(title, text, value)
            DialogBox.new( {TITLE => title, TEXT => text, VALUE => value, FIELD_TYPE => TEXTFIELD_INTEGER, CANCEL => true, ACCEPT => true } )
         end # DialogBox.inputInteger

         def DialogBox.select(title, text, list, value)
            DialogBox.new( {TITLE => title, TEXT => text, LIST => list, VALUE => value, CANCEL => true, ACCEPT => true } )
         end # DialogBox.select

         def show(placement)
            @text.setFocus if @text
            super(placement)
         end # show

      private

         def addCloseButton(owner)
            FXButton.new(owner, "Close", nil, self, ID_ACCEPT, BUTTON_INITIAL|BUTTON_DEFAULT|FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X, 0, 0, 0, 0, 30, 30, 4, 4).setFocus
         end # addCloseButton

         def addAcceptButton(owner)
            FXButton.new(owner, "Accept", nil, self, ID_ACCEPT, BUTTON_INITIAL|BUTTON_DEFAULT|FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT, 0, 0, 0, 0, 30, 30, 4, 4).setFocus
         end # addAcceptButton

         def addCancelButton(owner)
            FXButton.new(owner,"Cancel", nil, self, ID_CANCEL, FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT, 0, 0, 0, 0, 30, 30, 4, 4)
         end # addCancelButton

         def calcMetrics(text)
            width = TextMetrics.new(text).width
            width = 400 if width > 400

            return TextMetrics.new(text, width)
         end # calcMetrics

      end # class DialogBox

   end # module Dialogs

end # module GUI