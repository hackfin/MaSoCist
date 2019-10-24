#!/bin/bash

# Don't run regtest, just fire up test bench and minicom
# to virtual COM port
#
MASOCIST=$HOME/src/vhdl/masocist-opensource

# In case we use the default GHDLEX lib:
export LD_LIBRARY_PATH=$GHDLEX:$LD_LIBRARY_PATH

cd $MASOCIST/sim
if [ -e $1 ]; then
	./$1 --max-stack-alloc=256 >/dev/null &
	TB_PID=$!
	echo "Check if simulation running..."
	sleep 1
	if jobs | grep \$1;  then
		# Turn off tap throttle:
		netpp localhost TapThrottle 0
		minicom -o -D /tmp/virtualcom
		kill $TB_PID
	else
		echo
		jobs
		echo -e "\e[41m$1 just exited\e[0m"
	fi
else
	echo
	echo -e "\e[41m$1 not found\e[0m"
	false
fi
