
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
  80004b:	8d 83 dc ee ff ff    	lea    -0x1124(%ebx),%eax
  800051:	50                   	push   %eax
  800052:	e8 3c 01 00 00       	call   800193 <cprintf>
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
  800066:	57                   	push   %edi
  800067:	56                   	push   %esi
  800068:	53                   	push   %ebx
  800069:	83 ec 0c             	sub    $0xc,%esp
  80006c:	e8 ee ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800071:	81 c3 8f 1f 00 00    	add    $0x1f8f,%ebx
  800077:	8b 75 08             	mov    0x8(%ebp),%esi
  80007a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80007d:	e8 a0 0b 00 00       	call   800c22 <sys_getenvid>
  800082:	25 ff 03 00 00       	and    $0x3ff,%eax
  800087:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80008a:	c1 e0 05             	shl    $0x5,%eax
  80008d:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800093:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800099:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009b:	85 f6                	test   %esi,%esi
  80009d:	7e 08                	jle    8000a7 <libmain+0x44>
		binaryname = argv[0];
  80009f:	8b 07                	mov    (%edi),%eax
  8000a1:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a7:	83 ec 08             	sub    $0x8,%esp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	e8 82 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b1:	e8 0b 00 00 00       	call   8000c1 <exit>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5f                   	pop    %edi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	53                   	push   %ebx
  8000c5:	83 ec 10             	sub    $0x10,%esp
  8000c8:	e8 92 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000cd:	81 c3 33 1f 00 00    	add    $0x1f33,%ebx
	sys_env_destroy(0);
  8000d3:	6a 00                	push   $0x0
  8000d5:	e8 f3 0a 00 00       	call   800bcd <sys_env_destroy>
}
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    

008000e2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 73 ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8000ec:	81 c3 14 1f 00 00    	add    $0x1f14,%ebx
  8000f2:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f5:	8b 16                	mov    (%esi),%edx
  8000f7:	8d 42 01             	lea    0x1(%edx),%eax
  8000fa:	89 06                	mov    %eax,(%esi)
  8000fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ff:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800103:	3d ff 00 00 00       	cmp    $0xff,%eax
  800108:	74 0b                	je     800115 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80010a:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80010e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	68 ff 00 00 00       	push   $0xff
  80011d:	8d 46 08             	lea    0x8(%esi),%eax
  800120:	50                   	push   %eax
  800121:	e8 6a 0a 00 00       	call   800b90 <sys_cputs>
		b->idx = 0;
  800126:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	eb d9                	jmp    80010a <putch+0x28>

00800131 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	53                   	push   %ebx
  800135:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80013b:	e8 1f ff ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800140:	81 c3 c0 1e 00 00    	add    $0x1ec0,%ebx
	struct printbuf b;

	b.idx = 0;
  800146:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014d:	00 00 00 
	b.cnt = 0;
  800150:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800157:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800166:	50                   	push   %eax
  800167:	8d 83 e2 e0 ff ff    	lea    -0x1f1e(%ebx),%eax
  80016d:	50                   	push   %eax
  80016e:	e8 38 01 00 00       	call   8002ab <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800182:	50                   	push   %eax
  800183:	e8 08 0a 00 00       	call   800b90 <sys_cputs>
	return b.cnt;
}
  800188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800199:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019c:	50                   	push   %eax
  80019d:	ff 75 08             	pushl  0x8(%ebp)
  8001a0:	e8 8c ff ff ff       	call   800131 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 2c             	sub    $0x2c,%esp
  8001b0:	e8 63 06 00 00       	call   800818 <__x86.get_pc_thunk.cx>
  8001b5:	81 c1 4b 1e 00 00    	add    $0x1e4b,%ecx
  8001bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001be:	89 c7                	mov    %eax,%edi
  8001c0:	89 d6                	mov    %edx,%esi
  8001c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001cb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001d9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001dc:	39 d3                	cmp    %edx,%ebx
  8001de:	72 09                	jb     8001e9 <printnum+0x42>
  8001e0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e3:	0f 87 83 00 00 00    	ja     80026c <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	ff 75 18             	pushl  0x18(%ebp)
  8001ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f5:	53                   	push   %ebx
  8001f6:	ff 75 10             	pushl  0x10(%ebp)
  8001f9:	83 ec 08             	sub    $0x8,%esp
  8001fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800202:	ff 75 d4             	pushl  -0x2c(%ebp)
  800205:	ff 75 d0             	pushl  -0x30(%ebp)
  800208:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80020b:	e8 90 0a 00 00       	call   800ca0 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 89 ff ff ff       	call   8001a7 <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 13                	jmp    800236 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	85 db                	test   %ebx,%ebx
  800234:	7f ed                	jg     800223 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	83 ec 04             	sub    $0x4,%esp
  80023d:	ff 75 dc             	pushl  -0x24(%ebp)
  800240:	ff 75 d8             	pushl  -0x28(%ebp)
  800243:	ff 75 d4             	pushl  -0x2c(%ebp)
  800246:	ff 75 d0             	pushl  -0x30(%ebp)
  800249:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80024c:	89 f3                	mov    %esi,%ebx
  80024e:	e8 6d 0b 00 00       	call   800dc0 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 84 06 0d ef ff 	movsbl -0x10f3(%esi,%eax,1),%eax
  80025d:	ff 
  80025e:	50                   	push   %eax
  80025f:	ff d7                	call   *%edi
}
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    
  80026c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026f:	eb be                	jmp    80022f <printnum+0x88>

