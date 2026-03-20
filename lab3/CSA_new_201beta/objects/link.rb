#
# objects/link.rb - Base link definition, used for simple graph model
#
# $Id: link.rb,v 1.5 2005/12/19 10:29:54 pac Exp $
#

module Objects

   class Link < Entity
   
      @@showMarks = true
   
      def Link.showMarks
         @@showMarks
      end # showMarks

      def Link.showMarks=(val)
         @@showMarks = val
      end # showMarks

      attr_reader :source
      attr_reader :dest

      def initialize(source, dest)
         super("#{source.name}-->#{dest.name}")

         @source = source
         @dest   = dest
      end # initialize

   end # class Link

end # module Objects
