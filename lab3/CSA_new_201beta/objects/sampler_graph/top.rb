#
# objects/amc/top.rb - Absorb top definition
#
# $Id: top.rb,v 1.3 2005/10/04 09:42:11 pac Exp $
#

module Graphs

   module SamplerGraph

      require "objects/node"
      require "objects/sampler_graph/model"

      class Top < Objects::Node

        attr_accessor :nx
        attr_accessor :ny

        alias smp1_nx  nx
        alias smp1_nx= nx=

        alias smp1_ny  ny
        alias smp1_ny= ny=
      end # class Top

   end # module SamplerGraph

end # module Graphs
