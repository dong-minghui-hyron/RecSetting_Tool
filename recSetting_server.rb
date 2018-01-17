#
# RecSetting Tool
# Copyright(C) 2016-2017 MegaChips Co.,Ltd All right reserved.
# author: "dong.minghui<dong.minghui@mcc-system.jp>"
#

require 'pathname'
require './bin/recSetting_csv.rb'

$VER = "Ver 01.00"
$top_dir = "#{Pathname.new(File.dirname(__FILE__)).realpath}"
$workspace = "#{$top_dir}/workspace"
$recSetting_path = "#{$workspace}/output/recSetting"
$path_list = [
  "#{$workspace}/watchObj",
]

dirList = [$workspace, $recSetting_path] + $path_list
$logger = Log.new("#{$top_dir}/serverlog")

watcher = CSVMaker.new
watcher.check_workspace(dirList)
watcher.watch_dir($path_list,$recSetting_path)
watcher.close

$logger.close if $logger