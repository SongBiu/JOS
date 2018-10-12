
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
  80003a:	e8 35 00 00 00       	call   800074 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	cprintf("hello, world\n");
  800045:	8d 83 dc ee ff ff    	lea    -0x1124(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 40 01 00 00       	call   800191 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800051:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  800057:	8b 00                	mov    (%eax),%eax
  800059:	8b 40 48             	mov    0x48(%eax),%eax
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	8d 83 ea ee ff ff    	lea    -0x1116(%ebx),%eax
  800066:	50                   	push   %eax
  800067:	e8 25 01 00 00       	call   800191 <cprintf>
}
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <__x86.get_pc_thunk.bx>:
  800074:	8b 1c 24             	mov    (%esp),%ebx
  800077:	c3                   	ret    

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	53                   	push   %ebx
  80007c:	83 ec 04             	sub    $0x4,%esp
  80007f:	e8 f0 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800084:	81 c3 7c 1f 00 00    	add    $0x1f7c,%ebx
  80008a:	8b 45 08             	mov    0x8(%ebp),%eax
  80008d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800090:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800096:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009c:	85 c0                	test   %eax,%eax
  80009e:	7e 08                	jle    8000a8 <libmain+0x30>
		binaryname = argv[0];
  8000a0:	8b 0a                	mov    (%edx),%ecx
  8000a2:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	52                   	push   %edx
  8000ac:	50                   	push   %eax
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 08 00 00 00       	call   8000bf <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bd:	c9                   	leave  
  8000be:	c3                   	ret    

008000bf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 10             	sub    $0x10,%esp
  8000c6:	e8 a9 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000cb:	81 c3 35 1f 00 00    	add    $0x1f35,%ebx
	sys_env_destroy(0);
  8000d1:	6a 00                	push   $0x0
  8000d3:	e8 f3 0a 00 00       	call   800bcb <sys_env_destroy>
}
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	e8 8a ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000ea:	81 c3 16 1f 00 00    	add    $0x1f16,%ebx
  8000f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8000f3:	8b 16                	mov    (%esi),%edx
  8000f5:	8d 42 01             	lea    0x1(%edx),%eax
  8000f8:	89 06                	mov    %eax,(%esi)
  8000fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000fd:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800101:	3d ff 00 00 00       	cmp    $0xff,%eax
  800106:	74 0b                	je     800113 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800108:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80010c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800113:	83 ec 08             	sub    $0x8,%esp
  800116:	68 ff 00 00 00       	push   $0xff
  80011b:	8d 46 08             	lea    0x8(%esi),%eax
  80011e:	50                   	push   %eax
  80011f:	e8 6a 0a 00 00       	call   800b8e <sys_cputs>
		b->idx = 0;
  800124:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	eb d9                	jmp    800108 <putch+0x28>

0080012f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	53                   	push   %ebx
  800133:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800139:	e8 36 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  80013e:	81 c3 c2 1e 00 00    	add    $0x1ec2,%ebx
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	50                   	push   %eax
  800165:	8d 83 e0 e0 ff ff    	lea    -0x1f20(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 38 01 00 00       	call   8002a9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	83 c4 08             	add    $0x8,%esp
  800174:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	e8 08 0a 00 00       	call   800b8e <sys_cputs>

	return b.cnt;
}
  800186:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019a:	50                   	push   %eax
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	e8 8c ff ff ff       	call   80012f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 2c             	sub    $0x2c,%esp
  8001ae:	e8 63 06 00 00       	call   800816 <__x86.get_pc_thunk.cx>
  8001b3:	81 c1 4d 1e 00 00    	add    $0x1e4d,%ecx
  8001b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001bc:	89 c7                	mov    %eax,%edi
  8001be:	89 d6                	mov    %edx,%esi
  8001c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001c9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001d7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001da:	39 d3                	cmp    %edx,%ebx
  8001dc:	72 09                	jb     8001e7 <printnum+0x42>
  8001de:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e1:	0f 87 83 00 00 00    	ja     80026a <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f3:	53                   	push   %ebx
  8001f4:	ff 75 10             	pushl  0x10(%ebp)
  8001f7:	83 ec 08             	sub    $0x8,%esp
  8001fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800200:	ff 75 d4             	pushl  -0x2c(%ebp)
  800203:	ff 75 d0             	pushl  -0x30(%ebp)
  800206:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800209:	e8 92 0a 00 00       	call   800ca0 <__udivdi3>
  80020e:	83 c4 18             	add    $0x18,%esp
  800211:	52                   	push   %edx
  800212:	50                   	push   %eax
  800213:	89 f2                	mov    %esi,%edx
  800215:	89 f8                	mov    %edi,%eax
  800217:	e8 89 ff ff ff       	call   8001a5 <printnum>
  80021c:	83 c4 20             	add    $0x20,%esp
  80021f:	eb 13                	jmp    800234 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800221:	83 ec 08             	sub    $0x8,%esp
  800224:	56                   	push   %esi
  800225:	ff 75 18             	pushl  0x18(%ebp)
  800228:	ff d7                	call   *%edi
  80022a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022d:	83 eb 01             	sub    $0x1,%ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f ed                	jg     800221 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	83 ec 08             	sub    $0x8,%esp
  800237:	56                   	push   %esi
  800238:	83 ec 04             	sub    $0x4,%esp
  80023b:	ff 75 dc             	pushl  -0x24(%ebp)
  80023e:	ff 75 d8             	pushl  -0x28(%ebp)
  800241:	ff 75 d4             	pushl  -0x2c(%ebp)
  800244:	ff 75 d0             	pushl  -0x30(%ebp)
  800247:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80024a:	89 f3                	mov    %esi,%ebx
  80024c:	e8 6f 0b 00 00       	call   800dc0 <__umoddi3>
  800251:	83 c4 14             	add    $0x14,%esp
  800254:	0f be 84 06 0b ef ff 	movsbl -0x10f5(%esi,%eax,1),%eax
  80025b:	ff 
  80025c:	50                   	push   %eax
  80025d:	ff d7                	call   *%edi
}
  80025f:	83 c4 10             	add    $0x10,%esp
  800262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    
  80026a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026d:	eb be                	jmp    80022d <printnum+0x88>

