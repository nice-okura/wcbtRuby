#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120502ミーティング用
# あるタスクセットのリソースグループを全パターン計算し，最速，最悪のパターンを表示
# 
#
#
$:.unshift(File.dirname(__FILE__))
require "../task-CUI"
require "../manager"

TASK_NUMBER = 10

def save_min
  @manager.save_tasks("120502_min_task.json", "120502_min_require.json", "120502_min_group.json") 
end

def save_max
  @manager.save_tasks("120502_max_task.json", "120502_max_require.json", "120502_max_group.json") 
end



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

  #
  # グループ数
  #
  group_count = @manager.gm.get_group_array.size

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
  @manager.gm.get_group_array.each{|g|
    g.kind = "short"
  }

  #
  # タスクTASK_NUMBER の最悪応答時間
  #
  min_preempt_time = 10000000 # 適当な最大値
  max_preempt_time = -1       # 適当な最小値

  #
  # タスク TASK_NUMBER の最悪応答時間が最も良くなる場合を探す
  #
  i = 0
  group_times.times{
    $taskList.each{|task|
      pre = task.extime + get_extime_high_priority(task) + task.b
      #puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{pri} = #{task.extime + b + pri}"
      if pre < min_preempt_time
        min_preempt_time = pre
        puts "タスク#{TASK_NUMBER} MIN 最悪応答時間:#{pre}"
        show_groups
        save_min
        break
      end
=begin
      if pre > max_preempt_time
        max_preempt_time = pre
        puts "タスク#{TASK_NUMBER} MAX 最悪応答時間:#{pre}"
        show_groups
        save_max
        break
      end
=end
      #print "-> #{pre}"

    }
    i += 1
    istr = ("%010b" % [i])[10-group_count, group_count]
    #p "#{i}:#{istr}"
    change_groups(istr)
  }
end


extime = 80
rcsl = 0.2
tasks = 16
requires = 10
groups = 8
@manager = AllManager.new

info = ["120411", extime ,rcsl]
@manager.create_tasks(tasks, requires, groups, info)
compute_wcrt
@manager.all_data_clear
