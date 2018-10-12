
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 d7 00 00 00       	call   800108 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 c5 00 00 00       	call   800104 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	int i;

	cprintf("Making sure bss works right...\n");
  800045:	8d 83 6c ef ff ff    	lea    -0x1094(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 2b 02 00 00       	call   80027c <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800054:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  800059:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  80005f:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800063:	75 73                	jne    8000d8 <umain+0xa5>
	for (i = 0; i < ARRAYSIZE; i++)
  800065:	83 c0 01             	add    $0x1,%eax
  800068:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006d:	75 f0                	jne    80005f <umain+0x2c>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80006f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800074:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  80007a:	89 04 82             	mov    %eax,(%edx,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 f3                	jne    80007a <umain+0x47>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80008c:	c7 c2 40 20 80 00    	mov    $0x802040,%edx
  800092:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  800095:	75 57                	jne    8000ee <umain+0xbb>
	for (i = 0; i < ARRAYSIZE; i++)
  800097:	83 c0 01             	add    $0x1,%eax
  80009a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80009f:	75 f1                	jne    800092 <umain+0x5f>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000a1:	83 ec 0c             	sub    $0xc,%esp
  8000a4:	8d 83 b4 ef ff ff    	lea    -0x104c(%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	e8 cc 01 00 00       	call   80027c <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000b0:	c7 c0 40 20 80 00    	mov    $0x802040,%eax
  8000b6:	c7 80 00 10 40 00 00 	movl   $0x0,0x401000(%eax)
  8000bd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c0:	83 c4 0c             	add    $0xc,%esp
  8000c3:	8d 83 13 f0 ff ff    	lea    -0xfed(%ebx),%eax
  8000c9:	50                   	push   %eax
  8000ca:	6a 1a                	push   $0x1a
  8000cc:	8d 83 04 f0 ff ff    	lea    -0xffc(%ebx),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 98 00 00 00       	call   800170 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000d8:	50                   	push   %eax
  8000d9:	8d 83 e7 ef ff ff    	lea    -0x1019(%ebx),%eax
  8000df:	50                   	push   %eax
  8000e0:	6a 11                	push   $0x11
  8000e2:	8d 83 04 f0 ff ff    	lea    -0xffc(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 82 00 00 00       	call   800170 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ee:	50                   	push   %eax
  8000ef:	8d 83 8c ef ff ff    	lea    -0x1074(%ebx),%eax
  8000f5:	50                   	push   %eax
  8000f6:	6a 16                	push   $0x16
  8000f8:	8d 83 04 f0 ff ff    	lea    -0xffc(%ebx),%eax
  8000fe:	50                   	push   %eax
  8000ff:	e8 6c 00 00 00       	call   800170 <_panic>

00800104 <__x86.get_pc_thunk.bx>:
  800104:	8b 1c 24             	mov    (%esp),%ebx
  800107:	c3                   	ret    

00800108 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	53                   	push   %ebx
  80010c:	83 ec 04             	sub    $0x4,%esp
  80010f:	e8 f0 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800114:	81 c3 ec 1e 00 00    	add    $0x1eec,%ebx
  80011a:	8b 45 08             	mov    0x8(%ebp),%eax
  80011d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800120:	c7 c1 40 20 c0 00    	mov    $0xc02040,%ecx
  800126:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012c:	85 c0                	test   %eax,%eax
  80012e:	7e 08                	jle    800138 <libmain+0x30>
		binaryname = argv[0];
  800130:	8b 0a                	mov    (%edx),%ecx
  800132:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800138:	83 ec 08             	sub    $0x8,%esp
  80013b:	52                   	push   %edx
  80013c:	50                   	push   %eax
  80013d:	e8 f1 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800142:	e8 08 00 00 00       	call   80014f <exit>
}
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	53                   	push   %ebx
  800153:	83 ec 10             	sub    $0x10,%esp
  800156:	e8 a9 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  80015b:	81 c3 a5 1e 00 00    	add    $0x1ea5,%ebx
	sys_env_destroy(0);
  800161:	6a 00                	push   $0x0
  800163:	e8 4e 0b 00 00       	call   800cb6 <sys_env_destroy>
}
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	e8 86 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  80017e:	81 c3 82 1e 00 00    	add    $0x1e82,%ebx
	va_list ap;

	va_start(ap, fmt);
  800184:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800187:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80018d:	8b 38                	mov    (%eax),%edi
  80018f:	e8 77 0b 00 00       	call   800d0b <sys_getenvid>
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	ff 75 0c             	pushl  0xc(%ebp)
  80019a:	ff 75 08             	pushl  0x8(%ebp)
  80019d:	57                   	push   %edi
  80019e:	50                   	push   %eax
  80019f:	8d 83 34 f0 ff ff    	lea    -0xfcc(%ebx),%eax
  8001a5:	50                   	push   %eax
  8001a6:	e8 d1 00 00 00       	call   80027c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ab:	83 c4 18             	add    $0x18,%esp
  8001ae:	56                   	push   %esi
  8001af:	ff 75 10             	pushl  0x10(%ebp)
  8001b2:	e8 63 00 00 00       	call   80021a <vcprintf>
	cprintf("\n");
  8001b7:	8d 83 02 f0 ff ff    	lea    -0xffe(%ebx),%eax
  8001bd:	89 04 24             	mov    %eax,(%esp)
  8001c0:	e8 b7 00 00 00       	call   80027c <cprintf>
  8001c5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c8:	cc                   	int3   
  8001c9:	eb fd                	jmp    8001c8 <_panic+0x58>

008001cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	56                   	push   %esi
  8001cf:	53                   	push   %ebx
  8001d0:	e8 2f ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8001d5:	81 c3 2b 1e 00 00    	add    $0x1e2b,%ebx
  8001db:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001de:	8b 16                	mov    (%esi),%edx
  8001e0:	8d 42 01             	lea    0x1(%edx),%eax
  8001e3:	89 06                	mov    %eax,(%esi)
  8001e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e8:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f1:	74 0b                	je     8001fe <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f3:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	68 ff 00 00 00       	push   $0xff
  800206:	8d 46 08             	lea    0x8(%esi),%eax
  800209:	50                   	push   %eax
  80020a:	e8 6a 0a 00 00       	call   800c79 <sys_cputs>
		b->idx = 0;
  80020f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	eb d9                	jmp    8001f3 <putch+0x28>

0080021a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	53                   	push   %ebx
  80021e:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800224:	e8 db fe ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800229:	81 c3 d7 1d 00 00    	add    $0x1dd7,%ebx
	struct printbuf b;

	b.idx = 0;
  80022f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800236:	00 00 00 
	b.cnt = 0;
  800239:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800240:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800243:	ff 75 0c             	pushl  0xc(%ebp)
  800246:	ff 75 08             	pushl  0x8(%ebp)
  800249:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024f:	50                   	push   %eax
  800250:	8d 83 cb e1 ff ff    	lea    -0x1e35(%ebx),%eax
  800256:	50                   	push   %eax
  800257:	e8 38 01 00 00       	call   800394 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025c:	83 c4 08             	add    $0x8,%esp
  80025f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800265:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026b:	50                   	push   %eax
  80026c:	e8 08 0a 00 00       	call   800c79 <sys_cputs>

	return b.cnt;
}
  800271:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800282:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800285:	50                   	push   %eax
  800286:	ff 75 08             	pushl  0x8(%ebp)
  800289:	e8 8c ff ff ff       	call   80021a <vcprintf>
	va_end(ap);

	return cnt;
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 2c             	sub    $0x2c,%esp
  800299:	e8 63 06 00 00       	call   800901 <__x86.get_pc_thunk.cx>
  80029e:	81 c1 62 1d 00 00    	add    $0x1d62,%ecx
  8002a4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002a7:	89 c7                	mov    %eax,%edi
  8002a9:	89 d6                	mov    %edx,%esi
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c2:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002c5:	39 d3                	cmp    %edx,%ebx
  8002c7:	72 09                	jb     8002d2 <printnum+0x42>
  8002c9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002cc:	0f 87 83 00 00 00    	ja     800355 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d2:	83 ec 0c             	sub    $0xc,%esp
  8002d5:	ff 75 18             	pushl  0x18(%ebp)
  8002d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002db:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002de:	53                   	push   %ebx
  8002df:	ff 75 10             	pushl  0x10(%ebp)
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ee:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002f4:	e8 37 0a 00 00       	call   800d30 <__udivdi3>
  8002f9:	83 c4 18             	add    $0x18,%esp
  8002fc:	52                   	push   %edx
  8002fd:	50                   	push   %eax
  8002fe:	89 f2                	mov    %esi,%edx
  800300:	89 f8                	mov    %edi,%eax
  800302:	e8 89 ff ff ff       	call   800290 <printnum>
  800307:	83 c4 20             	add    $0x20,%esp
  80030a:	eb 13                	jmp    80031f <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	56                   	push   %esi
  800310:	ff 75 18             	pushl  0x18(%ebp)
  800313:	ff d7                	call   *%edi
  800315:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f ed                	jg     80030c <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 dc             	pushl  -0x24(%ebp)
  800329:	ff 75 d8             	pushl  -0x28(%ebp)
  80032c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80032f:	ff 75 d0             	pushl  -0x30(%ebp)
  800332:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800335:	89 f3                	mov    %esi,%ebx
  800337:	e8 14 0b 00 00       	call   800e50 <__umoddi3>
  80033c:	83 c4 14             	add    $0x14,%esp
  80033f:	0f be 84 06 58 f0 ff 	movsbl -0xfa8(%esi,%eax,1),%eax
  800346:	ff 
  800347:	50                   	push   %eax
  800348:	ff d7                	call   *%edi
}
  80034a:	83 c4 10             	add    $0x10,%esp
  80034d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    
  800355:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800358:	eb be                	jmp    800318 <printnum+0x88>

