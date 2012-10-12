#!/usr/bin/ruby
#
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
SCHESIM_FOLDER = "/Users/fujitani/Documents/lab/tkdos/schesim-0.7.2/"
@manager = AllManager.new
output_filename = ARGV[0]


def make_taskset(t_count, r_count, g_count, req_count, range, require_range)
  # タスクセット生成
  info = { }
  info[:proc_num] = 2
  info[:mode] = CREATE_MANUALLY
  info[:extime_range] = range
  info[:assign_mode] = 3  # ID順
  info[:require_count] = req_count
  info[:require_range] = require_range # CS範囲

  @manager.create_tasks(t_count, r_count, g_count, info)
end


taskset_count = 1   # タスクセット数
t_count = ARGV[1].to_i   # タスク数
r_count = t_count*2         # リソース要求数
g_count = t_count/2         # グループ数
req_count = 2       # タスク当たりのリソース要求数
ex_range = 50..200  # タスク実行時間の範囲
req_range = 5..10   # CS範囲


# main
taskset_count.times do |i|
  # タスクセット生成
  make_taskset(t_count, r_count, g_count, req_count, ex_range, req_range)

  # json出力
  Dir::mkdir(output_filename) unless File::exist?(output_filename)
  exp = EXPORT_SCHESIM.new("#{output_filename}/#{output_filename}_schesim")
  exp.output(@manager)

  # schesimフォルダにコピー
  FileUtils.copy_entry(output_filename, "#{SCHESIM_FOLDER}#{output_filename}_schesim")
end
