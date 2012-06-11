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
require 'progressbar'
require 'task-CUI'

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
  tsk = $taskList[idx]
=begin
  # longリソース要求をしているタスクかチェック
  unless tsk.get_long_require_array.size == 0
    # longリソースがある場合，
    # longリソース要求をするタスクのあるプロセッサに割当てる
    @proc_list.each{ |p|
      p.task_list.each{ |t|
        if t.get_long_require_array.size > 0
          #このプロセッサに割り当て
          p.assign_task(tsk)
        end
      }
    }
  else 
=end
    proc_id = lowest_util_proc_id
    @proc_list[proc_id - 1].assign_task(tsk)
  #end
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
taskset_count = 50 # 使用するタスクセット数
taskcount_ave = 0.0 # 割り当てられたタスクの平均
umax = 0.3          # タスク使用率の最大値
f_max = 0.1         # nesting factor
system_util_max = PROC_NUM/2.0 # システム使用率の最大値
output_str = []     # データ出力用

# プログレスバー
pbar = ProgressBar.new("スケジューラビリティ解析", taskset_count*((f_max/0.01).to_i+1))
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"


# スケジューラビリティ解析ループ
0.step(f_max, 0.01){ |f|
#  p f
  taskset_count.times{
    @manager = AllManager.new
    @manager.all_data_clear
    
    @proc_list = []

    # プロセッサクラス作成
    1.upto(PROC_NUM){ |id|
      @proc_list << Processor.new({ 'id'=> id }) 
    }

    info = ["sche_check", umax, f]
    @manager.create_tasks(TASK_NUM, 30, 10, info)
    #puts @manager.gm.get_group_array.size
    #puts @manager.rm.get_require_array.size
    #@manager.save_tasks("#{JSON_FOLDER}/sche_check")


    # タスクworstfitで割り当て
    task_count = 0  # 割当てることのできたタスク数
    1.upto(@manager.tm.get_task_array.size){ |id|
      assign_task_worstfit(id-1) # プロセッサにタスク割り当て
      set_blocktime
      sche = 0
      1.upto(PROC_NUM){ |p_id|
        sche += p_schedulability(p_id, id+1)
      }
      #puts "#{id}タスク：#{sche}"
      if sche < system_util_max
        # 設定したシステム使用率を超えていない場合，タスク割り当てできたとする
        task_count += 1
      else
        break
      end
    }
    #puts "割り当てたタスク数：#{task_count}個"
    taskcount_ave += task_count
    pbar.inc 
  }
  taskcount_ave /= taskset_count
  
  output_str << (taskcount_ave/TASK_NUM)*100
}
taskset = TaskSet.new($taskList)
taskset.show_taskset

File.open("#{taskset_count}taskset_umax#{umax}.dat", "w"){ |fp|
  f = 0.0 
  output_str.each{ |str|
    fp.puts "#{f} #{str}"
    f += 0.01
  }
}
pbar.finish
#show_proc_info
#pp @proc_list
#p lowest_util_proc_id
