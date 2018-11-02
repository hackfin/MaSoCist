	.extern stack_pointer
	.text
	.global start
	.set noat
start:
	lui $sp, stack_pointer
	ori $sp, stack_pointer
	lui $gp, __global
	ori $gp, __global

	move $at, $zero
	move $s8, $zero
	move $14, $zero
	jal main
	break 0
