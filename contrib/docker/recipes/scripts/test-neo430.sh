#!/bin/bash

# Don't run regtest, just fire up test bench and minicom
# to virtual COM port
#
MASOCIST=$HOME/src/vhdl/masocist-opensource

cd $MASOCIST/sim
cat /tmp/virtualcom > output.txt &
CAT_PID=$!
echo Running test bench ...
./tb_$1 --stop-time=8ms >/dev/null
kill $CAT_PID
out=`cat output.txt | grep Booting | cut -d " " -f 1,2`
if [ "$out" = "Booting neo430" ]; then
	echo PASS
	exit 0
else
	echo FAIL
	echo Output received:
	echo "${out}"
	exit 1
fi;
