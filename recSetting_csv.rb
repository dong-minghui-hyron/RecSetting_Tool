#
# RecSetting Tool
# Copyright(C) 2016-2017 MegaChips Co.,Ltd All right reserved.
# author: "dong.minghui<dong.minghui@mcc-system.jp>"
#

require './bin/makeXML.rb'
require './bin/xml_to_CSV.rb'
require 'rb-inotify'

$now_path = "/home/mcc/log"
$path_list = [
  "/home/mcc/log/test",
]

$recSetting_path = "/home/mcc/log/recSetting"
$log_path = "/home/mcc/log/test"

module Common
  def get_DirList(dirPath)
    dirList = Array.new

    Dir.foreach(dirPath) do |dirName|
      dirList << dirName if dirName != "." and dirName != ".."
    end

    return dirList
  end


  def make_dir(dirName)
    Dir.mkdir(dirName) unless File.exist?(dirName)
  end
end

module Log
  # 時刻取得
  def get_time(format)
    today = Time.new
    return today.strftime(format)
  end

  # log保存
  def write_log(text)
    filename = "/" + get_time("%Y%m%d") + "_log.txt"
    log_file = File.open($log_path + filename, "a+")

    now_time = get_time("%Y-%m-%d %H:%M:%S")
    log_file.puts "#{now_time},#{text}"
    log_file.close
  end
end

class CSVMaker
  include Log
  include Common

  def make_oneCSV(nowDir, logName, logPath)
    xml_maker = XMLMaker.new
    xml_to_csv = XML2CSV.new 
    
    csvPath = nowDir + "/recSetting/" + logName
    xmlPath = csvPath + "/xml"
    onelogPath = logPath + "/" + logName

    make_dir(csvPath)
    make_dir(xmlPath)

    xml_maker.make_XML(onelogPath, xmlPath)
    xml_to_csv.make_CSV(csvPath, xmlPath)
  end

  # make all of the xmlfile in now directory
  def make_allXML(nowDir, logPath)
    logList = get_DirList(logPath)
    logList.each do |logName|
      puts "#### #{logName} start ####"
      make_oneCSV(nowDir, logName, logPath)
      puts "#### #{logName} over ####"
      puts
    end
  end
  
  def watch_dir
    notifier = INotify::Notifier.new
    
    $path_list.each do |e|
      notifier.watch(e, :all_events) do |event|
        unless event.absolute_name == e
          puts "#{event.name} #{event.absolute_name} #{event.flags}  #{event.size} #{event.watcher.path}"
#          make_all_xml(event.absolute_name) if event.flags[0] == :close_nowrite
#          make_dir(event.name) if event.flags[0] == :close_nowrite
          puts "make_all_xml" if event.flags[0] == :close_nowrite
        end
      end
    end

    notifier.run
  end

end

csv_maker = CSVMaker.new
#csv_maker.watch_dir()
#csv_maker.make_allXML($now_path, $log_path)

