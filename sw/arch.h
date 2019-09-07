/** Architecture specifics */
#include "../include/generated/autoconf.h"

#if defined(CONFIG_ZEALOT) || defined(CONFIG_ZPUNG)
#define ARCH_ZPU
#elif defined(CONFIG_RISCV_POTATO)
#define HAVE_STRLEN
#define ARCH_RISCV
#elif defined(CONFIG_NEO430)
#warning "Experimental neo430 support"
#define HAVE_STRLEN
#define ARCH_MSP430
#elif defined(CONFIG_PYPS)
#define ARCH_MIPS32
#define REGISTERMAP_OFFSET(x) (0x10000000 + (x))
#else
#define ARCH_UNKNOWN
#warning "Unknown architecture"
#endif


#if defined(ARCH_ZPU)
#ifndef __VHDL__
#include "arch/zpu/inttypes.h"
#define BREAK asm("breakpoint")
#	ifdef CONFIG_ZPUNG
#		ifdef CONFIG_SCACHE_INSN
#			define __rodata_ext   __attribute__((section(".ext.rodata")))
#			define FORCE_L1RAM   __attribute__((section(".l1.text")))
#			define EXTERN_PROG __attribute__((section(".ext.text")))
#		else
#			define __rodata_ext
#			define FORCE_L1RAM
#			define EXTERN_PROG
#		endif
#	else
#		define FORCE_L1RAM
#		define EXTERN_PROG
#	endif
#endif
#elif defined(ARCH_MSP430) || defined(ARCH_RISCV)
#ifndef __VHDL__
#include <stdint.h>
#endif
#define BREAK
// Currently not breaking:
// #define BREAK asm("ebreak");
#endif

// Aux decorators for functions to be placed in outer space:
#define DEBUG_FUNCTION EXTERN_PROG
#ifndef INIT_FUNCTION
#define INIT_FUNCTION
#endif
#ifndef __INIT_DATA__
#define __INIT_DATA__
#endif

#ifdef ARCH_MIPS32
#define BREAK asm("break 0");
#endif

