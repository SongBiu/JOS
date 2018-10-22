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
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * 上述两个函数的功能：将num和error code入栈，然后进入_alltraps执行异常控制程序
 * 先push后jump理论上和call等价。
 */

###################################################################

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
/*
 * 代码要求：对每个系统调用生成指针。
 */
TRAPHANDLER_NOEC(handle_divide, T_DIVIDE)
TRAPHANDLER_NOEC(handle_brkpt, T_BRKPT)
TRAPHANDLER(handle_segnp, T_SEGNP)
TRAPHANDLER(handle_gpflt, T_GPFLT)
TRAPHANDLER(handle_pgflt, T_PGFLT)
TRAPHANDLER_NOEC(handle_syscall, T_SYSCALL)

/*
 * Lab 3: Your code here for _alltraps
 */

/*
 * 代码要求：转入对应的异常处理程序。无论有没有error code。 需要操作ebp, esp
 * 构造出Trapframe, 这里可以使用pushal指令将所有寄存器入栈
 * 将GD_KD导入ds, es中(数据段基址、拓展段基址)
 * push esp作为trap的参数struct Trapframe *tf
 * call trap
 */

_alltraps:

	/*
	 * 将ds, es的值入栈，作为参数
	 */
	pushl %ds
	pushl %es

	/*
	 * 我们需要构造出Trapframe结构。因此，需要pushal这条指令
	 * 得到PushRegs
	 */
	pushal

	/*
	 * 下面这段代码将GD_KD赋值给ds, es寄存器
	 */
	movl $GD_KD, %eax
	movw %ax, %ds
	movw %ax, %es

	push %esp
	call trap
