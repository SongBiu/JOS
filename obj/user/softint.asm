
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	57                   	push   %edi
  80003e:	56                   	push   %esi
  80003f:	53                   	push   %ebx
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	e8 50 00 00 00       	call   800098 <__x86.get_pc_thunk.bx>
  800048:	81 c3 b8 1f 00 00    	add    $0x1fb8,%ebx
  80004e:	8b 75 08             	mov    0x8(%ebp),%esi
  800051:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800054:	e8 f6 00 00 00       	call   80014f <sys_getenvid>
  800059:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800061:	c1 e0 05             	shl    $0x5,%eax
  800064:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80006a:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800070:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 f6                	test   %esi,%esi
  800074:	7e 08                	jle    80007e <libmain+0x44>
		binaryname = argv[0];
  800076:	8b 07                	mov    (%edi),%eax
  800078:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0f 00 00 00       	call   80009c <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5f                   	pop    %edi
  800096:	5d                   	pop    %ebp
  800097:	c3                   	ret    

00800098 <__x86.get_pc_thunk.bx>:
  800098:	8b 1c 24             	mov    (%esp),%ebx
  80009b:	c3                   	ret    

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	53                   	push   %ebx
  8000a0:	83 ec 10             	sub    $0x10,%esp
  8000a3:	e8 f0 ff ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  8000a8:	81 c3 58 1f 00 00    	add    $0x1f58,%ebx
	sys_env_destroy(0);
  8000ae:	6a 00                	push   $0x0
  8000b0:	e8 45 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 1c             	sub    $0x1c,%esp
  800103:	e8 66 00 00 00       	call   80016e <__x86.get_pc_thunk.ax>
  800108:	05 f8 1e 00 00       	add    $0x1ef8,%eax
  80010d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800110:	b9 00 00 00 00       	mov    $0x0,%ecx
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	b8 03 00 00 00       	mov    $0x3,%eax
  80011d:	89 cb                	mov    %ecx,%ebx
  80011f:	89 cf                	mov    %ecx,%edi
  800121:	89 ce                	mov    %ecx,%esi
  800123:	cd 30                	int    $0x30
	if(check && ret > 0)
  800125:	85 c0                	test   %eax,%eax
  800127:	7f 08                	jg     800131 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800129:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800131:	83 ec 0c             	sub    $0xc,%esp
  800134:	50                   	push   %eax
  800135:	6a 03                	push   $0x3
  800137:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013a:	8d 83 c6 ee ff ff    	lea    -0x113a(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	6a 26                	push   $0x26
  800143:	8d 83 e3 ee ff ff    	lea    -0x111d(%ebx),%eax
  800149:	50                   	push   %eax
  80014a:	e8 23 00 00 00       	call   800172 <_panic>

0080014f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <__x86.get_pc_thunk.ax>:
  80016e:	8b 04 24             	mov    (%esp),%eax
  800171:	c3                   	ret    

00800172 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
  800178:	83 ec 0c             	sub    $0xc,%esp
  80017b:	e8 18 ff ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  800180:	81 c3 80 1e 00 00    	add    $0x1e80,%ebx
	va_list ap;

	va_start(ap, fmt);
  800186:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800189:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80018f:	8b 38                	mov    (%eax),%edi
  800191:	e8 b9 ff ff ff       	call   80014f <sys_getenvid>
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	ff 75 0c             	pushl  0xc(%ebp)
  80019c:	ff 75 08             	pushl  0x8(%ebp)
  80019f:	57                   	push   %edi
  8001a0:	50                   	push   %eax
  8001a1:	8d 83 f4 ee ff ff    	lea    -0x110c(%ebx),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 d1 00 00 00       	call   80027e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ad:	83 c4 18             	add    $0x18,%esp
  8001b0:	56                   	push   %esi
  8001b1:	ff 75 10             	pushl  0x10(%ebp)
  8001b4:	e8 63 00 00 00       	call   80021c <vcprintf>
	cprintf("\n");
  8001b9:	8d 83 18 ef ff ff    	lea    -0x10e8(%ebx),%eax
  8001bf:	89 04 24             	mov    %eax,(%esp)
  8001c2:	e8 b7 00 00 00       	call   80027e <cprintf>
  8001c7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ca:	cc                   	int3   
  8001cb:	eb fd                	jmp    8001ca <_panic+0x58>

008001cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	e8 c1 fe ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  8001d7:	81 c3 29 1e 00 00    	add    $0x1e29,%ebx
  8001dd:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e0:	8b 16                	mov    (%esi),%edx
  8001e2:	8d 42 01             	lea    0x1(%edx),%eax
  8001e5:	89 06                	mov    %eax,(%esi)
  8001e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ea:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f3:	74 0b                	je     800200 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f5:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5e                   	pop    %esi
  8001fe:	5d                   	pop    %ebp
  8001ff:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	68 ff 00 00 00       	push   $0xff
  800208:	8d 46 08             	lea    0x8(%esi),%eax
  80020b:	50                   	push   %eax
  80020c:	e8 ac fe ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  800211:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb d9                	jmp    8001f5 <putch+0x28>

0080021c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	53                   	push   %ebx
  800220:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800226:	e8 6d fe ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  80022b:	81 c3 d5 1d 00 00    	add    $0x1dd5,%ebx
	struct printbuf b;

	b.idx = 0;
  800231:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800238:	00 00 00 
	b.cnt = 0;
  80023b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800242:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800245:	ff 75 0c             	pushl  0xc(%ebp)
  800248:	ff 75 08             	pushl  0x8(%ebp)
  80024b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800251:	50                   	push   %eax
  800252:	8d 83 cd e1 ff ff    	lea    -0x1e33(%ebx),%eax
  800258:	50                   	push   %eax
  800259:	e8 38 01 00 00       	call   800396 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025e:	83 c4 08             	add    $0x8,%esp
  800261:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800267:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026d:	50                   	push   %eax
  80026e:	e8 4a fe ff ff       	call   8000bd <sys_cputs>
	return b.cnt;
}
  800273:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800279:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800284:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800287:	50                   	push   %eax
  800288:	ff 75 08             	pushl  0x8(%ebp)
  80028b:	e8 8c ff ff ff       	call   80021c <vcprintf>
	va_end(ap);

	return cnt;
}
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	57                   	push   %edi
  800296:	56                   	push   %esi
  800297:	53                   	push   %ebx
  800298:	83 ec 2c             	sub    $0x2c,%esp
  80029b:	e8 63 06 00 00       	call   800903 <__x86.get_pc_thunk.cx>
  8002a0:	81 c1 60 1d 00 00    	add    $0x1d60,%ecx
  8002a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 09                	jb     8002d4 <printnum+0x42>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	0f 87 83 00 00 00    	ja     800357 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	ff 75 18             	pushl  0x18(%ebp)
  8002da:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e0:	53                   	push   %ebx
  8002e1:	ff 75 10             	pushl  0x10(%ebp)
  8002e4:	83 ec 08             	sub    $0x8,%esp
  8002e7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ea:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f0:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002f6:	e8 85 09 00 00       	call   800c80 <__udivdi3>
  8002fb:	83 c4 18             	add    $0x18,%esp
  8002fe:	52                   	push   %edx
  8002ff:	50                   	push   %eax
  800300:	89 f2                	mov    %esi,%edx
  800302:	89 f8                	mov    %edi,%eax
  800304:	e8 89 ff ff ff       	call   800292 <printnum>
  800309:	83 c4 20             	add    $0x20,%esp
  80030c:	eb 13                	jmp    800321 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030e:	83 ec 08             	sub    $0x8,%esp
  800311:	56                   	push   %esi
  800312:	ff 75 18             	pushl  0x18(%ebp)
  800315:	ff d7                	call   *%edi
  800317:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031a:	83 eb 01             	sub    $0x1,%ebx
  80031d:	85 db                	test   %ebx,%ebx
  80031f:	7f ed                	jg     80030e <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	56                   	push   %esi
  800325:	83 ec 04             	sub    $0x4,%esp
  800328:	ff 75 dc             	pushl  -0x24(%ebp)
  80032b:	ff 75 d8             	pushl  -0x28(%ebp)
  80032e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800331:	ff 75 d0             	pushl  -0x30(%ebp)
  800334:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800337:	89 f3                	mov    %esi,%ebx
  800339:	e8 62 0a 00 00       	call   800da0 <__umoddi3>
  80033e:	83 c4 14             	add    $0x14,%esp
  800341:	0f be 84 06 1a ef ff 	movsbl -0x10e6(%esi,%eax,1),%eax
  800348:	ff 
  800349:	50                   	push   %eax
  80034a:	ff d7                	call   *%edi
}
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    
  800357:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035a:	eb be                	jmp    80031a <printnum+0x88>

