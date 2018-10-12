
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 32 00 00 00       	call   800063 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 20 00 00 00       	call   80005f <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800045:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80004b:	8d 83 cc ee ff ff    	lea    -0x1134(%ebx),%eax
  800051:	50                   	push   %eax
  800052:	e8 25 01 00 00       	call   80017c <cprintf>
}
  800057:	83 c4 10             	add    $0x10,%esp
  80005a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005d:	c9                   	leave  
  80005e:	c3                   	ret    

0080005f <__x86.get_pc_thunk.bx>:
  80005f:	8b 1c 24             	mov    (%esp),%ebx
  800062:	c3                   	ret    

00800063 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800063:	55                   	push   %ebp
  800064:	89 e5                	mov    %esp,%ebp
  800066:	53                   	push   %ebx
  800067:	83 ec 04             	sub    $0x4,%esp
  80006a:	e8 f0 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 45 08             	mov    0x8(%ebp),%eax
  800078:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80007b:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800081:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 c0                	test   %eax,%eax
  800089:	7e 08                	jle    800093 <libmain+0x30>
		binaryname = argv[0];
  80008b:	8b 0a                	mov    (%edx),%ecx
  80008d:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800093:	83 ec 08             	sub    $0x8,%esp
  800096:	52                   	push   %edx
  800097:	50                   	push   %eax
  800098:	e8 96 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009d:	e8 08 00 00 00       	call   8000aa <exit>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	53                   	push   %ebx
  8000ae:	83 ec 10             	sub    $0x10,%esp
  8000b1:	e8 a9 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000b6:	81 c3 4a 1f 00 00    	add    $0x1f4a,%ebx
	sys_env_destroy(0);
  8000bc:	6a 00                	push   $0x0
  8000be:	e8 f3 0a 00 00       	call   800bb6 <sys_env_destroy>
}
  8000c3:	83 c4 10             	add    $0x10,%esp
  8000c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
  8000d0:	e8 8a ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000d5:	81 c3 2b 1f 00 00    	add    $0x1f2b,%ebx
  8000db:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000de:	8b 16                	mov    (%esi),%edx
  8000e0:	8d 42 01             	lea    0x1(%edx),%eax
  8000e3:	89 06                	mov    %eax,(%esi)
  8000e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e8:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8000ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f1:	74 0b                	je     8000fe <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f3:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8000f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	68 ff 00 00 00       	push   $0xff
  800106:	8d 46 08             	lea    0x8(%esi),%eax
  800109:	50                   	push   %eax
  80010a:	e8 6a 0a 00 00       	call   800b79 <sys_cputs>
		b->idx = 0;
  80010f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800115:	83 c4 10             	add    $0x10,%esp
  800118:	eb d9                	jmp    8000f3 <putch+0x28>

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	53                   	push   %ebx
  80011e:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800124:	e8 36 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800129:	81 c3 d7 1e 00 00    	add    $0x1ed7,%ebx
	struct printbuf b;

	b.idx = 0;
  80012f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800136:	00 00 00 
	b.cnt = 0;
  800139:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800140:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800143:	ff 75 0c             	pushl  0xc(%ebp)
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014f:	50                   	push   %eax
  800150:	8d 83 cb e0 ff ff    	lea    -0x1f35(%ebx),%eax
  800156:	50                   	push   %eax
  800157:	e8 38 01 00 00       	call   800294 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80015c:	83 c4 08             	add    $0x8,%esp
  80015f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800165:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 08 0a 00 00       	call   800b79 <sys_cputs>

	return b.cnt;
}
  800171:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800177:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800182:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800185:	50                   	push   %eax
  800186:	ff 75 08             	pushl  0x8(%ebp)
  800189:	e8 8c ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 2c             	sub    $0x2c,%esp
  800199:	e8 63 06 00 00       	call   800801 <__x86.get_pc_thunk.cx>
  80019e:	81 c1 62 1e 00 00    	add    $0x1e62,%ecx
  8001a4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001a7:	89 c7                	mov    %eax,%edi
  8001a9:	89 d6                	mov    %edx,%esi
  8001ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001bf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001c2:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001c5:	39 d3                	cmp    %edx,%ebx
  8001c7:	72 09                	jb     8001d2 <printnum+0x42>
  8001c9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001cc:	0f 87 83 00 00 00    	ja     800255 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	ff 75 18             	pushl  0x18(%ebp)
  8001d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8001db:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001de:	53                   	push   %ebx
  8001df:	ff 75 10             	pushl  0x10(%ebp)
  8001e2:	83 ec 08             	sub    $0x8,%esp
  8001e5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001eb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8001ee:	ff 75 d0             	pushl  -0x30(%ebp)
  8001f1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8001f4:	e8 97 0a 00 00       	call   800c90 <__udivdi3>
  8001f9:	83 c4 18             	add    $0x18,%esp
  8001fc:	52                   	push   %edx
  8001fd:	50                   	push   %eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	89 f8                	mov    %edi,%eax
  800202:	e8 89 ff ff ff       	call   800190 <printnum>
  800207:	83 c4 20             	add    $0x20,%esp
  80020a:	eb 13                	jmp    80021f <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	56                   	push   %esi
  800210:	ff 75 18             	pushl  0x18(%ebp)
  800213:	ff d7                	call   *%edi
  800215:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	85 db                	test   %ebx,%ebx
  80021d:	7f ed                	jg     80020c <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	ff 75 dc             	pushl  -0x24(%ebp)
  800229:	ff 75 d8             	pushl  -0x28(%ebp)
  80022c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80022f:	ff 75 d0             	pushl  -0x30(%ebp)
  800232:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800235:	89 f3                	mov    %esi,%ebx
  800237:	e8 74 0b 00 00       	call   800db0 <__umoddi3>
  80023c:	83 c4 14             	add    $0x14,%esp
  80023f:	0f be 84 06 fd ee ff 	movsbl -0x1103(%esi,%eax,1),%eax
  800246:	ff 
  800247:	50                   	push   %eax
  800248:	ff d7                	call   *%edi
}
  80024a:	83 c4 10             	add    $0x10,%esp
  80024d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    
  800255:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800258:	eb be                	jmp    800218 <printnum+0x88>

