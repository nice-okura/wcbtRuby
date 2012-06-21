#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 120620ミーティング用
# 
$:.unshift(File.dirname(__FILE__))
require "../task-CUI"
require "../manager"
require "progressbar"

FILENAME = "120620_2"

# 配列クラスに組合せ
class Array
  def permutations(k=self.size)
    return [[]] if k < 1
    perm = []
    self.each do |e|
      x = self.dup
      x.delete_at(x.index(e))
      x.permutations(k-1).each do |p|
        perm << ([e] + p)
      end
    end
    perm
  end
end



def save_min
  @manager.save_tasks(JSON_FOLDER + "/" + FILENAME)
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
  ret_hash
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
def compute_wcrt
  ret_hash = { }
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
  taskset = TaskSet.new(@manager.tm.get_task_array)
  
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
        #save_min
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

# 要求IDの配列[1,2,3,4]を順番にタスクに割当てる関数
def assign_require(req_id_list)
  $task_list.sort!{ |a,b| a.task_id <=> b.task_id }
  i = 0
  $task_list.each{ |t|
    t.req_list = [RequireManager.get_require_from_id(req_id_list[i])]
    i += 1
  }
end
#
# main関数
#
tasks = 8
requires = tasks
groups = 4
rcsl = 0.1
extime = 80
loop_count = 1000



info = {:mode => "120620_2", :extime => extime, :rcsl_l => rcsl, :rcsl_s => rcsl/10, :assign_mode => ID_ORDER}
@manager = AllManager.new
@manager.all_data_clear

# グループ1がlongでそれ以外がshortであるタスクセットを作る
# リソース要求はタスク数分しかつくらない
@manager.create_tasks(tasks, requires, groups, info)

taskset = TaskSet.new
ril = @manager.rm.get_require_array.collect{ |r| r.req_id}.permutations

pbar = ProgressBar.new("WCRTの計測", ril.size)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"


best_wcrt = 100000000
ril.each{ |rr|
  assign_require(rr)
  init_computing($task_list)
  set_blocktime
#  taskset.show_taskset
  pbar.inc
  w_t = @manager.pm.get_worst_wcrt
  best_wcrt = w_t.wcrt if best_wcrt > w_t.wcrt
  save_min
}
pbar.finish
