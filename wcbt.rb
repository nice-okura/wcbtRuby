$taskList = []

class Task
  attr_accessor :taskId, :proc, :period, :priority, :offset, :reqList
  def initialize(id, proc, period, priority, offset, reqarray)
    @taskId = id
    @proc = proc
    @period = period.to_i
    @priority = priority.to_i
    @offset = offset.to_i
    @reqList = reqarray
    checkOutermost
  end
  
  def getResCount
    @reqList.size
  end
  
  # outermostでない要求を探索して設定
  def checkOutermost
    reqList.each{|req|
      req.reqs.each{|req2|
        if req2.res.group == req.res.group then
          req2.outermost = false
        end
      }
    }
  end
  
  # 全てのグループロック要求の配列を取得
  # @reqListはネストしているものは含まれていない
  def getAllReq
    allReq = []
    reqList.each{|req|
      allReq << req 
      if req.reqs != nil then
        req.reqs.each{|req2|
          # 同じリソースのネストは不可能
          # req1.res == req2.res はダメ
          if req2.res == req.res then 
            puts "req" + req.reqId.to_s + "とreq" + req2.reqId.to_s + ":\n"
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
  
  def getLongResArray
    longResArray = []
    getAllReq.each{|req|
      if req.res.kind == "long" && req.outermost == true then
        longResArray << req.res
      end
    }
    longResArray
  end
  
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
end

# リソースではなくて，リソースグループのクラス
class Group
  attr_accessor :group, :kind
  def initialize(group, kind)
    @group = group
    @kind = kind
  end
end

class Req
  attr_accessor :reqId, :res, :time, :reqs, :outermost
  def initialize(id, res, time, reqs)
    @reqId = id
    @res = res
    @time = time
    @reqs = reqs
    @outermost = true
    
    # outermostのアクセス時間timeが最大でないといけない
    nesttime = 0
    reqs.each{|req|
      nesttime += req.time
    }
    if @time < nesttime then
      print "リソースネストエラー\n:ネストしているリソースアクセス時間がoutermostリソースのアクセスを超えています．\n"
      exit
    end
    
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

def wclx(task, job)
  tuples = []
  if task == nil || job == nil then 
    return []
  end
  k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
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
  proc.uniq!
end

##############################

def bbt(task, job)
  if task == job then
    return 0
  end
  len = 0
  tuples = wclx(task, job)
#  pp tuples
#  p tuples.size
#  p narr(job) + 1
  min = [tuples.size, narr(job) + 1].min
  #p min
  0.upto(min-1){|num|
    #pp tuples[num].req
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
  job.getLongResArray.each{|res|
    g << res.group
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
  job.getLongResArray.each{|res|
    if res.group == group then 
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
    tuples << wcsx(task, job)
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
  tuples = wcsx(job, proc)
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
  k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
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
  time = 0
  partition(proc).each{|task|
    time += wcsxg(task, job, group)
  }
  time
end

def sbg(job, group)
  time = 0
  #  procList.each{|proc|
end 

def sbgp(job, group, proc)
  time = 0
  b = 0
  job.getShortResArray.each{|req|
    if req.res.group == group then
      b += req.time
    end
  }
  tuples = wcspg(job, proc, group)
  min = [b, tuples.size].min
  0.upto(min-1){|num|
    time += tuples[num].req.time
  }
  time
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

