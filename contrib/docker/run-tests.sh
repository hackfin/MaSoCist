#!/bin/bash

SFX=masocist-synth_1.0_sfx.sh
wget https://section5.ch/downloads/$SFX -nc && \
	sh $SFX

# Create pipe for testing, explicitely. Don't rely on
# init-pty.sh entry point.
me=`whoami`
VCOM=/tmp/virtualcom
socat PTY,link=/tmp/ghdlsim,raw,echo=0,user=$me \
	   PTY,link=$VCOM,raw,echo=0,user=$me &

make all test-neo430
