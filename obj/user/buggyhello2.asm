
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 30 00 00 00       	call   800061 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 1e 00 00 00       	call   80005d <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs(hello, 1024*1024);
  800045:	68 00 00 10 00       	push   $0x100000
  80004a:	ff b3 0c 00 00 00    	pushl  0xc(%ebx)
  800050:	e8 74 00 00 00       	call   8000c9 <sys_cputs>
}
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <__x86.get_pc_thunk.bx>:
  80005d:	8b 1c 24             	mov    (%esp),%ebx
  800060:	c3                   	ret    

00800061 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	53                   	push   %ebx
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	e8 f0 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80006d:	81 c3 93 1f 00 00    	add    $0x1f93,%ebx
  800073:	8b 45 08             	mov    0x8(%ebp),%eax
  800076:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800079:	c7 c1 30 20 80 00    	mov    $0x802030,%ecx
  80007f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	7e 08                	jle    800091 <libmain+0x30>
		binaryname = argv[0];
  800089:	8b 0a                	mov    (%edx),%ecx
  80008b:	89 8b 10 00 00 00    	mov    %ecx,0x10(%ebx)

	// call user main routine
	umain(argc, argv);
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	52                   	push   %edx
  800095:	50                   	push   %eax
  800096:	e8 98 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009b:	e8 08 00 00 00       	call   8000a8 <exit>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 10             	sub    $0x10,%esp
  8000af:	e8 a9 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8000b4:	81 c3 4c 1f 00 00    	add    $0x1f4c,%ebx
	sys_env_destroy(0);
  8000ba:	6a 00                	push   $0x0
  8000bc:	e8 45 00 00 00       	call   800106 <sys_env_destroy>
}
  8000c1:	83 c4 10             	add    $0x10,%esp
  8000c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    

008000c9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000da:	89 c3                	mov    %eax,%ebx
  8000dc:	89 c7                	mov    %eax,%edi
  8000de:	89 c6                	mov    %eax,%esi
  8000e0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f7:	89 d1                	mov    %edx,%ecx
  8000f9:	89 d3                	mov    %edx,%ebx
  8000fb:	89 d7                	mov    %edx,%edi
  8000fd:	89 d6                	mov    %edx,%esi
  8000ff:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	57                   	push   %edi
  80010a:	56                   	push   %esi
  80010b:	53                   	push   %ebx
  80010c:	83 ec 1c             	sub    $0x1c,%esp
  80010f:	e8 66 00 00 00       	call   80017a <__x86.get_pc_thunk.ax>
  800114:	05 ec 1e 00 00       	add    $0x1eec,%eax
  800119:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80011c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800121:	8b 55 08             	mov    0x8(%ebp),%edx
  800124:	b8 03 00 00 00       	mov    $0x3,%eax
  800129:	89 cb                	mov    %ecx,%ebx
  80012b:	89 cf                	mov    %ecx,%edi
  80012d:	89 ce                	mov    %ecx,%esi
  80012f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800131:	85 c0                	test   %eax,%eax
  800133:	7f 08                	jg     80013d <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800135:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5f                   	pop    %edi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	50                   	push   %eax
  800141:	6a 03                	push   $0x3
  800143:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800146:	8d 83 e4 ee ff ff    	lea    -0x111c(%ebx),%eax
  80014c:	50                   	push   %eax
  80014d:	6a 23                	push   $0x23
  80014f:	8d 83 01 ef ff ff    	lea    -0x10ff(%ebx),%eax
  800155:	50                   	push   %eax
  800156:	e8 23 00 00 00       	call   80017e <_panic>

0080015b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	asm volatile("int %1\n"
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 02 00 00 00       	mov    $0x2,%eax
  80016b:	89 d1                	mov    %edx,%ecx
  80016d:	89 d3                	mov    %edx,%ebx
  80016f:	89 d7                	mov    %edx,%edi
  800171:	89 d6                	mov    %edx,%esi
  800173:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <__x86.get_pc_thunk.ax>:
  80017a:	8b 04 24             	mov    (%esp),%eax
  80017d:	c3                   	ret    

0080017e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	e8 d1 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80018c:	81 c3 74 1e 00 00    	add    $0x1e74,%ebx
	va_list ap;

	va_start(ap, fmt);
  800192:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800195:	c7 c0 10 20 80 00    	mov    $0x802010,%eax
  80019b:	8b 38                	mov    (%eax),%edi
  80019d:	e8 b9 ff ff ff       	call   80015b <sys_getenvid>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	ff 75 0c             	pushl  0xc(%ebp)
  8001a8:	ff 75 08             	pushl  0x8(%ebp)
  8001ab:	57                   	push   %edi
  8001ac:	50                   	push   %eax
  8001ad:	8d 83 10 ef ff ff    	lea    -0x10f0(%ebx),%eax
  8001b3:	50                   	push   %eax
  8001b4:	e8 d1 00 00 00       	call   80028a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	56                   	push   %esi
  8001bd:	ff 75 10             	pushl  0x10(%ebp)
  8001c0:	e8 63 00 00 00       	call   800228 <vcprintf>
	cprintf("\n");
  8001c5:	8d 83 d8 ee ff ff    	lea    -0x1128(%ebx),%eax
  8001cb:	89 04 24             	mov    %eax,(%esp)
  8001ce:	e8 b7 00 00 00       	call   80028a <cprintf>
  8001d3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x58>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
  8001de:	e8 7a fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001e3:	81 c3 1d 1e 00 00    	add    $0x1e1d,%ebx
  8001e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001ec:	8b 16                	mov    (%esi),%edx
  8001ee:	8d 42 01             	lea    0x1(%edx),%eax
  8001f1:	89 06                	mov    %eax,(%esi)
  8001f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f6:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001fa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ff:	74 0b                	je     80020c <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800201:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800205:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	68 ff 00 00 00       	push   $0xff
  800214:	8d 46 08             	lea    0x8(%esi),%eax
  800217:	50                   	push   %eax
  800218:	e8 ac fe ff ff       	call   8000c9 <sys_cputs>
		b->idx = 0;
  80021d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800223:	83 c4 10             	add    $0x10,%esp
  800226:	eb d9                	jmp    800201 <putch+0x28>

00800228 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	53                   	push   %ebx
  80022c:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800232:	e8 26 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  800237:	81 c3 c9 1d 00 00    	add    $0x1dc9,%ebx
	struct printbuf b;

	b.idx = 0;
  80023d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800244:	00 00 00 
	b.cnt = 0;
  800247:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80025d:	50                   	push   %eax
  80025e:	8d 83 d9 e1 ff ff    	lea    -0x1e27(%ebx),%eax
  800264:	50                   	push   %eax
  800265:	e8 38 01 00 00       	call   8003a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026a:	83 c4 08             	add    $0x8,%esp
  80026d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800273:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800279:	50                   	push   %eax
  80027a:	e8 4a fe ff ff       	call   8000c9 <sys_cputs>

	return b.cnt;
}
  80027f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800285:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800290:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800293:	50                   	push   %eax
  800294:	ff 75 08             	pushl  0x8(%ebp)
  800297:	e8 8c ff ff ff       	call   800228 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029c:	c9                   	leave  
  80029d:	c3                   	ret    