00800271 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800277:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027b:	8b 10                	mov    (%eax),%edx
  80027d:	3b 50 04             	cmp    0x4(%eax),%edx
  800280:	73 0a                	jae    80028c <sprintputch+0x1b>
		*b->buf++ = ch;
  800282:	8d 4a 01             	lea    0x1(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 45 08             	mov    0x8(%ebp),%eax
  80028a:	88 02                	mov    %al,(%edx)
}
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <printfmt>:
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800294:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800297:	50                   	push   %eax
  800298:	ff 75 10             	pushl  0x10(%ebp)
  80029b:	ff 75 0c             	pushl  0xc(%ebp)
  80029e:	ff 75 08             	pushl  0x8(%ebp)
  8002a1:	e8 05 00 00 00       	call   8002ab <vprintfmt>
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	c9                   	leave  
  8002aa:	c3                   	ret    

008002ab <vprintfmt>:
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
  8002b1:	83 ec 2c             	sub    $0x2c,%esp
  8002b4:	e8 a6 fd ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8002b9:	81 c3 47 1d 00 00    	add    $0x1d47,%ebx
  8002bf:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8002c2:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8002c9:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cb:	8d 77 01             	lea    0x1(%edi),%esi
  8002ce:	0f b6 07             	movzbl (%edi),%eax
  8002d1:	83 f8 25             	cmp    $0x25,%eax
  8002d4:	74 1c                	je     8002f2 <vprintfmt+0x47>
			if (ch == '\0')
  8002d6:	85 c0                	test   %eax,%eax
  8002d8:	0f 84 b9 04 00 00    	je     800797 <.L21+0x20>
			putch(ch, putdat);
  8002de:	83 ec 08             	sub    $0x8,%esp
  8002e1:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8002e4:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8002e7:	50                   	push   %eax
  8002e8:	ff 55 08             	call   *0x8(%ebp)
  8002eb:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ee:	89 f7                	mov    %esi,%edi
  8002f0:	eb d9                	jmp    8002cb <vprintfmt+0x20>
		padc = ' ';
  8002f2:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8002f6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002fd:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800304:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80030b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800310:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800313:	8d 7e 01             	lea    0x1(%esi),%edi
  800316:	0f b6 16             	movzbl (%esi),%edx
  800319:	8d 42 dd             	lea    -0x23(%edx),%eax
  80031c:	3c 55                	cmp    $0x55,%al
  80031e:	0f 87 53 04 00 00    	ja     800777 <.L21>
  800324:	0f b6 c0             	movzbl %al,%eax
  800327:	89 d9                	mov    %ebx,%ecx
  800329:	03 8c 83 9c ef ff ff 	add    -0x1064(%ebx,%eax,4),%ecx
  800330:	ff e1                	jmp    *%ecx

00800332 <.L73>:
  800332:	89 fe                	mov    %edi,%esi
			padc = '-';
  800334:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800338:	eb d9                	jmp    800313 <vprintfmt+0x68>

0080033a <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	89 fe                	mov    %edi,%esi
			padc = '0';
  80033c:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800340:	eb d1                	jmp    800313 <vprintfmt+0x68>

00800342 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	0f b6 d2             	movzbl %dl,%edx
  800345:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800347:	b8 00 00 00 00       	mov    $0x0,%eax
  80034c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  80034f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800352:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800356:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800359:	8d 7a d0             	lea    -0x30(%edx),%edi
  80035c:	83 ff 09             	cmp    $0x9,%edi
  80035f:	0f 87 94 00 00 00    	ja     8003f9 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800365:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800368:	eb e5                	jmp    80034f <.L28+0xd>

0080036a <.L25>:
			precision = va_arg(ap, int);
  80036a:	8b 45 14             	mov    0x14(%ebp),%eax
  80036d:	8b 00                	mov    (%eax),%eax
  80036f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800372:	8b 45 14             	mov    0x14(%ebp),%eax
  800375:	8d 40 04             	lea    0x4(%eax),%eax
  800378:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	89 fe                	mov    %edi,%esi
			if (width < 0)
  80037d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800381:	79 90                	jns    800313 <vprintfmt+0x68>
				width = precision, precision = -1;
  800383:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800386:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800389:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800390:	eb 81                	jmp    800313 <vprintfmt+0x68>

00800392 <.L26>:
  800392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800395:	85 c0                	test   %eax,%eax
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	0f 49 d0             	cmovns %eax,%edx
  80039f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	89 fe                	mov    %edi,%esi
  8003a4:	e9 6a ff ff ff       	jmp    800313 <vprintfmt+0x68>

008003a9 <.L22>:
  8003a9:	89 fe                	mov    %edi,%esi
			altflag = 1;
  8003ab:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b2:	e9 5c ff ff ff       	jmp    800313 <vprintfmt+0x68>

