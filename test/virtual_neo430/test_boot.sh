#!/bin/bash

# Run small check to see if neo430 is properly booting
# and spitting out stuff on the virtual UART

MASOCIST=$HOME/src/vhdl/masocist-opensource

echo MASOCIST dir: $MASOCIST

cd $MASOCIST/sim
cat /tmp/virtualcom > output.txt &
CAT_PID=$!
echo Running test bench ...
./$1 --stop-time=8ms >/dev/null
kill $CAT_PID
if [ $? != 0 ]; then
	exit 1
fi
out=`cat output.txt | grep Booting | cut -d " " -f 1,2`
if [ "$out" = "Booting neo430" ]; then
	echo -e "\e[42mPASS\e[0m"
	exit 0
else
	echo -e "\e[41mFAIL\e[0m"
	echo Output received:
	echo "${out}"
	exit 1
fi;