0080029e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	57                   	push   %edi
  8002a2:	56                   	push   %esi
  8002a3:	53                   	push   %ebx
  8002a4:	83 ec 2c             	sub    $0x2c,%esp
  8002a7:	e8 63 06 00 00       	call   80090f <__x86.get_pc_thunk.cx>
  8002ac:	81 c1 54 1d 00 00    	add    $0x1d54,%ecx
  8002b2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002b5:	89 c7                	mov    %eax,%edi
  8002b7:	89 d6                	mov    %edx,%esi
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002d0:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002d3:	39 d3                	cmp    %edx,%ebx
  8002d5:	72 09                	jb     8002e0 <printnum+0x42>
  8002d7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002da:	0f 87 83 00 00 00    	ja     800363 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	ff 75 18             	pushl  0x18(%ebp)
  8002e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ec:	53                   	push   %ebx
  8002ed:	ff 75 10             	pushl  0x10(%ebp)
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002fc:	ff 75 d0             	pushl  -0x30(%ebp)
  8002ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800302:	e8 89 09 00 00       	call   800c90 <__udivdi3>
  800307:	83 c4 18             	add    $0x18,%esp
  80030a:	52                   	push   %edx
  80030b:	50                   	push   %eax
  80030c:	89 f2                	mov    %esi,%edx
  80030e:	89 f8                	mov    %edi,%eax
  800310:	e8 89 ff ff ff       	call   80029e <printnum>
  800315:	83 c4 20             	add    $0x20,%esp
  800318:	eb 13                	jmp    80032d <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80031a:	83 ec 08             	sub    $0x8,%esp
  80031d:	56                   	push   %esi
  80031e:	ff 75 18             	pushl  0x18(%ebp)
  800321:	ff d7                	call   *%edi
  800323:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800326:	83 eb 01             	sub    $0x1,%ebx
  800329:	85 db                	test   %ebx,%ebx
  80032b:	7f ed                	jg     80031a <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80032d:	83 ec 08             	sub    $0x8,%esp
  800330:	56                   	push   %esi
  800331:	83 ec 04             	sub    $0x4,%esp
  800334:	ff 75 dc             	pushl  -0x24(%ebp)
  800337:	ff 75 d8             	pushl  -0x28(%ebp)
  80033a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80033d:	ff 75 d0             	pushl  -0x30(%ebp)
  800340:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800343:	89 f3                	mov    %esi,%ebx
  800345:	e8 66 0a 00 00       	call   800db0 <__umoddi3>
  80034a:	83 c4 14             	add    $0x14,%esp
  80034d:	0f be 84 06 34 ef ff 	movsbl -0x10cc(%esi,%eax,1),%eax
  800354:	ff 
  800355:	50                   	push   %eax
  800356:	ff d7                	call   *%edi
}
  800358:	83 c4 10             	add    $0x10,%esp
  80035b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035e:	5b                   	pop    %ebx
  80035f:	5e                   	pop    %esi
  800360:	5f                   	pop    %edi
  800361:	5d                   	pop    %ebp
  800362:	c3                   	ret    
  800363:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800366:	eb be                	jmp    800326 <printnum+0x88>

00800368 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800372:	8b 10                	mov    (%eax),%edx
  800374:	3b 50 04             	cmp    0x4(%eax),%edx
  800377:	73 0a                	jae    800383 <sprintputch+0x1b>
		*b->buf++ = ch;
  800379:	8d 4a 01             	lea    0x1(%edx),%ecx
  80037c:	89 08                	mov    %ecx,(%eax)
  80037e:	8b 45 08             	mov    0x8(%ebp),%eax
  800381:	88 02                	mov    %al,(%edx)
}
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <printfmt>:
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80038b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038e:	50                   	push   %eax
  80038f:	ff 75 10             	pushl  0x10(%ebp)
  800392:	ff 75 0c             	pushl  0xc(%ebp)
  800395:	ff 75 08             	pushl  0x8(%ebp)
  800398:	e8 05 00 00 00       	call   8003a2 <vprintfmt>
}
  80039d:	83 c4 10             	add    $0x10,%esp
  8003a0:	c9                   	leave  
  8003a1:	c3                   	ret    

