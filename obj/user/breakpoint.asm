
obj/user/breakpoint:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	53                   	push   %ebx
  80003d:	83 ec 04             	sub    $0x4,%esp
  800040:	e8 3b 00 00 00       	call   800080 <__x86.get_pc_thunk.bx>
  800045:	81 c3 bb 1f 00 00    	add    $0x1fbb,%ebx
  80004b:	8b 45 08             	mov    0x8(%ebp),%eax
  80004e:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800051:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800057:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005d:	85 c0                	test   %eax,%eax
  80005f:	7e 08                	jle    800069 <libmain+0x30>
		binaryname = argv[0];
  800061:	8b 0a                	mov    (%edx),%ecx
  800063:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	52                   	push   %edx
  80006d:	50                   	push   %eax
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 0c 00 00 00       	call   800084 <exit>
}
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <__x86.get_pc_thunk.bx>:
  800080:	8b 1c 24             	mov    (%esp),%ebx
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	53                   	push   %ebx
  800088:	83 ec 10             	sub    $0x10,%esp
  80008b:	e8 f0 ff ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  800090:	81 c3 70 1f 00 00    	add    $0x1f70,%ebx
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 45 00 00 00       	call   8000e2 <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    

008000a5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b6:	89 c3                	mov    %eax,%ebx
  8000b8:	89 c7                	mov    %eax,%edi
  8000ba:	89 c6                	mov    %eax,%esi
  8000bc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d3:	89 d1                	mov    %edx,%ecx
  8000d5:	89 d3                	mov    %edx,%ebx
  8000d7:	89 d7                	mov    %edx,%edi
  8000d9:	89 d6                	mov    %edx,%esi
  8000db:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 1c             	sub    $0x1c,%esp
  8000eb:	e8 66 00 00 00       	call   800156 <__x86.get_pc_thunk.ax>
  8000f0:	05 10 1f 00 00       	add    $0x1f10,%eax
  8000f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800100:	b8 03 00 00 00       	mov    $0x3,%eax
  800105:	89 cb                	mov    %ecx,%ebx
  800107:	89 cf                	mov    %ecx,%edi
  800109:	89 ce                	mov    %ecx,%esi
  80010b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010d:	85 c0                	test   %eax,%eax
  80010f:	7f 08                	jg     800119 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5f                   	pop    %edi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	50                   	push   %eax
  80011d:	6a 03                	push   $0x3
  80011f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800122:	8d 83 b6 ee ff ff    	lea    -0x114a(%ebx),%eax
  800128:	50                   	push   %eax
  800129:	6a 23                	push   $0x23
  80012b:	8d 83 d3 ee ff ff    	lea    -0x112d(%ebx),%eax
  800131:	50                   	push   %eax
  800132:	e8 23 00 00 00       	call   80015a <_panic>

00800137 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 02 00 00 00       	mov    $0x2,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <__x86.get_pc_thunk.ax>:
  800156:	8b 04 24             	mov    (%esp),%eax
  800159:	c3                   	ret    

0080015a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	e8 18 ff ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  800168:	81 c3 98 1e 00 00    	add    $0x1e98,%ebx
	va_list ap;

	va_start(ap, fmt);
  80016e:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800171:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800177:	8b 38                	mov    (%eax),%edi
  800179:	e8 b9 ff ff ff       	call   800137 <sys_getenvid>
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	ff 75 0c             	pushl  0xc(%ebp)
  800184:	ff 75 08             	pushl  0x8(%ebp)
  800187:	57                   	push   %edi
  800188:	50                   	push   %eax
  800189:	8d 83 e4 ee ff ff    	lea    -0x111c(%ebx),%eax
  80018f:	50                   	push   %eax
  800190:	e8 d1 00 00 00       	call   800266 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800195:	83 c4 18             	add    $0x18,%esp
  800198:	56                   	push   %esi
  800199:	ff 75 10             	pushl  0x10(%ebp)
  80019c:	e8 63 00 00 00       	call   800204 <vcprintf>
	cprintf("\n");
  8001a1:	8d 83 08 ef ff ff    	lea    -0x10f8(%ebx),%eax
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 b7 00 00 00       	call   800266 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b2:	cc                   	int3   
  8001b3:	eb fd                	jmp    8001b2 <_panic+0x58>

008001b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	e8 c1 fe ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  8001bf:	81 c3 41 1e 00 00    	add    $0x1e41,%ebx
  8001c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c8:	8b 16                	mov    (%esi),%edx
  8001ca:	8d 42 01             	lea    0x1(%edx),%eax
  8001cd:	89 06                	mov    %eax,(%esi)
  8001cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d2:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001db:	74 0b                	je     8001e8 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001dd:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5e                   	pop    %esi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	68 ff 00 00 00       	push   $0xff
  8001f0:	8d 46 08             	lea    0x8(%esi),%eax
  8001f3:	50                   	push   %eax
  8001f4:	e8 ac fe ff ff       	call   8000a5 <sys_cputs>
		b->idx = 0;
  8001f9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8001ff:	83 c4 10             	add    $0x10,%esp
  800202:	eb d9                	jmp    8001dd <putch+0x28>

00800204 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	53                   	push   %ebx
  800208:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80020e:	e8 6d fe ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  800213:	81 c3 ed 1d 00 00    	add    $0x1ded,%ebx
	struct printbuf b;

	b.idx = 0;
  800219:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800220:	00 00 00 
	b.cnt = 0;
  800223:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022d:	ff 75 0c             	pushl  0xc(%ebp)
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800239:	50                   	push   %eax
  80023a:	8d 83 b5 e1 ff ff    	lea    -0x1e4b(%ebx),%eax
  800240:	50                   	push   %eax
  800241:	e8 38 01 00 00       	call   80037e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800246:	83 c4 08             	add    $0x8,%esp
  800249:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80024f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800255:	50                   	push   %eax
  800256:	e8 4a fe ff ff       	call   8000a5 <sys_cputs>

	return b.cnt;
}
  80025b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800261:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800264:	c9                   	leave  
  800265:	c3                   	ret    

00800266 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026f:	50                   	push   %eax
  800270:	ff 75 08             	pushl  0x8(%ebp)
  800273:	e8 8c ff ff ff       	call   800204 <vcprintf>
	va_end(ap);

	return cnt;
}
  800278:	c9                   	leave  
  800279:	c3                   	ret    

