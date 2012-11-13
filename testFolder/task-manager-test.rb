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
$:.unshift(File.dirname(__FILE__))
# 標準ライブラリ
require "pp"
require "rubygems"  

# 独自ライブラリ
require "./manager"
require "test/unit" # テスト

TASKSET_FOLDER = "./testFolder/test_tasksets/"
class Test_taskMaker < Test::Unit::TestCase
  def setup
    @manager = AllManager.new
  end
  
  def set_taskset(filename)
    @manager.all_data_clear
    @manager.load_tasks(filename)
  end
  
  def test_deadline_miss?
    set_taskset("#{TASKSET_FOLDER}test_deadline_miss")
    
    assert_equal(true, @manager.tm.deadline_miss?)
    assert_equal(8, @manager.tm.get_deadline_miss_tasks.size)
  end
end