008003b7 <.L33>:
  8003b7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8003ba:	83 f9 01             	cmp    $0x1,%ecx
  8003bd:	7e 16                	jle    8003d5 <.L33+0x1e>
		return va_arg(*ap, long long);
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8b 00                	mov    (%eax),%eax
  8003c4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003c7:	8d 49 08             	lea    0x8(%ecx),%ecx
  8003ca:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8003cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8003d0:	e9 f6 fe ff ff       	jmp    8002cb <vprintfmt+0x20>
	else if (lflag)
  8003d5:	85 c9                	test   %ecx,%ecx
  8003d7:	75 10                	jne    8003e9 <.L33+0x32>
		return va_arg(*ap, int);
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003e1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8003e4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e7:	eb e4                	jmp    8003cd <.L33+0x16>
		return va_arg(*ap, long);
  8003e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ec:	8b 00                	mov    (%eax),%eax
  8003ee:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003f1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8003f4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f7:	eb d4                	jmp    8003cd <.L33+0x16>
  8003f9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ff:	e9 79 ff ff ff       	jmp    80037d <.L25+0x13>

00800404 <.L32>:
			lflag++;
  800404:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800408:	89 fe                	mov    %edi,%esi
			goto reswitch;
  80040a:	e9 04 ff ff ff       	jmp    800313 <vprintfmt+0x68>

0080040f <.L29>:
			putch(va_arg(ap, int), putdat);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 70 04             	lea    0x4(%eax),%esi
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 30                	pushl  (%eax)
  80041d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800420:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800423:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800426:	e9 a0 fe ff ff       	jmp    8002cb <vprintfmt+0x20>

0080042b <.L31>:
			err = va_arg(ap, int);
  80042b:	8b 45 14             	mov    0x14(%ebp),%eax
  80042e:	8d 70 04             	lea    0x4(%eax),%esi
  800431:	8b 00                	mov    (%eax),%eax
  800433:	99                   	cltd   
  800434:	31 d0                	xor    %edx,%eax
  800436:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800438:	83 f8 06             	cmp    $0x6,%eax
  80043b:	7f 29                	jg     800466 <.L31+0x3b>
  80043d:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800444:	85 d2                	test   %edx,%edx
  800446:	74 1e                	je     800466 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800448:	52                   	push   %edx
  800449:	8d 83 2e ef ff ff    	lea    -0x10d2(%ebx),%eax
  80044f:	50                   	push   %eax
  800450:	ff 75 0c             	pushl  0xc(%ebp)
  800453:	ff 75 08             	pushl  0x8(%ebp)
  800456:	e8 33 fe ff ff       	call   80028e <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045e:	89 75 14             	mov    %esi,0x14(%ebp)
  800461:	e9 65 fe ff ff       	jmp    8002cb <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800466:	50                   	push   %eax
  800467:	8d 83 25 ef ff ff    	lea    -0x10db(%ebx),%eax
  80046d:	50                   	push   %eax
  80046e:	ff 75 0c             	pushl  0xc(%ebp)
  800471:	ff 75 08             	pushl  0x8(%ebp)
  800474:	e8 15 fe ff ff       	call   80028e <printfmt>
  800479:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047c:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80047f:	e9 47 fe ff ff       	jmp    8002cb <vprintfmt+0x20>

