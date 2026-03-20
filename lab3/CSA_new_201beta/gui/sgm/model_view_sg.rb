#
# gui/emc/model_view.rb - SamplerGraph model view including editor
#
#  v 1.40  2008/09/01
#

module GUI
   require "gui/fox"

   module SMPL

      require "presampler/mtrans"
      class SamplerGraphModelView < ModelView
         #require "objects/emc/wizards"
       private

      def initButtons(owner)

         # пишем визарды явно
         Objects::Wizard.new(owner, "Move object", Icon::MOVE_ICON, @model)
         Objects::AddNodeWizard.new(owner, "Add node", GUI::Icon::PLACE_ICON, @model)
         Objects::AddLinkWizard.new(owner, "Add link", GUI::Icon::ARC_ICON,   @model)
         Objects::RemoveWizard.new(owner, "Remove object", Icon::REMOVE_ICON, @model)

#           Objects::Model.wizards.each { |wiz| wiz.new(owner, wiz.to_s, wiz::ICON, @model) if @model.class == wiz::MODEL }
        end # initButtons

        def initMethods(frame)
           owner = RadioGroup.new(frame)

           btnLoadSamplerTableIcon = GUI::Icon::SAMPLERTABLE_ICON
           btnLoadSamplerTableCaption = "Load and Attach Sampler table"
           btnLoadSamplerTable = FXButton.new(
             owner,
             "\t#{btnLoadSamplerTableCaption}",
             Icon.load(btnLoadSamplerTableIcon)
           )
           btnLoadSamplerTable.connect(SEL_COMMAND) do
            onLoadTablePress
           end
        end # initMethods


        def onLoadTablePress
           smp_EXT  = "smp"
           ext_INFO = "Sampler report (*#{smp_EXT})\nother (*.*)"
           filepath = FXFileDialog.getOpenFilename(
             self,
             "Select file to load ...",
              "*." + smp_EXT,
              ext_INFO
           )
           if ! filepath.empty? then
              fInName = filepath

              smp_rep = IO.readlines(fInName)

              p "=================="

              mt = ModelTransform.new
              samplerTable = mt.samplerReport2samplerTable(smp_rep)

              aG = samplerGraph2arcGraph(model, samplerTable)
              p "=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:"*2
              sum, empty, nameStr = coverPartition(aG);
              print "Всего дуг: #{sum}\n";
              print "Ненагруженных дуг: #{empty}\n";
              print "Названия ненагруженных дуг:";
              print nameStr;
              p "";
              GUI::AMC::AbsorbModelView.new(aG).create
              message = "Data coverage of model: \n\n";
              message += "Total count of arcs: \t#{sum.to_s}\n";
              message += "Uncovered arcs:\t\t#{empty.to_s}\n";
              message += "Names of uncovered arcs:\n";
              nameStr.each { |arcName|
                message += "\t#{arcName}\n";
              }
              message += "\n Save?";
              if GUI::Dialogs.confirm(message, "Result")
               filepath = FXFileDialog.getSaveFilename(GUI::MainWindow.instance, "Select file...", ".", "Text (*.txt)")
               return if filepath.empty?
               ext = File.extname(filepath)
               filepath += ".txt" if ext.empty?
               File.open(filepath, "w") do |f|
                  f.puts message;
               end
            end
           end #if ! filepath.empty?
        end #onLoadTablePress

       end # class ErgodicModelView

   end # module SMPL

end # module GUI
