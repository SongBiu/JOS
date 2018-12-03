
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
  800045:	8d 83 8c ef ff ff    	lea    -0x1074(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 42 02 00 00       	call   800293 <cprintf>
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
  8000a4:	8d 83 d4 ef ff ff    	lea    -0x102c(%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	e8 e3 01 00 00       	call   800293 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000b0:	c7 c0 40 20 80 00    	mov    $0x802040,%eax
  8000b6:	c7 80 00 10 40 00 00 	movl   $0x0,0x401000(%eax)
  8000bd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c0:	83 c4 0c             	add    $0xc,%esp
  8000c3:	8d 83 33 f0 ff ff    	lea    -0xfcd(%ebx),%eax
  8000c9:	50                   	push   %eax
  8000ca:	6a 1a                	push   $0x1a
  8000cc:	8d 83 24 f0 ff ff    	lea    -0xfdc(%ebx),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 af 00 00 00       	call   800187 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000d8:	50                   	push   %eax
  8000d9:	8d 83 07 f0 ff ff    	lea    -0xff9(%ebx),%eax
  8000df:	50                   	push   %eax
  8000e0:	6a 11                	push   $0x11
  8000e2:	8d 83 24 f0 ff ff    	lea    -0xfdc(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 99 00 00 00       	call   800187 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ee:	50                   	push   %eax
  8000ef:	8d 83 ac ef ff ff    	lea    -0x1054(%ebx),%eax
  8000f5:	50                   	push   %eax
  8000f6:	6a 16                	push   $0x16
  8000f8:	8d 83 24 f0 ff ff    	lea    -0xfdc(%ebx),%eax
  8000fe:	50                   	push   %eax
  8000ff:	e8 83 00 00 00       	call   800187 <_panic>

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
  80010b:	57                   	push   %edi
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	e8 ee ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800116:	81 c3 ea 1e 00 00    	add    $0x1eea,%ebx
  80011c:	8b 75 08             	mov    0x8(%ebp),%esi
  80011f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800122:	e8 fb 0b 00 00       	call   800d22 <sys_getenvid>
  800127:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80012f:	c1 e0 05             	shl    $0x5,%eax
  800132:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800138:	c7 c2 40 20 c0 00    	mov    $0xc02040,%edx
  80013e:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800140:	85 f6                	test   %esi,%esi
  800142:	7e 08                	jle    80014c <libmain+0x44>
		binaryname = argv[0];
  800144:	8b 07                	mov    (%edi),%eax
  800146:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80014c:	83 ec 08             	sub    $0x8,%esp
  80014f:	57                   	push   %edi
  800150:	56                   	push   %esi
  800151:	e8 dd fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800156:	e8 0b 00 00 00       	call   800166 <exit>
}
  80015b:	83 c4 10             	add    $0x10,%esp
  80015e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	53                   	push   %ebx
  80016a:	83 ec 10             	sub    $0x10,%esp
  80016d:	e8 92 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800172:	81 c3 8e 1e 00 00    	add    $0x1e8e,%ebx
	sys_env_destroy(0);
  800178:	6a 00                	push   $0x0
  80017a:	e8 4e 0b 00 00       	call   800ccd <sys_env_destroy>
}
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	e8 6f ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800195:	81 c3 6b 1e 00 00    	add    $0x1e6b,%ebx
	va_list ap;

	va_start(ap, fmt);
  80019b:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019e:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8001a4:	8b 38                	mov    (%eax),%edi
  8001a6:	e8 77 0b 00 00       	call   800d22 <sys_getenvid>
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	ff 75 0c             	pushl  0xc(%ebp)
  8001b1:	ff 75 08             	pushl  0x8(%ebp)
  8001b4:	57                   	push   %edi
  8001b5:	50                   	push   %eax
  8001b6:	8d 83 54 f0 ff ff    	lea    -0xfac(%ebx),%eax
  8001bc:	50                   	push   %eax
  8001bd:	e8 d1 00 00 00       	call   800293 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c2:	83 c4 18             	add    $0x18,%esp
  8001c5:	56                   	push   %esi
  8001c6:	ff 75 10             	pushl  0x10(%ebp)
  8001c9:	e8 63 00 00 00       	call   800231 <vcprintf>
	cprintf("\n");
  8001ce:	8d 83 22 f0 ff ff    	lea    -0xfde(%ebx),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 b7 00 00 00       	call   800293 <cprintf>
  8001dc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001df:	cc                   	int3   
  8001e0:	eb fd                	jmp    8001df <_panic+0x58>

008001e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	e8 18 ff ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8001ec:	81 c3 14 1e 00 00    	add    $0x1e14,%ebx
  8001f2:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001f5:	8b 16                	mov    (%esi),%edx
  8001f7:	8d 42 01             	lea    0x1(%edx),%eax
  8001fa:	89 06                	mov    %eax,(%esi)
  8001fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ff:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800203:	3d ff 00 00 00       	cmp    $0xff,%eax
  800208:	74 0b                	je     800215 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80020a:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80020e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	68 ff 00 00 00       	push   $0xff
  80021d:	8d 46 08             	lea    0x8(%esi),%eax
  800220:	50                   	push   %eax
  800221:	e8 6a 0a 00 00       	call   800c90 <sys_cputs>
		b->idx = 0;
  800226:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb d9                	jmp    80020a <putch+0x28>

00800231 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	53                   	push   %ebx
  800235:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80023b:	e8 c4 fe ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  800240:	81 c3 c0 1d 00 00    	add    $0x1dc0,%ebx
	struct printbuf b;

	b.idx = 0;
  800246:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024d:	00 00 00 
	b.cnt = 0;
  800250:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800257:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800266:	50                   	push   %eax
  800267:	8d 83 e2 e1 ff ff    	lea    -0x1e1e(%ebx),%eax
  80026d:	50                   	push   %eax
  80026e:	e8 38 01 00 00       	call   8003ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800273:	83 c4 08             	add    $0x8,%esp
  800276:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800282:	50                   	push   %eax
  800283:	e8 08 0a 00 00       	call   800c90 <sys_cputs>
	return b.cnt;
}
  800288:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800299:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029c:	50                   	push   %eax
  80029d:	ff 75 08             	pushl  0x8(%ebp)
  8002a0:	e8 8c ff ff ff       	call   800231 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a5:	c9                   	leave  
  8002a6:	c3                   	ret    