0080035a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800360:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800364:	8b 10                	mov    (%eax),%edx
  800366:	3b 50 04             	cmp    0x4(%eax),%edx
  800369:	73 0a                	jae    800375 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036e:	89 08                	mov    %ecx,(%eax)
  800370:	8b 45 08             	mov    0x8(%ebp),%eax
  800373:	88 02                	mov    %al,(%edx)
}
  800375:	5d                   	pop    %ebp
  800376:	c3                   	ret    

00800377 <printfmt>:
{
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800380:	50                   	push   %eax
  800381:	ff 75 10             	pushl  0x10(%ebp)
  800384:	ff 75 0c             	pushl  0xc(%ebp)
  800387:	ff 75 08             	pushl  0x8(%ebp)
  80038a:	e8 05 00 00 00       	call   800394 <vprintfmt>
}
  80038f:	83 c4 10             	add    $0x10,%esp
  800392:	c9                   	leave  
  800393:	c3                   	ret    

00800394 <vprintfmt>:
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
  80039a:	83 ec 2c             	sub    $0x2c,%esp
  80039d:	e8 62 fd ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8003a2:	81 c3 5e 1c 00 00    	add    $0x1c5e,%ebx
  8003a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003ab:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003b2:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b4:	8d 77 01             	lea    0x1(%edi),%esi
  8003b7:	0f b6 07             	movzbl (%edi),%eax
  8003ba:	83 f8 25             	cmp    $0x25,%eax
  8003bd:	74 1c                	je     8003db <vprintfmt+0x47>
			if (ch == '\0')
  8003bf:	85 c0                	test   %eax,%eax
  8003c1:	0f 84 b9 04 00 00    	je     800880 <.L21+0x20>
			putch(ch, putdat);
  8003c7:	83 ec 08             	sub    $0x8,%esp
  8003ca:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003cd:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003d0:	50                   	push   %eax
  8003d1:	ff 55 08             	call   *0x8(%ebp)
  8003d4:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d7:	89 f7                	mov    %esi,%edi
  8003d9:	eb d9                	jmp    8003b4 <vprintfmt+0x20>
		padc = ' ';
  8003db:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003df:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003e6:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003ed:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8d 7e 01             	lea    0x1(%esi),%edi
  8003ff:	0f b6 16             	movzbl (%esi),%edx
  800402:	8d 42 dd             	lea    -0x23(%edx),%eax
  800405:	3c 55                	cmp    $0x55,%al
  800407:	0f 87 53 04 00 00    	ja     800860 <.L21>
  80040d:	0f b6 c0             	movzbl %al,%eax
  800410:	89 d9                	mov    %ebx,%ecx
  800412:	03 8c 83 e8 f0 ff ff 	add    -0xf18(%ebx,%eax,4),%ecx
  800419:	ff e1                	jmp    *%ecx

0080041b <.L73>:
  80041b:	89 fe                	mov    %edi,%esi
			padc = '-';
  80041d:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800421:	eb d9                	jmp    8003fc <vprintfmt+0x68>

00800423 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800423:	89 fe                	mov    %edi,%esi
			padc = '0';
  800425:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800429:	eb d1                	jmp    8003fc <vprintfmt+0x68>

0080042b <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	0f b6 d2             	movzbl %dl,%edx
  80042e:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800430:	b8 00 00 00 00       	mov    $0x0,%eax
  800435:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800438:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80043f:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800442:	8d 7a d0             	lea    -0x30(%edx),%edi
  800445:	83 ff 09             	cmp    $0x9,%edi
  800448:	0f 87 94 00 00 00    	ja     8004e2 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  80044e:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800451:	eb e5                	jmp    800438 <.L28+0xd>

00800453 <.L25>:
			precision = va_arg(ap, int);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 40 04             	lea    0x4(%eax),%eax
  800461:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800464:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800466:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046a:	79 90                	jns    8003fc <vprintfmt+0x68>
				width = precision, precision = -1;
  80046c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80046f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800472:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800479:	eb 81                	jmp    8003fc <vprintfmt+0x68>

0080047b <.L26>:
  80047b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047e:	85 c0                	test   %eax,%eax
  800480:	ba 00 00 00 00       	mov    $0x0,%edx
  800485:	0f 49 d0             	cmovns %eax,%edx
  800488:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	89 fe                	mov    %edi,%esi
  80048d:	e9 6a ff ff ff       	jmp    8003fc <vprintfmt+0x68>

