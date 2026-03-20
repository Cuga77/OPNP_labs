#
# gui/emc/model_view.rb - SampLevelGraph model view including editor
#
#  v 1.40  2008/09/01
#

require 'objects/samplevel_graph/model'
require 'presampler/tokens'
require 'presampler/tokparser'
require 'presampler/tokparser2'
require 'presampler/utils'
module GUI
   require "gui/fox"
    module SGM
     class SGMModelView < FXMainWindow
        require "gui/windows_manager"
        require "gui/dialogs/simple"
        require "gui/components/radio_group"
        require "gui/object_inspector"

      require "gui/components/very_smart_table" #S
      require "gui/sgm/model_frame" #S

        include GUI

        include Responder

        require "objects/wizards"

        attr_reader :model

        def initialize(model)
           super(FXApp.instance, "Window for model '#{model.name}'", nil, nil, DECOR_ALL, 0, 0, 800, 600)

           FXMAPFUNC(SEL_FOCUSIN, 0, :onMFocusIn)

           @model = model
           @event = nil
           @selected = nil
           @canvas = nil
           @backBuffer = nil

           @table = nil #S
        end # initialize

        def create
           buttonFrame = FXVerticalFrame.new(self, LAYOUT_SIDE_LEFT|LAYOUT_FILL_Y|FRAME_THICK)

           tabbookFrame = FXVerticalFrame.new(self, LAYOUT_FILL|FRAME_SUNKEN)
           @tabbook = FXTabBook.new(tabbookFrame, nil, 0, LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_RIGHT)

        # Тут отображаем весь исходный текст программы
           tab1 = FXTabItem.new(@tabbook, "Original Program", nil)
           tab1.hide
           listframe1 = FXHorizontalFrame.new(@tabbook, FRAME_THICK|FRAME_RAISED)
           @simplelist1 = FXList.new(listframe1, nil, 0, LAYOUT_SIDE_RIGHT|LIST_EXTENDEDSELECT|LAYOUT_FILL_X|LAYOUT_FILL_Y)

        # Тут отображаем текст исследуемй функции, изменяющийся в процессе анализа
           tab2 = FXTabItem.new(@tabbook, "Sampled Function", nil)
           tab2.hide
           listframe2 = FXHorizontalFrame.new(@tabbook, FRAME_THICK|FRAME_RAISED)
           @simplelist2 = FXList.new(listframe2, nil, 0, LAYOUT_SIDE_RIGHT|LIST_EXTENDEDSELECT|LAYOUT_FILL_X|LAYOUT_FILL_Y)
           tab2.connect(SEL_FOCUSIN) do
              refreshTextProgramTab
           end

        # Тут фрейм, на котором рисуется граф
           tab3 = FXTabItem.new(@tabbook,"Sampler Graph", nil)
           @frame3 = FXHorizontalFrame.new(@tabbook, FRAME_THICK|FRAME_RAISED)

        # Наделаем кнопочек...
           buttonGroup  = RadioGroup.new(buttonFrame)
           buttonGroup2 = RadioGroup.new(buttonFrame)

           btnLoadCPPCaption   = "Load original C program"
           btnCreateSimpleModelCaption =
              "Create simple model of selected function from C program"
           btnLoadSGMCaption   = "Load sampler model (graph & CPP)"
           btnSaveSGMCaption   = "Save sampler model (graph & CPP)"
           btnSaveCPPCaption   = "Save text of CPP function"
           btnSaveGraphCaption = "Save samplevel graph"

           btnLoadCPPIcon    = GUI::Icon::OPENCPP_ICON
           btnCreateSimpleModelIcon    = GUI::Icon::BLOCKING_ICON
           btnLoadSGMIcon    = GUI::Icon::MENU_LOAD_ICON
           btnSaveSGMIcon    = GUI::Icon::MENU_SAVE_ICON
           btnSaveGraphIcon  = GUI::Icon::SAVEGRAPH_ICON
           btnSaveCPPIcon    = GUI::Icon::SAVECPP_ICON

           btnLoadCPP  = FXButton.new(buttonGroup,
                "\t#{btnLoadCPPCaption}", Icon.load(btnLoadCPPIcon) )
           btnCreateSimpleModel = FXButton.new(buttonGroup,
                "\t#{btnCreateSimpleModelCaption}", Icon.load(btnCreateSimpleModelIcon) )
           btnLoadSGM  = FXButton.new(buttonGroup2,
                "\t#{btnLoadSGMCaption}", Icon.load(btnLoadSGMIcon)  )
           btnSaveSGM  = FXButton.new(buttonGroup2,
                "\t#{btnSaveSGMCaption}", Icon.load(btnSaveSGMIcon) )
           btnSaveGraph = FXButton.new(buttonGroup2,
                "\t#{btnSaveGraphCaption}", Icon.load(btnSaveGraphIcon) )
           btnSaveCPP  = FXButton.new(buttonGroup2,
                "\t#{btnSaveCPPCaption}", Icon.load(btnSaveCPPIcon) )

           btnCreateSimpleModel.enabled = false
           btnSaveSGM.enabled  = false
           btnSaveGraph.enabled = false
           btnSaveCPP.enabled  = false


           btnLoadSGM.connect(SEL_COMMAND) do
              if onLoadSGMModel then
                btnLoadCPP.enabled   = false
                btnCreateSimpleModel.enabled  = false
                #btnLoadSGM.enabled   = true
                btnSaveSGM.enabled   = true
                btnSaveGraph.enabled = true
                btnSaveCPP.enabled   = true

                tab1.hide
                tab2.show
                tab3.show
                @tabbook.setCurrent(2)
                @tabbook.layout
              end
           end # btnLoadSGM.connect(SEL_COMMAND) do


           btnLoadCPP.connect(SEL_COMMAND) do
             cpp_EXT  = "cpp"
             ext_INFO = "original C program (*#{cpp_EXT})\nother (*.*)"
             @filepath = FXFileDialog.getOpenFilename( self,
                         "Select file to load ...", "*." + cpp_EXT, ext_INFO )
             if ! @filepath.empty? then
               fInName = @filepath
               @src_prg = IO.readlines(fInName)
               @src_prg.each do |s|
                 @simplelist1.appendItem( s.gsub("\t", '  ').gsub("\n", '') )
               end

               btnLoadCPP.enabled     = false
               btnCreateSimpleModel.enabled = true

               @tabbook.setCurrent(1)
               tab1.show
             end #if ! @filepath.empty?
           end # btnLoadCPP.connect(SEL_COMMAND) do


           btnCreateSimpleModel.connect(SEL_COMMAND) do
             # линейный список токенов (из построчного списка токенов)
             tokStream = src2tokens(@src_prg);