008002a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 2c             	sub    $0x2c,%esp
  8002b0:	e8 63 06 00 00       	call   800918 <__x86.get_pc_thunk.cx>
  8002b5:	81 c1 4b 1d 00 00    	add    $0x1d4b,%ecx
  8002bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002be:	89 c7                	mov    %eax,%edi
  8002c0:	89 d6                	mov    %edx,%esi
  8002c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002cb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002d9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002dc:	39 d3                	cmp    %edx,%ebx
  8002de:	72 09                	jb     8002e9 <printnum+0x42>
  8002e0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002e3:	0f 87 83 00 00 00    	ja     80036c <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e9:	83 ec 0c             	sub    $0xc,%esp
  8002ec:	ff 75 18             	pushl  0x18(%ebp)
  8002ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002f5:	53                   	push   %ebx
  8002f6:	ff 75 10             	pushl  0x10(%ebp)
  8002f9:	83 ec 08             	sub    $0x8,%esp
  8002fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800302:	ff 75 d4             	pushl  -0x2c(%ebp)
  800305:	ff 75 d0             	pushl  -0x30(%ebp)
  800308:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80030b:	e8 40 0a 00 00       	call   800d50 <__udivdi3>
  800310:	83 c4 18             	add    $0x18,%esp
  800313:	52                   	push   %edx
  800314:	50                   	push   %eax
  800315:	89 f2                	mov    %esi,%edx
  800317:	89 f8                	mov    %edi,%eax
  800319:	e8 89 ff ff ff       	call   8002a7 <printnum>
  80031e:	83 c4 20             	add    $0x20,%esp
  800321:	eb 13                	jmp    800336 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800323:	83 ec 08             	sub    $0x8,%esp
  800326:	56                   	push   %esi
  800327:	ff 75 18             	pushl  0x18(%ebp)
  80032a:	ff d7                	call   *%edi
  80032c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80032f:	83 eb 01             	sub    $0x1,%ebx
  800332:	85 db                	test   %ebx,%ebx
  800334:	7f ed                	jg     800323 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800336:	83 ec 08             	sub    $0x8,%esp
  800339:	56                   	push   %esi
  80033a:	83 ec 04             	sub    $0x4,%esp
  80033d:	ff 75 dc             	pushl  -0x24(%ebp)
  800340:	ff 75 d8             	pushl  -0x28(%ebp)
  800343:	ff 75 d4             	pushl  -0x2c(%ebp)
  800346:	ff 75 d0             	pushl  -0x30(%ebp)
  800349:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80034c:	89 f3                	mov    %esi,%ebx
  80034e:	e8 1d 0b 00 00       	call   800e70 <__umoddi3>
  800353:	83 c4 14             	add    $0x14,%esp
  800356:	0f be 84 06 78 f0 ff 	movsbl -0xf88(%esi,%eax,1),%eax
  80035d:	ff 
  80035e:	50                   	push   %eax
  80035f:	ff d7                	call   *%edi
}
  800361:	83 c4 10             	add    $0x10,%esp
  800364:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800367:	5b                   	pop    %ebx
  800368:	5e                   	pop    %esi
  800369:	5f                   	pop    %edi
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    
  80036c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80036f:	eb be                	jmp    80032f <printnum+0x88>

00800371 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800377:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	3b 50 04             	cmp    0x4(%eax),%edx
  800380:	73 0a                	jae    80038c <sprintputch+0x1b>
		*b->buf++ = ch;
  800382:	8d 4a 01             	lea    0x1(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
  80038a:	88 02                	mov    %al,(%edx)
}
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <printfmt>:
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800394:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800397:	50                   	push   %eax
  800398:	ff 75 10             	pushl  0x10(%ebp)
  80039b:	ff 75 0c             	pushl  0xc(%ebp)
  80039e:	ff 75 08             	pushl  0x8(%ebp)
  8003a1:	e8 05 00 00 00       	call   8003ab <vprintfmt>
}
  8003a6:	83 c4 10             	add    $0x10,%esp
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <vprintfmt>:
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	57                   	push   %edi
  8003af:	56                   	push   %esi
  8003b0:	53                   	push   %ebx
  8003b1:	83 ec 2c             	sub    $0x2c,%esp
  8003b4:	e8 4b fd ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8003b9:	81 c3 47 1c 00 00    	add    $0x1c47,%ebx
  8003bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003c2:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003c9:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003cb:	8d 77 01             	lea    0x1(%edi),%esi
  8003ce:	0f b6 07             	movzbl (%edi),%eax
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	74 1c                	je     8003f2 <vprintfmt+0x47>
			if (ch == '\0')
  8003d6:	85 c0                	test   %eax,%eax
  8003d8:	0f 84 b9 04 00 00    	je     800897 <.L21+0x20>
			putch(ch, putdat);
  8003de:	83 ec 08             	sub    $0x8,%esp
  8003e1:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003e4:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003e7:	50                   	push   %eax
  8003e8:	ff 55 08             	call   *0x8(%ebp)
  8003eb:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ee:	89 f7                	mov    %esi,%edi
  8003f0:	eb d9                	jmp    8003cb <vprintfmt+0x20>
		padc = ' ';
  8003f2:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003f6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003fd:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800404:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80040b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800410:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8d 7e 01             	lea    0x1(%esi),%edi
  800416:	0f b6 16             	movzbl (%esi),%edx
  800419:	8d 42 dd             	lea    -0x23(%edx),%eax
  80041c:	3c 55                	cmp    $0x55,%al
  80041e:	0f 87 53 04 00 00    	ja     800877 <.L21>
  800424:	0f b6 c0             	movzbl %al,%eax
  800427:	89 d9                	mov    %ebx,%ecx
  800429:	03 8c 83 08 f1 ff ff 	add    -0xef8(%ebx,%eax,4),%ecx
  800430:	ff e1                	jmp    *%ecx

00800432 <.L73>:
  800432:	89 fe                	mov    %edi,%esi
			padc = '-';
  800434:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800438:	eb d9                	jmp    800413 <vprintfmt+0x68>

0080043a <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	89 fe                	mov    %edi,%esi
			padc = '0';
  80043c:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800440:	eb d1                	jmp    800413 <vprintfmt+0x68>

00800442 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800442:	0f b6 d2             	movzbl %dl,%edx
  800445:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800447:	b8 00 00 00 00       	mov    $0x0,%eax
  80044c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  80044f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800452:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800456:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800459:	8d 7a d0             	lea    -0x30(%edx),%edi
  80045c:	83 ff 09             	cmp    $0x9,%edi
  80045f:	0f 87 94 00 00 00    	ja     8004f9 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800465:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800468:	eb e5                	jmp    80044f <.L28+0xd>

0080046a <.L25>:
			precision = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8b 00                	mov    (%eax),%eax
  80046f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 40 04             	lea    0x4(%eax),%eax
  800478:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	89 fe                	mov    %edi,%esi
			if (width < 0)
  80047d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800481:	79 90                	jns    800413 <vprintfmt+0x68>
				width = precision, precision = -1;
  800483:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800486:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800489:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800490:	eb 81                	jmp    800413 <vprintfmt+0x68>

00800492 <.L26>:
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	85 c0                	test   %eax,%eax
  800497:	ba 00 00 00 00       	mov    $0x0,%edx
  80049c:	0f 49 d0             	cmovns %eax,%edx
  80049f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	89 fe                	mov    %edi,%esi
  8004a4:	e9 6a ff ff ff       	jmp    800413 <vprintfmt+0x68>

008004a9 <.L22>:
  8004a9:	89 fe                	mov    %edi,%esi
			altflag = 1;
  8004ab:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004b2:	e9 5c ff ff ff       	jmp    800413 <vprintfmt+0x68>

