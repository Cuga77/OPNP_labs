#
# gui/model_view.rb - Base model view including editor
#
# $Id: model_view.rb,v 1.26 2006/07/20 11:22:33 pac Exp $
#

module GUI
   require "gui/fox"

   class ModelView < FXMainWindow
      require "gui/windows_manager"
      require "gui/dialogs/simple"
      require "gui/components/radio_group"
      require "gui/object_inspector"
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
      end # initialize

      def create
         buttonFrame = FXVerticalFrame.new(self, LAYOUT_SIDE_LEFT|LAYOUT_FILL_Y|FRAME_THICK)
         buttonGroup = RadioGroup.new(buttonFrame)
         initButtons(buttonGroup)
         
         initMethods(buttonFrame)

         canvasFrame = FXVerticalFrame.new(self, LAYOUT_FILL|FRAME_SUNKEN)
         canvasScroll = FXScrollWindow.new(canvasFrame, LAYOUT_FILL_X|LAYOUT_FILL_Y|FRAME_SUNKEN)

         @canvas = FXCanvas.new(canvasScroll, nil, 0, LAYOUT_FILL_X|LAYOUT_FILL_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, 0, 0, 800, 600)

         @backBuffer = FXPNGImage.new(getApp, nil, IMAGE_KEEP)
         @backBuffer.create
         
         # Handle expose events (by blitting the image to the canvas)
         @canvas.connect(SEL_PAINT) do |sender, sel, evt|
            @event = evt
            FXDCWindow.new(sender, evt) do |dc|
               dc.drawImage(@backBuffer, 0, 0)
            end
         end

         # Handle resize events
         @canvas.connect(SEL_CONFIGURE) do |sender, sel, evt|
            @event = evt
            @backBuffer.create
            @backBuffer.resize(sender.width, sender.height)
            updateCanvas
         end

         @canvas.connect(SEL_LEFTBUTTONPRESS) do |sender, sel, evt|
            @event = evt
            found = searchNode(evt)
            @selected = (found ? found : searchArc(evt))
            @model.current = @selected
            @selected = nil if buttonGroup.apply(@model)
            updateCanvas
         end

         @canvas.connect(SEL_LEFTBUTTONRELEASE) do |sender, sel, evt|
            @selected = nil
         end

         @canvas.connect(SEL_RIGHTBUTTONRELEASE) do |sender, sel, evt|
            @selected = searchNode(evt)
            if @selected and @selected.kind_of? Objects::SPN::SuperTransition
               SPN::PetriModelView.new(@selected.subnet).create
               updateCanvas
            end
            unless @selected
               popup = FXMenuPane.new(self)
               FXMenuCaption.new(popup, "CSA III Popup")
               FXMenuSeparator.new(popup)
               showLinkMarks = (Objects::Link.showMarks ? "Hide" : "Show") + " link marks"
               FXMenuCommand.new(popup, showLinkMarks).connect(SEL_COMMAND) do
                  Objects::Link.showMarks = !Objects::Link.showMarks
                  updateCanvas
               end

               popup.create
               popup.popup(nil, evt.root_x, evt.root_y)
            end
         end

         @canvas.connect(SEL_MOTION) do |sender, sel, evt|
            if @selected and (evt.win_x >= 0 and evt.win_y >= 0) and
             (evt.win_x <= sender.getWidth and evt.win_y <= sender.getHeight)
               @selected.nx = evt.win_x
               @selected.ny = evt.win_y
               updateCanvas
            end
         end

         WindowsManager.instance.registerWindow(self)

         super

         show(PLACEMENT_SCREEN)
      end # create

      def close(notify)
         WindowsManager.instance.unregisterWindow(self)
         MainWindow.instance.inspector.fill

         super(notify)
      end # close

      def onMFocusIn(sender, sel, ptr)
         ret = onFocusIn(sender, sel, ptr)
         WindowsManager.instance.showWindow(self)
         MainWindow.instance.inspector.fill(@selected, @model)
         return ret
      end # onMFocusIn

      def saveImage(filename)
         FXFileStream.open(filename, FXStreamSave) do |stream|
            @backBuffer.restore
            @backBuffer.savePixels(stream)
         end
      end # saveImage

   private

      def searchNode(event)
         x, y = event.win_x, event.win_y
         return @model.nodes.find { |n| ((x >= n.nx and n.nx + (n.rotated ? n.h : n.w) >= x) and (y >= n.ny and n.ny + (n.rotated ? n.w : n.h) >= y)) }
      end # searchNode

      def searchArc(event)
         x, y = event.win_x, event.win_y
         return @model.links.find do |arc|
            ((x >= arc.nx and arc.nx + arc.w >= x) and (y >= arc.ny and arc.ny + arc.h >= y))
         end
      end # searchArc

      def width
         @canvas.getWidth
      end # width

      def height
         @canvas.getHeight
      end # width

      def initButtons(owner)
         Objects::Wizard.new(owner, "Move object", Icon::MOVE_ICON, @model)
         Objects::Model.wizards.each { |wiz| wiz.new(owner, wiz.to_s, wiz::ICON, @model) if @model.class == wiz::MODEL }
         Objects::RemoveWizard.new(owner, "Remove object", Icon::REMOVE_ICON, @model)
      end # initButtons

      def initMethods(frame)
         controller = Objects::Controller.create(@model.class)
         methods = (controller ? controller.methods : {})
         return if methods.empty?
         
         owner = RadioGroup.new(frame)
         methods.each_value do |m|
            mc = FXButton.new(owner, "\t#{m::NAME}", Icon.load(m::ICON))
            mc.connect(SEL_COMMAND) do
               begin
                  result = controller.invoke(m, @model)
                  if result.kind_of? Objects::Model
                     MainWindow.instance.onNewModel(result.class, result, result.name)
                  elsif result.kind_of? Array
                     result.each { |r| MainWindow.instance.onNewModel(r.class, r, r.name) }
                  end
               rescue Exception => oops
                  Dialogs.error(oops.to_s, "#{m::NAME} - error")
               end
            end
         end
      end # initMethods

      # Draws the scene into the back buffer
      def drawScene(drawable)
         FXDCWindow.new(drawable) do |dc|
            dc.setForeground(FXRGB(255, 255, 255))
            dc.fillRectangle(0, 0, drawable.width, drawable.height)
            drawModel(dc) if @event
            drawSel(dc) if @selected
         end
      end # drawScene

      def drawSel(dc)
         x = @selected.nx - 2
         y = @selected.ny - 2
         w = @selected.w
         h = @selected.h

         dc.setForeground(FXRGB(0, 0, 255))
         dc.setLineStyle(LINE_ONOFF_DASH)
         dc.drawRectangle(x, y, w + 4, h + 4)
         dc.setLineStyle(LINE_SOLID)
      end # drawSel

      def drawModel(dc)
         @model.nodes.each { |n| drawNode(dc, n) }
         @model.links.each { |arc| drawArc(dc, arc) }
      end # drawModel

      def drawNode(dc, node)
         node.nx = @event.win_x unless node.nx
         node.ny = @event.win_y unless node.ny
         node.w = 30 unless node.w
         node.h = 30 unless node.h
         x, y = node.nx, node.ny
         w, h = node.w, node.h

         font = FXFont.new(FXApp::instance, "times", 10, FONTWEIGHT_BOLD)
         font.create
         dc.font = font
         dc.setForeground(FXRGB(255, 0, 0))
         dc.drawArc(x, y, w, h, 0, 64*360)
         begin
            dc.drawText(x, y - 8, node.name)
         rescue
            dc.drawText(x, y - 8, node.name, node.name.length)
         end
      end # drawNode

      def drawArc(dc, arc)
         dc.setForeground(FXRGB(0, 255, 0))
         arc.w = 10 unless arc.w
         arc.h = 10 unless arc.h
         s_x, s_y = arc.source.nx + arc.source.w / 2, arc.source.ny + arc.source.h / 2
         d_x, d_y = arc.dest.nx + arc.dest.w / 2, arc.dest.ny + arc.dest.h / 2

         unless arc.nx or arc.ny
            med_x = (s_x + d_x) / 2
            med_y = (s_y + d_y) / 2
            arc.nx = med_x - arc.w / 2
            arc.ny = med_y - arc.h / 2
         end

         w, h = arc.w, arc.h
         s_dx = arc.nx + w / 2 - s_x + 0.0001
         s_dy = arc.ny + w / 2 - s_y + 0.0001
         s_alpha = s_dy / s_dx
         sign_sdx = (0 <= s_dx ? 1 : -1)
         s_sin = s_alpha / Math.sqrt(1 + s_alpha * s_alpha) * sign_sdx
         s_cos = 1 / Math.sqrt(1 + s_alpha * s_alpha) * sign_sdx
         s_x += arc.source.w / 2 * s_cos
         s_y += arc.source.w / 2 * s_sin
         dc.drawLine(s_x, s_y, arc.nx + w / 2, arc.ny + h / 2)

         d_dx = d_x - arc.nx + w / 2 + 0.0001
         d_dy = d_y - arc.ny + h / 2
         d_alpha = d_dy / d_dx
         sign_ddx = (0 <= d_dx ? 1 : -1)
         d_sin = d_alpha / Math.sqrt(1 + d_alpha * d_alpha) * sign_ddx
         d_cos = 1 / Math.sqrt(1 + d_alpha * d_alpha) * sign_ddx
         d_x -= arc.dest.w / 2 * d_cos
         d_y -= arc.dest.w / 2 * d_sin

         dc.drawLine(arc.nx + w / 2, arc.ny + h / 2, d_x, d_y)

         dc.drawRectangle(arc.nx, arc.ny, w, h) if Objects::Link::showMarks
         
         a_edge = Math::sqrt(250)
         a_sin  = 5 / a_edge
         a_cos  = 15 / a_edge
         a_lx   = a_edge * (a_cos * d_cos - a_sin * d_sin)
         a_ly   = a_edge * (a_sin * d_cos + a_cos * d_sin)
         a_rx   = a_edge * (a_cos * d_cos + a_sin * d_sin)
         a_ry   = a_edge * (-a_sin * d_cos + a_cos * d_sin)
         dc.fillPolygon([FXPoint.new(d_x.to_i, d_y.to_i),
                         FXPoint.new((d_x - a_lx).to_i, (d_y - a_ly).to_i),
                         FXPoint.new((d_x - a_rx).to_i, (d_y - a_ry).to_i)])
      end # drawArc

      def updateCanvas
         MainWindow.instance.inspector.fill(@selected, @model)
         drawScene(@backBuffer)
         @canvas.update
      end # updateCanvas

   end # class ModelView

end # module GUI
