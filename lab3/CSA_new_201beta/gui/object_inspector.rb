#
# gui/object_inspector.rb - Object Inspector for faster objects browsing
#
# $Id: object_inspector.rb,v 1.13 2006/01/30 18:10:39 ldm Exp $
#

require "gui/fox"

module GUI

   class ObjectInspector < FXVerticalFrame
      include Responder

      require "gui/components/very_smart_table"

      ID_LIST_SELECT = FXMainWindow::ID_LAST

      def initialize(owner)
         super(owner, FRAME_THICK|LAYOUT_FILL)

         FXMAPFUNC(SEL_COMMAND, ID_LIST_SELECT, :onListSelect)

         @matrix = nil
         @model  = nil
         @objList = nil

         @setters = []
         @styles  = []
      end # initialize

      def create
         frame = FXHorizontalFrame.new(self, LAYOUT_FILL_X|LAYOUT_SIDE_TOP)
         @objList = FXListBox.new(frame, self, ID_LIST_SELECT, FRAME_NORMAL|LAYOUT_FILL|LISTBOX_NORMAL)
         @objList.setNumVisible(5)

         @table = VerySmartTable.new(self, nil, FXMainWindow::ID_LAST, LAYOUT_FILL|TABLE_COL_SIZABLE|TABLE_ROW_SIZABLE)
         initTable

         super
         show
      end

      def fill(obj = nil, model = nil)
         @setters = []
         @styles  = []

         @objList.clearItems # FIXME: we should detect close here
         
         return initTable unless obj or model

         @model = model if model
         return if @model.nodes.empty?

         @model.nodes.each { |n| @objList.appendItem(n.name + " : " + n.class.to_s, nil, n) }
         @model.links.each { |v| @objList.appendItem(v.name + " : " + v.class.to_s, nil, v) }

         obj = @model.nodes.first unless obj
         return unless obj

         found = @objList.findItem(obj.name + " : " + obj.class.to_s)
         @objList.setCurrentItem(found) unless found < 0

         properties = obj.properties
         return unless properties

         fillTable(properties)
      end # fill

      def onListSelect(sender, sel, ptr)
         fill(@objList.getItemData(@objList.getCurrentItem), @model)
      end # onListSelect

   private

      def initTable
         @table.updateTable do |t|
            t.clearItems

            t.setTableSize(0, 2)
            t.setRowHeaderWidth(0)

            t.setColumnWidth(0, 60)
            t.setColumnText(0, "Name")

            t.setColumnWidth(1, 110)
            t.setColumnText(1, "Value")

            t.control(0).editable = false
            t.control(1).editable = true
            t.control(1).itemEdited = method(:onTableValueEdited)
         end
      end # initTable

      def fillTable(p)
         initTable
         
         @table.updateTable do |t|
            p.each do |prp|
               name = prp.first
               value = prp.last
               
               val = value["get"].call
               @styles << if val.kind_of? String then TEXTFIELD_ENTER_ONLY
                  elsif val.kind_of? Fixnum then TEXTFIELD_INTEGER|TEXTFIELD_ENTER_ONLY
                  elsif val.kind_of? Float  then TEXTFIELD_REAL|TEXTFIELD_ENTER_ONLY
                  else TEXTFIELD_READONLY
               end
               addRows(name, val)

               @setters << value["set"]
            end
         end
      end # fillTable

      def addRows(name, value)
         @table.updateTable do |t|
            rowCount = t.numRows
            t.insertRows(rowCount, 1)
            t.setItemText(rowCount, 0, name)
            t.setItemText(rowCount, 1, value.to_s)
            t.setItemEditorStyle(rowCount, 1, @styles.last)
         end
      end # addRows

      def onTableValueEdited(row, col, item)
         return true unless 1 == col

         @setters[row].call(case (@styles[row] ^ TEXTFIELD_ENTER_ONLY)
            when TEXTFIELD_INTEGER then item.text.to_i
            when TEXTFIELD_REAL    then item.text.to_f
            when 0 then item.text
         end) if @setters[row]
      end # onTableValueEdited

   end # class ObjectInspector

end # module GUI
