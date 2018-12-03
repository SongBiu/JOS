
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
  800050:	e8 8b 00 00 00       	call   8000e0 <sys_cputs>
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
  800064:	57                   	push   %edi
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	83 ec 0c             	sub    $0xc,%esp
  80006a:	e8 ee ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80006f:	81 c3 91 1f 00 00    	add    $0x1f91,%ebx
  800075:	8b 75 08             	mov    0x8(%ebp),%esi
  800078:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80007b:	e8 f2 00 00 00       	call   800172 <sys_getenvid>
  800080:	25 ff 03 00 00       	and    $0x3ff,%eax
  800085:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800088:	c1 e0 05             	shl    $0x5,%eax
  80008b:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  800091:	c7 c2 30 20 80 00    	mov    $0x802030,%edx
  800097:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	85 f6                	test   %esi,%esi
  80009b:	7e 08                	jle    8000a5 <libmain+0x44>
		binaryname = argv[0];
  80009d:	8b 07                	mov    (%edi),%eax
  80009f:	89 83 10 00 00 00    	mov    %eax,0x10(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a5:	83 ec 08             	sub    $0x8,%esp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	e8 84 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000af:	e8 0b 00 00 00       	call   8000bf <exit>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	53                   	push   %ebx
  8000c3:	83 ec 10             	sub    $0x10,%esp
  8000c6:	e8 92 ff ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8000cb:	81 c3 35 1f 00 00    	add    $0x1f35,%ebx
	sys_env_destroy(0);
  8000d1:	6a 00                	push   $0x0
  8000d3:	e8 45 00 00 00       	call   80011d <sys_env_destroy>
}
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f1:	89 c3                	mov    %eax,%ebx
  8000f3:	89 c7                	mov    %eax,%edi
  8000f5:	89 c6                	mov    %eax,%esi
  8000f7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	57                   	push   %edi
  800102:	56                   	push   %esi
  800103:	53                   	push   %ebx
	asm volatile("int %1\n"
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
  800109:	b8 01 00 00 00       	mov    $0x1,%eax
  80010e:	89 d1                	mov    %edx,%ecx
  800110:	89 d3                	mov    %edx,%ebx
  800112:	89 d7                	mov    %edx,%edi
  800114:	89 d6                	mov    %edx,%esi
  800116:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
  800123:	83 ec 1c             	sub    $0x1c,%esp
  800126:	e8 66 00 00 00       	call   800191 <__x86.get_pc_thunk.ax>
  80012b:	05 d5 1e 00 00       	add    $0x1ed5,%eax
  800130:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800133:	b9 00 00 00 00       	mov    $0x0,%ecx
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	b8 03 00 00 00       	mov    $0x3,%eax
  800140:	89 cb                	mov    %ecx,%ebx
  800142:	89 cf                	mov    %ecx,%edi
  800144:	89 ce                	mov    %ecx,%esi
  800146:	cd 30                	int    $0x30
	if(check && ret > 0)
  800148:	85 c0                	test   %eax,%eax
  80014a:	7f 08                	jg     800154 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5f                   	pop    %edi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	50                   	push   %eax
  800158:	6a 03                	push   $0x3
  80015a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80015d:	8d 83 f4 ee ff ff    	lea    -0x110c(%ebx),%eax
  800163:	50                   	push   %eax
  800164:	6a 26                	push   $0x26
  800166:	8d 83 11 ef ff ff    	lea    -0x10ef(%ebx),%eax
  80016c:	50                   	push   %eax
  80016d:	e8 23 00 00 00       	call   800195 <_panic>

00800172 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
	asm volatile("int %1\n"
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 02 00 00 00       	mov    $0x2,%eax
  800182:	89 d1                	mov    %edx,%ecx
  800184:	89 d3                	mov    %edx,%ebx
  800186:	89 d7                	mov    %edx,%edi
  800188:	89 d6                	mov    %edx,%esi
  80018a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <__x86.get_pc_thunk.ax>:
  800191:	8b 04 24             	mov    (%esp),%eax
  800194:	c3                   	ret    

00800195 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	e8 ba fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001a3:	81 c3 5d 1e 00 00    	add    $0x1e5d,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001a9:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ac:	c7 c0 10 20 80 00    	mov    $0x802010,%eax
  8001b2:	8b 38                	mov    (%eax),%edi
  8001b4:	e8 b9 ff ff ff       	call   800172 <sys_getenvid>
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	ff 75 0c             	pushl  0xc(%ebp)
  8001bf:	ff 75 08             	pushl  0x8(%ebp)
  8001c2:	57                   	push   %edi
  8001c3:	50                   	push   %eax
  8001c4:	8d 83 20 ef ff ff    	lea    -0x10e0(%ebx),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 d1 00 00 00       	call   8002a1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d0:	83 c4 18             	add    $0x18,%esp
  8001d3:	56                   	push   %esi
  8001d4:	ff 75 10             	pushl  0x10(%ebp)
  8001d7:	e8 63 00 00 00       	call   80023f <vcprintf>
	cprintf("\n");
  8001dc:	8d 83 e8 ee ff ff    	lea    -0x1118(%ebx),%eax
  8001e2:	89 04 24             	mov    %eax,(%esp)
  8001e5:	e8 b7 00 00 00       	call   8002a1 <cprintf>
  8001ea:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ed:	cc                   	int3   
  8001ee:	eb fd                	jmp    8001ed <_panic+0x58>

008001f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	e8 63 fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8001fa:	81 c3 06 1e 00 00    	add    $0x1e06,%ebx
  800200:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  800203:	8b 16                	mov    (%esi),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 06                	mov    %eax,(%esi)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	74 0b                	je     800223 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800218:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  80021c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021f:	5b                   	pop    %ebx
  800220:	5e                   	pop    %esi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	68 ff 00 00 00       	push   $0xff
  80022b:	8d 46 08             	lea    0x8(%esi),%eax
  80022e:	50                   	push   %eax
  80022f:	e8 ac fe ff ff       	call   8000e0 <sys_cputs>
		b->idx = 0;
  800234:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80023a:	83 c4 10             	add    $0x10,%esp
  80023d:	eb d9                	jmp    800218 <putch+0x28>

0080023f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	53                   	push   %ebx
  800243:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800249:	e8 0f fe ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  80024e:	81 c3 b2 1d 00 00    	add    $0x1db2,%ebx
	struct printbuf b;

	b.idx = 0;
  800254:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80025b:	00 00 00 
	b.cnt = 0;
  80025e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800265:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800268:	ff 75 0c             	pushl  0xc(%ebp)
  80026b:	ff 75 08             	pushl  0x8(%ebp)
  80026e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800274:	50                   	push   %eax
  800275:	8d 83 f0 e1 ff ff    	lea    -0x1e10(%ebx),%eax
  80027b:	50                   	push   %eax
  80027c:	e8 38 01 00 00       	call   8003b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800281:	83 c4 08             	add    $0x8,%esp
  800284:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80028a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800290:	50                   	push   %eax
  800291:	e8 4a fe ff ff       	call   8000e0 <sys_cputs>
	return b.cnt;
}
  800296:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80029c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002aa:	50                   	push   %eax
  8002ab:	ff 75 08             	pushl  0x8(%ebp)
  8002ae:	e8 8c ff ff ff       	call   80023f <vcprintf>
	va_end(ap);

	return cnt;
}
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    

