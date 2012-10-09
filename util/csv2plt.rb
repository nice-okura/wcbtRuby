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

DIRNAME = ARGV[0] # 入力データのあるフォルダ 末尾の"/"あり
OUTPUT_FILE = ARGV[1]
TASK_COUNT = ARGV[2]

$task_stats_data = { }

def get_task_rt(id)
  rt_ave = 0.0
  rt_wc = 0.0
  rts = $task_stats_data[id]
  task_count = rts.size
  rts.each do |rt|
    rt_ave += rt[0]
    rt_wc += rt[1]
  end

  rt_ave /= task_count
  rt_wc /= task_count

  return [rt_ave, rt_wc]
end

Dir::glob(DIRNAME+"*.csv").each do |filename|
  # 読み取り
  CSV.open(filename, "r") do |f|
    header = f.take(1)[0]
    f.each do |row| 
      id = row[0].to_i    # タスクID
      $task_stats_data[id] = [] if $task_stats_data[id] == nil
      rt_ave = row[2].to_i # 平均応答時間
      rt_wc = row[3].to_i  # 最大実応答時間"
      $task_stats_data[id] << [rt_ave, rt_wc]
    end
  end
end
  
#p $task_stats_data

# TASKID:1 の平均応答時間と最大実応答時間



# 出力
File.open(OUTPUT_FILE, "w") do |fp|
  id = 1
  break if $task_stats_data[id] == nil
  #STDERR.puts $task_stats_data[id]
  fp.puts "#{TASK_COUNT} #{get_task_rt(id)[0]} #{get_task_rt(id)[1]}" 
end
