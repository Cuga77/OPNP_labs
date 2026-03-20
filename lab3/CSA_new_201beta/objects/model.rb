#
# objects/model.rb - Base model definition, used for describing simple graphs
#
# $Id: model.rb,v 1.14 2006/01/18 11:10:30 pac Exp $
#

module Objects
   require "objects/entity"

   class Model < Entity
      require "objects/node"
      require "objects/link"

      @@wizards = []

      attr_reader :nodes
      attr_reader :links

      attr_accessor :current

      def initialize(_name = "Model")
         super(_name)
         @nodes = []
         @links = []
         @last_id = -1
      end # initialize

      def appendNode(name = nil, type = Node)
         @nodes << makeNode(type)
         @nodes.last.name = name if name

         return @nodes.last
      end # append

      def appendLink(source, dest, name = nil)
         raise "No such node #{source} in model #{self}" unless @nodes.find { |n| n == source }
         raise "No such node #{dest} in model #{self}"   unless @nodes.find { |n| n == dest }

         link, message = makeLink(source, dest)
         return GUI::Dialogs.error(message) if message
         link.name = name if name
         @links << link

         return link
      end # appendLink

      def rotate
         current.rotate if current
      end # rotate

      def remove
         return GUI::Dialogs.warn("There is no selection in model!") unless current

         if current.kind_of? Objects::Node
            removeNode
         elsif current.kind_of? Objects::Link
            removeLink
         end
      end # remove

      def removeNode
         nodes.delete(current)
         links.delete_if { |link| link.source == current or link.dest == current }
      end # removeNode

      def removeLink
         links.delete(current)
      end # removeLink

      def copy
         out = self.class.new(name)

         nodes.each do |node|
            node.copy(out.appendNode(node.name, node.class))
         end
         links.each do |link|
            link.copy(out.appendLink(makeSource(out, link), makeDest(out, link), link.name))
         end

         return out
      end # copy

      def check
         return CheckStruct.new(true)
      end # check

      def Model.appendWizard(wiz)
         @@wizards << wiz
      end # appendWizard

      def Model.wizards
         @@wizards
      end # wizards

   protected
   
      CheckStruct = Struct.new("CheckStruct", :correct, :message)

      def makeSource(model, link)
         model.nodes.find { |n| n.name == link.source.name }
      end # makeSource

      def makeDest(model, link)
         model.nodes.find { |n| n.name == link.dest.name }
      end # makeDest

      def makeNode(type)
         return Node.new("n#{@last_id += 1}")
      end # makeNode

      def makeLink(source, dest)
         return Link.new(source, dest)
      end # makeLink

   end # class Model

end # module Objects
