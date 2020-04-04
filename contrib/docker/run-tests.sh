#!/bin/bash

wget https://section5.ch/downloads/masocist_sfx.sh -nc && \
	sh masocist_sfx.sh

# Create pipe for testing, explicitely. Don't rely on
# init-pty.sh entry point.
me=`whoami`
VCOM=/tmp/virtualcom
socat PTY,link=/tmp/ghdlsim,raw,echo=0,user=$me \
	   PTY,link=$VCOM,raw,echo=0,user=$me &

make all test-pyrv32
