
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 29 00 00 00       	call   80005a <libmain>
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
  80003a:	e8 17 00 00 00       	call   800056 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs((char*)1, 1);
  800045:	6a 01                	push   $0x1
  800047:	6a 01                	push   $0x1
  800049:	e8 74 00 00 00       	call   8000c2 <sys_cputs>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <__x86.get_pc_thunk.bx>:
  800056:	8b 1c 24             	mov    (%esp),%ebx
  800059:	c3                   	ret    

0080005a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005a:	55                   	push   %ebp
  80005b:	89 e5                	mov    %esp,%ebp
  80005d:	53                   	push   %ebx
  80005e:	83 ec 04             	sub    $0x4,%esp
  800061:	e8 f0 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800066:	81 c3 9a 1f 00 00    	add    $0x1f9a,%ebx
  80006c:	8b 45 08             	mov    0x8(%ebp),%eax
  80006f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800072:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800078:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 c0                	test   %eax,%eax
  800080:	7e 08                	jle    80008a <libmain+0x30>
		binaryname = argv[0];
  800082:	8b 0a                	mov    (%edx),%ecx
  800084:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80008a:	83 ec 08             	sub    $0x8,%esp
  80008d:	52                   	push   %edx
  80008e:	50                   	push   %eax
  80008f:	e8 9f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800094:	e8 08 00 00 00       	call   8000a1 <exit>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009f:	c9                   	leave  
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	53                   	push   %ebx
  8000a5:	83 ec 10             	sub    $0x10,%esp
  8000a8:	e8 a9 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8000ad:	81 c3 53 1f 00 00    	add    $0x1f53,%ebx
	sys_env_destroy(0);
  8000b3:	6a 00                	push   $0x0
  8000b5:	e8 45 00 00 00       	call   8000ff <sys_env_destroy>
}
  8000ba:	83 c4 10             	add    $0x10,%esp
  8000bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	89 c3                	mov    %eax,%ebx
  8000d5:	89 c7                	mov    %eax,%edi
  8000d7:	89 c6                	mov    %eax,%esi
  8000d9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f0:	89 d1                	mov    %edx,%ecx
  8000f2:	89 d3                	mov    %edx,%ebx
  8000f4:	89 d7                	mov    %edx,%edi
  8000f6:	89 d6                	mov    %edx,%esi
  8000f8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	83 ec 1c             	sub    $0x1c,%esp
  800108:	e8 66 00 00 00       	call   800173 <__x86.get_pc_thunk.ax>
  80010d:	05 f3 1e 00 00       	add    $0x1ef3,%eax
  800112:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800115:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011a:	8b 55 08             	mov    0x8(%ebp),%edx
  80011d:	b8 03 00 00 00       	mov    $0x3,%eax
  800122:	89 cb                	mov    %ecx,%ebx
  800124:	89 cf                	mov    %ecx,%edi
  800126:	89 ce                	mov    %ecx,%esi
  800128:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f 08                	jg     800136 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	6a 03                	push   $0x3
  80013c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013f:	8d 83 c6 ee ff ff    	lea    -0x113a(%ebx),%eax
  800145:	50                   	push   %eax
  800146:	6a 23                	push   $0x23
  800148:	8d 83 e3 ee ff ff    	lea    -0x111d(%ebx),%eax
  80014e:	50                   	push   %eax
  80014f:	e8 23 00 00 00       	call   800177 <_panic>

00800154 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015a:	ba 00 00 00 00       	mov    $0x0,%edx
  80015f:	b8 02 00 00 00       	mov    $0x2,%eax
  800164:	89 d1                	mov    %edx,%ecx
  800166:	89 d3                	mov    %edx,%ebx
  800168:	89 d7                	mov    %edx,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5f                   	pop    %edi
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <__x86.get_pc_thunk.ax>:
  800173:	8b 04 24             	mov    (%esp),%eax
  800176:	c3                   	ret    

