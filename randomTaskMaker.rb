require "wcbt"
require "pp"
require "singleton"

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

PROC_NUM = 4
REQ_EXE_MAX = 30
REQ_EXE_MIN = 10
TASK_EXE_MAX = 100
PRIORITY_MAX = 8


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
  
  def createTask
    @@taskId += 1
    proc = rand(PROC_NUM) + 1
    priority = rand(PRIORITY_MAX) + 1
    reqList = [RequireManager.getRandomReq]
    reqTime = 0
    #pp reqList
    reqList.each{|req|
      reqTime += req.time
    }
    extime = reqTime + rand(TASK_EXE_MAX - reqTime)
    period = rand(extime)
    offset = rand(period)
    #pp reqList
    #p extime
    Task.new(@@taskId, proc, period, extime, priority, offset, reqList)
  end
  
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
    @@kind = @kind == "long" ? "short" : "long"
    
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
  
  def createRequire
    @@id += 1
    group = GroupManager.getRandomGroup
    #pp group
    time = REQ_EXE_MIN + rand(REQ_EXE_MAX - REQ_EXE_MIN)
    req = []
    r = RequireManager.getRandomReq
    if r != [] then
      if r.group != group && time > r.time
        req << r
      end
    end
    Req.new(@@id, group, time, req)
  end
  
  def createRequireArray(i)
    reqArray = []
    i.times{
      @@reqArray << createRequire
    }
  end
  
  def getReqArray
    @@reqArray
  end
  
  def self.getRandomReq
    if @@reqArray.size <= 1 then
      # puts "要求が生成されていません．"
      []
    else
      @@reqArray[rand(@@reqArray.size)]
    end
  end
end

gm = GroupManager.instance
rm = RequireManager.instance
tm = TaskManager.instance
gm.createGroupArray(5)
rm.createRequireArray(5)
pp tm.createTaskArray(5)