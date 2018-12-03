
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	57                   	push   %edi
  800042:	56                   	push   %esi
  800043:	53                   	push   %ebx
  800044:	83 ec 0c             	sub    $0xc,%esp
  800047:	e8 50 00 00 00       	call   80009c <__x86.get_pc_thunk.bx>
  80004c:	81 c3 b4 1f 00 00    	add    $0x1fb4,%ebx
  800052:	8b 75 08             	mov    0x8(%ebp),%esi
  800055:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800058:	e8 f6 00 00 00       	call   800153 <sys_getenvid>
  80005d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800062:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800065:	c1 e0 05             	shl    $0x5,%eax
  800068:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80006e:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800074:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 f6                	test   %esi,%esi
  800078:	7e 08                	jle    800082 <libmain+0x44>
		binaryname = argv[0];
  80007a:	8b 07                	mov    (%edi),%eax
  80007c:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	57                   	push   %edi
  800086:	56                   	push   %esi
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0f 00 00 00       	call   8000a0 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5f                   	pop    %edi
  80009a:	5d                   	pop    %ebp
  80009b:	c3                   	ret    

0080009c <__x86.get_pc_thunk.bx>:
  80009c:	8b 1c 24             	mov    (%esp),%ebx
  80009f:	c3                   	ret    

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	53                   	push   %ebx
  8000a4:	83 ec 10             	sub    $0x10,%esp
  8000a7:	e8 f0 ff ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  8000ac:	81 c3 54 1f 00 00    	add    $0x1f54,%ebx
	sys_env_destroy(0);
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 45 00 00 00       	call   8000fe <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    

008000c1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d2:	89 c3                	mov    %eax,%ebx
  8000d4:	89 c7                	mov    %eax,%edi
  8000d6:	89 c6                	mov    %eax,%esi
  8000d8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_cgetc>:

int
sys_cgetc(void)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ea:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ef:	89 d1                	mov    %edx,%ecx
  8000f1:	89 d3                	mov    %edx,%ebx
  8000f3:	89 d7                	mov    %edx,%edi
  8000f5:	89 d6                	mov    %edx,%esi
  8000f7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
  800104:	83 ec 1c             	sub    $0x1c,%esp
  800107:	e8 66 00 00 00       	call   800172 <__x86.get_pc_thunk.ax>
  80010c:	05 f4 1e 00 00       	add    $0x1ef4,%eax
  800111:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800114:	b9 00 00 00 00       	mov    $0x0,%ecx
  800119:	8b 55 08             	mov    0x8(%ebp),%edx
  80011c:	b8 03 00 00 00       	mov    $0x3,%eax
  800121:	89 cb                	mov    %ecx,%ebx
  800123:	89 cf                	mov    %ecx,%edi
  800125:	89 ce                	mov    %ecx,%esi
  800127:	cd 30                	int    $0x30
	if(check && ret > 0)
  800129:	85 c0                	test   %eax,%eax
  80012b:	7f 08                	jg     800135 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5f                   	pop    %edi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	50                   	push   %eax
  800139:	6a 03                	push   $0x3
  80013b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013e:	8d 83 c6 ee ff ff    	lea    -0x113a(%ebx),%eax
  800144:	50                   	push   %eax
  800145:	6a 26                	push   $0x26
  800147:	8d 83 e3 ee ff ff    	lea    -0x111d(%ebx),%eax
  80014d:	50                   	push   %eax
  80014e:	e8 23 00 00 00       	call   800176 <_panic>

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 02 00 00 00       	mov    $0x2,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <__x86.get_pc_thunk.ax>:
  800172:	8b 04 24             	mov    (%esp),%eax
  800175:	c3                   	ret    

00800176 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	57                   	push   %edi
  80017a:	56                   	push   %esi
  80017b:	53                   	push   %ebx
  80017c:	83 ec 0c             	sub    $0xc,%esp
  80017f:	e8 18 ff ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  800184:	81 c3 7c 1e 00 00    	add    $0x1e7c,%ebx
	va_list ap;

	va_start(ap, fmt);
  80018a:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018d:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800193:	8b 38                	mov    (%eax),%edi
  800195:	e8 b9 ff ff ff       	call   800153 <sys_getenvid>
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	ff 75 0c             	pushl  0xc(%ebp)
  8001a0:	ff 75 08             	pushl  0x8(%ebp)
  8001a3:	57                   	push   %edi
  8001a4:	50                   	push   %eax
  8001a5:	8d 83 f4 ee ff ff    	lea    -0x110c(%ebx),%eax
  8001ab:	50                   	push   %eax
  8001ac:	e8 d1 00 00 00       	call   800282 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b1:	83 c4 18             	add    $0x18,%esp
  8001b4:	56                   	push   %esi
  8001b5:	ff 75 10             	pushl  0x10(%ebp)
  8001b8:	e8 63 00 00 00       	call   800220 <vcprintf>
	cprintf("\n");
  8001bd:	8d 83 18 ef ff ff    	lea    -0x10e8(%ebx),%eax
  8001c3:	89 04 24             	mov    %eax,(%esp)
  8001c6:	e8 b7 00 00 00       	call   800282 <cprintf>
  8001cb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ce:	cc                   	int3   
  8001cf:	eb fd                	jmp    8001ce <_panic+0x58>