00800177 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	57                   	push   %edi
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	e8 d1 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800185:	81 c3 7b 1e 00 00    	add    $0x1e7b,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018b:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018e:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800194:	8b 38                	mov    (%eax),%edi
  800196:	e8 b9 ff ff ff       	call   800154 <sys_getenvid>
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 0c             	pushl  0xc(%ebp)
  8001a1:	ff 75 08             	pushl  0x8(%ebp)
  8001a4:	57                   	push   %edi
  8001a5:	50                   	push   %eax
  8001a6:	8d 83 f4 ee ff ff    	lea    -0x110c(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 d1 00 00 00       	call   800283 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b2:	83 c4 18             	add    $0x18,%esp
  8001b5:	56                   	push   %esi
  8001b6:	ff 75 10             	pushl  0x10(%ebp)
  8001b9:	e8 63 00 00 00       	call   800221 <vcprintf>
	cprintf("\n");
  8001be:	8d 83 18 ef ff ff    	lea    -0x10e8(%ebx),%eax
  8001c4:	89 04 24             	mov    %eax,(%esp)
  8001c7:	e8 b7 00 00 00       	call   800283 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cf:	cc                   	int3   
  8001d0:	eb fd                	jmp    8001cf <_panic+0x58>

008001d2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	e8 7a fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8001dc:	81 c3 24 1e 00 00    	add    $0x1e24,%ebx
  8001e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e5:	8b 16                	mov    (%esi),%edx
  8001e7:	8d 42 01             	lea    0x1(%edx),%eax
  8001ea:	89 06                	mov    %eax,(%esi)
  8001ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ef:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f8:	74 0b                	je     800205 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fa:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	68 ff 00 00 00       	push   $0xff
  80020d:	8d 46 08             	lea    0x8(%esi),%eax
  800210:	50                   	push   %eax
  800211:	e8 ac fe ff ff       	call   8000c2 <sys_cputs>
		b->idx = 0;
  800216:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021c:	83 c4 10             	add    $0x10,%esp
  80021f:	eb d9                	jmp    8001fa <putch+0x28>

00800221 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	53                   	push   %ebx
  800225:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022b:	e8 26 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800230:	81 c3 d0 1d 00 00    	add    $0x1dd0,%ebx
	struct printbuf b;

	b.idx = 0;
  800236:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023d:	00 00 00 
	b.cnt = 0;
  800240:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800247:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024a:	ff 75 0c             	pushl  0xc(%ebp)
  80024d:	ff 75 08             	pushl  0x8(%ebp)
  800250:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800256:	50                   	push   %eax
  800257:	8d 83 d2 e1 ff ff    	lea    -0x1e2e(%ebx),%eax
  80025d:	50                   	push   %eax
  80025e:	e8 38 01 00 00       	call   80039b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800263:	83 c4 08             	add    $0x8,%esp
  800266:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800272:	50                   	push   %eax
  800273:	e8 4a fe ff ff       	call   8000c2 <sys_cputs>

	return b.cnt;
}
  800278:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800289:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028c:	50                   	push   %eax
  80028d:	ff 75 08             	pushl  0x8(%ebp)
  800290:	e8 8c ff ff ff       	call   800221 <vcprintf>
	va_end(ap);

	return cnt;
}
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	57                   	push   %edi
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 2c             	sub    $0x2c,%esp
  8002a0:	e8 63 06 00 00       	call   800908 <__x86.get_pc_thunk.cx>
  8002a5:	81 c1 5b 1d 00 00    	add    $0x1d5b,%ecx
  8002ab:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002ae:	89 c7                	mov    %eax,%edi
  8002b0:	89 d6                	mov    %edx,%esi
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c9:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002cc:	39 d3                	cmp    %edx,%ebx
  8002ce:	72 09                	jb     8002d9 <printnum+0x42>
  8002d0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d3:	0f 87 83 00 00 00    	ja     80035c <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d9:	83 ec 0c             	sub    $0xc,%esp
  8002dc:	ff 75 18             	pushl  0x18(%ebp)
  8002df:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e5:	53                   	push   %ebx
  8002e6:	ff 75 10             	pushl  0x10(%ebp)
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f5:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002fb:	e8 80 09 00 00       	call   800c80 <__udivdi3>
  800300:	83 c4 18             	add    $0x18,%esp
  800303:	52                   	push   %edx
  800304:	50                   	push   %eax
  800305:	89 f2                	mov    %esi,%edx
  800307:	89 f8                	mov    %edi,%eax
  800309:	e8 89 ff ff ff       	call   800297 <printnum>
  80030e:	83 c4 20             	add    $0x20,%esp
  800311:	eb 13                	jmp    800326 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800313:	83 ec 08             	sub    $0x8,%esp
  800316:	56                   	push   %esi
  800317:	ff 75 18             	pushl  0x18(%ebp)
  80031a:	ff d7                	call   *%edi
  80031c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031f:	83 eb 01             	sub    $0x1,%ebx
  800322:	85 db                	test   %ebx,%ebx
  800324:	7f ed                	jg     800313 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800326:	83 ec 08             	sub    $0x8,%esp
  800329:	56                   	push   %esi
  80032a:	83 ec 04             	sub    $0x4,%esp
  80032d:	ff 75 dc             	pushl  -0x24(%ebp)
  800330:	ff 75 d8             	pushl  -0x28(%ebp)
  800333:	ff 75 d4             	pushl  -0x2c(%ebp)
  800336:	ff 75 d0             	pushl  -0x30(%ebp)
  800339:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80033c:	89 f3                	mov    %esi,%ebx
  80033e:	e8 5d 0a 00 00       	call   800da0 <__umoddi3>
  800343:	83 c4 14             	add    $0x14,%esp
  800346:	0f be 84 06 1a ef ff 	movsbl -0x10e6(%esi,%eax,1),%eax
  80034d:	ff 
  80034e:	50                   	push   %eax
  80034f:	ff d7                	call   *%edi
}
  800351:	83 c4 10             	add    $0x10,%esp
  800354:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800357:	5b                   	pop    %ebx
  800358:	5e                   	pop    %esi
  800359:	5f                   	pop    %edi
  80035a:	5d                   	pop    %ebp
  80035b:	c3                   	ret    
  80035c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035f:	eb be                	jmp    80031f <printnum+0x88>

00800361 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800367:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036b:	8b 10                	mov    (%eax),%edx
  80036d:	3b 50 04             	cmp    0x4(%eax),%edx
  800370:	73 0a                	jae    80037c <sprintputch+0x1b>
		*b->buf++ = ch;
  800372:	8d 4a 01             	lea    0x1(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 45 08             	mov    0x8(%ebp),%eax
  80037a:	88 02                	mov    %al,(%edx)
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <printfmt>:
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800384:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800387:	50                   	push   %eax
  800388:	ff 75 10             	pushl  0x10(%ebp)
  80038b:	ff 75 0c             	pushl  0xc(%ebp)
  80038e:	ff 75 08             	pushl  0x8(%ebp)
  800391:	e8 05 00 00 00       	call   80039b <vprintfmt>
}
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	c9                   	leave  
  80039a:	c3                   	ret    

0080039b <vprintfmt>:
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	57                   	push   %edi
  80039f:	56                   	push   %esi
  8003a0:	53                   	push   %ebx
  8003a1:	83 ec 2c             	sub    $0x2c,%esp
  8003a4:	e8 ad fc ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8003a9:	81 c3 57 1c 00 00    	add    $0x1c57,%ebx
  8003af:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003b2:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003b9:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bb:	8d 77 01             	lea    0x1(%edi),%esi
  8003be:	0f b6 07             	movzbl (%edi),%eax
  8003c1:	83 f8 25             	cmp    $0x25,%eax
  8003c4:	74 1c                	je     8003e2 <vprintfmt+0x47>
			if (ch == '\0')
  8003c6:	85 c0                	test   %eax,%eax
  8003c8:	0f 84 b9 04 00 00    	je     800887 <.L21+0x20>
			putch(ch, putdat);
  8003ce:	83 ec 08             	sub    $0x8,%esp
  8003d1:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003d4:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003d7:	50                   	push   %eax
  8003d8:	ff 55 08             	call   *0x8(%ebp)
  8003db:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003de:	89 f7                	mov    %esi,%edi
  8003e0:	eb d9                	jmp    8003bb <vprintfmt+0x20>
		padc = ' ';
  8003e2:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003e6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003ed:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003f4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800400:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8d 7e 01             	lea    0x1(%esi),%edi
  800406:	0f b6 16             	movzbl (%esi),%edx
  800409:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040c:	3c 55                	cmp    $0x55,%al
  80040e:	0f 87 53 04 00 00    	ja     800867 <.L21>
  800414:	0f b6 c0             	movzbl %al,%eax
  800417:	89 d9                	mov    %ebx,%ecx
  800419:	03 8c 83 a8 ef ff ff 	add    -0x1058(%ebx,%eax,4),%ecx
  800420:	ff e1                	jmp    *%ecx

00800422 <.L73>:
  800422:	89 fe                	mov    %edi,%esi
			padc = '-';
  800424:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800428:	eb d9                	jmp    800403 <vprintfmt+0x68>

0080042a <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	89 fe                	mov    %edi,%esi
			padc = '0';
  80042c:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800430:	eb d1                	jmp    800403 <vprintfmt+0x68>

00800432 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	0f b6 d2             	movzbl %dl,%edx
  800435:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  80043f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800442:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800446:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800449:	8d 7a d0             	lea    -0x30(%edx),%edi
  80044c:	83 ff 09             	cmp    $0x9,%edi
  80044f:	0f 87 94 00 00 00    	ja     8004e9 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800455:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800458:	eb e5                	jmp    80043f <.L28+0xd>

0080045a <.L25>:
			precision = va_arg(ap, int);
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 40 04             	lea    0x4(%eax),%eax
  800468:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	89 fe                	mov    %edi,%esi
			if (width < 0)
  80046d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800471:	79 90                	jns    800403 <vprintfmt+0x68>
				width = precision, precision = -1;
  800473:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800476:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800479:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800480:	eb 81                	jmp    800403 <vprintfmt+0x68>