00800484 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	83 c0 04             	add    $0x4,%eax
  80048a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800492:	85 f6                	test   %esi,%esi
  800494:	8d 83 1e ef ff ff    	lea    -0x10e2(%ebx),%eax
  80049a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80049d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a1:	0f 8e b4 00 00 00    	jle    80055b <.L36+0xd7>
  8004a7:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8004ab:	75 08                	jne    8004b5 <.L36+0x31>
  8004ad:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004b0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004b3:	eb 6c                	jmp    800521 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	ff 75 cc             	pushl  -0x34(%ebp)
  8004bb:	56                   	push   %esi
  8004bc:	e8 73 03 00 00       	call   800834 <strnlen>
  8004c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c4:	29 c2                	sub    %eax,%edx
  8004c6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004cc:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004d0:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004d3:	89 d6                	mov    %edx,%esi
  8004d5:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004d8:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	eb 10                	jmp    8004ec <.L36+0x68>
					putch(padc, putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	ff 75 0c             	pushl  0xc(%ebp)
  8004e2:	57                   	push   %edi
  8004e3:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	83 ee 01             	sub    $0x1,%esi
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	85 f6                	test   %esi,%esi
  8004ee:	7f ec                	jg     8004dc <.L36+0x58>
  8004f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f6:	85 d2                	test   %edx,%edx
  8004f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fd:	0f 49 c2             	cmovns %edx,%eax
  800500:	29 c2                	sub    %eax,%edx
  800502:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800505:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800508:	eb 17                	jmp    800521 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050e:	75 30                	jne    800540 <.L36+0xbc>
					putch(ch, putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	ff 75 0c             	pushl  0xc(%ebp)
  800516:	50                   	push   %eax
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800521:	83 c6 01             	add    $0x1,%esi
  800524:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800528:	0f be c2             	movsbl %dl,%eax
  80052b:	85 c0                	test   %eax,%eax
  80052d:	74 58                	je     800587 <.L36+0x103>
  80052f:	85 ff                	test   %edi,%edi
  800531:	78 d7                	js     80050a <.L36+0x86>
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	79 d2                	jns    80050a <.L36+0x86>
  800538:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80053b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80053e:	eb 32                	jmp    800572 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800540:	0f be d2             	movsbl %dl,%edx
  800543:	83 ea 20             	sub    $0x20,%edx
  800546:	83 fa 5e             	cmp    $0x5e,%edx
  800549:	76 c5                	jbe    800510 <.L36+0x8c>
					putch('?', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	ff 75 0c             	pushl  0xc(%ebp)
  800551:	6a 3f                	push   $0x3f
  800553:	ff 55 08             	call   *0x8(%ebp)
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	eb c2                	jmp    80051d <.L36+0x99>
  80055b:	89 7d 10             	mov    %edi,0x10(%ebp)
  80055e:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800561:	eb be                	jmp    800521 <.L36+0x9d>
				putch(' ', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	57                   	push   %edi
  800567:	6a 20                	push   $0x20
  800569:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80056c:	83 ee 01             	sub    $0x1,%esi
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	85 f6                	test   %esi,%esi
  800574:	7f ed                	jg     800563 <.L36+0xdf>
  800576:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800579:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  80057c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
  800582:	e9 44 fd ff ff       	jmp    8002cb <vprintfmt+0x20>
  800587:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80058a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80058d:	eb e3                	jmp    800572 <.L36+0xee>

0080058f <.L30>:
  80058f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800592:	83 f9 01             	cmp    $0x1,%ecx
  800595:	7e 42                	jle    8005d9 <.L30+0x4a>
		return va_arg(*ap, long long);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 50 04             	mov    0x4(%eax),%edx
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 40 08             	lea    0x8(%eax),%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b2:	79 5f                	jns    800613 <.L30+0x84>
				putch('-', putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ba:	6a 2d                	push   $0x2d
  8005bc:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c5:	f7 da                	neg    %edx
  8005c7:	83 d1 00             	adc    $0x0,%ecx
  8005ca:	f7 d9                	neg    %ecx
  8005cc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d4:	e9 b8 00 00 00       	jmp    800691 <.L34+0x22>
	else if (lflag)
  8005d9:	85 c9                	test   %ecx,%ecx
  8005db:	75 1b                	jne    8005f8 <.L30+0x69>
		return va_arg(*ap, int);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 30                	mov    (%eax),%esi
  8005e2:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005e5:	89 f0                	mov    %esi,%eax
  8005e7:	c1 f8 1f             	sar    $0x1f,%eax
  8005ea:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f6:	eb b6                	jmp    8005ae <.L30+0x1f>
		return va_arg(*ap, long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 30                	mov    (%eax),%esi
  8005fd:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800600:	89 f0                	mov    %esi,%eax
  800602:	c1 f8 1f             	sar    $0x1f,%eax
  800605:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 40 04             	lea    0x4(%eax),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
  800611:	eb 9b                	jmp    8005ae <.L30+0x1f>
			num = getint(&ap, lflag);
  800613:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800616:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	eb 71                	jmp    800691 <.L34+0x22>

00800620 <.L37>:
  800620:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7e 15                	jle    80063d <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	8b 48 04             	mov    0x4(%eax),%ecx
  800630:	8d 40 08             	lea    0x8(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063b:	eb 54                	jmp    800691 <.L34+0x22>
	else if (lflag)
  80063d:	85 c9                	test   %ecx,%ecx
  80063f:	75 17                	jne    800658 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 10                	mov    (%eax),%edx
  800646:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064b:	8d 40 04             	lea    0x4(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800651:	b8 0a 00 00 00       	mov    $0xa,%eax
  800656:	eb 39                	jmp    800691 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800668:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066d:	eb 22                	jmp    800691 <.L34+0x22>

0080066f <.L34>:
  80066f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800672:	83 f9 01             	cmp    $0x1,%ecx
  800675:	7e 3b                	jle    8006b2 <.L34+0x43>
		return va_arg(*ap, long long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 50 04             	mov    0x4(%eax),%edx
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800682:	8d 49 08             	lea    0x8(%ecx),%ecx
  800685:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800688:	89 d1                	mov    %edx,%ecx
  80068a:	89 c2                	mov    %eax,%edx
			base = 8;
  80068c:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800691:	83 ec 0c             	sub    $0xc,%esp
  800694:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800698:	56                   	push   %esi
  800699:	ff 75 e0             	pushl  -0x20(%ebp)
  80069c:	50                   	push   %eax
  80069d:	51                   	push   %ecx
  80069e:	52                   	push   %edx
  80069f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a5:	e8 fd fa ff ff       	call   8001a7 <printnum>
			break;
  8006aa:	83 c4 20             	add    $0x20,%esp
  8006ad:	e9 19 fc ff ff       	jmp    8002cb <vprintfmt+0x20>
	else if (lflag)
  8006b2:	85 c9                	test   %ecx,%ecx
  8006b4:	75 13                	jne    8006c9 <.L34+0x5a>
		return va_arg(*ap, int);
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8b 10                	mov    (%eax),%edx
  8006bb:	89 d0                	mov    %edx,%eax
  8006bd:	99                   	cltd   
  8006be:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006c1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006c4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c7:	eb bf                	jmp    800688 <.L34+0x19>
		return va_arg(*ap, long);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	89 d0                	mov    %edx,%eax
  8006d0:	99                   	cltd   
  8006d1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006d4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006da:	eb ac                	jmp    800688 <.L34+0x19>

008006dc <.L35>:
			putch('0', putdat);
  8006dc:	83 ec 08             	sub    $0x8,%esp
  8006df:	ff 75 0c             	pushl  0xc(%ebp)
  8006e2:	6a 30                	push   $0x30
  8006e4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006e7:	83 c4 08             	add    $0x8,%esp
  8006ea:	ff 75 0c             	pushl  0xc(%ebp)
  8006ed:	6a 78                	push   $0x78
  8006ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 10                	mov    (%eax),%edx
  8006f7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006fc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800705:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80070a:	eb 85                	jmp    800691 <.L34+0x22>

0080070c <.L38>:
  80070c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80070f:	83 f9 01             	cmp    $0x1,%ecx
  800712:	7e 18                	jle    80072c <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
  800719:	8b 48 04             	mov    0x4(%eax),%ecx
  80071c:	8d 40 08             	lea    0x8(%eax),%eax
  80071f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800722:	b8 10 00 00 00       	mov    $0x10,%eax
  800727:	e9 65 ff ff ff       	jmp    800691 <.L34+0x22>
	else if (lflag)
  80072c:	85 c9                	test   %ecx,%ecx
  80072e:	75 1a                	jne    80074a <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8b 10                	mov    (%eax),%edx
  800735:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073a:	8d 40 04             	lea    0x4(%eax),%eax
  80073d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800740:	b8 10 00 00 00       	mov    $0x10,%eax
  800745:	e9 47 ff ff ff       	jmp    800691 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 10                	mov    (%eax),%edx
  80074f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80075a:	b8 10 00 00 00       	mov    $0x10,%eax
  80075f:	e9 2d ff ff ff       	jmp    800691 <.L34+0x22>

00800764 <.L24>:
			putch(ch, putdat);
  800764:	83 ec 08             	sub    $0x8,%esp
  800767:	ff 75 0c             	pushl  0xc(%ebp)
  80076a:	6a 25                	push   $0x25
  80076c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80076f:	83 c4 10             	add    $0x10,%esp
  800772:	e9 54 fb ff ff       	jmp    8002cb <vprintfmt+0x20>

00800777 <.L21>:
			putch('%', putdat);
  800777:	83 ec 08             	sub    $0x8,%esp
  80077a:	ff 75 0c             	pushl  0xc(%ebp)
  80077d:	6a 25                	push   $0x25
  80077f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	89 f7                	mov    %esi,%edi
  800787:	eb 03                	jmp    80078c <.L21+0x15>
  800789:	83 ef 01             	sub    $0x1,%edi
  80078c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800790:	75 f7                	jne    800789 <.L21+0x12>
  800792:	e9 34 fb ff ff       	jmp    8002cb <vprintfmt+0x20>
}
  800797:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80079a:	5b                   	pop    %ebx
  80079b:	5e                   	pop    %esi
  80079c:	5f                   	pop    %edi
  80079d:	5d                   	pop    %ebp
  80079e:	c3                   	ret    

0080079f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	53                   	push   %ebx
  8007a3:	83 ec 14             	sub    $0x14,%esp
  8007a6:	e8 b4 f8 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  8007ab:	81 c3 55 18 00 00    	add    $0x1855,%ebx
  8007b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007be:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c8:	85 c0                	test   %eax,%eax
  8007ca:	74 2b                	je     8007f7 <vsnprintf+0x58>
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	7e 27                	jle    8007f7 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d0:	ff 75 14             	pushl  0x14(%ebp)
  8007d3:	ff 75 10             	pushl  0x10(%ebp)
  8007d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	8d 83 71 e2 ff ff    	lea    -0x1d8f(%ebx),%eax
  8007e0:	50                   	push   %eax
  8007e1:	e8 c5 fa ff ff       	call   8002ab <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ef:	83 c4 10             	add    $0x10,%esp
}
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    
		return -E_INVAL;
  8007f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fc:	eb f4                	jmp    8007f2 <vsnprintf+0x53>

008007fe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800804:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800807:	50                   	push   %eax
  800808:	ff 75 10             	pushl  0x10(%ebp)
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	ff 75 08             	pushl  0x8(%ebp)
  800811:	e8 89 ff ff ff       	call   80079f <vsnprintf>
	va_end(ap);

	return rc;
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    

00800818 <__x86.get_pc_thunk.cx>:
  800818:	8b 0c 24             	mov    (%esp),%ecx
  80081b:	c3                   	ret    

0080081c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
  800827:	eb 03                	jmp    80082c <strlen+0x10>
		n++;
  800829:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80082c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800830:	75 f7                	jne    800829 <strlen+0xd>
	return n;
}
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
  800842:	eb 03                	jmp    800847 <strnlen+0x13>
		n++;
  800844:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	39 d0                	cmp    %edx,%eax
  800849:	74 06                	je     800851 <strnlen+0x1d>
  80084b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084f:	75 f3                	jne    800844 <strnlen+0x10>
	return n;
}
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085d:	89 c2                	mov    %eax,%edx
  80085f:	83 c1 01             	add    $0x1,%ecx
  800862:	83 c2 01             	add    $0x1,%edx
  800865:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800869:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086c:	84 db                	test   %bl,%bl
  80086e:	75 ef                	jne    80085f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087a:	53                   	push   %ebx
  80087b:	e8 9c ff ff ff       	call   80081c <strlen>
  800880:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800883:	ff 75 0c             	pushl  0xc(%ebp)
  800886:	01 d8                	add    %ebx,%eax
  800888:	50                   	push   %eax
  800889:	e8 c5 ff ff ff       	call   800853 <strcpy>
	return dst;
}
  80088e:	89 d8                	mov    %ebx,%eax
  800890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800893:	c9                   	leave  
  800894:	c3                   	ret    

00800895 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	8b 75 08             	mov    0x8(%ebp),%esi
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a0:	89 f3                	mov    %esi,%ebx
  8008a2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a5:	89 f2                	mov    %esi,%edx
  8008a7:	eb 0f                	jmp    8008b8 <strncpy+0x23>
		*dst++ = *src;
  8008a9:	83 c2 01             	add    $0x1,%edx
  8008ac:	0f b6 01             	movzbl (%ecx),%eax
  8008af:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b5:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008b8:	39 da                	cmp    %ebx,%edx
  8008ba:	75 ed                	jne    8008a9 <strncpy+0x14>
	}
	return ret;
}
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008d0:	89 f0                	mov    %esi,%eax
  8008d2:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d6:	85 c9                	test   %ecx,%ecx
  8008d8:	75 0b                	jne    8008e5 <strlcpy+0x23>
  8008da:	eb 17                	jmp    8008f3 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008dc:	83 c2 01             	add    $0x1,%edx
  8008df:	83 c0 01             	add    $0x1,%eax
  8008e2:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008e5:	39 d8                	cmp    %ebx,%eax
  8008e7:	74 07                	je     8008f0 <strlcpy+0x2e>
  8008e9:	0f b6 0a             	movzbl (%edx),%ecx
  8008ec:	84 c9                	test   %cl,%cl
  8008ee:	75 ec                	jne    8008dc <strlcpy+0x1a>
		*dst = '\0';
  8008f0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f3:	29 f0                	sub    %esi,%eax
}
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800902:	eb 06                	jmp    80090a <strcmp+0x11>
		p++, q++;
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80090a:	0f b6 01             	movzbl (%ecx),%eax
  80090d:	84 c0                	test   %al,%al
  80090f:	74 04                	je     800915 <strcmp+0x1c>
  800911:	3a 02                	cmp    (%edx),%al
  800913:	74 ef                	je     800904 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800915:	0f b6 c0             	movzbl %al,%eax
  800918:	0f b6 12             	movzbl (%edx),%edx
  80091b:	29 d0                	sub    %edx,%eax
}
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	53                   	push   %ebx
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	89 c3                	mov    %eax,%ebx
  80092b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092e:	eb 06                	jmp    800936 <strncmp+0x17>
		n--, p++, q++;
  800930:	83 c0 01             	add    $0x1,%eax
  800933:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800936:	39 d8                	cmp    %ebx,%eax
  800938:	74 16                	je     800950 <strncmp+0x31>
  80093a:	0f b6 08             	movzbl (%eax),%ecx
  80093d:	84 c9                	test   %cl,%cl
  80093f:	74 04                	je     800945 <strncmp+0x26>
  800941:	3a 0a                	cmp    (%edx),%cl
  800943:	74 eb                	je     800930 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800945:	0f b6 00             	movzbl (%eax),%eax
  800948:	0f b6 12             	movzbl (%edx),%edx
  80094b:	29 d0                	sub    %edx,%eax
}
  80094d:	5b                   	pop    %ebx
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    
		return 0;
  800950:	b8 00 00 00 00       	mov    $0x0,%eax
  800955:	eb f6                	jmp    80094d <strncmp+0x2e>