0080025a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800260:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800264:	8b 10                	mov    (%eax),%edx
  800266:	3b 50 04             	cmp    0x4(%eax),%edx
  800269:	73 0a                	jae    800275 <sprintputch+0x1b>
		*b->buf++ = ch;
  80026b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 45 08             	mov    0x8(%ebp),%eax
  800273:	88 02                	mov    %al,(%edx)
}
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <printfmt>:
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80027d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800280:	50                   	push   %eax
  800281:	ff 75 10             	pushl  0x10(%ebp)
  800284:	ff 75 0c             	pushl  0xc(%ebp)
  800287:	ff 75 08             	pushl  0x8(%ebp)
  80028a:	e8 05 00 00 00       	call   800294 <vprintfmt>
}
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <vprintfmt>:
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
  80029a:	83 ec 2c             	sub    $0x2c,%esp
  80029d:	e8 bd fd ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8002a2:	81 c3 5e 1d 00 00    	add    $0x1d5e,%ebx
  8002a8:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8002ab:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8002b2:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b4:	8d 77 01             	lea    0x1(%edi),%esi
  8002b7:	0f b6 07             	movzbl (%edi),%eax
  8002ba:	83 f8 25             	cmp    $0x25,%eax
  8002bd:	74 1c                	je     8002db <vprintfmt+0x47>
			if (ch == '\0')
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	0f 84 b9 04 00 00    	je     800780 <.L21+0x20>
			putch(ch, putdat);
  8002c7:	83 ec 08             	sub    $0x8,%esp
  8002ca:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8002cd:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8002d0:	50                   	push   %eax
  8002d1:	ff 55 08             	call   *0x8(%ebp)
  8002d4:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d7:	89 f7                	mov    %esi,%edi
  8002d9:	eb d9                	jmp    8002b4 <vprintfmt+0x20>
		padc = ' ';
  8002db:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8002df:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002e6:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8002ed:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8d 7e 01             	lea    0x1(%esi),%edi
  8002ff:	0f b6 16             	movzbl (%esi),%edx
  800302:	8d 42 dd             	lea    -0x23(%edx),%eax
  800305:	3c 55                	cmp    $0x55,%al
  800307:	0f 87 53 04 00 00    	ja     800760 <.L21>
  80030d:	0f b6 c0             	movzbl %al,%eax
  800310:	89 d9                	mov    %ebx,%ecx
  800312:	03 8c 83 8c ef ff ff 	add    -0x1074(%ebx,%eax,4),%ecx
  800319:	ff e1                	jmp    *%ecx

0080031b <.L73>:
  80031b:	89 fe                	mov    %edi,%esi
			padc = '-';
  80031d:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800321:	eb d9                	jmp    8002fc <vprintfmt+0x68>

00800323 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	89 fe                	mov    %edi,%esi
			padc = '0';
  800325:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800329:	eb d1                	jmp    8002fc <vprintfmt+0x68>

0080032b <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	0f b6 d2             	movzbl %dl,%edx
  80032e:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800330:	b8 00 00 00 00       	mov    $0x0,%eax
  800335:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800338:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033f:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800342:	8d 7a d0             	lea    -0x30(%edx),%edi
  800345:	83 ff 09             	cmp    $0x9,%edi
  800348:	0f 87 94 00 00 00    	ja     8003e2 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  80034e:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800351:	eb e5                	jmp    800338 <.L28+0xd>

00800353 <.L25>:
			precision = va_arg(ap, int);
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8b 00                	mov    (%eax),%eax
  800358:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 40 04             	lea    0x4(%eax),%eax
  800361:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800364:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800366:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036a:	79 90                	jns    8002fc <vprintfmt+0x68>
				width = precision, precision = -1;
  80036c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80036f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800372:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800379:	eb 81                	jmp    8002fc <vprintfmt+0x68>

0080037b <.L26>:
  80037b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037e:	85 c0                	test   %eax,%eax
  800380:	ba 00 00 00 00       	mov    $0x0,%edx
  800385:	0f 49 d0             	cmovns %eax,%edx
  800388:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	89 fe                	mov    %edi,%esi
  80038d:	e9 6a ff ff ff       	jmp    8002fc <vprintfmt+0x68>

00800392 <.L22>:
  800392:	89 fe                	mov    %edi,%esi
			altflag = 1;
  800394:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039b:	e9 5c ff ff ff       	jmp    8002fc <vprintfmt+0x68>

008003a0 <.L33>:
  8003a0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8003a3:	83 f9 01             	cmp    $0x1,%ecx
  8003a6:	7e 16                	jle    8003be <.L33+0x1e>
		return va_arg(*ap, long long);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003b0:	8d 49 08             	lea    0x8(%ecx),%ecx
  8003b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8003b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8003b9:	e9 f6 fe ff ff       	jmp    8002b4 <vprintfmt+0x20>
	else if (lflag)
  8003be:	85 c9                	test   %ecx,%ecx
  8003c0:	75 10                	jne    8003d2 <.L33+0x32>
		return va_arg(*ap, int);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8b 00                	mov    (%eax),%eax
  8003c7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003ca:	8d 49 04             	lea    0x4(%ecx),%ecx
  8003cd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d0:	eb e4                	jmp    8003b6 <.L33+0x16>
		return va_arg(*ap, long);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003da:	8d 49 04             	lea    0x4(%ecx),%ecx
  8003dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e0:	eb d4                	jmp    8003b6 <.L33+0x16>
  8003e2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003e5:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003e8:	e9 79 ff ff ff       	jmp    800366 <.L25+0x13>

008003ed <.L32>:
			lflag++;
  8003ed:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8003f3:	e9 04 ff ff ff       	jmp    8002fc <vprintfmt+0x68>

008003f8 <.L29>:
			putch(va_arg(ap, int), putdat);
  8003f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fb:	8d 70 04             	lea    0x4(%eax),%esi
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	ff 75 0c             	pushl  0xc(%ebp)
  800404:	ff 30                	pushl  (%eax)
  800406:	ff 55 08             	call   *0x8(%ebp)
			break;
  800409:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040c:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  80040f:	e9 a0 fe ff ff       	jmp    8002b4 <vprintfmt+0x20>

00800414 <.L31>:
			err = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 70 04             	lea    0x4(%eax),%esi
  80041a:	8b 00                	mov    (%eax),%eax
  80041c:	99                   	cltd   
  80041d:	31 d0                	xor    %edx,%eax
  80041f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800421:	83 f8 06             	cmp    $0x6,%eax
  800424:	7f 29                	jg     80044f <.L31+0x3b>
  800426:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  80042d:	85 d2                	test   %edx,%edx
  80042f:	74 1e                	je     80044f <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800431:	52                   	push   %edx
  800432:	8d 83 1e ef ff ff    	lea    -0x10e2(%ebx),%eax
  800438:	50                   	push   %eax
  800439:	ff 75 0c             	pushl  0xc(%ebp)
  80043c:	ff 75 08             	pushl  0x8(%ebp)
  80043f:	e8 33 fe ff ff       	call   800277 <printfmt>
  800444:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800447:	89 75 14             	mov    %esi,0x14(%ebp)
  80044a:	e9 65 fe ff ff       	jmp    8002b4 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  80044f:	50                   	push   %eax
  800450:	8d 83 15 ef ff ff    	lea    -0x10eb(%ebx),%eax
  800456:	50                   	push   %eax
  800457:	ff 75 0c             	pushl  0xc(%ebp)
  80045a:	ff 75 08             	pushl  0x8(%ebp)
  80045d:	e8 15 fe ff ff       	call   800277 <printfmt>
  800462:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800465:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800468:	e9 47 fe ff ff       	jmp    8002b4 <vprintfmt+0x20>

