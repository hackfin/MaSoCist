# replacement for flawy objdump not emitting empty sections.
#

import intelhex
import elf
import sys

IGNORE_SECTIONS = [ ".fini", ".jcr", ".eh_frame", ".bss", ".sdram.bss" ]

def open_elf(infile):
	e = elf.ELFObject()
	f = open(infile)
	e.fromFile(f)
	f.close()
	return e

class ExtFlashImage:
	EXT_SECTIONS = [".ext.text", ".ext.rodata" ]

	def __init__(self, outfile, lentext = 0x10000, lendata = 0x10000):
		self.ext = intelhex.IntelHex()
		self.outfile = outfile

	def write_segment(self, addr, data):
		self.ext.puts(addr, data)

	def handle(self, p):
		if p.name in ExtFlashImage.EXT_SECTIONS:
			self.write_segment(p.sh_addr, p.data)

	def finish(self):
		# print 20 * "-" + " EXT " + 20 * "-"
		# self.ext.dump()
		f = open(self.outfile, "wb")
		self.ext.tobinfile(f, start=0x10000)
		print "Wrote binary file %s" % (self.outfile)
		f.close()

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
		elif p.sh_type == elf.ELFSection.SHT_PROGBITS:
			romgen.handle(p)
		else:
			print "Dropping %s (type %d, flags: %04x), no LOAD flag" % (p.name, p.sh_type, p.sh_flags)

def gen_file(e, outfile):
	# if e.e_type != elf.ELFObject.ET_EXEC:
		# raise Exception("No executable")
	print 76 * '-'
	generator = ExtFlashImage(outfile)
	process_sections(e, generator)

	# Don't pad, use "OTHERS" clause
	generator.finish()


infile = sys.argv[1]

e = open_elf(infile)

gen_file(e, sys.argv[2])