008002b5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 2c             	sub    $0x2c,%esp
  8002be:	e8 63 06 00 00       	call   800926 <__x86.get_pc_thunk.cx>
  8002c3:	81 c1 3d 1d 00 00    	add    $0x1d3d,%ecx
  8002c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002cc:	89 c7                	mov    %eax,%edi
  8002ce:	89 d6                	mov    %edx,%esi
  8002d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002e7:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002ea:	39 d3                	cmp    %edx,%ebx
  8002ec:	72 09                	jb     8002f7 <printnum+0x42>
  8002ee:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f1:	0f 87 83 00 00 00    	ja     80037a <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	ff 75 18             	pushl  0x18(%ebp)
  8002fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800300:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800303:	53                   	push   %ebx
  800304:	ff 75 10             	pushl  0x10(%ebp)
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	ff 75 dc             	pushl  -0x24(%ebp)
  80030d:	ff 75 d8             	pushl  -0x28(%ebp)
  800310:	ff 75 d4             	pushl  -0x2c(%ebp)
  800313:	ff 75 d0             	pushl  -0x30(%ebp)
  800316:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800319:	e8 82 09 00 00       	call   800ca0 <__udivdi3>
  80031e:	83 c4 18             	add    $0x18,%esp
  800321:	52                   	push   %edx
  800322:	50                   	push   %eax
  800323:	89 f2                	mov    %esi,%edx
  800325:	89 f8                	mov    %edi,%eax
  800327:	e8 89 ff ff ff       	call   8002b5 <printnum>
  80032c:	83 c4 20             	add    $0x20,%esp
  80032f:	eb 13                	jmp    800344 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	56                   	push   %esi
  800335:	ff 75 18             	pushl  0x18(%ebp)
  800338:	ff d7                	call   *%edi
  80033a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f ed                	jg     800331 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 dc             	pushl  -0x24(%ebp)
  80034e:	ff 75 d8             	pushl  -0x28(%ebp)
  800351:	ff 75 d4             	pushl  -0x2c(%ebp)
  800354:	ff 75 d0             	pushl  -0x30(%ebp)
  800357:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80035a:	89 f3                	mov    %esi,%ebx
  80035c:	e8 5f 0a 00 00       	call   800dc0 <__umoddi3>
  800361:	83 c4 14             	add    $0x14,%esp
  800364:	0f be 84 06 44 ef ff 	movsbl -0x10bc(%esi,%eax,1),%eax
  80036b:	ff 
  80036c:	50                   	push   %eax
  80036d:	ff d7                	call   *%edi
}
  80036f:	83 c4 10             	add    $0x10,%esp
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80037d:	eb be                	jmp    80033d <printnum+0x88>

0080037f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800385:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	3b 50 04             	cmp    0x4(%eax),%edx
  80038e:	73 0a                	jae    80039a <sprintputch+0x1b>
		*b->buf++ = ch;
  800390:	8d 4a 01             	lea    0x1(%edx),%ecx
  800393:	89 08                	mov    %ecx,(%eax)
  800395:	8b 45 08             	mov    0x8(%ebp),%eax
  800398:	88 02                	mov    %al,(%edx)
}
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <printfmt>:
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a5:	50                   	push   %eax
  8003a6:	ff 75 10             	pushl  0x10(%ebp)
  8003a9:	ff 75 0c             	pushl  0xc(%ebp)
  8003ac:	ff 75 08             	pushl  0x8(%ebp)
  8003af:	e8 05 00 00 00       	call   8003b9 <vprintfmt>
}
  8003b4:	83 c4 10             	add    $0x10,%esp
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    

