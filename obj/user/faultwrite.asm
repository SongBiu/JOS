
obj/user/faultwrite:     file format elf32-i386


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
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
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
  800045:	57                   	push   %edi
  800046:	56                   	push   %esi
  800047:	53                   	push   %ebx
  800048:	83 ec 0c             	sub    $0xc,%esp
  80004b:	e8 50 00 00 00       	call   8000a0 <__x86.get_pc_thunk.bx>
  800050:	81 c3 b0 1f 00 00    	add    $0x1fb0,%ebx
  800056:	8b 75 08             	mov    0x8(%ebp),%esi
  800059:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005c:	e8 f6 00 00 00       	call   800157 <sys_getenvid>
  800061:	25 ff 03 00 00       	and    $0x3ff,%eax
  800066:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800069:	c1 e0 05             	shl    $0x5,%eax
  80006c:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800072:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800078:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 f6                	test   %esi,%esi
  80007c:	7e 08                	jle    800086 <libmain+0x44>
		binaryname = argv[0];
  80007e:	8b 07                	mov    (%edi),%eax
  800080:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	57                   	push   %edi
  80008a:	56                   	push   %esi
  80008b:	e8 a3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800090:	e8 0f 00 00 00       	call   8000a4 <exit>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5f                   	pop    %edi
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

008000a0 <__x86.get_pc_thunk.bx>:
  8000a0:	8b 1c 24             	mov    (%esp),%ebx
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	53                   	push   %ebx
  8000a8:	83 ec 10             	sub    $0x10,%esp
  8000ab:	e8 f0 ff ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  8000b0:	81 c3 50 1f 00 00    	add    $0x1f50,%ebx
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 45 00 00 00       	call   800102 <sys_env_destroy>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 1c             	sub    $0x1c,%esp
  80010b:	e8 66 00 00 00       	call   800176 <__x86.get_pc_thunk.ax>
  800110:	05 f0 1e 00 00       	add    $0x1ef0,%eax
  800115:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800118:	b9 00 00 00 00       	mov    $0x0,%ecx
  80011d:	8b 55 08             	mov    0x8(%ebp),%edx
  800120:	b8 03 00 00 00       	mov    $0x3,%eax
  800125:	89 cb                	mov    %ecx,%ebx
  800127:	89 cf                	mov    %ecx,%edi
  800129:	89 ce                	mov    %ecx,%esi
  80012b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80012d:	85 c0                	test   %eax,%eax
  80012f:	7f 08                	jg     800139 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800131:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	50                   	push   %eax
  80013d:	6a 03                	push   $0x3
  80013f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800142:	8d 83 d6 ee ff ff    	lea    -0x112a(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	6a 26                	push   $0x26
  80014b:	8d 83 f3 ee ff ff    	lea    -0x110d(%ebx),%eax
  800151:	50                   	push   %eax
  800152:	e8 23 00 00 00       	call   80017a <_panic>

00800157 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 02 00 00 00       	mov    $0x2,%eax
  800167:	89 d1                	mov    %edx,%ecx
  800169:	89 d3                	mov    %edx,%ebx
  80016b:	89 d7                	mov    %edx,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <__x86.get_pc_thunk.ax>:
  800176:	8b 04 24             	mov    (%esp),%eax
  800179:	c3                   	ret    

0080017a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	e8 18 ff ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  800188:	81 c3 78 1e 00 00    	add    $0x1e78,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018e:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800191:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800197:	8b 38                	mov    (%eax),%edi
  800199:	e8 b9 ff ff ff       	call   800157 <sys_getenvid>
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 0c             	pushl  0xc(%ebp)
  8001a4:	ff 75 08             	pushl  0x8(%ebp)
  8001a7:	57                   	push   %edi
  8001a8:	50                   	push   %eax
  8001a9:	8d 83 04 ef ff ff    	lea    -0x10fc(%ebx),%eax
  8001af:	50                   	push   %eax
  8001b0:	e8 d1 00 00 00       	call   800286 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b5:	83 c4 18             	add    $0x18,%esp
  8001b8:	56                   	push   %esi
  8001b9:	ff 75 10             	pushl  0x10(%ebp)
  8001bc:	e8 63 00 00 00       	call   800224 <vcprintf>
	cprintf("\n");
  8001c1:	8d 83 28 ef ff ff    	lea    -0x10d8(%ebx),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 b7 00 00 00       	call   800286 <cprintf>
  8001cf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d2:	cc                   	int3   
  8001d3:	eb fd                	jmp    8001d2 <_panic+0x58>

008001d5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	56                   	push   %esi
  8001d9:	53                   	push   %ebx
  8001da:	e8 c1 fe ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  8001df:	81 c3 21 1e 00 00    	add    $0x1e21,%ebx
  8001e5:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e8:	8b 16                	mov    (%esi),%edx
  8001ea:	8d 42 01             	lea    0x1(%edx),%eax
  8001ed:	89 06                	mov    %eax,(%esi)
  8001ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f2:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fb:	74 0b                	je     800208 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001fd:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800201:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	68 ff 00 00 00       	push   $0xff
  800210:	8d 46 08             	lea    0x8(%esi),%eax
  800213:	50                   	push   %eax
  800214:	e8 ac fe ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  800219:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021f:	83 c4 10             	add    $0x10,%esp
  800222:	eb d9                	jmp    8001fd <putch+0x28>

00800224 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022e:	e8 6d fe ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  800233:	81 c3 cd 1d 00 00    	add    $0x1dcd,%ebx
	struct printbuf b;

	b.idx = 0;
  800239:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800240:	00 00 00 
	b.cnt = 0;
  800243:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80024a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80024d:	ff 75 0c             	pushl  0xc(%ebp)
  800250:	ff 75 08             	pushl  0x8(%ebp)
  800253:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800259:	50                   	push   %eax
  80025a:	8d 83 d5 e1 ff ff    	lea    -0x1e2b(%ebx),%eax
  800260:	50                   	push   %eax
  800261:	e8 38 01 00 00       	call   80039e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800266:	83 c4 08             	add    $0x8,%esp
  800269:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800275:	50                   	push   %eax
  800276:	e8 4a fe ff ff       	call   8000c5 <sys_cputs>
	return b.cnt;
}
  80027b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80028c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028f:	50                   	push   %eax
  800290:	ff 75 08             	pushl  0x8(%ebp)
  800293:	e8 8c ff ff ff       	call   800224 <vcprintf>
	va_end(ap);

	return cnt;
}
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	57                   	push   %edi
  80029e:	56                   	push   %esi
  80029f:	53                   	push   %ebx
  8002a0:	83 ec 2c             	sub    $0x2c,%esp
  8002a3:	e8 63 06 00 00       	call   80090b <__x86.get_pc_thunk.cx>
  8002a8:	81 c1 58 1d 00 00    	add    $0x1d58,%ecx
  8002ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002b1:	89 c7                	mov    %eax,%edi
  8002b3:	89 d6                	mov    %edx,%esi
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002be:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002cc:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002cf:	39 d3                	cmp    %edx,%ebx
  8002d1:	72 09                	jb     8002dc <printnum+0x42>
  8002d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d6:	0f 87 83 00 00 00    	ja     80035f <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002dc:	83 ec 0c             	sub    $0xc,%esp
  8002df:	ff 75 18             	pushl  0x18(%ebp)
  8002e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e8:	53                   	push   %ebx
  8002e9:	ff 75 10             	pushl  0x10(%ebp)
  8002ec:	83 ec 08             	sub    $0x8,%esp
  8002ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f8:	ff 75 d0             	pushl  -0x30(%ebp)
  8002fb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002fe:	e8 8d 09 00 00       	call   800c90 <__udivdi3>
  800303:	83 c4 18             	add    $0x18,%esp
  800306:	52                   	push   %edx
  800307:	50                   	push   %eax
  800308:	89 f2                	mov    %esi,%edx
  80030a:	89 f8                	mov    %edi,%eax
  80030c:	e8 89 ff ff ff       	call   80029a <printnum>
  800311:	83 c4 20             	add    $0x20,%esp
  800314:	eb 13                	jmp    800329 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800316:	83 ec 08             	sub    $0x8,%esp
  800319:	56                   	push   %esi
  80031a:	ff 75 18             	pushl  0x18(%ebp)
  80031d:	ff d7                	call   *%edi
  80031f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800322:	83 eb 01             	sub    $0x1,%ebx
  800325:	85 db                	test   %ebx,%ebx
  800327:	7f ed                	jg     800316 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800329:	83 ec 08             	sub    $0x8,%esp
  80032c:	56                   	push   %esi
  80032d:	83 ec 04             	sub    $0x4,%esp
  800330:	ff 75 dc             	pushl  -0x24(%ebp)
  800333:	ff 75 d8             	pushl  -0x28(%ebp)
  800336:	ff 75 d4             	pushl  -0x2c(%ebp)
  800339:	ff 75 d0             	pushl  -0x30(%ebp)
  80033c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80033f:	89 f3                	mov    %esi,%ebx
  800341:	e8 6a 0a 00 00       	call   800db0 <__umoddi3>
  800346:	83 c4 14             	add    $0x14,%esp
  800349:	0f be 84 06 2a ef ff 	movsbl -0x10d6(%esi,%eax,1),%eax
  800350:	ff 
  800351:	50                   	push   %eax
  800352:	ff d7                	call   *%edi
}
  800354:	83 c4 10             	add    $0x10,%esp
  800357:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035a:	5b                   	pop    %ebx
  80035b:	5e                   	pop    %esi
  80035c:	5f                   	pop    %edi
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    
  80035f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800362:	eb be                	jmp    800322 <printnum+0x88>