0080026f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800275:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	3b 50 04             	cmp    0x4(%eax),%edx
  80027e:	73 0a                	jae    80028a <sprintputch+0x1b>
		*b->buf++ = ch;
  800280:	8d 4a 01             	lea    0x1(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 45 08             	mov    0x8(%ebp),%eax
  800288:	88 02                	mov    %al,(%edx)
}
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <printfmt>:
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800292:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 10             	pushl  0x10(%ebp)
  800299:	ff 75 0c             	pushl  0xc(%ebp)
  80029c:	ff 75 08             	pushl  0x8(%ebp)
  80029f:	e8 05 00 00 00       	call   8002a9 <vprintfmt>
}
  8002a4:	83 c4 10             	add    $0x10,%esp
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <vprintfmt>:
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 2c             	sub    $0x2c,%esp
  8002b2:	e8 bd fd ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8002b7:	81 c3 49 1d 00 00    	add    $0x1d49,%ebx
  8002bd:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8002c0:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8002c7:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c9:	8d 77 01             	lea    0x1(%edi),%esi
  8002cc:	0f b6 07             	movzbl (%edi),%eax
  8002cf:	83 f8 25             	cmp    $0x25,%eax
  8002d2:	74 1c                	je     8002f0 <vprintfmt+0x47>
			if (ch == '\0')
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	0f 84 b9 04 00 00    	je     800795 <.L21+0x20>
			putch(ch, putdat);
  8002dc:	83 ec 08             	sub    $0x8,%esp
  8002df:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8002e2:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8002e5:	50                   	push   %eax
  8002e6:	ff 55 08             	call   *0x8(%ebp)
  8002e9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ec:	89 f7                	mov    %esi,%edi
  8002ee:	eb d9                	jmp    8002c9 <vprintfmt+0x20>
		padc = ' ';
  8002f0:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8002f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002fb:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800302:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800309:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800311:	8d 7e 01             	lea    0x1(%esi),%edi
  800314:	0f b6 16             	movzbl (%esi),%edx
  800317:	8d 42 dd             	lea    -0x23(%edx),%eax
  80031a:	3c 55                	cmp    $0x55,%al
  80031c:	0f 87 53 04 00 00    	ja     800775 <.L21>
  800322:	0f b6 c0             	movzbl %al,%eax
  800325:	89 d9                	mov    %ebx,%ecx
  800327:	03 8c 83 98 ef ff ff 	add    -0x1068(%ebx,%eax,4),%ecx
  80032e:	ff e1                	jmp    *%ecx

00800330 <.L73>:
  800330:	89 fe                	mov    %edi,%esi
			padc = '-';
  800332:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800336:	eb d9                	jmp    800311 <vprintfmt+0x68>

00800338 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	89 fe                	mov    %edi,%esi
			padc = '0';
  80033a:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80033e:	eb d1                	jmp    800311 <vprintfmt+0x68>

00800340 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	0f b6 d2             	movzbl %dl,%edx
  800343:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800345:	b8 00 00 00 00       	mov    $0x0,%eax
  80034a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  80034d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800350:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800354:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800357:	8d 7a d0             	lea    -0x30(%edx),%edi
  80035a:	83 ff 09             	cmp    $0x9,%edi
  80035d:	0f 87 94 00 00 00    	ja     8003f7 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800363:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800366:	eb e5                	jmp    80034d <.L28+0xd>

00800368 <.L25>:
			precision = va_arg(ap, int);
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8b 00                	mov    (%eax),%eax
  80036d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 40 04             	lea    0x4(%eax),%eax
  800376:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800379:	89 fe                	mov    %edi,%esi
			if (width < 0)
  80037b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037f:	79 90                	jns    800311 <vprintfmt+0x68>
				width = precision, precision = -1;
  800381:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800384:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800387:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80038e:	eb 81                	jmp    800311 <vprintfmt+0x68>

00800390 <.L26>:
  800390:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800393:	85 c0                	test   %eax,%eax
  800395:	ba 00 00 00 00       	mov    $0x0,%edx
  80039a:	0f 49 d0             	cmovns %eax,%edx
  80039d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	89 fe                	mov    %edi,%esi
  8003a2:	e9 6a ff ff ff       	jmp    800311 <vprintfmt+0x68>

008003a7 <.L22>:
  8003a7:	89 fe                	mov    %edi,%esi
			altflag = 1;
  8003a9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b0:	e9 5c ff ff ff       	jmp    800311 <vprintfmt+0x68>

