#
# objects/amc/link.rb - Absorb link definition
#
# $Id: link.rb,v 1.4 2006/01/12 12:09:07 pac Exp $
#

module Objects

   module AMC

      require "objects/link"
      require "objects/amc/model"

      class Link < Objects::Link

         attr_accessor :probability
         alias csa1_probability probability
         alias csa1_probability= probability=
         
         attr_accessor :intensity
         alias csa2_intensity intensity
         alias csa2_intensity= intensity=
         
         attr_accessor :deviation
         alias csa3_deviation deviation
         alias csa3_deviation= deviation=

         # Constructor
         def initialize(_source, _dest, probability = 1.0, intensity = 0.0, deviation = 0.0)
            super(_source, _dest)

            @probability = probability
            @intensity   = intensity
            @deviation   = deviation
         end # initialize

         def copy(to)
            super(to)

            to.probability = probability
            to.intensity   = intensity
            to.deviation   = deviation
         end # copyLinkProperties

      end # class Link

   end # module AMC

end # module Objects
