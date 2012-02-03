require "wcbt"
require "test/unit"
require "pp"
class Test_wcbt < Test::Unit::TestCase
  def setup
    @res1 = Res.new(1, "long", 1)
    @res2 = Res.new(2, "short", 2)
    @res3 = Res.new(3, "long", 3)
    
    @res0 = Res.new(0, "", 0) # dummy Resource
    @req0 = Req.new(0, 0, 0, []) # dummy Require
    
    # アクセス時間1のリソース要求がアクセス時間1以上のリソース要求をネストすることができない！
    # Require
    # Req.new(reqId, res, time, reqs)
    # non-nestedRequire
    @reqLong1_1 = Req.new(1, @res1, 1, [])
    @reqLong2_2 = Req.new(2, @res1, 2, [])
    @reqLong3_2 = Req.new(3, @res1, 2, [])
    @reqShort4_2 = Req.new(4, @res2, 2, []) 
    @reqLong5_3 = Req.new(5, @res3, 3, [])
    @reqLong7_1 = Req.new(7, @res3, 1, [])
    
    # nestedRequire
    # ネストのルール
    # ・long→long，long→short，short→shortは可能
    # ・req1→req2の場合
    #   req1.time >= req2.time でないとダメ
    # ・同じリソースのネストは不可能
    #   req1.res != req2.res はダメ
    @reqLong6_1 = Req.new(6, @res1, 2, [@reqLong7_1])
    @reqLong8_1 = Req.new(8, @res1, 2, [])
    
    @tas1 = Task.new(1, 1, 10, 1, 0, [@reqLong1_1])
    @tas2 = Task.new(2, 1, 10, 2, 0, [@reqLong2_2])
    @tas3 = Task.new(3, 2, 10, 3, 0, [@reqLong3_2])
    @tas4 = Task.new(4, 1, 20, 4, 0, [])
    @tas5_L1 = Task.new(5, 1, 10, 5, 0, [@reqLong1_1])
    @tas6_S1 = Task.new(6, 1, 10, 6, 0, [@reqShort4_2])
    @tas7_L1 = Task.new(7, 1, 10, 7, 0, [@reqLong2_2])
    
    $taskList = [@tas1, @tas2, @tas4, @tas5_L1, @tas6_S1, @tas7_L1]
  end 
  
  def test_reqList
    task1 = Task.new(1, 1, 6, 1, 0, [@reqLong6_1])
    task2 = Task.new(2, 1, 6, 2, 0, [@reqLong2_2])
    task3 = Task.new(3, 2, 3, 3, 0, [@reqLong7_1])
    $taskList = [task1, task2, task3]
    
    assert(task1.reqList.size == 2)
    assert(task2.reqList.size == 1)
    assert(task3.reqList.size == 1)
  end
  
  def test_checkOutermost
    task1 = Task.new(1, 1, 6, 1, 0, [@reqLong6_1])
    task2 = Task.new(2, 1, 6, 2, 0, [@reqLong2_2])
    task3 = Task.new(3, 2, 3, 3, 0, [@reqLong7_1])
    $taskList = [task1, task2, task3]
    
    task1.checkOutermost
    assert(task1.reqList[0].outermost == true)
    # ↓エラーが起きる
    # assert(task1.reqList[1].outermost == false)
    assert(task2.reqList[0].outermost == true)
    assert(task3.reqList[0].outermost == false)
  end
  
  def test_longResArrayNested
    task1 = Task.new(1, 1, 6, 1, 0, [@reqLong6_1])
    task2 = Task.new(2, 1, 6, 2, 0, [@reqLong2_2])
    task3 = Task.new(3, 2, 3, 3, 0, [@reqLong7_1])
    $taskList = [task1, task2, task3]
    
    assert(task1.longResArray.size == 2)
  end

  def test_BB_longSameGroup
    task1 = Task.new(1, 1, 6, 1, 0, [@reqLong6_1])
    task2 = Task.new(2, 1, 6, 2, 0, [@reqLong2_2])
    task3 = Task.new(3, 2, 3, 3, 0, [@reqLong7_1])
    $taskList = [task1, task2, task3]
    
    assert(BB(task1) == 3)
  end

  def test_bbt_longSameGroup
    task1 = Task.new(1, 1, 6, 1, 0, [@reqLong6_1])
    task2 = Task.new(2, 1, 6, 2, 0, [@reqLong2_2])
    task3 = Task.new(3, 2, 3, 3, 0, [@reqLong7_1])
    $taskList = [task1, task2, task3]
    
    assert(bbt(task2, task1) == 3)
  end

