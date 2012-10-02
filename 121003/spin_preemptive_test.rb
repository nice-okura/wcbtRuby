#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require './manager'
require './task-CUI'
require 'progressbar'

TMP_FILE = "./121003/tmp"


# Parameters
taskset_count = 50
task_count_array = [4]
proc_count = 4
info = { }

# Progress bar Setting
pbar = ProgressBar.new("WCRT Improvement Rate", task_count_array.size * taskset_count) 
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"


info[:mode] = CREATE_MANUALLY
info[:assign_mode] = ID_ORDER
info[:require_count] = 2
info[:proc_num] = proc_count
info[:extime_range] = 50..500
info[:spin_preemptive] = false

@manager = AllManager.new
p info
task_count_array.each do |task_count|
  taskset_count.times do
    # Variables
    wcrt_nonpreemptive = {}  # WCRT under nonpreemptive spin
    wcrt_preemptive = {}     # WCRT under preemptive spin
    all_wcrt_nonpreemptive = 0 # all WCRT under nonpreemptive spin
    all_wcrt_preemptive = 0 # all WCRT under preemptive spin
    
    
    
    @manager.all_data_clear
    @manager.create_tasks(task_count, task_count*2, task_count/2, info)
    ProcessorManager.proc_list.each do |proc|
      t = proc.get_highest_priority_task
      unless t == nil
        wcrt_nonpreemptive[t.task_id] = t.wcrt
        #print "Task#{t.task_id}:#{t.wcrt}\t"
        #print "Task#{t.task_id}:#{t.bb} #{t.ab} #{t.sb} #{t.lb} #{t.db} #{t.b} =>\t"
        #print "Task#{t.task_id}:#{t.ab}\t"
      end
    end
    @manager.save_tasks(TMP_FILE)
    
    info[:spin_preemptive] = true
    @manager.all_data_clear
    @manager.load_tasks(TMP_FILE, info)
    
    ProcessorManager.proc_list.each do |proc|
      t = proc.get_highest_priority_task
      unless t == nil
        wcrt_preemptive[t.task_id] = t.wcrt
        #print "Task#{t.task_id}:#{t.wcrt}\t"
        #print "Task#{t.task_id}:#{t.bb} #{t.ab} #{t.sb} #{t.lb} #{t.db} #{t.b} =>\t"
        #print "Task#{t.task_id}:#{t.ab}\t"
      end
    end
 
    #p wcrt_nonpreemptive
    #p wcrt_preemptive
    wcrt_nonpreemptive.each_value{|v| all_wcrt_nonpreemptive += v }
    wcrt_preemptive.each_value{|v| all_wcrt_preemptive += v }
    
    diff = all_wcrt_nonpreemptive - all_wcrt_preemptive
    p (diff/all_wcrt_nonpreemptive) * 100
    
    #pbar.inc
  end
end
