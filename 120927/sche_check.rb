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
JSON_FOLDER = "./120926/json"

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
=begin
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
=end
    proc_id = lowest_util_proc_id
    ProcessorManager.proc_list[proc_id - 1].assign_task(tsk)
  #end
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

# スケジューラビリティチェック(FMLP-P)
# @param[Fixnum, Fixnum] k : プロセッサID，i : 割当てるタスク数
# @return [Fixnum]
def p_schedulability(k, i)
  tlist = ProcessorManager.get_proc(k).task_list
  return 0.0 if tlist.size == 0
  max = [i, tlist.size].min
  c = 0

  0.upto(max-1) do |j|
    t = tlist[j]
#    p t.b
    c += (t.extime + t.sb)/t.period
  end
  tsk = tlist[-1] # 最後に追加されたタスク
  
  return ((tsk.b - tsk.sb)/tsk.period + c)
end

# 現在割り当てられているタスクリストを返す
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
taskset_count = 500 # 使用するタスクセット数
task_count = 100     # タスクセット当たりのタスク数
umax = 0.3            # タスク使用率の最大値
#cpu_util_max = 0.8  # タスクセット生成時の最大CPU使用率
rcsl_max = 2.0      # nesting factor
system_util_max = proc_num/2.0 # システム使用率の最大値
output_str = []     # データ出力用

# プログレスバー
pbar = ProgressBar.new("スケジューラビリティ解析", (6*taskset_count*((rcsl_max-1.0)/0.1).to_i+1))
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

@manager = AllManager.new

## スケジューラビリティ解析ループ
# RCSLを変えて解析する
0.5.step(1.0, 0.1) do |cpu_util_max|
1.0.step(rcsl_max, 0.1) do |rcsl|
  tasksets = 0  # 割当てることのできたタスクセット数
  taskset_count_ave = 0.0  # 割り当てられたタスクセットの平均
  taskset_non = 0.0        # 割り当てられなかったタスクセット
  taskset_count.times do |i|

    @manager.all_data_clear
    
    info =  { }
    info[:mode] = MY_SCHE_CHECK
    info[:f] = 0.05
    info[:rcsl] = rcsl
    info[:umax] = umax
    info[:proc_num] = proc_num
    info[:cpu_util_max] = cpu_util_max

    @manager.create_tasks(task_count, 30, 10, info)

    # タスクリストを使用率の降順でソート
    @manager.tm.sort_tasklist_by_util
    #puts "#{@manager.tm.get_task_array.size}タスク:(#{@manager.tm.get_alltask_util.round(2)})"
    #puts @manager.gm.get_group_array.size
    #puts @manager.rm.get_require_array.size

    # タスクworstfitで割り当て
    1.upto(@manager.tm.get_task_array.size) do |id|
      @manager.assign_task_worstfit(id-1) # プロセッサにタスク割り当て
    end

    init_computing(@manager.tm.get_task_array)
    set_blocktime
    
    non_schedulable_flg = false # スケジューラブルでなかった場合立てるフラグ
    1.upto(proc_num) do |p_id|
      ProcessorManager.proc_list.each do |proc|
        proc.task_list.each do |task|
          if task.check_schedulable == false
            # スケジュール可能でない場合
            non_schedulable_flg = true
            break
          end
        end
      end
    end

    if non_schedulable_flg == false
      # 設定したシステム使用率を超えていない場合，タスク割り当てできたとする
      taskset_count_ave += 1
    end
    pbar.inc 
  end
  @manager.save_tasks("#{JSON_FOLDER}/sche_check_CPU_UTIL#{cpu_util_max}_UMAX#{umax}_RCSL#{rcsl}_preemptive_spin")
  #puts "\t#{taskset_count_ave}"
  taskset_count_ave /= taskset_count  
  output_str << taskset_count_ave*100
end
filename = "./120926/wcrt_analysis_#{taskset_count}taskset_CPU_UTIL#{cpu_util_max}_UMAX#{umax}_preemptive_spin.dat"
File.open(filename, "w") do |fp|
  rcsl = 1.0
  output_str.each do |str|
    fp.puts "#{rcsl.round(3)} #{str.to_f.round(3)}"
    rcsl += 0.1
  end
  output_str = []
end
puts "#{filename}に保存．"
end
#taskset = TaskSet.new
#taskset.show_taskset


pbar.finish
#show_proc_info
#pp @proc_list
#p lowest_util_proc_id
