require "manager"
require "task-CUI"
require "json"

if(ARGV.size < 4)
  puts "引数が足りません．"
  puts "% #{File.basename(__FILE__)} 出力ファイル名 タスク数 リソース要求数 グループ数"
  exit
end
  
FILENAME = ARGV[0]

@manager = AllManager.new
@manager.create_tasks(ARGV[1].to_i, ARGV[2].to_i, ARGV[3].to_i)
@manager.save_tasks("#{FILENAME}_task.json", "#{FILENAME}_require.json", "#{FILENAME}_group.json")

taskset = TaskSet.new(@manager.tm.get_task_array)
taskset.show_taskset