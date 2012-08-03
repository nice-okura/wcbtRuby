#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 計測
require "benchmark"
require "./manager"

@manager = AllManager.new
@manager.load_tasks("./testFolder/for_test_LB_nest")

puts Benchmark::CAPTION

puts Benchmark.measure{ 
  1000000.times do
    $calc_task.each{ |t| raise unless t.class == Task }
  end
}
puts Benchmark.measure{ 
  1000000.times do
    partition(ProcessorManager.get_proc(1)).each{ |t| raise unless t.class == Task }
  end
}

puts Benchmark.measure{ 
  1000000.times do
    ProcessorManager.get_proc(1).task_list.each{ |t| raise unless t.class == Task }
  end
}
