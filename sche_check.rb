#! /usr/bin/ruby
# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__))
require "manager"
require "task-CUI"
require "json"
require "optparse"

## オプション一覧
# show_help_message 参照
#

def show_help_message
  puts "正しい引数を入力してください．"
  puts "Usage:"
  puts "% #{File.basename(__FILE__)} 出力ファイル名 プロセッサ数 タスク数 最高タスク使用率 ネスティングファクター"
  puts ""
end

if(ARGV.size != 5)
  show_help_message
  exit
end

info = { }
FILENAME = ARGV[0]
info[:proc_num] = ARGV[1].to_i
info[:mode] = SCHE_CHECK
info[:umax] = ARGV[3].to_f
info[:f] = ARGV[4].to_f

p info
@manager = AllManager.new
@manager.create_tasks(ARGV[2].to_i, 0, 0, info)
@manager.save_tasks("#{FILENAME}")
taskset = TaskSet.new
taskset.show_taskset


