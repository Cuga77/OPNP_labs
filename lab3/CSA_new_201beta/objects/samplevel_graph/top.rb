#
# objects/amc/top.rb - Absorb top definition
#
# $Id: top.rb,v 1.3 2005/10/04 09:42:11 pac Exp $
#

module Graphs

   module SamplevelGraph

      require "objects/node"
      require "objects/samplevel_graph/model"

      class Top < Objects::Node
      
        attr_accessor :nx
        attr_accessor :ny
        
        def copyToSamplerGraph(to)
           to.nx = nx
           to.ny = ny
           to.w  = w
           to.h  = h
        end # copyToSamplerGraph
      
      end # class Top

   end # module SamplevelGraph

end # module Graphs
