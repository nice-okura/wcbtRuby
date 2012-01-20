require "pp"
require "info"

def taskset1
  res1 = Res.new(1, "long")
  res2 = Res.new(2, "long")
  res3 = Res.new(3, "long")

  req1 = Req.new(1, res3, 1)
  req2 = Req.new(2, res1, 2)
  req3 = Req.new(3, res2, 2)
  tas1 = Task.new(1, 1, 12, 1, 0, [req1])
  $taskList << tas1
  tas2 = Task.new(2, 1, 12, 2, 0, [req2])
  $taskList << tas2
  tas3 = Task.new(3, 1, 12, 3, 0, [req3])
  $taskList << tas3
end

def taskset2
  res1 = Res.new(1, "long")
  
  req1 = Req.new(1, res1, 1)
  req2 = Req.new(2, res1, 2)
  req3 = Req.new(3, res1, 2)
  
  tas1 = Task.new(1, 1, 10, 1, 0, [req1])
  tas2 = Task.new(2, 1, 10, 2, 0, [req2])
  tas3 = Task.new(3, 2, 10, 3, 0, [req3])
  $taskList = [tas1, tas2, tas3]
  pp BB(tas1)
  pp BB(tas2)
end

taskset2