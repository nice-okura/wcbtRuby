require "manager"
require "task-CUI"
require "json"

if(ARGV.size < 4)
  puts "引数が足りません．"
  puts "% #{File.basename(__FILE__)} 出力ファイル名 タスク数 リソース要求数 グループ数 info"
  puts "info:カンマ区切り情報 \n Ex. 120411,50,0.3"
  
  exit
end
  
FILENAME = ARGV[0]
unless ARGV[4] == nil
  info = ARGV[4].split(',')
else
  info = ["0"]
end
p info
@manager = AllManager.new
@manager.create_tasks(ARGV[1].to_i, ARGV[2].to_i, ARGV[3].to_i, info)
@manager.save_tasks("#{FILENAME}")

taskset = TaskSet.new(@manager.tm.get_task_array)
taskset.show_taskset
