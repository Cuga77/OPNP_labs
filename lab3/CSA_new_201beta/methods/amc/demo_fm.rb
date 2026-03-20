#
# methods/amc/calculation.rb - Calculation
#
# $Id: demo_fm.rb,v 1.7 2006/06/06 08:29:11 pac Exp $
#

module Methods

   module AMC
      require "objects/controller"

      class DemonstrationFM
         require "objects/amc/model"
         require "gui/icon"
         require "objects/model"
         require "gui/dialogs/simple"
         require "gui/main_window"

         NAME        = "Fundamental Matrix"
         MODEL_CLASS = Objects::AMC::Model
         ICON        = GUI::Icon::METHOD_ICON

         def execute(model)
            d, fm, nl = calculate(model)
            # Вычисление среднего времени возврата
            t_mean = 0.0
            nl.row(0).collect { |i| t_mean += i }
            # Диалог
            if GUI::Dialogs.confirm("Fundamental Matrix: \n\n#{fm}\n\n Mean time execution: #{t_mean}\n\n Deviation: #{d[0, 0]}\n\n  Save?", "Result")
               filepath = FXFileDialog.getSaveFilename(GUI::MainWindow.instance, "Select file...", ".", "Text (*.txt)")
               return if filepath.empty?
               ext = File.extname(filepath)
               filepath += ".txt" if ext.empty?
               File.open(filepath, "w") do |f|
                  f.puts fm, t_mean, d[0, 0]
               end
            end
         end # execute

         # Дисперсия
         def DemonstrationFM.deviation(model)
            dev = calculate(model).first[0,0]
            return (dev < 0.00001 ? 0.0 : dev)
         end # deviation

      private
      
         def self.calculate(model)
            # Calculating probability matrix
            prob_matrix = []
            model.nodes.each do |n1|
               row = []
               model.nodes.each_with_index do |n2, idx|
                  found = n1.outcome(model).find { |link| link.dest == n2 }
                  row[idx] = (found ? found.probability : 0.0)
               end
               p << row
            end
            # Подматрица переходов из невозвр. сост. в поглощающие
            q = p.clone
            q.pop
            q.each { |row| row.pop }
            q.each_index { |i| q[i].collect! { |x| x*(-1) }; q[i][i] += 1.0 }
            # Фундаментальная матрица
            fm = Matrix.rows(q).inverse
            # Вектор ресурсов
            l = []
            l_v = []
            model.nodes.each_with_index do |n, i|
               sum = 0.0
               n.outcome(model).each { |link| sum += link.probability * link.intensity }
               l[i] = Array.new(model.nodes.size-1) { 0.0 }
               l[i][i] = sum
               l_v << sum
            end
            l.pop
            l_v.pop
            # Диагональная матрица, составленная из вектора расурсов
            l_dg = Matrix.rows(l) 
            # Квадрат элементов вектора ресурсов
            l_v  = Matrix.columns([l_v])
            l_sq  = l_v.collect { |x| x * x }
            fml_sq = (fm * l_v).collect { |x| x * x }
            # Вектор дисперсии           
            d = fm * (l_dg * fm * l_v * 2 - l_sq) - fml_sq
            
            return [d, fm, fm * l_dg]
         end # calculate

      end # class demonstrationFM

      Objects::Controller.registerMethod(DemonstrationFM)

   end # module AMC

end # module Methods