008001d1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	e8 c1 fe ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  8001db:	81 c3 25 1e 00 00    	add    $0x1e25,%ebx
  8001e1:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e4:	8b 16                	mov    (%esi),%edx
  8001e6:	8d 42 01             	lea    0x1(%edx),%eax
  8001e9:	89 06                	mov    %eax,(%esi)
  8001eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ee:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f7:	74 0b                	je     800204 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f9:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800200:	5b                   	pop    %ebx
  800201:	5e                   	pop    %esi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800204:	83 ec 08             	sub    $0x8,%esp
  800207:	68 ff 00 00 00       	push   $0xff
  80020c:	8d 46 08             	lea    0x8(%esi),%eax
  80020f:	50                   	push   %eax
  800210:	e8 ac fe ff ff       	call   8000c1 <sys_cputs>
		b->idx = 0;
  800215:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021b:	83 c4 10             	add    $0x10,%esp
  80021e:	eb d9                	jmp    8001f9 <putch+0x28>

00800220 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	53                   	push   %ebx
  800224:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80022a:	e8 6d fe ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  80022f:	81 c3 d1 1d 00 00    	add    $0x1dd1,%ebx
	struct printbuf b;

	b.idx = 0;
  800235:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023c:	00 00 00 
	b.cnt = 0;
  80023f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800246:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800249:	ff 75 0c             	pushl  0xc(%ebp)
  80024c:	ff 75 08             	pushl  0x8(%ebp)
  80024f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800255:	50                   	push   %eax
  800256:	8d 83 d1 e1 ff ff    	lea    -0x1e2f(%ebx),%eax
  80025c:	50                   	push   %eax
  80025d:	e8 38 01 00 00       	call   80039a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800262:	83 c4 08             	add    $0x8,%esp
  800265:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80026b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800271:	50                   	push   %eax
  800272:	e8 4a fe ff ff       	call   8000c1 <sys_cputs>
	return b.cnt;
}
  800277:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800288:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028b:	50                   	push   %eax
  80028c:	ff 75 08             	pushl  0x8(%ebp)
  80028f:	e8 8c ff ff ff       	call   800220 <vcprintf>
	va_end(ap);

	return cnt;
}
  800294:	c9                   	leave  
  800295:	c3                   	ret    

00800296 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	57                   	push   %edi
  80029a:	56                   	push   %esi
  80029b:	53                   	push   %ebx
  80029c:	83 ec 2c             	sub    $0x2c,%esp
  80029f:	e8 63 06 00 00       	call   800907 <__x86.get_pc_thunk.cx>
  8002a4:	81 c1 5c 1d 00 00    	add    $0x1d5c,%ecx
  8002aa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002ad:	89 c7                	mov    %eax,%edi
  8002af:	89 d6                	mov    %edx,%esi
  8002b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c5:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002c8:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002cb:	39 d3                	cmp    %edx,%ebx
  8002cd:	72 09                	jb     8002d8 <printnum+0x42>
  8002cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d2:	0f 87 83 00 00 00    	ja     80035b <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	ff 75 18             	pushl  0x18(%ebp)
  8002de:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e4:	53                   	push   %ebx
  8002e5:	ff 75 10             	pushl  0x10(%ebp)
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002f4:	ff 75 d0             	pushl  -0x30(%ebp)
  8002f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002fa:	e8 81 09 00 00       	call   800c80 <__udivdi3>
  8002ff:	83 c4 18             	add    $0x18,%esp
  800302:	52                   	push   %edx
  800303:	50                   	push   %eax
  800304:	89 f2                	mov    %esi,%edx
  800306:	89 f8                	mov    %edi,%eax
  800308:	e8 89 ff ff ff       	call   800296 <printnum>
  80030d:	83 c4 20             	add    $0x20,%esp
  800310:	eb 13                	jmp    800325 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	56                   	push   %esi
  800316:	ff 75 18             	pushl  0x18(%ebp)
  800319:	ff d7                	call   *%edi
  80031b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031e:	83 eb 01             	sub    $0x1,%ebx
  800321:	85 db                	test   %ebx,%ebx
  800323:	7f ed                	jg     800312 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	56                   	push   %esi
  800329:	83 ec 04             	sub    $0x4,%esp
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	ff 75 d4             	pushl  -0x2c(%ebp)
  800335:	ff 75 d0             	pushl  -0x30(%ebp)
  800338:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80033b:	89 f3                	mov    %esi,%ebx
  80033d:	e8 5e 0a 00 00       	call   800da0 <__umoddi3>
  800342:	83 c4 14             	add    $0x14,%esp
  800345:	0f be 84 06 1a ef ff 	movsbl -0x10e6(%esi,%eax,1),%eax
  80034c:	ff 
  80034d:	50                   	push   %eax
  80034e:	ff d7                	call   *%edi
}
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    
  80035b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80035e:	eb be                	jmp    80031e <printnum+0x88>

