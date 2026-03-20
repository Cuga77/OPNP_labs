#
# gui/windows_manager.rb - Windows manager definition
#
# $Id: windows_manager.rb,v 1.4 2006/01/30 18:10:39 ldm Exp $
#

require "gui/fox"

module GUI

   class WindowsManager
      require "singleton"
      include Singleton

      attr_reader :currentWindow

      def initialize
         @winList = []
         @currentWindow = nil
      end # initialize

      def registerWindow(win)
         @winList << win

         return @winList.index(win)
      end # registerWindow

      def unregisterWindow(win)
         @winList.delete(win)
         if @winList.empty?
            @currentWindow = nil
         else
            @currentWindow = @winList.first
            showWindow(@currentWindow)
         end
      end # unregisterWindow

      def showWindow(wi)
         if wi.kind_of? Fixnum
            win = @winList[wi]
         else
            return MainWindow.instance.updateMenu(false) unless @winList.index(wi)
            win = wi
         end
         return MainWindow.instance.updateMenu(false) unless win
         win.show
         win.setFocus
         @currentWindow = win
         MainWindow.instance.updateMenu(true)
      end # showWindow

      def windowsList
         return @winList
      end

   end # class WindowsManager

end # module GUI
