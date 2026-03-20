module Graphs

   module SamplevelGraph

      require "objects/controller"

      class ReplaceLink
         require 'objects/samplevel_graph/model'

         require "gui/icon"
         require "objects/model"

         NAME        = "Replace selected Link to Model of Link"
         MODEL_CLASS = Graphs::SamplevelGraph::Model
         ICON        = GUI::Icon::LINKREPLACE_ICON

         def execute(model)
            return ReplaceLink.replaceLink(model)
         end # execute

         def ReplaceLink.replaceLink(model)
           return unless model.current and model.current.kind_of? Graphs::SamplevelGraph::Link
           return if model.current.isEndLevel == 0
            
           deletedArc =  model.current
#TODO FIXME

           # Получаем номера Sample-ов, между которыми 
           # расположен кусок текста, соответствующий дуге
           infoStr, topStr, downStr = deletedArc.info, deletedArc.up, deletedArc.down
           topVal  =  topStr.split("->").collect!{|x| x.to_i}
           nSample1, nSample2 =  topVal[0], topVal[1]
           
      # Вычленяем кусок текста, заключенного между Sample-ми
           src_codeblock = getSampledBlockInSRC(model.src_func, nSample1, nSample2)
           
      # БЛОКируем выделенный кусок текста 
           # линейный список токенов (из построчного списка токенов)
           tokStream = src2tokens(src_codeblock)
           
           findAndDelFuncCalls(tokStream, Array.new).each { |x|
              tokStream.delete(x);
           }
           # Парсим список токенов и строим дерево структуры исходной программы
           parser = TokenParser2.new(tokStream)
           parser.isMultiLevel = false
           parser.parse_program
           # Генерирование списка Токенов для БЛОКирования текста
           insertedBlocks = parser.getInsertedBlocks
           # БЛОКирование исходного текста программы
           # Получаем БЛОКированный текст
           bl_codeblock = insertBlocksToSrc(src_codeblock, insertedBlocks)

           
      # SAMPLEируем блокированную версию выделенного куска текста 
           # линейный список токенов (из построчного списка токенов)
           tokStream = src2tokens(bl_codeblock)
           # Парсим список токенов и строим дерево структуры исходной функции
           parser = TokenParser2.new(tokStream)
           parser.parse_program
                
           parser.printProgTree

           insertedSamples = 
              parser.getCodeblockModelAndInsertToSGModel(model, deletedArc)
           #p insertedSamples

          # SAMPLEирование ИСХОДНОГО текста функции
          # Получаем SAMPLEированый текст
          bl_codeblock = insertSamplesToSrc(bl_codeblock, insertedSamples) 

      # Заменяем исходный кусок текста на SAMPLEированный
          model.src_func = setSampledBlockToSRC(model.src_func, nSample1, nSample2, bl_codeblock)
          p "model.src_func"
          p model.src_func

          #return "updateCanvas"
         end # to_emc

      end # class SPN2EMC



      Objects::Controller.registerMethod(ReplaceLink)

   end # module SPN

end # module Methods