0080035c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800362:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800366:	8b 10                	mov    (%eax),%edx
  800368:	3b 50 04             	cmp    0x4(%eax),%edx
  80036b:	73 0a                	jae    800377 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800370:	89 08                	mov    %ecx,(%eax)
  800372:	8b 45 08             	mov    0x8(%ebp),%eax
  800375:	88 02                	mov    %al,(%edx)
}
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <printfmt>:
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800382:	50                   	push   %eax
  800383:	ff 75 10             	pushl  0x10(%ebp)
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	ff 75 08             	pushl  0x8(%ebp)
  80038c:	e8 05 00 00 00       	call   800396 <vprintfmt>
}
  800391:	83 c4 10             	add    $0x10,%esp
  800394:	c9                   	leave  
  800395:	c3                   	ret    

00800396 <vprintfmt>:
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	57                   	push   %edi
  80039a:	56                   	push   %esi
  80039b:	53                   	push   %ebx
  80039c:	83 ec 2c             	sub    $0x2c,%esp
  80039f:	e8 f4 fc ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  8003a4:	81 c3 5c 1c 00 00    	add    $0x1c5c,%ebx
  8003aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003ad:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003b4:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b6:	8d 77 01             	lea    0x1(%edi),%esi
  8003b9:	0f b6 07             	movzbl (%edi),%eax
  8003bc:	83 f8 25             	cmp    $0x25,%eax
  8003bf:	74 1c                	je     8003dd <vprintfmt+0x47>
			if (ch == '\0')
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	0f 84 b9 04 00 00    	je     800882 <.L21+0x20>
			putch(ch, putdat);
  8003c9:	83 ec 08             	sub    $0x8,%esp
  8003cc:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003cf:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003d2:	50                   	push   %eax
  8003d3:	ff 55 08             	call   *0x8(%ebp)
  8003d6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d9:	89 f7                	mov    %esi,%edi
  8003db:	eb d9                	jmp    8003b6 <vprintfmt+0x20>
		padc = ' ';
  8003dd:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003e1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003e8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003ef:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8d 7e 01             	lea    0x1(%esi),%edi
  800401:	0f b6 16             	movzbl (%esi),%edx
  800404:	8d 42 dd             	lea    -0x23(%edx),%eax
  800407:	3c 55                	cmp    $0x55,%al
  800409:	0f 87 53 04 00 00    	ja     800862 <.L21>
  80040f:	0f b6 c0             	movzbl %al,%eax
  800412:	89 d9                	mov    %ebx,%ecx
  800414:	03 8c 83 a8 ef ff ff 	add    -0x1058(%ebx,%eax,4),%ecx
  80041b:	ff e1                	jmp    *%ecx