0080027a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	57                   	push   %edi
  80027e:	56                   	push   %esi
  80027f:	53                   	push   %ebx
  800280:	83 ec 2c             	sub    $0x2c,%esp
  800283:	e8 63 06 00 00       	call   8008eb <__x86.get_pc_thunk.cx>
  800288:	81 c1 78 1d 00 00    	add    $0x1d78,%ecx
  80028e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800291:	89 c7                	mov    %eax,%edi
  800293:	89 d6                	mov    %edx,%esi
  800295:	8b 45 08             	mov    0x8(%ebp),%eax
  800298:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002ac:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002af:	39 d3                	cmp    %edx,%ebx
  8002b1:	72 09                	jb     8002bc <printnum+0x42>
  8002b3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b6:	0f 87 83 00 00 00    	ja     80033f <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	ff 75 18             	pushl  0x18(%ebp)
  8002c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002c8:	53                   	push   %ebx
  8002c9:	ff 75 10             	pushl  0x10(%ebp)
  8002cc:	83 ec 08             	sub    $0x8,%esp
  8002cf:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d8:	ff 75 d0             	pushl  -0x30(%ebp)
  8002db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002de:	e8 8d 09 00 00       	call   800c70 <__udivdi3>
  8002e3:	83 c4 18             	add    $0x18,%esp
  8002e6:	52                   	push   %edx
  8002e7:	50                   	push   %eax
  8002e8:	89 f2                	mov    %esi,%edx
  8002ea:	89 f8                	mov    %edi,%eax
  8002ec:	e8 89 ff ff ff       	call   80027a <printnum>
  8002f1:	83 c4 20             	add    $0x20,%esp
  8002f4:	eb 13                	jmp    800309 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f6:	83 ec 08             	sub    $0x8,%esp
  8002f9:	56                   	push   %esi
  8002fa:	ff 75 18             	pushl  0x18(%ebp)
  8002fd:	ff d7                	call   *%edi
  8002ff:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800302:	83 eb 01             	sub    $0x1,%ebx
  800305:	85 db                	test   %ebx,%ebx
  800307:	7f ed                	jg     8002f6 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	56                   	push   %esi
  80030d:	83 ec 04             	sub    $0x4,%esp
  800310:	ff 75 dc             	pushl  -0x24(%ebp)
  800313:	ff 75 d8             	pushl  -0x28(%ebp)
  800316:	ff 75 d4             	pushl  -0x2c(%ebp)
  800319:	ff 75 d0             	pushl  -0x30(%ebp)
  80031c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80031f:	89 f3                	mov    %esi,%ebx
  800321:	e8 6a 0a 00 00       	call   800d90 <__umoddi3>
  800326:	83 c4 14             	add    $0x14,%esp
  800329:	0f be 84 06 0a ef ff 	movsbl -0x10f6(%esi,%eax,1),%eax
  800330:	ff 
  800331:	50                   	push   %eax
  800332:	ff d7                	call   *%edi
}
  800334:	83 c4 10             	add    $0x10,%esp
  800337:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    
  80033f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800342:	eb be                	jmp    800302 <printnum+0x88>

00800344 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	3b 50 04             	cmp    0x4(%eax),%edx
  800353:	73 0a                	jae    80035f <sprintputch+0x1b>
		*b->buf++ = ch;
  800355:	8d 4a 01             	lea    0x1(%edx),%ecx
  800358:	89 08                	mov    %ecx,(%eax)
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	88 02                	mov    %al,(%edx)
}
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <printfmt>:
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800367:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036a:	50                   	push   %eax
  80036b:	ff 75 10             	pushl  0x10(%ebp)
  80036e:	ff 75 0c             	pushl  0xc(%ebp)
  800371:	ff 75 08             	pushl  0x8(%ebp)
  800374:	e8 05 00 00 00       	call   80037e <vprintfmt>
}
  800379:	83 c4 10             	add    $0x10,%esp
  80037c:	c9                   	leave  
  80037d:	c3                   	ret    

0080037e <vprintfmt>:
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	57                   	push   %edi
  800382:	56                   	push   %esi
  800383:	53                   	push   %ebx
  800384:	83 ec 2c             	sub    $0x2c,%esp
  800387:	e8 f4 fc ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  80038c:	81 c3 74 1c 00 00    	add    $0x1c74,%ebx
  800392:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  800395:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  80039c:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039e:	8d 77 01             	lea    0x1(%edi),%esi
  8003a1:	0f b6 07             	movzbl (%edi),%eax
  8003a4:	83 f8 25             	cmp    $0x25,%eax
  8003a7:	74 1c                	je     8003c5 <vprintfmt+0x47>
			if (ch == '\0')
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	0f 84 b9 04 00 00    	je     80086a <.L21+0x20>
			putch(ch, putdat);
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003b7:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003ba:	50                   	push   %eax
  8003bb:	ff 55 08             	call   *0x8(%ebp)
  8003be:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c1:	89 f7                	mov    %esi,%edi
  8003c3:	eb d9                	jmp    80039e <vprintfmt+0x20>
		padc = ' ';
  8003c5:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003d0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8d 7e 01             	lea    0x1(%esi),%edi
  8003e9:	0f b6 16             	movzbl (%esi),%edx
  8003ec:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ef:	3c 55                	cmp    $0x55,%al
  8003f1:	0f 87 53 04 00 00    	ja     80084a <.L21>
  8003f7:	0f b6 c0             	movzbl %al,%eax
  8003fa:	89 d9                	mov    %ebx,%ecx
  8003fc:	03 8c 83 98 ef ff ff 	add    -0x1068(%ebx,%eax,4),%ecx
  800403:	ff e1                	jmp    *%ecx

00800405 <.L73>:
  800405:	89 fe                	mov    %edi,%esi
			padc = '-';
  800407:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80040b:	eb d9                	jmp    8003e6 <vprintfmt+0x68>

0080040d <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  80040d:	89 fe                	mov    %edi,%esi
			padc = '0';
  80040f:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800413:	eb d1                	jmp    8003e6 <vprintfmt+0x68>

00800415 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	0f b6 d2             	movzbl %dl,%edx
  800418:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800422:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800425:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800429:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  80042c:	8d 7a d0             	lea    -0x30(%edx),%edi
  80042f:	83 ff 09             	cmp    $0x9,%edi
  800432:	0f 87 94 00 00 00    	ja     8004cc <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800438:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80043b:	eb e5                	jmp    800422 <.L28+0xd>

0080043d <.L25>:
			precision = va_arg(ap, int);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8b 00                	mov    (%eax),%eax
  800442:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 40 04             	lea    0x4(%eax),%eax
  80044b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800450:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800454:	79 90                	jns    8003e6 <vprintfmt+0x68>
				width = precision, precision = -1;
  800456:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800459:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800463:	eb 81                	jmp    8003e6 <vprintfmt+0x68>

00800465 <.L26>:
  800465:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800468:	85 c0                	test   %eax,%eax
  80046a:	ba 00 00 00 00       	mov    $0x0,%edx
  80046f:	0f 49 d0             	cmovns %eax,%edx
  800472:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800475:	89 fe                	mov    %edi,%esi
  800477:	e9 6a ff ff ff       	jmp    8003e6 <vprintfmt+0x68>

