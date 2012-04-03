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
#
require "rubygems"
require "term/ansicolor"

class String
  include Term::ANSIColor
end

module WCBT
  def print_debug(str)
    if $DEBUG == true
      puts("\t" + str)
    end
  end
  
  def WCLR(task)
    reqs = []
    task.req_list.each{|req|
      if req.outermost == true && req.res.kind == "long" then
        reqs << req
      end
    }
    reqs
  end
  
  def WCSR(task)
    reqs = []
    task.req_list.each{|req|
      if req.outermost == true && req.res.kind == "short" then
        reqs << req
      end
    }
    reqs
  end
  
  def LR(job)
    lr = []
    job.get_all_require.each{|req|
      if req.res.kind == "long" && req.outermost == true then
        lr << req
      end
    }
    lr
  end
  
  def SR(job)
    sr = []
    job.get_all_require.each{|req|
      if req.res.kind == "short" && req.outermost == true then
        sr << req
      end
    }
    sr
  end
  
  def wclx(task, job)
    tuples = []
    if task == nil || job == nil then 
      return []
    end
    begin
      k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
      rescue
      puts "タスク" + task.task_id.to_s + "の周期:" + task.period.to_f.to_s
      exit
    end
    1.upto(k){|n|
      WCLR(task).each{|req|
        if req.res.kind == "long" then
          tuples << ReqTuple.new(req, n)
        end
      }
    }
    tuples.sort!{|a, b|
      (-1) * (a.req.time <=> b.req.time)
    }
    return tuples
  end
  
  def wcsx(task, job)
    tuples = []
    if task == nil || job == nil then 
      return []
    end
    k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
    1.upto(k){|n|
      WCSR(task).each{|req|
        if req.res.kind == "short" then
          tuples << ReqTuple.new(req, n)
        end
      }
    }
    tuples.sort!{|a, b|
      (-1) * (a.req.time <=> b.req.time)
    }
    tuples
  end
  
  def narr(job)
    job.get_long_resource_array.size
  end
  
  def partition(proc)
    procTaskList = []
    $taskList.each{|task|
      if task.proc == proc then
        procTaskList << task
      end
    }
    return procTaskList
  end
  
  def procList
    proc = []
    $taskList.each{|task|
      proc << task.proc
    }
    proc = proc.sort
    proc = proc.uniq
    return proc
  end
  
  #
  # 同一プロセッサ内で最低優先度を持つタスクのリストを返す
  #
  private
  def lowest_priority_task(proc)
    pri = 0 # 最高優先度
    tsk = []
    $taskList.each{|t|
      if t.proc == proc
        if pri < t.priority
          pri = t.priority
        end
      end
    }
    $taskList.each{|t|
        if pri == t.priority && t.proc == proc
          tsk << t
        end
    }
    return tsk
  end
  
  def get_extime_high_priority(task)
    time = 0
    $taskList.each{|t|
      sb = SB(t)
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
    $taskList.each{|task|
      print "タスク#{task.task_id}"
      bb = BB(task)
      ab = AB(task)
      sb = SB(task)
      lb = LB(task)
      db = DB(task)
      
      b = bb + ab + sb + lb + db
      print "\tBB:" + bb.to_s
      print "\tAB:" + ab.to_s
      print "\tSB:" + sb.to_s
      print "\tLB:" + lb.to_s
      print "\tDB:" + db.to_s
      print "\tB:" + b.to_s
      print "\n"
      pri = get_extime_high_priority(task) 
      puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{b} + プリエンプト時間#{pri} = #{task.extime + b + pri}"
      if task.period < task.extime + b + pri
        puts "\t\t周期#{task.period}<最悪応答時間#{task.extime + b + pri}".red
      else
        puts "\t\t周期#{task.period}>最悪応答時間#{task.extime + b + pri}"
      end
    }
  end

  #
  # タスクにブロック時間情報を格納
  #
  def set_blocktime(t)
    t.bb = BB(t)
    t.ab = AB(t)
    t.sb = SB(t)
    t.lb = LB(t)
    t.db = DB(t)
    t.b = t.bb + t.ab + t.sb + t.lb + t.db
  end
  
  
  #
  # 以下のフォーマットでブロック時間等表示
  # 120409用
  #
  def show_blocktime_120409
    $taskList.each{|task|
      set_blocktime(task)

=begin
      print "タスク#{task.task_id}"
      print "(#{(task.extime+task.sb)/task.period})"
      print "\tBB:#{task.bb}" 
      print "\tAB:#{task.ab}" 
      print "\tSB:#{task.sb}" 
      print "\tLB:#{task.lb}" 
      print "\tDB:#{task.db}" 
      print "\tB:#{task.b}" 
      print "\n"
      pri = get_extime_high_priority(task) 
      puts "\t最悪応答時間：実行時間#{task.extime} + 最大ブロック時間#{task.b} + プリエンプト時間#{pri} = #{task.extime + task.b + pri}"
      
      if task.period < task.extime + task.b + pri
        puts "\t\t周期#{task.period}<最悪応答時間#{task.extime + task.b + pri}".red
        else
        puts "\t\t周期#{task.period}>最悪応答時間#{task.extime + task.b + pri}"
      end
=end

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
        u += (t.extime+t.sb.to_f)/t.period
      }
      #puts "CPU#{p}使用率:#{u}"
      uabj -= u
    }
    #puts "uabj:#{uabj}"
    return uabj
  end
  
  ##############################
  
  def bbt(task, job)
    if task == job then
      return 0
    end
    len = 0
    tuples = wclx(task, job)
    str = ""
    tuples.each{|t|
      str += t.prints
    }
    min = [tuples.size, narr(job) + 1].min
    0.upto(min-1){|num|
      len += tuples[num].req.time
    }
    print_debug("  bbt_tuples = #{str}")
    print_debug("bbt_min = min(#{tuples.size}, #{narr(job)+1})")
    print_debug("bbt(#{task.task_id.to_s.blue}, #{job.task_id.to_s.red}) = #{len}")
    return len
  end
  
  def abr(job)
    if job == nil then 
      return []
    end
    tuples = []
    str = ""
    $taskList.each{|task|
      if task.proc == job.proc && task.priority > job.priority then
        tuple = wcsx(task, job)
        if tuple != [] then
          tuples += tuple
        end
      end
    }
    tuples.each{|t|
      str += t.prints
    }
    print_debug("abr(#{job.task_id.to_s.red}) = #{str}")
    return tuples
  end
  
  
  def ndbp(job, proc)
    if job.proc == proc then
      return 0
    end
    count = 0
    partition(proc).each{|task|
      count += ndbt(task, job)
    }
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
    return count
  end
  
  def ndbtg(task, job, group)
    a = b = 0
    #  pp job.get_long_resource_array.size
    LR(job).each{|req|
      if req.res.group == group then 
        a += 1
      end
    }
    #pp WCLR(task).size
    WCLR(task).each{|req|
      if req.res.group == group then
        b += 1
      end
    }
    print_debug("ndbtg(#{task.task_id.to_s.blue}, #{job.task_id.to_s.red}, #{group.to_s.magenta})")
    return [a, b].min
  end
  
  def rbl(job)
    time = 0
    # p procList
    procList.each{|proc|
      if job.proc != proc then
        time += rblp(job, proc)
      end
    }
    print_debug("rbl(#{job.task_id.to_s.red}) = #{time}")
    return time 
  end
  
  def rblp(job, proc)
    count = 0
    partition(proc).each{|task|
      count += rblt(task, job)
    }
    print_debug("  rblp(#{job.task_id.to_s.red}, #{proc.to_s.yellow}) = #{count}")
    return count
  end
  
  def rblt(task, job)
    time = 0
    str = ""
    if task == nil || job == nil then
      return 0
      elsif task.proc  == job.proc then 
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
    print_debug("      tuples = #{str}")
    print_debug("    rblt_min = min(#{ndbp(job, task.proc)}, #{tuples.size})")
    print_debug("    rblt(#{task.task_id.to_s.blue}, #{job.task_id.to_s.red}) = #{time}")
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
      if job.proc != proc then
        time += rbsp(job, proc)
      end
    }
    print_debug("rbs(#{job.task_id.to_s.red}) = #{time}")
    return time
  end
  
  def rbsp(job, proc)
    time = 0
    if job == nil then
      return 0
    end
    str = ""
    tuples = wcsp(job, proc)
    min = [ndbp(job, proc), wcsp(job, proc).size].min
    0.upto(min-1){|num|
      time += tuples[num].req.time
    }
    print_debug("rbsp(#{job.task_id.to_s.blue}, #{proc.to_s.yellow}) = #{time}")
    return time
  end
  
  
  def wcsxg(task, job, group)
    tuples = []
    if task == nil || job == nil then 
      return []
    end
    begin
      k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
      rescue
      puts "タスク" + task.task_id.to_s + "の周期:" + task.period.to_f.to_s
      exit
    end
    1.upto(k){|n|
      task.req_list.each{|req|
        if req.res.kind == "short" && req.res.group == group then
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
      if job.proc != proc then
        time += sbgp(job, group, proc)
      end
    }
    print_debug("rblp(#{job.task_id.to_s.blue}, #{group.to_s.magenta}) = #{time}")
    return time
  end 
  
  def sbgp(job, group, proc)
    time = 0
    b = 0
    SR(job).each{|req|
      if req.res.group == group then
        b += 1
      end
    }
    tuples = wcspg(job, proc, group)
    min = [b, tuples.size].min
    0.upto(min-1){|num|
      time += tuples[num].req.time
    }
    print_debug("sbgp(#{job.task_id}, #{group}, #{proc}) = #{time}")
    time
  end
  
  
  def lbt(task)
    LB(task)
  end
  ##############################
  
  def BB(job)
    if job.get_long_resource_array.size == 0 then
      return 0
    end
    time = 0
    $taskList.each{|tas|
      if tas.proc == job.proc && tas.priority > job.priority then
        time += bbt(tas, job)
      end
    }
    return time
  end
  
  def AB(job)
    #p job.task_id
    if job == nil
      return 0
    elsif job.get_short_resource_array.size == 0
      return 0
    elsif lowest_priority_task(job.proc)[0].priority == job.priority
      #p "lowest"
      print_debug("最低優先度")
      return 0
    end
      
    time = 0
    tuples = abr(job)
    min = [tuples.size, narr(job) + 1].min
    0.upto(min-1){|num|
      time += tuples[num].req.time
    }
    print_debug("ABmin = min(#{tuples.size}, #{narr(job)+1})")
    return time
  end
  
  def LB(job)
    if job == nil then
      return 0
    elsif job.get_long_resource_array.size == 0
      return 0
    end
    return rbl(job) + rbs(job)
  end
  
  def SB(job)
    if job == nil then
      return 0
    elsif job.get_short_resource_array.size == 0
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
    $taskList.each{|tas|
      if tas.proc == task.proc && tas.priority < task.priority then
        time += [tas.extime, lbt(tas)].min
      end
    }
    time 
  end
  
  def B(job)
    return BB(job) + AB(job) + LB(job) + SB(job) + DB(job)
  end
  
  #############################
end