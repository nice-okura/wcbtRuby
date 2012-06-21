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
# プロセッサクラス
#
class Processor
  # プロセッサに割り当てられているタスクのリスト
  attr_reader :task_list
  attr_reader :util, :proc_id
  
  # コンストラクタ
  def initialize(attr)
    @task_list = []

    @util = 0.0
    id = attr[PROC_ID_SYN] # IDは1から始まる
    if id == nil || id == 0
      raise "プロセッサIDが不正です．"
    end
    @proc_id = id
    puts "プロセッサ#{@proc_id}作成"

    unless attr[TASK_LIST_SYN] == nil
      tlist = TaskManager.get_tasks(attr[TASK_LIST_SYN])
      tlist.each{ |t|
        #pp t
        assign_task(t)
      }
    end


  end
  
  ###############################################################
  #
  # 以下 public
  #
  ###############################################################
  public 
  # プロセッサにタスク割り当て
  # @param [Task] 割当てるタスク
  # @return 成功したらtrue
  def assign_task(task)
    if @proc_id == nil || @proc_id == 0
      raise "プロセッサIDが不正です．"
    elsif task == nil
      raise "taskがnilです.(Processor::assign_task)" if task == nil
    end
    @task_list << task

    # プロセッサ番号設定
#    p @proc_id
    task.proc = @proc_id
    # 優先度設定
    task.priority = @task_list.size

    # プロセッサ使用率計算
    @util = calc_util
    return true
  end

  # プロセッサ内のタスクのソート
  def sort_tasks(mode)
    case mode
    when SORT_PRIORITY
      sort_by_task_pri
    when SORT_ID
      sort_by_task_id
    when SORT_UTIL
      sort_by_task_util
    else 
      # ソートしない
    end
  end

  # プロセッサのデータを返す
  # JSON外部出力用
  def out_alldata
    tsk_list = []
    @task_list.each{|t|
      tsk_list << t.task_id
    }
    return {
      PROC_ID_SYN => @proc_id, 
      TASK_LIST_SYN => tsk_list
    }
    #return [@task_id, @proc, @period, @extime, @priority, @offset, req_list]
  end

  # プロセッサに割り当てられているタスクを削除
  def remove_task
    @task_list = []
  end
  ###############################################################
  #
  # 以下 private
  #
  ###############################################################
  # プロセッサ使用率を計算
  # @return [Float] プロセッサ使用率
  private
  def calc_util
    util = 0.0
    @task_list.each{ |t|
      util += t.extime/t.period
    }

    return util
  end

  # タスクをIDの降順で並べる
  def sort_by_task_id
    @task_list.sort!{ |a, b|
      a.task_id <=> b.task_id
    }
  end
  
  # タスク使用率の降順で並べる
  def sort_by_task_util
    @task_list.sort!{ |a, b|
      a.extime/a.period <=> b.extime/b.period
    }
  end

  # タスク優先度の降順で並べる
  def sort_by_task_pri
    @task_list.sort!{ |a, b|
      a.priority <=> b.priority
    }
  end
  
end