0080047c <.L22>:
  80047c:	89 fe                	mov    %edi,%esi
			altflag = 1;
  80047e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800485:	e9 5c ff ff ff       	jmp    8003e6 <vprintfmt+0x68>

0080048a <.L33>:
  80048a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80048d:	83 f9 01             	cmp    $0x1,%ecx
  800490:	7e 16                	jle    8004a8 <.L33+0x1e>
		return va_arg(*ap, long long);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8b 00                	mov    (%eax),%eax
  800497:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80049a:	8d 49 08             	lea    0x8(%ecx),%ecx
  80049d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004a3:	e9 f6 fe ff ff       	jmp    80039e <vprintfmt+0x20>
	else if (lflag)
  8004a8:	85 c9                	test   %ecx,%ecx
  8004aa:	75 10                	jne    8004bc <.L33+0x32>
		return va_arg(*ap, int);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004b4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004b7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ba:	eb e4                	jmp    8004a0 <.L33+0x16>
		return va_arg(*ap, long);
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8b 00                	mov    (%eax),%eax
  8004c1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004c4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004c7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ca:	eb d4                	jmp    8004a0 <.L33+0x16>
  8004cc:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004cf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004d2:	e9 79 ff ff ff       	jmp    800450 <.L25+0x13>

008004d7 <.L32>:
			lflag++;
  8004d7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004db:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8004dd:	e9 04 ff ff ff       	jmp    8003e6 <vprintfmt+0x68>

008004e2 <.L29>:
			putch(va_arg(ap, int), putdat);
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 70 04             	lea    0x4(%eax),%esi
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	ff 75 0c             	pushl  0xc(%ebp)
  8004ee:	ff 30                	pushl  (%eax)
  8004f0:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004f6:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  8004f9:	e9 a0 fe ff ff       	jmp    80039e <vprintfmt+0x20>

008004fe <.L31>:
			err = va_arg(ap, int);
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 70 04             	lea    0x4(%eax),%esi
  800504:	8b 00                	mov    (%eax),%eax
  800506:	99                   	cltd   
  800507:	31 d0                	xor    %edx,%eax
  800509:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050b:	83 f8 06             	cmp    $0x6,%eax
  80050e:	7f 29                	jg     800539 <.L31+0x3b>
  800510:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800517:	85 d2                	test   %edx,%edx
  800519:	74 1e                	je     800539 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  80051b:	52                   	push   %edx
  80051c:	8d 83 2b ef ff ff    	lea    -0x10d5(%ebx),%eax
  800522:	50                   	push   %eax
  800523:	ff 75 0c             	pushl  0xc(%ebp)
  800526:	ff 75 08             	pushl  0x8(%ebp)
  800529:	e8 33 fe ff ff       	call   800361 <printfmt>
  80052e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800531:	89 75 14             	mov    %esi,0x14(%ebp)
  800534:	e9 65 fe ff ff       	jmp    80039e <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800539:	50                   	push   %eax
  80053a:	8d 83 22 ef ff ff    	lea    -0x10de(%ebx),%eax
  800540:	50                   	push   %eax
  800541:	ff 75 0c             	pushl  0xc(%ebp)
  800544:	ff 75 08             	pushl  0x8(%ebp)
  800547:	e8 15 fe ff ff       	call   800361 <printfmt>
  80054c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80054f:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800552:	e9 47 fe ff ff       	jmp    80039e <vprintfmt+0x20>

