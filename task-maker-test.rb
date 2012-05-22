xo#! /usr/bin/ruby
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
require "taskMaker"
require "taskCUI"
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
# $external_input

class Test_taskMaker < Test::Unit::TestCase
  def setup
    @@m = AllManager.new
  end

  def test_initialize
    assert_not_nil(@@m)
    assert_not_nil(@@m.tm)
    assert_not_nil(@@m.rm)
    assert_not_nil(@@m.gm)
  end
  
  def test_create_tasks
    @@m.create_tasks
    assert_same(TASK_COUNT, @@m.tm.get_task_array.size)
    assert_same(REQ_COUNT, @@m.rm.get_require_array.size)
    assert_same(GRP_COUNT, @@m.gm.get_group_array.size)

    @@m.create_tasks(100, 1000, 500)
    assert_same(100, @@m.tm.get_task_array.size)
    assert_same(1000, @@m.rm.get_require_array.size)
    assert_same(500, @@m.gm.get_group_array.size)
  end
    
  def test_all_data_clear
    @@m.all_data_clear
    assert_equal([], @@m.tm.get_task_array)
    assert_equal([], @@m.rm.get_require_array)
    assert_equal([], @@m.gm.get_group_array)
  end
  
  def test_load
    @@m.load_tasks("sample")
    assert_same(30, @@m.tm.get_task_array.size)
    assert_same(30, @@m.rm.get_require_array.size)
    assert_same(10, @@m.gm.get_group_array.size)
    
    @@m.all_data_clear
  end
  
  def test_save 
    assert(@@m.save_tasks("sample"))
  end
end
