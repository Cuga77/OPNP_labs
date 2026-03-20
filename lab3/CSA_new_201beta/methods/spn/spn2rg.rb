#
# methods/petri/spn2rg.rb - Buildind reachability graph of petri net
#
# $Id: spn2rg.rb,v 1.6 2006/06/06 07:37:03 pac Exp $
#

module Methods

   module SPN

      require "objects/controller"

      class SPN2RG
         require "objects/spn/model"
         require "gui/icon"
         require "objects/model"

         NAME        = "Building Reachability Graph"
         MODEL_CLASS = Objects::SPN::Model
         ICON        = GUI::Icon::METHOD_ICON

         def execute(model)
            return SPN2RG.build_rg(model.copy)
         end # execute

         def SPN2RG.build_rg(model)
            # Looking for subnets and converting them first
            model.super_transitions.each do |t|
               if t.subnet
                  # Transforming subnet to EMC
                  sub_emc = SPN2EMC.to_emc(t.subnet)
                  # Calculating intensity for super_transition
                  time    = Methods::EMC::MTR.t_pr(sub_emc)
                  # Transforming EMC to AMC
                  sub_amc = Methods::EMC::Tr_AMC.to_amc(sub_emc)
                  # Calculating deviation for subnet AMC
                  dev     = Methods::AMC::DemonstrationFM.deviation(sub_amc)
                  # Calculating super-transition intensity
                  t.intensity = 1 / (time + Math.sqrt(dev))
               end
            end
            # Building RG
            rg = Objects::Model.new("Reachability Graph of #{model.name}")
            build(model, rg)
            return rg
         end # build_rg

         # Building Reachability Graph
         def SPN2RG.build(model, rg, trans = nil, mark = nil)
            # Creating first top of result chain
            m = marker(model)
            name = build_name(m)
            # Finding if there's duplicate top
            if top = duplicate_top(name, rg)
               rg.appendLink(mark, top, trans.name) if mark
               return
            end
            # Appending new node to RG
            top = rg.appendNode(name)
            # Appending link to RG if previous top given
            rg.appendLink(mark, top, trans.name) if mark
            # Forming name for EMC's top
            top.emc_name = name_by_marker(m, model)

            # Building array of enabled transitions...
            enabled_trans = []
            model.transitions.each do |t|
               enabled = true
               t.income(model).each do |ilink|
                  unless (ilink.arity <= ilink.source.markerCount)
                     enabled = false
                     break
                  end
               end
     
               enabled_trans << t if enabled
            end
            # ... if it's empty, getting next top
            return if enabled_trans.empty?

            # Executing all enabled transitions
            enabled_trans.each do |t|
               build(model, rg, t.execute(model), top)
               t.unexecute(model)
            end
         end # build

         # Builds begin state contains marker count in every position
         def SPN2RG.marker(model)
            model.places.collect { |p| p.markerCount }
         end # build_begin_state        

         # Returns tops' names of (model) by (marker)
         def SPN2RG.name_by_marker(marker, model)
            names = []
            model.places.each_with_index do |p, i|
               names << "#{p.name}(#{p.markerCount})" if marker[i] != 0
            end
            return names.join("")
         end # name_by_marker
        
         # Builds name for (state)
         def SPN2RG.build_name(state)
            return state.join(",")
         end # build_name

         # Returns true if (top) is duplicate in state space
         def SPN2RG.duplicate_top(mark, state_space)
            state_space.nodes.find { |n| n.name == mark }
         end # duplicate_top

      end # class SPN2RG
    
      Objects::Controller.registerMethod(SPN2RG)
        
   end # module SPN

end # module Methods
