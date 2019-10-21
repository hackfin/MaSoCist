from opcode_constants import *


############################################################################
# Basic Instructions

# Return from emulation:
INSN_EMURET = int('01111011001000000000000001110011', 2)
INSN_NOP    = int('00000000000000000000000000010011', 2)
INSN_EBREAK = int('00000000000100000000000001110011', 2)

def insn_csrrw(src, dst, csr):
	"Construct the CSRRW opcode"
	insn =  RV32_SYSTEM
	insn |= FN_CSRRW << FUNCT3.stop
	insn |= src << SLICE_RS1.stop
	insn |= dst << SLICE_RD.stop
	insn |= csr << SLICE_RS2.stop
	return insn

def insn_csrr(reg, csr):
	"Read CSR register into reg"
	return insn_csrrw(0, reg, csr)

def insn_csrw(reg, csr):
	"Write reg into CSR register"
	return insn_csrrw(reg, 0, csr)

def insn_auipc(val, dst):
	insn = RV32_AUIPC
	insn |= (val & ~0xfff)
	insn |= dst << SLICE_RD.stop
	return insn

def insn_ori(val, reg):
	insn = RV32_OP_IMM
	insn |= FN_OR << FUNCT3.stop
	insn |= (val & 0xfff) << SLICE_IMM_I.stop
	insn |= reg << SLICE_RS1.stop
	insn |= reg << SLICE_RD.stop
	return insn

def insn_addi(val, reg):
	insn = RV32_OP_IMM
	insn |= FN_ADD_SUB << FUNCT3.stop
	insn |= (val & 0xfff) << SLICE_IMM_I.stop
	insn |= reg << SLICE_RS1.stop
	insn |= reg << SLICE_RD.stop
	return insn

def insn_lui(val, dst):
	insn = RV32_LUI
	insn |= (val & ~0xfff)
	insn |= dst << SLICE_RD.stop
	return insn

def insn_jalr(val, src, dst):
	insn = RV32_JALR
	insn |= src << SLICE_RS1.stop
	insn |= (val & 0xfff) << SLICE_IMM_I.stop
	insn |= dst << SLICE_RD.stop
	return insn

d_sizes = {
	1: 0,
	2: 1,
	4: 2
}

def insn_load(offset, areg, dreg, size):
	insn = RV32_LOAD
	insn |= areg << SLICE_RS1.stop
	insn |= dreg << SLICE_RD.stop
	insn |= d_sizes[size] << FUNCT3.stop
	insn |= (offset & 0xfff) << SLICE_IMM_I.stop
	return insn

def insn_store(offset, areg, dreg, size):
	insn = RV32_STORE
	insn |= areg << SLICE_RS1.stop
	insn |= dreg << SLICE_RS2.stop
	insn |= d_sizes[size] << FUNCT3.stop
	insn |= (offset & 0x01f) << SLICE_IMML_S.stop
	insn |= (offset & 0xfe0) << SLICE_IMM_I.stop
	return insn
