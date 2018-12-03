
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
#include <inc/lib.h>

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
  80005f:	8d 83 fc ee ff ff    	lea    -0x1104(%ebx),%eax
  800065:	50                   	push   %eax
  800066:	e8 3c 01 00 00       	call   8001a7 <cprintf>
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
  80007a:	57                   	push   %edi
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 0c             	sub    $0xc,%esp
  800080:	e8 ee ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800085:	81 c3 7b 1f 00 00    	add    $0x1f7b,%ebx
  80008b:	8b 75 08             	mov    0x8(%ebp),%esi
  80008e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800091:	e8 a0 0b 00 00       	call   800c36 <sys_getenvid>
  800096:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009b:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80009e:	c1 e0 05             	shl    $0x5,%eax
  8000a1:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  8000a7:	c7 c2 30 20 80 00    	mov    $0x802030,%edx
  8000ad:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000af:	85 f6                	test   %esi,%esi
  8000b1:	7e 08                	jle    8000bb <libmain+0x44>
		binaryname = argv[0];
  8000b3:	8b 07                	mov    (%edi),%eax
  8000b5:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	57                   	push   %edi
  8000bf:	56                   	push   %esi
  8000c0:	e8 6e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c5:	e8 0b 00 00 00       	call   8000d5 <exit>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 10             	sub    $0x10,%esp
  8000dc:	e8 92 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8000e1:	81 c3 1f 1f 00 00    	add    $0x1f1f,%ebx
	sys_env_destroy(0);
  8000e7:	6a 00                	push   $0x0
  8000e9:	e8 f3 0a 00 00       	call   800be1 <sys_env_destroy>
}
  8000ee:	83 c4 10             	add    $0x10,%esp
  8000f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f4:	c9                   	leave  
  8000f5:	c3                   	ret    

008000f6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	e8 73 ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800100:	81 c3 00 1f 00 00    	add    $0x1f00,%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800109:	8b 16                	mov    (%esi),%edx
  80010b:	8d 42 01             	lea    0x1(%edx),%eax
  80010e:	89 06                	mov    %eax,(%esi)
  800110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800113:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800117:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011c:	74 0b                	je     800129 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80011e:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	68 ff 00 00 00       	push   $0xff
  800131:	8d 46 08             	lea    0x8(%esi),%eax
  800134:	50                   	push   %eax
  800135:	e8 6a 0a 00 00       	call   800ba4 <sys_cputs>
		b->idx = 0;
  80013a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	eb d9                	jmp    80011e <putch+0x28>

00800145 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	53                   	push   %ebx
  800149:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80014f:	e8 1f ff ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800154:	81 c3 ac 1e 00 00    	add    $0x1eac,%ebx
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	8d 83 f6 e0 ff ff    	lea    -0x1f0a(%ebx),%eax
  800181:	50                   	push   %eax
  800182:	e8 38 01 00 00       	call   8002bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800187:	83 c4 08             	add    $0x8,%esp
  80018a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800190:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800196:	50                   	push   %eax
  800197:	e8 08 0a 00 00       	call   800ba4 <sys_cputs>
	return b.cnt;
}
  80019c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ad:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b0:	50                   	push   %eax
  8001b1:	ff 75 08             	pushl  0x8(%ebp)
  8001b4:	e8 8c ff ff ff       	call   800145 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	57                   	push   %edi
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 2c             	sub    $0x2c,%esp
  8001c4:	e8 63 06 00 00       	call   80082c <__x86.get_pc_thunk.cx>
  8001c9:	81 c1 37 1e 00 00    	add    $0x1e37,%ecx
  8001cf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001d2:	89 c7                	mov    %eax,%edi
  8001d4:	89 d6                	mov    %edx,%esi
  8001d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8001df:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ea:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8001ed:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8001f0:	39 d3                	cmp    %edx,%ebx
  8001f2:	72 09                	jb     8001fd <printnum+0x42>
  8001f4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f7:	0f 87 83 00 00 00    	ja     800280 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	ff 75 18             	pushl  0x18(%ebp)
  800203:	8b 45 14             	mov    0x14(%ebp),%eax
  800206:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800209:	53                   	push   %ebx
  80020a:	ff 75 10             	pushl  0x10(%ebp)
  80020d:	83 ec 08             	sub    $0x8,%esp
  800210:	ff 75 dc             	pushl  -0x24(%ebp)
  800213:	ff 75 d8             	pushl  -0x28(%ebp)
  800216:	ff 75 d4             	pushl  -0x2c(%ebp)
  800219:	ff 75 d0             	pushl  -0x30(%ebp)
  80021c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80021f:	e8 9c 0a 00 00       	call   800cc0 <__udivdi3>
  800224:	83 c4 18             	add    $0x18,%esp
  800227:	52                   	push   %edx
  800228:	50                   	push   %eax
  800229:	89 f2                	mov    %esi,%edx
  80022b:	89 f8                	mov    %edi,%eax
  80022d:	e8 89 ff ff ff       	call   8001bb <printnum>
  800232:	83 c4 20             	add    $0x20,%esp
  800235:	eb 13                	jmp    80024a <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	56                   	push   %esi
  80023b:	ff 75 18             	pushl  0x18(%ebp)
  80023e:	ff d7                	call   *%edi
  800240:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800243:	83 eb 01             	sub    $0x1,%ebx
  800246:	85 db                	test   %ebx,%ebx
  800248:	7f ed                	jg     800237 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	56                   	push   %esi
  80024e:	83 ec 04             	sub    $0x4,%esp
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	ff 75 d4             	pushl  -0x2c(%ebp)
  80025a:	ff 75 d0             	pushl  -0x30(%ebp)
  80025d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800260:	89 f3                	mov    %esi,%ebx
  800262:	e8 79 0b 00 00       	call   800de0 <__umoddi3>
  800267:	83 c4 14             	add    $0x14,%esp
  80026a:	0f be 84 06 14 ef ff 	movsbl -0x10ec(%esi,%eax,1),%eax
  800271:	ff 
  800272:	50                   	push   %eax
  800273:	ff d7                	call   *%edi
}
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5e                   	pop    %esi
  80027d:	5f                   	pop    %edi
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    
  800280:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800283:	eb be                	jmp    800243 <printnum+0x88>