0080041d <.L73>:
  80041d:	89 fe                	mov    %edi,%esi
			padc = '-';
  80041f:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800423:	eb d9                	jmp    8003fe <vprintfmt+0x68>

00800425 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	89 fe                	mov    %edi,%esi
			padc = '0';
  800427:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80042b:	eb d1                	jmp    8003fe <vprintfmt+0x68>

0080042d <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	0f b6 d2             	movzbl %dl,%edx
  800430:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800432:	b8 00 00 00 00       	mov    $0x0,%eax
  800437:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  80043a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800441:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800444:	8d 7a d0             	lea    -0x30(%edx),%edi
  800447:	83 ff 09             	cmp    $0x9,%edi
  80044a:	0f 87 94 00 00 00    	ja     8004e4 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800450:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800453:	eb e5                	jmp    80043a <.L28+0xd>

00800455 <.L25>:
			precision = va_arg(ap, int);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8d 40 04             	lea    0x4(%eax),%eax
  800463:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800466:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800468:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046c:	79 90                	jns    8003fe <vprintfmt+0x68>
				width = precision, precision = -1;
  80046e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800471:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800474:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80047b:	eb 81                	jmp    8003fe <vprintfmt+0x68>

0080047d <.L26>:
  80047d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800480:	85 c0                	test   %eax,%eax
  800482:	ba 00 00 00 00       	mov    $0x0,%edx
  800487:	0f 49 d0             	cmovns %eax,%edx
  80048a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	89 fe                	mov    %edi,%esi
  80048f:	e9 6a ff ff ff       	jmp    8003fe <vprintfmt+0x68>

00800494 <.L22>:
  800494:	89 fe                	mov    %edi,%esi
			altflag = 1;
  800496:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049d:	e9 5c ff ff ff       	jmp    8003fe <vprintfmt+0x68>

008004a2 <.L33>:
  8004a2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004a5:	83 f9 01             	cmp    $0x1,%ecx
  8004a8:	7e 16                	jle    8004c0 <.L33+0x1e>
		return va_arg(*ap, long long);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004b2:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004b5:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004bb:	e9 f6 fe ff ff       	jmp    8003b6 <vprintfmt+0x20>
	else if (lflag)
  8004c0:	85 c9                	test   %ecx,%ecx
  8004c2:	75 10                	jne    8004d4 <.L33+0x32>
		return va_arg(*ap, int);
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004cc:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004cf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d2:	eb e4                	jmp    8004b8 <.L33+0x16>
		return va_arg(*ap, long);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8b 00                	mov    (%eax),%eax
  8004d9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004dc:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e2:	eb d4                	jmp    8004b8 <.L33+0x16>
  8004e4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ea:	e9 79 ff ff ff       	jmp    800468 <.L25+0x13>

008004ef <.L32>:
			lflag++;
  8004ef:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8004f5:	e9 04 ff ff ff       	jmp    8003fe <vprintfmt+0x68>

008004fa <.L29>:
			putch(va_arg(ap, int), putdat);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 70 04             	lea    0x4(%eax),%esi
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	ff 75 0c             	pushl  0xc(%ebp)
  800506:	ff 30                	pushl  (%eax)
  800508:	ff 55 08             	call   *0x8(%ebp)
			break;
  80050b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80050e:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800511:	e9 a0 fe ff ff       	jmp    8003b6 <vprintfmt+0x20>

00800516 <.L31>:
			err = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 70 04             	lea    0x4(%eax),%esi
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	99                   	cltd   
  80051f:	31 d0                	xor    %edx,%eax
  800521:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800523:	83 f8 06             	cmp    $0x6,%eax
  800526:	7f 29                	jg     800551 <.L31+0x3b>
  800528:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  80052f:	85 d2                	test   %edx,%edx
  800531:	74 1e                	je     800551 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800533:	52                   	push   %edx
  800534:	8d 83 3b ef ff ff    	lea    -0x10c5(%ebx),%eax
  80053a:	50                   	push   %eax
  80053b:	ff 75 0c             	pushl  0xc(%ebp)
  80053e:	ff 75 08             	pushl  0x8(%ebp)
  800541:	e8 33 fe ff ff       	call   800379 <printfmt>
  800546:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800549:	89 75 14             	mov    %esi,0x14(%ebp)
  80054c:	e9 65 fe ff ff       	jmp    8003b6 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800551:	50                   	push   %eax
  800552:	8d 83 32 ef ff ff    	lea    -0x10ce(%ebx),%eax
  800558:	50                   	push   %eax
  800559:	ff 75 0c             	pushl  0xc(%ebp)
  80055c:	ff 75 08             	pushl  0x8(%ebp)
  80055f:	e8 15 fe ff ff       	call   800379 <printfmt>
  800564:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800567:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80056a:	e9 47 fe ff ff       	jmp    8003b6 <vprintfmt+0x20>

