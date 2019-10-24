#!/bin/sh
export LD_LIBRARY_PATH=$HOME/src/vhdl/ghdlex:.:$LD_LIBRARY_PATH
killall shmidcat
WAVEFILE=/tmp/pipe.vcd
[ -e $WAVEFILE ] || mkfifo $WAVEFILE
echo Running for platform $1
echo $LD_LIBRARY_PATH
[ -e $1$2.sav ] || cp $1.sav $1$2.sav
shmidcat $WAVEFILE | gtkwave -g -v -I $1$2.sav &
ID_WAVE=$!
if [ -e tb_$1 ]; then
	./tb_$1 $3 --vcd=$WAVEFILE  2> /tmp/log
else
	./net_$1 $3 --vcd=$WAVEFILE  2> /tmp/log
fi;

kill $ID_WAVE
