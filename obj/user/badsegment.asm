
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	53                   	push   %ebx
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	e8 3b 00 00 00       	call   800085 <__x86.get_pc_thunk.bx>
  80004a:	81 c3 b6 1f 00 00    	add    $0x1fb6,%ebx
  800050:	8b 45 08             	mov    0x8(%ebp),%eax
  800053:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800056:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  80005c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800062:	85 c0                	test   %eax,%eax
  800064:	7e 08                	jle    80006e <libmain+0x30>
		binaryname = argv[0];
  800066:	8b 0a                	mov    (%edx),%ecx
  800068:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	52                   	push   %edx
  800072:	50                   	push   %eax
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0c 00 00 00       	call   800089 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800083:	c9                   	leave  
  800084:	c3                   	ret    

00800085 <__x86.get_pc_thunk.bx>:
  800085:	8b 1c 24             	mov    (%esp),%ebx
  800088:	c3                   	ret    

00800089 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800089:	55                   	push   %ebp
  80008a:	89 e5                	mov    %esp,%ebp
  80008c:	53                   	push   %ebx
  80008d:	83 ec 10             	sub    $0x10,%esp
  800090:	e8 f0 ff ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  800095:	81 c3 6b 1f 00 00    	add    $0x1f6b,%ebx
	sys_env_destroy(0);
  80009b:	6a 00                	push   $0x0
  80009d:	e8 45 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 1c             	sub    $0x1c,%esp
  8000f0:	e8 66 00 00 00       	call   80015b <__x86.get_pc_thunk.ax>
  8000f5:	05 0b 1f 00 00       	add    $0x1f0b,%eax
  8000fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800102:	8b 55 08             	mov    0x8(%ebp),%edx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	89 cb                	mov    %ecx,%ebx
  80010c:	89 cf                	mov    %ecx,%edi
  80010e:	89 ce                	mov    %ecx,%esi
  800110:	cd 30                	int    $0x30
	if(check && ret > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7f 08                	jg     80011e <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	50                   	push   %eax
  800122:	6a 03                	push   $0x3
  800124:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800127:	8d 83 b6 ee ff ff    	lea    -0x114a(%ebx),%eax
  80012d:	50                   	push   %eax
  80012e:	6a 23                	push   $0x23
  800130:	8d 83 d3 ee ff ff    	lea    -0x112d(%ebx),%eax
  800136:	50                   	push   %eax
  800137:	e8 23 00 00 00       	call   80015f <_panic>

0080013c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 02 00 00 00       	mov    $0x2,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <__x86.get_pc_thunk.ax>:
  80015b:	8b 04 24             	mov    (%esp),%eax
  80015e:	c3                   	ret    

0080015f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 0c             	sub    $0xc,%esp
  800168:	e8 18 ff ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  80016d:	81 c3 93 1e 00 00    	add    $0x1e93,%ebx
	va_list ap;

	va_start(ap, fmt);
  800173:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800176:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80017c:	8b 38                	mov    (%eax),%edi
  80017e:	e8 b9 ff ff ff       	call   80013c <sys_getenvid>
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	ff 75 0c             	pushl  0xc(%ebp)
  800189:	ff 75 08             	pushl  0x8(%ebp)
  80018c:	57                   	push   %edi
  80018d:	50                   	push   %eax
  80018e:	8d 83 e4 ee ff ff    	lea    -0x111c(%ebx),%eax
  800194:	50                   	push   %eax
  800195:	e8 d1 00 00 00       	call   80026b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019a:	83 c4 18             	add    $0x18,%esp
  80019d:	56                   	push   %esi
  80019e:	ff 75 10             	pushl  0x10(%ebp)
  8001a1:	e8 63 00 00 00       	call   800209 <vcprintf>
	cprintf("\n");
  8001a6:	8d 83 08 ef ff ff    	lea    -0x10f8(%ebx),%eax
  8001ac:	89 04 24             	mov    %eax,(%esp)
  8001af:	e8 b7 00 00 00       	call   80026b <cprintf>
  8001b4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b7:	cc                   	int3   
  8001b8:	eb fd                	jmp    8001b7 <_panic+0x58>

008001ba <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ba:	55                   	push   %ebp
  8001bb:	89 e5                	mov    %esp,%ebp
  8001bd:	56                   	push   %esi
  8001be:	53                   	push   %ebx
  8001bf:	e8 c1 fe ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  8001c4:	81 c3 3c 1e 00 00    	add    $0x1e3c,%ebx
  8001ca:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001cd:	8b 16                	mov    (%esi),%edx
  8001cf:	8d 42 01             	lea    0x1(%edx),%eax
  8001d2:	89 06                	mov    %eax,(%esi)
  8001d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d7:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e0:	74 0b                	je     8001ed <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001e2:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ed:	83 ec 08             	sub    $0x8,%esp
  8001f0:	68 ff 00 00 00       	push   $0xff
  8001f5:	8d 46 08             	lea    0x8(%esi),%eax
  8001f8:	50                   	push   %eax
  8001f9:	e8 ac fe ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8001fe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	eb d9                	jmp    8001e2 <putch+0x28>

00800209 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	53                   	push   %ebx
  80020d:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800213:	e8 6d fe ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  800218:	81 c3 e8 1d 00 00    	add    $0x1de8,%ebx
	struct printbuf b;

	b.idx = 0;
  80021e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800225:	00 00 00 
	b.cnt = 0;
  800228:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800232:	ff 75 0c             	pushl  0xc(%ebp)
  800235:	ff 75 08             	pushl  0x8(%ebp)
  800238:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023e:	50                   	push   %eax
  80023f:	8d 83 ba e1 ff ff    	lea    -0x1e46(%ebx),%eax
  800245:	50                   	push   %eax
  800246:	e8 38 01 00 00       	call   800383 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024b:	83 c4 08             	add    $0x8,%esp
  80024e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800254:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025a:	50                   	push   %eax
  80025b:	e8 4a fe ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  800260:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800266:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800271:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800274:	50                   	push   %eax
  800275:	ff 75 08             	pushl  0x8(%ebp)
  800278:	e8 8c ff ff ff       	call   800209 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027d:	c9                   	leave  
  80027e:	c3                   	ret    

0080027f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 2c             	sub    $0x2c,%esp
  800288:	e8 63 06 00 00       	call   8008f0 <__x86.get_pc_thunk.cx>
  80028d:	81 c1 73 1d 00 00    	add    $0x1d73,%ecx
  800293:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800296:	89 c7                	mov    %eax,%edi
  800298:	89 d6                	mov    %edx,%esi
  80029a:	8b 45 08             	mov    0x8(%ebp),%eax
  80029d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002b1:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002b4:	39 d3                	cmp    %edx,%ebx
  8002b6:	72 09                	jb     8002c1 <printnum+0x42>
  8002b8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002bb:	0f 87 83 00 00 00    	ja     800344 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c1:	83 ec 0c             	sub    $0xc,%esp
  8002c4:	ff 75 18             	pushl  0x18(%ebp)
  8002c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ca:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002cd:	53                   	push   %ebx
  8002ce:	ff 75 10             	pushl  0x10(%ebp)
  8002d1:	83 ec 08             	sub    $0x8,%esp
  8002d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002da:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002dd:	ff 75 d0             	pushl  -0x30(%ebp)
  8002e0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002e3:	e8 88 09 00 00       	call   800c70 <__udivdi3>
  8002e8:	83 c4 18             	add    $0x18,%esp
  8002eb:	52                   	push   %edx
  8002ec:	50                   	push   %eax
  8002ed:	89 f2                	mov    %esi,%edx
  8002ef:	89 f8                	mov    %edi,%eax
  8002f1:	e8 89 ff ff ff       	call   80027f <printnum>
  8002f6:	83 c4 20             	add    $0x20,%esp
  8002f9:	eb 13                	jmp    80030e <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002fb:	83 ec 08             	sub    $0x8,%esp
  8002fe:	56                   	push   %esi
  8002ff:	ff 75 18             	pushl  0x18(%ebp)
  800302:	ff d7                	call   *%edi
  800304:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800307:	83 eb 01             	sub    $0x1,%ebx
  80030a:	85 db                	test   %ebx,%ebx
  80030c:	7f ed                	jg     8002fb <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	56                   	push   %esi
  800312:	83 ec 04             	sub    $0x4,%esp
  800315:	ff 75 dc             	pushl  -0x24(%ebp)
  800318:	ff 75 d8             	pushl  -0x28(%ebp)
  80031b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80031e:	ff 75 d0             	pushl  -0x30(%ebp)
  800321:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800324:	89 f3                	mov    %esi,%ebx
  800326:	e8 65 0a 00 00       	call   800d90 <__umoddi3>
  80032b:	83 c4 14             	add    $0x14,%esp
  80032e:	0f be 84 06 0a ef ff 	movsbl -0x10f6(%esi,%eax,1),%eax
  800335:	ff 
  800336:	50                   	push   %eax
  800337:	ff d7                	call   *%edi
}
  800339:	83 c4 10             	add    $0x10,%esp
  80033c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    
  800344:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800347:	eb be                	jmp    800307 <printnum+0x88>

