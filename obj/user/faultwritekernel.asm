
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	53                   	push   %ebx
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	e8 3b 00 00 00       	call   800089 <__x86.get_pc_thunk.bx>
  80004e:	81 c3 b2 1f 00 00    	add    $0x1fb2,%ebx
  800054:	8b 45 08             	mov    0x8(%ebp),%eax
  800057:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800060:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	7e 08                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006a:	8b 0a                	mov    (%edx),%ecx
  80006c:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	52                   	push   %edx
  800076:	50                   	push   %eax
  800077:	e8 b7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0c 00 00 00       	call   80008d <exit>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800087:	c9                   	leave  
  800088:	c3                   	ret    

00800089 <__x86.get_pc_thunk.bx>:
  800089:	8b 1c 24             	mov    (%esp),%ebx
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	53                   	push   %ebx
  800091:	83 ec 10             	sub    $0x10,%esp
  800094:	e8 f0 ff ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  800099:	81 c3 67 1f 00 00    	add    $0x1f67,%ebx
	sys_env_destroy(0);
  80009f:	6a 00                	push   $0x0
  8000a1:	e8 45 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 1c             	sub    $0x1c,%esp
  8000f4:	e8 66 00 00 00       	call   80015f <__x86.get_pc_thunk.ax>
  8000f9:	05 07 1f 00 00       	add    $0x1f07,%eax
  8000fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800101:	b9 00 00 00 00       	mov    $0x0,%ecx
  800106:	8b 55 08             	mov    0x8(%ebp),%edx
  800109:	b8 03 00 00 00       	mov    $0x3,%eax
  80010e:	89 cb                	mov    %ecx,%ebx
  800110:	89 cf                	mov    %ecx,%edi
  800112:	89 ce                	mov    %ecx,%esi
  800114:	cd 30                	int    $0x30
	if(check && ret > 0)
  800116:	85 c0                	test   %eax,%eax
  800118:	7f 08                	jg     800122 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011d:	5b                   	pop    %ebx
  80011e:	5e                   	pop    %esi
  80011f:	5f                   	pop    %edi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800122:	83 ec 0c             	sub    $0xc,%esp
  800125:	50                   	push   %eax
  800126:	6a 03                	push   $0x3
  800128:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80012b:	8d 83 b6 ee ff ff    	lea    -0x114a(%ebx),%eax
  800131:	50                   	push   %eax
  800132:	6a 23                	push   $0x23
  800134:	8d 83 d3 ee ff ff    	lea    -0x112d(%ebx),%eax
  80013a:	50                   	push   %eax
  80013b:	e8 23 00 00 00       	call   800163 <_panic>

00800140 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
	asm volatile("int %1\n"
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 02 00 00 00       	mov    $0x2,%eax
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 d3                	mov    %edx,%ebx
  800154:	89 d7                	mov    %edx,%edi
  800156:	89 d6                	mov    %edx,%esi
  800158:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <__x86.get_pc_thunk.ax>:
  80015f:	8b 04 24             	mov    (%esp),%eax
  800162:	c3                   	ret    

00800163 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
  80016c:	e8 18 ff ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  800171:	81 c3 8f 1e 00 00    	add    $0x1e8f,%ebx
	va_list ap;

	va_start(ap, fmt);
  800177:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80017a:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800180:	8b 38                	mov    (%eax),%edi
  800182:	e8 b9 ff ff ff       	call   800140 <sys_getenvid>
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	ff 75 0c             	pushl  0xc(%ebp)
  80018d:	ff 75 08             	pushl  0x8(%ebp)
  800190:	57                   	push   %edi
  800191:	50                   	push   %eax
  800192:	8d 83 e4 ee ff ff    	lea    -0x111c(%ebx),%eax
  800198:	50                   	push   %eax
  800199:	e8 d1 00 00 00       	call   80026f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019e:	83 c4 18             	add    $0x18,%esp
  8001a1:	56                   	push   %esi
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	e8 63 00 00 00       	call   80020d <vcprintf>
	cprintf("\n");
  8001aa:	8d 83 08 ef ff ff    	lea    -0x10f8(%ebx),%eax
  8001b0:	89 04 24             	mov    %eax,(%esp)
  8001b3:	e8 b7 00 00 00       	call   80026f <cprintf>
  8001b8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bb:	cc                   	int3   
  8001bc:	eb fd                	jmp    8001bb <_panic+0x58>

008001be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	e8 c1 fe ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  8001c8:	81 c3 38 1e 00 00    	add    $0x1e38,%ebx
  8001ce:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001d1:	8b 16                	mov    (%esi),%edx
  8001d3:	8d 42 01             	lea    0x1(%edx),%eax
  8001d6:	89 06                	mov    %eax,(%esi)
  8001d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001db:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001e4:	74 0b                	je     8001f1 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001e6:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ed:	5b                   	pop    %ebx
  8001ee:	5e                   	pop    %esi
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001f1:	83 ec 08             	sub    $0x8,%esp
  8001f4:	68 ff 00 00 00       	push   $0xff
  8001f9:	8d 46 08             	lea    0x8(%esi),%eax
  8001fc:	50                   	push   %eax
  8001fd:	e8 ac fe ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  800202:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	eb d9                	jmp    8001e6 <putch+0x28>

0080020d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	53                   	push   %ebx
  800211:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800217:	e8 6d fe ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  80021c:	81 c3 e4 1d 00 00    	add    $0x1de4,%ebx
	struct printbuf b;

	b.idx = 0;
  800222:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800229:	00 00 00 
	b.cnt = 0;
  80022c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800233:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800236:	ff 75 0c             	pushl  0xc(%ebp)
  800239:	ff 75 08             	pushl  0x8(%ebp)
  80023c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800242:	50                   	push   %eax
  800243:	8d 83 be e1 ff ff    	lea    -0x1e42(%ebx),%eax
  800249:	50                   	push   %eax
  80024a:	e8 38 01 00 00       	call   800387 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024f:	83 c4 08             	add    $0x8,%esp
  800252:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800258:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025e:	50                   	push   %eax
  80025f:	e8 4a fe ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  800264:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80026d:	c9                   	leave  
  80026e:	c3                   	ret    

0080026f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800275:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800278:	50                   	push   %eax
  800279:	ff 75 08             	pushl  0x8(%ebp)
  80027c:	e8 8c ff ff ff       	call   80020d <vcprintf>
	va_end(ap);

	return cnt;
}
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 2c             	sub    $0x2c,%esp
  80028c:	e8 63 06 00 00       	call   8008f4 <__x86.get_pc_thunk.cx>
  800291:	81 c1 6f 1d 00 00    	add    $0x1d6f,%ecx
  800297:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80029a:	89 c7                	mov    %eax,%edi
  80029c:	89 d6                	mov    %edx,%esi
  80029e:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002b5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002b8:	39 d3                	cmp    %edx,%ebx
  8002ba:	72 09                	jb     8002c5 <printnum+0x42>
  8002bc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002bf:	0f 87 83 00 00 00    	ja     800348 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c5:	83 ec 0c             	sub    $0xc,%esp
  8002c8:	ff 75 18             	pushl  0x18(%ebp)
  8002cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ce:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002d1:	53                   	push   %ebx
  8002d2:	ff 75 10             	pushl  0x10(%ebp)
  8002d5:	83 ec 08             	sub    $0x8,%esp
  8002d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002db:	ff 75 d8             	pushl  -0x28(%ebp)
  8002de:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002e1:	ff 75 d0             	pushl  -0x30(%ebp)
  8002e4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002e7:	e8 84 09 00 00       	call   800c70 <__udivdi3>
  8002ec:	83 c4 18             	add    $0x18,%esp
  8002ef:	52                   	push   %edx
  8002f0:	50                   	push   %eax
  8002f1:	89 f2                	mov    %esi,%edx
  8002f3:	89 f8                	mov    %edi,%eax
  8002f5:	e8 89 ff ff ff       	call   800283 <printnum>
  8002fa:	83 c4 20             	add    $0x20,%esp
  8002fd:	eb 13                	jmp    800312 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	ff 75 18             	pushl  0x18(%ebp)
  800306:	ff d7                	call   *%edi
  800308:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80030b:	83 eb 01             	sub    $0x1,%ebx
  80030e:	85 db                	test   %ebx,%ebx
  800310:	7f ed                	jg     8002ff <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	56                   	push   %esi
  800316:	83 ec 04             	sub    $0x4,%esp
  800319:	ff 75 dc             	pushl  -0x24(%ebp)
  80031c:	ff 75 d8             	pushl  -0x28(%ebp)
  80031f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800322:	ff 75 d0             	pushl  -0x30(%ebp)
  800325:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800328:	89 f3                	mov    %esi,%ebx
  80032a:	e8 61 0a 00 00       	call   800d90 <__umoddi3>
  80032f:	83 c4 14             	add    $0x14,%esp
  800332:	0f be 84 06 0a ef ff 	movsbl -0x10f6(%esi,%eax,1),%eax
  800339:	ff 
  80033a:	50                   	push   %eax
  80033b:	ff d7                	call   *%edi
}
  80033d:	83 c4 10             	add    $0x10,%esp
  800340:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    
  800348:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80034b:	eb be                	jmp    80030b <printnum+0x88>