00800482 <.L26>:
  800482:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800485:	85 c0                	test   %eax,%eax
  800487:	ba 00 00 00 00       	mov    $0x0,%edx
  80048c:	0f 49 d0             	cmovns %eax,%edx
  80048f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800492:	89 fe                	mov    %edi,%esi
  800494:	e9 6a ff ff ff       	jmp    800403 <vprintfmt+0x68>

00800499 <.L22>:
  800499:	89 fe                	mov    %edi,%esi
			altflag = 1;
  80049b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a2:	e9 5c ff ff ff       	jmp    800403 <vprintfmt+0x68>

008004a7 <.L33>:
  8004a7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004aa:	83 f9 01             	cmp    $0x1,%ecx
  8004ad:	7e 16                	jle    8004c5 <.L33+0x1e>
		return va_arg(*ap, long long);
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8b 00                	mov    (%eax),%eax
  8004b4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004b7:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004ba:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004c0:	e9 f6 fe ff ff       	jmp    8003bb <vprintfmt+0x20>
	else if (lflag)
  8004c5:	85 c9                	test   %ecx,%ecx
  8004c7:	75 10                	jne    8004d9 <.L33+0x32>
		return va_arg(*ap, int);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8b 00                	mov    (%eax),%eax
  8004ce:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004d1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004d4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d7:	eb e4                	jmp    8004bd <.L33+0x16>
		return va_arg(*ap, long);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004e1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004e4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e7:	eb d4                	jmp    8004bd <.L33+0x16>
  8004e9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ef:	e9 79 ff ff ff       	jmp    80046d <.L25+0x13>

008004f4 <.L32>:
			lflag++;
  8004f4:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f8:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8004fa:	e9 04 ff ff ff       	jmp    800403 <vprintfmt+0x68>

008004ff <.L29>:
			putch(va_arg(ap, int), putdat);
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 70 04             	lea    0x4(%eax),%esi
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	ff 75 0c             	pushl  0xc(%ebp)
  80050b:	ff 30                	pushl  (%eax)
  80050d:	ff 55 08             	call   *0x8(%ebp)
			break;
  800510:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800513:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800516:	e9 a0 fe ff ff       	jmp    8003bb <vprintfmt+0x20>

0080051b <.L31>:
			err = va_arg(ap, int);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 70 04             	lea    0x4(%eax),%esi
  800521:	8b 00                	mov    (%eax),%eax
  800523:	99                   	cltd   
  800524:	31 d0                	xor    %edx,%eax
  800526:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800528:	83 f8 06             	cmp    $0x6,%eax
  80052b:	7f 29                	jg     800556 <.L31+0x3b>
  80052d:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800534:	85 d2                	test   %edx,%edx
  800536:	74 1e                	je     800556 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800538:	52                   	push   %edx
  800539:	8d 83 3b ef ff ff    	lea    -0x10c5(%ebx),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	ff 75 08             	pushl  0x8(%ebp)
  800546:	e8 33 fe ff ff       	call   80037e <printfmt>
  80054b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80054e:	89 75 14             	mov    %esi,0x14(%ebp)
  800551:	e9 65 fe ff ff       	jmp    8003bb <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800556:	50                   	push   %eax
  800557:	8d 83 32 ef ff ff    	lea    -0x10ce(%ebx),%eax
  80055d:	50                   	push   %eax
  80055e:	ff 75 0c             	pushl  0xc(%ebp)
  800561:	ff 75 08             	pushl  0x8(%ebp)
  800564:	e8 15 fe ff ff       	call   80037e <printfmt>
  800569:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80056c:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80056f:	e9 47 fe ff ff       	jmp    8003bb <vprintfmt+0x20>

