#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= RequireManager のテスト
#
#Author:: Takahiro FUJITANI (ERTL, Nagoya Univ.)
#Version:: 0.5.0
#License::
#
#== Usage:
#
#=== 
$:.unshift(File.dirname(__FILE__))
# 標準ライブラリ
require "pp"
require "rubygems"  

# 独自ライブラリ
require "../manager"
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

class TestRequireManager < Test::Unit::TestCase
  def setup
    @@gm = GroupManager.instance
    count = rand(100)
    @@gm.create_group_array(count)
    @@rm = RequireManager.instance
    @@rm.set_garray(@@gm.get_group_array)
    @@rm.data_clear
  end

  def test_initialize
    assert_equal([], @@rm.get_require_array)
  end
  
=begin
  def test_create_require
    assert_kind_of(Req, @@rm.create_require_array(1))

    50.times{
      a_group = rand(20)
      a_time = rand(100)
      assert_kind_of(Req, @@rm.create_require(a_group))
      assert_kind_of(Req, @@rm.create_require(a_group, a_time))
    }
  end
  
=end
  def test_create_require_array
    i = rand(100)
    50.times{
      assert_equal(i, @@rm.create_require_array(i))
      assert_equal(i, @@rm.create_require_array(i, {:mode => "120405_3"}))
    }
    
  end

  def test_data_clear
    assert(@@rm.data_clear)
    assert_equal([], @@rm.get_require_array)
  end
  
  def test_load
    assert_equal(31, @@rm.load_require_data("sample_require.json"))
    assert_equal(31, @@rm.get_require_array.size)
    
    @@rm.data_clear
    # JSONじゃないファイルを入力
    assert(@@rm.load_require_data("sample_require.jso")==false)
    assert_equal(0, @@rm.get_require_array.size)
  end
  
  def test_get_random_req
    10.times{
      i = rand(100)
      assert_equal(i, @@rm.create_require_array(i))
      #assert_kind_of(Req, RequireManager.get_random_req)
    }
  end

end
