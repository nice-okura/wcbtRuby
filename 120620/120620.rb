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

include WCBT
$DEBUG = false

#
# main関数
#
tasks = [12]
groups = [2,3,4,5]
rcsl = 0.1
extime = 80
loop_count = 1000


@manager = AllManager.new


pbar = ProgressBar.new("WCRTの計測", loop_count*tasks.size*groups.size)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

info = {:mode => "120620", :extime => extime, :rcsl_l => rcsl, :rcsl_s => 0.01, :assign_mode => ID_ORDER}
fp = File.open("log_12tasks_long_rcsl#{rcsl}.txt", "w")
tasks.each{ |tsk|
  requires = tsk
  groups.each{ |grp|
    group1OnlyLongCount = 0
    group1AlsoLongCount = 0
    otherLongCount = 0
    
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
      elsif group1Flg == true && shortFlg == true
        # Group1もそれ以外の何かがlong
        group1AlsoLongCount += 1
      elsif group1Flg == false && shortFlg == true
        # Group1以外がlong
        otherLongCount += 1 
      end
    }
    #fp.puts "#■#{PROC_NUM}CPU #{tsk}tasks #{grp}groups rcsl long:#{info[:rcsl_l]} short:#{info[:rcsl_s]}"
    fp.puts "#{grp} #{group1OnlyLongCount} #{group1AlsoLongCount} #{otherLongCount} #{loop_count - group1OnlyLongCount - group1AlsoLongCount - otherLongCount}"
    puts "■#{PROC_NUM}CPU #{tsk}tasks #{grp}groups rcsl long:#{info[:rcsl_l]} short:#{info[:rcsl_s]}"
    puts "Group1のみがlong：#{group1OnlyLongCount}個"
    puts "Group1とその他の何かがlong：#{group1AlsoLongCount}"
    puts "Group1以外がlong：#{otherLongCount}個"
    puts "longがないのは#{loop_count - group1OnlyLongCount - group1AlsoLongCount - otherLongCount}"
  }
}
save_min
pbar.finish