00800364 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	3b 50 04             	cmp    0x4(%eax),%edx
  800373:	73 0a                	jae    80037f <sprintputch+0x1b>
		*b->buf++ = ch;
  800375:	8d 4a 01             	lea    0x1(%edx),%ecx
  800378:	89 08                	mov    %ecx,(%eax)
  80037a:	8b 45 08             	mov    0x8(%ebp),%eax
  80037d:	88 02                	mov    %al,(%edx)
}
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <printfmt>:
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800387:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038a:	50                   	push   %eax
  80038b:	ff 75 10             	pushl  0x10(%ebp)
  80038e:	ff 75 0c             	pushl  0xc(%ebp)
  800391:	ff 75 08             	pushl  0x8(%ebp)
  800394:	e8 05 00 00 00       	call   80039e <vprintfmt>
}
  800399:	83 c4 10             	add    $0x10,%esp
  80039c:	c9                   	leave  
  80039d:	c3                   	ret    

0080039e <vprintfmt>:
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
  8003a1:	57                   	push   %edi
  8003a2:	56                   	push   %esi
  8003a3:	53                   	push   %ebx
  8003a4:	83 ec 2c             	sub    $0x2c,%esp
  8003a7:	e8 f4 fc ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  8003ac:	81 c3 54 1c 00 00    	add    $0x1c54,%ebx
  8003b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003b5:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003bc:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003be:	8d 77 01             	lea    0x1(%edi),%esi
  8003c1:	0f b6 07             	movzbl (%edi),%eax
  8003c4:	83 f8 25             	cmp    $0x25,%eax
  8003c7:	74 1c                	je     8003e5 <vprintfmt+0x47>
			if (ch == '\0')
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	0f 84 b9 04 00 00    	je     80088a <.L21+0x20>
			putch(ch, putdat);
  8003d1:	83 ec 08             	sub    $0x8,%esp
  8003d4:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003d7:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003da:	50                   	push   %eax
  8003db:	ff 55 08             	call   *0x8(%ebp)
  8003de:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e1:	89 f7                	mov    %esi,%edi
  8003e3:	eb d9                	jmp    8003be <vprintfmt+0x20>
		padc = ' ';
  8003e5:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003f0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800403:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8d 7e 01             	lea    0x1(%esi),%edi
  800409:	0f b6 16             	movzbl (%esi),%edx
  80040c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040f:	3c 55                	cmp    $0x55,%al
  800411:	0f 87 53 04 00 00    	ja     80086a <.L21>
  800417:	0f b6 c0             	movzbl %al,%eax
  80041a:	89 d9                	mov    %ebx,%ecx
  80041c:	03 8c 83 b8 ef ff ff 	add    -0x1048(%ebx,%eax,4),%ecx
  800423:	ff e1                	jmp    *%ecx