00800492 <.L22>:
  800492:	89 fe                	mov    %edi,%esi
			altflag = 1;
  800494:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049b:	e9 5c ff ff ff       	jmp    8003fc <vprintfmt+0x68>

008004a0 <.L33>:
  8004a0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004a3:	83 f9 01             	cmp    $0x1,%ecx
  8004a6:	7e 16                	jle    8004be <.L33+0x1e>
		return va_arg(*ap, long long);
  8004a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004b0:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004b9:	e9 f6 fe ff ff       	jmp    8003b4 <vprintfmt+0x20>
	else if (lflag)
  8004be:	85 c9                	test   %ecx,%ecx
  8004c0:	75 10                	jne    8004d2 <.L33+0x32>
		return va_arg(*ap, int);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8b 00                	mov    (%eax),%eax
  8004c7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004ca:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d0:	eb e4                	jmp    8004b6 <.L33+0x16>
		return va_arg(*ap, long);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8b 00                	mov    (%eax),%eax
  8004d7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004da:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e0:	eb d4                	jmp    8004b6 <.L33+0x16>
  8004e2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004e5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004e8:	e9 79 ff ff ff       	jmp    800466 <.L25+0x13>

008004ed <.L32>:
			lflag++;
  8004ed:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8004f3:	e9 04 ff ff ff       	jmp    8003fc <vprintfmt+0x68>

008004f8 <.L29>:
			putch(va_arg(ap, int), putdat);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 70 04             	lea    0x4(%eax),%esi
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	ff 30                	pushl  (%eax)
  800506:	ff 55 08             	call   *0x8(%ebp)
			break;
  800509:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80050c:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  80050f:	e9 a0 fe ff ff       	jmp    8003b4 <vprintfmt+0x20>

00800514 <.L31>:
			err = va_arg(ap, int);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 70 04             	lea    0x4(%eax),%esi
  80051a:	8b 00                	mov    (%eax),%eax
  80051c:	99                   	cltd   
  80051d:	31 d0                	xor    %edx,%eax
  80051f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800521:	83 f8 06             	cmp    $0x6,%eax
  800524:	7f 29                	jg     80054f <.L31+0x3b>
  800526:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  80052d:	85 d2                	test   %edx,%edx
  80052f:	74 1e                	je     80054f <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800531:	52                   	push   %edx
  800532:	8d 83 79 f0 ff ff    	lea    -0xf87(%ebx),%eax
  800538:	50                   	push   %eax
  800539:	ff 75 0c             	pushl  0xc(%ebp)
  80053c:	ff 75 08             	pushl  0x8(%ebp)
  80053f:	e8 33 fe ff ff       	call   800377 <printfmt>
  800544:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800547:	89 75 14             	mov    %esi,0x14(%ebp)
  80054a:	e9 65 fe ff ff       	jmp    8003b4 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  80054f:	50                   	push   %eax
  800550:	8d 83 70 f0 ff ff    	lea    -0xf90(%ebx),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 0c             	pushl  0xc(%ebp)
  80055a:	ff 75 08             	pushl  0x8(%ebp)
  80055d:	e8 15 fe ff ff       	call   800377 <printfmt>
  800562:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800565:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800568:	e9 47 fe ff ff       	jmp    8003b4 <vprintfmt+0x20>

