#!/bin/bash
# Virtual COM for ghdlex
# 2012-2017, <hackfin@section5.ch>

me=`whoami`

VCOM=/tmp/virtualcom

socat PTY,link=/tmp/ghdlsim,raw,echo=0,user=$me \
	   PTY,link=$VCOM,raw,echo=0,user=$me & \
echo Virtual COM running on $VCOM. Use: minicom -o -D $VCOM

/bin/bash