008003a2 <vprintfmt>:
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	57                   	push   %edi
  8003a6:	56                   	push   %esi
  8003a7:	53                   	push   %ebx
  8003a8:	83 ec 2c             	sub    $0x2c,%esp
  8003ab:	e8 ad fc ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8003b0:	81 c3 50 1c 00 00    	add    $0x1c50,%ebx
  8003b6:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003b9:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003c0:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c2:	8d 77 01             	lea    0x1(%edi),%esi
  8003c5:	0f b6 07             	movzbl (%edi),%eax
  8003c8:	83 f8 25             	cmp    $0x25,%eax
  8003cb:	74 1c                	je     8003e9 <vprintfmt+0x47>
			if (ch == '\0')
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	0f 84 b9 04 00 00    	je     80088e <.L21+0x20>
			putch(ch, putdat);
  8003d5:	83 ec 08             	sub    $0x8,%esp
  8003d8:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003db:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003de:	50                   	push   %eax
  8003df:	ff 55 08             	call   *0x8(%ebp)
  8003e2:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e5:	89 f7                	mov    %esi,%edi
  8003e7:	eb d9                	jmp    8003c2 <vprintfmt+0x20>
		padc = ' ';
  8003e9:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003ed:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003f4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003fb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800402:	b9 00 00 00 00       	mov    $0x0,%ecx
  800407:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8d 7e 01             	lea    0x1(%esi),%edi
  80040d:	0f b6 16             	movzbl (%esi),%edx
  800410:	8d 42 dd             	lea    -0x23(%edx),%eax
  800413:	3c 55                	cmp    $0x55,%al
  800415:	0f 87 53 04 00 00    	ja     80086e <.L21>
  80041b:	0f b6 c0             	movzbl %al,%eax
  80041e:	89 d9                	mov    %ebx,%ecx
  800420:	03 8c 83 c4 ef ff ff 	add    -0x103c(%ebx,%eax,4),%ecx
  800427:	ff e1                	jmp    *%ecx

00800429 <.L73>:
  800429:	89 fe                	mov    %edi,%esi
			padc = '-';
  80042b:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80042f:	eb d9                	jmp    80040a <vprintfmt+0x68>

00800431 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	89 fe                	mov    %edi,%esi
			padc = '0';
  800433:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800437:	eb d1                	jmp    80040a <vprintfmt+0x68>

00800439 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800439:	0f b6 d2             	movzbl %dl,%edx
  80043c:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  80043e:	b8 00 00 00 00       	mov    $0x0,%eax
  800443:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800446:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800449:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80044d:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800450:	8d 7a d0             	lea    -0x30(%edx),%edi
  800453:	83 ff 09             	cmp    $0x9,%edi
  800456:	0f 87 94 00 00 00    	ja     8004f0 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  80045c:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80045f:	eb e5                	jmp    800446 <.L28+0xd>

00800461 <.L25>:
			precision = va_arg(ap, int);
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8b 00                	mov    (%eax),%eax
  800466:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	8d 40 04             	lea    0x4(%eax),%eax
  80046f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800472:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800474:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800478:	79 90                	jns    80040a <vprintfmt+0x68>
				width = precision, precision = -1;
  80047a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80047d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800480:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800487:	eb 81                	jmp    80040a <vprintfmt+0x68>

00800489 <.L26>:
  800489:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80048c:	85 c0                	test   %eax,%eax
  80048e:	ba 00 00 00 00       	mov    $0x0,%edx
  800493:	0f 49 d0             	cmovns %eax,%edx
  800496:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800499:	89 fe                	mov    %edi,%esi
  80049b:	e9 6a ff ff ff       	jmp    80040a <vprintfmt+0x68>

008004a0 <.L22>:
  8004a0:	89 fe                	mov    %edi,%esi
			altflag = 1;
  8004a2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a9:	e9 5c ff ff ff       	jmp    80040a <vprintfmt+0x68>

008004ae <.L33>:
  8004ae:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004b1:	83 f9 01             	cmp    $0x1,%ecx
  8004b4:	7e 16                	jle    8004cc <.L33+0x1e>
		return va_arg(*ap, long long);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004be:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004c1:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004c7:	e9 f6 fe ff ff       	jmp    8003c2 <vprintfmt+0x20>
	else if (lflag)
  8004cc:	85 c9                	test   %ecx,%ecx
  8004ce:	75 10                	jne    8004e0 <.L33+0x32>
		return va_arg(*ap, int);
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004d8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004db:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004de:	eb e4                	jmp    8004c4 <.L33+0x16>
		return va_arg(*ap, long);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8b 00                	mov    (%eax),%eax
  8004e5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004e8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004eb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ee:	eb d4                	jmp    8004c4 <.L33+0x16>
  8004f0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004f6:	e9 79 ff ff ff       	jmp    800474 <.L25+0x13>

008004fb <.L32>:
			lflag++;
  8004fb:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004ff:	89 fe                	mov    %edi,%esi
			goto reswitch;
  800501:	e9 04 ff ff ff       	jmp    80040a <vprintfmt+0x68>

00800506 <.L29>:
			putch(va_arg(ap, int), putdat);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 70 04             	lea    0x4(%eax),%esi
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	ff 75 0c             	pushl  0xc(%ebp)
  800512:	ff 30                	pushl  (%eax)
  800514:	ff 55 08             	call   *0x8(%ebp)
			break;
  800517:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80051a:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  80051d:	e9 a0 fe ff ff       	jmp    8003c2 <vprintfmt+0x20>

