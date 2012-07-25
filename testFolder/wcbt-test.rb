#! /usr/bin/ruby
# -*- coding: utf-8 -*-

$:.unshift(File.dirname(__FILE__))
require "task"
require "test/unit"
require "pp"
require "task-CUI"
require "manager"

TEST_FOLDER = "testFolder/"
class Test_wcbt < Test::Unit::TestCase
  include WCBT
  
  def set_taskset(filename)
    @manager.all_data_clear
    @manager.load_tasks(filename)
    init_computing(@manager.tm.get_task_array)    
  end
  
  def setup
    # setupはtest_xxxのメソッドが実行される度に呼び出される
    
    @manager = AllManager.new
    @manager.all_data_clear
    #
    # Groupクラス定義
    # Group.new(group, kind)
    #
    @grp1 = Group.new(1, LONG)
    @grp2 = Group.new(2, SHORT)
    @grp3 = Group.new(3, LONG)
    @grp4 = Group.new(4, SHORT)
    
#    @grp0 = Group.new(0, LONG) # dummy Resource
#    @req0 = Req.new(0, 0, 0, []) # dummy Require
    
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

=begin
  def test_init_computing
    task1 = Task.new(1, 1, 60, 10, 1, 0, [@req6_LongLong4])
    = Task.new(2, 1, 60, 10, 2, 0, [@req6_LongLong4, @req1_Long1])
    TaskManager.get_task(3) = Task.new(3, 2, 60, 10, 3, 0, [@req12_LongLong2])

    $task_list = [task1, TaskManager.get_task(2), TaskManager.get_task(3)]
    init_computing($task_list)

    assert_equal(3, $WCLR.size) # タスク数
    assert_equal(1, WCLR(task1).size)
    assert_equal(2, WCLR(TaskManager.get_task(2)).size)
    assert_equal(1, WCLR(TaskManager.get_task(3)).size)
    
    assert_equal(0, $WCSR.size)
  end
