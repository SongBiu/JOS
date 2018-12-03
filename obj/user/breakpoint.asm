
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 0c             	sub    $0xc,%esp
  800042:	e8 50 00 00 00       	call   800097 <__x86.get_pc_thunk.bx>
  800047:	81 c3 b9 1f 00 00    	add    $0x1fb9,%ebx
  80004d:	8b 75 08             	mov    0x8(%ebp),%esi
  800050:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800053:	e8 f6 00 00 00       	call   80014e <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800060:	c1 e0 05             	shl    $0x5,%eax
  800063:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800069:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  80006f:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 f6                	test   %esi,%esi
  800073:	7e 08                	jle    80007d <libmain+0x44>
		binaryname = argv[0];
  800075:	8b 07                	mov    (%edi),%eax
  800077:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80007d:	83 ec 08             	sub    $0x8,%esp
  800080:	57                   	push   %edi
  800081:	56                   	push   %esi
  800082:	e8 ac ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800087:	e8 0f 00 00 00       	call   80009b <exit>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <__x86.get_pc_thunk.bx>:
  800097:	8b 1c 24             	mov    (%esp),%ebx
  80009a:	c3                   	ret    

0080009b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	53                   	push   %ebx
  80009f:	83 ec 10             	sub    $0x10,%esp
  8000a2:	e8 f0 ff ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  8000a7:	81 c3 59 1f 00 00    	add    $0x1f59,%ebx
	sys_env_destroy(0);
  8000ad:	6a 00                	push   $0x0
  8000af:	e8 45 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ea:	89 d1                	mov    %edx,%ecx
  8000ec:	89 d3                	mov    %edx,%ebx
  8000ee:	89 d7                	mov    %edx,%edi
  8000f0:	89 d6                	mov    %edx,%esi
  8000f2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	83 ec 1c             	sub    $0x1c,%esp
  800102:	e8 66 00 00 00       	call   80016d <__x86.get_pc_thunk.ax>
  800107:	05 f9 1e 00 00       	add    $0x1ef9,%eax
  80010c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80010f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	89 cb                	mov    %ecx,%ebx
  80011e:	89 cf                	mov    %ecx,%edi
  800120:	89 ce                	mov    %ecx,%esi
  800122:	cd 30                	int    $0x30
	if(check && ret > 0)
  800124:	85 c0                	test   %eax,%eax
  800126:	7f 08                	jg     800130 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800128:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012b:	5b                   	pop    %ebx
  80012c:	5e                   	pop    %esi
  80012d:	5f                   	pop    %edi
  80012e:	5d                   	pop    %ebp
  80012f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800130:	83 ec 0c             	sub    $0xc,%esp
  800133:	50                   	push   %eax
  800134:	6a 03                	push   $0x3
  800136:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800139:	8d 83 c6 ee ff ff    	lea    -0x113a(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	6a 26                	push   $0x26
  800142:	8d 83 e3 ee ff ff    	lea    -0x111d(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 23 00 00 00       	call   800171 <_panic>

0080014e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	asm volatile("int %1\n"
  800154:	ba 00 00 00 00       	mov    $0x0,%edx
  800159:	b8 02 00 00 00       	mov    $0x2,%eax
  80015e:	89 d1                	mov    %edx,%ecx
  800160:	89 d3                	mov    %edx,%ebx
  800162:	89 d7                	mov    %edx,%edi
  800164:	89 d6                	mov    %edx,%esi
  800166:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <__x86.get_pc_thunk.ax>:
  80016d:	8b 04 24             	mov    (%esp),%eax
  800170:	c3                   	ret    

00800171 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	57                   	push   %edi
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	e8 18 ff ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  80017f:	81 c3 81 1e 00 00    	add    $0x1e81,%ebx
	va_list ap;

	va_start(ap, fmt);
  800185:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800188:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80018e:	8b 38                	mov    (%eax),%edi
  800190:	e8 b9 ff ff ff       	call   80014e <sys_getenvid>
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 0c             	pushl  0xc(%ebp)
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	57                   	push   %edi
  80019f:	50                   	push   %eax
  8001a0:	8d 83 f4 ee ff ff    	lea    -0x110c(%ebx),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 d1 00 00 00       	call   80027d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ac:	83 c4 18             	add    $0x18,%esp
  8001af:	56                   	push   %esi
  8001b0:	ff 75 10             	pushl  0x10(%ebp)
  8001b3:	e8 63 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001b8:	8d 83 18 ef ff ff    	lea    -0x10e8(%ebx),%eax
  8001be:	89 04 24             	mov    %eax,(%esp)
  8001c1:	e8 b7 00 00 00       	call   80027d <cprintf>
  8001c6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001c9:	cc                   	int3   
  8001ca:	eb fd                	jmp    8001c9 <_panic+0x58>

008001cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	e8 c1 fe ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  8001d6:	81 c3 2a 1e 00 00    	add    $0x1e2a,%ebx
  8001dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001df:	8b 16                	mov    (%esi),%edx
  8001e1:	8d 42 01             	lea    0x1(%edx),%eax
  8001e4:	89 06                	mov    %eax,(%esi)
  8001e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e9:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001ed:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f2:	74 0b                	je     8001ff <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f4:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	68 ff 00 00 00       	push   $0xff
  800207:	8d 46 08             	lea    0x8(%esi),%eax
  80020a:	50                   	push   %eax
  80020b:	e8 ac fe ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  800210:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800216:	83 c4 10             	add    $0x10,%esp
  800219:	eb d9                	jmp    8001f4 <putch+0x28>

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	53                   	push   %ebx
  80021f:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800225:	e8 6d fe ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  80022a:	81 c3 d6 1d 00 00    	add    $0x1dd6,%ebx
	struct printbuf b;

	b.idx = 0;
  800230:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800237:	00 00 00 
	b.cnt = 0;
  80023a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800241:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800244:	ff 75 0c             	pushl  0xc(%ebp)
  800247:	ff 75 08             	pushl  0x8(%ebp)
  80024a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800250:	50                   	push   %eax
  800251:	8d 83 cc e1 ff ff    	lea    -0x1e34(%ebx),%eax
  800257:	50                   	push   %eax
  800258:	e8 38 01 00 00       	call   800395 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025d:	83 c4 08             	add    $0x8,%esp
  800260:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800266:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026c:	50                   	push   %eax
  80026d:	e8 4a fe ff ff       	call   8000bc <sys_cputs>
	return b.cnt;
}
  800272:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800278:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800283:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800286:	50                   	push   %eax
  800287:	ff 75 08             	pushl  0x8(%ebp)
  80028a:	e8 8c ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 2c             	sub    $0x2c,%esp
  80029a:	e8 63 06 00 00       	call   800902 <__x86.get_pc_thunk.cx>
  80029f:	81 c1 61 1d 00 00    	add    $0x1d61,%ecx
  8002a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002a8:	89 c7                	mov    %eax,%edi
  8002aa:	89 d6                	mov    %edx,%esi
  8002ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8002af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002b5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c3:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002c6:	39 d3                	cmp    %edx,%ebx
  8002c8:	72 09                	jb     8002d3 <printnum+0x42>
  8002ca:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002cd:	0f 87 83 00 00 00    	ja     800356 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	ff 75 18             	pushl  0x18(%ebp)
  8002d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002df:	53                   	push   %ebx
  8002e0:	ff 75 10             	pushl  0x10(%ebp)
  8002e3:	83 ec 08             	sub    $0x8,%esp
  8002e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002f5:	e8 86 09 00 00       	call   800c80 <__udivdi3>
  8002fa:	83 c4 18             	add    $0x18,%esp
  8002fd:	52                   	push   %edx
  8002fe:	50                   	push   %eax
  8002ff:	89 f2                	mov    %esi,%edx
  800301:	89 f8                	mov    %edi,%eax
  800303:	e8 89 ff ff ff       	call   800291 <printnum>
  800308:	83 c4 20             	add    $0x20,%esp
  80030b:	eb 13                	jmp    800320 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030d:	83 ec 08             	sub    $0x8,%esp
  800310:	56                   	push   %esi
  800311:	ff 75 18             	pushl  0x18(%ebp)
  800314:	ff d7                	call   *%edi
  800316:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800319:	83 eb 01             	sub    $0x1,%ebx
  80031c:	85 db                	test   %ebx,%ebx
  80031e:	7f ed                	jg     80030d <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800320:	83 ec 08             	sub    $0x8,%esp
  800323:	56                   	push   %esi
  800324:	83 ec 04             	sub    $0x4,%esp
  800327:	ff 75 dc             	pushl  -0x24(%ebp)
  80032a:	ff 75 d8             	pushl  -0x28(%ebp)
  80032d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800330:	ff 75 d0             	pushl  -0x30(%ebp)
  800333:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800336:	89 f3                	mov    %esi,%ebx
  800338:	e8 63 0a 00 00       	call   800da0 <__umoddi3>
  80033d:	83 c4 14             	add    $0x14,%esp
  800340:	0f be 84 06 1a ef ff 	movsbl -0x10e6(%esi,%eax,1),%eax
  800347:	ff 
  800348:	50                   	push   %eax
  800349:	ff d7                	call   *%edi
}
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    
  800356:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800359:	eb be                	jmp    800319 <printnum+0x88>

0080035b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800361:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800365:	8b 10                	mov    (%eax),%edx
  800367:	3b 50 04             	cmp    0x4(%eax),%edx
  80036a:	73 0a                	jae    800376 <sprintputch+0x1b>
		*b->buf++ = ch;
  80036c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036f:	89 08                	mov    %ecx,(%eax)
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	88 02                	mov    %al,(%edx)
}
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    

