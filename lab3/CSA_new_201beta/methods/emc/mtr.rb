#
# methods/emc/calculationMTR.rb - Calculation vector of mean return times
#
# $Id: mtr.rb,v 1.3 2006/06/06 08:11:19 pac Exp $
#

module Methods

   module EMC

      require "objects/controller"

      class MTR
         require "objects/emc/model"
         require "gui/icon"
         require "objects/model"
         require "gui/dialogs/simple"
         require "gui/main_window"

         require "matrix"

         NAME        = "Calculate mean times return"
         MODEL_CLASS = Objects::EMC::Model
         ICON        = GUI::Icon::METHOD_ICON

         def execute(model)
            t = MTR.meanTimesVector(model)
            # Saving vector
            if GUI::Dialogs.confirm("Mean times return: \n\n[#{t.join(", ")}]\n\n  Save?", "Result")
               filepath = FXFileDialog.getSaveFilename(GUI::MainWindow.instance, "Select file...", ".", "Text (*.txt)")
               return if filepath.empty?
               ext = File.extname(filepath)
               filepath += ".txt" if ext.empty?
               File.open(filepath, "w") do |f|
                  f.puts t
               end
            end
         end # execute

         # Calculating final probability vector using: m.t * s = b
         # - m: intensity matrix;
         # - b: special vector like this [0.0, 0.0, ..., 0.0, 1.0];
         # - s: final probability vector
         def MTR.finalProbsVector(model)
            # Calculating intensity matrix
            matrix = Methods.matrix(model)
            # Generating Matrix object
            m1 = Matrix.rows(matrix)
            # Appending 1.0 at the end of each matrix row
            last = model.nodes.size - 1
            model.nodes.size.times { |i| matrix[i][last] = 1.0 }
            # Generating b-vector
            col = []
            model.nodes.size.times { |i| col << 0.0 }
            col[last] = 1.0

            m = Matrix.rows(matrix)
            b = Matrix.rows([col])
            # Returning the result [FPV, intensity matrix]
            return [b * m.t * (m * m.t).inverse, m1]
         end # finalProbsVector

         def MTR.meanTimesVector(model)
            s, m = MTR.finalProbsVector(model)
            # Calculating mean times
            t = []
            model.nodes.size.times do |i|
               t[i] = 1.0 / (s[0,i] * m[i,i].abs)
            end
            return t
         end # meanTimesVector

         # Calculating mean time for model
         def MTR.t_pr(model)
            return MTR.meanTimesVector(model).first
         end

      end # class MTR

      Objects::Controller.registerMethod(MTR)

   end # module EMC

end # module Methods