00800522 <.L31>:
			err = va_arg(ap, int);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 70 04             	lea    0x4(%eax),%esi
  800528:	8b 00                	mov    (%eax),%eax
  80052a:	99                   	cltd   
  80052b:	31 d0                	xor    %edx,%eax
  80052d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052f:	83 f8 06             	cmp    $0x6,%eax
  800532:	7f 29                	jg     80055d <.L31+0x3b>
  800534:	8b 94 83 14 00 00 00 	mov    0x14(%ebx,%eax,4),%edx
  80053b:	85 d2                	test   %edx,%edx
  80053d:	74 1e                	je     80055d <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  80053f:	52                   	push   %edx
  800540:	8d 83 55 ef ff ff    	lea    -0x10ab(%ebx),%eax
  800546:	50                   	push   %eax
  800547:	ff 75 0c             	pushl  0xc(%ebp)
  80054a:	ff 75 08             	pushl  0x8(%ebp)
  80054d:	e8 33 fe ff ff       	call   800385 <printfmt>
  800552:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800555:	89 75 14             	mov    %esi,0x14(%ebp)
  800558:	e9 65 fe ff ff       	jmp    8003c2 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  80055d:	50                   	push   %eax
  80055e:	8d 83 4c ef ff ff    	lea    -0x10b4(%ebx),%eax
  800564:	50                   	push   %eax
  800565:	ff 75 0c             	pushl  0xc(%ebp)
  800568:	ff 75 08             	pushl  0x8(%ebp)
  80056b:	e8 15 fe ff ff       	call   800385 <printfmt>
  800570:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800573:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800576:	e9 47 fe ff ff       	jmp    8003c2 <vprintfmt+0x20>

