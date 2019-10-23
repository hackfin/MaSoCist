#!/bin/bash

# Don't run regtest, just fire up test bench and minicom
# to virtual COM port
#
MASOCIST=$HOME/src/vhdl/masocist-opensource

# In case we use the default GHDLEX lib:
export LD_LIBRARY_PATH=$GHDLEX:$LD_LIBRARY_PATH

cd $MASOCIST/sim
./$1 >/dev/null &
TB_PID=$!
minicom -o -D /tmp/virtualcom
kill $TB_PID