00800425 <.L73>:
  800425:	89 fe                	mov    %edi,%esi
			padc = '-';
  800427:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80042b:	eb d9                	jmp    800406 <vprintfmt+0x68>

0080042d <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	89 fe                	mov    %edi,%esi
			padc = '0';
  80042f:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800433:	eb d1                	jmp    800406 <vprintfmt+0x68>

00800435 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	0f b6 d2             	movzbl %dl,%edx
  800438:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  80043a:	b8 00 00 00 00       	mov    $0x0,%eax
  80043f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800442:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800445:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800449:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  80044c:	8d 7a d0             	lea    -0x30(%edx),%edi
  80044f:	83 ff 09             	cmp    $0x9,%edi
  800452:	0f 87 94 00 00 00    	ja     8004ec <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800458:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80045b:	eb e5                	jmp    800442 <.L28+0xd>

0080045d <.L25>:
			precision = va_arg(ap, int);
  80045d:	8b 45 14             	mov    0x14(%ebp),%eax
  800460:	8b 00                	mov    (%eax),%eax
  800462:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800465:	8b 45 14             	mov    0x14(%ebp),%eax
  800468:	8d 40 04             	lea    0x4(%eax),%eax
  80046b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800470:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800474:	79 90                	jns    800406 <vprintfmt+0x68>
				width = precision, precision = -1;
  800476:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800483:	eb 81                	jmp    800406 <vprintfmt+0x68>

00800485 <.L26>:
  800485:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800488:	85 c0                	test   %eax,%eax
  80048a:	ba 00 00 00 00       	mov    $0x0,%edx
  80048f:	0f 49 d0             	cmovns %eax,%edx
  800492:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800495:	89 fe                	mov    %edi,%esi
  800497:	e9 6a ff ff ff       	jmp    800406 <vprintfmt+0x68>

0080049c <.L22>:
  80049c:	89 fe                	mov    %edi,%esi
			altflag = 1;
  80049e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a5:	e9 5c ff ff ff       	jmp    800406 <vprintfmt+0x68>

008004aa <.L33>:
  8004aa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004ad:	83 f9 01             	cmp    $0x1,%ecx
  8004b0:	7e 16                	jle    8004c8 <.L33+0x1e>
		return va_arg(*ap, long long);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004ba:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004bd:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004c3:	e9 f6 fe ff ff       	jmp    8003be <vprintfmt+0x20>
	else if (lflag)
  8004c8:	85 c9                	test   %ecx,%ecx
  8004ca:	75 10                	jne    8004dc <.L33+0x32>
		return va_arg(*ap, int);
  8004cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cf:	8b 00                	mov    (%eax),%eax
  8004d1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004d4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004d7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004da:	eb e4                	jmp    8004c0 <.L33+0x16>
		return va_arg(*ap, long);
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004e4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ea:	eb d4                	jmp    8004c0 <.L33+0x16>
  8004ec:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004f2:	e9 79 ff ff ff       	jmp    800470 <.L25+0x13>

008004f7 <.L32>:
			lflag++;
  8004f7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8004fd:	e9 04 ff ff ff       	jmp    800406 <vprintfmt+0x68>

00800502 <.L29>:
			putch(va_arg(ap, int), putdat);
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	8d 70 04             	lea    0x4(%eax),%esi
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	ff 75 0c             	pushl  0xc(%ebp)
  80050e:	ff 30                	pushl  (%eax)
  800510:	ff 55 08             	call   *0x8(%ebp)
			break;
  800513:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800516:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800519:	e9 a0 fe ff ff       	jmp    8003be <vprintfmt+0x20>