=begin
  def test_longResArray
    task1 = Task.new(1, 1, 10, 1, 0, [@reqLong1_1, @reqLong1_1])
    task2 = Task.new(2, 1, 10, 2, 0, [@reqLong1_1, @reqLong1_1])
    task3 = Task.new(3, 1, 10, 3, 0, [@reqLong1_1, @reqLong5_3])
    $taskList = [task1, task2]
    assert(task1.longResArray.size == 2)
    #pp task3.longResArray
    assert(task3.longResArray.size == 2)
  end
  
  def test_abr
    #assert(abr(@tas1) == [wclx(@tas2, @tas1)])
    assert(abr(@tas5_L1).size == 2)
    assert(abr(@tas5_L1)[0].req.time == 2)
  end
  
  def test_wclx
    assert(wclx(nil, nil) == [])
    assert(wclx(@tas2, @tas1) != [])
    assert(wcsx(@tas6_S1, @tas5_L1).size == 2)
    assert(wcsx(@tas7_L1, @tas5_L1).size == 0)
    assert(wcsx(@tas6_S1, @tas5_L1)[0].req.time == 2)
  end
  
  def test_AB
    assert(AB(@tas5_L1) == 4)
  end
  
  def test_ndbp
    $taskList = [@tas1, @tas2, @tas3]
    assert(ndbp(@tas1, 2) == 1)
    assert(ndbp(@tas1, 1) == 2)
  end
  
  def test_partition
    $taskList = [@tas1, @tas2, @tas4, @tas5_L1, @tas6_S1, @tas7_L1]
    assert(partition(1).size == 6)
    assert(partition(2).size == 0)
  end
  
  def test_ndbtg
    #$taskList = [@tas1, @tas2, @tas4, @tas5_L1, @tas6_S1, @tas7_L1]
    task1 = Task.new(1, 1, 10, 1, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task2 = Task.new(2, 1, 10, 2, 0, [@reqLong1_1, @reqLong1_1, @reqLong5_3])
    task3 = Task.new(3, 1, 10, 3, 0, [@reqLong1_1, @reqLong5_3])
    $taskList = [task1, task2, task3]
    assert(ndbtg(task2, task1, 1) == 2)
    assert(ndbtg(task2, task1, 2) == 0)
    assert(ndbtg(task2, task1, 3) == 0)
    assert(ndbtg(task2, task3, 1) == 1)
    assert(ndbtg(task2, task3, 3) == 1)
    assert(ndbtg(task3, task1, 1) == 1)
    assert(ndbtg(task3, task1, 3) == 0)    
  end
  
  def test_ndbt
    task1 = Task.new(1, 1, 10, 1, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task2 = Task.new(2, 1, 10, 2, 0, [@reqLong1_1, @reqLong1_1, @reqLong5_3])
    task3 = Task.new(3, 1, 10, 3, 0, [@reqLong1_1, @reqLong5_3])
    task4 = Task.new(4, 2, 10, 4, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task5 = Task.new(5, 2, 10, 5, 0, [@reqLong1_1, @reqLong5_3])
    $taskList = [task1, task2, task3, task4, task5]
    assert(ndbt(task2, task1) == 2)
    assert(ndbt(task3, task1) == 1)
    assert(ndbt(task2, task3) == 2)
    assert(ndbt(task4, task1) == 2)
    assert(ndbt(task5, task1) == 1)
  end 
  
  def test_ndbp
    task1 = Task.new(1, 1, 10, 1, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task2 = Task.new(2, 1, 10, 2, 0, [@reqLong1_1, @reqLong1_1, @reqLong5_3])
    task3 = Task.new(3, 1, 10, 3, 0, [@reqLong1_1, @reqLong5_3])
    task4 = Task.new(4, 2, 10, 4, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task5 = Task.new(5, 2, 10, 5, 0, [@reqLong1_1, @reqLong5_3])
    task6 = Task.new(5, 3, 15, 6, 0, [@reqLong5_3])
    $taskList = [task1, task2, task3, task4, task5, task6]
    assert(ndbp(task1, 2) == 3)
    assert(ndbp(task1, 1) == 0)
    assert(ndbp(task1, 3) == 0)
  end
  
  def test_rblt
    task1 = Task.new(1, 1, 10, 1, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task2 = Task.new(2, 1, 10, 2, 0, [@reqLong1_1, @reqLong1_1, @reqLong5_3])
    task3 = Task.new(3, 1, 10, 3, 0, [@reqLong1_1, @reqLong5_3])
    task4 = Task.new(4, 2, 10, 4, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task5 = Task.new(5, 2, 10, 5, 0, [@reqLong1_1, @reqLong5_3])
    task6 = Task.new(5, 3, 15, 6, 0, [@reqLong5_3])
    $taskList = [task1, task2, task3, task4, task5, task6]
    assert(rblt(task2, task1) == 0)
    assert(rblt(task4, task1) == 3)
    assert(rblt(task5, task1) == 7)
    assert(rblt(task6, task1) == 0)
  end
  
  def test_rblp
    task1 = Task.new(1, 1, 10, 1, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task2 = Task.new(2, 1, 10, 2, 0, [@reqLong1_1, @reqLong1_1, @reqLong5_3])
    task3 = Task.new(3, 1, 10, 3, 0, [@reqLong1_1, @reqLong5_3])
    task4 = Task.new(4, 2, 10, 4, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task5 = Task.new(5, 2, 10, 5, 0, [@reqLong1_1, @reqLong5_3])
    task6 = Task.new(5, 3, 15, 6, 0, [@reqLong5_3])
    $taskList = [task1, task2, task3, task4, task5, task6]
    
    assert(rblp(task1, 2) == 10)
    assert(rblp(task1, 3) == 0)
  end
  
  def test_wcsxg
    task1 = Task.new(1, 1, 10, 1, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task2 = Task.new(2, 1, 10, 2, 0, [@reqLong1_1, @reqLong1_1, @reqLong5_3])
    task3 = Task.new(3, 1, 10, 3, 0, [@reqLong1_1, @reqLong5_3])
    task4 = Task.new(4, 2, 10, 4, 0, [@reqLong1_1, @reqLong1_1, @reqShort4_2])    
    task5 = Task.new(5, 2, 10, 5, 0, [@reqLong1_1, @reqLong5_3])
    task6 = Task.new(5, 3, 15, 6, 0, [@reqLong5_3])
    $taskList = [task1, task2, task3, task4, task5, task6]
  end
=end
end