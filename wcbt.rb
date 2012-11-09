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
$:.unshift(File.dirname(__FILE__))
require "./common_module"
require "./config"
require "rubygems"
require "term/ansicolor"

$calc_task = [] # WCBTモジュールで使用するタスク

class String
  include Term::ANSIColor
end

class Range
  # 範囲の中でランダムの数字を返す
  def get_random
    return (first + rand(last - first))
  end
end

class Object
  def debug
    $DEBUGFlg = true
    begin
      yield
    ensure
      $DEBUGFlg = false
    end
  end
end

# WCLRなど
$WCLR = Hash.new
$WCSR = Hash.new
$LR = Hash.new 
$SR = Hash.new
$NARR = Hash.new
$wclx = Hash.new
$wcsx = Hash.new
$ndbp = Hash.new
$wcsp = Hash.new
$rbs = Hash.new
$rbl = Hash.new
$bbt = Hash.new
$abr = Hash.new
$wcspg = Hash.new
$sbp = Hash.new

#$proc_list = Hash.new
#$proc_task_list = Hash.new

module WCBT
  def p_debug(str)
    puts("\t" + str) if $DEBUGFlg == true
  end
  
  # 予め計算しておく
  def init_computing(tasks)
    $calc_task = tasks
    
    $WCLR.clear
    $WCSR.clear
    $LR.clear
    $SR.clear
    $NARR.clear
    $wclx.clear
    $wcsx.clear
    $ndbp.clear
    $wcsp.clear
    $rbs.clear
    $rbl.clear
    $bbt.clear
    $abr.clear
    $wcspg.clear
    $sbp.clear
    
    # ブロック時間のリセット
    $calc_task.each { |tsk| tsk.reset_task }
    
    $calc_task.each do |task|
      # SR, LRの計算
      lr = []
      sr = []
      task.all_require.each do |req|
        if req.outermost == true
          case req.res.kind
          when LONG
            lr << req
          when SHORT
            sr << req
          end
        end
      end
      $LR[task.task_id] = lr unless lr == []
      $SR[task.task_id] = sr unless sr == []
    end
    
    # inflated_timeの計算
    $calc_task.each{ |task| SB_not_tight(task) }

    $calc_task.each do |task|
      lreqs = []
      sreqs = []

      # ネストしているリソース要求も含める
      task.all_require.each do |req|
        if req.outermost == true
          case req.res.kind
          when LONG
            lreqs << req
          when SHORT
            sreqs << req
          end
        end
      end
      $WCLR[task.task_id] = lreqs unless lreqs == []
      $WCSR[task.task_id] = sreqs unless sreqs == []

      # narrの計算
      if $REMOTE_RESOURCE_FLG
        $NARR[task.task_id] = 0

        # リモートタスクの要求するリソースのグループのリスト
        remote_group_list = get_remote_groups(task.proc)

        # longリソース要求により，suspendする回数
        suspend_cnt = 0
        
        task.long_require_array.each do |res|
          suspend_cnt += 1 if remote_group_list.include?(res.res.group)
        end

        $NARR[task.task_id] = suspend_cnt + 1
        
      else
        $NARR[task.task_id] = task.long_require_array.size + 1
      end
      
      # wclx, wcsxの計算
      $calc_task.each do |job|
        tuplesl = []
        tupless = []
        
        return [] if task == nil || job == nil

        begin
          k = (job.period/task.period).ceil.to_i + 1
        rescue => e
          p e
          puts "タスク" + task.task_id.to_s + "の周期:" + task.period.to_f.to_s
          exit
        end

        1.upto(k) do |n|
          WCLR(task).each{ |req| tuplesl << ReqTuple.new(req, n) if req.res.kind == LONG }
          WCSR(task).each{ |req| tupless << ReqTuple.new(req, n) if req.res.kind == SHORT && req.nested == false }
        end
        
        # リソース要求時間順にソート
        tuplesl.sort!{|a, b| (-1) * (a.req.get_time_inflated <=> b.req.get_time_inflated) }
        tupless.sort!{|a, b| (-1) * (a.req.get_time_inflated <=> b.req.get_time_inflated) }
        
        $wclx[[task.task_id, job.task_id]] = tuplesl
        $wcsx[[task.task_id, job.task_id]] = tupless
      end
    end
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

  # ジョブjobが高優先度なジョブにプリエンプトされる回数
  # @param: [Task] job プリエンプトされるジョブ
  # @return: [Fixnum] プリエンプトされる回数
  def preempt(job)
    preempt_list = [0]
    job.proc.task_list.each do |tsk|
      preempt_list << (job.period/tsk.period).ceil.to_i if tsk.priority < job.priority
    end
    
    return preempt_list.max
  end

  # リモートタスクが要求するリソースグループの配列を返す
  # @param: [Processor] proc 自プロセッサ
  # @return: [Array<Group>] リモートタスクが要求しているリソースグループの配列
  def get_remote_groups(proc)
    remote_group_list = []
    ProcessorManager.proc_list.each do |p|
      next if proc == p
      p.task_list.each do |tsk|
        tsk.long_require_array.each do |res2|
          remote_group_list << res2.res.group
        end
      end
    end

    return remote_group_list.uniq.sort!
  end

  def partition(proc)
    raise unless proc.class == Processor
    return proc.task_list
    #return $proc_task_list[proc]
  end
  
  # ProcessorのArrayを返す
  def proc_list
    return ProcessorManager.proc_list
  end

  def bbt(task, job)
    len = 0
    if $bbt[[task.task_id, job.task_id]] == nil
      tuples = wclx(task, job)
      min = [tuples.size, narr(job)].min
      0.upto(min-1) do |num|
        len += tuples[num].req.get_time_inflated
      end
      $bbt[[task.task_id, job.task_id]] = len
    else
      len = $bbt[[task.task_id, job.task_id]]
    end
    return len
    #return $bbt[[task.task_id, job.task_id]]
  end
  
  def abr(job)
    return [] if job == nil
    tuples = []

    if $abr[job.task_id] == nil
      job.proc.task_list.each do |task|
        next if task == nil || task == []
        if task.proc == job.proc && task.priority > job.priority
          tuple = wcsx(task, job)
          tuples += tuple unless tuple == []
        end
      end
      tuples.sort!{ |a, b| -1 * (a.req.get_time_inflated <=> b.req.get_time_inflated) }
      $abr[job.task_id] = tuples
    else
      tuples =  $abr[job.task_id]
    end
    return tuples
    #return $abr[job.task_id]
  end

  # shortリソース要求毎の最大ブロック時間
  # ABを計算する前に用いる
  def sbr(req, processor)
    raise unless processor.class == Processor
    block_time = 0
    
    # 各プロセッサからreqと競合する可能性のあるリソース要求のCS時間を足しあわせ
    proc_list.each do |proc|
      next if processor == proc
      reqs_time_array = competing(req, proc).collect{ |r| r.time }
      #puts "\t#{reqs_time_array}"
      block_time += reqs_time_array.max unless reqs_time_array == []
    end
    
    return block_time
  end
  
  # プロセッサp内の，reqと競合するリソース要求の集合
  # なければ [] を返す
  def competing(req, proc)
    raise unless proc.class == Processor
    req_list = []
    
    proc.task_list.each do |tsk|
      tsk.all_require.each do |r|
        next if r == req  # reqと同じなら除外
        req_list << r if req.res.group == r.res.group
      end
    end

    return req_list
  end

  
  def ndbp(job, proc)
    raise unless proc.class == Processor
    return 0 if job.proc == proc

    if $ndbp[[job.task_id, proc.proc_id]] == nil
      count = 0
      proc.task_list.each do |task|
        count += ndbt(task, job)
      end
      $ndbp[[job.task_id, proc.proc_id]] = count
      
      #p_debug("ndbp(#{job.task_id}, #{proc.to_s.yellow}) = #{count}")
    else
      count = $ndbp[[job.task_id, proc.proc_id]]
    end

    return count
  end
  
  def ndbt(task, job)
    count = 0
    g = []
    LR(job).each do |req|
      g << req.res.group
    end
    g.uniq!
    g.each do |group|
      count += ndbtg(task, job, group)
    end
    #p_debug("\tndbt(#{task.task_id.to_s.blue}, #{job.task_id.to_s.red}) = #{count}")
    return count
  end
  
  def ndbtg(task, job, group)
    a = 0
    b = 0
    LR(job).each do |req|
      a += 1 if req.res.group == group
    end
    WCLR(task).each do |req|
      b += 1 if req.res.group == group
    end
    b *= ((job.period.to_f/task.period.to_f).ceil.to_i + 1)
    #p_debug("\t\tndbtg(#{task.task_id.to_s.blue}, #{job.task_id.to_s.red}, #{group.to_s.magenta}) = #{[a, b].min}")
    return [a, b].min
  end
  
  def rbl(job)
    time = 0
    if $rbl[job.task_id] == nil
      proc_list.each do |proc|
        time += rblp(job, proc) if job.proc != proc
      end
      $rbl[job.task_id] = time
    else
      time = $rbl[job.task_id]
    end
    #p_debug("rbl(#{job.task_id.to_s.red}) = #{time}")
    return time 
  end
  
  def rblp(job, proc)
    raise unless proc.class == Processor
    count = 0
    proc.task_list.each do |task|
      count += rblt(task, job)
    end
    #p_debug("  rblp(#{job.task_id.to_s.red}, #{proc.to_s.yellow}) = #{count}")
    return count
  end
  
  def rblt(task, job)
    time = 0
    str = ""
    if task == nil || job == nil
      return 0
    elsif task.proc == job.proc
      return 0
    end
    
    unless task.class == Task
      p task.class
      raise
    end
    #p task.class unless task.class == Task
    tuples = wclx(task, job)
    tuples.each do |t|
      str += t.to_str
    end
    
    min = [ndbp(job, task.proc), tuples.size].min
    0.upto(min-1) do |num|
      #p_debug("#{tuples[num].to_str}: #{tuples[num].req.get_time_inflated}")
      time +=  tuples[num].req.get_time_inflated
    end
    #p_debug("      tuples = #{str}")
    #p_debug("    rblt_min = min(#{ndbp(job, task.proc)}, #{tuples.size})")
    #p_debug("    rblt(#{task.task_id.to_s.blue}, #{job.task_id.to_s.red}) = #{time}")
    return time
  end
  
  
  def wcsp(job, proc)
    tuples = []
    raise unless proc.class == Processor
    if $wcsp[[job.task_id, proc.proc_id]] == nil
      proc.task_list.each do |task|
        tuples += wcsx(task, job)
      end
      tuples.sort!{|a, b| -1*(a.req.get_time_inflated <=> b.req.get_time_inflated) }
      $wcsp[[job.task_id, proc.proc_id]] = tuples
    else
      tuples = $wcsp[[job.task_id, proc.proc_id]] 
    end
    return tuples
  end
  
  def rbs(job)
    time = 0
    if $rbs[job.task_id] == nil
      proc_list.each do |proc|
        time += rbsp(job, proc) if job.proc != proc
      end
      $rbs[job.task_id] = time
    else
      time = $rbs[job.task_id]
    end
    
    #p_debug("rbs(#{job.task_id.to_s.red}) = #{time}")
    return time
  end
  
  def rbsp(job, proc)
    time = 0
    return 0 if job == nil
    
    tuples = wcsp(job, proc)
    min = [ndbp(job, proc), wcsp(job, proc).size].min
    
    return 0 if min == 0
