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
    @manager = AllManager.new
  end
  
  def test_load_save
    @manager.all_data_clear
    @manager.pm.show_proc_info
    @manager.create_tasks(10, 2, 2, { :mode => "0" })
    @manager.save_tasks("test")
    @manager.load_tasks("test")
    @manager.pm.show_proc_info
  end
  
  def test_assign
    #@manager.all_data_clear
    #@manager.create_tasks(10, 4, 4, { :mode => "0"})
    #@manager.pm.assign_tasks(@manager.tm.get_task_array)
    #@manager.pm.show_proc_info
    #@manager.save_tasks("test")
    
    @manager.all_data_clear
    @manager.load_tasks("test")
    @manager.pm.show_proc_info
  end
end
