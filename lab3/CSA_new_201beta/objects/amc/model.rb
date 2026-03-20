#
# objects/amc/model.rb - Absorb Markov Chain model definition
#
# $Id: model.rb,v 1.6 2006/01/12 12:09:07 pac Exp $
#

module Objects

   module AMC

      require "objects/emc/model"

      class Model < Objects::EMC::Model
         require "objects/amc/link"
         require "objects/amc/top"

         # Constructor
         def initialize(_name = "Absorb Chain Model")
            super(_name)
         end # initialize

      protected

         def makeNode(type)
            return Top.new("t#{@last_id += 1}")
         end # makeNode

         def makeLink(source, dest)
            return AMC::Link.new(source, dest)
         end # makeLink

      end # class Model

   end # module AMC

end # module Objects