00800378 <printfmt>:
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800381:	50                   	push   %eax
  800382:	ff 75 10             	pushl  0x10(%ebp)
  800385:	ff 75 0c             	pushl  0xc(%ebp)
  800388:	ff 75 08             	pushl  0x8(%ebp)
  80038b:	e8 05 00 00 00       	call   800395 <vprintfmt>
}
  800390:	83 c4 10             	add    $0x10,%esp
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <vprintfmt>:
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	57                   	push   %edi
  800399:	56                   	push   %esi
  80039a:	53                   	push   %ebx
  80039b:	83 ec 2c             	sub    $0x2c,%esp
  80039e:	e8 f4 fc ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  8003a3:	81 c3 5d 1c 00 00    	add    $0x1c5d,%ebx
  8003a9:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003ac:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003b3:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b5:	8d 77 01             	lea    0x1(%edi),%esi
  8003b8:	0f b6 07             	movzbl (%edi),%eax
  8003bb:	83 f8 25             	cmp    $0x25,%eax
  8003be:	74 1c                	je     8003dc <vprintfmt+0x47>
			if (ch == '\0')
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	0f 84 b9 04 00 00    	je     800881 <.L21+0x20>
			putch(ch, putdat);
  8003c8:	83 ec 08             	sub    $0x8,%esp
  8003cb:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003ce:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003d1:	50                   	push   %eax
  8003d2:	ff 55 08             	call   *0x8(%ebp)
  8003d5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d8:	89 f7                	mov    %esi,%edi
  8003da:	eb d9                	jmp    8003b5 <vprintfmt+0x20>
		padc = ' ';
  8003dc:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003e0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003e7:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003ee:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fa:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8d 7e 01             	lea    0x1(%esi),%edi
  800400:	0f b6 16             	movzbl (%esi),%edx
  800403:	8d 42 dd             	lea    -0x23(%edx),%eax
  800406:	3c 55                	cmp    $0x55,%al
  800408:	0f 87 53 04 00 00    	ja     800861 <.L21>
  80040e:	0f b6 c0             	movzbl %al,%eax
  800411:	89 d9                	mov    %ebx,%ecx
  800413:	03 8c 83 a8 ef ff ff 	add    -0x1058(%ebx,%eax,4),%ecx
  80041a:	ff e1                	jmp    *%ecx

