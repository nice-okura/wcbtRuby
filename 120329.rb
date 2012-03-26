#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120329ミーティング用
#タスクの最悪実行時間を4パターンのタスクセットで比較
# タスクセットはランダム
#
#

require "wcbt"
require "task"
require "task-CUI"
require "manager"

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
$DEBUG = false


#############################
#
#############################

@gm = GroupManager.instance
@rm = RequireManager.instance
@tm = TaskManager.instance

@gm.create_group_array(5)
@rm.create_require_array(10)
@tm.create_task_array(10)

@gm.save_group_data("120329_group.json")
@rm.save_require_data("120329_require.json")
@tm.save_task_data("120329_task.json")

$taskList = @tm.get_task_array
taskset = TaskSet.new(@tm.get_task_array)

puts "通常"

$taskList.each{|task|
  print "タスク"
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
  puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} = #{task.extime + b + get_extime_high_priority(task.proc, task.priority)}"
}

taskset.show_taskset

puts "全部long"

#
# リソースを全てlongにする
#
@gm.get_group_array.each{|g|
  g.kind = "long"
}

$taskList.each{|task|
  print "タスク"# + task.task_id.to_s
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
  puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} = #{task.extime + b + get_extime_high_priority(task.proc, task.priority)}"
}

taskset.show_taskset


puts "全部short"

#
# リソースを全てshortにする
#
@gm.get_group_array.each{|g|
  g.kind = "short"
}

$taskList.each{|task|
  print "タスク"# + task.task_id.to_s
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
  puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} = #{task.extime + b + get_extime_high_priority(task.proc, task.priority)}"
}

taskset.show_taskset