0080056d <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	83 c0 04             	add    $0x4,%eax
  800573:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80057b:	85 f6                	test   %esi,%esi
  80057d:	8d 83 69 f0 ff ff    	lea    -0xf97(%ebx),%eax
  800583:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800586:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058a:	0f 8e b4 00 00 00    	jle    800644 <.L36+0xd7>
  800590:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800594:	75 08                	jne    80059e <.L36+0x31>
  800596:	89 7d 10             	mov    %edi,0x10(%ebp)
  800599:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80059c:	eb 6c                	jmp    80060a <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	ff 75 cc             	pushl  -0x34(%ebp)
  8005a4:	56                   	push   %esi
  8005a5:	e8 73 03 00 00       	call   80091d <strnlen>
  8005aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ad:	29 c2                	sub    %eax,%edx
  8005af:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005b5:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005b9:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005bc:	89 d6                	mov    %edx,%esi
  8005be:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005c1:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	eb 10                	jmp    8005d5 <.L36+0x68>
					putch(padc, putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	ff 75 0c             	pushl  0xc(%ebp)
  8005cb:	57                   	push   %edi
  8005cc:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cf:	83 ee 01             	sub    $0x1,%esi
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	85 f6                	test   %esi,%esi
  8005d7:	7f ec                	jg     8005c5 <.L36+0x58>
  8005d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005df:	85 d2                	test   %edx,%edx
  8005e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e6:	0f 49 c2             	cmovns %edx,%eax
  8005e9:	29 c2                	sub    %eax,%edx
  8005eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ee:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005f1:	eb 17                	jmp    80060a <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8005f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f7:	75 30                	jne    800629 <.L36+0xbc>
					putch(ch, putdat);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	ff 75 0c             	pushl  0xc(%ebp)
  8005ff:	50                   	push   %eax
  800600:	ff 55 08             	call   *0x8(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800606:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80060a:	83 c6 01             	add    $0x1,%esi
  80060d:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800611:	0f be c2             	movsbl %dl,%eax
  800614:	85 c0                	test   %eax,%eax
  800616:	74 58                	je     800670 <.L36+0x103>
  800618:	85 ff                	test   %edi,%edi
  80061a:	78 d7                	js     8005f3 <.L36+0x86>
  80061c:	83 ef 01             	sub    $0x1,%edi
  80061f:	79 d2                	jns    8005f3 <.L36+0x86>
  800621:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800624:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800627:	eb 32                	jmp    80065b <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800629:	0f be d2             	movsbl %dl,%edx
  80062c:	83 ea 20             	sub    $0x20,%edx
  80062f:	83 fa 5e             	cmp    $0x5e,%edx
  800632:	76 c5                	jbe    8005f9 <.L36+0x8c>
					putch('?', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	ff 75 0c             	pushl  0xc(%ebp)
  80063a:	6a 3f                	push   $0x3f
  80063c:	ff 55 08             	call   *0x8(%ebp)
  80063f:	83 c4 10             	add    $0x10,%esp
  800642:	eb c2                	jmp    800606 <.L36+0x99>
  800644:	89 7d 10             	mov    %edi,0x10(%ebp)
  800647:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80064a:	eb be                	jmp    80060a <.L36+0x9d>
				putch(' ', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	57                   	push   %edi
  800650:	6a 20                	push   $0x20
  800652:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800655:	83 ee 01             	sub    $0x1,%esi
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	85 f6                	test   %esi,%esi
  80065d:	7f ed                	jg     80064c <.L36+0xdf>
  80065f:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800662:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800665:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
  80066b:	e9 44 fd ff ff       	jmp    8003b4 <vprintfmt+0x20>
  800670:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800673:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800676:	eb e3                	jmp    80065b <.L36+0xee>

00800678 <.L30>:
  800678:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80067b:	83 f9 01             	cmp    $0x1,%ecx
  80067e:	7e 42                	jle    8006c2 <.L30+0x4a>
		return va_arg(*ap, long long);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8b 50 04             	mov    0x4(%eax),%edx
  800686:	8b 00                	mov    (%eax),%eax
  800688:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 40 08             	lea    0x8(%eax),%eax
  800694:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800697:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069b:	79 5f                	jns    8006fc <.L30+0x84>
				putch('-', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	ff 75 0c             	pushl  0xc(%ebp)
  8006a3:	6a 2d                	push   $0x2d
  8006a5:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ae:	f7 da                	neg    %edx
  8006b0:	83 d1 00             	adc    $0x0,%ecx
  8006b3:	f7 d9                	neg    %ecx
  8006b5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bd:	e9 b8 00 00 00       	jmp    80077a <.L34+0x22>
	else if (lflag)
  8006c2:	85 c9                	test   %ecx,%ecx
  8006c4:	75 1b                	jne    8006e1 <.L30+0x69>
		return va_arg(*ap, int);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 30                	mov    (%eax),%esi
  8006cb:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006ce:	89 f0                	mov    %esi,%eax
  8006d0:	c1 f8 1f             	sar    $0x1f,%eax
  8006d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 40 04             	lea    0x4(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8006df:	eb b6                	jmp    800697 <.L30+0x1f>
		return va_arg(*ap, long);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8b 30                	mov    (%eax),%esi
  8006e6:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006e9:	89 f0                	mov    %esi,%eax
  8006eb:	c1 f8 1f             	sar    $0x1f,%eax
  8006ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8d 40 04             	lea    0x4(%eax),%eax
  8006f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8006fa:	eb 9b                	jmp    800697 <.L30+0x1f>
			num = getint(&ap, lflag);
  8006fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800702:	b8 0a 00 00 00       	mov    $0xa,%eax
  800707:	eb 71                	jmp    80077a <.L34+0x22>

00800709 <.L37>:
  800709:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80070c:	83 f9 01             	cmp    $0x1,%ecx
  80070f:	7e 15                	jle    800726 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	8b 48 04             	mov    0x4(%eax),%ecx
  800719:	8d 40 08             	lea    0x8(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80071f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800724:	eb 54                	jmp    80077a <.L34+0x22>
	else if (lflag)
  800726:	85 c9                	test   %ecx,%ecx
  800728:	75 17                	jne    800741 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8b 10                	mov    (%eax),%edx
  80072f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800734:	8d 40 04             	lea    0x4(%eax),%eax
  800737:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073f:	eb 39                	jmp    80077a <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 10                	mov    (%eax),%edx
  800746:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074b:	8d 40 04             	lea    0x4(%eax),%eax
  80074e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800751:	b8 0a 00 00 00       	mov    $0xa,%eax
  800756:	eb 22                	jmp    80077a <.L34+0x22>

00800758 <.L34>:
  800758:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80075b:	83 f9 01             	cmp    $0x1,%ecx
  80075e:	7e 3b                	jle    80079b <.L34+0x43>
		return va_arg(*ap, long long);
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8b 50 04             	mov    0x4(%eax),%edx
  800766:	8b 00                	mov    (%eax),%eax
  800768:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80076b:	8d 49 08             	lea    0x8(%ecx),%ecx
  80076e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800771:	89 d1                	mov    %edx,%ecx
  800773:	89 c2                	mov    %eax,%edx
			base = 8;
  800775:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80077a:	83 ec 0c             	sub    $0xc,%esp
  80077d:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800781:	56                   	push   %esi
  800782:	ff 75 e0             	pushl  -0x20(%ebp)
  800785:	50                   	push   %eax
  800786:	51                   	push   %ecx
  800787:	52                   	push   %edx
  800788:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	e8 fd fa ff ff       	call   800290 <printnum>
			break;
  800793:	83 c4 20             	add    $0x20,%esp
  800796:	e9 19 fc ff ff       	jmp    8003b4 <vprintfmt+0x20>
	else if (lflag)
  80079b:	85 c9                	test   %ecx,%ecx
  80079d:	75 13                	jne    8007b2 <.L34+0x5a>
		return va_arg(*ap, int);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8b 10                	mov    (%eax),%edx
  8007a4:	89 d0                	mov    %edx,%eax
  8007a6:	99                   	cltd   
  8007a7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007aa:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b0:	eb bf                	jmp    800771 <.L34+0x19>
		return va_arg(*ap, long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	89 d0                	mov    %edx,%eax
  8007b9:	99                   	cltd   
  8007ba:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007bd:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007c0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007c3:	eb ac                	jmp    800771 <.L34+0x19>

008007c5 <.L35>:
			putch('0', putdat);
  8007c5:	83 ec 08             	sub    $0x8,%esp
  8007c8:	ff 75 0c             	pushl  0xc(%ebp)
  8007cb:	6a 30                	push   $0x30
  8007cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d0:	83 c4 08             	add    $0x8,%esp
  8007d3:	ff 75 0c             	pushl  0xc(%ebp)
  8007d6:	6a 78                	push   $0x78
  8007d8:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8b 10                	mov    (%eax),%edx
  8007e0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007e5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007e8:	8d 40 04             	lea    0x4(%eax),%eax
  8007eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ee:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f3:	eb 85                	jmp    80077a <.L34+0x22>

008007f5 <.L38>:
  8007f5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8007f8:	83 f9 01             	cmp    $0x1,%ecx
  8007fb:	7e 18                	jle    800815 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8b 10                	mov    (%eax),%edx
  800802:	8b 48 04             	mov    0x4(%eax),%ecx
  800805:	8d 40 08             	lea    0x8(%eax),%eax
  800808:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080b:	b8 10 00 00 00       	mov    $0x10,%eax
  800810:	e9 65 ff ff ff       	jmp    80077a <.L34+0x22>
	else if (lflag)
  800815:	85 c9                	test   %ecx,%ecx
  800817:	75 1a                	jne    800833 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8b 10                	mov    (%eax),%edx
  80081e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800823:	8d 40 04             	lea    0x4(%eax),%eax
  800826:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800829:	b8 10 00 00 00       	mov    $0x10,%eax
  80082e:	e9 47 ff ff ff       	jmp    80077a <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	8b 10                	mov    (%eax),%edx
  800838:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083d:	8d 40 04             	lea    0x4(%eax),%eax
  800840:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800843:	b8 10 00 00 00       	mov    $0x10,%eax
  800848:	e9 2d ff ff ff       	jmp    80077a <.L34+0x22>

0080084d <.L24>:
			putch(ch, putdat);
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	ff 75 0c             	pushl  0xc(%ebp)
  800853:	6a 25                	push   $0x25
  800855:	ff 55 08             	call   *0x8(%ebp)
			break;
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	e9 54 fb ff ff       	jmp    8003b4 <vprintfmt+0x20>

00800860 <.L21>:
			putch('%', putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	ff 75 0c             	pushl  0xc(%ebp)
  800866:	6a 25                	push   $0x25
  800868:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	89 f7                	mov    %esi,%edi
  800870:	eb 03                	jmp    800875 <.L21+0x15>
  800872:	83 ef 01             	sub    $0x1,%edi
  800875:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800879:	75 f7                	jne    800872 <.L21+0x12>
  80087b:	e9 34 fb ff ff       	jmp    8003b4 <vprintfmt+0x20>
}
  800880:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5f                   	pop    %edi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	83 ec 14             	sub    $0x14,%esp
  80088f:	e8 70 f8 ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800894:	81 c3 6c 17 00 00    	add    $0x176c,%ebx
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	74 2b                	je     8008e0 <vsnprintf+0x58>
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	7e 27                	jle    8008e0 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b9:	ff 75 14             	pushl  0x14(%ebp)
  8008bc:	ff 75 10             	pushl  0x10(%ebp)
  8008bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c2:	50                   	push   %eax
  8008c3:	8d 83 5a e3 ff ff    	lea    -0x1ca6(%ebx),%eax
  8008c9:	50                   	push   %eax
  8008ca:	e8 c5 fa ff ff       	call   800394 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d8:	83 c4 10             	add    $0x10,%esp
}
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    
		return -E_INVAL;
  8008e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e5:	eb f4                	jmp    8008db <vsnprintf+0x53>

008008e7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ed:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f0:	50                   	push   %eax
  8008f1:	ff 75 10             	pushl  0x10(%ebp)
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	ff 75 08             	pushl  0x8(%ebp)
  8008fa:	e8 89 ff ff ff       	call   800888 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    

00800901 <__x86.get_pc_thunk.cx>:
  800901:	8b 0c 24             	mov    (%esp),%ecx
  800904:	c3                   	ret    

00800905 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	eb 03                	jmp    800915 <strlen+0x10>
		n++;
  800912:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800915:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800919:	75 f7                	jne    800912 <strlen+0xd>
	return n;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800926:	b8 00 00 00 00       	mov    $0x0,%eax
  80092b:	eb 03                	jmp    800930 <strnlen+0x13>
		n++;
  80092d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800930:	39 d0                	cmp    %edx,%eax
  800932:	74 06                	je     80093a <strnlen+0x1d>
  800934:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800938:	75 f3                	jne    80092d <strnlen+0x10>
	return n;
}
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	53                   	push   %ebx
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800946:	89 c2                	mov    %eax,%edx
  800948:	83 c1 01             	add    $0x1,%ecx
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800952:	88 5a ff             	mov    %bl,-0x1(%edx)
  800955:	84 db                	test   %bl,%bl
  800957:	75 ef                	jne    800948 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800959:	5b                   	pop    %ebx
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	53                   	push   %ebx
  800960:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800963:	53                   	push   %ebx
  800964:	e8 9c ff ff ff       	call   800905 <strlen>
  800969:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80096c:	ff 75 0c             	pushl  0xc(%ebp)
  80096f:	01 d8                	add    %ebx,%eax
  800971:	50                   	push   %eax
  800972:	e8 c5 ff ff ff       	call   80093c <strcpy>
	return dst;
}
  800977:	89 d8                	mov    %ebx,%eax
  800979:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	56                   	push   %esi
  800982:	53                   	push   %ebx
  800983:	8b 75 08             	mov    0x8(%ebp),%esi
  800986:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800989:	89 f3                	mov    %esi,%ebx
  80098b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098e:	89 f2                	mov    %esi,%edx
  800990:	eb 0f                	jmp    8009a1 <strncpy+0x23>
		*dst++ = *src;
  800992:	83 c2 01             	add    $0x1,%edx
  800995:	0f b6 01             	movzbl (%ecx),%eax
  800998:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099b:	80 39 01             	cmpb   $0x1,(%ecx)
  80099e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009a1:	39 da                	cmp    %ebx,%edx
  8009a3:	75 ed                	jne    800992 <strncpy+0x14>
	}
	return ret;
}
  8009a5:	89 f0                	mov    %esi,%eax
  8009a7:	5b                   	pop    %ebx
  8009a8:	5e                   	pop    %esi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009b9:	89 f0                	mov    %esi,%eax
  8009bb:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009bf:	85 c9                	test   %ecx,%ecx
  8009c1:	75 0b                	jne    8009ce <strlcpy+0x23>
  8009c3:	eb 17                	jmp    8009dc <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c5:	83 c2 01             	add    $0x1,%edx
  8009c8:	83 c0 01             	add    $0x1,%eax
  8009cb:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009ce:	39 d8                	cmp    %ebx,%eax
  8009d0:	74 07                	je     8009d9 <strlcpy+0x2e>
  8009d2:	0f b6 0a             	movzbl (%edx),%ecx
  8009d5:	84 c9                	test   %cl,%cl
  8009d7:	75 ec                	jne    8009c5 <strlcpy+0x1a>
		*dst = '\0';
  8009d9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009dc:	29 f0                	sub    %esi,%eax
}
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009eb:	eb 06                	jmp    8009f3 <strcmp+0x11>
		p++, q++;
  8009ed:	83 c1 01             	add    $0x1,%ecx
  8009f0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009f3:	0f b6 01             	movzbl (%ecx),%eax
  8009f6:	84 c0                	test   %al,%al
  8009f8:	74 04                	je     8009fe <strcmp+0x1c>
  8009fa:	3a 02                	cmp    (%edx),%al
  8009fc:	74 ef                	je     8009ed <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fe:	0f b6 c0             	movzbl %al,%eax
  800a01:	0f b6 12             	movzbl (%edx),%edx
  800a04:	29 d0                	sub    %edx,%eax
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	53                   	push   %ebx
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a12:	89 c3                	mov    %eax,%ebx
  800a14:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a17:	eb 06                	jmp    800a1f <strncmp+0x17>
		n--, p++, q++;
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a1f:	39 d8                	cmp    %ebx,%eax
  800a21:	74 16                	je     800a39 <strncmp+0x31>
  800a23:	0f b6 08             	movzbl (%eax),%ecx
  800a26:	84 c9                	test   %cl,%cl
  800a28:	74 04                	je     800a2e <strncmp+0x26>
  800a2a:	3a 0a                	cmp    (%edx),%cl
  800a2c:	74 eb                	je     800a19 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2e:	0f b6 00             	movzbl (%eax),%eax
  800a31:	0f b6 12             	movzbl (%edx),%edx
  800a34:	29 d0                	sub    %edx,%eax
}
  800a36:	5b                   	pop    %ebx
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    
		return 0;
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3e:	eb f6                	jmp    800a36 <strncmp+0x2e>

00800a40 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4a:	0f b6 10             	movzbl (%eax),%edx
  800a4d:	84 d2                	test   %dl,%dl
  800a4f:	74 09                	je     800a5a <strchr+0x1a>
		if (*s == c)
  800a51:	38 ca                	cmp    %cl,%dl
  800a53:	74 0a                	je     800a5f <strchr+0x1f>
	for (; *s; s++)
  800a55:	83 c0 01             	add    $0x1,%eax
  800a58:	eb f0                	jmp    800a4a <strchr+0xa>
			return (char *) s;
	return 0;
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6b:	eb 03                	jmp    800a70 <strfind+0xf>
  800a6d:	83 c0 01             	add    $0x1,%eax
  800a70:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a73:	38 ca                	cmp    %cl,%dl
  800a75:	74 04                	je     800a7b <strfind+0x1a>
  800a77:	84 d2                	test   %dl,%dl
  800a79:	75 f2                	jne    800a6d <strfind+0xc>
			break;
	return (char *) s;
}
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	57                   	push   %edi
  800a81:	56                   	push   %esi
  800a82:	53                   	push   %ebx
  800a83:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a89:	85 c9                	test   %ecx,%ecx
  800a8b:	74 13                	je     800aa0 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a93:	75 05                	jne    800a9a <memset+0x1d>
  800a95:	f6 c1 03             	test   $0x3,%cl
  800a98:	74 0d                	je     800aa7 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9d:	fc                   	cld    
  800a9e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa0:	89 f8                	mov    %edi,%eax
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    
		c &= 0xFF;
  800aa7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aab:	89 d3                	mov    %edx,%ebx
  800aad:	c1 e3 08             	shl    $0x8,%ebx
  800ab0:	89 d0                	mov    %edx,%eax
  800ab2:	c1 e0 18             	shl    $0x18,%eax
  800ab5:	89 d6                	mov    %edx,%esi
  800ab7:	c1 e6 10             	shl    $0x10,%esi
  800aba:	09 f0                	or     %esi,%eax
  800abc:	09 c2                	or     %eax,%edx
  800abe:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ac0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ac3:	89 d0                	mov    %edx,%eax
  800ac5:	fc                   	cld    
  800ac6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac8:	eb d6                	jmp    800aa0 <memset+0x23>