0080056f <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	83 c0 04             	add    $0x4,%eax
  800575:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80057d:	85 f6                	test   %esi,%esi
  80057f:	8d 83 2b ef ff ff    	lea    -0x10d5(%ebx),%eax
  800585:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800588:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058c:	0f 8e b4 00 00 00    	jle    800646 <.L36+0xd7>
  800592:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800596:	75 08                	jne    8005a0 <.L36+0x31>
  800598:	89 7d 10             	mov    %edi,0x10(%ebp)
  80059b:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80059e:	eb 6c                	jmp    80060c <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	ff 75 cc             	pushl  -0x34(%ebp)
  8005a6:	56                   	push   %esi
  8005a7:	e8 73 03 00 00       	call   80091f <strnlen>
  8005ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005af:	29 c2                	sub    %eax,%edx
  8005b1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005b4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005b7:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005bb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005be:	89 d6                	mov    %edx,%esi
  8005c0:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005c3:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c5:	eb 10                	jmp    8005d7 <.L36+0x68>
					putch(padc, putdat);
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	ff 75 0c             	pushl  0xc(%ebp)
  8005cd:	57                   	push   %edi
  8005ce:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	83 ee 01             	sub    $0x1,%esi
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	85 f6                	test   %esi,%esi
  8005d9:	7f ec                	jg     8005c7 <.L36+0x58>
  8005db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005de:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e1:	85 d2                	test   %edx,%edx
  8005e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e8:	0f 49 c2             	cmovns %edx,%eax
  8005eb:	29 c2                	sub    %eax,%edx
  8005ed:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005f3:	eb 17                	jmp    80060c <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8005f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f9:	75 30                	jne    80062b <.L36+0xbc>
					putch(ch, putdat);
  8005fb:	83 ec 08             	sub    $0x8,%esp
  8005fe:	ff 75 0c             	pushl  0xc(%ebp)
  800601:	50                   	push   %eax
  800602:	ff 55 08             	call   *0x8(%ebp)
  800605:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800608:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80060c:	83 c6 01             	add    $0x1,%esi
  80060f:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800613:	0f be c2             	movsbl %dl,%eax
  800616:	85 c0                	test   %eax,%eax
  800618:	74 58                	je     800672 <.L36+0x103>
  80061a:	85 ff                	test   %edi,%edi
  80061c:	78 d7                	js     8005f5 <.L36+0x86>
  80061e:	83 ef 01             	sub    $0x1,%edi
  800621:	79 d2                	jns    8005f5 <.L36+0x86>
  800623:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800626:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800629:	eb 32                	jmp    80065d <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  80062b:	0f be d2             	movsbl %dl,%edx
  80062e:	83 ea 20             	sub    $0x20,%edx
  800631:	83 fa 5e             	cmp    $0x5e,%edx
  800634:	76 c5                	jbe    8005fb <.L36+0x8c>
					putch('?', putdat);
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	ff 75 0c             	pushl  0xc(%ebp)
  80063c:	6a 3f                	push   $0x3f
  80063e:	ff 55 08             	call   *0x8(%ebp)
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb c2                	jmp    800608 <.L36+0x99>
  800646:	89 7d 10             	mov    %edi,0x10(%ebp)
  800649:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80064c:	eb be                	jmp    80060c <.L36+0x9d>
				putch(' ', putdat);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	57                   	push   %edi
  800652:	6a 20                	push   $0x20
  800654:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800657:	83 ee 01             	sub    $0x1,%esi
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	85 f6                	test   %esi,%esi
  80065f:	7f ed                	jg     80064e <.L36+0xdf>
  800661:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800664:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800667:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80066a:	89 45 14             	mov    %eax,0x14(%ebp)
  80066d:	e9 44 fd ff ff       	jmp    8003b6 <vprintfmt+0x20>
  800672:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800675:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800678:	eb e3                	jmp    80065d <.L36+0xee>

