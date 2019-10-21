INST_WIDTH = 32
REG_ADDR_WIDTH = 5
XPR_LEN = 32
DOUBLE_XPR_LEN = 64
LOG2_XPR_LEN = 5
SHAMT_WIDTH = 5

RV_NOP = int('0010011', 2)


RV32_LOAD = int('0000011', 2)
RV32_STORE = int('0100011', 2)
RV32_MADD = int('1000011', 2)
RV32_BRANCH = int('1100011', 2)

RV32_LOAD_FP = int('0000111', 2)
RV32_STORE_FP = int('0100111', 2)
RV32_MSUB = int('1000111', 2)

RV32_CUSTOM_0 = int('0001011', 2)
RV32_CUSTOM_1 = int('0101011', 2)
RV32_NMSUB = int('1001011', 2)

# 7'b1101011 is reserved

RV32_MISC_MEM = int('0001111', 2)
RV32_AMO = int('0101111', 2)
RV32_NMADD = int('1001111', 2)
RV32_JAL = int('1101111', 2)
RV32_JALR = int('1100111', 2)

RV32_OP_IMM = int('0010011', 2)
RV32_OP = int('0110011', 2)
RV32_OP_FP = int('1010011', 2)
RV32_SYSTEM = int('1110011', 2)

RV32_AUIPC = int('0010111', 2)
RV32_LUI = int('0110111', 2)
# 7'b1010111 is reserved
# 7'b1110111 is reserved

# 7'b0011011 is RV64-specific
# 7'b0111011 is RV64-specific
RV32_CUSTOM_2 = int('1011011', 2)
RV32_CUSTOM_3 = int('1111011', 2)

# Arithmetic FUNCT3 encodings

FN_ADD_SUB = 0
FN_SLL = 1
FN_SLT = 2
FN_SLTU = 3
FN_XOR = 4
FN_SRA_SRL = 5
FN_OR = 6
FN_AND = 7

# Branch FUNCT3 encodings

FN_BEQ = 0
FN_BNE = 1
FN_BLT = 4
FN_BGE = 5
FN_BLTU = 6
FN_BGEU = 7

# MISC-MEM FUNCT3 encodings
RV32_FUNCT3_FENCE = 0
RV32_FUNCT3_FENCE_I = 1

# SYSTEM FUNCT3 encodings

FN_PRIV = 0
FN_CSRRW = 1
FN_CSRRS = 2
FN_CSRRC = 3
FN_CSRRWI = 5
FN_CSRRSI = 6
FN_CSRRCI = 7

# PRIV FUNCT12 encodings

FN12_ECALL = int('000000000000', 2)
FN12_EBREAK = int('000000000001', 2)
FN12_URET = int('000000000010', 2)
FN12_DRET = int('011110110010', 2)
FN12_MRET = int('001100000010', 2)
FN12_ERET = int('000100000000', 2)
FN12_WFI  = int('000100000101', 2)

# RV32M encodings
FN_MUL_DIV = 1

FN_MUL = 0
FN_MULH = 1
FN_MULHSU = 2
FN_MULHU = 3
FN_DIV = 4
FN_DIVU = 5
FN_REM = 6
FN_REMU = 7


############################################################################
# Slice objects:

FUNCT3        = slice(15, 12)
OPCODE        = slice(7, 0)
FUNCT_R       = slice(32, 25)
FUNCT12       = slice(32, 20)
FUNCT3        = slice(15, 12)
SLICE_RS1     = slice(20, 15)
SLICE_RS2     = slice(25, 20)
SLICE_RD      = slice(12, 7)
SLICE_IMML_S  = slice(12, 7)
SLICE_IMMH_S  = slice(32, 25)
SLICE_IMM_I   = slice(32, 20)
SLICE_IMM_U   = slice(32, 12)