0080046d <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	83 c0 04             	add    $0x4,%eax
  800473:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80047b:	85 f6                	test   %esi,%esi
  80047d:	8d 83 0e ef ff ff    	lea    -0x10f2(%ebx),%eax
  800483:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800486:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048a:	0f 8e b4 00 00 00    	jle    800544 <.L36+0xd7>
  800490:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800494:	75 08                	jne    80049e <.L36+0x31>
  800496:	89 7d 10             	mov    %edi,0x10(%ebp)
  800499:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80049c:	eb 6c                	jmp    80050a <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	ff 75 cc             	pushl  -0x34(%ebp)
  8004a4:	56                   	push   %esi
  8004a5:	e8 73 03 00 00       	call   80081d <strnlen>
  8004aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ad:	29 c2                	sub    %eax,%edx
  8004af:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b5:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004b9:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004bc:	89 d6                	mov    %edx,%esi
  8004be:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004c1:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	eb 10                	jmp    8004d5 <.L36+0x68>
					putch(padc, putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	ff 75 0c             	pushl  0xc(%ebp)
  8004cb:	57                   	push   %edi
  8004cc:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	83 ee 01             	sub    $0x1,%esi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 f6                	test   %esi,%esi
  8004d7:	7f ec                	jg     8004c5 <.L36+0x58>
  8004d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	0f 49 c2             	cmovns %edx,%eax
  8004e9:	29 c2                	sub    %eax,%edx
  8004eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ee:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004f1:	eb 17                	jmp    80050a <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f7:	75 30                	jne    800529 <.L36+0xbc>
					putch(ch, putdat);
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	ff 75 0c             	pushl  0xc(%ebp)
  8004ff:	50                   	push   %eax
  800500:	ff 55 08             	call   *0x8(%ebp)
  800503:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800506:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80050a:	83 c6 01             	add    $0x1,%esi
  80050d:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800511:	0f be c2             	movsbl %dl,%eax
  800514:	85 c0                	test   %eax,%eax
  800516:	74 58                	je     800570 <.L36+0x103>
  800518:	85 ff                	test   %edi,%edi
  80051a:	78 d7                	js     8004f3 <.L36+0x86>
  80051c:	83 ef 01             	sub    $0x1,%edi
  80051f:	79 d2                	jns    8004f3 <.L36+0x86>
  800521:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800524:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800527:	eb 32                	jmp    80055b <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	0f be d2             	movsbl %dl,%edx
  80052c:	83 ea 20             	sub    $0x20,%edx
  80052f:	83 fa 5e             	cmp    $0x5e,%edx
  800532:	76 c5                	jbe    8004f9 <.L36+0x8c>
					putch('?', putdat);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	ff 75 0c             	pushl  0xc(%ebp)
  80053a:	6a 3f                	push   $0x3f
  80053c:	ff 55 08             	call   *0x8(%ebp)
  80053f:	83 c4 10             	add    $0x10,%esp
  800542:	eb c2                	jmp    800506 <.L36+0x99>
  800544:	89 7d 10             	mov    %edi,0x10(%ebp)
  800547:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80054a:	eb be                	jmp    80050a <.L36+0x9d>
				putch(' ', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	57                   	push   %edi
  800550:	6a 20                	push   $0x20
  800552:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800555:	83 ee 01             	sub    $0x1,%esi
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	85 f6                	test   %esi,%esi
  80055d:	7f ed                	jg     80054c <.L36+0xdf>
  80055f:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800562:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800565:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
  80056b:	e9 44 fd ff ff       	jmp    8002b4 <vprintfmt+0x20>
  800570:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800573:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800576:	eb e3                	jmp    80055b <.L36+0xee>

00800578 <.L30>:
  800578:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80057b:	83 f9 01             	cmp    $0x1,%ecx
  80057e:	7e 42                	jle    8005c2 <.L30+0x4a>
		return va_arg(*ap, long long);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 50 04             	mov    0x4(%eax),%edx
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 40 08             	lea    0x8(%eax),%eax
  800594:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800597:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059b:	79 5f                	jns    8005fc <.L30+0x84>
				putch('-', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	ff 75 0c             	pushl  0xc(%ebp)
  8005a3:	6a 2d                	push   $0x2d
  8005a5:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ae:	f7 da                	neg    %edx
  8005b0:	83 d1 00             	adc    $0x0,%ecx
  8005b3:	f7 d9                	neg    %ecx
  8005b5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005bd:	e9 b8 00 00 00       	jmp    80067a <.L34+0x22>
	else if (lflag)
  8005c2:	85 c9                	test   %ecx,%ecx
  8005c4:	75 1b                	jne    8005e1 <.L30+0x69>
		return va_arg(*ap, int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 30                	mov    (%eax),%esi
  8005cb:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005ce:	89 f0                	mov    %esi,%eax
  8005d0:	c1 f8 1f             	sar    $0x1f,%eax
  8005d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 40 04             	lea    0x4(%eax),%eax
  8005dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005df:	eb b6                	jmp    800597 <.L30+0x1f>
		return va_arg(*ap, long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 30                	mov    (%eax),%esi
  8005e6:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005e9:	89 f0                	mov    %esi,%eax
  8005eb:	c1 f8 1f             	sar    $0x1f,%eax
  8005ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 40 04             	lea    0x4(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fa:	eb 9b                	jmp    800597 <.L30+0x1f>
			num = getint(&ap, lflag);
  8005fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
  800607:	eb 71                	jmp    80067a <.L34+0x22>

00800609 <.L37>:
  800609:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80060c:	83 f9 01             	cmp    $0x1,%ecx
  80060f:	7e 15                	jle    800626 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8b 10                	mov    (%eax),%edx
  800616:	8b 48 04             	mov    0x4(%eax),%ecx
  800619:	8d 40 08             	lea    0x8(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800624:	eb 54                	jmp    80067a <.L34+0x22>
	else if (lflag)
  800626:	85 c9                	test   %ecx,%ecx
  800628:	75 17                	jne    800641 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 10                	mov    (%eax),%edx
  80062f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800634:	8d 40 04             	lea    0x4(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063f:	eb 39                	jmp    80067a <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064b:	8d 40 04             	lea    0x4(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800651:	b8 0a 00 00 00       	mov    $0xa,%eax
  800656:	eb 22                	jmp    80067a <.L34+0x22>

00800658 <.L34>:
  800658:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80065b:	83 f9 01             	cmp    $0x1,%ecx
  80065e:	7e 3b                	jle    80069b <.L34+0x43>
		return va_arg(*ap, long long);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 50 04             	mov    0x4(%eax),%edx
  800666:	8b 00                	mov    (%eax),%eax
  800668:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80066b:	8d 49 08             	lea    0x8(%ecx),%ecx
  80066e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800671:	89 d1                	mov    %edx,%ecx
  800673:	89 c2                	mov    %eax,%edx
			base = 8;
  800675:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80067a:	83 ec 0c             	sub    $0xc,%esp
  80067d:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800681:	56                   	push   %esi
  800682:	ff 75 e0             	pushl  -0x20(%ebp)
  800685:	50                   	push   %eax
  800686:	51                   	push   %ecx
  800687:	52                   	push   %edx
  800688:	8b 55 0c             	mov    0xc(%ebp),%edx
  80068b:	8b 45 08             	mov    0x8(%ebp),%eax
  80068e:	e8 fd fa ff ff       	call   800190 <printnum>
			break;
  800693:	83 c4 20             	add    $0x20,%esp
  800696:	e9 19 fc ff ff       	jmp    8002b4 <vprintfmt+0x20>
	else if (lflag)
  80069b:	85 c9                	test   %ecx,%ecx
  80069d:	75 13                	jne    8006b2 <.L34+0x5a>
		return va_arg(*ap, int);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	89 d0                	mov    %edx,%eax
  8006a6:	99                   	cltd   
  8006a7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006aa:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b0:	eb bf                	jmp    800671 <.L34+0x19>
		return va_arg(*ap, long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8b 10                	mov    (%eax),%edx
  8006b7:	89 d0                	mov    %edx,%eax
  8006b9:	99                   	cltd   
  8006ba:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006bd:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006c0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c3:	eb ac                	jmp    800671 <.L34+0x19>

008006c5 <.L35>:
			putch('0', putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	ff 75 0c             	pushl  0xc(%ebp)
  8006cb:	6a 30                	push   $0x30
  8006cd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006d0:	83 c4 08             	add    $0x8,%esp
  8006d3:	ff 75 0c             	pushl  0xc(%ebp)
  8006d6:	6a 78                	push   $0x78
  8006d8:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8b 10                	mov    (%eax),%edx
  8006e0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006e5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006e8:	8d 40 04             	lea    0x4(%eax),%eax
  8006eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ee:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f3:	eb 85                	jmp    80067a <.L34+0x22>

008006f5 <.L38>:
  8006f5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8006f8:	83 f9 01             	cmp    $0x1,%ecx
  8006fb:	7e 18                	jle    800715 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8b 10                	mov    (%eax),%edx
  800702:	8b 48 04             	mov    0x4(%eax),%ecx
  800705:	8d 40 08             	lea    0x8(%eax),%eax
  800708:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070b:	b8 10 00 00 00       	mov    $0x10,%eax
  800710:	e9 65 ff ff ff       	jmp    80067a <.L34+0x22>
	else if (lflag)
  800715:	85 c9                	test   %ecx,%ecx
  800717:	75 1a                	jne    800733 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8b 10                	mov    (%eax),%edx
  80071e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800723:	8d 40 04             	lea    0x4(%eax),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800729:	b8 10 00 00 00       	mov    $0x10,%eax
  80072e:	e9 47 ff ff ff       	jmp    80067a <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073d:	8d 40 04             	lea    0x4(%eax),%eax
  800740:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800743:	b8 10 00 00 00       	mov    $0x10,%eax
  800748:	e9 2d ff ff ff       	jmp    80067a <.L34+0x22>

0080074d <.L24>:
			putch(ch, putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	6a 25                	push   $0x25
  800755:	ff 55 08             	call   *0x8(%ebp)
			break;
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	e9 54 fb ff ff       	jmp    8002b4 <vprintfmt+0x20>

00800760 <.L21>:
			putch('%', putdat);
  800760:	83 ec 08             	sub    $0x8,%esp
  800763:	ff 75 0c             	pushl  0xc(%ebp)
  800766:	6a 25                	push   $0x25
  800768:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	89 f7                	mov    %esi,%edi
  800770:	eb 03                	jmp    800775 <.L21+0x15>
  800772:	83 ef 01             	sub    $0x1,%edi
  800775:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800779:	75 f7                	jne    800772 <.L21+0x12>
  80077b:	e9 34 fb ff ff       	jmp    8002b4 <vprintfmt+0x20>
}
  800780:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800783:	5b                   	pop    %ebx
  800784:	5e                   	pop    %esi
  800785:	5f                   	pop    %edi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	83 ec 14             	sub    $0x14,%esp
  80078f:	e8 cb f8 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800794:	81 c3 6c 18 00 00    	add    $0x186c,%ebx
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	74 2b                	je     8007e0 <vsnprintf+0x58>
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	7e 27                	jle    8007e0 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b9:	ff 75 14             	pushl  0x14(%ebp)
  8007bc:	ff 75 10             	pushl  0x10(%ebp)
  8007bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c2:	50                   	push   %eax
  8007c3:	8d 83 5a e2 ff ff    	lea    -0x1da6(%ebx),%eax
  8007c9:	50                   	push   %eax
  8007ca:	e8 c5 fa ff ff       	call   800294 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d8:	83 c4 10             	add    $0x10,%esp
}
  8007db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    
		return -E_INVAL;
  8007e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e5:	eb f4                	jmp    8007db <vsnprintf+0x53>

008007e7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ed:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f0:	50                   	push   %eax
  8007f1:	ff 75 10             	pushl  0x10(%ebp)
  8007f4:	ff 75 0c             	pushl  0xc(%ebp)
  8007f7:	ff 75 08             	pushl  0x8(%ebp)
  8007fa:	e8 89 ff ff ff       	call   800788 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <__x86.get_pc_thunk.cx>:
  800801:	8b 0c 24             	mov    (%esp),%ecx
  800804:	c3                   	ret    

00800805 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
  800810:	eb 03                	jmp    800815 <strlen+0x10>
		n++;
  800812:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800815:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800819:	75 f7                	jne    800812 <strlen+0xd>
	return n;
}
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    

0080081d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	eb 03                	jmp    800830 <strnlen+0x13>
		n++;
  80082d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800830:	39 d0                	cmp    %edx,%eax
  800832:	74 06                	je     80083a <strnlen+0x1d>
  800834:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800838:	75 f3                	jne    80082d <strnlen+0x10>
	return n;
}
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	53                   	push   %ebx
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800846:	89 c2                	mov    %eax,%edx
  800848:	83 c1 01             	add    $0x1,%ecx
  80084b:	83 c2 01             	add    $0x1,%edx
  80084e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800852:	88 5a ff             	mov    %bl,-0x1(%edx)
  800855:	84 db                	test   %bl,%bl
  800857:	75 ef                	jne    800848 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800859:	5b                   	pop    %ebx
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	53                   	push   %ebx
  800860:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800863:	53                   	push   %ebx
  800864:	e8 9c ff ff ff       	call   800805 <strlen>
  800869:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80086c:	ff 75 0c             	pushl  0xc(%ebp)
  80086f:	01 d8                	add    %ebx,%eax
  800871:	50                   	push   %eax
  800872:	e8 c5 ff ff ff       	call   80083c <strcpy>
	return dst;
}
  800877:	89 d8                	mov    %ebx,%eax
  800879:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087c:	c9                   	leave  
  80087d:	c3                   	ret    

0080087e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	8b 75 08             	mov    0x8(%ebp),%esi
  800886:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800889:	89 f3                	mov    %esi,%ebx
  80088b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088e:	89 f2                	mov    %esi,%edx
  800890:	eb 0f                	jmp    8008a1 <strncpy+0x23>
		*dst++ = *src;
  800892:	83 c2 01             	add    $0x1,%edx
  800895:	0f b6 01             	movzbl (%ecx),%eax
  800898:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80089b:	80 39 01             	cmpb   $0x1,(%ecx)
  80089e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008a1:	39 da                	cmp    %ebx,%edx
  8008a3:	75 ed                	jne    800892 <strncpy+0x14>
	}
	return ret;
}
  8008a5:	89 f0                	mov    %esi,%eax
  8008a7:	5b                   	pop    %ebx
  8008a8:	5e                   	pop    %esi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008b9:	89 f0                	mov    %esi,%eax
  8008bb:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008bf:	85 c9                	test   %ecx,%ecx
  8008c1:	75 0b                	jne    8008ce <strlcpy+0x23>
  8008c3:	eb 17                	jmp    8008dc <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c5:	83 c2 01             	add    $0x1,%edx
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008ce:	39 d8                	cmp    %ebx,%eax
  8008d0:	74 07                	je     8008d9 <strlcpy+0x2e>
  8008d2:	0f b6 0a             	movzbl (%edx),%ecx
  8008d5:	84 c9                	test   %cl,%cl
  8008d7:	75 ec                	jne    8008c5 <strlcpy+0x1a>
		*dst = '\0';
  8008d9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008dc:	29 f0                	sub    %esi,%eax
}
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008eb:	eb 06                	jmp    8008f3 <strcmp+0x11>
		p++, q++;
  8008ed:	83 c1 01             	add    $0x1,%ecx
  8008f0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008f3:	0f b6 01             	movzbl (%ecx),%eax
  8008f6:	84 c0                	test   %al,%al
  8008f8:	74 04                	je     8008fe <strcmp+0x1c>
  8008fa:	3a 02                	cmp    (%edx),%al
  8008fc:	74 ef                	je     8008ed <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fe:	0f b6 c0             	movzbl %al,%eax
  800901:	0f b6 12             	movzbl (%edx),%edx
  800904:	29 d0                	sub    %edx,%eax
}
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	53                   	push   %ebx
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800912:	89 c3                	mov    %eax,%ebx
  800914:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800917:	eb 06                	jmp    80091f <strncmp+0x17>
		n--, p++, q++;
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80091f:	39 d8                	cmp    %ebx,%eax
  800921:	74 16                	je     800939 <strncmp+0x31>
  800923:	0f b6 08             	movzbl (%eax),%ecx
  800926:	84 c9                	test   %cl,%cl
  800928:	74 04                	je     80092e <strncmp+0x26>
  80092a:	3a 0a                	cmp    (%edx),%cl
  80092c:	74 eb                	je     800919 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092e:	0f b6 00             	movzbl (%eax),%eax
  800931:	0f b6 12             	movzbl (%edx),%edx
  800934:	29 d0                	sub    %edx,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    
		return 0;
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
  80093e:	eb f6                	jmp    800936 <strncmp+0x2e>

00800940 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094a:	0f b6 10             	movzbl (%eax),%edx
  80094d:	84 d2                	test   %dl,%dl
  80094f:	74 09                	je     80095a <strchr+0x1a>
		if (*s == c)
  800951:	38 ca                	cmp    %cl,%dl
  800953:	74 0a                	je     80095f <strchr+0x1f>
	for (; *s; s++)
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	eb f0                	jmp    80094a <strchr+0xa>
			return (char *) s;
	return 0;
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096b:	eb 03                	jmp    800970 <strfind+0xf>
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800973:	38 ca                	cmp    %cl,%dl
  800975:	74 04                	je     80097b <strfind+0x1a>
  800977:	84 d2                	test   %dl,%dl
  800979:	75 f2                	jne    80096d <strfind+0xc>
			break;
	return (char *) s;
}
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	57                   	push   %edi
  800981:	56                   	push   %esi
  800982:	53                   	push   %ebx
  800983:	8b 7d 08             	mov    0x8(%ebp),%edi
  800986:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800989:	85 c9                	test   %ecx,%ecx
  80098b:	74 13                	je     8009a0 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800993:	75 05                	jne    80099a <memset+0x1d>
  800995:	f6 c1 03             	test   $0x3,%cl
  800998:	74 0d                	je     8009a7 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099d:	fc                   	cld    
  80099e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a0:	89 f8                	mov    %edi,%eax
  8009a2:	5b                   	pop    %ebx
  8009a3:	5e                   	pop    %esi
  8009a4:	5f                   	pop    %edi
  8009a5:	5d                   	pop    %ebp
  8009a6:	c3                   	ret    
		c &= 0xFF;
  8009a7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ab:	89 d3                	mov    %edx,%ebx
  8009ad:	c1 e3 08             	shl    $0x8,%ebx
  8009b0:	89 d0                	mov    %edx,%eax
  8009b2:	c1 e0 18             	shl    $0x18,%eax
  8009b5:	89 d6                	mov    %edx,%esi
  8009b7:	c1 e6 10             	shl    $0x10,%esi
  8009ba:	09 f0                	or     %esi,%eax
  8009bc:	09 c2                	or     %eax,%edx
  8009be:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c3:	89 d0                	mov    %edx,%eax
  8009c5:	fc                   	cld    
  8009c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c8:	eb d6                	jmp    8009a0 <memset+0x23>

008009ca <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	57                   	push   %edi
  8009ce:	56                   	push   %esi
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d8:	39 c6                	cmp    %eax,%esi
  8009da:	73 35                	jae    800a11 <memmove+0x47>
  8009dc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009df:	39 c2                	cmp    %eax,%edx
  8009e1:	76 2e                	jbe    800a11 <memmove+0x47>
		s += n;
		d += n;
  8009e3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e6:	89 d6                	mov    %edx,%esi
  8009e8:	09 fe                	or     %edi,%esi
  8009ea:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f0:	74 0c                	je     8009fe <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f2:	83 ef 01             	sub    $0x1,%edi
  8009f5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009f8:	fd                   	std    
  8009f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009fb:	fc                   	cld    
  8009fc:	eb 21                	jmp    800a1f <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fe:	f6 c1 03             	test   $0x3,%cl
  800a01:	75 ef                	jne    8009f2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a03:	83 ef 04             	sub    $0x4,%edi
  800a06:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a09:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a0c:	fd                   	std    
  800a0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0f:	eb ea                	jmp    8009fb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a11:	89 f2                	mov    %esi,%edx
  800a13:	09 c2                	or     %eax,%edx
  800a15:	f6 c2 03             	test   $0x3,%dl
  800a18:	74 09                	je     800a23 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1a:	89 c7                	mov    %eax,%edi
  800a1c:	fc                   	cld    
  800a1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1f:	5e                   	pop    %esi
  800a20:	5f                   	pop    %edi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a23:	f6 c1 03             	test   $0x3,%cl
  800a26:	75 f2                	jne    800a1a <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a28:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a2b:	89 c7                	mov    %eax,%edi
  800a2d:	fc                   	cld    
  800a2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a30:	eb ed                	jmp    800a1f <memmove+0x55>

00800a32 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a35:	ff 75 10             	pushl  0x10(%ebp)
  800a38:	ff 75 0c             	pushl  0xc(%ebp)
  800a3b:	ff 75 08             	pushl  0x8(%ebp)
  800a3e:	e8 87 ff ff ff       	call   8009ca <memmove>
}
  800a43:	c9                   	leave  
  800a44:	c3                   	ret    

00800a45 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a50:	89 c6                	mov    %eax,%esi
  800a52:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a55:	39 f0                	cmp    %esi,%eax
  800a57:	74 1c                	je     800a75 <memcmp+0x30>
		if (*s1 != *s2)
  800a59:	0f b6 08             	movzbl (%eax),%ecx
  800a5c:	0f b6 1a             	movzbl (%edx),%ebx
  800a5f:	38 d9                	cmp    %bl,%cl
  800a61:	75 08                	jne    800a6b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	83 c2 01             	add    $0x1,%edx
  800a69:	eb ea                	jmp    800a55 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a6b:	0f b6 c1             	movzbl %cl,%eax
  800a6e:	0f b6 db             	movzbl %bl,%ebx
  800a71:	29 d8                	sub    %ebx,%eax
  800a73:	eb 05                	jmp    800a7a <memcmp+0x35>
	}

	return 0;
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a87:	89 c2                	mov    %eax,%edx
  800a89:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8c:	39 d0                	cmp    %edx,%eax
  800a8e:	73 09                	jae    800a99 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a90:	38 08                	cmp    %cl,(%eax)
  800a92:	74 05                	je     800a99 <memfind+0x1b>
	for (; s < ends; s++)
  800a94:	83 c0 01             	add    $0x1,%eax
  800a97:	eb f3                	jmp    800a8c <memfind+0xe>
			break;
	return (void *) s;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa7:	eb 03                	jmp    800aac <strtol+0x11>
		s++;
  800aa9:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aac:	0f b6 01             	movzbl (%ecx),%eax
  800aaf:	3c 20                	cmp    $0x20,%al
  800ab1:	74 f6                	je     800aa9 <strtol+0xe>
  800ab3:	3c 09                	cmp    $0x9,%al
  800ab5:	74 f2                	je     800aa9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ab7:	3c 2b                	cmp    $0x2b,%al
  800ab9:	74 2e                	je     800ae9 <strtol+0x4e>
	int neg = 0;
  800abb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ac0:	3c 2d                	cmp    $0x2d,%al
  800ac2:	74 2f                	je     800af3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aca:	75 05                	jne    800ad1 <strtol+0x36>
  800acc:	80 39 30             	cmpb   $0x30,(%ecx)
  800acf:	74 2c                	je     800afd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad1:	85 db                	test   %ebx,%ebx
  800ad3:	75 0a                	jne    800adf <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad5:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ada:	80 39 30             	cmpb   $0x30,(%ecx)
  800add:	74 28                	je     800b07 <strtol+0x6c>
		base = 10;
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ae7:	eb 50                	jmp    800b39 <strtol+0x9e>
		s++;
  800ae9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
  800af1:	eb d1                	jmp    800ac4 <strtol+0x29>
		s++, neg = 1;
  800af3:	83 c1 01             	add    $0x1,%ecx
  800af6:	bf 01 00 00 00       	mov    $0x1,%edi
  800afb:	eb c7                	jmp    800ac4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b01:	74 0e                	je     800b11 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b03:	85 db                	test   %ebx,%ebx
  800b05:	75 d8                	jne    800adf <strtol+0x44>
		s++, base = 8;
  800b07:	83 c1 01             	add    $0x1,%ecx
  800b0a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b0f:	eb ce                	jmp    800adf <strtol+0x44>
		s += 2, base = 16;
  800b11:	83 c1 02             	add    $0x2,%ecx
  800b14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b19:	eb c4                	jmp    800adf <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b1b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b1e:	89 f3                	mov    %esi,%ebx
  800b20:	80 fb 19             	cmp    $0x19,%bl
  800b23:	77 29                	ja     800b4e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b25:	0f be d2             	movsbl %dl,%edx
  800b28:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2e:	7d 30                	jge    800b60 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b37:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b39:	0f b6 11             	movzbl (%ecx),%edx
  800b3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 09             	cmp    $0x9,%bl
  800b44:	77 d5                	ja     800b1b <strtol+0x80>
			dig = *s - '0';
  800b46:	0f be d2             	movsbl %dl,%edx
  800b49:	83 ea 30             	sub    $0x30,%edx
  800b4c:	eb dd                	jmp    800b2b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b4e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b51:	89 f3                	mov    %esi,%ebx
  800b53:	80 fb 19             	cmp    $0x19,%bl
  800b56:	77 08                	ja     800b60 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b58:	0f be d2             	movsbl %dl,%edx
  800b5b:	83 ea 37             	sub    $0x37,%edx
  800b5e:	eb cb                	jmp    800b2b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b64:	74 05                	je     800b6b <strtol+0xd0>
		*endptr = (char *) s;
  800b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b69:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b6b:	89 c2                	mov    %eax,%edx
  800b6d:	f7 da                	neg    %edx
  800b6f:	85 ff                	test   %edi,%edi
  800b71:	0f 45 c2             	cmovne %edx,%eax
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8a:	89 c3                	mov    %eax,%ebx
  800b8c:	89 c7                	mov    %eax,%edi
  800b8e:	89 c6                	mov    %eax,%esi
  800b90:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba7:	89 d1                	mov    %edx,%ecx
  800ba9:	89 d3                	mov    %edx,%ebx
  800bab:	89 d7                	mov    %edx,%edi
  800bad:	89 d6                	mov    %edx,%esi
  800baf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 1c             	sub    $0x1c,%esp
  800bbf:	e8 66 00 00 00       	call   800c2a <__x86.get_pc_thunk.ax>
  800bc4:	05 3c 14 00 00       	add    $0x143c,%eax
  800bc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800bcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd9:	89 cb                	mov    %ecx,%ebx
  800bdb:	89 cf                	mov    %ecx,%edi
  800bdd:	89 ce                	mov    %ecx,%esi
  800bdf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be1:	85 c0                	test   %eax,%eax
  800be3:	7f 08                	jg     800bed <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	50                   	push   %eax
  800bf1:	6a 03                	push   $0x3
  800bf3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800bf6:	8d 83 e4 f0 ff ff    	lea    -0xf1c(%ebx),%eax
  800bfc:	50                   	push   %eax
  800bfd:	6a 23                	push   $0x23
  800bff:	8d 83 01 f1 ff ff    	lea    -0xeff(%ebx),%eax
  800c05:	50                   	push   %eax
  800c06:	e8 23 00 00 00       	call   800c2e <_panic>