0080034d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800353:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800357:	8b 10                	mov    (%eax),%edx
  800359:	3b 50 04             	cmp    0x4(%eax),%edx
  80035c:	73 0a                	jae    800368 <sprintputch+0x1b>
		*b->buf++ = ch;
  80035e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 45 08             	mov    0x8(%ebp),%eax
  800366:	88 02                	mov    %al,(%edx)
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <printfmt>:
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800370:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800373:	50                   	push   %eax
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 05 00 00 00       	call   800387 <vprintfmt>
}
  800382:	83 c4 10             	add    $0x10,%esp
  800385:	c9                   	leave  
  800386:	c3                   	ret    

00800387 <vprintfmt>:
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	57                   	push   %edi
  80038b:	56                   	push   %esi
  80038c:	53                   	push   %ebx
  80038d:	83 ec 2c             	sub    $0x2c,%esp
  800390:	e8 f4 fc ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  800395:	81 c3 6b 1c 00 00    	add    $0x1c6b,%ebx
  80039b:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  80039e:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003a5:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a7:	8d 77 01             	lea    0x1(%edi),%esi
  8003aa:	0f b6 07             	movzbl (%edi),%eax
  8003ad:	83 f8 25             	cmp    $0x25,%eax
  8003b0:	74 1c                	je     8003ce <vprintfmt+0x47>
			if (ch == '\0')
  8003b2:	85 c0                	test   %eax,%eax
  8003b4:	0f 84 b9 04 00 00    	je     800873 <.L21+0x20>
			putch(ch, putdat);
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003c0:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003c3:	50                   	push   %eax
  8003c4:	ff 55 08             	call   *0x8(%ebp)
  8003c7:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ca:	89 f7                	mov    %esi,%edi
  8003cc:	eb d9                	jmp    8003a7 <vprintfmt+0x20>
		padc = ' ';
  8003ce:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003d2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003d9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ec:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8d 7e 01             	lea    0x1(%esi),%edi
  8003f2:	0f b6 16             	movzbl (%esi),%edx
  8003f5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f8:	3c 55                	cmp    $0x55,%al
  8003fa:	0f 87 53 04 00 00    	ja     800853 <.L21>
  800400:	0f b6 c0             	movzbl %al,%eax
  800403:	89 d9                	mov    %ebx,%ecx
  800405:	03 8c 83 98 ef ff ff 	add    -0x1068(%ebx,%eax,4),%ecx
  80040c:	ff e1                	jmp    *%ecx

0080040e <.L73>:
  80040e:	89 fe                	mov    %edi,%esi
			padc = '-';
  800410:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800414:	eb d9                	jmp    8003ef <vprintfmt+0x68>

00800416 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	89 fe                	mov    %edi,%esi
			padc = '0';
  800418:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80041c:	eb d1                	jmp    8003ef <vprintfmt+0x68>

0080041e <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	0f b6 d2             	movzbl %dl,%edx
  800421:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800423:	b8 00 00 00 00       	mov    $0x0,%eax
  800428:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  80042b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800432:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800435:	8d 7a d0             	lea    -0x30(%edx),%edi
  800438:	83 ff 09             	cmp    $0x9,%edi
  80043b:	0f 87 94 00 00 00    	ja     8004d5 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800441:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800444:	eb e5                	jmp    80042b <.L28+0xd>

00800446 <.L25>:
			precision = va_arg(ap, int);
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8b 00                	mov    (%eax),%eax
  80044b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80044e:	8b 45 14             	mov    0x14(%ebp),%eax
  800451:	8d 40 04             	lea    0x4(%eax),%eax
  800454:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800457:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800459:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045d:	79 90                	jns    8003ef <vprintfmt+0x68>
				width = precision, precision = -1;
  80045f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800465:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80046c:	eb 81                	jmp    8003ef <vprintfmt+0x68>

0080046e <.L26>:
  80046e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800471:	85 c0                	test   %eax,%eax
  800473:	ba 00 00 00 00       	mov    $0x0,%edx
  800478:	0f 49 d0             	cmovns %eax,%edx
  80047b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	89 fe                	mov    %edi,%esi
  800480:	e9 6a ff ff ff       	jmp    8003ef <vprintfmt+0x68>

00800485 <.L22>:
  800485:	89 fe                	mov    %edi,%esi
			altflag = 1;
  800487:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80048e:	e9 5c ff ff ff       	jmp    8003ef <vprintfmt+0x68>