008003b5 <.L33>:
  8003b5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8003b8:	83 f9 01             	cmp    $0x1,%ecx
  8003bb:	7e 16                	jle    8003d3 <.L33+0x1e>
		return va_arg(*ap, long long);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003c5:	8d 49 08             	lea    0x8(%ecx),%ecx
  8003c8:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8003cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8003ce:	e9 f6 fe ff ff       	jmp    8002c9 <vprintfmt+0x20>
	else if (lflag)
  8003d3:	85 c9                	test   %ecx,%ecx
  8003d5:	75 10                	jne    8003e7 <.L33+0x32>
		return va_arg(*ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8b 00                	mov    (%eax),%eax
  8003dc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003df:	8d 49 04             	lea    0x4(%ecx),%ecx
  8003e2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e5:	eb e4                	jmp    8003cb <.L33+0x16>
		return va_arg(*ap, long);
  8003e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003ef:	8d 49 04             	lea    0x4(%ecx),%ecx
  8003f2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f5:	eb d4                	jmp    8003cb <.L33+0x16>
  8003f7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003fd:	e9 79 ff ff ff       	jmp    80037b <.L25+0x13>

00800402 <.L32>:
			lflag++;
  800402:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800406:	89 fe                	mov    %edi,%esi
			goto reswitch;
  800408:	e9 04 ff ff ff       	jmp    800311 <vprintfmt+0x68>

0080040d <.L29>:
			putch(va_arg(ap, int), putdat);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 70 04             	lea    0x4(%eax),%esi
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	ff 75 0c             	pushl  0xc(%ebp)
  800419:	ff 30                	pushl  (%eax)
  80041b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80041e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800421:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800424:	e9 a0 fe ff ff       	jmp    8002c9 <vprintfmt+0x20>

00800429 <.L31>:
			err = va_arg(ap, int);
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8d 70 04             	lea    0x4(%eax),%esi
  80042f:	8b 00                	mov    (%eax),%eax
  800431:	99                   	cltd   
  800432:	31 d0                	xor    %edx,%eax
  800434:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800436:	83 f8 06             	cmp    $0x6,%eax
  800439:	7f 29                	jg     800464 <.L31+0x3b>
  80043b:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800442:	85 d2                	test   %edx,%edx
  800444:	74 1e                	je     800464 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800446:	52                   	push   %edx
  800447:	8d 83 2c ef ff ff    	lea    -0x10d4(%ebx),%eax
  80044d:	50                   	push   %eax
  80044e:	ff 75 0c             	pushl  0xc(%ebp)
  800451:	ff 75 08             	pushl  0x8(%ebp)
  800454:	e8 33 fe ff ff       	call   80028c <printfmt>
  800459:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045c:	89 75 14             	mov    %esi,0x14(%ebp)
  80045f:	e9 65 fe ff ff       	jmp    8002c9 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800464:	50                   	push   %eax
  800465:	8d 83 23 ef ff ff    	lea    -0x10dd(%ebx),%eax
  80046b:	50                   	push   %eax
  80046c:	ff 75 0c             	pushl  0xc(%ebp)
  80046f:	ff 75 08             	pushl  0x8(%ebp)
  800472:	e8 15 fe ff ff       	call   80028c <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047a:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80047d:	e9 47 fe ff ff       	jmp    8002c9 <vprintfmt+0x20>

00800482 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	83 c0 04             	add    $0x4,%eax
  800488:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80048b:	8b 45 14             	mov    0x14(%ebp),%eax
  80048e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800490:	85 f6                	test   %esi,%esi
  800492:	8d 83 1c ef ff ff    	lea    -0x10e4(%ebx),%eax
  800498:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80049b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049f:	0f 8e b4 00 00 00    	jle    800559 <.L36+0xd7>
  8004a5:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8004a9:	75 08                	jne    8004b3 <.L36+0x31>
  8004ab:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004ae:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004b1:	eb 6c                	jmp    80051f <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b9:	56                   	push   %esi
  8004ba:	e8 73 03 00 00       	call   800832 <strnlen>
  8004bf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c2:	29 c2                	sub    %eax,%edx
  8004c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ca:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004ce:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004d1:	89 d6                	mov    %edx,%esi
  8004d3:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004d6:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d8:	eb 10                	jmp    8004ea <.L36+0x68>
					putch(padc, putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	ff 75 0c             	pushl  0xc(%ebp)
  8004e0:	57                   	push   %edi
  8004e1:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e4:	83 ee 01             	sub    $0x1,%esi
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	85 f6                	test   %esi,%esi
  8004ec:	7f ec                	jg     8004da <.L36+0x58>
  8004ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004f4:	85 d2                	test   %edx,%edx
  8004f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fb:	0f 49 c2             	cmovns %edx,%eax
  8004fe:	29 c2                	sub    %eax,%edx
  800500:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800503:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800506:	eb 17                	jmp    80051f <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  800508:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80050c:	75 30                	jne    80053e <.L36+0xbc>
					putch(ch, putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	50                   	push   %eax
  800515:	ff 55 08             	call   *0x8(%ebp)
  800518:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051b:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80051f:	83 c6 01             	add    $0x1,%esi
  800522:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800526:	0f be c2             	movsbl %dl,%eax
  800529:	85 c0                	test   %eax,%eax
  80052b:	74 58                	je     800585 <.L36+0x103>
  80052d:	85 ff                	test   %edi,%edi
  80052f:	78 d7                	js     800508 <.L36+0x86>
  800531:	83 ef 01             	sub    $0x1,%edi
  800534:	79 d2                	jns    800508 <.L36+0x86>
  800536:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800539:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80053c:	eb 32                	jmp    800570 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  80053e:	0f be d2             	movsbl %dl,%edx
  800541:	83 ea 20             	sub    $0x20,%edx
  800544:	83 fa 5e             	cmp    $0x5e,%edx
  800547:	76 c5                	jbe    80050e <.L36+0x8c>
					putch('?', putdat);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	ff 75 0c             	pushl  0xc(%ebp)
  80054f:	6a 3f                	push   $0x3f
  800551:	ff 55 08             	call   *0x8(%ebp)
  800554:	83 c4 10             	add    $0x10,%esp
  800557:	eb c2                	jmp    80051b <.L36+0x99>
  800559:	89 7d 10             	mov    %edi,0x10(%ebp)
  80055c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80055f:	eb be                	jmp    80051f <.L36+0x9d>
				putch(' ', putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	57                   	push   %edi
  800565:	6a 20                	push   $0x20
  800567:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80056a:	83 ee 01             	sub    $0x1,%esi
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	85 f6                	test   %esi,%esi
  800572:	7f ed                	jg     800561 <.L36+0xdf>
  800574:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800577:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  80057a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
  800580:	e9 44 fd ff ff       	jmp    8002c9 <vprintfmt+0x20>
  800585:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800588:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80058b:	eb e3                	jmp    800570 <.L36+0xee>

0080058d <.L30>:
  80058d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800590:	83 f9 01             	cmp    $0x1,%ecx
  800593:	7e 42                	jle    8005d7 <.L30+0x4a>
		return va_arg(*ap, long long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 50 04             	mov    0x4(%eax),%edx
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 40 08             	lea    0x8(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005ac:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b0:	79 5f                	jns    800611 <.L30+0x84>
				putch('-', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	ff 75 0c             	pushl  0xc(%ebp)
  8005b8:	6a 2d                	push   $0x2d
  8005ba:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c3:	f7 da                	neg    %edx
  8005c5:	83 d1 00             	adc    $0x0,%ecx
  8005c8:	f7 d9                	neg    %ecx
  8005ca:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	e9 b8 00 00 00       	jmp    80068f <.L34+0x22>
	else if (lflag)
  8005d7:	85 c9                	test   %ecx,%ecx
  8005d9:	75 1b                	jne    8005f6 <.L30+0x69>
		return va_arg(*ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 30                	mov    (%eax),%esi
  8005e0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005e3:	89 f0                	mov    %esi,%eax
  8005e5:	c1 f8 1f             	sar    $0x1f,%eax
  8005e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f4:	eb b6                	jmp    8005ac <.L30+0x1f>
		return va_arg(*ap, long);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8b 30                	mov    (%eax),%esi
  8005fb:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005fe:	89 f0                	mov    %esi,%eax
  800600:	c1 f8 1f             	sar    $0x1f,%eax
  800603:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 40 04             	lea    0x4(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
  80060f:	eb 9b                	jmp    8005ac <.L30+0x1f>
			num = getint(&ap, lflag);
  800611:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800614:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800617:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061c:	eb 71                	jmp    80068f <.L34+0x22>

0080061e <.L37>:
  80061e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800621:	83 f9 01             	cmp    $0x1,%ecx
  800624:	7e 15                	jle    80063b <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8b 10                	mov    (%eax),%edx
  80062b:	8b 48 04             	mov    0x4(%eax),%ecx
  80062e:	8d 40 08             	lea    0x8(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800634:	b8 0a 00 00 00       	mov    $0xa,%eax
  800639:	eb 54                	jmp    80068f <.L34+0x22>
	else if (lflag)
  80063b:	85 c9                	test   %ecx,%ecx
  80063d:	75 17                	jne    800656 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 10                	mov    (%eax),%edx
  800644:	b9 00 00 00 00       	mov    $0x0,%ecx
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800654:	eb 39                	jmp    80068f <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800660:	8d 40 04             	lea    0x4(%eax),%eax
  800663:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	eb 22                	jmp    80068f <.L34+0x22>

0080066d <.L34>:
  80066d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800670:	83 f9 01             	cmp    $0x1,%ecx
  800673:	7e 3b                	jle    8006b0 <.L34+0x43>
		return va_arg(*ap, long long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 50 04             	mov    0x4(%eax),%edx
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800680:	8d 49 08             	lea    0x8(%ecx),%ecx
  800683:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800686:	89 d1                	mov    %edx,%ecx
  800688:	89 c2                	mov    %eax,%edx
			base = 8;
  80068a:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800696:	56                   	push   %esi
  800697:	ff 75 e0             	pushl  -0x20(%ebp)
  80069a:	50                   	push   %eax
  80069b:	51                   	push   %ecx
  80069c:	52                   	push   %edx
  80069d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	e8 fd fa ff ff       	call   8001a5 <printnum>
			break;
  8006a8:	83 c4 20             	add    $0x20,%esp
  8006ab:	e9 19 fc ff ff       	jmp    8002c9 <vprintfmt+0x20>
	else if (lflag)
  8006b0:	85 c9                	test   %ecx,%ecx
  8006b2:	75 13                	jne    8006c7 <.L34+0x5a>
		return va_arg(*ap, int);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	89 d0                	mov    %edx,%eax
  8006bb:	99                   	cltd   
  8006bc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006bf:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006c2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006c5:	eb bf                	jmp    800686 <.L34+0x19>
		return va_arg(*ap, long);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	89 d0                	mov    %edx,%eax
  8006ce:	99                   	cltd   
  8006cf:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006d2:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006d8:	eb ac                	jmp    800686 <.L34+0x19>

008006da <.L35>:
			putch('0', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	ff 75 0c             	pushl  0xc(%ebp)
  8006e0:	6a 30                	push   $0x30
  8006e2:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006e5:	83 c4 08             	add    $0x8,%esp
  8006e8:	ff 75 0c             	pushl  0xc(%ebp)
  8006eb:	6a 78                	push   $0x78
  8006ed:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 10                	mov    (%eax),%edx
  8006f5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006fa:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006fd:	8d 40 04             	lea    0x4(%eax),%eax
  800700:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800703:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800708:	eb 85                	jmp    80068f <.L34+0x22>

0080070a <.L38>:
  80070a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80070d:	83 f9 01             	cmp    $0x1,%ecx
  800710:	7e 18                	jle    80072a <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8b 10                	mov    (%eax),%edx
  800717:	8b 48 04             	mov    0x4(%eax),%ecx
  80071a:	8d 40 08             	lea    0x8(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800720:	b8 10 00 00 00       	mov    $0x10,%eax
  800725:	e9 65 ff ff ff       	jmp    80068f <.L34+0x22>
	else if (lflag)
  80072a:	85 c9                	test   %ecx,%ecx
  80072c:	75 1a                	jne    800748 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8b 10                	mov    (%eax),%edx
  800733:	b9 00 00 00 00       	mov    $0x0,%ecx
  800738:	8d 40 04             	lea    0x4(%eax),%eax
  80073b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073e:	b8 10 00 00 00       	mov    $0x10,%eax
  800743:	e9 47 ff ff ff       	jmp    80068f <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800752:	8d 40 04             	lea    0x4(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800758:	b8 10 00 00 00       	mov    $0x10,%eax
  80075d:	e9 2d ff ff ff       	jmp    80068f <.L34+0x22>

00800762 <.L24>:
			putch(ch, putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	6a 25                	push   $0x25
  80076a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	e9 54 fb ff ff       	jmp    8002c9 <vprintfmt+0x20>

00800775 <.L21>:
			putch('%', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	ff 75 0c             	pushl  0xc(%ebp)
  80077b:	6a 25                	push   $0x25
  80077d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	89 f7                	mov    %esi,%edi
  800785:	eb 03                	jmp    80078a <.L21+0x15>
  800787:	83 ef 01             	sub    $0x1,%edi
  80078a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80078e:	75 f7                	jne    800787 <.L21+0x12>
  800790:	e9 34 fb ff ff       	jmp    8002c9 <vprintfmt+0x20>
}
  800795:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800798:	5b                   	pop    %ebx
  800799:	5e                   	pop    %esi
  80079a:	5f                   	pop    %edi
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	53                   	push   %ebx
  8007a1:	83 ec 14             	sub    $0x14,%esp
  8007a4:	e8 cb f8 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8007a9:	81 c3 57 18 00 00    	add    $0x1857,%ebx
  8007af:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	74 2b                	je     8007f5 <vsnprintf+0x58>
  8007ca:	85 d2                	test   %edx,%edx
  8007cc:	7e 27                	jle    8007f5 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ce:	ff 75 14             	pushl  0x14(%ebp)
  8007d1:	ff 75 10             	pushl  0x10(%ebp)
  8007d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d7:	50                   	push   %eax
  8007d8:	8d 83 6f e2 ff ff    	lea    -0x1d91(%ebx),%eax
  8007de:	50                   	push   %eax
  8007df:	e8 c5 fa ff ff       	call   8002a9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ed:	83 c4 10             	add    $0x10,%esp
}
  8007f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f3:	c9                   	leave  
  8007f4:	c3                   	ret    
		return -E_INVAL;
  8007f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fa:	eb f4                	jmp    8007f0 <vsnprintf+0x53>

008007fc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800802:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800805:	50                   	push   %eax
  800806:	ff 75 10             	pushl  0x10(%ebp)
  800809:	ff 75 0c             	pushl  0xc(%ebp)
  80080c:	ff 75 08             	pushl  0x8(%ebp)
  80080f:	e8 89 ff ff ff       	call   80079d <vsnprintf>
	va_end(ap);

	return rc;
}
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <__x86.get_pc_thunk.cx>:
  800816:	8b 0c 24             	mov    (%esp),%ecx
  800819:	c3                   	ret    

0080081a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
  800825:	eb 03                	jmp    80082a <strlen+0x10>
		n++;
  800827:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80082a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80082e:	75 f7                	jne    800827 <strlen+0xd>
	return n;
}
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
  800840:	eb 03                	jmp    800845 <strnlen+0x13>
		n++;
  800842:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800845:	39 d0                	cmp    %edx,%eax
  800847:	74 06                	je     80084f <strnlen+0x1d>
  800849:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80084d:	75 f3                	jne    800842 <strnlen+0x10>
	return n;
}
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085b:	89 c2                	mov    %eax,%edx
  80085d:	83 c1 01             	add    $0x1,%ecx
  800860:	83 c2 01             	add    $0x1,%edx
  800863:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800867:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086a:	84 db                	test   %bl,%bl
  80086c:	75 ef                	jne    80085d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80086e:	5b                   	pop    %ebx
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	53                   	push   %ebx
  800875:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800878:	53                   	push   %ebx
  800879:	e8 9c ff ff ff       	call   80081a <strlen>
  80087e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800881:	ff 75 0c             	pushl  0xc(%ebp)
  800884:	01 d8                	add    %ebx,%eax
  800886:	50                   	push   %eax
  800887:	e8 c5 ff ff ff       	call   800851 <strcpy>
	return dst;
}
  80088c:	89 d8                	mov    %ebx,%eax
  80088e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	8b 75 08             	mov    0x8(%ebp),%esi
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80089e:	89 f3                	mov    %esi,%ebx
  8008a0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a3:	89 f2                	mov    %esi,%edx
  8008a5:	eb 0f                	jmp    8008b6 <strncpy+0x23>
		*dst++ = *src;
  8008a7:	83 c2 01             	add    $0x1,%edx
  8008aa:	0f b6 01             	movzbl (%ecx),%eax
  8008ad:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b0:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b3:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008b6:	39 da                	cmp    %ebx,%edx
  8008b8:	75 ed                	jne    8008a7 <strncpy+0x14>
	}
	return ret;
}
  8008ba:	89 f0                	mov    %esi,%eax
  8008bc:	5b                   	pop    %ebx
  8008bd:	5e                   	pop    %esi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	56                   	push   %esi
  8008c4:	53                   	push   %ebx
  8008c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ce:	89 f0                	mov    %esi,%eax
  8008d0:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d4:	85 c9                	test   %ecx,%ecx
  8008d6:	75 0b                	jne    8008e3 <strlcpy+0x23>
  8008d8:	eb 17                	jmp    8008f1 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008da:	83 c2 01             	add    $0x1,%edx
  8008dd:	83 c0 01             	add    $0x1,%eax
  8008e0:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008e3:	39 d8                	cmp    %ebx,%eax
  8008e5:	74 07                	je     8008ee <strlcpy+0x2e>
  8008e7:	0f b6 0a             	movzbl (%edx),%ecx
  8008ea:	84 c9                	test   %cl,%cl
  8008ec:	75 ec                	jne    8008da <strlcpy+0x1a>
		*dst = '\0';
  8008ee:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f1:	29 f0                	sub    %esi,%eax
}
  8008f3:	5b                   	pop    %ebx
  8008f4:	5e                   	pop    %esi
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800900:	eb 06                	jmp    800908 <strcmp+0x11>
		p++, q++;
  800902:	83 c1 01             	add    $0x1,%ecx
  800905:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800908:	0f b6 01             	movzbl (%ecx),%eax
  80090b:	84 c0                	test   %al,%al
  80090d:	74 04                	je     800913 <strcmp+0x1c>
  80090f:	3a 02                	cmp    (%edx),%al
  800911:	74 ef                	je     800902 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800913:	0f b6 c0             	movzbl %al,%eax
  800916:	0f b6 12             	movzbl (%edx),%edx
  800919:	29 d0                	sub    %edx,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	53                   	push   %ebx
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
  800927:	89 c3                	mov    %eax,%ebx
  800929:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80092c:	eb 06                	jmp    800934 <strncmp+0x17>
		n--, p++, q++;
  80092e:	83 c0 01             	add    $0x1,%eax
  800931:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800934:	39 d8                	cmp    %ebx,%eax
  800936:	74 16                	je     80094e <strncmp+0x31>
  800938:	0f b6 08             	movzbl (%eax),%ecx
  80093b:	84 c9                	test   %cl,%cl
  80093d:	74 04                	je     800943 <strncmp+0x26>
  80093f:	3a 0a                	cmp    (%edx),%cl
  800941:	74 eb                	je     80092e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800943:	0f b6 00             	movzbl (%eax),%eax
  800946:	0f b6 12             	movzbl (%edx),%edx
  800949:	29 d0                	sub    %edx,%eax
}
  80094b:	5b                   	pop    %ebx
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    
		return 0;
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
  800953:	eb f6                	jmp    80094b <strncmp+0x2e>

00800955 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095f:	0f b6 10             	movzbl (%eax),%edx
  800962:	84 d2                	test   %dl,%dl
  800964:	74 09                	je     80096f <strchr+0x1a>
		if (*s == c)
  800966:	38 ca                	cmp    %cl,%dl
  800968:	74 0a                	je     800974 <strchr+0x1f>
	for (; *s; s++)
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	eb f0                	jmp    80095f <strchr+0xa>
			return (char *) s;
	return 0;
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800980:	eb 03                	jmp    800985 <strfind+0xf>
  800982:	83 c0 01             	add    $0x1,%eax
  800985:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800988:	38 ca                	cmp    %cl,%dl
  80098a:	74 04                	je     800990 <strfind+0x1a>
  80098c:	84 d2                	test   %dl,%dl
  80098e:	75 f2                	jne    800982 <strfind+0xc>
			break;
	return (char *) s;
}
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80099e:	85 c9                	test   %ecx,%ecx
  8009a0:	74 13                	je     8009b5 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a8:	75 05                	jne    8009af <memset+0x1d>
  8009aa:	f6 c1 03             	test   $0x3,%cl
  8009ad:	74 0d                	je     8009bc <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b2:	fc                   	cld    
  8009b3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b5:	89 f8                	mov    %edi,%eax
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    
		c &= 0xFF;
  8009bc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c0:	89 d3                	mov    %edx,%ebx
  8009c2:	c1 e3 08             	shl    $0x8,%ebx
  8009c5:	89 d0                	mov    %edx,%eax
  8009c7:	c1 e0 18             	shl    $0x18,%eax
  8009ca:	89 d6                	mov    %edx,%esi
  8009cc:	c1 e6 10             	shl    $0x10,%esi
  8009cf:	09 f0                	or     %esi,%eax
  8009d1:	09 c2                	or     %eax,%edx
  8009d3:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009d5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d8:	89 d0                	mov    %edx,%eax
  8009da:	fc                   	cld    
  8009db:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dd:	eb d6                	jmp    8009b5 <memset+0x23>

008009df <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ed:	39 c6                	cmp    %eax,%esi
  8009ef:	73 35                	jae    800a26 <memmove+0x47>
  8009f1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f4:	39 c2                	cmp    %eax,%edx
  8009f6:	76 2e                	jbe    800a26 <memmove+0x47>
		s += n;
		d += n;
  8009f8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fb:	89 d6                	mov    %edx,%esi
  8009fd:	09 fe                	or     %edi,%esi
  8009ff:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a05:	74 0c                	je     800a13 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a07:	83 ef 01             	sub    $0x1,%edi
  800a0a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a0d:	fd                   	std    
  800a0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a10:	fc                   	cld    
  800a11:	eb 21                	jmp    800a34 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a13:	f6 c1 03             	test   $0x3,%cl
  800a16:	75 ef                	jne    800a07 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a18:	83 ef 04             	sub    $0x4,%edi
  800a1b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a21:	fd                   	std    
  800a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a24:	eb ea                	jmp    800a10 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a26:	89 f2                	mov    %esi,%edx
  800a28:	09 c2                	or     %eax,%edx
  800a2a:	f6 c2 03             	test   $0x3,%dl
  800a2d:	74 09                	je     800a38 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a2f:	89 c7                	mov    %eax,%edi
  800a31:	fc                   	cld    
  800a32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a34:	5e                   	pop    %esi
  800a35:	5f                   	pop    %edi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a38:	f6 c1 03             	test   $0x3,%cl
  800a3b:	75 f2                	jne    800a2f <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a40:	89 c7                	mov    %eax,%edi
  800a42:	fc                   	cld    
  800a43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a45:	eb ed                	jmp    800a34 <memmove+0x55>

00800a47 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a4a:	ff 75 10             	pushl  0x10(%ebp)
  800a4d:	ff 75 0c             	pushl  0xc(%ebp)
  800a50:	ff 75 08             	pushl  0x8(%ebp)
  800a53:	e8 87 ff ff ff       	call   8009df <memmove>
}
  800a58:	c9                   	leave  
  800a59:	c3                   	ret    

00800a5a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 c6                	mov    %eax,%esi
  800a67:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6a:	39 f0                	cmp    %esi,%eax
  800a6c:	74 1c                	je     800a8a <memcmp+0x30>
		if (*s1 != *s2)
  800a6e:	0f b6 08             	movzbl (%eax),%ecx
  800a71:	0f b6 1a             	movzbl (%edx),%ebx
  800a74:	38 d9                	cmp    %bl,%cl
  800a76:	75 08                	jne    800a80 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a78:	83 c0 01             	add    $0x1,%eax
  800a7b:	83 c2 01             	add    $0x1,%edx
  800a7e:	eb ea                	jmp    800a6a <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a80:	0f b6 c1             	movzbl %cl,%eax
  800a83:	0f b6 db             	movzbl %bl,%ebx
  800a86:	29 d8                	sub    %ebx,%eax
  800a88:	eb 05                	jmp    800a8f <memcmp+0x35>
	}

	return 0;
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8f:	5b                   	pop    %ebx
  800a90:	5e                   	pop    %esi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a9c:	89 c2                	mov    %eax,%edx
  800a9e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa1:	39 d0                	cmp    %edx,%eax
  800aa3:	73 09                	jae    800aae <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa5:	38 08                	cmp    %cl,(%eax)
  800aa7:	74 05                	je     800aae <memfind+0x1b>
	for (; s < ends; s++)
  800aa9:	83 c0 01             	add    $0x1,%eax
  800aac:	eb f3                	jmp    800aa1 <memfind+0xe>
			break;
	return (void *) s;
}
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800abc:	eb 03                	jmp    800ac1 <strtol+0x11>
		s++;
  800abe:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ac1:	0f b6 01             	movzbl (%ecx),%eax
  800ac4:	3c 20                	cmp    $0x20,%al
  800ac6:	74 f6                	je     800abe <strtol+0xe>
  800ac8:	3c 09                	cmp    $0x9,%al
  800aca:	74 f2                	je     800abe <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800acc:	3c 2b                	cmp    $0x2b,%al
  800ace:	74 2e                	je     800afe <strtol+0x4e>
	int neg = 0;
  800ad0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad5:	3c 2d                	cmp    $0x2d,%al
  800ad7:	74 2f                	je     800b08 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800adf:	75 05                	jne    800ae6 <strtol+0x36>
  800ae1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae4:	74 2c                	je     800b12 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae6:	85 db                	test   %ebx,%ebx
  800ae8:	75 0a                	jne    800af4 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aea:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aef:	80 39 30             	cmpb   $0x30,(%ecx)
  800af2:	74 28                	je     800b1c <strtol+0x6c>
		base = 10;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
  800af9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800afc:	eb 50                	jmp    800b4e <strtol+0x9e>
		s++;
  800afe:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b01:	bf 00 00 00 00       	mov    $0x0,%edi
  800b06:	eb d1                	jmp    800ad9 <strtol+0x29>
		s++, neg = 1;
  800b08:	83 c1 01             	add    $0x1,%ecx
  800b0b:	bf 01 00 00 00       	mov    $0x1,%edi
  800b10:	eb c7                	jmp    800ad9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b12:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b16:	74 0e                	je     800b26 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b18:	85 db                	test   %ebx,%ebx
  800b1a:	75 d8                	jne    800af4 <strtol+0x44>
		s++, base = 8;
  800b1c:	83 c1 01             	add    $0x1,%ecx
  800b1f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b24:	eb ce                	jmp    800af4 <strtol+0x44>
		s += 2, base = 16;
  800b26:	83 c1 02             	add    $0x2,%ecx
  800b29:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2e:	eb c4                	jmp    800af4 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b30:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b33:	89 f3                	mov    %esi,%ebx
  800b35:	80 fb 19             	cmp    $0x19,%bl
  800b38:	77 29                	ja     800b63 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b3a:	0f be d2             	movsbl %dl,%edx
  800b3d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b40:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b43:	7d 30                	jge    800b75 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b4e:	0f b6 11             	movzbl (%ecx),%edx
  800b51:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b54:	89 f3                	mov    %esi,%ebx
  800b56:	80 fb 09             	cmp    $0x9,%bl
  800b59:	77 d5                	ja     800b30 <strtol+0x80>
			dig = *s - '0';
  800b5b:	0f be d2             	movsbl %dl,%edx
  800b5e:	83 ea 30             	sub    $0x30,%edx
  800b61:	eb dd                	jmp    800b40 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b63:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b66:	89 f3                	mov    %esi,%ebx
  800b68:	80 fb 19             	cmp    $0x19,%bl
  800b6b:	77 08                	ja     800b75 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b6d:	0f be d2             	movsbl %dl,%edx
  800b70:	83 ea 37             	sub    $0x37,%edx
  800b73:	eb cb                	jmp    800b40 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b79:	74 05                	je     800b80 <strtol+0xd0>
		*endptr = (char *) s;
  800b7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	f7 da                	neg    %edx
  800b84:	85 ff                	test   %edi,%edi
  800b86:	0f 45 c2             	cmovne %edx,%eax
}
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5f                   	pop    %edi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9f:	89 c3                	mov    %eax,%ebx
  800ba1:	89 c7                	mov    %eax,%edi
  800ba3:	89 c6                	mov    %eax,%esi
  800ba5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <sys_cgetc>:

int
sys_cgetc(void)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	57                   	push   %edi
  800bb0:	56                   	push   %esi
  800bb1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbc:	89 d1                	mov    %edx,%ecx
  800bbe:	89 d3                	mov    %edx,%ebx
  800bc0:	89 d7                	mov    %edx,%edi
  800bc2:	89 d6                	mov    %edx,%esi
  800bc4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 1c             	sub    $0x1c,%esp
  800bd4:	e8 66 00 00 00       	call   800c3f <__x86.get_pc_thunk.ax>
  800bd9:	05 27 14 00 00       	add    $0x1427,%eax
  800bde:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800be1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bee:	89 cb                	mov    %ecx,%ebx
  800bf0:	89 cf                	mov    %ecx,%edi
  800bf2:	89 ce                	mov    %ecx,%esi
  800bf4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf6:	85 c0                	test   %eax,%eax
  800bf8:	7f 08                	jg     800c02 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 03                	push   $0x3
  800c08:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c0b:	8d 83 f0 f0 ff ff    	lea    -0xf10(%ebx),%eax
  800c11:	50                   	push   %eax
  800c12:	6a 23                	push   $0x23
  800c14:	8d 83 0d f1 ff ff    	lea    -0xef3(%ebx),%eax
  800c1a:	50                   	push   %eax
  800c1b:	e8 23 00 00 00       	call   800c43 <_panic>

00800c20 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c26:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2b:	b8 02 00 00 00       	mov    $0x2,%eax
  800c30:	89 d1                	mov    %edx,%ecx
  800c32:	89 d3                	mov    %edx,%ebx
  800c34:	89 d7                	mov    %edx,%edi
  800c36:	89 d6                	mov    %edx,%esi
  800c38:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <__x86.get_pc_thunk.ax>:
  800c3f:	8b 04 24             	mov    (%esp),%eax
  800c42:	c3                   	ret    

00800c43 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
  800c4c:	e8 23 f4 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800c51:	81 c3 af 13 00 00    	add    $0x13af,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c57:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c5a:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c60:	8b 38                	mov    (%eax),%edi
  800c62:	e8 b9 ff ff ff       	call   800c20 <sys_getenvid>
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	ff 75 0c             	pushl  0xc(%ebp)
  800c6d:	ff 75 08             	pushl  0x8(%ebp)
  800c70:	57                   	push   %edi
  800c71:	50                   	push   %eax
  800c72:	8d 83 1c f1 ff ff    	lea    -0xee4(%ebx),%eax
  800c78:	50                   	push   %eax
  800c79:	e8 13 f5 ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c7e:	83 c4 18             	add    $0x18,%esp
  800c81:	56                   	push   %esi
  800c82:	ff 75 10             	pushl  0x10(%ebp)
  800c85:	e8 a5 f4 ff ff       	call   80012f <vcprintf>
	cprintf("\n");
  800c8a:	8d 83 e8 ee ff ff    	lea    -0x1118(%ebx),%eax
  800c90:	89 04 24             	mov    %eax,(%esp)
  800c93:	e8 f9 f4 ff ff       	call   800191 <cprintf>
  800c98:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800c9b:	cc                   	int3   
  800c9c:	eb fd                	jmp    800c9b <_panic+0x58>
  800c9e:	66 90                	xchg   %ax,%ax

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