0080051e <.L31>:
			err = va_arg(ap, int);
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	8d 70 04             	lea    0x4(%eax),%esi
  800524:	8b 00                	mov    (%eax),%eax
  800526:	99                   	cltd   
  800527:	31 d0                	xor    %edx,%eax
  800529:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052b:	83 f8 06             	cmp    $0x6,%eax
  80052e:	7f 29                	jg     800559 <.L31+0x3b>
  800530:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800537:	85 d2                	test   %edx,%edx
  800539:	74 1e                	je     800559 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  80053b:	52                   	push   %edx
  80053c:	8d 83 4b ef ff ff    	lea    -0x10b5(%ebx),%eax
  800542:	50                   	push   %eax
  800543:	ff 75 0c             	pushl  0xc(%ebp)
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 33 fe ff ff       	call   800381 <printfmt>
  80054e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800551:	89 75 14             	mov    %esi,0x14(%ebp)
  800554:	e9 65 fe ff ff       	jmp    8003be <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800559:	50                   	push   %eax
  80055a:	8d 83 42 ef ff ff    	lea    -0x10be(%ebx),%eax
  800560:	50                   	push   %eax
  800561:	ff 75 0c             	pushl  0xc(%ebp)
  800564:	ff 75 08             	pushl  0x8(%ebp)
  800567:	e8 15 fe ff ff       	call   800381 <printfmt>
  80056c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80056f:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800572:	e9 47 fe ff ff       	jmp    8003be <vprintfmt+0x20>

