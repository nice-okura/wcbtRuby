#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120620ミーティング用
#
$:.unshift(File.dirname(__FILE__))
require "../task-CUI"
require "../manager"
require "progressbar"

FILENAME = "120620"

def save_min
  @manager.save_tasks(JSON_FOLDER + "/" + FILENAME)
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
  @manager.gm.get_group_array.each{|g|
    g.kind = SHORT
  }
  taskset = TaskSet.new(@manager.tm.get_task_array)
  
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
      wcrt = t.wcrt
      wcrt_max_system = wcrt if wcrt_max_system < wcrt
      #pbar.inc
    }
    
    
    if wcrt_max_system < min_all_wcrt
      min_all_wcrt = wcrt_max_system
      long_count = get_long_groups
      change_count += 1

      #$COLOR_CHAR = false
      if long_count > 0
        puts "long_count:#{long_count}"
        puts "最悪応答時間:#{min_all_wcrt}"
        taskset = TaskSet.new($task_list)
        taskset.show_taskset
        taskset.show_blocktime
        show_groups
        save_min
      end
      #$COLOR_CHAR = true
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
requires = 20
groups = 3
rcsl = 0.1
extime = 80
resouce_count_max = 1
start_task_num = 8
end_task_num = 16
task_step_num = 4
loop_count = 1


@manager = AllManager.new


pbar = ProgressBar.new("WCRTの計測", loop_count)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

info = {:mode => "120620", :extime => extime, :rcsl => rcsl}
loop_count.times{
  @manager.all_data_clear
  @manager.create_tasks(tasks, requires, groups, info)
  #@manager.load_tasks("120613_8task_4CPU")
  #
  # クリティカルセクションの変更
  #
  #$task_list.each{|t|
  #  t.req_list[0].time = t.extime * rcsl
  #}
  pbar.inc  
  
  compute_wcrt
  #end

  
}
save_min
pbar.finish