00800c0b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c11:	ba 00 00 00 00       	mov    $0x0,%edx
  800c16:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1b:	89 d1                	mov    %edx,%ecx
  800c1d:	89 d3                	mov    %edx,%ebx
  800c1f:	89 d7                	mov    %edx,%edi
  800c21:	89 d6                	mov    %edx,%esi
  800c23:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <__x86.get_pc_thunk.ax>:
  800c2a:	8b 04 24             	mov    (%esp),%eax
  800c2d:	c3                   	ret    

00800c2e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
  800c37:	e8 23 f4 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800c3c:	81 c3 c4 13 00 00    	add    $0x13c4,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c42:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c45:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c4b:	8b 38                	mov    (%eax),%edi
  800c4d:	e8 b9 ff ff ff       	call   800c0b <sys_getenvid>
  800c52:	83 ec 0c             	sub    $0xc,%esp
  800c55:	ff 75 0c             	pushl  0xc(%ebp)
  800c58:	ff 75 08             	pushl  0x8(%ebp)
  800c5b:	57                   	push   %edi
  800c5c:	50                   	push   %eax
  800c5d:	8d 83 10 f1 ff ff    	lea    -0xef0(%ebx),%eax
  800c63:	50                   	push   %eax
  800c64:	e8 13 f5 ff ff       	call   80017c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c69:	83 c4 18             	add    $0x18,%esp
  800c6c:	56                   	push   %esi
  800c6d:	ff 75 10             	pushl  0x10(%ebp)
  800c70:	e8 a5 f4 ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  800c75:	8d 83 34 f1 ff ff    	lea    -0xecc(%ebx),%eax
  800c7b:	89 04 24             	mov    %eax,(%esp)
  800c7e:	e8 f9 f4 ff ff       	call   80017c <cprintf>
  800c83:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c86:	cc                   	int3   
  800c87:	eb fd                	jmp    800c86 <_panic+0x58>
  800c89:	66 90                	xchg   %ax,%ax
  800c8b:	66 90                	xchg   %ax,%ax
  800c8d:	66 90                	xchg   %ax,%ax
  800c8f:	90                   	nop