00800493 <.L33>:
  800493:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800496:	83 f9 01             	cmp    $0x1,%ecx
  800499:	7e 16                	jle    8004b1 <.L33+0x1e>
		return va_arg(*ap, long long);
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004a3:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004a6:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004ac:	e9 f6 fe ff ff       	jmp    8003a7 <vprintfmt+0x20>
	else if (lflag)
  8004b1:	85 c9                	test   %ecx,%ecx
  8004b3:	75 10                	jne    8004c5 <.L33+0x32>
		return va_arg(*ap, int);
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004bd:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004c0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004c3:	eb e4                	jmp    8004a9 <.L33+0x16>
		return va_arg(*ap, long);
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8b 00                	mov    (%eax),%eax
  8004ca:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004cd:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004d0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d3:	eb d4                	jmp    8004a9 <.L33+0x16>
  8004d5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004d8:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004db:	e9 79 ff ff ff       	jmp    800459 <.L25+0x13>

008004e0 <.L32>:
			lflag++;
  8004e0:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8004e6:	e9 04 ff ff ff       	jmp    8003ef <vprintfmt+0x68>

008004eb <.L29>:
			putch(va_arg(ap, int), putdat);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 70 04             	lea    0x4(%eax),%esi
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	ff 75 0c             	pushl  0xc(%ebp)
  8004f7:	ff 30                	pushl  (%eax)
  8004f9:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004fc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004ff:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800502:	e9 a0 fe ff ff       	jmp    8003a7 <vprintfmt+0x20>

00800507 <.L31>:
			err = va_arg(ap, int);
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8d 70 04             	lea    0x4(%eax),%esi
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	99                   	cltd   
  800510:	31 d0                	xor    %edx,%eax
  800512:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800514:	83 f8 06             	cmp    $0x6,%eax
  800517:	7f 29                	jg     800542 <.L31+0x3b>
  800519:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800520:	85 d2                	test   %edx,%edx
  800522:	74 1e                	je     800542 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800524:	52                   	push   %edx
  800525:	8d 83 2b ef ff ff    	lea    -0x10d5(%ebx),%eax
  80052b:	50                   	push   %eax
  80052c:	ff 75 0c             	pushl  0xc(%ebp)
  80052f:	ff 75 08             	pushl  0x8(%ebp)
  800532:	e8 33 fe ff ff       	call   80036a <printfmt>
  800537:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80053a:	89 75 14             	mov    %esi,0x14(%ebp)
  80053d:	e9 65 fe ff ff       	jmp    8003a7 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800542:	50                   	push   %eax
  800543:	8d 83 22 ef ff ff    	lea    -0x10de(%ebx),%eax
  800549:	50                   	push   %eax
  80054a:	ff 75 0c             	pushl  0xc(%ebp)
  80054d:	ff 75 08             	pushl  0x8(%ebp)
  800550:	e8 15 fe ff ff       	call   80036a <printfmt>
  800555:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800558:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80055b:	e9 47 fe ff ff       	jmp    8003a7 <vprintfmt+0x20>

