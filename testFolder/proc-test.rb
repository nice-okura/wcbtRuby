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
    @manager.all_data_clear
    @manager.load_tasks("test")
    @manager.pm.show_proc_info
  end

  def test_assign_list_order
    info = { :mode => "0", :assign_mode => LIST_ORDER}
    @manager.create_tasks(10, 4, 4, info)
    @manager.pm.assign_tasks(@manager.tm.get_task_array.sort_by{ rand }, info)
    @manager.pm.show_proc_info
    #@manager.save_tasks("test")
  end

  def test_assign_id_order
    info = { :mode => "0", :assign_mode => ID_ORDER}
    @manager.create_tasks(10, 4, 4, info)
    @manager.pm.assign_tasks(@manager.tm.get_task_array.reverse!, info)
    @manager.pm.show_proc_info
    #@manager.save_tasks("test")
  end
end
