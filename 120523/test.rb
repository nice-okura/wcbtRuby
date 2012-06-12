#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
$:.unshift(File.dirname(__FILE__))
require "../task-CUI"
require "../manager"
include WCBT

FILENAME = ARGV[0]

@manager = AllManager.new
@manager.load_tasks("#{FILENAME}")

taskset = TaskSet.new(@manager.tm.get_task_array)
taskset.show_taskset
taskset.show_blocktime
t = @manager.tm.get_task_array[4]
puts t.task_id
puts t.wcrt
