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

JSON_FOLDER = "./120601_sche_ana/json"



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
#    p t.b
    c += (t.extime + t.bw)/t.period
  end
  tsk = tlist[-1] # 最後に追加されたタスク
  
  return ((tsk.b - tsk.bw)/tsk.period + c)
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
system_util_max = proc_num/2.0 # システム使用率の最大値
output_str = []     # データ出力用

# プログレスバー
pbar = ProgressBar.new("スケジューラビリティ解析", (taskset_count*(f_max/0.01).to_i+1))
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

@manager = AllManager.new

# スケジューラビリティ解析ループ
0.0.step(f_max, 0.01) do |f|
  tasksets = 0  # 割当てることのできたタスクセット数
  taskset_count_ave = 0.0  # 割り当てられたタスクセットの平均
  taskset_non = 0.0        # 割り当てられなかったタスクセット
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
    #puts "#{@manager.tm.get_task_array.size}タスク:(#{@manager.tm.get_alltask_util.round(2)})"
    #puts @manager.gm.get_group_array.size
    #puts @manager.rm.get_require_array.size

    # タスクworstfitで割り当て
    1.upto(@manager.tm.get_task_array.size) do |id|
      @manager.assign_task_worstfit(id-1) # プロセッサにタスク割り当て
    end

    #add_task = @manager.tm.get_task_by_index(id-1)
    # @manager.pm.add_tasks([add_task], {:assign_mode => WORST_FIT})
    
    init_computing(@manager.tm.get_task_array)
    set_blocktime
    
    non_schedulable_flg = false # スケジューラブルでなかった場合立てるフラグ
    1.upto(proc_num) do |p_id|
      #sche += p_schedulability(p_id, id+1)
      sche = p_schedulability(p_id, @manager.tm.get_task_array.size)
      #puts "\tPROC#{p_id}:#{ProcessorManager.get_proc(p_id).task_list.size}タスク:#{sche.round(2)}"
      if sche < 1
        next
      else
        non_schedulable_flg = true
        break
      end
    end

    #      if sche < system_util_max
    if non_schedulable_flg == false
      # 設定したシステム使用率を超えていない場合，タスク割り当てできたとする
      taskset_count_ave += 1
    end
    pbar.inc 
  end
  @manager.save_tasks("#{JSON_FOLDER}/sche_check_#{umax}_nest")
  #puts "\t#{taskset_count_ave}"
  taskset_count_ave /= taskset_count  
  output_str << taskset_count_ave*100

end
#taskset = TaskSet.new
#taskset.show_taskset

filename = "./120601_sche_ana/#{taskset_count}taskset_umax#{umax}_0.8_edf.dat"
File.open(filename, "w") do |fp|
  f = 0.0 
  output_str.each do |str|
    fp.puts "#{f.round(2)} #{str}"
    f += 0.01
  end
end
puts "#{filename}に保存．"
pbar.finish
#show_proc_info
#pp @proc_list
#p lowest_util_proc_id
