#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= タスク生成本体　TaskManager, RequireManager, GroupManager
#
#Author:: Takahiro FUJITANI (ERTL, Nagoya Univ.)
#Version:: 0.5.0
#License::
#
#== Usage:
#
#=== 

# 標準ライブラリ
require "pp"
require "rubygems"  

# 独自ライブラリ
require "manager"
require "test/unit" # テスト

#==ランダム生成方針
# Task(task_id, proc, period, extime, priority, offset, reqList)
#  task_id:     タスク生成順にインクリメント
#  proc:        完全ランダム
#  period:      extime以下でランダム
#  extime:      reqListの総時間以上で乱数
#  priority:    完全ランダム
#  offset:      period以下でランダム
#  reqList:     createReqListで生成
#
# Group(group, kind)
#  group:       生成順にインクリメント
#  kind:        交互
#
# Require(req_id, group, time, reqs)
#  req_id:      生成順にインクリメント
#  group:       ランダムに選択
#  time:        (ある限度までで)ランダムに選択->20~50
#  reqs:        groupとは異なるグループのリソースを選択
# $external_input = true

$DEBUG = false
class Test_taskMaker < Test::Unit::TestCase
  def setup
    @@tm = TaskManager.instance
    @@rm = RequireManager.instance
    @@gm = GroupManager.instance
    i = 10
    @@gm.create_group_array(i)
    @@rm.set_garray(@@gm.get_group_array)
    @@rm.create_require_array(i)

    @@tm.set_array(@@rm.get_require_array, @@gm.get_group_array)
  end

  def test_initialize
    #assert_not_nil(@@tm.get_task_array)
    assert_equal([], @@tm.get_task_array) 
    #assert_equal(0, @@tm.get_task_array.size)
  end
  
  def test_create_tasks
    i = rand(100)
    assert_equal(i, @@tm.create_task_array(i))
  end
    
  def test_data_clear
    @@tm.data_clear
    assert_equal([], @@tm.get_task_array)
  end
  
  def test_load
    assert_equal(30, @@tm.load_task_data("sample_task.json"))
    assert_equal(30, @@tm.get_task_array.size)
    
    @@tm.data_clear
    # JSONじゃないファイルを入力
    @@tm.load_task_data("sample_task.jso")
    assert_equal(0, @@tm.get_task_array.size)
  end
  
  def test_save 
  end
end