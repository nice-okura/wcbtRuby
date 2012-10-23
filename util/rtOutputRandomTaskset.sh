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
readonly TASKSET_FILES="taskset_files/"

# タスクパラメータ
readonly TASKSET=$2
readonly CPU=2
readonly TASK=4
readonly MAX_TASK=8
readonly REQUIRE=8
readonly RESOURCE=2
readonly REQ_COUNT=2
readonly SIM_TIME=10000

if [ $# -eq 2 ]; then
    for tsk in `seq ${TASK} 2 ${MAX_TASK}`; do
	# 最大応答時間を格納する配列
	WCRT=()

	# ファイル新規作成
	cd ${SCHESIM_FOLDER}
	mkdir ${TMP_FILENAME}_schesim/data_${tsk}task/ >& /dev/null
	filename="${TMP_FILENAME}_schesim/data_${tsk}task/task_wcrt_${tsk}task.txt"
	touch ${filename}  # ファイル生成
	echo > ${filename} # ファイル初期化
	
	for i in `seq 1 ${TASKSET}`; do
	    echo ${tsk}:${i}
	    cd ${WCBT_FOLDER}
	    #ruby ./util/randomSchesimFile.rb ${TMP_FILENAME} ${tsk}
	    WCRT=("${WCRT[@]}" `ruby ./util/randomSchesimFile.rb ${TMP_FILENAME} ${tsk}`)
            
	    cd ${SCHESIM_FOLDER}
	    ./auto_schesim.sh ./${TASKSET_FILES}tmp_schesim/tmp_schesim ${SIM_TIME} >& /dev/null
	    
	    ruby utils/stats.rb -c -i ${TASKSET_FILES}${TMP_FILENAME}_schesim/${TMP_FILENAME}_schesim.log -o /dev/null > ${TASKSET_FILES}${TMP_FILENAME}_schesim/data_${tsk}task/${TMP_FILENAME}_schesim_${i}.csv
	done
	cd ${SCHESIM_FOLDER}
	#echo ${filename}
	for i in `seq 1 ${TASKSET}`; do
	    echo ${WCRT[i-1]} >> ${filename}
	done
    done
    cd ${WCBT_FOLDER}
    #ruby ${WCBT_FOLDER}util/csv2plt.rb ${SCHESIM_FOLDER}${TASKSET_FILES}${TMP_FILENAME}_schesim/ ${WCBT_FOLDER}test.txt ${MAX_TASK}
else
    echo "Usage: \n% ./rtOutputRandomTaskset.sh [結果出力ファイル名] [タスクセット数]"
fi