00800aca <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	57                   	push   %edi
  800ace:	56                   	push   %esi
  800acf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad8:	39 c6                	cmp    %eax,%esi
  800ada:	73 35                	jae    800b11 <memmove+0x47>
  800adc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800adf:	39 c2                	cmp    %eax,%edx
  800ae1:	76 2e                	jbe    800b11 <memmove+0x47>
		s += n;
		d += n;
  800ae3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae6:	89 d6                	mov    %edx,%esi
  800ae8:	09 fe                	or     %edi,%esi
  800aea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af0:	74 0c                	je     800afe <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af2:	83 ef 01             	sub    $0x1,%edi
  800af5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800af8:	fd                   	std    
  800af9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800afb:	fc                   	cld    
  800afc:	eb 21                	jmp    800b1f <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afe:	f6 c1 03             	test   $0x3,%cl
  800b01:	75 ef                	jne    800af2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b03:	83 ef 04             	sub    $0x4,%edi
  800b06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b09:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b0c:	fd                   	std    
  800b0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0f:	eb ea                	jmp    800afb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b11:	89 f2                	mov    %esi,%edx
  800b13:	09 c2                	or     %eax,%edx
  800b15:	f6 c2 03             	test   $0x3,%dl
  800b18:	74 09                	je     800b23 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b1a:	89 c7                	mov    %eax,%edi
  800b1c:	fc                   	cld    
  800b1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b23:	f6 c1 03             	test   $0x3,%cl
  800b26:	75 f2                	jne    800b1a <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b28:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b2b:	89 c7                	mov    %eax,%edi
  800b2d:	fc                   	cld    
  800b2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b30:	eb ed                	jmp    800b1f <memmove+0x55>