00800574 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	83 c0 04             	add    $0x4,%eax
  80057a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800582:	85 f6                	test   %esi,%esi
  800584:	8d 83 2b ef ff ff    	lea    -0x10d5(%ebx),%eax
  80058a:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80058d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800591:	0f 8e b4 00 00 00    	jle    80064b <.L36+0xd7>
  800597:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80059b:	75 08                	jne    8005a5 <.L36+0x31>
  80059d:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005a0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005a3:	eb 6c                	jmp    800611 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	ff 75 cc             	pushl  -0x34(%ebp)
  8005ab:	56                   	push   %esi
  8005ac:	e8 73 03 00 00       	call   800924 <strnlen>
  8005b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b4:	29 c2                	sub    %eax,%edx
  8005b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005b9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005bc:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005c0:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005c3:	89 d6                	mov    %edx,%esi
  8005c5:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005c8:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ca:	eb 10                	jmp    8005dc <.L36+0x68>
					putch(padc, putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	ff 75 0c             	pushl  0xc(%ebp)
  8005d2:	57                   	push   %edi
  8005d3:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d6:	83 ee 01             	sub    $0x1,%esi
  8005d9:	83 c4 10             	add    $0x10,%esp
  8005dc:	85 f6                	test   %esi,%esi
  8005de:	7f ec                	jg     8005cc <.L36+0x58>
  8005e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e6:	85 d2                	test   %edx,%edx
  8005e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ed:	0f 49 c2             	cmovns %edx,%eax
  8005f0:	29 c2                	sub    %eax,%edx
  8005f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f5:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005f8:	eb 17                	jmp    800611 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8005fa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005fe:	75 30                	jne    800630 <.L36+0xbc>
					putch(ch, putdat);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	ff 75 0c             	pushl  0xc(%ebp)
  800606:	50                   	push   %eax
  800607:	ff 55 08             	call   *0x8(%ebp)
  80060a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800611:	83 c6 01             	add    $0x1,%esi
  800614:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800618:	0f be c2             	movsbl %dl,%eax
  80061b:	85 c0                	test   %eax,%eax
  80061d:	74 58                	je     800677 <.L36+0x103>
  80061f:	85 ff                	test   %edi,%edi
  800621:	78 d7                	js     8005fa <.L36+0x86>
  800623:	83 ef 01             	sub    $0x1,%edi
  800626:	79 d2                	jns    8005fa <.L36+0x86>
  800628:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80062b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80062e:	eb 32                	jmp    800662 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800630:	0f be d2             	movsbl %dl,%edx
  800633:	83 ea 20             	sub    $0x20,%edx
  800636:	83 fa 5e             	cmp    $0x5e,%edx
  800639:	76 c5                	jbe    800600 <.L36+0x8c>
					putch('?', putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	ff 75 0c             	pushl  0xc(%ebp)
  800641:	6a 3f                	push   $0x3f
  800643:	ff 55 08             	call   *0x8(%ebp)
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	eb c2                	jmp    80060d <.L36+0x99>
  80064b:	89 7d 10             	mov    %edi,0x10(%ebp)
  80064e:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800651:	eb be                	jmp    800611 <.L36+0x9d>
				putch(' ', putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	57                   	push   %edi
  800657:	6a 20                	push   $0x20
  800659:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80065c:	83 ee 01             	sub    $0x1,%esi
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	85 f6                	test   %esi,%esi
  800664:	7f ed                	jg     800653 <.L36+0xdf>
  800666:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800669:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  80066c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
  800672:	e9 44 fd ff ff       	jmp    8003bb <vprintfmt+0x20>
  800677:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80067d:	eb e3                	jmp    800662 <.L36+0xee>

0080067f <.L30>:
  80067f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800682:	83 f9 01             	cmp    $0x1,%ecx
  800685:	7e 42                	jle    8006c9 <.L30+0x4a>
		return va_arg(*ap, long long);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8b 50 04             	mov    0x4(%eax),%edx
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800692:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 40 08             	lea    0x8(%eax),%eax
  80069b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80069e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a2:	79 5f                	jns    800703 <.L30+0x84>
				putch('-', putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	6a 2d                	push   $0x2d
  8006ac:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b5:	f7 da                	neg    %edx
  8006b7:	83 d1 00             	adc    $0x0,%ecx
  8006ba:	f7 d9                	neg    %ecx
  8006bc:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c4:	e9 b8 00 00 00       	jmp    800781 <.L34+0x22>
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	75 1b                	jne    8006e8 <.L30+0x69>
		return va_arg(*ap, int);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 30                	mov    (%eax),%esi
  8006d2:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	c1 f8 1f             	sar    $0x1f,%eax
  8006da:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e6:	eb b6                	jmp    80069e <.L30+0x1f>
		return va_arg(*ap, long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 30                	mov    (%eax),%esi
  8006ed:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006f0:	89 f0                	mov    %esi,%eax
  8006f2:	c1 f8 1f             	sar    $0x1f,%eax
  8006f5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)
  800701:	eb 9b                	jmp    80069e <.L30+0x1f>
			num = getint(&ap, lflag);
  800703:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800706:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800709:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070e:	eb 71                	jmp    800781 <.L34+0x22>

00800710 <.L37>:
  800710:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800713:	83 f9 01             	cmp    $0x1,%ecx
  800716:	7e 15                	jle    80072d <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8b 10                	mov    (%eax),%edx
  80071d:	8b 48 04             	mov    0x4(%eax),%ecx
  800720:	8d 40 08             	lea    0x8(%eax),%eax
  800723:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800726:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072b:	eb 54                	jmp    800781 <.L34+0x22>
	else if (lflag)
  80072d:	85 c9                	test   %ecx,%ecx
  80072f:	75 17                	jne    800748 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 10                	mov    (%eax),%edx
  800736:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073b:	8d 40 04             	lea    0x4(%eax),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800741:	b8 0a 00 00 00       	mov    $0xa,%eax
  800746:	eb 39                	jmp    800781 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800752:	8d 40 04             	lea    0x4(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800758:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075d:	eb 22                	jmp    800781 <.L34+0x22>

0080075f <.L34>:
  80075f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800762:	83 f9 01             	cmp    $0x1,%ecx
  800765:	7e 3b                	jle    8007a2 <.L34+0x43>
		return va_arg(*ap, long long);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8b 50 04             	mov    0x4(%eax),%edx
  80076d:	8b 00                	mov    (%eax),%eax
  80076f:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800772:	8d 49 08             	lea    0x8(%ecx),%ecx
  800775:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800778:	89 d1                	mov    %edx,%ecx
  80077a:	89 c2                	mov    %eax,%edx
			base = 8;
  80077c:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800781:	83 ec 0c             	sub    $0xc,%esp
  800784:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800788:	56                   	push   %esi
  800789:	ff 75 e0             	pushl  -0x20(%ebp)
  80078c:	50                   	push   %eax
  80078d:	51                   	push   %ecx
  80078e:	52                   	push   %edx
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800792:	8b 45 08             	mov    0x8(%ebp),%eax
  800795:	e8 fd fa ff ff       	call   800297 <printnum>
			break;
  80079a:	83 c4 20             	add    $0x20,%esp
  80079d:	e9 19 fc ff ff       	jmp    8003bb <vprintfmt+0x20>
	else if (lflag)
  8007a2:	85 c9                	test   %ecx,%ecx
  8007a4:	75 13                	jne    8007b9 <.L34+0x5a>
		return va_arg(*ap, int);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8b 10                	mov    (%eax),%edx
  8007ab:	89 d0                	mov    %edx,%eax
  8007ad:	99                   	cltd   
  8007ae:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007b1:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007b4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b7:	eb bf                	jmp    800778 <.L34+0x19>
		return va_arg(*ap, long);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8b 10                	mov    (%eax),%edx
  8007be:	89 d0                	mov    %edx,%eax
  8007c0:	99                   	cltd   
  8007c1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007c4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007c7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007ca:	eb ac                	jmp    800778 <.L34+0x19>

008007cc <.L35>:
			putch('0', putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	6a 30                	push   $0x30
  8007d4:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d7:	83 c4 08             	add    $0x8,%esp
  8007da:	ff 75 0c             	pushl  0xc(%ebp)
  8007dd:	6a 78                	push   $0x78
  8007df:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8b 10                	mov    (%eax),%edx
  8007e7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007ec:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007ef:	8d 40 04             	lea    0x4(%eax),%eax
  8007f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007fa:	eb 85                	jmp    800781 <.L34+0x22>

008007fc <.L38>:
  8007fc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8007ff:	83 f9 01             	cmp    $0x1,%ecx
  800802:	7e 18                	jle    80081c <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  800804:	8b 45 14             	mov    0x14(%ebp),%eax
  800807:	8b 10                	mov    (%eax),%edx
  800809:	8b 48 04             	mov    0x4(%eax),%ecx
  80080c:	8d 40 08             	lea    0x8(%eax),%eax
  80080f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800812:	b8 10 00 00 00       	mov    $0x10,%eax
  800817:	e9 65 ff ff ff       	jmp    800781 <.L34+0x22>
	else if (lflag)
  80081c:	85 c9                	test   %ecx,%ecx
  80081e:	75 1a                	jne    80083a <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8b 10                	mov    (%eax),%edx
  800825:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082a:	8d 40 04             	lea    0x4(%eax),%eax
  80082d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800830:	b8 10 00 00 00       	mov    $0x10,%eax
  800835:	e9 47 ff ff ff       	jmp    800781 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80083a:	8b 45 14             	mov    0x14(%ebp),%eax
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800844:	8d 40 04             	lea    0x4(%eax),%eax
  800847:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80084a:	b8 10 00 00 00       	mov    $0x10,%eax
  80084f:	e9 2d ff ff ff       	jmp    800781 <.L34+0x22>

00800854 <.L24>:
			putch(ch, putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	ff 75 0c             	pushl  0xc(%ebp)
  80085a:	6a 25                	push   $0x25
  80085c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80085f:	83 c4 10             	add    $0x10,%esp
  800862:	e9 54 fb ff ff       	jmp    8003bb <vprintfmt+0x20>

00800867 <.L21>:
			putch('%', putdat);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	ff 75 0c             	pushl  0xc(%ebp)
  80086d:	6a 25                	push   $0x25
  80086f:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800872:	83 c4 10             	add    $0x10,%esp
  800875:	89 f7                	mov    %esi,%edi
  800877:	eb 03                	jmp    80087c <.L21+0x15>
  800879:	83 ef 01             	sub    $0x1,%edi
  80087c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800880:	75 f7                	jne    800879 <.L21+0x12>
  800882:	e9 34 fb ff ff       	jmp    8003bb <vprintfmt+0x20>
}
  800887:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80088a:	5b                   	pop    %ebx
  80088b:	5e                   	pop    %esi
  80088c:	5f                   	pop    %edi
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	53                   	push   %ebx
  800893:	83 ec 14             	sub    $0x14,%esp
  800896:	e8 bb f7 ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  80089b:	81 c3 65 17 00 00    	add    $0x1765,%ebx
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b8:	85 c0                	test   %eax,%eax
  8008ba:	74 2b                	je     8008e7 <vsnprintf+0x58>
  8008bc:	85 d2                	test   %edx,%edx
  8008be:	7e 27                	jle    8008e7 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c0:	ff 75 14             	pushl  0x14(%ebp)
  8008c3:	ff 75 10             	pushl  0x10(%ebp)
  8008c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c9:	50                   	push   %eax
  8008ca:	8d 83 61 e3 ff ff    	lea    -0x1c9f(%ebx),%eax
  8008d0:	50                   	push   %eax
  8008d1:	e8 c5 fa ff ff       	call   80039b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008df:	83 c4 10             	add    $0x10,%esp
}
  8008e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    
		return -E_INVAL;
  8008e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ec:	eb f4                	jmp    8008e2 <vsnprintf+0x53>

008008ee <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f7:	50                   	push   %eax
  8008f8:	ff 75 10             	pushl  0x10(%ebp)
  8008fb:	ff 75 0c             	pushl  0xc(%ebp)
  8008fe:	ff 75 08             	pushl  0x8(%ebp)
  800901:	e8 89 ff ff ff       	call   80088f <vsnprintf>
	va_end(ap);

	return rc;
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <__x86.get_pc_thunk.cx>:
  800908:	8b 0c 24             	mov    (%esp),%ecx
  80090b:	c3                   	ret    

0080090c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
  800917:	eb 03                	jmp    80091c <strlen+0x10>
		n++;
  800919:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80091c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800920:	75 f7                	jne    800919 <strlen+0xd>
	return n;
}
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092d:	b8 00 00 00 00       	mov    $0x0,%eax
  800932:	eb 03                	jmp    800937 <strnlen+0x13>
		n++;
  800934:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800937:	39 d0                	cmp    %edx,%eax
  800939:	74 06                	je     800941 <strnlen+0x1d>
  80093b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80093f:	75 f3                	jne    800934 <strnlen+0x10>
	return n;
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094d:	89 c2                	mov    %eax,%edx
  80094f:	83 c1 01             	add    $0x1,%ecx
  800952:	83 c2 01             	add    $0x1,%edx
  800955:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800959:	88 5a ff             	mov    %bl,-0x1(%edx)
  80095c:	84 db                	test   %bl,%bl
  80095e:	75 ef                	jne    80094f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800960:	5b                   	pop    %ebx
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096a:	53                   	push   %ebx
  80096b:	e8 9c ff ff ff       	call   80090c <strlen>
  800970:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800973:	ff 75 0c             	pushl  0xc(%ebp)
  800976:	01 d8                	add    %ebx,%eax
  800978:	50                   	push   %eax
  800979:	e8 c5 ff ff ff       	call   800943 <strcpy>
	return dst;
}
  80097e:	89 d8                	mov    %ebx,%eax
  800980:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800983:	c9                   	leave  
  800984:	c3                   	ret    

00800985 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	56                   	push   %esi
  800989:	53                   	push   %ebx
  80098a:	8b 75 08             	mov    0x8(%ebp),%esi
  80098d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800990:	89 f3                	mov    %esi,%ebx
  800992:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800995:	89 f2                	mov    %esi,%edx
  800997:	eb 0f                	jmp    8009a8 <strncpy+0x23>
		*dst++ = *src;
  800999:	83 c2 01             	add    $0x1,%edx
  80099c:	0f b6 01             	movzbl (%ecx),%eax
  80099f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a2:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a5:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009a8:	39 da                	cmp    %ebx,%edx
  8009aa:	75 ed                	jne    800999 <strncpy+0x14>
	}
	return ret;
}
  8009ac:	89 f0                	mov    %esi,%eax
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	56                   	push   %esi
  8009b6:	53                   	push   %ebx
  8009b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009c0:	89 f0                	mov    %esi,%eax
  8009c2:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c6:	85 c9                	test   %ecx,%ecx
  8009c8:	75 0b                	jne    8009d5 <strlcpy+0x23>
  8009ca:	eb 17                	jmp    8009e3 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cc:	83 c2 01             	add    $0x1,%edx
  8009cf:	83 c0 01             	add    $0x1,%eax
  8009d2:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009d5:	39 d8                	cmp    %ebx,%eax
  8009d7:	74 07                	je     8009e0 <strlcpy+0x2e>
  8009d9:	0f b6 0a             	movzbl (%edx),%ecx
  8009dc:	84 c9                	test   %cl,%cl
  8009de:	75 ec                	jne    8009cc <strlcpy+0x1a>
		*dst = '\0';
  8009e0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e3:	29 f0                	sub    %esi,%eax
}
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f2:	eb 06                	jmp    8009fa <strcmp+0x11>
		p++, q++;
  8009f4:	83 c1 01             	add    $0x1,%ecx
  8009f7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009fa:	0f b6 01             	movzbl (%ecx),%eax
  8009fd:	84 c0                	test   %al,%al
  8009ff:	74 04                	je     800a05 <strcmp+0x1c>
  800a01:	3a 02                	cmp    (%edx),%al
  800a03:	74 ef                	je     8009f4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a05:	0f b6 c0             	movzbl %al,%eax
  800a08:	0f b6 12             	movzbl (%edx),%edx
  800a0b:	29 d0                	sub    %edx,%eax
}
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	53                   	push   %ebx
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a19:	89 c3                	mov    %eax,%ebx
  800a1b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a1e:	eb 06                	jmp    800a26 <strncmp+0x17>
		n--, p++, q++;
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a26:	39 d8                	cmp    %ebx,%eax
  800a28:	74 16                	je     800a40 <strncmp+0x31>
  800a2a:	0f b6 08             	movzbl (%eax),%ecx
  800a2d:	84 c9                	test   %cl,%cl
  800a2f:	74 04                	je     800a35 <strncmp+0x26>
  800a31:	3a 0a                	cmp    (%edx),%cl
  800a33:	74 eb                	je     800a20 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a35:	0f b6 00             	movzbl (%eax),%eax
  800a38:	0f b6 12             	movzbl (%edx),%edx
  800a3b:	29 d0                	sub    %edx,%eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    
		return 0;
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
  800a45:	eb f6                	jmp    800a3d <strncmp+0x2e>

