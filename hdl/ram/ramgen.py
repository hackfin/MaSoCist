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
def dpram_x(a, b):

	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]

	@always(a.clk.posedge)
	def porta_proc():
		if a.we:
			mem[a.addr].next = a.write
			a.read.next = a.write
		else:
			a.read.next = mem[a.addr]

	@always(b.clk.posedge)
	def portb_proc():
		if 0:
			mem[b.addr].next = b.write
			b.read.next = b.write
		else:
			b.read.next = mem[b.addr]


	return instances()

@block
def dpram_dc(a, b):

	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]

	@always(a.clk.posedge)
	def porta_proc():
		if a.we:
			mem[a.addr].next = a.write
			a.read.next = a.write
		else:
			a.read.next = mem[a.addr]

	@always(b.clk.posedge)
	def portb_proc():
		if 0:
			mem[b.addr].next = b.write
			b.read.next = b.write
		else:
			b.read.next = mem[b.addr]


	return instances()


@block
def single_raw(a):

	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]
	addr = Signal(modbv(0)[len(a.addr):])

	@always(a.clk.posedge)
	def port_a_proc():
		addr.next = a.addr
		if a.we:
			mem[a.addr].next = a.write

	@always_comb
	def assign():
	  a.read.next = mem[addr];

	return instances()


@block
def dual_raw(a, b):
	"Working"
	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]
	addr_a, addr_b = [ Signal(modbv(0)[len(a.addr):]) for i in range(2) ]

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
def dual_raw_sc(clk, a, b):

	mem = [Signal(modbv(0)[len(a.read):]) for i in range(2 ** len(a.addr))]
	addr_a, addr_b = [ Signal(modbv(0)[len(a.addr):]) for i in range(2) ]

	@always(clk.posedge)
	def port_a_proc():
		addr_a.next = a.addr
		if a.we:
			mem[a.addr].next = a.write

	@always(clk.posedge)
	def port_b_proc():
		addr_b.next = b.addr

	@always_comb
	def assign():
	  a.read.next = mem[addr_a];
	  b.read.next = mem[addr_b];

	return instances()

@block
def dpram_test(clk, a, b, addr, we, check):
	pa, pb = [ DPport(len(addr), 16) for i in range(2) ]

	# This is grown into duplicates, due to different clk domains
	# Would not be necessary for the ECP5.
	ram_raw1 = dual_raw(a, b)

	# This one has a common clock and translates fine
	ram_raw2 = dual_raw(pa, pb)

	@always_comb
	def assign():
		pa.clk.next = clk
		pb.clk.next = clk
		pa.addr.next = a.addr
		pb.addr.next = a.addr
		pa.write.next = a.write
		pb.write.next = b.write
		pa.we.next = we
		pb.we.next = we
		if pa.read == 0xface:
			check.next = 1
		else:
			check.next = 0
	

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
	dp = dpram_test(clk, a, b, addr, en, check)
	# ram_raw = ram_read_after_write(pa, pb)
	# ram_raw = single_raw(pa)

	# d.convert("Verilog")
	dp.convert("VHDL")
	dp.convert("Verilog")
	# ram_raw.convert("VHDL")
	# ram_raw.convert("Verilog")
	pa, pb = [ DPport(7, 8) for i in range(2) ]

	dpram_inst = dual_raw(pa, pb)
	dpram_inst.convert("Verilog")


convert()
