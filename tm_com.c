#include <tk/tkernel.h>

#if USE_TMONITOR
#include "../mtkernel_cfu/lib/libtm/libtm.h"

/* CFU-PG transmit-only UART: data register and TX-ready status bit. */
#define CFU_CONSOLE_TX		(*(volatile UB *)0x10000000U)
#define CFU_CONSOLE_STATUS	(*(volatile UB *)0x10000005U)
#define CFU_CONSOLE_TX_READY	0x00000020U

EXPORT	void	tm_snd_dat( const UB* buf, INT size )
{
	INT i;
	for (i = 0; i < size; i++) {
		while ((CFU_CONSOLE_STATUS & CFU_CONSOLE_TX_READY) == 0U) {
			/* Wait until the previous 8N1 frame has completed. */
		}
		CFU_CONSOLE_TX = buf[i];
	}
}

EXPORT	void	tm_rcv_dat( UB* buf, INT size )
{
	INT i;

	/* The current CFU-PG UART is output-only. */
	for (i = 0; i < size; i++) {
		buf[i] = 0;
	}
}

EXPORT	void	tm_com_init(void)
{
	/* The MMIO UART does not require software initialization. */
}

#endif /* USE_TMONITOR */
