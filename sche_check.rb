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
$:.unshift(File.dirname(__FILE__))
require './manager'
require 'progressbar'
require './task-CUI'

include WCBT

# タスクを使用率の降順に並び替え
def sort_tasklist_by_utilization
  @manager.tm.get_task_array.sort do |a, b|
    -1 * (a.extime/a.period <=> b.extime/b.period)
  end
end

# 指定したインデックスのtasklListのタスクをworst-fitでプロセッサに割り当て
# @param idx 
def assign_task_worstfit(idx)
  tsk = @manager.tm.get_task_by_index(idx)
#=begin
  # longリソース要求をしているタスクかチェック
  unless tsk.long_require_array.size == 0
    # longリソースがある場合，
    # longリソース要求をするタスクのあるプロセッサに割当てる
    ProcessorManager.proc_list.each do |p|
      p.task_list.each do |t|
        if t.long_require_array.size > 0
          #このプロセッサに割り当て
          p.assign_task(tsk)
        end
      end
    end
  else 
#=end
    proc_id = lowest_util_proc_id
    ProcessorManager.proc_list[proc_id - 1].assign_task(tsk)
  end
end


# CPU使用率が一番低いプロセッサIDを返す
def lowest_util_proc_id
  u = 10.0
  id = 0
  ProcessorManager.proc_list.each do |p|
    if p.util < u
      u = p.util 
      id = p.proc_id
    end
  end

  return id 
end


# 各プロセッサの使用率と割当てられているタスク数を表示
def show_proc_info
  ProcessorManager.proc_list.each do |p|
    puts "PE#{p.proc_id}(#{p.util}):#{p.task_list.size}tasks"
  end
end


#
# スケジューラビリティチェック(FMLP-P)
# @param[Fixnum, Fixnum] k : プロセッサID，i : 割当てるタスク数
# @return [Fixnum]
#
def p_schedulability(k, i)
  tlist = ProcessorManager.get_proc(k).task_list
  return 0.0 if tlist.size == 0
  max = [i, tlist.size].min
  c = 0

  0.upto(max-1) do |j|
    t = tlist[j]
    c += (t.extime + t.sb)/t.period
  end
  tsk = tlist[-1] # 最後に追加されたタスク

  return ((tsk.b - tsk.sb)/tsk.period + c)
end


#
# 現在割り当てられているタスクリストを返す
#
def get_using_tasks
  tasks = []
  ProcessorManager.proc_list.each do |p|
    tasks += p.task_list
  end
  
  return tasks
end

#
# main
#
proc_num = 4
taskset_count = 500  # 使用するタスクセット数
task_count = 20     # タスクセット当たりのタスク数
umax = 0.3          # タスク使用率の最大値
f_max = 0.1         # nesting factor
system_util_max = PROC_NUM/2.0 # システム使用率の最大値
output_str = []     # データ出力用

# プログレスバー
pbar = ProgressBar.new("スケジューラビリティ解析", taskset_count*((f_max/0.01).to_i+1))
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

@manager = AllManager.new

# スケジューラビリティ解析ループ
0.0.step(f_max, 0.01) do |f|
  taskcount_ave = 0.0  # 割り当てられたタスクの平均
  taskset_count.times do |i|

    @manager.all_data_clear
    
    info =  { }
    info[:mode] = SCHE_CHECK
    info[:f] = f
    info[:umax] = umax
    info[:proc_num] = proc_num
    @manager.create_tasks(task_count, 30, 10, info)
    # タスクリストを使用率の降順でソート
    @manager.tm.sort_tasklist_by_util
    #puts @manager.gm.get_group_array.size
    #puts @manager.rm.get_require_array.size



    # タスクworstfitで割り当て
    tasks = 0  # 割当てることのできたタスク数
    1.upto(task_count) do |id|
      assign_task_worstfit(id-1) # プロセッサにタスク割り当て
      #add_task = @manager.tm.get_task_by_index(id-1)
      # @manager.pm.add_tasks([add_task], {:assign_mode => WORST_FIT})
      
      init_computing(get_using_tasks)
      set_blocktime
      
      non_schedulable_flg = false # スケジューラブルでなかった場合立てるフラグ
      1.upto(proc_num) do |p_id|
        #sche += p_schedulability(p_id, id+1)
        next if p_schedulability(p_id, id+1) < 1
        non_schedulable_flg = true
      end

#      if sche < system_util_max
      if non_schedulable_flg == false
        # 設定したシステム使用率を超えていない場合，タスク割り当てできたとする
        tasks += 1
      else
        break
      end
    end
    #@manager.save_tasks("#{JSON_FOLDER}/sche_check_#{i}")
    taskcount_ave += tasks
    pbar.inc 
  end
  
  taskcount_ave /= taskset_count
  
  output_str << (taskcount_ave/task_count)*100
end
#taskset = TaskSet.new($task_list)
#taskset.show_taskset

filename = "#{taskset_count}taskset_umax#{umax}.dat"
File.open(filename, "w") do |fp|
  f = 0.0 
  output_str.each do |str|
    fp.puts "#{f} #{str}"
    f += 0.01
  end
end
puts "#{filename}に保存．"
pbar.finish
#show_proc_info
#pp @proc_list
#p lowest_util_proc_id