00800a47 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a51:	0f b6 10             	movzbl (%eax),%edx
  800a54:	84 d2                	test   %dl,%dl
  800a56:	74 09                	je     800a61 <strchr+0x1a>
		if (*s == c)
  800a58:	38 ca                	cmp    %cl,%dl
  800a5a:	74 0a                	je     800a66 <strchr+0x1f>
	for (; *s; s++)
  800a5c:	83 c0 01             	add    $0x1,%eax
  800a5f:	eb f0                	jmp    800a51 <strchr+0xa>
			return (char *) s;
	return 0;
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a72:	eb 03                	jmp    800a77 <strfind+0xf>
  800a74:	83 c0 01             	add    $0x1,%eax
  800a77:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a7a:	38 ca                	cmp    %cl,%dl
  800a7c:	74 04                	je     800a82 <strfind+0x1a>
  800a7e:	84 d2                	test   %dl,%dl
  800a80:	75 f2                	jne    800a74 <strfind+0xc>
			break;
	return (char *) s;
}
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a90:	85 c9                	test   %ecx,%ecx
  800a92:	74 13                	je     800aa7 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9a:	75 05                	jne    800aa1 <memset+0x1d>
  800a9c:	f6 c1 03             	test   $0x3,%cl
  800a9f:	74 0d                	je     800aae <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa4:	fc                   	cld    
  800aa5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa7:	89 f8                	mov    %edi,%eax
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    
		c &= 0xFF;
  800aae:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab2:	89 d3                	mov    %edx,%ebx
  800ab4:	c1 e3 08             	shl    $0x8,%ebx
  800ab7:	89 d0                	mov    %edx,%eax
  800ab9:	c1 e0 18             	shl    $0x18,%eax
  800abc:	89 d6                	mov    %edx,%esi
  800abe:	c1 e6 10             	shl    $0x10,%esi
  800ac1:	09 f0                	or     %esi,%eax
  800ac3:	09 c2                	or     %eax,%edx
  800ac5:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ac7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800aca:	89 d0                	mov    %edx,%eax
  800acc:	fc                   	cld    
  800acd:	f3 ab                	rep stos %eax,%es:(%edi)
  800acf:	eb d6                	jmp    800aa7 <memset+0x23>

