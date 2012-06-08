#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 
#
#Author:: Takahiro FUJITANI (ERTL, Nagoya Univ.)
#Version:: 0.1.0
#License::
#
#== Usage:
#
#=== 
#$:.unshift(File.dirname(__FILE__))
require "manager"

include WCBT

# タスクを使用率の降順に並び替え
def sort_tasklist_by_utilization
  $taskList.sort{ |a, b|
    -1 * (a.extime/a.period <=> b.extime/b.period)
  }
end

# 指定したインデックスのtasklListのタスクをworst-fitでプロセッサに割り当て
# @param idx 
def assign_task_worstfit(idx)
  proc_id = lowest_util_proc_id
  @proc_list[proc_id - 1].assign_task($taskList[idx])
end

# CPU使用率が一番低いプロセッサIDを返す
def lowest_util_proc_id
  u = 10.0
  id = 0
  @proc_list.each{ |p|
    if p.util < u
      u = p.util 
      id = p.proc_id
    end
  }

  return id 
end

# 各プロセッサの使用率と割当てられているタスク数を表示
def show_proc_info
  @proc_list.each{ |p|
    puts "PE#{p.proc_id}(#{p.util}):#{p.task_list.size}tasks"
  }
end


#
# スケジューラビリティチェック(FMLP-P)
# @param[Fixnum, Fixnum] k : プロセッサID，i : 割当てるタスク数
# @return [Fixnum]
#
def p_schedulability(k, i)
  tlist = @proc_list[k-1].task_list
  return 0.0 if tlist.size == 0
  max = [i, tlist.size].min
  c = 0
  #puts "proc#{k}:#{max}tasks"
  0.upto(max-1){ |j|
    t = tlist[j]
    c += (t.extime + t.bw)/t.period
  }
  tsk = tlist[-1] # 最後に追加されたタスク

  return ((tsk.b - tsk.bw)/tsk.period + c)
end

#
# main
#
@manager = AllManager.new
@manager.all_data_clear

@proc_list = []

# プロセッサクラス作成
1.upto(PROC_NUM){ |id|
  @proc_list << Processor.new({ 'id'=> id }) 
}

umax = 0.1
f = 0.1
system_util_max = PROC_NUM/2.0 # システム使用率の最大値

info = ["sche_check", umax, f]
@manager.create_tasks(TASK_NUM, 30, 10, info)
puts @manager.gm.get_group_array.size
puts @manager.rm.get_require_array.size
@manager.save_tasks("#{JSON_FOLDER}/sche_check")


# タスクworstfitで割り当て
task_count = 0  # 割当てることのできたタスク数
1.upto(@manager.tm.get_task_array.size){ |id|
  assign_task_worstfit(id-1)
  sche = 0
  1.upto(PROC_NUM){ |p_id|
    sche += p_schedulability(p_id, id+1)
  }
  puts "#{id}タスク：#{sche}"
  if sche < system_util_max
    # 設定したシステム使用率を超えていない場合，タスク割り当てできたとする
    task_count += 1
  else
    break
  end
}
puts "割り当てたタスク数：#{task_count}個"
show_proc_info
#pp @proc_list
#p lowest_util_proc_id