#    tuples.each{ |t| #p_debug(t.to_str); }
    0.upto(min-1) do |num|
      #p_debug(tuples[num].to_str)
      time += tuples[num].req.get_time_inflated
    end
    #p_debug("rbsp(#{job.task_id.to_s.blue}, #{proc.to_s.yellow}) = #{time}")
    return time
  end
  
  
  def wcsxg(task, job, group)
    tuples = []
    return [] if task == nil || job == nil 

    begin
      k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
    rescue => e
      p e
      puts "タスク" + task.task_id.to_s + "の周期:" + task.period.to_f.to_s
      raise
    end
    1.upto(k) do |n|
      task.req_list.each do |req|
        if req.res.kind == SHORT && req.res.group == group
          tuples << ReqTuple.new(req, n)
        end
      end
    end
    #tuples.sort!{ |a, b| (-1) * (a.req.get_time_ <=> b.req.time) }
    return tuples
  end
  
  # プロセッサpのタスクでグループgのリソースを要求するリソース要求の集合
  # @param: [Task] job 自タスク
  # @param: [Processor] proc リモートプロセッサ
  # @param: [Group] group リソースグループ
  def wcspg(job, proc, group)
    raise unless proc.class == Processor
    tuples = []
    
    if $wcspg[[job.task_id, proc.proc_id, group]] == nil
      proc.task_list.each do |task|
        tuples += wcsxg(task, job, group)
      end
      tuples.sort!{|a, b| (-1) * (a.req.time <=> b.req.time) }
      $wcspg[[job.task_id, proc.proc_id, group]] = tuples
    else
      tuples = $wcspg[[job.task_id, proc.proc_id, group]]
    end
    return tuples
  end

  # プロセッサpのタスクの中でタスクjobが要求するリソースを要求するリソース要求の集合
  # @param: [Task] job 自タスク
  # @param: [Processor] proc リモートプロセッサ
  # @return: [Array<ReqTaple>] プロセッサpのタスクの中でタスクjobが
  #  要求するリソースを要求するリソース要求の集合
  def wcspx(job, proc)
    tuples = []
    using_grp = []

    SR(job).each{ |req| using_grp << req.res.group }
    using_grp.uniq!
    
    using_grp.each { |grp| tuples += wcspg(job, proc, grp) }
    tuples.sort!{|a, b| (-1) * (a.req.time <=> b.req.time) }
    return tuples
  end
  
  def sbg(job, group)
    time = 0
    # p proc_list
    proc_list.each do |proc|
      if job.proc != proc
        time += sbgp(job, group, proc)
      end
    end
    #p_debug("rblp(#{job.task_id.to_s.blue}, #{group.to_s.magenta}) = #{time}")
    return time
  end 
  
  # プロセッサpのタスクによるブロック時間
  # @param: [Task] job 自タスク
  # @param: [Processor] proc リモートプロセッサ
  # @return: [Numeric] ブロック時間
  def sbp(job, proc)
    raise unless proc.class == Processor
    return 0 if job.proc == proc
    if $sbp[[job.task_id, proc.proc_id]] == nil
      time = 0
      
      # タスクjobがshortリソース要求する回数
      b = SR(job).size
      
      tuples = wcspx(job, proc)
      
      # ブロックされる回数
      min = [b+preempt(job), tuples.size].min
      
      0.upto(min-1) { |num| time += tuples[num].req.time }
      $sbp[[job.task_id, proc.proc_id]] = time
    else
      time = $sbp[[job.task_id, proc.proc_id]]
    end
    #p_debug("sbp(#{job.task_id}, #{proc}) = #{time}")
      
    return time
  end
  
  def sbgp(job, group, proc)
    raise unless proc.class == Processor
    time = 0
    b = 0
    SR(job).each do |req|
      if req.res.group == group
        b += 1
      end
    end
    tuples = wcspg(job, proc, group)
    if $PREEMPTIVE_FLG
      # preemptive spin の場合
      min = [b+preempt(job), tuples.size].min
    else
      min = [b, tuples.size].min
    end
    0.upto(min-1) do |num|
      time += tuples[num].req.time
    end
    #p_debug("sbgp(#{job.task_id}, #{group}, #{proc}) = #{time}")
    return time
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
  # ローカルタスクがlongリソースを要求する際に発生する最大ブロック時間
  # @param: [Task] job 自タスク
  # @return: [Numeric] LB最大ブロック時間
  def BB(job)
    return 0 if job == nil || job == []
    time = 0
    job.proc.task_list.each do |tsk|
      if tsk.proc == job.proc && tsk.priority > job.priority
        time += bbt(tsk, job)
      end
    end
    return time
  end

  # ローカルタスクがshortリソースを要求する際に発生する最大ブロック時間
  # @param: [Task] job 自タスク
  # @return: [Numeric] AB最大ブロック時間
  def AB(job)
    return 0 if job == nil || job == []

    time = 0
    tuples = abr(job)
    min = [tuples.size, narr(job)].min
    0.upto(min-1) do |num|
      if $PREEMPTIVE_FLG
        time += tuples[num].req.time # spinをpreemptiveにした場合
      else
        time += tuples[num].req.get_time_inflated # SBによるspintimeも考慮したAB時間
      end
    end
    #p_debug("ABmin = min(#{tuples.size}, #{narr(job)})")

    return time
  end
  
  def AB_preemptive(job)
    return 0 if job == nil || job == []

    time = 0
    tuples = abr(job)
    min = [tuples.size, narr(job)].min
    0.upto(min-1) do |num|
      time += tuples[num].req.time # spinをpreemptiveにした場合
      #time += tuples[num].req.get_time_inflated # SBによるspintimeも考慮したAB時間
    end
    #p_debug("ABmin = min(#{tuples.size}, #{narr(job)})")

    return time
  end

  # グローバルなlongリソースを要求する時の最大ブロック時間
  # @param: [Task] job 自タスク
  # @return: [Numeric] LB最大ブロック時間
  def LB(job)
    #p_debug("LB(#{job.task_id})")
    #RubyProf.start
    if job == nil
      return 0
    elsif job.long_require_array.size == 0
      #p_debug("\tlong_require_array.size == 0")
      return 0
    end
    return rbl(job) + rbs(job)
    #result = RubyProf.stop
    # Print a flat profile to text
    #printer = RubyProf::FlatPrinter.new(result)
    #printer.print(STDOUT)
  end
  
  # グローバルなshortリソースを要求する時の最大ブロック時間
  # @param [Task] job 自タスク
  # @return [Numeric] SB最大ブロック時間
  def SB(job)
    if job == nil
      return 0
    elsif job.short_require_array.size == 0
      return 0
    end
    g = []
    time = 0
    if $PREEMPTIVE_FLG
      proc_list.each do |proc|
        next if proc == job.proc
        time += sbp(job, proc)
      end
    else
      SR(job).each { |req| g << req.res.group }
      g.uniq!
      g.each { |group|  time += sbg(job, group) }
    end
    
    return time
  end

  #
  # SBより悲観的な最大ShortBlocking
  # Appendix A.5
  def SB_not_tight(job)
    block_time = 0

    job.short_require_array.each do |req|
      # spin_block時間の計算
      inflate_time = sbr(req, job.proc)
      
      # 各要求にspin_block時間を加える
      req.add_inflated_spintime(inflate_time)

      ## puts "リソース要求#{req.req_id}:inflate_time:#{inflate_time}"
      block_time += inflate_time
    end
    #job.set_extime(job.get_extime + block_time)
    job.set_inflated_time(block_time)
    return block_time
  end

  def DB(task)
    time = 0
    task.proc.task_list.each do |tas|
      if tas.proc == task.proc && tas.priority < task.priority
        time += [tas.get_extime+tas.get_inflated_time, lbt(tas)].min
      end
    end
    return time 
  end
  
  #def B(job)
  #  return BB(job) + AB(job) + LB(job) + SB(job) + DB(job)
  #end
  
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
    raise unless proc.class == Processor
    pri = 0 # 最高優先度
    tsk = []
    proc.task_list.each do |t|
      if t.proc == proc
        pri = t.priority if pri < t.priority
      end
    end
    proc.task_list.each do |t|
      if pri == t.priority && t.proc == proc
        tsk << t
      end
    end
    return tsk
  end
  
  
  def get_extime_high_priority(task)
    time = 0
    task.proc.task_list.each do |t|
      sb = t.sb
      if t.proc == task.proc && t.priority < task.priority
        time += (t.get_extime + sb) * ((task.period / t.period).ceil + 1)
        #print "(#{t.get_extime}+#{sb})*#{(t.period/task.period).ceil + 1}(#{t.period}, #{task.period}), " 
      end
    end
    #puts ""
    return time
  end
  
  # 以下のフォーマットでブロック時間等表示
  def show_blocktime
    $calc_task.each do |t|
      print "タスク#{t.task_id}"      
      print ["\tBB:", sprintf("%.3f", t.bb)].join
      print ["\tAB:", sprintf("%.3f", t.ab)].join
      print ["\tSB:", sprintf("%.3f", t.sb)].join
      print ["\tLB:", sprintf("%.3f", t.lb)].join
      print ["\tDB:", sprintf("%.3f", t.db)].join
      print ["\tB:", sprintf("%.3f", t.b)].join
      print "\n"

      if t.period < t.wcrt
        puts "\t\t周期#{t.period}<最悪応答時間#{sprintf("%.3f", t.wcrt)}".red
      else
        puts "\t\t周期#{t.period}>最悪応答時間#{sprintf("%.3f", t.wcrt)}"
      end
    end
    
  end

  # タスクのブロック時間を計算
  public
  def set_blocktime
    # 各タスクのブロック時間を計算
    #puts "set_blocktime"
    $calc_task.each{ |t| t.sb = SB(t) }
    $calc_task.each{ |t| t.ab = AB(t) }
    $calc_task.each{ |t| t.bb = BB(t) }
    $calc_task.each{ |t| t.lb = LB(t) }
    $calc_task.each{ |t| t.db = DB(t) }
    $calc_task.each{ |t| t.b = t.bb + t.ab + t.sb + t.lb + t.db }

    # 最悪応答時間の計算
    $calc_task.each{ |t| t.set_wcrt(wcrt(t)) }
  end
  
  # タスクのブロック時間を計算
  # @deprecated set_blocktimeと統合
  public
  def set_blocktime_spin_preemptive
    # 各タスクのブロック時間を計算
    #puts "set_blocktime"
    $calc_task.each{ |t| t.sb = SB(t) }
    $calc_task.each{ |t| t.ab = AB_preemptive(t) }
    $calc_task.each{ |t| t.bb = BB(t) }
    $calc_task.each{ |t| t.lb = LB(t) }
    $calc_task.each{ |t| t.db = DB(t) }
    $calc_task.each{ |t| t.b = t.bb + t.ab + t.sb + t.lb + t.db }

    # 最悪応答時間の計算
    $calc_task.each do |t|
      t.set_wcrt(wcrt(t))
    end
  end
  
  # 以下のフォーマットでブロック時間等表示
  # 120409用
  private
  def show_blocktime_120409
    $calc_task.each do |task|
      #RubyProf.start

      set_blocktime(task)
    
      #result = RubyProf.stop
      #printer = RubyProf::FlatPrinter.new(result)
      #printer.print(STDOUT)
    end

    #
    # CPU使用率を表示
    #
    
    uabj = PROC_NUM # utilization_available_to_background_jobs
    proc_list.each do |p|
      u = 0
      #      puts "#{partition(p).size}"
      p.task_list.each do |t|
        #puts "#{(t.get_extime+t.sb.to_f)/t.period}"
        u += (t.get_extime + t.b - t.lb)/t.period
      end
      #puts "CPU#{p}使用率:#{u}"
      uabj -= u
    end
    #puts "uabj:#{uabj}"
    return uabj
  end

  #
  # 以下のフォーマットでブロック時間等表示
  # 120409_2用
  #
  def show_blocktime_120409_2
    $calc_task.each do |task|
      set_blocktime(task)
    end
    
    #
    # CPU使用率を表示
    #
    
    uabj = PROC_NUM # utilization_available_to_background_jobs
    proc_list.each do |p|
      u = 0
      #      puts "#{partition(p).size}"
      p.task_list.each do |t|
        #puts "#{(t.get_extime+t.sb.to_f)/t.period}"
        u += (t.get_extime + t.b - t.lb)/t.period
      end
      #puts "CPU#{p}使用率:#{u}"
      uabj -= u
    end
    #puts "uabj:#{uabj}"
    return uabj
  end

  # 最悪応答時間
  private
  def wcrt(job)
    pre_wcrt = job.get_extime + job.b
    n = 1
    count = 0
    pre_array = [pre_wcrt]
    while(1)
      time = job.get_extime + job.b# - job.db
      job.proc.task_list.each do |t|
        if t.priority < job.priority && t.proc == job.proc
          count = ((pre_wcrt/t.period).ceil)
          time += count*(t.get_extime + t.sb)
        end
      end
      
      if time.round(2) == pre_wcrt.round(2) || n > 10
        break
      else
        pre_wcrt = time
        n += 1
      end
    end
    return time
  end
end
