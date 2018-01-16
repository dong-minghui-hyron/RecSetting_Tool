#
# RecSetting Tool
# Copyright(C) 2016-2017 MegaChips Co.,Ltd All right reserved.
# author: "dong.minghui<dong.minghui@mcc-system.jp>"
#

module IFofXML

  def get_basename(absoluteName)
    return File.basename(absoluteName)
  end

  def make_xmlName(srcName)
    return srcName.split(".")[0] + ".xml"
  end


  # make the xml of recSetting
  def make_xml(logName, objXMLPath)
    xmlname = make_xmlName(get_basename(logName))

    isRecSetting = false
    xmlFile = File.open(objXMLPath + "/" + xmlname, "w+")
  
    xmlFile.puts("<?xml version= \"1.0\"  encoding= \"utf-8\"?>")

    IO.foreach(logName) { |line| 
      isRecSetting = true if line.include?("<RecSetting>")
      xmlFile.puts(line) if isRecSetting == true
      isRecSetting = false if line.include?("</RecSetting>")
    }
end


  # traverse the floder of log
  def traverse_logDir(logPath, objXMLPath)
    if File.directory?(logPath)
      Dir.foreach(logPath) do |fileName|
        traverse_logDir(logPath + "/" + fileName, objXMLPath) if fileName != "." and fileName != ".."
      end
    else
      make_xml(logPath, objXMLPath) if logPath.include?(".log") and logPath.include?("CAM")
    end
  end

end

class XMLMaker
  include IFofXML

  # make the xmlfile of one log
  def make_XML(logPath, objXMLPath)
    puts "make xml in #{objXMLPath}"
    puts logPath
    traverse_logDir(logPath, objXMLPath)
  end
end
