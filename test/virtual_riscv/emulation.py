# Emulation test and riscv-test suite playback
#
# (c) info@section5.ch
#
# This test script is released unter MaSoCist opensource license.
#
#
#
import netpp
import sys
sys.path.append("../../hdl/riscv/pyrv32")
sys.path.append("../../utils")
import time
import elf
import struct

# Need only one scratch register:
CSR_SCRATCH0 = 0x7a2


from riscv32_insn import *

sim = netpp.connect("TCP:localhost:2008")

soc = sim.sync()

# Register defs:
ZERO, RA, SP, GP, TP, T0, T1, T2, S0, S1, A0, A1, A2, A3, A4, A5, A6, \
A7, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, T3, T4, T5, T6 = range(32)

def little_endian(data, i, off):
	j = off + 1
	return data[4*i+j]+data[4*i+off]

def write_imem(soc, imem, data, addr):
	"Write to data memory"
	l = len(data) / 4
	low = [ little_endian(data, i, 0) for i in range(l) ]
	high = [ little_endian(data, i, 2) for i in range(l) ]

	datah = buffer("".join(high))
	datal = buffer("".join(low))

	memh, meml = imem

	memh.Offset.set(addr)
	meml.Offset.set(addr)

	memh.Buffer.set(datah)
	meml.Buffer.set(datal)
		
def write_dmem(soc, dmem, data, addr):
	l = len(data)
	remainder = l % 4
	l -= remainder

	for i in range(0, l, 4):
		word = struct.unpack("<L", data[i:i+4])[0]
		mem_write32(soc, addr, word)
		addr += 4

	if remainder:
		last = 0
		s = 0
		for i in data[-remainder:]:
			last += ord(i) << s
			s += 8
	
		mem_write32(soc, addr, word)


def load_elf(soc, elffile, imemory, dmemory):
	DATA_SECTIONS = [ ".data", ".sdata", ".rodata", ".srodata" ]
	e = elf.ELFObject()
	f = open(elffile)
	e.fromFile(f)
	offset = 0
	if e.e_machine != 0xf3:
		raise TypeError, "This is not a RISCV32 executable: %x" % (e.e_machine)

	for p in e.sections:
		if p.sh_flags & (elf.ELFSection.SHF_WRITE | 
                         elf.ELFSection.SHF_EXECINSTR |
		                 elf.ELFSection.SHF_ALLOC):

			if p.name[:5] == ".text" or p.name == ".init":
				# print "Writing program '%s' at %08x, len: %d" % (p.name, p.sh_addr, len(p.data))
				write_imem(soc, imemory, p.data, p.sh_addr)
			elif p.name in DATA_SECTIONS:
				# print "Writing data '%s' at %08x, len: %d" % (p.name, p.sh_addr, len(p.data))
				write_dmem(soc, dmemory, p.data, p.sh_addr)
		else:
			print "Dropping '%s' at %08x, len: %d" % (p.name, p.sh_addr, len(p.data))

	return e.parseSymbols()

def wait_emuready(emu):
	while emu.Ready.get() == 0:
		pass

def resume(soc, step = 0):
	# Resume:
	emu = soc.Emu
	wait_emuready(emu)
	emu.IR.set(INSN_EMURET)
	if step:
		print "Resume, STEP"
		soc.TapThrottle.set(1)
	else:
		soc.TapThrottle.set(0)
		emu.Req.set(0)
		print "Resume, RUNNING"
	emu.Exec.set(1)
	emu.Exec.set(0)

def test_singlestep(soc):
	print "test single step"
	emu = soc.Emu
	emu.Req.set(1)
	wait_emuready(emu)
	for i in range(40):
		pc = emu.PC.get()
		print " PC: %08x    insn: %08x" % (pc, mem_read32(soc, pc))
		resume(soc, 1)
		wait_emuready(emu)




def halt(soc):
	emu = soc.Emu
	emu.Req.set(1)
	wait_emuready(emu)

def push_opcode(soc, insn):
	emu = soc.Emu
	emu.IR.set(int(insn))
	emu.Exec.set(1)
	emu.Exec.set(0)
	wait_emuready(emu)
	

def get_reg(soc, regno):
	op = insn_csrw(regno, CSR_SCRATCH0)
	emu = soc.Emu
	emu.IR.set(op)
	emu.Exec.set(1)
	emu.Exec.set(0)
	wait_emuready(emu)

	reg = emu.Data.get()
	return reg

def split(val32):
	"Splits value into part for LUI and part for ADDI"
	v_addi = val32 & 0xfff
	# Respect carry fixup: remember that IMM11 values are ALWAYS sign extended
	v_lui = (val32 & ~0xfff) + ( ((v_addi >> 11) & 1) << 12 )

	return v_lui, v_addi

def set_pc(soc, pcaddr):
	"""Note: This is not perfect, as the JALR issues a jump which has
currently priority over emulation. Means, the insn at the set 'pcaddr'
PC is single-step-executed. Not sure if this behaviour is RISC-V compatible."""
	t0save = get_reg(soc, T0)
	a, b = split(pcaddr)
	push_opcode(soc, insn_lui(a, T0))
	push_opcode(soc, insn_jalr(b, T0, ZERO))

	a, b = split(t0save)
	push_opcode(soc, insn_lui(a, T0))
	push_opcode(soc, insn_addi(b, T0))

def test_registers(soc):
	emu = soc.Emu

	r = get_reg(soc, S3)

	if r != 0xdead0000:
		print "Got reg value %08x" % r

		for i in range(32):
			reg = get_reg(soc, i)
			print "Reg %d: %08x" % (i, reg)

		raise ValueError, "Register check failed"

	print "Register check OK"
		
