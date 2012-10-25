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
# % ruby randomSchesimFile.rb [結果出力ファイル名] [タスク数] [タスクセット出力先] [タスクセット数]
require "./manager"
require "./export_schesim"
require "fileutils"

#cd ../schesim-0.7.2; ruby schesim.rb -t tmp/tmp.json -d tmp/tmp.rb -r tmp/tmp.res -e 10 ; cd ../wcbtRuby/
# マクロ
SCHESIM_FOLDER = "/Users/fujitani/Documents/lab/tkdos/schesim-0.7.2/taskset_files/121025_tmp_schesim/"
@manager = AllManager.new
output_dir = ARGV[0]

$tasksets = 0
def show_usage
  puts "## Usage:"
  puts "% ruby #{__FILE__} output_dir task_count [output_taskset_filename] [taskset_count]"
  puts "## Example:"
  puts "% ruby util/randomSchesimFile.rb tmp 4 ./121025/taskset_files/tmp 100"
end

def make_taskset(t_count, r_count, g_count, req_count, extime, require_time, filename="")
  @manager.all_data_clear
  # タスクセット生成
  info = { }
  info[:proc_num] = 2
  info[:mode] = CREATE_MANUALLY
  info[:extime] = extime
  info[:assign_mode] = ID_ORDER  # ID順
  info[:require_count] = req_count
  #  info[:require_range] = require_range # CS範囲
  info[:require_time] = require_time # CS
  info[:priority_mode] = PRIORITY_BY_UTIL # タスク使用率順にタスクIDと優先度をつける
  info[:period_range] = extime*3..extime*5

  @manager.create_tasks(t_count, r_count, g_count, info)
  
  @manager.save_tasks(filename) unless filename == ""

end

# 作成するタスクセット数
if ARGV[3] == nil
  taskset_count = 1
else 
  taskset_count = ARGV[3].to_i
end

t_count = ARGV[1].to_i      # タスク数
r_count = t_count*2         # リソース要求数
g_count = t_count/2         # グループ数
req_count = 2               # タスク当たりのリソース要求数
extime = (50..70).get_random           # タスク実行時間の範囲
req_range = extime*0.3          # CS範囲

# main
if ARGV.size < 2
  puts "引数が不正"
  show_usage
  exit
end

taskset_count.times do |i|
  # タスクセットファイル保存
  filedir = ARGV[2]
  filename = ""

  unless filedir == nil || filedir == ""
    # ディレクトリ作成
    Dir::mkdir(filedir) unless File::exists?(filedir)
    subdir = "#{File::basename(filedir)}_#{i}"
    Dir::mkdir("#{filedir}/#{subdir}") unless File::exists?("#{filedir}/#{subdir}")
    filename = "#{filedir}/#{subdir}/#{subdir}"
  end
  
  # タスクセット生成
  make_taskset(t_count, r_count, g_count, req_count, extime, req_range, filename)

  # *.rb, *.json出力
  Dir::mkdir(output_dir) unless File::exist?(output_dir)
  subdir = "#{File::basename(output_dir)}_#{i}_schesim"

  Dir::mkdir("#{output_dir}#{subdir}") unless File::exist?("#{output_dir}#{subdir}")
  exp = EXPORT_SCHESIM.new("#{output_dir}#{subdir}/#{subdir}")
  exp.output(@manager)

  # schesimフォルダにコピー
  # FileUtils.copy_entry(output_dir, "#{SCHESIM_FOLDER}#{output_dir}_#{i}_schesim")

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