0080041c <.L73>:
  80041c:	89 fe                	mov    %edi,%esi
			padc = '-';
  80041e:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800422:	eb d9                	jmp    8003fd <vprintfmt+0x68>

00800424 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	89 fe                	mov    %edi,%esi
			padc = '0';
  800426:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80042a:	eb d1                	jmp    8003fd <vprintfmt+0x68>

0080042c <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	0f b6 d2             	movzbl %dl,%edx
  80042f:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800431:	b8 00 00 00 00       	mov    $0x0,%eax
  800436:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800439:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800440:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800443:	8d 7a d0             	lea    -0x30(%edx),%edi
  800446:	83 ff 09             	cmp    $0x9,%edi
  800449:	0f 87 94 00 00 00    	ja     8004e3 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  80044f:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800452:	eb e5                	jmp    800439 <.L28+0xd>

00800454 <.L25>:
			precision = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8b 00                	mov    (%eax),%eax
  800459:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 40 04             	lea    0x4(%eax),%eax
  800462:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800465:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800467:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046b:	79 90                	jns    8003fd <vprintfmt+0x68>
				width = precision, precision = -1;
  80046d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800470:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800473:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80047a:	eb 81                	jmp    8003fd <vprintfmt+0x68>

0080047c <.L26>:
  80047c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047f:	85 c0                	test   %eax,%eax
  800481:	ba 00 00 00 00       	mov    $0x0,%edx
  800486:	0f 49 d0             	cmovns %eax,%edx
  800489:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	89 fe                	mov    %edi,%esi
  80048e:	e9 6a ff ff ff       	jmp    8003fd <vprintfmt+0x68>

00800493 <.L22>:
  800493:	89 fe                	mov    %edi,%esi
			altflag = 1;
  800495:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049c:	e9 5c ff ff ff       	jmp    8003fd <vprintfmt+0x68>

008004a1 <.L33>:
  8004a1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004a4:	83 f9 01             	cmp    $0x1,%ecx
  8004a7:	7e 16                	jle    8004bf <.L33+0x1e>
		return va_arg(*ap, long long);
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	8b 00                	mov    (%eax),%eax
  8004ae:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004b1:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004b4:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004ba:	e9 f6 fe ff ff       	jmp    8003b5 <vprintfmt+0x20>
	else if (lflag)
  8004bf:	85 c9                	test   %ecx,%ecx
  8004c1:	75 10                	jne    8004d3 <.L33+0x32>
		return va_arg(*ap, int);
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8b 00                	mov    (%eax),%eax
  8004c8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004cb:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d1:	eb e4                	jmp    8004b7 <.L33+0x16>
		return va_arg(*ap, long);
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8b 00                	mov    (%eax),%eax
  8004d8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004db:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e1:	eb d4                	jmp    8004b7 <.L33+0x16>
  8004e3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004e6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004e9:	e9 79 ff ff ff       	jmp    800467 <.L25+0x13>

008004ee <.L32>:
			lflag++;
  8004ee:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8004f4:	e9 04 ff ff ff       	jmp    8003fd <vprintfmt+0x68>

008004f9 <.L29>:
			putch(va_arg(ap, int), putdat);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 70 04             	lea    0x4(%eax),%esi
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	ff 75 0c             	pushl  0xc(%ebp)
  800505:	ff 30                	pushl  (%eax)
  800507:	ff 55 08             	call   *0x8(%ebp)
			break;
  80050a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80050d:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800510:	e9 a0 fe ff ff       	jmp    8003b5 <vprintfmt+0x20>

00800515 <.L31>:
			err = va_arg(ap, int);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 70 04             	lea    0x4(%eax),%esi
  80051b:	8b 00                	mov    (%eax),%eax
  80051d:	99                   	cltd   
  80051e:	31 d0                	xor    %edx,%eax
  800520:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800522:	83 f8 06             	cmp    $0x6,%eax
  800525:	7f 29                	jg     800550 <.L31+0x3b>
  800527:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  80052e:	85 d2                	test   %edx,%edx
  800530:	74 1e                	je     800550 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800532:	52                   	push   %edx
  800533:	8d 83 3b ef ff ff    	lea    -0x10c5(%ebx),%eax
  800539:	50                   	push   %eax
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	ff 75 08             	pushl  0x8(%ebp)
  800540:	e8 33 fe ff ff       	call   800378 <printfmt>
  800545:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800548:	89 75 14             	mov    %esi,0x14(%ebp)
  80054b:	e9 65 fe ff ff       	jmp    8003b5 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800550:	50                   	push   %eax
  800551:	8d 83 32 ef ff ff    	lea    -0x10ce(%ebx),%eax
  800557:	50                   	push   %eax
  800558:	ff 75 0c             	pushl  0xc(%ebp)
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 15 fe ff ff       	call   800378 <printfmt>
  800563:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800566:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800569:	e9 47 fe ff ff       	jmp    8003b5 <vprintfmt+0x20>