0080057b <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	83 c0 04             	add    $0x4,%eax
  800581:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800589:	85 f6                	test   %esi,%esi
  80058b:	8d 83 45 ef ff ff    	lea    -0x10bb(%ebx),%eax
  800591:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800594:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800598:	0f 8e b4 00 00 00    	jle    800652 <.L36+0xd7>
  80059e:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005a2:	75 08                	jne    8005ac <.L36+0x31>
  8005a4:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005a7:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005aa:	eb 6c                	jmp    800618 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	ff 75 cc             	pushl  -0x34(%ebp)
  8005b2:	56                   	push   %esi
  8005b3:	e8 73 03 00 00       	call   80092b <strnlen>
  8005b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005bb:	29 c2                	sub    %eax,%edx
  8005bd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005c0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005c3:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005c7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005ca:	89 d6                	mov    %edx,%esi
  8005cc:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005cf:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	eb 10                	jmp    8005e3 <.L36+0x68>
					putch(padc, putdat);
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	ff 75 0c             	pushl  0xc(%ebp)
  8005d9:	57                   	push   %edi
  8005da:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005dd:	83 ee 01             	sub    $0x1,%esi
  8005e0:	83 c4 10             	add    $0x10,%esp
  8005e3:	85 f6                	test   %esi,%esi
  8005e5:	7f ec                	jg     8005d3 <.L36+0x58>
  8005e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ea:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ed:	85 d2                	test   %edx,%edx
  8005ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f4:	0f 49 c2             	cmovns %edx,%eax
  8005f7:	29 c2                	sub    %eax,%edx
  8005f9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005fc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005ff:	eb 17                	jmp    800618 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  800601:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800605:	75 30                	jne    800637 <.L36+0xbc>
					putch(ch, putdat);
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	ff 75 0c             	pushl  0xc(%ebp)
  80060d:	50                   	push   %eax
  80060e:	ff 55 08             	call   *0x8(%ebp)
  800611:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800614:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800618:	83 c6 01             	add    $0x1,%esi
  80061b:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80061f:	0f be c2             	movsbl %dl,%eax
  800622:	85 c0                	test   %eax,%eax
  800624:	74 58                	je     80067e <.L36+0x103>
  800626:	85 ff                	test   %edi,%edi
  800628:	78 d7                	js     800601 <.L36+0x86>
  80062a:	83 ef 01             	sub    $0x1,%edi
  80062d:	79 d2                	jns    800601 <.L36+0x86>
  80062f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800632:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800635:	eb 32                	jmp    800669 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800637:	0f be d2             	movsbl %dl,%edx
  80063a:	83 ea 20             	sub    $0x20,%edx
  80063d:	83 fa 5e             	cmp    $0x5e,%edx
  800640:	76 c5                	jbe    800607 <.L36+0x8c>
					putch('?', putdat);
  800642:	83 ec 08             	sub    $0x8,%esp
  800645:	ff 75 0c             	pushl  0xc(%ebp)
  800648:	6a 3f                	push   $0x3f
  80064a:	ff 55 08             	call   *0x8(%ebp)
  80064d:	83 c4 10             	add    $0x10,%esp
  800650:	eb c2                	jmp    800614 <.L36+0x99>
  800652:	89 7d 10             	mov    %edi,0x10(%ebp)
  800655:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800658:	eb be                	jmp    800618 <.L36+0x9d>
				putch(' ', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	57                   	push   %edi
  80065e:	6a 20                	push   $0x20
  800660:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800663:	83 ee 01             	sub    $0x1,%esi
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	85 f6                	test   %esi,%esi
  80066b:	7f ed                	jg     80065a <.L36+0xdf>
  80066d:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800670:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800673:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
  800679:	e9 44 fd ff ff       	jmp    8003c2 <vprintfmt+0x20>
  80067e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800681:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800684:	eb e3                	jmp    800669 <.L36+0xee>

00800686 <.L30>:
  800686:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800689:	83 f9 01             	cmp    $0x1,%ecx
  80068c:	7e 42                	jle    8006d0 <.L30+0x4a>
		return va_arg(*ap, long long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 50 04             	mov    0x4(%eax),%edx
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 40 08             	lea    0x8(%eax),%eax
  8006a2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a9:	79 5f                	jns    80070a <.L30+0x84>
				putch('-', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 0c             	pushl  0xc(%ebp)
  8006b1:	6a 2d                	push   $0x2d
  8006b3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bc:	f7 da                	neg    %edx
  8006be:	83 d1 00             	adc    $0x0,%ecx
  8006c1:	f7 d9                	neg    %ecx
  8006c3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cb:	e9 b8 00 00 00       	jmp    800788 <.L34+0x22>
	else if (lflag)
  8006d0:	85 c9                	test   %ecx,%ecx
  8006d2:	75 1b                	jne    8006ef <.L30+0x69>
		return va_arg(*ap, int);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 30                	mov    (%eax),%esi
  8006d9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006dc:	89 f0                	mov    %esi,%eax
  8006de:	c1 f8 1f             	sar    $0x1f,%eax
  8006e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ed:	eb b6                	jmp    8006a5 <.L30+0x1f>
		return va_arg(*ap, long);
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8b 30                	mov    (%eax),%esi
  8006f4:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006f7:	89 f0                	mov    %esi,%eax
  8006f9:	c1 f8 1f             	sar    $0x1f,%eax
  8006fc:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8d 40 04             	lea    0x4(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
  800708:	eb 9b                	jmp    8006a5 <.L30+0x1f>
			num = getint(&ap, lflag);
  80070a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80070d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800710:	b8 0a 00 00 00       	mov    $0xa,%eax
  800715:	eb 71                	jmp    800788 <.L34+0x22>

00800717 <.L37>:
  800717:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80071a:	83 f9 01             	cmp    $0x1,%ecx
  80071d:	7e 15                	jle    800734 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8b 10                	mov    (%eax),%edx
  800724:	8b 48 04             	mov    0x4(%eax),%ecx
  800727:	8d 40 08             	lea    0x8(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80072d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800732:	eb 54                	jmp    800788 <.L34+0x22>
	else if (lflag)
  800734:	85 c9                	test   %ecx,%ecx
  800736:	75 17                	jne    80074f <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800738:	8b 45 14             	mov    0x14(%ebp),%eax
  80073b:	8b 10                	mov    (%eax),%edx
  80073d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800742:	8d 40 04             	lea    0x4(%eax),%eax
  800745:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800748:	b8 0a 00 00 00       	mov    $0xa,%eax
  80074d:	eb 39                	jmp    800788 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8b 10                	mov    (%eax),%edx
  800754:	b9 00 00 00 00       	mov    $0x0,%ecx
  800759:	8d 40 04             	lea    0x4(%eax),%eax
  80075c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80075f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800764:	eb 22                	jmp    800788 <.L34+0x22>

00800766 <.L34>:
  800766:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800769:	83 f9 01             	cmp    $0x1,%ecx
  80076c:	7e 3b                	jle    8007a9 <.L34+0x43>
		return va_arg(*ap, long long);
  80076e:	8b 45 14             	mov    0x14(%ebp),%eax
  800771:	8b 50 04             	mov    0x4(%eax),%edx
  800774:	8b 00                	mov    (%eax),%eax
  800776:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800779:	8d 49 08             	lea    0x8(%ecx),%ecx
  80077c:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80077f:	89 d1                	mov    %edx,%ecx
  800781:	89 c2                	mov    %eax,%edx
			base = 8;
  800783:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800788:	83 ec 0c             	sub    $0xc,%esp
  80078b:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  80078f:	56                   	push   %esi
  800790:	ff 75 e0             	pushl  -0x20(%ebp)
  800793:	50                   	push   %eax
  800794:	51                   	push   %ecx
  800795:	52                   	push   %edx
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	e8 fd fa ff ff       	call   80029e <printnum>
			break;
  8007a1:	83 c4 20             	add    $0x20,%esp
  8007a4:	e9 19 fc ff ff       	jmp    8003c2 <vprintfmt+0x20>
	else if (lflag)
  8007a9:	85 c9                	test   %ecx,%ecx
  8007ab:	75 13                	jne    8007c0 <.L34+0x5a>
		return va_arg(*ap, int);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8b 10                	mov    (%eax),%edx
  8007b2:	89 d0                	mov    %edx,%eax
  8007b4:	99                   	cltd   
  8007b5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007b8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007bb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007be:	eb bf                	jmp    80077f <.L34+0x19>
		return va_arg(*ap, long);
  8007c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c3:	8b 10                	mov    (%eax),%edx
  8007c5:	89 d0                	mov    %edx,%eax
  8007c7:	99                   	cltd   
  8007c8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007cb:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007d1:	eb ac                	jmp    80077f <.L34+0x19>

008007d3 <.L35>:
			putch('0', putdat);
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	ff 75 0c             	pushl  0xc(%ebp)
  8007d9:	6a 30                	push   $0x30
  8007db:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007de:	83 c4 08             	add    $0x8,%esp
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	6a 78                	push   $0x78
  8007e6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8b 10                	mov    (%eax),%edx
  8007ee:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007f3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007f6:	8d 40 04             	lea    0x4(%eax),%eax
  8007f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007fc:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800801:	eb 85                	jmp    800788 <.L34+0x22>

00800803 <.L38>:
  800803:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800806:	83 f9 01             	cmp    $0x1,%ecx
  800809:	7e 18                	jle    800823 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8b 10                	mov    (%eax),%edx
  800810:	8b 48 04             	mov    0x4(%eax),%ecx
  800813:	8d 40 08             	lea    0x8(%eax),%eax
  800816:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800819:	b8 10 00 00 00       	mov    $0x10,%eax
  80081e:	e9 65 ff ff ff       	jmp    800788 <.L34+0x22>
	else if (lflag)
  800823:	85 c9                	test   %ecx,%ecx
  800825:	75 1a                	jne    800841 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800827:	8b 45 14             	mov    0x14(%ebp),%eax
  80082a:	8b 10                	mov    (%eax),%edx
  80082c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800831:	8d 40 04             	lea    0x4(%eax),%eax
  800834:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800837:	b8 10 00 00 00       	mov    $0x10,%eax
  80083c:	e9 47 ff ff ff       	jmp    800788 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8b 10                	mov    (%eax),%edx
  800846:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084b:	8d 40 04             	lea    0x4(%eax),%eax
  80084e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800851:	b8 10 00 00 00       	mov    $0x10,%eax
  800856:	e9 2d ff ff ff       	jmp    800788 <.L34+0x22>

0080085b <.L24>:
			putch(ch, putdat);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	6a 25                	push   $0x25
  800863:	ff 55 08             	call   *0x8(%ebp)
			break;
  800866:	83 c4 10             	add    $0x10,%esp
  800869:	e9 54 fb ff ff       	jmp    8003c2 <vprintfmt+0x20>

0080086e <.L21>:
			putch('%', putdat);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	ff 75 0c             	pushl  0xc(%ebp)
  800874:	6a 25                	push   $0x25
  800876:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800879:	83 c4 10             	add    $0x10,%esp
  80087c:	89 f7                	mov    %esi,%edi
  80087e:	eb 03                	jmp    800883 <.L21+0x15>
  800880:	83 ef 01             	sub    $0x1,%edi
  800883:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800887:	75 f7                	jne    800880 <.L21+0x12>
  800889:	e9 34 fb ff ff       	jmp    8003c2 <vprintfmt+0x20>
}
  80088e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800891:	5b                   	pop    %ebx
  800892:	5e                   	pop    %esi
  800893:	5f                   	pop    %edi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	53                   	push   %ebx
  80089a:	83 ec 14             	sub    $0x14,%esp
  80089d:	e8 bb f7 ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8008a2:	81 c3 5e 17 00 00    	add    $0x175e,%ebx
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	74 2b                	je     8008ee <vsnprintf+0x58>
  8008c3:	85 d2                	test   %edx,%edx
  8008c5:	7e 27                	jle    8008ee <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c7:	ff 75 14             	pushl  0x14(%ebp)
  8008ca:	ff 75 10             	pushl  0x10(%ebp)
  8008cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d0:	50                   	push   %eax
  8008d1:	8d 83 68 e3 ff ff    	lea    -0x1c98(%ebx),%eax
  8008d7:	50                   	push   %eax
  8008d8:	e8 c5 fa ff ff       	call   8003a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e6:	83 c4 10             	add    $0x10,%esp
}
  8008e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    
		return -E_INVAL;
  8008ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f3:	eb f4                	jmp    8008e9 <vsnprintf+0x53>

008008f5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008fe:	50                   	push   %eax
  8008ff:	ff 75 10             	pushl  0x10(%ebp)
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	ff 75 08             	pushl  0x8(%ebp)
  800908:	e8 89 ff ff ff       	call   800896 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <__x86.get_pc_thunk.cx>:
  80090f:	8b 0c 24             	mov    (%esp),%ecx
  800912:	c3                   	ret    

00800913 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	eb 03                	jmp    800923 <strlen+0x10>
		n++;
  800920:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800923:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800927:	75 f7                	jne    800920 <strlen+0xd>
	return n;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
  800939:	eb 03                	jmp    80093e <strnlen+0x13>
		n++;
  80093b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	74 06                	je     800948 <strnlen+0x1d>
  800942:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800946:	75 f3                	jne    80093b <strnlen+0x10>
	return n;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800954:	89 c2                	mov    %eax,%edx
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	83 c2 01             	add    $0x1,%edx
  80095c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800960:	88 5a ff             	mov    %bl,-0x1(%edx)
  800963:	84 db                	test   %bl,%bl
  800965:	75 ef                	jne    800956 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800971:	53                   	push   %ebx
  800972:	e8 9c ff ff ff       	call   800913 <strlen>
  800977:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80097a:	ff 75 0c             	pushl  0xc(%ebp)
  80097d:	01 d8                	add    %ebx,%eax
  80097f:	50                   	push   %eax
  800980:	e8 c5 ff ff ff       	call   80094a <strcpy>
	return dst;
}
  800985:	89 d8                	mov    %ebx,%eax
  800987:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 75 08             	mov    0x8(%ebp),%esi
  800994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800997:	89 f3                	mov    %esi,%ebx
  800999:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099c:	89 f2                	mov    %esi,%edx
  80099e:	eb 0f                	jmp    8009af <strncpy+0x23>
		*dst++ = *src;
  8009a0:	83 c2 01             	add    $0x1,%edx
  8009a3:	0f b6 01             	movzbl (%ecx),%eax
  8009a6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a9:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ac:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009af:	39 da                	cmp    %ebx,%edx
  8009b1:	75 ed                	jne    8009a0 <strncpy+0x14>
	}
	return ret;
}
  8009b3:	89 f0                	mov    %esi,%eax
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009c7:	89 f0                	mov    %esi,%eax
  8009c9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009cd:	85 c9                	test   %ecx,%ecx
  8009cf:	75 0b                	jne    8009dc <strlcpy+0x23>
  8009d1:	eb 17                	jmp    8009ea <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d3:	83 c2 01             	add    $0x1,%edx
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009dc:	39 d8                	cmp    %ebx,%eax
  8009de:	74 07                	je     8009e7 <strlcpy+0x2e>
  8009e0:	0f b6 0a             	movzbl (%edx),%ecx
  8009e3:	84 c9                	test   %cl,%cl
  8009e5:	75 ec                	jne    8009d3 <strlcpy+0x1a>
		*dst = '\0';
  8009e7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ea:	29 f0                	sub    %esi,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f9:	eb 06                	jmp    800a01 <strcmp+0x11>
		p++, q++;
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a01:	0f b6 01             	movzbl (%ecx),%eax
  800a04:	84 c0                	test   %al,%al
  800a06:	74 04                	je     800a0c <strcmp+0x1c>
  800a08:	3a 02                	cmp    (%edx),%al
  800a0a:	74 ef                	je     8009fb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0c:	0f b6 c0             	movzbl %al,%eax
  800a0f:	0f b6 12             	movzbl (%edx),%edx
  800a12:	29 d0                	sub    %edx,%eax
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a20:	89 c3                	mov    %eax,%ebx
  800a22:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a25:	eb 06                	jmp    800a2d <strncmp+0x17>
		n--, p++, q++;
  800a27:	83 c0 01             	add    $0x1,%eax
  800a2a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a2d:	39 d8                	cmp    %ebx,%eax
  800a2f:	74 16                	je     800a47 <strncmp+0x31>
  800a31:	0f b6 08             	movzbl (%eax),%ecx
  800a34:	84 c9                	test   %cl,%cl
  800a36:	74 04                	je     800a3c <strncmp+0x26>
  800a38:	3a 0a                	cmp    (%edx),%cl
  800a3a:	74 eb                	je     800a27 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3c:	0f b6 00             	movzbl (%eax),%eax
  800a3f:	0f b6 12             	movzbl (%edx),%edx
  800a42:	29 d0                	sub    %edx,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    
		return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	eb f6                	jmp    800a44 <strncmp+0x2e>

