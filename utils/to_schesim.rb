# -*- coding: utf-8 -*-
#
# タスクセットファイル(*.json 4つ)をschesimの*.rb, *.jsonに変換して
# *.log, *.resファイルも作成する
#

SCHESIM ="./schesim.rb"

def usage
  puts "Usage: ruby to_schesim.rb <input_taskfile_prefix> <output_taskfile_prefix> <simulation time for schesim>"
  puts "% ruby utils/to_schesim.rb json/for_ET/tlv json/for_ET/schesim/tlv 1000"
  puts ""
  puts "# if you have taskset files, json/hoge/tmp_task.json, json/hoge/tmp_require.json, json/hoge/tmp_group.json and json/hoge/tmp_proc.json,  "
  puts "# input_taskfile_prefix is \"json/hoge/tmp \""
end

unless ARGV.size == 3
  usage
  exit
end

input_taskfile_prefix = ARGV[0]   # ./json/tmp
output_taskfile_prefix = ARGV[1]  # ./json/schesim/tmp
sim_time = ARGV[2]


## four hoge_xxx.json files -> hoge.rb, hoge.json

# mkdir schesim directory for hoge.rb, hoge.json
Dir::mkdir File::dirname(output_taskfile_prefix) unless File::exist?(File::dirname(output_taskfile_prefix))

# make hoge.rb, hoge.json in output_taskfile directory
`ruby ./utils/convert_schesim.rb #{input_taskfile_prefix} #{output_taskfile_prefix}`

# cd
Dir::chdir("../schesim-0.7.2")

# make *.log, *.res files
json_file = "../wcbtRuby/#{output_taskfile_prefix}.json"
rb_file = "../wcbtRuby/#{output_taskfile_prefix}.rb"
res_file = "../wcbtRuby/#{output_taskfile_prefix}.res"
log_file = "../wcbtRuby/#{output_taskfile_prefix}.log"
p json_file
`ruby schesim.rb -t #{json_file} -d #{rb_file} -r #{res_file} -e #{sim_time} > #{log_file}`

# copy to dropbox for TLV
dirname = "../wcbtRuby/#{File::dirname(input_taskfile_prefix)}"
`cp -r  #{dirname} ~/Dropbox/tkdos/tlv/taskset_files`
