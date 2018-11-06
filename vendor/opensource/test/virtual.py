#Test script to drive virtual simple ghdlex TAP
# (c) 2017-2018, section5.ch

# Usage: start sim/tb_virtual, and run this script
# It will wait for a CPU BREAK signal, then reset the target, resume
# and continue until the next break

import netpp
import time

def wait_for_break(r):
	r.SimThrottle.set(0)
	while r.Break.get() == False:
		print "Waiting for break..."
		time.sleep(1.0)
	r.SimThrottle.set(1)


dev = netpp.connect("TCP:localhost")
r = dev.sync()

wait_for_break(r)
print "Got break"

print "Resetting target..."
r.Reset.set(1)
r.Reset.set(0)

print "Resuming target..."
r.Resume.set(1)
r.Resume.set(0)

print "Resuming target..."

wait_for_break(r)

print "Got break, done"

