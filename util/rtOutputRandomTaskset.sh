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

readonly SCHE_DIR="/Users/fujitani/Documents/lab/tkdos/schesim-0.7.2/"
readonly WCBT_DIR="/Users/fujitani/Documents/lab/tkdos/wcbtRuby/"
readonly TMP="tmp"
readonly TS_DIR="taskset_files/"
readonly LOG_FILE="/Users/fujitani/Documents/lab/tkdos/wcbtRuby/util/rt_log.log"

# タスクパラメータ
readonly TASKSET=$2
readonly CPU=2
readonly TASK=4
readonly MAX_TASK=4
readonly REQUIRE=8
readonly RESOURCE=2
readonly REQ_COUNT=2
readonly SIM_TIME=1000

cd ${WCBT_DIR}
rm -rf tmp
mkdir tmp

cd ${SCHE_DIR}
rm -rf ${TS_DIR}${TMP}_schesim # 既存フォルダ削除
mkdir ${TS_DIR}${TMP}_schesim  # フォルダ作成


if [ $# -eq 2 ]; then
    for tsk in `seq ${TASK} 2 ${MAX_TASK}`; do
	# 最大応答時間を格納する配列
	WCRT=()

	# ファイル新規作成
	cd ${SCHE_DIR}
	mkdir ${TS_DIR}${TMP}_schesim/data_${tsk}task/ >& /dev/null
	filename="${TS_DIR}${TMP}_schesim/data_${tsk}task/task_wcrt_${tsk}task.txt"
	touch ${filename}  # ファイル生成
	echo > ${filename} # ファイル初期化
	
	for i in `seq 1 ${TASKSET}`; do
	    echo ${tsk}:${i}
	    cd ${WCBT_DIR}
	    WCRT=("${WCRT[@]}" `ruby ./util/randomSchesimFile.rb ${TMP} ${tsk}`)
            
	    cd ${SCHE_DIR}
	    ./auto_schesim.sh ./${TS_DIR}tmp_schesim/tmp_schesim ${SIM_TIME} >& /dev/null
	    
	    ruby utils/stats.rb -c -i ${TS_DIR}${TMP}_schesim/${TMP}_schesim.log -o /dev/null > ${TS_DIR}${TMP}_schesim/data_${tsk}task/${TMP}_schesim_${i}.csv
	    echo "${TS_DIR}${TMP}_schesim/data_${tsk}task/${TMP}_schesim_${i}.csv生成" > ${LOG_FILE}
	done
	cd ${SCHE_DIR}
	#echo ${filename}
	for i in `seq 1 ${TASKSET}`; do
	    echo ${WCRT[i-1]} >> ${filename}
	done
    done

    # グラフ用プロットデータ出力
    cd ${WCBT_DIR}
    ruby ${WCBT_DIR}util/csv2plt.rb ${SCHE_DIR}${TS_DIR}${TMP}_schesim/ ${WCBT_DIR}test.txt ${MAX_TASK}
else
    echo "Usage: \n% ./rtOutputRandomTaskset.sh [結果出力ファイル名] [タスクセット数]"
fi