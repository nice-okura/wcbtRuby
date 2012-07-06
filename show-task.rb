$:.unshift(File.dirname(__FILE__))
require "manager"
require "task-CUI"
require "json"
require "wcbt"

include WCBT

FILENAME = ARGV[0]
opt = ARGV[1]
$DEBUGFlg = true if opt == "-d"
@manager = AllManager.new
@manager.load_tasks("#{FILENAME}")

taskset = TaskSet.new#(@manager.tm.get_task_array)
taskset.show_taskset
#init_computing(@manager.tm.get_task_array)
#set_blocktime
taskset.show_blocktime
