#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 121003ミーティング用
# あるタスクセットのリソースグループを全パターン計算し，最速，最悪のパターンを表示
# リソース種をX軸にしてグラフを作成してみる．
#
#
require "./task-CUI"
require "./manager"
require "progressbar"


def save_min
  @manager.save_tasks("./121003/2CPU_6task_min") 
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
    @manager.using_group_array[i].kind = c.chr=="0" ? SHORT : LONG
    i += 1
  }
end

#
# 現在のリソースグループ表示
#
def show_groups
  @manager.using_group_array.each{|g|
    print "#{g.kind[0].chr} "
  }
end

#
# longグループ数を取得
#
def get_long_groups
  c = 0
  @manager.using_group_array.each{|g|
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
#
#############################

def compute_wcrt
  #pp @manager.using_group_array
  #
  # グループ数
  #
  group_count = @manager.using_group_array.size
  
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
  taskset = TaskSet.new
  
  #
  # システム全体の最悪応答時間
  #
  min_all_wcrt = 10000000 # 適当な最大値
  max_all_wcrt = -1       # 適当な最小値
  
  #
  # システム全体の最悪応答時間が最も良くなる場合を探す
  #
  
  i = 0
  change_count = 0
  long_count = 0
  
  #$DEBUG = true
  
  group_times.times{
    wcrt_max_system = -1 # 適当な最小値
    
    $task_list.each{|t|
      t.resetting
    }
    init_computing($task_list)
    set_blocktime
    
    $task_list.each{|t|
      wcrt = get_wcrt(t, t.b)
      wcrt_max_system = wcrt if wcrt_max_system < wcrt
      #pbar.inc
    }
    
    
    if wcrt_max_system < min_all_wcrt
      min_all_wcrt = wcrt_max_system
      puts "最悪応答時間:#{min_all_wcrt}"
      show_groups
      save_min
      long_count = get_long_groups
      change_count += 1
      puts "long_count:#{long_count}"
      if long_count == 0
        taskset = TaskSet.new
        taskset.show_taskset
        taskset.show_blocktime
      end
    end
    #taskset = TaskSet.new($task_list)
    #taskset.show_taskset
    #show_groups
    #puts wcrt_max_system
    i += 1
    istr = ("%010b" % [i])[10-group_count, group_count]
    #p "#{i}:#{istr}"
    change_groups(istr)
  }
  return long_count
end

#
# main関数
#
tasks = 12
requires = 8
groups = 4
extime = 100
resouce_count_max = 4
start_task_num = 8
end_task_num = 16
task_step_num = 4
loop_count = 100


@manager = AllManager.new


pbar = ProgressBar.new("WCRTの計測", loop_count)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

info = { 
  :mode => "121003", 
  :extime => extime, 
  :proc_num => 4,
  :require_count => 2,
  :assign_mode => 1,
  :require_time => 10
}
loop_count.times{
  @manager.create_tasks(tasks, requires, groups, info)
  #@manager.load_tasks("120502_8task_4CPU")
  #
  # クリティカルセクションの変更
  #
  #$task_list.each{|t|
  #  t.req_list[0].time = t.extime * rcsl
  #}
  pbar.inc  
  
  compute_wcrt

  @manager.all_data_clear
  
}



pbar.finish