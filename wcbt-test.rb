require "task"
require "test/unit"
require "pp"
require "task-CUI"
require "task-maker"

class Test_wcbt < Test::Unit::TestCase
  include WCBT
  def setup
    #
    # Groupクラス定義
    # Group.new(group, kind)
    #
    @grp1 = Group.new(1, "long")
    @grp2 = Group.new(2, "short")
    @grp3 = Group.new(3, "long")
    @grp4 = Group.new(4, "short")
    
    @grp0 = Group.new(0, "long") # dummy Resource
    @req0 = Req.new(0, 0, 0, []) # dummy Require
    
    #
    # Requireクラス定義
    # Req.new(reqId, res, time, reqs)
    #

    #
    # non-nested outermost
    #
    @req1_Long1 = Req.new(1, @grp1, 1, [])
    @req2_Long2 = Req.new(2, @grp1, 2, [])
    @req3_Long2 = Req.new(3, @grp1, 2, [])
    @req4_Short1 = Req.new(4, @grp2, 1, []) 
    @req5_Long3 = Req.new(5, @grp3, 3, [])
    
    #
    # nested non-outermost
    #
    @req7_Long2 = Req.new(7, @grp3, 2, [])
    @req9_Short2 = Req.new(9, @grp2, 2, [])
    @req11_Short2 = Req.new(11, @grp4, 2, [])
    @req13_Long1 = Req.new(13, @grp3, 1, [])
    @req15_Short1 = Req.new(15, @grp2, 1, []) 
    @req17_Short1 = Req.new(17, @grp4, 1, []) 
    
    #
    # nested outermost
    # ネストのルール
    # ・long→long，long→short，short→shortは可能
    # ・req1→req2の場合
    #   req1.time >= req2.time でないとダメ
    # ・同じリソースのネストは不可能
    #   req1.res != req2.res はダメ
    #
    @req6_LongLong4 = Req.new(6, @grp1, 4, [@req7_Long2])
    @req8_LongShort4 = Req.new(8, @grp1, 4, [@req9_Short2])
    @req10_ShortShort4 = Req.new(10, @grp2, 4, [@req11_Short2])
    @req12_LongLong2 = Req.new(12, @grp1, 2, [@req13_Long1])
    @req14_LongShort2 = Req.new(14, @grp1, 2, [@req15_Short1])
    @req16_ShortShort2 = Req.new(16, @grp2, 2, [@req17_Short1])
    
    #
    # 最大ブロック時間計算クラス
    #
    # wcbt = WCBT.new
    
  end 
  
  def test_WCLRWCLR
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
        
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
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])

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
    
  def test_req_list
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    
    $taskList = [task1, task2, task3]
    
    assert(task1.req_list.size == 1)
    assert(task2.req_list.size == 2)
    assert(task3.req_list.size == 1)
  end
  
  def test_checkOutermost
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]
    
    assert(task1.get_all_require[0].outermost == true)
    assert(task1.get_all_require[1].outermost == true)
    assert(task2.get_all_require[0].outermost == true)
    assert(task2.get_all_require[1].outermost == true)
    assert(task2.get_all_require[2].outermost == true)
    assert(task3.get_all_require[0].outermost == true)
    assert(task3.get_all_require[1].outermost == true)    
  end
  
  def test_getLongShortResArray
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    
    $taskList = [task1, task2, task3]
    
    assert(task1.get_long_resource_array.size == 2)
    assert(task2.get_long_resource_array.size == 3)
    assert(task3.get_long_resource_array.size == 2)
    assert(task1.get_short_resource_array.size == 0)
    assert(task2.get_short_resource_array.size == 0)
    assert(task3.get_short_resource_array.size == 0)

    assert(task4.get_long_resource_array.size == 1)
    assert(task5.get_long_resource_array.size == 1)
    assert(task6.get_long_resource_array.size == 1)
    assert(task4.get_short_resource_array.size == 1)
    assert(task5.get_short_resource_array.size == 2)
    assert(task6.get_short_resource_array.size == 1)

    assert(task7.get_long_resource_array.size == 0)
    assert(task8.get_long_resource_array.size == 0)
    assert(task9.get_long_resource_array.size == 0)
    assert(task7.get_short_resource_array.size == 2)
    assert(task8.get_short_resource_array.size == 3)
    assert(task9.get_short_resource_array.size == 2)

  end
  
  def test_get_all_require
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    
    assert(task1.get_all_require.size == 2)
    assert(task2.get_all_require.size == 3)
    assert(task3.get_all_require.size == 2)
    assert(task4.get_all_require.size == 2)
    assert(task5.get_all_require.size == 3)
    assert(task6.get_all_require.size == 2)
    assert(task7.get_all_require.size == 2)
    assert(task8.get_all_require.size == 3)
    assert(task9.get_all_require.size == 2)
  end

  def test_bbt
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
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
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
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
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
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
  
  def test_procList
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    $taskList = [task1, task2, task3]
    
    assert(procList = [1,2])
  end
    
  def test_AB
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    p "test_AB"
    $taskList = [task1, task2, task3]
    assert_same(0, AB(task1))
    assert_same(0, AB(task2))
    assert_same(0, AB(task3))

    $taskList = [task4, task5, task6]
    assert_same(0, AB(task4))
    assert_same(0, AB(task5))
    assert_same(0, AB(task6))
    
    $taskList = [task7, task8, task9]
    assert_same(4, AB(task7))
    assert_same(0, AB(task8))
    assert_same(0, AB(task9))
    p "end_test_AB"
  end
    
  def test_partition
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]
    
    assert(partition(1).size == 2)
    assert(partition(2).size == 1)
  end

  def test_ndbtg
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]

    assert(ndbtg(task2, task1, 1) == 1)
    assert(ndbtg(task2, task1, 2) == 0)
    assert(ndbtg(task2, task1, 3) == 0)
    assert(ndbtg(task2, task1, 4) == 0)
    
    assert(ndbtg(task3, task1, 1) == 1)
    assert(ndbtg(task3, task1, 2) == 0)
    assert(ndbtg(task3, task1, 3) == 0)
    assert(ndbtg(task3, task1, 4) == 0)
    
    assert(ndbtg(task6, task4, 1) == 1)
    assert(ndbtg(task6, task4, 2) == 0)
    assert(ndbtg(task6, task4, 3) == 0)
    assert(ndbtg(task6, task4, 4) == 0)

    assert(ndbtg(task9, task7, 1) == 0)
    assert(ndbtg(task9, task7, 2) == 0)
    assert(ndbtg(task9, task7, 3) == 0)
    assert(ndbtg(task9, task7, 4) == 0)
  end
    
  def test_ndbt
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    
    $taskList = [task1, task2, task3]
    assert(ndbt(task2, task1) == 1)
    assert(ndbt(task3, task1) == 1)
    assert(ndbt(task6, task4) == 1)
    assert(ndbt(task9, task7) == 0)
  end 
  
  def test_ndbp
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]
    
    assert(ndbp(task1, 2) == 1)

    $taskList = [task4, task5, task6]

    assert(ndbp(task4, 2) == 1)
    
    $taskList = [task7, task8, task9]

    assert(ndbp(task7, 2) == 0)
  end
  
  def test_rblt
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]
    
    assert(rblt(task3, task1) == 2)
    assert(rblt(task6, task4) == 2)
    assert(rblt(task9, task7) == 0)
  end
  
  def test_rblp
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]
    
    assert(rblp(task1, 2) == 2)
    
    $taskList = [task4, task5, task6]
    
    assert(rblp(task4, 2) == 2)
    
    $taskList = [task7, task8, task9]
    
    assert(rblp(task7, 2) == 0)
  end
  
  def test_rbl
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]
    
    assert(rbl(task1) == 2)
    
    $taskList = [task4, task5, task6]
    
    assert(rbl(task4) == 2)
    
    $taskList = [task7, task8, task9]
    
    assert(rbl(task7) == 0)
  end

  def test_wcsp
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 6, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 6, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 6, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 6, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 6, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 6, 10, 3, 0, [@req16_ShortShort2])
    $taskList = [task1, task2, task3]
    
    assert(wcsp(task1, 2).size == 0)
    
    $taskList = [task4, task5, task6]
    
    assert(wcsp(task4, 2).size == 0)
    
    $taskList = [task7, task8, task9]
    
    assert(wcsp(task7, 2).size == 2)
  end
  
  def test_rbspLB
    long1 = Group.new(1, "long")
    long2 = Group.new(2, "long")
    short1 = Group.new(3, "short")
    short2 = Group.new(4, "short")
    short3 = Group.new(5, "short")
    
    # Req.new(reqId, res, time, reqs)
      req2 = Req.new(2, long2, 2, [])
    req1 = Req.new(1, long1, 4, [req2])
    req1_2 = Req.new(7, long1, 2, [])
    
      req4 = Req.new(4, short2, 2, [])
    req3 = Req.new(3, short1, 5, [req4])
    
      req6 = Req.new(6, short3, 1, [])
    req5 = Req.new(5, short1, 3, [req6])
    
    task1 = Task.new(1, 1, 20, 10, 1, 0, [req1])
    task2 = Task.new(2, 2, 15, 10, 2, 0, [req1])
    task3 = Task.new(3, 2, 15, 10, 3, 0, [req1_2, req3])
    $taskList = [task1, task2, task3]
    
    assert(rbl(task1)==12)
    assert(rbs(task1)==10)
  end
  
  def test_wcsxg
    long1 = Group.new(1, "long")
    long2 = Group.new(2, "long")
    short1 = Group.new(3, "short")
    short2 = Group.new(4, "short")
    short3 = Group.new(5, "short")
    
    # Req.new(reqId, res, time, reqs)
    req2 = Req.new(2, long2, 2, [])
    req1 = Req.new(1, long1, 4, [req2])
    req1_2 = Req.new(7, long1, 2, [])
    
    req4 = Req.new(4, short2, 2, [])
    req3 = Req.new(3, short1, 5, [req4])
    
    req6 = Req.new(6, short3, 1, [])
    req5 = Req.new(5, short1, 3, [req6])
    
    task1 = Task.new(1, 1, 20, 10, 1, 0, [req3])
    task2 = Task.new(2, 2, 15, 10, 2, 0, [req1])
    task3 = Task.new(3, 2, 15, 10, 3, 0, [req1_2, req3, req4])
    $taskList = [task1, task2, task3]
    
    assert(wcsxg(task2, task1, 3).size == 0)
    assert(wcsxg(task2, task1, 4).size == 0)
    assert(wcsxg(task3, task1, 3).size == 3)
    assert(wcsxg(task3, task1, 4).size == 3)
  end
  
  def test_wcspg
    long1 = Group.new(1, "long")
    long2 = Group.new(2, "long")
    short1 = Group.new(3, "short")
    short2 = Group.new(4, "short")
    short3 = Group.new(5, "short")
    
    # Req.new(reqId, res, time, reqs)
    req2 = Req.new(2, long2, 2, [])
    req1 = Req.new(1, long1, 4, [req2])
    req1_2 = Req.new(7, long1, 2, [])
    
    req4 = Req.new(4, short2, 2, [])
    req3 = Req.new(3, short1, 5, [req4])
    
    req6 = Req.new(6, short3, 1, [])
    req5 = Req.new(5, short1, 3, [req6])
    
    task1 = Task.new(1, 1, 20, 10, 1, 0, [req3])
    task2 = Task.new(2, 2, 15, 10, 2, 0, [req1])
    task3 = Task.new(3, 2, 15, 10, 3, 0, [req1_2, req3, req4])
    $taskList = [task1, task2, task3]
    
    assert(wcspg(task1, 2, 3).size == 3)
    assert(wcspg(task1, 2, 4).size == 3)
  end
  
  def test_sbgp
    long1 = Group.new(1, "long")
    long2 = Group.new(2, "long")
    short1 = Group.new(3, "short")
    short2 = Group.new(4, "short")
    short3 = Group.new(5, "short")
    
    # Req.new(reqId, res, time, reqs)
    req2 = Req.new(2, long2, 2, [])
    req1 = Req.new(1, long1, 4, [req2])
    req1_2 = Req.new(7, long1, 2, [])
    
    req4 = Req.new(4, short2, 2, [])
    req3 = Req.new(3, short1, 5, [req4])
    
    req6 = Req.new(6, short3, 1, [])
    req5 = Req.new(5, short1, 3, [req6])
    
    task1 = Task.new(1, 1, 20, 10, 1, 0, [req3])
    task2 = Task.new(2, 2, 15, 10, 2, 0, [req1])
    task3 = Task.new(3, 2, 15, 10, 3, 0, [req1_2, req3, req4])
    $taskList = [task1, task2, task3]
    
    assert(sbgp(task1, 3, 2) == 5)
    assert(sbgp(task1, 4, 2) == 2) 
  end
  
  def test_sbgSB
    long1 = Group.new(1, "long")
    long2 = Group.new(2, "long")
    short1 = Group.new(3, "short")
    short2 = Group.new(4, "short")
    short3 = Group.new(5, "short")
    
    # Req.new(reqId, res, time, reqs)
    req2 = Req.new(2, long2, 2, [])
    req1 = Req.new(1, long1, 4, [req2])
    req1_2 = Req.new(7, long1, 2, [])
    
    req4 = Req.new(4, short2, 2, [])
    req3 = Req.new(3, short1, 5, [req4])
    
    req6 = Req.new(6, short3, 1, [])
    req5 = Req.new(5, short1, 3, [req6])
    
    task1 = Task.new(1, 1, 20, 10, 1, 0, [req3])
    task2 = Task.new(2, 2, 15, 10, 2, 0, [req1])
    task3 = Task.new(3, 2, 15, 10, 3, 0, [req1_2, req3, req4])
    $taskList = [task1, task2, task3]
    
    assert(sbg(task1, 3) == 5)
    assert(SB(task1) == 7)
  end
  
  def test_DB
    long1 = Group.new(1, "long")
    long2 = Group.new(2, "long")
    short1 = Group.new(3, "short")
    short2 = Group.new(4, "short")
    short3 = Group.new(5, "short")
    
    # Req.new(reqId, res, time, reqs)
    req2 = Req.new(2, long2, 2, [])
    req1 = Req.new(1, long1, 4, [req2])
    req1_2 = Req.new(7, long1, 2, [])
    
    req4 = Req.new(4, short2, 2, [])
    req3 = Req.new(3, short1, 5, [req4])
    
    req6 = Req.new(6, short3, 1, [])
    req5 = Req.new(5, short1, 3, [req6])
    
    task1 = Task.new(1, 1, 20, 10, 1, 0, [req3])
    task2 = Task.new(2, 2, 15, 10, 2, 0, [req1])
    task3 = Task.new(3, 2, 15, 10, 3, 0, [req1_2, req3, req4])
    $taskList = [task1, task2, task3]
    
    #p B(task1)
  end
  
  def test_B
    long1 = Group.new(1, "long")
    long2 = Group.new(2, "long")
    long3 = Group.new(3, "long")
    
    req1 = Req.new(1, long3, 1, [])
    req2 = Req.new(2, long1, 2, [])
    req3 = Req.new(3, long2, 2, [])
    req4 = Req.new(4, long3, 2, [])
    
    task1 =Task.new(1, 1, 12, 1, 1, 0, [req1])
    task2 =Task.new(2, 1, 12, 3, 2, 0, [req2])
    task3 =Task.new(3, 1, 12, 3, 3, 0, [req3])
    task4 =Task.new(4, 2, 6, 2, 4, 0, [req3])
    task5 =Task.new(5, 3, 12, 10, 5, 0, [req4, req4])
    $taskList = [task1, task2, task3, task4, task5]
    
    assert(B(task1) == 10)
  end
  
  def test_B2
    long1 = Group.new(1, "long")
    long2 = Group.new(2, "long")
    short1 = Group.new(3, "short")
    short2 = Group.new(4, "short")
    short3 = Group.new(5, "short")
    
    # Req.new(reqId, res, time, reqs)
    req2 = Req.new(2, long2, 2, [])
    req1 = Req.new(1, long1, 4, [req2])
    req1_2 = Req.new(7, long1, 2, [])
    
    req4 = Req.new(4, short2, 2, [])
    req3 = Req.new(3, short1, 5, [req4])
    
    req6 = Req.new(6, short3, 1, [])
    req5 = Req.new(5, short1, 3, [req6])
    
    task1 = Task.new(1, 1, 20, 10, 1, 0, [req3])
    task2 = Task.new(2, 2, 15, 10, 2, 0, [req1])
    task3 = Task.new(3, 2, 15, 10, 3, 0, [req1_2, req3, req4])
    $taskList = [task1, task2, task3]
    
    p B(task1)
  end
  
  def test_beginTime
    task1 = Task.new(1, 1, 6, 20, 1, 2, [@req6_LongLong4, @req1_Long1, @req6_LongLong4.clone, @req12_LongLong2.clone, @req4_Short1.clone])
    task2 = Task.new(2, 1, 6, 10, 2, 2, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 2, [@req12_LongLong2])
    
    #pp task1
    tc = TaskCUI.new(task1)
    #tc.show_task_char
  end
  
  def test_lowest_priority_task(proc)
    gm = GroupManager.instance
    rm = RequireManager.instance
    tm = TaskManager.instance
    
  end
end