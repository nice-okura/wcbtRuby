require "pp"
require "wcbt"

OFFSET_CHAR = " "
LONG_CHAR = "L"
SHORT_CHAR = "S"
CALC_CHAR = "-"

class TaskSet 
  attr_accessor :taskList
  def initialize(taskList)
    @taskList = taskList
  end
  
  def procList
    proc = []
    @taskList.each{|task|
      proc << task.proc
    }
    proc.uniq!
  end
end

# offset : "_"
# long要求 : "L"
# short要求 : "S"
# ただの計算 : "-"
class TaskCUI
  def initialize(task)
    @task = task
  end
  
  def showTaskChar
    print getTaskName + getTaskChar + "\n"
  end
  
  def getTaskName
    "タスク" + @task.taskId.to_s + ":"
  end
  
  def getTaskChar
    str = ""
    curTime = 0
    
    str += getTaskOffsetChar
    str += "|"
    curTime += @task.offset
    
    @task.reqList.each{|req|
      calcTime = 0
      calcTime = req.begintime - curTime
      calcTime.times{
        str += CALC_CHAR
      }
      curTime += calcTime
      str += getReqtimeChar(req)
      curTime += req.time
    }
    p curTime
    (@task.extime - curTime).times{
      str += CALC_CHAR
    }
    str += "|"
    str
  end
  
  def getTaskOffsetChar
    str = ""
    @task.offset.times{
      str += OFFSET_CHAR
    }
    str
  end
  
  def getReqtimeChar(req)
    str = ""
    req.time.times{
        req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR 
    }
    str
  end
end