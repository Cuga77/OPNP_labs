#
# objects/spn/transition.rb - Petri transition definition
#
# $Id: transition.rb,v 1.3 2006/01/18 11:10:30 pac Exp $
#

module Objects

   module SPN

      require "objects/node"

      class Transition < Node

         attr_accessor :intensity
         alias csa1_intensity intensity
         alias csa1_intensity= intensity=

         # Constructor
         def initialize(name, intensity = 0.0)
            super(name)

            @intensity = intensity
         end # initialize

         def copy(to)
            super(to)
            
            to.intensity = intensity
         end # copy

         def execute(model)
            model.links.each do |ilink|
               next unless ilink.dest == self
               ilink.source.markerCount -= ilink.arity
            end
            model.links.each do |olink|
               next unless olink.source == self
               olink.dest.markerCount += olink.arity
            end
            return self
         end # execute

         def unexecute(model)
            model.links.each do |ilink|
               next unless ilink.dest == self
               ilink.source.markerCount += ilink.arity
            end
            model.links.each do |olink|
               next unless olink.source == self
               olink.dest.markerCount -= olink.arity
            end
         end # unexecute

      protected
      
         def firstSector(dx, dy)
            return (@rotated ? dy <= 0.0 : dx > 0.0)
         end # firstSector
      
         def secondSector(dx, dy)
            return false
         end # secondSector

         def thirdSector(dx, dy)
            return (@rotated ? dy > 0.0 : dx <= 0.0)
         end # thirdSector

         def fouthSector(dx, dy)
            return false
         end # fouthSector

         def connectionPoints(sector, nw, nh)
            case sector
               when FIRST_SECTOR_CONNECT
                  (@rotated ? top(nx + nw / 2, ny) : right(nx + nw, ny + nh / 2))
               when THIRD_SECTOR_CONNECT
                  (@rotated ? bottom(nx + nw / 2, ny + nh) : left(nx, ny + nh / 2))
            end
         end # connectionPoints

         def arrowPoints(sector, nw, nh)
            case sector
               when FIRST_SECTOR_CONNECT
                  (@rotated ? top_arrow(nx + nw / 2, ny) : right_arrow(nx + nw, ny + nh / 2))
               when THIRD_SECTOR_CONNECT
                  (@rotated ? bottom_arrow(nx + nw / 2, ny + nh) : left_arrow(nx, ny + nh / 2))
            end
         end # arrowPoints

      end # class Transition

   end # module SPN

end # module SPN
