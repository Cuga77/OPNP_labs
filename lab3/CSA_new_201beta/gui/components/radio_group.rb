#
# gui/components/radio_group.rb - Radio buttons group with some extra functionality
#
# $Id: radio_group.rb,v 1.4 2005/12/06 08:27:31 pac Exp $
#

module GUI

   class RadioGroup < FXVerticalFrame

      attr_writer :action

      def initialize(parent)
         super(parent, LAYOUT_SIDE_TOP|LAYOUT_FILL_X|LAYOUT_SIDE_LEFT|FRAME_THICK)

         @current = nil
         @action  = nil
      end # initialize

      def apply(*args)
         return unless @action

         @action.call(*args)
      end # apply

      def index
         return (@current ? indexOfChild(@current) : -1)
      end # index

      def onButtonPress(sender, action)
         @current = sender
         getChildren.each { |c| c.setState(false) unless c == @current }
         @current.setState(true)

         @action = action
      end # onButtonPress

   end # class RadioGroup

end # module GUI