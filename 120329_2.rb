#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120329ミーティング用 2
# あるタスクセットのリソースグループを全パターン計算し，システム全体で最速に終わるタスクの最小最悪応答時間の計測
# 
#
#
require "wcbt"
require "task"
require "task-CUI"
require "manager"
require "progressbar"

def save_min
  @manager.save_tasks("120329_2_min") 
end

#
# 最悪応答時間を計算
#
def get_wcrt(task, b=nil)
  time = 0
  if b == nil
    block = BB(task)
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
    @manager.using_group_array[i].kind = c.chr=="0" ? "short" : "long"
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

include WCBT
$DEBUGFlgFlg = false


#############################
#
#############################

@manager = AllManager.new
@manager.load_tasks("120329_2")

$task_list = @manager.tm.get_task_array
taskset = TaskSet.new(@manager.tm.get_task_array)
new_group_array = @manager.using_group_array

puts "通常"

show_blocktime

taskset.show_taskset

#
# システムで使用するリソースグループを取得
#
pp new_group_array

#
# グループ数
#
group_count = new_group_array.size

#
# グループのパターン数
#
group_times = 2**group_count
p "#{group_times}times"

#
# グループパターン数を２進数で記録
#
group_binary = group_times.to_s(2)

#
# リソースを全てshortにする
#
new_group_array.each{|g|
  g.kind = "short"
}

#
# システム全体の最悪応答時間
#
min_all_wcrt = 10000000 # 適当な最大値

#
# システム全体の最悪応答時間が最も良くなる場合を探す
#
i = 0
pbar = ProgressBar.new("WCRTの計測", group_times*$task_list.size)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

group_times.times{
  wcrt_max_system = -1 # 適当な最小値
  $task_list.each{|task|
    bb = BB(task)
    ab = AB(task)
    sb = SB(task)
    lb = LB(task)
    db = DB(task)
    
    b = bb + ab + sb + lb + db
    wcrt = get_wcrt(task, b)
    if wcrt_max_system < wcrt
      wcrt_max_system = wcrt
    end
    pbar.inc
  }
  if wcrt_max_system < min_all_wcrt
    min_all_wcrt = wcrt_max_system
    puts "最悪応答時間:#{min_all_wcrt}"
    show_groups
    save_min
  end
  i += 1
  istr = ("%010b" % [i])[10-group_count, group_count]
  #p "#{i}:#{istr}"
  change_groups(istr)
}
pbar.finish
