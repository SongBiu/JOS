
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 46 00 00 00       	call   800077 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 34 00 00 00       	call   800073 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	zero = 0;
  800045:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  80004b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	cprintf("1/0 is %08x!\n", 1/zero);
  800051:	b8 01 00 00 00       	mov    $0x1,%eax
  800056:	b9 00 00 00 00       	mov    $0x0,%ecx
  80005b:	99                   	cltd   
  80005c:	f7 f9                	idiv   %ecx
  80005e:	50                   	push   %eax
  80005f:	8d 83 dc ee ff ff    	lea    -0x1124(%ebx),%eax
  800065:	50                   	push   %eax
  800066:	e8 25 01 00 00       	call   800190 <cprintf>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <__x86.get_pc_thunk.bx>:
  800073:	8b 1c 24             	mov    (%esp),%ebx
  800076:	c3                   	ret    

00800077 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	53                   	push   %ebx
  80007b:	83 ec 04             	sub    $0x4,%esp
  80007e:	e8 f0 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800083:	81 c3 7d 1f 00 00    	add    $0x1f7d,%ebx
  800089:	8b 45 08             	mov    0x8(%ebp),%eax
  80008c:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80008f:	c7 c1 30 20 80 00    	mov    $0x802030,%ecx
  800095:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009b:	85 c0                	test   %eax,%eax
  80009d:	7e 08                	jle    8000a7 <libmain+0x30>
		binaryname = argv[0];
  80009f:	8b 0a                	mov    (%edx),%ecx
  8000a1:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a7:	83 ec 08             	sub    $0x8,%esp
  8000aa:	52                   	push   %edx
  8000ab:	50                   	push   %eax
  8000ac:	e8 82 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b1:	e8 08 00 00 00       	call   8000be <exit>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 10             	sub    $0x10,%esp
  8000c5:	e8 a9 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8000ca:	81 c3 36 1f 00 00    	add    $0x1f36,%ebx
	sys_env_destroy(0);
  8000d0:	6a 00                	push   $0x0
  8000d2:	e8 f3 0a 00 00       	call   800bca <sys_env_destroy>
}
  8000d7:	83 c4 10             	add    $0x10,%esp
  8000da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000dd:	c9                   	leave  
  8000de:	c3                   	ret    

008000df <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	e8 8a ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8000e9:	81 c3 17 1f 00 00    	add    $0x1f17,%ebx
  8000ef:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f2:	8b 16                	mov    (%esi),%edx
  8000f4:	8d 42 01             	lea    0x1(%edx),%eax
  8000f7:	89 06                	mov    %eax,(%esi)
  8000f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fc:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800100:	3d ff 00 00 00       	cmp    $0xff,%eax
  800105:	74 0b                	je     800112 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800107:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80010b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800112:	83 ec 08             	sub    $0x8,%esp
  800115:	68 ff 00 00 00       	push   $0xff
  80011a:	8d 46 08             	lea    0x8(%esi),%eax
  80011d:	50                   	push   %eax
  80011e:	e8 6a 0a 00 00       	call   800b8d <sys_cputs>
		b->idx = 0;
  800123:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	eb d9                	jmp    800107 <putch+0x28>

0080012e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	53                   	push   %ebx
  800132:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800138:	e8 36 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  80013d:	81 c3 c3 1e 00 00    	add    $0x1ec3,%ebx
	struct printbuf b;

	b.idx = 0;
  800143:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014a:	00 00 00 
	b.cnt = 0;
  80014d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800154:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800157:	ff 75 0c             	pushl  0xc(%ebp)
  80015a:	ff 75 08             	pushl  0x8(%ebp)
  80015d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800163:	50                   	push   %eax
  800164:	8d 83 df e0 ff ff    	lea    -0x1f21(%ebx),%eax
  80016a:	50                   	push   %eax
  80016b:	e8 38 01 00 00       	call   8002a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800170:	83 c4 08             	add    $0x8,%esp
  800173:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800179:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017f:	50                   	push   %eax
  800180:	e8 08 0a 00 00       	call   800b8d <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800199:	50                   	push   %eax
  80019a:	ff 75 08             	pushl  0x8(%ebp)
  80019d:	e8 8c ff ff ff       	call   80012e <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 2c             	sub    $0x2c,%esp
  8001ad:	e8 63 06 00 00       	call   800815 <__x86.get_pc_thunk.cx>
  8001b2:	81 c1 4e 1e 00 00    	add    $0x1e4e,%ecx
  8001b8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001bb:	89 c7                	mov    %eax,%edi
  8001bd:	89 d6                	mov    %edx,%esi
  8001bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d3:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001d6:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001d9:	39 d3                	cmp    %edx,%ebx
  8001db:	72 09                	jb     8001e6 <printnum+0x42>
  8001dd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e0:	0f 87 83 00 00 00    	ja     800269 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e6:	83 ec 0c             	sub    $0xc,%esp
  8001e9:	ff 75 18             	pushl  0x18(%ebp)
  8001ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ef:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f2:	53                   	push   %ebx
  8001f3:	ff 75 10             	pushl  0x10(%ebp)
  8001f6:	83 ec 08             	sub    $0x8,%esp
  8001f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  800202:	ff 75 d0             	pushl  -0x30(%ebp)
  800205:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800208:	e8 93 0a 00 00       	call   800ca0 <__udivdi3>
  80020d:	83 c4 18             	add    $0x18,%esp
  800210:	52                   	push   %edx
  800211:	50                   	push   %eax
  800212:	89 f2                	mov    %esi,%edx
  800214:	89 f8                	mov    %edi,%eax
  800216:	e8 89 ff ff ff       	call   8001a4 <printnum>
  80021b:	83 c4 20             	add    $0x20,%esp
  80021e:	eb 13                	jmp    800233 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800220:	83 ec 08             	sub    $0x8,%esp
  800223:	56                   	push   %esi
  800224:	ff 75 18             	pushl  0x18(%ebp)
  800227:	ff d7                	call   *%edi
  800229:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022c:	83 eb 01             	sub    $0x1,%ebx
  80022f:	85 db                	test   %ebx,%ebx
  800231:	7f ed                	jg     800220 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	83 ec 04             	sub    $0x4,%esp
  80023a:	ff 75 dc             	pushl  -0x24(%ebp)
  80023d:	ff 75 d8             	pushl  -0x28(%ebp)
  800240:	ff 75 d4             	pushl  -0x2c(%ebp)
  800243:	ff 75 d0             	pushl  -0x30(%ebp)
  800246:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800249:	89 f3                	mov    %esi,%ebx
  80024b:	e8 70 0b 00 00       	call   800dc0 <__umoddi3>
  800250:	83 c4 14             	add    $0x14,%esp
  800253:	0f be 84 06 f4 ee ff 	movsbl -0x110c(%esi,%eax,1),%eax
  80025a:	ff 
  80025b:	50                   	push   %eax
  80025c:	ff d7                	call   *%edi
}
  80025e:	83 c4 10             	add    $0x10,%esp
  800261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800264:	5b                   	pop    %ebx
  800265:	5e                   	pop    %esi
  800266:	5f                   	pop    %edi
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    
  800269:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026c:	eb be                	jmp    80022c <printnum+0x88>

