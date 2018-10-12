
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
  80003d:	53                   	push   %ebx
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	e8 3b 00 00 00       	call   800081 <__x86.get_pc_thunk.bx>
  800046:	81 c3 ba 1f 00 00    	add    $0x1fba,%ebx
  80004c:	8b 45 08             	mov    0x8(%ebp),%eax
  80004f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800052:	c7 c1 2c 20 80 00    	mov    $0x80202c,%ecx
  800058:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 c0                	test   %eax,%eax
  800060:	7e 08                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800062:	8b 0a                	mov    (%edx),%ecx
  800064:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	52                   	push   %edx
  80006e:	50                   	push   %eax
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0c 00 00 00       	call   800085 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007f:	c9                   	leave  
  800080:	c3                   	ret    

00800081 <__x86.get_pc_thunk.bx>:
  800081:	8b 1c 24             	mov    (%esp),%ebx
  800084:	c3                   	ret    

00800085 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800085:	55                   	push   %ebp
  800086:	89 e5                	mov    %esp,%ebp
  800088:	53                   	push   %ebx
  800089:	83 ec 10             	sub    $0x10,%esp
  80008c:	e8 f0 ff ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  800091:	81 c3 6f 1f 00 00    	add    $0x1f6f,%ebx
	sys_env_destroy(0);
  800097:	6a 00                	push   $0x0
  800099:	e8 45 00 00 00       	call   8000e3 <sys_env_destroy>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 1c             	sub    $0x1c,%esp
  8000ec:	e8 66 00 00 00       	call   800157 <__x86.get_pc_thunk.ax>
  8000f1:	05 0f 1f 00 00       	add    $0x1f0f,%eax
  8000f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	b8 03 00 00 00       	mov    $0x3,%eax
  800106:	89 cb                	mov    %ecx,%ebx
  800108:	89 cf                	mov    %ecx,%edi
  80010a:	89 ce                	mov    %ecx,%esi
  80010c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	7f 08                	jg     80011a <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5f                   	pop    %edi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011a:	83 ec 0c             	sub    $0xc,%esp
  80011d:	50                   	push   %eax
  80011e:	6a 03                	push   $0x3
  800120:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800123:	8d 83 b6 ee ff ff    	lea    -0x114a(%ebx),%eax
  800129:	50                   	push   %eax
  80012a:	6a 23                	push   $0x23
  80012c:	8d 83 d3 ee ff ff    	lea    -0x112d(%ebx),%eax
  800132:	50                   	push   %eax
  800133:	e8 23 00 00 00       	call   80015b <_panic>

00800138 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	57                   	push   %edi
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013e:	ba 00 00 00 00       	mov    $0x0,%edx
  800143:	b8 02 00 00 00       	mov    $0x2,%eax
  800148:	89 d1                	mov    %edx,%ecx
  80014a:	89 d3                	mov    %edx,%ebx
  80014c:	89 d7                	mov    %edx,%edi
  80014e:	89 d6                	mov    %edx,%esi
  800150:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5f                   	pop    %edi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <__x86.get_pc_thunk.ax>:
  800157:	8b 04 24             	mov    (%esp),%eax
  80015a:	c3                   	ret    

0080015b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
  800164:	e8 18 ff ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  800169:	81 c3 97 1e 00 00    	add    $0x1e97,%ebx
	va_list ap;

	va_start(ap, fmt);
  80016f:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800172:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800178:	8b 38                	mov    (%eax),%edi
  80017a:	e8 b9 ff ff ff       	call   800138 <sys_getenvid>
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	ff 75 0c             	pushl  0xc(%ebp)
  800185:	ff 75 08             	pushl  0x8(%ebp)
  800188:	57                   	push   %edi
  800189:	50                   	push   %eax
  80018a:	8d 83 e4 ee ff ff    	lea    -0x111c(%ebx),%eax
  800190:	50                   	push   %eax
  800191:	e8 d1 00 00 00       	call   800267 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800196:	83 c4 18             	add    $0x18,%esp
  800199:	56                   	push   %esi
  80019a:	ff 75 10             	pushl  0x10(%ebp)
  80019d:	e8 63 00 00 00       	call   800205 <vcprintf>
	cprintf("\n");
  8001a2:	8d 83 08 ef ff ff    	lea    -0x10f8(%ebx),%eax
  8001a8:	89 04 24             	mov    %eax,(%esp)
  8001ab:	e8 b7 00 00 00       	call   800267 <cprintf>
  8001b0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b3:	cc                   	int3   
  8001b4:	eb fd                	jmp    8001b3 <_panic+0x58>

008001b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	e8 c1 fe ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  8001c0:	81 c3 40 1e 00 00    	add    $0x1e40,%ebx
  8001c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c9:	8b 16                	mov    (%esi),%edx
  8001cb:	8d 42 01             	lea    0x1(%edx),%eax
  8001ce:	89 06                	mov    %eax,(%esi)
  8001d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d3:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001dc:	74 0b                	je     8001e9 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001de:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	68 ff 00 00 00       	push   $0xff
  8001f1:	8d 46 08             	lea    0x8(%esi),%eax
  8001f4:	50                   	push   %eax
  8001f5:	e8 ac fe ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  8001fa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	eb d9                	jmp    8001de <putch+0x28>

