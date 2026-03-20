#
# methods/emc/transition_to_AMC.rb - Creating AMC equivalent for some EMC
#
# $Id: to_amc.rb,v 1.4 2006/06/06 08:11:19 pac Exp $
#

module Methods

   module EMC
      require "objects/controller"

      class Tr_AMC
         require "objects/emc/model"
         require "gui/icon"
         require "objects/model"

         NAME        = "Transition to AMC"
         MODEL_CLASS = Objects::EMC::Model
         ICON        = GUI::Icon::METHOD_ICON

         def execute(model)
            return Tr_AMC.to_amc(model)
         end # execute

         def Tr_AMC.to_amc(model)
            # Creating AMC
            amc = Objects::AMC::Model.new("Absorb Markov Chain of #{model.name}")
            # Appending nodes from EMC to AMC
            model.nodes.each { |i| amc.appendNode(i.name) }
            # Appending absorb top to AMC
            absorb = amc.appendNode("absorb")
            # Generating links parameters for AMC
            model.nodes.each do |n|
               sum = 0.0
               # Calculating common intensity for node
               n.outcome(model).collect { |l| sum += l.intensity }
               n.outcome(model).each do |l|
                  # Finding source node for AMC link
                  source = amc.nodes.find { |n| n.name == l.source.name }
                  # Finding destination node for AMC link
                  dest   = if (l.dest != model.nodes.first)
                     amc.nodes.find { |n| n.name == l.dest.name }
                  else
                     absorb
                  end
                  # Appending new link to AMC
                  link = amc.appendLink(source, dest)
                  # Calculating link probability
                  link.probability = l.intensity / sum
                  # Calculating link intensity
                  link.intensity   = 1.0 / sum
               end
            end
            # Appending "absorb" link
            link = amc.appendLink(absorb, absorb)
            # Calculating "absorb" link probability
            link.probability = 1.0
         
            return amc
         end # to_amc

      end # class MTR

      Objects::Controller.registerMethod(Tr_AMC)

   end # module Emc

end # module Methods