0080026e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800274:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800278:	8b 10                	mov    (%eax),%edx
  80027a:	3b 50 04             	cmp    0x4(%eax),%edx
  80027d:	73 0a                	jae    800289 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 45 08             	mov    0x8(%ebp),%eax
  800287:	88 02                	mov    %al,(%edx)
}
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <printfmt>:
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800291:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800294:	50                   	push   %eax
  800295:	ff 75 10             	pushl  0x10(%ebp)
  800298:	ff 75 0c             	pushl  0xc(%ebp)
  80029b:	ff 75 08             	pushl  0x8(%ebp)
  80029e:	e8 05 00 00 00       	call   8002a8 <vprintfmt>
}
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <vprintfmt>:
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 2c             	sub    $0x2c,%esp
  8002b1:	e8 bd fd ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8002b6:	81 c3 4a 1d 00 00    	add    $0x1d4a,%ebx
  8002bc:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8002bf:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8002c6:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c8:	8d 77 01             	lea    0x1(%edi),%esi
  8002cb:	0f b6 07             	movzbl (%edi),%eax
  8002ce:	83 f8 25             	cmp    $0x25,%eax
  8002d1:	74 1c                	je     8002ef <vprintfmt+0x47>
			if (ch == '\0')
  8002d3:	85 c0                	test   %eax,%eax
  8002d5:	0f 84 b9 04 00 00    	je     800794 <.L21+0x20>
			putch(ch, putdat);
  8002db:	83 ec 08             	sub    $0x8,%esp
  8002de:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8002e1:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8002e4:	50                   	push   %eax
  8002e5:	ff 55 08             	call   *0x8(%ebp)
  8002e8:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002eb:	89 f7                	mov    %esi,%edi
  8002ed:	eb d9                	jmp    8002c8 <vprintfmt+0x20>
		padc = ' ';
  8002ef:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8002f3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002fa:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800301:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800308:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8d 7e 01             	lea    0x1(%esi),%edi
  800313:	0f b6 16             	movzbl (%esi),%edx
  800316:	8d 42 dd             	lea    -0x23(%edx),%eax
  800319:	3c 55                	cmp    $0x55,%al
  80031b:	0f 87 53 04 00 00    	ja     800774 <.L21>
  800321:	0f b6 c0             	movzbl %al,%eax
  800324:	89 d9                	mov    %ebx,%ecx
  800326:	03 8c 83 84 ef ff ff 	add    -0x107c(%ebx,%eax,4),%ecx
  80032d:	ff e1                	jmp    *%ecx

0080032f <.L73>:
  80032f:	89 fe                	mov    %edi,%esi
			padc = '-';
  800331:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800335:	eb d9                	jmp    800310 <vprintfmt+0x68>

00800337 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800337:	89 fe                	mov    %edi,%esi
			padc = '0';
  800339:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80033d:	eb d1                	jmp    800310 <vprintfmt+0x68>

0080033f <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	0f b6 d2             	movzbl %dl,%edx
  800342:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800344:	b8 00 00 00 00       	mov    $0x0,%eax
  800349:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  80034c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800353:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800356:	8d 7a d0             	lea    -0x30(%edx),%edi
  800359:	83 ff 09             	cmp    $0x9,%edi
  80035c:	0f 87 94 00 00 00    	ja     8003f6 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800362:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800365:	eb e5                	jmp    80034c <.L28+0xd>

00800367 <.L25>:
			precision = va_arg(ap, int);
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8b 00                	mov    (%eax),%eax
  80036c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80036f:	8b 45 14             	mov    0x14(%ebp),%eax
  800372:	8d 40 04             	lea    0x4(%eax),%eax
  800375:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800378:	89 fe                	mov    %edi,%esi
			if (width < 0)
  80037a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037e:	79 90                	jns    800310 <vprintfmt+0x68>
				width = precision, precision = -1;
  800380:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800386:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80038d:	eb 81                	jmp    800310 <vprintfmt+0x68>

0080038f <.L26>:
  80038f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800392:	85 c0                	test   %eax,%eax
  800394:	ba 00 00 00 00       	mov    $0x0,%edx
  800399:	0f 49 d0             	cmovns %eax,%edx
  80039c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	89 fe                	mov    %edi,%esi
  8003a1:	e9 6a ff ff ff       	jmp    800310 <vprintfmt+0x68>

008003a6 <.L22>:
  8003a6:	89 fe                	mov    %edi,%esi
			altflag = 1;
  8003a8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003af:	e9 5c ff ff ff       	jmp    800310 <vprintfmt+0x68>

