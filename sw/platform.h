// "from the box" platforms:
//
#if defined(CONFIG_papilio)
#include "papilio.h"
#elif defined(CONFIG_hdr60)
#include "hdr60.h"
#elif defined(CONFIG_breakout)
#include "breakout.h"
#elif defined(CONFIG_netpp_node)
#include "netpp_node.h"
#elif defined(CONFIG_virtual)
#include "virtual.h"
#else
#include "../vendor/default/platform.h"
#endif
