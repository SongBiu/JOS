
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
  800045:	8d 83 fc ee ff ff    	lea    -0x1104(%ebx),%eax
  80004b:	50                   	push   %eax
  80004c:	e8 57 01 00 00       	call   8001a8 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800051:	c7 c0 2c 20 80 00    	mov    $0x80202c,%eax
  800057:	8b 00                	mov    (%eax),%eax
  800059:	8b 40 48             	mov    0x48(%eax),%eax
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	50                   	push   %eax
  800060:	8d 83 0a ef ff ff    	lea    -0x10f6(%ebx),%eax
  800066:	50                   	push   %eax
  800067:	e8 3c 01 00 00       	call   8001a8 <cprintf>
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
  80007b:	57                   	push   %edi
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	83 ec 0c             	sub    $0xc,%esp
  800081:	e8 ee ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800086:	81 c3 7a 1f 00 00    	add    $0x1f7a,%ebx
  80008c:	8b 75 08             	mov    0x8(%ebp),%esi
  80008f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800092:	e8 a0 0b 00 00       	call   800c37 <sys_getenvid>
  800097:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80009f:	c1 e0 05             	shl    $0x5,%eax
  8000a2:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000a8:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  8000ae:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b0:	85 f6                	test   %esi,%esi
  8000b2:	7e 08                	jle    8000bc <libmain+0x44>
		binaryname = argv[0];
  8000b4:	8b 07                	mov    (%edi),%eax
  8000b6:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000bc:	83 ec 08             	sub    $0x8,%esp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	e8 6d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c6:	e8 0b 00 00 00       	call   8000d6 <exit>
}
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	53                   	push   %ebx
  8000da:	83 ec 10             	sub    $0x10,%esp
  8000dd:	e8 92 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8000e2:	81 c3 1e 1f 00 00    	add    $0x1f1e,%ebx
	sys_env_destroy(0);
  8000e8:	6a 00                	push   $0x0
  8000ea:	e8 f3 0a 00 00       	call   800be2 <sys_env_destroy>
}
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    

008000f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 73 ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800101:	81 c3 ff 1e 00 00    	add    $0x1eff,%ebx
  800107:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  80010a:	8b 16                	mov    (%esi),%edx
  80010c:	8d 42 01             	lea    0x1(%edx),%eax
  80010f:	89 06                	mov    %eax,(%esi)
  800111:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800114:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800118:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011d:	74 0b                	je     80012a <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011f:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80012a:	83 ec 08             	sub    $0x8,%esp
  80012d:	68 ff 00 00 00       	push   $0xff
  800132:	8d 46 08             	lea    0x8(%esi),%eax
  800135:	50                   	push   %eax
  800136:	e8 6a 0a 00 00       	call   800ba5 <sys_cputs>
		b->idx = 0;
  80013b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	eb d9                	jmp    80011f <putch+0x28>

00800146 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	53                   	push   %ebx
  80014a:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800150:	e8 1f ff ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800155:	81 c3 ab 1e 00 00    	add    $0x1eab,%ebx
	struct printbuf b;

	b.idx = 0;
  80015b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800162:	00 00 00 
	b.cnt = 0;
  800165:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016f:	ff 75 0c             	pushl  0xc(%ebp)
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017b:	50                   	push   %eax
  80017c:	8d 83 f7 e0 ff ff    	lea    -0x1f09(%ebx),%eax
  800182:	50                   	push   %eax
  800183:	e8 38 01 00 00       	call   8002c0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800188:	83 c4 08             	add    $0x8,%esp
  80018b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	50                   	push   %eax
  800198:	e8 08 0a 00 00       	call   800ba5 <sys_cputs>
	return b.cnt;
}
  80019d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 8c ff ff ff       	call   800146 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 2c             	sub    $0x2c,%esp
  8001c5:	e8 63 06 00 00       	call   80082d <__x86.get_pc_thunk.cx>
  8001ca:	81 c1 36 1e 00 00    	add    $0x1e36,%ecx
  8001d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001d3:	89 c7                	mov    %eax,%edi
  8001d5:	89 d6                	mov    %edx,%esi
  8001d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001eb:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001ee:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001f1:	39 d3                	cmp    %edx,%ebx
  8001f3:	72 09                	jb     8001fe <printnum+0x42>
  8001f5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f8:	0f 87 83 00 00 00    	ja     800281 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	ff 75 18             	pushl  0x18(%ebp)
  800204:	8b 45 14             	mov    0x14(%ebp),%eax
  800207:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80020a:	53                   	push   %ebx
  80020b:	ff 75 10             	pushl  0x10(%ebp)
  80020e:	83 ec 08             	sub    $0x8,%esp
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	ff 75 d4             	pushl  -0x2c(%ebp)
  80021a:	ff 75 d0             	pushl  -0x30(%ebp)
  80021d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800220:	e8 9b 0a 00 00       	call   800cc0 <__udivdi3>
  800225:	83 c4 18             	add    $0x18,%esp
  800228:	52                   	push   %edx
  800229:	50                   	push   %eax
  80022a:	89 f2                	mov    %esi,%edx
  80022c:	89 f8                	mov    %edi,%eax
  80022e:	e8 89 ff ff ff       	call   8001bc <printnum>
  800233:	83 c4 20             	add    $0x20,%esp
  800236:	eb 13                	jmp    80024b <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	56                   	push   %esi
  80023c:	ff 75 18             	pushl  0x18(%ebp)
  80023f:	ff d7                	call   *%edi
  800241:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800244:	83 eb 01             	sub    $0x1,%ebx
  800247:	85 db                	test   %ebx,%ebx
  800249:	7f ed                	jg     800238 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	56                   	push   %esi
  80024f:	83 ec 04             	sub    $0x4,%esp
  800252:	ff 75 dc             	pushl  -0x24(%ebp)
  800255:	ff 75 d8             	pushl  -0x28(%ebp)
  800258:	ff 75 d4             	pushl  -0x2c(%ebp)
  80025b:	ff 75 d0             	pushl  -0x30(%ebp)
  80025e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800261:	89 f3                	mov    %esi,%ebx
  800263:	e8 78 0b 00 00       	call   800de0 <__umoddi3>
  800268:	83 c4 14             	add    $0x14,%esp
  80026b:	0f be 84 06 2b ef ff 	movsbl -0x10d5(%esi,%eax,1),%eax
  800272:	ff 
  800273:	50                   	push   %eax
  800274:	ff d7                	call   *%edi
}
  800276:	83 c4 10             	add    $0x10,%esp
  800279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    
  800281:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800284:	eb be                	jmp    800244 <printnum+0x88>