def mem_get_long(soc, addr, n):
	hi = netpp.Buffer(n * 2)
	lo = netpp.Buffer(n * 2)
	addr >>= 1
	soc.VRAM_L.Offset.set(addr)
	soc.VRAM_H.Offset.set(addr)
	soc.VRAM_H.Buffer.get(hi)
	soc.VRAM_L.Buffer.get(lo)

	l = range(len(hi) / 2) 

	print "%02x %02x" % (ord(lo[0]), ord(lo[1]))
	print "%02x %02x" % (ord(hi[0]), ord(hi[1]))

	data32 = [ struct.unpack(">L", (hi[i*2:i*2+2] + lo[i*2:i*2+2]) )[0] for i in l ]

	return data32

def mem_read32(soc, addr):
	"Memory read via registers"
	a, b = split(addr)
	push_opcode(soc, insn_lui(a, T0))
	push_opcode(soc, insn_addi(b, T0))
	push_opcode(soc, insn_load(0, T0, T1, 4))
	push_opcode(soc, insn_csrw(T1, CSR_SCRATCH0))
	reg = soc.Emu.Data.get()
	return reg

def mem_write32(soc, addr, val):
	a, b = split(addr)
	push_opcode(soc, insn_lui(a, T0))
	push_opcode(soc, insn_addi(b, T0))
	a, b = split(val)
	push_opcode(soc, insn_lui(a,  T1))
	push_opcode(soc, insn_addi(b,  T1))
	print "Write %08x to %08x" % (val, addr)
	push_opcode(soc, insn_store(0, T0, T1, 4))


def imem_set_long(soc, addr, insn):
	addr >>= 1
	soc.VRAM_L.Offset.set(addr)
	soc.VRAM_H.Offset.set(addr)

	buf = buffer(struct.pack(">L", insn))

	soc.VRAM_H.Buffer.set(buffer(buf[:2]))
	soc.VRAM_L.Buffer.set(buffer(buf[2:]))

def test_break(soc, brklist):
	"""Test breakpoint. Requires instruction memory write access, only 32 bit
is supported"""
	for brk in brklist:
		brk_addr = brk.st_value
		print "Break addr %08x" % brk_addr
		prev = mem_get_long(soc, brk_addr, 1)
		print "Previous: %08x" % prev[0]
		mem_write32(soc, brk_addr, INSN_EBREAK)

		break_insn = mem_get_long(soc, brk_addr, 1)
		print "brkpt: %08x" % break_insn[0]

		resume(soc)
		while soc.Break.get() == 0:
			pass

		pc = soc.Emu.PC.get()
		print "Hit breakpoint at %08x" % pc
		soc.Emu.Req.set(1)
		wait_emuready(soc.Emu)

		test_registers(soc)

		mem_write32(soc, brk_addr, prev[0]) # Restore
		set_pc(soc, pc)

def run_pyrv32_test(soc, elffile, logfile):
	"Runs the specified ELF file from the test suite"
	halt(soc)

	print("Running test '" + elffile)


	line = 80 * "="

	logfile.write(line + "\n")
	logfile.write("Running test '" + elffile + "'\n")

	sym = load_elf(soc, elffile, (soc.VRAM_H, soc.VRAM_L), None)

	start = sym['_start'].st_value
	pc_pass = sym['brk_pass'].st_value
	pc_fail = sym['brk_fail'].st_value
	set_pc(soc, start)
	resume(soc)
	# Wait for break
	while soc.Break.get() == 0:
		pass

	halt(soc)

	pc_reg = soc.Emu.PC
	curpc = pc_reg.get()
	if (curpc == pc_pass):
		logfile.write("PASSED TEST\n")
	elif (curpc == pc_fail):
		logfile.write("FAILED TEST %d of %s\n" % \
			(get_reg(soc, GP) >> 1, elffile))
		logfile.write("PC at %08x\n" % curpc)
	else:
		logfile.write("TEST result undefined.\n")
		logfile.write("PC at %08x\n" % curpc)

	
############################################################################
# Official riscv test suite integrated:

RISCV_TEST_SUITE = "/home/strubi/build/riscv-tests/isa"

RISCV_TESTS = [
"beq", "bge", "bgeu", "blt", "bltu", "bne", "jal", "jalr", "lb", "lbu",
"lh", "lhu", "lui", "lw", "or", "ori", "sb", "sh", "sll", "slli",
"slt", "slti", "sltiu", "sltu", "sra", "srai", "srl", "srli", "sub", "sw",
"xor", "xori",
]

# Override:
# RISCV_TESTS = [  "jalr", "sra", "srl" ]

DISABLED_TESTS = [
"simple",
"fence_i",
]

def run_riscv32_tests(soc, log_filename):
	"""Run the riscv-tests from the official riscv repo at
https://github.com/riscv/riscv-tests"""
	logfile = open(log_filename, "w")
	for test in RISCV_TESTS:
		elffile = RISCV_TEST_SUITE + "/rv32ui-s5-" + test
		run_pyrv32_test(soc, elffile, logfile)

	logfile.close()

halt(soc)

soc.Reset.set(1)
soc.Reset.set(0)

resume(soc, 1)

run_riscv32_tests(soc, sys.argv[1])

print "RISCV test suite done"

if 0:
	sym = load_elf(soc, "test.elf", (soc.VRAM_H, soc.VRAM_L), None)
	brk = sym['brkpt']

	soc.Reset.set(1)
	soc.Reset.set(0)

	test_break(soc, [brk])


	soc.SimSleepCycles.set(4000)
	soc.TapThrottle.set(0)

	while 1:
		time.sleep(5.0)
		soc.TapThrottle.set(1)
		test_singlestep(soc)
		soc.TapThrottle.set(0)
		resume(soc)


