#
# objects/emc/wizards.rb - Ergodic Markov Chain wizards definition
#
# $Id: wizards.rb,v 1.2 2005/10/04 09:42:11 pac Exp $
#

module Objects

   module EMC
      require "objects/emc/model"
      require "objects/wizards"
      require "gui/icon"

      class AddTopWizard < AddNodeWizard
         MODEL = Objects::EMC::Model
         ICON  = GUI::Icon::PLACE_ICON

         Model.appendWizard self
      end # class AddTopWizard

      class AddErgodicLinkWizard < AddLinkWizard
         MODEL = Objects::EMC::Model
         ICON  = GUI::Icon::ARC_ICON

         Model.appendWizard self
      end # class AddErgodicLinkWizard

   end # module EMC

end # module Objects