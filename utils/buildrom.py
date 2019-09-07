# ROM builder for ZPU and MIPS CPU cores
# (c) 2012, <hackfin@section5.ch>
#

IGNORE_SECTIONS = [ ".fini", ".jcr", ".eh_frame", ".bss", ".sdram.bss" ]

# Unused in this implementation, kept anyway:
DEFAULT_ISIZE = 0x2000
DEFAULT_DSIZE = 0x2000

import intelhex
import elf
import sys
from romgen import Romgen_MIPS, Romgen_RISCV, Romgen_ZPU, Romgen_MSP430


def align4(data):
	l = len(data) % 4
	l = 4 - l
	pad = ""
	for i in range(l):
		pad += chr(0)
	data += pad
	return data



def pad_zero(f, size):
	c = 0
	while size > 4:
		f.write('x"0000",')
		size -= 4
		c += 1
		if c == 8:
			c = 0
			f.write('\n')

	f.write('x"0000"')


def open_elf(infile):
	e = elf.ELFObject()
	f = open(infile)
	e.fromFile(f)
	f.close()
	return e

def process_sections(e, romgen):
	for p in e.sections:
		if p.sh_flags & (elf.ELFSection.SHF_WRITE |
		                 elf.ELFSection.SHF_EXECINSTR |
		                 elf.ELFSection.SHF_ALLOC):

			if p.name in IGNORE_SECTIONS:
				print "Dropping %s" % p.name
			else:
				romgen.handle(p)
		elif p.sh_type == elf.ELFSection.SHT_SYMTAB:
			symtab = p
		elif p.sh_type == elf.ELFSection.SHT_STRTAB:
			strtab = p
		else:
			print "Dropping %s, no LOAD flag" % p.name


def gen_hex(e, isize = DEFAULT_ISIZE, dsize = DEFAULT_DSIZE):
	romgen = Romgen_HEX(isize, dsize)

	process_sections(e, romgen)

	romgen.finish()

KNOWN_ARCHITECTURES = {
	0x08 : (Romgen_MIPS, "MIPS"),
	0x6a : (Romgen_ZPU, "ZPU"),
	0xf3 : (Romgen_RISCV, "RISCV"),
	0x69 : (Romgen_MSP430, "NEO430"),
}

def gen_file(e, prefix, isize = DEFAULT_ISIZE, dsize = DEFAULT_DSIZE):
	# if e.e_type != elf.ELFObject.ET_EXEC:
		# raise Exception("No executable")
	print 76 * '-'

	try:
		r = KNOWN_ARCHITECTURES[e.e_machine]
		romgen = r[0](prefix)
		print "Found %s executable" % r[1]
	except KeyError:
		print "Unknown architecture: 0x%x" % e.e_machine
		return

	print 76 * '-'
	# print hex(e.e_shnum)
	# print e.e_phnum

	process_sections(e, romgen)

	# Don't pad, use "OTHERS" clause
	romgen.finish()


	print 76 * '-'

	return e
	
if __name__ == "__main__":
	infile = sys.argv[1]
	if len(sys.argv) == 4:
		size = int(sys.argv[3])
	else:
		size = 0
		
	dsize = size # XXX size currently not used
	e = open_elf(infile)
	gen_file(e, sys.argv[2], size, dsize)
	# gen_hex(e, size, dsize)