00800560 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	83 c0 04             	add    $0x4,%eax
  800566:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80056e:	85 f6                	test   %esi,%esi
  800570:	8d 83 1b ef ff ff    	lea    -0x10e5(%ebx),%eax
  800576:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800579:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057d:	0f 8e b4 00 00 00    	jle    800637 <.L36+0xd7>
  800583:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  800587:	75 08                	jne    800591 <.L36+0x31>
  800589:	89 7d 10             	mov    %edi,0x10(%ebp)
  80058c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80058f:	eb 6c                	jmp    8005fd <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	ff 75 cc             	pushl  -0x34(%ebp)
  800597:	56                   	push   %esi
  800598:	e8 73 03 00 00       	call   800910 <strnlen>
  80059d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005a0:	29 c2                	sub    %eax,%edx
  8005a2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005a5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a8:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005ac:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005af:	89 d6                	mov    %edx,%esi
  8005b1:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005b4:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b6:	eb 10                	jmp    8005c8 <.L36+0x68>
					putch(padc, putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	ff 75 0c             	pushl  0xc(%ebp)
  8005be:	57                   	push   %edi
  8005bf:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c2:	83 ee 01             	sub    $0x1,%esi
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	85 f6                	test   %esi,%esi
  8005ca:	7f ec                	jg     8005b8 <.L36+0x58>
  8005cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d9:	0f 49 c2             	cmovns %edx,%eax
  8005dc:	29 c2                	sub    %eax,%edx
  8005de:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005e1:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005e4:	eb 17                	jmp    8005fd <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ea:	75 30                	jne    80061c <.L36+0xbc>
					putch(ch, putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	ff 75 0c             	pushl  0xc(%ebp)
  8005f2:	50                   	push   %eax
  8005f3:	ff 55 08             	call   *0x8(%ebp)
  8005f6:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f9:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005fd:	83 c6 01             	add    $0x1,%esi
  800600:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800604:	0f be c2             	movsbl %dl,%eax
  800607:	85 c0                	test   %eax,%eax
  800609:	74 58                	je     800663 <.L36+0x103>
  80060b:	85 ff                	test   %edi,%edi
  80060d:	78 d7                	js     8005e6 <.L36+0x86>
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	79 d2                	jns    8005e6 <.L36+0x86>
  800614:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800617:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80061a:	eb 32                	jmp    80064e <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  80061c:	0f be d2             	movsbl %dl,%edx
  80061f:	83 ea 20             	sub    $0x20,%edx
  800622:	83 fa 5e             	cmp    $0x5e,%edx
  800625:	76 c5                	jbe    8005ec <.L36+0x8c>
					putch('?', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	ff 75 0c             	pushl  0xc(%ebp)
  80062d:	6a 3f                	push   $0x3f
  80062f:	ff 55 08             	call   *0x8(%ebp)
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb c2                	jmp    8005f9 <.L36+0x99>
  800637:	89 7d 10             	mov    %edi,0x10(%ebp)
  80063a:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80063d:	eb be                	jmp    8005fd <.L36+0x9d>
				putch(' ', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	57                   	push   %edi
  800643:	6a 20                	push   $0x20
  800645:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800648:	83 ee 01             	sub    $0x1,%esi
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	85 f6                	test   %esi,%esi
  800650:	7f ed                	jg     80063f <.L36+0xdf>
  800652:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800655:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800658:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80065b:	89 45 14             	mov    %eax,0x14(%ebp)
  80065e:	e9 44 fd ff ff       	jmp    8003a7 <vprintfmt+0x20>
  800663:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800666:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800669:	eb e3                	jmp    80064e <.L36+0xee>

0080066b <.L30>:
  80066b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80066e:	83 f9 01             	cmp    $0x1,%ecx
  800671:	7e 42                	jle    8006b5 <.L30+0x4a>
		return va_arg(*ap, long long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 50 04             	mov    0x4(%eax),%edx
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8d 40 08             	lea    0x8(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80068a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80068e:	79 5f                	jns    8006ef <.L30+0x84>
				putch('-', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	ff 75 0c             	pushl  0xc(%ebp)
  800696:	6a 2d                	push   $0x2d
  800698:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80069b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006a1:	f7 da                	neg    %edx
  8006a3:	83 d1 00             	adc    $0x0,%ecx
  8006a6:	f7 d9                	neg    %ecx
  8006a8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b0:	e9 b8 00 00 00       	jmp    80076d <.L34+0x22>
	else if (lflag)
  8006b5:	85 c9                	test   %ecx,%ecx
  8006b7:	75 1b                	jne    8006d4 <.L30+0x69>
		return va_arg(*ap, int);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 30                	mov    (%eax),%esi
  8006be:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006c1:	89 f0                	mov    %esi,%eax
  8006c3:	c1 f8 1f             	sar    $0x1f,%eax
  8006c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 40 04             	lea    0x4(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d2:	eb b6                	jmp    80068a <.L30+0x1f>
		return va_arg(*ap, long);
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8b 30                	mov    (%eax),%esi
  8006d9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006dc:	89 f0                	mov    %esi,%eax
  8006de:	c1 f8 1f             	sar    $0x1f,%eax
  8006e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 40 04             	lea    0x4(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ed:	eb 9b                	jmp    80068a <.L30+0x1f>
			num = getint(&ap, lflag);
  8006ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006f2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fa:	eb 71                	jmp    80076d <.L34+0x22>

008006fc <.L37>:
  8006fc:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8006ff:	83 f9 01             	cmp    $0x1,%ecx
  800702:	7e 15                	jle    800719 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8b 10                	mov    (%eax),%edx
  800709:	8b 48 04             	mov    0x4(%eax),%ecx
  80070c:	8d 40 08             	lea    0x8(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800712:	b8 0a 00 00 00       	mov    $0xa,%eax
  800717:	eb 54                	jmp    80076d <.L34+0x22>
	else if (lflag)
  800719:	85 c9                	test   %ecx,%ecx
  80071b:	75 17                	jne    800734 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80072d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800732:	eb 39                	jmp    80076d <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800744:	b8 0a 00 00 00       	mov    $0xa,%eax
  800749:	eb 22                	jmp    80076d <.L34+0x22>

0080074b <.L34>:
  80074b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80074e:	83 f9 01             	cmp    $0x1,%ecx
  800751:	7e 3b                	jle    80078e <.L34+0x43>
		return va_arg(*ap, long long);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8b 50 04             	mov    0x4(%eax),%edx
  800759:	8b 00                	mov    (%eax),%eax
  80075b:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80075e:	8d 49 08             	lea    0x8(%ecx),%ecx
  800761:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800764:	89 d1                	mov    %edx,%ecx
  800766:	89 c2                	mov    %eax,%edx
			base = 8;
  800768:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80076d:	83 ec 0c             	sub    $0xc,%esp
  800770:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800774:	56                   	push   %esi
  800775:	ff 75 e0             	pushl  -0x20(%ebp)
  800778:	50                   	push   %eax
  800779:	51                   	push   %ecx
  80077a:	52                   	push   %edx
  80077b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	e8 fd fa ff ff       	call   800283 <printnum>
			break;
  800786:	83 c4 20             	add    $0x20,%esp
  800789:	e9 19 fc ff ff       	jmp    8003a7 <vprintfmt+0x20>
	else if (lflag)
  80078e:	85 c9                	test   %ecx,%ecx
  800790:	75 13                	jne    8007a5 <.L34+0x5a>
		return va_arg(*ap, int);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8b 10                	mov    (%eax),%edx
  800797:	89 d0                	mov    %edx,%eax
  800799:	99                   	cltd   
  80079a:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80079d:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007a0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a3:	eb bf                	jmp    800764 <.L34+0x19>
		return va_arg(*ap, long);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8b 10                	mov    (%eax),%edx
  8007aa:	89 d0                	mov    %edx,%eax
  8007ac:	99                   	cltd   
  8007ad:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007b0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b6:	eb ac                	jmp    800764 <.L34+0x19>

008007b8 <.L35>:
			putch('0', putdat);
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	ff 75 0c             	pushl  0xc(%ebp)
  8007be:	6a 30                	push   $0x30
  8007c0:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007c3:	83 c4 08             	add    $0x8,%esp
  8007c6:	ff 75 0c             	pushl  0xc(%ebp)
  8007c9:	6a 78                	push   $0x78
  8007cb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8b 10                	mov    (%eax),%edx
  8007d3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007d8:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007db:	8d 40 04             	lea    0x4(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007e6:	eb 85                	jmp    80076d <.L34+0x22>

008007e8 <.L38>:
  8007e8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8007eb:	83 f9 01             	cmp    $0x1,%ecx
  8007ee:	7e 18                	jle    800808 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8b 10                	mov    (%eax),%edx
  8007f5:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f8:	8d 40 08             	lea    0x8(%eax),%eax
  8007fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007fe:	b8 10 00 00 00       	mov    $0x10,%eax
  800803:	e9 65 ff ff ff       	jmp    80076d <.L34+0x22>
	else if (lflag)
  800808:	85 c9                	test   %ecx,%ecx
  80080a:	75 1a                	jne    800826 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8b 10                	mov    (%eax),%edx
  800811:	b9 00 00 00 00       	mov    $0x0,%ecx
  800816:	8d 40 04             	lea    0x4(%eax),%eax
  800819:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80081c:	b8 10 00 00 00       	mov    $0x10,%eax
  800821:	e9 47 ff ff ff       	jmp    80076d <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800826:	8b 45 14             	mov    0x14(%ebp),%eax
  800829:	8b 10                	mov    (%eax),%edx
  80082b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800830:	8d 40 04             	lea    0x4(%eax),%eax
  800833:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800836:	b8 10 00 00 00       	mov    $0x10,%eax
  80083b:	e9 2d ff ff ff       	jmp    80076d <.L34+0x22>

00800840 <.L24>:
			putch(ch, putdat);
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	ff 75 0c             	pushl  0xc(%ebp)
  800846:	6a 25                	push   $0x25
  800848:	ff 55 08             	call   *0x8(%ebp)
			break;
  80084b:	83 c4 10             	add    $0x10,%esp
  80084e:	e9 54 fb ff ff       	jmp    8003a7 <vprintfmt+0x20>

00800853 <.L21>:
			putch('%', putdat);
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	ff 75 0c             	pushl  0xc(%ebp)
  800859:	6a 25                	push   $0x25
  80085b:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085e:	83 c4 10             	add    $0x10,%esp
  800861:	89 f7                	mov    %esi,%edi
  800863:	eb 03                	jmp    800868 <.L21+0x15>
  800865:	83 ef 01             	sub    $0x1,%edi
  800868:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80086c:	75 f7                	jne    800865 <.L21+0x12>
  80086e:	e9 34 fb ff ff       	jmp    8003a7 <vprintfmt+0x20>
}
  800873:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800876:	5b                   	pop    %ebx
  800877:	5e                   	pop    %esi
  800878:	5f                   	pop    %edi
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	83 ec 14             	sub    $0x14,%esp
  800882:	e8 02 f8 ff ff       	call   800089 <__x86.get_pc_thunk.bx>
  800887:	81 c3 79 17 00 00    	add    $0x1779,%ebx
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800893:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800896:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	74 2b                	je     8008d3 <vsnprintf+0x58>
  8008a8:	85 d2                	test   %edx,%edx
  8008aa:	7e 27                	jle    8008d3 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ac:	ff 75 14             	pushl  0x14(%ebp)
  8008af:	ff 75 10             	pushl  0x10(%ebp)
  8008b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b5:	50                   	push   %eax
  8008b6:	8d 83 4d e3 ff ff    	lea    -0x1cb3(%ebx),%eax
  8008bc:	50                   	push   %eax
  8008bd:	e8 c5 fa ff ff       	call   800387 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cb:	83 c4 10             	add    $0x10,%esp
}
  8008ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    
		return -E_INVAL;
  8008d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d8:	eb f4                	jmp    8008ce <vsnprintf+0x53>

008008da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e3:	50                   	push   %eax
  8008e4:	ff 75 10             	pushl  0x10(%ebp)
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	ff 75 08             	pushl  0x8(%ebp)
  8008ed:	e8 89 ff ff ff       	call   80087b <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f2:	c9                   	leave  
  8008f3:	c3                   	ret    

008008f4 <__x86.get_pc_thunk.cx>:
  8008f4:	8b 0c 24             	mov    (%esp),%ecx
  8008f7:	c3                   	ret    

008008f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800903:	eb 03                	jmp    800908 <strlen+0x10>
		n++;
  800905:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800908:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80090c:	75 f7                	jne    800905 <strlen+0xd>
	return n;
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	eb 03                	jmp    800923 <strnlen+0x13>
		n++;
  800920:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800923:	39 d0                	cmp    %edx,%eax
  800925:	74 06                	je     80092d <strnlen+0x1d>
  800927:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80092b:	75 f3                	jne    800920 <strnlen+0x10>
	return n;
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	53                   	push   %ebx
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800939:	89 c2                	mov    %eax,%edx
  80093b:	83 c1 01             	add    $0x1,%ecx
  80093e:	83 c2 01             	add    $0x1,%edx
  800941:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800945:	88 5a ff             	mov    %bl,-0x1(%edx)
  800948:	84 db                	test   %bl,%bl
  80094a:	75 ef                	jne    80093b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80094c:	5b                   	pop    %ebx
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	53                   	push   %ebx
  800953:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800956:	53                   	push   %ebx
  800957:	e8 9c ff ff ff       	call   8008f8 <strlen>
  80095c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80095f:	ff 75 0c             	pushl  0xc(%ebp)
  800962:	01 d8                	add    %ebx,%eax
  800964:	50                   	push   %eax
  800965:	e8 c5 ff ff ff       	call   80092f <strcpy>
	return dst;
}
  80096a:	89 d8                	mov    %ebx,%eax
  80096c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	56                   	push   %esi
  800975:	53                   	push   %ebx
  800976:	8b 75 08             	mov    0x8(%ebp),%esi
  800979:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097c:	89 f3                	mov    %esi,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800981:	89 f2                	mov    %esi,%edx
  800983:	eb 0f                	jmp    800994 <strncpy+0x23>
		*dst++ = *src;
  800985:	83 c2 01             	add    $0x1,%edx
  800988:	0f b6 01             	movzbl (%ecx),%eax
  80098b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80098e:	80 39 01             	cmpb   $0x1,(%ecx)
  800991:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800994:	39 da                	cmp    %ebx,%edx
  800996:	75 ed                	jne    800985 <strncpy+0x14>
	}
	return ret;
}
  800998:	89 f0                	mov    %esi,%eax
  80099a:	5b                   	pop    %ebx
  80099b:	5e                   	pop    %esi
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	56                   	push   %esi
  8009a2:	53                   	push   %ebx
  8009a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ac:	89 f0                	mov    %esi,%eax
  8009ae:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b2:	85 c9                	test   %ecx,%ecx
  8009b4:	75 0b                	jne    8009c1 <strlcpy+0x23>
  8009b6:	eb 17                	jmp    8009cf <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b8:	83 c2 01             	add    $0x1,%edx
  8009bb:	83 c0 01             	add    $0x1,%eax
  8009be:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009c1:	39 d8                	cmp    %ebx,%eax
  8009c3:	74 07                	je     8009cc <strlcpy+0x2e>
  8009c5:	0f b6 0a             	movzbl (%edx),%ecx
  8009c8:	84 c9                	test   %cl,%cl
  8009ca:	75 ec                	jne    8009b8 <strlcpy+0x1a>
		*dst = '\0';
  8009cc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009cf:	29 f0                	sub    %esi,%eax
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009de:	eb 06                	jmp    8009e6 <strcmp+0x11>
		p++, q++;
  8009e0:	83 c1 01             	add    $0x1,%ecx
  8009e3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009e6:	0f b6 01             	movzbl (%ecx),%eax
  8009e9:	84 c0                	test   %al,%al
  8009eb:	74 04                	je     8009f1 <strcmp+0x1c>
  8009ed:	3a 02                	cmp    (%edx),%al
  8009ef:	74 ef                	je     8009e0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f1:	0f b6 c0             	movzbl %al,%eax
  8009f4:	0f b6 12             	movzbl (%edx),%edx
  8009f7:	29 d0                	sub    %edx,%eax
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a05:	89 c3                	mov    %eax,%ebx
  800a07:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a0a:	eb 06                	jmp    800a12 <strncmp+0x17>
		n--, p++, q++;
  800a0c:	83 c0 01             	add    $0x1,%eax
  800a0f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a12:	39 d8                	cmp    %ebx,%eax
  800a14:	74 16                	je     800a2c <strncmp+0x31>
  800a16:	0f b6 08             	movzbl (%eax),%ecx
  800a19:	84 c9                	test   %cl,%cl
  800a1b:	74 04                	je     800a21 <strncmp+0x26>
  800a1d:	3a 0a                	cmp    (%edx),%cl
  800a1f:	74 eb                	je     800a0c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a21:	0f b6 00             	movzbl (%eax),%eax
  800a24:	0f b6 12             	movzbl (%edx),%edx
  800a27:	29 d0                	sub    %edx,%eax
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    
		return 0;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	eb f6                	jmp    800a29 <strncmp+0x2e>

00800a33 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a3d:	0f b6 10             	movzbl (%eax),%edx
  800a40:	84 d2                	test   %dl,%dl
  800a42:	74 09                	je     800a4d <strchr+0x1a>
		if (*s == c)
  800a44:	38 ca                	cmp    %cl,%dl
  800a46:	74 0a                	je     800a52 <strchr+0x1f>
	for (; *s; s++)
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	eb f0                	jmp    800a3d <strchr+0xa>
			return (char *) s;
	return 0;
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a5e:	eb 03                	jmp    800a63 <strfind+0xf>
  800a60:	83 c0 01             	add    $0x1,%eax
  800a63:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a66:	38 ca                	cmp    %cl,%dl
  800a68:	74 04                	je     800a6e <strfind+0x1a>
  800a6a:	84 d2                	test   %dl,%dl
  800a6c:	75 f2                	jne    800a60 <strfind+0xc>
			break;
	return (char *) s;
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a7c:	85 c9                	test   %ecx,%ecx
  800a7e:	74 13                	je     800a93 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a80:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a86:	75 05                	jne    800a8d <memset+0x1d>
  800a88:	f6 c1 03             	test   $0x3,%cl
  800a8b:	74 0d                	je     800a9a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a90:	fc                   	cld    
  800a91:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a93:	89 f8                	mov    %edi,%eax
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    
		c &= 0xFF;
  800a9a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9e:	89 d3                	mov    %edx,%ebx
  800aa0:	c1 e3 08             	shl    $0x8,%ebx
  800aa3:	89 d0                	mov    %edx,%eax
  800aa5:	c1 e0 18             	shl    $0x18,%eax
  800aa8:	89 d6                	mov    %edx,%esi
  800aaa:	c1 e6 10             	shl    $0x10,%esi
  800aad:	09 f0                	or     %esi,%eax
  800aaf:	09 c2                	or     %eax,%edx
  800ab1:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ab3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ab6:	89 d0                	mov    %edx,%eax
  800ab8:	fc                   	cld    
  800ab9:	f3 ab                	rep stos %eax,%es:(%edi)
  800abb:	eb d6                	jmp    800a93 <memset+0x23>

00800abd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800acb:	39 c6                	cmp    %eax,%esi
  800acd:	73 35                	jae    800b04 <memmove+0x47>
  800acf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad2:	39 c2                	cmp    %eax,%edx
  800ad4:	76 2e                	jbe    800b04 <memmove+0x47>
		s += n;
		d += n;
  800ad6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad9:	89 d6                	mov    %edx,%esi
  800adb:	09 fe                	or     %edi,%esi
  800add:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae3:	74 0c                	je     800af1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae5:	83 ef 01             	sub    $0x1,%edi
  800ae8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aeb:	fd                   	std    
  800aec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aee:	fc                   	cld    
  800aef:	eb 21                	jmp    800b12 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af1:	f6 c1 03             	test   $0x3,%cl
  800af4:	75 ef                	jne    800ae5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af6:	83 ef 04             	sub    $0x4,%edi
  800af9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800afc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aff:	fd                   	std    
  800b00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b02:	eb ea                	jmp    800aee <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b04:	89 f2                	mov    %esi,%edx
  800b06:	09 c2                	or     %eax,%edx
  800b08:	f6 c2 03             	test   $0x3,%dl
  800b0b:	74 09                	je     800b16 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b0d:	89 c7                	mov    %eax,%edi
  800b0f:	fc                   	cld    
  800b10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b16:	f6 c1 03             	test   $0x3,%cl
  800b19:	75 f2                	jne    800b0d <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b1b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b1e:	89 c7                	mov    %eax,%edi
  800b20:	fc                   	cld    
  800b21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b23:	eb ed                	jmp    800b12 <memmove+0x55>

00800b25 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b28:	ff 75 10             	pushl  0x10(%ebp)
  800b2b:	ff 75 0c             	pushl  0xc(%ebp)
  800b2e:	ff 75 08             	pushl  0x8(%ebp)
  800b31:	e8 87 ff ff ff       	call   800abd <memmove>
}
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b43:	89 c6                	mov    %eax,%esi
  800b45:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b48:	39 f0                	cmp    %esi,%eax
  800b4a:	74 1c                	je     800b68 <memcmp+0x30>
		if (*s1 != *s2)
  800b4c:	0f b6 08             	movzbl (%eax),%ecx
  800b4f:	0f b6 1a             	movzbl (%edx),%ebx
  800b52:	38 d9                	cmp    %bl,%cl
  800b54:	75 08                	jne    800b5e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b56:	83 c0 01             	add    $0x1,%eax
  800b59:	83 c2 01             	add    $0x1,%edx
  800b5c:	eb ea                	jmp    800b48 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b5e:	0f b6 c1             	movzbl %cl,%eax
  800b61:	0f b6 db             	movzbl %bl,%ebx
  800b64:	29 d8                	sub    %ebx,%eax
  800b66:	eb 05                	jmp    800b6d <memcmp+0x35>
	}

	return 0;
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	8b 45 08             	mov    0x8(%ebp),%eax
  800b77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b7a:	89 c2                	mov    %eax,%edx
  800b7c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7f:	39 d0                	cmp    %edx,%eax
  800b81:	73 09                	jae    800b8c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b83:	38 08                	cmp    %cl,(%eax)
  800b85:	74 05                	je     800b8c <memfind+0x1b>
	for (; s < ends; s++)
  800b87:	83 c0 01             	add    $0x1,%eax
  800b8a:	eb f3                	jmp    800b7f <memfind+0xe>
			break;
	return (void *) s;
}
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	57                   	push   %edi
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9a:	eb 03                	jmp    800b9f <strtol+0x11>
		s++;
  800b9c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b9f:	0f b6 01             	movzbl (%ecx),%eax
  800ba2:	3c 20                	cmp    $0x20,%al
  800ba4:	74 f6                	je     800b9c <strtol+0xe>
  800ba6:	3c 09                	cmp    $0x9,%al
  800ba8:	74 f2                	je     800b9c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800baa:	3c 2b                	cmp    $0x2b,%al
  800bac:	74 2e                	je     800bdc <strtol+0x4e>
	int neg = 0;
  800bae:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bb3:	3c 2d                	cmp    $0x2d,%al
  800bb5:	74 2f                	je     800be6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bbd:	75 05                	jne    800bc4 <strtol+0x36>
  800bbf:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc2:	74 2c                	je     800bf0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc4:	85 db                	test   %ebx,%ebx
  800bc6:	75 0a                	jne    800bd2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc8:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bcd:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd0:	74 28                	je     800bfa <strtol+0x6c>
		base = 10;
  800bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bda:	eb 50                	jmp    800c2c <strtol+0x9e>
		s++;
  800bdc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bdf:	bf 00 00 00 00       	mov    $0x0,%edi
  800be4:	eb d1                	jmp    800bb7 <strtol+0x29>
		s++, neg = 1;
  800be6:	83 c1 01             	add    $0x1,%ecx
  800be9:	bf 01 00 00 00       	mov    $0x1,%edi
  800bee:	eb c7                	jmp    800bb7 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf4:	74 0e                	je     800c04 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bf6:	85 db                	test   %ebx,%ebx
  800bf8:	75 d8                	jne    800bd2 <strtol+0x44>
		s++, base = 8;
  800bfa:	83 c1 01             	add    $0x1,%ecx
  800bfd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c02:	eb ce                	jmp    800bd2 <strtol+0x44>
		s += 2, base = 16;
  800c04:	83 c1 02             	add    $0x2,%ecx
  800c07:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c0c:	eb c4                	jmp    800bd2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c11:	89 f3                	mov    %esi,%ebx
  800c13:	80 fb 19             	cmp    $0x19,%bl
  800c16:	77 29                	ja     800c41 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c18:	0f be d2             	movsbl %dl,%edx
  800c1b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c1e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c21:	7d 30                	jge    800c53 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c23:	83 c1 01             	add    $0x1,%ecx
  800c26:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c2a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c2c:	0f b6 11             	movzbl (%ecx),%edx
  800c2f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c32:	89 f3                	mov    %esi,%ebx
  800c34:	80 fb 09             	cmp    $0x9,%bl
  800c37:	77 d5                	ja     800c0e <strtol+0x80>
			dig = *s - '0';
  800c39:	0f be d2             	movsbl %dl,%edx
  800c3c:	83 ea 30             	sub    $0x30,%edx
  800c3f:	eb dd                	jmp    800c1e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c41:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c44:	89 f3                	mov    %esi,%ebx
  800c46:	80 fb 19             	cmp    $0x19,%bl
  800c49:	77 08                	ja     800c53 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c4b:	0f be d2             	movsbl %dl,%edx
  800c4e:	83 ea 37             	sub    $0x37,%edx
  800c51:	eb cb                	jmp    800c1e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c57:	74 05                	je     800c5e <strtol+0xd0>
		*endptr = (char *) s;
  800c59:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c5e:	89 c2                	mov    %eax,%edx
  800c60:	f7 da                	neg    %edx
  800c62:	85 ff                	test   %edi,%edi
  800c64:	0f 45 c2             	cmovne %edx,%eax
}
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    
  800c6c:	66 90                	xchg   %ax,%ax
  800c6e:	66 90                	xchg   %ax,%ax

00800c70 <__udivdi3>:
  800c70:	55                   	push   %ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 1c             	sub    $0x1c,%esp
  800c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c7b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c83:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c87:	85 d2                	test   %edx,%edx
  800c89:	75 35                	jne    800cc0 <__udivdi3+0x50>
  800c8b:	39 f3                	cmp    %esi,%ebx
  800c8d:	0f 87 bd 00 00 00    	ja     800d50 <__udivdi3+0xe0>
  800c93:	85 db                	test   %ebx,%ebx
  800c95:	89 d9                	mov    %ebx,%ecx
  800c97:	75 0b                	jne    800ca4 <__udivdi3+0x34>
  800c99:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9e:	31 d2                	xor    %edx,%edx
  800ca0:	f7 f3                	div    %ebx
  800ca2:	89 c1                	mov    %eax,%ecx
  800ca4:	31 d2                	xor    %edx,%edx
  800ca6:	89 f0                	mov    %esi,%eax
  800ca8:	f7 f1                	div    %ecx
  800caa:	89 c6                	mov    %eax,%esi
  800cac:	89 e8                	mov    %ebp,%eax
  800cae:	89 f7                	mov    %esi,%edi
  800cb0:	f7 f1                	div    %ecx
  800cb2:	89 fa                	mov    %edi,%edx
  800cb4:	83 c4 1c             	add    $0x1c,%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    
  800cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	39 f2                	cmp    %esi,%edx
  800cc2:	77 7c                	ja     800d40 <__udivdi3+0xd0>
  800cc4:	0f bd fa             	bsr    %edx,%edi
  800cc7:	83 f7 1f             	xor    $0x1f,%edi
  800cca:	0f 84 98 00 00 00    	je     800d68 <__udivdi3+0xf8>
  800cd0:	89 f9                	mov    %edi,%ecx
  800cd2:	b8 20 00 00 00       	mov    $0x20,%eax
  800cd7:	29 f8                	sub    %edi,%eax
  800cd9:	d3 e2                	shl    %cl,%edx
  800cdb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800cdf:	89 c1                	mov    %eax,%ecx
  800ce1:	89 da                	mov    %ebx,%edx
  800ce3:	d3 ea                	shr    %cl,%edx
  800ce5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ce9:	09 d1                	or     %edx,%ecx
  800ceb:	89 f2                	mov    %esi,%edx
  800ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cf1:	89 f9                	mov    %edi,%ecx
  800cf3:	d3 e3                	shl    %cl,%ebx
  800cf5:	89 c1                	mov    %eax,%ecx
  800cf7:	d3 ea                	shr    %cl,%edx
  800cf9:	89 f9                	mov    %edi,%ecx
  800cfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cff:	d3 e6                	shl    %cl,%esi
  800d01:	89 eb                	mov    %ebp,%ebx
  800d03:	89 c1                	mov    %eax,%ecx
  800d05:	d3 eb                	shr    %cl,%ebx
  800d07:	09 de                	or     %ebx,%esi
  800d09:	89 f0                	mov    %esi,%eax
  800d0b:	f7 74 24 08          	divl   0x8(%esp)
  800d0f:	89 d6                	mov    %edx,%esi
  800d11:	89 c3                	mov    %eax,%ebx
  800d13:	f7 64 24 0c          	mull   0xc(%esp)
  800d17:	39 d6                	cmp    %edx,%esi
  800d19:	72 0c                	jb     800d27 <__udivdi3+0xb7>
  800d1b:	89 f9                	mov    %edi,%ecx
  800d1d:	d3 e5                	shl    %cl,%ebp
  800d1f:	39 c5                	cmp    %eax,%ebp
  800d21:	73 5d                	jae    800d80 <__udivdi3+0x110>
  800d23:	39 d6                	cmp    %edx,%esi
  800d25:	75 59                	jne    800d80 <__udivdi3+0x110>
  800d27:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d2a:	31 ff                	xor    %edi,%edi
  800d2c:	89 fa                	mov    %edi,%edx
  800d2e:	83 c4 1c             	add    $0x1c,%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    
  800d36:	8d 76 00             	lea    0x0(%esi),%esi
  800d39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d40:	31 ff                	xor    %edi,%edi
  800d42:	31 c0                	xor    %eax,%eax
  800d44:	89 fa                	mov    %edi,%edx
  800d46:	83 c4 1c             	add    $0x1c,%esp
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    
  800d4e:	66 90                	xchg   %ax,%ax
  800d50:	31 ff                	xor    %edi,%edi
  800d52:	89 e8                	mov    %ebp,%eax
  800d54:	89 f2                	mov    %esi,%edx
  800d56:	f7 f3                	div    %ebx
  800d58:	89 fa                	mov    %edi,%edx
  800d5a:	83 c4 1c             	add    $0x1c,%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    
  800d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d68:	39 f2                	cmp    %esi,%edx
  800d6a:	72 06                	jb     800d72 <__udivdi3+0x102>
  800d6c:	31 c0                	xor    %eax,%eax
  800d6e:	39 eb                	cmp    %ebp,%ebx
  800d70:	77 d2                	ja     800d44 <__udivdi3+0xd4>
  800d72:	b8 01 00 00 00       	mov    $0x1,%eax
  800d77:	eb cb                	jmp    800d44 <__udivdi3+0xd4>
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	89 d8                	mov    %ebx,%eax
  800d82:	31 ff                	xor    %edi,%edi
  800d84:	eb be                	jmp    800d44 <__udivdi3+0xd4>
  800d86:	66 90                	xchg   %ax,%ax
  800d88:	66 90                	xchg   %ax,%ax
  800d8a:	66 90                	xchg   %ax,%ax
  800d8c:	66 90                	xchg   %ax,%ax
  800d8e:	66 90                	xchg   %ax,%ax

00800d90 <__umoddi3>:
  800d90:	55                   	push   %ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 1c             	sub    $0x1c,%esp
  800d97:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800d9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800da7:	85 ed                	test   %ebp,%ebp
  800da9:	89 f0                	mov    %esi,%eax
  800dab:	89 da                	mov    %ebx,%edx
  800dad:	75 19                	jne    800dc8 <__umoddi3+0x38>
  800daf:	39 df                	cmp    %ebx,%edi
  800db1:	0f 86 b1 00 00 00    	jbe    800e68 <__umoddi3+0xd8>
  800db7:	f7 f7                	div    %edi
  800db9:	89 d0                	mov    %edx,%eax
  800dbb:	31 d2                	xor    %edx,%edx
  800dbd:	83 c4 1c             	add    $0x1c,%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    
  800dc5:	8d 76 00             	lea    0x0(%esi),%esi
  800dc8:	39 dd                	cmp    %ebx,%ebp
  800dca:	77 f1                	ja     800dbd <__umoddi3+0x2d>
  800dcc:	0f bd cd             	bsr    %ebp,%ecx
  800dcf:	83 f1 1f             	xor    $0x1f,%ecx
  800dd2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800dd6:	0f 84 b4 00 00 00    	je     800e90 <__umoddi3+0x100>
  800ddc:	b8 20 00 00 00       	mov    $0x20,%eax
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800de7:	29 c2                	sub    %eax,%edx
  800de9:	89 c1                	mov    %eax,%ecx
  800deb:	89 f8                	mov    %edi,%eax
  800ded:	d3 e5                	shl    %cl,%ebp
  800def:	89 d1                	mov    %edx,%ecx
  800df1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800df5:	d3 e8                	shr    %cl,%eax
  800df7:	09 c5                	or     %eax,%ebp
  800df9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dfd:	89 c1                	mov    %eax,%ecx
  800dff:	d3 e7                	shl    %cl,%edi
  800e01:	89 d1                	mov    %edx,%ecx
  800e03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e07:	89 df                	mov    %ebx,%edi
  800e09:	d3 ef                	shr    %cl,%edi
  800e0b:	89 c1                	mov    %eax,%ecx
  800e0d:	89 f0                	mov    %esi,%eax
  800e0f:	d3 e3                	shl    %cl,%ebx
  800e11:	89 d1                	mov    %edx,%ecx
  800e13:	89 fa                	mov    %edi,%edx
  800e15:	d3 e8                	shr    %cl,%eax
  800e17:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e1c:	09 d8                	or     %ebx,%eax
  800e1e:	f7 f5                	div    %ebp
  800e20:	d3 e6                	shl    %cl,%esi
  800e22:	89 d1                	mov    %edx,%ecx
  800e24:	f7 64 24 08          	mull   0x8(%esp)
  800e28:	39 d1                	cmp    %edx,%ecx
  800e2a:	89 c3                	mov    %eax,%ebx
  800e2c:	89 d7                	mov    %edx,%edi
  800e2e:	72 06                	jb     800e36 <__umoddi3+0xa6>
  800e30:	75 0e                	jne    800e40 <__umoddi3+0xb0>
  800e32:	39 c6                	cmp    %eax,%esi
  800e34:	73 0a                	jae    800e40 <__umoddi3+0xb0>
  800e36:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e3a:	19 ea                	sbb    %ebp,%edx
  800e3c:	89 d7                	mov    %edx,%edi
  800e3e:	89 c3                	mov    %eax,%ebx
  800e40:	89 ca                	mov    %ecx,%edx
  800e42:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e47:	29 de                	sub    %ebx,%esi
  800e49:	19 fa                	sbb    %edi,%edx
  800e4b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e4f:	89 d0                	mov    %edx,%eax
  800e51:	d3 e0                	shl    %cl,%eax
  800e53:	89 d9                	mov    %ebx,%ecx
  800e55:	d3 ee                	shr    %cl,%esi
  800e57:	d3 ea                	shr    %cl,%edx
  800e59:	09 f0                	or     %esi,%eax
  800e5b:	83 c4 1c             	add    $0x1c,%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    
  800e63:	90                   	nop
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	85 ff                	test   %edi,%edi
  800e6a:	89 f9                	mov    %edi,%ecx
  800e6c:	75 0b                	jne    800e79 <__umoddi3+0xe9>
  800e6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e73:	31 d2                	xor    %edx,%edx
  800e75:	f7 f7                	div    %edi
  800e77:	89 c1                	mov    %eax,%ecx
  800e79:	89 d8                	mov    %ebx,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f1                	div    %ecx
  800e7f:	89 f0                	mov    %esi,%eax
  800e81:	f7 f1                	div    %ecx
  800e83:	e9 31 ff ff ff       	jmp    800db9 <__umoddi3+0x29>
  800e88:	90                   	nop
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	39 dd                	cmp    %ebx,%ebp
  800e92:	72 08                	jb     800e9c <__umoddi3+0x10c>
  800e94:	39 f7                	cmp    %esi,%edi
  800e96:	0f 87 21 ff ff ff    	ja     800dbd <__umoddi3+0x2d>
  800e9c:	89 da                	mov    %ebx,%edx
  800e9e:	89 f0                	mov    %esi,%eax
  800ea0:	29 f8                	sub    %edi,%eax
  800ea2:	19 ea                	sbb    %ebp,%edx
  800ea4:	e9 14 ff ff ff       	jmp    800dbd <__umoddi3+0x2d>
