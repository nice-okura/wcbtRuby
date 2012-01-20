$taskList = []

class Task
  attr_reader :id, :proc, :period, :priority, :offset, :reqList
  def initialize(id, proc, period, priority, offset, reqarray)
    @id = id
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
end

class Res
  attr_reader :id, :kind
  def initialize(id, kind)
    @id = id
    @kind = kind
  end
end

class Req
  attr_reader :id, :res, :time
  def initialize(id, res, time)
    @id = id
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
  k = (job.period.to_f/task.period.to_f).ceil.to_i + 1
  1.upto(k){|n|
    task.reqList.each{|req|
      tuples << ReqTuple.new(req, n)
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

def BB(job)
  bb = 0
  $taskList.each{|tas|
    if tas.proc == job.proc && tas.priority > job.priority then
      bb += bbt(tas, job)
    end
  }
  bb
end