00800285 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028f:	8b 10                	mov    (%eax),%edx
  800291:	3b 50 04             	cmp    0x4(%eax),%edx
  800294:	73 0a                	jae    8002a0 <sprintputch+0x1b>
		*b->buf++ = ch;
  800296:	8d 4a 01             	lea    0x1(%edx),%ecx
  800299:	89 08                	mov    %ecx,(%eax)
  80029b:	8b 45 08             	mov    0x8(%ebp),%eax
  80029e:	88 02                	mov    %al,(%edx)
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <printfmt>:
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ab:	50                   	push   %eax
  8002ac:	ff 75 10             	pushl  0x10(%ebp)
  8002af:	ff 75 0c             	pushl  0xc(%ebp)
  8002b2:	ff 75 08             	pushl  0x8(%ebp)
  8002b5:	e8 05 00 00 00       	call   8002bf <vprintfmt>
}
  8002ba:	83 c4 10             	add    $0x10,%esp
  8002bd:	c9                   	leave  
  8002be:	c3                   	ret    

008002bf <vprintfmt>:
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	57                   	push   %edi
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
  8002c5:	83 ec 2c             	sub    $0x2c,%esp
  8002c8:	e8 a6 fd ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8002cd:	81 c3 33 1d 00 00    	add    $0x1d33,%ebx
  8002d3:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8002d6:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8002dd:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002df:	8d 77 01             	lea    0x1(%edi),%esi
  8002e2:	0f b6 07             	movzbl (%edi),%eax
  8002e5:	83 f8 25             	cmp    $0x25,%eax
  8002e8:	74 1c                	je     800306 <vprintfmt+0x47>
			if (ch == '\0')
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 b9 04 00 00    	je     8007ab <.L21+0x20>
			putch(ch, putdat);
  8002f2:	83 ec 08             	sub    $0x8,%esp
  8002f5:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8002f8:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8002fb:	50                   	push   %eax
  8002fc:	ff 55 08             	call   *0x8(%ebp)
  8002ff:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800302:	89 f7                	mov    %esi,%edi
  800304:	eb d9                	jmp    8002df <vprintfmt+0x20>
		padc = ' ';
  800306:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  80030a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800311:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800318:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8d 7e 01             	lea    0x1(%esi),%edi
  80032a:	0f b6 16             	movzbl (%esi),%edx
  80032d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800330:	3c 55                	cmp    $0x55,%al
  800332:	0f 87 53 04 00 00    	ja     80078b <.L21>
  800338:	0f b6 c0             	movzbl %al,%eax
  80033b:	89 d9                	mov    %ebx,%ecx
  80033d:	03 8c 83 a4 ef ff ff 	add    -0x105c(%ebx,%eax,4),%ecx
  800344:	ff e1                	jmp    *%ecx

00800346 <.L73>:
  800346:	89 fe                	mov    %edi,%esi
			padc = '-';
  800348:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80034c:	eb d9                	jmp    800327 <vprintfmt+0x68>

0080034e <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  80034e:	89 fe                	mov    %edi,%esi
			padc = '0';
  800350:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800354:	eb d1                	jmp    800327 <vprintfmt+0x68>

00800356 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	0f b6 d2             	movzbl %dl,%edx
  800359:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  80035b:	b8 00 00 00 00       	mov    $0x0,%eax
  800360:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800363:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800366:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036a:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  80036d:	8d 7a d0             	lea    -0x30(%edx),%edi
  800370:	83 ff 09             	cmp    $0x9,%edi
  800373:	0f 87 94 00 00 00    	ja     80040d <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800379:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80037c:	eb e5                	jmp    800363 <.L28+0xd>

0080037e <.L25>:
			precision = va_arg(ap, int);
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8b 00                	mov    (%eax),%eax
  800383:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8d 40 04             	lea    0x4(%eax),%eax
  80038c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800391:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800395:	79 90                	jns    800327 <vprintfmt+0x68>
				width = precision, precision = -1;
  800397:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80039a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003a4:	eb 81                	jmp    800327 <vprintfmt+0x68>

008003a6 <.L26>:
  8003a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	0f 49 d0             	cmovns %eax,%edx
  8003b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	89 fe                	mov    %edi,%esi
  8003b8:	e9 6a ff ff ff       	jmp    800327 <vprintfmt+0x68>

008003bd <.L22>:
  8003bd:	89 fe                	mov    %edi,%esi
			altflag = 1;
  8003bf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c6:	e9 5c ff ff ff       	jmp    800327 <vprintfmt+0x68>

