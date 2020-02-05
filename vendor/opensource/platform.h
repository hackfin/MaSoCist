#if defined(CONFIG_virtual_neo430)
#include "virtual_neo430.h"
#elif defined(CONFIG_versa_ecp5)
#include "versa_ecp5.h"
#else
#warning "Unknown platform"
#include "unknown.h"
#endif

