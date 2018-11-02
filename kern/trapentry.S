/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */

#define TRAPHANDLER(name, num)						\
	.data; \
		.long name; \
	.text; \
		.globl name;		/* define global symbol for 'name' */	\
		.type name, @function;	/* symbol type is function */		\
		.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
		pushl $(num);							\
		jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.data; \
		.long name; \
	.text; \
		.globl name;							\
		.type name, @function;						\
		.align 2;							\
	name:								\
		pushl $0;							\
		pushl $(num);							\
		jmp _alltraps



.data
	.globl handles

handles:
	TRAPHANDLER_NOEC(handles0, T_DIVIDE)
	TRAPHANDLER_NOEC(handles1, T_DEBUG)
	TRAPHANDLER_NOEC(handles2, T_NMI)
	TRAPHANDLER_NOEC(handles3, T_BRKPT)
	TRAPHANDLER_NOEC(handles4, T_OFLOW)
	TRAPHANDLER_NOEC(handles5, T_BOUND)
	TRAPHANDLER_NOEC(handles6, T_ILLOP)
	TRAPHANDLER_NOEC(handles7, T_DEVICE)
	TRAPHANDLER(handles8, T_DBLFLT)
	TRAPHANDLER_NOEC(handles9, 9)
	TRAPHANDLER(handles10, T_TSS)
	TRAPHANDLER(handles11, T_SEGNP)
	TRAPHANDLER(handles12, T_STACK)
	TRAPHANDLER(handles13, T_GPFLT)
	TRAPHANDLER(handles14, T_PGFLT)
	TRAPHANDLER_NOEC(handles15, 15)
	TRAPHANDLER_NOEC(handles16, T_FPERR)
	TRAPHANDLER(handles17, T_ALIGN)
	TRAPHANDLER_NOEC(handles18, T_MCHK)
	TRAPHANDLER_NOEC(handles19, T_SIMDERR)
	TRAPHANDLER_NOEC(handles20, 20)
	TRAPHANDLER_NOEC(handles21, 21)
	TRAPHANDLER_NOEC(handles22, 22)
	TRAPHANDLER_NOEC(handles23, 23)
	TRAPHANDLER_NOEC(handles24, 24)
	TRAPHANDLER_NOEC(handles25, 25)
	TRAPHANDLER_NOEC(handles26, 26)
	TRAPHANDLER_NOEC(handles27, 27)
	TRAPHANDLER_NOEC(handles28, 28)
	TRAPHANDLER_NOEC(handles29, 29)
	TRAPHANDLER_NOEC(handles30, 30)
	TRAPHANDLER_NOEC(handles31, 31)
	TRAPHANDLER_NOEC(handles32, 32)
	TRAPHANDLER_NOEC(handles33, 33)
	TRAPHANDLER_NOEC(handles34, 34)
	TRAPHANDLER_NOEC(handles35, 35)
	TRAPHANDLER_NOEC(handles36, 36)
	TRAPHANDLER_NOEC(handles37, 37)
	TRAPHANDLER_NOEC(handles38, 38)
	TRAPHANDLER_NOEC(handles39, 39)
	TRAPHANDLER_NOEC(handles40, 40)
	TRAPHANDLER_NOEC(handles41, 41)
	TRAPHANDLER_NOEC(handles42, 42)
	TRAPHANDLER_NOEC(handles43, 43)
	TRAPHANDLER_NOEC(handles44, 44)
	TRAPHANDLER_NOEC(handles45, 45)
	TRAPHANDLER_NOEC(handles46, 46)
	TRAPHANDLER_NOEC(handles47, 47)
	TRAPHANDLER_NOEC(handles48, T_SYSCALL)

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
/*
.text
; TRAPHANDLER_NOEC(handle_divide, T_DIVIDE)
; TRAPHANDLER_NOEC(handle_brkpt, T_BRKPT)
; TRAPHANDLER(handle_segnp, T_SEGNP)
; TRAPHANDLER(handle_gpflt, T_GPFLT)
; TRAPHANDLER(handle_pgflt, T_PGFLT)
; TRAPHANDLER_NOEC(handle_syscall, T_SYSCALL)
*/
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds;
	pushl %es;
	pushal;
	movl $GD_KD, %eax;
	movw %ax, %ds;
	movw %ax, %es;
	push %esp;
	call trap;