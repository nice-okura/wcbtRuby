#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120329ミーティング用
# あるタスクセットのリソースグループを全パターン計算し，最速，最悪のパターンを表示
# 
#
#

require "wcbt"
require "task"
require "task-CUI"
require "manager"

def save
  @manager.save_tasks("120329_min_task.json", "120329_min_require.json", "120329_min_group.json") 
end

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


#
# グループを変更
#
def change_groups(str)
  i = 0
  str.each_byte{|c|
    @manager.gm.get_group_array[i].kind = c.chr=="0" ? "short" : "long"
    i += 1
  }
end

#
# 現在のリソースグループ表示
#
def show_groups
  @manager.gm.get_group_array.each{|g|
    print "#{g.kind[0].chr} "
  }
end


include WCBT
$DEBUG = false


#############################
#
#############################

@manager = AllManager.new
@manager.load_tasks("120329_task.json", "120329_require.json", "120329_group.json")

$taskList = @manager.tm.get_task_array
taskset = TaskSet.new(@manager.tm.get_task_array)

puts "通常"

$taskList.each{|task|
  print "タスク + #{task.task_id}"
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

#
# グループ数
#
group_count = @manager.gm.get_group_array.size

#
# グループのパターン数
#
group_times = 2**group_count
p "#{group_times}times"
#
# グループパターン数を２進数で記録
#
group_binary = group_times.to_s(2)

#
# リソースを全てshortにする
#
@manager.gm.get_group_array.each{|g|
  g.kind = "short"
}

min_preempt_time = 10000000 # 適当な最大値

#
# タスク6の最悪応答時間が最も良くなる場合を探す
#
i = 0
group_times.times{
  $taskList.each{|task|
    if task.task_id == 4
      #print "タスク"
      bb = BB(task)
      ab = AB(task)
      sb = SB(task)
      lb = LB(task)
      db = DB(task)
      
      b = bb + ab + sb + lb + db
      pre = task.extime + get_extime_high_priority(task) + b
      #puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{pri} = #{task.extime + b + pri}"
      show_groups
      if pre < min_preempt_time
        min_preempt_time = pre
        puts "!!!!!pre:#{pre}"
        save
        break
      end
      print "-> #{pre}"
    end
  }
  i += 1
  istr = ("%010b" % [i])[10-group_count, group_count]
  #p "#{i}:#{istr}"
  change_groups(istr)
}
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
