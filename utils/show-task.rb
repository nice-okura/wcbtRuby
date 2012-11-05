#!/usr/bin/ruby
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__))
require "./manager"
require "./utils/task-CUI"
require "json"
require "optparse"

#require "./120601_sche_ana/wcbt-edf"

include WCBT

optparser = OptionParser.new

opt = { }
optparser.on('-d') { $DEBUGFlg = true }
optparser.on('-m [VAL]') do |v|
  case v
  when "priority"
    opt[:sort_mode] = SORT_PRIORITY
  when "id"
    opt[:sort_mode] = SORT_ID
  when "util"
    opt[:sort_mode] = SORT_UTIL
  when "period"
    opt[:sort_mode] = SORT_PERIOD
  end
end
optparser.on('-p'){ $PREEMPTIVE_FLG = true }

optparser.parse!(ARGV)

FILENAME = ARGV[0]
@manager = AllManager.new
@manager.load_tasks(FILENAME, opt)

taskset = TaskSet.new#(@manager.tm.get_task_array)
taskset.show_taskset(opt)
#init_computing(@manager.tm.get_task_array)
#set_blocktime
#taskset.show_blocktime_edf
taskset.show_blocktime