00800957 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800961:	0f b6 10             	movzbl (%eax),%edx
  800964:	84 d2                	test   %dl,%dl
  800966:	74 09                	je     800971 <strchr+0x1a>
		if (*s == c)
  800968:	38 ca                	cmp    %cl,%dl
  80096a:	74 0a                	je     800976 <strchr+0x1f>
	for (; *s; s++)
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	eb f0                	jmp    800961 <strchr+0xa>
			return (char *) s;
	return 0;
  800971:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800982:	eb 03                	jmp    800987 <strfind+0xf>
  800984:	83 c0 01             	add    $0x1,%eax
  800987:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098a:	38 ca                	cmp    %cl,%dl
  80098c:	74 04                	je     800992 <strfind+0x1a>
  80098e:	84 d2                	test   %dl,%dl
  800990:	75 f2                	jne    800984 <strfind+0xc>
			break;
	return (char *) s;
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a0:	85 c9                	test   %ecx,%ecx
  8009a2:	74 13                	je     8009b7 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009aa:	75 05                	jne    8009b1 <memset+0x1d>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	74 0d                	je     8009be <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b4:	fc                   	cld    
  8009b5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b7:	89 f8                	mov    %edi,%eax
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5f                   	pop    %edi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    
		c &= 0xFF;
  8009be:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c2:	89 d3                	mov    %edx,%ebx
  8009c4:	c1 e3 08             	shl    $0x8,%ebx
  8009c7:	89 d0                	mov    %edx,%eax
  8009c9:	c1 e0 18             	shl    $0x18,%eax
  8009cc:	89 d6                	mov    %edx,%esi
  8009ce:	c1 e6 10             	shl    $0x10,%esi
  8009d1:	09 f0                	or     %esi,%eax
  8009d3:	09 c2                	or     %eax,%edx
  8009d5:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009da:	89 d0                	mov    %edx,%eax
  8009dc:	fc                   	cld    
  8009dd:	f3 ab                	rep stos %eax,%es:(%edi)
  8009df:	eb d6                	jmp    8009b7 <memset+0x23>

