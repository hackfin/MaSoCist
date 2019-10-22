/* Generated linker script
 *
 * Only modify this file when it has a XSL extension.
 *
 * 2004-2018, Martin Strubel <hackfin@section5.ch>
 *
 */

 OUTPUT_FORMAT("elf32-littleriscv",
  "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
	l1prog(x)  : ORIGIN =  0x00000000, LENGTH = 0x08000
	l1data_a(rw)  : ORIGIN =  0x00010000, LENGTH = 0x4000
	l1data_b(x)  : ORIGIN =  0x00020000, LENGTH = 0x2000
	mmr(rw)  : ORIGIN =  0xfff80000, LENGTH = 0x1000
	scratchpad_a(x)  : ORIGIN =  0x00fcf000, LENGTH = 0x1000
	scratchpad_b(x)  : ORIGIN =  0x00fdf000, LENGTH = 0x1000

}

SECTIONS
{
	.text :
	{

		crt0.o(*.text)
		*(.init)

		__text_begin = .;
		*(.text*)
		__text_end = .;
		
	} > l1prog

	.rodata :
	{

		__rodata_begin = .;
		*(.rodata*)
		__rodata_end = .;
		
	} > l1data_a

	.ext.rodata :
	{

		__cached_rodata_begin = .;
		*(.ext.rodata*)
		__cached_rodata_end = .;
		
	} > l1data_b

	.dma0.data (NOLOAD) :
	{

		. = ALIGN(4);
		*.o(.dma.data)
		*.o(.dma0.data)
		
	} > scratchpad_a

	.dma1.data (NOLOAD) :
	{

		. = ALIGN(4);
		*.o(.dma1.data)
		
	} > scratchpad_b

	.data :
	{

		__data_begin = .;
		*(.data*)
		*(.eh_frame*)
		__data_end = .;
		
	} > l1data_a

	.sdata :
	{

		__data_begin = .;
		*(.sdata*)
		*(.srodata*)
		__data_end = .;
		__config_start = . ;
		*(.config.data)
		__config_end = . ;
		
	} > l1data_a

	.bss ALIGN(4) :
	{

		__bss_begin = .;
		*(.bss*)
		*(.sbss*)
		__bss_end = ALIGN(4);
		
	} > l1data_a

/* Extra stuff */

	/* Set the start of the stack to the top of RAM: */
	__stack_top = 0x00018000-4;

	/DISCARD/ :
	{
		*(.comment)
	}

}
