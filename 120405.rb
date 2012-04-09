#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120405ミーティング用
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
uabj_array = [[]]

resource_max = 16
resource_kind = "short"
loop_count = 12
task_count = 64

granularity = 10  # 粒度
start_rcsl = 0.0
end_rcsl = 1.0

x_count = ((end_rcsl - start_rcsl) / (1.0/granularity)).to_i
p x_count
0.upto(resource_max-1){|i|
  uabj_array[i] = []
  0.upto(x_count-1){|j|
    uabj_array[i][j] = 0.0
  }
}


pbar = ProgressBar.new("", loop_count*granularity*resource_max)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

for resource_count in 1..resource_max
  granularity.times{uabj_array[resource_count-1] << 0}
  1.upto(loop_count){|lc|
    rcsl = start_rcsl
    i = 0
    #p rcsl
    @manager.all_data_clear
    info = ["120405", rcsl]
    #p resource_count
    @manager.create_tasks(task_count, resource_count*2, resource_count, info)
    $taskList = @manager.tm.get_task_array
    taskset = TaskSet.new(@manager.tm.get_task_array)
    while rcsl < 1.0
      #
      # クリティカルセクションの変更
      #
      $taskList.each{|t|
        t.req_list.each{|r|
          r.time = t.extime * rcsl
        }
      }
      
      #
      # システムで使用するリソースグループを取得
      #
      new_group_array = @manager.using_group_array
      
      #pp new_group_array
      
      #
      # リソースを全てshortにする
      #
      new_group_array.each{|g|
        g.kind = resource_kind
      }
      #save_short
      
      begin
        uabj_array[resource_count-1][i] += show_blocktime_120409
      rescue
        puts "\n\ni:#{i}"
        exit
      end
=begin
      if lc == 1 && rcsl == 0.1
        puts "resource_count : #{resource_count}".red
        taskset.show_taskset
      end
=end
      rcsl += 1.0/granularity
      i += 1
      pbar.inc
    end
  }  
  #pp uabj_array
  uabj_array[resource_count-1].map!{|x| x/loop_count} # 平均
  #pp uabj_array
end

File.open("120405_plot.dat", "w"){|fp|
  rcsl = start_rcsl
  0.upto(granularity - 1){|j|
    str = ""
    0.upto(resource_max - 1){|i|
      begin
        str +=  "#{uabj_array[i][j]} "
      rescue => e
        puts "i:j = #{i}#{j}"
        puts "#{uabj_array[i]}"
        $stderr.puts e
        exit
      end
    }
    fp.puts "#{rcsl} #{str}"
    rcsl += 1.0/granularity
  }
}
pbar.finish