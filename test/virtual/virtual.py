# Virtual board example
#

import sys
import netpp
import time

sys.path.append("../../utils")

from romgen import *

PROGRAMFILE = "main"

def resume(r):
	"Resumes the CPU"
	r.Emu.IR.set(0x00) # Send resume instruction
	r.Emu.Exec.set(1) # Toggle Execute flag
	r.Emu.Exec.set(0)


def break_test(r):
	"""This test lets the program run until it hits a break."""
	r.TapThrottle.set(0) # let it run at full speed
	print("Running until break...")
	retries = 10
	while r.Break.get() == 0:
		print("Waiting for break...")
		time.sleep(1.0)
		retries -= 1
		if retries < 0:
			raise SystemError, "Break not reached"
	pc = r.Emu.PC.get()
	r.TapThrottle.set(1) # Throttle it
	r.Reset.set(1)
	r.Reset.set(0)
	# Note that Emulation overrides the reset, so we have to explicitely
	# resume:
	# The BREAK command is always one PC behind:
	print("Hit break at %08x" % (pc-1))
	return pc

def set_break(r, addr):
	"Patch BREAK at pc-1 with NOP instruction to resume on next run"
	r.VRAM.Offset.set(addr)
	b = netpp.Buffer(1) # Buffer var to read
	r.VRAM.Buffer.get(b)
	prev = b
	print("Instruction: %02x" % ord(b[0]))
	bpt = buffer(chr(0)) # Breakpoint
	r.VRAM.Buffer.set(bpt)
	return prev

def skip_break_patch(r, pc):
	"Patch BREAK at pc-1 with NOP instruction to resume on next run"
	r.VRAM.Offset.set(int(pc)-1)
	b = buffer(chr(0x0b)) # Patch with NOP instruction
	r.VRAM.Buffer.set(b)


def bootload(url, elffile):
	"Load program into RAM of netpp node and start"
	buf = load_elf(elffile, None)

	symbols = load_symbols(elffile)

	breakpoint_addr = symbols['main'].st_value

	simulation = netpp.connect(url)
	r = simulation.sync()

	r.Reset.set(1)
	ram = r.VRAM
	ram.Offset.set(0)
	ram.Buffer.set(buffer(buf))

	# Set breakpoint in main():
	set_break(r, breakpoint_addr)
	r.Reset.set(0)
	resume(r) # In case a debug event was pending:

	return r


if __name__ == "__main__":
	if len(sys.argv) != 2:
		elffile = "main"
	else:
		elffile = sys.argv[1]

	r = bootload("TCP:localhost", elffile)
	pc = break_test(r)
	resume(r)

	print("Done after second break")
