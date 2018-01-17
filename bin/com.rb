#
# RecSetting Tool
# Copyright(C) 2016-2017 MegaChips Co.,Ltd All right reserved.
# author: "dong.minghui<dong.minghui@mcc-system.jp>"
#

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
  
  def check_dir_isExist(dir)
    isExist = Dir.exist?(dir)
    puts " [ #{isExist ? "OK" : "NG"} ] #{dir} " 
    return isExist
  end
  
end

class Log
  def initialize(path)
    filename = "/" + get_time("%Y%m%d") + "_serverLog.csv"
    @file_fd = File.open(path + filename, "a+")
    @file_fd.sync = true
  end
  
  # 時刻取得
  def get_time(format)
    today = Time.new
    return today.strftime(format)
  end

  def close
    @file_fd.close if @file_fd
  end
  
  def watch_history(newLog, csvPath)
    nowTime = get_time("%Y-%m-%d %H:%M:%S")
    @file_fd.puts "HIST, #{nowTime},#{newLog},#{csvPath}" if @file_fd
  end
  
  def server_inf(action, result, ver)
    nowTime = get_time("%Y-%m-%d %H:%M:%S")
    @file_fd.puts "INF, #{nowTime},#{ver},#{action},#{result}" if @file_fd
  end
end