#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#$:.unshift(File.dirname(__FILE__))
require "./task"
require "test/unit"
require "pp"
require "./utils/task-CUI"
require "./manager"

TEST_FOLDER = "./testFolder/test_tastsets/"
class Test_wcbt < Test::Unit::TestCase
  include WCBT

  def task(id)
    return TaskManager.get_task(id)
  end
  
  def processor(id)
    return ProcessorManager.get_proc(id)
  end


  def set_taskset(filename)
    @manager.all_data_clear
    @manager.load_tasks(filename)
    #init_computing(@manager.tm.get_task_array)    
  end
  
  def setup
    # setupはtest_xxxのメソッドが実行される度に呼び出される
    
    @manager = AllManager.new
    @manager.all_data_clear
  end 

  def test_WCLRWCSR
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
    
    assert_equal(0, WCSR(TaskManager.get_task(1)).size)
    assert_equal(1, WCSR(TaskManager.get_task(2)).size)
    assert_equal(1, WCSR(TaskManager.get_task(3)).size)
    assert_equal(1, WCSR(TaskManager.get_task(4)).size)
    assert_equal(1, WCSR(TaskManager.get_task(5)).size)
    assert_equal(2, WCSR(TaskManager.get_task(6)).size)
    assert_equal(3, WCSR(TaskManager.get_task(7)).size)
    assert_equal(3, WCSR(TaskManager.get_task(8)).size)
    assert_equal(0, WCSR(TaskManager.get_task(9)).size)
    assert_equal(2, WCSR(TaskManager.get_task(10)).size)
    assert_equal(0, WCSR(TaskManager.get_task(11)).size)
    assert_equal(2, WCSR(TaskManager.get_task(12)).size)
    assert_equal(2, WCSR(TaskManager.get_task(13)).size)
    assert_equal(1, WCSR(TaskManager.get_task(14)).size)
    assert_equal(0, WCSR(TaskManager.get_task(15)).size)
    assert_equal(1, WCSR(TaskManager.get_task(16)).size)

  end
  
  def test_wclxwcsx
    set_taskset("#{TEST_FOLDER}for_many_test")
    assert_equal(8, wclx(TaskManager.get_task(2), TaskManager.get_task(1)).size)
    assert_equal(9, wclx(TaskManager.get_task(3), TaskManager.get_task(1)).size)
    assert_equal(6, wclx(TaskManager.get_task(4), TaskManager.get_task(1)).size)
    assert_equal(6, wclx(TaskManager.get_task(5), TaskManager.get_task(1)).size)
    assert_equal(3, wclx(TaskManager.get_task(6), TaskManager.get_task(1)).size)
    assert_equal(0, wclx(TaskManager.get_task(7), TaskManager.get_task(1)).size)
    assert_equal(3, wclx(TaskManager.get_task(8), TaskManager.get_task(1)).size)
    assert_equal(8, wclx(TaskManager.get_task(9), TaskManager.get_task(1)).size)
    assert_equal(3, wclx(TaskManager.get_task(10), TaskManager.get_task(1)).size)
    assert_equal(6, wclx(TaskManager.get_task(11), TaskManager.get_task(1)).size)
    assert_equal(6, wclx(TaskManager.get_task(12), TaskManager.get_task(1)).size)
    assert_equal(3, wclx(TaskManager.get_task(13), TaskManager.get_task(1)).size)
    assert_equal(4, wclx(TaskManager.get_task(14), TaskManager.get_task(1)).size)
    assert_equal(9, wclx(TaskManager.get_task(15), TaskManager.get_task(1)).size)
    assert_equal(6, wclx(TaskManager.get_task(16), TaskManager.get_task(1)).size)

    assert_equal(4, wcsx(TaskManager.get_task(2), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(3), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(4), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(5), TaskManager.get_task(1)).size)
    assert_equal(6, wcsx(TaskManager.get_task(6), TaskManager.get_task(1)).size)
    assert_equal(9, wcsx(TaskManager.get_task(7), TaskManager.get_task(1)).size)
    assert_equal(6, wcsx(TaskManager.get_task(8), TaskManager.get_task(1)).size)
    assert_equal(0, wcsx(TaskManager.get_task(9), TaskManager.get_task(1)).size)
    assert_equal(6, wcsx(TaskManager.get_task(10), TaskManager.get_task(1)).size)
    assert_equal(0, wcsx(TaskManager.get_task(11), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(12), TaskManager.get_task(1)).size)
    assert_equal(6, wcsx(TaskManager.get_task(13), TaskManager.get_task(1)).size)
    assert_equal(2, wcsx(TaskManager.get_task(14), TaskManager.get_task(1)).size)
    assert_equal(0, wcsx(TaskManager.get_task(15), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(16), TaskManager.get_task(1)).size)

    set_taskset("#{TEST_FOLDER}for_test_LB_nest")
    assert_equal(6, wcsx(TaskManager.get_task(2), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(3), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(4), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(5), TaskManager.get_task(1)).size)
    assert_equal(6, wcsx(TaskManager.get_task(6), TaskManager.get_task(1)).size)
    assert_equal(6, wcsx(TaskManager.get_task(7), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(8), TaskManager.get_task(1)).size)
    assert_equal(9, wcsx(TaskManager.get_task(9), TaskManager.get_task(1)).size)
    assert_equal(0, wcsx(TaskManager.get_task(10), TaskManager.get_task(1)).size)
    assert_equal(0, wcsx(TaskManager.get_task(11), TaskManager.get_task(1)).size)
    assert_equal(2, wcsx(TaskManager.get_task(12), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(13), TaskManager.get_task(1)).size)
    assert_equal(6, wcsx(TaskManager.get_task(14), TaskManager.get_task(1)).size)
    assert_equal(3, wcsx(TaskManager.get_task(15), TaskManager.get_task(1)).size)
    assert_equal(0, wcsx(TaskManager.get_task(16), TaskManager.get_task(1)).size)
    

  end
    
  def test_req_list
    set_taskset("#{TEST_FOLDER}wcbt-test_1")
    assert_equal(1, TaskManager.get_task(1).req_list.size)
    assert_equal(2, TaskManager.get_task(2).req_list.size)
    assert_equal(1, TaskManager.get_task(3).req_list.size)
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

    assert_equal(3, TaskManager.get_task(1).long_require_array.size)
    assert_equal(2, TaskManager.get_task(2).long_require_array.size)
    assert_equal(3, TaskManager.get_task(3).long_require_array.size) 
    assert_equal(2, TaskManager.get_task(4).long_require_array.size)
    assert_equal(2, TaskManager.get_task(5).long_require_array.size)
    assert_equal(1, TaskManager.get_task(6).long_require_array.size)
    assert_equal(0, TaskManager.get_task(7).long_require_array.size)
    assert_equal(1, TaskManager.get_task(8).long_require_array.size)

    assert_equal(0, TaskManager.get_task(1).short_require_array.size)
    assert_equal(1, TaskManager.get_task(2).short_require_array.size)
    assert_equal(1, TaskManager.get_task(3).short_require_array.size)
    assert_equal(1, TaskManager.get_task(4).short_require_array.size)
    assert_equal(1, TaskManager.get_task(5).short_require_array.size)
    assert_equal(2, TaskManager.get_task(6).short_require_array.size)
    assert_equal(3, TaskManager.get_task(7).short_require_array.size)
    assert_equal(3, TaskManager.get_task(8).short_require_array.size)
  end
  
  def test_all_require
    set_taskset("#{TEST_FOLDER}for_many_test")
    assert_equal(3, TaskManager.get_task(1).all_require.size)
    assert_equal(3, TaskManager.get_task(2).all_require.size)
    assert_equal(4, TaskManager.get_task(3).all_require.size)
    assert_equal(3, TaskManager.get_task(4).all_require.size)
    assert_equal(3, TaskManager.get_task(5).all_require.size)
    assert_equal(3, TaskManager.get_task(6).all_require.size)
    assert_equal(3, TaskManager.get_task(7).all_require.size)
    assert_equal(4, TaskManager.get_task(8).all_require.size)
    assert_equal(4, TaskManager.get_task(9).all_require.size)
    assert_equal(3, TaskManager.get_task(10).all_require.size)
    assert_equal(3, TaskManager.get_task(11).all_require.size)
    assert_equal(4, TaskManager.get_task(12).all_require.size)
    assert_equal(3, TaskManager.get_task(13).all_require.size)
    assert_equal(3, TaskManager.get_task(14).all_require.size)
    assert_equal(3, TaskManager.get_task(15).all_require.size)
    assert_equal(3, TaskManager.get_task(16).all_require.size)
  end

  def test_narr
    set_taskset("#{TEST_FOLDER}for_many_test")
    assert_equal(4, narr(TaskManager.get_task(1)))
    assert_equal(3, narr(TaskManager.get_task(2)))
    assert_equal(4, narr(TaskManager.get_task(3)))
    assert_equal(3, narr(TaskManager.get_task(4)))
    assert_equal(3, narr(TaskManager.get_task(5)))
    assert_equal(2, narr(TaskManager.get_task(6)))
    assert_equal(1, narr(TaskManager.get_task(7)))
    assert_equal(2, narr(TaskManager.get_task(8)))
    assert_equal(5, narr(TaskManager.get_task(9)))
    assert_equal(2, narr(TaskManager.get_task(10)))
    assert_equal(4, narr(TaskManager.get_task(11)))
    assert_equal(3, narr(TaskManager.get_task(12)))
    assert_equal(2, narr(TaskManager.get_task(13)))
    assert_equal(3, narr(TaskManager.get_task(14)))
    assert_equal(4, narr(TaskManager.get_task(15)))
    assert_equal(3, narr(TaskManager.get_task(16)))
                
  end

  def test_bbt
    set_taskset("#{TEST_FOLDER}for_many_test")
    assert_equal(16, bbt(TaskManager.get_task(2), TaskManager.get_task(1)))
    assert_equal(14, bbt(TaskManager.get_task(3), TaskManager.get_task(1)))  
    assert_equal(14, bbt(TaskManager.get_task(4), TaskManager.get_task(1)))
    assert_equal(11, bbt(TaskManager.get_task(5), TaskManager.get_task(1)))  
    assert_equal(12, bbt(TaskManager.get_task(6), TaskManager.get_task(1)))
    assert_equal(0, bbt(TaskManager.get_task(7), TaskManager.get_task(1)))  
    assert_equal(12+8*3, bbt(TaskManager.get_task(8), TaskManager.get_task(1)))
    assert_equal(12, bbt(TaskManager.get_task(9), TaskManager.get_task(1)))  
    assert_equal(12, bbt(TaskManager.get_task(10), TaskManager.get_task(1)))
    assert_equal(12, bbt(TaskManager.get_task(11), TaskManager.get_task(1)))  
    assert_equal(13+8*3, bbt(TaskManager.get_task(12), TaskManager.get_task(1)))
    assert_equal(12, bbt(TaskManager.get_task(13), TaskManager.get_task(1)))  
    assert_equal(8, bbt(TaskManager.get_task(14), TaskManager.get_task(1)))
    assert_equal(10, bbt(TaskManager.get_task(15), TaskManager.get_task(1)))  
    assert_equal(8, bbt(TaskManager.get_task(16), TaskManager.get_task(1)))

    assert_equal(10, bbt(TaskManager.get_task(1), TaskManager.get_task(3)))
    assert_equal(14, bbt(TaskManager.get_task(2), TaskManager.get_task(3)))  
    assert_equal(12, bbt(TaskManager.get_task(4), TaskManager.get_task(3)))
    assert_equal(8, bbt(TaskManager.get_task(6), TaskManager.get_task(3)))
    assert_equal(8+8*2, bbt(TaskManager.get_task(8), TaskManager.get_task(3)))
  end
  
  def test_BB
    set_taskset("#{TEST_FOLDER}for_many_test")
    assert_equal(35, BB(TaskManager.get_task(1)))
    assert_equal(22, BB(TaskManager.get_task(2)))
    assert_equal(20, BB(TaskManager.get_task(3)))

  end
  
  def test_abr
    set_taskset("#{TEST_FOLDER}for_many_test")
    assert_equal(9, abr(TaskManager.get_task(1)).size)
    assert_equal(10, abr(TaskManager.get_task(2)).size)
    #abr(TaskManager.get_task(2)).each{|tuple| puts tuple.prints}
    assert_equal(9, abr(TaskManager.get_task(3)).size)
    assert_equal(8, abr(TaskManager.get_task(4)).size)
    assert_equal(4, abr(TaskManager.get_task(5)).size)
    assert_equal(8, abr(TaskManager.get_task(6)).size)
    assert_equal(0, abr(TaskManager.get_task(7)).size)
    assert_equal(6, abr(TaskManager.get_task(8)).size)
    assert_equal(6, abr(TaskManager.get_task(9)).size)
    assert_equal(2, abr(TaskManager.get_task(10)).size)
    assert_equal(0, abr(TaskManager.get_task(11)).size)
    assert_equal(3, abr(TaskManager.get_task(12)).size)
    assert_equal(0, abr(TaskManager.get_task(13)).size)
    assert_equal(0, abr(TaskManager.get_task(14)).size)

    
  end
  
  def test_proc_list
    set_taskset("#{TEST_FOLDER}for_many_test")
    assert_equal([1,2,3,4], proc_list.collect{|proc| proc.proc_id})
  end

  def test_AB
    set_taskset("#{TEST_FOLDER}for_many_test")
    assert_equal(16+16+16+10, AB(TaskManager.get_task(1)))
    assert_equal(16+16+10, AB(TaskManager.get_task(2)))
    assert_equal(16+16+16+2, AB(TaskManager.get_task(3)))
    assert_equal(16+16+16, AB(TaskManager.get_task(4)))
  end

  def test_ndbtg
    set_taskset("#{TEST_FOLDER}for_test_LB")
    assert_equal(2, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 1))
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 2))
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 3))
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 4))
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 5))
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 6))
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 7))
    assert_equal(0, ndbtg(TaskManager.get_task(2), TaskManager.get_task(1), 8))

    assert_equal(2, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 1))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 2))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 3))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 4))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 5))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 6))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 7))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(1), 8))

    assert_equal(1, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 1))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 2))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 3))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 4))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 5))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 6))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 7))
    assert_equal(0, ndbtg(TaskManager.get_task(3), TaskManager.get_task(2), 8))

    assert_equal(2, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 1))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 2))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 3))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 4))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 5))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 6))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 7))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(3), 8))

    # ネストしている場合のテスト
    set_taskset("#{TEST_FOLDER}for_test_LB_nest")
    #    p    LR(TaskManager.get_task(1))
    #pp WCLR(TaskManager.get_task(7))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(1), 1))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(1), 2))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(1), 3))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(1), 4))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(1), 5))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(1), 6))
    assert_equal(0, ndbtg(TaskManager.get_task(5), TaskManager.get_task(1), 7))
    assert_equal(1, ndbtg(TaskManager.get_task(5), TaskManager.get_task(1), 8))

    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 1))
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 2))
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 3))
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 4))
    assert_equal(1, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 5))
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 6))
    assert_equal(0, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 7))
    assert_equal(1, ndbtg(TaskManager.get_task(7), TaskManager.get_task(1), 8))


  end
    
  def test_ndbt
    set_taskset("#{TEST_FOLDER}for_test_LB")
    assert_equal(2, ndbt(TaskManager.get_task(2), TaskManager.get_task(1)))
    assert_equal(2, ndbt(TaskManager.get_task(3), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(4), TaskManager.get_task(1)))
    assert_equal(2, ndbt(TaskManager.get_task(5), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(7), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(8), TaskManager.get_task(1)))
    assert_equal(2, ndbt(TaskManager.get_task(9), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(10), TaskManager.get_task(1)))
    assert_equal(2, ndbt(TaskManager.get_task(11), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(12), TaskManager.get_task(1)))
    assert_equal(2, ndbt(TaskManager.get_task(13), TaskManager.get_task(1)))
    assert_equal(2, ndbt(TaskManager.get_task(14), TaskManager.get_task(1)))
    assert_equal(2, ndbt(TaskManager.get_task(15), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(16), TaskManager.get_task(1)))

    assert_equal(1, ndbt(TaskManager.get_task(1), TaskManager.get_task(2)))
    assert_equal(1, ndbt(TaskManager.get_task(3), TaskManager.get_task(2)))
    assert_equal(0, ndbt(TaskManager.get_task(4), TaskManager.get_task(2)))
    assert_equal(1, ndbt(TaskManager.get_task(5), TaskManager.get_task(2)))
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(2)))
    assert_equal(0, ndbt(TaskManager.get_task(7), TaskManager.get_task(2)))
    assert_equal(0, ndbt(TaskManager.get_task(8), TaskManager.get_task(2)))
    assert_equal(1, ndbt(TaskManager.get_task(9), TaskManager.get_task(2)))
    assert_equal(0, ndbt(TaskManager.get_task(10), TaskManager.get_task(2)))
    assert_equal(1, ndbt(TaskManager.get_task(11), TaskManager.get_task(2)))
    assert_equal(0, ndbt(TaskManager.get_task(12), TaskManager.get_task(2)))
    assert_equal(1, ndbt(TaskManager.get_task(13), TaskManager.get_task(2)))
    assert_equal(1, ndbt(TaskManager.get_task(14), TaskManager.get_task(2)))
    assert_equal(1, ndbt(TaskManager.get_task(15), TaskManager.get_task(2)))
    assert_equal(0, ndbt(TaskManager.get_task(16), TaskManager.get_task(2)))

    assert_equal(2, ndbt(TaskManager.get_task(1), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(2), TaskManager.get_task(3)))
    assert_equal(1, ndbt(TaskManager.get_task(4), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(5), TaskManager.get_task(3)))
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(3)))
    assert_equal(1, ndbt(TaskManager.get_task(7), TaskManager.get_task(3)))
    assert_equal(1, ndbt(TaskManager.get_task(8), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(9), TaskManager.get_task(3)))
    assert_equal(0, ndbt(TaskManager.get_task(10), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(11), TaskManager.get_task(3)))
    assert_equal(0, ndbt(TaskManager.get_task(12), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(13), TaskManager.get_task(3)))
    assert_equal(3, ndbt(TaskManager.get_task(14), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(15), TaskManager.get_task(3)))
    assert_equal(1, ndbt(TaskManager.get_task(16), TaskManager.get_task(3)))

    assert_equal(2, ndbt(TaskManager.get_task(1), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(2), TaskManager.get_task(3)))
    assert_equal(1, ndbt(TaskManager.get_task(4), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(5), TaskManager.get_task(3)))
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(3)))
    assert_equal(1, ndbt(TaskManager.get_task(7), TaskManager.get_task(3)))
    assert_equal(1, ndbt(TaskManager.get_task(8), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(9), TaskManager.get_task(3)))
    assert_equal(0, ndbt(TaskManager.get_task(10), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(11), TaskManager.get_task(3)))
    assert_equal(0, ndbt(TaskManager.get_task(12), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(13), TaskManager.get_task(3)))
    assert_equal(3, ndbt(TaskManager.get_task(14), TaskManager.get_task(3)))
    assert_equal(2, ndbt(TaskManager.get_task(15), TaskManager.get_task(3)))
    assert_equal(1, ndbt(TaskManager.get_task(16), TaskManager.get_task(3)))

    assert_equal(0, ndbt(TaskManager.get_task(1), TaskManager.get_task(4)))
    assert_equal(0, ndbt(TaskManager.get_task(2), TaskManager.get_task(4)))
    assert_equal(1, ndbt(TaskManager.get_task(3), TaskManager.get_task(4)))
    assert_equal(1, ndbt(TaskManager.get_task(5), TaskManager.get_task(4)))
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(4)))
    assert_equal(1, ndbt(TaskManager.get_task(7), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(8), TaskManager.get_task(4)))
    assert_equal(1, ndbt(TaskManager.get_task(9), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(10), TaskManager.get_task(4)))
    assert_equal(1, ndbt(TaskManager.get_task(11), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(12), TaskManager.get_task(4)))
    assert_equal(1, ndbt(TaskManager.get_task(13), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(14), TaskManager.get_task(4)))
    assert_equal(1, ndbt(TaskManager.get_task(15), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(16), TaskManager.get_task(4)))

    assert_equal(2, ndbt(TaskManager.get_task(1), TaskManager.get_task(5)))
    assert_equal(2, ndbt(TaskManager.get_task(2), TaskManager.get_task(5)))
    assert_equal(2, ndbt(TaskManager.get_task(3), TaskManager.get_task(5)))
    assert_equal(1, ndbt(TaskManager.get_task(4), TaskManager.get_task(5)))
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(5)))
    assert_equal(0, ndbt(TaskManager.get_task(7), TaskManager.get_task(5)))
    assert_equal(0, ndbt(TaskManager.get_task(8), TaskManager.get_task(5)))
    assert_equal(2, ndbt(TaskManager.get_task(9), TaskManager.get_task(5)))
    assert_equal(1, ndbt(TaskManager.get_task(10), TaskManager.get_task(5)))
    assert_equal(3, ndbt(TaskManager.get_task(11), TaskManager.get_task(5)))
    assert_equal(1, ndbt(TaskManager.get_task(12), TaskManager.get_task(5)))
    assert_equal(2, ndbt(TaskManager.get_task(13), TaskManager.get_task(5)))
    assert_equal(2, ndbt(TaskManager.get_task(14), TaskManager.get_task(5)))
    assert_equal(3, ndbt(TaskManager.get_task(15), TaskManager.get_task(5)))
    assert_equal(1, ndbt(TaskManager.get_task(16), TaskManager.get_task(5)))

    
    # ネストしている場合のテスト
    set_taskset "#{TEST_FOLDER}for_test_LB_nest"
    assert_equal(0, ndbt(TaskManager.get_task(2), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(3), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(4), TaskManager.get_task(1)))
    assert_equal(1, ndbt(TaskManager.get_task(5), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(1)))
    assert_equal(2, ndbt(TaskManager.get_task(7), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(8), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(9), TaskManager.get_task(1)))
    assert_equal(2, ndbt(TaskManager.get_task(10), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(11), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(12), TaskManager.get_task(1)))
    assert_equal(1, ndbt(TaskManager.get_task(13), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(14), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(15), TaskManager.get_task(1)))
    assert_equal(0, ndbt(TaskManager.get_task(16), TaskManager.get_task(1)))
    
    assert_equal(0, ndbt(TaskManager.get_task(1), TaskManager.get_task(4)))
    assert_equal(0, ndbt(TaskManager.get_task(2), TaskManager.get_task(4)))
    assert_equal(0, ndbt(TaskManager.get_task(3), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(5), TaskManager.get_task(4)))
    assert_equal(0, ndbt(TaskManager.get_task(6), TaskManager.get_task(4)))
    assert_equal(0, ndbt(TaskManager.get_task(7), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(8), TaskManager.get_task(4)))
    assert_equal(0, ndbt(TaskManager.get_task(9), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(10), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(11), TaskManager.get_task(4)))
    assert_equal(0, ndbt(TaskManager.get_task(12), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(13), TaskManager.get_task(4)))
    assert_equal(0, ndbt(TaskManager.get_task(14), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(15), TaskManager.get_task(4)))
    assert_equal(2, ndbt(TaskManager.get_task(16), TaskManager.get_task(4)))
    
  end 
  
  def test_ndbp
    set_taskset("#{TEST_FOLDER}for_test_LB_nest")
    
    assert_equal(0, ndbp(TaskManager.get_task(1), ProcessorManager.get_proc(1)))
    assert_equal(2, ndbp(TaskManager.get_task(1), ProcessorManager.get_proc(2)))
    assert_equal(2, ndbp(TaskManager.get_task(1), ProcessorManager.get_proc(3)))
    assert_equal(0, ndbp(TaskManager.get_task(1), ProcessorManager.get_proc(4)))
    assert_equal(0, ndbp(TaskManager.get_task(2), ProcessorManager.get_proc(1)))
    assert_equal(0, ndbp(TaskManager.get_task(2), ProcessorManager.get_proc(3)))
    assert_equal(0, ndbp(TaskManager.get_task(2), ProcessorManager.get_proc(4)))
    assert_equal(0, ndbp(TaskManager.get_task(3), ProcessorManager.get_proc(1)))
    assert_equal(3, ndbp(TaskManager.get_task(3), ProcessorManager.get_proc(2)))
    assert_equal(4, ndbp(TaskManager.get_task(3), ProcessorManager.get_proc(4)))
    assert_equal(4, ndbp(TaskManager.get_task(4), ProcessorManager.get_proc(1)))
    assert_equal(2, ndbp(TaskManager.get_task(4), ProcessorManager.get_proc(2)))
    assert_equal(4, ndbp(TaskManager.get_task(4), ProcessorManager.get_proc(3)))

    assert_equal(2, ndbp(TaskManager.get_task(5), ProcessorManager.get_proc(2)))
    assert_equal(3, ndbp(TaskManager.get_task(5), ProcessorManager.get_proc(3)))
    assert_equal(3, ndbp(TaskManager.get_task(5), ProcessorManager.get_proc(4)))
    assert_equal(0, ndbp(TaskManager.get_task(6), ProcessorManager.get_proc(1)))
    assert_equal(2, ndbp(TaskManager.get_task(6), ProcessorManager.get_proc(3)))
    assert_equal(2, ndbp(TaskManager.get_task(6), ProcessorManager.get_proc(4)))
    assert_equal(4, ndbp(TaskManager.get_task(7), ProcessorManager.get_proc(1)))
    assert_equal(2, ndbp(TaskManager.get_task(7), ProcessorManager.get_proc(2)))
    assert_equal(0, ndbp(TaskManager.get_task(7), ProcessorManager.get_proc(4)))
    assert_equal(2, ndbp(TaskManager.get_task(8), ProcessorManager.get_proc(1)))
    assert_equal(2, ndbp(TaskManager.get_task(8), ProcessorManager.get_proc(2)))
    assert_equal(3, ndbp(TaskManager.get_task(8), ProcessorManager.get_proc(3)))
    
    assert_equal(0, ndbp(TaskManager.get_task(9), ProcessorManager.get_proc(2)))
    assert_equal(0, ndbp(TaskManager.get_task(9), ProcessorManager.get_proc(3)))
    assert_equal(0, ndbp(TaskManager.get_task(9), ProcessorManager.get_proc(4)))
    assert_equal(6, ndbp(TaskManager.get_task(10), ProcessorManager.get_proc(1)))
    assert_equal(5, ndbp(TaskManager.get_task(10), ProcessorManager.get_proc(3)))
    assert_equal(5, ndbp(TaskManager.get_task(10), ProcessorManager.get_proc(4)))
    assert_equal(2, ndbp(TaskManager.get_task(11), ProcessorManager.get_proc(1)))
    assert_equal(5, ndbp(TaskManager.get_task(11), ProcessorManager.get_proc(2)))
    assert_equal(7, ndbp(TaskManager.get_task(11), ProcessorManager.get_proc(4)))
    assert_equal(0, ndbp(TaskManager.get_task(12), ProcessorManager.get_proc(1)))
    assert_equal(3, ndbp(TaskManager.get_task(12), ProcessorManager.get_proc(2)))
    assert_equal(3, ndbp(TaskManager.get_task(12), ProcessorManager.get_proc(3)))

    assert_equal(0, ndbp(TaskManager.get_task(13), ProcessorManager.get_proc(1)))
    assert_equal(2, ndbp(TaskManager.get_task(13), ProcessorManager.get_proc(2)))
    assert_equal(3, ndbp(TaskManager.get_task(13), ProcessorManager.get_proc(3)))
    assert_equal(3, ndbp(TaskManager.get_task(13), ProcessorManager.get_proc(4)))
    assert_equal(0, ndbp(TaskManager.get_task(14), ProcessorManager.get_proc(1)))
    assert_equal(2, ndbp(TaskManager.get_task(14), ProcessorManager.get_proc(3)))
    assert_equal(2, ndbp(TaskManager.get_task(14), ProcessorManager.get_proc(4)))
    assert_equal(4, ndbp(TaskManager.get_task(15), ProcessorManager.get_proc(1)))
    assert_equal(2, ndbp(TaskManager.get_task(15), ProcessorManager.get_proc(2)))
    assert_equal(6, ndbp(TaskManager.get_task(15), ProcessorManager.get_proc(4)))
    assert_equal(2, ndbp(TaskManager.get_task(16), ProcessorManager.get_proc(1)))
    assert_equal(5, ndbp(TaskManager.get_task(16), ProcessorManager.get_proc(2)))
    assert_equal(6, ndbp(TaskManager.get_task(16), ProcessorManager.get_proc(3)))

  end
  
  def test_rblt
    set_taskset("#{TEST_FOLDER}for_test_LB_nest")
    assert_equal(0, rblt(TaskManager.get_task(2), TaskManager.get_task(1)))
    assert_equal(4, rblt(TaskManager.get_task(3), TaskManager.get_task(1)))
    assert_equal(0, rblt(TaskManager.get_task(4), TaskManager.get_task(1)))
    assert_equal(0, rblt(TaskManager.get_task(5), TaskManager.get_task(1)))
    assert_equal(2, rblt(TaskManager.get_task(6), TaskManager.get_task(1)))
    assert_equal(8, rblt(TaskManager.get_task(7), TaskManager.get_task(1)))
    assert_equal(0, rblt(TaskManager.get_task(8), TaskManager.get_task(1)))
    assert_equal(0, rblt(TaskManager.get_task(9), TaskManager.get_task(1)))
    assert_equal(16, rblt(TaskManager.get_task(10), TaskManager.get_task(1)))
    assert_equal(16, rblt(TaskManager.get_task(11), TaskManager.get_task(1)))
    assert_equal(0, rblt(TaskManager.get_task(12), TaskManager.get_task(1)))
    assert_equal(0, rblt(TaskManager.get_task(13), TaskManager.get_task(1)))
    assert_equal(4, rblt(TaskManager.get_task(14), TaskManager.get_task(1)))
    assert_equal(6+5*2, rblt(TaskManager.get_task(15), TaskManager.get_task(1)))
    assert_equal(0, rblt(TaskManager.get_task(16), TaskManager.get_task(1)))

    assert_equal(0, rblt(TaskManager.get_task(1), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(3), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(4), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(5), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(6), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(7), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(8), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(9), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(10), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(11), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(12), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(13), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(14), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(15), TaskManager.get_task(2)))
    assert_equal(0, rblt(TaskManager.get_task(16), TaskManager.get_task(2)))

    assert_equal(0, rblt(TaskManager.get_task(1), TaskManager.get_task(3)))
    assert_equal(0, rblt(TaskManager.get_task(2), TaskManager.get_task(3)))
    assert_equal(9+9+9+8, rblt(TaskManager.get_task(4), TaskManager.get_task(3)))
    assert_equal(0, rblt(TaskManager.get_task(5), TaskManager.get_task(3)))
    assert_equal(3, rblt(TaskManager.get_task(6), TaskManager.get_task(3)))
    assert_equal(0, rblt(TaskManager.get_task(7), TaskManager.get_task(3)))
    assert_equal(6, rblt(TaskManager.get_task(8), TaskManager.get_task(3)))
    assert_equal(0, rblt(TaskManager.get_task(9), TaskManager.get_task(3)))
    assert_equal(8+8+4, rblt(TaskManager.get_task(10), TaskManager.get_task(3)))
    assert_equal(0, rblt(TaskManager.get_task(11), TaskManager.get_task(3)))
    assert_equal(10, rblt(TaskManager.get_task(12), TaskManager.get_task(3)))
    assert_equal(0, rblt(TaskManager.get_task(13), TaskManager.get_task(3)))
    assert_equal(4, rblt(TaskManager.get_task(14), TaskManager.get_task(3)))
    assert_equal(0, rblt(TaskManager.get_task(15), TaskManager.get_task(3)))
    assert_equal(8, rblt(TaskManager.get_task(16), TaskManager.get_task(3)))
  end

  def test_rblp
    set_taskset("#{TEST_FOLDER}for_test_LB_nest")
    assert_equal(0+2+16+4, rblp(TaskManager.get_task(1), ProcessorManager.get_proc(2)))
    assert_equal(4+8+16+16, rblp(TaskManager.get_task(1), ProcessorManager.get_proc(3)))
    assert_equal(0, rblp(TaskManager.get_task(1), ProcessorManager.get_proc(4)))
    assert_equal(0, rblp(TaskManager.get_task(2), ProcessorManager.get_proc(1)))
    assert_equal(0, rblp(TaskManager.get_task(2), ProcessorManager.get_proc(3)))
    assert_equal(0, rblp(TaskManager.get_task(2), ProcessorManager.get_proc(4)))
    assert_equal(0, rblp(TaskManager.get_task(3), ProcessorManager.get_proc(1)))
    assert_equal(0+3+20+4, rblp(TaskManager.get_task(3), ProcessorManager.get_proc(2)))
    assert_equal(35+6+10+8, rblp(TaskManager.get_task(3), ProcessorManager.get_proc(4)))
  end
  
  def test_rbl
    set_taskset("#{TEST_FOLDER}for_test_LB_nest")
    assert_equal(22+44+0, rbl(TaskManager.get_task(1)))
    assert_equal(0, rbl(TaskManager.get_task(2)))
    assert_equal(27+59, rbl(TaskManager.get_task(3)))
  end
  
  def test_rbsp
    set_taskset("#{TEST_FOLDER}for_test_LB_nest")
    assert_equal(0, rbsp(TaskManager.get_task(1), ProcessorManager.get_proc(1)))
    assert_equal(8+8, rbsp(TaskManager.get_task(1), ProcessorManager.get_proc(2)))
    assert_equal(8+8, rbsp(TaskManager.get_task(1), ProcessorManager.get_proc(3)))
    assert_equal(0, rbsp(TaskManager.get_task(1), ProcessorManager.get_proc(4)))
    assert_equal(0, rbsp(TaskManager.get_task(2), ProcessorManager.get_proc(1)))
    assert_equal(0, rbsp(TaskManager.get_task(2), ProcessorManager.get_proc(2)))
    assert_equal(0, rbsp(TaskManager.get_task(2), ProcessorManager.get_proc(3)))
    assert_equal(0, rbsp(TaskManager.get_task(2), ProcessorManager.get_proc(4)))

    assert_equal(0, rbsp(TaskManager.get_task(3), ProcessorManager.get_proc(1)))
    assert_equal(8+8+6, rbsp(TaskManager.get_task(3), ProcessorManager.get_proc(2)))
    assert_equal(0, rbsp(TaskManager.get_task(3), ProcessorManager.get_proc(3)))
    assert_equal(7+7+7+7, rbsp(TaskManager.get_task(3), ProcessorManager.get_proc(4)))

    assert_equal(8+8+8+8, rbsp(TaskManager.get_task(4), ProcessorManager.get_proc(1)))
    assert_equal(8+8, rbsp(TaskManager.get_task(4), ProcessorManager.get_proc(2)))
    assert_equal(8+8+8+7, rbsp(TaskManager.get_task(4), ProcessorManager.get_proc(3)))
    assert_equal(0, rbsp(TaskManager.get_task(4), ProcessorManager.get_proc(4)))

  end
  
  def test_rbs
    set_taskset("#{TEST_FOLDER}for_test_LB_nest")
    assert_equal(32, rbs(TaskManager.get_task(1)))
    assert_equal(0, rbs(TaskManager.get_task(2)))
    assert_equal(0+22+0+28, rbs(TaskManager.get_task(3)))
    assert_equal(32+16+31+0, rbs(TaskManager.get_task(4)))

  end
  
  def test_wcsp
    set_taskset("#{TEST_FOLDER}for_test_LB_nest")
    assert_equal(18, wcsp(TaskManager.get_task(1), ProcessorManager.get_proc(2)).size)
    assert_equal(12, wcsp(TaskManager.get_task(1), ProcessorManager.get_proc(3)).size)
    assert_equal(8, wcsp(TaskManager.get_task(1), ProcessorManager.get_proc(4)).size)
    
  end
  
  def test_wcsxg
    set_taskset("#{TEST_FOLDER}for_test_sbgp")
  
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 5).size)
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 6).size)
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 7).size)
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 8).size)
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 9).size)

    assert_equal(0, wcsxg(TaskManager.get_task(3), TaskManager.get_task(1), 1).size)
    assert_equal(6, wcsxg(TaskManager.get_task(3), TaskManager.get_task(1), 2).size)

    assert_equal(2, wcsxg(TaskManager.get_task(4), TaskManager.get_task(1), 2).size)
    assert_equal(2, wcsxg(TaskManager.get_task(4), TaskManager.get_task(1), 8).size)
   
    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 1).size) 
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 1).size)
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 1).size)
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 1).size)

    assert_equal(3, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 2).size)
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 2).size)
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 2).size)
    assert_equal(3, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 2).size)

    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 3).size)
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 3).size)
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 3).size)
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 3).size)

    assert_equal(3, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 4).size)
    assert_equal(2, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 4).size)
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 4).size)
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 4).size)

    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 5).size)
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 5).size)
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 5).size)
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 5).size)

    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 6).size)
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 6).size)
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 6).size)
    assert_equal(3, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 6).size)

    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 7).size)
    assert_equal(0, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 7).size)
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 7).size)
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 7).size)

    assert_equal(0, wcsxg(TaskManager.get_task(2), TaskManager.get_task(1), 8).size)
    assert_equal(2, wcsxg(TaskManager.get_task(6), TaskManager.get_task(1), 8).size)
    assert_equal(0, wcsxg(TaskManager.get_task(10), TaskManager.get_task(1), 8).size)
    assert_equal(0, wcsxg(TaskManager.get_task(14), TaskManager.get_task(1), 8).size)

  end
  
  def test_wcspg
    set_taskset("#{TEST_FOLDER}for_test_sbgp")
    
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(2),  1).size)
    assert_equal(6, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(2), 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(2), 3).size)
    assert_equal(5, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(2), 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(2), 5).size)
    assert_equal(3, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(2), 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(2), 7).size)
    assert_equal(2, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(2), 8).size)

    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(3), 1).size)
    assert_equal(8, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(3), 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(3), 3).size)
    assert_equal(2, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(3), 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(3), 5).size)
    assert_equal(3, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(3), 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(3), 7).size)
    assert_equal(5, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(3), 8).size)

    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(4), 1).size)
    assert_equal(4, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(4), 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(4), 3).size)
    assert_equal(2, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(4), 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(4), 5).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(4), 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(4), 7).size)
    assert_equal(8, wcspg(TaskManager.get_task(1), ProcessorManager.get_proc(4), 8).size)

    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(1), 1).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(1), 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(1), 3).size)
    assert_equal(7, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(1), 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(1), 5).size)
    assert_equal(2, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(1), 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(1), 7).size)
    assert_equal(2, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(1), 8).size)

    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(3), 1).size)
    assert_equal(8, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(3), 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(3), 3).size)
    assert_equal(2, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(3), 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(3), 5).size)
    assert_equal(2, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(3), 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(3), 7).size)
    assert_equal(4, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(3), 8).size)

    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(4), 1).size)
    assert_equal(4, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(4), 2).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(4), 3).size)
    assert_equal(2, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(4), 4).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(4), 5).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(4), 6).size)
    assert_equal(0, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(4), 7).size)
    assert_equal(8, wcspg(TaskManager.get_task(2), ProcessorManager.get_proc(4), 8).size)
    
    set_taskset("#{TEST_FOLDER}test_wcspx1")
    assert_equal(3, wcspg(task(1), processor(2), 1).size)
    assert_equal(9, wcspg(task(1), processor(2), 2).size)
    assert_equal(2, wcspg(task(3), processor(2), 1).size)
    assert_equal(6, wcspg(task(3), processor(2), 2).size)
  end
  
  def test_sbgp
    set_taskset("#{TEST_FOLDER}for_test_sbgp")
    assert_equal(0, sbgp(TaskManager.get_task(1), 1, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 2, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 3, ProcessorManager.get_proc(2)))
    assert_equal(1, sbgp(TaskManager.get_task(1), 4, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 5, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 6, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 7, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 8, ProcessorManager.get_proc(2)))

    assert_equal(0, sbgp(TaskManager.get_task(1), 1, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 2, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 3, ProcessorManager.get_proc(3)))
    assert_equal(2, sbgp(TaskManager.get_task(1), 4, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 5, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 6, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 7, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 8, ProcessorManager.get_proc(3)))

    assert_equal(0, sbgp(TaskManager.get_task(1), 1, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 2, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 3, ProcessorManager.get_proc(4)))
    assert_equal(1, sbgp(TaskManager.get_task(1), 4, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 5, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 6, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 7, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(1), 8, ProcessorManager.get_proc(4)))


    assert_equal(0, sbgp(TaskManager.get_task(2), 1, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 2, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 3, ProcessorManager.get_proc(1)))
    assert_equal(4, sbgp(TaskManager.get_task(2), 4, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 5, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 6, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 7, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 8, ProcessorManager.get_proc(1)))

    assert_equal(0, sbgp(TaskManager.get_task(2), 1, ProcessorManager.get_proc(3)))
    assert_equal(4, sbgp(TaskManager.get_task(2), 2, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 3, ProcessorManager.get_proc(3)))
    assert_equal(2, sbgp(TaskManager.get_task(2), 4, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 5, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 6, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 7, ProcessorManager.get_proc(3)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 8, ProcessorManager.get_proc(3)))

    assert_equal(0, sbgp(TaskManager.get_task(2), 1, ProcessorManager.get_proc(4)))
    assert_equal(4, sbgp(TaskManager.get_task(2), 2, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 3, ProcessorManager.get_proc(4)))
    assert_equal(1, sbgp(TaskManager.get_task(2), 4, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 5, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 6, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 7, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(2), 8, ProcessorManager.get_proc(4)))


    assert_equal(0, sbgp(TaskManager.get_task(3), 1, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 2, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 3, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 4, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 5, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 6, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 7, ProcessorManager.get_proc(1)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 8, ProcessorManager.get_proc(1)))

    assert_equal(0, sbgp(TaskManager.get_task(3), 1, ProcessorManager.get_proc(2)))
    assert_equal(4, sbgp(TaskManager.get_task(3), 2, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 3, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 4, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 5, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 6, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 7, ProcessorManager.get_proc(2)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 8, ProcessorManager.get_proc(2)))

    assert_equal(0, sbgp(TaskManager.get_task(3), 1, ProcessorManager.get_proc(4)))
    assert_equal(8, sbgp(TaskManager.get_task(3), 2, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 3, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 4, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 5, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 6, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 7, ProcessorManager.get_proc(4)))
    assert_equal(0, sbgp(TaskManager.get_task(3), 8, ProcessorManager.get_proc(4)))
  end
  
  def test_sbgSB
    set_taskset("#{TEST_FOLDER}for_test_sbgp")

    assert_equal(0, sbg(TaskManager.get_task(1), 1))
    assert_equal(0, sbg(TaskManager.get_task(1), 2))
    assert_equal(0, sbg(TaskManager.get_task(1), 3))
    assert_equal(4, sbg(TaskManager.get_task(1), 4))
    assert_equal(0, sbg(TaskManager.get_task(1), 5))
    assert_equal(0, sbg(TaskManager.get_task(1), 6))
    assert_equal(0, sbg(TaskManager.get_task(1), 7))
    assert_equal(0, sbg(TaskManager.get_task(1), 8))

    assert_equal(0, sbg(TaskManager.get_task(2), 1))
    assert_equal(8, sbg(TaskManager.get_task(2), 2))
    assert_equal(0, sbg(TaskManager.get_task(2), 3))
    assert_equal(7, sbg(TaskManager.get_task(2), 4))
    assert_equal(0, sbg(TaskManager.get_task(2), 5))
    assert_equal(0, sbg(TaskManager.get_task(2), 6))
    assert_equal(0, sbg(TaskManager.get_task(2), 7))
    assert_equal(0, sbg(TaskManager.get_task(2), 8))

    assert_equal(0, sbg(TaskManager.get_task(3), 1))
    assert_equal(12, sbg(TaskManager.get_task(3), 2))
    assert_equal(0, sbg(TaskManager.get_task(3), 3))
    assert_equal(0, sbg(TaskManager.get_task(3), 4))
    assert_equal(0, sbg(TaskManager.get_task(3), 5))
    assert_equal(0, sbg(TaskManager.get_task(3), 6))
    assert_equal(0, sbg(TaskManager.get_task(3), 7))
    assert_equal(0, sbg(TaskManager.get_task(3), 8))

    assert_equal(0, sbg(TaskManager.get_task(4), 1))
    assert_equal(6, sbg(TaskManager.get_task(4), 2))
    assert_equal(0, sbg(TaskManager.get_task(4), 3))
    assert_equal(0, sbg(TaskManager.get_task(4), 4))
    assert_equal(0, sbg(TaskManager.get_task(4), 5))
    assert_equal(0, sbg(TaskManager.get_task(4), 6))
    assert_equal(0, sbg(TaskManager.get_task(4), 7))
    assert_equal(6, sbg(TaskManager.get_task(4), 8))


    assert_equal(4, SB(TaskManager.get_task(1)))
    assert_equal(15, SB(TaskManager.get_task(2)))
    assert_equal(12, SB(TaskManager.get_task(3)))
    assert_equal(12, SB(TaskManager.get_task(4)))
  end
 
  
  def test_120430
    set_taskset("#{TEST_FOLDER}120430_fortest")
    
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
    assert_equal(4+1*2, bbt(t2, t1))
    assert_equal(4+1*2, bbt(t3, t1))
    assert_equal(6, bbt(t4, t1))
    assert_equal(4, bbt(t5, t1))
    assert_equal(4+1*2, bbt(t6, t1))
    assert_equal(0, bbt(t7, t1))
    assert_equal(0, bbt(t8, t1))

    assert_equal(4, bbt(t1, t2))
    assert_equal(4+1*2, bbt(t3, t2))
    assert_equal(6, bbt(t4, t2))
    assert_equal(4, bbt(t5, t2))
    assert_equal(4+1*2, bbt(t6, t2))
    assert_equal(0, bbt(t7, t2))
    assert_equal(0, bbt(t8, t2))

    assert_equal(4, bbt(t1, t3))
    assert_equal(4+1*2, bbt(t2, t3))
    assert_equal(6, bbt(t4, t3))
    assert_equal(4, bbt(t5, t3))
    assert_equal(4+1*2, bbt(t6, t3))
    assert_equal(0, bbt(t7, t3))
    assert_equal(0, bbt(t8, t3))
    
    assert_equal(2, bbt(t1, t7))
    assert_equal(2+1*1, bbt(t2, t7))
    assert_equal(2+1*1, bbt(t3, t7))
    assert_equal(3, bbt(t4, t7))
    assert_equal(2, bbt(t5, t7))
    assert_equal(2+1*1, bbt(t6, t7))
    assert_equal(0, bbt(t8, t7))

    assert_equal(6, t1.bb)
    assert_equal(0, t2.bb)
    assert_equal(6, t3.bb)
    assert_equal(4, t4.bb)
    assert_equal(0, t5.bb)
    assert_equal(0, t6.bb)
    assert_equal(0, t7.bb)
    assert_equal(0, t8.bb)
  end
  
  def test_120502
    set_taskset("#{TEST_FOLDER}120502_fortest")
  
    t1 = TaskManager.get_task(1)
    t2 = TaskManager.get_task(2)
    t3 = TaskManager.get_task(3)
    t4 = TaskManager.get_task(4)
    t5 = TaskManager.get_task(5)
    t6 = TaskManager.get_task(6)

    assert_equal(0, ndbt(t1, t2))
    assert_equal(0, ndbp(t2, ProcessorManager.get_proc(2)))
    assert_equal(2, ndbp(t4, ProcessorManager.get_proc(2)))
    assert_equal(0, ndbp(t6, ProcessorManager.get_proc(2)))
    
    assert_equal(0, rbl(t2))
    assert_equal(0, rbs(t2))
    assert_equal(8, rbl(t4))
    assert_equal(8, rbs(t4))
    assert_equal(0, rbl(t6))
    assert_equal(0, rbs(t6))
    
    assert_equal(0, bbt(t6, t4))
    assert_equal(4, bbt(t3, t1))
    assert_equal(2, abr(t2).size)
    assert_equal(4, AB(t2))
    assert_equal(0, AB(t4))
    assert_equal(0, AB(t6))
    
  end
  
  

  def test_competing
    set_taskset("#{TEST_FOLDER}for_test_competing_1")
    
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
    
    set_taskset("#{TEST_FOLDER}for_test_competing_2")

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

    set_taskset("#{TEST_FOLDER}for_many_test")
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
    assert_equal(3, competing(t1.req_list[0], ProcessorManager.get_proc(3)).size)
    assert_equal(1, competing(t1.req_list[0], ProcessorManager.get_proc(4)).size)
    
    assert_equal(2, competing(t2.req_list[1], ProcessorManager.get_proc(1)).size)
    assert_equal(4, competing(t2.req_list[1], ProcessorManager.get_proc(2)).size)
    assert_equal(0, competing(t2.req_list[1], ProcessorManager.get_proc(3)).size)
    assert_equal(2, competing(t2.req_list[1], ProcessorManager.get_proc(4)).size)
  end
  
  def test_sbr
    @manager = AllManager.new
    @manager.load_tasks("#{TEST_FOLDER}for_test_competing_2")

    assert_equal(10, TaskManager.get_task(1).req_list[0].inflated_spintime)
    assert_equal(4, TaskManager.get_task(1).req_list[1].inflated_spintime)
    assert_equal(5, TaskManager.get_task(2).req_list[0].inflated_spintime)
    assert_equal(0, TaskManager.get_task(2).req_list[1].inflated_spintime)
    assert_equal(2, TaskManager.get_task(3).req_list[0].inflated_spintime)
    assert_equal(0, TaskManager.get_task(3).req_list[1].inflated_spintime)
    assert_equal(9, TaskManager.get_task(4).req_list[0].inflated_spintime)
    assert_equal(2, TaskManager.get_task(4).req_list[1].inflated_spintime)
    assert_equal(0, TaskManager.get_task(5).req_list[0].inflated_spintime)
    
    @manager.all_data_clear
    @manager.load_tasks("#{TEST_FOLDER}for_many_test")
    assert_equal(0, TaskManager.get_task(5).req_list[0].inflated_spintime)
    assert_equal(12, TaskManager.get_task(5).req_list[1].inflated_spintime)
    assert_equal(0, TaskManager.get_task(9).req_list[0].inflated_spintime)
    assert_equal(6, TaskManager.get_task(13).req_list[0].inflated_spintime)
    assert_equal(0, TaskManager.get_task(13).req_list[1].inflated_spintime)
    assert_equal(6, TaskManager.get_task(13).req_list[2].inflated_spintime)
    
    assert_equal(3, TaskManager.get_task(5).req_list[0].get_time_inflated)
    assert_equal(16, TaskManager.get_task(5).req_list[1].get_time_inflated)
    assert_equal(2, TaskManager.get_task(9).req_list[0].get_time_inflated)
    assert_equal(8, TaskManager.get_task(13).req_list[0].get_time_inflated)
    assert_equal(4, TaskManager.get_task(13).req_list[1].get_time_inflated)
    assert_equal(10, TaskManager.get_task(13).req_list[2].get_time_inflated)
    
    assert_equal(2+6, TaskManager.get_task(2).req_list[1].get_time_inflated)
    assert_equal(4+6, TaskManager.get_task(6).req_list[0].get_time_inflated)
    assert_equal(2+6, TaskManager.get_task(6).req_list[2].get_time_inflated)
    assert_equal(4+12, TaskManager.get_task(10).req_list[0].get_time_inflated)
    assert_equal(4+6, TaskManager.get_task(10).req_list[1].get_time_inflated)
    assert_equal(2+6, TaskManager.get_task(14).req_list[0].get_time_inflated)
    
    assert_equal(1+1, TaskManager.get_task(3).req_list[1].get_time_inflated)
    assert_equal(4+12, TaskManager.get_task(7).req_list[0].get_time_inflated)
    assert_equal(1+1, TaskManager.get_task(7).req_list[1].get_time_inflated)
    assert_equal(1+1, TaskManager.get_task(7).req_list[2].get_time_inflated)
    
    assert_equal(4+12, TaskManager.get_task(4).req_list[1].get_time_inflated)
    assert_equal(1+1, TaskManager.get_task(8).req_list[0].get_time_inflated)
    assert_equal(2+8, TaskManager.get_task(8).req_list[1].reqs[0].get_time_inflated)
    assert_equal(4+12, TaskManager.get_task(8).req_list[2].get_time_inflated)
    assert_equal(4+12, TaskManager.get_task(12).req_list[1].get_time_inflated)
    assert_equal(2+8, TaskManager.get_task(12).req_list[2].reqs[0].get_time_inflated)
    assert_equal(4+12, TaskManager.get_task(16).req_list[2].get_time_inflated)

  end

  def test_inflated_short_req_nested
    # ネストしたshort requireがinflateすると，outerなlongリソースもinflateする
    @manager = AllManager.new
    @manager.load_tasks("#{TEST_FOLDER}for_test_LB_nest")

    assert_equal(TaskManager.get_task(4).req_list[1].inflated_spintime, TaskManager.get_task(4).req_list[1].reqs[0].inflated_spintime)
  end

  def test_preempt
    set_taskset("#{TEST_FOLDER}test_preempt")
    assert_equal(0, preempt(TaskManager.get_task(1)))
    assert_equal(0, preempt(TaskManager.get_task(2)))
    assert_equal(3, preempt(TaskManager.get_task(3)))
    assert_equal(1, preempt(TaskManager.get_task(4)))
    assert_equal(3, preempt(TaskManager.get_task(5)))
    assert_equal(2, preempt(TaskManager.get_task(6)))
    assert_equal(3, preempt(TaskManager.get_task(7)))
    assert_equal(1, preempt(TaskManager.get_task(8)))
  end

  def test_get_remote_groups
    set_taskset("#{TEST_FOLDER}test_get_remote_groups1")
    assert_equal([4,6], get_remote_groups(TaskManager.get_task(1).proc))
    assert_equal([2,6], get_remote_groups(TaskManager.get_task(2).proc))

    set_taskset("#{TEST_FOLDER}test_get_remote_groups3")
    assert_equal([4,6], get_remote_groups(TaskManager.get_task(1).proc))
    assert_equal([2,4,6], get_remote_groups(TaskManager.get_task(2).proc))
  end

  # preemptive spin の最大ブロック時間を求める際の式の1つwcspxのテスト
  def test_wcspx
    set_taskset("#{TEST_FOLDER}test_wcspx1")
    assert_equal(6+6, wcspx(task(1), processor(2)).size)
    assert_equal(4+2, wcspx(task(3), processor(2)).size)

    set_taskset("#{TEST_FOLDER}test_wcspx2")
    assert_equal(9, wcspx(task(11), processor(2)).size)
    assert_equal(3, wcspx(task(11), processor(3)).size)
    assert_equal(10, wcspx(task(11), processor(4)).size)
    assert_equal(2, wcspx(task(1), processor(1)).size)
    assert_equal(2, wcspx(task(1), processor(3)).size)
    assert_equal(4, wcspx(task(1), processor(4)).size)
  end

  def test_sbp
    set_taskset("#{TEST_FOLDER}test_wcspx1")
    assert_equal(6, sbp(task(1), processor(2)))
    assert_equal(9, sbp(task(3), processor(2)))

    set_taskset("#{TEST_FOLDER}test_sbp")
    assert_equal(0, sbp(task(6), processor(2)))
    assert_equal(16, sbp(task(6), processor(3)))
    assert_equal(0, sbp(task(6), processor(4)))
    assert_equal(12, sbp(task(12), processor(1)))
    assert_equal(9, sbp(task(12), processor(2)))
    assert_equal(4, sbp(task(12), processor(3)))
    assert_equal(0, sbp(task(12), processor(4)))
    assert_equal(0, sbp(task(8), processor(1)))
    assert_equal(16, sbp(task(8), processor(3)))
    assert_equal(0, sbp(task(8), processor(4)))
    assert_equal(0, sbp(task(11), processor(1)))
    assert_equal(12, sbp(task(11), processor(2)))
    assert_equal(14, sbp(task(11), processor(3)))
    assert_equal(16, sbp(task(11), processor(4)))
    
  end

  def test_SB_preemptive_spin
    $PREEMPTIVE_FLG = true
    set_taskset("#{TEST_FOLDER}test_wcspx1")
    assert_equal(6, SB(task(1)))
    assert_equal(9, SB(task(3)))

    set_taskset("#{TEST_FOLDER}test_sbp")
    assert_equal(16, SB(task(6)))
    assert_equal(25, SB(task(12)))
    assert_equal(16, SB(task(8)))
    assert_equal(42, SB(task(11)))
    $PREEMPTIVE_FLG = false
  end
end

