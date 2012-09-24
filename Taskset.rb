#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require "pp"

class Taskset
  attr_reader :task_list
  
  def initialize
    @task_list = []
  end
end
