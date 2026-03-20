module Methods

   module AMC
      require "objects/controller"

      class Level_detailed
 
         require "objects/amc/model"
         require "gui/icon"
         require "objects/model"
         require "gui/dialogs/simple"
         require "gui/main_window"

         NAME = "Method level detailed elaboration"
         MODEL_CLASS = Objects::AMC::Model
         ICON = GUI::Icon::METHOD_ICON

         def execute(model)
           # Вектор ресурсов
           l = []
           l_v = []
           model.nodes.each_with_index do |n, i|
              sum = 0.0
              n.outcome(model).each do |link|
                 sum+= link.probability*link.intensity                 
              end
              l[i] = Array.new(model.nodes.size-1){0.0} 
              l[i][i] = sum
              l_v << sum
           end
           l.pop
           l_v.pop
           # Диагональная матрица, составленная из вектора расурсов
           l_dg = Matrix.rows(l) 
           # Вычисление среднего времени возврата
           nl = fm * l_dg
           t_mean = 0.0
           nl.row(0).collect { |i| t_mean += i }
           # Квадрат элементов вектора ресурсов
           l_v  = Matrix.columns([l_v])
           l_sq  = l_v.collect { |x| x * x }
           fml_sq = fm * l_v
           fml_sq = fml_sq.collect { |x| x * x }
           # Вектор дисперсии           
           d = fm * (l_dg * fm * l_v * 2 - l_sq) - fml_sq
           # Диалог
           if GUI::Dialogs.confirm("Fundamental Matrix: \n\n#{fm}\n\n Mean time execution: #{t_mean}\n\n Deviation: #{d[0, 0]}\n\n  Save?", "Result")
              filepath = FXFileDialog.getSaveFilename(GUI::MainWindow.instance, "Select file...", ".", "Text (*.txt)")
              return if filepath.empty?
              ext = File.extname(filepath)
              filepath += ".txt" if ext.empty?
              File.open(filepath, "w") do |f|
                 f.puts t
              end
           end
         end # execute
         def detectTemplate(model, p_startTop, p_endTop)
           # атомарная операция
           return true if (p_startTop.name==p_endTop.name)
           # ветвление
           if (isCondStart(p_startTop)==true)
             return false if ( (p_endTop.income.size!=2) || (p_endTop.outcome.size>1) )
	       # деталзация матрицы
	       model.places.each { |top| tops_b << top if top.income.include?(p_startTop) }
	       model.places.each { |top| tops_e << top if top.outcome.include?(p_endTop) }	
	       return false if (tops_b.size!=tops_e.size)
	       tops_b.each_index do |i|
	         ret = detectTemplate(model, tops_b[i], tops_e[i])
	         return false if (ret==false)
	       end
	       return true
           end
           # цикл while
          if (isLoopWhileStart(p_startTop)==true)
               return false if (p_endTop.income.size!=1)
	      # детализация матрицы
	      top_b = model.places.find { |top| top.income.include?(p_startTop) }
	      top_e = model.places.find { |top| top.outcome.include?(p_startTop) }
	      ret = detectTemplate(model, top_b, top_e)
              return false if (ret==false)
	      return true
          end
          # цикл do-while
          if (isLoopDoWhileStart(p_startTop)==true)
              return false if (p_endTop.income.size!=1)
	      # детализация матрицы
	      top_b = model.places.find { |top| top.income.include?(p_startTop) }
	      top_e = model.places.find { |top| top.outcome.include?(p_startTop) }
	      ret = detectTemplate(model, top_b, top_e)
              return false if (ret==false)
	      return true
          end
          # следование
          if ((p_startTop.outcome.size==1)&&(p_startTop.income==nil))
              return false if (p_endTop.income.size!=1)
	      # детализация матрицы
	      return true
          end
          return false
        end
      
      end # class Level_detailed

      Objects::Controller.registerMethod(Level_detailed)

   end # module AMC
end # module Methods