#!/bin/sh
# -*- coding: utf-8 -*-
#=author: fujitani
#=Date: 2012/09/10
#
# to_schesim.sh
#
# タスクセットファイルをschesimに変換するスクリプト
#
# Usage:
# % sh ./to_schesim [タスクファイル名] [出力ファイル名]
# % ruby convert_schesim.rb [タスクファイル名] [出力ファイル名]
#Ex.
#% ruby ../random-task.rb 20tasks 20 2 10 
#% ruby ../convert_schesim.rb 20tasks 20tasks_schesim
#% cp -r 20tasks_schesim ../../schesim-0.7.2/
#% cd ../../schesim-0.7.2/
#% . auto_schesim.sh 20tasks_schesim/20tasks_schesim
#
if [ $# -eq 3 ]; then
    #echo "正しい引数です"
    ruby convert_schesim.rb $1 $2
    cp -r $2 ../schesim-0.7.2/
    cd ../schesim-0.7.2/
    . auto_schesim.sh $2/$2 $3
    cd ~/Documents/lab/tkdos/wcbtRuby/
	
else
    echo "正しい引数を入力して"
    echo "% sh ./to_schesim [タスクファイル名] [出力フォルダ名] [schesimシミュレーション時間]"
    echo "Ex."
    echo "% . to_schesim.sh 20task ./20tasks_schesim 1000"　
fi