#TODO
             # имена и границы функций, найденных в исходном тексте программы
             funcBounds = findFucnNames(tokStream, findFunctionBounds(tokStream), @src_prg)

             fNames = ""
             funcBounds.each { |bound| fNames <<  bound[:tokStr].to_s + "\n" }
             #p bound[:tokStr].to_s + ": "+bound[:begTok].to_s+"<==>  "+bound[:endTok].to_s

             # Получаем номер функции
             @selectSampleNumber =0
             @selectFuncNumber, @selectSampleNumber  = SelectFunctionDialog.run(self, fNames)
#             p @selectFuncNumber
             @selectSampleNumber = @selectSampleNumber.to_i
#             p @selectSampleNumber
             unless [nil, -1].include? @selectFuncNumber then
#                @selectSampleNumber =0
#                @selectSampleNumber = SelectFirstSampleDialog.run(self, fNames).to_i
                print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!NUMBER of SAMPLE = #{@selectSampleNumber}/n"
                # Работаем с функцией № funcNum
                funcNum = @selectFuncNumber
                selectedFuncName = fNames.split("\n")[funcNum] #!!!

                # токены, ограничивающие выбранную функцию
                leftTok  = funcBounds[funcNum][:begTok]
                rightTok = funcBounds[funcNum][:endTok]
                #Затеняем те строки ИСХОДНОГО кода, которые нас не интересуют
                (0..@simplelist1.numItems-1).each do |i|
                  @simplelist1.disableItem(i) unless
                        (leftTok.line..rightTok.line).include? i
                end

          # Вычленяем текст выбранной функции из исходного текста программы
          # Дальше РАБОТАЕМ С ФУНКЦИЕЙ
                @src_func = @src_prg[leftTok.line-1..rightTok.line]