00800b32 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b35:	ff 75 10             	pushl  0x10(%ebp)
  800b38:	ff 75 0c             	pushl  0xc(%ebp)
  800b3b:	ff 75 08             	pushl  0x8(%ebp)
  800b3e:	e8 87 ff ff ff       	call   800aca <memmove>
}
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b50:	89 c6                	mov    %eax,%esi
  800b52:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b55:	39 f0                	cmp    %esi,%eax
  800b57:	74 1c                	je     800b75 <memcmp+0x30>
		if (*s1 != *s2)
  800b59:	0f b6 08             	movzbl (%eax),%ecx
  800b5c:	0f b6 1a             	movzbl (%edx),%ebx
  800b5f:	38 d9                	cmp    %bl,%cl
  800b61:	75 08                	jne    800b6b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b63:	83 c0 01             	add    $0x1,%eax
  800b66:	83 c2 01             	add    $0x1,%edx
  800b69:	eb ea                	jmp    800b55 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b6b:	0f b6 c1             	movzbl %cl,%eax
  800b6e:	0f b6 db             	movzbl %bl,%ebx
  800b71:	29 d8                	sub    %ebx,%eax
  800b73:	eb 05                	jmp    800b7a <memcmp+0x35>
	}

	return 0;
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b87:	89 c2                	mov    %eax,%edx
  800b89:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8c:	39 d0                	cmp    %edx,%eax
  800b8e:	73 09                	jae    800b99 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b90:	38 08                	cmp    %cl,(%eax)
  800b92:	74 05                	je     800b99 <memfind+0x1b>
	for (; s < ends; s++)
  800b94:	83 c0 01             	add    $0x1,%eax
  800b97:	eb f3                	jmp    800b8c <memfind+0xe>
			break;
	return (void *) s;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba7:	eb 03                	jmp    800bac <strtol+0x11>
		s++;
  800ba9:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bac:	0f b6 01             	movzbl (%ecx),%eax
  800baf:	3c 20                	cmp    $0x20,%al
  800bb1:	74 f6                	je     800ba9 <strtol+0xe>
  800bb3:	3c 09                	cmp    $0x9,%al
  800bb5:	74 f2                	je     800ba9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bb7:	3c 2b                	cmp    $0x2b,%al
  800bb9:	74 2e                	je     800be9 <strtol+0x4e>
	int neg = 0;
  800bbb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bc0:	3c 2d                	cmp    $0x2d,%al
  800bc2:	74 2f                	je     800bf3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bca:	75 05                	jne    800bd1 <strtol+0x36>
  800bcc:	80 39 30             	cmpb   $0x30,(%ecx)
  800bcf:	74 2c                	je     800bfd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd1:	85 db                	test   %ebx,%ebx
  800bd3:	75 0a                	jne    800bdf <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd5:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bda:	80 39 30             	cmpb   $0x30,(%ecx)
  800bdd:	74 28                	je     800c07 <strtol+0x6c>
		base = 10;
  800bdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800be4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800be7:	eb 50                	jmp    800c39 <strtol+0x9e>
		s++;
  800be9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bec:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf1:	eb d1                	jmp    800bc4 <strtol+0x29>
		s++, neg = 1;
  800bf3:	83 c1 01             	add    $0x1,%ecx
  800bf6:	bf 01 00 00 00       	mov    $0x1,%edi
  800bfb:	eb c7                	jmp    800bc4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c01:	74 0e                	je     800c11 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c03:	85 db                	test   %ebx,%ebx
  800c05:	75 d8                	jne    800bdf <strtol+0x44>
		s++, base = 8;
  800c07:	83 c1 01             	add    $0x1,%ecx
  800c0a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c0f:	eb ce                	jmp    800bdf <strtol+0x44>
		s += 2, base = 16;
  800c11:	83 c1 02             	add    $0x2,%ecx
  800c14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c19:	eb c4                	jmp    800bdf <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c1b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c1e:	89 f3                	mov    %esi,%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 29                	ja     800c4e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c25:	0f be d2             	movsbl %dl,%edx
  800c28:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c2e:	7d 30                	jge    800c60 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c30:	83 c1 01             	add    $0x1,%ecx
  800c33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c37:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c39:	0f b6 11             	movzbl (%ecx),%edx
  800c3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c3f:	89 f3                	mov    %esi,%ebx
  800c41:	80 fb 09             	cmp    $0x9,%bl
  800c44:	77 d5                	ja     800c1b <strtol+0x80>
			dig = *s - '0';
  800c46:	0f be d2             	movsbl %dl,%edx
  800c49:	83 ea 30             	sub    $0x30,%edx
  800c4c:	eb dd                	jmp    800c2b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c4e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c51:	89 f3                	mov    %esi,%ebx
  800c53:	80 fb 19             	cmp    $0x19,%bl
  800c56:	77 08                	ja     800c60 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c58:	0f be d2             	movsbl %dl,%edx
  800c5b:	83 ea 37             	sub    $0x37,%edx
  800c5e:	eb cb                	jmp    800c2b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c64:	74 05                	je     800c6b <strtol+0xd0>
		*endptr = (char *) s;
  800c66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c69:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c6b:	89 c2                	mov    %eax,%edx
  800c6d:	f7 da                	neg    %edx
  800c6f:	85 ff                	test   %edi,%edi
  800c71:	0f 45 c2             	cmovne %edx,%eax
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	89 c3                	mov    %eax,%ebx
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	89 c6                	mov    %eax,%esi
  800c90:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca7:	89 d1                	mov    %edx,%ecx
  800ca9:	89 d3                	mov    %edx,%ebx
  800cab:	89 d7                	mov    %edx,%edi
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 1c             	sub    $0x1c,%esp
  800cbf:	e8 66 00 00 00       	call   800d2a <__x86.get_pc_thunk.ax>
  800cc4:	05 3c 13 00 00       	add    $0x133c,%eax
  800cc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800ccc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd9:	89 cb                	mov    %ecx,%ebx
  800cdb:	89 cf                	mov    %ecx,%edi
  800cdd:	89 ce                	mov    %ecx,%esi
  800cdf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	7f 08                	jg     800ced <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ce5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ced:	83 ec 0c             	sub    $0xc,%esp
  800cf0:	50                   	push   %eax
  800cf1:	6a 03                	push   $0x3
  800cf3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800cf6:	8d 83 40 f2 ff ff    	lea    -0xdc0(%ebx),%eax
  800cfc:	50                   	push   %eax
  800cfd:	6a 23                	push   $0x23
  800cff:	8d 83 5d f2 ff ff    	lea    -0xda3(%ebx),%eax
  800d05:	50                   	push   %eax
  800d06:	e8 65 f4 ff ff       	call   800170 <_panic>

