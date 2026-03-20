#
# objects/csaxml.rb - XML parser and generator for CSA
#
# $Id: csaxml.rb,v 1.3 2006/01/18 13:28:16 pac Exp $
#                v 1.4 2008/09/01          msv, ras


module Objects

   class CSAXML

      require "xmlparser"

      def CSAXML.dump(model, file)
         file.puts "<model type = \"#{model.class}\" name = \"#{model.name}\">"
         model.nodes.each { |n| printAttributes(n, file, "\t") }
         model.links.each { |l| printAttributes(l, file, "\t") }
         file.puts "</model>"
      end # dump

      def CSAXML.load(file)
         parser = XMLParser.new
         text = file.readlines.join

         model = nil

         parser.parse(text) do |event, name, data|
            next unless event == XMLParser::START_ELEM

            case name
               when "model"
                  model = eval(data["type"]).new(data["name"])
               when "node"
                  node = model.appendNode(data["name"], data["type"])
                  appendProperties(node, data)
               when "link"
                  name = data["name"]
                  source = model.nodes.find { |n| data["source"] == n.name }
                  dest   = model.nodes.find { |n| data["dest"] == n.name }
                  link = model.appendLink(source, dest, name)
                  appendProperties(link, data)
            end
         end

         return model
      end # load

   private

      def CSAXML.appendProperties(entity, data)
         data.each do |k, v|
            next if ["name", "type", "source", "dest"].include? k
            if "subnet" == k
               File.open(v) { |f| entity.subnet = load(f) }
               next
            end

#            eval "entity.#{k} = #{v}"
            if ["down", "up", "info"].include? k
              eval "entity.#{k} = '"+v+"'"
            else
              eval "entity.#{k} = #{v}"
            end
         end
      end # appendProperties

      def CSAXML.printAttributes(entity, file, margin)
         attr = ["type = \"#{entity.class}\""]
         entity.properties(true).each do |p|
            name  = p.first
            value = p.last["get"].call
            attr << "#{name} = \"#{value}\""
         end
         attr << "source = \"#{entity.source.name}\" dest = \"#{entity.dest.name}\"" if entity.kind_of? Objects::Link
         if entity.instance_of? Objects::SPN::SuperTransition
            filename = "#{File.dirname(file.path)}/Sub#{entity.name}.xml"
            File.open(filename, "w") { |f| dump(entity.subnet, f) }
            attr << "subnet = \"#{filename}\""
         end
         kind = (entity.kind_of?(Objects::Node) ? "node" : "link")

         file.puts "#{margin}<#{kind} #{attr.join(" ")}></#{kind}>"
      end # printAttributes

   end # class CSAXML

end # module Objects