#                p "Source text Model"
                print @src_func
                # линейный список токенов (из построчного списка токенов)
                tokStream = src2tokens(@src_func).flatten
 #               p "tokStream"
                print tokStream
                #funcBounds = findFunctionBounds(tokStream)
                #p "Function bounds:"
                # имена и границы функций, найденных в исходном тексте программы
                funcBounds = findFucnNames(tokStream, findFunctionBounds(tokStream), @src_func)

#                p funcBounds

                # Выделяем из исходного списка токенов подсписок, содержащий функцию
                leftTok  = funcBounds[0][:begTok]
                rightTok = funcBounds[0][:endTok]
                left  = tokStream.index(tokStream.detect {|tok| tok.eql? leftTok})
                right = tokStream.index(tokStream.detect {|tok| tok.eql? rightTok})
                tokStream = tokStream[left..right]
                #tokStream.each {|ar| p ar}

                # Парсим список токенов и строим дерево структуры исходной функции
                parser = TokenParser2.new(tokStream, @selectSampleNumber-1)
                parser.parse_program

                parser.printProgTree

                insertedSamples, m = parser.getProgramSGModel

                # SAMPLEирование ИСХОДНОГО текста функции
                # Получаем SAMPLEированый текст
                @sampled_prg = insertSamplesToSrc(@src_func, insertedSamples)

                #TODO SGM Frame open
                @model = m
                @model.name = selectedFuncName #!!!
                @model.src_func = @sampled_prg

                @modelFrame = ModelFrame.new(@model, @frame3, LAYOUT_FILL|FRAME_SUNKEN)
                @modelFrame.create
                @frame3.layout

                refreshTextProgramTab

                btnLoadCPP.enabled   = false
                btnCreateSimpleModel.enabled  = false
                btnLoadSGM.enabled   = true
                btnSaveSGM.enabled   = true
                btnSaveGraph.enabled = true
                btnSaveCPP.enabled   = true


                tab1.hide
                tab2.show
                btnCreateSimpleModel.enabled = false
                @tabbook.setCurrent(2)
             end
           end # btnCreateSimpleModel.connect(SEL_COMMAND) do

           btnSaveSGM.connect(SEL_COMMAND) do
              onSaveSGMModel
           end # btnSaveSGM.connect(SEL_COMMAND) do

           btnSaveGraph.connect(SEL_COMMAND) do
              onSaveGraph
           end # btnSaveGraph.connect(SEL_COMMAND) do

           btnSaveCPP.connect(SEL_COMMAND) do
              onSaveCPP
           end # btnSaveCPP.connect(SEL_COMMAND) do


           #TODO FIXME Теперь не регистрируем окно, чтобы отрубить кнопку SAVE главного окна
           #WindowsManager.instance.registerWindow(self)
           super

           show(PLACEMENT_SCREEN)
        end # create

        def onSaveCPP
           name, ext = @filepath.split(".") unless @filepath.nil?
           name = "program" if name.nil?
           ext  = "cpp"     if ext.nil?

           cpp_EXT  = "cpp"
           ext_INFO = "C program (*.#{cpp_EXT})\nother (*.*)"
           @filepath = FXFileDialog.getSaveFilename(self,
                        "Select file to save ...",
                        name + "_s." + cpp_EXT,
                        ext_INFO)

           #win   = WindowsManager.instance.currentWindow
           #model = win.model

           name, ext = @filepath.split(".")
           ext = ".#{ext}"

           cpp_text = @model.src_func

           File.open(@filepath,"w") do |fout|
             fout.print( cpp_text )
           end  unless @filepath.empty?
        end # onSaveCPP

        def onSaveGraph
          xml_EXT  = ".xml"
          marshal_EXT = ".csa3"
          ext_INFO = "SamplerGraph descriptions (*#{marshal_EXT})\nSamplerGraph (*#{xml_EXT})\nother (*.*)"


         filepath = FXFileDialog.getSaveFilename(
            self,
            "Select file to save ...",
            Time.new.strftime("%Y-%d-%m %I_%M%p") + marshal_EXT,
            ext_INFO
            #EXT_INFO + "\nPNG image (*#{PNG_EXT})"
         )
         name, ext = filepath.split(".")

         ext = ".#{ext}"
         unless filepath.empty?
            case ext
               when xml_EXT, marshal_EXT
