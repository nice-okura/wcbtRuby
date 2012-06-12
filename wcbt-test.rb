#! /usr/bin/ruby
# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__))
require "task"
require "test/unit"
require "pp"
require "task-CUI"
require "manager"

class Test_wcbt < Test::Unit::TestCase
  include WCBT
  def setup
    #
    # Groupクラス定義
    # Group.new(group, kind)
    #
    @grp1 = Group.new(1, LONG)
    @grp2 = Group.new(2, SHORT)
    @grp3 = Group.new(3, LONG)
    @grp4 = Group.new(4, SHORT)
    
    @grp0 = Group.new(0, LONG) # dummy Resource
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
  
  def test_init_computing
    task1 = Task.new(1, 1, 60, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 60, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 60, 10, 3, 0, [@req12_LongLong2])

    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert_equal(3, $WCLR.size) # タスク数
    assert_equal(1, WCLR(task1).size)
    assert_equal(2, WCLR(task2).size)
    assert_equal(1, WCLR(task3).size)
    
    assert_equal(0, $WCSR.size)
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

    $task_list = [task1, task2, task3]
    init_computing($task_list)
    #pp $WCLR
    #pp @req6_LongLong4
    assert_equal(1, WCLR(task1).size)
    assert_equal(4, WCLR(task1)[0].time)
    assert_equal(2, WCLR(task2).size)
    assert_equal(4, WCLR(task2)[0].time)
    assert_equal(1, WCLR(task2)[1].time)
    assert_equal(1, WCLR(task3).size)
    assert_equal(2, WCLR(task3)[0].time)
    
    assert_equal(0, WCSR(task1).size)
    assert_equal(0, WCSR(task2).size)
    assert_equal(0, WCSR(task3).size)
    
    $task_list = [task4, task5, task6]
    init_computing($task_list)
 
    assert_equal(1, WCLR(task4).size)
    assert_equal(1, WCLR(task5).size)
    assert_equal(1, WCLR(task6).size)
    assert_equal(0, WCSR(task4).size)
    assert_equal(1, WCSR(task5).size)
    assert_equal(0, WCSR(task6).size)

    $task_list = [task7, task8, task9]
    init_computing($task_list)
    
    assert_equal(0, WCLR(task7).size)
    assert_equal(0, WCLR(task8).size)
    assert_equal(0, WCLR(task9).size)
  
    assert_equal(1, WCSR(task7).size)
    assert_equal(2, WCSR(task8).size)
    assert_equal(1, WCSR(task9).size)
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

    $task_list = [task1, task2, task3]
    init_computing($task_list)
    assert(wclx(task2, task1).size == 4)
    assert(wclx(task3, task1).size == 2)
    assert(wcsx(task2, task1).size == 0)
    assert(wcsx(task3, task1).size == 0)
    $task_list = [task4, task5, task6]
    init_computing($task_list)

    assert_equal(2, wclx(task5, task4).size)
    assert_equal(2, wclx(task6, task4).size)
    assert_equal(2, wcsx(task5, task4).size)
    assert_equal(0, wcsx(task6, task4).size)
    $task_list = [task7, task8, task9]
    init_computing($task_list)

    assert_equal(0, wclx(task8, task7).size)
    assert_equal(0, wclx(task9, task7).size)
    assert_equal(4, wcsx(task8, task7).size)
    assert_equal(2, wcsx(task9, task7).size)

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
    
    $task_list = [task1, task2, task3]
    init_computing($task_list)
    assert_equal(1, task1.req_list.size )
    assert_equal(2, task2.req_list.size )
    assert_equal(1, task3.req_list.size )
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)
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
    
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert_equal(1, task1.get_long_require_array.size )
    assert_equal(2, task2.get_long_require_array.size )
    assert_equal(1, task3.get_long_require_array.size )
    assert_equal(0, task1.get_short_require_array.size )
    assert_equal(0, task2.get_short_require_array.size )
    assert_equal(0, task3.get_short_require_array.size )

    $task_list = [task4, task5, task6]
    init_computing($task_list)

    assert_equal(1, task4.get_long_require_array.size )
    assert_equal(1, task5.get_long_require_array.size )
    assert_equal(1, task6.get_long_require_array.size )
    assert_equal(0, task4.get_short_require_array.size )
    assert_equal(1, task5.get_short_require_array.size )
    assert_equal(0, task6.get_short_require_array.size )

    $task_list = [task7, task8, task9]
    init_computing($task_list)

    assert_equal(0, task7.get_long_require_array.size )
    assert_equal(0, task8.get_long_require_array.size )
    assert_equal(0, task9.get_long_require_array.size )
    assert_equal(1, task7.get_short_require_array.size )
    assert_equal(2, task8.get_short_require_array.size )
    assert_equal(1, task9.get_short_require_array.size )

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
    
    
    assert_equal(2, task1.get_all_require.size )
    assert_equal(3, task2.get_all_require.size )
    assert_equal(2, task3.get_all_require.size )
    
    assert_equal(2, task4.get_all_require.size )
    assert_equal(3, task5.get_all_require.size )
    assert_equal(2, task6.get_all_require.size )
    
    assert_equal(2, task7.get_all_require.size )
    assert_equal(3, task8.get_all_require.size )
    assert_equal(2, task9.get_all_require.size )
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)
    
    #    pp wclx(task1, task1)
    assert_equal(9, bbt(task2, task1) )
    assert_equal(4, bbt(task3, task1) )  

    $task_list = [task4, task5, task6]
    init_computing($task_list)

    assert_equal(8, bbt(task5, task4) )    
    assert_equal(4, bbt(task6, task4) )
    
    $task_list = [task7, task8, task9]
    init_computing($task_list)

    assert_equal(0, bbt(task8, task7) )
    assert_equal(0, bbt(task9, task7) )    

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
    $task_list = [task1, task2, task3]
    init_computing($task_list)
    
    assert_equal(9, BB(task1) )
    assert_equal(0, BB(task2) )
    assert_equal(0, BB(task3) )
    
    $task_list = [task4, task5, task6]
    init_computing($task_list)

    assert_equal(8, BB(task4) )
    assert_equal(0, BB(task5) )
    assert_equal(0, BB(task6) )
    
    $task_list = [task7, task8, task9]
    init_computing($task_list)
    
    assert_equal(0, BB(task7) )
    assert_equal(0, BB(task8) )
    assert_equal(0, BB(task9) )
  end
  
  def test_BB2  
    ###
    @manager = AllManager.new
    @manager.load_tasks("120613")

    #ts = TaskSet.new(@manager.tm.get_task_array)
    #ts.show_taskset
    t2 = @manager.tm.get_task(2)
    t6 = @manager.tm.get_task(6)

    assert_equal(4, BB(t2))
    
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)
    
    assert_equal(0, abr(task1).size )
    assert_equal(0, abr(task2).size )
    assert_equal(0, abr(task3).size )
    $task_list = [task4, task5, task6]
    
    init_computing($task_list)
    
    assert_equal(2, abr(task4).size )
    assert_equal(0, abr(task5).size )
    assert_equal(0, abr(task6).size )
    $task_list = [task7, task8, task9]
    init_computing($task_list)
    #taskset = TaskSet.new($task_list)
    #taskset.show_taskset
    
    assert_equal(4, abr(task7).size )
    assert_equal(0, abr(task8).size )
    assert_equal(0, abr(task9).size )
  end
  
  def test_procList
    task1 = Task.new(1, 1, 6, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 6, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 6, 10, 3, 0, [@req12_LongLong2])
    $task_list = [task1, task2, task3]
    init_computing($task_list)
    
    assert(procList == [1,2])
  end

  def test_AB
    task1 = Task.new(1, 1, 600, 10, 1, 0, [@req6_LongLong4])
    task2 = Task.new(2, 1, 600, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    task3 = Task.new(3, 2, 600, 10, 3, 0, [@req12_LongLong2])
    
    task4 = Task.new(4, 1, 600, 10, 1, 0, [@req8_LongShort4])
    task5 = Task.new(5, 1, 600, 10, 2, 0, [@req8_LongShort4, @req4_Short1])
    task6 = Task.new(6, 2, 600, 10, 3, 0, [@req14_LongShort2])
    
    task7 = Task.new(7, 1, 600, 10, 1, 0, [@req10_ShortShort4])
    task8 = Task.new(8, 1, 600, 10, 2, 0, [@req10_ShortShort4, @req4_Short1])
    task9 = Task.new(9, 2, 600, 10, 3, 0, [@req16_ShortShort2])
    $task_list = [task1, task2, task3]
    init_computing($task_list)
    
    assert_equal(0, AB(task1))
    assert_equal(0, AB(task2))
    assert_equal(0, AB(task3))

    $task_list = [task4, task5, task6]
    #taskset = TaskSet.new($task_list)
    #taskset.show_taskset
    init_computing($task_list)
    
    assert_equal(2, AB(task4))
    assert_equal(0, AB(task5))
    assert_equal(0, AB(task6))
    
    $task_list = [task7, task8, task9]
    init_computing($task_list)
    
    assert_equal(4, AB(task7))
    assert_equal(0, AB(task8))
    assert_equal(0, AB(task9))
    #p "end_test_AB"
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)
    
    
    assert_equal(2, partition(1).size )
    assert_equal(1, partition(2).size )
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)
    
    
    assert_equal(1, ndbtg(task2, task1, 1) )
    assert_equal(0, ndbtg(task2, task1, 2) )
    assert_equal(0, ndbtg(task2, task1, 3) )
    assert_equal(0, ndbtg(task2, task1, 4) )
    
    assert_equal(1, ndbtg(task3, task1, 1) )
    assert_equal(0, ndbtg(task3, task1, 2) )
    assert_equal(0, ndbtg(task3, task1, 3) )
    assert_equal(0, ndbtg(task3, task1, 4) )
    
    $task_list = [task4, task5, task6]
    init_computing($task_list)

    assert_equal(1, ndbtg(task6, task4, 1) )
    assert_equal(0, ndbtg(task6, task4, 2) )
    assert_equal(0, ndbtg(task6, task4, 3) )
    assert_equal(0, ndbtg(task6, task4, 4) )
    
    $task_list = [task7, task8, task9]
    init_computing($task_list)

    assert_equal(0, ndbtg(task9, task7, 1) )
    assert_equal(0, ndbtg(task9, task7, 2) )
    assert_equal(0, ndbtg(task9, task7, 3) )
    assert_equal(0, ndbtg(task9, task7, 4) )
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
    
    $task_list = [task1, task2, task3]
    init_computing($task_list)
    
    assert_equal(1, ndbt(task2, task1) )
    assert_equal(1, ndbt(task3, task1) )
    
    $task_list = [task4, task5, task6]
    init_computing($task_list)

    assert_equal(1, ndbt(task6, task4) )
    
    $task_list = [task7, task8, task9]
    init_computing($task_list)
    
    assert_equal(0, ndbt(task9, task7) )
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)
    
    assert_equal(1, ndbp(task1, 2) )

    $task_list = [task4, task5, task6]
    init_computing($task_list)
    
    assert_equal(1, ndbp(task4, 2) )
    
    $task_list = [task7, task8, task9]
    init_computing($task_list)
    
    assert_equal(0, ndbp(task7, 2) )
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert_equal(2, rblt(task3, task1) )
    
    $task_list = [task4, task5, task6]
    init_computing($task_list)

    assert_equal(2, rblt(task6, task4) )
    
    $task_list = [task7, task8, task9]
    init_computing($task_list)
    
    assert_equal(0, rblt(task9, task7) )
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert_equal(2, rblp(task1, 2) )
    
    $task_list = [task4, task5, task6]
    init_computing($task_list)

    assert_equal(2, rblp(task4, 2) )
    
    $task_list = [task7, task8, task9]
    init_computing($task_list)

    assert_equal(0, rblp(task7, 2) )
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert_equal(2, rbl(task1) )
    
    $task_list = [task4, task5, task6]
    init_computing($task_list)
    
    assert_equal(2, rbl(task4) )
    
    $task_list = [task7, task8, task9]
    init_computing($task_list)

    assert_equal(0, rbl(task7) )
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert_equal(0, wcsp(task1, 2).size )
    
    $task_list = [task4, task5, task6]
    init_computing($task_list)

    assert_equal(0, wcsp(task4, 2).size )
    
    $task_list = [task7, task8, task9]
    init_computing($task_list)

    assert_equal(2, wcsp(task7, 2).size )
  end
  
  def test_rbspLB
    long1 = Group.new(1, LONG)
    long2 = Group.new(2, LONG)
    short1 = Group.new(3, SHORT)
    short2 = Group.new(4, SHORT)
    short3 = Group.new(5, SHORT)
    
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert(rbl(task1)==12)
    assert(rbs(task1)==10)
  end
  
  def test_wcsxg
    long1 = Group.new(1, LONG)
    long2 = Group.new(2, LONG)
    short1 = Group.new(3, SHORT)
    short2 = Group.new(4, SHORT)
    short3 = Group.new(5, SHORT)
    
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert_equal(0, wcsxg(task2, task1, 3).size )
    assert_equal(0, wcsxg(task2, task1, 4).size )
    assert_equal(3, wcsxg(task3, task1, 3).size )
    assert_equal(3, wcsxg(task3, task1, 4).size )
  end
  
  def test_wcspg
    long1 = Group.new(1, LONG)
    long2 = Group.new(2, LONG)
    short1 = Group.new(3, SHORT)
    short2 = Group.new(4, SHORT)
    short3 = Group.new(5, SHORT)
    
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert_equal(3, wcspg(task1, 2, 3).size )
    assert_equal(3, wcspg(task1, 2, 4).size )
  end
  
  def test_sbgp
    long1 = Group.new(1, LONG)
    long2 = Group.new(2, LONG)
    short1 = Group.new(3, SHORT)
    short2 = Group.new(4, SHORT)
    short3 = Group.new(5, SHORT)
    
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert_equal(5, sbgp(task1, 3, 2) )
    assert_equal(2, sbgp(task1, 4, 2) ) 
  end
  
  def test_sbgSB
    long1 = Group.new(1, LONG)
    long2 = Group.new(2, LONG)
    short1 = Group.new(3, SHORT)
    short2 = Group.new(4, SHORT)
    short3 = Group.new(5, SHORT)
    
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    assert_equal(5, sbg(task1, 3) )
    assert_equal(7, SB(task1) )
  end
  
  def test_DB
    long1 = Group.new(1, LONG)
    long2 = Group.new(2, LONG)
    short1 = Group.new(3, SHORT)
    short2 = Group.new(4, SHORT)
    short3 = Group.new(5, SHORT)
    
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)

    #p B(task1)
  end
  
  def test_B
    long1 = Group.new(1, LONG)
    long2 = Group.new(2, LONG)
    long3 = Group.new(3, LONG)
    
    req1 = Req.new(1, long3, 1, [])
    req2 = Req.new(2, long1, 2, [])
    req3 = Req.new(3, long2, 2, [])
    req4 = Req.new(4, long3, 2, [])
    
    task1 =Task.new(1, 1, 12, 1, 1, 0, [req1])
    task2 =Task.new(2, 1, 12, 3, 2, 0, [req2])
    task3 =Task.new(3, 1, 12, 3, 3, 0, [req3])
    task4 =Task.new(4, 2, 6, 2, 4, 0, [req3])
    task5 =Task.new(5, 3, 12, 10, 5, 0, [req4, req4])
    $task_list = [task1, task2, task3, task4, task5]
    init_computing($task_list)
    
    assert_equal(10, B(task1))
  end
  
  def test_B2
    long1 = Group.new(1, LONG)
    long2 = Group.new(2, LONG)
    short1 = Group.new(3, SHORT)
    short2 = Group.new(4, SHORT)
    short3 = Group.new(5, SHORT)
    
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
    $task_list = [task1, task2, task3]
    init_computing($task_list)
