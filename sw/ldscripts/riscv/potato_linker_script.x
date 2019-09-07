/* Linker script for standalone test applications for the Potato SoC
 * (c) Kristian Klomsten Skordal 2016 <kristian.skordal@wafflemail.net>
 * Report bugs and issues on <https://github.com/skordal/potato/issues>
 */

ENTRY(_start)

MEMORY
{
	l1prog (rwx)    : ORIGIN = 0x00000000, LENGTH = 0x00008000
	l1data (rw)    : ORIGIN = 0x00010000, LENGTH = 0x00008000
}

SECTIONS
{
	.text :
	{
		crt0-nocache.o(*.text)
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
	} > l1data

	.data :
	{
		__data_begin = .;
		*(.data*)
		*(.eh_frame*)
		__data_end = .;
	} > l1data

	.sdata :
	{
		__data_begin = .;
		*(.sdata*)
		*(.srodata*)
		__data_end = .;
	} > l1data


	.bss ALIGN(4) :
	{
		__bss_begin = .;
		*(.bss*)
		*(.sbss*)
		__bss_end = ALIGN(4);
	} > l1data

	/* Set the start of the stack to the top of RAM: */
	__stack_top = 0x00018000;

	/DISCARD/ :
	{
		*(.comment)
	}
}

