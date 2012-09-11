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
  puts "引数が足りません．"
  puts "Usage:"
  puts "% #{File.basename(__FILE__)} 出力ファイル名 プロセッサ数 タスク数 リソース要求数 グループ数 info"
  puts ""
#  puts "info:カンマ区切り情報 \n Ex. 120411,50,0.3"
  puts "[オプション一覧]"
  puts " -m, --mode <mode>"
  puts "     モード指定"
  puts "     create_manually: 手動でタスク生成"
  puts ""
  puts " -e, --extime <time>"
  puts "     実行時間を指定"
  puts "     未指定(nil)の場合はランダム"
  puts "     --extime_rangeが指定されていたら無視される"
  puts ""
  puts " -E, --extime_range <range>"
  puts "     実行時間の範囲を指定"
  puts "     Ex. --extime_range 20..100"
  puts ""
  puts " -R, --require_range <range>"
  puts "     リソース要求時間の範囲を指定"
  puts "     Ex. --require_range 2..8"
  puts ""
  puts " --rcsl <ratio>" 
  puts "     RCSL指定"
  puts "     未指定(nil)の場合はランダム"
  puts ""
  puts " -a, --assign_mode <num>"
  puts "     タスク割り当て方針"
  puts "         1   WORST_FIT 割り当て(ProcessorManager::assign_tasks参照)"
  puts "         2   LIST_ORDER"
  puts "         3   ID_ORDER"
  puts "         4   RANDOM_ORDER"
  puts "      未指定 RANDOM_ORDER"
  puts ""
  puts " -c, --require_count <num>" 
  puts "     タスク当たりのリソース要求数"
  puts "     未指定(nil)の場合はconfig.rbのREQ_NUM以下のランダム数"
  puts ""
  puts " --nest"
  puts "     ネストさせたい場合に指定する"

end


opt = OptionParser.new
info = { }

# オプション解析
opt.on('-m [VAL]', '--mode [VAL]') {|v|
  if(v == "c")
    info[:mode] = "create_manually"
  else
    info[:mode] = v
  end
}

opt.on('-e [VAL]', '--extime [VAL]') {|v|
  info[:extime] = v.to_i
}

opt.on('-e [VAL]', '--extime_range [VAL]') { |v|
  first = v.split("..")[0].to_i
  last = v.split("..")[1].to_i
  info[:extime_range] = first..last
}

opt.on('--rcsl [VAL]') {|v|
  info[:rcsl] = v.to_f
}

opt.on('-a [VAL]', '--assign_mode [VAL]') {|v|
  case v.to_i
  when 1
    info[:assign_mode] = WORST_FIT
  when 2
    info[:assign_mode] = LIST_ORDER
  when 3
    info[:assign_mode] = ID_ORDER
  when 4
    info[:assign_mode] = RANDOM_ORDER
  else
    info[:assign_mode] = RANDOM_ORDER
  end
}

opt.on('-c [VAL]', '--require_count [VAL]') {|v|
  info[:require_count] = v.to_i
}

opt.on('--nest') { |v|
  info[:nest] = true
}

opt.on('-R [VAL]', '--require_range [VAL]') { |v|
  first = v.split("..")[0].to_i
  last = v.split("..")[1].to_i
  info[:require_range] = first..last
}

opt.parse!(ARGV)


if(ARGV.size < 5)
  show_help_message
  exit
end

FILENAME = ARGV[0]
info[:proc_num] = ARGV[1].to_i
info[:mode] = "0" if info[:mode] == nil

=begin
unless ARGV[5] == nil
  info = { :mode => ARGV[5].split(',')[0], :extime => ARGV[5].split(',')[1], :rcsl => ARGV[5].split(',')[2] }
else
  info = { :mode => "0" }
end
=end

p info
@manager = AllManager.new
@manager.create_tasks(ARGV[2].to_i, ARGV[3].to_i, ARGV[4].to_i, info)
@manager.save_tasks("#{FILENAME}")
taskset = TaskSet.new
taskset.show_taskset


