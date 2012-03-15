require "wcbt"
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
@req1_1 = Req.new(1, @grp1, 2, [])
@req3_1 = Req.new(2, @grp1, 4, [])
@req3_2 = Req.new(3, @grp2, 2, [])

@req2_0 = Req.new(4, @grp2, 2, [])
@req2_1 = Req.new(5, @grp1, 3, [@req2_0])
@req2_2 = Req.new(6, @grp2, 1, [])

@req4_1 = Req.new(7, @grp1, 1, [])

#
# Taskクラス定義
# Taks.new(task_id, proc, period, extime, priority, offset, req_list)
#
task1 = Task.new(1, 1, 50, 4, 1, 2, [@req1_1])
task2 = Task.new(2, 2, 50, 8, 2, 0, [@req2_1, @req2_2])
task3 = Task.new(3, 1, 50, 7, 3, 3, [@req3_1, @req3_2])
task4 = Task.new(4, 2, 50, 4, 4, 0, [@req4_1])

$taskList = [task1, task2, task3, task4]
puts "#{@grp1.kind}, #{@grp2.kind}"
$taskList.each{|task|
  puts "タスク" + task.taskId.to_s
  puts "BB:" + BB(task).to_s
  puts "AB:" + AB(task).to_s
  puts "SB:" + SB(task).to_s
  puts "LB:" + LB(task).to_s
  puts "DB:" + DB(task).to_s
  puts "B:" + B(task).to_s
  
  puts "最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{B(task)} + プリエンプト時間#{get_extime_high_priority(task.proc, task.priority)} = #{task.extime + B(task) + get_extime_high_priority(task.proc, task.priority)}"
}