00800360 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800366:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036a:	8b 10                	mov    (%eax),%edx
  80036c:	3b 50 04             	cmp    0x4(%eax),%edx
  80036f:	73 0a                	jae    80037b <sprintputch+0x1b>
		*b->buf++ = ch;
  800371:	8d 4a 01             	lea    0x1(%edx),%ecx
  800374:	89 08                	mov    %ecx,(%eax)
  800376:	8b 45 08             	mov    0x8(%ebp),%eax
  800379:	88 02                	mov    %al,(%edx)
}
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <printfmt>:
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800383:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800386:	50                   	push   %eax
  800387:	ff 75 10             	pushl  0x10(%ebp)
  80038a:	ff 75 0c             	pushl  0xc(%ebp)
  80038d:	ff 75 08             	pushl  0x8(%ebp)
  800390:	e8 05 00 00 00       	call   80039a <vprintfmt>
}
  800395:	83 c4 10             	add    $0x10,%esp
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vprintfmt>:
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	57                   	push   %edi
  80039e:	56                   	push   %esi
  80039f:	53                   	push   %ebx
  8003a0:	83 ec 2c             	sub    $0x2c,%esp
  8003a3:	e8 f4 fc ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  8003a8:	81 c3 58 1c 00 00    	add    $0x1c58,%ebx
  8003ae:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003b1:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003b8:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003ba:	8d 77 01             	lea    0x1(%edi),%esi
  8003bd:	0f b6 07             	movzbl (%edi),%eax
  8003c0:	83 f8 25             	cmp    $0x25,%eax
  8003c3:	74 1c                	je     8003e1 <vprintfmt+0x47>
			if (ch == '\0')
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	0f 84 b9 04 00 00    	je     800886 <.L21+0x20>
			putch(ch, putdat);
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003d3:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003d6:	50                   	push   %eax
  8003d7:	ff 55 08             	call   *0x8(%ebp)
  8003da:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003dd:	89 f7                	mov    %esi,%edi
  8003df:	eb d9                	jmp    8003ba <vprintfmt+0x20>
		padc = ' ';
  8003e1:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003e5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003ec:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003f3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ff:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800402:	8d 7e 01             	lea    0x1(%esi),%edi
  800405:	0f b6 16             	movzbl (%esi),%edx
  800408:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040b:	3c 55                	cmp    $0x55,%al
  80040d:	0f 87 53 04 00 00    	ja     800866 <.L21>
  800413:	0f b6 c0             	movzbl %al,%eax
  800416:	89 d9                	mov    %ebx,%ecx
  800418:	03 8c 83 a8 ef ff ff 	add    -0x1058(%ebx,%eax,4),%ecx
  80041f:	ff e1                	jmp    *%ecx

00800421 <.L73>:
  800421:	89 fe                	mov    %edi,%esi
			padc = '-';
  800423:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800427:	eb d9                	jmp    800402 <vprintfmt+0x68>

00800429 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	89 fe                	mov    %edi,%esi
			padc = '0';
  80042b:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80042f:	eb d1                	jmp    800402 <vprintfmt+0x68>

00800431 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	0f b6 d2             	movzbl %dl,%edx
  800434:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  80043e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800441:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800445:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800448:	8d 7a d0             	lea    -0x30(%edx),%edi
  80044b:	83 ff 09             	cmp    $0x9,%edi
  80044e:	0f 87 94 00 00 00    	ja     8004e8 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800454:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800457:	eb e5                	jmp    80043e <.L28+0xd>

00800459 <.L25>:
			precision = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8b 00                	mov    (%eax),%eax
  80045e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 40 04             	lea    0x4(%eax),%eax
  800467:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	89 fe                	mov    %edi,%esi
			if (width < 0)
  80046c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800470:	79 90                	jns    800402 <vprintfmt+0x68>
				width = precision, precision = -1;
  800472:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800475:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800478:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80047f:	eb 81                	jmp    800402 <vprintfmt+0x68>

00800481 <.L26>:
  800481:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800484:	85 c0                	test   %eax,%eax
  800486:	ba 00 00 00 00       	mov    $0x0,%edx
  80048b:	0f 49 d0             	cmovns %eax,%edx
  80048e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800491:	89 fe                	mov    %edi,%esi
  800493:	e9 6a ff ff ff       	jmp    800402 <vprintfmt+0x68>

00800498 <.L22>:
  800498:	89 fe                	mov    %edi,%esi
			altflag = 1;
  80049a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a1:	e9 5c ff ff ff       	jmp    800402 <vprintfmt+0x68>

008004a6 <.L33>:
  8004a6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004a9:	83 f9 01             	cmp    $0x1,%ecx
  8004ac:	7e 16                	jle    8004c4 <.L33+0x1e>
		return va_arg(*ap, long long);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8b 00                	mov    (%eax),%eax
  8004b3:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004b6:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004b9:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004bf:	e9 f6 fe ff ff       	jmp    8003ba <vprintfmt+0x20>
	else if (lflag)
  8004c4:	85 c9                	test   %ecx,%ecx
  8004c6:	75 10                	jne    8004d8 <.L33+0x32>
		return va_arg(*ap, int);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004d0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004d3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004d6:	eb e4                	jmp    8004bc <.L33+0x16>
		return va_arg(*ap, long);
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004e0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004e3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004e6:	eb d4                	jmp    8004bc <.L33+0x16>
  8004e8:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ee:	e9 79 ff ff ff       	jmp    80046c <.L25+0x13>

008004f3 <.L32>:
			lflag++;
  8004f3:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8004f9:	e9 04 ff ff ff       	jmp    800402 <vprintfmt+0x68>

008004fe <.L29>:
			putch(va_arg(ap, int), putdat);
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 70 04             	lea    0x4(%eax),%esi
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	ff 75 0c             	pushl  0xc(%ebp)
  80050a:	ff 30                	pushl  (%eax)
  80050c:	ff 55 08             	call   *0x8(%ebp)
			break;
  80050f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800512:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800515:	e9 a0 fe ff ff       	jmp    8003ba <vprintfmt+0x20>

