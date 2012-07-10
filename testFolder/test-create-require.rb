#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= create-require.rb のテスト
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
    group_count = 10
    @@gm.create_group_array(group_count)
    @@rm = RequireManager.instance
    @@rm.data_clear
  end

  def test_initialize
    @@rm.create_require_array(20)
    group_array_for_check = []
    RequireManager.get_require_array.each{ |req|
      group_array_for_check << req.res
    }
    assert_equal(20, group_array_for_check.size)
    assert_equal(10, group_array_for_check.uniq.size)
    
    # ToDo：ここでinfo[:mode]を変えてテストしたい
    @@rm.create_require_array(20)
    group_array_for_check = []
    RequireManager.get_require_array.each{ |req|
      group_array_for_check << req.res
    }
    assert_equal(20, group_array_for_check.size)
    assert_equal(10, group_array_for_check.uniq.size)
  end

end
