#!/bin/sh

while getopts t OPT
do
  case $OPT in
    "t" ) FLG_T="TRUE" ;;
    #"b" ) FLG_B="TRUE" ; VALUE_B="$OPTARG" ;;
    #"c" ) FLG_C="TRUE" ; VALUE_C="$OPTARG" ;;
    #  * ) echo "Usage: $CMDNAME [-a] [-b VALUE] [-c VALUE]" 1>&2
    #      exit 1 ;;
  esac
done

if [ "$FLG_T" = "TRUE" ]; then
    echo "RANDOM"
    ruby random-task.rb 120411 12 10 4 120411,50,0.5
fi
ruby 120411.rb
#ruby show-task.rb 120411_min