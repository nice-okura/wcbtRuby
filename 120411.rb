#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120411ミーティング用
# あるタスクセットのリソースグループを全パターン計算し，最速，最悪のパターンを表示
# 
#
#
require "wcbt"
require "task"
require "task-CUI"
require "manager"
require "progressbar"


def save_min
  @manager.save_tasks("120411_min_task.json", "120411_min_require.json", "120411_min_group.json") 
end

def save_max
  @manager.save_tasks("120411_max_task.json", "120411_max_require.json", "120411_max_group.json") 
end



def get_wcrt(task, b=nil)
  time = 0
  if b == nil
    block = task.b
  else
    block = b
  end
  
  time = task.extime + block + get_extime_high_priority(task) 
  return time 
end


#
# グループを変更
#
def change_groups(str)
  i = 0
  str.each_byte{|c|
    @manager.gm.get_group_array[i].kind = c.chr=="0" ? "short" : "long"
    i += 1
  }
end

#
# 現在のリソースグループ表示
#
def show_groups
  @manager.gm.get_group_array.each{|g|
    print "#{g.kind[0].chr} "
  }
end


include WCBT
$DEBUG = false


#############################
#
#############################

def compute_wcrt
  #@manager = AllManager.new
  #@manager.load_tasks("120411_task.json", "120411_require.json", "120411_group.json")
  
  
  
  #
  # グループ数
  #
  group_count = @manager.gm.get_group_array.size
  
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
  @manager.gm.get_group_array.each{|g|
    g.kind = "short"
  }
  #set_blocktime
  taskset = TaskSet.new(@manager.tm.get_task_array)
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
  #pbar = ProgressBar.new("WCRTの計測", group_times*$taskList.size)
  #pbar.format_arguments = [:percentage, :bar, :stat]
  #  pbar.format = "%3d%% %s %s"

  i = 0
  change_count = 0
  group_times.times{
    wcrt_max_system = -1 # 適当な最小値
    set_blocktime
    #show_blocktime
    $taskList.each{|t|
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
      change_count += 1
    end
    i += 1
    istr = ("%010b" % [i])[10-group_count, group_count]
    #p "#{i}:#{istr}"
    change_groups(istr)
  }
  #show_blocktime
  return change_count
end

#
# main関数
#
tasks = 12
requires = 10
groups = 4
rcsl = 0.3
extime = 50
@manager = AllManager.new
loop_count = 10
pbar = ProgressBar.new("WCRTの計測", 10*loop_count)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"
mes = ""


0.1.step(1.0, 0.1){|r|
  rcsl = r
  c = 0
  info = ["120411", extime, rcsl]
  loop_count.times{
    @manager.create_tasks(tasks, requires, groups, info)
    #@manager.save_tasks("#{FILENAME}_task.json", "#{FILENAME}_require.json", "#{FILENAME}_group.json")
    c += compute_wcrt
    pbar.inc
    @manager.all_data_clear
  }
  mes += "[TASKS:#{tasks} CPUs:#{PROC_NUM} GROUPS:#{groups} RCSL:#{rcsl} ]change_count:#{c.to_f/loop_count.to_f}\n"
}
puts mes
pbar.finish