00800205 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	53                   	push   %ebx
  800209:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80020f:	e8 6d fe ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  800214:	81 c3 ec 1d 00 00    	add    $0x1dec,%ebx
	struct printbuf b;

	b.idx = 0;
  80021a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800221:	00 00 00 
	b.cnt = 0;
  800224:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023a:	50                   	push   %eax
  80023b:	8d 83 b6 e1 ff ff    	lea    -0x1e4a(%ebx),%eax
  800241:	50                   	push   %eax
  800242:	e8 38 01 00 00       	call   80037f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800247:	83 c4 08             	add    $0x8,%esp
  80024a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800250:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800256:	50                   	push   %eax
  800257:	e8 4a fe ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  80025c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800270:	50                   	push   %eax
  800271:	ff 75 08             	pushl  0x8(%ebp)
  800274:	e8 8c ff ff ff       	call   800205 <vcprintf>
	va_end(ap);

	return cnt;
}
  800279:	c9                   	leave  
  80027a:	c3                   	ret    

0080027b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 2c             	sub    $0x2c,%esp
  800284:	e8 63 06 00 00       	call   8008ec <__x86.get_pc_thunk.cx>
  800289:	81 c1 77 1d 00 00    	add    $0x1d77,%ecx
  80028f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800292:	89 c7                	mov    %eax,%edi
  800294:	89 d6                	mov    %edx,%esi
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002aa:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002ad:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002b0:	39 d3                	cmp    %edx,%ebx
  8002b2:	72 09                	jb     8002bd <printnum+0x42>
  8002b4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002b7:	0f 87 83 00 00 00    	ja     800340 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	ff 75 18             	pushl  0x18(%ebp)
  8002c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002c9:	53                   	push   %ebx
  8002ca:	ff 75 10             	pushl  0x10(%ebp)
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8002dc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8002df:	e8 8c 09 00 00       	call   800c70 <__udivdi3>
  8002e4:	83 c4 18             	add    $0x18,%esp
  8002e7:	52                   	push   %edx
  8002e8:	50                   	push   %eax
  8002e9:	89 f2                	mov    %esi,%edx
  8002eb:	89 f8                	mov    %edi,%eax
  8002ed:	e8 89 ff ff ff       	call   80027b <printnum>
  8002f2:	83 c4 20             	add    $0x20,%esp
  8002f5:	eb 13                	jmp    80030a <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f7:	83 ec 08             	sub    $0x8,%esp
  8002fa:	56                   	push   %esi
  8002fb:	ff 75 18             	pushl  0x18(%ebp)
  8002fe:	ff d7                	call   *%edi
  800300:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800303:	83 eb 01             	sub    $0x1,%ebx
  800306:	85 db                	test   %ebx,%ebx
  800308:	7f ed                	jg     8002f7 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	56                   	push   %esi
  80030e:	83 ec 04             	sub    $0x4,%esp
  800311:	ff 75 dc             	pushl  -0x24(%ebp)
  800314:	ff 75 d8             	pushl  -0x28(%ebp)
  800317:	ff 75 d4             	pushl  -0x2c(%ebp)
  80031a:	ff 75 d0             	pushl  -0x30(%ebp)
  80031d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800320:	89 f3                	mov    %esi,%ebx
  800322:	e8 69 0a 00 00       	call   800d90 <__umoddi3>
  800327:	83 c4 14             	add    $0x14,%esp
  80032a:	0f be 84 06 0a ef ff 	movsbl -0x10f6(%esi,%eax,1),%eax
  800331:	ff 
  800332:	50                   	push   %eax
  800333:	ff d7                	call   *%edi
}
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    
  800340:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800343:	eb be                	jmp    800303 <printnum+0x88>

00800345 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80034b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034f:	8b 10                	mov    (%eax),%edx
  800351:	3b 50 04             	cmp    0x4(%eax),%edx
  800354:	73 0a                	jae    800360 <sprintputch+0x1b>
		*b->buf++ = ch;
  800356:	8d 4a 01             	lea    0x1(%edx),%ecx
  800359:	89 08                	mov    %ecx,(%eax)
  80035b:	8b 45 08             	mov    0x8(%ebp),%eax
  80035e:	88 02                	mov    %al,(%edx)
}
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    

00800362 <printfmt>:
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800368:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80036b:	50                   	push   %eax
  80036c:	ff 75 10             	pushl  0x10(%ebp)
  80036f:	ff 75 0c             	pushl  0xc(%ebp)
  800372:	ff 75 08             	pushl  0x8(%ebp)
  800375:	e8 05 00 00 00       	call   80037f <vprintfmt>
}
  80037a:	83 c4 10             	add    $0x10,%esp
  80037d:	c9                   	leave  
  80037e:	c3                   	ret    

0080037f <vprintfmt>:
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	57                   	push   %edi
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
  800385:	83 ec 2c             	sub    $0x2c,%esp
  800388:	e8 f4 fc ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  80038d:	81 c3 73 1c 00 00    	add    $0x1c73,%ebx
  800393:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  800396:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  80039d:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039f:	8d 77 01             	lea    0x1(%edi),%esi
  8003a2:	0f b6 07             	movzbl (%edi),%eax
  8003a5:	83 f8 25             	cmp    $0x25,%eax
  8003a8:	74 1c                	je     8003c6 <vprintfmt+0x47>
			if (ch == '\0')
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	0f 84 b9 04 00 00    	je     80086b <.L21+0x20>
			putch(ch, putdat);
  8003b2:	83 ec 08             	sub    $0x8,%esp
  8003b5:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003b8:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003bb:	50                   	push   %eax
  8003bc:	ff 55 08             	call   *0x8(%ebp)
  8003bf:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c2:	89 f7                	mov    %esi,%edi
  8003c4:	eb d9                	jmp    80039f <vprintfmt+0x20>
		padc = ' ';
  8003c6:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003ca:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003d1:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  8003d8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8d 7e 01             	lea    0x1(%esi),%edi
  8003ea:	0f b6 16             	movzbl (%esi),%edx
  8003ed:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f0:	3c 55                	cmp    $0x55,%al
  8003f2:	0f 87 53 04 00 00    	ja     80084b <.L21>
  8003f8:	0f b6 c0             	movzbl %al,%eax
  8003fb:	89 d9                	mov    %ebx,%ecx
  8003fd:	03 8c 83 98 ef ff ff 	add    -0x1068(%ebx,%eax,4),%ecx
  800404:	ff e1                	jmp    *%ecx

