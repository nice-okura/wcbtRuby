#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120405ミーティング用_3
# リソース要求時間でlongとshortを分ける
# 分ける境界(RCLS)はborderとして，0.1〜1.0まで変化させて計算

require "task"
require "task-CUI"
require "manager"
require "rubygems"
require "progressbar"
require "pp"

#IN_FILENAME = ARGV[0]
OUT_FILENAME = ARGV[0]

def save_min
  @manager.save_tasks("#{OUT_FILENAME}_task.json", "#{OUT_FILENAME}_require.json", "#{OUT_FILENAME}_group.json") 
end

def save_short
  @manager.save_tasks("120329_2_short_task.json", "120329_2_short_require.json", "120329_2_short_group.json") 
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

include WCBT
$DEBUG = false


#############################
#
#############################

task_count = 12
resource_max = 4

rcls = 0.3
rcls_border = 0.1
info = ["120405_3", rcls]
@manager = AllManager.new
@manager.create_tasks(task_count, 10, resource_max, info)
$taskList = @manager.tm.get_task_array
taskset = TaskSet.new(@manager.tm.get_task_array)

0.1.step(1.0, 0.1){|border|
  puts border.to_s.red
  $taskList.each{|t|
    set_blocktime(t)
    t.req_list.each{|r|
      if r.time < t.extime * border
        r.res.kind = SHORT
        else
        r.res.kind = LONG
      end
    }
  }
  taskset.show_taskset
  show_blocktime
}
