#===============================================================================
# presampler/preload.rb 
#  v 1.11  2008/09/01
#
#  первоначальная инициализация подсистемы Presampler
#  require 'presampler/setup' 
#===============================================================================

class ObjectLoader
  Pattern = '=-=-=-=-=-=-'
  RBExt   = '.rb'
  DATExt  = '.dat'
  TMPName = 'temp_module'
  def ObjectLoader.loadModule(moduleName)
    load_prg = File.open(moduleName+DATExt,"r") { |fin|  fin.read  }
    decode_prg = ObjectLoader.invert(load_prg).split(Pattern)
    File.open(TMPName+RBExt,"w") { |fout| decode_prg.each { |line| fout.print(line) } }
    require TMPName
    File.delete(TMPName+RBExt)
  end
  def ObjectLoader.saveModule(moduleName)
    src_prg   = IO.readlines(moduleName+RBExt)
    File.open(moduleName+DATExt,"w") { |fout| fout.print(ObjectLoader.invert(src_prg.join(Pattern))) }
  end
  def ObjectLoader.invert(str)
    newStr = ''
    str.each_byte {|b| newStr+=((256-b).chr)}
    newStr
  end
end

#ObjectLoader.saveModule("presampler/setup")
ObjectLoader.loadModule("presampler/setup")
