$:.unshift(File.dirname(__FILE__))
require "manager"
require "task-CUI"
require "json"
require "wcbt"

include WCBT

FILENAME = ARGV[0]

@manager = AllManager.new
@manager.load_tasks("#{FILENAME}")

$DEBUG=true
taskset = TaskSet.new(@manager.tm.get_task_array)
taskset.show_taskset
init_computing
set_blocktime
taskset.show_blocktime
