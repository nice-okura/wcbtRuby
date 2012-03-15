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
  attr_accessor :task_id, :proc, :period, :extime, :priority, :offset, :req_list
  def initialize(id, proc, period, extime, priority, offset, reqarray)
    @task_id = id
    @proc = proc
    @period = period.to_i
    @extime = extime
    @priority = priority.to_i
    @offset = offset.to_i
    @req_list = reqarray
    check_outermost
    check_over_extime
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
  # リソース要求時間が
  # タスクの実行時間を超えていないかチェック
  #
  def check_over_extime
    time = 0
    req_list.each{|req|
      time += req.time
    }
    
    if @extime < time then
      puts "タスク" + @task_id.to_s + "のリソース要求時間が実行時間を超えています．"
      exit
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
    all_require = []
    req_list.each{|req|
      all_require << req 
      if req.reqs != nil then
        req.reqs.each{|req2|
          # 同じリソースのネストは不可能
          # req1.res == req2.res はダメ
          if req2.res == req.res then 
            puts "req" + req.req_id.to_s + "とreq" + req2.req_id.to_s + ":\n"
            puts "同じリソース(res" + req.res.group.to_s + ")はネストできません．"
            exit # 強制終了
          end
          # グループが異なるときに別要求としてreq_listに追加
          # 同じグループならグループロックを1回取得するだけで良いから
          # 同グループなら別要求としては扱わない．
          if req2.res.group != req.res.group then
            all_require << req2
          end
        }
      end
    }
    return all_require
  end
  
  #
  # longリソースの配列を返す
  # outermostなもののみ
  #
  def get_long_resource_array
    long_resource_array = []
    get_all_require.each{|req|
      if req.res.kind == "long" && req.outermost == true then
        long_resource_array << req.res
      end
    }
    return long_resource_array
  end
  
  #
  # shortリソースの配列を返す
  # outermost なもののみ
  #
  def get_short_resource_array
    short_resource_array = []
    get_all_require.each{|req|
      if req.res.kind == "short" && req.outermost == true then
        short_resource_array << req.res
=begin
         req.reqs.each{|req2|
         if req2.res.group != req.res.group then
         get_short_resource_array << req2.res
         end
         }
=end
      end
    }
    return short_resource_array
  end
  
  def set_begin_time
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
      random = rand(non_req_time)
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
  attr_accessor :req_id, :res, :time, :begintime, :reqs, :outermost
  def initialize(id, res, time, reqs, begintime=0, outermost=true)
    @req_id = id
    @res = res
    @time = time
    @begintime = begintime
    @reqs = reqs  #リソースID
    @outermost = outermost
    
    # outermost のアクセス時間timeが最大でないといけない
    nesttime = 0
    reqs.each{|req|
      nesttime += req.time
    }
    if @time < nesttime then
      print "リソースネストエラー\n:ネストしているリソースアクセス時間がoutermost リソースのアクセスを超えています．\n"
      exit
    end
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
    p @begintime
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
end