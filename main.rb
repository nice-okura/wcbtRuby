require "randomTaskMaker"
require "taskCUI"

gm = GroupManager.instance
rm = RequireManager.instance
tm = TaskManager.instance

gm.createGroupArray(20)
rm.createRequireArray(30)
$taskList = tm.createTaskArray(100)

#pp $taskList
$taskList.each{|task|
  puts "タスク" + task.taskId.to_s
  puts "BB:" + BB(task).to_s
  puts "AB:" + AB(task).to_s
  puts "SB:" + SB(task).to_s
  puts "LB:" + LB(task).to_s
  puts "DB:" + DB(task).to_s
  puts "B:" + B(task).to_s
}

pp $taskList

taskset = TaskSet.new($taskList)
taskset.taskList.each{|task|
  tCUI = TaskCUI.new(task)
  tCUI.showTaskChar
}
