require "pp"

class Task
  attr_reader :id, :proc, :period, :period, :offset, :reqList
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
  
end
  
res1 = Res.new(1, "long")
res2 = Res.new(2, "long")

req1 = Req.new(1, res1, 2)
req2 = Req.new(2, res1, 1)
req3 = Req.new(3, res2, 4)
reqarray = [req1, req2]
tas1 = Task.new(1, 1, 10, 1, 0, reqarray)
reqarray = [req1, req3]
tas2 = Task.new(1, 1, 15, 2, 0, reqarray)

pp wclx(tas2, tas1)