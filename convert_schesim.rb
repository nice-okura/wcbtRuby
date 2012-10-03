#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
# タスクをschesim用に変換する
#
# Usage: % ruby convert_schesim.rb [タスクファイル名] [出力ファイル名]
# 
$:.unshift(File.dirname(__FILE__))
require "export_schesim"

#
# main
#
if ARGV.size != 2
  STDERR.puts "Usage: % ruby convert_schesim.rb [タスクファイル名] [出力ファイル名]"
  STDERR.puts "Ex."
  STDERR.puts "% ruby ../make_taskset.rb 20tasks 20 2 10 "
  STDERR.puts "% ruby ../convert_schesim.rb 20tasks 20tasks_schesim"
  STDERR.puts "% cp -r 20tasks_schesim ../../schesim-0.7.2/"
  STDERR.puts "% cd ../../schesim-0.7.2/"
  STDERR.puts "% . auto_schesim.sh 20tasks_schesim/20tasks_schesim"
  exit
end
input_filename = ARGV[0]
output_filename = ARGV[1]

manager = AllManager.new
puts "ロード失敗" if manager.load_tasks(input_filename) == false

Dir::mkdir(output_filename) unless File::exist?(output_filename)
exp = EXPORT_SCHESIM.new("#{output_filename}/#{output_filename}")
exp.output(manager)