0080067a <.L30>:
  80067a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80067d:	83 f9 01             	cmp    $0x1,%ecx
  800680:	7e 42                	jle    8006c4 <.L30+0x4a>
		return va_arg(*ap, long long);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 50 04             	mov    0x4(%eax),%edx
  800688:	8b 00                	mov    (%eax),%eax
  80068a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 40 08             	lea    0x8(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800699:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069d:	79 5f                	jns    8006fe <.L30+0x84>
				putch('-', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	ff 75 0c             	pushl  0xc(%ebp)
  8006a5:	6a 2d                	push   $0x2d
  8006a7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006aa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ad:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b0:	f7 da                	neg    %edx
  8006b2:	83 d1 00             	adc    $0x0,%ecx
  8006b5:	f7 d9                	neg    %ecx
  8006b7:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006ba:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bf:	e9 b8 00 00 00       	jmp    80077c <.L34+0x22>
	else if (lflag)
  8006c4:	85 c9                	test   %ecx,%ecx
  8006c6:	75 1b                	jne    8006e3 <.L30+0x69>
		return va_arg(*ap, int);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 30                	mov    (%eax),%esi
  8006cd:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	c1 f8 1f             	sar    $0x1f,%eax
  8006d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e1:	eb b6                	jmp    800699 <.L30+0x1f>
		return va_arg(*ap, long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 30                	mov    (%eax),%esi
  8006e8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	c1 f8 1f             	sar    $0x1f,%eax
  8006f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8d 40 04             	lea    0x4(%eax),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006fc:	eb 9b                	jmp    800699 <.L30+0x1f>
			num = getint(&ap, lflag);
  8006fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800701:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800704:	b8 0a 00 00 00       	mov    $0xa,%eax
  800709:	eb 71                	jmp    80077c <.L34+0x22>

0080070b <.L37>:
  80070b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80070e:	83 f9 01             	cmp    $0x1,%ecx
  800711:	7e 15                	jle    800728 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8b 10                	mov    (%eax),%edx
  800718:	8b 48 04             	mov    0x4(%eax),%ecx
  80071b:	8d 40 08             	lea    0x8(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800721:	b8 0a 00 00 00       	mov    $0xa,%eax
  800726:	eb 54                	jmp    80077c <.L34+0x22>
	else if (lflag)
  800728:	85 c9                	test   %ecx,%ecx
  80072a:	75 17                	jne    800743 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 10                	mov    (%eax),%edx
  800731:	b9 00 00 00 00       	mov    $0x0,%ecx
  800736:	8d 40 04             	lea    0x4(%eax),%eax
  800739:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800741:	eb 39                	jmp    80077c <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8b 10                	mov    (%eax),%edx
  800748:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074d:	8d 40 04             	lea    0x4(%eax),%eax
  800750:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800753:	b8 0a 00 00 00       	mov    $0xa,%eax
  800758:	eb 22                	jmp    80077c <.L34+0x22>

0080075a <.L34>:
  80075a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80075d:	83 f9 01             	cmp    $0x1,%ecx
  800760:	7e 3b                	jle    80079d <.L34+0x43>
		return va_arg(*ap, long long);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 50 04             	mov    0x4(%eax),%edx
  800768:	8b 00                	mov    (%eax),%eax
  80076a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80076d:	8d 49 08             	lea    0x8(%ecx),%ecx
  800770:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800773:	89 d1                	mov    %edx,%ecx
  800775:	89 c2                	mov    %eax,%edx
			base = 8;
  800777:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80077c:	83 ec 0c             	sub    $0xc,%esp
  80077f:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800783:	56                   	push   %esi
  800784:	ff 75 e0             	pushl  -0x20(%ebp)
  800787:	50                   	push   %eax
  800788:	51                   	push   %ecx
  800789:	52                   	push   %edx
  80078a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	e8 fd fa ff ff       	call   800292 <printnum>
			break;
  800795:	83 c4 20             	add    $0x20,%esp
  800798:	e9 19 fc ff ff       	jmp    8003b6 <vprintfmt+0x20>
	else if (lflag)
  80079d:	85 c9                	test   %ecx,%ecx
  80079f:	75 13                	jne    8007b4 <.L34+0x5a>
		return va_arg(*ap, int);
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8b 10                	mov    (%eax),%edx
  8007a6:	89 d0                	mov    %edx,%eax
  8007a8:	99                   	cltd   
  8007a9:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007ac:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007af:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b2:	eb bf                	jmp    800773 <.L34+0x19>
		return va_arg(*ap, long);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8b 10                	mov    (%eax),%edx
  8007b9:	89 d0                	mov    %edx,%eax
  8007bb:	99                   	cltd   
  8007bc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007bf:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007c2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007c5:	eb ac                	jmp    800773 <.L34+0x19>

008007c7 <.L35>:
			putch('0', putdat);
  8007c7:	83 ec 08             	sub    $0x8,%esp
  8007ca:	ff 75 0c             	pushl  0xc(%ebp)
  8007cd:	6a 30                	push   $0x30
  8007cf:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d2:	83 c4 08             	add    $0x8,%esp
  8007d5:	ff 75 0c             	pushl  0xc(%ebp)
  8007d8:	6a 78                	push   $0x78
  8007da:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007e7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007ea:	8d 40 04             	lea    0x4(%eax),%eax
  8007ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f5:	eb 85                	jmp    80077c <.L34+0x22>

008007f7 <.L38>:
  8007f7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8007fa:	83 f9 01             	cmp    $0x1,%ecx
  8007fd:	7e 18                	jle    800817 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 10                	mov    (%eax),%edx
  800804:	8b 48 04             	mov    0x4(%eax),%ecx
  800807:	8d 40 08             	lea    0x8(%eax),%eax
  80080a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080d:	b8 10 00 00 00       	mov    $0x10,%eax
  800812:	e9 65 ff ff ff       	jmp    80077c <.L34+0x22>
	else if (lflag)
  800817:	85 c9                	test   %ecx,%ecx
  800819:	75 1a                	jne    800835 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	8b 10                	mov    (%eax),%edx
  800820:	b9 00 00 00 00       	mov    $0x0,%ecx
  800825:	8d 40 04             	lea    0x4(%eax),%eax
  800828:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082b:	b8 10 00 00 00       	mov    $0x10,%eax
  800830:	e9 47 ff ff ff       	jmp    80077c <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083f:	8d 40 04             	lea    0x4(%eax),%eax
  800842:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800845:	b8 10 00 00 00       	mov    $0x10,%eax
  80084a:	e9 2d ff ff ff       	jmp    80077c <.L34+0x22>

0080084f <.L24>:
			putch(ch, putdat);
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	ff 75 0c             	pushl  0xc(%ebp)
  800855:	6a 25                	push   $0x25
  800857:	ff 55 08             	call   *0x8(%ebp)
			break;
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	e9 54 fb ff ff       	jmp    8003b6 <vprintfmt+0x20>

00800862 <.L21>:
			putch('%', putdat);
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	ff 75 0c             	pushl  0xc(%ebp)
  800868:	6a 25                	push   $0x25
  80086a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	89 f7                	mov    %esi,%edi
  800872:	eb 03                	jmp    800877 <.L21+0x15>
  800874:	83 ef 01             	sub    $0x1,%edi
  800877:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80087b:	75 f7                	jne    800874 <.L21+0x12>
  80087d:	e9 34 fb ff ff       	jmp    8003b6 <vprintfmt+0x20>
}
  800882:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800885:	5b                   	pop    %ebx
  800886:	5e                   	pop    %esi
  800887:	5f                   	pop    %edi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	83 ec 14             	sub    $0x14,%esp
  800891:	e8 02 f8 ff ff       	call   800098 <__x86.get_pc_thunk.bx>
  800896:	81 c3 6a 17 00 00    	add    $0x176a,%ebx
  80089c:	8b 45 08             	mov    0x8(%ebp),%eax
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	74 2b                	je     8008e2 <vsnprintf+0x58>
  8008b7:	85 d2                	test   %edx,%edx
  8008b9:	7e 27                	jle    8008e2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008bb:	ff 75 14             	pushl  0x14(%ebp)
  8008be:	ff 75 10             	pushl  0x10(%ebp)
  8008c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c4:	50                   	push   %eax
  8008c5:	8d 83 5c e3 ff ff    	lea    -0x1ca4(%ebx),%eax
  8008cb:	50                   	push   %eax
  8008cc:	e8 c5 fa ff ff       	call   800396 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008da:	83 c4 10             	add    $0x10,%esp
}
  8008dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e0:	c9                   	leave  
  8008e1:	c3                   	ret    
		return -E_INVAL;
  8008e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e7:	eb f4                	jmp    8008dd <vsnprintf+0x53>

008008e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f2:	50                   	push   %eax
  8008f3:	ff 75 10             	pushl  0x10(%ebp)
  8008f6:	ff 75 0c             	pushl  0xc(%ebp)
  8008f9:	ff 75 08             	pushl  0x8(%ebp)
  8008fc:	e8 89 ff ff ff       	call   80088a <vsnprintf>
	va_end(ap);

	return rc;
}
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <__x86.get_pc_thunk.cx>:
  800903:	8b 0c 24             	mov    (%esp),%ecx
  800906:	c3                   	ret    

00800907 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
  800912:	eb 03                	jmp    800917 <strlen+0x10>
		n++;
  800914:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800917:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091b:	75 f7                	jne    800914 <strlen+0xd>
	return n;
}
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	eb 03                	jmp    800932 <strnlen+0x13>
		n++;
  80092f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800932:	39 d0                	cmp    %edx,%eax
  800934:	74 06                	je     80093c <strnlen+0x1d>
  800936:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80093a:	75 f3                	jne    80092f <strnlen+0x10>
	return n;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800948:	89 c2                	mov    %eax,%edx
  80094a:	83 c1 01             	add    $0x1,%ecx
  80094d:	83 c2 01             	add    $0x1,%edx
  800950:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800954:	88 5a ff             	mov    %bl,-0x1(%edx)
  800957:	84 db                	test   %bl,%bl
  800959:	75 ef                	jne    80094a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80095b:	5b                   	pop    %ebx
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	53                   	push   %ebx
  800962:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800965:	53                   	push   %ebx
  800966:	e8 9c ff ff ff       	call   800907 <strlen>
  80096b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80096e:	ff 75 0c             	pushl  0xc(%ebp)
  800971:	01 d8                	add    %ebx,%eax
  800973:	50                   	push   %eax
  800974:	e8 c5 ff ff ff       	call   80093e <strcpy>
	return dst;
}
  800979:	89 d8                	mov    %ebx,%eax
  80097b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 75 08             	mov    0x8(%ebp),%esi
  800988:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098b:	89 f3                	mov    %esi,%ebx
  80098d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800990:	89 f2                	mov    %esi,%edx
  800992:	eb 0f                	jmp    8009a3 <strncpy+0x23>
		*dst++ = *src;
  800994:	83 c2 01             	add    $0x1,%edx
  800997:	0f b6 01             	movzbl (%ecx),%eax
  80099a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099d:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a0:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009a3:	39 da                	cmp    %ebx,%edx
  8009a5:	75 ed                	jne    800994 <strncpy+0x14>
	}
	return ret;
}
  8009a7:	89 f0                	mov    %esi,%eax
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009bb:	89 f0                	mov    %esi,%eax
  8009bd:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c1:	85 c9                	test   %ecx,%ecx
  8009c3:	75 0b                	jne    8009d0 <strlcpy+0x23>
  8009c5:	eb 17                	jmp    8009de <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c7:	83 c2 01             	add    $0x1,%edx
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009d0:	39 d8                	cmp    %ebx,%eax
  8009d2:	74 07                	je     8009db <strlcpy+0x2e>
  8009d4:	0f b6 0a             	movzbl (%edx),%ecx
  8009d7:	84 c9                	test   %cl,%cl
  8009d9:	75 ec                	jne    8009c7 <strlcpy+0x1a>
		*dst = '\0';
  8009db:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009de:	29 f0                	sub    %esi,%eax
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ed:	eb 06                	jmp    8009f5 <strcmp+0x11>
		p++, q++;
  8009ef:	83 c1 01             	add    $0x1,%ecx
  8009f2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009f5:	0f b6 01             	movzbl (%ecx),%eax
  8009f8:	84 c0                	test   %al,%al
  8009fa:	74 04                	je     800a00 <strcmp+0x1c>
  8009fc:	3a 02                	cmp    (%edx),%al
  8009fe:	74 ef                	je     8009ef <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a00:	0f b6 c0             	movzbl %al,%eax
  800a03:	0f b6 12             	movzbl (%edx),%edx
  800a06:	29 d0                	sub    %edx,%eax
}
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	53                   	push   %ebx
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a14:	89 c3                	mov    %eax,%ebx
  800a16:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a19:	eb 06                	jmp    800a21 <strncmp+0x17>
		n--, p++, q++;
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a21:	39 d8                	cmp    %ebx,%eax
  800a23:	74 16                	je     800a3b <strncmp+0x31>
  800a25:	0f b6 08             	movzbl (%eax),%ecx
  800a28:	84 c9                	test   %cl,%cl
  800a2a:	74 04                	je     800a30 <strncmp+0x26>
  800a2c:	3a 0a                	cmp    (%edx),%cl
  800a2e:	74 eb                	je     800a1b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a30:	0f b6 00             	movzbl (%eax),%eax
  800a33:	0f b6 12             	movzbl (%edx),%edx
  800a36:	29 d0                	sub    %edx,%eax
}
  800a38:	5b                   	pop    %ebx
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    
		return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a40:	eb f6                	jmp    800a38 <strncmp+0x2e>

