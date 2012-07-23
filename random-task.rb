$:.unshift(File.dirname(__FILE__))
require "manager"
require "task-CUI"
require "json"
require "optparse"

## オプション一覧
# --mode=<mode>
#     モード指定
#
# --extime=<time>
#     実行時間を指定
#     未指定(nil)の場合はランダム
#     TODO: 範囲指定可能にしたい
#
# --rcsl=<ratio>
#     RCSL指定
#     未指定(nil)の場合はランダム
#
# --assign_mode=<num>
#     タスク割り当て方式
#         1   WORST_FIT 割り当て(ProcessorManager::assign_tasks参照)
#         2   LIST_ORDER 
#         3   ID_ORDER
#         4   RANDOM_ORDER
#      未指定 RANDOM_ORDER
#
# --require_count=<count>
#     タスク当たりのリソース要求数
#     未指定(nil)の場合はconfig.rbのREQ_NUM以下のランダム数
#

def show_help_message
  puts "引数が足りません．"
  puts "Usage:"
  puts "% #{File.basename(__FILE__)} 出力ファイル名 プロセッサ数 タスク数 リソース要求数 グループ数 info"
  puts ""
#  puts "info:カンマ区切り情報 \n Ex. 120411,50,0.3"
  puts "[オプション一覧]"
  puts " --mode=<mode>"
  puts "     モード指定"
  puts ""
  puts " --extime=<time>"
  puts "     実行時間を指定"
  puts "     未指定(nil)の場合はランダム"
  puts "     TODO: 範囲指定可能にしたい"
  puts ""
  puts " --rcsl=<ratio>" 
  puts "     RCSL指定"
  puts "     未指定(nil)の場合はランダム"
  puts ""
  puts " --assign_mode=<num>"
  puts "     タスク割り当て方針"
  puts "         1   WORST_FIT 割り当て(ProcessorManager::assign_tasks参照)"
  puts "         2   LIST_ORDER"
  puts "         3   ID_ORDER"
  puts "         4   RANDOM_ORDER"
  puts "      未指定 RANDOM_ORDER"
  puts ""
  puts " --require_count=<num>" 
  puts "     タスク当たりのリソース要求数"
  puts "     未指定(nil)の場合はconfig.rbのREQ_NUM以下のランダム数"
end


opt = OptionParser.new
info = { }

# オプション解析
opt.on('--mode [VAL]') {|v|
  info[:mode] = v
}

opt.on('--extime [VAL]') {|v|
  info[:extime] = v.to_i
}

opt.on('--rcsl [VAL]') {|v|
  info[:rcsl] = v.to_f
}
opt.on('--assign_mode [VAL]') {|v|
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

opt.on('--require_count [VAL]') {|v|
  info[:require_count] = v.to_i
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


