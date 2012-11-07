#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= タスク，リソース，リソース要求クラス
#
#Author:: Takahiro FUJITANI (ERTL, Nagoya Univ.)
#Version:: 0.5.0
#License::
#

#
# タスククラス
#
class Task
  attr_accessor :req_list, :b, :bb, :ab, :sb, :lb, :db, :offset
  attr_reader :task_id, :all_require, :short_require_array, :long_require_array, :period, :reqtime, :wcrt, :proc, :priority
  
  def initialize(id, proc, period, extime, priority, offset, reqarray)
    @task_id = id.to_i
    if proc.class == Fixnum
      set_proc(ProcessorManager.get_proc(proc))
    else raise; end
    set_period(period)
    set_extime(extime) # CS時間も含めた時間
    @inflated_time = 0.0  # shortのspinにより増加した時間
    @priority = priority.to_i
    @offset = format('%.2f', offset).to_f
    set_reqlist(reqarray)
    @reqtime = get_require_time
    @wcrt = 0.0
    @b = 0.0
    @bb = 0.0
    @ab = 0.0
    @sb = 0.0
    @lb = 0.0
    @db = 0.0
    #check_outermost
    check_over_extime
    set_begin_time
    resetting
  end
  
  def resetting
    # all_requireを事前に求めておく
    @all_require = []
    
    @req_list.each do |req|
      @all_require << req
      if req.reqs != nil
        req.reqs.each do |req2|
          # 同じリソースのネストは不可能
          # req1.res == req2.res はダメ
          if req2.res == req.res
            #puts "req" + req.req_id.to_s + "とreq" + req2.req_id.to_s + ":\n"
            puts "同じリソース(res" + req.res.group.to_s + ")はネストできません．"
            raise
          end
          # グループが異なるときに別要求としてreq_listに追加
          # 同じグループならグループロックを1回取得するだけで良いから
          # 同グループなら別要求としては扱わない．
          if req2.res.group != req.res.group
            @all_require << req2
          end
        end
      end
    end

    # shortリソース要求の配列を返す
    # outermost なもののみ
    # ネストされているものも含む
    @short_require_array = []
    @all_require.each do |req|
      if req.res.kind == SHORT && req.outermost == true
        @short_require_array << req
      end
    end
    
    # longリソースの配列を返す
    # outermostなもののみ
    # ネストされているものも含む
    @long_require_array = []
    
    @all_require.each do |req|
      if req.res.kind == LONG && req.outermost == true
        @long_require_array << req
      end
    end
  end
  
  def get_resource_count
    @req_list.size
  end

  # タスクIDを設定する
  def set_taskid(id)
    @task_id = id
  end

  # 有効数字2桁で実行時間を代入
  def set_extime(extime)
    @extime = extime.to_f.round(2)
  end
  
  # inflateした実行時間を返す
  def get_extime
    return @extime+@inflated_time
  end

  # inflateしていない実行時間を返す
  def get_noninflate_time
    return @extime
  end
  
  # 有効数字2桁でinflated_timeを代入
  def set_inflated_time(inflated_time)
    @inflated_time = inflated_time.to_f.round(2)
  end

  # 有効数字2桁で実行時間を代入
  def set_period(period)
    @period = period.to_f.round(2)
  end

  # 有効数字2桁で実行時間を代入
  def set_wcrt(wcrt)
    @wcrt = wcrt.to_f.round(2)
  end

  # プロセッサを設定
  def set_proc(proc)
    begin 
      raise unless proc.class == Processor
      @proc = proc
    rescue
      @proc = nil
      #pp caller
    end
  end

  # 優先度設定
  def set_priority(priority)
    @priority = priority
  end

  # リソース要求設定
  def set_reqlist(reqarray)
    raise unless reqarray.class == Array
    @req_list = reqarray
  end
  
  # タスク使用率を返す
  def util
    return @extime/@period
  end
  #
  # outermostでない要求を探索して設定
  #
  def check_outermost
    req_list.each do |req|
      req.reqs.each do |req2|
        if req2.res.group == req.res.group
          req2.outermost = false
        end
      end
    end
  end
  
  #
  # 総リソース要求時間を計算
  #
  def get_require_time
    time = 0
    req_list.each{ |req| time += req.time }
    return time
  end

  # inflateした総spin時間を求める
  # DBで使用する
  def get_inflated_time
    time = 0
    @req_list.each do |req|
      if req.res.group == SHORT
        time += req.inflated_spintime
      end
    end
    
    return time
  end
  
  # リソース要求時間が
  # タスクの実行時間を超えていないかチェック
  def check_over_extime
    if @extime < @reqtime
      puts "タスク" + @task_id.to_s + "のリソース要求時間が実行時間を超えています．"
      raise
    end
  end
  
  # 最大応答時間がデッドラインを満たすかチェック
  # true: 満たす
  # false: 満たさない
  def check_schedulable
    return true if @period > @wcrt
    return false
  end
  
  #
  # タスクのデータを返す
  # JSON外部出力用
  # 
  def out_alldata
    req_list = []
    @req_list.each do |req| 
      req_list << req.req_id
    end
    return {
      "task_id"=>@task_id, 
      "proc"=>@proc.proc_id, 
      "period"=>@period, 
      "extime"=>@extime, 
      "priority"=>@priority,
      "offset"=>@offset,
      "req_id_list"=>req_list
    }
    #return [@task_id, @proc, @period, @extime, @priority, @offset, req_list]
  end
  
  # ブロック時間等リセット
  def reset_task
    @inflated_time = 0.0
    @reqtime = get_require_time
    @wcrt = 0.0
    @bb = 0.0
    @ab = 0.0
    @sb = 0.0
    @lb = 0.0
    @db = 0.0
    @b = 0.0
    @all_require.each{ |req| req.reset_require }
  end
  
  # デバッグ用
  def to_str
    puts "#{caller[0]}"
    puts "ID: #{task_id}"
    puts "extime: #{@extime}"
    puts "priority: #{@priority}"
    puts "period: #{@period}"
    puts "proc: #{proc.proc_id}"
    puts "wcrt: #{@wcrt}"
    puts "B: #{@b}"
    puts "Task<#{self.object_id}>"
    puts ""
  end
  #
  # 全てのグループロック要求の配列を取得
  # @req_listはネストしているものは含まれていない
  #
  #def get_all_require
  #  return @all_require 
  #end
  
  #
  # longリソースの配列を返す
  # outermostなもののみ
  # ネストされているものも含む
  #
  #def get_long_require_array_nest
  #  rlist = []
  #  @all_require.each{ |req|
  #    rlist << req if req.res.kind == LONG && req.outermost == true
  #  }
  #  return rlist
  #end

  #
  # longリソース要求の配列を返す
  # outermost なもののみ
  # ネストされているものは含まない
  #
  #def get_long_require_array
  #  return @long_require_array
  #end
  
  #
  # shortリソース要求の配列を返す
  # outermost なもののみ
  # ネストされているものもふくむ
  #
  def get_short_require_array_nest
    rlist = []
    @all_require.each do |req|
      rlist << req if req.res.kind == SHORT && req.outermost == true
    end
    return rlist
  end

  #
  # shortリソース要求の配列を返す
  # outermost なもののみ
  # ネストされているものは含まない
  #
  #def get_short_require_array
  #  return @short_require_array
  #end

  #
  # リソース要求のbegintimeを設定
  #
  private
  def set_begin_time
    
    # set_begintimeする必要があるかチェック
    @req_list.each do |req|
      return false if req.begintime != 0
    end
    
    req_time = 0
    @req_list.each do |req|
      req_time += req.time
    end
    
    # リソース要求A,B,Cがあるとして，要求時間が 10, 20, 30 とし，タスクの実行時間は 80 とする
    # リソース要求A, B, Cの間(この場合は4箇所)に余った 80-60 = 20 を適当に割り振る
    non_req_time = @extime - req_time
    
    # 初めはA, B, Cの開始時間を0(offset), 10, 30 として，適当に残りの時間を割り振る
    first_begin_time = offset
    @req_list.each do |req|
      #puts "first_begin_time:" + first_begin_time.to_s 
      req.begintime = first_begin_time
      first_begin_time += req.time
    end
    
    # A, B, Cの間にnon_req_timeを割り振る -> A, B, Cの開始時間を適当に遅らせる
    plus_time = 0
    @req_list.each do |req|
      #puts "non_req_time:" + non_req_time.to_s
      begin
      random = rand(non_req_time.to_i)
      rescue => e
        puts e
        puts "non_req_time:#{non_req_time} extime:#{extime} req_time:#{req_time}"
      end
      plus_time += non_req_time <= 0 ? 0 : random  # rand関数の引数が0だと0以下の浮動小数点数が返る
      #puts "plus_time:" + plus_time.to_s
      req.begintime += plus_time
      #puts "Req" + req.req_id.to_s + " beginTime:" + plus_time.to_s
      non_req_time -= random
      
      # ネストしている場合は，今のところreq.begintimeと同じ
      # ※2段ネストのみ対応
      nest_begin_time = req.begintime
      req.reqs.each do |nestreq|
        nestreq.begintime = nest_begin_time
        nest_begin_time += nestreq.time
      end
    end
    
    # おわり
    return true
  end