=end

  def test_WCLRWCLR
    set_taskset("#{TEST_FOLDER}for_many_test")

    assert_equal(3, WCLR(TaskManager.get_task(1)).size)
    assert_equal(2, WCLR(TaskManager.get_task(2)).size)
    assert_equal(3, WCLR(TaskManager.get_task(3)).size)
    assert_equal(2, WCLR(TaskManager.get_task(4)).size)
    assert_equal(2, WCLR(TaskManager.get_task(5)).size)
    assert_equal(1, WCLR(TaskManager.get_task(6)).size)
    assert_equal(0, WCLR(TaskManager.get_task(7)).size)
    assert_equal(1, WCLR(TaskManager.get_task(8)).size)
    assert_equal(4, WCLR(TaskManager.get_task(9)).size)
    assert_equal(1, WCLR(TaskManager.get_task(10)).size)
    assert_equal(3, WCLR(TaskManager.get_task(11)).size)
    assert_equal(2, WCLR(TaskManager.get_task(12)).size)
    assert_equal(1, WCLR(TaskManager.get_task(13)).size)
    assert_equal(2, WCLR(TaskManager.get_task(14)).size)
    assert_equal(3, WCLR(TaskManager.get_task(15)).size)
    assert_equal(2, WCLR(TaskManager.get_task(16)).size)
    
    assert_equal(0, WCLR(TaskManager.get_task(1)).size)
    assert_equal(1, WCLR(TaskManager.get_task(2)).size)
    assert_equal(1, WCLR(TaskManager.get_task(3)).size)
    assert_equal(1, WCLR(TaskManager.get_task(4)).size)
    assert_equal(1, WCLR(TaskManager.get_task(5)).size)
    assert_equal(2, WCLR(TaskManager.get_task(6)).size)
    assert_equal(3, WCLR(TaskManager.get_task(7)).size)
    assert_equal(3, WCLR(TaskManager.get_task(8)).size)
    assert_equal(0, WCLR(TaskManager.get_task(9)).size)
    assert_equal(2, WCLR(TaskManager.get_task(10)).size)
    assert_equal(0, WCLR(TaskManager.get_task(11)).size)
    assert_equal(2, WCLR(TaskManager.get_task(12)).size)
    assert_equal(2, WCLR(TaskManager.get_task(13)).size)
    assert_equal(1, WCLR(TaskManager.get_task(14)).size)
    assert_equal(0, WCLR(TaskManager.get_task(15)).size)
    assert_equal(1, WCLR(TaskManager.get_task(16)).size)

  end
  
  def test_wclxwcsx
    set_taskset("#{TEST_FOLDER}for_many_test")
    assert_equal(8 ,wclx(TaskManager.get_task(2), TaskManager.get_task(1)).size)
    assert_equal(9 ,wclx(TaskManager.get_task(3), TaskManager.get_task(1)).size)
    assert_equal(6 ,wclx(TaskManager.get_task(4), TaskManager.get_task(1)).size)
    assert_equal(6 ,wclx(TaskManager.get_task(5), TaskManager.get_task(1)).size)
    assert_equal(3 ,wclx(TaskManager.get_task(6), TaskManager.get_task(1)).size)
    assert_equal(0 ,wclx(TaskManager.get_task(7), TaskManager.get_task(1)).size)
    assert_equal(3 ,wclx(TaskManager.get_task(8), TaskManager.get_task(1)).size)
    assert_equal(8 ,wclx(TaskManager.get_task(9), TaskManager.get_task(1)).size)
    assert_equal(3 ,wclx(TaskManager.get_task(10), TaskManager.get_task(1)).size)
    assert_equal(6 ,wclx(TaskManager.get_task(11), TaskManager.get_task(1)).size)
    assert_equal(6 ,wclx(TaskManager.get_task(12), TaskManager.get_task(1)).size)
    assert_equal(3 ,wclx(TaskManager.get_task(13), TaskManager.get_task(1)).size)
    assert_equal(4 ,wclx(TaskManager.get_task(14), TaskManager.get_task(1)).size)
    assert_equal(9 ,wclx(TaskManager.get_task(15), TaskManager.get_task(1)).size)
    assert_equal(6 ,wclx(TaskManager.get_task(16), TaskManager.get_task(1)).size)

    assert_equal(4 ,wcsx(TaskManager.get_task(2), TaskManager.get_task(1)).size)
    assert_equal(3 ,wcsx(TaskManager.get_task(3), TaskManager.get_task(1)).size)
    assert_equal(3 ,wcsx(TaskManager.get_task(4), TaskManager.get_task(1)).size)
    assert_equal(3 ,wcsx(TaskManager.get_task(5), TaskManager.get_task(1)).size)
    assert_equal(6 ,wcsx(TaskManager.get_task(6), TaskManager.get_task(1)).size)
    assert_equal(9 ,wcsx(TaskManager.get_task(7), TaskManager.get_task(1)).size)
    assert_equal(9 ,wcsx(TaskManager.get_task(8), TaskManager.get_task(1)).size)
    assert_equal(0 ,wcsx(TaskManager.get_task(9), TaskManager.get_task(1)).size)
    assert_equal(6 ,wcsx(TaskManager.get_task(10), TaskManager.get_task(1)).size)
    assert_equal(0 ,wcsx(TaskManager.get_task(11), TaskManager.get_task(1)).size)
    assert_equal(6 ,wcsx(TaskManager.get_task(12), TaskManager.get_task(1)).size)
    assert_equal(6 ,wcsx(TaskManager.get_task(13), TaskManager.get_task(1)).size)
    assert_equal(2 ,wcsx(TaskManager.get_task(14), TaskManager.get_task(1)).size)
    assert_equal(0 ,wcsx(TaskManager.get_task(15), TaskManager.get_task(1)).size)
    assert_equal(3 ,wcsx(TaskManager.get_task(16), TaskManager.get_task(1)).size)

  end
    
  def test_req_list
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(1, TaskManager.get_task(1).req_list.size )
    assert_equal(2, TaskManager.get_task(2).req_list.size )
    assert_equal(1, TaskManager.get_task(3).req_list.size )
  end
  
  def test_checkOutermost
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert(TaskManager.get_task(1).all_require[0].outermost == true)
    assert(TaskManager.get_task(1).all_require[1].outermost == true)
    assert(TaskManager.get_task(2).all_require[0].outermost == true)
    assert(TaskManager.get_task(2).all_require[1].outermost == true)
    assert(TaskManager.get_task(2).all_require[2].outermost == true)
    assert(TaskManager.get_task(3).all_require[0].outermost == true)
    assert(TaskManager.get_task(3).all_require[1].outermost == true)    
  end
  
  def test_getLongShortResArray
    # ネストはカウントしない
    set_taskset("#{TEST_FOLDER}for_many_test")

    assert_equal(3, TaskManager.get_task(1).long_require_array.size )
    assert_equal(2, TaskManager.get_task(2).long_require_array.size )
    assert_equal(2, TaskManager.get_task(3).long_require_array.size ) 
    assert_equal(2, TaskManager.get_task(4).long_require_array.size )
    assert_equal(2, TaskManager.get_task(5).long_require_array.size )
    assert_equal(1, TaskManager.get_task(6).long_require_array.size )
    assert_equal(0, TaskManager.get_task(7).long_require_array.size )
    assert_equal(1, TaskManager.get_task(8).long_require_array.size )

    assert_equal(0, TaskManager.get_task(1).short_require_array.size )
    assert_equal(1, TaskManager.get_task(2).short_require_array.size )
    assert_equal(1, TaskManager.get_task(3).short_require_array.size )
    assert_equal(1, TaskManager.get_task(4).short_require_array.size )
    assert_equal(1, TaskManager.get_task(5).short_require_array.size )
    assert_equal(2, TaskManager.get_task(6).short_require_array.size )
    assert_equal(3, TaskManager.get_task(7).short_require_array.size )
    assert_equal(3, TaskManager.get_task(8).short_require_array.size )


    

  end
  
  def test_all_require
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(2, TaskManager.get_task(1).all_require.size )
    assert_equal(3, TaskManager.get_task(2).all_require.size )
    assert_equal(2, TaskManager.get_task(3).all_require.size )
    
    set_taskset("#{TEST_FOLDER}wcbt-test_2")
    assert_equal(2, TaskManager.get_task(4).all_require.size )
    assert_equal(3, TaskManager.get_task(5).all_require.size )
    assert_equal(2, TaskManager.get_task(6).all_require.size )
    
    set_taskset("#{TEST_FOLDER}wcbt-test_3")
    assert_equal(2, TaskManager.get_task(7).all_require.size )
    assert_equal(3, TaskManager.get_task(8).all_require.size )
    assert_equal(2, TaskManager.get_task(9).all_require.size )
  end

  def test_bbt
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(9, bbt(TaskManager.get_task(2), TaskManager.get_task(1)) )
    assert_equal(4, bbt(TaskManager.get_task(3), TaskManager.get_task(1)) )  

    set_taskset("#{TEST_FOLDER}wcbt-test_2")
    assert_equal(8, bbt(TaskManager.get_task(5), TaskManager.get_task(4)) )    
    assert_equal(4, bbt(TaskManager.get_task(6), TaskManager.get_task(4)) )
    
    set_taskset("#{TEST_FOLDER}wcbt-test_3")
    assert_equal(0, bbt(TaskManager.get_task(8), TaskManager.get_task(7)) )
    assert_equal(0, bbt(TaskManager.get_task(9), TaskManager.get_task(7)) )    

  end
  
  def test_BB
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(9, BB(TaskManager.get_task(1)) )
    assert_equal(0, BB(TaskManager.get_task(2)) )
    assert_equal(0, BB(TaskManager.get_task(3)) )

    set_taskset("#{TEST_FOLDER}wcbt-test_2")
    assert_equal(8, BB(TaskManager.get_task(4)) )
    assert_equal(0, BB(TaskManager.get_task(5)) )
    assert_equal(0, BB(TaskManager.get_task(6)) )
    
    set_taskset("#{TEST_FOLDER}wcbt-test_3")
    assert_equal(0, BB(TaskManager.get_task(7)) )
    assert_equal(0, BB(TaskManager.get_task(8)) )
    assert_equal(0, BB(TaskManager.get_task(9)) )
  end
  
  def test_BB2  
    @manager.load_tasks("#{TEST_FOLDER}120613")

    #ts = TaskSet.new(@manager.tm.get_task_array)
    #ts.show_taskset
    t2 = TaskManager.get_task(2)
    t6 = TaskManager.get_task(6)

    assert_equal(4, BB(t2))
    
  end

  def test_abr
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(0, abr(TaskManager.get_task(1)).size )
    assert_equal(0, abr(TaskManager.get_task(2)).size )
    assert_equal(0, abr(TaskManager.get_task(3)).size )

    set_taskset("#{TEST_FOLDER}wcbt-test_2")
    assert_equal(2, abr(TaskManager.get_task(4)).size )
    assert_equal(0, abr(TaskManager.get_task(5)).size )
    assert_equal(0, abr(TaskManager.get_task(6)).size )

    set_taskset("#{TEST_FOLDER}wcbt-test_3")
    assert_equal(4, abr(TaskManager.get_task(7)).size )
    assert_equal(0, abr(TaskManager.get_task(8)).size )
    assert_equal(0, abr(TaskManager.get_task(9)).size )
  end
  
  def test_procList
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert(procList == [1,2])
  end

  def test_AB
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(0, AB(TaskManager.get_task(1)))
    assert_equal(0, AB(TaskManager.get_task(2)))
    assert_equal(0, AB(TaskManager.get_task(3)))

    set_taskset("#{TEST_FOLDER}wcbt-test_2")
    assert_equal(2, AB(TaskManager.get_task(4)))
    assert_equal(0, AB(TaskManager.get_task(5)))
    assert_equal(0, AB(TaskManager.get_task(6)))
    
    set_taskset("#{TEST_FOLDER}wcbt-test_3")
    assert_equal(4, AB(TaskManager.get_task(7)))
    assert_equal(0, AB(TaskManager.get_task(8)))
    assert_equal(0, AB(TaskManager.get_task(9)))
    #p "end_test_AB"
  end

  def test_ndbtg
    set_taskset("#{TEST_FOLDER}for_test_LB")
    assert_equal(2, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 1) )
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 2) )
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 3) )
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 4) )
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 5) )
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 6) )
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 7) )
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 8) )

    assert_equal(2, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 1) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 2) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 3) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 4) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 5) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 6) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 7) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 8) )

    assert_equal(1, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 1) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 2) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 3) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 4) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 5) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 6) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 7) )
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 8) )

    assert_equal(2, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 1) )
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 2) )
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 3) )
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 4) )
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 5) )
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 6) )
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 7) )
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 8) )

    # ネストしている場合のテスト
    set_taskset("#{TEST_FOLDER}for_test_LB_nest")
    #    p    LR(TaskManager.get_task(1))
    #pp WCLR(TaskManager.get_task(7))
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 1) )
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 2) )
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 3) )
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 4) )
    assert_equal(1, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 5) )
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 6) )
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 7) )
    assert_equal(1, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 8) )

  end
    
  def test_ndbt
    set_taskset("#{TEST_FOLDER}for_test_LB")
    assert_equal(2, ndbt(TaskManager.get_task(2), TaskManager.get_task(1)) )
    assert_equal(2, ndbt(TaskManager.get_task(3), TaskManager.get_task(1)) )
    assert_equal(0, ndbt(TaskManager.get_task(4), TaskManager.get_task(1)) )
    assert_equal(2, ndbt(TaskManager.get_task(5), TaskManager.get_task(1)) )
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(1)) )
    assert_equal(0, ndbt(TaskManager.get_task(7), TaskManager.get_task(1)) )
    assert_equal(0, ndbt(TaskManager.get_task(8), TaskManager.get_task(1)) )
    assert_equal(2, ndbt(TaskManager.get_task(9), TaskManager.get_task(1)) )
    assert_equal(0, ndbt(TaskManager.get_task(10), TaskManager.get_task(1)) )
    assert_equal(2, ndbt(TaskManager.get_task(11), TaskManager.get_task(1)) )
    assert_equal(0, ndbt(TaskManager.get_task(12), TaskManager.get_task(1)) )
    assert_equal(2, ndbt(TaskManager.get_task(13), TaskManager.get_task(1)) )
    assert_equal(2, ndbt(TaskManager.get_task(14), TaskManager.get_task(1)) )
    assert_equal(2, ndbt(TaskManager.get_task(15), TaskManager.get_task(1)) )
    assert_equal(0, ndbt(TaskManager.get_task(16), TaskManager.get_task(1)) )

    assert_equal(1, ndbt(TaskManager.get_task(1), TaskManager.get_task(2)) )
    assert_equal(1, ndbt(TaskManager.get_task(3), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(4), TaskManager.get_task(2)) )
    assert_equal(1, ndbt(TaskManager.get_task(5), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(7), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(8), TaskManager.get_task(2)) )
    assert_equal(1, ndbt(TaskManager.get_task(9), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(10), TaskManager.get_task(2)) )
    assert_equal(1, ndbt(TaskManager.get_task(11), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(12), TaskManager.get_task(2)) )
    assert_equal(1, ndbt(TaskManager.get_task(13), TaskManager.get_task(2)) )
    assert_equal(1, ndbt(TaskManager.get_task(14), TaskManager.get_task(2)) )
    assert_equal(1, ndbt(TaskManager.get_task(15), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(16), TaskManager.get_task(2)) )

    assert_equal(2, ndbt(TaskManager.get_task(1), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(2), TaskManager.get_task(3)) )
    assert_equal(1, ndbt(TaskManager.get_task(4), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(5), TaskManager.get_task(3)) )
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(3)) )
    assert_equal(1, ndbt(TaskManager.get_task(7), TaskManager.get_task(3)) )
    assert_equal(1, ndbt(TaskManager.get_task(8), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(9), TaskManager.get_task(3)) )
    assert_equal(0, ndbt(TaskManager.get_task(10), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(11), TaskManager.get_task(3)) )
    assert_equal(0, ndbt(TaskManager.get_task(12), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(13), TaskManager.get_task(3)) )
    assert_equal(3, ndbt(TaskManager.get_task(14), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(15), TaskManager.get_task(3)) )
    assert_equal(1, ndbt(TaskManager.get_task(16), TaskManager.get_task(3)) )

    assert_equal(2, ndbt(TaskManager.get_task(1), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(2), TaskManager.get_task(3)) )
    assert_equal(1, ndbt(TaskManager.get_task(4), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(5), TaskManager.get_task(3)) )
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(3)) )
    assert_equal(1, ndbt(TaskManager.get_task(7), TaskManager.get_task(3)) )
    assert_equal(1, ndbt(TaskManager.get_task(8), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(9), TaskManager.get_task(3)) )
    assert_equal(0, ndbt(TaskManager.get_task(10), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(11), TaskManager.get_task(3)) )
    assert_equal(0, ndbt(TaskManager.get_task(12), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(13), TaskManager.get_task(3)) )
    assert_equal(3, ndbt(TaskManager.get_task(14), TaskManager.get_task(3)) )
    assert_equal(2, ndbt(TaskManager.get_task(15), TaskManager.get_task(3)) )
    assert_equal(1, ndbt(TaskManager.get_task(16), TaskManager.get_task(3)) )

    assert_equal(0, ndbt(TaskManager.get_task(1), TaskManager.get_task(4)) )
    assert_equal(0, ndbt(TaskManager.get_task(2), TaskManager.get_task(4)) )
    assert_equal(1, ndbt(TaskManager.get_task(3), TaskManager.get_task(4)) )
    assert_equal(1, ndbt(TaskManager.get_task(5), TaskManager.get_task(4)) )
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(4)) )
    assert_equal(1, ndbt(TaskManager.get_task(7), TaskManager.get_task(4)) )
    assert_equal(2, ndbt(TaskManager.get_task(8), TaskManager.get_task(4)) )
    assert_equal(1, ndbt(TaskManager.get_task(9), TaskManager.get_task(4)) )
    assert_equal(2, ndbt(TaskManager.get_task(10), TaskManager.get_task(4)) )
    assert_equal(1, ndbt(TaskManager.get_task(11), TaskManager.get_task(4)) )
    assert_equal(2, ndbt(TaskManager.get_task(12), TaskManager.get_task(4)) )
    assert_equal(1, ndbt(TaskManager.get_task(13), TaskManager.get_task(4)) )
    assert_equal(2, ndbt(TaskManager.get_task(14), TaskManager.get_task(4)) )
    assert_equal(1, ndbt(TaskManager.get_task(15), TaskManager.get_task(4)) )
    assert_equal(2, ndbt(TaskManager.get_task(16), TaskManager.get_task(4)) )

    assert_equal(2, ndbt(TaskManager.get_task(1), TaskManager.get_task(5)) )
    assert_equal(2, ndbt(TaskManager.get_task(2), TaskManager.get_task(5)) )
    assert_equal(2, ndbt(TaskManager.get_task(3), TaskManager.get_task(5)) )
    assert_equal(1, ndbt(TaskManager.get_task(4), TaskManager.get_task(5)) )
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(5)) )
    assert_equal(0, ndbt(TaskManager.get_task(7), TaskManager.get_task(5)) )
    assert_equal(0, ndbt(TaskManager.get_task(8), TaskManager.get_task(5)) )
    assert_equal(2, ndbt(TaskManager.get_task(9), TaskManager.get_task(5)) )
    assert_equal(1, ndbt(TaskManager.get_task(10), TaskManager.get_task(5)) )
    assert_equal(3, ndbt(TaskManager.get_task(11), TaskManager.get_task(5)) )
    assert_equal(1, ndbt(TaskManager.get_task(12), TaskManager.get_task(5)) )
    assert_equal(2, ndbt(TaskManager.get_task(13), TaskManager.get_task(5)) )
    assert_equal(2, ndbt(TaskManager.get_task(14), TaskManager.get_task(5)) )
    assert_equal(3, ndbt(TaskManager.get_task(15), TaskManager.get_task(5)) )
    assert_equal(1, ndbt(TaskManager.get_task(16), TaskManager.get_task(5)) )

    
    # ネストしている場合のテスト
    set_taskset "#{TEST_FOLDER}for_test_LB_nest"
    assert_equal(1, ndbt(TaskManager.get_task(1), TaskManager.get_task(2)) )
    assert_equal(1, ndbt(TaskManager.get_task(3), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(4), TaskManager.get_task(2)) )
    assert_equal(2, ndbt(TaskManager.get_task(5), TaskManager.get_task(2)) )
    assert_equal(2, ndbt(TaskManager.get_task(6), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(7), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(8), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(9), TaskManager.get_task(2)) )
    assert_equal(2, ndbt(TaskManager.get_task(10), TaskManager.get_task(2)) )
    assert_equal(0, ndbt(TaskManager.get_task(11), TaskManager.get_task(2)) )
    assert_equal(3, ndbt(TaskManager.get_task(12), TaskManager.get_task(2)) )
    assert_equal(1, ndbt(TaskManager.get_task(13), TaskManager.get_task(2)) )
    assert_equal(2, ndbt(TaskManager.get_task(14), TaskManager.get_task(2)) )
    assert_equal(1, ndbt(TaskManager.get_task(15), TaskManager.get_task(2)) )
    assert_equal(2, ndbt(TaskManager.get_task(16), TaskManager.get_task(2)) )
    
  end 
  
  def test_ndbp
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(1, ndbp(TaskManager.get_task(1), 2) )

    set_taskset("#{TEST_FOLDER}wcbt-test_2")
    assert_equal(1, ndbp(TaskManager.get_task(4), 2) )

    set_taskset("#{TEST_FOLDER}wcbt-test_3")
    assert_equal(0, ndbp(TaskManager.get_task(7), 2) )
  end
  
  def test_rblt
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(2, rblt(TaskManager.get_task(3), TaskManager.get_task(1)) )

    set_taskset("#{TEST_FOLDER}wcbt-test_2")
    assert_equal(2, rblt(TaskManager.get_task(6), TaskManager.get_task(4)) )

    set_taskset("#{TEST_FOLDER}wcbt-test_3")
    assert_equal(0, rblt(TaskManager.get_task(9), TaskManager.get_task(7)) )
  end
  
  def test_rbl
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(2, rblp(TaskManager.get_task(1), 2) )

    set_taskset("#{TEST_FOLDER}wcbt-test_2")
    assert_equal(2, rblp(TaskManager.get_task(4), 2) )

    set_taskset("#{TEST_FOLDER}wcbt-test_3")
    assert_equal(0, rblp(TaskManager.get_task(7), 2) )
  end
  
  def test_rbl
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(2, rbl(TaskManager.get_task(1)))

    set_taskset("#{TEST_FOLDER}wcbt-test_2")
    assert_equal(2, rbl(TaskManager.get_task(4)))

    set_taskset("#{TEST_FOLDER}wcbt-test_3")
    assert_equal(0, rbl(TaskManager.get_task(7)))

  end
  
  def test_wcsp
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(0, wcsp(TaskManager.get_task(1), 2).size )
    
    set_taskset("#{TEST_FOLDER}wcbt-test_2")
    assert_equal(0, wcsp(TaskManager.get_task(4), 2).size )
    
    set_taskset("#{TEST_FOLDER}wcbt-test_3")
    assert_equal(2, wcsp(TaskManager.get_task(7), 2).size )
  end
  
  def test_rbspLB
    set_taskset("#{TEST_FOLDER}for_test_sbgp")
    assert(rbl(TaskManager.get_task(1))==12)
    assert(rbs(TaskManager.get_task(1))==10)
  end
  
  def test_wcsxg
    set_taskset("#{TEST_FOLDER}for_test_sbgp")
  
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 5).size )
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 6).size )
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 7).size )
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 8).size )
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 9).size )

    assert_equal(0, wcsxg(TaskManager.get_task(3), TaskManager.get_task(1), 1).size )
    assert_equal(6, wcsxg(TaskManager.get_task(3), TaskManager.get_task(1), 2).size )

    assert_equal(2, wcsxg(TaskManager.get_task(4), TaskManager.get_task(1), 2).size )
    assert_equal(2, wcsxg(TaskManager.get_task(4), TaskManager.get_task(1), 8).size )
   
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 1).size ) 
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 1).size )
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 1).size )
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 1).size )

    assert_equal(3, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 2).size )
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 2).size )
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 2).size )
    assert_equal(3, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 2).size )

    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 3).size )
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 3).size )
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 3).size )
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 3).size )

    assert_equal(3, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 4).size )
    assert_equal(2, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 4).size )
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 4).size )
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 4).size )

    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 5).size )
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 5).size )
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 5).size )
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 5).size )

    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 6).size )
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 6).size )
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 6).size )
    assert_equal(3, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 6).size )

    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 7).size )
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 7).size )
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 7).size )
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 7).size )

    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 8).size )
    assert_equal(2, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 8).size )
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 8).size )
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 8).size )

  end
  
  def test_wcspg
    set_taskset("#{TEST_FOLDER}for_test_sbgp")
    
    assert_equal(0, wcspg(TaskManager.get_task(1), 2, 1).size)
    assert_equal(6, wcspg(TaskManager.get_task(1), 2, 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), 2, 3).size)
    assert_equal(5, wcspg(TaskManager.get_task(1), 2, 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), 2, 5).size)
    assert_equal(3, wcspg(TaskManager.get_task(1), 2, 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), 2, 7).size)
    assert_equal(2, wcspg(TaskManager.get_task(1), 2, 8).size)

    assert_equal(0, wcspg(TaskManager.get_task(1), 3, 1).size)
    assert_equal(8, wcspg(TaskManager.get_task(1), 3, 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), 3, 3).size)
    assert_equal(2, wcspg(TaskManager.get_task(1), 3, 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), 3, 5).size)
    assert_equal(3, wcspg(TaskManager.get_task(1), 3, 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), 3, 7).size)
    assert_equal(5, wcspg(TaskManager.get_task(1), 3, 8).size)

    assert_equal(0, wcspg(TaskManager.get_task(1), 4, 1).size)
    assert_equal(4, wcspg(TaskManager.get_task(1), 4, 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), 4, 3).size)
    assert_equal(2, wcspg(TaskManager.get_task(1), 4, 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), 4, 5).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), 4, 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), 4, 7).size)
    assert_equal(8, wcspg(TaskManager.get_task(1), 4, 8).size)

    assert_equal(0, wcspg(TaskManager.get_task(2), 1, 1).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 1, 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 1, 3).size)
    assert_equal(7, wcspg(TaskManager.get_task(2), 1, 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 1, 5).size)
    assert_equal(2, wcspg(TaskManager.get_task(2), 1, 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 1, 7).size)
    assert_equal(2, wcspg(TaskManager.get_task(2), 1, 8).size)

    assert_equal(0, wcspg(TaskManager.get_task(2), 3, 1).size)
    assert_equal(8, wcspg(TaskManager.get_task(2), 3, 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 3, 3).size)
    assert_equal(2, wcspg(TaskManager.get_task(2), 3, 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 3, 5).size)
    assert_equal(2, wcspg(TaskManager.get_task(2), 3, 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 3, 7).size)
    assert_equal(4, wcspg(TaskManager.get_task(2), 3, 8).size)

    assert_equal(0, wcspg(TaskManager.get_task(2), 4, 1).size)
    assert_equal(4, wcspg(TaskManager.get_task(2), 4, 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 4, 3).size)
    assert_equal(2, wcspg(TaskManager.get_task(2), 4, 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 4, 5).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 4, 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), 4, 7).size)
    assert_equal(8, wcspg(TaskManager.get_task(2), 4, 8).size)
  end
  
  def test_sbgp
    set_taskset("#{TEST_FOLDER}for_test_sbgp")
    assert_equal(0, sbgp(TaskManager.get_task(1), 1, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 2, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 3, 2) )
    assert_equal(1, sbgp(TaskManager.get_task(1), 4, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 5, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 6, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 7, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 8, 2) )

    assert_equal(0, sbgp(TaskManager.get_task(1), 1, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 2, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 3, 3) )
    assert_equal(2, sbgp(TaskManager.get_task(1), 4, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 5, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 6, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 7, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 8, 3) )

    assert_equal(0, sbgp(TaskManager.get_task(1), 1, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 2, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 3, 4) )
    assert_equal(1, sbgp(TaskManager.get_task(1), 4, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 5, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 6, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 7, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(1), 8, 4) )


    assert_equal(0, sbgp(TaskManager.get_task(2), 1, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 2, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 3, 1) )
    assert_equal(4, sbgp(TaskManager.get_task(2), 4, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 5, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 6, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 7, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 8, 1) )

    assert_equal(0, sbgp(TaskManager.get_task(2), 1, 3) )
    assert_equal(4, sbgp(TaskManager.get_task(2), 2, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 3, 3) )
    assert_equal(2, sbgp(TaskManager.get_task(2), 4, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 5, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 6, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 7, 3) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 8, 3) )

    assert_equal(0, sbgp(TaskManager.get_task(2), 1, 4) )
    assert_equal(4, sbgp(TaskManager.get_task(2), 2, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 3, 4) )
    assert_equal(1, sbgp(TaskManager.get_task(2), 4, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 5, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 6, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 7, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(2), 8, 4) )


    assert_equal(0, sbgp(TaskManager.get_task(3), 1, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 2, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 3, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 4, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 5, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 6, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 7, 1) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 8, 1) )

    assert_equal(0, sbgp(TaskManager.get_task(3), 1, 2) )
    assert_equal(4, sbgp(TaskManager.get_task(3), 2, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 3, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 4, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 5, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 6, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 7, 2) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 8, 2) )

    assert_equal(0, sbgp(TaskManager.get_task(3), 1, 4) )
    assert_equal(8, sbgp(TaskManager.get_task(3), 2, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 3, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 4, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 5, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 6, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 7, 4) )
    assert_equal(0, sbgp(TaskManager.get_task(3), 8, 4) )
  end
  
  def test_sbgSB
    set_taskset("#{TEST_FOLDER}for_test_sbgp")

    assert_equal(0, sbg(TaskManager.get_task(1), 1) )
    assert_equal(0, sbg(TaskManager.get_task(1), 2) )
    assert_equal(0, sbg(TaskManager.get_task(1), 3) )
    assert_equal(4, sbg(TaskManager.get_task(1), 4) )
    assert_equal(0, sbg(TaskManager.get_task(1), 5) )
    assert_equal(0, sbg(TaskManager.get_task(1), 6) )
    assert_equal(0, sbg(TaskManager.get_task(1), 7) )
    assert_equal(0, sbg(TaskManager.get_task(1), 8) )

    assert_equal(0, sbg(TaskManager.get_task(2), 1) )
    assert_equal(8, sbg(TaskManager.get_task(2), 2) )
    assert_equal(0, sbg(TaskManager.get_task(2), 3) )
    assert_equal(7, sbg(TaskManager.get_task(2), 4) )
    assert_equal(0, sbg(TaskManager.get_task(2), 5) )
    assert_equal(0, sbg(TaskManager.get_task(2), 6) )
    assert_equal(0, sbg(TaskManager.get_task(2), 7) )
    assert_equal(0, sbg(TaskManager.get_task(2), 8) )

    assert_equal(0, sbg(TaskManager.get_task(3), 1) )
    assert_equal(12, sbg(TaskManager.get_task(3), 2) )
    assert_equal(0, sbg(TaskManager.get_task(3), 3) )
    assert_equal(0, sbg(TaskManager.get_task(3), 4) )
    assert_equal(0, sbg(TaskManager.get_task(3), 5) )
    assert_equal(0, sbg(TaskManager.get_task(3), 6) )
    assert_equal(0, sbg(TaskManager.get_task(3), 7) )
    assert_equal(0, sbg(TaskManager.get_task(3), 8) )

    assert_equal(0, sbg(TaskManager.get_task(4), 1) )
    assert_equal(6, sbg(TaskManager.get_task(4), 2) )
    assert_equal(0, sbg(TaskManager.get_task(4), 3) )
    assert_equal(0, sbg(TaskManager.get_task(4), 4) )
    assert_equal(0, sbg(TaskManager.get_task(4), 5) )
    assert_equal(0, sbg(TaskManager.get_task(4), 6) )
    assert_equal(0, sbg(TaskManager.get_task(4), 7) )
    assert_equal(6, sbg(TaskManager.get_task(4), 8) )


    assert_equal(4, SB(TaskManager.get_task(1)) )
    assert_equal(15, SB(TaskManager.get_task(2)) )
    assert_equal(12, SB(TaskManager.get_task(3)) )
    assert_equal(12, SB(TaskManager.get_task(4)) )
  end
 
  
  def test_120430_fortest
    @manager = AllManager.new
    @manager.load_tasks("#{TEST_FOLDER}120430_fortest")
    
    #ts = TaskSet.new(@manager.tm.get_task_array)
    #ts.show_taskset

    t1 = TaskManager.get_task(1)
    t2 = TaskManager.get_task(2)
    t3 = TaskManager.get_task(3)
    t4 = TaskManager.get_task(4)
    t5 = TaskManager.get_task(5)
    t6 = TaskManager.get_task(6)
    t7 = TaskManager.get_task(7)
    t8 = TaskManager.get_task(8)
    
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

    assert_equal(4, t1.bb)
    assert_equal(0, t2.bb)
    assert_equal(4, t3.bb)
    assert_equal(4, t4.bb)
    assert_equal(0, t5.bb)
    assert_equal(0, t6.bb)
    assert_equal(0, t7.bb)
    assert_equal(0, t8.bb)
  end
  
  def test_120502
    @manager = AllManager.new
    @manager.load_tasks("#{TEST_FOLDER}120502_fortest")
  
    t1 = TaskManager.get_task(1)
    t2 = TaskManager.get_task(2)
    t3 = TaskManager.get_task(3)
    t4 = TaskManager.get_task(4)
    t5 = TaskManager.get_task(5)
    t6 = TaskManager.get_task(6)

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
    assert_equal(0, AB(t4))
    assert_equal(0, AB(t6))
    
  end
  
  

  def test_competing
    @manager = AllManager.new
    @manager.load_tasks("#{TEST_FOLDER}for_test_competing_1")
    
    t1 = TaskManager.get_task(1)
    t2 = TaskManager.get_task(2)
    t3 = TaskManager.get_task(3)
    t4 = TaskManager.get_task(4)
    t5 = TaskManager.get_task(5)
    t6 = TaskManager.get_task(6)
    t7 = TaskManager.get_task(7)
    t8 = TaskManager.get_task(8)
    t9 = TaskManager.get_task(9)

    assert_equal(0, competing(t1.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(1, competing(t1.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(2, competing(t1.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(0, competing(t1.req_list[0], ProcessorManager.get_proc(4)).size)
    
    assert_equal(0, competing(t2.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(0, competing(t2.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(1, competing(t2.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(1, competing(t2.req_list[0], ProcessorManager.get_proc(4)).size)
    
    assert_equal(1, competing(t3.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(1, competing(t3.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(1, competing(t3.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(0, competing(t3.req_list[0], ProcessorManager.get_proc(4)).size)

    assert_equal(1, competing(t4.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(0, competing(t4.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(0, competing(t4.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(0, competing(t4.req_list[0], ProcessorManager.get_proc(4)).size)

    assert_equal(0, competing(t5.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(0, competing(t5.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(0, competing(t5.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(1, competing(t5.req_list[0], ProcessorManager.get_proc(4)).size)

    assert_equal(0, competing(t6.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(0, competing(t6.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(0, competing(t6.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(0, competing(t6.req_list[0], ProcessorManager.get_proc(4)).size)
    
    assert_equal(0, competing(t7.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(1, competing(t7.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(0, competing(t7.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(1, competing(t7.req_list[0], ProcessorManager.get_proc(4)).size)

    assert_equal(2, competing(t8.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(0, competing(t8.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(0, competing(t8.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(0, competing(t8.req_list[0], ProcessorManager.get_proc(4)).size)

    assert_equal(1, competing(t9.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(0, competing(t9.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(0, competing(t9.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(1, competing(t9.req_list[0], ProcessorManager.get_proc(4)).size)
    
    @manager.all_data_clear
    @manager.load_tasks("#{TEST_FOLDER}for_test_competing_2")

    t1 = TaskManager.get_task(1)
    t2 = TaskManager.get_task(2)
    t3 = TaskManager.get_task(3)
    t4 = TaskManager.get_task(4)
    t5 = TaskManager.get_task(5)
    t6 = TaskManager.get_task(6)
    t7 = TaskManager.get_task(7)
    t8 = TaskManager.get_task(8)
    t9 = TaskManager.get_task(9)

    assert_equal(1, competing(t1.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(1, competing(t1.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(1, competing(t1.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(1, competing(t1.req_list[0], ProcessorManager.get_proc(4)).size)

    assert_equal(1, competing(t1.req_list[1], ProcessorManager.get_proc(1)).size)
    assert_equal(2, competing(t1.req_list[1], ProcessorManager.get_proc(2)).size)
    assert_equal(1, competing(t1.req_list[1], ProcessorManager.get_proc(3)).size)
    assert_equal(1, competing(t1.req_list[1], ProcessorManager.get_proc(4)).size)
    
    assert_equal(2, competing(t2.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(1, competing(t2.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(1, competing(t2.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(1, competing(t2.req_list[0], ProcessorManager.get_proc(4)).size)

    assert_equal(1, competing(t2.req_list[1], ProcessorManager.get_proc(1)).size)
    assert_equal(0, competing(t2.req_list[1], ProcessorManager.get_proc(2)).size)
    assert_equal(0, competing(t2.req_list[1], ProcessorManager.get_proc(3)).size)
    assert_equal(0, competing(t2.req_list[1], ProcessorManager.get_proc(4)).size)
    
    assert_equal(0, competing(t3.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(1, competing(t3.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(0, competing(t3.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(0, competing(t3.req_list[0], ProcessorManager.get_proc(4)).size)

    assert_equal(1, competing(t3.req_list[1], ProcessorManager.get_proc(1)).size)
    assert_equal(1, competing(t3.req_list[1], ProcessorManager.get_proc(2)).size)
    assert_equal(1, competing(t3.req_list[1], ProcessorManager.get_proc(3)).size)
    assert_equal(2, competing(t3.req_list[1], ProcessorManager.get_proc(4)).size)

    assert_equal(2, competing(t4.req_list[0], ProcessorManager.get_proc(1)).size)
    assert_equal(1, competing(t4.req_list[0], ProcessorManager.get_proc(2)).size)
    assert_equal(1, competing(t4.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(0, competing(t4.req_list[0], ProcessorManager.get_proc(4)).size)

    assert_equal(0, competing(t4.req_list[1], ProcessorManager.get_proc(1)).size)
    assert_equal(1, competing(t4.req_list[1], ProcessorManager.get_proc(2)).size)
    assert_equal(1, competing(t4.req_list[1], ProcessorManager.get_proc(3)).size)
    assert_equal(1, competing(t4.req_list[1], ProcessorManager.get_proc(4)).size)

  end
  
  def test_sbr
    @manager = AllManager.new
    @manager.load_tasks("#{TEST_FOLDER}for_test_competing_1")
    
    
  end
end
 