#    ts = TaskSet.new($task_list)
#    ts.show_taskset
    assert_equal(7, B(task1))
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

  def test_120430_fortest
    @manager = AllManager.new
    @manager.load_tasks("120430_fortest")
    
    #ts = TaskSet.new(@manager.tm.get_task_array)
    #ts.show_taskset

    t1 = @manager.tm.get_task(1)
    t2 = @manager.tm.get_task(2)
    t3 = @manager.tm.get_task(3)
    t4 = @manager.tm.get_task(4)
    t5 = @manager.tm.get_task(5)
    t6 = @manager.tm.get_task(6)
    t7 = @manager.tm.get_task(7)
    t8 = @manager.tm.get_task(8)
    
    assert_equal(2, wclx(t2, t1).size)
    assert_equal(4, wclx(t3, t1).size)
    assert_equal(2, wclx(t4, t1).size)
    assert_equal(2, wclx(t5, t1).size)
    assert_equal(3, wclx(t6, t1).size)
    assert_equal(0, wclx(t7, t1).size)
    assert_equal(0, wclx(t8, t1).size)
    
    assert_equal(3, wclx(t1, t2).size)
    assert_equal(5, wclx(t3, t2).size)
    assert_equal(3, wclx(t4, t2).size)
    assert_equal(2, wclx(t5, t2).size)
    assert_equal(3, wclx(t6, t2).size)
    assert_equal(0, wclx(t7, t2).size)
    assert_equal(0, wclx(t8, t2).size)

    assert_equal(2, wclx(t1, t3).size)
    assert_equal(2, wclx(t2, t3).size)
    assert_equal(2, wclx(t4, t3).size)
    assert_equal(2, wclx(t5, t3).size)
    assert_equal(2, wclx(t6, t3).size)
    assert_equal(0, wclx(t7, t3).size)
    assert_equal(0, wclx(t8, t3).size)

    assert_equal(8, wclx(t1, t7).size)
    assert_equal(6, wclx(t2, t7).size)
    assert_equal(17, wclx(t3, t7).size)
    assert_equal(8, wclx(t4, t7).size)
    assert_equal(3, wclx(t5, t7).size)
    assert_equal(8, wclx(t6, t7).size)
    assert_equal(0, wclx(t8, t7).size)

    #
    # BB
    #
    assert_equal(4, bbt(t2, t1))
    assert_equal(4, bbt(t3, t1))
    assert_equal(6, bbt(t4, t1))
    assert_equal(4, bbt(t5, t1))
    assert_equal(4, bbt(t6, t1))
    assert_equal(0, bbt(t7, t1))
    assert_equal(0, bbt(t8, t1))

    assert_equal(4, bbt(t1, t2))
    assert_equal(4, bbt(t3, t2))
    assert_equal(6, bbt(t4, t2))
    assert_equal(4, bbt(t5, t2))
    assert_equal(4, bbt(t6, t2))
    assert_equal(0, bbt(t7, t2))
    assert_equal(0, bbt(t8, t2))

    assert_equal(4, bbt(t1, t3))
    assert_equal(4, bbt(t2, t3))
    assert_equal(6, bbt(t4, t3))
    assert_equal(4, bbt(t5, t3))
    assert_equal(4, bbt(t6, t3))
    assert_equal(0, bbt(t7, t3))
    assert_equal(0, bbt(t8, t3))
    
    assert_equal(2, bbt(t1, t7))
    assert_equal(2, bbt(t2, t7))
    assert_equal(2, bbt(t3, t7))
    assert_equal(3, bbt(t4, t7))
    assert_equal(2, bbt(t5, t7))
    assert_equal(2, bbt(t6, t7))
    assert_equal(0, bbt(t8, t7))

    assert_equal(0, t1.bb)
    assert_equal(4, t2.bb)
    assert_equal(0, t3.bb)
    assert_equal(4, t4.bb)
    assert_equal(0, t5.bb)
    assert_equal(4, t6.bb)
    assert_equal(2, t7.bb)
    assert_equal(2, t8.bb)
    
  end
  
  def test_120502
    @manager = AllManager.new
    @manager.load_tasks("120502_fortest")
  
    t1 = @manager.tm.get_task(1)
    t2 = @manager.tm.get_task(2)
    t3 = @manager.tm.get_task(3)
    t4 = @manager.tm.get_task(4)
    t5 = @manager.tm.get_task(5)
    t6 = @manager.tm.get_task(6)

    assert_equal(0, ndbt(t1, t2))
    assert_equal(0, ndbp(t2, 2))
    assert_equal(2, ndbp(t4, 2))
    assert_equal(0, ndbp(t6, 2))

    assert_equal(0, rbl(t2))
    assert_equal(0, rbs(t2))
    assert_equal(8, rbl(t4))
    assert_equal(4, rbs(t4))
    assert_equal(0, rbl(t6))
    assert_equal(0, rbs(t6))
    
    assert_equal(0, bbt(t6, t4))
    assert_equal(4, bbt(t3, t1))
    assert_equal(2, abr(t2).size)
    assert_equal(2, AB(t2))
    assert_equal(4, AB(t4))
    assert_equal(0, AB(t6))
    
   end

end
 