00800577 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	83 c0 04             	add    $0x4,%eax
  80057d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800585:	85 f6                	test   %esi,%esi
  800587:	8d 83 3b ef ff ff    	lea    -0x10c5(%ebx),%eax
  80058d:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800590:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800594:	0f 8e b4 00 00 00    	jle    80064e <.L36+0xd7>
  80059a:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80059e:	75 08                	jne    8005a8 <.L36+0x31>
  8005a0:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005a3:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005a6:	eb 6c                	jmp    800614 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 cc             	pushl  -0x34(%ebp)
  8005ae:	56                   	push   %esi
  8005af:	e8 73 03 00 00       	call   800927 <strnlen>
  8005b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b7:	29 c2                	sub    %eax,%edx
  8005b9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005bc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005bf:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005c3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005c6:	89 d6                	mov    %edx,%esi
  8005c8:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005cb:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cd:	eb 10                	jmp    8005df <.L36+0x68>
					putch(padc, putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	ff 75 0c             	pushl  0xc(%ebp)
  8005d5:	57                   	push   %edi
  8005d6:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d9:	83 ee 01             	sub    $0x1,%esi
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	85 f6                	test   %esi,%esi
  8005e1:	7f ec                	jg     8005cf <.L36+0x58>
  8005e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e9:	85 d2                	test   %edx,%edx
  8005eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f0:	0f 49 c2             	cmovns %edx,%eax
  8005f3:	29 c2                	sub    %eax,%edx
  8005f5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005fb:	eb 17                	jmp    800614 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8005fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800601:	75 30                	jne    800633 <.L36+0xbc>
					putch(ch, putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	ff 75 0c             	pushl  0xc(%ebp)
  800609:	50                   	push   %eax
  80060a:	ff 55 08             	call   *0x8(%ebp)
  80060d:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800610:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800614:	83 c6 01             	add    $0x1,%esi
  800617:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80061b:	0f be c2             	movsbl %dl,%eax
  80061e:	85 c0                	test   %eax,%eax
  800620:	74 58                	je     80067a <.L36+0x103>
  800622:	85 ff                	test   %edi,%edi
  800624:	78 d7                	js     8005fd <.L36+0x86>
  800626:	83 ef 01             	sub    $0x1,%edi
  800629:	79 d2                	jns    8005fd <.L36+0x86>
  80062b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80062e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800631:	eb 32                	jmp    800665 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800633:	0f be d2             	movsbl %dl,%edx
  800636:	83 ea 20             	sub    $0x20,%edx
  800639:	83 fa 5e             	cmp    $0x5e,%edx
  80063c:	76 c5                	jbe    800603 <.L36+0x8c>
					putch('?', putdat);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	ff 75 0c             	pushl  0xc(%ebp)
  800644:	6a 3f                	push   $0x3f
  800646:	ff 55 08             	call   *0x8(%ebp)
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	eb c2                	jmp    800610 <.L36+0x99>
  80064e:	89 7d 10             	mov    %edi,0x10(%ebp)
  800651:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800654:	eb be                	jmp    800614 <.L36+0x9d>
				putch(' ', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	57                   	push   %edi
  80065a:	6a 20                	push   $0x20
  80065c:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80065f:	83 ee 01             	sub    $0x1,%esi
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	85 f6                	test   %esi,%esi
  800667:	7f ed                	jg     800656 <.L36+0xdf>
  800669:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80066c:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  80066f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
  800675:	e9 44 fd ff ff       	jmp    8003be <vprintfmt+0x20>
  80067a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80067d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800680:	eb e3                	jmp    800665 <.L36+0xee>

00800682 <.L30>:
  800682:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800685:	83 f9 01             	cmp    $0x1,%ecx
  800688:	7e 42                	jle    8006cc <.L30+0x4a>
		return va_arg(*ap, long long);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 50 04             	mov    0x4(%eax),%edx
  800690:	8b 00                	mov    (%eax),%eax
  800692:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800695:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8d 40 08             	lea    0x8(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006a1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a5:	79 5f                	jns    800706 <.L30+0x84>
				putch('-', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	6a 2d                	push   $0x2d
  8006af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b8:	f7 da                	neg    %edx
  8006ba:	83 d1 00             	adc    $0x0,%ecx
  8006bd:	f7 d9                	neg    %ecx
  8006bf:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c7:	e9 b8 00 00 00       	jmp    800784 <.L34+0x22>
	else if (lflag)
  8006cc:	85 c9                	test   %ecx,%ecx
  8006ce:	75 1b                	jne    8006eb <.L30+0x69>
		return va_arg(*ap, int);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 30                	mov    (%eax),%esi
  8006d5:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	c1 f8 1f             	sar    $0x1f,%eax
  8006dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8d 40 04             	lea    0x4(%eax),%eax
  8006e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e9:	eb b6                	jmp    8006a1 <.L30+0x1f>
		return va_arg(*ap, long);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8b 30                	mov    (%eax),%esi
  8006f0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006f3:	89 f0                	mov    %esi,%eax
  8006f5:	c1 f8 1f             	sar    $0x1f,%eax
  8006f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8d 40 04             	lea    0x4(%eax),%eax
  800701:	89 45 14             	mov    %eax,0x14(%ebp)
  800704:	eb 9b                	jmp    8006a1 <.L30+0x1f>
			num = getint(&ap, lflag);
  800706:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800709:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80070c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800711:	eb 71                	jmp    800784 <.L34+0x22>

00800713 <.L37>:
  800713:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800716:	83 f9 01             	cmp    $0x1,%ecx
  800719:	7e 15                	jle    800730 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	8b 10                	mov    (%eax),%edx
  800720:	8b 48 04             	mov    0x4(%eax),%ecx
  800723:	8d 40 08             	lea    0x8(%eax),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800729:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072e:	eb 54                	jmp    800784 <.L34+0x22>
	else if (lflag)
  800730:	85 c9                	test   %ecx,%ecx
  800732:	75 17                	jne    80074b <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800744:	b8 0a 00 00 00       	mov    $0xa,%eax
  800749:	eb 39                	jmp    800784 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8b 10                	mov    (%eax),%edx
  800750:	b9 00 00 00 00       	mov    $0x0,%ecx
  800755:	8d 40 04             	lea    0x4(%eax),%eax
  800758:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80075b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800760:	eb 22                	jmp    800784 <.L34+0x22>

00800762 <.L34>:
  800762:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800765:	83 f9 01             	cmp    $0x1,%ecx
  800768:	7e 3b                	jle    8007a5 <.L34+0x43>
		return va_arg(*ap, long long);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8b 50 04             	mov    0x4(%eax),%edx
  800770:	8b 00                	mov    (%eax),%eax
  800772:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800775:	8d 49 08             	lea    0x8(%ecx),%ecx
  800778:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80077b:	89 d1                	mov    %edx,%ecx
  80077d:	89 c2                	mov    %eax,%edx
			base = 8;
  80077f:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800784:	83 ec 0c             	sub    $0xc,%esp
  800787:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  80078b:	56                   	push   %esi
  80078c:	ff 75 e0             	pushl  -0x20(%ebp)
  80078f:	50                   	push   %eax
  800790:	51                   	push   %ecx
  800791:	52                   	push   %edx
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	e8 fd fa ff ff       	call   80029a <printnum>
			break;
  80079d:	83 c4 20             	add    $0x20,%esp
  8007a0:	e9 19 fc ff ff       	jmp    8003be <vprintfmt+0x20>
	else if (lflag)
  8007a5:	85 c9                	test   %ecx,%ecx
  8007a7:	75 13                	jne    8007bc <.L34+0x5a>
		return va_arg(*ap, int);
  8007a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ac:	8b 10                	mov    (%eax),%edx
  8007ae:	89 d0                	mov    %edx,%eax
  8007b0:	99                   	cltd   
  8007b1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007b4:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007b7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007ba:	eb bf                	jmp    80077b <.L34+0x19>
		return va_arg(*ap, long);
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8b 10                	mov    (%eax),%edx
  8007c1:	89 d0                	mov    %edx,%eax
  8007c3:	99                   	cltd   
  8007c4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007c7:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007ca:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007cd:	eb ac                	jmp    80077b <.L34+0x19>

008007cf <.L35>:
			putch('0', putdat);
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	ff 75 0c             	pushl  0xc(%ebp)
  8007d5:	6a 30                	push   $0x30
  8007d7:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	ff 75 0c             	pushl  0xc(%ebp)
  8007e0:	6a 78                	push   $0x78
  8007e2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8b 10                	mov    (%eax),%edx
  8007ea:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007ef:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007fd:	eb 85                	jmp    800784 <.L34+0x22>

008007ff <.L38>:
  8007ff:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800802:	83 f9 01             	cmp    $0x1,%ecx
  800805:	7e 18                	jle    80081f <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8b 10                	mov    (%eax),%edx
  80080c:	8b 48 04             	mov    0x4(%eax),%ecx
  80080f:	8d 40 08             	lea    0x8(%eax),%eax
  800812:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800815:	b8 10 00 00 00       	mov    $0x10,%eax
  80081a:	e9 65 ff ff ff       	jmp    800784 <.L34+0x22>
	else if (lflag)
  80081f:	85 c9                	test   %ecx,%ecx
  800821:	75 1a                	jne    80083d <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8b 10                	mov    (%eax),%edx
  800828:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082d:	8d 40 04             	lea    0x4(%eax),%eax
  800830:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800833:	b8 10 00 00 00       	mov    $0x10,%eax
  800838:	e9 47 ff ff ff       	jmp    800784 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8b 10                	mov    (%eax),%edx
  800842:	b9 00 00 00 00       	mov    $0x0,%ecx
  800847:	8d 40 04             	lea    0x4(%eax),%eax
  80084a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80084d:	b8 10 00 00 00       	mov    $0x10,%eax
  800852:	e9 2d ff ff ff       	jmp    800784 <.L34+0x22>

00800857 <.L24>:
			putch(ch, putdat);
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	ff 75 0c             	pushl  0xc(%ebp)
  80085d:	6a 25                	push   $0x25
  80085f:	ff 55 08             	call   *0x8(%ebp)
			break;
  800862:	83 c4 10             	add    $0x10,%esp
  800865:	e9 54 fb ff ff       	jmp    8003be <vprintfmt+0x20>

0080086a <.L21>:
			putch('%', putdat);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	ff 75 0c             	pushl  0xc(%ebp)
  800870:	6a 25                	push   $0x25
  800872:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800875:	83 c4 10             	add    $0x10,%esp
  800878:	89 f7                	mov    %esi,%edi
  80087a:	eb 03                	jmp    80087f <.L21+0x15>
  80087c:	83 ef 01             	sub    $0x1,%edi
  80087f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800883:	75 f7                	jne    80087c <.L21+0x12>
  800885:	e9 34 fb ff ff       	jmp    8003be <vprintfmt+0x20>
}
  80088a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80088d:	5b                   	pop    %ebx
  80088e:	5e                   	pop    %esi
  80088f:	5f                   	pop    %edi
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	53                   	push   %ebx
  800896:	83 ec 14             	sub    $0x14,%esp
  800899:	e8 02 f8 ff ff       	call   8000a0 <__x86.get_pc_thunk.bx>
  80089e:	81 c3 62 17 00 00    	add    $0x1762,%ebx
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	74 2b                	je     8008ea <vsnprintf+0x58>
  8008bf:	85 d2                	test   %edx,%edx
  8008c1:	7e 27                	jle    8008ea <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c3:	ff 75 14             	pushl  0x14(%ebp)
  8008c6:	ff 75 10             	pushl  0x10(%ebp)
  8008c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008cc:	50                   	push   %eax
  8008cd:	8d 83 64 e3 ff ff    	lea    -0x1c9c(%ebx),%eax
  8008d3:	50                   	push   %eax
  8008d4:	e8 c5 fa ff ff       	call   80039e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008dc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e2:	83 c4 10             	add    $0x10,%esp
}
  8008e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    
		return -E_INVAL;
  8008ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ef:	eb f4                	jmp    8008e5 <vsnprintf+0x53>

008008f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008fa:	50                   	push   %eax
  8008fb:	ff 75 10             	pushl  0x10(%ebp)
  8008fe:	ff 75 0c             	pushl  0xc(%ebp)
  800901:	ff 75 08             	pushl  0x8(%ebp)
  800904:	e8 89 ff ff ff       	call   800892 <vsnprintf>
	va_end(ap);

	return rc;
}
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <__x86.get_pc_thunk.cx>:
  80090b:	8b 0c 24             	mov    (%esp),%ecx
  80090e:	c3                   	ret    

0080090f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
  80091a:	eb 03                	jmp    80091f <strlen+0x10>
		n++;
  80091c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80091f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800923:	75 f7                	jne    80091c <strlen+0xd>
	return n;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800930:	b8 00 00 00 00       	mov    $0x0,%eax
  800935:	eb 03                	jmp    80093a <strnlen+0x13>
		n++;
  800937:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093a:	39 d0                	cmp    %edx,%eax
  80093c:	74 06                	je     800944 <strnlen+0x1d>
  80093e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800942:	75 f3                	jne    800937 <strnlen+0x10>
	return n;
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800950:	89 c2                	mov    %eax,%edx
  800952:	83 c1 01             	add    $0x1,%ecx
  800955:	83 c2 01             	add    $0x1,%edx
  800958:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80095c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80095f:	84 db                	test   %bl,%bl
  800961:	75 ef                	jne    800952 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800963:	5b                   	pop    %ebx
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	53                   	push   %ebx
  80096a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096d:	53                   	push   %ebx
  80096e:	e8 9c ff ff ff       	call   80090f <strlen>
  800973:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800976:	ff 75 0c             	pushl  0xc(%ebp)
  800979:	01 d8                	add    %ebx,%eax
  80097b:	50                   	push   %eax
  80097c:	e8 c5 ff ff ff       	call   800946 <strcpy>
	return dst;
}
  800981:	89 d8                	mov    %ebx,%eax
  800983:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 75 08             	mov    0x8(%ebp),%esi
  800990:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800993:	89 f3                	mov    %esi,%ebx
  800995:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800998:	89 f2                	mov    %esi,%edx
  80099a:	eb 0f                	jmp    8009ab <strncpy+0x23>
		*dst++ = *src;
  80099c:	83 c2 01             	add    $0x1,%edx
  80099f:	0f b6 01             	movzbl (%ecx),%eax
  8009a2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a5:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a8:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009ab:	39 da                	cmp    %ebx,%edx
  8009ad:	75 ed                	jne    80099c <strncpy+0x14>
	}
	return ret;
}
  8009af:	89 f0                	mov    %esi,%eax
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	56                   	push   %esi
  8009b9:	53                   	push   %ebx
  8009ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009c3:	89 f0                	mov    %esi,%eax
  8009c5:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c9:	85 c9                	test   %ecx,%ecx
  8009cb:	75 0b                	jne    8009d8 <strlcpy+0x23>
  8009cd:	eb 17                	jmp    8009e6 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cf:	83 c2 01             	add    $0x1,%edx
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009d8:	39 d8                	cmp    %ebx,%eax
  8009da:	74 07                	je     8009e3 <strlcpy+0x2e>
  8009dc:	0f b6 0a             	movzbl (%edx),%ecx
  8009df:	84 c9                	test   %cl,%cl
  8009e1:	75 ec                	jne    8009cf <strlcpy+0x1a>
		*dst = '\0';
  8009e3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e6:	29 f0                	sub    %esi,%eax
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f5:	eb 06                	jmp    8009fd <strcmp+0x11>
		p++, q++;
  8009f7:	83 c1 01             	add    $0x1,%ecx
  8009fa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009fd:	0f b6 01             	movzbl (%ecx),%eax
  800a00:	84 c0                	test   %al,%al
  800a02:	74 04                	je     800a08 <strcmp+0x1c>
  800a04:	3a 02                	cmp    (%edx),%al
  800a06:	74 ef                	je     8009f7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a08:	0f b6 c0             	movzbl %al,%eax
  800a0b:	0f b6 12             	movzbl (%edx),%edx
  800a0e:	29 d0                	sub    %edx,%eax
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1c:	89 c3                	mov    %eax,%ebx
  800a1e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a21:	eb 06                	jmp    800a29 <strncmp+0x17>
		n--, p++, q++;
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a29:	39 d8                	cmp    %ebx,%eax
  800a2b:	74 16                	je     800a43 <strncmp+0x31>
  800a2d:	0f b6 08             	movzbl (%eax),%ecx
  800a30:	84 c9                	test   %cl,%cl
  800a32:	74 04                	je     800a38 <strncmp+0x26>
  800a34:	3a 0a                	cmp    (%edx),%cl
  800a36:	74 eb                	je     800a23 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a38:	0f b6 00             	movzbl (%eax),%eax
  800a3b:	0f b6 12             	movzbl (%edx),%edx
  800a3e:	29 d0                	sub    %edx,%eax
}
  800a40:	5b                   	pop    %ebx
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    
		return 0;
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
  800a48:	eb f6                	jmp    800a40 <strncmp+0x2e>

