require "task-CUI"
require "task"
require "test/unit"
require "pp"
require "manager"
class Test_taskCUI < Test::Unit::TestCase
  def setup
    # Groupクラス
    # Group.new(group, kind)
    @grp1 = Group.new(1, LONG)
    @grp2 = Group.new(2, SHORT)
    @grp3 = Group.new(3, LONG)
    @grp4 = Group.new(4, SHORT)
    
    @grp0 = Group.new(0, LONG) # dummy Resource
    @req0 = Req.new(0, 0, 0, []) # dummy Require
    
    # Require
    # Req.new(reqId, res, time, reqs)
    
    # non-nested outermost
    @req1_Long1 = Req.new(1, @grp1, 1, [])
    @req2_Long2 = Req.new(2, @grp1, 2, [])
    @req3_Long2 = Req.new(3, @grp1, 2, [])
    @req4_Short1 = Req.new(4, @grp2, 1, []) 
    @req5_Long3 = Req.new(5, @grp3, 3, [])
    
    # nested non-outermost
    @req7_Long2 = Req.new(7, @grp3, 2, [])
    @req9_Short2 = Req.new(9, @grp2, 2, [])
    @req11_Short2 = Req.new(11, @grp4, 2, [])
    @req13_Long1 = Req.new(13, @grp3, 1, [])
    @req15_Short1 = Req.new(15, @grp2, 1, []) 
    @req17_Short1 = Req.new(17, @grp4, 1, []) 
    
    # nested outermost
    # ネストのルール
    # ・long→long，long→short，short→shortは可能
    # ・req1→req2の場合
    #   req1.time >= req2.time でないとダメ
    # ・同じリソースのネストは不可能
    #   req1.res != req2.res はダメ
    @req6_LongLong4 = Req.new(6, @grp1, 7, [@req7_Long2])
    @req8_LongShort4 = Req.new(8, @grp1, 14, [@req9_Short2])
    @req10_ShortShort4 = Req.new(10, @grp2, 4, [@req11_Short2])
    @req12_LongLong2 = Req.new(12, @grp1, 2, [@req13_Long1])
    @req14_LongShort2 = Req.new(14, @grp1, 2, [@req15_Short1])
    @req16_ShortShort2 = Req.new(16, @grp2, 2, [@req17_Short1])
  end

  def test_1
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 30, 2, 0, [@req6_LongLong4, @req8_LongShort4])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    taskList = [task1, task2, task3]
    
    #task2.set_begin_time
    tc = TaskCUI.new(task2)
    tc.show_task_char
    pp task2
  
  end

  def test_show_taskset
    info = { :mode => "0", :assign_mode => LIST_ORDER}
    @manager = AllManager.new
    @manager.all_data_clear
    @manager.create_tasks(10, 4, 4, info)
    @manager.pm.assign_tasks(@manager.tm.get_task_array.sort_by{ rand }, info)
    @manager.pm.show_proc_info
    taskset = TaskSet.new
    taskset.show_taskset
    @manager.pm.sort_tasks(SORT_UTIL)
    taskset.show_taskset
  end
end
  