00800406 <.L73>:
  800406:	89 fe                	mov    %edi,%esi
			padc = '-';
  800408:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80040c:	eb d9                	jmp    8003e7 <vprintfmt+0x68>

0080040e <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	89 fe                	mov    %edi,%esi
			padc = '0';
  800410:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800414:	eb d1                	jmp    8003e7 <vprintfmt+0x68>

00800416 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800416:	0f b6 d2             	movzbl %dl,%edx
  800419:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  80041b:	b8 00 00 00 00       	mov    $0x0,%eax
  800420:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800423:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800426:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042a:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  80042d:	8d 7a d0             	lea    -0x30(%edx),%edi
  800430:	83 ff 09             	cmp    $0x9,%edi
  800433:	0f 87 94 00 00 00    	ja     8004cd <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800439:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80043c:	eb e5                	jmp    800423 <.L28+0xd>

0080043e <.L25>:
			precision = va_arg(ap, int);
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8b 00                	mov    (%eax),%eax
  800443:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	8d 40 04             	lea    0x4(%eax),%eax
  80044c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800451:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800455:	79 90                	jns    8003e7 <vprintfmt+0x68>
				width = precision, precision = -1;
  800457:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80045a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800464:	eb 81                	jmp    8003e7 <vprintfmt+0x68>

00800466 <.L26>:
  800466:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800469:	85 c0                	test   %eax,%eax
  80046b:	ba 00 00 00 00       	mov    $0x0,%edx
  800470:	0f 49 d0             	cmovns %eax,%edx
  800473:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800476:	89 fe                	mov    %edi,%esi
  800478:	e9 6a ff ff ff       	jmp    8003e7 <vprintfmt+0x68>

0080047d <.L22>:
  80047d:	89 fe                	mov    %edi,%esi
			altflag = 1;
  80047f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800486:	e9 5c ff ff ff       	jmp    8003e7 <vprintfmt+0x68>

0080048b <.L33>:
  80048b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80048e:	83 f9 01             	cmp    $0x1,%ecx
  800491:	7e 16                	jle    8004a9 <.L33+0x1e>
		return va_arg(*ap, long long);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8b 00                	mov    (%eax),%eax
  800498:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80049b:	8d 49 08             	lea    0x8(%ecx),%ecx
  80049e:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004a4:	e9 f6 fe ff ff       	jmp    80039f <vprintfmt+0x20>
	else if (lflag)
  8004a9:	85 c9                	test   %ecx,%ecx
  8004ab:	75 10                	jne    8004bd <.L33+0x32>
		return va_arg(*ap, int);
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8b 00                	mov    (%eax),%eax
  8004b2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004b5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004b8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004bb:	eb e4                	jmp    8004a1 <.L33+0x16>
		return va_arg(*ap, long);
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8b 00                	mov    (%eax),%eax
  8004c2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004c5:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004c8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004cb:	eb d4                	jmp    8004a1 <.L33+0x16>
  8004cd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004d0:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004d3:	e9 79 ff ff ff       	jmp    800451 <.L25+0x13>

008004d8 <.L32>:
			lflag++;
  8004d8:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	89 fe                	mov    %edi,%esi
			goto reswitch;
  8004de:	e9 04 ff ff ff       	jmp    8003e7 <vprintfmt+0x68>

008004e3 <.L29>:
			putch(va_arg(ap, int), putdat);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 70 04             	lea    0x4(%eax),%esi
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	ff 75 0c             	pushl  0xc(%ebp)
  8004ef:	ff 30                	pushl  (%eax)
  8004f1:	ff 55 08             	call   *0x8(%ebp)
			break;
  8004f4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004f7:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  8004fa:	e9 a0 fe ff ff       	jmp    80039f <vprintfmt+0x20>

008004ff <.L31>:
			err = va_arg(ap, int);
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 70 04             	lea    0x4(%eax),%esi
  800505:	8b 00                	mov    (%eax),%eax
  800507:	99                   	cltd   
  800508:	31 d0                	xor    %edx,%eax
  80050a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050c:	83 f8 06             	cmp    $0x6,%eax
  80050f:	7f 29                	jg     80053a <.L31+0x3b>
  800511:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  800518:	85 d2                	test   %edx,%edx
  80051a:	74 1e                	je     80053a <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  80051c:	52                   	push   %edx
  80051d:	8d 83 2b ef ff ff    	lea    -0x10d5(%ebx),%eax
  800523:	50                   	push   %eax
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 33 fe ff ff       	call   800362 <printfmt>
  80052f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800532:	89 75 14             	mov    %esi,0x14(%ebp)
  800535:	e9 65 fe ff ff       	jmp    80039f <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  80053a:	50                   	push   %eax
  80053b:	8d 83 22 ef ff ff    	lea    -0x10de(%ebx),%eax
  800541:	50                   	push   %eax
  800542:	ff 75 0c             	pushl  0xc(%ebp)
  800545:	ff 75 08             	pushl  0x8(%ebp)
  800548:	e8 15 fe ff ff       	call   800362 <printfmt>
  80054d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800550:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800553:	e9 47 fe ff ff       	jmp    80039f <vprintfmt+0x20>

