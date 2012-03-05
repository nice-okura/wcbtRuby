require "randomTaskMaker"
require "taskCUI"
require "json"

gm = GroupManager.instance
rm = RequireManager.instance
tm = TaskManager.instance

gm.createGroupArray(3)
rm.createRequireArray(15)
$taskList = tm.createTaskArray(TASK_NUM)

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

#pp $taskList
taskset = TaskSet.new($taskList)
taskset.showTaskSet

tm.save_task_data
#puts JSON.pretty_generate([$taskList[0].outalldata])
#pp $taskList
=begin
grp1 = Group.new(1, "long")
grp2 = Group.new(2, "short")
req2 = Req.new(2, grp2, 10, [])
req1 = Req.new(1, grp1, 20, [req2])
pp req1
pp req1.clone
=end