008004b7 <.L33>:
  8004b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004ba:	83 f9 01             	cmp    $0x1,%ecx
  8004bd:	7e 16                	jle    8004d5 <.L33+0x1e>
		return va_arg(*ap, long long);
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8b 00                	mov    (%eax),%eax
  8004c4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004c7:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004ca:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004d0:	e9 f6 fe ff ff       	jmp    8003cb <vprintfmt+0x20>
	else if (lflag)
  8004d5:	85 c9                	test   %ecx,%ecx
  8004d7:	75 10                	jne    8004e9 <.L33+0x32>
		return va_arg(*ap, int);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004e1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004e4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e7:	eb e4                	jmp    8004cd <.L33+0x16>
		return va_arg(*ap, long);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004f1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004f4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f7:	eb d4                	jmp    8004cd <.L33+0x16>
  8004f9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ff:	e9 79 ff ff ff       	jmp    80047d <.L25+0x13>

00800504 <.L32>:
			lflag++;
  800504:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800508:	89 fe                	mov    %edi,%esi
			goto reswitch;
  80050a:	e9 04 ff ff ff       	jmp    800413 <vprintfmt+0x68>

0080050f <.L29>:
			putch(va_arg(ap, int), putdat);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 70 04             	lea    0x4(%eax),%esi
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	ff 75 0c             	pushl  0xc(%ebp)
  80051b:	ff 30                	pushl  (%eax)
  80051d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800520:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800523:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800526:	e9 a0 fe ff ff       	jmp    8003cb <vprintfmt+0x20>

0080052b <.L31>:
			err = va_arg(ap, int);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 70 04             	lea    0x4(%eax),%esi
  800531:	8b 00                	mov    (%eax),%eax
  800533:	99                   	cltd   
  800534:	31 d0                	xor    %edx,%eax
  800536:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800538:	83 f8 06             	cmp    $0x6,%eax
  80053b:	7f 29                	jg     800566 <.L31+0x3b>
  80053d:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800544:	85 d2                	test   %edx,%edx
  800546:	74 1e                	je     800566 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800548:	52                   	push   %edx
  800549:	8d 83 99 f0 ff ff    	lea    -0xf67(%ebx),%eax
  80054f:	50                   	push   %eax
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	ff 75 08             	pushl  0x8(%ebp)
  800556:	e8 33 fe ff ff       	call   80038e <printfmt>
  80055b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80055e:	89 75 14             	mov    %esi,0x14(%ebp)
  800561:	e9 65 fe ff ff       	jmp    8003cb <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800566:	50                   	push   %eax
  800567:	8d 83 90 f0 ff ff    	lea    -0xf70(%ebx),%eax
  80056d:	50                   	push   %eax
  80056e:	ff 75 0c             	pushl  0xc(%ebp)
  800571:	ff 75 08             	pushl  0x8(%ebp)
  800574:	e8 15 fe ff ff       	call   80038e <printfmt>
  800579:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80057c:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80057f:	e9 47 fe ff ff       	jmp    8003cb <vprintfmt+0x20>

