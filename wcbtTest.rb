require "wcbt"
require "test/unit"
require "pp"
class Test_wcbt < Test::Unit::TestCase
  def setup
    
    # Groupクラス
    # Group.new(group, kind)
    @grp1 = Group.new(1, "long")
    @grp2 = Group.new(2, "short")
    @grp3 = Group.new(3, "long")
    @grp4 = Group.new(4, "short")
    
    @grp0 = Group.new(0, "long") # dummy Resource
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
    @req13_Long1 = Req.new(13, @grp1, 1, [])
    @req15_Short1 = Req.new(15, @grp2, 1, []) 
    @req17_Short1 = Req.new(17, @grp4, 1, []) 
    
    # nested outermost
    # ネストのルール
    # ・long→long，long→short，short→shortは可能
    # ・req1→req2の場合
    #   req1.time >= req2.time でないとダメ
    # ・同じリソースのネストは不可能
    #   req1.res != req2.res はダメ
    @req6_LongLong4 = Req.new(6, @grp1, 4, [@req7_Long2])
    @req8_LongShort4 = Req.new(8, @grp1, 4, [@req9_Short2])
    @req10_ShortShort4 = Req.new(10, @grp2, 4, [@req11_Short2])
    @req12_LongLong2 = Req.new(12, @grp3, 2, [@req13_Long1])
    @req14_LongShort2 = Req.new(14, @grp1, 2, [@req15_Short1])
    @req16_ShortShort2 = Req.new(16, @grp2, 2, [@req17_Short1])
    
  end 
  
  def test_WCLRWCLR
    task1 = Task.new(1, 1, 6, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 3, 0, [@req16_ShortShort2])
        
    assert(WCLR(task1).size == 1)
    assert(WCLR(task1)[0].time == 4)
    assert(WCLR(task2).size == 2)
    assert(WCLR(task2)[0].time == 4)
    assert(WCLR(task2)[1].time == 1)
    assert(WCLR(task3).size == 1)
    assert(WCLR(task3)[0].time == 2)
    
    assert(WCLR(task4).size == 1)
    assert(WCLR(task5).size == 1)
    assert(WCLR(task6).size == 1)

    assert(WCLR(task7).size == 0)
    assert(WCLR(task8).size == 0)
    assert(WCLR(task9).size == 0)
    
    
    assert(WCSR(task1).size == 0)
    assert(WCSR(task2).size == 0)
    assert(WCSR(task3).size == 0)
    
    assert(WCSR(task4).size == 0)
    assert(WCSR(task5).size == 1)
    assert(WCSR(task6).size == 0)
    
    assert(WCSR(task7).size == 1)
    assert(WCSR(task8).size == 2)
    assert(WCSR(task9).size == 1)
  end

  def test_wclxwcsx
    task1 = Task.new(1, 1, 6, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 3, 0, [@req16_ShortShort2])

    $taskList = [task1, task2, task3]
    
    assert(wclx(task2, task1).size == 4)
    assert(wclx(task3, task1).size == 2)
    assert(wcsx(task2, task1).size == 0)
    assert(wcsx(task3, task1).size == 0)

    assert(wclx(task5, task4).size == 2)
    assert(wclx(task6, task4).size == 2)
    assert(wcsx(task5, task4).size == 2)
    assert(wcsx(task6, task4).size == 0)

    assert(wclx(task8, task7).size == 0)
    assert(wclx(task9, task7).size == 0)
    assert(wcsx(task8, task7).size == 4)
    assert(wcsx(task9, task7).size == 2)

  end
    
  def test_reqList
    task1 = Task.new(1, 1, 6, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 3, 0, [@req16_ShortShort2])
    
    $taskList = [task1, task2, task3]
    
    assert(task1.reqList.size == 1)
    assert(task2.reqList.size == 2)
    assert(task3.reqList.size == 1)
  end
  
  def test_checkOutermost
    task1 = Task.new(1, 1, 6, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]
    
    assert(task1.getAllReq[0].outermost == true)
    assert(task1.getAllReq[1].outermost == true)
    assert(task2.getAllReq[0].outermost == true)
    assert(task2.getAllReq[1].outermost == true)
    assert(task2.getAllReq[2].outermost == true)
    assert(task3.getAllReq[0].outermost == true)
    assert(task3.getAllReq[1].outermost == true)    
  end
  
  def test_getLongShortResArray
    task1 = Task.new(1, 1, 6, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 3, 0, [@req16_ShortShort2])
    
    $taskList = [task1, task2, task3]
    
    assert(task1.getLongResArray.size == 2)
    assert(task2.getLongResArray.size == 3)
    assert(task3.getLongResArray.size == 2)
    assert(task1.getShortResArray.size == 0)
    assert(task2.getShortResArray.size == 0)
    assert(task3.getShortResArray.size == 0)

    assert(task4.getLongResArray.size == 1)
    assert(task5.getLongResArray.size == 1)
    assert(task6.getLongResArray.size == 1)
    assert(task4.getShortResArray.size == 1)
    assert(task5.getShortResArray.size == 2)
    assert(task6.getShortResArray.size == 1)

    assert(task7.getLongResArray.size == 0)
    assert(task8.getLongResArray.size == 0)
    assert(task9.getLongResArray.size == 0)
    assert(task7.getShortResArray.size == 2)
    assert(task8.getShortResArray.size == 3)
    assert(task9.getShortResArray.size == 2)

  end
  
  def test_getAllReq
    task1 = Task.new(1, 1, 6, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 3, 0, [@req16_ShortShort2])
    
    assert(task1.getAllReq.size == 2)
    assert(task2.getAllReq.size == 3)
    assert(task3.getAllReq.size == 2)
    assert(task4.getAllReq.size == 2)
    assert(task5.getAllReq.size == 3)
    assert(task6.getAllReq.size == 2)
    assert(task7.getAllReq.size == 2)
    assert(task8.getAllReq.size == 3)
    assert(task9.getAllReq.size == 2)
  end

  def test_bbt
    task1 = Task.new(1, 1, 6, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]

    #    pp wclx(task1, task1)
    assert(bbt(task2, task1) == 9)
    assert(bbt(task3, task1) == 4)    
    assert(bbt(task5, task4) == 8)    
    assert(bbt(task6, task4) == 4)
    assert(bbt(task8, task7) == 0)
    assert(bbt(task9, task7) == 0)    

  end
  
  def test_BB
    task1 = Task.new(1, 1, 6, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]

    assert(BB(task1) == 9)
    assert(BB(task2) == 0)
    assert(BB(task3) == 0)
    assert(BB(task4) == 8)
    assert(BB(task5) == 0)
    assert(BB(task6) == 0)
    assert(BB(task7) == 0)
    assert(BB(task8) == 0)
    assert(BB(task9) == 0)
  end

  def test_abr
    task1 = Task.new(1, 1, 6, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]
    assert(abr(task1).size == 0)
    assert(abr(task2).size == 0)
    assert(abr(task3).size == 0)
    $taskList = [task4, task5, task6]
    assert(abr(task4).size == 2)
    assert(abr(task5).size == 0)
    assert(abr(task6).size == 0)
    $taskList = [task7, task8, task9]
    assert(abr(task7).size == 4)
    assert(abr(task8).size == 0)
    assert(abr(task9).size == 0)
  end

  def test_AB
    task1 = Task.new(1, 1, 6, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]
    assert(AB(task1)== 0)
    assert(AB(task2)== 0)
    assert(AB(task3)== 0)

    $taskList = [task4, task5, task6]
    assert(AB(task4)== 2)
    assert(AB(task5)== 0)
    assert(AB(task6)== 0)
    
    $taskList = [task7, task8, task9]
    assert(AB(task7)== 4)
    assert(AB(task8)== 0)
    assert(AB(task9)== 0)
  end
