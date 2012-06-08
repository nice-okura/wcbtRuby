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

# 指定した範囲のtasklListのタスクをworst-fitでプロセッサに割り当て
# @param start_idx, end_idx 
def assign_task_worstfit(start_idx, end_idx)
  start_idx.upto(end_idx){ |idx|
    proc_id = lowest_util_proc_id
    @proc_list[idx].assign_task($taskList[idx])
  }
  
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
info = ["sche_check", umax, f]
@manager.create_tasks(TASK_NUM, 30, 10, info)
puts @manager.gm.get_group_array.size
puts @manager.rm.get_require_array.size
@manager.save_tasks("#{JSON_FOLDER}/sche_check")
p_schedulability_check(1, 30)
p_schedulability_check(2, 30)
p_schedulability_check(3, 30)
p_schedulability_check(4, 30)

#@proc_list[0].assign_task(@manager.tm.get_task_array[0])
pp @proc_list
assign_task_worstfit(0, 0)
pp @proc_list
p lowest_util_proc_id
