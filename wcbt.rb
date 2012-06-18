#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 最大ブロック時間計算用モジュール
#
#Author:: Takahiro FUJITANI (ERTL, Nagoya Univ.)
#Version:: 0.5.0
#License:: 
#
#
# 最大ブロック時間計算用モジュール
#$:.unshift(File.dirname(__FILE__))
require "rubygems"
require "term/ansicolor"
require "config"
#require "ruby-prof"

$calc_task = [] # WCBTモジュールで使用するタスク

class String
  include Term::ANSIColor
end

#
# WCLRなど
#
$WCLR = Hash.new
$WCSR = Hash.new
$LR = Hash.new 
$SR = Hash.new
$NARR = Hash.new
$wclx = Hash.new
$wcsx = Hash.new
$bbt = Hash.new
$abr = Hash.new
$proc_list = Hash.new
$proc_task_list = Hash.new

module WCBT
  def p_debug(str)
    puts("\t" + str) if $DEBUGFlg == true
  end
  
  #
  # 予め計算しておく
  #
  def init_computing(tasks)
    $calc_task = tasks

    $WCLR.clear
    $WCSR.clear
    $LR.clear
    $SR.clear
    $NARR.clear
    $wclx.clear
    $wcsx.clear
    $bbt.clear
    $abr.clear
    $proc_list.clear
    $proc_task_list.clear 

    #puts "INIT_COMPUTING"
    
    proc = [] # proc_list用プロセッサ配列
    
    $calc_task.each{|task|
      lreqs = []
      sreqs = []
      task.req_list.each{|req|
        if req.outermost == true && req.res.kind == LONG
          lreqs << req
        elsif req.outermost == true && req.res.kind == SHORT
          sreqs << req
        end
      }
      $WCLR[task.task_id] = lreqs unless lreqs == []
      $WCSR[task.task_id] = sreqs unless sreqs == []
      
      #
      # SR, LRの計算
      #
      lr = []
      sr = []
      task.get_all_require.each{|req|
        if req.res.kind == LONG && req.outermost == true
          lr << req
        elsif req.res.kind == SHORT && req.outermost == true
          sr << req
        end
      }
      $LR[task.task_id] = lr unless lr == []
      $SR[task.task_id] = sr unless sr == []
      
      #
      # narrの計算
      #
      $NARR[task.task_id] = task.get_long_require_array_nest.size


      #
      # proc_listの計算
      #      
      proc << task.proc      

      #
      # wclx, wcsxの計算
      #
      $calc_task.each{|job|
        tuplesl = []
        tupless = []
        
        if task == nil || job == nil
          return []
        end
        begin
          k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
        rescue => e
          p e
          puts "タスク" + task.task_id.to_s + "の周期:" + task.period.to_f.to_s
          exit
        end
        1.upto(k){|n|
          WCLR(task).each{|req|
            if req.res.kind == LONG
              tuplesl << ReqTuple.new(req, n)
            end
          }
          WCSR(task).each{|req|
            if req.res.kind == SHORT && req.nested == false
              tupless << ReqTuple.new(req, n)
            end
          }
        }
        tuplesl.sort!{|a, b|
          (-1) * (a.req.time <=> b.req.time)
        }
        tupless.sort!{|a, b|
          (-1) * (a.req.time <=> b.req.time)
        }
        $wclx[[task.task_id, job.task_id]] = tuplesl
        $wcsx[[task.task_id, job.task_id]] = tupless
      }
    }
    
    #
    # proc_list設定
    #
    proc.uniq!
    proc.sort!    
    $proc_list = proc

    #
    # 上記の計算をした後でしか計算できないもの
    #
    $calc_task.each{ |job|
      tuple_abr = []
      tuples_abr = []
      $calc_task.each{ |task|
        #
        # abrの計算
        #
        if task.proc == job.proc && task.priority > job.priority
          tuple_abr = wcsx(task, job)
          if tuple_abr != []
            tuples_abr += tuple_abr
          end
        end

        
        #
        # bbtの計算
        #
        len = 0
        tuples = wclx(task, job)
        str = ""
        #tuples.each{|t|
        #  str += t.prints
        #}
        min = [tuples.size, narr(job) + 1].min
        0.upto(min-1){|num|
          len += tuples[num].req.time
        }
        $bbt[[task.task_id, job.task_id]] = len

      }
      $abr[job.task_id] = tuples_abr
    }

    
    #
    # partitionの計算
    #
    $proc_list.each{ |proc|
      proc_task_list = []
      $calc_task.each{|task|
        proc_task_list << task if task.proc == proc
      }
      $proc_task_list[proc] = proc_task_list
    }


  end
  ###########################################
  #
  #   以下 private 
  #
  ###########################################
  private

  def WCLR(task)
    ret = $WCLR[task.task_id]
    ret = [] if ret == nil
    return ret
  end
  
  def WCSR(task)
    ret = $WCSR[task.task_id]
    ret = [] if ret == nil
    return ret
  end
  
  def LR(job)
    ret = $LR[job.task_id]
    ret = [] if ret == nil
    return ret
  end
  
  def SR(job)
    ret = $SR[job.task_id]
    ret = [] if ret == nil
    return ret
  end
  
  def wclx(task, job)
    return $wclx[[task.task_id, job.task_id]]
  end
  
  def wcsx(task, job)
    return $wcsx[[task.task_id, job.task_id]]
  end
  
  def narr(job)
    return $NARR[job.task_id]
  end
  
  def partition(proc)
    return $proc_task_list[proc]
  end
  
  def procList
    return $proc_list
  end

  
  ##############################
  
  def bbt(task, job)
    return $bbt[[task.task_id, job.task_id]]
  end
  
  def abr(job)
    return $abr[job.task_id]
  end
  
  
  def ndbp(job, proc)
    if job.proc == proc
      return 0
    end
    count = 0
    partition(proc).each{|task|
      count += ndbt(task, job)
    }
    p_debug("ndbp(#{job.task_id}, #{proc.to_s.yellow}) = #{count}")
    return count
  end
  
  def ndbt(task, job)
    count = 0
    g = []
    LR(job).each{|req|
      g << req.res.group
    }
    g.uniq!
    g.each{|group|
      count += ndbtg(task, job, group)
    }
    p_debug("\tndbt(#{task.task_id.to_s.blue}, #{job.task_id.to_s.red}) = #{count}")
    return count
  end
  
  def ndbtg(task, job, group)
    a = 0
    b = 0
    LR(job).each{|req|
      a += 1 if req.res.group == group
    }
    WCLR(task).each{|req|
      b += 1 if req.res.group == group
    }
    p_debug("\t\tndbtg(#{task.task_id.to_s.blue}, #{job.task_id.to_s.red}, #{group.to_s.magenta}) = #{[a, b].min}")
    return [a, b].min
  end
  
  def rbl(job)
    time = 0
    procList.each{|proc|
      if job.proc != proc
        time += rblp(job, proc)
      end
    }
    p_debug("rbl(#{job.task_id.to_s.red}) = #{time}")
    return time 
  end
  
  def rblp(job, proc)
    count = 0
    partition(proc).each{|task|
      count += rblt(task, job)
    }
    p_debug("  rblp(#{job.task_id.to_s.red}, #{proc.to_s.yellow}) = #{count}")
    return count
  end
  
  def rblt(task, job)
    time = 0
    str = ""
    if task == nil || job == nil
      return 0
      elsif task.proc  == job.proc 
      return 0
    end
    tuples = wclx(task, job)
    tuples.each{|t|
      str += t.prints
    }
    min = [ndbp(job, task.proc), tuples.size].min
    0.upto(min-1){|num|
      time += tuples[num].req.time
    }
    p_debug("      tuples = #{str}")
    p_debug("    rblt_min = min(#{ndbp(job, task.proc)}, #{tuples.size})")
    p_debug("    rblt(#{task.task_id.to_s.blue}, #{job.task_id.to_s.red}) = #{time}")
    return time
  end
  
  
  def wcsp(job, proc)
    tuples = []
    partition(proc).each{|task|
      tuples += wcsx(task, job)
    }
    tuples
  end
  
  def rbs(job)
    time = 0
    procList.each{|proc|
      if job.proc != proc
        time += rbsp(job, proc)
      end
    }
    p_debug("rbs(#{job.task_id.to_s.red}) = #{time}")
    return time
  end
  
  def rbsp(job, proc)
    time = 0
    if job == nil
      return 0
    end
    str = ""
    tuples = wcsp(job, proc)
    min = [ndbp(job, proc), wcsp(job, proc).size].min
    0.upto(min-1){|num|
      time += tuples[num].req.time
    }
    p_debug("rbsp(#{job.task_id.to_s.blue}, #{proc.to_s.yellow}) = #{time}")
    return time
  end
  
  
  def wcsxg(task, job, group)
    tuples = []
    if task == nil || job == nil 
      return []
    end
    begin
      k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
      rescue => e
      p e
      puts "タスク" + task.task_id.to_s + "の周期:" + task.period.to_f.to_s
      exit
    end
    1.upto(k){|n|
      task.req_list.each{|req|
        if req.res.kind == SHORT && req.res.group == group
          tuples << ReqTuple.new(req, n)
        end
      }
    }
    tuples.sort!{|a, b|
      (-1) * (a.req.time <=> b.req.time)
    }
    tuples
  end
  
  def wcspg(job, proc, group)
    tuples = []
    partition(proc).each{|task|
      tuples += wcsxg(task, job, group)
    }
    tuples.sort!{|a, b|
      (-1) * (a.req.time <=> b.req.time)
    }
    return tuples
  end
  
  def sbg(job, group)
    time = 0
    # p procList
    procList.each{|proc|
      if job.proc != proc
        time += sbgp(job, group, proc)
      end
    }
    p_debug("rblp(#{job.task_id.to_s.blue}, #{group.to_s.magenta}) = #{time}")
    return time
  end 
  
  def sbgp(job, group, proc)
    time = 0
    b = 0
    SR(job).each{|req|
      if req.res.group == group
        b += 1
      end
    }
    tuples = wcspg(job, proc, group)
    min = [b, tuples.size].min
    0.upto(min-1){|num|
      time += tuples[num].req.time
    }
    p_debug("sbgp(#{job.task_id}, #{group}, #{proc}) = #{time}")
    time
  end
  
  
  def lbt(task)
    LB(task)
  end

  ###########################################
  #
  #   以下 public
  #
  ###########################################
  public
  def BB(job)
    return 0 if job == nil
    time = 0
    $calc_task.each{|tas|
      if tas.proc == job.proc && tas.priority > job.priority
        time += bbt(tas, job)
      end
    }
    return time
  end
  
  def AB(job)
    #p job.task_id
    if job == nil
      return 0
    end

      
    time = 0
    tuples = abr(job)
    min = [tuples.size, narr(job) + 1].min
    0.upto(min-1){|num|
      time += tuples[num].req.time
    }
    p_debug("ABmin = min(#{tuples.size}, #{narr(job)+1})")
    return time
  end
  
  def LB(job)
    p_debug("LB(#{job.task_id})")
    #RubyProf.start
    if job == nil
      return 0
    elsif job.get_long_require_array.size == 0
      p_debug("\tget_long_require_array.size == 0")
      return 0
    end
    return rbl(job) + rbs(job)
    #result = RubyProf.stop
    # Print a flat profile to text
    #printer = RubyProf::FlatPrinter.new(result)
    #printer.print(STDOUT)
  end
  
  def SB(job)
    if job == nil
      return 0
    elsif job.get_short_require_array.size == 0
      return 0
    end
    g = []
    time = 0
    SR(job).each{|req|
      g << req.res.group
    }
    g.uniq!
    g.each{|group|
      time += sbg(job, group)
    }
    time
  end
  
  def DB(task)
    time = 0
    $calc_task.each{|tas|
      if tas.proc == task.proc && tas.priority < task.priority
        time += [tas.extime, lbt(tas)].min
      end
    }
    time 
  end
  
  def B(job)
    return BB(job) + AB(job) + LB(job) + SB(job) + DB(job)
  end
  
