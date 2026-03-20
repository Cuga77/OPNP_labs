#
# gui/main_window.rb - Main window definition
#
# $Id: main_window.rb,v 1.27 2006/01/30 18:10:39 ldm Exp $
#                     v 1.28 2008/09/01          msv


require "gui/fox"

module GUI

   class MainWindow < FXMainWindow
      require "singleton"

      require "objects/csaxml"

      require "gui/dialogs/simple"
      require "gui/icon"
      require "gui/model_view"

      require "objects/spn/model"
      require "objects/amc/model"
      require "objects/emc/model"

      require "gui/spn/model_view"
      require "gui/amc/model_view"
      require "gui/emc/model_view"
      
      require "gui/sgm/model_view_sg" #S 
      require "gui/sgm/model_view"    #S
      require "presampler/preload"    #S
      

      include Singleton
      include Responder

      attr_reader :font
      attr_reader :inspector

      def initialize
         super(FXApp::instance, "CSA III", nil, nil, DECOR_ALL, 0, 20, 200, 600)
         @font  = FXFont.new(FXApp::instance, "times", 10, FONTWEIGHT_BOLD)
      end # initialize

      def create
         menu = FXHorizontalFrame.new(self)

         FXButton.new(menu, "\tNew...", Icon.load(Icon::MENU_NEW_ICON)).connect(SEL_COMMAND) { onNewModel(SelectModelDialog.run) }
         
         FXButton.new(menu, "\tLoad...", Icon.load(Icon::MENU_LOAD_ICON)).connect(SEL_COMMAND) { onLoadModel }
         @saveItem = FXButton.new(menu, "\tSave...", Icon.load(Icon::MENU_SAVE_ICON))
         @saveItem.connect(SEL_COMMAND) { onSaveModel }
         @saveItem.disable

#S - begin
         FXVerticalSeparator.new(menu)
         FXButton.new(menu,
                      "\tSample Marking", 
                      Icon.load(Icon::SAMPLERING_ICON)).connect(SEL_COMMAND) { 
            name = "Sample Marking"

            #FIXME !!!!!!
            #model = Objects::SGM::Model.new(name)
            model = Graphs::SamplevelGraph::Model.new(name)

            viewType = GUI::SGM::SGMModelView
            viewType.new(model).create
         }
#S - end

         FXVerticalSeparator.new(menu)
         FXButton.new(menu, "\tExit", Icon.load(Icon::MENU_EXIT_ICON), getApp, FXApp::ID_QUIT)

         @font.create

         @inspector = ObjectInspector.new(self)

         super

         show
      end # create

      def onNewModel(type, model = nil, name = nil)
         # FIXME: type here shall be a new model class name!
         return if type == SelectModelDialog::NONE_TYPE
      
         name = Dialogs.input("Enter model name", nil, "Enter name...") unless name
         return if name.nil? or name.empty?

         if model
            check = model.check
            GUI::Dialogs.warn(check.message) unless check.correct
         end
         model = type.new(name) unless model
         # CASE does not work here (don't know why)
         
         viewType = if type == Objects::SPN::Model    then GUI::SPN::PetriModelView
            elsif type == Objects::EMC::Model         then GUI::EMC::ErgodicModelView
            elsif type == Objects::AMC::Model         then GUI::AMC::AbsorbModelView
            elsif type == Graphs::SamplerGraph::Model then GUI::SMPL::SamplerGraphModelView #S
            else GUI::ModelView
         end

         viewType.new(model).create
      end # onNewModel

      # Loading and store objects in binary and textual files
      XML_EXT     = ".xml"
      MARSHAL_EXT = ".csa3"
      PNG_EXT     = ".png"

      CSA3_EXT    = MARSHAL_EXT
      EXT_INFO    = "CSA3 model descriptions (*#{CSA3_EXT})\nXML model descriptions (*#{XML_EXT})"

      def onSaveModel
         filepath = FXFileDialog.getSaveFilename(self, "Select file to save ...", Time.new.to_s + CSA3_EXT, EXT_INFO + "\nPNG image (*#{PNG_EXT})")
         win      = WindowsManager.instance.currentWindow
         model = win.model
         
         name, ext = filepath.split(".")
         ext = ".#{ext}"
         unless filepath.empty?
            case ext
               when XML_EXT, CSA3_EXT then getApp.beginWaitCursor { model.save(name, [ext]) }
               when PNG_EXT then win.saveImage(filepath)
            end
         end
      end # onSaveModel

      def onLoadModel
         filepath = FXFileDialog.getOpenFilename(self, "Select file to load ...", Time.new.to_s + CSA3_EXT, EXT_INFO)
         return if filepath.empty?

         File.open(filepath) do |input|
            model = if File.extname(filepath) == MARSHAL_EXT
               Marshal.load(input)
            else
               Objects::CSAXML.load(input)
            end
            onNewModel(model.class, model, model.name)
         end
      end # onLoadModel

      def updateMenu(enabled)
         @saveItem.setEnabled(enabled)
      end # updateMenu

   private
   
      class SelectModelDialog < FXDialogBox
         include Responder
      
         NONE_TYPE = -1
         
         ID_MODELTYPE_CHANGED = FXDialogBox::ID_LAST
         
         attr_reader :modelType
      
         def initialize(owner)
            super(owner, "Select model type")
            
            FXMAPFUNC(SEL_COMMAND, ID_MODELTYPE_CHANGED, :modelTypeChanged)
            
            frame = FXVerticalFrame.new(self)
            FXLabel.new(frame, "Which model do you want:")
            
            group = FXGroupBox.new(self, "", FRAME_THICK|LAYOUT_FILL_X)
            @spnButton = initButton(group, "Stochastic Petri Net")
            @emcButton = initButton(group, "Ergodic Markov Chain")
            @amcButton = initButton(group, "Absorb Markov Chain")
            
            
            FXHorizontalSeparator.new(self, SEPARATOR_GROOVE|LAYOUT_FILL_X)
                        
            frame = FXHorizontalFrame.new(self)

            FXButton.new(frame, "Accept", nil, self, ID_ACCEPT, BUTTON_INITIAL|BUTTON_DEFAULT|FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X, 0, 0, 0, 0, 30, 30, 4, 4)
            FXButton.new(frame, "Cancel", nil, self, ID_CANCEL, BUTTON_INITIAL|BUTTON_DEFAULT|FRAME_RAISED|FRAME_THICK|LAYOUT_CENTER_X, 0, 0, 0, 0, 30, 30, 4, 4)
         end # initialize

         def SelectModelDialog.run
            dlg = SelectModelDialog.new(MainWindow.instance)
            
            return dlg.modelType if (Fox::TRUE == dlg.execute)
            return NONE_TYPE
         end # run

      private
      
         def initButton(owner, text)
            return FXRadioButton.new(owner, text, self, ID_MODELTYPE_CHANGED)
         end # initButton
      
         def modelTypeChanged(sender, sel, ptr)
            @modelType = case sender
               when @spnButton
                  @emcButton.setCheck(false)
                  @amcButton.setCheck(false)
                  Objects::SPN::Model
               when @emcButton
                  @spnButton.setCheck(false)
                  @amcButton.setCheck(false)
                  Objects::EMC::Model
               when @amcButton
                  @emcButton.setCheck(false)
                  @spnButton.setCheck(false)
                  Objects::AMC::Model
            end
         end # modelTypeChanged

      end # class SelectModelDialog

   end # class MainWindow

end # module GUI