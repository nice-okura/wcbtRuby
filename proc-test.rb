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
  end
end