00800584 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	83 c0 04             	add    $0x4,%eax
  80058a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800592:	85 f6                	test   %esi,%esi
  800594:	8d 83 89 f0 ff ff    	lea    -0xf77(%ebx),%eax
  80059a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80059d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a1:	0f 8e b4 00 00 00    	jle    80065b <.L36+0xd7>
  8005a7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005ab:	75 08                	jne    8005b5 <.L36+0x31>
  8005ad:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005b0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005b3:	eb 6c                	jmp    800621 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	ff 75 cc             	pushl  -0x34(%ebp)
  8005bb:	56                   	push   %esi
  8005bc:	e8 73 03 00 00       	call   800934 <strnlen>
  8005c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005c4:	29 c2                	sub    %eax,%edx
  8005c6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005c9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005cc:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005d0:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005d3:	89 d6                	mov    %edx,%esi
  8005d5:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005d8:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005da:	eb 10                	jmp    8005ec <.L36+0x68>
					putch(padc, putdat);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	ff 75 0c             	pushl  0xc(%ebp)
  8005e2:	57                   	push   %edi
  8005e3:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	83 ee 01             	sub    $0x1,%esi
  8005e9:	83 c4 10             	add    $0x10,%esp
  8005ec:	85 f6                	test   %esi,%esi
  8005ee:	7f ec                	jg     8005dc <.L36+0x58>
  8005f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005f6:	85 d2                	test   %edx,%edx
  8005f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fd:	0f 49 c2             	cmovns %edx,%eax
  800600:	29 c2                	sub    %eax,%edx
  800602:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800605:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800608:	eb 17                	jmp    800621 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  80060a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060e:	75 30                	jne    800640 <.L36+0xbc>
					putch(ch, putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	ff 75 0c             	pushl  0xc(%ebp)
  800616:	50                   	push   %eax
  800617:	ff 55 08             	call   *0x8(%ebp)
  80061a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800621:	83 c6 01             	add    $0x1,%esi
  800624:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800628:	0f be c2             	movsbl %dl,%eax
  80062b:	85 c0                	test   %eax,%eax
  80062d:	74 58                	je     800687 <.L36+0x103>
  80062f:	85 ff                	test   %edi,%edi
  800631:	78 d7                	js     80060a <.L36+0x86>
  800633:	83 ef 01             	sub    $0x1,%edi
  800636:	79 d2                	jns    80060a <.L36+0x86>
  800638:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80063b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80063e:	eb 32                	jmp    800672 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800640:	0f be d2             	movsbl %dl,%edx
  800643:	83 ea 20             	sub    $0x20,%edx
  800646:	83 fa 5e             	cmp    $0x5e,%edx
  800649:	76 c5                	jbe    800610 <.L36+0x8c>
					putch('?', putdat);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	ff 75 0c             	pushl  0xc(%ebp)
  800651:	6a 3f                	push   $0x3f
  800653:	ff 55 08             	call   *0x8(%ebp)
  800656:	83 c4 10             	add    $0x10,%esp
  800659:	eb c2                	jmp    80061d <.L36+0x99>
  80065b:	89 7d 10             	mov    %edi,0x10(%ebp)
  80065e:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800661:	eb be                	jmp    800621 <.L36+0x9d>
				putch(' ', putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	57                   	push   %edi
  800667:	6a 20                	push   $0x20
  800669:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80066c:	83 ee 01             	sub    $0x1,%esi
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	85 f6                	test   %esi,%esi
  800674:	7f ed                	jg     800663 <.L36+0xdf>
  800676:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800679:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  80067c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
  800682:	e9 44 fd ff ff       	jmp    8003cb <vprintfmt+0x20>
  800687:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80068a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80068d:	eb e3                	jmp    800672 <.L36+0xee>

0080068f <.L30>:
  80068f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800692:	83 f9 01             	cmp    $0x1,%ecx
  800695:	7e 42                	jle    8006d9 <.L30+0x4a>
		return va_arg(*ap, long long);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8b 50 04             	mov    0x4(%eax),%edx
  80069d:	8b 00                	mov    (%eax),%eax
  80069f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 40 08             	lea    0x8(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006b2:	79 5f                	jns    800713 <.L30+0x84>
				putch('-', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ba:	6a 2d                	push   $0x2d
  8006bc:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006c5:	f7 da                	neg    %edx
  8006c7:	83 d1 00             	adc    $0x0,%ecx
  8006ca:	f7 d9                	neg    %ecx
  8006cc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d4:	e9 b8 00 00 00       	jmp    800791 <.L34+0x22>
	else if (lflag)
  8006d9:	85 c9                	test   %ecx,%ecx
  8006db:	75 1b                	jne    8006f8 <.L30+0x69>
		return va_arg(*ap, int);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 30                	mov    (%eax),%esi
  8006e2:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006e5:	89 f0                	mov    %esi,%eax
  8006e7:	c1 f8 1f             	sar    $0x1f,%eax
  8006ea:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8d 40 04             	lea    0x4(%eax),%eax
  8006f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f6:	eb b6                	jmp    8006ae <.L30+0x1f>
		return va_arg(*ap, long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 30                	mov    (%eax),%esi
  8006fd:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800700:	89 f0                	mov    %esi,%eax
  800702:	c1 f8 1f             	sar    $0x1f,%eax
  800705:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8d 40 04             	lea    0x4(%eax),%eax
  80070e:	89 45 14             	mov    %eax,0x14(%ebp)
  800711:	eb 9b                	jmp    8006ae <.L30+0x1f>
			num = getint(&ap, lflag);
  800713:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800716:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800719:	b8 0a 00 00 00       	mov    $0xa,%eax
  80071e:	eb 71                	jmp    800791 <.L34+0x22>

00800720 <.L37>:
  800720:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800723:	83 f9 01             	cmp    $0x1,%ecx
  800726:	7e 15                	jle    80073d <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	8b 48 04             	mov    0x4(%eax),%ecx
  800730:	8d 40 08             	lea    0x8(%eax),%eax
  800733:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800736:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073b:	eb 54                	jmp    800791 <.L34+0x22>
	else if (lflag)
  80073d:	85 c9                	test   %ecx,%ecx
  80073f:	75 17                	jne    800758 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 10                	mov    (%eax),%edx
  800746:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074b:	8d 40 04             	lea    0x4(%eax),%eax
  80074e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800751:	b8 0a 00 00 00       	mov    $0xa,%eax
  800756:	eb 39                	jmp    800791 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 10                	mov    (%eax),%edx
  80075d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800762:	8d 40 04             	lea    0x4(%eax),%eax
  800765:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800768:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076d:	eb 22                	jmp    800791 <.L34+0x22>

0080076f <.L34>:
  80076f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800772:	83 f9 01             	cmp    $0x1,%ecx
  800775:	7e 3b                	jle    8007b2 <.L34+0x43>
		return va_arg(*ap, long long);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8b 50 04             	mov    0x4(%eax),%edx
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800782:	8d 49 08             	lea    0x8(%ecx),%ecx
  800785:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800788:	89 d1                	mov    %edx,%ecx
  80078a:	89 c2                	mov    %eax,%edx
			base = 8;
  80078c:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800791:	83 ec 0c             	sub    $0xc,%esp
  800794:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800798:	56                   	push   %esi
  800799:	ff 75 e0             	pushl  -0x20(%ebp)
  80079c:	50                   	push   %eax
  80079d:	51                   	push   %ecx
  80079e:	52                   	push   %edx
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a5:	e8 fd fa ff ff       	call   8002a7 <printnum>
			break;
  8007aa:	83 c4 20             	add    $0x20,%esp
  8007ad:	e9 19 fc ff ff       	jmp    8003cb <vprintfmt+0x20>
	else if (lflag)
  8007b2:	85 c9                	test   %ecx,%ecx
  8007b4:	75 13                	jne    8007c9 <.L34+0x5a>
		return va_arg(*ap, int);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8b 10                	mov    (%eax),%edx
  8007bb:	89 d0                	mov    %edx,%eax
  8007bd:	99                   	cltd   
  8007be:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007c1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007c4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007c7:	eb bf                	jmp    800788 <.L34+0x19>
		return va_arg(*ap, long);
  8007c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cc:	8b 10                	mov    (%eax),%edx
  8007ce:	89 d0                	mov    %edx,%eax
  8007d0:	99                   	cltd   
  8007d1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007d4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007d7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007da:	eb ac                	jmp    800788 <.L34+0x19>

008007dc <.L35>:
			putch('0', putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	ff 75 0c             	pushl  0xc(%ebp)
  8007e2:	6a 30                	push   $0x30
  8007e4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007e7:	83 c4 08             	add    $0x8,%esp
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	6a 78                	push   $0x78
  8007ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8b 10                	mov    (%eax),%edx
  8007f7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007fc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007ff:	8d 40 04             	lea    0x4(%eax),%eax
  800802:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800805:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80080a:	eb 85                	jmp    800791 <.L34+0x22>

0080080c <.L38>:
  80080c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80080f:	83 f9 01             	cmp    $0x1,%ecx
  800812:	7e 18                	jle    80082c <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	8b 10                	mov    (%eax),%edx
  800819:	8b 48 04             	mov    0x4(%eax),%ecx
  80081c:	8d 40 08             	lea    0x8(%eax),%eax
  80081f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800822:	b8 10 00 00 00       	mov    $0x10,%eax
  800827:	e9 65 ff ff ff       	jmp    800791 <.L34+0x22>
	else if (lflag)
  80082c:	85 c9                	test   %ecx,%ecx
  80082e:	75 1a                	jne    80084a <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800830:	8b 45 14             	mov    0x14(%ebp),%eax
  800833:	8b 10                	mov    (%eax),%edx
  800835:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083a:	8d 40 04             	lea    0x4(%eax),%eax
  80083d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800840:	b8 10 00 00 00       	mov    $0x10,%eax
  800845:	e9 47 ff ff ff       	jmp    800791 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80084a:	8b 45 14             	mov    0x14(%ebp),%eax
  80084d:	8b 10                	mov    (%eax),%edx
  80084f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800854:	8d 40 04             	lea    0x4(%eax),%eax
  800857:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80085a:	b8 10 00 00 00       	mov    $0x10,%eax
  80085f:	e9 2d ff ff ff       	jmp    800791 <.L34+0x22>

00800864 <.L24>:
			putch(ch, putdat);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	6a 25                	push   $0x25
  80086c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	e9 54 fb ff ff       	jmp    8003cb <vprintfmt+0x20>

00800877 <.L21>:
			putch('%', putdat);
  800877:	83 ec 08             	sub    $0x8,%esp
  80087a:	ff 75 0c             	pushl  0xc(%ebp)
  80087d:	6a 25                	push   $0x25
  80087f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800882:	83 c4 10             	add    $0x10,%esp
  800885:	89 f7                	mov    %esi,%edi
  800887:	eb 03                	jmp    80088c <.L21+0x15>
  800889:	83 ef 01             	sub    $0x1,%edi
  80088c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800890:	75 f7                	jne    800889 <.L21+0x12>
  800892:	e9 34 fb ff ff       	jmp    8003cb <vprintfmt+0x20>
}
  800897:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5f                   	pop    %edi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	53                   	push   %ebx
  8008a3:	83 ec 14             	sub    $0x14,%esp
  8008a6:	e8 59 f8 ff ff       	call   800104 <__x86.get_pc_thunk.bx>
  8008ab:	81 c3 55 17 00 00    	add    $0x1755,%ebx
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008be:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 2b                	je     8008f7 <vsnprintf+0x58>
  8008cc:	85 d2                	test   %edx,%edx
  8008ce:	7e 27                	jle    8008f7 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d0:	ff 75 14             	pushl  0x14(%ebp)
  8008d3:	ff 75 10             	pushl  0x10(%ebp)
  8008d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d9:	50                   	push   %eax
  8008da:	8d 83 71 e3 ff ff    	lea    -0x1c8f(%ebx),%eax
  8008e0:	50                   	push   %eax
  8008e1:	e8 c5 fa ff ff       	call   8003ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ef:	83 c4 10             	add    $0x10,%esp
}
  8008f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    
		return -E_INVAL;
  8008f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008fc:	eb f4                	jmp    8008f2 <vsnprintf+0x53>

008008fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800904:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800907:	50                   	push   %eax
  800908:	ff 75 10             	pushl  0x10(%ebp)
  80090b:	ff 75 0c             	pushl  0xc(%ebp)
  80090e:	ff 75 08             	pushl  0x8(%ebp)
  800911:	e8 89 ff ff ff       	call   80089f <vsnprintf>
	va_end(ap);

	return rc;
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <__x86.get_pc_thunk.cx>:
  800918:	8b 0c 24             	mov    (%esp),%ecx
  80091b:	c3                   	ret    

0080091c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	eb 03                	jmp    80092c <strlen+0x10>
		n++;
  800929:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80092c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800930:	75 f7                	jne    800929 <strlen+0xd>
	return n;
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
  800942:	eb 03                	jmp    800947 <strnlen+0x13>
		n++;
  800944:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800947:	39 d0                	cmp    %edx,%eax
  800949:	74 06                	je     800951 <strnlen+0x1d>
  80094b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80094f:	75 f3                	jne    800944 <strnlen+0x10>
	return n;
}
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	53                   	push   %ebx
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80095d:	89 c2                	mov    %eax,%edx
  80095f:	83 c1 01             	add    $0x1,%ecx
  800962:	83 c2 01             	add    $0x1,%edx
  800965:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800969:	88 5a ff             	mov    %bl,-0x1(%edx)
  80096c:	84 db                	test   %bl,%bl
  80096e:	75 ef                	jne    80095f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800970:	5b                   	pop    %ebx
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	53                   	push   %ebx
  800977:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80097a:	53                   	push   %ebx
  80097b:	e8 9c ff ff ff       	call   80091c <strlen>
  800980:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800983:	ff 75 0c             	pushl  0xc(%ebp)
  800986:	01 d8                	add    %ebx,%eax
  800988:	50                   	push   %eax
  800989:	e8 c5 ff ff ff       	call   800953 <strcpy>
	return dst;
}
  80098e:	89 d8                	mov    %ebx,%eax
  800990:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 75 08             	mov    0x8(%ebp),%esi
  80099d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a0:	89 f3                	mov    %esi,%ebx
  8009a2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a5:	89 f2                	mov    %esi,%edx
  8009a7:	eb 0f                	jmp    8009b8 <strncpy+0x23>
		*dst++ = *src;
  8009a9:	83 c2 01             	add    $0x1,%edx
  8009ac:	0f b6 01             	movzbl (%ecx),%eax
  8009af:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b2:	80 39 01             	cmpb   $0x1,(%ecx)
  8009b5:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009b8:	39 da                	cmp    %ebx,%edx
  8009ba:	75 ed                	jne    8009a9 <strncpy+0x14>
	}
	return ret;
}
  8009bc:	89 f0                	mov    %esi,%eax
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009d0:	89 f0                	mov    %esi,%eax
  8009d2:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d6:	85 c9                	test   %ecx,%ecx
  8009d8:	75 0b                	jne    8009e5 <strlcpy+0x23>
  8009da:	eb 17                	jmp    8009f3 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009dc:	83 c2 01             	add    $0x1,%edx
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009e5:	39 d8                	cmp    %ebx,%eax
  8009e7:	74 07                	je     8009f0 <strlcpy+0x2e>
  8009e9:	0f b6 0a             	movzbl (%edx),%ecx
  8009ec:	84 c9                	test   %cl,%cl
  8009ee:	75 ec                	jne    8009dc <strlcpy+0x1a>
		*dst = '\0';
  8009f0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009f3:	29 f0                	sub    %esi,%eax
}
  8009f5:	5b                   	pop    %ebx
  8009f6:	5e                   	pop    %esi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a02:	eb 06                	jmp    800a0a <strcmp+0x11>
		p++, q++;
  800a04:	83 c1 01             	add    $0x1,%ecx
  800a07:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a0a:	0f b6 01             	movzbl (%ecx),%eax
  800a0d:	84 c0                	test   %al,%al
  800a0f:	74 04                	je     800a15 <strcmp+0x1c>
  800a11:	3a 02                	cmp    (%edx),%al
  800a13:	74 ef                	je     800a04 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a15:	0f b6 c0             	movzbl %al,%eax
  800a18:	0f b6 12             	movzbl (%edx),%edx
  800a1b:	29 d0                	sub    %edx,%eax
}
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a29:	89 c3                	mov    %eax,%ebx
  800a2b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a2e:	eb 06                	jmp    800a36 <strncmp+0x17>
		n--, p++, q++;
  800a30:	83 c0 01             	add    $0x1,%eax
  800a33:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a36:	39 d8                	cmp    %ebx,%eax
  800a38:	74 16                	je     800a50 <strncmp+0x31>
  800a3a:	0f b6 08             	movzbl (%eax),%ecx
  800a3d:	84 c9                	test   %cl,%cl
  800a3f:	74 04                	je     800a45 <strncmp+0x26>
  800a41:	3a 0a                	cmp    (%edx),%cl
  800a43:	74 eb                	je     800a30 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a45:	0f b6 00             	movzbl (%eax),%eax
  800a48:	0f b6 12             	movzbl (%edx),%edx
  800a4b:	29 d0                	sub    %edx,%eax
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    
		return 0;
  800a50:	b8 00 00 00 00       	mov    $0x0,%eax
  800a55:	eb f6                	jmp    800a4d <strncmp+0x2e>

