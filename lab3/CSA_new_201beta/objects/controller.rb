#
# objects/controller.rb - Controller for methods manipulations
#
# $Id: controller.rb,v 1.3 2005/10/04 09:42:11 pac Exp $
#

module Objects

   class Controller

      @@methods = Array.new

      attr_reader :methods

      def Controller.registerMethod(method)
         @@methods << method
      end # Controller.registerMethod

      def Controller.list
         @@methods.collect { |m| m::NAME }
      end # Controller.list

      def Controller.create(modelClass)
         template = @@methods.collect { |m| m if m::MODEL_CLASS == modelClass }.compact

         return (template ? new(template) : nil)
      end # Controller.create


   public

      # Constructor
      def initialize(_template)
         @template   = _template

         @methods  = Hash.new
         @template.each { |m| @methods[m::NAME] = m }
      end # initialize

      def name
         @template::NAME
      end # name

      def list
         @methods.keys
      end # list

      def invoke(method, model)
         raise "Wrong model type for method #{method::NAME}" unless model.class == method::MODEL_CLASS

         begin
            return method::new.execute(model)
         rescue => oops
            raise
         end
      end # invoke

   end # class Controller

end # module Objects
