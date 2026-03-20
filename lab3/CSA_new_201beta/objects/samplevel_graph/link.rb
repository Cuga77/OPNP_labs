#
# objects/amc/link.rb - Absorb link definition
#
# $Id: link.rb,v 1.4 2006/01/12 12:09:07 pac Exp $
#                     v 1.28 2008/09/01          msv

module Graphs

   module SamplevelGraph

      require "objects/link"

      class Link < Objects::Link

         attr_accessor :isEndLevel
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


         # Constructor
         def initialize(_source, _dest, linkInfo = "'nil'", isEndLevel = 0)
            super(_source, _dest)
            @isEndLevel = isEndLevel
            @up   = ""
            @down = ""
            @info = ""
         end # initialize

         def copy(to)
            super(to)
            to.up = up
            to.down = down
            to.info = info
            to.isEndLevel = isEndLevel
         end # copyLinkProperties

         def copyToSamplerGraph(to)
            to.nx = nx
            to.ny = ny
            to.w  = w
            to.h  = h
            to.up = up
            to.down = down
            to.info = info
         end # copyLinkProperties

         #задание значений параметров info, up, down
         def setLinkInfo(args)
            @info = args[:info]

            @up, @down = getUpDown(args)
         end

      end # class Link

   end # module SamplevelGraph

end # module Graphs