00800ad1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800adf:	39 c6                	cmp    %eax,%esi
  800ae1:	73 35                	jae    800b18 <memmove+0x47>
  800ae3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae6:	39 c2                	cmp    %eax,%edx
  800ae8:	76 2e                	jbe    800b18 <memmove+0x47>
		s += n;
		d += n;
  800aea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aed:	89 d6                	mov    %edx,%esi
  800aef:	09 fe                	or     %edi,%esi
  800af1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af7:	74 0c                	je     800b05 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af9:	83 ef 01             	sub    $0x1,%edi
  800afc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aff:	fd                   	std    
  800b00:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b02:	fc                   	cld    
  800b03:	eb 21                	jmp    800b26 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b05:	f6 c1 03             	test   $0x3,%cl
  800b08:	75 ef                	jne    800af9 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b0a:	83 ef 04             	sub    $0x4,%edi
  800b0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b10:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b13:	fd                   	std    
  800b14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b16:	eb ea                	jmp    800b02 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b18:	89 f2                	mov    %esi,%edx
  800b1a:	09 c2                	or     %eax,%edx
  800b1c:	f6 c2 03             	test   $0x3,%dl
  800b1f:	74 09                	je     800b2a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b21:	89 c7                	mov    %eax,%edi
  800b23:	fc                   	cld    
  800b24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2a:	f6 c1 03             	test   $0x3,%cl
  800b2d:	75 f2                	jne    800b21 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	fc                   	cld    
  800b35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b37:	eb ed                	jmp    800b26 <memmove+0x55>

00800b39 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3c:	ff 75 10             	pushl  0x10(%ebp)
  800b3f:	ff 75 0c             	pushl  0xc(%ebp)
  800b42:	ff 75 08             	pushl  0x8(%ebp)
  800b45:	e8 87 ff ff ff       	call   800ad1 <memmove>
}
  800b4a:	c9                   	leave  
  800b4b:	c3                   	ret    

