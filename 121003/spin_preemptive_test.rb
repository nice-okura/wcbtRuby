#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require './manager'
require './task-CUI'
require 'progressbar'



def set_blocktime_preemptiveAB
  # 各タスクのブロック時間を計算
  $calc_task.each{ |t| t.sb = SB(t) }
  $calc_task.each{ |t| SB_not_tight(t) }
  $calc_task.each{ |t| t.ab = AB_preemptive(t) }
  $calc_task.each{ |t| t.bb = BB(t) }
  $calc_task.each{ |t| t.lb = LB(t) }
  $calc_task.each{ |t| t.db = DB(t) }
  $calc_task.each{ |t| t.b = t.bb + t.ab + t.sb + t.lb + t.db }

  # 最悪応答時間の計算
  $calc_task.each do |t|
    t.set_wcrt(wcrt(t))
  end
end


# プログレスバー
pbar = ProgressBar.new("高優先度タスク最悪応答時間改善率", 100) 
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

# 各種パラメータ
taskset_count = 1
task_count = 20
proc_count = 4
info = { }

info[:mode] = CREATE_MANUALLY
info[:proc_num] = proc_count
info[:extime_range] = 20..30

@manager = AllManager.new
p info
taskset_count.times do
  @manager.all_data_clear
  @manager.create_tasks(task_count, task_count*2, task_count/2, info)
  ProcessorManager.proc_list.each do |proc|
    t = proc.get_highest_priority_task
    unless t == nil
      pre_wcrt = t.wcrt
      print "Task#{t.task_id}:#{t.bb} #{t.ab} #{t.sb} #{t.lb} #{t.db} #{t.b} =>\t"
      if pre_wcrt < t.wcrt
        #taskset = TaskSet.new
        #taskset.show_taskset
        #show_blocktime
      end
    end
    pp t
    
  end
  @manager.save_tasks("./121003/tmp0")
  
  puts

  init_computing($task_list)
  set_blocktime
  
  ProcessorManager.proc_list.each do |proc|
    t = proc.get_highest_priority_task
    unless t == nil
      pre_wcrt = t.wcrt
      print "Task#{t.task_id}:#{t.bb} #{t.ab} #{t.sb} #{t.lb} #{t.db} #{t.b} =>\t"
    end
    pp t
    
  end
  puts
  @manager.save_tasks("./121003/tmp1")
  
end

