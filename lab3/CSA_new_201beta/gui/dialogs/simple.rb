#
# gui/dialogs/simple.rb - Simple and useful dialogs
#
# $Id: simple.rb,v 1.4 2005/12/19 11:08:21 pac Exp $
#

module GUI

   module Dialogs

      require "gui/dialogs/dialog_box"

      # Простой диалог для вывода строки
      def Dialogs.message(text, title="Message")
         DialogBox.message(title, text).execute(PLACEMENT_SCREEN)
      end # Dialogs.message

      # Диалог c текстом ошибки
      def Dialogs.error(text, title="Error")
         DialogBox.error(title, text).execute(PLACEMENT_SCREEN)
      end # Dialogs.error

      # Диалог с некоторой информацией
      def Dialogs.info(text, title="Information")
         DialogBox.info(title, text).execute(PLACEMENT_SCREEN)
      end # Dialogs.info

      # Диалог с подтверждение
      def Dialogs.confirm(text, title="Confirmation")
         return Fox::TRUE == DialogBox.confirm(title, text).execute(PLACEMENT_SCREEN)
      end # Dialogs.confirm

      # Диалог с предупреждением
      def Dialogs.warn(text, title="Warning")
         DialogBox.warn(title, text).execute(PLACEMENT_SCREEN)
      end # Dialogs.warn

      # Диалог для ввода строки
      def Dialogs.input(text, value=nil, title="Enter value")
         box = DialogBox.input(title, text, value)
         return Fox::TRUE == box.execute(PLACEMENT_SCREEN) ? box.value : nil
      end # Dialogs.input

      # Диалог для ввода вещ. числа
      def Dialogs.inputFloat(text, value=nil, title="Enter float")
         box = DialogBox.inputFloat(title, text, value)
         return Fox::TRUE == box.execute(PLACEMENT_SCREEN) ? box.value.to_f : nil
      end # Dialogs.inputFloat

      # Диалог для ввода целого числа
      def Dialogs.inputInteger(text, value=nil, title="Enter integer")
         box = DialogBox.inputInteger(title, text, value)
         return Fox::TRUE == box.execute(PLACEMENT_SCREEN) ? box.value.to_i : nil
      end # Dialogs.inputInteger

      # Диалог для выбора из списка строк
      def Dialogs.select(text, values=[], value=0, title="Select value")
         box = DialogBox.select(title, text, values, value)
         return Fox::TRUE == box.execute(PLACEMENT_SCREEN) ? box.value : nil
      end # Dialogs.select

   end # module Dialogs

end # module GUI