00800c90 <__udivdi3>:
  800c90:	55                   	push   %ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 1c             	sub    $0x1c,%esp
  800c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ca3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ca7:	85 d2                	test   %edx,%edx
  800ca9:	75 35                	jne    800ce0 <__udivdi3+0x50>
  800cab:	39 f3                	cmp    %esi,%ebx
  800cad:	0f 87 bd 00 00 00    	ja     800d70 <__udivdi3+0xe0>
  800cb3:	85 db                	test   %ebx,%ebx
  800cb5:	89 d9                	mov    %ebx,%ecx
  800cb7:	75 0b                	jne    800cc4 <__udivdi3+0x34>
  800cb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cbe:	31 d2                	xor    %edx,%edx
  800cc0:	f7 f3                	div    %ebx
  800cc2:	89 c1                	mov    %eax,%ecx
  800cc4:	31 d2                	xor    %edx,%edx
  800cc6:	89 f0                	mov    %esi,%eax
  800cc8:	f7 f1                	div    %ecx
  800cca:	89 c6                	mov    %eax,%esi
  800ccc:	89 e8                	mov    %ebp,%eax
  800cce:	89 f7                	mov    %esi,%edi
  800cd0:	f7 f1                	div    %ecx
  800cd2:	89 fa                	mov    %edi,%edx
  800cd4:	83 c4 1c             	add    $0x1c,%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    
  800cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	39 f2                	cmp    %esi,%edx
  800ce2:	77 7c                	ja     800d60 <__udivdi3+0xd0>
  800ce4:	0f bd fa             	bsr    %edx,%edi
  800ce7:	83 f7 1f             	xor    $0x1f,%edi
  800cea:	0f 84 98 00 00 00    	je     800d88 <__udivdi3+0xf8>
  800cf0:	89 f9                	mov    %edi,%ecx
  800cf2:	b8 20 00 00 00       	mov    $0x20,%eax
  800cf7:	29 f8                	sub    %edi,%eax
  800cf9:	d3 e2                	shl    %cl,%edx
  800cfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cff:	89 c1                	mov    %eax,%ecx
  800d01:	89 da                	mov    %ebx,%edx
  800d03:	d3 ea                	shr    %cl,%edx
  800d05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d09:	09 d1                	or     %edx,%ecx
  800d0b:	89 f2                	mov    %esi,%edx
  800d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d11:	89 f9                	mov    %edi,%ecx
  800d13:	d3 e3                	shl    %cl,%ebx
  800d15:	89 c1                	mov    %eax,%ecx
  800d17:	d3 ea                	shr    %cl,%edx
  800d19:	89 f9                	mov    %edi,%ecx
  800d1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d1f:	d3 e6                	shl    %cl,%esi
  800d21:	89 eb                	mov    %ebp,%ebx
  800d23:	89 c1                	mov    %eax,%ecx
  800d25:	d3 eb                	shr    %cl,%ebx
  800d27:	09 de                	or     %ebx,%esi
  800d29:	89 f0                	mov    %esi,%eax
  800d2b:	f7 74 24 08          	divl   0x8(%esp)
  800d2f:	89 d6                	mov    %edx,%esi
  800d31:	89 c3                	mov    %eax,%ebx
  800d33:	f7 64 24 0c          	mull   0xc(%esp)
  800d37:	39 d6                	cmp    %edx,%esi
  800d39:	72 0c                	jb     800d47 <__udivdi3+0xb7>
  800d3b:	89 f9                	mov    %edi,%ecx
  800d3d:	d3 e5                	shl    %cl,%ebp
  800d3f:	39 c5                	cmp    %eax,%ebp
  800d41:	73 5d                	jae    800da0 <__udivdi3+0x110>
  800d43:	39 d6                	cmp    %edx,%esi
  800d45:	75 59                	jne    800da0 <__udivdi3+0x110>
  800d47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d4a:	31 ff                	xor    %edi,%edi
  800d4c:	89 fa                	mov    %edi,%edx
  800d4e:	83 c4 1c             	add    $0x1c,%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
  800d56:	8d 76 00             	lea    0x0(%esi),%esi
  800d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d60:	31 ff                	xor    %edi,%edi
  800d62:	31 c0                	xor    %eax,%eax
  800d64:	89 fa                	mov    %edi,%edx
  800d66:	83 c4 1c             	add    $0x1c,%esp
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    
  800d6e:	66 90                	xchg   %ax,%ax
  800d70:	31 ff                	xor    %edi,%edi
  800d72:	89 e8                	mov    %ebp,%eax
  800d74:	89 f2                	mov    %esi,%edx
  800d76:	f7 f3                	div    %ebx
  800d78:	89 fa                	mov    %edi,%edx
  800d7a:	83 c4 1c             	add    $0x1c,%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    
  800d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d88:	39 f2                	cmp    %esi,%edx
  800d8a:	72 06                	jb     800d92 <__udivdi3+0x102>
  800d8c:	31 c0                	xor    %eax,%eax
  800d8e:	39 eb                	cmp    %ebp,%ebx
  800d90:	77 d2                	ja     800d64 <__udivdi3+0xd4>
  800d92:	b8 01 00 00 00       	mov    $0x1,%eax
  800d97:	eb cb                	jmp    800d64 <__udivdi3+0xd4>
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	89 d8                	mov    %ebx,%eax
  800da2:	31 ff                	xor    %edi,%edi
  800da4:	eb be                	jmp    800d64 <__udivdi3+0xd4>
  800da6:	66 90                	xchg   %ax,%ax
  800da8:	66 90                	xchg   %ax,%ax
  800daa:	66 90                	xchg   %ax,%ax
  800dac:	66 90                	xchg   %ax,%ax
  800dae:	66 90                	xchg   %ax,%ax