00800b4c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b57:	89 c6                	mov    %eax,%esi
  800b59:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5c:	39 f0                	cmp    %esi,%eax
  800b5e:	74 1c                	je     800b7c <memcmp+0x30>
		if (*s1 != *s2)
  800b60:	0f b6 08             	movzbl (%eax),%ecx
  800b63:	0f b6 1a             	movzbl (%edx),%ebx
  800b66:	38 d9                	cmp    %bl,%cl
  800b68:	75 08                	jne    800b72 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	83 c2 01             	add    $0x1,%edx
  800b70:	eb ea                	jmp    800b5c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b72:	0f b6 c1             	movzbl %cl,%eax
  800b75:	0f b6 db             	movzbl %bl,%ebx
  800b78:	29 d8                	sub    %ebx,%eax
  800b7a:	eb 05                	jmp    800b81 <memcmp+0x35>
	}

	return 0;
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b81:	5b                   	pop    %ebx
  800b82:	5e                   	pop    %esi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b8e:	89 c2                	mov    %eax,%edx
  800b90:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b93:	39 d0                	cmp    %edx,%eax
  800b95:	73 09                	jae    800ba0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b97:	38 08                	cmp    %cl,(%eax)
  800b99:	74 05                	je     800ba0 <memfind+0x1b>
	for (; s < ends; s++)
  800b9b:	83 c0 01             	add    $0x1,%eax
  800b9e:	eb f3                	jmp    800b93 <memfind+0xe>
			break;
	return (void *) s;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bae:	eb 03                	jmp    800bb3 <strtol+0x11>
		s++;
  800bb0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bb3:	0f b6 01             	movzbl (%ecx),%eax
  800bb6:	3c 20                	cmp    $0x20,%al
  800bb8:	74 f6                	je     800bb0 <strtol+0xe>
  800bba:	3c 09                	cmp    $0x9,%al
  800bbc:	74 f2                	je     800bb0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bbe:	3c 2b                	cmp    $0x2b,%al
  800bc0:	74 2e                	je     800bf0 <strtol+0x4e>
	int neg = 0;
  800bc2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bc7:	3c 2d                	cmp    $0x2d,%al
  800bc9:	74 2f                	je     800bfa <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bcb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bd1:	75 05                	jne    800bd8 <strtol+0x36>
  800bd3:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd6:	74 2c                	je     800c04 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd8:	85 db                	test   %ebx,%ebx
  800bda:	75 0a                	jne    800be6 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bdc:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800be1:	80 39 30             	cmpb   $0x30,(%ecx)
  800be4:	74 28                	je     800c0e <strtol+0x6c>
		base = 10;
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bee:	eb 50                	jmp    800c40 <strtol+0x9e>
		s++;
  800bf0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bf3:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf8:	eb d1                	jmp    800bcb <strtol+0x29>
		s++, neg = 1;
  800bfa:	83 c1 01             	add    $0x1,%ecx
  800bfd:	bf 01 00 00 00       	mov    $0x1,%edi
  800c02:	eb c7                	jmp    800bcb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c04:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c08:	74 0e                	je     800c18 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c0a:	85 db                	test   %ebx,%ebx
  800c0c:	75 d8                	jne    800be6 <strtol+0x44>
		s++, base = 8;
  800c0e:	83 c1 01             	add    $0x1,%ecx
  800c11:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c16:	eb ce                	jmp    800be6 <strtol+0x44>
		s += 2, base = 16;
  800c18:	83 c1 02             	add    $0x2,%ecx
  800c1b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c20:	eb c4                	jmp    800be6 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c22:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c25:	89 f3                	mov    %esi,%ebx
  800c27:	80 fb 19             	cmp    $0x19,%bl
  800c2a:	77 29                	ja     800c55 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c2c:	0f be d2             	movsbl %dl,%edx
  800c2f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c32:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c35:	7d 30                	jge    800c67 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c37:	83 c1 01             	add    $0x1,%ecx
  800c3a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c3e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c40:	0f b6 11             	movzbl (%ecx),%edx
  800c43:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c46:	89 f3                	mov    %esi,%ebx
  800c48:	80 fb 09             	cmp    $0x9,%bl
  800c4b:	77 d5                	ja     800c22 <strtol+0x80>
			dig = *s - '0';
  800c4d:	0f be d2             	movsbl %dl,%edx
  800c50:	83 ea 30             	sub    $0x30,%edx
  800c53:	eb dd                	jmp    800c32 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c55:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c58:	89 f3                	mov    %esi,%ebx
  800c5a:	80 fb 19             	cmp    $0x19,%bl
  800c5d:	77 08                	ja     800c67 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c5f:	0f be d2             	movsbl %dl,%edx
  800c62:	83 ea 37             	sub    $0x37,%edx
  800c65:	eb cb                	jmp    800c32 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6b:	74 05                	je     800c72 <strtol+0xd0>
		*endptr = (char *) s;
  800c6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c70:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c72:	89 c2                	mov    %eax,%edx
  800c74:	f7 da                	neg    %edx
  800c76:	85 ff                	test   %edi,%edi
  800c78:	0f 45 c2             	cmovne %edx,%eax
}
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <__udivdi3>:
  800c80:	55                   	push   %ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 1c             	sub    $0x1c,%esp
  800c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c8b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c93:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c97:	85 d2                	test   %edx,%edx
  800c99:	75 35                	jne    800cd0 <__udivdi3+0x50>
  800c9b:	39 f3                	cmp    %esi,%ebx
  800c9d:	0f 87 bd 00 00 00    	ja     800d60 <__udivdi3+0xe0>
  800ca3:	85 db                	test   %ebx,%ebx
  800ca5:	89 d9                	mov    %ebx,%ecx
  800ca7:	75 0b                	jne    800cb4 <__udivdi3+0x34>
  800ca9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cae:	31 d2                	xor    %edx,%edx
  800cb0:	f7 f3                	div    %ebx
  800cb2:	89 c1                	mov    %eax,%ecx
  800cb4:	31 d2                	xor    %edx,%edx
  800cb6:	89 f0                	mov    %esi,%eax
  800cb8:	f7 f1                	div    %ecx
  800cba:	89 c6                	mov    %eax,%esi
  800cbc:	89 e8                	mov    %ebp,%eax
  800cbe:	89 f7                	mov    %esi,%edi
  800cc0:	f7 f1                	div    %ecx
  800cc2:	89 fa                	mov    %edi,%edx
  800cc4:	83 c4 1c             	add    $0x1c,%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    
  800ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	39 f2                	cmp    %esi,%edx
  800cd2:	77 7c                	ja     800d50 <__udivdi3+0xd0>
  800cd4:	0f bd fa             	bsr    %edx,%edi
  800cd7:	83 f7 1f             	xor    $0x1f,%edi
  800cda:	0f 84 98 00 00 00    	je     800d78 <__udivdi3+0xf8>
  800ce0:	89 f9                	mov    %edi,%ecx
  800ce2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ce7:	29 f8                	sub    %edi,%eax
  800ce9:	d3 e2                	shl    %cl,%edx
  800ceb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cef:	89 c1                	mov    %eax,%ecx
  800cf1:	89 da                	mov    %ebx,%edx
  800cf3:	d3 ea                	shr    %cl,%edx
  800cf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cf9:	09 d1                	or     %edx,%ecx
  800cfb:	89 f2                	mov    %esi,%edx
  800cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d01:	89 f9                	mov    %edi,%ecx
  800d03:	d3 e3                	shl    %cl,%ebx
  800d05:	89 c1                	mov    %eax,%ecx
  800d07:	d3 ea                	shr    %cl,%edx
  800d09:	89 f9                	mov    %edi,%ecx
  800d0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d0f:	d3 e6                	shl    %cl,%esi
  800d11:	89 eb                	mov    %ebp,%ebx
  800d13:	89 c1                	mov    %eax,%ecx
  800d15:	d3 eb                	shr    %cl,%ebx
  800d17:	09 de                	or     %ebx,%esi
  800d19:	89 f0                	mov    %esi,%eax
  800d1b:	f7 74 24 08          	divl   0x8(%esp)
  800d1f:	89 d6                	mov    %edx,%esi
  800d21:	89 c3                	mov    %eax,%ebx
  800d23:	f7 64 24 0c          	mull   0xc(%esp)
  800d27:	39 d6                	cmp    %edx,%esi
  800d29:	72 0c                	jb     800d37 <__udivdi3+0xb7>
  800d2b:	89 f9                	mov    %edi,%ecx
  800d2d:	d3 e5                	shl    %cl,%ebp
  800d2f:	39 c5                	cmp    %eax,%ebp
  800d31:	73 5d                	jae    800d90 <__udivdi3+0x110>
  800d33:	39 d6                	cmp    %edx,%esi
  800d35:	75 59                	jne    800d90 <__udivdi3+0x110>
  800d37:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d3a:	31 ff                	xor    %edi,%edi
  800d3c:	89 fa                	mov    %edi,%edx
  800d3e:	83 c4 1c             	add    $0x1c,%esp
  800d41:	5b                   	pop    %ebx
  800d42:	5e                   	pop    %esi
  800d43:	5f                   	pop    %edi
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    
  800d46:	8d 76 00             	lea    0x0(%esi),%esi
  800d49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d50:	31 ff                	xor    %edi,%edi
  800d52:	31 c0                	xor    %eax,%eax
  800d54:	89 fa                	mov    %edi,%edx
  800d56:	83 c4 1c             	add    $0x1c,%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    
  800d5e:	66 90                	xchg   %ax,%ax
  800d60:	31 ff                	xor    %edi,%edi
  800d62:	89 e8                	mov    %ebp,%eax
  800d64:	89 f2                	mov    %esi,%edx
  800d66:	f7 f3                	div    %ebx
  800d68:	89 fa                	mov    %edi,%edx
  800d6a:	83 c4 1c             	add    $0x1c,%esp
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    
  800d72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d78:	39 f2                	cmp    %esi,%edx
  800d7a:	72 06                	jb     800d82 <__udivdi3+0x102>
  800d7c:	31 c0                	xor    %eax,%eax
  800d7e:	39 eb                	cmp    %ebp,%ebx
  800d80:	77 d2                	ja     800d54 <__udivdi3+0xd4>
  800d82:	b8 01 00 00 00       	mov    $0x1,%eax
  800d87:	eb cb                	jmp    800d54 <__udivdi3+0xd4>
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	89 d8                	mov    %ebx,%eax
  800d92:	31 ff                	xor    %edi,%edi
  800d94:	eb be                	jmp    800d54 <__udivdi3+0xd4>
  800d96:	66 90                	xchg   %ax,%ax
  800d98:	66 90                	xchg   %ax,%ax
  800d9a:	66 90                	xchg   %ax,%ax
  800d9c:	66 90                	xchg   %ax,%ax
  800d9e:	66 90                	xchg   %ax,%ax

