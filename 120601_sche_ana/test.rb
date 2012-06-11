#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= wcbt-edfテスト
#== A flexible real-time locking protocol for multiprocessors
#
#Author:: Takahiro FUJITANI (ERTL, Nagoya Univ.)
#Version:: 0.1.0
#License:: 
#
#
require "task-edf"
require "test/unit"
require "pp"
require "manager"

JSON_FOLDER = "./json"

#
# WCBTのテストクラス
#
class Test_wcbt < Test::Unit::TestCase
  include WCBT

  # setup
  def setup
    @manager = AllManager.new
  end

  # Zのテスト
  def test_Z
    @manager.all_data_clear
    @manager.load_tasks("#{JSON_FOLDER}/test_Z")
    #@manager.create_tasks(6, 5, 2)
    #@manager.save_tasks("#{JSON_FOLDER}/test_Z")
    g = @manager.gm.get_group_array[0]
    assert_same(4, Z(@manager.tm.get_task_array[0], g).size)
    assert_same(3 ,Z(@manager.tm.get_task_array[1], g).size)
    assert_same(3 ,Z(@manager.tm.get_task_array[2], g).size)
    assert_same(3 ,Z(@manager.tm.get_task_array[3], g).size)
    assert_same(3 ,Z(@manager.tm.get_task_array[4], g).size)
  end

  def test_schedulability_check
    @manager.all_data_clear
    
    # ["sche_check", umax, f]
    umax = 0.1
    f = 0.1
    info = ["sche_check", umax, f]
    @manager.create_tasks(TASK_NUM, 30, 10, info)
    puts @manager.gm.get_group_array.size
    puts @manager.rm.get_require_array.size
    @manager.save_tasks("#{JSON_FOLDER}/sche_check")
    p_schedulability_check(1, 30)
    p_schedulability_check(2, 30)
    p_schedulability_check(3, 30)
    p_schedulability_check(4, 30)
    
  end
end