#                    then getApp.beginWaitCursor { @model.save(name, [ext]) }
                    then
                      savedModel = @model.copyToSamplerGraph
                      getApp.beginWaitCursor { savedModel.save(name, [ext]) }

                      #GUI::SMPL::SamplerGraphModelView.new(savedModel).create

               #when PNG_EXT then win.saveImage(filepath)
            end
         end

=begin
        savedModel = @model.copyToSamplerGraph

        GUI::SMPL::SamplerGraphModelView.new(savedModel).create
=end
        end


#================================================================================
#================================================================================
#================================================================================
        def refreshTextProgramTab
          return if @model.nil?
          return if @model.src_func.nil? || @model.src_func == ""
#          p @model.src_func
          @simplelist2.clearItems
          @model.src_func.each do |s|
            curStr = s.gsub("\t", '  ').gsub("\n", '')
#            p curStr
            @simplelist2.appendItem( curStr )
          end
        end


        def close(notify)
           #TODO FIXME Теперь не регистрируем окно, чтобы отрубить кнопку SAVE главного окна
           #WindowsManager.instance.unregisterWindow(self)

           MainWindow.instance.inspector.fill

           super(notify)
        end # close

        def onMFocusIn(sender, sel, ptr)
           ret = onFocusIn(sender, sel, ptr)

           #TODO FIXME Теперь не регистрируем окно, чтобы отрубить кнопку SAVE главного окна
           #WindowsManager.instance.showWindow(self)

           MainWindow.instance.inspector.fill(@selected, @model)
           return ret
        end # onMFocusIn

        def saveImage(filename)
           FXFileStream.open(filename, FXStreamSave) do |stream|
              @backBuffer.restore
              @backBuffer.savePixels(stream)
           end
        end # saveImage



      def onSaveSGMModel
          xml_EXT  = ".xml"
          marshal_EXT = ".sgm"
          ext_INFO = "SGM model descriptions (*#{marshal_EXT})\nother (*.*)"

         filepath = FXFileDialog.getSaveFilename(
            self,
            "Select file to save ...",
            Time.new.strftime("%Y-%d-%m %I_%M%p") + marshal_EXT,
            ext_INFO
            #EXT_INFO + "\nPNG image (*#{PNG_EXT})"
         )
#         p filepath
         ##win   = WindowsManager.instance.currentWindow
         ##model = win.model

         name, ext = filepath.split(".")
#         p ext = ".#{ext}"
         unless filepath.empty?
#            p "NAME != []"
            case ext
               when xml_EXT, marshal_EXT then getApp.beginWaitCursor { @model.save(name, [ext]) }
               #when PNG_EXT then win.saveImage(filepath)
            end
         end
      end # onSaveSGMModel


      def onLoadSGMModel
         xml_EXT  = ".xml"
         marshal_EXT = ".sgm"
         ext_INFO  = "SGM model descriptions (*#{marshal_EXT})\nother (*.*)"

         filepath = FXFileDialog.getOpenFilename(
            self,
            "Select file to load ...",
            marshal_EXT,
            ext_INFO
         )
         return false if filepath.empty?