00800349 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800353:	8b 10                	mov    (%eax),%edx
  800355:	3b 50 04             	cmp    0x4(%eax),%edx
  800358:	73 0a                	jae    800364 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	88 02                	mov    %al,(%edx)
}
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <printfmt>:
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80036c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036f:	50                   	push   %eax
  800370:	ff 75 10             	pushl  0x10(%ebp)
  800373:	ff 75 0c             	pushl  0xc(%ebp)
  800376:	ff 75 08             	pushl  0x8(%ebp)
  800379:	e8 05 00 00 00       	call   800383 <vprintfmt>
}
  80037e:	83 c4 10             	add    $0x10,%esp
  800381:	c9                   	leave  
  800382:	c3                   	ret    

00800383 <vprintfmt>:
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	57                   	push   %edi
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	83 ec 2c             	sub    $0x2c,%esp
  80038c:	e8 f4 fc ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  800391:	81 c3 6f 1c 00 00    	add    $0x1c6f,%ebx
  800397:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  80039a:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003a1:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a3:	8d 77 01             	lea    0x1(%edi),%esi
  8003a6:	0f b6 07             	movzbl (%edi),%eax
  8003a9:	83 f8 25             	cmp    $0x25,%eax
  8003ac:	74 1c                	je     8003ca <vprintfmt+0x47>
			if (ch == '\0')
  8003ae:	85 c0                	test   %eax,%eax
  8003b0:	0f 84 b9 04 00 00    	je     80086f <.L21+0x20>
			putch(ch, putdat);
  8003b6:	83 ec 08             	sub    $0x8,%esp
  8003b9:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003bc:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003bf:	50                   	push   %eax
  8003c0:	ff 55 08             	call   *0x8(%ebp)
  8003c3:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c6:	89 f7                	mov    %esi,%edi
  8003c8:	eb d9                	jmp    8003a3 <vprintfmt+0x20>
		padc = ' ';
  8003ca:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003d5:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8d 7e 01             	lea    0x1(%esi),%edi
  8003ee:	0f b6 16             	movzbl (%esi),%edx
  8003f1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f4:	3c 55                	cmp    $0x55,%al
  8003f6:	0f 87 53 04 00 00    	ja     80084f <.L21>
  8003fc:	0f b6 c0             	movzbl %al,%eax
  8003ff:	89 d9                	mov    %ebx,%ecx
  800401:	03 8c 83 98 ef ff ff 	add    -0x1068(%ebx,%eax,4),%ecx
  800408:	ff e1                	jmp    *%ecx