00800a4a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a54:	0f b6 10             	movzbl (%eax),%edx
  800a57:	84 d2                	test   %dl,%dl
  800a59:	74 09                	je     800a64 <strchr+0x1a>
		if (*s == c)
  800a5b:	38 ca                	cmp    %cl,%dl
  800a5d:	74 0a                	je     800a69 <strchr+0x1f>
	for (; *s; s++)
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	eb f0                	jmp    800a54 <strchr+0xa>
			return (char *) s;
	return 0;
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a75:	eb 03                	jmp    800a7a <strfind+0xf>
  800a77:	83 c0 01             	add    $0x1,%eax
  800a7a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a7d:	38 ca                	cmp    %cl,%dl
  800a7f:	74 04                	je     800a85 <strfind+0x1a>
  800a81:	84 d2                	test   %dl,%dl
  800a83:	75 f2                	jne    800a77 <strfind+0xc>
			break;
	return (char *) s;
}
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	53                   	push   %ebx
  800a8d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a93:	85 c9                	test   %ecx,%ecx
  800a95:	74 13                	je     800aaa <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a97:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9d:	75 05                	jne    800aa4 <memset+0x1d>
  800a9f:	f6 c1 03             	test   $0x3,%cl
  800aa2:	74 0d                	je     800ab1 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa7:	fc                   	cld    
  800aa8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aaa:	89 f8                	mov    %edi,%eax
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5f                   	pop    %edi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    
		c &= 0xFF;
  800ab1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab5:	89 d3                	mov    %edx,%ebx
  800ab7:	c1 e3 08             	shl    $0x8,%ebx
  800aba:	89 d0                	mov    %edx,%eax
  800abc:	c1 e0 18             	shl    $0x18,%eax
  800abf:	89 d6                	mov    %edx,%esi
  800ac1:	c1 e6 10             	shl    $0x10,%esi
  800ac4:	09 f0                	or     %esi,%eax
  800ac6:	09 c2                	or     %eax,%edx
  800ac8:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800aca:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800acd:	89 d0                	mov    %edx,%eax
  800acf:	fc                   	cld    
  800ad0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad2:	eb d6                	jmp    800aaa <memset+0x23>

