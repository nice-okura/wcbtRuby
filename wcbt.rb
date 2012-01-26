$taskList = []

class Task
  attr_reader :taskId, :proc, :period, :priority, :offset, :reqList
  def initialize(id, proc, period, priority, offset, reqarray)
    @taskId = id
    @proc = proc
    @period = period.to_i
    @priority = priority.to_i
    @offset = offset.to_i
    @reqList = reqarray
  end
  
  def resCount
    @reqList.size
  end
  
  def longResArray
    longResArray = []
    @reqList.each{|req|
      if req.res.kind == "long" then
        longResArray << req.res
      end
    }
    longResArray
  end
  def shortResArray
    shortResArray = []
    @reqList.each{|req|
      if req.res.kind == "short" then
        shortResArray << req.res
      end
    }
    shortResArray
  end
end

class Res
  attr_reader :resId, :kind, :group
  def initialize(id, kind, group)
    @resId = id
    @kind = kind
    @group = group
  end
end

class Req
  attr_reader :reqId, :res, :time
  def initialize(id, res, time)
    @reqId = id
    @res = res
    @time = time
  end
end

class ReqTuple
  attr_reader :req, :k
  def initialize(req, k)
    @req = req
    @k = k
  end
  
end

def wclx(task, job)
  tuples = []
  if task == nil || job == nil then 
    return []
  end
  k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
  1.upto(k){|n|
    task.reqList.each{|req|
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
    task.reqList.each{|req|
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
  job.longResArray.size
end

def bbt(task, job)
  len = 0
  tuples = wclx(task, job)
  #pp tuples
  #p tuples.size
  #p narr(job) + 1
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
      tuple = wcsx(task, job)
      if tuple != [] then
        tuples += tuple
      end
    end
  }
  tuples
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
  job.longResArray.each{|res|
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
  job.longResArray.each{|res|
    if res.group == group then 
      a += 1
    end
  }
  task.longResArray.each{|res|
    if res.group == group then
      b += 1
    end
  }
 [a, b].min
end

def procList
  proc = []
  $taskList.each{|task|
    proc << task.proc
  }
  proc.uniq!
end
  

def rbl(job)
  time = 0
  procList.each{|proc|
    if job.proc != proc then
      time += rblp(job, proc)
    end
  }
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

def BB(job)
  if job.longResArray.size == 0 then
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

