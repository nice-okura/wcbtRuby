#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= GroupManager のテスト
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
require "mamager"
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
class Test_groupMaker < Test::Unit::TestCase
  def setup
    @@gm = GroupManager.instance
  end

  def test_initialize
    assert_equal([], @@gm.get_group_array)
  end
  
  def test_create_group
    i = rand(100)
    assert_equal(i, @@gm.create_group_array(i))
  end
    
  def test_data_clear
    assert(@@gm.data_clear)
    assert_equal([], @@gm.get_group_array)
  end
  
  def test_load
    assert_equal(10, @@gm.load_group_data("sample_group.json"))
    assert_equal(10, @@gm.get_group_array.size)
    
    @@gm.data_clear
    # JSONじゃないファイルを入力
    assert(@@gm.load_group_data("sample_group.jso")==false)
    assert_equal(0, @@gm.get_group_array.size)
  end
  
  def test_save 
  end
end