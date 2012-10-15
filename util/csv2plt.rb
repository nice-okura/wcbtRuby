#!/usr/bin/ruby
#
#author: fujitani
#date: 2012/10/09
#
# csv2plt.rb
#
# schesim-0.7.2/utils/stats.rb で出力した統計データ(CSV)をgnuplot用のpltに変換する
# タスクID,起動回数,平均応答時間,最大応答時間,最小応答時間,総実行時間,平均実行時間,最大実行時間,最小実行時間
# 1,12,260,270,260,3130,260,270,260

require "csv"
require "pp"
DIRNAME = ARGV[0] # 入力データのあるフォルダ 末尾の"/"あり
OUTPUT_FILE = ARGV[1]
MAX_TASK = ARGV[2].to_i
$task_stats_data = { }


task_count = []
4.step(MAX_TASK, 2){ |i| task_count << i }

task_count.each do |tsk|
  $task_stats_data[tsk] = { }

  rt_ave = Array.new(tsk, 0.0) # 平均応答時間
  rt_wc = Array.new(tsk, 0.0)  # 最大実応答時間
  sets = 0     # タスクセット数
  
  Dir::glob(DIRNAME+"data_#{tsk}task/*.csv").each do |filename|
    # 読み取り
    sets += 1
    CSV.open(filename, "r") do |f|
      header = f.take(1)[0]
      f.each do |row| 
        id = row[0].to_i    # タスクID
        $task_stats_data[tsk][id] = [] if $task_stats_data[tsk][id] == nil
        rt_ave[id-1] += row[2].to_f # 平均応答時間
        rt_wc[id-1] += row[3].to_f  # 最大実応答時間"
      end
      tsk.times do |id|
        $task_stats_data[tsk][id+1] = [rt_ave[id]/sets, rt_wc[id]/sets]
      end
    end
  end

  Dir::glob(DIRNAME+"data_#{tsk}task/task_wcrt_#{tsk}task.txt").each do |filename|
    sets = 0  # タスクセット数
    ret = Array.new(tsk, 0.0)

    File.open(filename, "r") do |fp|
      fp.gets # 初めの1行は捨てる

      while l = fp.gets
        sets += 1
        l.split(",").each_with_index { |v, i| ret[i] += v.to_f }
      end

      ret.each_with_index do |v, id|
        $task_stats_data[tsk][id+1] << v/sets
      end
    end
  end
end  
pp $task_stats_data

# TASKID:1 の平均応答時間と最大実応答時間

# 出力
File.open(OUTPUT_FILE, "w") do |fp|
  id = 1
  
  #STDERR.puts $task_stats_data[id]

  task_count.each do |tsk|
    break if $task_stats_data[tsk][id] == nil

    fp.puts "#{tsk} #{$task_stats_data[tsk][id][0]} #{$task_stats_data[tsk][id][1]} #{$task_stats_data[tsk][id][2]}" 
  end
end
