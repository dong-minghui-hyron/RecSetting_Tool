#
# RecSetting Tool
# Copyright(C) 2016-2017 MegaChips Co.,Ltd All right reserved.
# author: "dong.minghui<dong.minghui@mcc-system.jp>"
#

require 'csv'
require 'rexml/document'
require 'pathname'
include REXML

module IFofCSV
  @title =" ," 
  @isFirst = true
  
  def make_title(e)
    if e.elements.size == 0
      @title = @title + e.name + ","
      return
    end
    e.elements.each do |c|
      make_title(c)
    end
  end
  
  def read_val(e)
    if e.elements.size == 0
      @recSetting = @recSetting + e.text + ","
      return
    end
    e.elements.each do |c|
      read_val(c)
    end
  end
  
  # xml analysis
  def read_recSetting(filename)
    xmlFile = File.open(filename, "r")
    xmldoc = Document.new(xmlFile)
    
    if xmldoc.root
      xmldoc.root.elements.each do |e|
        make_title(e) if @isFirst
        read_val(e)
      end
    end
  end
  
  def write_csv(csvfile)
    if @isFirst
      csvfile.puts(@title)
      @isFirst = false
    end
    csvfile.puts(@recSetting)
  end
  
  def traverse_xmlDir(xmlPath, csvfile)
    if File.directory?(xmlPath)
      Dir.foreach(xmlPath) do |xmlName|
        traverse_xmlDir(xmlPath + "/" + xmlName, csvfile) if xmlName != "." and xmlName != ".."
      end
    else
      if xmlPath.include?(".xml") and xmlPath.include?("CAM")
        @recSetting = File.basename(xmlPath).split(".")[0] +","
        read_recSetting(xmlPath)
        write_csv(csvfile)
      end
    end
  end

end

class XML2CSV
  include IFofCSV

  def make_CSV(objPath, xmlPath)
    objName = File.basename(objPath) + "_recSetting.csv"
    csvfile = File.open(objPath + "/" + objName, 'w+')
    puts "make #{objPath}/#{objName}"
    traverse_xmlDir(xmlPath, csvfile)
  end
end

