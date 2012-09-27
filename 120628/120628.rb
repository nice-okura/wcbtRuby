#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120628ミーティング用
#  120628と同様の動きをするけれど，
#  longリソースを要求するタスクの優先度をみる
#  120628の実験から，Group1(CSが長いリソース)がlongリソースとなるとき，
#  そのタスクはプロセッサの最高優先度であるきがするので確かめる．
#
#$:.unshift(File.dirname(__FILE__))
require "./task-CUI"
require "./manager"
require "./util"

require "progressbar"
include UTIL
FILENAME = "120628"

include WCBT
$DEBUG = false

#
# main関数
#
tasks = [8]
groups = [4]
rcsls = [0.9]
extime = 80
loop_count = 100

@manager = AllManager.new

pbar = ProgressBar.new("WCRTの計測", loop_count*tasks.size*groups.size*rcsls.size)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

tasks.each do |tsk|
  rcsls.each do |rcsl|
    info = {:mode => "120620", :extime => extime, :rcsl_l => rcsl, :rcsl_s => 0.01, :assign_mode => ID_ORDER, :proc_num => 2}
    fp = File.open("./120927/120927_log_#{tsk}tasks_#{rcsl}.txt", "w")
    
    requires = tsk
    groups.each do |grp|
      group1OnlyLongCount = 0
      group1Highest_Only = 0
      group1AlsoLongCount = 0
      group1Highest_Also = 0
      otherLongCount = 0
      group1Highest_Other = 0
      group1Highest_None = 0
      
      loop_count.times do |i|
        @manager.all_data_clear
        @manager.create_tasks(tsk, requires, grp, info)
        
        g_hash = @manager.compute_wcrt(i)
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
      end
      #fp.puts "#■#{PROC_NUM}CPU #{tsk}tasks #{grp}groups rcsl long:#{info[:rcsl_l]} short:#{info[:rcsl_s]}"
      fp.puts "#{grp} #{group1OnlyLongCount} #{group1AlsoLongCount} #{otherLongCount} #{loop_count - group1OnlyLongCount - group1AlsoLongCount - otherLongCount}"
      puts "■#{PROC_NUM}CPU #{tsk}tasks #{grp}groups rcsl long:#{info[:rcsl_l]} short:#{info[:rcsl_s]}"
      puts "Group1のみがlong：#{group1OnlyLongCount}個(内，全て最高優先度なのは#{group1Highest_Only}個)"
      puts "Group1とその他の何かがlong：#{group1AlsoLongCount}(内，全て最高優先度なのは#{group1Highest_Also}個)"
      puts "Group1以外がlong：#{otherLongCount}個(内，全て最高優先度なのは#{group1Highest_Other}個)"
      puts "longがないのは#{loop_count - group1OnlyLongCount - group1AlsoLongCount - otherLongCount}(内，全て最高優先度なのは#{group1Highest_None}個)"
    end
  end
end
pbar.finish
