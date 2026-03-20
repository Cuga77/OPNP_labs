#
# gui/emc/model_view.rb - EMC model view including editor
#
# $Id: model_view.rb,v 1.5 2005/11/15 12:20:54 pac Exp $
#

module GUI
   require "gui/fox"

   module EMC

      class ErgodicModelView < ModelView
         require "objects/emc/wizards"
      end # class ErgodicModelView

   end # module EMC

end # module GUI
