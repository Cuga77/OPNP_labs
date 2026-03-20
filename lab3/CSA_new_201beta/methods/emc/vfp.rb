#
# methods/emc/calculationVFP.rb - Calculation vector of final probabilities
#
# $Id: vfp.rb,v 1.2 2006/06/06 08:11:19 pac Exp $
#

module Methods

   module EMC

      require "objects/controller"

      class CVFP
         require "objects/emc/model"
         require "gui/icon"
         require "objects/model"
         require "gui/dialogs/simple"
         require "gui/main_window"

         NAME        = "Calculate vector final probability"
         MODEL_CLASS = Objects::EMC::Model
         ICON        = GUI::Icon::METHOD_ICON

         def execute(model)
            # Calculating final probability vector
            s = MTR.finalProbsVector(model).first
            # Saving result
            if GUI::Dialogs.confirm("Vector final probability: \n\n[#{s.to_a.first.join(", ")}]\n\n  Save?", "Result")
               filepath = FXFileDialog.getSaveFilename(GUI::MainWindow.instance, "Select file...", ".", "Text (*.txt)")
               return if filepath.empty?
               ext = File.extname(filepath)
               filepath += ".txt" if ext.empty?
               File.open(filepath, "w") do |f|
                  f.puts s
               end
            end
         end # execute

      end # class CVFP

      Objects::Controller.registerMethod(CVFP)

   end # module EMC

end # module Methods