00800da0 <__umoddi3>:
  800da0:	55                   	push   %ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 1c             	sub    $0x1c,%esp
  800da7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800dab:	8b 74 24 30          	mov    0x30(%esp),%esi
  800daf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800db7:	85 ed                	test   %ebp,%ebp
  800db9:	89 f0                	mov    %esi,%eax
  800dbb:	89 da                	mov    %ebx,%edx
  800dbd:	75 19                	jne    800dd8 <__umoddi3+0x38>
  800dbf:	39 df                	cmp    %ebx,%edi
  800dc1:	0f 86 b1 00 00 00    	jbe    800e78 <__umoddi3+0xd8>
  800dc7:	f7 f7                	div    %edi
  800dc9:	89 d0                	mov    %edx,%eax
  800dcb:	31 d2                	xor    %edx,%edx
  800dcd:	83 c4 1c             	add    $0x1c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	39 dd                	cmp    %ebx,%ebp
  800dda:	77 f1                	ja     800dcd <__umoddi3+0x2d>
  800ddc:	0f bd cd             	bsr    %ebp,%ecx
  800ddf:	83 f1 1f             	xor    $0x1f,%ecx
  800de2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800de6:	0f 84 b4 00 00 00    	je     800ea0 <__umoddi3+0x100>
  800dec:	b8 20 00 00 00       	mov    $0x20,%eax
  800df1:	89 c2                	mov    %eax,%edx
  800df3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800df7:	29 c2                	sub    %eax,%edx
  800df9:	89 c1                	mov    %eax,%ecx
  800dfb:	89 f8                	mov    %edi,%eax
  800dfd:	d3 e5                	shl    %cl,%ebp
  800dff:	89 d1                	mov    %edx,%ecx
  800e01:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e05:	d3 e8                	shr    %cl,%eax
  800e07:	09 c5                	or     %eax,%ebp
  800e09:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e0d:	89 c1                	mov    %eax,%ecx
  800e0f:	d3 e7                	shl    %cl,%edi
  800e11:	89 d1                	mov    %edx,%ecx
  800e13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e17:	89 df                	mov    %ebx,%edi
  800e19:	d3 ef                	shr    %cl,%edi
  800e1b:	89 c1                	mov    %eax,%ecx
  800e1d:	89 f0                	mov    %esi,%eax
  800e1f:	d3 e3                	shl    %cl,%ebx
  800e21:	89 d1                	mov    %edx,%ecx
  800e23:	89 fa                	mov    %edi,%edx
  800e25:	d3 e8                	shr    %cl,%eax
  800e27:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e2c:	09 d8                	or     %ebx,%eax
  800e2e:	f7 f5                	div    %ebp
  800e30:	d3 e6                	shl    %cl,%esi
  800e32:	89 d1                	mov    %edx,%ecx
  800e34:	f7 64 24 08          	mull   0x8(%esp)
  800e38:	39 d1                	cmp    %edx,%ecx
  800e3a:	89 c3                	mov    %eax,%ebx
  800e3c:	89 d7                	mov    %edx,%edi
  800e3e:	72 06                	jb     800e46 <__umoddi3+0xa6>
  800e40:	75 0e                	jne    800e50 <__umoddi3+0xb0>
  800e42:	39 c6                	cmp    %eax,%esi
  800e44:	73 0a                	jae    800e50 <__umoddi3+0xb0>
  800e46:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e4a:	19 ea                	sbb    %ebp,%edx
  800e4c:	89 d7                	mov    %edx,%edi
  800e4e:	89 c3                	mov    %eax,%ebx
  800e50:	89 ca                	mov    %ecx,%edx
  800e52:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e57:	29 de                	sub    %ebx,%esi
  800e59:	19 fa                	sbb    %edi,%edx
  800e5b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e5f:	89 d0                	mov    %edx,%eax
  800e61:	d3 e0                	shl    %cl,%eax
  800e63:	89 d9                	mov    %ebx,%ecx
  800e65:	d3 ee                	shr    %cl,%esi
  800e67:	d3 ea                	shr    %cl,%edx
  800e69:	09 f0                	or     %esi,%eax
  800e6b:	83 c4 1c             	add    $0x1c,%esp
  800e6e:	5b                   	pop    %ebx
  800e6f:	5e                   	pop    %esi
  800e70:	5f                   	pop    %edi
  800e71:	5d                   	pop    %ebp
  800e72:	c3                   	ret    
  800e73:	90                   	nop
  800e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e78:	85 ff                	test   %edi,%edi
  800e7a:	89 f9                	mov    %edi,%ecx
  800e7c:	75 0b                	jne    800e89 <__umoddi3+0xe9>
  800e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e83:	31 d2                	xor    %edx,%edx
  800e85:	f7 f7                	div    %edi
  800e87:	89 c1                	mov    %eax,%ecx
  800e89:	89 d8                	mov    %ebx,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	f7 f1                	div    %ecx
  800e8f:	89 f0                	mov    %esi,%eax
  800e91:	f7 f1                	div    %ecx
  800e93:	e9 31 ff ff ff       	jmp    800dc9 <__umoddi3+0x29>
  800e98:	90                   	nop
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	39 dd                	cmp    %ebx,%ebp
  800ea2:	72 08                	jb     800eac <__umoddi3+0x10c>
  800ea4:	39 f7                	cmp    %esi,%edi
  800ea6:	0f 87 21 ff ff ff    	ja     800dcd <__umoddi3+0x2d>
  800eac:	89 da                	mov    %ebx,%edx
  800eae:	89 f0                	mov    %esi,%eax
  800eb0:	29 f8                	sub    %edi,%eax
  800eb2:	19 ea                	sbb    %ebp,%edx
  800eb4:	e9 14 ff ff ff       	jmp    800dcd <__umoddi3+0x2d>
