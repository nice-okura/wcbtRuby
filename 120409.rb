#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120409ミーティング用
# spinningをsuspendingの比較実験
# Real-time synchronization on multiprocessors: To block or not to block, to suspend or spin?
# の4.3 Spinning vs. Suspending
# Spin-based utilization loss
# にあったように，
# ・32タスクからなる6タスクセット
# ・各タスクは[40ms, 1000ms]の周期
# ・使用率は0.125の4分の1くらい
# ・コア数は4
# ・longリソースのみ，1, 2, 4種類のshortリソースのみ，の4種類の場合で実験
# ・n種類のリソースがある場合は，その32/nグループにタスクを分けて，それぞれが別のリソースと競合するようにする．
# ・比較は，バックグラウンドのジョブがどんだけ実行できるか．

require "task"
require "task-CUI"
require "manager"
require "rubygems"
require "progressbar"

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
$DEBUG = false


#############################
#
#############################

@manager = AllManager.new
#@manager.load_tasks("#{IN_FILENAME}_task.json", "#{IN_FILENAME}_require.json", "#{IN_FILENAME}_group.json")
@manager.create_tasks(32, 1, 1)
$taskList = @manager.tm.get_task_array
taskset = TaskSet.new(@manager.tm.get_task_array)

#
# システムで使用するリソースグループを取得
#
new_group_array = @manager.using_group_array

puts "通常"

show_blocktime

taskset.show_taskset

pp new_group_array

#
# リソースを全てshortにする
#
new_group_array.each{|g|
  g.kind = "short"
}
#save_short
