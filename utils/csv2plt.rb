#author: fujitani
#date: 2012/10/09
#
# csv2plt.rb
#
# schesim-0.7.2/utils/stats.rb で出力した統計データ(CSV)をgnuplot用のpltに変換する
# タスクID,起動回数,平均応答時間,最大応答時間,最小応答時間,総実行時間,平均実行時間,最大実行時間,最小実行時間
# 1,12,260,270,260,3130,260,270,260

require "rubygems"
require "fastercsv"
require "pp"

DIRNAME = ARGV[0] # 入力データのあるフォルダ 末尾の"/"あり
OUTPUT_FILE = ARGV[1]
MAX_TASK = ARGV[2].to_i

# CSVヘッダ情報
TASK_ID = 'タスクID'
ACT = "起動回数"
AVE_RT = "平均応答時間"
MAX_RT = "最大応答時間"


$task_stats_data = { }
# task_stats_data[tsk][id][0]: 平均応答時間の平均
# task_stats_data[tsk][id][1]: 最大実応答時間の平均
# task_stats_data[tsk][id][2]: 最大応答時間の平均
# task_stats_data[tsk][id][3]: 最大実応答時間と最大応答時間の差

task_count = []
rt_diff = Hash.new{ |hash, id| hash[id] = Hash.new { |hash, id| hash[id] = [] }} # 最大実応答時間と最大応答時間の差

4.step(MAX_TASK, 2){ |i| task_count << i }


task_count.each do |tsk|
  $task_stats_data[tsk] = { }
  rt_ave = Array.new(tsk, 0.0) # 平均応答時間
  rt_wc = Array.new(tsk, 0.0)  # 最大実応答時間
  
  tasksets = 0     # タスクセット数
  
  Dir::glob(DIRNAME+"data_#{tsk}task/*.csv").each do |filename|
    # 読み取り
    tasksets += 1
    FasterCSV.open(filename, "r", :headers=>true) do |f|
      i = 0
      f.each do |row|
        i += 1
        id = row[TASK_ID].to_i    # タスクID
        
        $task_stats_data[tsk][id] = [] if $task_stats_data[tsk][id] == nil
        rt_ave[id-1] += row[AVE_RT].to_f # 平均応答時間
        rt_wc[id-1] += row[MAX_RT].to_f  # 最大実応答時間"
        # Ex. rt_diff[Taskid] = [タスクセット1の最大実応答時間, ...]
        # rt_diff[1] = [100.0, 200.0, 341.0, 134.0]
        # rt_diff[2] = [134.0, 462.0, 456.0, 235.0]...
        rt_diff[id] << row[MAX_RT].to_f # タスクセット毎に最大実応答時間を格納
        pp rt_diff[tsk]
      end

      # 何かが原因でstats.rbで正しい統計情報が出力されず，
      # #{tsk}個のタスクの統計情報が得られなかった場合
      # 正しいタスクセットではないと判断して，カウントしない
      tasksets -= 1 unless i == tsk
    end
  end

  # 全ファイル走査した後，$task_stats_dataに平均を代入
  tsk.times do |id|
    $task_stats_data[tsk][id+1] = [rt_ave[id]/tasksets, rt_wc[id]/tasksets]
  end

  # 計算によって求まった最大応答時間の平均
  Dir::glob(DIRNAME+"data_#{tsk}task/task_wcrt_#{tsk}task.txt").each do |filename|
    sets = 0  # タスクセット数
    ret = Array.new(tsk, 0.0)

    File.open(filename, "r") do |fp|
      fp.gets # 初めの1行は捨てる
      puts filename
      while l = fp.gets
        sets += 1
        wcrt = l.split(',')
        wcrt.each_with_index do |v, idx|
          ret[idx] += v.to_f 
          puts "#{v.to_f} - #{rt_diff[idx+1][sets-1]}"
          rt_diff[tsk][idx+1][sets-1] = v.to_f - rt_diff[tsk][idx+1][sets-1]
        end
        #break if sets == tasksets
      end

      ret.each_with_index do |v, id|
        $task_stats_data[tsk][id+1] << v/sets
      end
    end
  end
  #
end  
#pp $task_stats_data
pp rt_diff

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

# 最大時間差 出力
File.open("diff_rt.txt", "w") do |fp|
  #fp.puts rt_diff[1]
end