00800ad4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae2:	39 c6                	cmp    %eax,%esi
  800ae4:	73 35                	jae    800b1b <memmove+0x47>
  800ae6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae9:	39 c2                	cmp    %eax,%edx
  800aeb:	76 2e                	jbe    800b1b <memmove+0x47>
		s += n;
		d += n;
  800aed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	09 fe                	or     %edi,%esi
  800af4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afa:	74 0c                	je     800b08 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800afc:	83 ef 01             	sub    $0x1,%edi
  800aff:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b02:	fd                   	std    
  800b03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b05:	fc                   	cld    
  800b06:	eb 21                	jmp    800b29 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b08:	f6 c1 03             	test   $0x3,%cl
  800b0b:	75 ef                	jne    800afc <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b0d:	83 ef 04             	sub    $0x4,%edi
  800b10:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b13:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b16:	fd                   	std    
  800b17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b19:	eb ea                	jmp    800b05 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1b:	89 f2                	mov    %esi,%edx
  800b1d:	09 c2                	or     %eax,%edx
  800b1f:	f6 c2 03             	test   $0x3,%dl
  800b22:	74 09                	je     800b2d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b24:	89 c7                	mov    %eax,%edi
  800b26:	fc                   	cld    
  800b27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2d:	f6 c1 03             	test   $0x3,%cl
  800b30:	75 f2                	jne    800b24 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b32:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b35:	89 c7                	mov    %eax,%edi
  800b37:	fc                   	cld    
  800b38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3a:	eb ed                	jmp    800b29 <memmove+0x55>