00800a4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a58:	0f b6 10             	movzbl (%eax),%edx
  800a5b:	84 d2                	test   %dl,%dl
  800a5d:	74 09                	je     800a68 <strchr+0x1a>
		if (*s == c)
  800a5f:	38 ca                	cmp    %cl,%dl
  800a61:	74 0a                	je     800a6d <strchr+0x1f>
	for (; *s; s++)
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	eb f0                	jmp    800a58 <strchr+0xa>
			return (char *) s;
	return 0;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a79:	eb 03                	jmp    800a7e <strfind+0xf>
  800a7b:	83 c0 01             	add    $0x1,%eax
  800a7e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a81:	38 ca                	cmp    %cl,%dl
  800a83:	74 04                	je     800a89 <strfind+0x1a>
  800a85:	84 d2                	test   %dl,%dl
  800a87:	75 f2                	jne    800a7b <strfind+0xc>
			break;
	return (char *) s;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a97:	85 c9                	test   %ecx,%ecx
  800a99:	74 13                	je     800aae <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa1:	75 05                	jne    800aa8 <memset+0x1d>
  800aa3:	f6 c1 03             	test   $0x3,%cl
  800aa6:	74 0d                	je     800ab5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	fc                   	cld    
  800aac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aae:	89 f8                	mov    %edi,%eax
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    
		c &= 0xFF;
  800ab5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab9:	89 d3                	mov    %edx,%ebx
  800abb:	c1 e3 08             	shl    $0x8,%ebx
  800abe:	89 d0                	mov    %edx,%eax
  800ac0:	c1 e0 18             	shl    $0x18,%eax
  800ac3:	89 d6                	mov    %edx,%esi
  800ac5:	c1 e6 10             	shl    $0x10,%esi
  800ac8:	09 f0                	or     %esi,%eax
  800aca:	09 c2                	or     %eax,%edx
  800acc:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ace:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ad1:	89 d0                	mov    %edx,%eax
  800ad3:	fc                   	cld    
  800ad4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad6:	eb d6                	jmp    800aae <memset+0x23>

