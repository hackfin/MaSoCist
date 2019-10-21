#define csr_read(csr)                                   \
({                                                      \
	register uint32_t __v;                              \
	__asm__ __volatile__ ("csrr %0, " #csr              \
 			      : "=r" (__v) :			            \
 			      : "memory");	                        \
 			      __v;                                 \
})

#define csr_write(csr, val)	 			                \
({                                                      \
	register uint32_t __v = (uint32_t) val;             \
	__asm__ __volatile__ ("csrw " #csr ", %0"           \
 			      : : "rK" (__v)                        \
 			      : "memory");	                        \
})

