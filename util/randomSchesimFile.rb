#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
#=Author: fujitani
#=Date: 2012/10/09
#
# rtOutput.rb
#
# ランダムなタスクセットを生成し，schesimフォルダにタスクセットファイル(.rb, .json)を生成する
#
# Usage: 
# % ruby randomSchesimFile.rb [結果出力ファイル名] [タスク数] 
require "./manager"
require "./export_schesim"
require "fileutils"

#cd ../schesim-0.7.2; ruby schesim.rb -t tmp/tmp.json -d tmp/tmp.rb -r tmp/tmp.res -e 10 ; cd ../wcbtRuby/
# マクロ
SCHESIM_FOLDER = "/Users/fujitani/Documents/lab/tkdos/schesim-0.7.2/taskset_files/"
@manager = AllManager.new
output_filename = ARGV[0]

$tasksets = 0

def make_taskset(t_count, r_count, g_count, req_count, range, require_range, offset_range)
  # タスクセット生成
  info = { }
  info[:proc_num] = 2
  info[:mode] = CREATE_MANUALLY
  info[:extime_range] = range
  info[:assign_mode] = ID_ORDER  # ID順
  info[:require_count] = req_count
  info[:require_range] = require_range # CS範囲
  info[:priority_mode] = PRIORITY_BY_PERIOD # 周期順にタスクIDと優先度をつける
  info[:period_range] = range.first*10*(t_count/2)..range.last*10*(t_count/2)
  info[:offset_range] = offset_range

  @manager.create_tasks(t_count, r_count, g_count, info)

  filename = ""
  while(1)
    filename = "./tmp/tmp_#{t_count}_#{$tasksets}"
    
    #STDERR.puts "#{filename+"_task.json"}:#{File.exists?(filename+"_task.json")}"
    if File.exists?(filename+"_task.json")
      $tasksets += 1
    else
      break
    end
  end
  
  #STDERR.puts filename
  @manager.save_tasks(filename)
end

taskset_count = 1           # タスクセット数
t_count = ARGV[1].to_i      # タスク数
r_count = t_count*2         # リソース要求数
g_count = t_count/2         # グループ数
req_count = 2               # タスク当たりのリソース要求数
ex_range = 50..100          # タスク実行時間の範囲
req_range = 2..5            # CS範囲
offset_range = 0..50        # オフセット範囲

# main
if ARGV.size != 2
  puts "引数が不正"
  exit
end

taskset_count.times do |i|
  # タスクセット生成
  make_taskset(t_count, r_count, g_count, req_count, ex_range, req_range, offset_range)

  # json出力
  Dir::mkdir(output_filename) unless File::exist?(output_filename)
  exp = EXPORT_SCHESIM.new("#{output_filename}/#{output_filename}_schesim")
  exp.output(@manager)

  # schesimフォルダにコピー
  FileUtils.copy_entry(output_filename, "#{SCHESIM_FOLDER}#{output_filename}_schesim")

  wcrt_array = []
  1.upto(@manager.tm.get_task_array.size) do |id|
    wcrt_array << TaskManager.get_task(id).wcrt*10
  end

  case RUBY_VERSION 
  when "1.8.7"
    puts wcrt_array.inject(""){|str, x| str += "#{x},"}.gsub(/,$/, "")
  when "1.9.3"
    puts wcrt_array.to_s.gsub(/\[|\]|\"/, "").gsub(/, /, ",")
  end
end