00800a42 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4c:	0f b6 10             	movzbl (%eax),%edx
  800a4f:	84 d2                	test   %dl,%dl
  800a51:	74 09                	je     800a5c <strchr+0x1a>
		if (*s == c)
  800a53:	38 ca                	cmp    %cl,%dl
  800a55:	74 0a                	je     800a61 <strchr+0x1f>
	for (; *s; s++)
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	eb f0                	jmp    800a4c <strchr+0xa>
			return (char *) s;
	return 0;
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6d:	eb 03                	jmp    800a72 <strfind+0xf>
  800a6f:	83 c0 01             	add    $0x1,%eax
  800a72:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a75:	38 ca                	cmp    %cl,%dl
  800a77:	74 04                	je     800a7d <strfind+0x1a>
  800a79:	84 d2                	test   %dl,%dl
  800a7b:	75 f2                	jne    800a6f <strfind+0xc>
			break;
	return (char *) s;
}
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8b:	85 c9                	test   %ecx,%ecx
  800a8d:	74 13                	je     800aa2 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a95:	75 05                	jne    800a9c <memset+0x1d>
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	74 0d                	je     800aa9 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9f:	fc                   	cld    
  800aa0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa2:	89 f8                	mov    %edi,%eax
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    
		c &= 0xFF;
  800aa9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	c1 e3 08             	shl    $0x8,%ebx
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	c1 e0 18             	shl    $0x18,%eax
  800ab7:	89 d6                	mov    %edx,%esi
  800ab9:	c1 e6 10             	shl    $0x10,%esi
  800abc:	09 f0                	or     %esi,%eax
  800abe:	09 c2                	or     %eax,%edx
  800ac0:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ac5:	89 d0                	mov    %edx,%eax
  800ac7:	fc                   	cld    
  800ac8:	f3 ab                	rep stos %eax,%es:(%edi)
  800aca:	eb d6                	jmp    800aa2 <memset+0x23>