end

#
# リソース
# Resource(group)
#
class Resource
  attr_reader :res_id, :group
  def initialize(res_id, group)
    @res_id = res_id
    @group = group
  end
end

#
# リソースグループのクラス
#
class Group
  attr_accessor :group, :kind
  def initialize(group, kind)
    @group = group
    @kind = kind
  end
  
  #
  # グループのデータを返す
  # JSON外部出力用
  # 
  public
  def out_alldata
    return {
      "group"=>@group, 
      "kind"=>@kind
    }
  end
  
end

#
# リソース要求クラス
#
class Req
  attr_reader :outermost, :inflated_spintime, :res, :time
  attr_accessor :req_id, :nested, :reqs, :begintime

  def initialize(id, res, time, reqs, begintime=0, outermost=true)
    @req_id = id
    set_resource(res)
    @time = set_time(time)
    @begintime = begintime
    @reqs = reqs
    @outermost = outermost
    @inflated_spintime = 0.0     # sbr で計算されるSBによるspin時間．ABを計算する際に必要となる.
    @nested = false # ネスト"されている"場合 true
    
    # outermost のアクセス時間timeが最大でないといけない
    nesttime = 0
    @reqs.each do |req|
      nesttime += req.time
      
      # ネストしているリソース要求のnestedフラグをたてる
      req.nested = true unless req == []
      
      # ネストしているリソース要求のインスタンス変数に親リソース要求の参照を持たせる
      req.instance_variable_set(:@outer_req, self)
    end

    if @time < nesttime && @time != -1
      print "リソースネストエラー\n:ネストしているリソースアクセス時間がoutermost リソースのアクセスを超えています．\n"
      pp self
      raise
      #exit
    end
  end

  # spintimeを付加したリソース要求時間
  def get_time_inflated
    return @time + @inflated_spintime
  end

  # リソースsetter
  def set_resource(res)
    raise IllegalClass unless res.class == Group
    @res = res
  end

  # リソース要求時間setter
  # 有効数字2桁で実行時間を代入
  # @param: [Numeric] time リソース要求時間
  def set_time(time)
    @time = time.to_f.round(2)
  end
  
  #
  # Object.clone オーバーライド
  # ネストしているリソース要求の参照もcloneする
  #
  def clone
    newreqs = []
    @reqs.each { |r| newreqs << r.clone }
    Req.new(@req_id, @res, @time, newreqs)
  end
  
  #
  # リソース要求のデータを返す
  # JSON外部出力用
  # 
  def out_alldata
    reqss = []
    @reqs.each { |r| reqss << r.req_id }

    #p @begintime
    return {
      "req_id"=>@req_id, 
      "group"=>@res.group, 
      "time"=>@time, 
      "req_id_list"=>reqss, 
      "begintime"=>@begintime, 
      "outermost"=>outermost
    }
  end

  
  # sbrで計算したspin_block時間を加える
  def add_inflated_spintime(time)
    @inflated_spintime += time
    
    outer_req = instance_variable_get(:@outer_req)
    #outer_req.change_require_time(time) unless outer_req == nil
    outer_req.add_inflated_spintime(time) unless outer_req == nil

=begin
    # このリソース要求を行うタスクの実行時間も伸ばす
    # (ネストしていない場合のみ)
    if @nested == false
      loop_break = false
      ProcessorManager.proc_list.each do |proc|
        proc.task_list.each do |task|
          task.req_list.each do |req|
            if req.req_id == @req_id
              task.get_extime += time
              loop_break = true 
            
              puts ("T#{task.task_id}:R#{req.req_id}(G:#{req.res.group}) == R#{@req_id}")
              loop_break = true 
            end
          end
          break if loop_break == true
        end
        break if loop_break == true
      end
    end
=end
  end

  # リソース要求の時間を変更する
  def change_require_time(time)
    @time = time
  end

  # inflated_spintimeなどのリセット
  def reset_require
    @inflated_spintime = 0.0
  end
end

#
# タプルクラス
#
class ReqTuple
  attr_reader :req, :k
  def initialize(req, k)
    @req = req
    @k = k
  end
  
  public
  def to_str
    return "<G#{@req.res.group}(#{@req.get_time_inflated}), #{@k}>"
  end
end