00800557 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	83 c0 04             	add    $0x4,%eax
  80055d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800565:	85 f6                	test   %esi,%esi
  800567:	8d 83 1b ef ff ff    	lea    -0x10e5(%ebx),%eax
  80056d:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800570:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800574:	0f 8e b4 00 00 00    	jle    80062e <.L36+0xd7>
  80057a:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80057e:	75 08                	jne    800588 <.L36+0x31>
  800580:	89 7d 10             	mov    %edi,0x10(%ebp)
  800583:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800586:	eb 6c                	jmp    8005f4 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800588:	83 ec 08             	sub    $0x8,%esp
  80058b:	ff 75 cc             	pushl  -0x34(%ebp)
  80058e:	56                   	push   %esi
  80058f:	e8 73 03 00 00       	call   800907 <strnlen>
  800594:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800597:	29 c2                	sub    %eax,%edx
  800599:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80059c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80059f:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005a3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005a6:	89 d6                	mov    %edx,%esi
  8005a8:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005ab:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ad:	eb 10                	jmp    8005bf <.L36+0x68>
					putch(padc, putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	ff 75 0c             	pushl  0xc(%ebp)
  8005b5:	57                   	push   %edi
  8005b6:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b9:	83 ee 01             	sub    $0x1,%esi
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	85 f6                	test   %esi,%esi
  8005c1:	7f ec                	jg     8005af <.L36+0x58>
  8005c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005c9:	85 d2                	test   %edx,%edx
  8005cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d0:	0f 49 c2             	cmovns %edx,%eax
  8005d3:	29 c2                	sub    %eax,%edx
  8005d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005d8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005db:	eb 17                	jmp    8005f4 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8005dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e1:	75 30                	jne    800613 <.L36+0xbc>
					putch(ch, putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	ff 75 0c             	pushl  0xc(%ebp)
  8005e9:	50                   	push   %eax
  8005ea:	ff 55 08             	call   *0x8(%ebp)
  8005ed:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f0:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005f4:	83 c6 01             	add    $0x1,%esi
  8005f7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8005fb:	0f be c2             	movsbl %dl,%eax
  8005fe:	85 c0                	test   %eax,%eax
  800600:	74 58                	je     80065a <.L36+0x103>
  800602:	85 ff                	test   %edi,%edi
  800604:	78 d7                	js     8005dd <.L36+0x86>
  800606:	83 ef 01             	sub    $0x1,%edi
  800609:	79 d2                	jns    8005dd <.L36+0x86>
  80060b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800611:	eb 32                	jmp    800645 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800613:	0f be d2             	movsbl %dl,%edx
  800616:	83 ea 20             	sub    $0x20,%edx
  800619:	83 fa 5e             	cmp    $0x5e,%edx
  80061c:	76 c5                	jbe    8005e3 <.L36+0x8c>
					putch('?', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	ff 75 0c             	pushl  0xc(%ebp)
  800624:	6a 3f                	push   $0x3f
  800626:	ff 55 08             	call   *0x8(%ebp)
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	eb c2                	jmp    8005f0 <.L36+0x99>
  80062e:	89 7d 10             	mov    %edi,0x10(%ebp)
  800631:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800634:	eb be                	jmp    8005f4 <.L36+0x9d>
				putch(' ', putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	57                   	push   %edi
  80063a:	6a 20                	push   $0x20
  80063c:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80063f:	83 ee 01             	sub    $0x1,%esi
  800642:	83 c4 10             	add    $0x10,%esp
  800645:	85 f6                	test   %esi,%esi
  800647:	7f ed                	jg     800636 <.L36+0xdf>
  800649:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80064c:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  80064f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800652:	89 45 14             	mov    %eax,0x14(%ebp)
  800655:	e9 44 fd ff ff       	jmp    80039e <vprintfmt+0x20>
  80065a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80065d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800660:	eb e3                	jmp    800645 <.L36+0xee>

00800662 <.L30>:
  800662:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800665:	83 f9 01             	cmp    $0x1,%ecx
  800668:	7e 42                	jle    8006ac <.L30+0x4a>
		return va_arg(*ap, long long);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 50 04             	mov    0x4(%eax),%edx
  800670:	8b 00                	mov    (%eax),%eax
  800672:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800675:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8d 40 08             	lea    0x8(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800681:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800685:	79 5f                	jns    8006e6 <.L30+0x84>
				putch('-', putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	ff 75 0c             	pushl  0xc(%ebp)
  80068d:	6a 2d                	push   $0x2d
  80068f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800692:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800695:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800698:	f7 da                	neg    %edx
  80069a:	83 d1 00             	adc    $0x0,%ecx
  80069d:	f7 d9                	neg    %ecx
  80069f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a7:	e9 b8 00 00 00       	jmp    800764 <.L34+0x22>
	else if (lflag)
  8006ac:	85 c9                	test   %ecx,%ecx
  8006ae:	75 1b                	jne    8006cb <.L30+0x69>
		return va_arg(*ap, int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8b 30                	mov    (%eax),%esi
  8006b5:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006b8:	89 f0                	mov    %esi,%eax
  8006ba:	c1 f8 1f             	sar    $0x1f,%eax
  8006bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8d 40 04             	lea    0x4(%eax),%eax
  8006c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c9:	eb b6                	jmp    800681 <.L30+0x1f>
		return va_arg(*ap, long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 30                	mov    (%eax),%esi
  8006d0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006d3:	89 f0                	mov    %esi,%eax
  8006d5:	c1 f8 1f             	sar    $0x1f,%eax
  8006d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8d 40 04             	lea    0x4(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e4:	eb 9b                	jmp    800681 <.L30+0x1f>
			num = getint(&ap, lflag);
  8006e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006ec:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f1:	eb 71                	jmp    800764 <.L34+0x22>

008006f3 <.L37>:
  8006f3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8006f6:	83 f9 01             	cmp    $0x1,%ecx
  8006f9:	7e 15                	jle    800710 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8b 10                	mov    (%eax),%edx
  800700:	8b 48 04             	mov    0x4(%eax),%ecx
  800703:	8d 40 08             	lea    0x8(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800709:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070e:	eb 54                	jmp    800764 <.L34+0x22>
	else if (lflag)
  800710:	85 c9                	test   %ecx,%ecx
  800712:	75 17                	jne    80072b <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
  800719:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071e:	8d 40 04             	lea    0x4(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800724:	b8 0a 00 00 00       	mov    $0xa,%eax
  800729:	eb 39                	jmp    800764 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	8b 10                	mov    (%eax),%edx
  800730:	b9 00 00 00 00       	mov    $0x0,%ecx
  800735:	8d 40 04             	lea    0x4(%eax),%eax
  800738:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800740:	eb 22                	jmp    800764 <.L34+0x22>

00800742 <.L34>:
  800742:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800745:	83 f9 01             	cmp    $0x1,%ecx
  800748:	7e 3b                	jle    800785 <.L34+0x43>
		return va_arg(*ap, long long);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 50 04             	mov    0x4(%eax),%edx
  800750:	8b 00                	mov    (%eax),%eax
  800752:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800755:	8d 49 08             	lea    0x8(%ecx),%ecx
  800758:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80075b:	89 d1                	mov    %edx,%ecx
  80075d:	89 c2                	mov    %eax,%edx
			base = 8;
  80075f:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800764:	83 ec 0c             	sub    $0xc,%esp
  800767:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  80076b:	56                   	push   %esi
  80076c:	ff 75 e0             	pushl  -0x20(%ebp)
  80076f:	50                   	push   %eax
  800770:	51                   	push   %ecx
  800771:	52                   	push   %edx
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
  800775:	8b 45 08             	mov    0x8(%ebp),%eax
  800778:	e8 fd fa ff ff       	call   80027a <printnum>
			break;
  80077d:	83 c4 20             	add    $0x20,%esp
  800780:	e9 19 fc ff ff       	jmp    80039e <vprintfmt+0x20>
	else if (lflag)
  800785:	85 c9                	test   %ecx,%ecx
  800787:	75 13                	jne    80079c <.L34+0x5a>
		return va_arg(*ap, int);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8b 10                	mov    (%eax),%edx
  80078e:	89 d0                	mov    %edx,%eax
  800790:	99                   	cltd   
  800791:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800794:	8d 49 04             	lea    0x4(%ecx),%ecx
  800797:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079a:	eb bf                	jmp    80075b <.L34+0x19>
		return va_arg(*ap, long);
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8b 10                	mov    (%eax),%edx
  8007a1:	89 d0                	mov    %edx,%eax
  8007a3:	99                   	cltd   
  8007a4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007a7:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007aa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007ad:	eb ac                	jmp    80075b <.L34+0x19>

008007af <.L35>:
			putch('0', putdat);
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	ff 75 0c             	pushl  0xc(%ebp)
  8007b5:	6a 30                	push   $0x30
  8007b7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	6a 78                	push   $0x78
  8007c2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8b 10                	mov    (%eax),%edx
  8007ca:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007cf:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007dd:	eb 85                	jmp    800764 <.L34+0x22>

008007df <.L38>:
  8007df:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8007e2:	83 f9 01             	cmp    $0x1,%ecx
  8007e5:	7e 18                	jle    8007ff <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8b 10                	mov    (%eax),%edx
  8007ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ef:	8d 40 08             	lea    0x8(%eax),%eax
  8007f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f5:	b8 10 00 00 00       	mov    $0x10,%eax
  8007fa:	e9 65 ff ff ff       	jmp    800764 <.L34+0x22>
	else if (lflag)
  8007ff:	85 c9                	test   %ecx,%ecx
  800801:	75 1a                	jne    80081d <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	8b 10                	mov    (%eax),%edx
  800808:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080d:	8d 40 04             	lea    0x4(%eax),%eax
  800810:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800813:	b8 10 00 00 00       	mov    $0x10,%eax
  800818:	e9 47 ff ff ff       	jmp    800764 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8b 10                	mov    (%eax),%edx
  800822:	b9 00 00 00 00       	mov    $0x0,%ecx
  800827:	8d 40 04             	lea    0x4(%eax),%eax
  80082a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082d:	b8 10 00 00 00       	mov    $0x10,%eax
  800832:	e9 2d ff ff ff       	jmp    800764 <.L34+0x22>

00800837 <.L24>:
			putch(ch, putdat);
  800837:	83 ec 08             	sub    $0x8,%esp
  80083a:	ff 75 0c             	pushl  0xc(%ebp)
  80083d:	6a 25                	push   $0x25
  80083f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	e9 54 fb ff ff       	jmp    80039e <vprintfmt+0x20>

0080084a <.L21>:
			putch('%', putdat);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	ff 75 0c             	pushl  0xc(%ebp)
  800850:	6a 25                	push   $0x25
  800852:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	89 f7                	mov    %esi,%edi
  80085a:	eb 03                	jmp    80085f <.L21+0x15>
  80085c:	83 ef 01             	sub    $0x1,%edi
  80085f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800863:	75 f7                	jne    80085c <.L21+0x12>
  800865:	e9 34 fb ff ff       	jmp    80039e <vprintfmt+0x20>
}
  80086a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5f                   	pop    %edi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	83 ec 14             	sub    $0x14,%esp
  800879:	e8 02 f8 ff ff       	call   800080 <__x86.get_pc_thunk.bx>
  80087e:	81 c3 82 17 00 00    	add    $0x1782,%ebx
  800884:	8b 45 08             	mov    0x8(%ebp),%eax
  800887:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800891:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800894:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089b:	85 c0                	test   %eax,%eax
  80089d:	74 2b                	je     8008ca <vsnprintf+0x58>
  80089f:	85 d2                	test   %edx,%edx
  8008a1:	7e 27                	jle    8008ca <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a3:	ff 75 14             	pushl  0x14(%ebp)
  8008a6:	ff 75 10             	pushl  0x10(%ebp)
  8008a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ac:	50                   	push   %eax
  8008ad:	8d 83 44 e3 ff ff    	lea    -0x1cbc(%ebx),%eax
  8008b3:	50                   	push   %eax
  8008b4:	e8 c5 fa ff ff       	call   80037e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c2:	83 c4 10             	add    $0x10,%esp
}
  8008c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c8:	c9                   	leave  
  8008c9:	c3                   	ret    
		return -E_INVAL;
  8008ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008cf:	eb f4                	jmp    8008c5 <vsnprintf+0x53>

008008d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008da:	50                   	push   %eax
  8008db:	ff 75 10             	pushl  0x10(%ebp)
  8008de:	ff 75 0c             	pushl  0xc(%ebp)
  8008e1:	ff 75 08             	pushl  0x8(%ebp)
  8008e4:	e8 89 ff ff ff       	call   800872 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <__x86.get_pc_thunk.cx>:
  8008eb:	8b 0c 24             	mov    (%esp),%ecx
  8008ee:	c3                   	ret    

008008ef <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fa:	eb 03                	jmp    8008ff <strlen+0x10>
		n++;
  8008fc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008ff:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800903:	75 f7                	jne    8008fc <strlen+0xd>
	return n;
}
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
  800915:	eb 03                	jmp    80091a <strnlen+0x13>
		n++;
  800917:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091a:	39 d0                	cmp    %edx,%eax
  80091c:	74 06                	je     800924 <strnlen+0x1d>
  80091e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800922:	75 f3                	jne    800917 <strnlen+0x10>
	return n;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800930:	89 c2                	mov    %eax,%edx
  800932:	83 c1 01             	add    $0x1,%ecx
  800935:	83 c2 01             	add    $0x1,%edx
  800938:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80093c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80093f:	84 db                	test   %bl,%bl
  800941:	75 ef                	jne    800932 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800943:	5b                   	pop    %ebx
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80094d:	53                   	push   %ebx
  80094e:	e8 9c ff ff ff       	call   8008ef <strlen>
  800953:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800956:	ff 75 0c             	pushl  0xc(%ebp)
  800959:	01 d8                	add    %ebx,%eax
  80095b:	50                   	push   %eax
  80095c:	e8 c5 ff ff ff       	call   800926 <strcpy>
	return dst;
}
  800961:	89 d8                	mov    %ebx,%eax
  800963:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800966:	c9                   	leave  
  800967:	c3                   	ret    

00800968 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 75 08             	mov    0x8(%ebp),%esi
  800970:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800973:	89 f3                	mov    %esi,%ebx
  800975:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800978:	89 f2                	mov    %esi,%edx
  80097a:	eb 0f                	jmp    80098b <strncpy+0x23>
		*dst++ = *src;
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	0f b6 01             	movzbl (%ecx),%eax
  800982:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800985:	80 39 01             	cmpb   $0x1,(%ecx)
  800988:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80098b:	39 da                	cmp    %ebx,%edx
  80098d:	75 ed                	jne    80097c <strncpy+0x14>
	}
	return ret;
}
  80098f:	89 f0                	mov    %esi,%eax
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 75 08             	mov    0x8(%ebp),%esi
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009a3:	89 f0                	mov    %esi,%eax
  8009a5:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a9:	85 c9                	test   %ecx,%ecx
  8009ab:	75 0b                	jne    8009b8 <strlcpy+0x23>
  8009ad:	eb 17                	jmp    8009c6 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009af:	83 c2 01             	add    $0x1,%edx
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009b8:	39 d8                	cmp    %ebx,%eax
  8009ba:	74 07                	je     8009c3 <strlcpy+0x2e>
  8009bc:	0f b6 0a             	movzbl (%edx),%ecx
  8009bf:	84 c9                	test   %cl,%cl
  8009c1:	75 ec                	jne    8009af <strlcpy+0x1a>
		*dst = '\0';
  8009c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c6:	29 f0                	sub    %esi,%eax
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d5:	eb 06                	jmp    8009dd <strcmp+0x11>
		p++, q++;
  8009d7:	83 c1 01             	add    $0x1,%ecx
  8009da:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009dd:	0f b6 01             	movzbl (%ecx),%eax
  8009e0:	84 c0                	test   %al,%al
  8009e2:	74 04                	je     8009e8 <strcmp+0x1c>
  8009e4:	3a 02                	cmp    (%edx),%al
  8009e6:	74 ef                	je     8009d7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e8:	0f b6 c0             	movzbl %al,%eax
  8009eb:	0f b6 12             	movzbl (%edx),%edx
  8009ee:	29 d0                	sub    %edx,%eax
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fc:	89 c3                	mov    %eax,%ebx
  8009fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a01:	eb 06                	jmp    800a09 <strncmp+0x17>
		n--, p++, q++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a09:	39 d8                	cmp    %ebx,%eax
  800a0b:	74 16                	je     800a23 <strncmp+0x31>
  800a0d:	0f b6 08             	movzbl (%eax),%ecx
  800a10:	84 c9                	test   %cl,%cl
  800a12:	74 04                	je     800a18 <strncmp+0x26>
  800a14:	3a 0a                	cmp    (%edx),%cl
  800a16:	74 eb                	je     800a03 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a18:	0f b6 00             	movzbl (%eax),%eax
  800a1b:	0f b6 12             	movzbl (%edx),%edx
  800a1e:	29 d0                	sub    %edx,%eax
}
  800a20:	5b                   	pop    %ebx
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    
		return 0;
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	eb f6                	jmp    800a20 <strncmp+0x2e>

00800a2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a34:	0f b6 10             	movzbl (%eax),%edx
  800a37:	84 d2                	test   %dl,%dl
  800a39:	74 09                	je     800a44 <strchr+0x1a>
		if (*s == c)
  800a3b:	38 ca                	cmp    %cl,%dl
  800a3d:	74 0a                	je     800a49 <strchr+0x1f>
	for (; *s; s++)
  800a3f:	83 c0 01             	add    $0x1,%eax
  800a42:	eb f0                	jmp    800a34 <strchr+0xa>
			return (char *) s;
	return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a55:	eb 03                	jmp    800a5a <strfind+0xf>
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5d:	38 ca                	cmp    %cl,%dl
  800a5f:	74 04                	je     800a65 <strfind+0x1a>
  800a61:	84 d2                	test   %dl,%dl
  800a63:	75 f2                	jne    800a57 <strfind+0xc>
			break;
	return (char *) s;
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a73:	85 c9                	test   %ecx,%ecx
  800a75:	74 13                	je     800a8a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7d:	75 05                	jne    800a84 <memset+0x1d>
  800a7f:	f6 c1 03             	test   $0x3,%cl
  800a82:	74 0d                	je     800a91 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a87:	fc                   	cld    
  800a88:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8a:	89 f8                	mov    %edi,%eax
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    
		c &= 0xFF;
  800a91:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a95:	89 d3                	mov    %edx,%ebx
  800a97:	c1 e3 08             	shl    $0x8,%ebx
  800a9a:	89 d0                	mov    %edx,%eax
  800a9c:	c1 e0 18             	shl    $0x18,%eax
  800a9f:	89 d6                	mov    %edx,%esi
  800aa1:	c1 e6 10             	shl    $0x10,%esi
  800aa4:	09 f0                	or     %esi,%eax
  800aa6:	09 c2                	or     %eax,%edx
  800aa8:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800aaa:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800aad:	89 d0                	mov    %edx,%eax
  800aaf:	fc                   	cld    
  800ab0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab2:	eb d6                	jmp    800a8a <memset+0x23>

00800ab4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  800abc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac2:	39 c6                	cmp    %eax,%esi
  800ac4:	73 35                	jae    800afb <memmove+0x47>
  800ac6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac9:	39 c2                	cmp    %eax,%edx
  800acb:	76 2e                	jbe    800afb <memmove+0x47>
		s += n;
		d += n;
  800acd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	09 fe                	or     %edi,%esi
  800ad4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ada:	74 0c                	je     800ae8 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800adc:	83 ef 01             	sub    $0x1,%edi
  800adf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae2:	fd                   	std    
  800ae3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae5:	fc                   	cld    
  800ae6:	eb 21                	jmp    800b09 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae8:	f6 c1 03             	test   $0x3,%cl
  800aeb:	75 ef                	jne    800adc <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aed:	83 ef 04             	sub    $0x4,%edi
  800af0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800af6:	fd                   	std    
  800af7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af9:	eb ea                	jmp    800ae5 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afb:	89 f2                	mov    %esi,%edx
  800afd:	09 c2                	or     %eax,%edx
  800aff:	f6 c2 03             	test   $0x3,%dl
  800b02:	74 09                	je     800b0d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0d:	f6 c1 03             	test   $0x3,%cl
  800b10:	75 f2                	jne    800b04 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b12:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b15:	89 c7                	mov    %eax,%edi
  800b17:	fc                   	cld    
  800b18:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1a:	eb ed                	jmp    800b09 <memmove+0x55>

00800b1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b1f:	ff 75 10             	pushl  0x10(%ebp)
  800b22:	ff 75 0c             	pushl  0xc(%ebp)
  800b25:	ff 75 08             	pushl  0x8(%ebp)
  800b28:	e8 87 ff ff ff       	call   800ab4 <memmove>
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3a:	89 c6                	mov    %eax,%esi
  800b3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3f:	39 f0                	cmp    %esi,%eax
  800b41:	74 1c                	je     800b5f <memcmp+0x30>
		if (*s1 != *s2)
  800b43:	0f b6 08             	movzbl (%eax),%ecx
  800b46:	0f b6 1a             	movzbl (%edx),%ebx
  800b49:	38 d9                	cmp    %bl,%cl
  800b4b:	75 08                	jne    800b55 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b4d:	83 c0 01             	add    $0x1,%eax
  800b50:	83 c2 01             	add    $0x1,%edx
  800b53:	eb ea                	jmp    800b3f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c1             	movzbl %cl,%eax
  800b58:	0f b6 db             	movzbl %bl,%ebx
  800b5b:	29 d8                	sub    %ebx,%eax
  800b5d:	eb 05                	jmp    800b64 <memcmp+0x35>
	}

	return 0;
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b76:	39 d0                	cmp    %edx,%eax
  800b78:	73 09                	jae    800b83 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7a:	38 08                	cmp    %cl,(%eax)
  800b7c:	74 05                	je     800b83 <memfind+0x1b>
	for (; s < ends; s++)
  800b7e:	83 c0 01             	add    $0x1,%eax
  800b81:	eb f3                	jmp    800b76 <memfind+0xe>
			break;
	return (void *) s;
}
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b91:	eb 03                	jmp    800b96 <strtol+0x11>
		s++;
  800b93:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b96:	0f b6 01             	movzbl (%ecx),%eax
  800b99:	3c 20                	cmp    $0x20,%al
  800b9b:	74 f6                	je     800b93 <strtol+0xe>
  800b9d:	3c 09                	cmp    $0x9,%al
  800b9f:	74 f2                	je     800b93 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ba1:	3c 2b                	cmp    $0x2b,%al
  800ba3:	74 2e                	je     800bd3 <strtol+0x4e>
	int neg = 0;
  800ba5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800baa:	3c 2d                	cmp    $0x2d,%al
  800bac:	74 2f                	je     800bdd <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bb4:	75 05                	jne    800bbb <strtol+0x36>
  800bb6:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb9:	74 2c                	je     800be7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbb:	85 db                	test   %ebx,%ebx
  800bbd:	75 0a                	jne    800bc9 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bbf:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bc4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc7:	74 28                	je     800bf1 <strtol+0x6c>
		base = 10;
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd1:	eb 50                	jmp    800c23 <strtol+0x9e>
		s++;
  800bd3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bd6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdb:	eb d1                	jmp    800bae <strtol+0x29>
		s++, neg = 1;
  800bdd:	83 c1 01             	add    $0x1,%ecx
  800be0:	bf 01 00 00 00       	mov    $0x1,%edi
  800be5:	eb c7                	jmp    800bae <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800beb:	74 0e                	je     800bfb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bed:	85 db                	test   %ebx,%ebx
  800bef:	75 d8                	jne    800bc9 <strtol+0x44>
		s++, base = 8;
  800bf1:	83 c1 01             	add    $0x1,%ecx
  800bf4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bf9:	eb ce                	jmp    800bc9 <strtol+0x44>
		s += 2, base = 16;
  800bfb:	83 c1 02             	add    $0x2,%ecx
  800bfe:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c03:	eb c4                	jmp    800bc9 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c08:	89 f3                	mov    %esi,%ebx
  800c0a:	80 fb 19             	cmp    $0x19,%bl
  800c0d:	77 29                	ja     800c38 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c0f:	0f be d2             	movsbl %dl,%edx
  800c12:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c15:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c18:	7d 30                	jge    800c4a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c1a:	83 c1 01             	add    $0x1,%ecx
  800c1d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c21:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c23:	0f b6 11             	movzbl (%ecx),%edx
  800c26:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c29:	89 f3                	mov    %esi,%ebx
  800c2b:	80 fb 09             	cmp    $0x9,%bl
  800c2e:	77 d5                	ja     800c05 <strtol+0x80>
			dig = *s - '0';
  800c30:	0f be d2             	movsbl %dl,%edx
  800c33:	83 ea 30             	sub    $0x30,%edx
  800c36:	eb dd                	jmp    800c15 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c38:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c3b:	89 f3                	mov    %esi,%ebx
  800c3d:	80 fb 19             	cmp    $0x19,%bl
  800c40:	77 08                	ja     800c4a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c42:	0f be d2             	movsbl %dl,%edx
  800c45:	83 ea 37             	sub    $0x37,%edx
  800c48:	eb cb                	jmp    800c15 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4e:	74 05                	je     800c55 <strtol+0xd0>
		*endptr = (char *) s;
  800c50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c53:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c55:	89 c2                	mov    %eax,%edx
  800c57:	f7 da                	neg    %edx
  800c59:	85 ff                	test   %edi,%edi
  800c5b:	0f 45 c2             	cmovne %edx,%eax
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    
  800c63:	66 90                	xchg   %ax,%ax
  800c65:	66 90                	xchg   %ax,%ax
  800c67:	66 90                	xchg   %ax,%ax
  800c69:	66 90                	xchg   %ax,%ax
  800c6b:	66 90                	xchg   %ax,%ax
  800c6d:	66 90                	xchg   %ax,%ax
  800c6f:	90                   	nop

00800c70 <__udivdi3>:
  800c70:	55                   	push   %ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 1c             	sub    $0x1c,%esp
  800c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c7b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c83:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c87:	85 d2                	test   %edx,%edx
  800c89:	75 35                	jne    800cc0 <__udivdi3+0x50>
  800c8b:	39 f3                	cmp    %esi,%ebx
  800c8d:	0f 87 bd 00 00 00    	ja     800d50 <__udivdi3+0xe0>
  800c93:	85 db                	test   %ebx,%ebx
  800c95:	89 d9                	mov    %ebx,%ecx
  800c97:	75 0b                	jne    800ca4 <__udivdi3+0x34>
  800c99:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9e:	31 d2                	xor    %edx,%edx
  800ca0:	f7 f3                	div    %ebx
  800ca2:	89 c1                	mov    %eax,%ecx
  800ca4:	31 d2                	xor    %edx,%edx
  800ca6:	89 f0                	mov    %esi,%eax
  800ca8:	f7 f1                	div    %ecx
  800caa:	89 c6                	mov    %eax,%esi
  800cac:	89 e8                	mov    %ebp,%eax
  800cae:	89 f7                	mov    %esi,%edi
  800cb0:	f7 f1                	div    %ecx
  800cb2:	89 fa                	mov    %edi,%edx
  800cb4:	83 c4 1c             	add    $0x1c,%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    
  800cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	39 f2                	cmp    %esi,%edx
  800cc2:	77 7c                	ja     800d40 <__udivdi3+0xd0>
  800cc4:	0f bd fa             	bsr    %edx,%edi
  800cc7:	83 f7 1f             	xor    $0x1f,%edi
  800cca:	0f 84 98 00 00 00    	je     800d68 <__udivdi3+0xf8>
  800cd0:	89 f9                	mov    %edi,%ecx
  800cd2:	b8 20 00 00 00       	mov    $0x20,%eax
  800cd7:	29 f8                	sub    %edi,%eax
  800cd9:	d3 e2                	shl    %cl,%edx
  800cdb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cdf:	89 c1                	mov    %eax,%ecx
  800ce1:	89 da                	mov    %ebx,%edx
  800ce3:	d3 ea                	shr    %cl,%edx
  800ce5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ce9:	09 d1                	or     %edx,%ecx
  800ceb:	89 f2                	mov    %esi,%edx
  800ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cf1:	89 f9                	mov    %edi,%ecx
  800cf3:	d3 e3                	shl    %cl,%ebx
  800cf5:	89 c1                	mov    %eax,%ecx
  800cf7:	d3 ea                	shr    %cl,%edx
  800cf9:	89 f9                	mov    %edi,%ecx
  800cfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cff:	d3 e6                	shl    %cl,%esi
  800d01:	89 eb                	mov    %ebp,%ebx
  800d03:	89 c1                	mov    %eax,%ecx
  800d05:	d3 eb                	shr    %cl,%ebx
  800d07:	09 de                	or     %ebx,%esi
  800d09:	89 f0                	mov    %esi,%eax
  800d0b:	f7 74 24 08          	divl   0x8(%esp)
  800d0f:	89 d6                	mov    %edx,%esi
  800d11:	89 c3                	mov    %eax,%ebx
  800d13:	f7 64 24 0c          	mull   0xc(%esp)
  800d17:	39 d6                	cmp    %edx,%esi
  800d19:	72 0c                	jb     800d27 <__udivdi3+0xb7>
  800d1b:	89 f9                	mov    %edi,%ecx
  800d1d:	d3 e5                	shl    %cl,%ebp
  800d1f:	39 c5                	cmp    %eax,%ebp
  800d21:	73 5d                	jae    800d80 <__udivdi3+0x110>
  800d23:	39 d6                	cmp    %edx,%esi
  800d25:	75 59                	jne    800d80 <__udivdi3+0x110>
  800d27:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d2a:	31 ff                	xor    %edi,%edi
  800d2c:	89 fa                	mov    %edi,%edx
  800d2e:	83 c4 1c             	add    $0x1c,%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    
  800d36:	8d 76 00             	lea    0x0(%esi),%esi
  800d39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d40:	31 ff                	xor    %edi,%edi
  800d42:	31 c0                	xor    %eax,%eax
  800d44:	89 fa                	mov    %edi,%edx
  800d46:	83 c4 1c             	add    $0x1c,%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    
  800d4e:	66 90                	xchg   %ax,%ax
  800d50:	31 ff                	xor    %edi,%edi
  800d52:	89 e8                	mov    %ebp,%eax
  800d54:	89 f2                	mov    %esi,%edx
  800d56:	f7 f3                	div    %ebx
  800d58:	89 fa                	mov    %edi,%edx
  800d5a:	83 c4 1c             	add    $0x1c,%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    
  800d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d68:	39 f2                	cmp    %esi,%edx
  800d6a:	72 06                	jb     800d72 <__udivdi3+0x102>
  800d6c:	31 c0                	xor    %eax,%eax
  800d6e:	39 eb                	cmp    %ebp,%ebx
  800d70:	77 d2                	ja     800d44 <__udivdi3+0xd4>
  800d72:	b8 01 00 00 00       	mov    $0x1,%eax
  800d77:	eb cb                	jmp    800d44 <__udivdi3+0xd4>
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	89 d8                	mov    %ebx,%eax
  800d82:	31 ff                	xor    %edi,%edi
  800d84:	eb be                	jmp    800d44 <__udivdi3+0xd4>
  800d86:	66 90                	xchg   %ax,%ax
  800d88:	66 90                	xchg   %ax,%ax
  800d8a:	66 90                	xchg   %ax,%ax
  800d8c:	66 90                	xchg   %ax,%ax
  800d8e:	66 90                	xchg   %ax,%ax

00800d90 <__umoddi3>:
  800d90:	55                   	push   %ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 1c             	sub    $0x1c,%esp
  800d97:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800da7:	85 ed                	test   %ebp,%ebp
  800da9:	89 f0                	mov    %esi,%eax
  800dab:	89 da                	mov    %ebx,%edx
  800dad:	75 19                	jne    800dc8 <__umoddi3+0x38>
  800daf:	39 df                	cmp    %ebx,%edi
  800db1:	0f 86 b1 00 00 00    	jbe    800e68 <__umoddi3+0xd8>
  800db7:	f7 f7                	div    %edi
  800db9:	89 d0                	mov    %edx,%eax
  800dbb:	31 d2                	xor    %edx,%edx
  800dbd:	83 c4 1c             	add    $0x1c,%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    
  800dc5:	8d 76 00             	lea    0x0(%esi),%esi
  800dc8:	39 dd                	cmp    %ebx,%ebp
  800dca:	77 f1                	ja     800dbd <__umoddi3+0x2d>
  800dcc:	0f bd cd             	bsr    %ebp,%ecx
  800dcf:	83 f1 1f             	xor    $0x1f,%ecx
  800dd2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800dd6:	0f 84 b4 00 00 00    	je     800e90 <__umoddi3+0x100>
  800ddc:	b8 20 00 00 00       	mov    $0x20,%eax
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800de7:	29 c2                	sub    %eax,%edx
  800de9:	89 c1                	mov    %eax,%ecx
  800deb:	89 f8                	mov    %edi,%eax
  800ded:	d3 e5                	shl    %cl,%ebp
  800def:	89 d1                	mov    %edx,%ecx
  800df1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800df5:	d3 e8                	shr    %cl,%eax
  800df7:	09 c5                	or     %eax,%ebp
  800df9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dfd:	89 c1                	mov    %eax,%ecx
  800dff:	d3 e7                	shl    %cl,%edi
  800e01:	89 d1                	mov    %edx,%ecx
  800e03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e07:	89 df                	mov    %ebx,%edi
  800e09:	d3 ef                	shr    %cl,%edi
  800e0b:	89 c1                	mov    %eax,%ecx
  800e0d:	89 f0                	mov    %esi,%eax
  800e0f:	d3 e3                	shl    %cl,%ebx
  800e11:	89 d1                	mov    %edx,%ecx
  800e13:	89 fa                	mov    %edi,%edx
  800e15:	d3 e8                	shr    %cl,%eax
  800e17:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e1c:	09 d8                	or     %ebx,%eax
  800e1e:	f7 f5                	div    %ebp
  800e20:	d3 e6                	shl    %cl,%esi
  800e22:	89 d1                	mov    %edx,%ecx
  800e24:	f7 64 24 08          	mull   0x8(%esp)
  800e28:	39 d1                	cmp    %edx,%ecx
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	89 d7                	mov    %edx,%edi
  800e2e:	72 06                	jb     800e36 <__umoddi3+0xa6>
  800e30:	75 0e                	jne    800e40 <__umoddi3+0xb0>
  800e32:	39 c6                	cmp    %eax,%esi
  800e34:	73 0a                	jae    800e40 <__umoddi3+0xb0>
  800e36:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e3a:	19 ea                	sbb    %ebp,%edx
  800e3c:	89 d7                	mov    %edx,%edi
  800e3e:	89 c3                	mov    %eax,%ebx
  800e40:	89 ca                	mov    %ecx,%edx
  800e42:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e47:	29 de                	sub    %ebx,%esi
  800e49:	19 fa                	sbb    %edi,%edx
  800e4b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e4f:	89 d0                	mov    %edx,%eax
  800e51:	d3 e0                	shl    %cl,%eax
  800e53:	89 d9                	mov    %ebx,%ecx
  800e55:	d3 ee                	shr    %cl,%esi
  800e57:	d3 ea                	shr    %cl,%edx
  800e59:	09 f0                	or     %esi,%eax
  800e5b:	83 c4 1c             	add    $0x1c,%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    
  800e63:	90                   	nop
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	85 ff                	test   %edi,%edi
  800e6a:	89 f9                	mov    %edi,%ecx
  800e6c:	75 0b                	jne    800e79 <__umoddi3+0xe9>
  800e6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e73:	31 d2                	xor    %edx,%edx
  800e75:	f7 f7                	div    %edi
  800e77:	89 c1                	mov    %eax,%ecx
  800e79:	89 d8                	mov    %ebx,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f1                	div    %ecx
  800e7f:	89 f0                	mov    %esi,%eax
  800e81:	f7 f1                	div    %ecx
  800e83:	e9 31 ff ff ff       	jmp    800db9 <__umoddi3+0x29>
  800e88:	90                   	nop
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	39 dd                	cmp    %ebx,%ebp
  800e92:	72 08                	jb     800e9c <__umoddi3+0x10c>
  800e94:	39 f7                	cmp    %esi,%edi
  800e96:	0f 87 21 ff ff ff    	ja     800dbd <__umoddi3+0x2d>
  800e9c:	89 da                	mov    %ebx,%edx
  800e9e:	89 f0                	mov    %esi,%eax
  800ea0:	29 f8                	sub    %edi,%eax
  800ea2:	19 ea                	sbb    %ebp,%edx
  800ea4:	e9 14 ff ff ff       	jmp    800dbd <__umoddi3+0x2d>