00800d0b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d11:	ba 00 00 00 00       	mov    $0x0,%edx
  800d16:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1b:	89 d1                	mov    %edx,%ecx
  800d1d:	89 d3                	mov    %edx,%ebx
  800d1f:	89 d7                	mov    %edx,%edi
  800d21:	89 d6                	mov    %edx,%esi
  800d23:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <__x86.get_pc_thunk.ax>:
  800d2a:	8b 04 24             	mov    (%esp),%eax
  800d2d:	c3                   	ret    
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__udivdi3>:
  800d30:	55                   	push   %ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 1c             	sub    $0x1c,%esp
  800d37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d3b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d47:	85 d2                	test   %edx,%edx
  800d49:	75 35                	jne    800d80 <__udivdi3+0x50>
  800d4b:	39 f3                	cmp    %esi,%ebx
  800d4d:	0f 87 bd 00 00 00    	ja     800e10 <__udivdi3+0xe0>
  800d53:	85 db                	test   %ebx,%ebx
  800d55:	89 d9                	mov    %ebx,%ecx
  800d57:	75 0b                	jne    800d64 <__udivdi3+0x34>
  800d59:	b8 01 00 00 00       	mov    $0x1,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f3                	div    %ebx
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	31 d2                	xor    %edx,%edx
  800d66:	89 f0                	mov    %esi,%eax
  800d68:	f7 f1                	div    %ecx
  800d6a:	89 c6                	mov    %eax,%esi
  800d6c:	89 e8                	mov    %ebp,%eax
  800d6e:	89 f7                	mov    %esi,%edi
  800d70:	f7 f1                	div    %ecx
  800d72:	89 fa                	mov    %edi,%edx
  800d74:	83 c4 1c             	add    $0x1c,%esp
  800d77:	5b                   	pop    %ebx
  800d78:	5e                   	pop    %esi
  800d79:	5f                   	pop    %edi
  800d7a:	5d                   	pop    %ebp
  800d7b:	c3                   	ret    
  800d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 f2                	cmp    %esi,%edx
  800d82:	77 7c                	ja     800e00 <__udivdi3+0xd0>
  800d84:	0f bd fa             	bsr    %edx,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0xf8>
  800d90:	89 f9                	mov    %edi,%ecx
  800d92:	b8 20 00 00 00       	mov    $0x20,%eax
  800d97:	29 f8                	sub    %edi,%eax
  800d99:	d3 e2                	shl    %cl,%edx
  800d9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d9f:	89 c1                	mov    %eax,%ecx
  800da1:	89 da                	mov    %ebx,%edx
  800da3:	d3 ea                	shr    %cl,%edx
  800da5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800da9:	09 d1                	or     %edx,%ecx
  800dab:	89 f2                	mov    %esi,%edx
  800dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800db1:	89 f9                	mov    %edi,%ecx
  800db3:	d3 e3                	shl    %cl,%ebx
  800db5:	89 c1                	mov    %eax,%ecx
  800db7:	d3 ea                	shr    %cl,%edx
  800db9:	89 f9                	mov    %edi,%ecx
  800dbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dbf:	d3 e6                	shl    %cl,%esi
  800dc1:	89 eb                	mov    %ebp,%ebx
  800dc3:	89 c1                	mov    %eax,%ecx
  800dc5:	d3 eb                	shr    %cl,%ebx
  800dc7:	09 de                	or     %ebx,%esi
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	f7 74 24 08          	divl   0x8(%esp)
  800dcf:	89 d6                	mov    %edx,%esi
  800dd1:	89 c3                	mov    %eax,%ebx
  800dd3:	f7 64 24 0c          	mull   0xc(%esp)
  800dd7:	39 d6                	cmp    %edx,%esi
  800dd9:	72 0c                	jb     800de7 <__udivdi3+0xb7>
  800ddb:	89 f9                	mov    %edi,%ecx
  800ddd:	d3 e5                	shl    %cl,%ebp
  800ddf:	39 c5                	cmp    %eax,%ebp
  800de1:	73 5d                	jae    800e40 <__udivdi3+0x110>
  800de3:	39 d6                	cmp    %edx,%esi
  800de5:	75 59                	jne    800e40 <__udivdi3+0x110>
  800de7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dea:	31 ff                	xor    %edi,%edi
  800dec:	89 fa                	mov    %edi,%edx
  800dee:	83 c4 1c             	add    $0x1c,%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    
  800df6:	8d 76 00             	lea    0x0(%esi),%esi
  800df9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e00:	31 ff                	xor    %edi,%edi
  800e02:	31 c0                	xor    %eax,%eax
  800e04:	89 fa                	mov    %edi,%edx
  800e06:	83 c4 1c             	add    $0x1c,%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    
  800e0e:	66 90                	xchg   %ax,%ax
  800e10:	31 ff                	xor    %edi,%edi
  800e12:	89 e8                	mov    %ebp,%eax
  800e14:	89 f2                	mov    %esi,%edx
  800e16:	f7 f3                	div    %ebx
  800e18:	89 fa                	mov    %edi,%edx
  800e1a:	83 c4 1c             	add    $0x1c,%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
  800e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	72 06                	jb     800e32 <__udivdi3+0x102>
  800e2c:	31 c0                	xor    %eax,%eax
  800e2e:	39 eb                	cmp    %ebp,%ebx
  800e30:	77 d2                	ja     800e04 <__udivdi3+0xd4>
  800e32:	b8 01 00 00 00       	mov    $0x1,%eax
  800e37:	eb cb                	jmp    800e04 <__udivdi3+0xd4>
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 d8                	mov    %ebx,%eax
  800e42:	31 ff                	xor    %edi,%edi
  800e44:	eb be                	jmp    800e04 <__udivdi3+0xd4>
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 ed                	test   %ebp,%ebp
  800e69:	89 f0                	mov    %esi,%eax
  800e6b:	89 da                	mov    %ebx,%edx
  800e6d:	75 19                	jne    800e88 <__umoddi3+0x38>
  800e6f:	39 df                	cmp    %ebx,%edi
  800e71:	0f 86 b1 00 00 00    	jbe    800f28 <__umoddi3+0xd8>
  800e77:	f7 f7                	div    %edi
  800e79:	89 d0                	mov    %edx,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	83 c4 1c             	add    $0x1c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
  800e85:	8d 76 00             	lea    0x0(%esi),%esi
  800e88:	39 dd                	cmp    %ebx,%ebp
  800e8a:	77 f1                	ja     800e7d <__umoddi3+0x2d>
  800e8c:	0f bd cd             	bsr    %ebp,%ecx
  800e8f:	83 f1 1f             	xor    $0x1f,%ecx
  800e92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e96:	0f 84 b4 00 00 00    	je     800f50 <__umoddi3+0x100>
  800e9c:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea1:	89 c2                	mov    %eax,%edx
  800ea3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ea7:	29 c2                	sub    %eax,%edx
  800ea9:	89 c1                	mov    %eax,%ecx
  800eab:	89 f8                	mov    %edi,%eax
  800ead:	d3 e5                	shl    %cl,%ebp
  800eaf:	89 d1                	mov    %edx,%ecx
  800eb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800eb5:	d3 e8                	shr    %cl,%eax
  800eb7:	09 c5                	or     %eax,%ebp
  800eb9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ebd:	89 c1                	mov    %eax,%ecx
  800ebf:	d3 e7                	shl    %cl,%edi
  800ec1:	89 d1                	mov    %edx,%ecx
  800ec3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ec7:	89 df                	mov    %ebx,%edi
  800ec9:	d3 ef                	shr    %cl,%edi
  800ecb:	89 c1                	mov    %eax,%ecx
  800ecd:	89 f0                	mov    %esi,%eax
  800ecf:	d3 e3                	shl    %cl,%ebx
  800ed1:	89 d1                	mov    %edx,%ecx
  800ed3:	89 fa                	mov    %edi,%edx
  800ed5:	d3 e8                	shr    %cl,%eax
  800ed7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800edc:	09 d8                	or     %ebx,%eax
  800ede:	f7 f5                	div    %ebp
  800ee0:	d3 e6                	shl    %cl,%esi
  800ee2:	89 d1                	mov    %edx,%ecx
  800ee4:	f7 64 24 08          	mull   0x8(%esp)
  800ee8:	39 d1                	cmp    %edx,%ecx
  800eea:	89 c3                	mov    %eax,%ebx
  800eec:	89 d7                	mov    %edx,%edi
  800eee:	72 06                	jb     800ef6 <__umoddi3+0xa6>
  800ef0:	75 0e                	jne    800f00 <__umoddi3+0xb0>
  800ef2:	39 c6                	cmp    %eax,%esi
  800ef4:	73 0a                	jae    800f00 <__umoddi3+0xb0>
  800ef6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800efa:	19 ea                	sbb    %ebp,%edx
  800efc:	89 d7                	mov    %edx,%edi
  800efe:	89 c3                	mov    %eax,%ebx
  800f00:	89 ca                	mov    %ecx,%edx
  800f02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f07:	29 de                	sub    %ebx,%esi
  800f09:	19 fa                	sbb    %edi,%edx
  800f0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f0f:	89 d0                	mov    %edx,%eax
  800f11:	d3 e0                	shl    %cl,%eax
  800f13:	89 d9                	mov    %ebx,%ecx
  800f15:	d3 ee                	shr    %cl,%esi
  800f17:	d3 ea                	shr    %cl,%edx
  800f19:	09 f0                	or     %esi,%eax
  800f1b:	83 c4 1c             	add    $0x1c,%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5f                   	pop    %edi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    
  800f23:	90                   	nop
  800f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f28:	85 ff                	test   %edi,%edi
  800f2a:	89 f9                	mov    %edi,%ecx
  800f2c:	75 0b                	jne    800f39 <__umoddi3+0xe9>
  800f2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f33:	31 d2                	xor    %edx,%edx
  800f35:	f7 f7                	div    %edi
  800f37:	89 c1                	mov    %eax,%ecx
  800f39:	89 d8                	mov    %ebx,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f1                	div    %ecx
  800f3f:	89 f0                	mov    %esi,%eax
  800f41:	f7 f1                	div    %ecx
  800f43:	e9 31 ff ff ff       	jmp    800e79 <__umoddi3+0x29>
  800f48:	90                   	nop
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	39 dd                	cmp    %ebx,%ebp
  800f52:	72 08                	jb     800f5c <__umoddi3+0x10c>
  800f54:	39 f7                	cmp    %esi,%edi
  800f56:	0f 87 21 ff ff ff    	ja     800e7d <__umoddi3+0x2d>
  800f5c:	89 da                	mov    %ebx,%edx
  800f5e:	89 f0                	mov    %esi,%eax
  800f60:	29 f8                	sub    %edi,%eax
  800f62:	19 ea                	sbb    %ebp,%edx
  800f64:	e9 14 ff ff ff       	jmp    800e7d <__umoddi3+0x2d>
