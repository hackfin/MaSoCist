#!/bin/bash

# Runs 
# to virtual COM port
#
MASOCIST=$HOME/src/vhdl/masocist-opensource

make -C $MASOCIST virtual_riscv-main sim

make -C $MASOCIST/test/virtual_riscv all
