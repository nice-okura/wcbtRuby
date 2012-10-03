#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120411ミーティング用
# あるタスクセットのリソースグループを全パターン計算し，最速，最悪のパターンを表示
# 
#
#
require "./task-CUI"
require "./manager"
require "progressbar"


def save_min
  @manager.save_tasks("120411_min_task") 
end

def save_max
  @manager.save_tasks("120411_max_task") 
end



def get_wcrt(task, b=nil)
  time = 0
  if b == nil
    block = task.b
  else
    block = b
  end
  
  time = task.get_extime + block + get_extime_high_priority(task) 
  return time 
end


#
# グループを変更
#
def change_groups(str)
  i = 0
  str.each_byte{|c|
    GroupManager.get_group_array[i].kind = c.chr=="0" ? SHORT : LONG
    i += 1
  }
end

#
# 現在のリソースグループ表示
#
def show_groups
  GroupManager.get_group_array.each{|g|
    print "#{g.kind[0].chr} "
  }
end

#
# longグループ数を取得
#
def get_long_groups
  c = 0
  GroupManager.get_group_array.each{|g|
    #c += 1 if g.kind == LONG
    if g.kind == LONG
      c += 1
      #puts LONG
    end
  }
  return c
end

include WCBT
$DEBUG = false


#############################
#
#############################

def compute_wcrt
  #
  # グループ数
  #
  group_count = GroupManager.get_group_array.size
  
  #
  # グループのパターン数
  #
  group_times = 2**group_count
  #p "#{group_times}times"
  
  #
  # グループパターン数を２進数で記録
  #
  group_binary = group_times.to_s(2)
  
  #
  # リソースを全てshortにする
  #
  GroupManager.get_group_array.each{|g|
    g.kind = SHORT
  }
  #set_blocktime
  taskset = TaskSet.new#(@manager.tm.get_task_array)
  #show_blocktime
  #taskset.show_taskset
  
  
  #
  # システム全体の最悪応答時間
  #
  min_all_wcrt = 10000000 # 適当な最大値
  max_all_wcrt = -1       # 適当な最小値
  
  #
  # システム全体の最悪応答時間が最も良くなる場合を探す
  #
  #pbar = ProgressBar.new("WCRTの計測", group_times*$task_list.size)
  #pbar.format_arguments = [:percentage, :bar, :stat]
  #  pbar.format = "%3d%% %s %s"

  i = 0
  change_count = 0
  long_count = 0
  group_times.times{
    wcrt_max_system = -1 # 適当な最小値
    set_blocktime
    #show_blocktime
    $task_list.each{|t|
      wcrt = get_wcrt(t, t.b)
      if wcrt_max_system < wcrt
        wcrt_max_system = wcrt
      end
      #pbar.inc
    }
    if wcrt_max_system < min_all_wcrt
      min_all_wcrt = wcrt_max_system
      #puts "最悪応答時間:#{min_all_wcrt}"
      #show_groups
      #save_min
      long_count = get_long_groups
      change_count += 1
    end
    i += 1
    istr = ("%010b" % [i])[10-group_count, group_count]
    #p "#{i}:#{istr}"
    change_groups(istr)
    

  }
  #show_blocktime
  #return [get_long_groups, change_count]
  return long_count
end

#
# main関数
#
tasks = 12
requires = 10
groups = 4
rcsl = 0.1
extime = 50
resouce_count_max = 4
start_task_num = 8
end_task_num = 8
task_step_num = 4
loop_count = 1
info = {}

@manager = AllManager.new


pbar = ProgressBar.new("WCRTの計測", loop_count*((end_task_num - start_task_num)/task_step_num + 1)*resouce_count_max*loop_count)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"
mes = ""


start_task_num.step(end_task_num, task_step_num){|t|
  tasks = t
  for g in [4]
  #for g in [1, 2, 4, 8]
    groups = g
    info[:mode] = "120411"
    info[:extime] = extime
    info[:rcsl] = rcsl
    info[:proc_num] = 4
    #info = ["120411", extime, rcsl]
    c = []
    c.fill(0,0..9)

    loop_count.times{
      i = 0
      rcsl = 0.1
      @manager.all_data_clear
      @manager.create_tasks(tasks, requires, groups, info)
      while rcsl < 1.0
        #
        # クリティカルセクションの変更
        #
        $task_list.each{|t|
          t.req_list[0].change_require_time(t.get_extime * rcsl)
        }
        c[i] += compute_wcrt
        pbar.inc
        rcsl += 0.1
        rcsl.round(3)
        i += 1
      end

    }
    j = 0.1
    c.each{|l|
      # long_count 全タスク中のlongリソースであり，
      # タスク数が増えれ増えて当たり前なので，1タスクあたりの平均longリソース数を見るため，
      # タスク数で割る
      puts "[TASKS:#{tasks} CPUs:#{PROC_NUM} GROUPS:#{groups} RCSL:#{j} ]long_count:#{l.to_f/loop_count.to_f/tasks.to_f}\n"
      j += 0.1
    }
    puts "------------------------------------------------------------"
  end
}
puts mes
pbar.finish
