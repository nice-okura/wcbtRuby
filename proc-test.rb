#! /usr/bin/ruby
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))
require "task"
require "test/unit"
require "pp"
require "task-CUI"
require "manager"

class Test_proc < Test::Unit::TestCase
 
  def setup
  end
  
  def test_proc_init
    @manager = AllManager.new
    @manager.pm.show_proc_info
    @manager.save_tasks("test")
    @manager.load_tasks("test")
    @manager.create_tasks(10, 2, 2, { :mode => "0" })
    @manager.save_tasks("test")
    @manager.load_tasks("test")
  end
end
