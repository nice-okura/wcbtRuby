#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= タスク，リソース，リソース要求クラス(FMLP_EDF)
#
#Author:: Takahiro FUJITANI (ERTL, Nagoya Univ.)
#Version:: 0.1.0
#License::
#

#
# プロセッサクラス
#
class Proc
  attr_accessor :task_list
end

#
# タスククラス
#
class Task
  attr_accessor :task_id, :proc, :period, :extime, :priority, :offset, :req_list, :reqtime, :bw, :npb, :db, :b, :wcrt
  def initialize(id, proc, period, extime, priority, offset, reqarray)
    @task_id = id
    @proc = proc
    @period = period.to_f
    @extime = extime
    @priority = priority.to_i
    @offset = offset.to_i
    @req_list = reqarray
    @reqtime = get_require_time
    @wcrt = 0
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
    
    if NEST_FLG == TRUE
      
      req_list.each{|req|
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
    else
      @all_require = @req_list
    end
    #
    # shortリソース要求の配列を返す
    # outermost なもののみ
    # ネストされているものもふくむ
    #
    @short_require_array = []
    get_all_require.each{|req|
      if req.res.kind == "short" && req.outermost == true then
        @short_require_array << req
      end
    }
    
    #
    # longリソースの配列を返す
    # outermostなもののみ
    # ネストされているものも含む
    #
    @long_require_array = []
    
    get_all_require.each{|req|
      if req.res.kind == "long" && req.outermost == true then
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
        if req2.res.group == req.res.group then
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
    
    if @extime < time then
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
  def get_long_require_array
    return @long_require_array
  end
  
  #
  # shortリソース要求の配列を返す
  # outermost なもののみ
  # ネストされているものもふくむ
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
