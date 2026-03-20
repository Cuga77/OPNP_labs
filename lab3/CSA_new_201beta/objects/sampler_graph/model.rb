#
# objects/amc/model.rb - Absorb Markov Chain model definition
#
# $Id: model.rb,v 1.6 2006/01/12 12:09:07 pac Exp $
#

module Graphs

   module SamplerGraph

      require "objects/model"

      class Model < Objects::Model
         require "objects/sampler_graph/link"
         require "objects/sampler_graph/top"

         # Constructor
         def initialize(_name = "SamplerGraph Model")
            super(_name)
         end # initialize

      protected

         def makeNode(type)
            return Top.new("t#{@last_id += 1}")
         end # makeNode

         def makeLink(source, dest)
            return SamplerGraph::Link.new(source, dest)
         end # makeLink

      end # class Model

   end # module SamplerGraph

end # module Graphs