008003b9 <vprintfmt>:
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	57                   	push   %edi
  8003bd:	56                   	push   %esi
  8003be:	53                   	push   %ebx
  8003bf:	83 ec 2c             	sub    $0x2c,%esp
  8003c2:	e8 96 fc ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8003c7:	81 c3 39 1c 00 00    	add    $0x1c39,%ebx
  8003cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003d0:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003d7:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d9:	8d 77 01             	lea    0x1(%edi),%esi
  8003dc:	0f b6 07             	movzbl (%edi),%eax
  8003df:	83 f8 25             	cmp    $0x25,%eax
  8003e2:	74 1c                	je     800400 <vprintfmt+0x47>
			if (ch == '\0')
  8003e4:	85 c0                	test   %eax,%eax
  8003e6:	0f 84 b9 04 00 00    	je     8008a5 <.L21+0x20>
			putch(ch, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003f2:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003f5:	50                   	push   %eax
  8003f6:	ff 55 08             	call   *0x8(%ebp)
  8003f9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003fc:	89 f7                	mov    %esi,%edi
  8003fe:	eb d9                	jmp    8003d9 <vprintfmt+0x20>
		padc = ' ';
  800400:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800404:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80040b:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  800412:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800419:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8d 7e 01             	lea    0x1(%esi),%edi
  800424:	0f b6 16             	movzbl (%esi),%edx
  800427:	8d 42 dd             	lea    -0x23(%edx),%eax
  80042a:	3c 55                	cmp    $0x55,%al
  80042c:	0f 87 53 04 00 00    	ja     800885 <.L21>
  800432:	0f b6 c0             	movzbl %al,%eax
  800435:	89 d9                	mov    %ebx,%ecx
  800437:	03 8c 83 d4 ef ff ff 	add    -0x102c(%ebx,%eax,4),%ecx
  80043e:	ff e1                	jmp    *%ecx

00800440 <.L73>:
  800440:	89 fe                	mov    %edi,%esi
			padc = '-';
  800442:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800446:	eb d9                	jmp    800421 <vprintfmt+0x68>

00800448 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	89 fe                	mov    %edi,%esi
			padc = '0';
  80044a:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80044e:	eb d1                	jmp    800421 <vprintfmt+0x68>

00800450 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	0f b6 d2             	movzbl %dl,%edx
  800453:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800455:	b8 00 00 00 00       	mov    $0x0,%eax
  80045a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  80045d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800460:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800464:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800467:	8d 7a d0             	lea    -0x30(%edx),%edi
  80046a:	83 ff 09             	cmp    $0x9,%edi
  80046d:	0f 87 94 00 00 00    	ja     800507 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  800473:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800476:	eb e5                	jmp    80045d <.L28+0xd>

00800478 <.L25>:
			precision = va_arg(ap, int);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8b 00                	mov    (%eax),%eax
  80047d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8d 40 04             	lea    0x4(%eax),%eax
  800486:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800489:	89 fe                	mov    %edi,%esi
			if (width < 0)
  80048b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048f:	79 90                	jns    800421 <vprintfmt+0x68>
				width = precision, precision = -1;
  800491:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800494:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800497:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80049e:	eb 81                	jmp    800421 <vprintfmt+0x68>

008004a0 <.L26>:
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 49 d0             	cmovns %eax,%edx
  8004ad:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	89 fe                	mov    %edi,%esi
  8004b2:	e9 6a ff ff ff       	jmp    800421 <vprintfmt+0x68>

008004b7 <.L22>:
  8004b7:	89 fe                	mov    %edi,%esi
			altflag = 1;
  8004b9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c0:	e9 5c ff ff ff       	jmp    800421 <vprintfmt+0x68>

008004c5 <.L33>:
  8004c5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004c8:	83 f9 01             	cmp    $0x1,%ecx
  8004cb:	7e 16                	jle    8004e3 <.L33+0x1e>
		return va_arg(*ap, long long);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8b 00                	mov    (%eax),%eax
  8004d2:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004d5:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004d8:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004de:	e9 f6 fe ff ff       	jmp    8003d9 <vprintfmt+0x20>
	else if (lflag)
  8004e3:	85 c9                	test   %ecx,%ecx
  8004e5:	75 10                	jne    8004f7 <.L33+0x32>
		return va_arg(*ap, int);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004ef:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004f2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f5:	eb e4                	jmp    8004db <.L33+0x16>
		return va_arg(*ap, long);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004ff:	8d 49 04             	lea    0x4(%ecx),%ecx
  800502:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800505:	eb d4                	jmp    8004db <.L33+0x16>
  800507:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80050a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80050d:	e9 79 ff ff ff       	jmp    80048b <.L25+0x13>

00800512 <.L32>:
			lflag++;
  800512:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800516:	89 fe                	mov    %edi,%esi
			goto reswitch;
  800518:	e9 04 ff ff ff       	jmp    800421 <vprintfmt+0x68>

0080051d <.L29>:
			putch(va_arg(ap, int), putdat);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 70 04             	lea    0x4(%eax),%esi
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	ff 75 0c             	pushl  0xc(%ebp)
  800529:	ff 30                	pushl  (%eax)
  80052b:	ff 55 08             	call   *0x8(%ebp)
			break;
  80052e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800531:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800534:	e9 a0 fe ff ff       	jmp    8003d9 <vprintfmt+0x20>

00800539 <.L31>:
			err = va_arg(ap, int);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 70 04             	lea    0x4(%eax),%esi
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	99                   	cltd   
  800542:	31 d0                	xor    %edx,%eax
  800544:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800546:	83 f8 06             	cmp    $0x6,%eax
  800549:	7f 29                	jg     800574 <.L31+0x3b>
  80054b:	8b 94 83 14 00 00 00 	mov    0x14(%ebx,%eax,4),%edx
  800552:	85 d2                	test   %edx,%edx
  800554:	74 1e                	je     800574 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800556:	52                   	push   %edx
  800557:	8d 83 65 ef ff ff    	lea    -0x109b(%ebx),%eax
  80055d:	50                   	push   %eax
  80055e:	ff 75 0c             	pushl  0xc(%ebp)
  800561:	ff 75 08             	pushl  0x8(%ebp)
  800564:	e8 33 fe ff ff       	call   80039c <printfmt>
  800569:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80056c:	89 75 14             	mov    %esi,0x14(%ebp)
  80056f:	e9 65 fe ff ff       	jmp    8003d9 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800574:	50                   	push   %eax
  800575:	8d 83 5c ef ff ff    	lea    -0x10a4(%ebx),%eax
  80057b:	50                   	push   %eax
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	ff 75 08             	pushl  0x8(%ebp)
  800582:	e8 15 fe ff ff       	call   80039c <printfmt>
  800587:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80058a:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80058d:	e9 47 fe ff ff       	jmp    8003d9 <vprintfmt+0x20>

00800592 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	83 c0 04             	add    $0x4,%eax
  800598:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  8005a0:	85 f6                	test   %esi,%esi
  8005a2:	8d 83 55 ef ff ff    	lea    -0x10ab(%ebx),%eax
  8005a8:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005af:	0f 8e b4 00 00 00    	jle    800669 <.L36+0xd7>
  8005b5:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005b9:	75 08                	jne    8005c3 <.L36+0x31>
  8005bb:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005be:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005c1:	eb 6c                	jmp    80062f <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	ff 75 cc             	pushl  -0x34(%ebp)
  8005c9:	56                   	push   %esi
  8005ca:	e8 73 03 00 00       	call   800942 <strnlen>
  8005cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d2:	29 c2                	sub    %eax,%edx
  8005d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005da:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005de:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005e1:	89 d6                	mov    %edx,%esi
  8005e3:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005e6:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e8:	eb 10                	jmp    8005fa <.L36+0x68>
					putch(padc, putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	ff 75 0c             	pushl  0xc(%ebp)
  8005f0:	57                   	push   %edi
  8005f1:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f4:	83 ee 01             	sub    $0x1,%esi
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	85 f6                	test   %esi,%esi
  8005fc:	7f ec                	jg     8005ea <.L36+0x58>
  8005fe:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800601:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800604:	85 d2                	test   %edx,%edx
  800606:	b8 00 00 00 00       	mov    $0x0,%eax
  80060b:	0f 49 c2             	cmovns %edx,%eax
  80060e:	29 c2                	sub    %eax,%edx
  800610:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800613:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800616:	eb 17                	jmp    80062f <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  800618:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80061c:	75 30                	jne    80064e <.L36+0xbc>
					putch(ch, putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	ff 75 0c             	pushl  0xc(%ebp)
  800624:	50                   	push   %eax
  800625:	ff 55 08             	call   *0x8(%ebp)
  800628:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062b:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80062f:	83 c6 01             	add    $0x1,%esi
  800632:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800636:	0f be c2             	movsbl %dl,%eax
  800639:	85 c0                	test   %eax,%eax
  80063b:	74 58                	je     800695 <.L36+0x103>
  80063d:	85 ff                	test   %edi,%edi
  80063f:	78 d7                	js     800618 <.L36+0x86>
  800641:	83 ef 01             	sub    $0x1,%edi
  800644:	79 d2                	jns    800618 <.L36+0x86>
  800646:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800649:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80064c:	eb 32                	jmp    800680 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  80064e:	0f be d2             	movsbl %dl,%edx
  800651:	83 ea 20             	sub    $0x20,%edx
  800654:	83 fa 5e             	cmp    $0x5e,%edx
  800657:	76 c5                	jbe    80061e <.L36+0x8c>
					putch('?', putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	6a 3f                	push   $0x3f
  800661:	ff 55 08             	call   *0x8(%ebp)
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	eb c2                	jmp    80062b <.L36+0x99>
  800669:	89 7d 10             	mov    %edi,0x10(%ebp)
  80066c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80066f:	eb be                	jmp    80062f <.L36+0x9d>
				putch(' ', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	57                   	push   %edi
  800675:	6a 20                	push   $0x20
  800677:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  80067a:	83 ee 01             	sub    $0x1,%esi
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	85 f6                	test   %esi,%esi
  800682:	7f ed                	jg     800671 <.L36+0xdf>
  800684:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800687:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  80068a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80068d:	89 45 14             	mov    %eax,0x14(%ebp)
  800690:	e9 44 fd ff ff       	jmp    8003d9 <vprintfmt+0x20>
  800695:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800698:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80069b:	eb e3                	jmp    800680 <.L36+0xee>

0080069d <.L30>:
  80069d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8006a0:	83 f9 01             	cmp    $0x1,%ecx
  8006a3:	7e 42                	jle    8006e7 <.L30+0x4a>
		return va_arg(*ap, long long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 50 04             	mov    0x4(%eax),%edx
  8006ab:	8b 00                	mov    (%eax),%eax
  8006ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 40 08             	lea    0x8(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c0:	79 5f                	jns    800721 <.L30+0x84>
				putch('-', putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	ff 75 0c             	pushl  0xc(%ebp)
  8006c8:	6a 2d                	push   $0x2d
  8006ca:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006cd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006d0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006d3:	f7 da                	neg    %edx
  8006d5:	83 d1 00             	adc    $0x0,%ecx
  8006d8:	f7 d9                	neg    %ecx
  8006da:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e2:	e9 b8 00 00 00       	jmp    80079f <.L34+0x22>
	else if (lflag)
  8006e7:	85 c9                	test   %ecx,%ecx
  8006e9:	75 1b                	jne    800706 <.L30+0x69>
		return va_arg(*ap, int);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8b 30                	mov    (%eax),%esi
  8006f0:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006f3:	89 f0                	mov    %esi,%eax
  8006f5:	c1 f8 1f             	sar    $0x1f,%eax
  8006f8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8d 40 04             	lea    0x4(%eax),%eax
  800701:	89 45 14             	mov    %eax,0x14(%ebp)
  800704:	eb b6                	jmp    8006bc <.L30+0x1f>
		return va_arg(*ap, long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 30                	mov    (%eax),%esi
  80070b:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80070e:	89 f0                	mov    %esi,%eax
  800710:	c1 f8 1f             	sar    $0x1f,%eax
  800713:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 40 04             	lea    0x4(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
  80071f:	eb 9b                	jmp    8006bc <.L30+0x1f>
			num = getint(&ap, lflag);
  800721:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800724:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800727:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072c:	eb 71                	jmp    80079f <.L34+0x22>

0080072e <.L37>:
  80072e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800731:	83 f9 01             	cmp    $0x1,%ecx
  800734:	7e 15                	jle    80074b <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8b 10                	mov    (%eax),%edx
  80073b:	8b 48 04             	mov    0x4(%eax),%ecx
  80073e:	8d 40 08             	lea    0x8(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800744:	b8 0a 00 00 00       	mov    $0xa,%eax
  800749:	eb 54                	jmp    80079f <.L34+0x22>
	else if (lflag)
  80074b:	85 c9                	test   %ecx,%ecx
  80074d:	75 17                	jne    800766 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8b 10                	mov    (%eax),%edx
  800754:	b9 00 00 00 00       	mov    $0x0,%ecx
  800759:	8d 40 04             	lea    0x4(%eax),%eax
  80075c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80075f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800764:	eb 39                	jmp    80079f <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 10                	mov    (%eax),%edx
  80076b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800770:	8d 40 04             	lea    0x4(%eax),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800776:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077b:	eb 22                	jmp    80079f <.L34+0x22>

0080077d <.L34>:
  80077d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800780:	83 f9 01             	cmp    $0x1,%ecx
  800783:	7e 3b                	jle    8007c0 <.L34+0x43>
		return va_arg(*ap, long long);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8b 50 04             	mov    0x4(%eax),%edx
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800790:	8d 49 08             	lea    0x8(%ecx),%ecx
  800793:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800796:	89 d1                	mov    %edx,%ecx
  800798:	89 c2                	mov    %eax,%edx
			base = 8;
  80079a:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80079f:	83 ec 0c             	sub    $0xc,%esp
  8007a2:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  8007a6:	56                   	push   %esi
  8007a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007aa:	50                   	push   %eax
  8007ab:	51                   	push   %ecx
  8007ac:	52                   	push   %edx
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	e8 fd fa ff ff       	call   8002b5 <printnum>
			break;
  8007b8:	83 c4 20             	add    $0x20,%esp
  8007bb:	e9 19 fc ff ff       	jmp    8003d9 <vprintfmt+0x20>
	else if (lflag)
  8007c0:	85 c9                	test   %ecx,%ecx
  8007c2:	75 13                	jne    8007d7 <.L34+0x5a>
		return va_arg(*ap, int);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8b 10                	mov    (%eax),%edx
  8007c9:	89 d0                	mov    %edx,%eax
  8007cb:	99                   	cltd   
  8007cc:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007cf:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007d2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007d5:	eb bf                	jmp    800796 <.L34+0x19>
		return va_arg(*ap, long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8b 10                	mov    (%eax),%edx
  8007dc:	89 d0                	mov    %edx,%eax
  8007de:	99                   	cltd   
  8007df:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007e2:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007e5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007e8:	eb ac                	jmp    800796 <.L34+0x19>

008007ea <.L35>:
			putch('0', putdat);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	ff 75 0c             	pushl  0xc(%ebp)
  8007f0:	6a 30                	push   $0x30
  8007f2:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007f5:	83 c4 08             	add    $0x8,%esp
  8007f8:	ff 75 0c             	pushl  0xc(%ebp)
  8007fb:	6a 78                	push   $0x78
  8007fd:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	8b 10                	mov    (%eax),%edx
  800805:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80080a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80080d:	8d 40 04             	lea    0x4(%eax),%eax
  800810:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800813:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800818:	eb 85                	jmp    80079f <.L34+0x22>

0080081a <.L38>:
  80081a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80081d:	83 f9 01             	cmp    $0x1,%ecx
  800820:	7e 18                	jle    80083a <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8b 10                	mov    (%eax),%edx
  800827:	8b 48 04             	mov    0x4(%eax),%ecx
  80082a:	8d 40 08             	lea    0x8(%eax),%eax
  80082d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800830:	b8 10 00 00 00       	mov    $0x10,%eax
  800835:	e9 65 ff ff ff       	jmp    80079f <.L34+0x22>
	else if (lflag)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	75 1a                	jne    800858 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 10                	mov    (%eax),%edx
  800843:	b9 00 00 00 00       	mov    $0x0,%ecx
  800848:	8d 40 04             	lea    0x4(%eax),%eax
  80084b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80084e:	b8 10 00 00 00       	mov    $0x10,%eax
  800853:	e9 47 ff ff ff       	jmp    80079f <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8b 10                	mov    (%eax),%edx
  80085d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800862:	8d 40 04             	lea    0x4(%eax),%eax
  800865:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800868:	b8 10 00 00 00       	mov    $0x10,%eax
  80086d:	e9 2d ff ff ff       	jmp    80079f <.L34+0x22>

00800872 <.L24>:
			putch(ch, putdat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	ff 75 0c             	pushl  0xc(%ebp)
  800878:	6a 25                	push   $0x25
  80087a:	ff 55 08             	call   *0x8(%ebp)
			break;
  80087d:	83 c4 10             	add    $0x10,%esp
  800880:	e9 54 fb ff ff       	jmp    8003d9 <vprintfmt+0x20>

00800885 <.L21>:
			putch('%', putdat);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	6a 25                	push   $0x25
  80088d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	89 f7                	mov    %esi,%edi
  800895:	eb 03                	jmp    80089a <.L21+0x15>
  800897:	83 ef 01             	sub    $0x1,%edi
  80089a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80089e:	75 f7                	jne    800897 <.L21+0x12>
  8008a0:	e9 34 fb ff ff       	jmp    8003d9 <vprintfmt+0x20>
}
  8008a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5f                   	pop    %edi
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	53                   	push   %ebx
  8008b1:	83 ec 14             	sub    $0x14,%esp
  8008b4:	e8 a4 f7 ff ff       	call   80005d <__x86.get_pc_thunk.bx>
  8008b9:	81 c3 47 17 00 00    	add    $0x1747,%ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d6:	85 c0                	test   %eax,%eax
  8008d8:	74 2b                	je     800905 <vsnprintf+0x58>
  8008da:	85 d2                	test   %edx,%edx
  8008dc:	7e 27                	jle    800905 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008de:	ff 75 14             	pushl  0x14(%ebp)
  8008e1:	ff 75 10             	pushl  0x10(%ebp)
  8008e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e7:	50                   	push   %eax
  8008e8:	8d 83 7f e3 ff ff    	lea    -0x1c81(%ebx),%eax
  8008ee:	50                   	push   %eax
  8008ef:	e8 c5 fa ff ff       	call   8003b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fd:	83 c4 10             	add    $0x10,%esp
}
  800900:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800903:	c9                   	leave  
  800904:	c3                   	ret    
		return -E_INVAL;
  800905:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80090a:	eb f4                	jmp    800900 <vsnprintf+0x53>

0080090c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800912:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800915:	50                   	push   %eax
  800916:	ff 75 10             	pushl  0x10(%ebp)
  800919:	ff 75 0c             	pushl  0xc(%ebp)
  80091c:	ff 75 08             	pushl  0x8(%ebp)
  80091f:	e8 89 ff ff ff       	call   8008ad <vsnprintf>
	va_end(ap);

	return rc;
}
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <__x86.get_pc_thunk.cx>:
  800926:	8b 0c 24             	mov    (%esp),%ecx
  800929:	c3                   	ret    

0080092a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800930:	b8 00 00 00 00       	mov    $0x0,%eax
  800935:	eb 03                	jmp    80093a <strlen+0x10>
		n++;
  800937:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80093a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093e:	75 f7                	jne    800937 <strlen+0xd>
	return n;
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800948:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
  800950:	eb 03                	jmp    800955 <strnlen+0x13>
		n++;
  800952:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800955:	39 d0                	cmp    %edx,%eax
  800957:	74 06                	je     80095f <strnlen+0x1d>
  800959:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80095d:	75 f3                	jne    800952 <strnlen+0x10>
	return n;
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	53                   	push   %ebx
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80096b:	89 c2                	mov    %eax,%edx
  80096d:	83 c1 01             	add    $0x1,%ecx
  800970:	83 c2 01             	add    $0x1,%edx
  800973:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800977:	88 5a ff             	mov    %bl,-0x1(%edx)
  80097a:	84 db                	test   %bl,%bl
  80097c:	75 ef                	jne    80096d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80097e:	5b                   	pop    %ebx
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	53                   	push   %ebx
  800985:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800988:	53                   	push   %ebx
  800989:	e8 9c ff ff ff       	call   80092a <strlen>
  80098e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800991:	ff 75 0c             	pushl  0xc(%ebp)
  800994:	01 d8                	add    %ebx,%eax
  800996:	50                   	push   %eax
  800997:	e8 c5 ff ff ff       	call   800961 <strcpy>
	return dst;
}
  80099c:	89 d8                	mov    %ebx,%eax
  80099e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ae:	89 f3                	mov    %esi,%ebx
  8009b0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b3:	89 f2                	mov    %esi,%edx
  8009b5:	eb 0f                	jmp    8009c6 <strncpy+0x23>
		*dst++ = *src;
  8009b7:	83 c2 01             	add    $0x1,%edx
  8009ba:	0f b6 01             	movzbl (%ecx),%eax
  8009bd:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c0:	80 39 01             	cmpb   $0x1,(%ecx)
  8009c3:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009c6:	39 da                	cmp    %ebx,%edx
  8009c8:	75 ed                	jne    8009b7 <strncpy+0x14>
	}
	return ret;
}
  8009ca:	89 f0                	mov    %esi,%eax
  8009cc:	5b                   	pop    %ebx
  8009cd:	5e                   	pop    %esi
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009db:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009de:	89 f0                	mov    %esi,%eax
  8009e0:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e4:	85 c9                	test   %ecx,%ecx
  8009e6:	75 0b                	jne    8009f3 <strlcpy+0x23>
  8009e8:	eb 17                	jmp    800a01 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ea:	83 c2 01             	add    $0x1,%edx
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009f3:	39 d8                	cmp    %ebx,%eax
  8009f5:	74 07                	je     8009fe <strlcpy+0x2e>
  8009f7:	0f b6 0a             	movzbl (%edx),%ecx
  8009fa:	84 c9                	test   %cl,%cl
  8009fc:	75 ec                	jne    8009ea <strlcpy+0x1a>
		*dst = '\0';
  8009fe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a01:	29 f0                	sub    %esi,%eax
}
  800a03:	5b                   	pop    %ebx
  800a04:	5e                   	pop    %esi
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a10:	eb 06                	jmp    800a18 <strcmp+0x11>
		p++, q++;
  800a12:	83 c1 01             	add    $0x1,%ecx
  800a15:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a18:	0f b6 01             	movzbl (%ecx),%eax
  800a1b:	84 c0                	test   %al,%al
  800a1d:	74 04                	je     800a23 <strcmp+0x1c>
  800a1f:	3a 02                	cmp    (%edx),%al
  800a21:	74 ef                	je     800a12 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a23:	0f b6 c0             	movzbl %al,%eax
  800a26:	0f b6 12             	movzbl (%edx),%edx
  800a29:	29 d0                	sub    %edx,%eax
}
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	53                   	push   %ebx
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a37:	89 c3                	mov    %eax,%ebx
  800a39:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a3c:	eb 06                	jmp    800a44 <strncmp+0x17>
		n--, p++, q++;
  800a3e:	83 c0 01             	add    $0x1,%eax
  800a41:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a44:	39 d8                	cmp    %ebx,%eax
  800a46:	74 16                	je     800a5e <strncmp+0x31>
  800a48:	0f b6 08             	movzbl (%eax),%ecx
  800a4b:	84 c9                	test   %cl,%cl
  800a4d:	74 04                	je     800a53 <strncmp+0x26>
  800a4f:	3a 0a                	cmp    (%edx),%cl
  800a51:	74 eb                	je     800a3e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a53:	0f b6 00             	movzbl (%eax),%eax
  800a56:	0f b6 12             	movzbl (%edx),%edx
  800a59:	29 d0                	sub    %edx,%eax
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    
		return 0;
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a63:	eb f6                	jmp    800a5b <strncmp+0x2e>

00800a65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6f:	0f b6 10             	movzbl (%eax),%edx
  800a72:	84 d2                	test   %dl,%dl
  800a74:	74 09                	je     800a7f <strchr+0x1a>
		if (*s == c)
  800a76:	38 ca                	cmp    %cl,%dl
  800a78:	74 0a                	je     800a84 <strchr+0x1f>
	for (; *s; s++)
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	eb f0                	jmp    800a6f <strchr+0xa>
			return (char *) s;
	return 0;
  800a7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a90:	eb 03                	jmp    800a95 <strfind+0xf>
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a98:	38 ca                	cmp    %cl,%dl
  800a9a:	74 04                	je     800aa0 <strfind+0x1a>
  800a9c:	84 d2                	test   %dl,%dl
  800a9e:	75 f2                	jne    800a92 <strfind+0xc>
			break;
	return (char *) s;
}
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aae:	85 c9                	test   %ecx,%ecx
  800ab0:	74 13                	je     800ac5 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab8:	75 05                	jne    800abf <memset+0x1d>
  800aba:	f6 c1 03             	test   $0x3,%cl
  800abd:	74 0d                	je     800acc <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	fc                   	cld    
  800ac3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac5:	89 f8                	mov    %edi,%eax
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    
		c &= 0xFF;
  800acc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad0:	89 d3                	mov    %edx,%ebx
  800ad2:	c1 e3 08             	shl    $0x8,%ebx
  800ad5:	89 d0                	mov    %edx,%eax
  800ad7:	c1 e0 18             	shl    $0x18,%eax
  800ada:	89 d6                	mov    %edx,%esi
  800adc:	c1 e6 10             	shl    $0x10,%esi
  800adf:	09 f0                	or     %esi,%eax
  800ae1:	09 c2                	or     %eax,%edx
  800ae3:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ae5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ae8:	89 d0                	mov    %edx,%eax
  800aea:	fc                   	cld    
  800aeb:	f3 ab                	rep stos %eax,%es:(%edi)
  800aed:	eb d6                	jmp    800ac5 <memset+0x23>

00800aef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800afd:	39 c6                	cmp    %eax,%esi
  800aff:	73 35                	jae    800b36 <memmove+0x47>
  800b01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b04:	39 c2                	cmp    %eax,%edx
  800b06:	76 2e                	jbe    800b36 <memmove+0x47>
		s += n;
		d += n;
  800b08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0b:	89 d6                	mov    %edx,%esi
  800b0d:	09 fe                	or     %edi,%esi
  800b0f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b15:	74 0c                	je     800b23 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b17:	83 ef 01             	sub    $0x1,%edi
  800b1a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b1d:	fd                   	std    
  800b1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b20:	fc                   	cld    
  800b21:	eb 21                	jmp    800b44 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b23:	f6 c1 03             	test   $0x3,%cl
  800b26:	75 ef                	jne    800b17 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b28:	83 ef 04             	sub    $0x4,%edi
  800b2b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b31:	fd                   	std    
  800b32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b34:	eb ea                	jmp    800b20 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b36:	89 f2                	mov    %esi,%edx
  800b38:	09 c2                	or     %eax,%edx
  800b3a:	f6 c2 03             	test   $0x3,%dl
  800b3d:	74 09                	je     800b48 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b3f:	89 c7                	mov    %eax,%edi
  800b41:	fc                   	cld    
  800b42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b48:	f6 c1 03             	test   $0x3,%cl
  800b4b:	75 f2                	jne    800b3f <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b4d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b50:	89 c7                	mov    %eax,%edi
  800b52:	fc                   	cld    
  800b53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b55:	eb ed                	jmp    800b44 <memmove+0x55>

00800b57 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b5a:	ff 75 10             	pushl  0x10(%ebp)
  800b5d:	ff 75 0c             	pushl  0xc(%ebp)
  800b60:	ff 75 08             	pushl  0x8(%ebp)
  800b63:	e8 87 ff ff ff       	call   800aef <memmove>
}
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b75:	89 c6                	mov    %eax,%esi
  800b77:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7a:	39 f0                	cmp    %esi,%eax
  800b7c:	74 1c                	je     800b9a <memcmp+0x30>
		if (*s1 != *s2)
  800b7e:	0f b6 08             	movzbl (%eax),%ecx
  800b81:	0f b6 1a             	movzbl (%edx),%ebx
  800b84:	38 d9                	cmp    %bl,%cl
  800b86:	75 08                	jne    800b90 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b88:	83 c0 01             	add    $0x1,%eax
  800b8b:	83 c2 01             	add    $0x1,%edx
  800b8e:	eb ea                	jmp    800b7a <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b90:	0f b6 c1             	movzbl %cl,%eax
  800b93:	0f b6 db             	movzbl %bl,%ebx
  800b96:	29 d8                	sub    %ebx,%eax
  800b98:	eb 05                	jmp    800b9f <memcmp+0x35>
	}

	return 0;
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bac:	89 c2                	mov    %eax,%edx
  800bae:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb1:	39 d0                	cmp    %edx,%eax
  800bb3:	73 09                	jae    800bbe <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb5:	38 08                	cmp    %cl,(%eax)
  800bb7:	74 05                	je     800bbe <memfind+0x1b>
	for (; s < ends; s++)
  800bb9:	83 c0 01             	add    $0x1,%eax
  800bbc:	eb f3                	jmp    800bb1 <memfind+0xe>
			break;
	return (void *) s;
}
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcc:	eb 03                	jmp    800bd1 <strtol+0x11>
		s++;
  800bce:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bd1:	0f b6 01             	movzbl (%ecx),%eax
  800bd4:	3c 20                	cmp    $0x20,%al
  800bd6:	74 f6                	je     800bce <strtol+0xe>
  800bd8:	3c 09                	cmp    $0x9,%al
  800bda:	74 f2                	je     800bce <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bdc:	3c 2b                	cmp    $0x2b,%al
  800bde:	74 2e                	je     800c0e <strtol+0x4e>
	int neg = 0;
  800be0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800be5:	3c 2d                	cmp    $0x2d,%al
  800be7:	74 2f                	je     800c18 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bef:	75 05                	jne    800bf6 <strtol+0x36>
  800bf1:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf4:	74 2c                	je     800c22 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf6:	85 db                	test   %ebx,%ebx
  800bf8:	75 0a                	jne    800c04 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bfa:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bff:	80 39 30             	cmpb   $0x30,(%ecx)
  800c02:	74 28                	je     800c2c <strtol+0x6c>
		base = 10;
  800c04:	b8 00 00 00 00       	mov    $0x0,%eax
  800c09:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c0c:	eb 50                	jmp    800c5e <strtol+0x9e>
		s++;
  800c0e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c11:	bf 00 00 00 00       	mov    $0x0,%edi
  800c16:	eb d1                	jmp    800be9 <strtol+0x29>
		s++, neg = 1;
  800c18:	83 c1 01             	add    $0x1,%ecx
  800c1b:	bf 01 00 00 00       	mov    $0x1,%edi
  800c20:	eb c7                	jmp    800be9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c22:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c26:	74 0e                	je     800c36 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c28:	85 db                	test   %ebx,%ebx
  800c2a:	75 d8                	jne    800c04 <strtol+0x44>
		s++, base = 8;
  800c2c:	83 c1 01             	add    $0x1,%ecx
  800c2f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c34:	eb ce                	jmp    800c04 <strtol+0x44>
		s += 2, base = 16;
  800c36:	83 c1 02             	add    $0x2,%ecx
  800c39:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3e:	eb c4                	jmp    800c04 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c40:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c43:	89 f3                	mov    %esi,%ebx
  800c45:	80 fb 19             	cmp    $0x19,%bl
  800c48:	77 29                	ja     800c73 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c4a:	0f be d2             	movsbl %dl,%edx
  800c4d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c50:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c53:	7d 30                	jge    800c85 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c55:	83 c1 01             	add    $0x1,%ecx
  800c58:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c5c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c5e:	0f b6 11             	movzbl (%ecx),%edx
  800c61:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c64:	89 f3                	mov    %esi,%ebx
  800c66:	80 fb 09             	cmp    $0x9,%bl
  800c69:	77 d5                	ja     800c40 <strtol+0x80>
			dig = *s - '0';
  800c6b:	0f be d2             	movsbl %dl,%edx
  800c6e:	83 ea 30             	sub    $0x30,%edx
  800c71:	eb dd                	jmp    800c50 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c73:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c76:	89 f3                	mov    %esi,%ebx
  800c78:	80 fb 19             	cmp    $0x19,%bl
  800c7b:	77 08                	ja     800c85 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c7d:	0f be d2             	movsbl %dl,%edx
  800c80:	83 ea 37             	sub    $0x37,%edx
  800c83:	eb cb                	jmp    800c50 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c89:	74 05                	je     800c90 <strtol+0xd0>
		*endptr = (char *) s;
  800c8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c90:	89 c2                	mov    %eax,%edx
  800c92:	f7 da                	neg    %edx
  800c94:	85 ff                	test   %edi,%edi
  800c96:	0f 45 c2             	cmovne %edx,%eax
}
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    
  800c9e:	66 90                	xchg   %ax,%ax

