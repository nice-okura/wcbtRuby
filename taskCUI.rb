require "pp"
require "wcbt"
require "rubygems"
require "term/ansicolor"

class String
  include Term::ANSIColor
end

OFFSET_CHAR = " "
LONG_CHAR = "L".red
SHORT_CHAR = "S".blue
CALC_CHAR = "-"
# offset : " "
# long要求 : "L"
# short要求 : "S"
# ただの計算 : "-"


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
    "タスク" + @task.taskId.to_s + "(" + "%1.3f"%(@task.extime.to_f/@task.period.to_f) + ")" + ":"
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
      str += "["  # リソース要求区切り
      str += getReqtimeChar(req)  # リソース要求の分だけLONG or SHORTCHAR を表示
      str += "]"  # リソース要求区切り
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
    curTime = req.begintime
    str += "G" + req.res.group.to_s + ":"
    
    reqtime = req.time
    req.reqs.each{|subreq|
      rt = subreq.begintime - curTime
      rt.times{
        req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR 
      }
      reqtime -= rt
      str += "("
      str += getReqtimeChar(subreq)
      str += ")"
      reqtime -= subreq.time
    }
    reqtime.times{
      req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR 
    }
      
    
    
    
=begin
    subreqArray = req.reqs
    
    reqtime = req.time
    if subreqArray.size > 0 then
      # ネストしている場合
      i = 0
      while i < subreqArray.size 
        # i番目のネスト
        if curTime == subreqArray[i].begintime then
          p i
          str += "("
          str += getReqtimeChar(subreqArray[i])
          str += ")"
          curTime += subreqArray[i].time
          reqtime -= subreqArray[i].time
          i += 1
        else
          p "2"
          req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR 
          curTime += 1
          reqtime -= 1
        end
      end
      reqtime.times{
        req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR
      }
    else
      # ネストしていない場合
      reqtime.times{
        req.res.kind == "long" ? str += LONG_CHAR : str += SHORT_CHAR
      }
    end
=end
    str
  end
end