00800a57 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a61:	0f b6 10             	movzbl (%eax),%edx
  800a64:	84 d2                	test   %dl,%dl
  800a66:	74 09                	je     800a71 <strchr+0x1a>
		if (*s == c)
  800a68:	38 ca                	cmp    %cl,%dl
  800a6a:	74 0a                	je     800a76 <strchr+0x1f>
	for (; *s; s++)
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	eb f0                	jmp    800a61 <strchr+0xa>
			return (char *) s;
	return 0;
  800a71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a82:	eb 03                	jmp    800a87 <strfind+0xf>
  800a84:	83 c0 01             	add    $0x1,%eax
  800a87:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a8a:	38 ca                	cmp    %cl,%dl
  800a8c:	74 04                	je     800a92 <strfind+0x1a>
  800a8e:	84 d2                	test   %dl,%dl
  800a90:	75 f2                	jne    800a84 <strfind+0xc>
			break;
	return (char *) s;
}
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
  800a9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa0:	85 c9                	test   %ecx,%ecx
  800aa2:	74 13                	je     800ab7 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aaa:	75 05                	jne    800ab1 <memset+0x1d>
  800aac:	f6 c1 03             	test   $0x3,%cl
  800aaf:	74 0d                	je     800abe <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab4:	fc                   	cld    
  800ab5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab7:	89 f8                	mov    %edi,%eax
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    
		c &= 0xFF;
  800abe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac2:	89 d3                	mov    %edx,%ebx
  800ac4:	c1 e3 08             	shl    $0x8,%ebx
  800ac7:	89 d0                	mov    %edx,%eax
  800ac9:	c1 e0 18             	shl    $0x18,%eax
  800acc:	89 d6                	mov    %edx,%esi
  800ace:	c1 e6 10             	shl    $0x10,%esi
  800ad1:	09 f0                	or     %esi,%eax
  800ad3:	09 c2                	or     %eax,%edx
  800ad5:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ad7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ada:	89 d0                	mov    %edx,%eax
  800adc:	fc                   	cld    
  800add:	f3 ab                	rep stos %eax,%es:(%edi)
  800adf:	eb d6                	jmp    800ab7 <memset+0x23>