0080040a <.L73>:
  80040a:	89 fe                	mov    %edi,%esi
			padc = '-';
  80040c:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800410:	eb d9                	jmp    8003eb <vprintfmt+0x68>

00800412 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800412:	89 fe                	mov    %edi,%esi
			padc = '0';
  800414:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800418:	eb d1                	jmp    8003eb <vprintfmt+0x68>

0080041a <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	0f b6 d2             	movzbl %dl,%edx
  80041d:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  80041f:	b8 00 00 00 00       	mov    $0x0,%eax
  800424:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800427:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042e:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800431:	8d 7a d0             	lea    -0x30(%edx),%edi
  800434:	83 ff 09             	cmp    $0x9,%edi
  800437:	0f 87 94 00 00 00    	ja     8004d1 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  80043d:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800440:	eb e5                	jmp    800427 <.L28+0xd>

00800442 <.L25>:
			precision = va_arg(ap, int);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8b 00                	mov    (%eax),%eax
  800447:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	8d 40 04             	lea    0x4(%eax),%eax
  800450:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800453:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800455:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800459:	79 90                	jns    8003eb <vprintfmt+0x68>
				width = precision, precision = -1;
  80045b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80045e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800461:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800468:	eb 81                	jmp    8003eb <vprintfmt+0x68>

0080046a <.L26>:
  80046a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046d:	85 c0                	test   %eax,%eax
  80046f:	ba 00 00 00 00       	mov    $0x0,%edx
  800474:	0f 49 d0             	cmovns %eax,%edx
  800477:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	89 fe                	mov    %edi,%esi
  80047c:	e9 6a ff ff ff       	jmp    8003eb <vprintfmt+0x68>

00800481 <.L22>:
  800481:	89 fe                	mov    %edi,%esi
			altflag = 1;
  800483:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80048a:	e9 5c ff ff ff       	jmp    8003eb <vprintfmt+0x68>

