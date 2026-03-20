#
# objects/amc/link.rb - Absorb link definition
#
# $Id: link.rb,v 1.4 2006/01/12 12:09:07 pac Exp $
#

module Graphs

   module SamplerGraph

      require "objects/link"

      class Link < Objects::Link

         attr_accessor :info
         attr_accessor :up
         attr_accessor :down
         attr_accessor :nx
         attr_accessor :ny

         alias csa1_info info
         alias csa1_info= info=

         alias csa2_up  up
         alias csa2_up= up=

         alias csa3_down down
         alias csa3_down= down=

         alias smp1_nx  nx
         alias smp1_nx= nx=

         alias smp1_ny  ny
         alias smp1_ny= ny=

         # Constructor
         def initialize(_source, _dest)
            super(_source, _dest)
            @up   = ""
            @down = ""
            @info = ""
         end # initialize

         def copy(to)
            super(to)
         end # copyLinkProperties

         #задание значений параметров info, up, down
         def setLinkInfo(args)
            @info = args[:info]

            @up, @down = getUpDown(args)
         end
      end # class Link

   end # module SamplerGraph

end # module Graphs