00800acc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ada:	39 c6                	cmp    %eax,%esi
  800adc:	73 35                	jae    800b13 <memmove+0x47>
  800ade:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae1:	39 c2                	cmp    %eax,%edx
  800ae3:	76 2e                	jbe    800b13 <memmove+0x47>
		s += n;
		d += n;
  800ae5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae8:	89 d6                	mov    %edx,%esi
  800aea:	09 fe                	or     %edi,%esi
  800aec:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af2:	74 0c                	je     800b00 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af4:	83 ef 01             	sub    $0x1,%edi
  800af7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800afa:	fd                   	std    
  800afb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800afd:	fc                   	cld    
  800afe:	eb 21                	jmp    800b21 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b00:	f6 c1 03             	test   $0x3,%cl
  800b03:	75 ef                	jne    800af4 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b05:	83 ef 04             	sub    $0x4,%edi
  800b08:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b0e:	fd                   	std    
  800b0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b11:	eb ea                	jmp    800afd <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b13:	89 f2                	mov    %esi,%edx
  800b15:	09 c2                	or     %eax,%edx
  800b17:	f6 c2 03             	test   $0x3,%dl
  800b1a:	74 09                	je     800b25 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b1c:	89 c7                	mov    %eax,%edi
  800b1e:	fc                   	cld    
  800b1f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b25:	f6 c1 03             	test   $0x3,%cl
  800b28:	75 f2                	jne    800b1c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b2d:	89 c7                	mov    %eax,%edi
  800b2f:	fc                   	cld    
  800b30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b32:	eb ed                	jmp    800b21 <memmove+0x55>