008009e1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	57                   	push   %edi
  8009e5:	56                   	push   %esi
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ef:	39 c6                	cmp    %eax,%esi
  8009f1:	73 35                	jae    800a28 <memmove+0x47>
  8009f3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f6:	39 c2                	cmp    %eax,%edx
  8009f8:	76 2e                	jbe    800a28 <memmove+0x47>
		s += n;
		d += n;
  8009fa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fd:	89 d6                	mov    %edx,%esi
  8009ff:	09 fe                	or     %edi,%esi
  800a01:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a07:	74 0c                	je     800a15 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a09:	83 ef 01             	sub    $0x1,%edi
  800a0c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a0f:	fd                   	std    
  800a10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a12:	fc                   	cld    
  800a13:	eb 21                	jmp    800a36 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a15:	f6 c1 03             	test   $0x3,%cl
  800a18:	75 ef                	jne    800a09 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a1a:	83 ef 04             	sub    $0x4,%edi
  800a1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a20:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a23:	fd                   	std    
  800a24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a26:	eb ea                	jmp    800a12 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a28:	89 f2                	mov    %esi,%edx
  800a2a:	09 c2                	or     %eax,%edx
  800a2c:	f6 c2 03             	test   $0x3,%dl
  800a2f:	74 09                	je     800a3a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a31:	89 c7                	mov    %eax,%edi
  800a33:	fc                   	cld    
  800a34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3a:	f6 c1 03             	test   $0x3,%cl
  800a3d:	75 f2                	jne    800a31 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a42:	89 c7                	mov    %eax,%edi
  800a44:	fc                   	cld    
  800a45:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a47:	eb ed                	jmp    800a36 <memmove+0x55>

