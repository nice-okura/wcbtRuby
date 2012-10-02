#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120926ミーティング用
#  120628と同様の動きで，スケジューラビリティの観点から
#  longリソース要求のよい配置方法を考える
#
#$:.unshift(File.dirname(__FILE__))
require "./task-CUI"
require "./manager"
require "./util"

require "progressbar"

FILENAME = "120927_2"

include WCBT
$DEBUG = false

# main関数
tasks = [8]
groups = [4]
rcsls = [20..30]
rcsl_s = 1.3..6.5
#extime = 80
extime_range = 50..500
loop_count = 100
proc_num = 2


@manager = AllManager.new

pbar = ProgressBar.new("WCRTの計測", loop_count*tasks.size*groups.size*rcsls.size)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

tasks.each do |tsk|
  rcsls.each do |rcsl|
    p rcsl
    p rcsl_s
    info = {:mode => "120927_2", :extime_range => extime_range, :long_range => rcsl, :short_range => rcsl_s, :assign_mode => ID_ORDER, :proc_num => proc_num}
    fp = File.open("./120927_"/120927_2_log_#{tsk}tasks_#{rcsl}.txt", "w")
    
    requires = tsk
    groups.each do |grp|
      loop_count.times do |i|
        @manager.all_data_clear
        @manager.create_tasks(tsk, requires, grp, info)
        
        g_hash = @manager.compute_wcrt(i)
        pbar.inc
      end
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
