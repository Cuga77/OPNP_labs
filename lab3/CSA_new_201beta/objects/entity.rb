#
# objects/entity.rb - Base class for all objects
#
# $Id: entity.rb,v 1.14 2006/07/20 11:22:33 pac Exp $
#                v 1.15 2008/09/01          msv, ras

module Objects

   class Entity

      attr_accessor :name
      alias csa0_name name
      alias csa0_name= name=

      attr_reader :rotated

      def initialize(_name)
         @name = _name

         @rotated = false
      end # initialize

      def method_missing(meth, *args)
         sMethod = (meth.to_s.include?("=") ? meth.to_s.gsub("=", "") : meth.to_s)

         eval "def #{sMethod}\n @#{sMethod}; end"
         eval "def #{sMethod}=(v)\n @#{sMethod} = v; end"

         send(meth.to_s, *args)
      end # method_missing

      def properties(save_prp = nil)
         ret = []
         csa_methods = public_methods.select { |m| m.include? "csa" }.uniq.sort
         csa_methods = csa_methods.concat(public_methods.select { |m| m.include? "smp"}.uniq.sort) if save_prp
         csa_methods.each do |m|
            next if m.include? "="

            ret << [m.split("_").last, {"get" => eval("method(:#{m})"),
                                        "set" => eval("method(:#{m}=)")}]
         end
         return ret
      end # properties

      def save(filename, exts)
         p "SAVE MODEL"
         exts.each do |ext|
            File.open(filename + ext, "w") do |out|
               vSGM_EXT     = ".sgm"
               case ext
                  when GUI::MainWindow::MARSHAL_EXT, vSGM_EXT then Marshal.dump(self, out)
                  when GUI::MainWindow::XML_EXT               then CSAXML.dump(self, out)
               end
            end
         end
      end # save

   protected

      def copy(to)
      end # copy

      def rotate
         @rotated = !@rotated
         @w, @h = h, w
      end # rotate

   end # class Entity

end # module Objects