00800286 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800290:	8b 10                	mov    (%eax),%edx
  800292:	3b 50 04             	cmp    0x4(%eax),%edx
  800295:	73 0a                	jae    8002a1 <sprintputch+0x1b>
		*b->buf++ = ch;
  800297:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029a:	89 08                	mov    %ecx,(%eax)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	88 02                	mov    %al,(%edx)
}
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <printfmt>:
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ac:	50                   	push   %eax
  8002ad:	ff 75 10             	pushl  0x10(%ebp)
  8002b0:	ff 75 0c             	pushl  0xc(%ebp)
  8002b3:	ff 75 08             	pushl  0x8(%ebp)
  8002b6:	e8 05 00 00 00       	call   8002c0 <vprintfmt>
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <vprintfmt>:
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 2c             	sub    $0x2c,%esp
  8002c9:	e8 a6 fd ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8002ce:	81 c3 32 1d 00 00    	add    $0x1d32,%ebx
  8002d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8002d7:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8002de:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e0:	8d 77 01             	lea    0x1(%edi),%esi
  8002e3:	0f b6 07             	movzbl (%edi),%eax
  8002e6:	83 f8 25             	cmp    $0x25,%eax
  8002e9:	74 1c                	je     800307 <vprintfmt+0x47>
			if (ch == '\0')
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	0f 84 b9 04 00 00    	je     8007ac <.L21+0x20>
			putch(ch, putdat);
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8002f9:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8002fc:	50                   	push   %eax
  8002fd:	ff 55 08             	call   *0x8(%ebp)
  800300:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800303:	89 f7                	mov    %esi,%edi
  800305:	eb d9                	jmp    8002e0 <vprintfmt+0x20>
		padc = ' ';
  800307:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  80030b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800312:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800319:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800320:	b9 00 00 00 00       	mov    $0x0,%ecx
  800325:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8d 7e 01             	lea    0x1(%esi),%edi
  80032b:	0f b6 16             	movzbl (%esi),%edx
  80032e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800331:	3c 55                	cmp    $0x55,%al
  800333:	0f 87 53 04 00 00    	ja     80078c <.L21>
  800339:	0f b6 c0             	movzbl %al,%eax
  80033c:	89 d9                	mov    %ebx,%ecx
  80033e:	03 8c 83 b8 ef ff ff 	add    -0x1048(%ebx,%eax,4),%ecx
  800345:	ff e1                	jmp    *%ecx

00800347 <.L73>:
  800347:	89 fe                	mov    %edi,%esi
			padc = '-';
  800349:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80034d:	eb d9                	jmp    800328 <vprintfmt+0x68>

0080034f <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	89 fe                	mov    %edi,%esi
			padc = '0';
  800351:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800355:	eb d1                	jmp    800328 <vprintfmt+0x68>

00800357 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800357:	0f b6 d2             	movzbl %dl,%edx
  80035a:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  80035c:	b8 00 00 00 00       	mov    $0x0,%eax
  800361:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800364:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800367:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036b:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  80036e:	8d 7a d0             	lea    -0x30(%edx),%edi
  800371:	83 ff 09             	cmp    $0x9,%edi
  800374:	0f 87 94 00 00 00    	ja     80040e <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  80037a:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80037d:	eb e5                	jmp    800364 <.L28+0xd>

0080037f <.L25>:
			precision = va_arg(ap, int);
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8b 00                	mov    (%eax),%eax
  800384:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800387:	8b 45 14             	mov    0x14(%ebp),%eax
  80038a:	8d 40 04             	lea    0x4(%eax),%eax
  80038d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800390:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800392:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800396:	79 90                	jns    800328 <vprintfmt+0x68>
				width = precision, precision = -1;
  800398:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80039b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039e:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003a5:	eb 81                	jmp    800328 <vprintfmt+0x68>

008003a7 <.L26>:
  8003a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b1:	0f 49 d0             	cmovns %eax,%edx
  8003b4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	89 fe                	mov    %edi,%esi
  8003b9:	e9 6a ff ff ff       	jmp    800328 <vprintfmt+0x68>

008003be <.L22>:
  8003be:	89 fe                	mov    %edi,%esi
			altflag = 1;
  8003c0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c7:	e9 5c ff ff ff       	jmp    800328 <vprintfmt+0x68>

008003cc <.L33>:
  8003cc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8003cf:	83 f9 01             	cmp    $0x1,%ecx
  8003d2:	7e 16                	jle    8003ea <.L33+0x1e>
		return va_arg(*ap, long long);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003dc:	8d 49 08             	lea    0x8(%ecx),%ecx
  8003df:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8003e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8003e5:	e9 f6 fe ff ff       	jmp    8002e0 <vprintfmt+0x20>
	else if (lflag)
  8003ea:	85 c9                	test   %ecx,%ecx
  8003ec:	75 10                	jne    8003fe <.L33+0x32>
		return va_arg(*ap, int);
  8003ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f1:	8b 00                	mov    (%eax),%eax
  8003f3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003f6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8003f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fc:	eb e4                	jmp    8003e2 <.L33+0x16>
		return va_arg(*ap, long);
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8b 00                	mov    (%eax),%eax
  800403:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800406:	8d 49 04             	lea    0x4(%ecx),%ecx
  800409:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040c:	eb d4                	jmp    8003e2 <.L33+0x16>
  80040e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800411:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800414:	e9 79 ff ff ff       	jmp    800392 <.L25+0x13>

00800419 <.L32>:
			lflag++;
  800419:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	89 fe                	mov    %edi,%esi
			goto reswitch;
  80041f:	e9 04 ff ff ff       	jmp    800328 <vprintfmt+0x68>

00800424 <.L29>:
			putch(va_arg(ap, int), putdat);
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 70 04             	lea    0x4(%eax),%esi
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	ff 75 0c             	pushl  0xc(%ebp)
  800430:	ff 30                	pushl  (%eax)
  800432:	ff 55 08             	call   *0x8(%ebp)
			break;
  800435:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800438:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  80043b:	e9 a0 fe ff ff       	jmp    8002e0 <vprintfmt+0x20>

00800440 <.L31>:
			err = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 70 04             	lea    0x4(%eax),%esi
  800446:	8b 00                	mov    (%eax),%eax
  800448:	99                   	cltd   
  800449:	31 d0                	xor    %edx,%eax
  80044b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044d:	83 f8 06             	cmp    $0x6,%eax
  800450:	7f 29                	jg     80047b <.L31+0x3b>
  800452:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800459:	85 d2                	test   %edx,%edx
  80045b:	74 1e                	je     80047b <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  80045d:	52                   	push   %edx
  80045e:	8d 83 4c ef ff ff    	lea    -0x10b4(%ebx),%eax
  800464:	50                   	push   %eax
  800465:	ff 75 0c             	pushl  0xc(%ebp)
  800468:	ff 75 08             	pushl  0x8(%ebp)
  80046b:	e8 33 fe ff ff       	call   8002a3 <printfmt>
  800470:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800473:	89 75 14             	mov    %esi,0x14(%ebp)
  800476:	e9 65 fe ff ff       	jmp    8002e0 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  80047b:	50                   	push   %eax
  80047c:	8d 83 43 ef ff ff    	lea    -0x10bd(%ebx),%eax
  800482:	50                   	push   %eax
  800483:	ff 75 0c             	pushl  0xc(%ebp)
  800486:	ff 75 08             	pushl  0x8(%ebp)
  800489:	e8 15 fe ff ff       	call   8002a3 <printfmt>
  80048e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800491:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800494:	e9 47 fe ff ff       	jmp    8002e0 <vprintfmt+0x20>

