class Task
  attr_accessor :taskId, :proc, :period, :extime, :priority, :offset, :reqList
  def initialize(id, proc, period, extime, priority, offset, reqarray)
    @taskId = id
    @proc = proc
    @period = period.to_i
    @extime = extime
    @priority = priority.to_i
    @offset = offset.to_i
    @reqList = reqarray
    checkOutermost
    checkOverExTime
  end
  
  def getResCount
    @reqList.size
  end
  
  #
  # outermostでない要求を探索して設定
  #
  def checkOutermost
    reqList.each{|req|
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
  def checkOverExTime
    time = 0
    reqList.each{|req|
      time += req.time
    }
    
    if @extime < time then
      puts "タスク" + @taskId.to_s + "のリソース要求時間が実行時間を超えています．"
      exit
    end
  end
  
  #
  # タスクのデータを返す
  # JSON外部出力用
  # 
  def out_alldata
    reqlist = []
    @reqList.each{|req|
      reqlist << req.req_id
    }
    return {
      "task_id"=>@taskId, 
      "proc"=>@proc, 
      "period"=>@period, 
      "extime"=>@extime, 
      "priority"=>@priority,
      "offset"=>@offset,
      "req_id_list"=>reqlist
    }
    #return [@taskId, @proc, @period, @extime, @priority, @offset, reqlist]
  end
  
  #
  # 全てのグループロック要求の配列を取得
  # @reqListはネストしているものは含まれていない
  #
  def getAllReq
    allReq = []
    reqList.each{|req|
      allReq << req 
      if req.reqs != nil then
        req.reqs.each{|req2|
          # 同じリソースのネストは不可能
          # req1.res == req2.res はダメ
          if req2.res == req.res then 
            puts "req" + req.req_id.to_s + "とreq" + req2.req_id.to_s + ":\n"
            puts "同じリソース(res" + req.res.group.to_s + ")はネストできません．"
            exit # 強制終了
          end
          # グループが異なるときに別要求としてreqListに追加
          # 同じグループならグループロックを1回取得するだけで良いから
          # 同グループなら別要求としては扱わない．
          if req2.res.group != req.res.group then
            allReq << req2
          end
        }
      end
    }
    allReq
  end
  
  #
  # longリソースの配列を返す
  # outermostなもののみ
  #
  def getLongResArray
    longResArray = []
    getAllReq.each{|req|
      if req.res.kind == "long" && req.outermost == true then
        longResArray << req.res
      end
    }
    longResArray
  end

  #
  # shortリソースの配列を返す
  # outermost なもののみ
  #

  def getShortResArray
    shortResArray = []
    getAllReq.each{|req|
      if req.res.kind == "short" && req.outermost == true then
        shortResArray << req.res
=begin
        req.reqs.each{|req2|
          if req2.res.group != req.res.group then
            getShortResArray << req2.res
          end
        }
=end
      end
    }
    shortResArray
  end
  
  def setBeginTime
    reqTime = 0
    reqList.each{|req|
      reqTime += req.time
    }
    #
    # リソース要求A,B,Cがあるとして，要求時間が 10, 20, 30 とし，タスクの実行時間は 80 とする
    # リソース要求A, B, Cの間(この場合は4箇所)に余った 80-60 = 20 を適当に割り振る
    #
    nonReqTime = extime - reqTime
    #puts "nonReqTime:" + nonReqTime.to_s
    
    #
    # 初めはA, B, Cの開始時間を0(offset), 10, 30 として，適当に残りの時間を割り振る
    #
    firstBeginTime = offset
    reqList.each{|req|
      #puts "firstBeginTime:" + firstBeginTime.to_s 
      req.begintime = firstBeginTime
      firstBeginTime += req.time
    }
    
    #
    # A, B, Cの間にnonReqTimeを割り振る -> A, B, Cの開始時間を適当に遅らせる
    #
    plusTime = 0
    reqList.each{|req|
      #puts "nonReqTime:" + nonReqTime.to_s
      random = rand(nonReqTime)
      plusTime += nonReqTime <= 0 ? 0 : random  # rand関数の引数が0だと0以下の浮動小数点数が返る
      #puts "plusTime:" + plusTime.to_s
      req.begintime += plusTime
      #puts "Req" + req.req_id.to_s + " beginTime:" + plusTime.to_s
      nonReqTime -= random
      
      #
      # ネストしている場合は，今のところreq.begintimeと同じ
      # ※2段ネストのみ対応
      #
      nestBeginTime = req.begintime
      req.reqs.each{|nestreq|
        nestreq.begintime = nestBeginTime
        nestBeginTime += nestreq.time
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
  attr_accessor :resId, :group
  def initialize(resId, group)
    @resId = resId
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

class ReqTuple
  attr_reader :req, :k
  def initialize(req, k)
    @req = req
    @k = k
  end
  
end

##############################
def WCLR(task)
  reqs = []
  task.reqList.each{|req|
    if req.outermost == true && req.res.kind == "long" then
      reqs << req
    end
  }
  reqs
end

def WCSR(task)
  reqs = []
  task.reqList.each{|req|
    if req.outermost == true && req.res.kind == "short" then
      reqs << req
    end
  }
  reqs
end

def LR(job)
  lr = []
  job.getAllReq.each{|req|
    if req.res.kind == "long" && req.outermost == true then
      lr << req
    end
  }
  lr
end

def SR(job)
  sr = []
  job.getAllReq.each{|req|
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
    puts "タスク" + task.taskId.to_s + "の周期:" + task.period.to_f.to_s
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
  tuples
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
  job.getLongResArray.size
end

def partition(proc)
  procTaskList = []
  $taskList.each{|task|
    if task.proc == proc then
      procTaskList << task
    end
  }
  procTaskList
end

def procList
  proc = []
  $taskList.each{|task|
    proc << task.proc
  }
  proc = proc.sort
  proc = proc.uniq
  proc
end

##############################

def bbt(task, job)
  if task == job then
    return 0
  end
  len = 0
  tuples = wclx(task, job)
  min = [tuples.size, narr(job) + 1].min
  0.upto(min-1){|num|
    len += tuples[num].req.time
  }
  len
end

def abr(job)
  if job == nil then 
    return []
  end
  tuples = []
  $taskList.each{|task|
    if task.proc == job.proc && task.priority > job.priority then
      #pp task
      tuple = wcsx(task, job)
      if tuple != [] then
        tuples += tuple
      end
    end
  }
  #  pp tuples
  tuples
end


def ndbp(job, proc)
  if job.proc == proc then
    return 0
  end
  count = 0
  partition(proc).each{|task|
    count += ndbt(task, job)
  }
  count
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
  count
end

def ndbtg(task, job, group)
  a = b = 0
  #  pp job.getLongResArray.size
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
 [a, b].min
end

def rbl(job)
  time = 0
  # p procList
  procList.each{|proc|
    if job.proc != proc then
      time += rblp(job, proc)
    end
  }
  time 
end

def rblp(job, proc)
  count = 0
  partition(proc).each{|task|
    count += rblt(task, job)
  }
  count
end

def rblt(task, job)
  time = 0
  if task == nil || job == nil then
    return 0
  elsif task.proc  == job.proc then 
    return 0
  end
  tuples = wclx(task, job)
  min = [ndbp(job, task.proc), tuples.size].min
  0.upto(min-1){|num|
    time += tuples[num].req.time
  }
  time
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
  time
end

def rbsp(job, proc)
  time = 0
  if job == nil then
    return 0
  end
  tuples = wcsp(job, proc)
  min = [ndbp(job, proc), wcsp(job, proc).size].min
  0.upto(min-1){|num|
    time += tuples[num].req.time
  }
  time
end


def wcsxg(task, job, group)
  tuples = []
  if task == nil || job == nil then 
    return []
  end
  begin
    k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
    rescue
    puts "タスク" + task.taskId.to_s + "の周期:" + task.period.to_f.to_s
    exit
  end
  1.upto(k){|n|
    task.reqList.each{|req|
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
  time = []
  partition(proc).each{|task|
    time += wcsxg(task, job, group)
  }
  time
end

def sbg(job, group)
  time = 0
  # p procList
  procList.each{|proc|
    if job.proc != proc then
      time += sbgp(job, group, proc)
    end
  }
  time
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
  time
end


def lbt(task)
  LB(task)
end
##############################

def BB(job)
  if job.getLongResArray.size == 0 then
    return 0
  end
  time = 0
  $taskList.each{|tas|
    if tas.proc == job.proc && tas.priority > job.priority then
      time += bbt(tas, job)
    end
  }
  time
end

def AB(job)
  if job == nil then
    return 0
  end
  time = 0
  tuples = abr(job)
  min = [tuples.size, narr(job) + 1].min
  0.upto(min-1){|num|
    time += tuples[num].req.time
  }
  time
end

def LB(job)
  if job == nil then
    return 0
  end
  return rbl(job) + rbs(job)
end

def SB(job)
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
