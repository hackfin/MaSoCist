/** \file
 *
 * I/O access rules for various CPUs
 *
 */

#include "arch.h"

/** Base address auxiliaries */


// ZPU 32 bit architecture:
#if defined(ARCH_ZPU)
#if defined(CONFIG_LITTLE_ENDIAN)
#define MMR8_PTR  volatile uint8_t *
#define MMR16_PTR volatile uint16_t *
#define MMR32_PTR volatile uint32_t *
#else
// Big endian uses uniform 32 bit access width
#define MMR8_PTR  volatile uint32_t *
#define MMR16_PTR volatile uint32_t *
#define MMR32_PTR volatile uint32_t *
#endif
// All default accesses are 32 bit wide:
#define MMR MMR32

#elif defined(ARCH_MSP430)
// Only 16 bit access allowed:
#define MMR8_PTR  volatile uint32_t *
#define MMR16_PTR volatile uint16_t *
// Default access is 16 bit wide
#define MMR MMR16
#elif defined(ARCH_MIPS32) || defined(ARCH_RISCV)
#define MMR32_PTR volatile uint32_t *
#define MMR MMR32

#else
#warning "Generic architecture no longer maintained"

#define MMR8_PTR  volatile uint8_t *
#define MMR16_PTR volatile uint16_t *
#define MMR32_PTR volatile uint32_t *


#endif

/** MMR access, use only these functions for I/O space: */
#ifdef CONFIG_GLOBAL_MMRPTR
extern uint32_t *g_mmrptr;
#define MMR32(x) g_mmrptr[(x) >> 2]
#define MMR16(x) ((uint16_t *) g_mmrptr)[(x) >> 1]
#define MMR8(x)  ((uint8_t *) g_mmrptr)[x]
#else
#define MMR32(x) *((MMR32_PTR) ((x) + MMR_Offset))
#define MMR16(x) *((MMR16_PTR) ((x) + MMR_Offset))
#define MMR8(x)  *((MMR8_PTR) ((x) + MMR_Offset))
#endif

/** Base calculation: */
#define MMR8_BASE(base, x)  *((MMR8_PTR)  (&((unsigned char *) base)[x]))
#define MMR16_BASE(base, x) *((MMR16_PTR) (&((unsigned char *) base)[x]))
#define MMR32_BASE(base, x) *((MMR32_PTR) (&((unsigned char *) base)[x]))


#ifdef CONFIG_MAP_PREFIX
#define DEVICE_SELECT_PREFIX      SELECT
#else
#define DEVICE_SELECT_PREFIX      MMR_SELECT
#endif
#define _resolve_devindex(p, n) \
	p##_DEVINDEX_##n##_SHFT

// Here we just use the compiler predefs:

#if defined(__zpu__) || defined(__riscv)
// Ensure 32 bit access all the time:

typedef volatile uint32_t *MMRBase;

#define _device_register(pre, name, dev, offset) \
	(MMRBase) &((uint8_t *) (offset + MMR_Offset))[(dev << \
		(_resolve_devindex(pre, name)))]

#define _device_base(pre, name, dev) \
	(MMRBase) &((uint8_t *) (name##_Offset + MMR_Offset))[(dev << \
		(_resolve_devindex(pre, name)))]

#define device_mmr_base(name, base, x) \
	base[(x - name##_Offset) >> 2]

#elif defined(__MSP430__)

typedef volatile uint16_t *MMRBase;

#define _device_register(pre, name, dev, offset) \
	(MMRBase) &((uint8_t *) (offset + MMR_Offset))[(dev << \
		(_resolve_devindex(pre, name)))]

#define _device_base(pre, name, dev) \
	(MMRBase) &((uint8_t *) (name##_Offset + MMR_Offset))[(dev << \
		(_resolve_devindex(pre, name)))]

#define device_mmr_base(name, base, x) \
	base[(x - name##_Offset) >> 1]

#else
#error "Undefined MMR access for this architecture"
#endif

#define device_base(name, dev) _device_base(DEVICE_SELECT_PREFIX, name, dev)

#define device_register(name, dev, offset) \
	_device_register(DEVICE_SELECT_PREFIX, name, dev, offset)


