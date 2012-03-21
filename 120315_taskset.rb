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

0.upto(1000){
  #
  # Groupクラス定義
  # Group.new(group, kind)
  #
  @grp1 = Group.new(1, "short")
  @grp2 = Group.new(2, "short")
  
  #
  #  乱数生成のための種を生成
  #
  def generate_seed
    t = Time.now
    return t.sec ^ t.usec ^ Process.pid 
  end
  
  def grouprand
    rand(2)==1 ? @grp1 : @grp2
  end
  srand(generate_seed)
  
  #
  # Requireクラス定義
  # Req.new(reqId, res, time, reqs)
  #
  grp1 = grouprand
  grp2 = grp1 == @grp1 ? @grp2 : @grp1
  grp3 = grouprand
  grp4 = grouprand
  grp5 = grp4 == @grp1 ? @grp2 : @grp1
  grp6 = grouprand
  grp7 = grouprand
  
  time1 = rand(6) + 1
  time2 = rand(6) + 1
  time3 = rand(6) + 1
  time4 = rand(6) + 1
  time5 = rand(6) + 1
  time6 = rand(6) + 1
  time7 = rand(6) + 1
  
  @req1_1 = Req.new(1, grp1, time1, [])
  @req3_1 = Req.new(2, grp2, time2, [])
  @req3_2 = Req.new(3, grp3, time3, [])
  
  @req2_0 = Req.new(4, grp4, time4, [])
  @req2_1 = Req.new(5, grp5, time5, [@req2_0])
  @req2_2 = Req.new(6, grp6, time6, [])
  
  @req4_1 = Req.new(7, grp7, time7, [])
  
  extime1 = rand(5) + time1
  extime2 = rand(5) + time4 + time5 + time6
  extime3 = rand(5) + time2 + time3
  extime4 = rand(5) + time7
  
  #
  # Taskクラス定義
  # Taks.new(task_id, proc, period, extime, priority, offset, req_list)
  #
  task1 = Task.new(1, 1, 50, extime1, 1, 2, [@req1_1])
  task2 = Task.new(2, 2, 50, extime2, 2, 3, [@req2_1, @req2_2])
  task3 = Task.new(3, 1, 50, extime3, 3, 0, [@req3_1, @req3_2])
  task4 = Task.new(4, 2, 50, extime4, 4, 0, [@req4_1])
  
  $taskList = [task1, task2, task3, task4]
  tasks1 = $taskList
  #puts "#{@grp1.kind}, #{@grp2.kind}"
=begin
   $taskList.each{|task|
   print "タスク" + task.task_id.to_s
   print "\tBB:" + BB(task).to_s
   print "\tAB:" + AB(task).to_s
   print "\tSB:" + SB(task).to_s
   print "\tLB:" + LB(task).to_s
   print "\tDB:" + DB(task).to_s
   print "\tB:" + B(task).to_s
   print "\n"
   puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{B(task)} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} = #{task.extime + B(task) + get_extime_high_priority(task.proc, task.priority)}"
   }
=end
  task = $taskList[2]
  a = task.extime + B(task) + get_extime_high_priority(task.proc, task.priority)
  t1 = task
  
  def grouprand2
    rand(2)==1 ? @grp3 : @grp4
  end
  srand(generate_seed)
  
  
  
  
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
  @req5_1 = Req.new(1, grp1==@grp1 ? @grp3 : @grp4, time1, [])
  @req7_1 = Req.new(2, grp2==@grp1 ? @grp3 : @grp4, time2, [])
  @req7_2 = Req.new(3, grp3==@grp1 ? @grp3 : @grp4, time3, [])
  
  @req6_0 = Req.new(4, grp4==@grp1 ? @grp3 : @grp4, time4, [])
  @req6_1 = Req.new(5, grp5==@grp1 ? @grp3 : @grp4, time5, [@req6_0])
  @req6_2 = Req.new(6, grp6==@grp1 ? @grp3 : @grp4, time6, [])

  @req8_1 = Req.new(7, grp7==@grp1 ? @grp3 : @grp4, time7, [])
  
  #
  # Taskクラス定義
  # Taks.new(task_id, proc, period, extime, priority, offset, req_list)
  #
  task5 = Task.new(1, 1, 50, extime1, 1, 2, [@req5_1])
  task6 = Task.new(2, 2, 50, extime2, 2, 3, [@req6_1, @req6_2])
  task7 = Task.new(3, 1, 50, extime3, 3, 0, [@req7_1, @req7_2])
  task8 = Task.new(4, 2, 50, extime4, 4, 0, [@req8_1])
  
  
  
  $taskList = [task5, task6, task7, task8]
  #puts "#{@grp3.kind}, #{@grp4.kind}"
=begin
   $taskList.each{|task|
   print "タスク" + task.task_id.to_s
   print "\tBB:" + BB(task).to_s
   print "\tAB:" + AB(task).to_s
   print "\tSB:" + SB(task).to_s
   print "\tLB:" + LB(task).to_s
   print "\tDB:" + DB(task).to_s
   print "\tB:" + B(task).to_s
   print "\n"
   puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{B(task)} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} = #{task.extime + B(task) + get_extime_high_priority(task.proc, task.priority)}"
   }
=end
  task = $taskList[2]
  tasks2 = $taskList
  b = task.extime + B($taskList[2]) + get_extime_high_priority(task.proc, task.priority)

  

  if a > b + 5
    $DEBUG = true
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
      puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} = #{task.extime + b + get_extime_high_priority(task.proc, task.priority)}"
    }
    taskset = TaskSet.new(tasks1)
    taskset.show_taskset
    
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
      puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} = #{task.extime + b + get_extime_high_priority(task.proc, task.priority)}"
    }
    taskset = TaskSet.new(tasks2)
    taskset.show_taskset
    
    break
  end
}
=begin
 #
 # Requireクラス定義
 # Req.new(reqId, res, time, reqs)
 #
 @req1_1 = Req.new(1, @grp1, rand(10), [])
 @req3_1 = Req.new(2, @grp2, rand(10), [])
 @req3_2 = Req.new(3, @grp2, rand(10), [])
 
 @req2_0 = Req.new(4, @grp1, 2, [])
 @req2_1 = Req.new(5, @grp2, 3, [@req2_0])
 @req2_2 = Req.new(6, @grp1, 1, [])
 
 @req4_1 = Req.new(7, @grp1, 10, [])
 
 #
 # Taskクラス定義
 # Taks.new(task_id, proc, period, extime, priority, offset, req_list)
 #
 task1 = Task.new(1, 1, 50, 10, 1, 2, [@req1_1])
 task2 = Task.new(2, 2, 50, 20, 2, 0, [@req2_1, @req2_2])
 task3 = Task.new(3, 1, 50, 10, 3, 3, [@req3_1, @req3_2])
 task4 = Task.new(4, 2, 50, 20, 4, 0, [@req4_1])
=end