008003b4 <.L33>:
  8003b4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8003b7:	83 f9 01             	cmp    $0x1,%ecx
  8003ba:	7e 16                	jle    8003d2 <.L33+0x1e>
		return va_arg(*ap, long long);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003c4:	8d 49 08             	lea    0x8(%ecx),%ecx
  8003c7:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8003ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8003cd:	e9 f6 fe ff ff       	jmp    8002c8 <vprintfmt+0x20>
	else if (lflag)
  8003d2:	85 c9                	test   %ecx,%ecx
  8003d4:	75 10                	jne    8003e6 <.L33+0x32>
		return va_arg(*ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8b 00                	mov    (%eax),%eax
  8003db:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003de:	8d 49 04             	lea    0x4(%ecx),%ecx
  8003e1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e4:	eb e4                	jmp    8003ca <.L33+0x16>
		return va_arg(*ap, long);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8b 00                	mov    (%eax),%eax
  8003eb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003ee:	8d 49 04             	lea    0x4(%ecx),%ecx
  8003f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f4:	eb d4                	jmp    8003ca <.L33+0x16>
  8003f6:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003f9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003fc:	e9 79 ff ff ff       	jmp    80037a <.L25+0x13>

00800401 <.L32>:
			lflag++;
  800401:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800405:	89 fe                	mov    %edi,%esi
			goto reswitch;
  800407:	e9 04 ff ff ff       	jmp    800310 <vprintfmt+0x68>

0080040c <.L29>:
			putch(va_arg(ap, int), putdat);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 70 04             	lea    0x4(%eax),%esi
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	ff 75 0c             	pushl  0xc(%ebp)
  800418:	ff 30                	pushl  (%eax)
  80041a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80041d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800420:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800423:	e9 a0 fe ff ff       	jmp    8002c8 <vprintfmt+0x20>

00800428 <.L31>:
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 70 04             	lea    0x4(%eax),%esi
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 06             	cmp    $0x6,%eax
  800438:	7f 29                	jg     800463 <.L31+0x3b>
  80043a:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	74 1e                	je     800463 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800445:	52                   	push   %edx
  800446:	8d 83 15 ef ff ff    	lea    -0x10eb(%ebx),%eax
  80044c:	50                   	push   %eax
  80044d:	ff 75 0c             	pushl  0xc(%ebp)
  800450:	ff 75 08             	pushl  0x8(%ebp)
  800453:	e8 33 fe ff ff       	call   80028b <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045b:	89 75 14             	mov    %esi,0x14(%ebp)
  80045e:	e9 65 fe ff ff       	jmp    8002c8 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800463:	50                   	push   %eax
  800464:	8d 83 0c ef ff ff    	lea    -0x10f4(%ebx),%eax
  80046a:	50                   	push   %eax
  80046b:	ff 75 0c             	pushl  0xc(%ebp)
  80046e:	ff 75 08             	pushl  0x8(%ebp)
  800471:	e8 15 fe ff ff       	call   80028b <printfmt>
  800476:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800479:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80047c:	e9 47 fe ff ff       	jmp    8002c8 <vprintfmt+0x20>

00800481 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	83 c0 04             	add    $0x4,%eax
  800487:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80048f:	85 f6                	test   %esi,%esi
  800491:	8d 83 05 ef ff ff    	lea    -0x10fb(%ebx),%eax
  800497:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80049a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049e:	0f 8e b4 00 00 00    	jle    800558 <.L36+0xd7>
  8004a4:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8004a8:	75 08                	jne    8004b2 <.L36+0x31>
  8004aa:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004ad:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004b0:	eb 6c                	jmp    80051e <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b8:	56                   	push   %esi
  8004b9:	e8 73 03 00 00       	call   800831 <strnlen>
  8004be:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c1:	29 c2                	sub    %eax,%edx
  8004c3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004c9:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004cd:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004d0:	89 d6                	mov    %edx,%esi
  8004d2:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004d5:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	eb 10                	jmp    8004e9 <.L36+0x68>
					putch(padc, putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	ff 75 0c             	pushl  0xc(%ebp)
  8004df:	57                   	push   %edi
  8004e0:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e3:	83 ee 01             	sub    $0x1,%esi
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	85 f6                	test   %esi,%esi
  8004eb:	7f ec                	jg     8004d9 <.L36+0x58>
  8004ed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fa:	0f 49 c2             	cmovns %edx,%eax
  8004fd:	29 c2                	sub    %eax,%edx
  8004ff:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800502:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800505:	eb 17                	jmp    80051e <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  800507:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050b:	75 30                	jne    80053d <.L36+0xbc>
					putch(ch, putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	ff 75 0c             	pushl  0xc(%ebp)
  800513:	50                   	push   %eax
  800514:	ff 55 08             	call   *0x8(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051a:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80051e:	83 c6 01             	add    $0x1,%esi
  800521:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800525:	0f be c2             	movsbl %dl,%eax
  800528:	85 c0                	test   %eax,%eax
  80052a:	74 58                	je     800584 <.L36+0x103>
  80052c:	85 ff                	test   %edi,%edi
  80052e:	78 d7                	js     800507 <.L36+0x86>
  800530:	83 ef 01             	sub    $0x1,%edi
  800533:	79 d2                	jns    800507 <.L36+0x86>
  800535:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800538:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80053b:	eb 32                	jmp    80056f <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  80053d:	0f be d2             	movsbl %dl,%edx
  800540:	83 ea 20             	sub    $0x20,%edx
  800543:	83 fa 5e             	cmp    $0x5e,%edx
  800546:	76 c5                	jbe    80050d <.L36+0x8c>
					putch('?', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	ff 75 0c             	pushl  0xc(%ebp)
  80054e:	6a 3f                	push   $0x3f
  800550:	ff 55 08             	call   *0x8(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb c2                	jmp    80051a <.L36+0x99>
  800558:	89 7d 10             	mov    %edi,0x10(%ebp)
  80055b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80055e:	eb be                	jmp    80051e <.L36+0x9d>
				putch(' ', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	57                   	push   %edi
  800564:	6a 20                	push   $0x20
  800566:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800569:	83 ee 01             	sub    $0x1,%esi
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	85 f6                	test   %esi,%esi
  800571:	7f ed                	jg     800560 <.L36+0xdf>
  800573:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800576:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800579:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
  80057f:	e9 44 fd ff ff       	jmp    8002c8 <vprintfmt+0x20>
  800584:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800587:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80058a:	eb e3                	jmp    80056f <.L36+0xee>

0080058c <.L30>:
  80058c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80058f:	83 f9 01             	cmp    $0x1,%ecx
  800592:	7e 42                	jle    8005d6 <.L30+0x4a>
		return va_arg(*ap, long long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 50 04             	mov    0x4(%eax),%edx
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 40 08             	lea    0x8(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ab:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005af:	79 5f                	jns    800610 <.L30+0x84>
				putch('-', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	ff 75 0c             	pushl  0xc(%ebp)
  8005b7:	6a 2d                	push   $0x2d
  8005b9:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c2:	f7 da                	neg    %edx
  8005c4:	83 d1 00             	adc    $0x0,%ecx
  8005c7:	f7 d9                	neg    %ecx
  8005c9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d1:	e9 b8 00 00 00       	jmp    80068e <.L34+0x22>
	else if (lflag)
  8005d6:	85 c9                	test   %ecx,%ecx
  8005d8:	75 1b                	jne    8005f5 <.L30+0x69>
		return va_arg(*ap, int);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 30                	mov    (%eax),%esi
  8005df:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005e2:	89 f0                	mov    %esi,%eax
  8005e4:	c1 f8 1f             	sar    $0x1f,%eax
  8005e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 40 04             	lea    0x4(%eax),%eax
  8005f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f3:	eb b6                	jmp    8005ab <.L30+0x1f>
		return va_arg(*ap, long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 30                	mov    (%eax),%esi
  8005fa:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005fd:	89 f0                	mov    %esi,%eax
  8005ff:	c1 f8 1f             	sar    $0x1f,%eax
  800602:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 40 04             	lea    0x4(%eax),%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)
  80060e:	eb 9b                	jmp    8005ab <.L30+0x1f>
			num = getint(&ap, lflag);
  800610:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800613:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061b:	eb 71                	jmp    80068e <.L34+0x22>

0080061d <.L37>:
  80061d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800620:	83 f9 01             	cmp    $0x1,%ecx
  800623:	7e 15                	jle    80063a <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 10                	mov    (%eax),%edx
  80062a:	8b 48 04             	mov    0x4(%eax),%ecx
  80062d:	8d 40 08             	lea    0x8(%eax),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800633:	b8 0a 00 00 00       	mov    $0xa,%eax
  800638:	eb 54                	jmp    80068e <.L34+0x22>
	else if (lflag)
  80063a:	85 c9                	test   %ecx,%ecx
  80063c:	75 17                	jne    800655 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 10                	mov    (%eax),%edx
  800643:	b9 00 00 00 00       	mov    $0x0,%ecx
  800648:	8d 40 04             	lea    0x4(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800653:	eb 39                	jmp    80068e <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065f:	8d 40 04             	lea    0x4(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800665:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066a:	eb 22                	jmp    80068e <.L34+0x22>

0080066c <.L34>:
  80066c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80066f:	83 f9 01             	cmp    $0x1,%ecx
  800672:	7e 3b                	jle    8006af <.L34+0x43>
		return va_arg(*ap, long long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 50 04             	mov    0x4(%eax),%edx
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80067f:	8d 49 08             	lea    0x8(%ecx),%ecx
  800682:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800685:	89 d1                	mov    %edx,%ecx
  800687:	89 c2                	mov    %eax,%edx
			base = 8;
  800689:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80068e:	83 ec 0c             	sub    $0xc,%esp
  800691:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800695:	56                   	push   %esi
  800696:	ff 75 e0             	pushl  -0x20(%ebp)
  800699:	50                   	push   %eax
  80069a:	51                   	push   %ecx
  80069b:	52                   	push   %edx
  80069c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80069f:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a2:	e8 fd fa ff ff       	call   8001a4 <printnum>
			break;
  8006a7:	83 c4 20             	add    $0x20,%esp
  8006aa:	e9 19 fc ff ff       	jmp    8002c8 <vprintfmt+0x20>
	else if (lflag)
  8006af:	85 c9                	test   %ecx,%ecx
  8006b1:	75 13                	jne    8006c6 <.L34+0x5a>
		return va_arg(*ap, int);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 10                	mov    (%eax),%edx
  8006b8:	89 d0                	mov    %edx,%eax
  8006ba:	99                   	cltd   
  8006bb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006be:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006c1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c4:	eb bf                	jmp    800685 <.L34+0x19>
		return va_arg(*ap, long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 10                	mov    (%eax),%edx
  8006cb:	89 d0                	mov    %edx,%eax
  8006cd:	99                   	cltd   
  8006ce:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006d1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006d7:	eb ac                	jmp    800685 <.L34+0x19>

008006d9 <.L35>:
			putch('0', putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	6a 30                	push   $0x30
  8006e1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006e4:	83 c4 08             	add    $0x8,%esp
  8006e7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ea:	6a 78                	push   $0x78
  8006ec:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 10                	mov    (%eax),%edx
  8006f4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006f9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006fc:	8d 40 04             	lea    0x4(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800702:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800707:	eb 85                	jmp    80068e <.L34+0x22>

00800709 <.L38>:
  800709:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80070c:	83 f9 01             	cmp    $0x1,%ecx
  80070f:	7e 18                	jle    800729 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	8b 48 04             	mov    0x4(%eax),%ecx
  800719:	8d 40 08             	lea    0x8(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071f:	b8 10 00 00 00       	mov    $0x10,%eax
  800724:	e9 65 ff ff ff       	jmp    80068e <.L34+0x22>
	else if (lflag)
  800729:	85 c9                	test   %ecx,%ecx
  80072b:	75 1a                	jne    800747 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  80072d:	8b 45 14             	mov    0x14(%ebp),%eax
  800730:	8b 10                	mov    (%eax),%edx
  800732:	b9 00 00 00 00       	mov    $0x0,%ecx
  800737:	8d 40 04             	lea    0x4(%eax),%eax
  80073a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073d:	b8 10 00 00 00       	mov    $0x10,%eax
  800742:	e9 47 ff ff ff       	jmp    80068e <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8b 10                	mov    (%eax),%edx
  80074c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800751:	8d 40 04             	lea    0x4(%eax),%eax
  800754:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800757:	b8 10 00 00 00       	mov    $0x10,%eax
  80075c:	e9 2d ff ff ff       	jmp    80068e <.L34+0x22>

00800761 <.L24>:
			putch(ch, putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	ff 75 0c             	pushl  0xc(%ebp)
  800767:	6a 25                	push   $0x25
  800769:	ff 55 08             	call   *0x8(%ebp)
			break;
  80076c:	83 c4 10             	add    $0x10,%esp
  80076f:	e9 54 fb ff ff       	jmp    8002c8 <vprintfmt+0x20>

00800774 <.L21>:
			putch('%', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	ff 75 0c             	pushl  0xc(%ebp)
  80077a:	6a 25                	push   $0x25
  80077c:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	89 f7                	mov    %esi,%edi
  800784:	eb 03                	jmp    800789 <.L21+0x15>
  800786:	83 ef 01             	sub    $0x1,%edi
  800789:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80078d:	75 f7                	jne    800786 <.L21+0x12>
  80078f:	e9 34 fb ff ff       	jmp    8002c8 <vprintfmt+0x20>
}
  800794:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800797:	5b                   	pop    %ebx
  800798:	5e                   	pop    %esi
  800799:	5f                   	pop    %edi
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	83 ec 14             	sub    $0x14,%esp
  8007a3:	e8 cb f8 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8007a8:	81 c3 58 18 00 00    	add    $0x1858,%ebx
  8007ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c5:	85 c0                	test   %eax,%eax
  8007c7:	74 2b                	je     8007f4 <vsnprintf+0x58>
  8007c9:	85 d2                	test   %edx,%edx
  8007cb:	7e 27                	jle    8007f4 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cd:	ff 75 14             	pushl  0x14(%ebp)
  8007d0:	ff 75 10             	pushl  0x10(%ebp)
  8007d3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d6:	50                   	push   %eax
  8007d7:	8d 83 6e e2 ff ff    	lea    -0x1d92(%ebx),%eax
  8007dd:	50                   	push   %eax
  8007de:	e8 c5 fa ff ff       	call   8002a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ec:	83 c4 10             	add    $0x10,%esp
}
  8007ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f2:	c9                   	leave  
  8007f3:	c3                   	ret    
		return -E_INVAL;
  8007f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f9:	eb f4                	jmp    8007ef <vsnprintf+0x53>

008007fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800801:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800804:	50                   	push   %eax
  800805:	ff 75 10             	pushl  0x10(%ebp)
  800808:	ff 75 0c             	pushl  0xc(%ebp)
  80080b:	ff 75 08             	pushl  0x8(%ebp)
  80080e:	e8 89 ff ff ff       	call   80079c <vsnprintf>
	va_end(ap);

	return rc;
}
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <__x86.get_pc_thunk.cx>:
  800815:	8b 0c 24             	mov    (%esp),%ecx
  800818:	c3                   	ret    

00800819 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	eb 03                	jmp    800829 <strlen+0x10>
		n++;
  800826:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800829:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082d:	75 f7                	jne    800826 <strlen+0xd>
	return n;
}
  80082f:	5d                   	pop    %ebp
  800830:	c3                   	ret    

00800831 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
  80083f:	eb 03                	jmp    800844 <strnlen+0x13>
		n++;
  800841:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800844:	39 d0                	cmp    %edx,%eax
  800846:	74 06                	je     80084e <strnlen+0x1d>
  800848:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084c:	75 f3                	jne    800841 <strnlen+0x10>
	return n;
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085a:	89 c2                	mov    %eax,%edx
  80085c:	83 c1 01             	add    $0x1,%ecx
  80085f:	83 c2 01             	add    $0x1,%edx
  800862:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800866:	88 5a ff             	mov    %bl,-0x1(%edx)
  800869:	84 db                	test   %bl,%bl
  80086b:	75 ef                	jne    80085c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086d:	5b                   	pop    %ebx
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	53                   	push   %ebx
  800874:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800877:	53                   	push   %ebx
  800878:	e8 9c ff ff ff       	call   800819 <strlen>
  80087d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800880:	ff 75 0c             	pushl  0xc(%ebp)
  800883:	01 d8                	add    %ebx,%eax
  800885:	50                   	push   %eax
  800886:	e8 c5 ff ff ff       	call   800850 <strcpy>
	return dst;
}
  80088b:	89 d8                	mov    %ebx,%eax
  80088d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
  800897:	8b 75 08             	mov    0x8(%ebp),%esi
  80089a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089d:	89 f3                	mov    %esi,%ebx
  80089f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a2:	89 f2                	mov    %esi,%edx
  8008a4:	eb 0f                	jmp    8008b5 <strncpy+0x23>
		*dst++ = *src;
  8008a6:	83 c2 01             	add    $0x1,%edx
  8008a9:	0f b6 01             	movzbl (%ecx),%eax
  8008ac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008af:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b2:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008b5:	39 da                	cmp    %ebx,%edx
  8008b7:	75 ed                	jne    8008a6 <strncpy+0x14>
	}
	return ret;
}
  8008b9:	89 f0                	mov    %esi,%eax
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	56                   	push   %esi
  8008c3:	53                   	push   %ebx
  8008c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008cd:	89 f0                	mov    %esi,%eax
  8008cf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d3:	85 c9                	test   %ecx,%ecx
  8008d5:	75 0b                	jne    8008e2 <strlcpy+0x23>
  8008d7:	eb 17                	jmp    8008f0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008d9:	83 c2 01             	add    $0x1,%edx
  8008dc:	83 c0 01             	add    $0x1,%eax
  8008df:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008e2:	39 d8                	cmp    %ebx,%eax
  8008e4:	74 07                	je     8008ed <strlcpy+0x2e>
  8008e6:	0f b6 0a             	movzbl (%edx),%ecx
  8008e9:	84 c9                	test   %cl,%cl
  8008eb:	75 ec                	jne    8008d9 <strlcpy+0x1a>
		*dst = '\0';
  8008ed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f0:	29 f0                	sub    %esi,%eax
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ff:	eb 06                	jmp    800907 <strcmp+0x11>
		p++, q++;
  800901:	83 c1 01             	add    $0x1,%ecx
  800904:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800907:	0f b6 01             	movzbl (%ecx),%eax
  80090a:	84 c0                	test   %al,%al
  80090c:	74 04                	je     800912 <strcmp+0x1c>
  80090e:	3a 02                	cmp    (%edx),%al
  800910:	74 ef                	je     800901 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800912:	0f b6 c0             	movzbl %al,%eax
  800915:	0f b6 12             	movzbl (%edx),%edx
  800918:	29 d0                	sub    %edx,%eax
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	53                   	push   %ebx
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
  800926:	89 c3                	mov    %eax,%ebx
  800928:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092b:	eb 06                	jmp    800933 <strncmp+0x17>
		n--, p++, q++;
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800933:	39 d8                	cmp    %ebx,%eax
  800935:	74 16                	je     80094d <strncmp+0x31>
  800937:	0f b6 08             	movzbl (%eax),%ecx
  80093a:	84 c9                	test   %cl,%cl
  80093c:	74 04                	je     800942 <strncmp+0x26>
  80093e:	3a 0a                	cmp    (%edx),%cl
  800940:	74 eb                	je     80092d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800942:	0f b6 00             	movzbl (%eax),%eax
  800945:	0f b6 12             	movzbl (%edx),%edx
  800948:	29 d0                	sub    %edx,%eax
}
  80094a:	5b                   	pop    %ebx
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    
		return 0;
  80094d:	b8 00 00 00 00       	mov    $0x0,%eax
  800952:	eb f6                	jmp    80094a <strncmp+0x2e>

00800954 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095e:	0f b6 10             	movzbl (%eax),%edx
  800961:	84 d2                	test   %dl,%dl
  800963:	74 09                	je     80096e <strchr+0x1a>
		if (*s == c)
  800965:	38 ca                	cmp    %cl,%dl
  800967:	74 0a                	je     800973 <strchr+0x1f>
	for (; *s; s++)
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	eb f0                	jmp    80095e <strchr+0xa>
			return (char *) s;
	return 0;
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097f:	eb 03                	jmp    800984 <strfind+0xf>
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800987:	38 ca                	cmp    %cl,%dl
  800989:	74 04                	je     80098f <strfind+0x1a>
  80098b:	84 d2                	test   %dl,%dl
  80098d:	75 f2                	jne    800981 <strfind+0xc>
			break;
	return (char *) s;
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	57                   	push   %edi
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099d:	85 c9                	test   %ecx,%ecx
  80099f:	74 13                	je     8009b4 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a7:	75 05                	jne    8009ae <memset+0x1d>
  8009a9:	f6 c1 03             	test   $0x3,%cl
  8009ac:	74 0d                	je     8009bb <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b1:	fc                   	cld    
  8009b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b4:	89 f8                	mov    %edi,%eax
  8009b6:	5b                   	pop    %ebx
  8009b7:	5e                   	pop    %esi
  8009b8:	5f                   	pop    %edi
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    
		c &= 0xFF;
  8009bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bf:	89 d3                	mov    %edx,%ebx
  8009c1:	c1 e3 08             	shl    $0x8,%ebx
  8009c4:	89 d0                	mov    %edx,%eax
  8009c6:	c1 e0 18             	shl    $0x18,%eax
  8009c9:	89 d6                	mov    %edx,%esi
  8009cb:	c1 e6 10             	shl    $0x10,%esi
  8009ce:	09 f0                	or     %esi,%eax
  8009d0:	09 c2                	or     %eax,%edx
  8009d2:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d7:	89 d0                	mov    %edx,%eax
  8009d9:	fc                   	cld    
  8009da:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dc:	eb d6                	jmp    8009b4 <memset+0x23>

008009de <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	57                   	push   %edi
  8009e2:	56                   	push   %esi
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ec:	39 c6                	cmp    %eax,%esi
  8009ee:	73 35                	jae    800a25 <memmove+0x47>
  8009f0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f3:	39 c2                	cmp    %eax,%edx
  8009f5:	76 2e                	jbe    800a25 <memmove+0x47>
		s += n;
		d += n;
  8009f7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fa:	89 d6                	mov    %edx,%esi
  8009fc:	09 fe                	or     %edi,%esi
  8009fe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a04:	74 0c                	je     800a12 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a06:	83 ef 01             	sub    $0x1,%edi
  800a09:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a0c:	fd                   	std    
  800a0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0f:	fc                   	cld    
  800a10:	eb 21                	jmp    800a33 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a12:	f6 c1 03             	test   $0x3,%cl
  800a15:	75 ef                	jne    800a06 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a17:	83 ef 04             	sub    $0x4,%edi
  800a1a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a20:	fd                   	std    
  800a21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a23:	eb ea                	jmp    800a0f <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a25:	89 f2                	mov    %esi,%edx
  800a27:	09 c2                	or     %eax,%edx
  800a29:	f6 c2 03             	test   $0x3,%dl
  800a2c:	74 09                	je     800a37 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2e:	89 c7                	mov    %eax,%edi
  800a30:	fc                   	cld    
  800a31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a37:	f6 c1 03             	test   $0x3,%cl
  800a3a:	75 f2                	jne    800a2e <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a3f:	89 c7                	mov    %eax,%edi
  800a41:	fc                   	cld    
  800a42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a44:	eb ed                	jmp    800a33 <memmove+0x55>

00800a46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a49:	ff 75 10             	pushl  0x10(%ebp)
  800a4c:	ff 75 0c             	pushl  0xc(%ebp)
  800a4f:	ff 75 08             	pushl  0x8(%ebp)
  800a52:	e8 87 ff ff ff       	call   8009de <memmove>
}
  800a57:	c9                   	leave  
  800a58:	c3                   	ret    

00800a59 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a64:	89 c6                	mov    %eax,%esi
  800a66:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a69:	39 f0                	cmp    %esi,%eax
  800a6b:	74 1c                	je     800a89 <memcmp+0x30>
		if (*s1 != *s2)
  800a6d:	0f b6 08             	movzbl (%eax),%ecx
  800a70:	0f b6 1a             	movzbl (%edx),%ebx
  800a73:	38 d9                	cmp    %bl,%cl
  800a75:	75 08                	jne    800a7f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a77:	83 c0 01             	add    $0x1,%eax
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	eb ea                	jmp    800a69 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a7f:	0f b6 c1             	movzbl %cl,%eax
  800a82:	0f b6 db             	movzbl %bl,%ebx
  800a85:	29 d8                	sub    %ebx,%eax
  800a87:	eb 05                	jmp    800a8e <memcmp+0x35>
	}

	return 0;
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9b:	89 c2                	mov    %eax,%edx
  800a9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa0:	39 d0                	cmp    %edx,%eax
  800aa2:	73 09                	jae    800aad <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa4:	38 08                	cmp    %cl,(%eax)
  800aa6:	74 05                	je     800aad <memfind+0x1b>
	for (; s < ends; s++)
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	eb f3                	jmp    800aa0 <memfind+0xe>
			break;
	return (void *) s;
}
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	57                   	push   %edi
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abb:	eb 03                	jmp    800ac0 <strtol+0x11>
		s++;
  800abd:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac0:	0f b6 01             	movzbl (%ecx),%eax
  800ac3:	3c 20                	cmp    $0x20,%al
  800ac5:	74 f6                	je     800abd <strtol+0xe>
  800ac7:	3c 09                	cmp    $0x9,%al
  800ac9:	74 f2                	je     800abd <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800acb:	3c 2b                	cmp    $0x2b,%al
  800acd:	74 2e                	je     800afd <strtol+0x4e>
	int neg = 0;
  800acf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad4:	3c 2d                	cmp    $0x2d,%al
  800ad6:	74 2f                	je     800b07 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ade:	75 05                	jne    800ae5 <strtol+0x36>
  800ae0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae3:	74 2c                	je     800b11 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae5:	85 db                	test   %ebx,%ebx
  800ae7:	75 0a                	jne    800af3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ae9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aee:	80 39 30             	cmpb   $0x30,(%ecx)
  800af1:	74 28                	je     800b1b <strtol+0x6c>
		base = 10;
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800afb:	eb 50                	jmp    800b4d <strtol+0x9e>
		s++;
  800afd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b00:	bf 00 00 00 00       	mov    $0x0,%edi
  800b05:	eb d1                	jmp    800ad8 <strtol+0x29>
		s++, neg = 1;
  800b07:	83 c1 01             	add    $0x1,%ecx
  800b0a:	bf 01 00 00 00       	mov    $0x1,%edi
  800b0f:	eb c7                	jmp    800ad8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b11:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b15:	74 0e                	je     800b25 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	75 d8                	jne    800af3 <strtol+0x44>
		s++, base = 8;
  800b1b:	83 c1 01             	add    $0x1,%ecx
  800b1e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b23:	eb ce                	jmp    800af3 <strtol+0x44>
		s += 2, base = 16;
  800b25:	83 c1 02             	add    $0x2,%ecx
  800b28:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2d:	eb c4                	jmp    800af3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b2f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b32:	89 f3                	mov    %esi,%ebx
  800b34:	80 fb 19             	cmp    $0x19,%bl
  800b37:	77 29                	ja     800b62 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b39:	0f be d2             	movsbl %dl,%edx
  800b3c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b3f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b42:	7d 30                	jge    800b74 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b44:	83 c1 01             	add    $0x1,%ecx
  800b47:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b4d:	0f b6 11             	movzbl (%ecx),%edx
  800b50:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b53:	89 f3                	mov    %esi,%ebx
  800b55:	80 fb 09             	cmp    $0x9,%bl
  800b58:	77 d5                	ja     800b2f <strtol+0x80>
			dig = *s - '0';
  800b5a:	0f be d2             	movsbl %dl,%edx
  800b5d:	83 ea 30             	sub    $0x30,%edx
  800b60:	eb dd                	jmp    800b3f <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b62:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b65:	89 f3                	mov    %esi,%ebx
  800b67:	80 fb 19             	cmp    $0x19,%bl
  800b6a:	77 08                	ja     800b74 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b6c:	0f be d2             	movsbl %dl,%edx
  800b6f:	83 ea 37             	sub    $0x37,%edx
  800b72:	eb cb                	jmp    800b3f <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b74:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b78:	74 05                	je     800b7f <strtol+0xd0>
		*endptr = (char *) s;
  800b7a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b7f:	89 c2                	mov    %eax,%edx
  800b81:	f7 da                	neg    %edx
  800b83:	85 ff                	test   %edi,%edi
  800b85:	0f 45 c2             	cmovne %edx,%eax
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	89 c3                	mov    %eax,%ebx
  800ba0:	89 c7                	mov    %eax,%edi
  800ba2:	89 c6                	mov    %eax,%esi
  800ba4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <sys_cgetc>:

int
sys_cgetc(void)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbb:	89 d1                	mov    %edx,%ecx
  800bbd:	89 d3                	mov    %edx,%ebx
  800bbf:	89 d7                	mov    %edx,%edi
  800bc1:	89 d6                	mov    %edx,%esi
  800bc3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
  800bd0:	83 ec 1c             	sub    $0x1c,%esp
  800bd3:	e8 66 00 00 00       	call   800c3e <__x86.get_pc_thunk.ax>
  800bd8:	05 28 14 00 00       	add    $0x1428,%eax
  800bdd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800be0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be5:	8b 55 08             	mov    0x8(%ebp),%edx
  800be8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bed:	89 cb                	mov    %ecx,%ebx
  800bef:	89 cf                	mov    %ecx,%edi
  800bf1:	89 ce                	mov    %ecx,%esi
  800bf3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf5:	85 c0                	test   %eax,%eax
  800bf7:	7f 08                	jg     800c01 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfc:	5b                   	pop    %ebx
  800bfd:	5e                   	pop    %esi
  800bfe:	5f                   	pop    %edi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 03                	push   $0x3
  800c07:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c0a:	8d 83 dc f0 ff ff    	lea    -0xf24(%ebx),%eax
  800c10:	50                   	push   %eax
  800c11:	6a 23                	push   $0x23
  800c13:	8d 83 f9 f0 ff ff    	lea    -0xf07(%ebx),%eax
  800c19:	50                   	push   %eax
  800c1a:	e8 23 00 00 00       	call   800c42 <_panic>

00800c1f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2f:	89 d1                	mov    %edx,%ecx
  800c31:	89 d3                	mov    %edx,%ebx
  800c33:	89 d7                	mov    %edx,%edi
  800c35:	89 d6                	mov    %edx,%esi
  800c37:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <__x86.get_pc_thunk.ax>:
  800c3e:	8b 04 24             	mov    (%esp),%eax
  800c41:	c3                   	ret    

00800c42 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	e8 23 f4 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800c50:	81 c3 b0 13 00 00    	add    $0x13b0,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c56:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c59:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c5f:	8b 38                	mov    (%eax),%edi
  800c61:	e8 b9 ff ff ff       	call   800c1f <sys_getenvid>
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	ff 75 0c             	pushl  0xc(%ebp)
  800c6c:	ff 75 08             	pushl  0x8(%ebp)
  800c6f:	57                   	push   %edi
  800c70:	50                   	push   %eax
  800c71:	8d 83 08 f1 ff ff    	lea    -0xef8(%ebx),%eax
  800c77:	50                   	push   %eax
  800c78:	e8 13 f5 ff ff       	call   800190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c7d:	83 c4 18             	add    $0x18,%esp
  800c80:	56                   	push   %esi
  800c81:	ff 75 10             	pushl  0x10(%ebp)
  800c84:	e8 a5 f4 ff ff       	call   80012e <vcprintf>
	cprintf("\n");
  800c89:	8d 83 e8 ee ff ff    	lea    -0x1118(%ebx),%eax
  800c8f:	89 04 24             	mov    %eax,(%esp)
  800c92:	e8 f9 f4 ff ff       	call   800190 <cprintf>
  800c97:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c9a:	cc                   	int3   
  800c9b:	eb fd                	jmp    800c9a <_panic+0x58>
  800c9d:	66 90                	xchg   %ax,%ax
  800c9f:	90                   	nop

00800ca0 <__udivdi3>:
  800ca0:	55                   	push   %ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 1c             	sub    $0x1c,%esp
  800ca7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800cab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800caf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cb7:	85 d2                	test   %edx,%edx
  800cb9:	75 35                	jne    800cf0 <__udivdi3+0x50>
  800cbb:	39 f3                	cmp    %esi,%ebx
  800cbd:	0f 87 bd 00 00 00    	ja     800d80 <__udivdi3+0xe0>
  800cc3:	85 db                	test   %ebx,%ebx
  800cc5:	89 d9                	mov    %ebx,%ecx
  800cc7:	75 0b                	jne    800cd4 <__udivdi3+0x34>
  800cc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cce:	31 d2                	xor    %edx,%edx
  800cd0:	f7 f3                	div    %ebx
  800cd2:	89 c1                	mov    %eax,%ecx
  800cd4:	31 d2                	xor    %edx,%edx
  800cd6:	89 f0                	mov    %esi,%eax
  800cd8:	f7 f1                	div    %ecx
  800cda:	89 c6                	mov    %eax,%esi
  800cdc:	89 e8                	mov    %ebp,%eax
  800cde:	89 f7                	mov    %esi,%edi
  800ce0:	f7 f1                	div    %ecx
  800ce2:	89 fa                	mov    %edi,%edx
  800ce4:	83 c4 1c             	add    $0x1c,%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
  800cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	39 f2                	cmp    %esi,%edx
  800cf2:	77 7c                	ja     800d70 <__udivdi3+0xd0>
  800cf4:	0f bd fa             	bsr    %edx,%edi
  800cf7:	83 f7 1f             	xor    $0x1f,%edi
  800cfa:	0f 84 98 00 00 00    	je     800d98 <__udivdi3+0xf8>
  800d00:	89 f9                	mov    %edi,%ecx
  800d02:	b8 20 00 00 00       	mov    $0x20,%eax
  800d07:	29 f8                	sub    %edi,%eax
  800d09:	d3 e2                	shl    %cl,%edx
  800d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d0f:	89 c1                	mov    %eax,%ecx
  800d11:	89 da                	mov    %ebx,%edx
  800d13:	d3 ea                	shr    %cl,%edx
  800d15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d19:	09 d1                	or     %edx,%ecx
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d21:	89 f9                	mov    %edi,%ecx
  800d23:	d3 e3                	shl    %cl,%ebx
  800d25:	89 c1                	mov    %eax,%ecx
  800d27:	d3 ea                	shr    %cl,%edx
  800d29:	89 f9                	mov    %edi,%ecx
  800d2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d2f:	d3 e6                	shl    %cl,%esi
  800d31:	89 eb                	mov    %ebp,%ebx
  800d33:	89 c1                	mov    %eax,%ecx
  800d35:	d3 eb                	shr    %cl,%ebx
  800d37:	09 de                	or     %ebx,%esi
  800d39:	89 f0                	mov    %esi,%eax
  800d3b:	f7 74 24 08          	divl   0x8(%esp)
  800d3f:	89 d6                	mov    %edx,%esi
  800d41:	89 c3                	mov    %eax,%ebx
  800d43:	f7 64 24 0c          	mull   0xc(%esp)
  800d47:	39 d6                	cmp    %edx,%esi
  800d49:	72 0c                	jb     800d57 <__udivdi3+0xb7>
  800d4b:	89 f9                	mov    %edi,%ecx
  800d4d:	d3 e5                	shl    %cl,%ebp
  800d4f:	39 c5                	cmp    %eax,%ebp
  800d51:	73 5d                	jae    800db0 <__udivdi3+0x110>
  800d53:	39 d6                	cmp    %edx,%esi
  800d55:	75 59                	jne    800db0 <__udivdi3+0x110>
  800d57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d5a:	31 ff                	xor    %edi,%edi
  800d5c:	89 fa                	mov    %edi,%edx
  800d5e:	83 c4 1c             	add    $0x1c,%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
  800d66:	8d 76 00             	lea    0x0(%esi),%esi
  800d69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d70:	31 ff                	xor    %edi,%edi
  800d72:	31 c0                	xor    %eax,%eax
  800d74:	89 fa                	mov    %edi,%edx
  800d76:	83 c4 1c             	add    $0x1c,%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
  800d7e:	66 90                	xchg   %ax,%ax
  800d80:	31 ff                	xor    %edi,%edi
  800d82:	89 e8                	mov    %ebp,%eax
  800d84:	89 f2                	mov    %esi,%edx
  800d86:	f7 f3                	div    %ebx
  800d88:	89 fa                	mov    %edi,%edx
  800d8a:	83 c4 1c             	add    $0x1c,%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
  800d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d98:	39 f2                	cmp    %esi,%edx
  800d9a:	72 06                	jb     800da2 <__udivdi3+0x102>
  800d9c:	31 c0                	xor    %eax,%eax
  800d9e:	39 eb                	cmp    %ebp,%ebx
  800da0:	77 d2                	ja     800d74 <__udivdi3+0xd4>
  800da2:	b8 01 00 00 00       	mov    $0x1,%eax
  800da7:	eb cb                	jmp    800d74 <__udivdi3+0xd4>
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	89 d8                	mov    %ebx,%eax
  800db2:	31 ff                	xor    %edi,%edi
  800db4:	eb be                	jmp    800d74 <__udivdi3+0xd4>
  800db6:	66 90                	xchg   %ax,%ax
  800db8:	66 90                	xchg   %ax,%ax
  800dba:	66 90                	xchg   %ax,%ax
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__umoddi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
  800dc7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800dcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dd7:	85 ed                	test   %ebp,%ebp
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	89 da                	mov    %ebx,%edx
  800ddd:	75 19                	jne    800df8 <__umoddi3+0x38>
  800ddf:	39 df                	cmp    %ebx,%edi
  800de1:	0f 86 b1 00 00 00    	jbe    800e98 <__umoddi3+0xd8>
  800de7:	f7 f7                	div    %edi
  800de9:	89 d0                	mov    %edx,%eax
  800deb:	31 d2                	xor    %edx,%edx
  800ded:	83 c4 1c             	add    $0x1c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	39 dd                	cmp    %ebx,%ebp
  800dfa:	77 f1                	ja     800ded <__umoddi3+0x2d>
  800dfc:	0f bd cd             	bsr    %ebp,%ecx
  800dff:	83 f1 1f             	xor    $0x1f,%ecx
  800e02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e06:	0f 84 b4 00 00 00    	je     800ec0 <__umoddi3+0x100>
  800e0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e11:	89 c2                	mov    %eax,%edx
  800e13:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e17:	29 c2                	sub    %eax,%edx
  800e19:	89 c1                	mov    %eax,%ecx
  800e1b:	89 f8                	mov    %edi,%eax
  800e1d:	d3 e5                	shl    %cl,%ebp
  800e1f:	89 d1                	mov    %edx,%ecx
  800e21:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e25:	d3 e8                	shr    %cl,%eax
  800e27:	09 c5                	or     %eax,%ebp
  800e29:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e2d:	89 c1                	mov    %eax,%ecx
  800e2f:	d3 e7                	shl    %cl,%edi
  800e31:	89 d1                	mov    %edx,%ecx
  800e33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e37:	89 df                	mov    %ebx,%edi
  800e39:	d3 ef                	shr    %cl,%edi
  800e3b:	89 c1                	mov    %eax,%ecx
  800e3d:	89 f0                	mov    %esi,%eax
  800e3f:	d3 e3                	shl    %cl,%ebx
  800e41:	89 d1                	mov    %edx,%ecx
  800e43:	89 fa                	mov    %edi,%edx
  800e45:	d3 e8                	shr    %cl,%eax
  800e47:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e4c:	09 d8                	or     %ebx,%eax
  800e4e:	f7 f5                	div    %ebp
  800e50:	d3 e6                	shl    %cl,%esi
  800e52:	89 d1                	mov    %edx,%ecx
  800e54:	f7 64 24 08          	mull   0x8(%esp)
  800e58:	39 d1                	cmp    %edx,%ecx
  800e5a:	89 c3                	mov    %eax,%ebx
  800e5c:	89 d7                	mov    %edx,%edi
  800e5e:	72 06                	jb     800e66 <__umoddi3+0xa6>
  800e60:	75 0e                	jne    800e70 <__umoddi3+0xb0>
  800e62:	39 c6                	cmp    %eax,%esi
  800e64:	73 0a                	jae    800e70 <__umoddi3+0xb0>
  800e66:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e6a:	19 ea                	sbb    %ebp,%edx
  800e6c:	89 d7                	mov    %edx,%edi
  800e6e:	89 c3                	mov    %eax,%ebx
  800e70:	89 ca                	mov    %ecx,%edx
  800e72:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e77:	29 de                	sub    %ebx,%esi
  800e79:	19 fa                	sbb    %edi,%edx
  800e7b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e7f:	89 d0                	mov    %edx,%eax
  800e81:	d3 e0                	shl    %cl,%eax
  800e83:	89 d9                	mov    %ebx,%ecx
  800e85:	d3 ee                	shr    %cl,%esi
  800e87:	d3 ea                	shr    %cl,%edx
  800e89:	09 f0                	or     %esi,%eax
  800e8b:	83 c4 1c             	add    $0x1c,%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    
  800e93:	90                   	nop
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	85 ff                	test   %edi,%edi
  800e9a:	89 f9                	mov    %edi,%ecx
  800e9c:	75 0b                	jne    800ea9 <__umoddi3+0xe9>
  800e9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  800ea5:	f7 f7                	div    %edi
  800ea7:	89 c1                	mov    %eax,%ecx
  800ea9:	89 d8                	mov    %ebx,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f1                	div    %ecx
  800eaf:	89 f0                	mov    %esi,%eax
  800eb1:	f7 f1                	div    %ecx
  800eb3:	e9 31 ff ff ff       	jmp    800de9 <__umoddi3+0x29>
  800eb8:	90                   	nop
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	39 dd                	cmp    %ebx,%ebp
  800ec2:	72 08                	jb     800ecc <__umoddi3+0x10c>
  800ec4:	39 f7                	cmp    %esi,%edi
  800ec6:	0f 87 21 ff ff ff    	ja     800ded <__umoddi3+0x2d>
  800ecc:	89 da                	mov    %ebx,%edx
  800ece:	89 f0                	mov    %esi,%eax
  800ed0:	29 f8                	sub    %edi,%eax
  800ed2:	19 ea                	sbb    %ebp,%edx
  800ed4:	e9 14 ff ff ff       	jmp    800ded <__umoddi3+0x2d>