0080056e <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	83 c0 04             	add    $0x4,%eax
  800574:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80057c:	85 f6                	test   %esi,%esi
  80057e:	8d 83 2b ef ff ff    	lea    -0x10d5(%ebx),%eax
  800584:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	0f 8e b4 00 00 00    	jle    800645 <.L36+0xd7>
  800591:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800595:	75 08                	jne    80059f <.L36+0x31>
  800597:	89 7d 10             	mov    %edi,0x10(%ebp)
  80059a:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80059d:	eb 6c                	jmp    80060b <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	ff 75 cc             	pushl  -0x34(%ebp)
  8005a5:	56                   	push   %esi
  8005a6:	e8 73 03 00 00       	call   80091e <strnlen>
  8005ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ae:	29 c2                	sub    %eax,%edx
  8005b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005b3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005b6:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005ba:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005bd:	89 d6                	mov    %edx,%esi
  8005bf:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005c2:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c4:	eb 10                	jmp    8005d6 <.L36+0x68>
					putch(padc, putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	ff 75 0c             	pushl  0xc(%ebp)
  8005cc:	57                   	push   %edi
  8005cd:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d0:	83 ee 01             	sub    $0x1,%esi
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	85 f6                	test   %esi,%esi
  8005d8:	7f ec                	jg     8005c6 <.L36+0x58>
  8005da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005dd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e7:	0f 49 c2             	cmovns %edx,%eax
  8005ea:	29 c2                	sub    %eax,%edx
  8005ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ef:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005f2:	eb 17                	jmp    80060b <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8005f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f8:	75 30                	jne    80062a <.L36+0xbc>
					putch(ch, putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	ff 75 0c             	pushl  0xc(%ebp)
  800600:	50                   	push   %eax
  800601:	ff 55 08             	call   *0x8(%ebp)
  800604:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800607:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80060b:	83 c6 01             	add    $0x1,%esi
  80060e:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800612:	0f be c2             	movsbl %dl,%eax
  800615:	85 c0                	test   %eax,%eax
  800617:	74 58                	je     800671 <.L36+0x103>
  800619:	85 ff                	test   %edi,%edi
  80061b:	78 d7                	js     8005f4 <.L36+0x86>
  80061d:	83 ef 01             	sub    $0x1,%edi
  800620:	79 d2                	jns    8005f4 <.L36+0x86>
  800622:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800625:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800628:	eb 32                	jmp    80065c <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  80062a:	0f be d2             	movsbl %dl,%edx
  80062d:	83 ea 20             	sub    $0x20,%edx
  800630:	83 fa 5e             	cmp    $0x5e,%edx
  800633:	76 c5                	jbe    8005fa <.L36+0x8c>
					putch('?', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	ff 75 0c             	pushl  0xc(%ebp)
  80063b:	6a 3f                	push   $0x3f
  80063d:	ff 55 08             	call   *0x8(%ebp)
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	eb c2                	jmp    800607 <.L36+0x99>
  800645:	89 7d 10             	mov    %edi,0x10(%ebp)
  800648:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80064b:	eb be                	jmp    80060b <.L36+0x9d>
				putch(' ', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	57                   	push   %edi
  800651:	6a 20                	push   $0x20
  800653:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800656:	83 ee 01             	sub    $0x1,%esi
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 f6                	test   %esi,%esi
  80065e:	7f ed                	jg     80064d <.L36+0xdf>
  800660:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800663:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800666:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
  80066c:	e9 44 fd ff ff       	jmp    8003b5 <vprintfmt+0x20>
  800671:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800674:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800677:	eb e3                	jmp    80065c <.L36+0xee>

00800679 <.L30>:
  800679:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80067c:	83 f9 01             	cmp    $0x1,%ecx
  80067f:	7e 42                	jle    8006c3 <.L30+0x4a>
		return va_arg(*ap, long long);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 50 04             	mov    0x4(%eax),%edx
  800687:	8b 00                	mov    (%eax),%eax
  800689:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 40 08             	lea    0x8(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800698:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069c:	79 5f                	jns    8006fd <.L30+0x84>
				putch('-', putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	ff 75 0c             	pushl  0xc(%ebp)
  8006a4:	6a 2d                	push   $0x2d
  8006a6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ac:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006af:	f7 da                	neg    %edx
  8006b1:	83 d1 00             	adc    $0x0,%ecx
  8006b4:	f7 d9                	neg    %ecx
  8006b6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006be:	e9 b8 00 00 00       	jmp    80077b <.L34+0x22>
	else if (lflag)
  8006c3:	85 c9                	test   %ecx,%ecx
  8006c5:	75 1b                	jne    8006e2 <.L30+0x69>
		return va_arg(*ap, int);
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8b 30                	mov    (%eax),%esi
  8006cc:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006cf:	89 f0                	mov    %esi,%eax
  8006d1:	c1 f8 1f             	sar    $0x1f,%eax
  8006d4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e0:	eb b6                	jmp    800698 <.L30+0x1f>
		return va_arg(*ap, long);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8b 30                	mov    (%eax),%esi
  8006e7:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006ea:	89 f0                	mov    %esi,%eax
  8006ec:	c1 f8 1f             	sar    $0x1f,%eax
  8006ef:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 40 04             	lea    0x4(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8006fb:	eb 9b                	jmp    800698 <.L30+0x1f>
			num = getint(&ap, lflag);
  8006fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800700:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800703:	b8 0a 00 00 00       	mov    $0xa,%eax
  800708:	eb 71                	jmp    80077b <.L34+0x22>

0080070a <.L37>:
  80070a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80070d:	83 f9 01             	cmp    $0x1,%ecx
  800710:	7e 15                	jle    800727 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8b 10                	mov    (%eax),%edx
  800717:	8b 48 04             	mov    0x4(%eax),%ecx
  80071a:	8d 40 08             	lea    0x8(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800720:	b8 0a 00 00 00       	mov    $0xa,%eax
  800725:	eb 54                	jmp    80077b <.L34+0x22>
	else if (lflag)
  800727:	85 c9                	test   %ecx,%ecx
  800729:	75 17                	jne    800742 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	8b 10                	mov    (%eax),%edx
  800730:	b9 00 00 00 00       	mov    $0x0,%ecx
  800735:	8d 40 04             	lea    0x4(%eax),%eax
  800738:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800740:	eb 39                	jmp    80077b <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8b 10                	mov    (%eax),%edx
  800747:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074c:	8d 40 04             	lea    0x4(%eax),%eax
  80074f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800752:	b8 0a 00 00 00       	mov    $0xa,%eax
  800757:	eb 22                	jmp    80077b <.L34+0x22>

00800759 <.L34>:
  800759:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80075c:	83 f9 01             	cmp    $0x1,%ecx
  80075f:	7e 3b                	jle    80079c <.L34+0x43>
		return va_arg(*ap, long long);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8b 50 04             	mov    0x4(%eax),%edx
  800767:	8b 00                	mov    (%eax),%eax
  800769:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80076c:	8d 49 08             	lea    0x8(%ecx),%ecx
  80076f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800772:	89 d1                	mov    %edx,%ecx
  800774:	89 c2                	mov    %eax,%edx
			base = 8;
  800776:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80077b:	83 ec 0c             	sub    $0xc,%esp
  80077e:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800782:	56                   	push   %esi
  800783:	ff 75 e0             	pushl  -0x20(%ebp)
  800786:	50                   	push   %eax
  800787:	51                   	push   %ecx
  800788:	52                   	push   %edx
  800789:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	e8 fd fa ff ff       	call   800291 <printnum>
			break;
  800794:	83 c4 20             	add    $0x20,%esp
  800797:	e9 19 fc ff ff       	jmp    8003b5 <vprintfmt+0x20>
	else if (lflag)
  80079c:	85 c9                	test   %ecx,%ecx
  80079e:	75 13                	jne    8007b3 <.L34+0x5a>
		return va_arg(*ap, int);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 10                	mov    (%eax),%edx
  8007a5:	89 d0                	mov    %edx,%eax
  8007a7:	99                   	cltd   
  8007a8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007ab:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b1:	eb bf                	jmp    800772 <.L34+0x19>
		return va_arg(*ap, long);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8b 10                	mov    (%eax),%edx
  8007b8:	89 d0                	mov    %edx,%eax
  8007ba:	99                   	cltd   
  8007bb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007be:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007c1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007c4:	eb ac                	jmp    800772 <.L34+0x19>

008007c6 <.L35>:
			putch('0', putdat);
  8007c6:	83 ec 08             	sub    $0x8,%esp
  8007c9:	ff 75 0c             	pushl  0xc(%ebp)
  8007cc:	6a 30                	push   $0x30
  8007ce:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d1:	83 c4 08             	add    $0x8,%esp
  8007d4:	ff 75 0c             	pushl  0xc(%ebp)
  8007d7:	6a 78                	push   $0x78
  8007d9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8b 10                	mov    (%eax),%edx
  8007e1:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007e6:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007e9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ef:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f4:	eb 85                	jmp    80077b <.L34+0x22>

008007f6 <.L38>:
  8007f6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8007f9:	83 f9 01             	cmp    $0x1,%ecx
  8007fc:	7e 18                	jle    800816 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8b 10                	mov    (%eax),%edx
  800803:	8b 48 04             	mov    0x4(%eax),%ecx
  800806:	8d 40 08             	lea    0x8(%eax),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080c:	b8 10 00 00 00       	mov    $0x10,%eax
  800811:	e9 65 ff ff ff       	jmp    80077b <.L34+0x22>
	else if (lflag)
  800816:	85 c9                	test   %ecx,%ecx
  800818:	75 1a                	jne    800834 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  80081a:	8b 45 14             	mov    0x14(%ebp),%eax
  80081d:	8b 10                	mov    (%eax),%edx
  80081f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800824:	8d 40 04             	lea    0x4(%eax),%eax
  800827:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082a:	b8 10 00 00 00       	mov    $0x10,%eax
  80082f:	e9 47 ff ff ff       	jmp    80077b <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8b 10                	mov    (%eax),%edx
  800839:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083e:	8d 40 04             	lea    0x4(%eax),%eax
  800841:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800844:	b8 10 00 00 00       	mov    $0x10,%eax
  800849:	e9 2d ff ff ff       	jmp    80077b <.L34+0x22>

0080084e <.L24>:
			putch(ch, putdat);
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	ff 75 0c             	pushl  0xc(%ebp)
  800854:	6a 25                	push   $0x25
  800856:	ff 55 08             	call   *0x8(%ebp)
			break;
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	e9 54 fb ff ff       	jmp    8003b5 <vprintfmt+0x20>

00800861 <.L21>:
			putch('%', putdat);
  800861:	83 ec 08             	sub    $0x8,%esp
  800864:	ff 75 0c             	pushl  0xc(%ebp)
  800867:	6a 25                	push   $0x25
  800869:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086c:	83 c4 10             	add    $0x10,%esp
  80086f:	89 f7                	mov    %esi,%edi
  800871:	eb 03                	jmp    800876 <.L21+0x15>
  800873:	83 ef 01             	sub    $0x1,%edi
  800876:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80087a:	75 f7                	jne    800873 <.L21+0x12>
  80087c:	e9 34 fb ff ff       	jmp    8003b5 <vprintfmt+0x20>
}
  800881:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5f                   	pop    %edi
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	83 ec 14             	sub    $0x14,%esp
  800890:	e8 02 f8 ff ff       	call   800097 <__x86.get_pc_thunk.bx>
  800895:	81 c3 6b 17 00 00    	add    $0x176b,%ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b2:	85 c0                	test   %eax,%eax
  8008b4:	74 2b                	je     8008e1 <vsnprintf+0x58>
  8008b6:	85 d2                	test   %edx,%edx
  8008b8:	7e 27                	jle    8008e1 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ba:	ff 75 14             	pushl  0x14(%ebp)
  8008bd:	ff 75 10             	pushl  0x10(%ebp)
  8008c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c3:	50                   	push   %eax
  8008c4:	8d 83 5b e3 ff ff    	lea    -0x1ca5(%ebx),%eax
  8008ca:	50                   	push   %eax
  8008cb:	e8 c5 fa ff ff       	call   800395 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d9:	83 c4 10             	add    $0x10,%esp
}
  8008dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008df:	c9                   	leave  
  8008e0:	c3                   	ret    
		return -E_INVAL;
  8008e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e6:	eb f4                	jmp    8008dc <vsnprintf+0x53>

008008e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f1:	50                   	push   %eax
  8008f2:	ff 75 10             	pushl  0x10(%ebp)
  8008f5:	ff 75 0c             	pushl  0xc(%ebp)
  8008f8:	ff 75 08             	pushl  0x8(%ebp)
  8008fb:	e8 89 ff ff ff       	call   800889 <vsnprintf>
	va_end(ap);

	return rc;
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <__x86.get_pc_thunk.cx>:
  800902:	8b 0c 24             	mov    (%esp),%ecx
  800905:	c3                   	ret    

00800906 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
  800911:	eb 03                	jmp    800916 <strlen+0x10>
		n++;
  800913:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800916:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091a:	75 f7                	jne    800913 <strlen+0xd>
	return n;
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
  80092c:	eb 03                	jmp    800931 <strnlen+0x13>
		n++;
  80092e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800931:	39 d0                	cmp    %edx,%eax
  800933:	74 06                	je     80093b <strnlen+0x1d>
  800935:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800939:	75 f3                	jne    80092e <strnlen+0x10>
	return n;
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	53                   	push   %ebx
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800947:	89 c2                	mov    %eax,%edx
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
  80094f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800953:	88 5a ff             	mov    %bl,-0x1(%edx)
  800956:	84 db                	test   %bl,%bl
  800958:	75 ef                	jne    800949 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80095a:	5b                   	pop    %ebx
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	53                   	push   %ebx
  800961:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800964:	53                   	push   %ebx
  800965:	e8 9c ff ff ff       	call   800906 <strlen>
  80096a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80096d:	ff 75 0c             	pushl  0xc(%ebp)
  800970:	01 d8                	add    %ebx,%eax
  800972:	50                   	push   %eax
  800973:	e8 c5 ff ff ff       	call   80093d <strcpy>
	return dst;
}
  800978:	89 d8                	mov    %ebx,%eax
  80097a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	56                   	push   %esi
  800983:	53                   	push   %ebx
  800984:	8b 75 08             	mov    0x8(%ebp),%esi
  800987:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098a:	89 f3                	mov    %esi,%ebx
  80098c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098f:	89 f2                	mov    %esi,%edx
  800991:	eb 0f                	jmp    8009a2 <strncpy+0x23>
		*dst++ = *src;
  800993:	83 c2 01             	add    $0x1,%edx
  800996:	0f b6 01             	movzbl (%ecx),%eax
  800999:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099c:	80 39 01             	cmpb   $0x1,(%ecx)
  80099f:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009a2:	39 da                	cmp    %ebx,%edx
  8009a4:	75 ed                	jne    800993 <strncpy+0x14>
	}
	return ret;
}
  8009a6:	89 f0                	mov    %esi,%eax
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	56                   	push   %esi
  8009b0:	53                   	push   %ebx
  8009b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ba:	89 f0                	mov    %esi,%eax
  8009bc:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c0:	85 c9                	test   %ecx,%ecx
  8009c2:	75 0b                	jne    8009cf <strlcpy+0x23>
  8009c4:	eb 17                	jmp    8009dd <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009c6:	83 c2 01             	add    $0x1,%edx
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009cf:	39 d8                	cmp    %ebx,%eax
  8009d1:	74 07                	je     8009da <strlcpy+0x2e>
  8009d3:	0f b6 0a             	movzbl (%edx),%ecx
  8009d6:	84 c9                	test   %cl,%cl
  8009d8:	75 ec                	jne    8009c6 <strlcpy+0x1a>
		*dst = '\0';
  8009da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009dd:	29 f0                	sub    %esi,%eax
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ec:	eb 06                	jmp    8009f4 <strcmp+0x11>
		p++, q++;
  8009ee:	83 c1 01             	add    $0x1,%ecx
  8009f1:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009f4:	0f b6 01             	movzbl (%ecx),%eax
  8009f7:	84 c0                	test   %al,%al
  8009f9:	74 04                	je     8009ff <strcmp+0x1c>
  8009fb:	3a 02                	cmp    (%edx),%al
  8009fd:	74 ef                	je     8009ee <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ff:	0f b6 c0             	movzbl %al,%eax
  800a02:	0f b6 12             	movzbl (%edx),%edx
  800a05:	29 d0                	sub    %edx,%eax
}
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	53                   	push   %ebx
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a13:	89 c3                	mov    %eax,%ebx
  800a15:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a18:	eb 06                	jmp    800a20 <strncmp+0x17>
		n--, p++, q++;
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a20:	39 d8                	cmp    %ebx,%eax
  800a22:	74 16                	je     800a3a <strncmp+0x31>
  800a24:	0f b6 08             	movzbl (%eax),%ecx
  800a27:	84 c9                	test   %cl,%cl
  800a29:	74 04                	je     800a2f <strncmp+0x26>
  800a2b:	3a 0a                	cmp    (%edx),%cl
  800a2d:	74 eb                	je     800a1a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2f:	0f b6 00             	movzbl (%eax),%eax
  800a32:	0f b6 12             	movzbl (%edx),%edx
  800a35:	29 d0                	sub    %edx,%eax
}
  800a37:	5b                   	pop    %ebx
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    
		return 0;
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	eb f6                	jmp    800a37 <strncmp+0x2e>

00800a41 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4b:	0f b6 10             	movzbl (%eax),%edx
  800a4e:	84 d2                	test   %dl,%dl
  800a50:	74 09                	je     800a5b <strchr+0x1a>
		if (*s == c)
  800a52:	38 ca                	cmp    %cl,%dl
  800a54:	74 0a                	je     800a60 <strchr+0x1f>
	for (; *s; s++)
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	eb f0                	jmp    800a4b <strchr+0xa>
			return (char *) s;
	return 0;
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6c:	eb 03                	jmp    800a71 <strfind+0xf>
  800a6e:	83 c0 01             	add    $0x1,%eax
  800a71:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a74:	38 ca                	cmp    %cl,%dl
  800a76:	74 04                	je     800a7c <strfind+0x1a>
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	75 f2                	jne    800a6e <strfind+0xc>
			break;
	return (char *) s;
}
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8a:	85 c9                	test   %ecx,%ecx
  800a8c:	74 13                	je     800aa1 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a94:	75 05                	jne    800a9b <memset+0x1d>
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	74 0d                	je     800aa8 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9e:	fc                   	cld    
  800a9f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa1:	89 f8                	mov    %edi,%eax
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5f                   	pop    %edi
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    
		c &= 0xFF;
  800aa8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aac:	89 d3                	mov    %edx,%ebx
  800aae:	c1 e3 08             	shl    $0x8,%ebx
  800ab1:	89 d0                	mov    %edx,%eax
  800ab3:	c1 e0 18             	shl    $0x18,%eax
  800ab6:	89 d6                	mov    %edx,%esi
  800ab8:	c1 e6 10             	shl    $0x10,%esi
  800abb:	09 f0                	or     %esi,%eax
  800abd:	09 c2                	or     %eax,%edx
  800abf:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ac1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ac4:	89 d0                	mov    %edx,%eax
  800ac6:	fc                   	cld    
  800ac7:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac9:	eb d6                	jmp    800aa1 <memset+0x23>

