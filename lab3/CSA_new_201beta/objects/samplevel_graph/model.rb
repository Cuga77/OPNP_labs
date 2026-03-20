#
# objects/amc/model.rb - Absorb Markov Chain model definition
#
# $Id: model.rb,v 1.6 2006/01/12 12:09:07 pac Exp $
#

module Graphs

   module SamplevelGraph

      require "objects/model"
      require "objects/sampler_graph/model"

      class Model < Objects::Model
        require "objects/samplevel_graph/link"
        require "objects/samplevel_graph/top"

        # Текст функции, соответствующий графу
        attr_accessor :src_func 

        # Счетчик КТ, расставляемых в теле функции
        attr_accessor :lastSampleID

        # Constructor
        def initialize(_name = "SamplevelGraph Model")
           super(_name)
           
           src_func = ""
           lastSampleID = 1000
        end # initialize

        def copyToSamplerGraph
           out = Graphs::SamplerGraph::Model.new(name)
  
           nodes.each do |node|
#              newNode = out.appendNode(node.name, Graphs::SamplerGraph::Top)
              newNode = out.appendNode(node.name)
              node.copyToSamplerGraph(newNode)
           end
           links.each do |link|
              link.copyToSamplerGraph(out.appendLink(makeSource(out, link), makeDest(out, link), link.name))
           end
  
           return out
        end # copyToSamplerGraph


      protected

         def makeNode(type)
            return Top.new("t#{@last_id += 1}")
         end # makeNode

         def makeLink(source, dest)
            return SamplevelGraph::Link.new(source, dest)
         end # makeLink
         
                 

      end # class Model

   end # module SamplevelGraph

end # module Graphs