00800ca0 <__udivdi3>:
  800ca0:	55                   	push   %ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 1c             	sub    $0x1c,%esp
  800ca7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800cab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800caf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800cb7:	85 d2                	test   %edx,%edx
  800cb9:	75 35                	jne    800cf0 <__udivdi3+0x50>
  800cbb:	39 f3                	cmp    %esi,%ebx
  800cbd:	0f 87 bd 00 00 00    	ja     800d80 <__udivdi3+0xe0>
  800cc3:	85 db                	test   %ebx,%ebx
  800cc5:	89 d9                	mov    %ebx,%ecx
  800cc7:	75 0b                	jne    800cd4 <__udivdi3+0x34>
  800cc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cce:	31 d2                	xor    %edx,%edx
  800cd0:	f7 f3                	div    %ebx
  800cd2:	89 c1                	mov    %eax,%ecx
  800cd4:	31 d2                	xor    %edx,%edx
  800cd6:	89 f0                	mov    %esi,%eax
  800cd8:	f7 f1                	div    %ecx
  800cda:	89 c6                	mov    %eax,%esi
  800cdc:	89 e8                	mov    %ebp,%eax
  800cde:	89 f7                	mov    %esi,%edi
  800ce0:	f7 f1                	div    %ecx
  800ce2:	89 fa                	mov    %edi,%edx
  800ce4:	83 c4 1c             	add    $0x1c,%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
  800cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	39 f2                	cmp    %esi,%edx
  800cf2:	77 7c                	ja     800d70 <__udivdi3+0xd0>
  800cf4:	0f bd fa             	bsr    %edx,%edi
  800cf7:	83 f7 1f             	xor    $0x1f,%edi
  800cfa:	0f 84 98 00 00 00    	je     800d98 <__udivdi3+0xf8>
  800d00:	89 f9                	mov    %edi,%ecx
  800d02:	b8 20 00 00 00       	mov    $0x20,%eax
  800d07:	29 f8                	sub    %edi,%eax
  800d09:	d3 e2                	shl    %cl,%edx
  800d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800d0f:	89 c1                	mov    %eax,%ecx
  800d11:	89 da                	mov    %ebx,%edx
  800d13:	d3 ea                	shr    %cl,%edx
  800d15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800d19:	09 d1                	or     %edx,%ecx
  800d1b:	89 f2                	mov    %esi,%edx
  800d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d21:	89 f9                	mov    %edi,%ecx
  800d23:	d3 e3                	shl    %cl,%ebx
  800d25:	89 c1                	mov    %eax,%ecx
  800d27:	d3 ea                	shr    %cl,%edx
  800d29:	89 f9                	mov    %edi,%ecx
  800d2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800d2f:	d3 e6                	shl    %cl,%esi
  800d31:	89 eb                	mov    %ebp,%ebx
  800d33:	89 c1                	mov    %eax,%ecx
  800d35:	d3 eb                	shr    %cl,%ebx
  800d37:	09 de                	or     %ebx,%esi
  800d39:	89 f0                	mov    %esi,%eax
  800d3b:	f7 74 24 08          	divl   0x8(%esp)
  800d3f:	89 d6                	mov    %edx,%esi
  800d41:	89 c3                	mov    %eax,%ebx
  800d43:	f7 64 24 0c          	mull   0xc(%esp)
  800d47:	39 d6                	cmp    %edx,%esi
  800d49:	72 0c                	jb     800d57 <__udivdi3+0xb7>
  800d4b:	89 f9                	mov    %edi,%ecx
  800d4d:	d3 e5                	shl    %cl,%ebp
  800d4f:	39 c5                	cmp    %eax,%ebp
  800d51:	73 5d                	jae    800db0 <__udivdi3+0x110>
  800d53:	39 d6                	cmp    %edx,%esi
  800d55:	75 59                	jne    800db0 <__udivdi3+0x110>
  800d57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d5a:	31 ff                	xor    %edi,%edi
  800d5c:	89 fa                	mov    %edi,%edx
  800d5e:	83 c4 1c             	add    $0x1c,%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    
  800d66:	8d 76 00             	lea    0x0(%esi),%esi
  800d69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800d70:	31 ff                	xor    %edi,%edi
  800d72:	31 c0                	xor    %eax,%eax
  800d74:	89 fa                	mov    %edi,%edx
  800d76:	83 c4 1c             	add    $0x1c,%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
  800d7e:	66 90                	xchg   %ax,%ax
  800d80:	31 ff                	xor    %edi,%edi
  800d82:	89 e8                	mov    %ebp,%eax
  800d84:	89 f2                	mov    %esi,%edx
  800d86:	f7 f3                	div    %ebx
  800d88:	89 fa                	mov    %edi,%edx
  800d8a:	83 c4 1c             	add    $0x1c,%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
  800d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d98:	39 f2                	cmp    %esi,%edx
  800d9a:	72 06                	jb     800da2 <__udivdi3+0x102>
  800d9c:	31 c0                	xor    %eax,%eax
  800d9e:	39 eb                	cmp    %ebp,%ebx
  800da0:	77 d2                	ja     800d74 <__udivdi3+0xd4>
  800da2:	b8 01 00 00 00       	mov    $0x1,%eax
  800da7:	eb cb                	jmp    800d74 <__udivdi3+0xd4>
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	89 d8                	mov    %ebx,%eax
  800db2:	31 ff                	xor    %edi,%edi
  800db4:	eb be                	jmp    800d74 <__udivdi3+0xd4>
  800db6:	66 90                	xchg   %ax,%ax
  800db8:	66 90                	xchg   %ax,%ax
  800dba:	66 90                	xchg   %ax,%ax
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__umoddi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
  800dc7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800dcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800dcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dd7:	85 ed                	test   %ebp,%ebp
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	89 da                	mov    %ebx,%edx
  800ddd:	75 19                	jne    800df8 <__umoddi3+0x38>
  800ddf:	39 df                	cmp    %ebx,%edi
  800de1:	0f 86 b1 00 00 00    	jbe    800e98 <__umoddi3+0xd8>
  800de7:	f7 f7                	div    %edi
  800de9:	89 d0                	mov    %edx,%eax
  800deb:	31 d2                	xor    %edx,%edx
  800ded:	83 c4 1c             	add    $0x1c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	39 dd                	cmp    %ebx,%ebp
  800dfa:	77 f1                	ja     800ded <__umoddi3+0x2d>
  800dfc:	0f bd cd             	bsr    %ebp,%ecx
  800dff:	83 f1 1f             	xor    $0x1f,%ecx
  800e02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e06:	0f 84 b4 00 00 00    	je     800ec0 <__umoddi3+0x100>
  800e0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800e11:	89 c2                	mov    %eax,%edx
  800e13:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e17:	29 c2                	sub    %eax,%edx
  800e19:	89 c1                	mov    %eax,%ecx
  800e1b:	89 f8                	mov    %edi,%eax
  800e1d:	d3 e5                	shl    %cl,%ebp
  800e1f:	89 d1                	mov    %edx,%ecx
  800e21:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e25:	d3 e8                	shr    %cl,%eax
  800e27:	09 c5                	or     %eax,%ebp
  800e29:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e2d:	89 c1                	mov    %eax,%ecx
  800e2f:	d3 e7                	shl    %cl,%edi
  800e31:	89 d1                	mov    %edx,%ecx
  800e33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e37:	89 df                	mov    %ebx,%edi
  800e39:	d3 ef                	shr    %cl,%edi
  800e3b:	89 c1                	mov    %eax,%ecx
  800e3d:	89 f0                	mov    %esi,%eax
  800e3f:	d3 e3                	shl    %cl,%ebx
  800e41:	89 d1                	mov    %edx,%ecx
  800e43:	89 fa                	mov    %edi,%edx
  800e45:	d3 e8                	shr    %cl,%eax
  800e47:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e4c:	09 d8                	or     %ebx,%eax
  800e4e:	f7 f5                	div    %ebp
  800e50:	d3 e6                	shl    %cl,%esi
  800e52:	89 d1                	mov    %edx,%ecx
  800e54:	f7 64 24 08          	mull   0x8(%esp)
  800e58:	39 d1                	cmp    %edx,%ecx
  800e5a:	89 c3                	mov    %eax,%ebx
  800e5c:	89 d7                	mov    %edx,%edi
  800e5e:	72 06                	jb     800e66 <__umoddi3+0xa6>
  800e60:	75 0e                	jne    800e70 <__umoddi3+0xb0>
  800e62:	39 c6                	cmp    %eax,%esi
  800e64:	73 0a                	jae    800e70 <__umoddi3+0xb0>
  800e66:	2b 44 24 08          	sub    0x8(%esp),%eax
  800e6a:	19 ea                	sbb    %ebp,%edx
  800e6c:	89 d7                	mov    %edx,%edi
  800e6e:	89 c3                	mov    %eax,%ebx
  800e70:	89 ca                	mov    %ecx,%edx
  800e72:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e77:	29 de                	sub    %ebx,%esi
  800e79:	19 fa                	sbb    %edi,%edx
  800e7b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800e7f:	89 d0                	mov    %edx,%eax
  800e81:	d3 e0                	shl    %cl,%eax
  800e83:	89 d9                	mov    %ebx,%ecx
  800e85:	d3 ee                	shr    %cl,%esi
  800e87:	d3 ea                	shr    %cl,%edx
  800e89:	09 f0                	or     %esi,%eax
  800e8b:	83 c4 1c             	add    $0x1c,%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    
  800e93:	90                   	nop
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	85 ff                	test   %edi,%edi
  800e9a:	89 f9                	mov    %edi,%ecx
  800e9c:	75 0b                	jne    800ea9 <__umoddi3+0xe9>
  800e9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  800ea5:	f7 f7                	div    %edi
  800ea7:	89 c1                	mov    %eax,%ecx
  800ea9:	89 d8                	mov    %ebx,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f1                	div    %ecx
  800eaf:	89 f0                	mov    %esi,%eax
  800eb1:	f7 f1                	div    %ecx
  800eb3:	e9 31 ff ff ff       	jmp    800de9 <__umoddi3+0x29>
  800eb8:	90                   	nop
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	39 dd                	cmp    %ebx,%ebp
  800ec2:	72 08                	jb     800ecc <__umoddi3+0x10c>
  800ec4:	39 f7                	cmp    %esi,%edi
  800ec6:	0f 87 21 ff ff ff    	ja     800ded <__umoddi3+0x2d>
  800ecc:	89 da                	mov    %ebx,%edx
  800ece:	89 f0                	mov    %esi,%eax
  800ed0:	29 f8                	sub    %edi,%eax
  800ed2:	19 ea                	sbb    %ebp,%edx
  800ed4:	e9 14 ff ff ff       	jmp    800ded <__umoddi3+0x2d>