00800acb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	57                   	push   %edi
  800acf:	56                   	push   %esi
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad9:	39 c6                	cmp    %eax,%esi
  800adb:	73 35                	jae    800b12 <memmove+0x47>
  800add:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae0:	39 c2                	cmp    %eax,%edx
  800ae2:	76 2e                	jbe    800b12 <memmove+0x47>
		s += n;
		d += n;
  800ae4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae7:	89 d6                	mov    %edx,%esi
  800ae9:	09 fe                	or     %edi,%esi
  800aeb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af1:	74 0c                	je     800aff <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af3:	83 ef 01             	sub    $0x1,%edi
  800af6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800af9:	fd                   	std    
  800afa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800afc:	fc                   	cld    
  800afd:	eb 21                	jmp    800b20 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aff:	f6 c1 03             	test   $0x3,%cl
  800b02:	75 ef                	jne    800af3 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b04:	83 ef 04             	sub    $0x4,%edi
  800b07:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b0d:	fd                   	std    
  800b0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b10:	eb ea                	jmp    800afc <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b12:	89 f2                	mov    %esi,%edx
  800b14:	09 c2                	or     %eax,%edx
  800b16:	f6 c2 03             	test   $0x3,%dl
  800b19:	74 09                	je     800b24 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b1b:	89 c7                	mov    %eax,%edi
  800b1d:	fc                   	cld    
  800b1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b24:	f6 c1 03             	test   $0x3,%cl
  800b27:	75 f2                	jne    800b1b <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b29:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b2c:	89 c7                	mov    %eax,%edi
  800b2e:	fc                   	cld    
  800b2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b31:	eb ed                	jmp    800b20 <memmove+0x55>