0080048f <.L33>:
  80048f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800492:	83 f9 01             	cmp    $0x1,%ecx
  800495:	7e 16                	jle    8004ad <.L33+0x1e>
		return va_arg(*ap, long long);
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80049f:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004a2:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004a8:	e9 f6 fe ff ff       	jmp    8003a3 <vprintfmt+0x20>
	else if (lflag)
  8004ad:	85 c9                	test   %ecx,%ecx
  8004af:	75 10                	jne    8004c1 <.L33+0x32>
		return va_arg(*ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004b9:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004bf:	eb e4                	jmp    8004a5 <.L33+0x16>
		return va_arg(*ap, long);
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8b 00                	mov    (%eax),%eax
  8004c6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004c9:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004cf:	eb d4                	jmp    8004a5 <.L33+0x16>
  8004d1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004d4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004d7:	e9 79 ff ff ff       	jmp    800455 <.L25+0x13>

008004dc <.L32>:
			lflag++;
  8004dc:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8004e2:	e9 04 ff ff ff       	jmp    8003eb <vprintfmt+0x68>

008004e7 <.L29>:
			putch(va_arg(ap, int), putdat);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 70 04             	lea    0x4(%eax),%esi
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	ff 30                	pushl  (%eax)
  8004f5:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004fb:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  8004fe:	e9 a0 fe ff ff       	jmp    8003a3 <vprintfmt+0x20>

00800503 <.L31>:
			err = va_arg(ap, int);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 70 04             	lea    0x4(%eax),%esi
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	99                   	cltd   
  80050c:	31 d0                	xor    %edx,%eax
  80050e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800510:	83 f8 06             	cmp    $0x6,%eax
  800513:	7f 29                	jg     80053e <.L31+0x3b>
  800515:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  80051c:	85 d2                	test   %edx,%edx
  80051e:	74 1e                	je     80053e <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800520:	52                   	push   %edx
  800521:	8d 83 2b ef ff ff    	lea    -0x10d5(%ebx),%eax
  800527:	50                   	push   %eax
  800528:	ff 75 0c             	pushl  0xc(%ebp)
  80052b:	ff 75 08             	pushl  0x8(%ebp)
  80052e:	e8 33 fe ff ff       	call   800366 <printfmt>
  800533:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800536:	89 75 14             	mov    %esi,0x14(%ebp)
  800539:	e9 65 fe ff ff       	jmp    8003a3 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  80053e:	50                   	push   %eax
  80053f:	8d 83 22 ef ff ff    	lea    -0x10de(%ebx),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 0c             	pushl  0xc(%ebp)
  800549:	ff 75 08             	pushl  0x8(%ebp)
  80054c:	e8 15 fe ff ff       	call   800366 <printfmt>
  800551:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800554:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800557:	e9 47 fe ff ff       	jmp    8003a3 <vprintfmt+0x20>

0080055c <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	83 c0 04             	add    $0x4,%eax
  800562:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80056a:	85 f6                	test   %esi,%esi
  80056c:	8d 83 1b ef ff ff    	lea    -0x10e5(%ebx),%eax
  800572:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800575:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800579:	0f 8e b4 00 00 00    	jle    800633 <.L36+0xd7>
  80057f:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800583:	75 08                	jne    80058d <.L36+0x31>
  800585:	89 7d 10             	mov    %edi,0x10(%ebp)
  800588:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80058b:	eb 6c                	jmp    8005f9 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	ff 75 cc             	pushl  -0x34(%ebp)
  800593:	56                   	push   %esi
  800594:	e8 73 03 00 00       	call   80090c <strnlen>
  800599:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80059c:	29 c2                	sub    %eax,%edx
  80059e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005a1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a4:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005a8:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005ab:	89 d6                	mov    %edx,%esi
  8005ad:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005b0:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b2:	eb 10                	jmp    8005c4 <.L36+0x68>
					putch(padc, putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ba:	57                   	push   %edi
  8005bb:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005be:	83 ee 01             	sub    $0x1,%esi
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	85 f6                	test   %esi,%esi
  8005c6:	7f ec                	jg     8005b4 <.L36+0x58>
  8005c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ce:	85 d2                	test   %edx,%edx
  8005d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d5:	0f 49 c2             	cmovns %edx,%eax
  8005d8:	29 c2                	sub    %eax,%edx
  8005da:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005dd:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005e0:	eb 17                	jmp    8005f9 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e6:	75 30                	jne    800618 <.L36+0xbc>
					putch(ch, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	ff 75 0c             	pushl  0xc(%ebp)
  8005ee:	50                   	push   %eax
  8005ef:	ff 55 08             	call   *0x8(%ebp)
  8005f2:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f5:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005f9:	83 c6 01             	add    $0x1,%esi
  8005fc:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800600:	0f be c2             	movsbl %dl,%eax
  800603:	85 c0                	test   %eax,%eax
  800605:	74 58                	je     80065f <.L36+0x103>
  800607:	85 ff                	test   %edi,%edi
  800609:	78 d7                	js     8005e2 <.L36+0x86>
  80060b:	83 ef 01             	sub    $0x1,%edi
  80060e:	79 d2                	jns    8005e2 <.L36+0x86>
  800610:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800613:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800616:	eb 32                	jmp    80064a <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800618:	0f be d2             	movsbl %dl,%edx
  80061b:	83 ea 20             	sub    $0x20,%edx
  80061e:	83 fa 5e             	cmp    $0x5e,%edx
  800621:	76 c5                	jbe    8005e8 <.L36+0x8c>
					putch('?', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	ff 75 0c             	pushl  0xc(%ebp)
  800629:	6a 3f                	push   $0x3f
  80062b:	ff 55 08             	call   *0x8(%ebp)
  80062e:	83 c4 10             	add    $0x10,%esp
  800631:	eb c2                	jmp    8005f5 <.L36+0x99>
  800633:	89 7d 10             	mov    %edi,0x10(%ebp)
  800636:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800639:	eb be                	jmp    8005f9 <.L36+0x9d>
				putch(' ', putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	57                   	push   %edi
  80063f:	6a 20                	push   $0x20
  800641:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800644:	83 ee 01             	sub    $0x1,%esi
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	85 f6                	test   %esi,%esi
  80064c:	7f ed                	jg     80063b <.L36+0xdf>
  80064e:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800651:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800654:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
  80065a:	e9 44 fd ff ff       	jmp    8003a3 <vprintfmt+0x20>
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800662:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800665:	eb e3                	jmp    80064a <.L36+0xee>

00800667 <.L30>:
  800667:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80066a:	83 f9 01             	cmp    $0x1,%ecx
  80066d:	7e 42                	jle    8006b1 <.L30+0x4a>
		return va_arg(*ap, long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 50 04             	mov    0x4(%eax),%edx
  800675:	8b 00                	mov    (%eax),%eax
  800677:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 40 08             	lea    0x8(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800686:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068a:	79 5f                	jns    8006eb <.L30+0x84>
				putch('-', putdat);
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	ff 75 0c             	pushl  0xc(%ebp)
  800692:	6a 2d                	push   $0x2d
  800694:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800697:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80069d:	f7 da                	neg    %edx
  80069f:	83 d1 00             	adc    $0x0,%ecx
  8006a2:	f7 d9                	neg    %ecx
  8006a4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ac:	e9 b8 00 00 00       	jmp    800769 <.L34+0x22>
	else if (lflag)
  8006b1:	85 c9                	test   %ecx,%ecx
  8006b3:	75 1b                	jne    8006d0 <.L30+0x69>
		return va_arg(*ap, int);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 30                	mov    (%eax),%esi
  8006ba:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006bd:	89 f0                	mov    %esi,%eax
  8006bf:	c1 f8 1f             	sar    $0x1f,%eax
  8006c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 40 04             	lea    0x4(%eax),%eax
  8006cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ce:	eb b6                	jmp    800686 <.L30+0x1f>
		return va_arg(*ap, long);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 30                	mov    (%eax),%esi
  8006d5:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	c1 f8 1f             	sar    $0x1f,%eax
  8006dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e9:	eb 9b                	jmp    800686 <.L30+0x1f>
			num = getint(&ap, lflag);
  8006eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f6:	eb 71                	jmp    800769 <.L34+0x22>

008006f8 <.L37>:
  8006f8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8006fb:	83 f9 01             	cmp    $0x1,%ecx
  8006fe:	7e 15                	jle    800715 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8b 10                	mov    (%eax),%edx
  800705:	8b 48 04             	mov    0x4(%eax),%ecx
  800708:	8d 40 08             	lea    0x8(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800713:	eb 54                	jmp    800769 <.L34+0x22>
	else if (lflag)
  800715:	85 c9                	test   %ecx,%ecx
  800717:	75 17                	jne    800730 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8b 10                	mov    (%eax),%edx
  80071e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800723:	8d 40 04             	lea    0x4(%eax),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800729:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072e:	eb 39                	jmp    800769 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8b 10                	mov    (%eax),%edx
  800735:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073a:	8d 40 04             	lea    0x4(%eax),%eax
  80073d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800740:	b8 0a 00 00 00       	mov    $0xa,%eax
  800745:	eb 22                	jmp    800769 <.L34+0x22>

00800747 <.L34>:
  800747:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80074a:	83 f9 01             	cmp    $0x1,%ecx
  80074d:	7e 3b                	jle    80078a <.L34+0x43>
		return va_arg(*ap, long long);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8b 50 04             	mov    0x4(%eax),%edx
  800755:	8b 00                	mov    (%eax),%eax
  800757:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80075a:	8d 49 08             	lea    0x8(%ecx),%ecx
  80075d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800760:	89 d1                	mov    %edx,%ecx
  800762:	89 c2                	mov    %eax,%edx
			base = 8;
  800764:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800770:	56                   	push   %esi
  800771:	ff 75 e0             	pushl  -0x20(%ebp)
  800774:	50                   	push   %eax
  800775:	51                   	push   %ecx
  800776:	52                   	push   %edx
  800777:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077a:	8b 45 08             	mov    0x8(%ebp),%eax
  80077d:	e8 fd fa ff ff       	call   80027f <printnum>
			break;
  800782:	83 c4 20             	add    $0x20,%esp
  800785:	e9 19 fc ff ff       	jmp    8003a3 <vprintfmt+0x20>
	else if (lflag)
  80078a:	85 c9                	test   %ecx,%ecx
  80078c:	75 13                	jne    8007a1 <.L34+0x5a>
		return va_arg(*ap, int);
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8b 10                	mov    (%eax),%edx
  800793:	89 d0                	mov    %edx,%eax
  800795:	99                   	cltd   
  800796:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800799:	8d 49 04             	lea    0x4(%ecx),%ecx
  80079c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079f:	eb bf                	jmp    800760 <.L34+0x19>
		return va_arg(*ap, long);
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8b 10                	mov    (%eax),%edx
  8007a6:	89 d0                	mov    %edx,%eax
  8007a8:	99                   	cltd   
  8007a9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007ac:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007af:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b2:	eb ac                	jmp    800760 <.L34+0x19>

008007b4 <.L35>:
			putch('0', putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	6a 30                	push   $0x30
  8007bc:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007bf:	83 c4 08             	add    $0x8,%esp
  8007c2:	ff 75 0c             	pushl  0xc(%ebp)
  8007c5:	6a 78                	push   $0x78
  8007c7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8b 10                	mov    (%eax),%edx
  8007cf:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007d4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007d7:	8d 40 04             	lea    0x4(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007dd:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007e2:	eb 85                	jmp    800769 <.L34+0x22>

008007e4 <.L38>:
  8007e4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8007e7:	83 f9 01             	cmp    $0x1,%ecx
  8007ea:	7e 18                	jle    800804 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8b 10                	mov    (%eax),%edx
  8007f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f4:	8d 40 08             	lea    0x8(%eax),%eax
  8007f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007fa:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ff:	e9 65 ff ff ff       	jmp    800769 <.L34+0x22>
	else if (lflag)
  800804:	85 c9                	test   %ecx,%ecx
  800806:	75 1a                	jne    800822 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8b 10                	mov    (%eax),%edx
  80080d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800812:	8d 40 04             	lea    0x4(%eax),%eax
  800815:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800818:	b8 10 00 00 00       	mov    $0x10,%eax
  80081d:	e9 47 ff ff ff       	jmp    800769 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8b 10                	mov    (%eax),%edx
  800827:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082c:	8d 40 04             	lea    0x4(%eax),%eax
  80082f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800832:	b8 10 00 00 00       	mov    $0x10,%eax
  800837:	e9 2d ff ff ff       	jmp    800769 <.L34+0x22>

0080083c <.L24>:
			putch(ch, putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	ff 75 0c             	pushl  0xc(%ebp)
  800842:	6a 25                	push   $0x25
  800844:	ff 55 08             	call   *0x8(%ebp)
			break;
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	e9 54 fb ff ff       	jmp    8003a3 <vprintfmt+0x20>

0080084f <.L21>:
			putch('%', putdat);
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	ff 75 0c             	pushl  0xc(%ebp)
  800855:	6a 25                	push   $0x25
  800857:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	89 f7                	mov    %esi,%edi
  80085f:	eb 03                	jmp    800864 <.L21+0x15>
  800861:	83 ef 01             	sub    $0x1,%edi
  800864:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800868:	75 f7                	jne    800861 <.L21+0x12>
  80086a:	e9 34 fb ff ff       	jmp    8003a3 <vprintfmt+0x20>
}
  80086f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	83 ec 14             	sub    $0x14,%esp
  80087e:	e8 02 f8 ff ff       	call   800085 <__x86.get_pc_thunk.bx>
  800883:	81 c3 7d 17 00 00    	add    $0x177d,%ebx
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800892:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800896:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800899:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	74 2b                	je     8008cf <vsnprintf+0x58>
  8008a4:	85 d2                	test   %edx,%edx
  8008a6:	7e 27                	jle    8008cf <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a8:	ff 75 14             	pushl  0x14(%ebp)
  8008ab:	ff 75 10             	pushl  0x10(%ebp)
  8008ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b1:	50                   	push   %eax
  8008b2:	8d 83 49 e3 ff ff    	lea    -0x1cb7(%ebx),%eax
  8008b8:	50                   	push   %eax
  8008b9:	e8 c5 fa ff ff       	call   800383 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c7:	83 c4 10             	add    $0x10,%esp
}
  8008ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    
		return -E_INVAL;
  8008cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d4:	eb f4                	jmp    8008ca <vsnprintf+0x53>

008008d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008dc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008df:	50                   	push   %eax
  8008e0:	ff 75 10             	pushl  0x10(%ebp)
  8008e3:	ff 75 0c             	pushl  0xc(%ebp)
  8008e6:	ff 75 08             	pushl  0x8(%ebp)
  8008e9:	e8 89 ff ff ff       	call   800877 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <__x86.get_pc_thunk.cx>:
  8008f0:	8b 0c 24             	mov    (%esp),%ecx
  8008f3:	c3                   	ret    

008008f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ff:	eb 03                	jmp    800904 <strlen+0x10>
		n++;
  800901:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800904:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800908:	75 f7                	jne    800901 <strlen+0xd>
	return n;
}
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800912:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
  80091a:	eb 03                	jmp    80091f <strnlen+0x13>
		n++;
  80091c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091f:	39 d0                	cmp    %edx,%eax
  800921:	74 06                	je     800929 <strnlen+0x1d>
  800923:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800927:	75 f3                	jne    80091c <strnlen+0x10>
	return n;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800935:	89 c2                	mov    %eax,%edx
  800937:	83 c1 01             	add    $0x1,%ecx
  80093a:	83 c2 01             	add    $0x1,%edx
  80093d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800941:	88 5a ff             	mov    %bl,-0x1(%edx)
  800944:	84 db                	test   %bl,%bl
  800946:	75 ef                	jne    800937 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800948:	5b                   	pop    %ebx
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	53                   	push   %ebx
  80094f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800952:	53                   	push   %ebx
  800953:	e8 9c ff ff ff       	call   8008f4 <strlen>
  800958:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80095b:	ff 75 0c             	pushl  0xc(%ebp)
  80095e:	01 d8                	add    %ebx,%eax
  800960:	50                   	push   %eax
  800961:	e8 c5 ff ff ff       	call   80092b <strcpy>
	return dst;
}
  800966:	89 d8                	mov    %ebx,%eax
  800968:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    

0080096d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	56                   	push   %esi
  800971:	53                   	push   %ebx
  800972:	8b 75 08             	mov    0x8(%ebp),%esi
  800975:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800978:	89 f3                	mov    %esi,%ebx
  80097a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097d:	89 f2                	mov    %esi,%edx
  80097f:	eb 0f                	jmp    800990 <strncpy+0x23>
		*dst++ = *src;
  800981:	83 c2 01             	add    $0x1,%edx
  800984:	0f b6 01             	movzbl (%ecx),%eax
  800987:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80098a:	80 39 01             	cmpb   $0x1,(%ecx)
  80098d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800990:	39 da                	cmp    %ebx,%edx
  800992:	75 ed                	jne    800981 <strncpy+0x14>
	}
	return ret;
}
  800994:	89 f0                	mov    %esi,%eax
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	56                   	push   %esi
  80099e:	53                   	push   %ebx
  80099f:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009a8:	89 f0                	mov    %esi,%eax
  8009aa:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ae:	85 c9                	test   %ecx,%ecx
  8009b0:	75 0b                	jne    8009bd <strlcpy+0x23>
  8009b2:	eb 17                	jmp    8009cb <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b4:	83 c2 01             	add    $0x1,%edx
  8009b7:	83 c0 01             	add    $0x1,%eax
  8009ba:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009bd:	39 d8                	cmp    %ebx,%eax
  8009bf:	74 07                	je     8009c8 <strlcpy+0x2e>
  8009c1:	0f b6 0a             	movzbl (%edx),%ecx
  8009c4:	84 c9                	test   %cl,%cl
  8009c6:	75 ec                	jne    8009b4 <strlcpy+0x1a>
		*dst = '\0';
  8009c8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009cb:	29 f0                	sub    %esi,%eax
}
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5d                   	pop    %ebp
  8009d0:	c3                   	ret    

008009d1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009da:	eb 06                	jmp    8009e2 <strcmp+0x11>
		p++, q++;
  8009dc:	83 c1 01             	add    $0x1,%ecx
  8009df:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009e2:	0f b6 01             	movzbl (%ecx),%eax
  8009e5:	84 c0                	test   %al,%al
  8009e7:	74 04                	je     8009ed <strcmp+0x1c>
  8009e9:	3a 02                	cmp    (%edx),%al
  8009eb:	74 ef                	je     8009dc <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ed:	0f b6 c0             	movzbl %al,%eax
  8009f0:	0f b6 12             	movzbl (%edx),%edx
  8009f3:	29 d0                	sub    %edx,%eax
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a01:	89 c3                	mov    %eax,%ebx
  800a03:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a06:	eb 06                	jmp    800a0e <strncmp+0x17>
		n--, p++, q++;
  800a08:	83 c0 01             	add    $0x1,%eax
  800a0b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a0e:	39 d8                	cmp    %ebx,%eax
  800a10:	74 16                	je     800a28 <strncmp+0x31>
  800a12:	0f b6 08             	movzbl (%eax),%ecx
  800a15:	84 c9                	test   %cl,%cl
  800a17:	74 04                	je     800a1d <strncmp+0x26>
  800a19:	3a 0a                	cmp    (%edx),%cl
  800a1b:	74 eb                	je     800a08 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1d:	0f b6 00             	movzbl (%eax),%eax
  800a20:	0f b6 12             	movzbl (%edx),%edx
  800a23:	29 d0                	sub    %edx,%eax
}
  800a25:	5b                   	pop    %ebx
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    
		return 0;
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2d:	eb f6                	jmp    800a25 <strncmp+0x2e>

00800a2f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a39:	0f b6 10             	movzbl (%eax),%edx
  800a3c:	84 d2                	test   %dl,%dl
  800a3e:	74 09                	je     800a49 <strchr+0x1a>
		if (*s == c)
  800a40:	38 ca                	cmp    %cl,%dl
  800a42:	74 0a                	je     800a4e <strchr+0x1f>
	for (; *s; s++)
  800a44:	83 c0 01             	add    $0x1,%eax
  800a47:	eb f0                	jmp    800a39 <strchr+0xa>
			return (char *) s;
	return 0;
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a5a:	eb 03                	jmp    800a5f <strfind+0xf>
  800a5c:	83 c0 01             	add    $0x1,%eax
  800a5f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a62:	38 ca                	cmp    %cl,%dl
  800a64:	74 04                	je     800a6a <strfind+0x1a>
  800a66:	84 d2                	test   %dl,%dl
  800a68:	75 f2                	jne    800a5c <strfind+0xc>
			break;
	return (char *) s;
}
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a78:	85 c9                	test   %ecx,%ecx
  800a7a:	74 13                	je     800a8f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a82:	75 05                	jne    800a89 <memset+0x1d>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	74 0d                	je     800a96 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8c:	fc                   	cld    
  800a8d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8f:	89 f8                	mov    %edi,%eax
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    
		c &= 0xFF;
  800a96:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9a:	89 d3                	mov    %edx,%ebx
  800a9c:	c1 e3 08             	shl    $0x8,%ebx
  800a9f:	89 d0                	mov    %edx,%eax
  800aa1:	c1 e0 18             	shl    $0x18,%eax
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	c1 e6 10             	shl    $0x10,%esi
  800aa9:	09 f0                	or     %esi,%eax
  800aab:	09 c2                	or     %eax,%edx
  800aad:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800aaf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	fc                   	cld    
  800ab5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab7:	eb d6                	jmp    800a8f <memset+0x23>

00800ab9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	57                   	push   %edi
  800abd:	56                   	push   %esi
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac7:	39 c6                	cmp    %eax,%esi
  800ac9:	73 35                	jae    800b00 <memmove+0x47>
  800acb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ace:	39 c2                	cmp    %eax,%edx
  800ad0:	76 2e                	jbe    800b00 <memmove+0x47>
		s += n;
		d += n;
  800ad2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad5:	89 d6                	mov    %edx,%esi
  800ad7:	09 fe                	or     %edi,%esi
  800ad9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800adf:	74 0c                	je     800aed <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae1:	83 ef 01             	sub    $0x1,%edi
  800ae4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae7:	fd                   	std    
  800ae8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aea:	fc                   	cld    
  800aeb:	eb 21                	jmp    800b0e <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aed:	f6 c1 03             	test   $0x3,%cl
  800af0:	75 ef                	jne    800ae1 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af2:	83 ef 04             	sub    $0x4,%edi
  800af5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800afb:	fd                   	std    
  800afc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afe:	eb ea                	jmp    800aea <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b00:	89 f2                	mov    %esi,%edx
  800b02:	09 c2                	or     %eax,%edx
  800b04:	f6 c2 03             	test   $0x3,%dl
  800b07:	74 09                	je     800b12 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b09:	89 c7                	mov    %eax,%edi
  800b0b:	fc                   	cld    
  800b0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b12:	f6 c1 03             	test   $0x3,%cl
  800b15:	75 f2                	jne    800b09 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b17:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b1a:	89 c7                	mov    %eax,%edi
  800b1c:	fc                   	cld    
  800b1d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1f:	eb ed                	jmp    800b0e <memmove+0x55>

00800b21 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b24:	ff 75 10             	pushl  0x10(%ebp)
  800b27:	ff 75 0c             	pushl  0xc(%ebp)
  800b2a:	ff 75 08             	pushl  0x8(%ebp)
  800b2d:	e8 87 ff ff ff       	call   800ab9 <memmove>
}
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3f:	89 c6                	mov    %eax,%esi
  800b41:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b44:	39 f0                	cmp    %esi,%eax
  800b46:	74 1c                	je     800b64 <memcmp+0x30>
		if (*s1 != *s2)
  800b48:	0f b6 08             	movzbl (%eax),%ecx
  800b4b:	0f b6 1a             	movzbl (%edx),%ebx
  800b4e:	38 d9                	cmp    %bl,%cl
  800b50:	75 08                	jne    800b5a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	83 c2 01             	add    $0x1,%edx
  800b58:	eb ea                	jmp    800b44 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b5a:	0f b6 c1             	movzbl %cl,%eax
  800b5d:	0f b6 db             	movzbl %bl,%ebx
  800b60:	29 d8                	sub    %ebx,%eax
  800b62:	eb 05                	jmp    800b69 <memcmp+0x35>
	}

	return 0;
  800b64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b76:	89 c2                	mov    %eax,%edx
  800b78:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7b:	39 d0                	cmp    %edx,%eax
  800b7d:	73 09                	jae    800b88 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7f:	38 08                	cmp    %cl,(%eax)
  800b81:	74 05                	je     800b88 <memfind+0x1b>
	for (; s < ends; s++)
  800b83:	83 c0 01             	add    $0x1,%eax
  800b86:	eb f3                	jmp    800b7b <memfind+0xe>
			break;
	return (void *) s;
}
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	57                   	push   %edi
  800b8e:	56                   	push   %esi
  800b8f:	53                   	push   %ebx
  800b90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b96:	eb 03                	jmp    800b9b <strtol+0x11>
		s++;
  800b98:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b9b:	0f b6 01             	movzbl (%ecx),%eax
  800b9e:	3c 20                	cmp    $0x20,%al
  800ba0:	74 f6                	je     800b98 <strtol+0xe>
  800ba2:	3c 09                	cmp    $0x9,%al
  800ba4:	74 f2                	je     800b98 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ba6:	3c 2b                	cmp    $0x2b,%al
  800ba8:	74 2e                	je     800bd8 <strtol+0x4e>
	int neg = 0;
  800baa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800baf:	3c 2d                	cmp    $0x2d,%al
  800bb1:	74 2f                	je     800be2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bb9:	75 05                	jne    800bc0 <strtol+0x36>
  800bbb:	80 39 30             	cmpb   $0x30,(%ecx)
  800bbe:	74 2c                	je     800bec <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc0:	85 db                	test   %ebx,%ebx
  800bc2:	75 0a                	jne    800bce <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc4:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bc9:	80 39 30             	cmpb   $0x30,(%ecx)
  800bcc:	74 28                	je     800bf6 <strtol+0x6c>
		base = 10;
  800bce:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd6:	eb 50                	jmp    800c28 <strtol+0x9e>
		s++;
  800bd8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bdb:	bf 00 00 00 00       	mov    $0x0,%edi
  800be0:	eb d1                	jmp    800bb3 <strtol+0x29>
		s++, neg = 1;
  800be2:	83 c1 01             	add    $0x1,%ecx
  800be5:	bf 01 00 00 00       	mov    $0x1,%edi
  800bea:	eb c7                	jmp    800bb3 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bec:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf0:	74 0e                	je     800c00 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bf2:	85 db                	test   %ebx,%ebx
  800bf4:	75 d8                	jne    800bce <strtol+0x44>
		s++, base = 8;
  800bf6:	83 c1 01             	add    $0x1,%ecx
  800bf9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bfe:	eb ce                	jmp    800bce <strtol+0x44>
		s += 2, base = 16;
  800c00:	83 c1 02             	add    $0x2,%ecx
  800c03:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c08:	eb c4                	jmp    800bce <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c0a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c0d:	89 f3                	mov    %esi,%ebx
  800c0f:	80 fb 19             	cmp    $0x19,%bl
  800c12:	77 29                	ja     800c3d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c14:	0f be d2             	movsbl %dl,%edx
  800c17:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c1a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c1d:	7d 30                	jge    800c4f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c1f:	83 c1 01             	add    $0x1,%ecx
  800c22:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c26:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c28:	0f b6 11             	movzbl (%ecx),%edx
  800c2b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c2e:	89 f3                	mov    %esi,%ebx
  800c30:	80 fb 09             	cmp    $0x9,%bl
  800c33:	77 d5                	ja     800c0a <strtol+0x80>
			dig = *s - '0';
  800c35:	0f be d2             	movsbl %dl,%edx
  800c38:	83 ea 30             	sub    $0x30,%edx
  800c3b:	eb dd                	jmp    800c1a <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c3d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c40:	89 f3                	mov    %esi,%ebx
  800c42:	80 fb 19             	cmp    $0x19,%bl
  800c45:	77 08                	ja     800c4f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c47:	0f be d2             	movsbl %dl,%edx
  800c4a:	83 ea 37             	sub    $0x37,%edx
  800c4d:	eb cb                	jmp    800c1a <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c53:	74 05                	je     800c5a <strtol+0xd0>
		*endptr = (char *) s;
  800c55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c58:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c5a:	89 c2                	mov    %eax,%edx
  800c5c:	f7 da                	neg    %edx
  800c5e:	85 ff                	test   %edi,%edi
  800c60:	0f 45 c2             	cmovne %edx,%eax
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    
  800c68:	66 90                	xchg   %ax,%ax
  800c6a:	66 90                	xchg   %ax,%ax
  800c6c:	66 90                	xchg   %ax,%ax
  800c6e:	66 90                	xchg   %ax,%ax

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
