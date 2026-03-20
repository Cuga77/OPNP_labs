#
# objects/emc/model.rb - Ergodic Markov Chain model definition
#
# $Id: model.rb,v 1.7 2006/01/12 12:09:07 pac Exp $
#

module Objects

   module EMC

      require "objects/model"

      class Model < Objects::Model
         require "objects/emc/top"
         require "objects/emc/link"

         # Make chain intensity visible
         attr_reader :intensity

         # Constructor
         def initialize(_name = "Ergodic Chain Model")
            super(_name)

            # Initializing fields
            @intensity = nil
         end # initialize

      protected

         def makeNode(type)
            return Top.new("t#{@last_id += 1}")
         end # makeNode

         def makeLink(source, dest)
            return EMC::Link.new(source, dest)
         end # makeLink

      end # class Model

   end # module EMC

end # module Objects
