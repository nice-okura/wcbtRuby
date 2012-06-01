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
$:.unshift(File.dirname(__FILE__))
require "manager"

include WCBT
msum(5, [1,2])

@manager = AllManager.new
@manager.load_tasks("120601")
#@manager.create_tasks(4, 5, 5, ["0"])
#@manager.save_tasks("120601")
t = @manager.tm.get_task_array[0]
g = t.req_list[0].res.group
p g
pp get_Rset_for_spin(t, g)
