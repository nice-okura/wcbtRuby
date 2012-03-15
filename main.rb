require "taskMaker"
require "taskCUI"
require "json"
require "optparse"  # コマンドライン引数
#
# コマンドライン引数の処理
#
opt = OptionParser.new

#
# 外部のタスク，リソース要求，グループファイルを読み込む場合
#
opt.on('-l') { |v|
  $external_input = true
}

opt.parse!(ARGV)


@gm = GroupManager.instance
@rm = RequireManager.instance
@tm = TaskManager.instance

@gm.create_group_array(20)
@rm.create_require_array(60)
@tm.create_task_array(100)

@gm.save_group_data
@rm.save_require_data
@tm.save_task_data

taskset = TaskSet.new(@tm.get_task_array)
taskset.show_taskset

=begin
$taskList.each{|task|
  puts "タスク" + task.taskId.to_s
  puts "BB:" + BB(task).to_s
  puts "AB:" + AB(task).to_s
  puts "SB:" + SB(task).to_s
  puts "LB:" + LB(task).to_s
  puts "DB:" + DB(task).to_s
  puts "B:" + B(task).to_s
}
=end