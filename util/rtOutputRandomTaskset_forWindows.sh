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
# % sh ./rtOutputRandomTaskset_forCygwin.sh [結果出力ファイル名] [タスクセット数]

readonly SCHESIM_FOLDER="/cygdrive/c/Users/fujitani/Documents/schesim-0.7.2/"
readonly WCBT_FOLDER="/cygdrive/c/Users/fujitani/Documents/wcbtRuby/"
readonly TMP_FILENAME="tmp"

# タスクパラメータ
readonly TASKSET=$2
readonly CPU=2
readonly TASK=4
readonly MAX_TASK=16
readonly REQUIRE=8
readonly RESOURCE=2
readonly REQ_COUNT=2

if [ $# -eq 2 ]; then
    for tsk in `seq ${TASK} 2 ${MAX_TASK}`; do
	# 最大応答時間を格納する配列
	WCRT=()

	# ファイル新規作成
	cd ${SCHESIM_FOLDER}
	mkdir ${TMP_FILENAME}_schesim/data_${tsk}task/ >& /dev/null
	filename="${TMP_FILENAME}_schesim/data_${tsk}task/task_wcrt_${tsk}task.txt"
	touch ${filename}
	echo > ${filename}
	
	for i in `seq 1 ${TASKSET}`; do
	    echo ${i}
	    cd ${WCBT_FOLDER}
	    #ruby ./util/randomSchesimFile.rb ${TMP_FILENAME} ${tsk}
	    WCRT=("${WCRT[@]}" `ruby ./util/randomSchesimFile_forCygwin.rb ${TMP_FILENAME} ${tsk}`)
            
	    cd ${SCHESIM_FOLDER}
	    ./auto_schesim_forCygwin.sh ./tmp_schesim/tmp_schesim >& /dev/null
	    
	    ruby utils/stats.rb -c -i ${TMP_FILENAME}_schesim/${TMP_FILENAME}_schesim.log -o /dev/null > ${TMP_FILENAME}_schesim/data_${tsk}task/${TMP_FILENAME}_schesim_${i}.csv
	done
	cd ${SCHESIM_FOLDER}
	#echo ${filename}
	for i in `seq 1 ${TASKSET}`; do
	    echo ${WCRT[i-1]} >> ${filename}
	done
    done
    cd ${WCBT_FOLDER}
    ruby ${WCBT_FOLDER}util/csv2plt.rb ${SCHESIM_FOLDER}${TMP_FILENAME}_schesim/ ${WCBT_FOLDER}test.txt ${MAX_TASK}
else
    echo "Usage: \n% ./rtOutputRandomTaskset.sh [結果出力ファイル名] [タスクセット数]"
fi