00800ae1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aef:	39 c6                	cmp    %eax,%esi
  800af1:	73 35                	jae    800b28 <memmove+0x47>
  800af3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af6:	39 c2                	cmp    %eax,%edx
  800af8:	76 2e                	jbe    800b28 <memmove+0x47>
		s += n;
		d += n;
  800afa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afd:	89 d6                	mov    %edx,%esi
  800aff:	09 fe                	or     %edi,%esi
  800b01:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b07:	74 0c                	je     800b15 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b09:	83 ef 01             	sub    $0x1,%edi
  800b0c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b0f:	fd                   	std    
  800b10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b12:	fc                   	cld    
  800b13:	eb 21                	jmp    800b36 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b15:	f6 c1 03             	test   $0x3,%cl
  800b18:	75 ef                	jne    800b09 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b1a:	83 ef 04             	sub    $0x4,%edi
  800b1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b20:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b23:	fd                   	std    
  800b24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b26:	eb ea                	jmp    800b12 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b28:	89 f2                	mov    %esi,%edx
  800b2a:	09 c2                	or     %eax,%edx
  800b2c:	f6 c2 03             	test   $0x3,%dl
  800b2f:	74 09                	je     800b3a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	fc                   	cld    
  800b34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3a:	f6 c1 03             	test   $0x3,%cl
  800b3d:	75 f2                	jne    800b31 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b3f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b42:	89 c7                	mov    %eax,%edi
  800b44:	fc                   	cld    
  800b45:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b47:	eb ed                	jmp    800b36 <memmove+0x55>

00800b49 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b4c:	ff 75 10             	pushl  0x10(%ebp)
  800b4f:	ff 75 0c             	pushl  0xc(%ebp)
  800b52:	ff 75 08             	pushl  0x8(%ebp)
  800b55:	e8 87 ff ff ff       	call   800ae1 <memmove>
}
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b67:	89 c6                	mov    %eax,%esi
  800b69:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6c:	39 f0                	cmp    %esi,%eax
  800b6e:	74 1c                	je     800b8c <memcmp+0x30>
		if (*s1 != *s2)
  800b70:	0f b6 08             	movzbl (%eax),%ecx
  800b73:	0f b6 1a             	movzbl (%edx),%ebx
  800b76:	38 d9                	cmp    %bl,%cl
  800b78:	75 08                	jne    800b82 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b7a:	83 c0 01             	add    $0x1,%eax
  800b7d:	83 c2 01             	add    $0x1,%edx
  800b80:	eb ea                	jmp    800b6c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b82:	0f b6 c1             	movzbl %cl,%eax
  800b85:	0f b6 db             	movzbl %bl,%ebx
  800b88:	29 d8                	sub    %ebx,%eax
  800b8a:	eb 05                	jmp    800b91 <memcmp+0x35>
	}

	return 0;
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b9e:	89 c2                	mov    %eax,%edx
  800ba0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba3:	39 d0                	cmp    %edx,%eax
  800ba5:	73 09                	jae    800bb0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba7:	38 08                	cmp    %cl,(%eax)
  800ba9:	74 05                	je     800bb0 <memfind+0x1b>
	for (; s < ends; s++)
  800bab:	83 c0 01             	add    $0x1,%eax
  800bae:	eb f3                	jmp    800ba3 <memfind+0xe>
			break;
	return (void *) s;
}
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbe:	eb 03                	jmp    800bc3 <strtol+0x11>
		s++;
  800bc0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bc3:	0f b6 01             	movzbl (%ecx),%eax
  800bc6:	3c 20                	cmp    $0x20,%al
  800bc8:	74 f6                	je     800bc0 <strtol+0xe>
  800bca:	3c 09                	cmp    $0x9,%al
  800bcc:	74 f2                	je     800bc0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bce:	3c 2b                	cmp    $0x2b,%al
  800bd0:	74 2e                	je     800c00 <strtol+0x4e>
	int neg = 0;
  800bd2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bd7:	3c 2d                	cmp    $0x2d,%al
  800bd9:	74 2f                	je     800c0a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bdb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800be1:	75 05                	jne    800be8 <strtol+0x36>
  800be3:	80 39 30             	cmpb   $0x30,(%ecx)
  800be6:	74 2c                	je     800c14 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be8:	85 db                	test   %ebx,%ebx
  800bea:	75 0a                	jne    800bf6 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bec:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bf1:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf4:	74 28                	je     800c1e <strtol+0x6c>
		base = 10;
  800bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bfe:	eb 50                	jmp    800c50 <strtol+0x9e>
		s++;
  800c00:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c03:	bf 00 00 00 00       	mov    $0x0,%edi
  800c08:	eb d1                	jmp    800bdb <strtol+0x29>
		s++, neg = 1;
  800c0a:	83 c1 01             	add    $0x1,%ecx
  800c0d:	bf 01 00 00 00       	mov    $0x1,%edi
  800c12:	eb c7                	jmp    800bdb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c14:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c18:	74 0e                	je     800c28 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c1a:	85 db                	test   %ebx,%ebx
  800c1c:	75 d8                	jne    800bf6 <strtol+0x44>
		s++, base = 8;
  800c1e:	83 c1 01             	add    $0x1,%ecx
  800c21:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c26:	eb ce                	jmp    800bf6 <strtol+0x44>
		s += 2, base = 16;
  800c28:	83 c1 02             	add    $0x2,%ecx
  800c2b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c30:	eb c4                	jmp    800bf6 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c32:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c35:	89 f3                	mov    %esi,%ebx
  800c37:	80 fb 19             	cmp    $0x19,%bl
  800c3a:	77 29                	ja     800c65 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c3c:	0f be d2             	movsbl %dl,%edx
  800c3f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c42:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c45:	7d 30                	jge    800c77 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c47:	83 c1 01             	add    $0x1,%ecx
  800c4a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c4e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c50:	0f b6 11             	movzbl (%ecx),%edx
  800c53:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c56:	89 f3                	mov    %esi,%ebx
  800c58:	80 fb 09             	cmp    $0x9,%bl
  800c5b:	77 d5                	ja     800c32 <strtol+0x80>
			dig = *s - '0';
  800c5d:	0f be d2             	movsbl %dl,%edx
  800c60:	83 ea 30             	sub    $0x30,%edx
  800c63:	eb dd                	jmp    800c42 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c65:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c68:	89 f3                	mov    %esi,%ebx
  800c6a:	80 fb 19             	cmp    $0x19,%bl
  800c6d:	77 08                	ja     800c77 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c6f:	0f be d2             	movsbl %dl,%edx
  800c72:	83 ea 37             	sub    $0x37,%edx
  800c75:	eb cb                	jmp    800c42 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c7b:	74 05                	je     800c82 <strtol+0xd0>
		*endptr = (char *) s;
  800c7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c80:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c82:	89 c2                	mov    %eax,%edx
  800c84:	f7 da                	neg    %edx
  800c86:	85 ff                	test   %edi,%edi
  800c88:	0f 45 c2             	cmovne %edx,%eax
}
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c96:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	89 c3                	mov    %eax,%ebx
  800ca3:	89 c7                	mov    %eax,%edi
  800ca5:	89 c6                	mov    %eax,%esi
  800ca7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5e                   	pop    %esi
  800cab:	5f                   	pop    %edi
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <sys_cgetc>:

int
sys_cgetc(void)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cbe:	89 d1                	mov    %edx,%ecx
  800cc0:	89 d3                	mov    %edx,%ebx
  800cc2:	89 d7                	mov    %edx,%edi
  800cc4:	89 d6                	mov    %edx,%esi
  800cc6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 1c             	sub    $0x1c,%esp
  800cd6:	e8 66 00 00 00       	call   800d41 <__x86.get_pc_thunk.ax>
  800cdb:	05 25 13 00 00       	add    $0x1325,%eax
  800ce0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800ce3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	b8 03 00 00 00       	mov    $0x3,%eax
  800cf0:	89 cb                	mov    %ecx,%ebx
  800cf2:	89 cf                	mov    %ecx,%edi
  800cf4:	89 ce                	mov    %ecx,%esi
  800cf6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	7f 08                	jg     800d04 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5f                   	pop    %edi
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	50                   	push   %eax
  800d08:	6a 03                	push   $0x3
  800d0a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800d0d:	8d 83 60 f2 ff ff    	lea    -0xda0(%ebx),%eax
  800d13:	50                   	push   %eax
  800d14:	6a 26                	push   $0x26
  800d16:	8d 83 7d f2 ff ff    	lea    -0xd83(%ebx),%eax
  800d1c:	50                   	push   %eax
  800d1d:	e8 65 f4 ff ff       	call   800187 <_panic>

00800d22 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d28:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d32:	89 d1                	mov    %edx,%ecx
  800d34:	89 d3                	mov    %edx,%ebx
  800d36:	89 d7                	mov    %edx,%edi
  800d38:	89 d6                	mov    %edx,%esi
  800d3a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <__x86.get_pc_thunk.ax>:
  800d41:	8b 04 24             	mov    (%esp),%eax
  800d44:	c3                   	ret    
  800d45:	66 90                	xchg   %ax,%ax
  800d47:	66 90                	xchg   %ax,%ax
  800d49:	66 90                	xchg   %ax,%ax
  800d4b:	66 90                	xchg   %ax,%ax
  800d4d:	66 90                	xchg   %ax,%ax
  800d4f:	90                   	nop

