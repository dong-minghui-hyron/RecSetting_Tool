#
# RecSetting Tool
# Copyright(C) 2016-2017 MegaChips Co.,Ltd All right reserved.
# author: "dong.minghui<dong.minghui@mcc-system.jp>"
#

require File.dirname(__FILE__) + '/com.rb'
require File.dirname(__FILE__) + '/makeXML.rb'
require File.dirname(__FILE__) + '/xml_to_CSV.rb'
require 'rb-inotify'

class ObjLog
  def initialize(oldStatus, nowStatus)
    @oldStatus = oldStatus
    @nowStatus = nowStatus
    @camNum = 0
    @recSettingNum = 0
  end
  
  def get_oldStatus
    return @oldStatus
  end
  
  def get_nowStatus
    return @nowStatus
  end
  
  def set_oldStatus(oldStatus)
    @oldStatus = oldStatus
  end
  
  def set_nowStatus(nowStatus)
    @nowStatus = nowStatus
  end

end


class CSVMaker
  include Common

  def check_workspace(dirList)
    result = true
    puts "check the workspace ..."
    dirList.each do |dir|
      result = false unless check_dir_isExist(dir)
    end 

    $logger.server_inf("server start",result ? "OK" : "NG", $VER)

    if result
      puts "the workspace check is [ OK ], server is started. #{$VER}"
    else
      puts "the workspace check is [ NG ], please create the workspace. #{$VER}"
      $logger.close
      exit
    end
  end
  
  def close
    $logger.server_inf("server stop","", $VER)
  end
  
  def make_oneCSV(recSettingPath, logName, logPath)
    puts "#### #{logName} start ####"
    
    xml_maker = XMLMaker.new
    xml_to_csv = XML2CSV.new 
    
    csvPath = recSettingPath + "/" + logName
    xmlPath = csvPath + "/xml"
    onelogPath = logPath + "/" + logName

    make_dir(csvPath)
    make_dir(xmlPath)

    xml_maker.make_XML(onelogPath, xmlPath)
    xml_to_csv.make_CSV(csvPath, xmlPath)
    
    puts "#### #{logName} over ####"
    puts
  end

  # make all of the xmlfile in now directory
  def make_allXML(recSettingPath, logPath)
    logList = get_DirList(logPath)
    logList.each do |logName|
      make_oneCSV(recSettingPath, logName, logPath)
    end
  end

  # watch these directories in the list
  def watch_dir(pathList, recSettingPath)
    notifier = INotify::Notifier.new
    logHash = Hash.new

    pathList.each do |e|
      notifier.watch(e, :all_events) do |event|
        unless event.absolute_name == e
          nowStatus = event.flags[0]
          logName = event.name

          # if the new log was created, save its Status into the Hash
          logHash[logName] = ObjLog.new("none", nowStatus) if nowStatus == :create 

          # if the Status of log exists in the Hash, it was judged to be a new log and update its Status in the Hash
          if logHash.include?(logName)
            logHash[logName].set_oldStatus(logHash[logName].get_nowStatus)
            logHash[logName].set_nowStatus(nowStatus)
            # if the oldStatus is [:open] and the nowStatus is [:close_nowrite], 
            # the new log was judged to be the Status that was updated completed
            if logHash[logName].get_oldStatus == :open and nowStatus == :close_nowrite
              make_oneCSV(recSettingPath, logName, e)
              $logger.watch_history(event.absolute_name, "#{recSettingPath}/#{logName}") if $logger
              logHash.delete(event.name)
            end
          end
        end
      end
    end

    trap("INT") { notifier.close }

    # run the watcher
    notifier.run
  end

end

#csv_maker = CSVMaker.new
#csv_maker.check_workspace
#csv_maker.watch_dir($path_list, $work_space)
#csv_maker.make_allXML($now_path, $log_path)
#csv_maker.make_oneCSV($now_path, "log2", "#{$log_path}")
