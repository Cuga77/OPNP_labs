#
# gui/amc/model_view.rb - AMC model view including editor
#
# $Id: model_view.rb,v 1.5 2005/11/15 12:20:54 pac Exp $
#

module GUI
   require "gui/fox"

   module AMC

      class AbsorbModelView < ModelView
         require "objects/amc/wizards"
      end # class AbsorbModelView

   end # module AMC

end # module GUI
