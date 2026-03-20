#
# objects/amc/wizards.rb - Absorb Markov Chain wizards definition
#
# $Id: wizards.rb,v 1.2 2005/10/04 09:42:11 pac Exp $
#

module Objects

   module AMC
      require "objects/amc/model"
      require "objects/wizards"
      require "gui/icon"

      class AddTopWizard < AddNodeWizard
         MODEL = Objects::AMC::Model
         ICON  = GUI::Icon::PLACE_ICON

         Model.appendWizard self
      end # class AddTopWizard

      class AddAbsorbLinkWizard < AddLinkWizard
         MODEL = Objects::AMC::Model
         ICON  = GUI::Icon::ARC_ICON

         Model.appendWizard self
      end # class AddAbsorbLinkWizard

   end # module AMC

end # module Objects