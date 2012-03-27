#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120329ミーティング用
# あるタスクセットのリソースkindを全パターン計算し，最速，最悪のパターンを表示
# 
#
#

require "wcbt"
require "task"
require "task-CUI"
require "manager"

def get_extime_high_priority(task)
  time = 0
  $taskList.each{|t|
    sb = SB(t)
    if t.proc == task.proc && t.priority < task.priority
      time += (t.extime + sb) * ((task.period / t.period).ceil + 1)
      #print "(#{t.extime}+#{sb})*#{(t.period/task.period).ceil + 1}(#{t.period}, #{task.period}), " 
    end
  }
  puts ""
  return time
end

def get_wcrt(task, b=nil)
  time = 0
  if b == nil
    block = BB(task)
  else
    block = b
  end
  
  time = task.extime + block + get_extime_high_priority(task) 
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

=begin
@gm.create_group_array(5)
@rm.create_require_array(10)
@tm.create_task_array(6)
=end
@gm.load_group_data("120329_group.json")
@rm.load_require_data("120329_require.json")
@tm.load_task_data("120329_task.json")

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
  pri = get_extime_high_priority(task) 
  puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{pri} = #{task.extime + b + pri}"
}

taskset.show_taskset

=begin
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
  puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task)} = #{task.extime + b + get_extime_high_priority(task)}"
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
  puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task)} = #{task.extime + b + get_extime_high_priority(task)}"
}

taskset.show_taskset
=end
