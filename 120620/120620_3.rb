#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120620ミーティング用
#  120620と同様の動きをするけれど，
#  longリソースを要求するタスクの優先度をみる
#  120620の実験から，Group1(CSが長いリソース)がlongリソースとなるとき，
#  そのタスクはプロセッサの最高優先度であるきがするので確かめる．
#
$:.unshift(File.dirname(__FILE__))
require "../task-CUI"
require "../manager"
require "progressbar"
require "util"

include UTIL
FILENAME = "120620_3"
def save_min
  @manager.save_tasks(JSON_FOLDER + "/" + FILENAME)
end

def save_taskset(filename)
  @manager.save_tasks(JSON_FOLDER + "/tasksets_for_priority/" + filename)
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
# 現在のリソースグループをハッシュにして返す
#
def get_groups
  ret_hash = { }
  @manager.using_group_array.each{ |g|
    ret_hash[g.group] = g.kind
  }
  return ret_hash
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

#
# 最悪応答時間が最も良くなる時のグループの分類を求める
# @return [Array<String>]
#
def compute_wcrt(loops)
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
  ret_hash = get_groups
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
        #puts "long_count:#{long_count}"
        #puts "最悪応答時間:#{min_all_wcrt}"
        #taskset = TaskSet.new($task_list)
        #taskset.show_taskset
        #taskset.show_blocktime
        #show_groups
        ret_hash = get_groups
        gsp = get_groups.values.collect{ |s| if s == LONG then "L" elsif s === SHORT then "S" end}.join 
        filename = "T#{$task_list.size}G#{group_count}_#{gsp}_jikken2_#{loops}"
        save_taskset(filename)
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
  return ret_hash
end


#
# main関数
#
tasks = [8]
groups = [4]
rcsls = [0.01, 0.02, 0.03, 0.04, 0.05, 0.06]
extime = 80
loop_count = 100


@manager = AllManager.new


pbar = ProgressBar.new("WCRTの計測", loop_count*tasks.size*groups.size*rcsls.size)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

tasks.each{ |tsk|
  rcsls.each{ |rcsl|
    info = {:mode => "120620", :extime => extime, :rcsl_l => rcsl, :rcsl_s => 0.01, :assign_mode => ID_ORDER}
    fp = File.open("log_#{tsk}tasks_#{rcsl}.txt", "w")
    
    requires = tsk
    groups.each{ |grp|
      group1OnlyLongCount = 0
      group1Highest_Only = 0
      group1AlsoLongCount = 0
      group1Highest_Also = 0
      otherLongCount = 0
      group1Highest_Other = 0
      group1Highest_None = 0
      
      loop_count.times{|i|
        @manager.all_data_clear
        @manager.create_tasks(tsk, requires, grp, info)
        
        g_hash = compute_wcrt(i)
        pbar.inc
        group1Flg = g_hash[1] == LONG  # グループ1がlongかどうか
        g_hash.delete(1)               #
        shortFlg = g_hash.value?(LONG) # グループ1以外にlongリソースがあるかどうか．あればtrue

        if group1Flg == true && shortFlg == false
          # Group1のみがLongなもの
          group1OnlyLongCount += 1
          if check_highest_priority(@manager.tm.get_task_array) == true
            # group1リソースを要求するタスクが全て最高優先度の場合
            group1Highest_Only += 1
          end
        elsif group1Flg == true && shortFlg == true
          # Group1もそれ以外の何かがlong
          group1AlsoLongCount += 1
          group1Highest_Also += 1 if check_highest_priority(@manager.tm.get_task_array) == true
        elsif group1Flg == false && shortFlg == true
          # Group1以外がlong
          otherLongCount += 1
          group1Highest_Other += 1 if check_highest_priority(@manager.tm.get_task_array) == true
        else
          group1Highest_None += 1 if check_highest_priority(@manager.tm.get_task_array) == true
        end
      }
      #fp.puts "#■#{PROC_NUM}CPU #{tsk}tasks #{grp}groups rcsl long:#{info[:rcsl_l]} short:#{info[:rcsl_s]}"
      fp.puts "#{grp} #{group1OnlyLongCount} #{group1AlsoLongCount} #{otherLongCount} #{loop_count - group1OnlyLongCount - group1AlsoLongCount - otherLongCount}"
      puts "■#{PROC_NUM}CPU #{tsk}tasks #{grp}groups rcsl long:#{info[:rcsl_l]} short:#{info[:rcsl_s]}"
      puts "Group1のみがlong：#{group1OnlyLongCount}個(内，全て最高優先度なのは#{group1Highest_Only}個)"
      puts "Group1とその他の何かがlong：#{group1AlsoLongCount}(内，全て最高優先度なのは#{group1Highest_Also}個)"
      puts "Group1以外がlong：#{otherLongCount}個(内，全て最高優先度なのは#{group1Highest_Other}個)"
      puts "longがないのは#{loop_count - group1OnlyLongCount - group1AlsoLongCount - otherLongCount}(内，全て最高優先度なのは#{group1Highest_None}個)"
    }
  }
}
pbar.finish