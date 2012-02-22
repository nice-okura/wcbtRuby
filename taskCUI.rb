require "pp"
require "wcbt"

class TaskSet 
  attr_accessor :taskList

  def initialize(taskList)
    @taskList = taskList
    @taskSetProc = []    
    # プロセッサ順にソート
    @taskList.sort!{|a, b|
      a.proc <=> b.proc
    }
    
    # タスクを分類
    distributeTaskProc
    
    # 優先度順にソート
    @taskSetProc.each{|tasks|
      tasks.sort!{|a, b|
        a.priority <=> b.priority
      }
    }
  end
  
  def procList
    proc = []
    @taskList.each{|task|
      proc << task.proc
    }
    proc.uniq!
    return proc.sort!
  end
  
  # @taskSetProcにプロセッサでタスクを分類
  def distributeTaskProc
    procNum = 1
    taskArray = []
    #pp @taskSetProc
    @taskList.each{|task|
      if task.proc != procNum then
        procNum = task.proc
        @taskSetProc.push(taskArray)
        taskArray = []
      end
      taskArray << task
    }
    @taskSetProc.push(taskArray)
    #p @taskList.size
  end
  
  def showTaskSet
    procNum = 1
    @taskSetProc.each{|tasks|
      puts "[プロセッサ" + procNum.to_s + "]"
      #      p tasks.size
      tasks.each{|task|
        tc = TaskCUI.new(task)
        tc.showTaskChar
      }
      procNum += 1
    }
  end
end

OFFSET_CHAR = " "
LONG_CHAR = "L"
SHORT_CHAR = "S"
CALC_CHAR = "-"
# offset : " "
# long要求 : "L"
# short要求 : "S"
# ただの計算 : "-"
class TaskCUI
  def initialize(task)
    @task = task
  end

  # タスク表示
  def showTaskChar
    print getTaskName + getTaskChar + "\n"
  end
  
  # タスク名表示
  def getTaskName
    "タスク" + @task.taskId.to_s + ":"
  end
  
  def getTaskChar
    str = ""
    curTime = 0 # 現在時刻ポインタ設定
    
    # オフセット出力
    str += getTaskOffsetChar
    
    # タスク開始
    str += "|"
    curTime += @task.offset # 現在時刻を進める 
    
    # リソース要求
    @task.reqList.each{|req|
      calcTime = 0  # リソース要求以外の時間
      calcTime = req.begintime - curTime  # 現在時刻から次のリソース要求の時間までが計算時間
      # 計算時間の分だけCALC_CHARを表示
      
      calcTime.to_i.times{
        str += CALC_CHAR
      }

      curTime += calcTime # 現在時刻を進める
      str += getReqtimeChar(req)  # リソース要求の分だけLONG or SHORTCHAR を表示
      curTime += req.time
    }
    
    # 最後に計算時間が余っていれば表示
    (@task.extime + @task.offset - curTime).to_i.times{
      str += CALC_CHAR
    }
    str += "|"
    # タスク終了
    
    str
  end
  
  # オフセット表示
  def getTaskOffsetChar
    str = ""
    @task.offset.times{
      str += OFFSET_CHAR
    }
    str
  end
  
  # リソース要求 文字表示
  def getReqtimeChar(req)
    str = ""
    str += "["  # リソース要求区切り
    req.time.times{
        req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR 
    }
    str += "]"  # リソース要求区切り
    str
  end
end