00800b34 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b37:	ff 75 10             	pushl  0x10(%ebp)
  800b3a:	ff 75 0c             	pushl  0xc(%ebp)
  800b3d:	ff 75 08             	pushl  0x8(%ebp)
  800b40:	e8 87 ff ff ff       	call   800acc <memmove>
}
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b52:	89 c6                	mov    %eax,%esi
  800b54:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b57:	39 f0                	cmp    %esi,%eax
  800b59:	74 1c                	je     800b77 <memcmp+0x30>
		if (*s1 != *s2)
  800b5b:	0f b6 08             	movzbl (%eax),%ecx
  800b5e:	0f b6 1a             	movzbl (%edx),%ebx
  800b61:	38 d9                	cmp    %bl,%cl
  800b63:	75 08                	jne    800b6d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b65:	83 c0 01             	add    $0x1,%eax
  800b68:	83 c2 01             	add    $0x1,%edx
  800b6b:	eb ea                	jmp    800b57 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b6d:	0f b6 c1             	movzbl %cl,%eax
  800b70:	0f b6 db             	movzbl %bl,%ebx
  800b73:	29 d8                	sub    %ebx,%eax
  800b75:	eb 05                	jmp    800b7c <memcmp+0x35>
	}

	return 0;
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	8b 45 08             	mov    0x8(%ebp),%eax
  800b86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b89:	89 c2                	mov    %eax,%edx
  800b8b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8e:	39 d0                	cmp    %edx,%eax
  800b90:	73 09                	jae    800b9b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b92:	38 08                	cmp    %cl,(%eax)
  800b94:	74 05                	je     800b9b <memfind+0x1b>
	for (; s < ends; s++)
  800b96:	83 c0 01             	add    $0x1,%eax
  800b99:	eb f3                	jmp    800b8e <memfind+0xe>
			break;
	return (void *) s;
}
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba9:	eb 03                	jmp    800bae <strtol+0x11>
		s++;
  800bab:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bae:	0f b6 01             	movzbl (%ecx),%eax
  800bb1:	3c 20                	cmp    $0x20,%al
  800bb3:	74 f6                	je     800bab <strtol+0xe>
  800bb5:	3c 09                	cmp    $0x9,%al
  800bb7:	74 f2                	je     800bab <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bb9:	3c 2b                	cmp    $0x2b,%al
  800bbb:	74 2e                	je     800beb <strtol+0x4e>
	int neg = 0;
  800bbd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bc2:	3c 2d                	cmp    $0x2d,%al
  800bc4:	74 2f                	je     800bf5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bcc:	75 05                	jne    800bd3 <strtol+0x36>
  800bce:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd1:	74 2c                	je     800bff <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd3:	85 db                	test   %ebx,%ebx
  800bd5:	75 0a                	jne    800be1 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd7:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bdc:	80 39 30             	cmpb   $0x30,(%ecx)
  800bdf:	74 28                	je     800c09 <strtol+0x6c>
		base = 10;
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800be9:	eb 50                	jmp    800c3b <strtol+0x9e>
		s++;
  800beb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bee:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf3:	eb d1                	jmp    800bc6 <strtol+0x29>
		s++, neg = 1;
  800bf5:	83 c1 01             	add    $0x1,%ecx
  800bf8:	bf 01 00 00 00       	mov    $0x1,%edi
  800bfd:	eb c7                	jmp    800bc6 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bff:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c03:	74 0e                	je     800c13 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c05:	85 db                	test   %ebx,%ebx
  800c07:	75 d8                	jne    800be1 <strtol+0x44>
		s++, base = 8;
  800c09:	83 c1 01             	add    $0x1,%ecx
  800c0c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c11:	eb ce                	jmp    800be1 <strtol+0x44>
		s += 2, base = 16;
  800c13:	83 c1 02             	add    $0x2,%ecx
  800c16:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c1b:	eb c4                	jmp    800be1 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c1d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c20:	89 f3                	mov    %esi,%ebx
  800c22:	80 fb 19             	cmp    $0x19,%bl
  800c25:	77 29                	ja     800c50 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c27:	0f be d2             	movsbl %dl,%edx
  800c2a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c2d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c30:	7d 30                	jge    800c62 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c32:	83 c1 01             	add    $0x1,%ecx
  800c35:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c39:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c3b:	0f b6 11             	movzbl (%ecx),%edx
  800c3e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c41:	89 f3                	mov    %esi,%ebx
  800c43:	80 fb 09             	cmp    $0x9,%bl
  800c46:	77 d5                	ja     800c1d <strtol+0x80>
			dig = *s - '0';
  800c48:	0f be d2             	movsbl %dl,%edx
  800c4b:	83 ea 30             	sub    $0x30,%edx
  800c4e:	eb dd                	jmp    800c2d <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c50:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c53:	89 f3                	mov    %esi,%ebx
  800c55:	80 fb 19             	cmp    $0x19,%bl
  800c58:	77 08                	ja     800c62 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c5a:	0f be d2             	movsbl %dl,%edx
  800c5d:	83 ea 37             	sub    $0x37,%edx
  800c60:	eb cb                	jmp    800c2d <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c66:	74 05                	je     800c6d <strtol+0xd0>
		*endptr = (char *) s;
  800c68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c6d:	89 c2                	mov    %eax,%edx
  800c6f:	f7 da                	neg    %edx
  800c71:	85 ff                	test   %edi,%edi
  800c73:	0f 45 c2             	cmovne %edx,%eax
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    
  800c7b:	66 90                	xchg   %ax,%ax
  800c7d:	66 90                	xchg   %ax,%ax
  800c7f:	90                   	nop

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