=begin    
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
    task1 = Task.new(1, 1, 10, 1, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task2 = Task.new(2, 1, 10, 2, 0, [@req1_Long1, @req1_Long1, @req5_Long3])
    task3 = Task.new(3, 1, 10, 3, 0, [@req1_Long1, @req5_Long3])
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
    task1 = Task.new(1, 1, 10, 1, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task2 = Task.new(2, 1, 10, 2, 0, [@req1_Long1, @req1_Long1, @req5_Long3])
    task3 = Task.new(3, 1, 10, 3, 0, [@req1_Long1, @req5_Long3])
    task4 = Task.new(4, 2, 10, 4, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task5 = Task.new(5, 2, 10, 5, 0, [@req1_Long1, @req5_Long3])
    $taskList = [task1, task2, task3, task4, task5]
    assert(ndbt(task2, task1) == 2)
    assert(ndbt(task3, task1) == 1)
    assert(ndbt(task2, task3) == 2)
    assert(ndbt(task4, task1) == 2)
    assert(ndbt(task5, task1) == 1)
  end 
  
  def test_ndbp
    task1 = Task.new(1, 1, 10, 1, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task2 = Task.new(2, 1, 10, 2, 0, [@req1_Long1, @req1_Long1, @req5_Long3])
    task3 = Task.new(3, 1, 10, 3, 0, [@req1_Long1, @req5_Long3])
    task4 = Task.new(4, 2, 10, 4, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task5 = Task.new(5, 2, 10, 5, 0, [@req1_Long1, @req5_Long3])
    task6 = Task.new(5, 3, 15, 6, 0, [@req5_Long3])
    $taskList = [task1, task2, task3, task4, task5, task6]
    assert(ndbp(task1, 2) == 3)
    assert(ndbp(task1, 1) == 0)
    assert(ndbp(task1, 3) == 0)
  end
  
  def test_rblt
    task1 = Task.new(1, 1, 10, 1, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task2 = Task.new(2, 1, 10, 2, 0, [@req1_Long1, @req1_Long1, @req5_Long3])
    task3 = Task.new(3, 1, 10, 3, 0, [@req1_Long1, @req5_Long3])
    task4 = Task.new(4, 2, 10, 4, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task5 = Task.new(5, 2, 10, 5, 0, [@req1_Long1, @req5_Long3])
    task6 = Task.new(5, 3, 15, 6, 0, [@req5_Long3])
    $taskList = [task1, task2, task3, task4, task5, task6]
    assert(rblt(task2, task1) == 0)
    assert(rblt(task4, task1) == 3)
    assert(rblt(task5, task1) == 7)
    assert(rblt(task6, task1) == 0)
  end
  
  def test_rblp
    task1 = Task.new(1, 1, 10, 1, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task2 = Task.new(2, 1, 10, 2, 0, [@req1_Long1, @req1_Long1, @req5_Long3])
    task3 = Task.new(3, 1, 10, 3, 0, [@req1_Long1, @req5_Long3])
    task4 = Task.new(4, 2, 10, 4, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task5 = Task.new(5, 2, 10, 5, 0, [@req1_Long1, @req5_Long3])
    task6 = Task.new(5, 3, 15, 6, 0, [@req5_Long3])
    $taskList = [task1, task2, task3, task4, task5, task6]
    
    assert(rblp(task1, 2) == 10)
    assert(rblp(task1, 3) == 0)
  end
  
  def test_wcsxg
    task1 = Task.new(1, 1, 10, 1, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task2 = Task.new(2, 1, 10, 2, 0, [@req1_Long1, @req1_Long1, @req5_Long3])
    task3 = Task.new(3, 1, 10, 3, 0, [@req1_Long1, @req5_Long3])
    task4 = Task.new(4, 2, 10, 4, 0, [@req1_Long1, @req1_Long1, @req4_Short1])    
    task5 = Task.new(5, 2, 10, 5, 0, [@req1_Long1, @req5_Long3])
    task6 = Task.new(5, 3, 15, 6, 0, [@req5_Long3])
    $taskList = [task1, task2, task3, task4, task5, task6]
  end
=end
end