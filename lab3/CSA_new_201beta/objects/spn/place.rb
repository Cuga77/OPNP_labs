#
# objects/spn/place.rb - Petri place definition
#
# $Id: place.rb,v 1.2 2006/01/12 12:09:07 pac Exp $
#

module Objects

   module SPN

      require "objects/node"

      class Place < Node

         attr_accessor :markerCount
         alias csa1_markerCount markerCount
         alias csa1_markerCount= markerCount=

         # Constructor
         def initialize(_name, marker = 0)
            super(_name)

            @markerCount = marker
         end # initialize

         def copy(to)
            super(to)
            
            to.markerCount = markerCount
         end # copy

      end # class Place

   end # module SPN

end # module Objects
