#
# gui/icon.rb - Icons definition
#
# $Id: icon.rb,v 1.6 2006/01/11 13:32:23 pac Exp $
#              v 1.7 2008/09/01          msv

module GUI

   module Icon

      ERROR_ICON       = "error.png"
      INFORMATION_ICON = "information.png"
      QUESTION_ICON    = "question.png"
      WARNING_ICON     = "warning.png"
      MENU_START_ICON  = "small_application.png"
      MENU_NEW_ICON    = "filenew.png"
      MENU_LOAD_ICON   = "fileopen.png"
      MENU_SAVE_ICON   = "filesave.png"
      MENU_EXIT_ICON   = "exit.png"

      ADD_HANDLE_ICON  = "addhan.gif"
      ADD_TOKENS_ICON  = "addtok.gif"
      DEL_TOKENS_ICON  = "subtok.gif"
      ARC_ICON         = "arc.gif"
      REMOVE_ICON      = "des.gif"
      PLACE_ICON       = "place.gif"
      TRANSITION_ICON  = "imtra.gif"
      SUPER_TRANS_ICON = "sub.gif"
      INHIBITOR_ICON   = "inh.gif"
      MOVE_ICON        = "move.gif"
      ROTATE_ICON      = "toggle.gif"

      METHOD_ICON      = "small_methods.png"

      BLOCKING_ICON     = "blocking.png"
      SAMPLERING_ICON   = "samplering.png"
      SAMPLERTABLE_ICON = "samplertable.png"
      ARCREPLACE_ICON   = "arcreplace.gif"
      LINKREPLACE_ICON  = "linkreplace.gif"
      SAVECPP_ICON      = "savecpp.png"
      SAVEGRAPH_ICON    = "savegraph.png"
      OPENCPP_ICON      = "opencpp.png"


      def Icon.iconPath
         #return "icons"
         return "icons"
      end # iconPath

      def Icon.load(filename)
         return nil unless filename

         filename = iconPath + "/" + filename
         ext = File.extname(filename)
         File.open(filename, "rb") do |f|
            begin
               return case ext
                  when ".gif" then FXGIFIcon.new(FXApp::instance, f.read)
                  when ".png" then FXPNGIcon.new(FXApp::instance, f.read)
                  when ".ico" then FXICOIcon.new(FXApp::instance, f.read)
               end
            rescue => oops
               Dialogs.error(oops.message, "Load error...")
            end
         end
      end # Icon.load

   end # module Icon

end # module GUI