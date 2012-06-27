set terminal png size 960,640
set xlabel "rcsl"
set ylabel "tasksets"
set xrange [0:0.07]
set yrange [0:110]
set title "A ratio of Resource Group(8Tasks, group1:0.01-0.06 other:0.01)"
set output "8tasks_rcsl_change0.01.png"
set boxwidth 0.005
plot 'log_8tasks_rcsl_change.txt' using 1:($2+$3+$4+$5) ti "All short" w boxes fs pattern 1, \
     '' using 1:($2+$3+$4) ti "Group1 is short, but some of other groups are long" w boxes fs pattern 2, \
     '' using 1:($2+$3) ti "Group1 and other group are long" w boxes fs pattern 3, \
     '' using 1:2 ti "Only Group1 is long" w boxes fs pattern 4
