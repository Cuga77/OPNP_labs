#
# objects/emc/link.rb - Ergodic link definition
#
# $Id: link.rb,v 1.4 2006/01/12 12:09:07 pac Exp $
#

module Objects

   module EMC

      require "objects/link"

      class Link < Objects::Link

         attr_accessor :intensity
         alias csa1_intensity intensity
         alias csa1_intensity= intensity=

         # Constructor
         def initialize(_source, _dest, intensity = 0.0)
            super(_source, _dest)

            @intensity = intensity
         end # initialize

         def copy(to)
            super(to)
            
            to.intensity = intensity
         end # copy

      end # class Link

   end # module EMC

end # module Objects
