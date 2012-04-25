$:.unshift(File.dirname(__FILE__))
require "manager"
require "task-CUI"
require "json"
require "wcbt"

include WCBT

FILENAME = ARGV[0]

@manager = AllManager.new
@manager.load_tasks("#{FILENAME}_task.json", "#{FILENAME}_require.json", "#{FILENAME}_group.json")

taskset = TaskSet.new(@manager.tm.get_task_array)
taskset.show_taskset
show_blocktime
