#
# methods/spn/spn2emc.rb - Transforming petri net to ergodic markov chain
#
# $Id: spn2emc.rb,v 1.7 2006/06/06 07:37:03 pac Exp $
#

module Methods

   module SPN

      require "objects/controller"

      class SPN2EMC
         require "objects/spn/model"
         require "gui/icon"
         require "objects/model"

         NAME        = "Transforming to Ergodic Markov Chain"
         MODEL_CLASS = Objects::SPN::Model
         ICON        = GUI::Icon::METHOD_ICON

         def execute(model)
            # Building EMC
            return SPN2EMC.to_emc(model)
         end # execute

         # Transforming to EMC
         def SPN2EMC.to_emc(model)
            # Building reachability graph
            rg = SPN2RG.build_rg(model)
            # Creating ergodic markov chain
            emc = Objects::EMC::Model.new("Ergodic Markov Chain of #{model.name}")

            # Adding nodes from RG to EMC
            rg.nodes.each { |n| emc.appendNode(n.emc_name) }

            # Adding links to EMC
            rg.links.each do |l|
               # Finding source top for new link
               source = emc.nodes.find { |n| n.name == l.source.emc_name }
               # Finding destination top for new link
               dest   = emc.nodes.find { |n| n.name == l.dest.emc_name }
               # Appending link to chain
               new_link = emc.appendLink(source, dest)
               # Finding relative transition for link
               trans = model.transitions.find { |t| t.name == l.name }
               # Updating link intensity with transition one
               new_link.intensity = trans.intensity
            end
            # Returning EMC
            return emc
         end # to_emc

      end # class SPN2EMC

      Objects::Controller.registerMethod(SPN2EMC)

   end # module SPN

end # module Methods