00800ad8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae6:	39 c6                	cmp    %eax,%esi
  800ae8:	73 35                	jae    800b1f <memmove+0x47>
  800aea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aed:	39 c2                	cmp    %eax,%edx
  800aef:	76 2e                	jbe    800b1f <memmove+0x47>
		s += n;
		d += n;
  800af1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	09 fe                	or     %edi,%esi
  800af8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afe:	74 0c                	je     800b0c <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b06:	fd                   	std    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b09:	fc                   	cld    
  800b0a:	eb 21                	jmp    800b2d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 ef                	jne    800b00 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b11:	83 ef 04             	sub    $0x4,%edi
  800b14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b17:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b1a:	fd                   	std    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb ea                	jmp    800b09 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	89 f2                	mov    %esi,%edx
  800b21:	09 c2                	or     %eax,%edx
  800b23:	f6 c2 03             	test   $0x3,%dl
  800b26:	74 09                	je     800b31 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b28:	89 c7                	mov    %eax,%edi
  800b2a:	fc                   	cld    
  800b2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b31:	f6 c1 03             	test   $0x3,%cl
  800b34:	75 f2                	jne    800b28 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b36:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b39:	89 c7                	mov    %eax,%edi
  800b3b:	fc                   	cld    
  800b3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3e:	eb ed                	jmp    800b2d <memmove+0x55>

