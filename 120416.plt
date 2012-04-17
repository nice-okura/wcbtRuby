#!/Applications/gnuplot.app/bin/gnuplot -persist
#
#    
#    	G N U P L O T
#    	Version 4.7 patchlevel 0    last modified 2012-03-12 
#    	Build System: Darwin x86_64
#    
#    	Copyright (C) 1986-1993, 1998, 2004, 2007-2012
#    	Thomas Williams, Colin Kelley and many others
#    
#    	gnuplot home:     http://www.gnuplot.info
#    	mailing list:     gnuplot-beta@lists.sourceforge.net
#    	faq, bugs, etc:   type "help FAQ"
#    	immediate help:   type "help"  (plot window: hit 'h')
# set terminal x11 
# set output
set yrange [0:3]
set title "The number of long resources in 8tasks" 
set xlabel "critical section length(RCSL)" 
set ylabel "The number of long resources in 8tasks" 

set terminal png
set output "120416_plt_8tasks.png"
plot "pltdata_120416_log.txt_8tasks.dat" using 1:2 title "8tasks 1group" w l, \
     "pltdata_120416_log.txt_8tasks.dat" using 1:3 title "8tasks 2groups" w l, \
     "pltdata_120416_log.txt_8tasks.dat" using 1:4 title "8tasks 4groups" w l, \
     "pltdata_120416_log.txt_8tasks.dat" using 1:5 title "8tasks 8groups" w l
set output "120416_plt_12tasks.png"
plot "pltdata_120416_log.txt_12tasks.dat" using 1:2 title "12tasks 1group" w l, \
     "pltdata_120416_log.txt_12tasks.dat" using 1:3 title "12tasks 2groups" w l, \
     "pltdata_120416_log.txt_12tasks.dat" using 1:4 title "12tasks 4groups" w l, \
     "pltdata_120416_log.txt_12tasks.dat" using 1:5 title "12tasks 8groups" w l
set output "120416_plt_16tasks.png"
plot "pltdata_120416_log.txt_16tasks.dat" using 1:2 title "16tasks 1group" w l, \
     "pltdata_120416_log.txt_16tasks.dat" using 1:3 title "16tasks 2groups" w l, \
     "pltdata_120416_log.txt_16tasks.dat" using 1:4 title "16tasks 4groups" w l, \
     "pltdata_120416_log.txt_16tasks.dat" using 1:5 title "16tasks 8groups" w l
#    EOF
