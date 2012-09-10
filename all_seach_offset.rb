#!/usr/bin/ruby
# -*- encoding : utf-8 -*-

# 各タスクのoffsetをずらして全数探索でブロック時間を計測する
# Usage: ruby all_search_offset.rb [filename]

require "manager"

Filename = ARGV[0]
@manager = AllManager.new

def init 
  @manager = load_tasks(Filename)
end

# offset of this task increament 
# @param task
# @return true if success increament, false if offset == period
def add_offset(task)
  task.offset += 1
  return false if task.offset == task.preiod
  return true
end

# main
task_list = @manager.TaskManager.get_task_array

# offset of all tasks = 0
task_list.each do |t|
  t.offset = 0
end



# 
