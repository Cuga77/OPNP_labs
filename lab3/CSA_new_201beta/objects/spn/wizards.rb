#
# objects/spn/wizards.rb - Petri wizards definition
#
# $Id: wizards.rb,v 1.2 2006/01/12 12:09:07 pac Exp $
#

module Objects

   module SPN
      require "objects/spn/model"
      require "objects/wizards"
      require "gui/icon"

      class RotateWizard < Wizard
         MODEL = Objects::SPN::Model
         ICON  = GUI::Icon::ROTATE_ICON

         def apply(model)
            model.rotate
         end # apply

         Model.appendWizard self
      end # class RotateWizard

      class AddPlaceWizard < AddNodeWizard
         MODEL = Objects::SPN::Model
         ICON  = GUI::Icon::PLACE_ICON

         def apply(model)
            model.appendNode(nil, model.placeClass)
         end # apply

         Model.appendWizard self
      end # class AddPlaceWizard

      class AddTransitionWizard < AddNodeWizard
         MODEL = Objects::SPN::Model
         ICON  = GUI::Icon::TRANSITION_ICON

         def apply(model)
            model.appendNode(nil, model.transitionClass)
         end # apply

         Model.appendWizard self
      end # class AddTransitionWizard

      class AddSuperTransitionWizard < AddNodeWizard
         MODEL = Objects::SPN::Model
         ICON  = GUI::Icon::SUPER_TRANS_ICON

         def apply(model)
            model.appendNode(nil, model.superTransitionClass)
         end # apply

         Model.appendWizard self
      end # class AddSuperTransitionWizard

      class AddPetriLinkWizard < AddLinkWizard
         MODEL = Objects::SPN::Model
         ICON  = GUI::Icon::ARC_ICON

         Model.appendWizard self
      end # class AddPetriLinkWizard

   end # module SPN

end # module Objects