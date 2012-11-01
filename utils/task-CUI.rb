# -*- coding: utf-8 -*-
require "pp"
require "rubygems" unless RUBY_VERSION == "1.9.3"
require "term/ansicolor"

class String
  include Term::ANSIColor
end


OFFSET_CHAR = " "       # offset : " "
CALC_CHAR = "-"         # ただの計算 : "-"
INFLATE_CHAR = "*"      # inflateした時間 : "*"

if $COLOR_CHAR == true
  LONG_CHAR = "L".red     # long要求 : "L"
  SHORT_CHAR = "S".blue   # short要求 : "S"
else
  LONG_CHAR = "L"         # long要求 : "L"
  SHORT_CHAR = "S"        # short要求 : "S"
end

class TaskSet 
  attr_accessor :task_list
  
  # コンストラクタ
  # @param [Array<Task>] タスクリスト
  # @param [ProcessorManager] プロセッサマネージャー
  def initialize()
    
  end

  #
  # システム全体のプロセッサのリスト
  #
  def proc_list
    proc = []
    @task_list.each do |task|
      # タスクが未割り当ての場合
      if task.proc == UNASSIGNED
        puts "タスク#{task.task_id}が未割り当てです"
        exit
      end
      proc << task.proc
    end
    proc.uniq!
    return proc.sort!
  end
  
  #
  # @taskset_procにプロセッサでタスクを分類
  #
  def distribute_task_proc
    proc_num = 1
    task_array = []

    @task_list.each do |task|
      if task.proc != proc_num
        proc_num = task.proc
        @taskset_proc.push(task_array)
        task_array = []
      end
      task_array << task
    end
    @taskset_proc.push(task_array)
    #p @task_list.size
  end
 
  # ProcessorManagerからプロセッサ情報を得てタスクを表示させる
  # opt[:sortmode]
  #   SORT_PRIORITY: 優先度順に表示
  #   SORT_ID: ID順に表示
  #   SORT_UTIL: CPU使用率順に表示
  def show_taskset(opt={ })
    ProcessorManager.proc_list.each do |proc|
      proc.sort_tasks(opt[:sort_mode])
      puts "[プロセッサ#{proc.proc_id}]"
      proc.task_list.each do |t|
        tc = TaskCUI.new(t)
        tc.show_task_char
      end
    end
  end

  # 旧仕様のshow_taskset
  def show_taskset_old
    proc_num = 1
    @taskset_proc.each do |tasks|
      puts "[プロセッサ#{proc_num}]"
      tasks.each do |task|
        tc = TaskCUI.new(task)
        tc.show_task_char
      end
      proc_num += 1
    end
  end
  
  #
  # 以下のフォーマットでブロック時間等表示
  #
  def show_blocktime
    ProcessorManager.proc_list.each do |proc|
      proc.task_list.each do |t|
        print "タスク#{t.task_id}"      
        print ["\tBB:", sprintf("%.1f", t.bb)].join
        print ["\tAB:", sprintf("%.1f", t.ab)].join
        print ["\tSB:", sprintf("%.1f", t.sb)].join
        print ["\tLB:", sprintf("%.1f", t.lb)].join
        print ["\tDB:", sprintf("%.1f", t.db)].join
        print ["\tB:", sprintf("%.1f", t.b)].join
        print "(#{t.get_extime})"
        print "\n"
        #pri = get_extime_high_priority(t) 
        
        if t.period < t.wcrt
          puts "\t\t周期#{t.period}<最悪応答時間#{sprintf("%.1f", t.wcrt)}".red
        else
          puts "\t\t周期#{t.period}>最悪応答時間#{sprintf("%.1f", t.wcrt)}"
        end
        puts "\t\t e/p = #{(t.get_extime/t.period).round(5)} e+sb/p = #{((t.get_extime+t.sb)/t.period).round(5)}"
      end
    end
  end

  #
  # 以下のフォーマットでブロック時間等表示
  #
  def show_blocktime_edf
    ProcessorManager.proc_list.each do |proc|
      proc.task_list.each do |t|
        print "タスク#{t.task_id}"
        print ["\tBW:", sprintf("%.1f", t.bw)].join
        print ["\tNPB:", sprintf("%.1f", t.npb)].join
        print ["\tDB:", sprintf("%.1f", t.db)].join
        print ["\tB:", sprintf("%.1f", t.b)].join
        print "(#{t.get_extime})"
        print "\n"

        if t.period < t.wcrt
          puts "\t\t周期#{t.period}<最悪応答時間#{sprintf("%.1f", t.wcrt)}".red
        else
          puts "\t\t周期#{t.period}>最悪応答時間#{sprintf("%.1f", t.wcrt)}"
        end
      end
    end
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
    return print get_task_name + get_task_char + " (p:#{@task.period})\n"
  end
  
  #
  # タスク名表示
  #
  def get_task_name
    return "タスク#{@task.task_id}(#{"%1.3f"%(@task.util)}):"
    #return "タスク" + @task.task_id.to_s + "(" + "%1.3f"%(@task.get_extime.to_f/@task.period.to_f) + ")" + ":"
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
    (@task.get_extime + @task.offset - curTime).to_i.times{
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
    @task.offset.to_i.times{
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
    str += req.res.kind == LONG ? "G#{req.res.group}:".red : "G#{req.res.group}:".blue
    
    reqtime = req.time
    req.reqs.each{|subreq|
      rt = subreq.begintime - curTime
      rt.to_i.times{
        req.res.kind == LONG ? str += LONG_CHAR : str += SHORT_CHAR 
      }
      reqtime -= rt
      str += "("
      str += get_require_time_char(subreq)
      str += ")"
      reqtime -= subreq.time
    }
    
    # inflate time 表示
    if req.reqs == []
      req.inflated_spintime.to_i.times{ 
        str += INFLATE_CHAR
      }
      reqtime - req.inflated_spintime
    end    
    reqtime.to_i.times{
      req.res.kind == LONG ? str += LONG_CHAR : str += SHORT_CHAR 
    }

    return str
  end
end
