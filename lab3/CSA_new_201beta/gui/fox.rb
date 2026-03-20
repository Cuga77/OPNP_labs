#
# gui/fox.rb - Fox library loader
#
# $Id: fox.rb,v 1.3 2005/10/04 09:42:11 pac Exp $
#

begin
   require "fox14"
rescue LoadError
   begin
      require "fox12"
   rescue LoadError
      require "fox"
   end
end

include Fox

puts "FXRuby library version #{Fox.fxrubyversion} found"