#
# タスククラス
#
class Task
  attr_accessor :task_id, :proc, :period, :extime, :priority, :offset, :req_list, :reqtime, :bb, :ab, :sb, :lb, :db, :b, :wcrt
  def initialize(id, proc, period, extime, priority, offset, reqarray)
    @task_id = id.to_i
    @proc = proc
    @period = period.to_f
    @extime = extime
    @priority = priority.to_i
    @offset = offset.to_i
    @req_list = reqarray
    @reqtime = get_require_time
    @wcrt = 0
    @b = 0.0
    @bb = 0.0
    @ab = 0.0
    @sb = 0.0
    @lb = 0.0
    @db = 0.0
    check_outermost
    check_over_extime
    set_begin_time
    resetting
  end
  
  def resetting
    #
    # all_requireを事前に求めておく
    #
    @all_require = []
    
    @req_list.each{|req|
      @all_require << req
      if req.reqs != nil
        req.reqs.each{|req2|
          # 同じリソースのネストは不可能
          # req1.res == req2.res はダメ
          #if req2.res == req.res then 
          #puts "req" + req.req_id.to_s + "とreq" + req2.req_id.to_s + ":\n"
          #puts "同じリソース(res" + req.res.group.to_s + ")はネストできません．"
          #exit # 強制終了
          #end
          # グループが異なるときに別要求としてreq_listに追加
          # 同じグループならグループロックを1回取得するだけで良いから
          # 同グループなら別要求としては扱わない．
          if req2.res.group != req.res.group
            @all_require << req2
          end
        }
      end
    }

    #
    # shortリソース要求の配列を返す
    # outermost なもののみ
    # ネストされているものは含まない
    #
    @short_require_array = []
    @req_list.each{|req|
      if req.res.kind == SHORT && req.outermost == true
        @short_require_array << req
      end
    }
    
    #
    # longリソースの配列を返す
    # outermostなもののみ
    # ネストされているものは含まない
    #
    @long_require_array = []
    
    @req_list.each{|req|
      if req.res.kind == LONG && req.outermost == true
        @long_require_array << req
      end
    }
  end
  
  def get_resource_count
    @req_list.size
  end
  
  #
  # outermostでない要求を探索して設定
  #
  def check_outermost
    req_list.each{|req|
      req.reqs.each{|req2|
        if req2.res.group == req.res.group
          req2.outermost = false
        end
      }
    }
  end
  
  #
  # 総リソース要求時間を計算
  #
  def get_require_time
    time = 0
    req_list.each{|req|
      time += req.time
    }
    return time
  end
  
  #
  # リソース要求時間が
  # タスクの実行時間を超えていないかチェック
  #
  def check_over_extime
    time = @reqtime
    
    if @extime < time
      #puts "タスク" + @task_id.to_s + "のリソース要求時間が実行時間を超えています．"
      #exit
    end
  end
  
  #
  # タスクのデータを返す
  # JSON外部出力用
  # 
  def out_alldata
    req_list = []
    @req_list.each{|req|
      req_list << req.req_id
    }
    return {
      "task_id"=>@task_id, 
      "proc"=>@proc, 
      "period"=>@period, 
      "extime"=>@extime, 
      "priority"=>@priority,
      "offset"=>@offset,
      "req_id_list"=>req_list
    }
    #return [@task_id, @proc, @period, @extime, @priority, @offset, req_list]
  end
  
  #
  # 全てのグループロック要求の配列を取得
  # @req_listはネストしているものは含まれていない
  #
  def get_all_require
    return @all_require 
  end
  
  #
  # longリソースの配列を返す
  # outermostなもののみ
  # ネストされているものも含む
  #
  def get_long_require_array_nest
    rlist = []
    @all_require.each{ |req|
      rlist << req if req.res.kind == LONG && req.outermost == true
    }
    return rlist
  end

  #
  # longリソース要求の配列を返す
  # outermost なもののみ
  # ネストされているものは含まない
  #
  def get_long_require_array
    return @long_require_array
  end
  
  #
  # shortリソース要求の配列を返す
  # outermost なもののみ
  # ネストされているものもふくむ
  #
  def get_short_require_array_nest
    rlist = []
    @all_require.each{ |req|
      rlist << req if req.res.kind == SHORT && req.outermost == true
    }
    return rlist
  end

  #
  # shortリソース要求の配列を返す
  # outermost なもののみ
  # ネストされているものは含まない
  #
  def get_short_require_array
    return @short_require_array
  end

  #
  # リソース要求のbegintimeを設定
  #
  private
  def set_begin_time
    #
    # set_begintimeする必要があるかチェック
    #
    req_list.each{|req|
      if req.begintime != 0
        return false
      end
    }
    
    req_time = 0
    req_list.each{|req|
      req_time += req.time
    }
    #
    # リソース要求A,B,Cがあるとして，要求時間が 10, 20, 30 とし，タスクの実行時間は 80 とする
    # リソース要求A, B, Cの間(この場合は4箇所)に余った 80-60 = 20 を適当に割り振る
    #
    non_req_time = extime - req_time
    #puts "non_req_time:" + non_req_time.to_s
    
    #
    # 初めはA, B, Cの開始時間を0(offset), 10, 30 として，適当に残りの時間を割り振る
    #
    first_begin_time = offset
    req_list.each{|req|
      #puts "first_begin_time:" + first_begin_time.to_s 
      req.begintime = first_begin_time
      first_begin_time += req.time
    }
    
    #
    # A, B, Cの間にnon_req_timeを割り振る -> A, B, Cの開始時間を適当に遅らせる
    #
    plus_time = 0
    req_list.each{|req|
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
      
      #
      # ネストしている場合は，今のところreq.begintimeと同じ
      # ※2段ネストのみ対応
      #
      nest_begin_time = req.begintime
      req.reqs.each{|nestreq|
        nestreq.begintime = nest_begin_time
        nest_begin_time += nestreq.time
      }
    }
    # おわり
    return true
  end
end

#
# リソース
# Resource(group)
#
class Resource
  attr_accessor :res_id, :group
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
  attr_accessor :req_id, :res, :time, :begintime, :reqs, :outermost, :nested
  def initialize(id, res, time, reqs, begintime=0, outermost=true)
    @req_id = id
    @res = res
    @time = time
    @begintime = begintime
    @reqs = reqs
    @outermost = outermost
    @nested = false # ネスト"されている"場合 true
    
    # outermost のアクセス時間timeが最大でないといけない
    nesttime = 0
    reqs.each{|req|
      nesttime += req.time
    }
    if @time < nesttime then
      # print "リソースネストエラー\n:ネストしているリソースアクセス時間がoutermost リソースのアクセスを超えています．\n"
      #exit
    end
    reqs.each{|r|
      r.nested unless r == []
    }
  end
  
  #
  # Object.clone オーバーライド
  #
  def clone
    newreqs = []
    @reqs.each{|r|
      newreqs << r.clone
    }
    Req.new(@req_id, @res, @time, newreqs)
  end
  
  #
  # リソース要求のデータを返す
  # JSON外部出力用
  # 
  def out_alldata
    reqss = []
    @reqs.each{|r|
      reqss << r.req_id
    }
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
  def prints
    return "<#{@req.req_id}(#{@req.time}), #{@k}>"
  end
end