00800b40 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b43:	ff 75 10             	pushl  0x10(%ebp)
  800b46:	ff 75 0c             	pushl  0xc(%ebp)
  800b49:	ff 75 08             	pushl  0x8(%ebp)
  800b4c:	e8 87 ff ff ff       	call   800ad8 <memmove>
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5e:	89 c6                	mov    %eax,%esi
  800b60:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b63:	39 f0                	cmp    %esi,%eax
  800b65:	74 1c                	je     800b83 <memcmp+0x30>
		if (*s1 != *s2)
  800b67:	0f b6 08             	movzbl (%eax),%ecx
  800b6a:	0f b6 1a             	movzbl (%edx),%ebx
  800b6d:	38 d9                	cmp    %bl,%cl
  800b6f:	75 08                	jne    800b79 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b71:	83 c0 01             	add    $0x1,%eax
  800b74:	83 c2 01             	add    $0x1,%edx
  800b77:	eb ea                	jmp    800b63 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b79:	0f b6 c1             	movzbl %cl,%eax
  800b7c:	0f b6 db             	movzbl %bl,%ebx
  800b7f:	29 d8                	sub    %ebx,%eax
  800b81:	eb 05                	jmp    800b88 <memcmp+0x35>
	}

	return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b95:	89 c2                	mov    %eax,%edx
  800b97:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9a:	39 d0                	cmp    %edx,%eax
  800b9c:	73 09                	jae    800ba7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9e:	38 08                	cmp    %cl,(%eax)
  800ba0:	74 05                	je     800ba7 <memfind+0x1b>
	for (; s < ends; s++)
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	eb f3                	jmp    800b9a <memfind+0xe>
			break;
	return (void *) s;
}
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb5:	eb 03                	jmp    800bba <strtol+0x11>
		s++;
  800bb7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bba:	0f b6 01             	movzbl (%ecx),%eax
  800bbd:	3c 20                	cmp    $0x20,%al
  800bbf:	74 f6                	je     800bb7 <strtol+0xe>
  800bc1:	3c 09                	cmp    $0x9,%al
  800bc3:	74 f2                	je     800bb7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bc5:	3c 2b                	cmp    $0x2b,%al
  800bc7:	74 2e                	je     800bf7 <strtol+0x4e>
	int neg = 0;
  800bc9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bce:	3c 2d                	cmp    $0x2d,%al
  800bd0:	74 2f                	je     800c01 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bd8:	75 05                	jne    800bdf <strtol+0x36>
  800bda:	80 39 30             	cmpb   $0x30,(%ecx)
  800bdd:	74 2c                	je     800c0b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdf:	85 db                	test   %ebx,%ebx
  800be1:	75 0a                	jne    800bed <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800be8:	80 39 30             	cmpb   $0x30,(%ecx)
  800beb:	74 28                	je     800c15 <strtol+0x6c>
		base = 10;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bf5:	eb 50                	jmp    800c47 <strtol+0x9e>
		s++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bfa:	bf 00 00 00 00       	mov    $0x0,%edi
  800bff:	eb d1                	jmp    800bd2 <strtol+0x29>
		s++, neg = 1;
  800c01:	83 c1 01             	add    $0x1,%ecx
  800c04:	bf 01 00 00 00       	mov    $0x1,%edi
  800c09:	eb c7                	jmp    800bd2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c0f:	74 0e                	je     800c1f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c11:	85 db                	test   %ebx,%ebx
  800c13:	75 d8                	jne    800bed <strtol+0x44>
		s++, base = 8;
  800c15:	83 c1 01             	add    $0x1,%ecx
  800c18:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c1d:	eb ce                	jmp    800bed <strtol+0x44>
		s += 2, base = 16;
  800c1f:	83 c1 02             	add    $0x2,%ecx
  800c22:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c27:	eb c4                	jmp    800bed <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c29:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c2c:	89 f3                	mov    %esi,%ebx
  800c2e:	80 fb 19             	cmp    $0x19,%bl
  800c31:	77 29                	ja     800c5c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c33:	0f be d2             	movsbl %dl,%edx
  800c36:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c39:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c3c:	7d 30                	jge    800c6e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c3e:	83 c1 01             	add    $0x1,%ecx
  800c41:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c45:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c47:	0f b6 11             	movzbl (%ecx),%edx
  800c4a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c4d:	89 f3                	mov    %esi,%ebx
  800c4f:	80 fb 09             	cmp    $0x9,%bl
  800c52:	77 d5                	ja     800c29 <strtol+0x80>
			dig = *s - '0';
  800c54:	0f be d2             	movsbl %dl,%edx
  800c57:	83 ea 30             	sub    $0x30,%edx
  800c5a:	eb dd                	jmp    800c39 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c5c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c5f:	89 f3                	mov    %esi,%ebx
  800c61:	80 fb 19             	cmp    $0x19,%bl
  800c64:	77 08                	ja     800c6e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c66:	0f be d2             	movsbl %dl,%edx
  800c69:	83 ea 37             	sub    $0x37,%edx
  800c6c:	eb cb                	jmp    800c39 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c72:	74 05                	je     800c79 <strtol+0xd0>
		*endptr = (char *) s;
  800c74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c77:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c79:	89 c2                	mov    %eax,%edx
  800c7b:	f7 da                	neg    %edx
  800c7d:	85 ff                	test   %edi,%edi
  800c7f:	0f 45 c2             	cmovne %edx,%eax
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    
  800c87:	66 90                	xchg   %ax,%ax
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
