	.text
	.extern _memreg
	.extern g_in_irq
	.extern timer_service
	.extern g_regs

.macro  save_memregs
	im _memreg
	load
	im _memreg+4
	load
	im _memreg+8
	load
	im _memreg+12
	load
.endm

.macro  restore_memregs
	im _memreg+12
	store
	im _memreg+8
	store
	im _memreg+4
	store
	im _memreg
	store
.endm

.macro set_stack_isr
	pushsp
	im _irq_stack-4
	store
	im _irq_stack-4
	popsp
.endm

; Save current SP context in a global variable g_context
.macro save_context
	pushsp
	im g_context
	load
	store
.endm

; Restore SP context from global variable g_context
.macro restore_context
	im g_context
	load
	load
	popsp
.endm

.macro restore_stack
	popsp
.endm

	.globl this_sp
this_sp:
	pushsp
	im _memreg
	store
	poppc


; -- User space context save/restore
	.globl zpung_ctx_save
zpu_ctx_save:
	save_memregs
	loadsp 20  /* Get last argument (regs) */
	pushsp
	store      /* regs[0] = $sp */
	poppc

	.globl zpung_ctx_restore
zpu_ctx_restore:
	loadsp 4  /* Get last argument (ptr) */
	load      /* Get register @arg0 (SP) */
	popsp     /* $sp = regs[0] */
	restore_memregs
	poppc



; -- IRQ handler
	.globl irq_timer_handler
irq_timer_handler:
	; Stores the current context (sp) into the variable pointed to
	; by g_context.
	save_context
	set_stack_isr
	save_memregs

	im timer_service
	call

	restore_memregs
	restore_stack
	; This leaves a possibly new return jump address on
	; TOS, if g_context was modified by the timer_service.
	restore_context
	
	.byte 15
	poppc
; ---------------------

	.section ".stack"
	.balign 4,0
	.globl _irq_stack
_irq_stack:
	.rept 128
	.byte 0
	.endr
	
