#
# objects/wizards.rb - Base wizards definition, used for simple graph model
#
# $Id: wizards.rb,v 1.5 2005/12/19 11:12:42 pac Exp $
#

module Objects
   require "objects/model"
   require "gui/icon"

   class Wizard

      def initialize(owner, name, iconName, model)
         icon = GUI::Icon.load(iconName)
         FXToggleButton.new(owner, "\t#{name}", "\t#{name}", icon, icon, nil, 0, TOGGLEBUTTON_KEEPSTATE|FRAME_SUNKEN).connect(SEL_COMMAND) do |sender, sel, ptr|
            owner.onButtonPress(sender, method(:apply))
         end
      end # initialize

   protected

      def apply(model)
         return nil
      end # apply

   end # class Wizard

   class RemoveWizard < Wizard
      ICON  = GUI::Icon::PLACE_ICON

      def apply(model)
         model.remove
      end # apply

   end # class RemoveWizard

   class AddNodeWizard < Wizard
      MODEL = Objects::Model
      ICON  = GUI::Icon::PLACE_ICON

      def apply(model)
         model.appendNode
      end # apply

      Model.appendWizard self
   end # class AddNodeWizard

   class AddLinkWizard < Wizard
      MODEL = Objects::Model
      ICON  = GUI::Icon::ARC_ICON

      def apply(model)
         nodes = model.nodes.collect { |n| n.name }
         return nil if nodes.empty?

         return nil unless user = GUI::Dialogs.select("Select source", nodes)
         source = model.nodes[user]
         return nil unless user = GUI::Dialogs.select("Select dest", nodes)
         dest   = model.nodes[user]
         return nil unless source and dest

         model.appendLink(source, dest)
      end # apply

      Model.appendWizard self
   end # class AddLinkWizard

end # Objects