require "wcbt"
require "pp"
require "singleton"

# ランダム生成方針
# Task(taskId, proc, period, extime, priority, offset, reqList)
#  taskId: タスク生成順にインクリメント
#  proc: 完全ランダム
#  period: extime以下でランダム
#  extime: reqListの総時間
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

$groupArray = []
$taskArray = []
$reqArray = []

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

end

class GroupManager
  include Singleton

  def initialize
    @groupId = 0
    @kind = "long"
  end

  # グループを生成する
  def createGroup
    @groupId += 1
    group = Group.new(@groupId, @kind)
    @kind = @kind == "long" ? "short" : "long"
    
    group
  end
  
  # i個のグループを生成し，groupArrayとする
  def createGroupArray(i)
    garray = []
    i.times{
      garray << createGroup
    }
    $groupArray = garray
  end
  
  def getCount
    @groupId
  end
  
  # グループをランダムに返す
  def self.getRandomGroup
    if $groupArray.size == 0 then
      puts "グループが生成されていません．"
      exit
    end
    $groupArray[rand($groupArray.size)]
  end
end

class RequireManager
  include Singleton

  def initialize
    @id = 0
  end
  
  def createRequire
    @id += 1
    group = GroupManager.getRandomGroup
    pp group
    time = 20 + rand(30)
    req = []
    r = Req.new(0, 0, 0, [])
    if rand(2) == 1 then
      while r == group
        r = GroupManager.getRandomGroup
      end
      req << r
    end
    Req.new(@id, group, time, req)
  end
  
  def createRequireArray(i)
    reqArray = []
    i.times{
      reqArray << createRequire
    }
    $reqArray = reqArray
  end
  
  
end

gc = GroupManager.instance
gc.createGroupArray(5)
rc = RequireManager.instance
rc.createRequireArray(5)
pp $reqArray
