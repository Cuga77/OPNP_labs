#
# objects/spn/link.rb - Petri link definition
#
# $Id: link.rb,v 1.2 2006/01/12 12:09:07 pac Exp $
#

module Objects

   module SPN

      require "objects/link"

      class Link < Objects::Link

         attr_accessor :arity
         alias csa1_arity arity
         alias csa1_arity= arity=
         
         attr_accessor :inhib
         alias csa2_inhib inhib
         alias csa2_inhib= inhib=

         # Constructor
         def initialize(_source, _dest, arity = 1, inhib = false)
            super(_source, _dest)

            @arity = arity
            @inhib = inhib
         end # initialize

         def copy(to)
            super(to)

            to.arity = arity
            to.inhib = inhib
         end # copy

      end # class Link

   end # module SPN

end # module Objects