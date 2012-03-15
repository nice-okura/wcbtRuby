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
$external_input = true

class Test_taskMaker < Test::Unit::TestCase
  def setup
    @gm = GroupManager.instance
    @rm = RequireManager.instance
    @tm = TaskManager.instance
    
    @gm.create_group_array(20)
    @rm.create_require_array(60)
    @tm.create_task_array(100)
    
    @gm.save_group_data
    @rm.save_require_data
    @tm.save_task_data
    
    taskset = TaskSet.new(@tm.get_task_array)
    taskset.show_taskset
    
  end

  def test_load_group_data
    #assert_same(3, @gm.get_group_array.size)
  end
    
  def test_load_require_data
    #assert_same(15, @rm.get_require_array.size)
    @rm.get_require_array.each{|rq|
      assert_instance_of(Group, rq.res)
      rq.reqs.each{|r|
        assert_instance_of(Req, r)
      }
    }
  end
  
  def test_load_task_data
    #assert_same(5, @tm.get_task_array.size)
    @tm.get_task_array.each{|t|
      t.req_list.each{|r|
        assert_instance_of(Req, r)
      }
    }
  end
end