00800b3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3f:	ff 75 10             	pushl  0x10(%ebp)
  800b42:	ff 75 0c             	pushl  0xc(%ebp)
  800b45:	ff 75 08             	pushl  0x8(%ebp)
  800b48:	e8 87 ff ff ff       	call   800ad4 <memmove>
}
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5a:	89 c6                	mov    %eax,%esi
  800b5c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5f:	39 f0                	cmp    %esi,%eax
  800b61:	74 1c                	je     800b7f <memcmp+0x30>
		if (*s1 != *s2)
  800b63:	0f b6 08             	movzbl (%eax),%ecx
  800b66:	0f b6 1a             	movzbl (%edx),%ebx
  800b69:	38 d9                	cmp    %bl,%cl
  800b6b:	75 08                	jne    800b75 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b6d:	83 c0 01             	add    $0x1,%eax
  800b70:	83 c2 01             	add    $0x1,%edx
  800b73:	eb ea                	jmp    800b5f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b75:	0f b6 c1             	movzbl %cl,%eax
  800b78:	0f b6 db             	movzbl %bl,%ebx
  800b7b:	29 d8                	sub    %ebx,%eax
  800b7d:	eb 05                	jmp    800b84 <memcmp+0x35>
	}

	return 0;
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b91:	89 c2                	mov    %eax,%edx
  800b93:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b96:	39 d0                	cmp    %edx,%eax
  800b98:	73 09                	jae    800ba3 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9a:	38 08                	cmp    %cl,(%eax)
  800b9c:	74 05                	je     800ba3 <memfind+0x1b>
	for (; s < ends; s++)
  800b9e:	83 c0 01             	add    $0x1,%eax
  800ba1:	eb f3                	jmp    800b96 <memfind+0xe>
			break;
	return (void *) s;
}
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	57                   	push   %edi
  800ba9:	56                   	push   %esi
  800baa:	53                   	push   %ebx
  800bab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb1:	eb 03                	jmp    800bb6 <strtol+0x11>
		s++;
  800bb3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bb6:	0f b6 01             	movzbl (%ecx),%eax
  800bb9:	3c 20                	cmp    $0x20,%al
  800bbb:	74 f6                	je     800bb3 <strtol+0xe>
  800bbd:	3c 09                	cmp    $0x9,%al
  800bbf:	74 f2                	je     800bb3 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bc1:	3c 2b                	cmp    $0x2b,%al
  800bc3:	74 2e                	je     800bf3 <strtol+0x4e>
	int neg = 0;
  800bc5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bca:	3c 2d                	cmp    $0x2d,%al
  800bcc:	74 2f                	je     800bfd <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bce:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bd4:	75 05                	jne    800bdb <strtol+0x36>
  800bd6:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd9:	74 2c                	je     800c07 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdb:	85 db                	test   %ebx,%ebx
  800bdd:	75 0a                	jne    800be9 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bdf:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800be4:	80 39 30             	cmpb   $0x30,(%ecx)
  800be7:	74 28                	je     800c11 <strtol+0x6c>
		base = 10;
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bf1:	eb 50                	jmp    800c43 <strtol+0x9e>
		s++;
  800bf3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bf6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfb:	eb d1                	jmp    800bce <strtol+0x29>
		s++, neg = 1;
  800bfd:	83 c1 01             	add    $0x1,%ecx
  800c00:	bf 01 00 00 00       	mov    $0x1,%edi
  800c05:	eb c7                	jmp    800bce <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c07:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c0b:	74 0e                	je     800c1b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c0d:	85 db                	test   %ebx,%ebx
  800c0f:	75 d8                	jne    800be9 <strtol+0x44>
		s++, base = 8;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c19:	eb ce                	jmp    800be9 <strtol+0x44>
		s += 2, base = 16;
  800c1b:	83 c1 02             	add    $0x2,%ecx
  800c1e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c23:	eb c4                	jmp    800be9 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c25:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c28:	89 f3                	mov    %esi,%ebx
  800c2a:	80 fb 19             	cmp    $0x19,%bl
  800c2d:	77 29                	ja     800c58 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c2f:	0f be d2             	movsbl %dl,%edx
  800c32:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c35:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c38:	7d 30                	jge    800c6a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c3a:	83 c1 01             	add    $0x1,%ecx
  800c3d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c41:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c43:	0f b6 11             	movzbl (%ecx),%edx
  800c46:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c49:	89 f3                	mov    %esi,%ebx
  800c4b:	80 fb 09             	cmp    $0x9,%bl
  800c4e:	77 d5                	ja     800c25 <strtol+0x80>
			dig = *s - '0';
  800c50:	0f be d2             	movsbl %dl,%edx
  800c53:	83 ea 30             	sub    $0x30,%edx
  800c56:	eb dd                	jmp    800c35 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c58:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c5b:	89 f3                	mov    %esi,%ebx
  800c5d:	80 fb 19             	cmp    $0x19,%bl
  800c60:	77 08                	ja     800c6a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c62:	0f be d2             	movsbl %dl,%edx
  800c65:	83 ea 37             	sub    $0x37,%edx
  800c68:	eb cb                	jmp    800c35 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6e:	74 05                	je     800c75 <strtol+0xd0>
		*endptr = (char *) s;
  800c70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c73:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c75:	89 c2                	mov    %eax,%edx
  800c77:	f7 da                	neg    %edx
  800c79:	85 ff                	test   %edi,%edi
  800c7b:	0f 45 c2             	cmovne %edx,%eax
}
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    
  800c83:	66 90                	xchg   %ax,%ax
  800c85:	66 90                	xchg   %ax,%ax
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
