# Test case RAM generators for dual port RAM case scenarios
#
# <hackfin@section5.ch>
#

from myhdl import *

class DPport:
	def __init__(self, awidth, dwidth):
		self.clk = Signal(bool(0))
		self.we = Signal(bool(0))
		self.ce = Signal(bool(0))
		self.addr = Signal(modbv()[awidth:])
		self.write = Signal(modbv()[dwidth:])
		self.read = Signal(modbv()[dwidth:])

@block
def dummy(a, b):
	def worker():
		pass

	return instances()


@block
def meminit(mem, hexfile):
	size = len(mem)
	init_values = tuple([int(ss.val) for ss in mem])
	wsize = len(mem[0])

	@instance
	def initialize():
		for i in range(size):
			mem[i].next = init_values[i]
		yield delay(10)

	return instances()


meminit.verilog_code = """
initial begin
	$$readmemh(\"$hexfile\", $mem, $size);
end
"""

meminit.vhdl_code = """
	type ram_t is array(0 to $size-1) of unsigned($wsize-1 downto 0);

	impure function init_ram() return ram_t is
		file hexfile : text open read_mode is "$hexfile";
		variable l : line;
		variable hw : unsigned($wsize-1 downto 0);
		variable initmem : ram_t := (others => (others => '0'));
	begin
		for i in 0 to $size-1 loop
			exit when endfile(hexfile);
			readline(hexfile, l);
			report "read: " & l.all;
			hread(l, hw);
			initmem(i) := hw;
		end loop;

		return initmem;
	end function;
"""

@block
def dpram_tdp(a, b):
	"Not synthesizing, throwing error due to concurrent access"
	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]

	if HEXFILE:
		init_inst = meminit(mem, HEXFILE)

	@always(a.clk.posedge)
	def porta_proc():
		if a.we:
			mem[a.addr].next = a.write
			a.read.next = a.write
		else:
			a.read.next = mem[a.addr]

	@always(b.clk.posedge)
	def portb_proc():
		if b.we:
			mem[b.addr].next = b.write
			b.read.next = b.write
		else:
			b.read.next = mem[b.addr]


	return instances()

@block
def dpram_tdp_r2w1(HEXFILE, a, b):
	"Synthesizing two read one write port DPRAM"
	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]

	if HEXFILE:
		init_inst = meminit(mem, HEXFILE)

	@always(a.clk.posedge)
	def porta_proc():
		if a.we:
			mem[a.addr].next = a.write
			a.read.next = a.write
		else:
			a.read.next = mem[a.addr]

	@always(b.clk.posedge)
	def portb_proc():
		b.read.next = mem[b.addr]


	return instances()

@block
def dpram_tdp_r2w1_ce(HEXFILE, a, b):
	"Synthesizing two read one write port DPRAM"
	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]

	if HEXFILE:
		init_inst = meminit(mem, HEXFILE)

	@always(a.clk.posedge)
	def porta_proc():
		if a.ce:
			if a.we:
				mem[a.addr].next = a.write
				a.read.next = a.write
			else:
				a.read.next = mem[a.addr]

	@always(b.clk.posedge)
	def portb_proc():
		if b.ce:
			b.read.next = mem[b.addr]


	return instances()


@block
def simple_raw(HEXFILE, a, b):

	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]
	addr = Signal(modbv(0)[len(a.addr):])

	if HEXFILE:
		init_inst = meminit(mem, HEXFILE)

	@always(a.clk.posedge)
	def port_a_proc():
		if a.we:
			mem[a.addr].next = a.write

		a.read.next = mem[a.addr];

	return instances()


@block
def dual_raw_v0(HEXFILE, a, b):
	"Synthesizes for ECP5_DP16KD in Verilog, but not in VHDL"
	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]
	addr_a, addr_b = [ Signal(modbv(0)[len(a.addr):]) for i in range(2) ]

	if HEXFILE:
		init_inst = meminit(mem, HEXFILE)

	@always(a.clk.posedge)
	def port_a_proc():
		addr_a.next = a.addr
		if a.we:
			mem[a.addr].next = a.write

	@always(b.clk.posedge)
	def port_b_proc():
		addr_b.next = b.addr

	@always_comb
	def assign():
	  a.read.next = mem[addr_a];
	  b.read.next = mem[addr_b];

	return instances()


@block
def dual_raw_v1(HEXFILE, a, b):
	"Working with dual clock mode"
	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]

	if HEXFILE:
		init_inst = meminit(mem, HEXFILE)

	@always(a.clk.posedge)
	def port_a_proc():
		if a.we:
			mem[a.addr].next = a.write
		a.read.next = mem[a.addr];

	@always(b.clk.posedge)
	def port_b_proc():
		b.read.next = mem[b.addr];

	return instances()


@block
def dpram_test(clk, a, b, addr, we, check, ent, HEXFILE, CLKMODE):
	"Entities that are 'required' to work"
	pa, pb = [ DPport(len(addr), 16) for i in range(2) ]

	# This is grown into duplicates, due to different clk domains
	# Would not be necessary for the ECP5.
	# ram_raw1 = dual_raw_v0(a, b)

	# This one has a common clock and translates fine
	# ram_raw2 = dual_raw_v0(pa, pb)

	# Both port clocks the same:
	if CLKMODE:
		ram_tdp = ent(HEXFILE, pa, pb)
	else:
		ram_tdp = ent(HEXFILE, a, b)

	@always_comb
	def assign():
		pa.clk.next = clk
		pb.clk.next = clk
		pa.addr.next = a.addr
		pb.addr.next = b.addr
		pa.write.next = a.write
		pb.write.next = b.write
		pa.we.next = we
		pb.we.next = we

		# When true, no port is optimized away
		if 1:
			# Wire them through
			a.read.next = pa.read
			b.read.next = pb.read
		else:
			# Do a simple check. This seems to eliminate ports

# Yosys optimizes this paragraph as it should, unless you indent below
# from 'INDENT_BEGIN':
			if pa.read == 0xface:
				check.next = 0
			else:
				check.next = 1

			# When indenting, nothing is optimized away,
			# but then no port is optimized away
			# -> not resolving into ECP5_DP16KD
			# INDENT_BEGIN
			if pb.read == 0xface:
				check.next = 2
			else:
				check.next = 3
			# INDENT_END
		
	return instances()


def convert():
	clk = Signal(bool(0))
	clka = Signal(bool(0))
	clkb = Signal(bool(0))
	en = Signal(bool(0))
	check = Signal(modbv()[4:])
	addr = Signal(modbv()[12:])
	a = DPport(len(addr), 16)
	b = DPport(len(addr), 16)
	# d = dpram16_init(a, b)

	RAM_LIST = [ dpram_tdp_r2w1, dpram_tdp_r2w1_ce, dual_raw_v1, dual_raw_v0 ]
	RAM_LIST += [ simple_raw ]

	for ent in RAM_LIST:
		dp = dpram_test(clk, a, b, addr, en, check, ent, False, True)
		s = "test_" + ent.__name__
		dp.convert("VHDL", name=s)
		dp.convert("Verilog", name=s)

	pa, pb = [ DPport(len(addr), 16) for i in range(2) ]
	test_init = dpram_tdp_r2w1("../sw/bootrom_l.hex", a, b)
	test_init.convert("VHDL")
	# test_init.convert("Verilog")

convert()