0080051a <.L31>:
			err = va_arg(ap, int);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 70 04             	lea    0x4(%eax),%esi
  800520:	8b 00                	mov    (%eax),%eax
  800522:	99                   	cltd   
  800523:	31 d0                	xor    %edx,%eax
  800525:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800527:	83 f8 06             	cmp    $0x6,%eax
  80052a:	7f 29                	jg     800555 <.L31+0x3b>
  80052c:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	74 1e                	je     800555 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800537:	52                   	push   %edx
  800538:	8d 83 3b ef ff ff    	lea    -0x10c5(%ebx),%eax
  80053e:	50                   	push   %eax
  80053f:	ff 75 0c             	pushl  0xc(%ebp)
  800542:	ff 75 08             	pushl  0x8(%ebp)
  800545:	e8 33 fe ff ff       	call   80037d <printfmt>
  80054a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80054d:	89 75 14             	mov    %esi,0x14(%ebp)
  800550:	e9 65 fe ff ff       	jmp    8003ba <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800555:	50                   	push   %eax
  800556:	8d 83 32 ef ff ff    	lea    -0x10ce(%ebx),%eax
  80055c:	50                   	push   %eax
  80055d:	ff 75 0c             	pushl  0xc(%ebp)
  800560:	ff 75 08             	pushl  0x8(%ebp)
  800563:	e8 15 fe ff ff       	call   80037d <printfmt>
  800568:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80056b:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80056e:	e9 47 fe ff ff       	jmp    8003ba <vprintfmt+0x20>