#############################
#
# その他関数
#
#############################
  #
  # 同一プロセッサ内で最低優先度を持つタスクのリストを返す
  #
  private
  def lowest_priority_task(proc)
    pri = 0 # 最高優先度
    tsk = []
    $calc_task.each{|t|
      if t.proc == proc
        if pri < t.priority
          pri = t.priority
        end
      end
    }
    $calc_task.each{|t|
        if pri == t.priority && t.proc == proc
          tsk << t
        end
    }
    return tsk
  end
  
  
  def get_extime_high_priority(task)
    time = 0
    $calc_task.each{|t|
      sb = t.sb
      if t.proc == task.proc && t.priority < task.priority
        time += (t.extime + sb) * ((task.period / t.period).ceil + 1)
        #print "(#{t.extime}+#{sb})*#{(t.period/task.period).ceil + 1}(#{t.period}, #{task.period}), " 
      end
    }
    #puts ""
    return time
  end
  
  #
  # 以下のフォーマットでブロック時間等表示
  #
  def show_blocktime
    $calc_task.each{|t|
      print "タスク#{t.task_id}"      
      print ["\tBB:", sprintf("%.3f", t.bb)].join
      print ["\tAB:", sprintf("%.3f", t.ab)].join
      print ["\tSB:", sprintf("%.3f", t.sb)].join
      print ["\tLB:", sprintf("%.3f", t.lb)].join
      print ["\tDB:", sprintf("%.3f", t.db)].join
      print ["\tB:", sprintf("%.3f", t.b)].join
      print "\n"
      pri = get_extime_high_priority(t) 
      #puts "\t最悪応答時間：実行時間#{t.extime} + 最大ブロック時間#{sprintf("%.3f", t.b)} + プリエンプト時間#{sprintf("%.3f", pri)} = #{sprintf("%.3f", t.extime + t.b + pri)}"
      if t.period < t.extime + t.b + pri
        puts "\t\t周期#{t.period}<最悪応答時間#{sprintf("%.3f", t.extime + t.b + pri)}".red
      else
        puts "\t\t周期#{t.period}>最悪応答時間#{sprintf("%.3f", t.extime + t.b + pri)}"
      end
    }
  end

  #
  # タスクにブロック時間情報を格納
  #
  public
  def set_blocktime
    $calc_task.each{|t|
      #puts "SET_BLOCKTIME:タスク#{t.task_id}"
      t.bb = BB(t)
      t.ab = AB(t)
      t.sb = SB(t)
      t.lb = LB(t)
      t.db = DB(t)
      t.b = t.bb + t.ab + t.sb + t.lb + t.db
    }
    # 最悪応答時間の計算
    $calc_task.each{ |t|
      t.wcrt = wcrt(t)
    }
  end
  
  #
  # 以下のフォーマットでブロック時間等表示
  # 120409用
  #
  private
  def show_blocktime_120409
    $calc_task.each{|task|
      #RubyProf.start

      set_blocktime(task)
    
      #result = RubyProf.stop
      #printer = RubyProf::FlatPrinter.new(result)
      #printer.print(STDOUT)
    }

    #
    # CPU使用率を表示
    #
    
    uabj = PROC_NUM # utilization_available_to_background_jobs
    procList.each{|p|
      u = 0
      #      puts "#{partition(p).size}"
      partition(p).each{|t|
        #puts "#{(t.extime+t.sb.to_f)/t.period}"
        u += (t.extime + t.b - t.lb)/t.period
      }
      #puts "CPU#{p}使用率:#{u}"
      uabj -= u
    }
    #puts "uabj:#{uabj}"
    return uabj
  end

  #
  # 以下のフォーマットでブロック時間等表示
  # 120409_2用
  #
  def show_blocktime_120409_2
    $calc_task.each{|task|
      set_blocktime(task)
    }
    
    #
    # CPU使用率を表示
    #
    
    uabj = PROC_NUM # utilization_available_to_background_jobs
    procList.each{|p|
      u = 0
      #      puts "#{partition(p).size}"
      partition(p).each{|t|
        #puts "#{(t.extime+t.sb.to_f)/t.period}"
        u += (t.extime + t.b - t.lb)/t.period
      }
      #puts "CPU#{p}使用率:#{u}"
      uabj -= u
    }
    #puts "uabj:#{uabj}"
    return uabj
  end

  #
  # 最悪応答時間
  #
  private
  def wcrt(job)
    pre_wcrt = job.extime + job.b
    n = 1
    #puts "job:#{job.task_id}"
    while(1)
      time = job.extime + job.b
      $calc_task.each{ |t|
        #pp t
        if t.priority < job.priority && t.proc == job.proc
          count = (((pre_wcrt+t.lb)/t.period).ceil)
          #puts "\t task#{t.task_id}:#{count}*#{t.extime+t.b-t.lb}"
          time += count*(t.extime + t.b - t.lb - t.db)
        end
      }
      #p time
      if time == pre_wcrt
        break
      else
        pre_wcrt = time
        n += 1
      end
    end
    return time
  end
end
