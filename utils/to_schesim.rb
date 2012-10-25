# -*- coding: utf-8 -*-
#
# タスクセットファイル(*.json 4つ)をschesimの*.rb, *.jsonに変換して
# *.log, *.resファイルも作成する
#

input_taskfile_prefix = ARGV[0] # ./hoge
output_taskfile_prefix = ARGV[1]

# four hoge_xxx.json files -> hoge.rb, hoge.json
p File::dirname(output_taskfile_prefix)
#`ruby ./utils/convert_schesim.rb #{input_taskfile} #{}`