00800a49 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4c:	ff 75 10             	pushl  0x10(%ebp)
  800a4f:	ff 75 0c             	pushl  0xc(%ebp)
  800a52:	ff 75 08             	pushl  0x8(%ebp)
  800a55:	e8 87 ff ff ff       	call   8009e1 <memmove>
}
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a67:	89 c6                	mov    %eax,%esi
  800a69:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6c:	39 f0                	cmp    %esi,%eax
  800a6e:	74 1c                	je     800a8c <memcmp+0x30>
		if (*s1 != *s2)
  800a70:	0f b6 08             	movzbl (%eax),%ecx
  800a73:	0f b6 1a             	movzbl (%edx),%ebx
  800a76:	38 d9                	cmp    %bl,%cl
  800a78:	75 08                	jne    800a82 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	83 c2 01             	add    $0x1,%edx
  800a80:	eb ea                	jmp    800a6c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a82:	0f b6 c1             	movzbl %cl,%eax
  800a85:	0f b6 db             	movzbl %bl,%ebx
  800a88:	29 d8                	sub    %ebx,%eax
  800a8a:	eb 05                	jmp    800a91 <memcmp+0x35>
	}

	return 0;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a91:	5b                   	pop    %ebx
  800a92:	5e                   	pop    %esi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9e:	89 c2                	mov    %eax,%edx
  800aa0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa3:	39 d0                	cmp    %edx,%eax
  800aa5:	73 09                	jae    800ab0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa7:	38 08                	cmp    %cl,(%eax)
  800aa9:	74 05                	je     800ab0 <memfind+0x1b>
	for (; s < ends; s++)
  800aab:	83 c0 01             	add    $0x1,%eax
  800aae:	eb f3                	jmp    800aa3 <memfind+0xe>
			break;
	return (void *) s;
}
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abe:	eb 03                	jmp    800ac3 <strtol+0x11>
		s++;
  800ac0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac3:	0f b6 01             	movzbl (%ecx),%eax
  800ac6:	3c 20                	cmp    $0x20,%al
  800ac8:	74 f6                	je     800ac0 <strtol+0xe>
  800aca:	3c 09                	cmp    $0x9,%al
  800acc:	74 f2                	je     800ac0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ace:	3c 2b                	cmp    $0x2b,%al
  800ad0:	74 2e                	je     800b00 <strtol+0x4e>
	int neg = 0;
  800ad2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad7:	3c 2d                	cmp    $0x2d,%al
  800ad9:	74 2f                	je     800b0a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800adb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae1:	75 05                	jne    800ae8 <strtol+0x36>
  800ae3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae6:	74 2c                	je     800b14 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae8:	85 db                	test   %ebx,%ebx
  800aea:	75 0a                	jne    800af6 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aec:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800af1:	80 39 30             	cmpb   $0x30,(%ecx)
  800af4:	74 28                	je     800b1e <strtol+0x6c>
		base = 10;
  800af6:	b8 00 00 00 00       	mov    $0x0,%eax
  800afb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800afe:	eb 50                	jmp    800b50 <strtol+0x9e>
		s++;
  800b00:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b03:	bf 00 00 00 00       	mov    $0x0,%edi
  800b08:	eb d1                	jmp    800adb <strtol+0x29>
		s++, neg = 1;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b12:	eb c7                	jmp    800adb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b14:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b18:	74 0e                	je     800b28 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b1a:	85 db                	test   %ebx,%ebx
  800b1c:	75 d8                	jne    800af6 <strtol+0x44>
		s++, base = 8;
  800b1e:	83 c1 01             	add    $0x1,%ecx
  800b21:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b26:	eb ce                	jmp    800af6 <strtol+0x44>
		s += 2, base = 16;
  800b28:	83 c1 02             	add    $0x2,%ecx
  800b2b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b30:	eb c4                	jmp    800af6 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b32:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b35:	89 f3                	mov    %esi,%ebx
  800b37:	80 fb 19             	cmp    $0x19,%bl
  800b3a:	77 29                	ja     800b65 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b3c:	0f be d2             	movsbl %dl,%edx
  800b3f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b42:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b45:	7d 30                	jge    800b77 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b47:	83 c1 01             	add    $0x1,%ecx
  800b4a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b50:	0f b6 11             	movzbl (%ecx),%edx
  800b53:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b56:	89 f3                	mov    %esi,%ebx
  800b58:	80 fb 09             	cmp    $0x9,%bl
  800b5b:	77 d5                	ja     800b32 <strtol+0x80>
			dig = *s - '0';
  800b5d:	0f be d2             	movsbl %dl,%edx
  800b60:	83 ea 30             	sub    $0x30,%edx
  800b63:	eb dd                	jmp    800b42 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b65:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b68:	89 f3                	mov    %esi,%ebx
  800b6a:	80 fb 19             	cmp    $0x19,%bl
  800b6d:	77 08                	ja     800b77 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b6f:	0f be d2             	movsbl %dl,%edx
  800b72:	83 ea 37             	sub    $0x37,%edx
  800b75:	eb cb                	jmp    800b42 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7b:	74 05                	je     800b82 <strtol+0xd0>
		*endptr = (char *) s;
  800b7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b80:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b82:	89 c2                	mov    %eax,%edx
  800b84:	f7 da                	neg    %edx
  800b86:	85 ff                	test   %edi,%edi
  800b88:	0f 45 c2             	cmovne %edx,%eax
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	89 c3                	mov    %eax,%ebx
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	89 c6                	mov    %eax,%esi
  800ba7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_cgetc>:

