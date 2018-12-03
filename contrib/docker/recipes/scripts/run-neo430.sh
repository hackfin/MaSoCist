#!/bin/bash

# Don't run regtest, just fire up test bench and minicom
# to virtual COM port
#
MASOCIST=$HOME/src/vhdl/masocist-opensource

cd $MASOCIST/sim
./tb_$1 >/dev/null &
TB_PID=$!
minicom -o -D /tmp/virtualcom
kill $TB_PID
