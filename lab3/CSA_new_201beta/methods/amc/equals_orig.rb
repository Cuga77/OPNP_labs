#
# methods/amc/equals.rb - Equivalent transform of absorb chain
#
# $Id: equals.rb,v 1.4 2006/06/06 08:29:11 pac Exp $
#

module Methods

   module AMC
      require "objects/controller"

      class EqualsTransform
         require "objects/amc/model"
         require "gui/icon"
         require "objects/model"

         NAME        = "Equivalent transform"
         MODEL_CLASS = Objects::AMC::Model
         ICON        = GUI::Icon::METHOD_ICON

         def execute(model)
            out = model.copy
            out.name = "Equal absorb chain for '#{model.name}'"
            
            return equals(out)
         end # execute

      private

         def equals(model)
            # 1. remove parallel links
            model.links.each do |link|
               parallel = model.links.select { |x| x != link and x.dest == link.dest and x.source == link.source }
               parallel.each do |x|
                  probability = link.probability + x.probability
                  intensity   = (link.probability * link.intensity + 
                     x.probability * x.intensity) / probability
                  deviation   = (link.probability * link.deviation +
                         x.probability * x.deviation +
                         link.probability * (link.intensity ** 2) +
                         x.probability * (x.intensity ** 2)) / 
                         probability - (intensity ** 2)
                  link.probability = probability
                  link.intensity   = intensity
                  link.deviation   = deviation

                  model.current = x
                  model.removeLink
               end
            end

            # 2. remove circle links
            circles = model.links.select { |link| link.source == link.dest }
            circles.each do |circle|
               node = circle.source
               outs = node.outcome(model)
               next if outs.size == 1

               model.current = circle
               model.removeLink

               model.links.each do |link|
                  next unless outs.include? link
               
                  link.probability /= (1.0 - circle.probability)
                  link.intensity   += circle.probability * circle.intensity / (1.0 - circle.probability)
                  link.deviation   += circle.probability * circle.deviation /
                                   (1.0 - circle.probability) +
                                   circle.probability * (circle.intensity ** 2) /
                                   ((1.0 - circle.probability) ** 2)
               end
            end
            
            # 3. remove top
            model.nodes.each do |t|
               next if t.name == "absorb"

               ins  = t.income(model)
               outs = t.outcome(model)
               next if outs.empty? or ins.empty?
               ins.each do |input|
                  outs.each do |output|
                     new_link = model.appendLink(input.source, output.dest, "#{input.source.name}-->#{output.dest.name}")
                     new_link.probability = input.probability * output.probability
                     new_link.intensity   = input.intensity + output.intensity
                     new_link.deviation   = input.deviation + output.deviation
                  end
               end
               model.current = t
               model.removeNode

               equals(model)
            end

            # Calculating intensity of chain using converted link, that might be
            # only in chain after equals
            main_link = model.links.find { |x| x.source != x.dest }
            model.intensity = main_link.probability / (main_link.intensity + 3 * Math.sqrt(main_link.deviation)) if main_link

            return model
         end # equals

      end # class EqualsTransform

      Objects::Controller.registerMethod(EqualsTransform)

   end # module AMC

end # module Methods