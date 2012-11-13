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
$:.unshift(File.dirname(__FILE__))
# 標準ライブラリ
require "pp"
require "rubygems"  

# 独自ライブラリ
require "./manager"
require "test/unit" # テスト

TASKSET_FOLDER = "./testFolder/test_tasksets/"
class Test_groupMaker < Test::Unit::TestCase
  def setup
    @manager = AllManager.new
    @@gm = GroupManager.instance
    @manager.all_data_clear
  end

  def set_taskset(filename)
    @manager.all_data_clear
    @manager.load_tasks(filename)
  end

  def test_initialize
    assert_equal([], GroupManager.get_group_array)
  end
  
  def test_create_group
    i = rand(100)
    assert_equal(i, @@gm.create_group_array(i))
  end
    
  def test_data_clear
    assert(@@gm.data_clear)
    assert_equal([], GroupManager.get_group_array)
  end
  
  def test_load
    assert_equal(8, @@gm.load_group_data("#{TASKSET_FOLDER}for_test_LB_nest_group.json"))
    assert_equal(8, GroupManager.get_group_array.size)
    
    @@gm.data_clear
    # JSONじゃないファイルを入力
    assert_equal(false, @@gm.load_group_data("sample_group.jso"))
    assert_equal(0, GroupManager.get_group_array.size)
  end
  
  def test_get_ramdom_short_group
    set_taskset("#{TASKSET_FOLDER}for_test_LB_nest")
    assert_equal(8, GroupManager.get_group_array.size)
    100.times { assert_equal(SHORT, GroupManager.get_random_short_group.kind)}
  end

  def test_get_ramdom_long_group
    set_taskset("#{TASKSET_FOLDER}for_test_LB_nest")
    assert_equal(8, GroupManager.get_group_array.size)
    100.times { assert_equal(LONG, GroupManager.get_random_long_group.kind)}
  end
end