00800573 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	83 c0 04             	add    $0x4,%eax
  800579:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800581:	85 f6                	test   %esi,%esi
  800583:	8d 83 2b ef ff ff    	lea    -0x10d5(%ebx),%eax
  800589:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  80058c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800590:	0f 8e b4 00 00 00    	jle    80064a <.L36+0xd7>
  800596:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80059a:	75 08                	jne    8005a4 <.L36+0x31>
  80059c:	89 7d 10             	mov    %edi,0x10(%ebp)
  80059f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005a2:	eb 6c                	jmp    800610 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	ff 75 cc             	pushl  -0x34(%ebp)
  8005aa:	56                   	push   %esi
  8005ab:	e8 73 03 00 00       	call   800923 <strnlen>
  8005b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b3:	29 c2                	sub    %eax,%edx
  8005b5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005b8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005bb:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005c2:	89 d6                	mov    %edx,%esi
  8005c4:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005c7:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c9:	eb 10                	jmp    8005db <.L36+0x68>
					putch(padc, putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	ff 75 0c             	pushl  0xc(%ebp)
  8005d1:	57                   	push   %edi
  8005d2:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d5:	83 ee 01             	sub    $0x1,%esi
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	85 f6                	test   %esi,%esi
  8005dd:	7f ec                	jg     8005cb <.L36+0x58>
  8005df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e5:	85 d2                	test   %edx,%edx
  8005e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ec:	0f 49 c2             	cmovns %edx,%eax
  8005ef:	29 c2                	sub    %eax,%edx
  8005f1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005f7:	eb 17                	jmp    800610 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8005f9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005fd:	75 30                	jne    80062f <.L36+0xbc>
					putch(ch, putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	ff 75 0c             	pushl  0xc(%ebp)
  800605:	50                   	push   %eax
  800606:	ff 55 08             	call   *0x8(%ebp)
  800609:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80060c:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800610:	83 c6 01             	add    $0x1,%esi
  800613:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800617:	0f be c2             	movsbl %dl,%eax
  80061a:	85 c0                	test   %eax,%eax
  80061c:	74 58                	je     800676 <.L36+0x103>
  80061e:	85 ff                	test   %edi,%edi
  800620:	78 d7                	js     8005f9 <.L36+0x86>
  800622:	83 ef 01             	sub    $0x1,%edi
  800625:	79 d2                	jns    8005f9 <.L36+0x86>
  800627:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80062a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80062d:	eb 32                	jmp    800661 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  80062f:	0f be d2             	movsbl %dl,%edx
  800632:	83 ea 20             	sub    $0x20,%edx
  800635:	83 fa 5e             	cmp    $0x5e,%edx
  800638:	76 c5                	jbe    8005ff <.L36+0x8c>
					putch('?', putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	ff 75 0c             	pushl  0xc(%ebp)
  800640:	6a 3f                	push   $0x3f
  800642:	ff 55 08             	call   *0x8(%ebp)
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	eb c2                	jmp    80060c <.L36+0x99>
  80064a:	89 7d 10             	mov    %edi,0x10(%ebp)
  80064d:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800650:	eb be                	jmp    800610 <.L36+0x9d>
				putch(' ', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	57                   	push   %edi
  800656:	6a 20                	push   $0x20
  800658:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80065b:	83 ee 01             	sub    $0x1,%esi
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 f6                	test   %esi,%esi
  800663:	7f ed                	jg     800652 <.L36+0xdf>
  800665:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800668:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  80066b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80066e:	89 45 14             	mov    %eax,0x14(%ebp)
  800671:	e9 44 fd ff ff       	jmp    8003ba <vprintfmt+0x20>
  800676:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800679:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80067c:	eb e3                	jmp    800661 <.L36+0xee>

0080067e <.L30>:
  80067e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800681:	83 f9 01             	cmp    $0x1,%ecx
  800684:	7e 42                	jle    8006c8 <.L30+0x4a>
		return va_arg(*ap, long long);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8b 50 04             	mov    0x4(%eax),%edx
  80068c:	8b 00                	mov    (%eax),%eax
  80068e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800691:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 40 08             	lea    0x8(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80069d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a1:	79 5f                	jns    800702 <.L30+0x84>
				putch('-', putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	ff 75 0c             	pushl  0xc(%ebp)
  8006a9:	6a 2d                	push   $0x2d
  8006ab:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b4:	f7 da                	neg    %edx
  8006b6:	83 d1 00             	adc    $0x0,%ecx
  8006b9:	f7 d9                	neg    %ecx
  8006bb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c3:	e9 b8 00 00 00       	jmp    800780 <.L34+0x22>
	else if (lflag)
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	75 1b                	jne    8006e7 <.L30+0x69>
		return va_arg(*ap, int);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 30                	mov    (%eax),%esi
  8006d1:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006d4:	89 f0                	mov    %esi,%eax
  8006d6:	c1 f8 1f             	sar    $0x1f,%eax
  8006d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 40 04             	lea    0x4(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e5:	eb b6                	jmp    80069d <.L30+0x1f>
		return va_arg(*ap, long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 30                	mov    (%eax),%esi
  8006ec:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006ef:	89 f0                	mov    %esi,%eax
  8006f1:	c1 f8 1f             	sar    $0x1f,%eax
  8006f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 40 04             	lea    0x4(%eax),%eax
  8006fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800700:	eb 9b                	jmp    80069d <.L30+0x1f>
			num = getint(&ap, lflag);
  800702:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800705:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800708:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070d:	eb 71                	jmp    800780 <.L34+0x22>

0080070f <.L37>:
  80070f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800712:	83 f9 01             	cmp    $0x1,%ecx
  800715:	7e 15                	jle    80072c <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8b 10                	mov    (%eax),%edx
  80071c:	8b 48 04             	mov    0x4(%eax),%ecx
  80071f:	8d 40 08             	lea    0x8(%eax),%eax
  800722:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800725:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072a:	eb 54                	jmp    800780 <.L34+0x22>
	else if (lflag)
  80072c:	85 c9                	test   %ecx,%ecx
  80072e:	75 17                	jne    800747 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8b 10                	mov    (%eax),%edx
  800735:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073a:	8d 40 04             	lea    0x4(%eax),%eax
  80073d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800740:	b8 0a 00 00 00       	mov    $0xa,%eax
  800745:	eb 39                	jmp    800780 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8b 10                	mov    (%eax),%edx
  80074c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800751:	8d 40 04             	lea    0x4(%eax),%eax
  800754:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800757:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075c:	eb 22                	jmp    800780 <.L34+0x22>

0080075e <.L34>:
  80075e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800761:	83 f9 01             	cmp    $0x1,%ecx
  800764:	7e 3b                	jle    8007a1 <.L34+0x43>
		return va_arg(*ap, long long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 50 04             	mov    0x4(%eax),%edx
  80076c:	8b 00                	mov    (%eax),%eax
  80076e:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800771:	8d 49 08             	lea    0x8(%ecx),%ecx
  800774:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800777:	89 d1                	mov    %edx,%ecx
  800779:	89 c2                	mov    %eax,%edx
			base = 8;
  80077b:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800780:	83 ec 0c             	sub    $0xc,%esp
  800783:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  800787:	56                   	push   %esi
  800788:	ff 75 e0             	pushl  -0x20(%ebp)
  80078b:	50                   	push   %eax
  80078c:	51                   	push   %ecx
  80078d:	52                   	push   %edx
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	e8 fd fa ff ff       	call   800296 <printnum>
			break;
  800799:	83 c4 20             	add    $0x20,%esp
  80079c:	e9 19 fc ff ff       	jmp    8003ba <vprintfmt+0x20>
	else if (lflag)
  8007a1:	85 c9                	test   %ecx,%ecx
  8007a3:	75 13                	jne    8007b8 <.L34+0x5a>
		return va_arg(*ap, int);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8b 10                	mov    (%eax),%edx
  8007aa:	89 d0                	mov    %edx,%eax
  8007ac:	99                   	cltd   
  8007ad:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007b0:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007b3:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007b6:	eb bf                	jmp    800777 <.L34+0x19>
		return va_arg(*ap, long);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8b 10                	mov    (%eax),%edx
  8007bd:	89 d0                	mov    %edx,%eax
  8007bf:	99                   	cltd   
  8007c0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007c3:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007c6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007c9:	eb ac                	jmp    800777 <.L34+0x19>

008007cb <.L35>:
			putch('0', putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	ff 75 0c             	pushl  0xc(%ebp)
  8007d1:	6a 30                	push   $0x30
  8007d3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	ff 75 0c             	pushl  0xc(%ebp)
  8007dc:	6a 78                	push   $0x78
  8007de:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8b 10                	mov    (%eax),%edx
  8007e6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007eb:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007ee:	8d 40 04             	lea    0x4(%eax),%eax
  8007f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f9:	eb 85                	jmp    800780 <.L34+0x22>

008007fb <.L38>:
  8007fb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8007fe:	83 f9 01             	cmp    $0x1,%ecx
  800801:	7e 18                	jle    80081b <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	8b 10                	mov    (%eax),%edx
  800808:	8b 48 04             	mov    0x4(%eax),%ecx
  80080b:	8d 40 08             	lea    0x8(%eax),%eax
  80080e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800811:	b8 10 00 00 00       	mov    $0x10,%eax
  800816:	e9 65 ff ff ff       	jmp    800780 <.L34+0x22>
	else if (lflag)
  80081b:	85 c9                	test   %ecx,%ecx
  80081d:	75 1a                	jne    800839 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8b 10                	mov    (%eax),%edx
  800824:	b9 00 00 00 00       	mov    $0x0,%ecx
  800829:	8d 40 04             	lea    0x4(%eax),%eax
  80082c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082f:	b8 10 00 00 00       	mov    $0x10,%eax
  800834:	e9 47 ff ff ff       	jmp    800780 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800839:	8b 45 14             	mov    0x14(%ebp),%eax
  80083c:	8b 10                	mov    (%eax),%edx
  80083e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800843:	8d 40 04             	lea    0x4(%eax),%eax
  800846:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800849:	b8 10 00 00 00       	mov    $0x10,%eax
  80084e:	e9 2d ff ff ff       	jmp    800780 <.L34+0x22>

00800853 <.L24>:
			putch(ch, putdat);
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	ff 75 0c             	pushl  0xc(%ebp)
  800859:	6a 25                	push   $0x25
  80085b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80085e:	83 c4 10             	add    $0x10,%esp
  800861:	e9 54 fb ff ff       	jmp    8003ba <vprintfmt+0x20>

00800866 <.L21>:
			putch('%', putdat);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	ff 75 0c             	pushl  0xc(%ebp)
  80086c:	6a 25                	push   $0x25
  80086e:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800871:	83 c4 10             	add    $0x10,%esp
  800874:	89 f7                	mov    %esi,%edi
  800876:	eb 03                	jmp    80087b <.L21+0x15>
  800878:	83 ef 01             	sub    $0x1,%edi
  80087b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80087f:	75 f7                	jne    800878 <.L21+0x12>
  800881:	e9 34 fb ff ff       	jmp    8003ba <vprintfmt+0x20>
}
  800886:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800889:	5b                   	pop    %ebx
  80088a:	5e                   	pop    %esi
  80088b:	5f                   	pop    %edi
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	53                   	push   %ebx
  800892:	83 ec 14             	sub    $0x14,%esp
  800895:	e8 02 f8 ff ff       	call   80009c <__x86.get_pc_thunk.bx>
  80089a:	81 c3 66 17 00 00    	add    $0x1766,%ebx
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	74 2b                	je     8008e6 <vsnprintf+0x58>
  8008bb:	85 d2                	test   %edx,%edx
  8008bd:	7e 27                	jle    8008e6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008bf:	ff 75 14             	pushl  0x14(%ebp)
  8008c2:	ff 75 10             	pushl  0x10(%ebp)
  8008c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c8:	50                   	push   %eax
  8008c9:	8d 83 60 e3 ff ff    	lea    -0x1ca0(%ebx),%eax
  8008cf:	50                   	push   %eax
  8008d0:	e8 c5 fa ff ff       	call   80039a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008de:	83 c4 10             	add    $0x10,%esp
}
  8008e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    
		return -E_INVAL;
  8008e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008eb:	eb f4                	jmp    8008e1 <vsnprintf+0x53>

008008ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f6:	50                   	push   %eax
  8008f7:	ff 75 10             	pushl  0x10(%ebp)
  8008fa:	ff 75 0c             	pushl  0xc(%ebp)
  8008fd:	ff 75 08             	pushl  0x8(%ebp)
  800900:	e8 89 ff ff ff       	call   80088e <vsnprintf>
	va_end(ap);

	return rc;
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <__x86.get_pc_thunk.cx>:
  800907:	8b 0c 24             	mov    (%esp),%ecx
  80090a:	c3                   	ret    

0080090b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
  800916:	eb 03                	jmp    80091b <strlen+0x10>
		n++;
  800918:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80091b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091f:	75 f7                	jne    800918 <strlen+0xd>
	return n;
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	eb 03                	jmp    800936 <strnlen+0x13>
		n++;
  800933:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800936:	39 d0                	cmp    %edx,%eax
  800938:	74 06                	je     800940 <strnlen+0x1d>
  80093a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80093e:	75 f3                	jne    800933 <strnlen+0x10>
	return n;
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	53                   	push   %ebx
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094c:	89 c2                	mov    %eax,%edx
  80094e:	83 c1 01             	add    $0x1,%ecx
  800951:	83 c2 01             	add    $0x1,%edx
  800954:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800958:	88 5a ff             	mov    %bl,-0x1(%edx)
  80095b:	84 db                	test   %bl,%bl
  80095d:	75 ef                	jne    80094e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80095f:	5b                   	pop    %ebx
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	53                   	push   %ebx
  800966:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800969:	53                   	push   %ebx
  80096a:	e8 9c ff ff ff       	call   80090b <strlen>
  80096f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800972:	ff 75 0c             	pushl  0xc(%ebp)
  800975:	01 d8                	add    %ebx,%eax
  800977:	50                   	push   %eax
  800978:	e8 c5 ff ff ff       	call   800942 <strcpy>
	return dst;
}
  80097d:	89 d8                	mov    %ebx,%eax
  80097f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 75 08             	mov    0x8(%ebp),%esi
  80098c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098f:	89 f3                	mov    %esi,%ebx
  800991:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800994:	89 f2                	mov    %esi,%edx
  800996:	eb 0f                	jmp    8009a7 <strncpy+0x23>
		*dst++ = *src;
  800998:	83 c2 01             	add    $0x1,%edx
  80099b:	0f b6 01             	movzbl (%ecx),%eax
  80099e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a1:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a4:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009a7:	39 da                	cmp    %ebx,%edx
  8009a9:	75 ed                	jne    800998 <strncpy+0x14>
	}
	return ret;
}
  8009ab:	89 f0                	mov    %esi,%eax
  8009ad:	5b                   	pop    %ebx
  8009ae:	5e                   	pop    %esi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
  8009b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009bf:	89 f0                	mov    %esi,%eax
  8009c1:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c5:	85 c9                	test   %ecx,%ecx
  8009c7:	75 0b                	jne    8009d4 <strlcpy+0x23>
  8009c9:	eb 17                	jmp    8009e2 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cb:	83 c2 01             	add    $0x1,%edx
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009d4:	39 d8                	cmp    %ebx,%eax
  8009d6:	74 07                	je     8009df <strlcpy+0x2e>
  8009d8:	0f b6 0a             	movzbl (%edx),%ecx
  8009db:	84 c9                	test   %cl,%cl
  8009dd:	75 ec                	jne    8009cb <strlcpy+0x1a>
		*dst = '\0';
  8009df:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e2:	29 f0                	sub    %esi,%eax
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5e                   	pop    %esi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f1:	eb 06                	jmp    8009f9 <strcmp+0x11>
		p++, q++;
  8009f3:	83 c1 01             	add    $0x1,%ecx
  8009f6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009f9:	0f b6 01             	movzbl (%ecx),%eax
  8009fc:	84 c0                	test   %al,%al
  8009fe:	74 04                	je     800a04 <strcmp+0x1c>
  800a00:	3a 02                	cmp    (%edx),%al
  800a02:	74 ef                	je     8009f3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a04:	0f b6 c0             	movzbl %al,%eax
  800a07:	0f b6 12             	movzbl (%edx),%edx
  800a0a:	29 d0                	sub    %edx,%eax
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	53                   	push   %ebx
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a18:	89 c3                	mov    %eax,%ebx
  800a1a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a1d:	eb 06                	jmp    800a25 <strncmp+0x17>
		n--, p++, q++;
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a25:	39 d8                	cmp    %ebx,%eax
  800a27:	74 16                	je     800a3f <strncmp+0x31>
  800a29:	0f b6 08             	movzbl (%eax),%ecx
  800a2c:	84 c9                	test   %cl,%cl
  800a2e:	74 04                	je     800a34 <strncmp+0x26>
  800a30:	3a 0a                	cmp    (%edx),%cl
  800a32:	74 eb                	je     800a1f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a34:	0f b6 00             	movzbl (%eax),%eax
  800a37:	0f b6 12             	movzbl (%edx),%edx
  800a3a:	29 d0                	sub    %edx,%eax
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    
		return 0;
  800a3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a44:	eb f6                	jmp    800a3c <strncmp+0x2e>

00800a46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a50:	0f b6 10             	movzbl (%eax),%edx
  800a53:	84 d2                	test   %dl,%dl
  800a55:	74 09                	je     800a60 <strchr+0x1a>
		if (*s == c)
  800a57:	38 ca                	cmp    %cl,%dl
  800a59:	74 0a                	je     800a65 <strchr+0x1f>
	for (; *s; s++)
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	eb f0                	jmp    800a50 <strchr+0xa>
			return (char *) s;
	return 0;
  800a60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a71:	eb 03                	jmp    800a76 <strfind+0xf>
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a79:	38 ca                	cmp    %cl,%dl
  800a7b:	74 04                	je     800a81 <strfind+0x1a>
  800a7d:	84 d2                	test   %dl,%dl
  800a7f:	75 f2                	jne    800a73 <strfind+0xc>
			break;
	return (char *) s;
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	57                   	push   %edi
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8f:	85 c9                	test   %ecx,%ecx
  800a91:	74 13                	je     800aa6 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a93:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a99:	75 05                	jne    800aa0 <memset+0x1d>
  800a9b:	f6 c1 03             	test   $0x3,%cl
  800a9e:	74 0d                	je     800aad <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa3:	fc                   	cld    
  800aa4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa6:	89 f8                	mov    %edi,%eax
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    
		c &= 0xFF;
  800aad:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab1:	89 d3                	mov    %edx,%ebx
  800ab3:	c1 e3 08             	shl    $0x8,%ebx
  800ab6:	89 d0                	mov    %edx,%eax
  800ab8:	c1 e0 18             	shl    $0x18,%eax
  800abb:	89 d6                	mov    %edx,%esi
  800abd:	c1 e6 10             	shl    $0x10,%esi
  800ac0:	09 f0                	or     %esi,%eax
  800ac2:	09 c2                	or     %eax,%edx
  800ac4:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ac6:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ac9:	89 d0                	mov    %edx,%eax
  800acb:	fc                   	cld    
  800acc:	f3 ab                	rep stos %eax,%es:(%edi)
  800ace:	eb d6                	jmp    800aa6 <memset+0x23>

00800ad0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ade:	39 c6                	cmp    %eax,%esi
  800ae0:	73 35                	jae    800b17 <memmove+0x47>
  800ae2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae5:	39 c2                	cmp    %eax,%edx
  800ae7:	76 2e                	jbe    800b17 <memmove+0x47>
		s += n;
		d += n;
  800ae9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aec:	89 d6                	mov    %edx,%esi
  800aee:	09 fe                	or     %edi,%esi
  800af0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af6:	74 0c                	je     800b04 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af8:	83 ef 01             	sub    $0x1,%edi
  800afb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800afe:	fd                   	std    
  800aff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b01:	fc                   	cld    
  800b02:	eb 21                	jmp    800b25 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b04:	f6 c1 03             	test   $0x3,%cl
  800b07:	75 ef                	jne    800af8 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b09:	83 ef 04             	sub    $0x4,%edi
  800b0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b12:	fd                   	std    
  800b13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b15:	eb ea                	jmp    800b01 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b17:	89 f2                	mov    %esi,%edx
  800b19:	09 c2                	or     %eax,%edx
  800b1b:	f6 c2 03             	test   $0x3,%dl
  800b1e:	74 09                	je     800b29 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b20:	89 c7                	mov    %eax,%edi
  800b22:	fc                   	cld    
  800b23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b29:	f6 c1 03             	test   $0x3,%cl
  800b2c:	75 f2                	jne    800b20 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	fc                   	cld    
  800b34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b36:	eb ed                	jmp    800b25 <memmove+0x55>

00800b38 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3b:	ff 75 10             	pushl  0x10(%ebp)
  800b3e:	ff 75 0c             	pushl  0xc(%ebp)
  800b41:	ff 75 08             	pushl  0x8(%ebp)
  800b44:	e8 87 ff ff ff       	call   800ad0 <memmove>
}
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b56:	89 c6                	mov    %eax,%esi
  800b58:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5b:	39 f0                	cmp    %esi,%eax
  800b5d:	74 1c                	je     800b7b <memcmp+0x30>
		if (*s1 != *s2)
  800b5f:	0f b6 08             	movzbl (%eax),%ecx
  800b62:	0f b6 1a             	movzbl (%edx),%ebx
  800b65:	38 d9                	cmp    %bl,%cl
  800b67:	75 08                	jne    800b71 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b69:	83 c0 01             	add    $0x1,%eax
  800b6c:	83 c2 01             	add    $0x1,%edx
  800b6f:	eb ea                	jmp    800b5b <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b71:	0f b6 c1             	movzbl %cl,%eax
  800b74:	0f b6 db             	movzbl %bl,%ebx
  800b77:	29 d8                	sub    %ebx,%eax
  800b79:	eb 05                	jmp    800b80 <memcmp+0x35>
	}

	return 0;
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5d                   	pop    %ebp
  800b83:	c3                   	ret    

00800b84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b8d:	89 c2                	mov    %eax,%edx
  800b8f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b92:	39 d0                	cmp    %edx,%eax
  800b94:	73 09                	jae    800b9f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b96:	38 08                	cmp    %cl,(%eax)
  800b98:	74 05                	je     800b9f <memfind+0x1b>
	for (; s < ends; s++)
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	eb f3                	jmp    800b92 <memfind+0xe>
			break;
	return (void *) s;
}
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800baa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bad:	eb 03                	jmp    800bb2 <strtol+0x11>
		s++;
  800baf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bb2:	0f b6 01             	movzbl (%ecx),%eax
  800bb5:	3c 20                	cmp    $0x20,%al
  800bb7:	74 f6                	je     800baf <strtol+0xe>
  800bb9:	3c 09                	cmp    $0x9,%al
  800bbb:	74 f2                	je     800baf <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bbd:	3c 2b                	cmp    $0x2b,%al
  800bbf:	74 2e                	je     800bef <strtol+0x4e>
	int neg = 0;
  800bc1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bc6:	3c 2d                	cmp    $0x2d,%al
  800bc8:	74 2f                	je     800bf9 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bca:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bd0:	75 05                	jne    800bd7 <strtol+0x36>
  800bd2:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd5:	74 2c                	je     800c03 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd7:	85 db                	test   %ebx,%ebx
  800bd9:	75 0a                	jne    800be5 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bdb:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800be0:	80 39 30             	cmpb   $0x30,(%ecx)
  800be3:	74 28                	je     800c0d <strtol+0x6c>
		base = 10;
  800be5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bea:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bed:	eb 50                	jmp    800c3f <strtol+0x9e>
		s++;
  800bef:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bf2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf7:	eb d1                	jmp    800bca <strtol+0x29>
		s++, neg = 1;
  800bf9:	83 c1 01             	add    $0x1,%ecx
  800bfc:	bf 01 00 00 00       	mov    $0x1,%edi
  800c01:	eb c7                	jmp    800bca <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c03:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c07:	74 0e                	je     800c17 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c09:	85 db                	test   %ebx,%ebx
  800c0b:	75 d8                	jne    800be5 <strtol+0x44>
		s++, base = 8;
  800c0d:	83 c1 01             	add    $0x1,%ecx
  800c10:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c15:	eb ce                	jmp    800be5 <strtol+0x44>
		s += 2, base = 16;
  800c17:	83 c1 02             	add    $0x2,%ecx
  800c1a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c1f:	eb c4                	jmp    800be5 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c21:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c24:	89 f3                	mov    %esi,%ebx
  800c26:	80 fb 19             	cmp    $0x19,%bl
  800c29:	77 29                	ja     800c54 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c2b:	0f be d2             	movsbl %dl,%edx
  800c2e:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c31:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c34:	7d 30                	jge    800c66 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c36:	83 c1 01             	add    $0x1,%ecx
  800c39:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c3d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c3f:	0f b6 11             	movzbl (%ecx),%edx
  800c42:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c45:	89 f3                	mov    %esi,%ebx
  800c47:	80 fb 09             	cmp    $0x9,%bl
  800c4a:	77 d5                	ja     800c21 <strtol+0x80>
			dig = *s - '0';
  800c4c:	0f be d2             	movsbl %dl,%edx
  800c4f:	83 ea 30             	sub    $0x30,%edx
  800c52:	eb dd                	jmp    800c31 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c54:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c57:	89 f3                	mov    %esi,%ebx
  800c59:	80 fb 19             	cmp    $0x19,%bl
  800c5c:	77 08                	ja     800c66 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c5e:	0f be d2             	movsbl %dl,%edx
  800c61:	83 ea 37             	sub    $0x37,%edx
  800c64:	eb cb                	jmp    800c31 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6a:	74 05                	je     800c71 <strtol+0xd0>
		*endptr = (char *) s;
  800c6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c6f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c71:	89 c2                	mov    %eax,%edx
  800c73:	f7 da                	neg    %edx
  800c75:	85 ff                	test   %edi,%edi
  800c77:	0f 45 c2             	cmovne %edx,%eax
}
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    
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
