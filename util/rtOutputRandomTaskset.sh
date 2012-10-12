#!/bin/sh
#
#=Author: fujitani
#=Date: 2012/10/09
#
# rtOutpuRandomTaskset.sh
#
# ランダムなタスクセットを生成し，平均，最大実実行時間を計測する
#
# Usage: 
# % sh ./rtOutputRandomTaskset.sh [結果出力ファイル名] [タスクセット数]

readonly SCHESIM_FOLDER="/Users/fujitani/Documents/lab/tkdos/schesim-0.7.2/"
readonly WCBT_FOLDER="/Users/fujitani/Documents/lab/tkdos/wcbtRuby/"
readonly TMP_FILENAME="tmp"

# タスクパラメータ
readonly TASKSET=$2
readonly CPU=2
readonly TASK=4
readonly REQUIRE=8
readonly RESOURCE=2
readonly REQ_COUNT=2

for tsk in 4 6 8; do
    if [ $# -eq 2 ]; then
	for i in `seq 1 ${TASKSET}`; do
	    cd ${WCBT_FOLDER}
	    ruby ./util/randomSchesimFile.rb ${TMP_FILENAME} ${tsk}
            #ruby ${WCBT_FOLDER}make_taskset.rb ${WCBT_FOLDER}rtOutputRandomTaskset/${TMP_FILENAME} ${CPU} ${TASK} ${REQUIRE} ${RESOURCE} -m c -a 2 -c ${REQ_COUNT} -E 50..200 
	    cd ${SCHESIM_FOLDER}
	    ./auto_schesim.sh ./tmp_schesim/tmp_schesim 2> /dev/null
	    mkdir ${TMP_FILENAME}_schesim/data_${tsk}task/
	    ruby utils/stats.rb -c -i ${TMP_FILENAME}_schesim/${TMP_FILENAME}_schesim.log -o /dev/null > ${TMP_FILENAME}_schesim/data_${tsk}task/${TMP_FILENAME}_schesim_${i}.csv
	done
	cd ${WCBT_FOLDER}
	
    else
	echo "Usage: \n% ./rtOutputRandomTaskset.sh [結果出力ファイル名] [タスクセット数]"
    fi
done
ruby ${WCBT_FOLDER}util/csv2plt.rb ${SCHESIM_FOLDER}${TMP_FILENAME}_schesim/ ${WCBT_FOLDER}test.txt