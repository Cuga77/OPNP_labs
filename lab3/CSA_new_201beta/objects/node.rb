#
# objects/node.rb - Base node definition, used for simple graph model
#
# $Id: node.rb,v 1.11 2006/07/20 11:22:33 pac Exp $
#

module Objects

   class Node < Entity
   
      def income(model)
         model.links.select { |l| l.dest == self }
      end # income

      def outcome(model)
         model.links.select { |l| l.source == self }
      end # outcome

   end # class Node

end # module Objects