00800b33 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b36:	ff 75 10             	pushl  0x10(%ebp)
  800b39:	ff 75 0c             	pushl  0xc(%ebp)
  800b3c:	ff 75 08             	pushl  0x8(%ebp)
  800b3f:	e8 87 ff ff ff       	call   800acb <memmove>
}
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b51:	89 c6                	mov    %eax,%esi
  800b53:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b56:	39 f0                	cmp    %esi,%eax
  800b58:	74 1c                	je     800b76 <memcmp+0x30>
		if (*s1 != *s2)
  800b5a:	0f b6 08             	movzbl (%eax),%ecx
  800b5d:	0f b6 1a             	movzbl (%edx),%ebx
  800b60:	38 d9                	cmp    %bl,%cl
  800b62:	75 08                	jne    800b6c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b64:	83 c0 01             	add    $0x1,%eax
  800b67:	83 c2 01             	add    $0x1,%edx
  800b6a:	eb ea                	jmp    800b56 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b6c:	0f b6 c1             	movzbl %cl,%eax
  800b6f:	0f b6 db             	movzbl %bl,%ebx
  800b72:	29 d8                	sub    %ebx,%eax
  800b74:	eb 05                	jmp    800b7b <memcmp+0x35>
	}

	return 0;
  800b76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b88:	89 c2                	mov    %eax,%edx
  800b8a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8d:	39 d0                	cmp    %edx,%eax
  800b8f:	73 09                	jae    800b9a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b91:	38 08                	cmp    %cl,(%eax)
  800b93:	74 05                	je     800b9a <memfind+0x1b>
	for (; s < ends; s++)
  800b95:	83 c0 01             	add    $0x1,%eax
  800b98:	eb f3                	jmp    800b8d <memfind+0xe>
			break;
	return (void *) s;
}
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
  800ba2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba8:	eb 03                	jmp    800bad <strtol+0x11>
		s++;
  800baa:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bad:	0f b6 01             	movzbl (%ecx),%eax
  800bb0:	3c 20                	cmp    $0x20,%al
  800bb2:	74 f6                	je     800baa <strtol+0xe>
  800bb4:	3c 09                	cmp    $0x9,%al
  800bb6:	74 f2                	je     800baa <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bb8:	3c 2b                	cmp    $0x2b,%al
  800bba:	74 2e                	je     800bea <strtol+0x4e>
	int neg = 0;
  800bbc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bc1:	3c 2d                	cmp    $0x2d,%al
  800bc3:	74 2f                	je     800bf4 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bcb:	75 05                	jne    800bd2 <strtol+0x36>
  800bcd:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd0:	74 2c                	je     800bfe <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd2:	85 db                	test   %ebx,%ebx
  800bd4:	75 0a                	jne    800be0 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd6:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bdb:	80 39 30             	cmpb   $0x30,(%ecx)
  800bde:	74 28                	je     800c08 <strtol+0x6c>
		base = 10;
  800be0:	b8 00 00 00 00       	mov    $0x0,%eax
  800be5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800be8:	eb 50                	jmp    800c3a <strtol+0x9e>
		s++;
  800bea:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bed:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf2:	eb d1                	jmp    800bc5 <strtol+0x29>
		s++, neg = 1;
  800bf4:	83 c1 01             	add    $0x1,%ecx
  800bf7:	bf 01 00 00 00       	mov    $0x1,%edi
  800bfc:	eb c7                	jmp    800bc5 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfe:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c02:	74 0e                	je     800c12 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c04:	85 db                	test   %ebx,%ebx
  800c06:	75 d8                	jne    800be0 <strtol+0x44>
		s++, base = 8;
  800c08:	83 c1 01             	add    $0x1,%ecx
  800c0b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c10:	eb ce                	jmp    800be0 <strtol+0x44>
		s += 2, base = 16;
  800c12:	83 c1 02             	add    $0x2,%ecx
  800c15:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c1a:	eb c4                	jmp    800be0 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c1c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c1f:	89 f3                	mov    %esi,%ebx
  800c21:	80 fb 19             	cmp    $0x19,%bl
  800c24:	77 29                	ja     800c4f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c26:	0f be d2             	movsbl %dl,%edx
  800c29:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c2c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c2f:	7d 30                	jge    800c61 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c31:	83 c1 01             	add    $0x1,%ecx
  800c34:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c38:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c3a:	0f b6 11             	movzbl (%ecx),%edx
  800c3d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c40:	89 f3                	mov    %esi,%ebx
  800c42:	80 fb 09             	cmp    $0x9,%bl
  800c45:	77 d5                	ja     800c1c <strtol+0x80>
			dig = *s - '0';
  800c47:	0f be d2             	movsbl %dl,%edx
  800c4a:	83 ea 30             	sub    $0x30,%edx
  800c4d:	eb dd                	jmp    800c2c <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c4f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c52:	89 f3                	mov    %esi,%ebx
  800c54:	80 fb 19             	cmp    $0x19,%bl
  800c57:	77 08                	ja     800c61 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c59:	0f be d2             	movsbl %dl,%edx
  800c5c:	83 ea 37             	sub    $0x37,%edx
  800c5f:	eb cb                	jmp    800c2c <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c65:	74 05                	je     800c6c <strtol+0xd0>
		*endptr = (char *) s;
  800c67:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c6c:	89 c2                	mov    %eax,%edx
  800c6e:	f7 da                	neg    %edx
  800c70:	85 ff                	test   %edi,%edi
  800c72:	0f 45 c2             	cmovne %edx,%eax
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    
  800c7a:	66 90                	xchg   %ax,%ax
  800c7c:	66 90                	xchg   %ax,%ax
  800c7e:	66 90                	xchg   %ax,%ax

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
