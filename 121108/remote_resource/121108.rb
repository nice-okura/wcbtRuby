# coding: utf-8
require "manager"
require "progressbar"
require "pp"

# タスクセット数
TASKSETS = 10

cpus = 2
tasks = 4
requires = 8
groups = 4

def parameter_info
  info = { }
  info[:mode] = CREATE_MANUALLY
  info[:extime_range] = 50..100
  info[:period_range] = 400..500
  info[:assign_mode] = ID_ORDER
  info[:require_count] = 2
  info[:require_range] = 4..5
  info[:proc_num] = 2

  return info
end

# タスク配列から応答時間を格納したハッシュを返す
# @param: [Array<Task>] task_list タスクの配列
# @return: [Hash] タスクの応答時間を格納したハッシュ
def get_wcrt_hash(task_list)
  wcrt_hash = { }
  task_list.each do |tsk|
    wcrt_hash[tsk.task_id] = tsk.wcrt
  end

  return wcrt_hash
end

# リモートリソースを考慮した場合のタスクの応答時間
wcrt_no_remote_resource = []
# リモートリソースを考慮していない場合のタスクの応答時間
wcrt_remote_resource = []

manager = AllManager.new
TASKSETS.times do |i|
  manager.all_data_clear
  manager.create_tasks(tasks, requires, groups, parameter_info)
  manager.save_tasks("#{File::dirname(__FILE__)}/taskset_files/taskset_#{i}")
  wcrt_no_remote_resource << get_wcrt_hash(manager.tm.get_task_array)

  pp manager.tm.get_task_array
  # リモートリソースを考慮してブロック時間を計算するフラグ
  $REMOTE_RESOURCE_FLG = true
  init_computing(manager.tm.get_task_array)
  set_blocktime
  wcrt_remote_resource << get_wcrt_hash(manager.tm.get_task_array)
  pp manager.tm.get_task_array
  
  # リモートリソースを考慮してブロック時間を計算するフラグ
  $REMOTE_RESOURCE_FLG = false
end


File.open("#{File::dirname(__FILE__)}/wcbt_no_remote_resource.dat", "w") do |fp|
  wcrt_no_remote_resource.each do |hash|
    hash.to_a.sort{ |a, b| a[0] <=> b[0] }.each do |wcrt|
      fp.print "#{wcrt[1]} "
    end
    fp.puts
  end
end

File.open("#{File::dirname(__FILE__)}/wcbt_remote_resource.dat", "w") do |fp|
  wcrt_remote_resource.each do |hash|
    hash.to_a.sort{ |a, b| a[0] <=> b[0] }.each do |wcrt|
      fp.print "#{wcrt[1]} "
    end
    fp.puts
  end
end
