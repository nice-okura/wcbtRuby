#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120321ミーティング用
#タスクの最悪実行時間を4パターンのタスクセットで比較
#
#

require "wcbt"
require "task"
require "taskCUI"

def get_extime_high_priority(proc, priority)
  time = 0
  $taskList.each{|t|
    if t.proc == proc && t.priority < priority
      time += t.extime + SB(t)
    end
  }
  return time
end

include WCBT
$DEBUG = true


#############################
#
#############################


#
# Groupクラス定義
# Group.new(group, kind)
#
@grp1 = Group.new(1, "short")
@grp2 = Group.new(2, "short")
#
# Requireクラス定義
# Req.new(reqId, res, time, reqs)
#
@req1_1 = Req.new(1, @grp1, 1, [])
@req3_1 = Req.new(2, @grp2, 3, [])
@req3_2 = Req.new(3, @grp2, 6, [])

@req2_0 = Req.new(4, @grp1, 1, [])
@req2_1 = Req.new(5, @grp2, 6, [@req2_0])
@req2_2 = Req.new(6, @grp1, 4, [])

@req4_1 = Req.new(7, @grp1, 3, [])

#
# Taskクラス定義
# Taks.new(task_id, proc, period, extime, priority, offset, req_list)
#
task1 = Task.new(1, 1, 50, 1, 1, 2, [@req1_1])
task2 = Task.new(2, 2, 50, 15, 2, 3, [@req2_1, @req2_2])
task3 = Task.new(3, 1, 50, 10, 3, 0, [@req3_1, @req3_2])
task4 = Task.new(4, 2, 50, 5, 4, 0, [@req4_1])

$taskList = [task1, task2, task3, task4]
tasks1 = $taskList

$taskList = tasks1
tasks1.each{|task|
  print "タスク" + task.task_id.to_s
  bb = BB(task)
  ab = AB(task)
  sb = SB(task)
  lb = LB(task)
  db = DB(task)
  
  b = bb + ab + sb + lb + db
  print "\tBB:" + bb.to_s
  print "\tAB:" + ab.to_s
  print "\tSB:" + sb.to_s
  print "\tLB:" + lb.to_s
  print "\tDB:" + db.to_s
  print "\tB:" + b.to_s
  print "\n"
  puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} * 2= #{task.extime + b + get_extime_high_priority(task.proc, task.priority)*2}"
}
taskset = TaskSet.new(tasks1)
taskset.show_taskset

#############################
#
#############################

@grp1.kind = "short"
@grp2.kind = "long"

$taskList = tasks1
tasks1.each{|task|
  print "タスク" + task.task_id.to_s
  bb = BB(task)
  ab = AB(task)
  sb = SB(task)
  lb = LB(task)
  db = DB(task)
  
  b = bb + ab + sb + lb + db
  print "\tBB:" + bb.to_s
  print "\tAB:" + ab.to_s
  print "\tSB:" + sb.to_s
  print "\tLB:" + lb.to_s
  print "\tDB:" + db.to_s
  print "\tB:" + b.to_s
  print "\n"
  puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} * 2= #{task.extime + b + get_extime_high_priority(task.proc, task.priority)*2}"
}
taskset = TaskSet.new(tasks1)
taskset.show_taskset



#############################
#
#############################

@grp1.kind = "long"
@grp2.kind = "short"

$taskList = tasks1
tasks1.each{|task|
  print "タスク" + task.task_id.to_s
  bb = BB(task)
  ab = AB(task)
  sb = SB(task)
  lb = LB(task)
  db = DB(task)
  
  b = bb + ab + sb + lb + db
  print "\tBB:" + bb.to_s
  print "\tAB:" + ab.to_s
  print "\tSB:" + sb.to_s
  print "\tLB:" + lb.to_s
  print "\tDB:" + db.to_s
  print "\tB:" + b.to_s
  print "\n"
  puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} * 2= #{task.extime + b + get_extime_high_priority(task.proc, task.priority)*2}"
}
taskset = TaskSet.new(tasks1)
taskset.show_taskset


#############################
#
#############################





#
# Groupクラス定義
# Group.new(group, kind)
#
@grp3 = Group.new(1, "long")
@grp4 = Group.new(2, "long")

#
# Requireクラス定義
# Req.new(reqId, res, time, reqs)
#
@req5_1 = Req.new(1, @grp3, 1, [])
@req7_1 = Req.new(2, @grp4, 3, [])
@req7_2 = Req.new(3, @grp4, 6, [])

@req6_0 = Req.new(4, @grp3, 1, [])
@req6_1 = Req.new(5, @grp4, 6, [@req6_0])
@req6_2 = Req.new(6, @grp3, 4, [])

@req8_1 = Req.new(7, @grp3, 3, [])

#
# Taskクラス定義
# Taks.new(task_id, proc, period, extime, priority, offset, req_list)
#
task5 = Task.new(1, 1, 50, 1, 1, 2, [@req5_1])
task6 = Task.new(2, 2, 50, 15, 2, 3, [@req6_1, @req6_2])
task7 = Task.new(3, 1, 50, 10, 3, 0, [@req7_1, @req7_2])
task8 = Task.new(4, 2, 50, 5, 4, 0, [@req8_1])



$taskList = [task5, task6, task7, task8]

task = $taskList[2]
tasks2 = $taskList

$taskList = tasks2
tasks2.each{|task|
  print "タスク" + task.task_id.to_s
  bb = BB(task)
  ab = AB(task)
  sb = SB(task)
  lb = LB(task)
  db = DB(task)
  
  b = bb + ab + sb + lb + db
  print "\tBB:" + bb.to_s
  print "\tAB:" + ab.to_s
  print "\tSB:" + sb.to_s
  print "\tLB:" + lb.to_s
  print "\tDB:" + db.to_s
  print "\tB:" + b.to_s
  print "\n"
  puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} * 2= #{task.extime + b + get_extime_high_priority(task.proc, task.priority)*2}"
}
taskset = TaskSet.new(tasks2)
taskset.show_taskset
