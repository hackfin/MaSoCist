/* Extended function block supply code
 *
 */

#include "ioaccess.h"
#include "efb_register.h"
#include "efb_register_modes.h"
// Translate this directly to 32 bit address:

static int g_datacount;

static struct {
	char traceid[8];
} g_efbinfo;

static char g_msgbuf[256];

int read_fifodata(uint32_t *base, char *c, int n)
{
	volatile uint32_t *p = &base[Reg_EFB_CFG_CFGSR];
	g_datacount = 0;
	while (n-- && (*p & RXFE) == 0) {
		g_datacount++;
		*c++ = base[Reg_EFB_CFG_CFGRXDR];
	}
	return n;
}

int test_efb(uint32_t *base)
{
	int c;
	MMRBase cr = &base[Reg_EFB_CFG_CFGCR];
	MMRBase txdr = &base[Reg_EFB_CFG_CFGTXDR];

	*cr = RSTE; // Reset FIFO
	delay(1);

	*cr = WBCE; // {
	*txdr = CMD_READ_TRACEID;
	*txdr = 0; *txdr = 0; *txdr = 0;
	read_fifodata(base, g_efbinfo.traceid, sizeof(g_efbinfo.traceid));
	*cr = 0; // }
	return 0;
}

