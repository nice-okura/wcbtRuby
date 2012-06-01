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
@manager.create_tasks(4, 10, 10)
pp $taskList
