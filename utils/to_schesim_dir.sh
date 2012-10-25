#!/bin/sh
# -*- coding: utf-8 -*-
#=author: fujitani
#=Date: 2012/09/10
#
# to_schesim.sh
#
# あるディレクトリのタスクセットファイルをschesimに変換するスクリプト
#
# Usage:
# % sh ./to_schesim_dir [入力ディレクトリ名] [出力ディレクトリ名] [シミュレーション時間]


if [ $# -eq 3 ]; then
    #echo "正しい引数です"
    ruby convert_schesim.rb $1 $2
    cp -r $2 ../schesim-0.7.2/taskset_files/
    cd ../schesim-0.7.2/
    . auto_schesim.sh $2/$2 $3
    cd ~/Documents/lab/tkdos/wcbtRuby/
    
else
    echo "正しい引数を入力して"
    echo " % sh ./to_schesim_dir [入力ディレクトリ名] [出力ディレクトリ名] [シミュレーション時間]"
    echo "Ex."
    echo "% . to_schesim.sh 20task ./20tasks_schesim 1000"　
fi
