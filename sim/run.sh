#!/bin/sh
export LD_LIBRARY_PATH=`pwd`/../contrib:.:$LD_LIBRARY_PATH
killall shmidcat
WAVEFILE=/tmp/pipe.vcd
[ -e $WAVEFILE ] || mkfifo $WAVEFILE
echo Running for platform $1
[ -e $1$2.sav ] || cp $1.sav $1$2.sav
shmidcat $WAVEFILE | gtkwave -g -v -I $1$2.sav &
ID_WAVE=$!
./tb_$1 --vcd=$WAVEFILE  2> /tmp/log
kill $ID_WAVE