00800499 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	83 c0 04             	add    $0x4,%eax
  80049f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004a7:	85 f6                	test   %esi,%esi
  8004a9:	8d 83 3c ef ff ff    	lea    -0x10c4(%ebx),%eax
  8004af:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b6:	0f 8e b4 00 00 00    	jle    800570 <.L36+0xd7>
  8004bc:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8004c0:	75 08                	jne    8004ca <.L36+0x31>
  8004c2:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004c5:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004c8:	eb 6c                	jmp    800536 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 cc             	pushl  -0x34(%ebp)
  8004d0:	56                   	push   %esi
  8004d1:	e8 73 03 00 00       	call   800849 <strnlen>
  8004d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d9:	29 c2                	sub    %eax,%edx
  8004db:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e1:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004e5:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004e8:	89 d6                	mov    %edx,%esi
  8004ea:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004ed:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	eb 10                	jmp    800501 <.L36+0x68>
					putch(padc, putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	ff 75 0c             	pushl  0xc(%ebp)
  8004f7:	57                   	push   %edi
  8004f8:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 ee 01             	sub    $0x1,%esi
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 f6                	test   %esi,%esi
  800503:	7f ec                	jg     8004f1 <.L36+0x58>
  800505:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800508:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80050b:	85 d2                	test   %edx,%edx
  80050d:	b8 00 00 00 00       	mov    $0x0,%eax
  800512:	0f 49 c2             	cmovns %edx,%eax
  800515:	29 c2                	sub    %eax,%edx
  800517:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80051a:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80051d:	eb 17                	jmp    800536 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  80051f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800523:	75 30                	jne    800555 <.L36+0xbc>
					putch(ch, putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	ff 75 0c             	pushl  0xc(%ebp)
  80052b:	50                   	push   %eax
  80052c:	ff 55 08             	call   *0x8(%ebp)
  80052f:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800532:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800536:	83 c6 01             	add    $0x1,%esi
  800539:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80053d:	0f be c2             	movsbl %dl,%eax
  800540:	85 c0                	test   %eax,%eax
  800542:	74 58                	je     80059c <.L36+0x103>
  800544:	85 ff                	test   %edi,%edi
  800546:	78 d7                	js     80051f <.L36+0x86>
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	79 d2                	jns    80051f <.L36+0x86>
  80054d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800550:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800553:	eb 32                	jmp    800587 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800555:	0f be d2             	movsbl %dl,%edx
  800558:	83 ea 20             	sub    $0x20,%edx
  80055b:	83 fa 5e             	cmp    $0x5e,%edx
  80055e:	76 c5                	jbe    800525 <.L36+0x8c>
					putch('?', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 0c             	pushl  0xc(%ebp)
  800566:	6a 3f                	push   $0x3f
  800568:	ff 55 08             	call   *0x8(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	eb c2                	jmp    800532 <.L36+0x99>
  800570:	89 7d 10             	mov    %edi,0x10(%ebp)
  800573:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800576:	eb be                	jmp    800536 <.L36+0x9d>
				putch(' ', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	57                   	push   %edi
  80057c:	6a 20                	push   $0x20
  80057e:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800581:	83 ee 01             	sub    $0x1,%esi
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	85 f6                	test   %esi,%esi
  800589:	7f ed                	jg     800578 <.L36+0xdf>
  80058b:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80058e:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800591:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800594:	89 45 14             	mov    %eax,0x14(%ebp)
  800597:	e9 44 fd ff ff       	jmp    8002e0 <vprintfmt+0x20>
  80059c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80059f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005a2:	eb e3                	jmp    800587 <.L36+0xee>

008005a4 <.L30>:
  8005a4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8005a7:	83 f9 01             	cmp    $0x1,%ecx
  8005aa:	7e 42                	jle    8005ee <.L30+0x4a>
		return va_arg(*ap, long long);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 50 04             	mov    0x4(%eax),%edx
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 40 08             	lea    0x8(%eax),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005c3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c7:	79 5f                	jns    800628 <.L30+0x84>
				putch('-', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	ff 75 0c             	pushl  0xc(%ebp)
  8005cf:	6a 2d                	push   $0x2d
  8005d1:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005da:	f7 da                	neg    %edx
  8005dc:	83 d1 00             	adc    $0x0,%ecx
  8005df:	f7 d9                	neg    %ecx
  8005e1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e9:	e9 b8 00 00 00       	jmp    8006a6 <.L34+0x22>
	else if (lflag)
  8005ee:	85 c9                	test   %ecx,%ecx
  8005f0:	75 1b                	jne    80060d <.L30+0x69>
		return va_arg(*ap, int);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 30                	mov    (%eax),%esi
  8005f7:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005fa:	89 f0                	mov    %esi,%eax
  8005fc:	c1 f8 1f             	sar    $0x1f,%eax
  8005ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 40 04             	lea    0x4(%eax),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
  80060b:	eb b6                	jmp    8005c3 <.L30+0x1f>
		return va_arg(*ap, long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 30                	mov    (%eax),%esi
  800612:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800615:	89 f0                	mov    %esi,%eax
  800617:	c1 f8 1f             	sar    $0x1f,%eax
  80061a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 40 04             	lea    0x4(%eax),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
  800626:	eb 9b                	jmp    8005c3 <.L30+0x1f>
			num = getint(&ap, lflag);
  800628:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800633:	eb 71                	jmp    8006a6 <.L34+0x22>

00800635 <.L37>:
  800635:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800638:	83 f9 01             	cmp    $0x1,%ecx
  80063b:	7e 15                	jle    800652 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 10                	mov    (%eax),%edx
  800642:	8b 48 04             	mov    0x4(%eax),%ecx
  800645:	8d 40 08             	lea    0x8(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800650:	eb 54                	jmp    8006a6 <.L34+0x22>
	else if (lflag)
  800652:	85 c9                	test   %ecx,%ecx
  800654:	75 17                	jne    80066d <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800660:	8d 40 04             	lea    0x4(%eax),%eax
  800663:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	eb 39                	jmp    8006a6 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 10                	mov    (%eax),%edx
  800672:	b9 00 00 00 00       	mov    $0x0,%ecx
  800677:	8d 40 04             	lea    0x4(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80067d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800682:	eb 22                	jmp    8006a6 <.L34+0x22>

00800684 <.L34>:
  800684:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800687:	83 f9 01             	cmp    $0x1,%ecx
  80068a:	7e 3b                	jle    8006c7 <.L34+0x43>
		return va_arg(*ap, long long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 50 04             	mov    0x4(%eax),%edx
  800692:	8b 00                	mov    (%eax),%eax
  800694:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800697:	8d 49 08             	lea    0x8(%ecx),%ecx
  80069a:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80069d:	89 d1                	mov    %edx,%ecx
  80069f:	89 c2                	mov    %eax,%edx
			base = 8;
  8006a1:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006a6:	83 ec 0c             	sub    $0xc,%esp
  8006a9:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  8006ad:	56                   	push   %esi
  8006ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b1:	50                   	push   %eax
  8006b2:	51                   	push   %ecx
  8006b3:	52                   	push   %edx
  8006b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ba:	e8 fd fa ff ff       	call   8001bc <printnum>
			break;
  8006bf:	83 c4 20             	add    $0x20,%esp
  8006c2:	e9 19 fc ff ff       	jmp    8002e0 <vprintfmt+0x20>
	else if (lflag)
  8006c7:	85 c9                	test   %ecx,%ecx
  8006c9:	75 13                	jne    8006de <.L34+0x5a>
		return va_arg(*ap, int);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 10                	mov    (%eax),%edx
  8006d0:	89 d0                	mov    %edx,%eax
  8006d2:	99                   	cltd   
  8006d3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006d6:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006dc:	eb bf                	jmp    80069d <.L34+0x19>
		return va_arg(*ap, long);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8b 10                	mov    (%eax),%edx
  8006e3:	89 d0                	mov    %edx,%eax
  8006e5:	99                   	cltd   
  8006e6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006e9:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006ec:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006ef:	eb ac                	jmp    80069d <.L34+0x19>

008006f1 <.L35>:
			putch('0', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	ff 75 0c             	pushl  0xc(%ebp)
  8006f7:	6a 30                	push   $0x30
  8006f9:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006fc:	83 c4 08             	add    $0x8,%esp
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	6a 78                	push   $0x78
  800704:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800711:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800714:	8d 40 04             	lea    0x4(%eax),%eax
  800717:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80071f:	eb 85                	jmp    8006a6 <.L34+0x22>

00800721 <.L38>:
  800721:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800724:	83 f9 01             	cmp    $0x1,%ecx
  800727:	7e 18                	jle    800741 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  800729:	8b 45 14             	mov    0x14(%ebp),%eax
  80072c:	8b 10                	mov    (%eax),%edx
  80072e:	8b 48 04             	mov    0x4(%eax),%ecx
  800731:	8d 40 08             	lea    0x8(%eax),%eax
  800734:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800737:	b8 10 00 00 00       	mov    $0x10,%eax
  80073c:	e9 65 ff ff ff       	jmp    8006a6 <.L34+0x22>
	else if (lflag)
  800741:	85 c9                	test   %ecx,%ecx
  800743:	75 1a                	jne    80075f <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8b 10                	mov    (%eax),%edx
  80074a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074f:	8d 40 04             	lea    0x4(%eax),%eax
  800752:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800755:	b8 10 00 00 00       	mov    $0x10,%eax
  80075a:	e9 47 ff ff ff       	jmp    8006a6 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8b 10                	mov    (%eax),%edx
  800764:	b9 00 00 00 00       	mov    $0x0,%ecx
  800769:	8d 40 04             	lea    0x4(%eax),%eax
  80076c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076f:	b8 10 00 00 00       	mov    $0x10,%eax
  800774:	e9 2d ff ff ff       	jmp    8006a6 <.L34+0x22>

00800779 <.L24>:
			putch(ch, putdat);
  800779:	83 ec 08             	sub    $0x8,%esp
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	6a 25                	push   $0x25
  800781:	ff 55 08             	call   *0x8(%ebp)
			break;
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	e9 54 fb ff ff       	jmp    8002e0 <vprintfmt+0x20>

0080078c <.L21>:
			putch('%', putdat);
  80078c:	83 ec 08             	sub    $0x8,%esp
  80078f:	ff 75 0c             	pushl  0xc(%ebp)
  800792:	6a 25                	push   $0x25
  800794:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	89 f7                	mov    %esi,%edi
  80079c:	eb 03                	jmp    8007a1 <.L21+0x15>
  80079e:	83 ef 01             	sub    $0x1,%edi
  8007a1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a5:	75 f7                	jne    80079e <.L21+0x12>
  8007a7:	e9 34 fb ff ff       	jmp    8002e0 <vprintfmt+0x20>
}
  8007ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007af:	5b                   	pop    %ebx
  8007b0:	5e                   	pop    %esi
  8007b1:	5f                   	pop    %edi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	83 ec 14             	sub    $0x14,%esp
  8007bb:	e8 b4 f8 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  8007c0:	81 c3 40 18 00 00    	add    $0x1840,%ebx
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007cc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007cf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	74 2b                	je     80080c <vsnprintf+0x58>
  8007e1:	85 d2                	test   %edx,%edx
  8007e3:	7e 27                	jle    80080c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e5:	ff 75 14             	pushl  0x14(%ebp)
  8007e8:	ff 75 10             	pushl  0x10(%ebp)
  8007eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ee:	50                   	push   %eax
  8007ef:	8d 83 86 e2 ff ff    	lea    -0x1d7a(%ebx),%eax
  8007f5:	50                   	push   %eax
  8007f6:	e8 c5 fa ff ff       	call   8002c0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800801:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800804:	83 c4 10             	add    $0x10,%esp
}
  800807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080a:	c9                   	leave  
  80080b:	c3                   	ret    
		return -E_INVAL;
  80080c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800811:	eb f4                	jmp    800807 <vsnprintf+0x53>

00800813 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800819:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081c:	50                   	push   %eax
  80081d:	ff 75 10             	pushl  0x10(%ebp)
  800820:	ff 75 0c             	pushl  0xc(%ebp)
  800823:	ff 75 08             	pushl  0x8(%ebp)
  800826:	e8 89 ff ff ff       	call   8007b4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <__x86.get_pc_thunk.cx>:
  80082d:	8b 0c 24             	mov    (%esp),%ecx
  800830:	c3                   	ret    

00800831 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
  80083c:	eb 03                	jmp    800841 <strlen+0x10>
		n++;
  80083e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800841:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800845:	75 f7                	jne    80083e <strlen+0xd>
	return n;
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
  800857:	eb 03                	jmp    80085c <strnlen+0x13>
		n++;
  800859:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085c:	39 d0                	cmp    %edx,%eax
  80085e:	74 06                	je     800866 <strnlen+0x1d>
  800860:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800864:	75 f3                	jne    800859 <strnlen+0x10>
	return n;
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800872:	89 c2                	mov    %eax,%edx
  800874:	83 c1 01             	add    $0x1,%ecx
  800877:	83 c2 01             	add    $0x1,%edx
  80087a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80087e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800881:	84 db                	test   %bl,%bl
  800883:	75 ef                	jne    800874 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088f:	53                   	push   %ebx
  800890:	e8 9c ff ff ff       	call   800831 <strlen>
  800895:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800898:	ff 75 0c             	pushl  0xc(%ebp)
  80089b:	01 d8                	add    %ebx,%eax
  80089d:	50                   	push   %eax
  80089e:	e8 c5 ff ff ff       	call   800868 <strcpy>
	return dst;
}
  8008a3:	89 d8                	mov    %ebx,%eax
  8008a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b5:	89 f3                	mov    %esi,%ebx
  8008b7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ba:	89 f2                	mov    %esi,%edx
  8008bc:	eb 0f                	jmp    8008cd <strncpy+0x23>
		*dst++ = *src;
  8008be:	83 c2 01             	add    $0x1,%edx
  8008c1:	0f b6 01             	movzbl (%ecx),%eax
  8008c4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c7:	80 39 01             	cmpb   $0x1,(%ecx)
  8008ca:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008cd:	39 da                	cmp    %ebx,%edx
  8008cf:	75 ed                	jne    8008be <strncpy+0x14>
	}
	return ret;
}
  8008d1:	89 f0                	mov    %esi,%eax
  8008d3:	5b                   	pop    %ebx
  8008d4:	5e                   	pop    %esi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008e5:	89 f0                	mov    %esi,%eax
  8008e7:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	75 0b                	jne    8008fa <strlcpy+0x23>
  8008ef:	eb 17                	jmp    800908 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f1:	83 c2 01             	add    $0x1,%edx
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008fa:	39 d8                	cmp    %ebx,%eax
  8008fc:	74 07                	je     800905 <strlcpy+0x2e>
  8008fe:	0f b6 0a             	movzbl (%edx),%ecx
  800901:	84 c9                	test   %cl,%cl
  800903:	75 ec                	jne    8008f1 <strlcpy+0x1a>
		*dst = '\0';
  800905:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800908:	29 f0                	sub    %esi,%eax
}
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800914:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800917:	eb 06                	jmp    80091f <strcmp+0x11>
		p++, q++;
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80091f:	0f b6 01             	movzbl (%ecx),%eax
  800922:	84 c0                	test   %al,%al
  800924:	74 04                	je     80092a <strcmp+0x1c>
  800926:	3a 02                	cmp    (%edx),%al
  800928:	74 ef                	je     800919 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80092a:	0f b6 c0             	movzbl %al,%eax
  80092d:	0f b6 12             	movzbl (%edx),%edx
  800930:	29 d0                	sub    %edx,%eax
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	53                   	push   %ebx
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093e:	89 c3                	mov    %eax,%ebx
  800940:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800943:	eb 06                	jmp    80094b <strncmp+0x17>
		n--, p++, q++;
  800945:	83 c0 01             	add    $0x1,%eax
  800948:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80094b:	39 d8                	cmp    %ebx,%eax
  80094d:	74 16                	je     800965 <strncmp+0x31>
  80094f:	0f b6 08             	movzbl (%eax),%ecx
  800952:	84 c9                	test   %cl,%cl
  800954:	74 04                	je     80095a <strncmp+0x26>
  800956:	3a 0a                	cmp    (%edx),%cl
  800958:	74 eb                	je     800945 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80095a:	0f b6 00             	movzbl (%eax),%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
}
  800962:	5b                   	pop    %ebx
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    
		return 0;
  800965:	b8 00 00 00 00       	mov    $0x0,%eax
  80096a:	eb f6                	jmp    800962 <strncmp+0x2e>

0080096c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800976:	0f b6 10             	movzbl (%eax),%edx
  800979:	84 d2                	test   %dl,%dl
  80097b:	74 09                	je     800986 <strchr+0x1a>
		if (*s == c)
  80097d:	38 ca                	cmp    %cl,%dl
  80097f:	74 0a                	je     80098b <strchr+0x1f>
	for (; *s; s++)
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	eb f0                	jmp    800976 <strchr+0xa>
			return (char *) s;
	return 0;
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800997:	eb 03                	jmp    80099c <strfind+0xf>
  800999:	83 c0 01             	add    $0x1,%eax
  80099c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80099f:	38 ca                	cmp    %cl,%dl
  8009a1:	74 04                	je     8009a7 <strfind+0x1a>
  8009a3:	84 d2                	test   %dl,%dl
  8009a5:	75 f2                	jne    800999 <strfind+0xc>
			break;
	return (char *) s;
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	57                   	push   %edi
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b5:	85 c9                	test   %ecx,%ecx
  8009b7:	74 13                	je     8009cc <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009bf:	75 05                	jne    8009c6 <memset+0x1d>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	74 0d                	je     8009d3 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c9:	fc                   	cld    
  8009ca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cc:	89 f8                	mov    %edi,%eax
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5f                   	pop    %edi
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    
		c &= 0xFF;
  8009d3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d7:	89 d3                	mov    %edx,%ebx
  8009d9:	c1 e3 08             	shl    $0x8,%ebx
  8009dc:	89 d0                	mov    %edx,%eax
  8009de:	c1 e0 18             	shl    $0x18,%eax
  8009e1:	89 d6                	mov    %edx,%esi
  8009e3:	c1 e6 10             	shl    $0x10,%esi
  8009e6:	09 f0                	or     %esi,%eax
  8009e8:	09 c2                	or     %eax,%edx
  8009ea:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009ec:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ef:	89 d0                	mov    %edx,%eax
  8009f1:	fc                   	cld    
  8009f2:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f4:	eb d6                	jmp    8009cc <memset+0x23>

008009f6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	57                   	push   %edi
  8009fa:	56                   	push   %esi
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a01:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a04:	39 c6                	cmp    %eax,%esi
  800a06:	73 35                	jae    800a3d <memmove+0x47>
  800a08:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0b:	39 c2                	cmp    %eax,%edx
  800a0d:	76 2e                	jbe    800a3d <memmove+0x47>
		s += n;
		d += n;
  800a0f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a12:	89 d6                	mov    %edx,%esi
  800a14:	09 fe                	or     %edi,%esi
  800a16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1c:	74 0c                	je     800a2a <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1e:	83 ef 01             	sub    $0x1,%edi
  800a21:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a24:	fd                   	std    
  800a25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a27:	fc                   	cld    
  800a28:	eb 21                	jmp    800a4b <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2a:	f6 c1 03             	test   $0x3,%cl
  800a2d:	75 ef                	jne    800a1e <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a2f:	83 ef 04             	sub    $0x4,%edi
  800a32:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a35:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a38:	fd                   	std    
  800a39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3b:	eb ea                	jmp    800a27 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3d:	89 f2                	mov    %esi,%edx
  800a3f:	09 c2                	or     %eax,%edx
  800a41:	f6 c2 03             	test   $0x3,%dl
  800a44:	74 09                	je     800a4f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a46:	89 c7                	mov    %eax,%edi
  800a48:	fc                   	cld    
  800a49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4f:	f6 c1 03             	test   $0x3,%cl
  800a52:	75 f2                	jne    800a46 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a54:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a57:	89 c7                	mov    %eax,%edi
  800a59:	fc                   	cld    
  800a5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5c:	eb ed                	jmp    800a4b <memmove+0x55>

00800a5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a61:	ff 75 10             	pushl  0x10(%ebp)
  800a64:	ff 75 0c             	pushl  0xc(%ebp)
  800a67:	ff 75 08             	pushl  0x8(%ebp)
  800a6a:	e8 87 ff ff ff       	call   8009f6 <memmove>
}
  800a6f:	c9                   	leave  
  800a70:	c3                   	ret    

00800a71 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7c:	89 c6                	mov    %eax,%esi
  800a7e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a81:	39 f0                	cmp    %esi,%eax
  800a83:	74 1c                	je     800aa1 <memcmp+0x30>
		if (*s1 != *s2)
  800a85:	0f b6 08             	movzbl (%eax),%ecx
  800a88:	0f b6 1a             	movzbl (%edx),%ebx
  800a8b:	38 d9                	cmp    %bl,%cl
  800a8d:	75 08                	jne    800a97 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a8f:	83 c0 01             	add    $0x1,%eax
  800a92:	83 c2 01             	add    $0x1,%edx
  800a95:	eb ea                	jmp    800a81 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a97:	0f b6 c1             	movzbl %cl,%eax
  800a9a:	0f b6 db             	movzbl %bl,%ebx
  800a9d:	29 d8                	sub    %ebx,%eax
  800a9f:	eb 05                	jmp    800aa6 <memcmp+0x35>
	}

	return 0;
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab3:	89 c2                	mov    %eax,%edx
  800ab5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab8:	39 d0                	cmp    %edx,%eax
  800aba:	73 09                	jae    800ac5 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abc:	38 08                	cmp    %cl,(%eax)
  800abe:	74 05                	je     800ac5 <memfind+0x1b>
	for (; s < ends; s++)
  800ac0:	83 c0 01             	add    $0x1,%eax
  800ac3:	eb f3                	jmp    800ab8 <memfind+0xe>
			break;
	return (void *) s;
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad3:	eb 03                	jmp    800ad8 <strtol+0x11>
		s++;
  800ad5:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ad8:	0f b6 01             	movzbl (%ecx),%eax
  800adb:	3c 20                	cmp    $0x20,%al
  800add:	74 f6                	je     800ad5 <strtol+0xe>
  800adf:	3c 09                	cmp    $0x9,%al
  800ae1:	74 f2                	je     800ad5 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ae3:	3c 2b                	cmp    $0x2b,%al
  800ae5:	74 2e                	je     800b15 <strtol+0x4e>
	int neg = 0;
  800ae7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aec:	3c 2d                	cmp    $0x2d,%al
  800aee:	74 2f                	je     800b1f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800af6:	75 05                	jne    800afd <strtol+0x36>
  800af8:	80 39 30             	cmpb   $0x30,(%ecx)
  800afb:	74 2c                	je     800b29 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800afd:	85 db                	test   %ebx,%ebx
  800aff:	75 0a                	jne    800b0b <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b01:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b06:	80 39 30             	cmpb   $0x30,(%ecx)
  800b09:	74 28                	je     800b33 <strtol+0x6c>
		base = 10;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b10:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b13:	eb 50                	jmp    800b65 <strtol+0x9e>
		s++;
  800b15:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b18:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1d:	eb d1                	jmp    800af0 <strtol+0x29>
		s++, neg = 1;
  800b1f:	83 c1 01             	add    $0x1,%ecx
  800b22:	bf 01 00 00 00       	mov    $0x1,%edi
  800b27:	eb c7                	jmp    800af0 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b29:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2d:	74 0e                	je     800b3d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b2f:	85 db                	test   %ebx,%ebx
  800b31:	75 d8                	jne    800b0b <strtol+0x44>
		s++, base = 8;
  800b33:	83 c1 01             	add    $0x1,%ecx
  800b36:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b3b:	eb ce                	jmp    800b0b <strtol+0x44>
		s += 2, base = 16;
  800b3d:	83 c1 02             	add    $0x2,%ecx
  800b40:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b45:	eb c4                	jmp    800b0b <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b47:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b4a:	89 f3                	mov    %esi,%ebx
  800b4c:	80 fb 19             	cmp    $0x19,%bl
  800b4f:	77 29                	ja     800b7a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b51:	0f be d2             	movsbl %dl,%edx
  800b54:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b57:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5a:	7d 30                	jge    800b8c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b5c:	83 c1 01             	add    $0x1,%ecx
  800b5f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b63:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b65:	0f b6 11             	movzbl (%ecx),%edx
  800b68:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b6b:	89 f3                	mov    %esi,%ebx
  800b6d:	80 fb 09             	cmp    $0x9,%bl
  800b70:	77 d5                	ja     800b47 <strtol+0x80>
			dig = *s - '0';
  800b72:	0f be d2             	movsbl %dl,%edx
  800b75:	83 ea 30             	sub    $0x30,%edx
  800b78:	eb dd                	jmp    800b57 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b7a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7d:	89 f3                	mov    %esi,%ebx
  800b7f:	80 fb 19             	cmp    $0x19,%bl
  800b82:	77 08                	ja     800b8c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b84:	0f be d2             	movsbl %dl,%edx
  800b87:	83 ea 37             	sub    $0x37,%edx
  800b8a:	eb cb                	jmp    800b57 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b90:	74 05                	je     800b97 <strtol+0xd0>
		*endptr = (char *) s;
  800b92:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b95:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b97:	89 c2                	mov    %eax,%edx
  800b99:	f7 da                	neg    %edx
  800b9b:	85 ff                	test   %edi,%edi
  800b9d:	0f 45 c2             	cmovne %edx,%eax
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	89 c3                	mov    %eax,%ebx
  800bb8:	89 c7                	mov    %eax,%edi
  800bba:	89 c6                	mov    %eax,%esi
  800bbc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 1c             	sub    $0x1c,%esp
  800beb:	e8 66 00 00 00       	call   800c56 <__x86.get_pc_thunk.ax>
  800bf0:	05 10 14 00 00       	add    $0x1410,%eax
  800bf5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800bf8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	b8 03 00 00 00       	mov    $0x3,%eax
  800c05:	89 cb                	mov    %ecx,%ebx
  800c07:	89 cf                	mov    %ecx,%edi
  800c09:	89 ce                	mov    %ecx,%esi
  800c0b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7f 08                	jg     800c19 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 03                	push   $0x3
  800c1f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c22:	8d 83 10 f1 ff ff    	lea    -0xef0(%ebx),%eax
  800c28:	50                   	push   %eax
  800c29:	6a 26                	push   $0x26
  800c2b:	8d 83 2d f1 ff ff    	lea    -0xed3(%ebx),%eax
  800c31:	50                   	push   %eax
  800c32:	e8 23 00 00 00       	call   800c5a <_panic>

00800c37 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	b8 02 00 00 00       	mov    $0x2,%eax
  800c47:	89 d1                	mov    %edx,%ecx
  800c49:	89 d3                	mov    %edx,%ebx
  800c4b:	89 d7                	mov    %edx,%edi
  800c4d:	89 d6                	mov    %edx,%esi
  800c4f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <__x86.get_pc_thunk.ax>:
  800c56:	8b 04 24             	mov    (%esp),%eax
  800c59:	c3                   	ret    

00800c5a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	e8 0c f4 ff ff       	call   800074 <__x86.get_pc_thunk.bx>
  800c68:	81 c3 98 13 00 00    	add    $0x1398,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c6e:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c71:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c77:	8b 38                	mov    (%eax),%edi
  800c79:	e8 b9 ff ff ff       	call   800c37 <sys_getenvid>
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	ff 75 0c             	pushl  0xc(%ebp)
  800c84:	ff 75 08             	pushl  0x8(%ebp)
  800c87:	57                   	push   %edi
  800c88:	50                   	push   %eax
  800c89:	8d 83 3c f1 ff ff    	lea    -0xec4(%ebx),%eax
  800c8f:	50                   	push   %eax
  800c90:	e8 13 f5 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c95:	83 c4 18             	add    $0x18,%esp
  800c98:	56                   	push   %esi
  800c99:	ff 75 10             	pushl  0x10(%ebp)
  800c9c:	e8 a5 f4 ff ff       	call   800146 <vcprintf>
	cprintf("\n");
  800ca1:	8d 83 08 ef ff ff    	lea    -0x10f8(%ebx),%eax
  800ca7:	89 04 24             	mov    %eax,(%esp)
  800caa:	e8 f9 f4 ff ff       	call   8001a8 <cprintf>
  800caf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cb2:	cc                   	int3   
  800cb3:	eb fd                	jmp    800cb2 <_panic+0x58>
  800cb5:	66 90                	xchg   %ax,%ax
  800cb7:	66 90                	xchg   %ax,%ax
  800cb9:	66 90                	xchg   %ax,%ax
  800cbb:	66 90                	xchg   %ax,%ax
  800cbd:	66 90                	xchg   %ax,%ax
  800cbf:	90                   	nop

00800cc0 <__udivdi3>:
  800cc0:	55                   	push   %ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 1c             	sub    $0x1c,%esp
  800cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ccb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cd3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cd7:	85 d2                	test   %edx,%edx
  800cd9:	75 35                	jne    800d10 <__udivdi3+0x50>
  800cdb:	39 f3                	cmp    %esi,%ebx
  800cdd:	0f 87 bd 00 00 00    	ja     800da0 <__udivdi3+0xe0>
  800ce3:	85 db                	test   %ebx,%ebx
  800ce5:	89 d9                	mov    %ebx,%ecx
  800ce7:	75 0b                	jne    800cf4 <__udivdi3+0x34>
  800ce9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cee:	31 d2                	xor    %edx,%edx
  800cf0:	f7 f3                	div    %ebx
  800cf2:	89 c1                	mov    %eax,%ecx
  800cf4:	31 d2                	xor    %edx,%edx
  800cf6:	89 f0                	mov    %esi,%eax
  800cf8:	f7 f1                	div    %ecx
  800cfa:	89 c6                	mov    %eax,%esi
  800cfc:	89 e8                	mov    %ebp,%eax
  800cfe:	89 f7                	mov    %esi,%edi
  800d00:	f7 f1                	div    %ecx
  800d02:	89 fa                	mov    %edi,%edx
  800d04:	83 c4 1c             	add    $0x1c,%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    
  800d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d10:	39 f2                	cmp    %esi,%edx
  800d12:	77 7c                	ja     800d90 <__udivdi3+0xd0>
  800d14:	0f bd fa             	bsr    %edx,%edi
  800d17:	83 f7 1f             	xor    $0x1f,%edi
  800d1a:	0f 84 98 00 00 00    	je     800db8 <__udivdi3+0xf8>
  800d20:	89 f9                	mov    %edi,%ecx
  800d22:	b8 20 00 00 00       	mov    $0x20,%eax
  800d27:	29 f8                	sub    %edi,%eax
  800d29:	d3 e2                	shl    %cl,%edx
  800d2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d2f:	89 c1                	mov    %eax,%ecx
  800d31:	89 da                	mov    %ebx,%edx
  800d33:	d3 ea                	shr    %cl,%edx
  800d35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d39:	09 d1                	or     %edx,%ecx
  800d3b:	89 f2                	mov    %esi,%edx
  800d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	d3 e3                	shl    %cl,%ebx
  800d45:	89 c1                	mov    %eax,%ecx
  800d47:	d3 ea                	shr    %cl,%edx
  800d49:	89 f9                	mov    %edi,%ecx
  800d4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d4f:	d3 e6                	shl    %cl,%esi
  800d51:	89 eb                	mov    %ebp,%ebx
  800d53:	89 c1                	mov    %eax,%ecx
  800d55:	d3 eb                	shr    %cl,%ebx
  800d57:	09 de                	or     %ebx,%esi
  800d59:	89 f0                	mov    %esi,%eax
  800d5b:	f7 74 24 08          	divl   0x8(%esp)
  800d5f:	89 d6                	mov    %edx,%esi
  800d61:	89 c3                	mov    %eax,%ebx
  800d63:	f7 64 24 0c          	mull   0xc(%esp)
  800d67:	39 d6                	cmp    %edx,%esi
  800d69:	72 0c                	jb     800d77 <__udivdi3+0xb7>
  800d6b:	89 f9                	mov    %edi,%ecx
  800d6d:	d3 e5                	shl    %cl,%ebp
  800d6f:	39 c5                	cmp    %eax,%ebp
  800d71:	73 5d                	jae    800dd0 <__udivdi3+0x110>
  800d73:	39 d6                	cmp    %edx,%esi
  800d75:	75 59                	jne    800dd0 <__udivdi3+0x110>
  800d77:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d7a:	31 ff                	xor    %edi,%edi
  800d7c:	89 fa                	mov    %edi,%edx
  800d7e:	83 c4 1c             	add    $0x1c,%esp
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
  800d86:	8d 76 00             	lea    0x0(%esi),%esi
  800d89:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d90:	31 ff                	xor    %edi,%edi
  800d92:	31 c0                	xor    %eax,%eax
  800d94:	89 fa                	mov    %edi,%edx
  800d96:	83 c4 1c             	add    $0x1c,%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    
  800d9e:	66 90                	xchg   %ax,%ax
  800da0:	31 ff                	xor    %edi,%edi
  800da2:	89 e8                	mov    %ebp,%eax
  800da4:	89 f2                	mov    %esi,%edx
  800da6:	f7 f3                	div    %ebx
  800da8:	89 fa                	mov    %edi,%edx
  800daa:	83 c4 1c             	add    $0x1c,%esp
  800dad:	5b                   	pop    %ebx
  800dae:	5e                   	pop    %esi
  800daf:	5f                   	pop    %edi
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    
  800db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800db8:	39 f2                	cmp    %esi,%edx
  800dba:	72 06                	jb     800dc2 <__udivdi3+0x102>
  800dbc:	31 c0                	xor    %eax,%eax
  800dbe:	39 eb                	cmp    %ebp,%ebx
  800dc0:	77 d2                	ja     800d94 <__udivdi3+0xd4>
  800dc2:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc7:	eb cb                	jmp    800d94 <__udivdi3+0xd4>
  800dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	89 d8                	mov    %ebx,%eax
  800dd2:	31 ff                	xor    %edi,%edi
  800dd4:	eb be                	jmp    800d94 <__udivdi3+0xd4>
  800dd6:	66 90                	xchg   %ax,%ax
  800dd8:	66 90                	xchg   %ax,%ax
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__umoddi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 1c             	sub    $0x1c,%esp
  800de7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800deb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800def:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800df3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800df7:	85 ed                	test   %ebp,%ebp
  800df9:	89 f0                	mov    %esi,%eax
  800dfb:	89 da                	mov    %ebx,%edx
  800dfd:	75 19                	jne    800e18 <__umoddi3+0x38>
  800dff:	39 df                	cmp    %ebx,%edi
  800e01:	0f 86 b1 00 00 00    	jbe    800eb8 <__umoddi3+0xd8>
  800e07:	f7 f7                	div    %edi
  800e09:	89 d0                	mov    %edx,%eax
  800e0b:	31 d2                	xor    %edx,%edx
  800e0d:	83 c4 1c             	add    $0x1c,%esp
  800e10:	5b                   	pop    %ebx
  800e11:	5e                   	pop    %esi
  800e12:	5f                   	pop    %edi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
  800e15:	8d 76 00             	lea    0x0(%esi),%esi
  800e18:	39 dd                	cmp    %ebx,%ebp
  800e1a:	77 f1                	ja     800e0d <__umoddi3+0x2d>
  800e1c:	0f bd cd             	bsr    %ebp,%ecx
  800e1f:	83 f1 1f             	xor    $0x1f,%ecx
  800e22:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e26:	0f 84 b4 00 00 00    	je     800ee0 <__umoddi3+0x100>
  800e2c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e31:	89 c2                	mov    %eax,%edx
  800e33:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e37:	29 c2                	sub    %eax,%edx
  800e39:	89 c1                	mov    %eax,%ecx
  800e3b:	89 f8                	mov    %edi,%eax
  800e3d:	d3 e5                	shl    %cl,%ebp
  800e3f:	89 d1                	mov    %edx,%ecx
  800e41:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e45:	d3 e8                	shr    %cl,%eax
  800e47:	09 c5                	or     %eax,%ebp
  800e49:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e4d:	89 c1                	mov    %eax,%ecx
  800e4f:	d3 e7                	shl    %cl,%edi
  800e51:	89 d1                	mov    %edx,%ecx
  800e53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e57:	89 df                	mov    %ebx,%edi
  800e59:	d3 ef                	shr    %cl,%edi
  800e5b:	89 c1                	mov    %eax,%ecx
  800e5d:	89 f0                	mov    %esi,%eax
  800e5f:	d3 e3                	shl    %cl,%ebx
  800e61:	89 d1                	mov    %edx,%ecx
  800e63:	89 fa                	mov    %edi,%edx
  800e65:	d3 e8                	shr    %cl,%eax
  800e67:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e6c:	09 d8                	or     %ebx,%eax
  800e6e:	f7 f5                	div    %ebp
  800e70:	d3 e6                	shl    %cl,%esi
  800e72:	89 d1                	mov    %edx,%ecx
  800e74:	f7 64 24 08          	mull   0x8(%esp)
  800e78:	39 d1                	cmp    %edx,%ecx
  800e7a:	89 c3                	mov    %eax,%ebx
  800e7c:	89 d7                	mov    %edx,%edi
  800e7e:	72 06                	jb     800e86 <__umoddi3+0xa6>
  800e80:	75 0e                	jne    800e90 <__umoddi3+0xb0>
  800e82:	39 c6                	cmp    %eax,%esi
  800e84:	73 0a                	jae    800e90 <__umoddi3+0xb0>
  800e86:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e8a:	19 ea                	sbb    %ebp,%edx
  800e8c:	89 d7                	mov    %edx,%edi
  800e8e:	89 c3                	mov    %eax,%ebx
  800e90:	89 ca                	mov    %ecx,%edx
  800e92:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e97:	29 de                	sub    %ebx,%esi
  800e99:	19 fa                	sbb    %edi,%edx
  800e9b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e9f:	89 d0                	mov    %edx,%eax
  800ea1:	d3 e0                	shl    %cl,%eax
  800ea3:	89 d9                	mov    %ebx,%ecx
  800ea5:	d3 ee                	shr    %cl,%esi
  800ea7:	d3 ea                	shr    %cl,%edx
  800ea9:	09 f0                	or     %esi,%eax
  800eab:	83 c4 1c             	add    $0x1c,%esp
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    
  800eb3:	90                   	nop
  800eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	85 ff                	test   %edi,%edi
  800eba:	89 f9                	mov    %edi,%ecx
  800ebc:	75 0b                	jne    800ec9 <__umoddi3+0xe9>
  800ebe:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	f7 f7                	div    %edi
  800ec7:	89 c1                	mov    %eax,%ecx
  800ec9:	89 d8                	mov    %ebx,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	f7 f1                	div    %ecx
  800ecf:	89 f0                	mov    %esi,%eax
  800ed1:	f7 f1                	div    %ecx
  800ed3:	e9 31 ff ff ff       	jmp    800e09 <__umoddi3+0x29>
  800ed8:	90                   	nop
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	39 dd                	cmp    %ebx,%ebp
  800ee2:	72 08                	jb     800eec <__umoddi3+0x10c>
  800ee4:	39 f7                	cmp    %esi,%edi
  800ee6:	0f 87 21 ff ff ff    	ja     800e0d <__umoddi3+0x2d>
  800eec:	89 da                	mov    %ebx,%edx
  800eee:	89 f0                	mov    %esi,%eax
  800ef0:	29 f8                	sub    %edi,%eax
  800ef2:	19 ea                	sbb    %ebp,%edx
  800ef4:	e9 14 ff ff ff       	jmp    800e0d <__umoddi3+0x2d>