008003cb <.L33>:
  8003cb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8003ce:	83 f9 01             	cmp    $0x1,%ecx
  8003d1:	7e 16                	jle    8003e9 <.L33+0x1e>
		return va_arg(*ap, long long);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003db:	8d 49 08             	lea    0x8(%ecx),%ecx
  8003de:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8003e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8003e4:	e9 f6 fe ff ff       	jmp    8002df <vprintfmt+0x20>
	else if (lflag)
  8003e9:	85 c9                	test   %ecx,%ecx
  8003eb:	75 10                	jne    8003fd <.L33+0x32>
		return va_arg(*ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8b 00                	mov    (%eax),%eax
  8003f2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003f5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8003f8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fb:	eb e4                	jmp    8003e1 <.L33+0x16>
		return va_arg(*ap, long);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8b 00                	mov    (%eax),%eax
  800402:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800405:	8d 49 04             	lea    0x4(%ecx),%ecx
  800408:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040b:	eb d4                	jmp    8003e1 <.L33+0x16>
  80040d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800410:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800413:	e9 79 ff ff ff       	jmp    800391 <.L25+0x13>

00800418 <.L32>:
			lflag++;
  800418:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	89 fe                	mov    %edi,%esi
			goto reswitch;
  80041e:	e9 04 ff ff ff       	jmp    800327 <vprintfmt+0x68>

00800423 <.L29>:
			putch(va_arg(ap, int), putdat);
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 70 04             	lea    0x4(%eax),%esi
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	ff 75 0c             	pushl  0xc(%ebp)
  80042f:	ff 30                	pushl  (%eax)
  800431:	ff 55 08             	call   *0x8(%ebp)
			break;
  800434:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800437:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  80043a:	e9 a0 fe ff ff       	jmp    8002df <vprintfmt+0x20>

0080043f <.L31>:
			err = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 70 04             	lea    0x4(%eax),%esi
  800445:	8b 00                	mov    (%eax),%eax
  800447:	99                   	cltd   
  800448:	31 d0                	xor    %edx,%eax
  80044a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044c:	83 f8 06             	cmp    $0x6,%eax
  80044f:	7f 29                	jg     80047a <.L31+0x3b>
  800451:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800458:	85 d2                	test   %edx,%edx
  80045a:	74 1e                	je     80047a <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  80045c:	52                   	push   %edx
  80045d:	8d 83 35 ef ff ff    	lea    -0x10cb(%ebx),%eax
  800463:	50                   	push   %eax
  800464:	ff 75 0c             	pushl  0xc(%ebp)
  800467:	ff 75 08             	pushl  0x8(%ebp)
  80046a:	e8 33 fe ff ff       	call   8002a2 <printfmt>
  80046f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800472:	89 75 14             	mov    %esi,0x14(%ebp)
  800475:	e9 65 fe ff ff       	jmp    8002df <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  80047a:	50                   	push   %eax
  80047b:	8d 83 2c ef ff ff    	lea    -0x10d4(%ebx),%eax
  800481:	50                   	push   %eax
  800482:	ff 75 0c             	pushl  0xc(%ebp)
  800485:	ff 75 08             	pushl  0x8(%ebp)
  800488:	e8 15 fe ff ff       	call   8002a2 <printfmt>
  80048d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800490:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800493:	e9 47 fe ff ff       	jmp    8002df <vprintfmt+0x20>

00800498 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	83 c0 04             	add    $0x4,%eax
  80049e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8004a6:	85 f6                	test   %esi,%esi
  8004a8:	8d 83 25 ef ff ff    	lea    -0x10db(%ebx),%eax
  8004ae:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8004b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b5:	0f 8e b4 00 00 00    	jle    80056f <.L36+0xd7>
  8004bb:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8004bf:	75 08                	jne    8004c9 <.L36+0x31>
  8004c1:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004c7:	eb 6c                	jmp    800535 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 cc             	pushl  -0x34(%ebp)
  8004cf:	56                   	push   %esi
  8004d0:	e8 73 03 00 00       	call   800848 <strnlen>
  8004d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d8:	29 c2                	sub    %eax,%edx
  8004da:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004dd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e0:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8004e4:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004e7:	89 d6                	mov    %edx,%esi
  8004e9:	89 7d 10             	mov    %edi,0x10(%ebp)
  8004ec:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	eb 10                	jmp    800500 <.L36+0x68>
					putch(padc, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 0c             	pushl  0xc(%ebp)
  8004f6:	57                   	push   %edi
  8004f7:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fa:	83 ee 01             	sub    $0x1,%esi
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 f6                	test   %esi,%esi
  800502:	7f ec                	jg     8004f0 <.L36+0x58>
  800504:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800507:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80050a:	85 d2                	test   %edx,%edx
  80050c:	b8 00 00 00 00       	mov    $0x0,%eax
  800511:	0f 49 c2             	cmovns %edx,%eax
  800514:	29 c2                	sub    %eax,%edx
  800516:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800519:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80051c:	eb 17                	jmp    800535 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  80051e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800522:	75 30                	jne    800554 <.L36+0xbc>
					putch(ch, putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	ff 75 0c             	pushl  0xc(%ebp)
  80052a:	50                   	push   %eax
  80052b:	ff 55 08             	call   *0x8(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800531:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800535:	83 c6 01             	add    $0x1,%esi
  800538:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80053c:	0f be c2             	movsbl %dl,%eax
  80053f:	85 c0                	test   %eax,%eax
  800541:	74 58                	je     80059b <.L36+0x103>
  800543:	85 ff                	test   %edi,%edi
  800545:	78 d7                	js     80051e <.L36+0x86>
  800547:	83 ef 01             	sub    $0x1,%edi
  80054a:	79 d2                	jns    80051e <.L36+0x86>
  80054c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80054f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800552:	eb 32                	jmp    800586 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800554:	0f be d2             	movsbl %dl,%edx
  800557:	83 ea 20             	sub    $0x20,%edx
  80055a:	83 fa 5e             	cmp    $0x5e,%edx
  80055d:	76 c5                	jbe    800524 <.L36+0x8c>
					putch('?', putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 0c             	pushl  0xc(%ebp)
  800565:	6a 3f                	push   $0x3f
  800567:	ff 55 08             	call   *0x8(%ebp)
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	eb c2                	jmp    800531 <.L36+0x99>
  80056f:	89 7d 10             	mov    %edi,0x10(%ebp)
  800572:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800575:	eb be                	jmp    800535 <.L36+0x9d>
				putch(' ', putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	57                   	push   %edi
  80057b:	6a 20                	push   $0x20
  80057d:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800580:	83 ee 01             	sub    $0x1,%esi
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	85 f6                	test   %esi,%esi
  800588:	7f ed                	jg     800577 <.L36+0xdf>
  80058a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80058d:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800590:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
  800596:	e9 44 fd ff ff       	jmp    8002df <vprintfmt+0x20>
  80059b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80059e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8005a1:	eb e3                	jmp    800586 <.L36+0xee>

008005a3 <.L30>:
  8005a3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8005a6:	83 f9 01             	cmp    $0x1,%ecx
  8005a9:	7e 42                	jle    8005ed <.L30+0x4a>
		return va_arg(*ap, long long);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8b 50 04             	mov    0x4(%eax),%edx
  8005b1:	8b 00                	mov    (%eax),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 40 08             	lea    0x8(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005c2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c6:	79 5f                	jns    800627 <.L30+0x84>
				putch('-', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	ff 75 0c             	pushl  0xc(%ebp)
  8005ce:	6a 2d                	push   $0x2d
  8005d0:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005d3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d9:	f7 da                	neg    %edx
  8005db:	83 d1 00             	adc    $0x0,%ecx
  8005de:	f7 d9                	neg    %ecx
  8005e0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e8:	e9 b8 00 00 00       	jmp    8006a5 <.L34+0x22>
	else if (lflag)
  8005ed:	85 c9                	test   %ecx,%ecx
  8005ef:	75 1b                	jne    80060c <.L30+0x69>
		return va_arg(*ap, int);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8b 30                	mov    (%eax),%esi
  8005f6:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005f9:	89 f0                	mov    %esi,%eax
  8005fb:	c1 f8 1f             	sar    $0x1f,%eax
  8005fe:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 40 04             	lea    0x4(%eax),%eax
  800607:	89 45 14             	mov    %eax,0x14(%ebp)
  80060a:	eb b6                	jmp    8005c2 <.L30+0x1f>
		return va_arg(*ap, long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 30                	mov    (%eax),%esi
  800611:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800614:	89 f0                	mov    %esi,%eax
  800616:	c1 f8 1f             	sar    $0x1f,%eax
  800619:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
  800625:	eb 9b                	jmp    8005c2 <.L30+0x1f>
			num = getint(&ap, lflag);
  800627:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80062d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800632:	eb 71                	jmp    8006a5 <.L34+0x22>

00800634 <.L37>:
  800634:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800637:	83 f9 01             	cmp    $0x1,%ecx
  80063a:	7e 15                	jle    800651 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	8b 48 04             	mov    0x4(%eax),%ecx
  800644:	8d 40 08             	lea    0x8(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064f:	eb 54                	jmp    8006a5 <.L34+0x22>
	else if (lflag)
  800651:	85 c9                	test   %ecx,%ecx
  800653:	75 17                	jne    80066c <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 10                	mov    (%eax),%edx
  80065a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065f:	8d 40 04             	lea    0x4(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800665:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066a:	eb 39                	jmp    8006a5 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80067c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800681:	eb 22                	jmp    8006a5 <.L34+0x22>

00800683 <.L34>:
  800683:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800686:	83 f9 01             	cmp    $0x1,%ecx
  800689:	7e 3b                	jle    8006c6 <.L34+0x43>
		return va_arg(*ap, long long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 50 04             	mov    0x4(%eax),%edx
  800691:	8b 00                	mov    (%eax),%eax
  800693:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800696:	8d 49 08             	lea    0x8(%ecx),%ecx
  800699:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80069c:	89 d1                	mov    %edx,%ecx
  80069e:	89 c2                	mov    %eax,%edx
			base = 8;
  8006a0:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006a5:	83 ec 0c             	sub    $0xc,%esp
  8006a8:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  8006ac:	56                   	push   %esi
  8006ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b0:	50                   	push   %eax
  8006b1:	51                   	push   %ecx
  8006b2:	52                   	push   %edx
  8006b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b9:	e8 fd fa ff ff       	call   8001bb <printnum>
			break;
  8006be:	83 c4 20             	add    $0x20,%esp
  8006c1:	e9 19 fc ff ff       	jmp    8002df <vprintfmt+0x20>
	else if (lflag)
  8006c6:	85 c9                	test   %ecx,%ecx
  8006c8:	75 13                	jne    8006dd <.L34+0x5a>
		return va_arg(*ap, int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	89 d0                	mov    %edx,%eax
  8006d1:	99                   	cltd   
  8006d2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006d5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006d8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006db:	eb bf                	jmp    80069c <.L34+0x19>
		return va_arg(*ap, long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	89 d0                	mov    %edx,%eax
  8006e4:	99                   	cltd   
  8006e5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8006e8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8006eb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006ee:	eb ac                	jmp    80069c <.L34+0x19>

008006f0 <.L35>:
			putch('0', putdat);
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	ff 75 0c             	pushl  0xc(%ebp)
  8006f6:	6a 30                	push   $0x30
  8006f8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006fb:	83 c4 08             	add    $0x8,%esp
  8006fe:	ff 75 0c             	pushl  0xc(%ebp)
  800701:	6a 78                	push   $0x78
  800703:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800710:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800713:	8d 40 04             	lea    0x4(%eax),%eax
  800716:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800719:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80071e:	eb 85                	jmp    8006a5 <.L34+0x22>

00800720 <.L38>:
  800720:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800723:	83 f9 01             	cmp    $0x1,%ecx
  800726:	7e 18                	jle    800740 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	8b 48 04             	mov    0x4(%eax),%ecx
  800730:	8d 40 08             	lea    0x8(%eax),%eax
  800733:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800736:	b8 10 00 00 00       	mov    $0x10,%eax
  80073b:	e9 65 ff ff ff       	jmp    8006a5 <.L34+0x22>
	else if (lflag)
  800740:	85 c9                	test   %ecx,%ecx
  800742:	75 1a                	jne    80075e <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8b 10                	mov    (%eax),%edx
  800749:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074e:	8d 40 04             	lea    0x4(%eax),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800754:	b8 10 00 00 00       	mov    $0x10,%eax
  800759:	e9 47 ff ff ff       	jmp    8006a5 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 10                	mov    (%eax),%edx
  800763:	b9 00 00 00 00       	mov    $0x0,%ecx
  800768:	8d 40 04             	lea    0x4(%eax),%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076e:	b8 10 00 00 00       	mov    $0x10,%eax
  800773:	e9 2d ff ff ff       	jmp    8006a5 <.L34+0x22>

00800778 <.L24>:
			putch(ch, putdat);
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	ff 75 0c             	pushl  0xc(%ebp)
  80077e:	6a 25                	push   $0x25
  800780:	ff 55 08             	call   *0x8(%ebp)
			break;
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	e9 54 fb ff ff       	jmp    8002df <vprintfmt+0x20>

0080078b <.L21>:
			putch('%', putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	ff 75 0c             	pushl  0xc(%ebp)
  800791:	6a 25                	push   $0x25
  800793:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	89 f7                	mov    %esi,%edi
  80079b:	eb 03                	jmp    8007a0 <.L21+0x15>
  80079d:	83 ef 01             	sub    $0x1,%edi
  8007a0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a4:	75 f7                	jne    80079d <.L21+0x12>
  8007a6:	e9 34 fb ff ff       	jmp    8002df <vprintfmt+0x20>
}
  8007ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5f                   	pop    %edi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	83 ec 14             	sub    $0x14,%esp
  8007ba:	e8 b4 f8 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  8007bf:	81 c3 41 18 00 00    	add    $0x1841,%ebx
  8007c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	74 2b                	je     80080b <vsnprintf+0x58>
  8007e0:	85 d2                	test   %edx,%edx
  8007e2:	7e 27                	jle    80080b <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e4:	ff 75 14             	pushl  0x14(%ebp)
  8007e7:	ff 75 10             	pushl  0x10(%ebp)
  8007ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ed:	50                   	push   %eax
  8007ee:	8d 83 85 e2 ff ff    	lea    -0x1d7b(%ebx),%eax
  8007f4:	50                   	push   %eax
  8007f5:	e8 c5 fa ff ff       	call   8002bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800800:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800803:	83 c4 10             	add    $0x10,%esp
}
  800806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    
		return -E_INVAL;
  80080b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800810:	eb f4                	jmp    800806 <vsnprintf+0x53>

00800812 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80081b:	50                   	push   %eax
  80081c:	ff 75 10             	pushl  0x10(%ebp)
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	ff 75 08             	pushl  0x8(%ebp)
  800825:	e8 89 ff ff ff       	call   8007b3 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <__x86.get_pc_thunk.cx>:
  80082c:	8b 0c 24             	mov    (%esp),%ecx
  80082f:	c3                   	ret    

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 03                	jmp    800840 <strlen+0x10>
		n++;
  80083d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800844:	75 f7                	jne    80083d <strlen+0xd>
	return n;
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800851:	b8 00 00 00 00       	mov    $0x0,%eax
  800856:	eb 03                	jmp    80085b <strnlen+0x13>
		n++;
  800858:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085b:	39 d0                	cmp    %edx,%eax
  80085d:	74 06                	je     800865 <strnlen+0x1d>
  80085f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800863:	75 f3                	jne    800858 <strnlen+0x10>
	return n;
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800871:	89 c2                	mov    %eax,%edx
  800873:	83 c1 01             	add    $0x1,%ecx
  800876:	83 c2 01             	add    $0x1,%edx
  800879:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80087d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800880:	84 db                	test   %bl,%bl
  800882:	75 ef                	jne    800873 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800884:	5b                   	pop    %ebx
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80088e:	53                   	push   %ebx
  80088f:	e8 9c ff ff ff       	call   800830 <strlen>
  800894:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800897:	ff 75 0c             	pushl  0xc(%ebp)
  80089a:	01 d8                	add    %ebx,%eax
  80089c:	50                   	push   %eax
  80089d:	e8 c5 ff ff ff       	call   800867 <strcpy>
	return dst;
}
  8008a2:	89 d8                	mov    %ebx,%eax
  8008a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    

008008a9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	56                   	push   %esi
  8008ad:	53                   	push   %ebx
  8008ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b4:	89 f3                	mov    %esi,%ebx
  8008b6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	89 f2                	mov    %esi,%edx
  8008bb:	eb 0f                	jmp    8008cc <strncpy+0x23>
		*dst++ = *src;
  8008bd:	83 c2 01             	add    $0x1,%edx
  8008c0:	0f b6 01             	movzbl (%ecx),%eax
  8008c3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c6:	80 39 01             	cmpb   $0x1,(%ecx)
  8008c9:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8008cc:	39 da                	cmp    %ebx,%edx
  8008ce:	75 ed                	jne    8008bd <strncpy+0x14>
	}
	return ret;
}
  8008d0:	89 f0                	mov    %esi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008e4:	89 f0                	mov    %esi,%eax
  8008e6:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ea:	85 c9                	test   %ecx,%ecx
  8008ec:	75 0b                	jne    8008f9 <strlcpy+0x23>
  8008ee:	eb 17                	jmp    800907 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008f9:	39 d8                	cmp    %ebx,%eax
  8008fb:	74 07                	je     800904 <strlcpy+0x2e>
  8008fd:	0f b6 0a             	movzbl (%edx),%ecx
  800900:	84 c9                	test   %cl,%cl
  800902:	75 ec                	jne    8008f0 <strlcpy+0x1a>
		*dst = '\0';
  800904:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800907:	29 f0                	sub    %esi,%eax
}
  800909:	5b                   	pop    %ebx
  80090a:	5e                   	pop    %esi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800916:	eb 06                	jmp    80091e <strcmp+0x11>
		p++, q++;
  800918:	83 c1 01             	add    $0x1,%ecx
  80091b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80091e:	0f b6 01             	movzbl (%ecx),%eax
  800921:	84 c0                	test   %al,%al
  800923:	74 04                	je     800929 <strcmp+0x1c>
  800925:	3a 02                	cmp    (%edx),%al
  800927:	74 ef                	je     800918 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800929:	0f b6 c0             	movzbl %al,%eax
  80092c:	0f b6 12             	movzbl (%edx),%edx
  80092f:	29 d0                	sub    %edx,%eax
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	53                   	push   %ebx
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093d:	89 c3                	mov    %eax,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800942:	eb 06                	jmp    80094a <strncmp+0x17>
		n--, p++, q++;
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80094a:	39 d8                	cmp    %ebx,%eax
  80094c:	74 16                	je     800964 <strncmp+0x31>
  80094e:	0f b6 08             	movzbl (%eax),%ecx
  800951:	84 c9                	test   %cl,%cl
  800953:	74 04                	je     800959 <strncmp+0x26>
  800955:	3a 0a                	cmp    (%edx),%cl
  800957:	74 eb                	je     800944 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800959:	0f b6 00             	movzbl (%eax),%eax
  80095c:	0f b6 12             	movzbl (%edx),%edx
  80095f:	29 d0                	sub    %edx,%eax
}
  800961:	5b                   	pop    %ebx
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    
		return 0;
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
  800969:	eb f6                	jmp    800961 <strncmp+0x2e>

0080096b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	74 09                	je     800985 <strchr+0x1a>
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	74 0a                	je     80098a <strchr+0x1f>
	for (; *s; s++)
  800980:	83 c0 01             	add    $0x1,%eax
  800983:	eb f0                	jmp    800975 <strchr+0xa>
			return (char *) s;
	return 0;
  800985:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800996:	eb 03                	jmp    80099b <strfind+0xf>
  800998:	83 c0 01             	add    $0x1,%eax
  80099b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80099e:	38 ca                	cmp    %cl,%dl
  8009a0:	74 04                	je     8009a6 <strfind+0x1a>
  8009a2:	84 d2                	test   %dl,%dl
  8009a4:	75 f2                	jne    800998 <strfind+0xc>
			break;
	return (char *) s;
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	57                   	push   %edi
  8009ac:	56                   	push   %esi
  8009ad:	53                   	push   %ebx
  8009ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b4:	85 c9                	test   %ecx,%ecx
  8009b6:	74 13                	je     8009cb <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009be:	75 05                	jne    8009c5 <memset+0x1d>
  8009c0:	f6 c1 03             	test   $0x3,%cl
  8009c3:	74 0d                	je     8009d2 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c8:	fc                   	cld    
  8009c9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009cb:	89 f8                	mov    %edi,%eax
  8009cd:	5b                   	pop    %ebx
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    
		c &= 0xFF;
  8009d2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d6:	89 d3                	mov    %edx,%ebx
  8009d8:	c1 e3 08             	shl    $0x8,%ebx
  8009db:	89 d0                	mov    %edx,%eax
  8009dd:	c1 e0 18             	shl    $0x18,%eax
  8009e0:	89 d6                	mov    %edx,%esi
  8009e2:	c1 e6 10             	shl    $0x10,%esi
  8009e5:	09 f0                	or     %esi,%eax
  8009e7:	09 c2                	or     %eax,%edx
  8009e9:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009eb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ee:	89 d0                	mov    %edx,%eax
  8009f0:	fc                   	cld    
  8009f1:	f3 ab                	rep stos %eax,%es:(%edi)
  8009f3:	eb d6                	jmp    8009cb <memset+0x23>

008009f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	57                   	push   %edi
  8009f9:	56                   	push   %esi
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a03:	39 c6                	cmp    %eax,%esi
  800a05:	73 35                	jae    800a3c <memmove+0x47>
  800a07:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0a:	39 c2                	cmp    %eax,%edx
  800a0c:	76 2e                	jbe    800a3c <memmove+0x47>
		s += n;
		d += n;
  800a0e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a11:	89 d6                	mov    %edx,%esi
  800a13:	09 fe                	or     %edi,%esi
  800a15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a1b:	74 0c                	je     800a29 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1d:	83 ef 01             	sub    $0x1,%edi
  800a20:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a23:	fd                   	std    
  800a24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a26:	fc                   	cld    
  800a27:	eb 21                	jmp    800a4a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a29:	f6 c1 03             	test   $0x3,%cl
  800a2c:	75 ef                	jne    800a1d <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a2e:	83 ef 04             	sub    $0x4,%edi
  800a31:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a34:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a37:	fd                   	std    
  800a38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3a:	eb ea                	jmp    800a26 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3c:	89 f2                	mov    %esi,%edx
  800a3e:	09 c2                	or     %eax,%edx
  800a40:	f6 c2 03             	test   $0x3,%dl
  800a43:	74 09                	je     800a4e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a45:	89 c7                	mov    %eax,%edi
  800a47:	fc                   	cld    
  800a48:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 f2                	jne    800a45 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a53:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a56:	89 c7                	mov    %eax,%edi
  800a58:	fc                   	cld    
  800a59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5b:	eb ed                	jmp    800a4a <memmove+0x55>

00800a5d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a60:	ff 75 10             	pushl  0x10(%ebp)
  800a63:	ff 75 0c             	pushl  0xc(%ebp)
  800a66:	ff 75 08             	pushl  0x8(%ebp)
  800a69:	e8 87 ff ff ff       	call   8009f5 <memmove>
}
  800a6e:	c9                   	leave  
  800a6f:	c3                   	ret    

00800a70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7b:	89 c6                	mov    %eax,%esi
  800a7d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a80:	39 f0                	cmp    %esi,%eax
  800a82:	74 1c                	je     800aa0 <memcmp+0x30>
		if (*s1 != *s2)
  800a84:	0f b6 08             	movzbl (%eax),%ecx
  800a87:	0f b6 1a             	movzbl (%edx),%ebx
  800a8a:	38 d9                	cmp    %bl,%cl
  800a8c:	75 08                	jne    800a96 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	83 c2 01             	add    $0x1,%edx
  800a94:	eb ea                	jmp    800a80 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a96:	0f b6 c1             	movzbl %cl,%eax
  800a99:	0f b6 db             	movzbl %bl,%ebx
  800a9c:	29 d8                	sub    %ebx,%eax
  800a9e:	eb 05                	jmp    800aa5 <memcmp+0x35>
	}

	return 0;
  800aa0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab7:	39 d0                	cmp    %edx,%eax
  800ab9:	73 09                	jae    800ac4 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abb:	38 08                	cmp    %cl,(%eax)
  800abd:	74 05                	je     800ac4 <memfind+0x1b>
	for (; s < ends; s++)
  800abf:	83 c0 01             	add    $0x1,%eax
  800ac2:	eb f3                	jmp    800ab7 <memfind+0xe>
			break;
	return (void *) s;
}
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	53                   	push   %ebx
  800acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad2:	eb 03                	jmp    800ad7 <strtol+0x11>
		s++;
  800ad4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ad7:	0f b6 01             	movzbl (%ecx),%eax
  800ada:	3c 20                	cmp    $0x20,%al
  800adc:	74 f6                	je     800ad4 <strtol+0xe>
  800ade:	3c 09                	cmp    $0x9,%al
  800ae0:	74 f2                	je     800ad4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ae2:	3c 2b                	cmp    $0x2b,%al
  800ae4:	74 2e                	je     800b14 <strtol+0x4e>
	int neg = 0;
  800ae6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aeb:	3c 2d                	cmp    $0x2d,%al
  800aed:	74 2f                	je     800b1e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aef:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800af5:	75 05                	jne    800afc <strtol+0x36>
  800af7:	80 39 30             	cmpb   $0x30,(%ecx)
  800afa:	74 2c                	je     800b28 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800afc:	85 db                	test   %ebx,%ebx
  800afe:	75 0a                	jne    800b0a <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b00:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b05:	80 39 30             	cmpb   $0x30,(%ecx)
  800b08:	74 28                	je     800b32 <strtol+0x6c>
		base = 10;
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b12:	eb 50                	jmp    800b64 <strtol+0x9e>
		s++;
  800b14:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b17:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1c:	eb d1                	jmp    800aef <strtol+0x29>
		s++, neg = 1;
  800b1e:	83 c1 01             	add    $0x1,%ecx
  800b21:	bf 01 00 00 00       	mov    $0x1,%edi
  800b26:	eb c7                	jmp    800aef <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b28:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2c:	74 0e                	je     800b3c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b2e:	85 db                	test   %ebx,%ebx
  800b30:	75 d8                	jne    800b0a <strtol+0x44>
		s++, base = 8;
  800b32:	83 c1 01             	add    $0x1,%ecx
  800b35:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b3a:	eb ce                	jmp    800b0a <strtol+0x44>
		s += 2, base = 16;
  800b3c:	83 c1 02             	add    $0x2,%ecx
  800b3f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b44:	eb c4                	jmp    800b0a <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b46:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b49:	89 f3                	mov    %esi,%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 29                	ja     800b79 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b50:	0f be d2             	movsbl %dl,%edx
  800b53:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b56:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b59:	7d 30                	jge    800b8b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b5b:	83 c1 01             	add    $0x1,%ecx
  800b5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b62:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b64:	0f b6 11             	movzbl (%ecx),%edx
  800b67:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b6a:	89 f3                	mov    %esi,%ebx
  800b6c:	80 fb 09             	cmp    $0x9,%bl
  800b6f:	77 d5                	ja     800b46 <strtol+0x80>
			dig = *s - '0';
  800b71:	0f be d2             	movsbl %dl,%edx
  800b74:	83 ea 30             	sub    $0x30,%edx
  800b77:	eb dd                	jmp    800b56 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b79:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7c:	89 f3                	mov    %esi,%ebx
  800b7e:	80 fb 19             	cmp    $0x19,%bl
  800b81:	77 08                	ja     800b8b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b83:	0f be d2             	movsbl %dl,%edx
  800b86:	83 ea 37             	sub    $0x37,%edx
  800b89:	eb cb                	jmp    800b56 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b8f:	74 05                	je     800b96 <strtol+0xd0>
		*endptr = (char *) s;
  800b91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b94:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b96:	89 c2                	mov    %eax,%edx
  800b98:	f7 da                	neg    %edx
  800b9a:	85 ff                	test   %edi,%edi
  800b9c:	0f 45 c2             	cmovne %edx,%eax
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb5:	89 c3                	mov    %eax,%ebx
  800bb7:	89 c7                	mov    %eax,%edi
  800bb9:	89 c6                	mov    %eax,%esi
  800bbb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 01 00 00 00       	mov    $0x1,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 1c             	sub    $0x1c,%esp
  800bea:	e8 66 00 00 00       	call   800c55 <__x86.get_pc_thunk.ax>
  800bef:	05 11 14 00 00       	add    $0x1411,%eax
  800bf4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800bf7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bff:	b8 03 00 00 00       	mov    $0x3,%eax
  800c04:	89 cb                	mov    %ecx,%ebx
  800c06:	89 cf                	mov    %ecx,%edi
  800c08:	89 ce                	mov    %ecx,%esi
  800c0a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	7f 08                	jg     800c18 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c18:	83 ec 0c             	sub    $0xc,%esp
  800c1b:	50                   	push   %eax
  800c1c:	6a 03                	push   $0x3
  800c1e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c21:	8d 83 fc f0 ff ff    	lea    -0xf04(%ebx),%eax
  800c27:	50                   	push   %eax
  800c28:	6a 26                	push   $0x26
  800c2a:	8d 83 19 f1 ff ff    	lea    -0xee7(%ebx),%eax
  800c30:	50                   	push   %eax
  800c31:	e8 23 00 00 00       	call   800c59 <_panic>

00800c36 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 02 00 00 00       	mov    $0x2,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <__x86.get_pc_thunk.ax>:
  800c55:	8b 04 24             	mov    (%esp),%eax
  800c58:	c3                   	ret    

00800c59 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	e8 0c f4 ff ff       	call   800073 <__x86.get_pc_thunk.bx>
  800c67:	81 c3 99 13 00 00    	add    $0x1399,%ebx
	va_list ap;

	va_start(ap, fmt);
  800c6d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c70:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800c76:	8b 38                	mov    (%eax),%edi
  800c78:	e8 b9 ff ff ff       	call   800c36 <sys_getenvid>
  800c7d:	83 ec 0c             	sub    $0xc,%esp
  800c80:	ff 75 0c             	pushl  0xc(%ebp)
  800c83:	ff 75 08             	pushl  0x8(%ebp)
  800c86:	57                   	push   %edi
  800c87:	50                   	push   %eax
  800c88:	8d 83 28 f1 ff ff    	lea    -0xed8(%ebx),%eax
  800c8e:	50                   	push   %eax
  800c8f:	e8 13 f5 ff ff       	call   8001a7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800c94:	83 c4 18             	add    $0x18,%esp
  800c97:	56                   	push   %esi
  800c98:	ff 75 10             	pushl  0x10(%ebp)
  800c9b:	e8 a5 f4 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  800ca0:	8d 83 08 ef ff ff    	lea    -0x10f8(%ebx),%eax
  800ca6:	89 04 24             	mov    %eax,(%esp)
  800ca9:	e8 f9 f4 ff ff       	call   8001a7 <cprintf>
  800cae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cb1:	cc                   	int3   
  800cb2:	eb fd                	jmp    800cb1 <_panic+0x58>
  800cb4:	66 90                	xchg   %ax,%ax
  800cb6:	66 90                	xchg   %ax,%ax
  800cb8:	66 90                	xchg   %ax,%ax
  800cba:	66 90                	xchg   %ax,%ax
  800cbc:	66 90                	xchg   %ax,%ax
  800cbe:	66 90                	xchg   %ax,%ax

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
