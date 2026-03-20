#
# objects/spn/model.rb - Petri model definition
#
# $Id: model.rb,v 1.3 2006/01/18 11:10:30 pac Exp $
#

module Objects

   module SPN

      require "objects/model"

      class Model < Objects::Model
         require "objects/spn/link"
         require "objects/spn/place"
         require "objects/spn/transition"
         require "objects/spn/super_trans"

         PLACE_CLASS            = "Objects::SPN::Place"
         TRANSITION_CLASS       = "Objects::SPN::Transition"
         SUPER_TRANSITION_CLASS = "Objects::SPN::SuperTransition"

         # Constructor
         def initialize(_name = "SPN Model")
            super(_name)

            @places_last_id      = -1
            @trans_last_id       = -1
            @super_trans_last_id = -1
         end # initialize

         # Positions
         def places
            nodes.collect { |n| n if n.class == Place }.compact
         end # places

         # Transitions
         def transitions
            nodes.collect { |n| n if n.class == Transition or n.class == SuperTransition }.compact
         end # transitions

         # SuperTransitions
         def super_transitions
            nodes.collect { |n| n if n.class == SuperTransition }.compact
         end # super_transitions

         def placeClass
            PLACE_CLASS
         end # placeClass

         def transitionClass
            TRANSITION_CLASS
         end # transitionClass

         def superTransitionClass
            SUPER_TRANSITION_CLASS
         end # superTransitionClass

      private

         # Overloaded factory method for nodes creation
         def makeNode(type_id)
            type, letter, size = case type_id.to_s
               when PLACE_CLASS then [Place, "p", @places_last_id += 1]
               when TRANSITION_CLASS then [Transition, "t", @trans_last_id += 1]
               when SUPER_TRANSITION_CLASS then [SuperTransition, "s", @super_trans_last_id += 1]
            end
            return type.new("#{letter}#{size}")
         end # makeNode

         # Overloaded factory method for links creation
         def makeLink(source, dest)
            return [SPN::Link.new(source, dest), checkNodes(source, dest)]
         end # makeLink

         def checkNodes(source, dest)
            return "Can't create link from #{source.class} to #{dest.class}!" if source == dest or source.kind_of?(dest.class) or dest.kind_of?(source.class)
         end # checkNodes

      end # class Model

   end # module SPN

end # module Objects
