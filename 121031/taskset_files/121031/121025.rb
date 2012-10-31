# -*- coding: utf-8 -*-
#
# あるディレクトリのサブディレクトリの*.rb, *.jsonファイルから*.log, *.resファイルを作成する
#
# 
#
# Folder Tree Ex.
#
#  tmp_schesim
#      |
#      |- tmp_schesim_0_schesim
#      |             |-- tmp_schesim_0_schesim.rb
#      |             |-- tmp_schesim_0_schesim.json 
#      |
#      |- tmp_schesim_1_schesim
#      |             |-- tmp_schesim_1_schesim.rb
#      |             |-- tmp_schesim_1_schesim.json 
#      |
#      |- tmp_schesim_2_schesim
#      |                 .....
# Usage: 
#   % ruby auto_schesim.rb ./tmp_schesim 100
#

require "./utils/schesim_taskset"
require "progressbar"

unless ARGV.size == 2
  puts "## Usage:"
  puts "  % ruby auto_schesim.rb ./tmp_schesim 100"
  exit
end

dirname = ARGV[0]
simtime = ARGV[1].to_i

dirname += '/' unless dirname =~ /\/$/ # ディレクトリパスの末尾が / でなければ / をつける

unless File.exist?(dirname)
  puts "ディレクトリが存在しません．"
  exit
end

pbar = ProgressBar.new("応答時間の計測", 100)
pbar.format_arguments = [:percentage, :bar, :stat]
pbar.format = "%3d%% %s %s"

rt_aves = Array.new(100, 0.0)
Dir::glob("#{dirname}*/") do |subdir|
  taskset_num = subdir.scan(/([\d]+)_schesim/)[0][0].to_i

  # サブディレクトリを抽出
  STDERR.puts subdir
  taskset = SchesimTaskset.new(subdir, simtime)
  taskset.make_log
  taskset.make_stats

  rt_aves[taskset_num] = taskset.tasks[1].get_rt_ave
  
  pbar.inc
end
pbar.finish

File.open("#{File::dirname(File::expand_path(__FILE__))}/rt_ave_preemptive.txt", "w") do |f|
  rt_aves.each_with_index do |rt, i|
    f.puts "#{i} #{rt}"
  end
end
