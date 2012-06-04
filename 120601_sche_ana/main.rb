#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= 
#
#Author:: Takahiro FUJITANI (ERTL, Nagoya Univ.)
#Version:: 0.1.0
#License::
#
#== Usage:
#
#=== 
#$:.unshift(File.dirname(__FILE__))
require "manager"

include WCBT
@manager = AllManager.new
@manager.load_tasks("120601")
#@manager.create_tasks(4, 5, 5, ["0"])
#@manager.save_tasks("120601")

@manager.tm.get_task_array.each{ |t|
  #g = t.req_list[0].res.group
  #pp get_Rset_for_spin(t, g)
  aid = []
  bid = []
  A(t).each{ |ta|
    aid << ta.task_id
  }
  B(t).each{ |tb|
    bid << tb.task_id
  }
  
  puts "A(タスク#{t.task_id}):#{aid}"
  puts "B(タスク#{t.task_id}):#{bid}"
  puts "L(タスク#{t.task_id}):#{L(t)}"
}