int
sys_cgetc(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 1c             	sub    $0x1c,%esp
  800bd6:	e8 66 00 00 00       	call   800c41 <__x86.get_pc_thunk.ax>
  800bdb:	05 25 14 00 00       	add    $0x1425,%eax
  800be0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800be3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf0:	89 cb                	mov    %ecx,%ebx
  800bf2:	89 cf                	mov    %ecx,%edi
  800bf4:	89 ce                	mov    %ecx,%esi
  800bf6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7f 08                	jg     800c04 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 03                	push   $0x3
  800c0a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c0d:	8d 83 f4 f0 ff ff    	lea    -0xf0c(%ebx),%eax
  800c13:	50                   	push   %eax
  800c14:	6a 26                	push   $0x26
  800c16:	8d 83 11 f1 ff ff    	lea    -0xeef(%ebx),%eax
  800c1c:	50                   	push   %eax
  800c1d:	e8 23 00 00 00       	call   800c45 <_panic>

00800c22 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c28:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800c32:	89 d1                	mov    %edx,%ecx
  800c34:	89 d3                	mov    %edx,%ebx
  800c36:	89 d7                	mov    %edx,%edi
  800c38:	89 d6                	mov    %edx,%esi
  800c3a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <__x86.get_pc_thunk.ax>:
  800c41:	8b 04 24             	mov    (%esp),%eax
  800c44:	c3                   	ret    

00800c45 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	57                   	push   %edi
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	e8 0c f4 ff ff       	call   80005f <__x86.get_pc_thunk.bx>
  800c53:	81 c3 ad 13 00 00    	add    $0x13ad,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c59:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c5c:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c62:	8b 38                	mov    (%eax),%edi
  800c64:	e8 b9 ff ff ff       	call   800c22 <sys_getenvid>
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	ff 75 0c             	pushl  0xc(%ebp)
  800c6f:	ff 75 08             	pushl  0x8(%ebp)
  800c72:	57                   	push   %edi
  800c73:	50                   	push   %eax
  800c74:	8d 83 20 f1 ff ff    	lea    -0xee0(%ebx),%eax
  800c7a:	50                   	push   %eax
  800c7b:	e8 13 f5 ff ff       	call   800193 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c80:	83 c4 18             	add    $0x18,%esp
  800c83:	56                   	push   %esi
  800c84:	ff 75 10             	pushl  0x10(%ebp)
  800c87:	e8 a5 f4 ff ff       	call   800131 <vcprintf>
	cprintf("\n");
  800c8c:	8d 83 44 f1 ff ff    	lea    -0xebc(%ebx),%eax
  800c92:	89 04 24             	mov    %eax,(%esp)
  800c95:	e8 f9 f4 ff ff       	call   800193 <cprintf>
  800c9a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c9d:	cc                   	int3   
  800c9e:	eb fd                	jmp    800c9d <_panic+0x58>

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