00800db0 <__umoddi3>:
  800db0:	55                   	push   %ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 1c             	sub    $0x1c,%esp
  800db7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800dbb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dbf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dc7:	85 ed                	test   %ebp,%ebp
  800dc9:	89 f0                	mov    %esi,%eax
  800dcb:	89 da                	mov    %ebx,%edx
  800dcd:	75 19                	jne    800de8 <__umoddi3+0x38>
  800dcf:	39 df                	cmp    %ebx,%edi
  800dd1:	0f 86 b1 00 00 00    	jbe    800e88 <__umoddi3+0xd8>
  800dd7:	f7 f7                	div    %edi
  800dd9:	89 d0                	mov    %edx,%eax
  800ddb:	31 d2                	xor    %edx,%edx
  800ddd:	83 c4 1c             	add    $0x1c,%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
  800de5:	8d 76 00             	lea    0x0(%esi),%esi
  800de8:	39 dd                	cmp    %ebx,%ebp
  800dea:	77 f1                	ja     800ddd <__umoddi3+0x2d>
  800dec:	0f bd cd             	bsr    %ebp,%ecx
  800def:	83 f1 1f             	xor    $0x1f,%ecx
  800df2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800df6:	0f 84 b4 00 00 00    	je     800eb0 <__umoddi3+0x100>
  800dfc:	b8 20 00 00 00       	mov    $0x20,%eax
  800e01:	89 c2                	mov    %eax,%edx
  800e03:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e07:	29 c2                	sub    %eax,%edx
  800e09:	89 c1                	mov    %eax,%ecx
  800e0b:	89 f8                	mov    %edi,%eax
  800e0d:	d3 e5                	shl    %cl,%ebp
  800e0f:	89 d1                	mov    %edx,%ecx
  800e11:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e15:	d3 e8                	shr    %cl,%eax
  800e17:	09 c5                	or     %eax,%ebp
  800e19:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e1d:	89 c1                	mov    %eax,%ecx
  800e1f:	d3 e7                	shl    %cl,%edi
  800e21:	89 d1                	mov    %edx,%ecx
  800e23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e27:	89 df                	mov    %ebx,%edi
  800e29:	d3 ef                	shr    %cl,%edi
  800e2b:	89 c1                	mov    %eax,%ecx
  800e2d:	89 f0                	mov    %esi,%eax
  800e2f:	d3 e3                	shl    %cl,%ebx
  800e31:	89 d1                	mov    %edx,%ecx
  800e33:	89 fa                	mov    %edi,%edx
  800e35:	d3 e8                	shr    %cl,%eax
  800e37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e3c:	09 d8                	or     %ebx,%eax
  800e3e:	f7 f5                	div    %ebp
  800e40:	d3 e6                	shl    %cl,%esi
  800e42:	89 d1                	mov    %edx,%ecx
  800e44:	f7 64 24 08          	mull   0x8(%esp)
  800e48:	39 d1                	cmp    %edx,%ecx
  800e4a:	89 c3                	mov    %eax,%ebx
  800e4c:	89 d7                	mov    %edx,%edi
  800e4e:	72 06                	jb     800e56 <__umoddi3+0xa6>
  800e50:	75 0e                	jne    800e60 <__umoddi3+0xb0>
  800e52:	39 c6                	cmp    %eax,%esi
  800e54:	73 0a                	jae    800e60 <__umoddi3+0xb0>
  800e56:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e5a:	19 ea                	sbb    %ebp,%edx
  800e5c:	89 d7                	mov    %edx,%edi
  800e5e:	89 c3                	mov    %eax,%ebx
  800e60:	89 ca                	mov    %ecx,%edx
  800e62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e67:	29 de                	sub    %ebx,%esi
  800e69:	19 fa                	sbb    %edi,%edx
  800e6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e6f:	89 d0                	mov    %edx,%eax
  800e71:	d3 e0                	shl    %cl,%eax
  800e73:	89 d9                	mov    %ebx,%ecx
  800e75:	d3 ee                	shr    %cl,%esi
  800e77:	d3 ea                	shr    %cl,%edx
  800e79:	09 f0                	or     %esi,%eax
  800e7b:	83 c4 1c             	add    $0x1c,%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5f                   	pop    %edi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    
  800e83:	90                   	nop
  800e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e88:	85 ff                	test   %edi,%edi
  800e8a:	89 f9                	mov    %edi,%ecx
  800e8c:	75 0b                	jne    800e99 <__umoddi3+0xe9>
  800e8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e93:	31 d2                	xor    %edx,%edx
  800e95:	f7 f7                	div    %edi
  800e97:	89 c1                	mov    %eax,%ecx
  800e99:	89 d8                	mov    %ebx,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	f7 f1                	div    %ecx
  800e9f:	89 f0                	mov    %esi,%eax
  800ea1:	f7 f1                	div    %ecx
  800ea3:	e9 31 ff ff ff       	jmp    800dd9 <__umoddi3+0x29>
  800ea8:	90                   	nop
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	39 dd                	cmp    %ebx,%ebp
  800eb2:	72 08                	jb     800ebc <__umoddi3+0x10c>
  800eb4:	39 f7                	cmp    %esi,%edi
  800eb6:	0f 87 21 ff ff ff    	ja     800ddd <__umoddi3+0x2d>
  800ebc:	89 da                	mov    %ebx,%edx
  800ebe:	89 f0                	mov    %esi,%eax
  800ec0:	29 f8                	sub    %edi,%eax
  800ec2:	19 ea                	sbb    %ebp,%edx
  800ec4:	e9 14 ff ff ff       	jmp    800ddd <__umoddi3+0x2d>
