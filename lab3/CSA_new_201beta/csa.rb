#
# csa.rb - CSA main starter
#
# $Id: csa.rb,v 1.7 2006/01/22 12:41:18 ldm Exp $
#

$LOAD_PATH << Dir.pwd

require "gui/main_window"
require "methods/methods"

# Control for trace level for FXRuby from 0 (disabled) to 1000 (maximal)
Fox.fxTraceLevel = 0

FXApp.new("", "") do |app|
   app.enableThreads

   FXToolTip.new(app)

   GUI::MainWindow.instance

   app.create
   app.run
end