#         p filepath

         File.open(filepath) do |input|
            #p File.extname(filepath)
            model = nil
            begin
              model = if File.extname(filepath) == marshal_EXT
                 Marshal.load(input)
              else
                 Objects::CSAXML.load(input)
              end
            rescue
            end

            if (! model.nil?) || (model.kind_of? Graphs::SamplevelGraph::Model)
              onNewSGMModel(model.class, model, model.name)
              return true
            end
         end

         return false

      end # onLoadSGMModel

      def onNewSGMModel(type, model = nil, name = nil)
#         p "type = #{type}"

#         if model
#            check = model.check
#            GUI::Dialogs.warn(check.message) unless check.correct
#         end
         model = type.new(name) unless model

         @model = model

         @frame3.removeChild(@modelFrame) unless @modelFrame.nil?

         @modelFrame = ModelFrame.new(@model, @frame3, LAYOUT_FILL|FRAME_SUNKEN)
         @modelFrame.create
         @frame3.layout
      end # onNewSGMModel



      private
       class SelectFunctionDialog < FXDialogBox
         include Responder

         NONE_TYPE = -1

         ID_MODELTYPE_CHANGED = FXDialogBox::ID_LAST

         attr_reader :selectedFunction
         attr_reader :sampleNumber

         def initialize(owner, funcNames)
            super(owner, "Select function for Samplering")

            FXMAPFUNC(SEL_COMMAND, ID_MODELTYPE_CHANGED, :functionChanged)
#            FXMAPFUNC(SEL_COMMAND, ID_FIRSTNUMBER_CHANGED, :numberChanged)

            frame = FXVerticalFrame.new(self)
            FXLabel.new(frame, "Find function:")

            group = FXGroupBox.new(self, "", FRAME_THICK|LAYOUT_FILL_X)
            @buttons = Array.new
            funcNames.each { |fName|
              @buttons <<  initButton(group, fName)
            }

            FXHorizontalSeparator.new(self, SEPARATOR_GROOVE|LAYOUT_FILL_X)
            
            group = FXGroupBox.new(self, "", FRAME_THICK|LAYOUT_FILL_X)
            
            FXLabel.new(group, "Number of first CTRPOINT:")
            @sampleText = FXTextField.new(group,10, self, ID_MODELTYPE_CHANGED,TEXTFIELD_INTEGER)
            @sampleText.setText("0")

            FXHorizontalSeparator.new(self, SEPARATOR_GROOVE|LAYOUT_FILL_X)            
            
            frame = FXHorizontalFrame.new(self)

            FXButton.new(frame, "Accept", nil, self, ID_ACCEPT, BUTTON_INITIAL|BUTTON_DEFAULT|FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X, 0, 0, 0, 0, 30, 30, 4, 4)
            FXButton.new(frame, "Cancel", nil, self, ID_CANCEL, BUTTON_INITIAL|BUTTON_DEFAULT|FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X, 0, 0, 0, 0, 30, 30, 4, 4)
         end # initialize

         def SelectFunctionDialog.run(owner, funcNames)
            dlg = SelectFunctionDialog.new(owner, funcNames)

            return dlg.selectedFunction, dlg.sampleNumber if (Fox::TRUE == dlg.execute)
            return NONE_TYPE
         end # run

      private
         def initButton(owner, text)
            return FXRadioButton.new(owner, text, self, ID_MODELTYPE_CHANGED)
         end # initButton
      public
      # TODO
         def functionChanged(sender, sel, ptr)
           if @sampleText.eql?(sender)
              @sampleNumber = @sampleText.text;
#              p "NUMBER = #{@sampleNumber}";
           else
             @selectedFunction = NONE_TYPE
             @buttons.each_index do |i|
                btn = @buttons[i]
                if btn.eql?(sender) then
                  @selectedFunction = i
                else
                  btn.setCheck(false)
                end
             end
           end
#           p "Selected Function = #{@selectedFunction}";
#           p "NUMBER = #{@sampleNumber}";
         end # modelTypeChanged
      end # class SelectFunctionDialog
   
    end # class ModelView
  end # module SGM
end # module GUI
