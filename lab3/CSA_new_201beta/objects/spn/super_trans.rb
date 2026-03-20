#
# objects/spn/super_trans.rb - Petri super transition definition
#
# $Id: super_trans.rb,v 1.4 2006/01/18 13:28:16 pac Exp $
#

module Objects

   module SPN

      class SuperTransition < Transition

         attr_accessor :subnet

         # Constructor
         def initialize(name, intensity = 0.0, subnet = Objects::SPN::Model.new("Subnet for '#{name}'"))
            super(name, intensity)

            @subnet    = subnet
         end # initialize

         def copy(to)
            super(to)
            
            to.subnet    = subnet
         end # copy

      end # class SuperTransition

   end # module SPN

end # module Objects
