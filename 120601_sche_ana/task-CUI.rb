#! /usr/bin/ruby
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))
require "pp"
require "config"
#require "wcbt"
require "rubygems" unless RUBY_VERSION == "1.9.3"
require "term/ansicolor"

class String
  include Term::ANSIColor
end

if $COLOR_CHAR == true
  OFFSET_CHAR = " "       # offset : " "
  LONG_CHAR = "L".red     # long要求 : "L"
  SHORT_CHAR = "S".blue   # short要求 : "S"
  CALC_CHAR = "-"         # ただの計算 : "-"
else
  OFFSET_CHAR = " "       # offset : " "
  LONG_CHAR = "L"         # long要求 : "L"
  SHORT_CHAR = "S"        # short要求 : "S"
  CALC_CHAR = "-"         # ただの計算 : "-"
end

class TaskSet 
  attr_accessor :task_list

  def initialize(task_list)
    @task_list = task_list
    @taskset_proc = []
    
    #
    # プロセッサ順にソート
    #
    @task_list.sort!{|a, b|
      a.proc <=> b.proc
    }
    
    #
    # タスクを分類
    #
    distribute_task_proc
    
    #
    # 優先度順にソート
    #
    @taskset_proc.each{|tasks|
      tasks.sort!{|a, b|
        a.priority <=> b.priority
      }
    }
  end
  
  #
  # システム全体のプロセッサのリスト
  #
  def proc_list
    proc = []
    @task_list.each{|task|
      proc << task.proc
    }
    proc.uniq!
    return proc.sort!
  end
  
  #
  # @taskset_procにプロセッサでタスクを分類
  #
  def distribute_task_proc
    proc_num = 1
    task_array = []
    #pp @taskset_proc
    @task_list.each{|task|
      if task.proc != proc_num then
        proc_num = task.proc
        @taskset_proc.push(task_array)
        task_array = []
      end
      task_array << task
    }
    @taskset_proc.push(task_array)
    #p @task_list.size
  end
  
  def show_taskset
    proc_num = 1
    @taskset_proc.each{|tasks|
      puts "[プロセッサ#{proc_num}]"
      tasks.each{|task|
        tc = TaskCUI.new(task)
        tc.show_task_char
      }
      proc_num += 1
    }
  end
  
  #
  # 以下のフォーマットでブロック時間等表示
  #
  def show_blocktime
    @taskset_proc.each{|tasks|
      tasks.each{|t|
        print "タスク#{t.task_id}"      
        print ["\tBW:", sprintf("%.1f", t.bw)].join
        print ["\tNPB:", sprintf("%.1f", t.npb)].join
        print ["\tDB:", sprintf("%.1f", t.db)].join
        print ["\tB:", sprintf("%.1f", t.b)].join
        print "\n"
        #        pri = get_extime_high_priority(t) 
=begin        
        if t.period < t.wcrt
          puts "\t\t周期#{t.period}<最悪応答時間#{sprintf("%.1f", t.wcrt)}".red
        else
          puts "\t\t周期#{t.period}>最悪応答時間#{sprintf("%.1f", t.wcrt)}"
        end
=end
      }
    }
  end
end

#
# タスクをCUI表示させるためのクラス
#
class TaskCUI
  def initialize(task)
    @task = task
  end
  
  #
  # タスク表示
  #
  def show_task_char
    return print get_task_name + get_task_char + "\n"
  end
  
  #
  # タスク名表示
  #
  def get_task_name
    return "タスク#{@task.task_id}(#{"%1.3f"%(@task.extime.to_f/@task.period.to_f)}):"
    #return "タスク" + @task.task_id.to_s + "(" + "%1.3f"%(@task.extime.to_f/@task.period.to_f) + ")" + ":"
  end
  
  
  #
  # タスクCUI作成
  #
  def get_task_char
    str = ""
    curTime = 0                           # 現在時刻ポインタ設定
    
    str += get_task_offset_char           # オフセット出力
    
    str += "|"                            # タスク開始
    curTime += @task.offset               # 現在時刻を進める 
    
    #
    # リソース要求
    #
    @task.req_list.each{|req|
      calc_time = 0                       # リソース要求以外の時間
      calc_time = req.begintime - curTime # 現在時刻から次のリソース要求の時間までが計算時間
      
      calc_time.to_i.times{               # 計算時間の分だけCALC_CHARを表示
        str += CALC_CHAR
      }

      curTime += calc_time                # 現在時刻を進める
      str += "["                          # リソース要求区切り
      str += get_require_time_char(req)   # リソース要求の分だけLONG or SHORTCHAR を表示
      str += "]"                          # リソース要求区切り
      curTime += req.time
    }

                                          # 最後に計算時間が余っていれば表示
    (@task.extime + @task.offset - curTime).to_i.times{
      str += CALC_CHAR
    }
    str += "|"  # タスク終了
    
    return str
  end
  
  #
  # オフセット表示
  #
  def get_task_offset_char
    str = ""
    @task.offset.times{
      str += OFFSET_CHAR
    }
    return str
  end
  
  #
  # リソース要求CUI表示
  #
  def get_require_time_char(req)
    str = ""
    curTime = req.begintime
    str += "G" + req.res.group.to_s + ":"
    
    reqtime = req.time
    req.reqs.each{|subreq|
      rt = subreq.begintime - curTime
      rt.times{
        req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR 
      }
      reqtime -= rt
      str += "("
      str += get_require_time_char(subreq)
      str += ")"
      reqtime -= subreq.time
    }
    reqtime.to_i.times{
      req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR 
    }
=begin
    subreqArray = req.reqs
    
    reqtime = req.time
    if subreqArray.size > 0 then
      # ネストしている場合
      i = 0
      while i < subreqArray.size 
        # i番目のネスト
        if curTime == subreqArray[i].begintime then
          p i
          str += "("
          str += get_require_time_char(subreqArray[i])
          str += ")"
          curTime += subreqArray[i].time
          reqtime -= subreqArray[i].time
          i += 1
        else
          p "2"
          req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR 
          curTime += 1
          reqtime -= 1
        end
      end
      reqtime.times{
        req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR
      }
    else
      # ネストしていない場合
      reqtime.times{
        req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR
      }
    end
=end
    return str
  end
end