00800558 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	83 c0 04             	add    $0x4,%eax
  80055e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800566:	85 f6                	test   %esi,%esi
  800568:	8d 83 1b ef ff ff    	lea    -0x10e5(%ebx),%eax
  80056e:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  800571:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800575:	0f 8e b4 00 00 00    	jle    80062f <.L36+0xd7>
  80057b:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  80057f:	75 08                	jne    800589 <.L36+0x31>
  800581:	89 7d 10             	mov    %edi,0x10(%ebp)
  800584:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800587:	eb 6c                	jmp    8005f5 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	ff 75 cc             	pushl  -0x34(%ebp)
  80058f:	56                   	push   %esi
  800590:	e8 73 03 00 00       	call   800908 <strnlen>
  800595:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800598:	29 c2                	sub    %eax,%edx
  80059a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80059d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005a0:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005a4:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005a7:	89 d6                	mov    %edx,%esi
  8005a9:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005ac:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ae:	eb 10                	jmp    8005c0 <.L36+0x68>
					putch(padc, putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	ff 75 0c             	pushl  0xc(%ebp)
  8005b6:	57                   	push   %edi
  8005b7:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ba:	83 ee 01             	sub    $0x1,%esi
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	85 f6                	test   %esi,%esi
  8005c2:	7f ec                	jg     8005b0 <.L36+0x58>
  8005c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ca:	85 d2                	test   %edx,%edx
  8005cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d1:	0f 49 c2             	cmovns %edx,%eax
  8005d4:	29 c2                	sub    %eax,%edx
  8005d6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005d9:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005dc:	eb 17                	jmp    8005f5 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  8005de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e2:	75 30                	jne    800614 <.L36+0xbc>
					putch(ch, putdat);
  8005e4:	83 ec 08             	sub    $0x8,%esp
  8005e7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ea:	50                   	push   %eax
  8005eb:	ff 55 08             	call   *0x8(%ebp)
  8005ee:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f1:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005f5:	83 c6 01             	add    $0x1,%esi
  8005f8:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  8005fc:	0f be c2             	movsbl %dl,%eax
  8005ff:	85 c0                	test   %eax,%eax
  800601:	74 58                	je     80065b <.L36+0x103>
  800603:	85 ff                	test   %edi,%edi
  800605:	78 d7                	js     8005de <.L36+0x86>
  800607:	83 ef 01             	sub    $0x1,%edi
  80060a:	79 d2                	jns    8005de <.L36+0x86>
  80060c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800612:	eb 32                	jmp    800646 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800614:	0f be d2             	movsbl %dl,%edx
  800617:	83 ea 20             	sub    $0x20,%edx
  80061a:	83 fa 5e             	cmp    $0x5e,%edx
  80061d:	76 c5                	jbe    8005e4 <.L36+0x8c>
					putch('?', putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	ff 75 0c             	pushl  0xc(%ebp)
  800625:	6a 3f                	push   $0x3f
  800627:	ff 55 08             	call   *0x8(%ebp)
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	eb c2                	jmp    8005f1 <.L36+0x99>
  80062f:	89 7d 10             	mov    %edi,0x10(%ebp)
  800632:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800635:	eb be                	jmp    8005f5 <.L36+0x9d>
				putch(' ', putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	57                   	push   %edi
  80063b:	6a 20                	push   $0x20
  80063d:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800640:	83 ee 01             	sub    $0x1,%esi
  800643:	83 c4 10             	add    $0x10,%esp
  800646:	85 f6                	test   %esi,%esi
  800648:	7f ed                	jg     800637 <.L36+0xdf>
  80064a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80064d:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800650:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800653:	89 45 14             	mov    %eax,0x14(%ebp)
  800656:	e9 44 fd ff ff       	jmp    80039f <vprintfmt+0x20>
  80065b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80065e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800661:	eb e3                	jmp    800646 <.L36+0xee>

00800663 <.L30>:
  800663:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800666:	83 f9 01             	cmp    $0x1,%ecx
  800669:	7e 42                	jle    8006ad <.L30+0x4a>
		return va_arg(*ap, long long);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 50 04             	mov    0x4(%eax),%edx
  800671:	8b 00                	mov    (%eax),%eax
  800673:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800676:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8d 40 08             	lea    0x8(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800682:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800686:	79 5f                	jns    8006e7 <.L30+0x84>
				putch('-', putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	ff 75 0c             	pushl  0xc(%ebp)
  80068e:	6a 2d                	push   $0x2d
  800690:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800693:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800696:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800699:	f7 da                	neg    %edx
  80069b:	83 d1 00             	adc    $0x0,%ecx
  80069e:	f7 d9                	neg    %ecx
  8006a0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a8:	e9 b8 00 00 00       	jmp    800765 <.L34+0x22>
	else if (lflag)
  8006ad:	85 c9                	test   %ecx,%ecx
  8006af:	75 1b                	jne    8006cc <.L30+0x69>
		return va_arg(*ap, int);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 30                	mov    (%eax),%esi
  8006b6:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006b9:	89 f0                	mov    %esi,%eax
  8006bb:	c1 f8 1f             	sar    $0x1f,%eax
  8006be:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 40 04             	lea    0x4(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8006ca:	eb b6                	jmp    800682 <.L30+0x1f>
		return va_arg(*ap, long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8b 30                	mov    (%eax),%esi
  8006d1:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006d4:	89 f0                	mov    %esi,%eax
  8006d6:	c1 f8 1f             	sar    $0x1f,%eax
  8006d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 40 04             	lea    0x4(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e5:	eb 9b                	jmp    800682 <.L30+0x1f>
			num = getint(&ap, lflag);
  8006e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ea:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f2:	eb 71                	jmp    800765 <.L34+0x22>

008006f4 <.L37>:
  8006f4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8006f7:	83 f9 01             	cmp    $0x1,%ecx
  8006fa:	7e 15                	jle    800711 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	8b 48 04             	mov    0x4(%eax),%ecx
  800704:	8d 40 08             	lea    0x8(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070f:	eb 54                	jmp    800765 <.L34+0x22>
	else if (lflag)
  800711:	85 c9                	test   %ecx,%ecx
  800713:	75 17                	jne    80072c <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8b 10                	mov    (%eax),%edx
  80071a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071f:	8d 40 04             	lea    0x4(%eax),%eax
  800722:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800725:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072a:	eb 39                	jmp    800765 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 10                	mov    (%eax),%edx
  800731:	b9 00 00 00 00       	mov    $0x0,%ecx
  800736:	8d 40 04             	lea    0x4(%eax),%eax
  800739:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800741:	eb 22                	jmp    800765 <.L34+0x22>

00800743 <.L34>:
  800743:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800746:	83 f9 01             	cmp    $0x1,%ecx
  800749:	7e 3b                	jle    800786 <.L34+0x43>
		return va_arg(*ap, long long);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8b 50 04             	mov    0x4(%eax),%edx
  800751:	8b 00                	mov    (%eax),%eax
  800753:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800756:	8d 49 08             	lea    0x8(%ecx),%ecx
  800759:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80075c:	89 d1                	mov    %edx,%ecx
  80075e:	89 c2                	mov    %eax,%edx
			base = 8;
  800760:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800765:	83 ec 0c             	sub    $0xc,%esp
  800768:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  80076c:	56                   	push   %esi
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	50                   	push   %eax
  800771:	51                   	push   %ecx
  800772:	52                   	push   %edx
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	e8 fd fa ff ff       	call   80027b <printnum>
			break;
  80077e:	83 c4 20             	add    $0x20,%esp
  800781:	e9 19 fc ff ff       	jmp    80039f <vprintfmt+0x20>
	else if (lflag)
  800786:	85 c9                	test   %ecx,%ecx
  800788:	75 13                	jne    80079d <.L34+0x5a>
		return va_arg(*ap, int);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8b 10                	mov    (%eax),%edx
  80078f:	89 d0                	mov    %edx,%eax
  800791:	99                   	cltd   
  800792:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800795:	8d 49 04             	lea    0x4(%ecx),%ecx
  800798:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80079b:	eb bf                	jmp    80075c <.L34+0x19>
		return va_arg(*ap, long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 10                	mov    (%eax),%edx
  8007a2:	89 d0                	mov    %edx,%eax
  8007a4:	99                   	cltd   
  8007a5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007a8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007ab:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007ae:	eb ac                	jmp    80075c <.L34+0x19>

008007b0 <.L35>:
			putch('0', putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	6a 30                	push   $0x30
  8007b8:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	ff 75 0c             	pushl  0xc(%ebp)
  8007c1:	6a 78                	push   $0x78
  8007c3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8b 10                	mov    (%eax),%edx
  8007cb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007d0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007d3:	8d 40 04             	lea    0x4(%eax),%eax
  8007d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007de:	eb 85                	jmp    800765 <.L34+0x22>

008007e0 <.L38>:
  8007e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8007e3:	83 f9 01             	cmp    $0x1,%ecx
  8007e6:	7e 18                	jle    800800 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f0:	8d 40 08             	lea    0x8(%eax),%eax
  8007f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007fb:	e9 65 ff ff ff       	jmp    800765 <.L34+0x22>
	else if (lflag)
  800800:	85 c9                	test   %ecx,%ecx
  800802:	75 1a                	jne    80081e <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800804:	8b 45 14             	mov    0x14(%ebp),%eax
  800807:	8b 10                	mov    (%eax),%edx
  800809:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080e:	8d 40 04             	lea    0x4(%eax),%eax
  800811:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800814:	b8 10 00 00 00       	mov    $0x10,%eax
  800819:	e9 47 ff ff ff       	jmp    800765 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8b 10                	mov    (%eax),%edx
  800823:	b9 00 00 00 00       	mov    $0x0,%ecx
  800828:	8d 40 04             	lea    0x4(%eax),%eax
  80082b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082e:	b8 10 00 00 00       	mov    $0x10,%eax
  800833:	e9 2d ff ff ff       	jmp    800765 <.L34+0x22>

00800838 <.L24>:
			putch(ch, putdat);
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	ff 75 0c             	pushl  0xc(%ebp)
  80083e:	6a 25                	push   $0x25
  800840:	ff 55 08             	call   *0x8(%ebp)
			break;
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	e9 54 fb ff ff       	jmp    80039f <vprintfmt+0x20>

0080084b <.L21>:
			putch('%', putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	6a 25                	push   $0x25
  800853:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	89 f7                	mov    %esi,%edi
  80085b:	eb 03                	jmp    800860 <.L21+0x15>
  80085d:	83 ef 01             	sub    $0x1,%edi
  800860:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800864:	75 f7                	jne    80085d <.L21+0x12>
  800866:	e9 34 fb ff ff       	jmp    80039f <vprintfmt+0x20>
}
  80086b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5f                   	pop    %edi
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	83 ec 14             	sub    $0x14,%esp
  80087a:	e8 02 f8 ff ff       	call   800081 <__x86.get_pc_thunk.bx>
  80087f:	81 c3 81 17 00 00    	add    $0x1781,%ebx
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800892:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800895:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80089c:	85 c0                	test   %eax,%eax
  80089e:	74 2b                	je     8008cb <vsnprintf+0x58>
  8008a0:	85 d2                	test   %edx,%edx
  8008a2:	7e 27                	jle    8008cb <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a4:	ff 75 14             	pushl  0x14(%ebp)
  8008a7:	ff 75 10             	pushl  0x10(%ebp)
  8008aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ad:	50                   	push   %eax
  8008ae:	8d 83 45 e3 ff ff    	lea    -0x1cbb(%ebx),%eax
  8008b4:	50                   	push   %eax
  8008b5:	e8 c5 fa ff ff       	call   80037f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c3:	83 c4 10             	add    $0x10,%esp
}
  8008c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c9:	c9                   	leave  
  8008ca:	c3                   	ret    
		return -E_INVAL;
  8008cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d0:	eb f4                	jmp    8008c6 <vsnprintf+0x53>

008008d2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008db:	50                   	push   %eax
  8008dc:	ff 75 10             	pushl  0x10(%ebp)
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	ff 75 08             	pushl  0x8(%ebp)
  8008e5:	e8 89 ff ff ff       	call   800873 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <__x86.get_pc_thunk.cx>:
  8008ec:	8b 0c 24             	mov    (%esp),%ecx
  8008ef:	c3                   	ret    

008008f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fb:	eb 03                	jmp    800900 <strlen+0x10>
		n++;
  8008fd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800900:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800904:	75 f7                	jne    8008fd <strlen+0xd>
	return n;
}
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
  800916:	eb 03                	jmp    80091b <strnlen+0x13>
		n++;
  800918:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091b:	39 d0                	cmp    %edx,%eax
  80091d:	74 06                	je     800925 <strnlen+0x1d>
  80091f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800923:	75 f3                	jne    800918 <strnlen+0x10>
	return n;
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800931:	89 c2                	mov    %eax,%edx
  800933:	83 c1 01             	add    $0x1,%ecx
  800936:	83 c2 01             	add    $0x1,%edx
  800939:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80093d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800940:	84 db                	test   %bl,%bl
  800942:	75 ef                	jne    800933 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800944:	5b                   	pop    %ebx
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	53                   	push   %ebx
  80094b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80094e:	53                   	push   %ebx
  80094f:	e8 9c ff ff ff       	call   8008f0 <strlen>
  800954:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800957:	ff 75 0c             	pushl  0xc(%ebp)
  80095a:	01 d8                	add    %ebx,%eax
  80095c:	50                   	push   %eax
  80095d:	e8 c5 ff ff ff       	call   800927 <strcpy>
	return dst;
}
  800962:	89 d8                	mov    %ebx,%eax
  800964:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	56                   	push   %esi
  80096d:	53                   	push   %ebx
  80096e:	8b 75 08             	mov    0x8(%ebp),%esi
  800971:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800974:	89 f3                	mov    %esi,%ebx
  800976:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800979:	89 f2                	mov    %esi,%edx
  80097b:	eb 0f                	jmp    80098c <strncpy+0x23>
		*dst++ = *src;
  80097d:	83 c2 01             	add    $0x1,%edx
  800980:	0f b6 01             	movzbl (%ecx),%eax
  800983:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800986:	80 39 01             	cmpb   $0x1,(%ecx)
  800989:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80098c:	39 da                	cmp    %ebx,%edx
  80098e:	75 ed                	jne    80097d <strncpy+0x14>
	}
	return ret;
}
  800990:	89 f0                	mov    %esi,%eax
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 75 08             	mov    0x8(%ebp),%esi
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009a4:	89 f0                	mov    %esi,%eax
  8009a6:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009aa:	85 c9                	test   %ecx,%ecx
  8009ac:	75 0b                	jne    8009b9 <strlcpy+0x23>
  8009ae:	eb 17                	jmp    8009c7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b0:	83 c2 01             	add    $0x1,%edx
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009b9:	39 d8                	cmp    %ebx,%eax
  8009bb:	74 07                	je     8009c4 <strlcpy+0x2e>
  8009bd:	0f b6 0a             	movzbl (%edx),%ecx
  8009c0:	84 c9                	test   %cl,%cl
  8009c2:	75 ec                	jne    8009b0 <strlcpy+0x1a>
		*dst = '\0';
  8009c4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c7:	29 f0                	sub    %esi,%eax
}
  8009c9:	5b                   	pop    %ebx
  8009ca:	5e                   	pop    %esi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d6:	eb 06                	jmp    8009de <strcmp+0x11>
		p++, q++;
  8009d8:	83 c1 01             	add    $0x1,%ecx
  8009db:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009de:	0f b6 01             	movzbl (%ecx),%eax
  8009e1:	84 c0                	test   %al,%al
  8009e3:	74 04                	je     8009e9 <strcmp+0x1c>
  8009e5:	3a 02                	cmp    (%edx),%al
  8009e7:	74 ef                	je     8009d8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e9:	0f b6 c0             	movzbl %al,%eax
  8009ec:	0f b6 12             	movzbl (%edx),%edx
  8009ef:	29 d0                	sub    %edx,%eax
}
  8009f1:	5d                   	pop    %ebp
  8009f2:	c3                   	ret    

008009f3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	53                   	push   %ebx
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fd:	89 c3                	mov    %eax,%ebx
  8009ff:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a02:	eb 06                	jmp    800a0a <strncmp+0x17>
		n--, p++, q++;
  800a04:	83 c0 01             	add    $0x1,%eax
  800a07:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a0a:	39 d8                	cmp    %ebx,%eax
  800a0c:	74 16                	je     800a24 <strncmp+0x31>
  800a0e:	0f b6 08             	movzbl (%eax),%ecx
  800a11:	84 c9                	test   %cl,%cl
  800a13:	74 04                	je     800a19 <strncmp+0x26>
  800a15:	3a 0a                	cmp    (%edx),%cl
  800a17:	74 eb                	je     800a04 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a19:	0f b6 00             	movzbl (%eax),%eax
  800a1c:	0f b6 12             	movzbl (%edx),%edx
  800a1f:	29 d0                	sub    %edx,%eax
}
  800a21:	5b                   	pop    %ebx
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    
		return 0;
  800a24:	b8 00 00 00 00       	mov    $0x0,%eax
  800a29:	eb f6                	jmp    800a21 <strncmp+0x2e>

00800a2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a35:	0f b6 10             	movzbl (%eax),%edx
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	74 09                	je     800a45 <strchr+0x1a>
		if (*s == c)
  800a3c:	38 ca                	cmp    %cl,%dl
  800a3e:	74 0a                	je     800a4a <strchr+0x1f>
	for (; *s; s++)
  800a40:	83 c0 01             	add    $0x1,%eax
  800a43:	eb f0                	jmp    800a35 <strchr+0xa>
			return (char *) s;
	return 0;
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a56:	eb 03                	jmp    800a5b <strfind+0xf>
  800a58:	83 c0 01             	add    $0x1,%eax
  800a5b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5e:	38 ca                	cmp    %cl,%dl
  800a60:	74 04                	je     800a66 <strfind+0x1a>
  800a62:	84 d2                	test   %dl,%dl
  800a64:	75 f2                	jne    800a58 <strfind+0xc>
			break;
	return (char *) s;
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a71:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a74:	85 c9                	test   %ecx,%ecx
  800a76:	74 13                	je     800a8b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a78:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7e:	75 05                	jne    800a85 <memset+0x1d>
  800a80:	f6 c1 03             	test   $0x3,%cl
  800a83:	74 0d                	je     800a92 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a88:	fc                   	cld    
  800a89:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8b:	89 f8                	mov    %edi,%eax
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    
		c &= 0xFF;
  800a92:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a96:	89 d3                	mov    %edx,%ebx
  800a98:	c1 e3 08             	shl    $0x8,%ebx
  800a9b:	89 d0                	mov    %edx,%eax
  800a9d:	c1 e0 18             	shl    $0x18,%eax
  800aa0:	89 d6                	mov    %edx,%esi
  800aa2:	c1 e6 10             	shl    $0x10,%esi
  800aa5:	09 f0                	or     %esi,%eax
  800aa7:	09 c2                	or     %eax,%edx
  800aa9:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800aab:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800aae:	89 d0                	mov    %edx,%eax
  800ab0:	fc                   	cld    
  800ab1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab3:	eb d6                	jmp    800a8b <memset+0x23>

00800ab5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac3:	39 c6                	cmp    %eax,%esi
  800ac5:	73 35                	jae    800afc <memmove+0x47>
  800ac7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aca:	39 c2                	cmp    %eax,%edx
  800acc:	76 2e                	jbe    800afc <memmove+0x47>
		s += n;
		d += n;
  800ace:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad1:	89 d6                	mov    %edx,%esi
  800ad3:	09 fe                	or     %edi,%esi
  800ad5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800adb:	74 0c                	je     800ae9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800add:	83 ef 01             	sub    $0x1,%edi
  800ae0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae3:	fd                   	std    
  800ae4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae6:	fc                   	cld    
  800ae7:	eb 21                	jmp    800b0a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae9:	f6 c1 03             	test   $0x3,%cl
  800aec:	75 ef                	jne    800add <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aee:	83 ef 04             	sub    $0x4,%edi
  800af1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800af7:	fd                   	std    
  800af8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afa:	eb ea                	jmp    800ae6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afc:	89 f2                	mov    %esi,%edx
  800afe:	09 c2                	or     %eax,%edx
  800b00:	f6 c2 03             	test   $0x3,%dl
  800b03:	74 09                	je     800b0e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	fc                   	cld    
  800b08:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0e:	f6 c1 03             	test   $0x3,%cl
  800b11:	75 f2                	jne    800b05 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b13:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b16:	89 c7                	mov    %eax,%edi
  800b18:	fc                   	cld    
  800b19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1b:	eb ed                	jmp    800b0a <memmove+0x55>

00800b1d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b20:	ff 75 10             	pushl  0x10(%ebp)
  800b23:	ff 75 0c             	pushl  0xc(%ebp)
  800b26:	ff 75 08             	pushl  0x8(%ebp)
  800b29:	e8 87 ff ff ff       	call   800ab5 <memmove>
}
  800b2e:	c9                   	leave  
  800b2f:	c3                   	ret    

00800b30 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3b:	89 c6                	mov    %eax,%esi
  800b3d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b40:	39 f0                	cmp    %esi,%eax
  800b42:	74 1c                	je     800b60 <memcmp+0x30>
		if (*s1 != *s2)
  800b44:	0f b6 08             	movzbl (%eax),%ecx
  800b47:	0f b6 1a             	movzbl (%edx),%ebx
  800b4a:	38 d9                	cmp    %bl,%cl
  800b4c:	75 08                	jne    800b56 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b4e:	83 c0 01             	add    $0x1,%eax
  800b51:	83 c2 01             	add    $0x1,%edx
  800b54:	eb ea                	jmp    800b40 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b56:	0f b6 c1             	movzbl %cl,%eax
  800b59:	0f b6 db             	movzbl %bl,%ebx
  800b5c:	29 d8                	sub    %ebx,%eax
  800b5e:	eb 05                	jmp    800b65 <memcmp+0x35>
	}

	return 0;
  800b60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b72:	89 c2                	mov    %eax,%edx
  800b74:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b77:	39 d0                	cmp    %edx,%eax
  800b79:	73 09                	jae    800b84 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b7b:	38 08                	cmp    %cl,(%eax)
  800b7d:	74 05                	je     800b84 <memfind+0x1b>
	for (; s < ends; s++)
  800b7f:	83 c0 01             	add    $0x1,%eax
  800b82:	eb f3                	jmp    800b77 <memfind+0xe>
			break;
	return (void *) s;
}
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b92:	eb 03                	jmp    800b97 <strtol+0x11>
		s++;
  800b94:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b97:	0f b6 01             	movzbl (%ecx),%eax
  800b9a:	3c 20                	cmp    $0x20,%al
  800b9c:	74 f6                	je     800b94 <strtol+0xe>
  800b9e:	3c 09                	cmp    $0x9,%al
  800ba0:	74 f2                	je     800b94 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ba2:	3c 2b                	cmp    $0x2b,%al
  800ba4:	74 2e                	je     800bd4 <strtol+0x4e>
	int neg = 0;
  800ba6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bab:	3c 2d                	cmp    $0x2d,%al
  800bad:	74 2f                	je     800bde <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800baf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bb5:	75 05                	jne    800bbc <strtol+0x36>
  800bb7:	80 39 30             	cmpb   $0x30,(%ecx)
  800bba:	74 2c                	je     800be8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbc:	85 db                	test   %ebx,%ebx
  800bbe:	75 0a                	jne    800bca <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bc5:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc8:	74 28                	je     800bf2 <strtol+0x6c>
		base = 10;
  800bca:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd2:	eb 50                	jmp    800c24 <strtol+0x9e>
		s++;
  800bd4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bd7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bdc:	eb d1                	jmp    800baf <strtol+0x29>
		s++, neg = 1;
  800bde:	83 c1 01             	add    $0x1,%ecx
  800be1:	bf 01 00 00 00       	mov    $0x1,%edi
  800be6:	eb c7                	jmp    800baf <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bec:	74 0e                	je     800bfc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bee:	85 db                	test   %ebx,%ebx
  800bf0:	75 d8                	jne    800bca <strtol+0x44>
		s++, base = 8;
  800bf2:	83 c1 01             	add    $0x1,%ecx
  800bf5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bfa:	eb ce                	jmp    800bca <strtol+0x44>
		s += 2, base = 16;
  800bfc:	83 c1 02             	add    $0x2,%ecx
  800bff:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c04:	eb c4                	jmp    800bca <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c06:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c09:	89 f3                	mov    %esi,%ebx
  800c0b:	80 fb 19             	cmp    $0x19,%bl
  800c0e:	77 29                	ja     800c39 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c10:	0f be d2             	movsbl %dl,%edx
  800c13:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c16:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c19:	7d 30                	jge    800c4b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c1b:	83 c1 01             	add    $0x1,%ecx
  800c1e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c22:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c24:	0f b6 11             	movzbl (%ecx),%edx
  800c27:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c2a:	89 f3                	mov    %esi,%ebx
  800c2c:	80 fb 09             	cmp    $0x9,%bl
  800c2f:	77 d5                	ja     800c06 <strtol+0x80>
			dig = *s - '0';
  800c31:	0f be d2             	movsbl %dl,%edx
  800c34:	83 ea 30             	sub    $0x30,%edx
  800c37:	eb dd                	jmp    800c16 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c39:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c3c:	89 f3                	mov    %esi,%ebx
  800c3e:	80 fb 19             	cmp    $0x19,%bl
  800c41:	77 08                	ja     800c4b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c43:	0f be d2             	movsbl %dl,%edx
  800c46:	83 ea 37             	sub    $0x37,%edx
  800c49:	eb cb                	jmp    800c16 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c4f:	74 05                	je     800c56 <strtol+0xd0>
		*endptr = (char *) s;
  800c51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c54:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c56:	89 c2                	mov    %eax,%edx
  800c58:	f7 da                	neg    %edx
  800c5a:	85 ff                	test   %edi,%edi
  800c5c:	0f 45 c2             	cmovne %edx,%eax
}
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    
  800c64:	66 90                	xchg   %ax,%ax
  800c66:	66 90                	xchg   %ax,%ax
  800c68:	66 90                	xchg   %ax,%ax
  800c6a:	66 90                	xchg   %ax,%ax
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