00800d50 <__udivdi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
  800d57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d67:	85 d2                	test   %edx,%edx
  800d69:	75 35                	jne    800da0 <__udivdi3+0x50>
  800d6b:	39 f3                	cmp    %esi,%ebx
  800d6d:	0f 87 bd 00 00 00    	ja     800e30 <__udivdi3+0xe0>
  800d73:	85 db                	test   %ebx,%ebx
  800d75:	89 d9                	mov    %ebx,%ecx
  800d77:	75 0b                	jne    800d84 <__udivdi3+0x34>
  800d79:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7e:	31 d2                	xor    %edx,%edx
  800d80:	f7 f3                	div    %ebx
  800d82:	89 c1                	mov    %eax,%ecx
  800d84:	31 d2                	xor    %edx,%edx
  800d86:	89 f0                	mov    %esi,%eax
  800d88:	f7 f1                	div    %ecx
  800d8a:	89 c6                	mov    %eax,%esi
  800d8c:	89 e8                	mov    %ebp,%eax
  800d8e:	89 f7                	mov    %esi,%edi
  800d90:	f7 f1                	div    %ecx
  800d92:	89 fa                	mov    %edi,%edx
  800d94:	83 c4 1c             	add    $0x1c,%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
  800d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800da0:	39 f2                	cmp    %esi,%edx
  800da2:	77 7c                	ja     800e20 <__udivdi3+0xd0>
  800da4:	0f bd fa             	bsr    %edx,%edi
  800da7:	83 f7 1f             	xor    $0x1f,%edi
  800daa:	0f 84 98 00 00 00    	je     800e48 <__udivdi3+0xf8>
  800db0:	89 f9                	mov    %edi,%ecx
  800db2:	b8 20 00 00 00       	mov    $0x20,%eax
  800db7:	29 f8                	sub    %edi,%eax
  800db9:	d3 e2                	shl    %cl,%edx
  800dbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dbf:	89 c1                	mov    %eax,%ecx
  800dc1:	89 da                	mov    %ebx,%edx
  800dc3:	d3 ea                	shr    %cl,%edx
  800dc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dc9:	09 d1                	or     %edx,%ecx
  800dcb:	89 f2                	mov    %esi,%edx
  800dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	d3 e3                	shl    %cl,%ebx
  800dd5:	89 c1                	mov    %eax,%ecx
  800dd7:	d3 ea                	shr    %cl,%edx
  800dd9:	89 f9                	mov    %edi,%ecx
  800ddb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ddf:	d3 e6                	shl    %cl,%esi
  800de1:	89 eb                	mov    %ebp,%ebx
  800de3:	89 c1                	mov    %eax,%ecx
  800de5:	d3 eb                	shr    %cl,%ebx
  800de7:	09 de                	or     %ebx,%esi
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	f7 74 24 08          	divl   0x8(%esp)
  800def:	89 d6                	mov    %edx,%esi
  800df1:	89 c3                	mov    %eax,%ebx
  800df3:	f7 64 24 0c          	mull   0xc(%esp)
  800df7:	39 d6                	cmp    %edx,%esi
  800df9:	72 0c                	jb     800e07 <__udivdi3+0xb7>
  800dfb:	89 f9                	mov    %edi,%ecx
  800dfd:	d3 e5                	shl    %cl,%ebp
  800dff:	39 c5                	cmp    %eax,%ebp
  800e01:	73 5d                	jae    800e60 <__udivdi3+0x110>
  800e03:	39 d6                	cmp    %edx,%esi
  800e05:	75 59                	jne    800e60 <__udivdi3+0x110>
  800e07:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e0a:	31 ff                	xor    %edi,%edi
  800e0c:	89 fa                	mov    %edi,%edx
  800e0e:	83 c4 1c             	add    $0x1c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
  800e16:	8d 76 00             	lea    0x0(%esi),%esi
  800e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e20:	31 ff                	xor    %edi,%edi
  800e22:	31 c0                	xor    %eax,%eax
  800e24:	89 fa                	mov    %edi,%edx
  800e26:	83 c4 1c             	add    $0x1c,%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    
  800e2e:	66 90                	xchg   %ax,%ax
  800e30:	31 ff                	xor    %edi,%edi
  800e32:	89 e8                	mov    %ebp,%eax
  800e34:	89 f2                	mov    %esi,%edx
  800e36:	f7 f3                	div    %ebx
  800e38:	89 fa                	mov    %edi,%edx
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	72 06                	jb     800e52 <__udivdi3+0x102>
  800e4c:	31 c0                	xor    %eax,%eax
  800e4e:	39 eb                	cmp    %ebp,%ebx
  800e50:	77 d2                	ja     800e24 <__udivdi3+0xd4>
  800e52:	b8 01 00 00 00       	mov    $0x1,%eax
  800e57:	eb cb                	jmp    800e24 <__udivdi3+0xd4>
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 d8                	mov    %ebx,%eax
  800e62:	31 ff                	xor    %edi,%edi
  800e64:	eb be                	jmp    800e24 <__udivdi3+0xd4>
  800e66:	66 90                	xchg   %ax,%ax
  800e68:	66 90                	xchg   %ax,%ax
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__umoddi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 ed                	test   %ebp,%ebp
  800e89:	89 f0                	mov    %esi,%eax
  800e8b:	89 da                	mov    %ebx,%edx
  800e8d:	75 19                	jne    800ea8 <__umoddi3+0x38>
  800e8f:	39 df                	cmp    %ebx,%edi
  800e91:	0f 86 b1 00 00 00    	jbe    800f48 <__umoddi3+0xd8>
  800e97:	f7 f7                	div    %edi
  800e99:	89 d0                	mov    %edx,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	83 c4 1c             	add    $0x1c,%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    
  800ea5:	8d 76 00             	lea    0x0(%esi),%esi
  800ea8:	39 dd                	cmp    %ebx,%ebp
  800eaa:	77 f1                	ja     800e9d <__umoddi3+0x2d>
  800eac:	0f bd cd             	bsr    %ebp,%ecx
  800eaf:	83 f1 1f             	xor    $0x1f,%ecx
  800eb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800eb6:	0f 84 b4 00 00 00    	je     800f70 <__umoddi3+0x100>
  800ebc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ec7:	29 c2                	sub    %eax,%edx
  800ec9:	89 c1                	mov    %eax,%ecx
  800ecb:	89 f8                	mov    %edi,%eax
  800ecd:	d3 e5                	shl    %cl,%ebp
  800ecf:	89 d1                	mov    %edx,%ecx
  800ed1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ed5:	d3 e8                	shr    %cl,%eax
  800ed7:	09 c5                	or     %eax,%ebp
  800ed9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800edd:	89 c1                	mov    %eax,%ecx
  800edf:	d3 e7                	shl    %cl,%edi
  800ee1:	89 d1                	mov    %edx,%ecx
  800ee3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ee7:	89 df                	mov    %ebx,%edi
  800ee9:	d3 ef                	shr    %cl,%edi
  800eeb:	89 c1                	mov    %eax,%ecx
  800eed:	89 f0                	mov    %esi,%eax
  800eef:	d3 e3                	shl    %cl,%ebx
  800ef1:	89 d1                	mov    %edx,%ecx
  800ef3:	89 fa                	mov    %edi,%edx
  800ef5:	d3 e8                	shr    %cl,%eax
  800ef7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800efc:	09 d8                	or     %ebx,%eax
  800efe:	f7 f5                	div    %ebp
  800f00:	d3 e6                	shl    %cl,%esi
  800f02:	89 d1                	mov    %edx,%ecx
  800f04:	f7 64 24 08          	mull   0x8(%esp)
  800f08:	39 d1                	cmp    %edx,%ecx
  800f0a:	89 c3                	mov    %eax,%ebx
  800f0c:	89 d7                	mov    %edx,%edi
  800f0e:	72 06                	jb     800f16 <__umoddi3+0xa6>
  800f10:	75 0e                	jne    800f20 <__umoddi3+0xb0>
  800f12:	39 c6                	cmp    %eax,%esi
  800f14:	73 0a                	jae    800f20 <__umoddi3+0xb0>
  800f16:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f1a:	19 ea                	sbb    %ebp,%edx
  800f1c:	89 d7                	mov    %edx,%edi
  800f1e:	89 c3                	mov    %eax,%ebx
  800f20:	89 ca                	mov    %ecx,%edx
  800f22:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f27:	29 de                	sub    %ebx,%esi
  800f29:	19 fa                	sbb    %edi,%edx
  800f2b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f2f:	89 d0                	mov    %edx,%eax
  800f31:	d3 e0                	shl    %cl,%eax
  800f33:	89 d9                	mov    %ebx,%ecx
  800f35:	d3 ee                	shr    %cl,%esi
  800f37:	d3 ea                	shr    %cl,%edx
  800f39:	09 f0                	or     %esi,%eax
  800f3b:	83 c4 1c             	add    $0x1c,%esp
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    
  800f43:	90                   	nop
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	85 ff                	test   %edi,%edi
  800f4a:	89 f9                	mov    %edi,%ecx
  800f4c:	75 0b                	jne    800f59 <__umoddi3+0xe9>
  800f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f7                	div    %edi
  800f57:	89 c1                	mov    %eax,%ecx
  800f59:	89 d8                	mov    %ebx,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f1                	div    %ecx
  800f5f:	89 f0                	mov    %esi,%eax
  800f61:	f7 f1                	div    %ecx
  800f63:	e9 31 ff ff ff       	jmp    800e99 <__umoddi3+0x29>
  800f68:	90                   	nop
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	39 dd                	cmp    %ebx,%ebp
  800f72:	72 08                	jb     800f7c <__umoddi3+0x10c>
  800f74:	39 f7                	cmp    %esi,%edi
  800f76:	0f 87 21 ff ff ff    	ja     800e9d <__umoddi3+0x2d>
  800f7c:	89 da                	mov    %ebx,%edx
  800f7e:	89 f0                	mov    %esi,%eax
  800f80:	29 f8                	sub    %edi,%eax
  800f82:	19 ea                	sbb    %ebp,%edx
  800f84:	e9 14 ff ff ff       	jmp    800e9d <__umoddi3+0x2d>
