require "wcbt"
require "pp"
require "singleton"
require "config"

# ランダム生成方針
# Task(taskId, proc, period, extime, priority, offset, reqList)
#  taskId: タスク生成順にインクリメント
#  proc: 完全ランダム
#  period: extime以下でランダム
#  extime: reqListの総時間以上で乱数
#  priority: 完全ランダム
#  offset: period以下でランダム
#  reqList: createReqListで生成

# Group(group, kind)
#  group: 生成順にインクリメント
#  kind: 交互

# Require(reqId, group, time, reqs)
#  reqId: 生成順にインクリメント
#  group: ランダムに選択
#  time: (ある限度までで)ランダムに選択->20~50
#  reqs: groupとは異なるグループのリソースを選択

class List
  # @cdrは「値」
  # @carは「次の要素へのラベル」
  def initialize(i)
    @cdr = nil
    @car = nil
    @index = i
  end
  attr_accessor :cdr, :car, :index

  def addTail(x)
    a = self
    a = a.car until a.car.nil?
    a.car = List.new(a.size)
    a.car.cdr = x
  end

  def getAt(index)
    a = self
  end

  def size
    a = self
    i = 0
    i += 1 while a = a.car
    return i
  end

  def each
    a = self.car
    self.size.times do
      yield a.cdr
      a = a.car
    end
  end

  def getRandom
    rand(self.size)
  end    
end

class TaskManager
  include Singleton
  
  def initialize
    @@taskId = 0
    @@taskArray = []
  end
  
  private
  def createTask
    # リソース要求
    # 最大REQ_NUM回リソースを取得
    reqList = []
    REQ_NUM.times{
      if rand(2) == 1 then
        reqList += [RequireManager.getRandomReq]
      end
    }
    #reqList.uniq!
    
    reqTime = 0
    #pp reqList
    reqList.each{|req|
      reqTime += req.time
    }
    #################
    # タスクステータス #
    #################
    
    @@taskId += 1
    proc = rand(PROC_NUM) + 1
    priority = rand(PRIORITY_MAX) + 1
    extime = reqTime + rand(TASK_EXE_MAX - reqTime)
    period = extime/(rand % (1/TASK_NUM.to_f)) # 1つのCPUに全てのタスクが割り当てられても，CPU使用率が1を超えないタスク使用率にする
    offset = rand(10)

    #################
    
    task = Task.new(@@taskId, proc, period, extime, priority, offset, reqList)
    task.setBeginTime
    return task
  end
  
  public
  def createTaskArray(i)
    tarray = []
    i.times{
      tarray << createTask
    }
    @@taskArray = tarray
  end
end

class GroupManager
  include Singleton

  def initialize
    @@groupId = 0
    @@kind = "long"
    @@groupArray = []
  end

  # グループを生成する
  def createGroup
    @@groupId += 1
    group = Group.new(@@groupId, @@kind)
    #@@kind = "short"
    @@kind = @@kind == "long" ? "short" : "long"
    
    group
  end
  
  # i個のグループを生成し，groupArrayとする
  def createGroupArray(i)
    garray = []
    i.times{
      garray << createGroup
    }
    @@groupArray = garray
  end
  
  def getCount
    @@groupId
  end
  
  # グループをランダムに返す
  def self.getRandomGroup
    if @@groupArray.size == 0 then
      puts "グループが生成されていません．"
      exit
    end
    @@groupArray[rand(@@groupArray.size)]
  end
end

class RequireManager
  include Singleton

  def initialize
    @@id = 0
    @@reqArray = []
  end
  
  private
  def createRequire
    @@id += 1
    group = GroupManager.getRandomGroup
    #pp group
    time = REQ_EXE_MIN + rand(REQ_EXE_MAX - REQ_EXE_MIN)
    req = []
    r = RequireManager.getRandomReq
    if r != [] && r.reqs.size == 0 && !(group.kind == "short" && r.res.kind == "long")then
      # ※2段ネストまで対応
      if r.res != group && time > r.time
        # p r.object_id
        req << r.clone
      end
    end
    Req.new(@@id, group, time, req)
  end
  
  def getReqArray
    @@reqArray
  end
  
  def self.getRandomReq
    if @@reqArray.size <= 1 then
      # puts "要求が生成されていません．"
      []
    else
      req = @@reqArray[rand(@@reqArray.size)]
      return req.clone
    end
  end
  
  public
  def createRequireArray(i)
    reqArray = []
    i.times{
      @@reqArray << createRequire
    }
  end
end

# 使用方法 
# グループ，要求，タスクのマネージャーインスタンスを作成
# gm = GroupManager.instance
# rm = RequireManager.instance
# tm = TaskManager.instance
puts "ランダムタスク"
# 
# グループをランダムに5個作成
# gm.createGroupArray(5)
#
# それらのグループから要求から5つの要求を作成
# rm.createRequireArray(5)
#
# それらの要求から5つのタスクを作成
# pp tm.createTaskArray(5)