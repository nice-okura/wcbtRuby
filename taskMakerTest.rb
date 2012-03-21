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
# $external_input = true

$DEBUG = true
class Test_taskMaker < Test::Unit::TestCase
  def setup
    @@m = AllManager.new
  end

  def test_initialize
    assert_not_nil(@@m)
    assert_not_nil(@@m.tm)
    assert_not_nil(@@m.rm)
    assert_not_nil(@@m.gm)
  
    @@m.create_tasks
    assert_same(TASK_COUNT, @@m.tm.get_task_array.size)
    assert_same(REQ_COUNT, @@m.rm.get_require_array.size)
    assert_same(GRP_COUNT, @@m.gm.get_group_array.size)
    
    @@m.all_data_clear
    assert_same(0, @@m.tm.get_task_array.size)
    assert_same(0, @@m.rm.get_require_array.size)
    assert_same(0, @@m.gm.get_group_array.size)
    
    @@m.load_tasks
    assert_same(100, @@m.tm.get_task_array.size)
    assert_same(100, @@m.rm.get_require_array.size)
    assert_same(100, @@m.gm.get_group_array.size)
    
    
  end
    
end