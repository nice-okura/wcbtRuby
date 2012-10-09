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
# % sh ./rtOutputRandomTaskset.sh [結果出力ファイル名]

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

if [ $# -eq 2 ]; then
    for i in `seq 1 ${TASKSET}`; do
        ruby ${WCBT_FOLDER}make_taskset.rb ${WCBT_FOLDER}rtOutputRandomTaskset/${TMP_FILENAME} ${CPU} ${TASK} ${REQUIRE} ${RESOURCE} -m c -a 2 -c ${REQ_COUNT} -E 50..200 
	sh ./to_schesim.sh ./rtOutputRandomTaskset/${TMP_FILENAME} ./${TMP_FILENAME}_schesim
	ruby ${SCHESIM_FOLDER}utils/stats.rb -c -i ${SCHESIM_FOLDER}${TMP_FILENAME}_schesim/${TMP_FILENAME}_schesim.log -o /dev/null > ${SCHESIM_FOLDER}${TMP_FILENAME}_schesim/data/${TMP_FILENAME}_schesim_${i}.csv
    done
    ruby ${WCBT_FOLDER}util/csv2plt.rb ${SCHESIM_FOLDER}${TMP_FILENAME}_schesim/data/ ${WCBT_FOLDER}test.txt ${TASK}
fi