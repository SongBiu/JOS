
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 2c 00 00 00       	call   80005d <libmain>
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
  80003a:	e8 1a 00 00 00       	call   800059 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800045:	6a 64                	push   $0x64
  800047:	68 0c 00 10 f0       	push   $0xf010000c
  80004c:	e8 8b 00 00 00       	call   8000dc <sys_cputs>
}
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <__x86.get_pc_thunk.bx>:
  800059:	8b 1c 24             	mov    (%esp),%ebx
  80005c:	c3                   	ret    

0080005d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	e8 ee ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80006b:	81 c3 95 1f 00 00    	add    $0x1f95,%ebx
  800071:	8b 75 08             	mov    0x8(%ebp),%esi
  800074:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800077:	e8 f2 00 00 00       	call   80016e <sys_getenvid>
  80007c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800081:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800084:	c1 e0 05             	shl    $0x5,%eax
  800087:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80008d:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800093:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800095:	85 f6                	test   %esi,%esi
  800097:	7e 08                	jle    8000a1 <libmain+0x44>
		binaryname = argv[0];
  800099:	8b 07                	mov    (%edi),%eax
  80009b:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  8000a1:	83 ec 08             	sub    $0x8,%esp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	e8 88 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ab:	e8 0b 00 00 00       	call   8000bb <exit>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b6:	5b                   	pop    %ebx
  8000b7:	5e                   	pop    %esi
  8000b8:	5f                   	pop    %edi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	53                   	push   %ebx
  8000bf:	83 ec 10             	sub    $0x10,%esp
  8000c2:	e8 92 ff ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8000c7:	81 c3 39 1f 00 00    	add    $0x1f39,%ebx
	sys_env_destroy(0);
  8000cd:	6a 00                	push   $0x0
  8000cf:	e8 45 00 00 00       	call   800119 <sys_env_destroy>
}
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ed:	89 c3                	mov    %eax,%ebx
  8000ef:	89 c7                	mov    %eax,%edi
  8000f1:	89 c6                	mov    %eax,%esi
  8000f3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_cgetc>:

int
sys_cgetc(void)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800100:	ba 00 00 00 00       	mov    $0x0,%edx
  800105:	b8 01 00 00 00       	mov    $0x1,%eax
  80010a:	89 d1                	mov    %edx,%ecx
  80010c:	89 d3                	mov    %edx,%ebx
  80010e:	89 d7                	mov    %edx,%edi
  800110:	89 d6                	mov    %edx,%esi
  800112:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5f                   	pop    %edi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	57                   	push   %edi
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	83 ec 1c             	sub    $0x1c,%esp
  800122:	e8 66 00 00 00       	call   80018d <__x86.get_pc_thunk.ax>
  800127:	05 d9 1e 00 00       	add    $0x1ed9,%eax
  80012c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80012f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800134:	8b 55 08             	mov    0x8(%ebp),%edx
  800137:	b8 03 00 00 00       	mov    $0x3,%eax
  80013c:	89 cb                	mov    %ecx,%ebx
  80013e:	89 cf                	mov    %ecx,%edi
  800140:	89 ce                	mov    %ecx,%esi
  800142:	cd 30                	int    $0x30
	if(check && ret > 0)
  800144:	85 c0                	test   %eax,%eax
  800146:	7f 08                	jg     800150 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	50                   	push   %eax
  800154:	6a 03                	push   $0x3
  800156:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800159:	8d 83 e6 ee ff ff    	lea    -0x111a(%ebx),%eax
  80015f:	50                   	push   %eax
  800160:	6a 26                	push   $0x26
  800162:	8d 83 03 ef ff ff    	lea    -0x10fd(%ebx),%eax
  800168:	50                   	push   %eax
  800169:	e8 23 00 00 00       	call   800191 <_panic>

0080016e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
	asm volatile("int %1\n"
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 02 00 00 00       	mov    $0x2,%eax
  80017e:	89 d1                	mov    %edx,%ecx
  800180:	89 d3                	mov    %edx,%ebx
  800182:	89 d7                	mov    %edx,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800188:	5b                   	pop    %ebx
  800189:	5e                   	pop    %esi
  80018a:	5f                   	pop    %edi
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <__x86.get_pc_thunk.ax>:
  80018d:	8b 04 24             	mov    (%esp),%eax
  800190:	c3                   	ret    

00800191 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	e8 ba fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80019f:	81 c3 61 1e 00 00    	add    $0x1e61,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001a5:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a8:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8001ae:	8b 38                	mov    (%eax),%edi
  8001b0:	e8 b9 ff ff ff       	call   80016e <sys_getenvid>
  8001b5:	83 ec 0c             	sub    $0xc,%esp
  8001b8:	ff 75 0c             	pushl  0xc(%ebp)
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	57                   	push   %edi
  8001bf:	50                   	push   %eax
  8001c0:	8d 83 14 ef ff ff    	lea    -0x10ec(%ebx),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 d1 00 00 00       	call   80029d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	83 c4 18             	add    $0x18,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 10             	pushl  0x10(%ebp)
  8001d3:	e8 63 00 00 00       	call   80023b <vcprintf>
	cprintf("\n");
  8001d8:	8d 83 38 ef ff ff    	lea    -0x10c8(%ebx),%eax
  8001de:	89 04 24             	mov    %eax,(%esp)
  8001e1:	e8 b7 00 00 00       	call   80029d <cprintf>
  8001e6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e9:	cc                   	int3   
  8001ea:	eb fd                	jmp    8001e9 <_panic+0x58>

008001ec <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	e8 63 fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8001f6:	81 c3 0a 1e 00 00    	add    $0x1e0a,%ebx
  8001fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001ff:	8b 16                	mov    (%esi),%edx
  800201:	8d 42 01             	lea    0x1(%edx),%eax
  800204:	89 06                	mov    %eax,(%esi)
  800206:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800209:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  80020d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800212:	74 0b                	je     80021f <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800214:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800218:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5d                   	pop    %ebp
  80021e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	68 ff 00 00 00       	push   $0xff
  800227:	8d 46 08             	lea    0x8(%esi),%eax
  80022a:	50                   	push   %eax
  80022b:	e8 ac fe ff ff       	call   8000dc <sys_cputs>
		b->idx = 0;
  800230:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	eb d9                	jmp    800214 <putch+0x28>

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	53                   	push   %ebx
  80023f:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800245:	e8 0f fe ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  80024a:	81 c3 b6 1d 00 00    	add    $0x1db6,%ebx
	struct printbuf b;

	b.idx = 0;
  800250:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800257:	00 00 00 
	b.cnt = 0;
  80025a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800261:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800264:	ff 75 0c             	pushl  0xc(%ebp)
  800267:	ff 75 08             	pushl  0x8(%ebp)
  80026a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	8d 83 ec e1 ff ff    	lea    -0x1e14(%ebx),%eax
  800277:	50                   	push   %eax
  800278:	e8 38 01 00 00       	call   8003b5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027d:	83 c4 08             	add    $0x8,%esp
  800280:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800286:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80028c:	50                   	push   %eax
  80028d:	e8 4a fe ff ff       	call   8000dc <sys_cputs>
	return b.cnt;
}
  800292:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800298:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029b:	c9                   	leave  
  80029c:	c3                   	ret    

0080029d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a6:	50                   	push   %eax
  8002a7:	ff 75 08             	pushl  0x8(%ebp)
  8002aa:	e8 8c ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 2c             	sub    $0x2c,%esp
  8002ba:	e8 63 06 00 00       	call   800922 <__x86.get_pc_thunk.cx>
  8002bf:	81 c1 41 1d 00 00    	add    $0x1d41,%ecx
  8002c5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002c8:	89 c7                	mov    %eax,%edi
  8002ca:	89 d6                	mov    %edx,%esi
  8002cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002e3:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002e6:	39 d3                	cmp    %edx,%ebx
  8002e8:	72 09                	jb     8002f3 <printnum+0x42>
  8002ea:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ed:	0f 87 83 00 00 00    	ja     800376 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f3:	83 ec 0c             	sub    $0xc,%esp
  8002f6:	ff 75 18             	pushl  0x18(%ebp)
  8002f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002ff:	53                   	push   %ebx
  800300:	ff 75 10             	pushl  0x10(%ebp)
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	ff 75 dc             	pushl  -0x24(%ebp)
  800309:	ff 75 d8             	pushl  -0x28(%ebp)
  80030c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80030f:	ff 75 d0             	pushl  -0x30(%ebp)
  800312:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800315:	e8 86 09 00 00       	call   800ca0 <__udivdi3>
  80031a:	83 c4 18             	add    $0x18,%esp
  80031d:	52                   	push   %edx
  80031e:	50                   	push   %eax
  80031f:	89 f2                	mov    %esi,%edx
  800321:	89 f8                	mov    %edi,%eax
  800323:	e8 89 ff ff ff       	call   8002b1 <printnum>
  800328:	83 c4 20             	add    $0x20,%esp
  80032b:	eb 13                	jmp    800340 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032d:	83 ec 08             	sub    $0x8,%esp
  800330:	56                   	push   %esi
  800331:	ff 75 18             	pushl  0x18(%ebp)
  800334:	ff d7                	call   *%edi
  800336:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800339:	83 eb 01             	sub    $0x1,%ebx
  80033c:	85 db                	test   %ebx,%ebx
  80033e:	7f ed                	jg     80032d <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800340:	83 ec 08             	sub    $0x8,%esp
  800343:	56                   	push   %esi
  800344:	83 ec 04             	sub    $0x4,%esp
  800347:	ff 75 dc             	pushl  -0x24(%ebp)
  80034a:	ff 75 d8             	pushl  -0x28(%ebp)
  80034d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800350:	ff 75 d0             	pushl  -0x30(%ebp)
  800353:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800356:	89 f3                	mov    %esi,%ebx
  800358:	e8 63 0a 00 00       	call   800dc0 <__umoddi3>
  80035d:	83 c4 14             	add    $0x14,%esp
  800360:	0f be 84 06 3a ef ff 	movsbl -0x10c6(%esi,%eax,1),%eax
  800367:	ff 
  800368:	50                   	push   %eax
  800369:	ff d7                	call   *%edi
}
  80036b:	83 c4 10             	add    $0x10,%esp
  80036e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    
  800376:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800379:	eb be                	jmp    800339 <printnum+0x88>

0080037b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800381:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800385:	8b 10                	mov    (%eax),%edx
  800387:	3b 50 04             	cmp    0x4(%eax),%edx
  80038a:	73 0a                	jae    800396 <sprintputch+0x1b>
		*b->buf++ = ch;
  80038c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038f:	89 08                	mov    %ecx,(%eax)
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	88 02                	mov    %al,(%edx)
}
  800396:	5d                   	pop    %ebp
  800397:	c3                   	ret    

00800398 <printfmt>:
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80039e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003a1:	50                   	push   %eax
  8003a2:	ff 75 10             	pushl  0x10(%ebp)
  8003a5:	ff 75 0c             	pushl  0xc(%ebp)
  8003a8:	ff 75 08             	pushl  0x8(%ebp)
  8003ab:	e8 05 00 00 00       	call   8003b5 <vprintfmt>
}
  8003b0:	83 c4 10             	add    $0x10,%esp
  8003b3:	c9                   	leave  
  8003b4:	c3                   	ret    

008003b5 <vprintfmt>:
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	57                   	push   %edi
  8003b9:	56                   	push   %esi
  8003ba:	53                   	push   %ebx
  8003bb:	83 ec 2c             	sub    $0x2c,%esp
  8003be:	e8 96 fc ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8003c3:	81 c3 3d 1c 00 00    	add    $0x1c3d,%ebx
  8003c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003cc:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003d3:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d5:	8d 77 01             	lea    0x1(%edi),%esi
  8003d8:	0f b6 07             	movzbl (%edi),%eax
  8003db:	83 f8 25             	cmp    $0x25,%eax
  8003de:	74 1c                	je     8003fc <vprintfmt+0x47>
			if (ch == '\0')
  8003e0:	85 c0                	test   %eax,%eax
  8003e2:	0f 84 b9 04 00 00    	je     8008a1 <.L21+0x20>
			putch(ch, putdat);
  8003e8:	83 ec 08             	sub    $0x8,%esp
  8003eb:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003ee:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003f1:	50                   	push   %eax
  8003f2:	ff 55 08             	call   *0x8(%ebp)
  8003f5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f8:	89 f7                	mov    %esi,%edi
  8003fa:	eb d9                	jmp    8003d5 <vprintfmt+0x20>
		padc = ' ';
  8003fc:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  800400:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800407:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  80040e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800415:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8d 7e 01             	lea    0x1(%esi),%edi
  800420:	0f b6 16             	movzbl (%esi),%edx
  800423:	8d 42 dd             	lea    -0x23(%edx),%eax
  800426:	3c 55                	cmp    $0x55,%al
  800428:	0f 87 53 04 00 00    	ja     800881 <.L21>
  80042e:	0f b6 c0             	movzbl %al,%eax
  800431:	89 d9                	mov    %ebx,%ecx
  800433:	03 8c 83 c8 ef ff ff 	add    -0x1038(%ebx,%eax,4),%ecx
  80043a:	ff e1                	jmp    *%ecx

0080043c <.L73>:
  80043c:	89 fe                	mov    %edi,%esi
			padc = '-';
  80043e:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  800442:	eb d9                	jmp    80041d <vprintfmt+0x68>

00800444 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	89 fe                	mov    %edi,%esi
			padc = '0';
  800446:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  80044a:	eb d1                	jmp    80041d <vprintfmt+0x68>

0080044c <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	0f b6 d2             	movzbl %dl,%edx
  80044f:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  800451:	b8 00 00 00 00       	mov    $0x0,%eax
  800456:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800459:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80045c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800460:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800463:	8d 7a d0             	lea    -0x30(%edx),%edi
  800466:	83 ff 09             	cmp    $0x9,%edi
  800469:	0f 87 94 00 00 00    	ja     800503 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  80046f:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  800472:	eb e5                	jmp    800459 <.L28+0xd>

00800474 <.L25>:
			precision = va_arg(ap, int);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8b 00                	mov    (%eax),%eax
  800479:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 40 04             	lea    0x4(%eax),%eax
  800482:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800485:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800487:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048b:	79 90                	jns    80041d <vprintfmt+0x68>
				width = precision, precision = -1;
  80048d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800490:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800493:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80049a:	eb 81                	jmp    80041d <vprintfmt+0x68>

0080049c <.L26>:
  80049c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a6:	0f 49 d0             	cmovns %eax,%edx
  8004a9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004ac:	89 fe                	mov    %edi,%esi
  8004ae:	e9 6a ff ff ff       	jmp    80041d <vprintfmt+0x68>

008004b3 <.L22>:
  8004b3:	89 fe                	mov    %edi,%esi
			altflag = 1;
  8004b5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004bc:	e9 5c ff ff ff       	jmp    80041d <vprintfmt+0x68>

008004c1 <.L33>:
  8004c1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004c4:	83 f9 01             	cmp    $0x1,%ecx
  8004c7:	7e 16                	jle    8004df <.L33+0x1e>
		return va_arg(*ap, long long);
  8004c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cc:	8b 00                	mov    (%eax),%eax
  8004ce:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004d1:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004d4:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004da:	e9 f6 fe ff ff       	jmp    8003d5 <vprintfmt+0x20>
	else if (lflag)
  8004df:	85 c9                	test   %ecx,%ecx
  8004e1:	75 10                	jne    8004f3 <.L33+0x32>
		return va_arg(*ap, int);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8b 00                	mov    (%eax),%eax
  8004e8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004eb:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004ee:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f1:	eb e4                	jmp    8004d7 <.L33+0x16>
		return va_arg(*ap, long);
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8b 00                	mov    (%eax),%eax
  8004f8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004fb:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004fe:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800501:	eb d4                	jmp    8004d7 <.L33+0x16>
  800503:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800506:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800509:	e9 79 ff ff ff       	jmp    800487 <.L25+0x13>

0080050e <.L32>:
			lflag++;
  80050e:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800512:	89 fe                	mov    %edi,%esi
			goto reswitch;
  800514:	e9 04 ff ff ff       	jmp    80041d <vprintfmt+0x68>

00800519 <.L29>:
			putch(va_arg(ap, int), putdat);
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 70 04             	lea    0x4(%eax),%esi
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	ff 30                	pushl  (%eax)
  800527:	ff 55 08             	call   *0x8(%ebp)
			break;
  80052a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80052d:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  800530:	e9 a0 fe ff ff       	jmp    8003d5 <vprintfmt+0x20>

00800535 <.L31>:
			err = va_arg(ap, int);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 70 04             	lea    0x4(%eax),%esi
  80053b:	8b 00                	mov    (%eax),%eax
  80053d:	99                   	cltd   
  80053e:	31 d0                	xor    %edx,%eax
  800540:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800542:	83 f8 06             	cmp    $0x6,%eax
  800545:	7f 29                	jg     800570 <.L31+0x3b>
  800547:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  80054e:	85 d2                	test   %edx,%edx
  800550:	74 1e                	je     800570 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  800552:	52                   	push   %edx
  800553:	8d 83 5b ef ff ff    	lea    -0x10a5(%ebx),%eax
  800559:	50                   	push   %eax
  80055a:	ff 75 0c             	pushl  0xc(%ebp)
  80055d:	ff 75 08             	pushl  0x8(%ebp)
  800560:	e8 33 fe ff ff       	call   800398 <printfmt>
  800565:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800568:	89 75 14             	mov    %esi,0x14(%ebp)
  80056b:	e9 65 fe ff ff       	jmp    8003d5 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  800570:	50                   	push   %eax
  800571:	8d 83 52 ef ff ff    	lea    -0x10ae(%ebx),%eax
  800577:	50                   	push   %eax
  800578:	ff 75 0c             	pushl  0xc(%ebp)
  80057b:	ff 75 08             	pushl  0x8(%ebp)
  80057e:	e8 15 fe ff ff       	call   800398 <printfmt>
  800583:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800586:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800589:	e9 47 fe ff ff       	jmp    8003d5 <vprintfmt+0x20>

0080058e <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	83 c0 04             	add    $0x4,%eax
  800594:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  80059c:	85 f6                	test   %esi,%esi
  80059e:	8d 83 4b ef ff ff    	lea    -0x10b5(%ebx),%eax
  8005a4:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ab:	0f 8e b4 00 00 00    	jle    800665 <.L36+0xd7>
  8005b1:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005b5:	75 08                	jne    8005bf <.L36+0x31>
  8005b7:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005ba:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005bd:	eb 6c                	jmp    80062b <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bf:	83 ec 08             	sub    $0x8,%esp
  8005c2:	ff 75 cc             	pushl  -0x34(%ebp)
  8005c5:	56                   	push   %esi
  8005c6:	e8 73 03 00 00       	call   80093e <strnlen>
  8005cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ce:	29 c2                	sub    %eax,%edx
  8005d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005d3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005d6:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005da:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005dd:	89 d6                	mov    %edx,%esi
  8005df:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005e2:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e4:	eb 10                	jmp    8005f6 <.L36+0x68>
					putch(padc, putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	ff 75 0c             	pushl  0xc(%ebp)
  8005ec:	57                   	push   %edi
  8005ed:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f0:	83 ee 01             	sub    $0x1,%esi
  8005f3:	83 c4 10             	add    $0x10,%esp
  8005f6:	85 f6                	test   %esi,%esi
  8005f8:	7f ec                	jg     8005e6 <.L36+0x58>
  8005fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800600:	85 d2                	test   %edx,%edx
  800602:	b8 00 00 00 00       	mov    $0x0,%eax
  800607:	0f 49 c2             	cmovns %edx,%eax
  80060a:	29 c2                	sub    %eax,%edx
  80060c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80060f:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800612:	eb 17                	jmp    80062b <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  800614:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800618:	75 30                	jne    80064a <.L36+0xbc>
					putch(ch, putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	ff 75 0c             	pushl  0xc(%ebp)
  800620:	50                   	push   %eax
  800621:	ff 55 08             	call   *0x8(%ebp)
  800624:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800627:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80062b:	83 c6 01             	add    $0x1,%esi
  80062e:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800632:	0f be c2             	movsbl %dl,%eax
  800635:	85 c0                	test   %eax,%eax
  800637:	74 58                	je     800691 <.L36+0x103>
  800639:	85 ff                	test   %edi,%edi
  80063b:	78 d7                	js     800614 <.L36+0x86>
  80063d:	83 ef 01             	sub    $0x1,%edi
  800640:	79 d2                	jns    800614 <.L36+0x86>
  800642:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800645:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800648:	eb 32                	jmp    80067c <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  80064a:	0f be d2             	movsbl %dl,%edx
  80064d:	83 ea 20             	sub    $0x20,%edx
  800650:	83 fa 5e             	cmp    $0x5e,%edx
  800653:	76 c5                	jbe    80061a <.L36+0x8c>
					putch('?', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	ff 75 0c             	pushl  0xc(%ebp)
  80065b:	6a 3f                	push   $0x3f
  80065d:	ff 55 08             	call   *0x8(%ebp)
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb c2                	jmp    800627 <.L36+0x99>
  800665:	89 7d 10             	mov    %edi,0x10(%ebp)
  800668:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80066b:	eb be                	jmp    80062b <.L36+0x9d>
				putch(' ', putdat);
  80066d:	83 ec 08             	sub    $0x8,%esp
  800670:	57                   	push   %edi
  800671:	6a 20                	push   $0x20
  800673:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800676:	83 ee 01             	sub    $0x1,%esi
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	85 f6                	test   %esi,%esi
  80067e:	7f ed                	jg     80066d <.L36+0xdf>
  800680:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800683:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800686:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
  80068c:	e9 44 fd ff ff       	jmp    8003d5 <vprintfmt+0x20>
  800691:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800694:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800697:	eb e3                	jmp    80067c <.L36+0xee>

00800699 <.L30>:
  800699:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80069c:	83 f9 01             	cmp    $0x1,%ecx
  80069f:	7e 42                	jle    8006e3 <.L30+0x4a>
		return va_arg(*ap, long long);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8b 50 04             	mov    0x4(%eax),%edx
  8006a7:	8b 00                	mov    (%eax),%eax
  8006a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 40 08             	lea    0x8(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006bc:	79 5f                	jns    80071d <.L30+0x84>
				putch('-', putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	6a 2d                	push   $0x2d
  8006c6:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006cc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006cf:	f7 da                	neg    %edx
  8006d1:	83 d1 00             	adc    $0x0,%ecx
  8006d4:	f7 d9                	neg    %ecx
  8006d6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006de:	e9 b8 00 00 00       	jmp    80079b <.L34+0x22>
	else if (lflag)
  8006e3:	85 c9                	test   %ecx,%ecx
  8006e5:	75 1b                	jne    800702 <.L30+0x69>
		return va_arg(*ap, int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 30                	mov    (%eax),%esi
  8006ec:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006ef:	89 f0                	mov    %esi,%eax
  8006f1:	c1 f8 1f             	sar    $0x1f,%eax
  8006f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 40 04             	lea    0x4(%eax),%eax
  8006fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800700:	eb b6                	jmp    8006b8 <.L30+0x1f>
		return va_arg(*ap, long);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8b 30                	mov    (%eax),%esi
  800707:	89 75 d8             	mov    %esi,-0x28(%ebp)
  80070a:	89 f0                	mov    %esi,%eax
  80070c:	c1 f8 1f             	sar    $0x1f,%eax
  80070f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 40 04             	lea    0x4(%eax),%eax
  800718:	89 45 14             	mov    %eax,0x14(%ebp)
  80071b:	eb 9b                	jmp    8006b8 <.L30+0x1f>
			num = getint(&ap, lflag);
  80071d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800720:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800723:	b8 0a 00 00 00       	mov    $0xa,%eax
  800728:	eb 71                	jmp    80079b <.L34+0x22>

0080072a <.L37>:
  80072a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80072d:	83 f9 01             	cmp    $0x1,%ecx
  800730:	7e 15                	jle    800747 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	8b 48 04             	mov    0x4(%eax),%ecx
  80073a:	8d 40 08             	lea    0x8(%eax),%eax
  80073d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800740:	b8 0a 00 00 00       	mov    $0xa,%eax
  800745:	eb 54                	jmp    80079b <.L34+0x22>
	else if (lflag)
  800747:	85 c9                	test   %ecx,%ecx
  800749:	75 17                	jne    800762 <.L37+0x38>
		return va_arg(*ap, unsigned int);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	8b 10                	mov    (%eax),%edx
  800750:	b9 00 00 00 00       	mov    $0x0,%ecx
  800755:	8d 40 04             	lea    0x4(%eax),%eax
  800758:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80075b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800760:	eb 39                	jmp    80079b <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 10                	mov    (%eax),%edx
  800767:	b9 00 00 00 00       	mov    $0x0,%ecx
  80076c:	8d 40 04             	lea    0x4(%eax),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800772:	b8 0a 00 00 00       	mov    $0xa,%eax
  800777:	eb 22                	jmp    80079b <.L34+0x22>

00800779 <.L34>:
  800779:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80077c:	83 f9 01             	cmp    $0x1,%ecx
  80077f:	7e 3b                	jle    8007bc <.L34+0x43>
		return va_arg(*ap, long long);
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8b 50 04             	mov    0x4(%eax),%edx
  800787:	8b 00                	mov    (%eax),%eax
  800789:	8b 4d 14             	mov    0x14(%ebp),%ecx
  80078c:	8d 49 08             	lea    0x8(%ecx),%ecx
  80078f:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  800792:	89 d1                	mov    %edx,%ecx
  800794:	89 c2                	mov    %eax,%edx
			base = 8;
  800796:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  80079b:	83 ec 0c             	sub    $0xc,%esp
  80079e:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  8007a2:	56                   	push   %esi
  8007a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a6:	50                   	push   %eax
  8007a7:	51                   	push   %ecx
  8007a8:	52                   	push   %edx
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8007af:	e8 fd fa ff ff       	call   8002b1 <printnum>
			break;
  8007b4:	83 c4 20             	add    $0x20,%esp
  8007b7:	e9 19 fc ff ff       	jmp    8003d5 <vprintfmt+0x20>
	else if (lflag)
  8007bc:	85 c9                	test   %ecx,%ecx
  8007be:	75 13                	jne    8007d3 <.L34+0x5a>
		return va_arg(*ap, int);
  8007c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c3:	8b 10                	mov    (%eax),%edx
  8007c5:	89 d0                	mov    %edx,%eax
  8007c7:	99                   	cltd   
  8007c8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007cb:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007ce:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007d1:	eb bf                	jmp    800792 <.L34+0x19>
		return va_arg(*ap, long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8b 10                	mov    (%eax),%edx
  8007d8:	89 d0                	mov    %edx,%eax
  8007da:	99                   	cltd   
  8007db:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007de:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007e1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007e4:	eb ac                	jmp    800792 <.L34+0x19>

008007e6 <.L35>:
			putch('0', putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	6a 30                	push   $0x30
  8007ee:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	ff 75 0c             	pushl  0xc(%ebp)
  8007f7:	6a 78                	push   $0x78
  8007f9:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8b 10                	mov    (%eax),%edx
  800801:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800806:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800809:	8d 40 04             	lea    0x4(%eax),%eax
  80080c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800814:	eb 85                	jmp    80079b <.L34+0x22>

00800816 <.L38>:
  800816:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800819:	83 f9 01             	cmp    $0x1,%ecx
  80081c:	7e 18                	jle    800836 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8b 10                	mov    (%eax),%edx
  800823:	8b 48 04             	mov    0x4(%eax),%ecx
  800826:	8d 40 08             	lea    0x8(%eax),%eax
  800829:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082c:	b8 10 00 00 00       	mov    $0x10,%eax
  800831:	e9 65 ff ff ff       	jmp    80079b <.L34+0x22>
	else if (lflag)
  800836:	85 c9                	test   %ecx,%ecx
  800838:	75 1a                	jne    800854 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  80083a:	8b 45 14             	mov    0x14(%ebp),%eax
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800844:	8d 40 04             	lea    0x4(%eax),%eax
  800847:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80084a:	b8 10 00 00 00       	mov    $0x10,%eax
  80084f:	e9 47 ff ff ff       	jmp    80079b <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800854:	8b 45 14             	mov    0x14(%ebp),%eax
  800857:	8b 10                	mov    (%eax),%edx
  800859:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085e:	8d 40 04             	lea    0x4(%eax),%eax
  800861:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800864:	b8 10 00 00 00       	mov    $0x10,%eax
  800869:	e9 2d ff ff ff       	jmp    80079b <.L34+0x22>

0080086e <.L24>:
			putch(ch, putdat);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	ff 75 0c             	pushl  0xc(%ebp)
  800874:	6a 25                	push   $0x25
  800876:	ff 55 08             	call   *0x8(%ebp)
			break;
  800879:	83 c4 10             	add    $0x10,%esp
  80087c:	e9 54 fb ff ff       	jmp    8003d5 <vprintfmt+0x20>

00800881 <.L21>:
			putch('%', putdat);
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	ff 75 0c             	pushl  0xc(%ebp)
  800887:	6a 25                	push   $0x25
  800889:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088c:	83 c4 10             	add    $0x10,%esp
  80088f:	89 f7                	mov    %esi,%edi
  800891:	eb 03                	jmp    800896 <.L21+0x15>
  800893:	83 ef 01             	sub    $0x1,%edi
  800896:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80089a:	75 f7                	jne    800893 <.L21+0x12>
  80089c:	e9 34 fb ff ff       	jmp    8003d5 <vprintfmt+0x20>
}
  8008a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a4:	5b                   	pop    %ebx
  8008a5:	5e                   	pop    %esi
  8008a6:	5f                   	pop    %edi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	83 ec 14             	sub    $0x14,%esp
  8008b0:	e8 a4 f7 ff ff       	call   800059 <__x86.get_pc_thunk.bx>
  8008b5:	81 c3 4b 17 00 00    	add    $0x174b,%ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008c4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d2:	85 c0                	test   %eax,%eax
  8008d4:	74 2b                	je     800901 <vsnprintf+0x58>
  8008d6:	85 d2                	test   %edx,%edx
  8008d8:	7e 27                	jle    800901 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008da:	ff 75 14             	pushl  0x14(%ebp)
  8008dd:	ff 75 10             	pushl  0x10(%ebp)
  8008e0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e3:	50                   	push   %eax
  8008e4:	8d 83 7b e3 ff ff    	lea    -0x1c85(%ebx),%eax
  8008ea:	50                   	push   %eax
  8008eb:	e8 c5 fa ff ff       	call   8003b5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f9:	83 c4 10             	add    $0x10,%esp
}
  8008fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ff:	c9                   	leave  
  800900:	c3                   	ret    
		return -E_INVAL;
  800901:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800906:	eb f4                	jmp    8008fc <vsnprintf+0x53>

00800908 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800911:	50                   	push   %eax
  800912:	ff 75 10             	pushl  0x10(%ebp)
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	ff 75 08             	pushl  0x8(%ebp)
  80091b:	e8 89 ff ff ff       	call   8008a9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <__x86.get_pc_thunk.cx>:
  800922:	8b 0c 24             	mov    (%esp),%ecx
  800925:	c3                   	ret    

00800926 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	eb 03                	jmp    800936 <strlen+0x10>
		n++;
  800933:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800936:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093a:	75 f7                	jne    800933 <strlen+0xd>
	return n;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
  80094c:	eb 03                	jmp    800951 <strnlen+0x13>
		n++;
  80094e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800951:	39 d0                	cmp    %edx,%eax
  800953:	74 06                	je     80095b <strnlen+0x1d>
  800955:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800959:	75 f3                	jne    80094e <strnlen+0x10>
	return n;
}
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	53                   	push   %ebx
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800967:	89 c2                	mov    %eax,%edx
  800969:	83 c1 01             	add    $0x1,%ecx
  80096c:	83 c2 01             	add    $0x1,%edx
  80096f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800973:	88 5a ff             	mov    %bl,-0x1(%edx)
  800976:	84 db                	test   %bl,%bl
  800978:	75 ef                	jne    800969 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80097a:	5b                   	pop    %ebx
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	53                   	push   %ebx
  800981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800984:	53                   	push   %ebx
  800985:	e8 9c ff ff ff       	call   800926 <strlen>
  80098a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80098d:	ff 75 0c             	pushl  0xc(%ebp)
  800990:	01 d8                	add    %ebx,%eax
  800992:	50                   	push   %eax
  800993:	e8 c5 ff ff ff       	call   80095d <strcpy>
	return dst;
}
  800998:	89 d8                	mov    %ebx,%eax
  80099a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    

0080099f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009aa:	89 f3                	mov    %esi,%ebx
  8009ac:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009af:	89 f2                	mov    %esi,%edx
  8009b1:	eb 0f                	jmp    8009c2 <strncpy+0x23>
		*dst++ = *src;
  8009b3:	83 c2 01             	add    $0x1,%edx
  8009b6:	0f b6 01             	movzbl (%ecx),%eax
  8009b9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009bc:	80 39 01             	cmpb   $0x1,(%ecx)
  8009bf:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009c2:	39 da                	cmp    %ebx,%edx
  8009c4:	75 ed                	jne    8009b3 <strncpy+0x14>
	}
	return ret;
}
  8009c6:	89 f0                	mov    %esi,%eax
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009da:	89 f0                	mov    %esi,%eax
  8009dc:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e0:	85 c9                	test   %ecx,%ecx
  8009e2:	75 0b                	jne    8009ef <strlcpy+0x23>
  8009e4:	eb 17                	jmp    8009fd <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e6:	83 c2 01             	add    $0x1,%edx
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009ef:	39 d8                	cmp    %ebx,%eax
  8009f1:	74 07                	je     8009fa <strlcpy+0x2e>
  8009f3:	0f b6 0a             	movzbl (%edx),%ecx
  8009f6:	84 c9                	test   %cl,%cl
  8009f8:	75 ec                	jne    8009e6 <strlcpy+0x1a>
		*dst = '\0';
  8009fa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009fd:	29 f0                	sub    %esi,%eax
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0c:	eb 06                	jmp    800a14 <strcmp+0x11>
		p++, q++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
  800a11:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a14:	0f b6 01             	movzbl (%ecx),%eax
  800a17:	84 c0                	test   %al,%al
  800a19:	74 04                	je     800a1f <strcmp+0x1c>
  800a1b:	3a 02                	cmp    (%edx),%al
  800a1d:	74 ef                	je     800a0e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1f:	0f b6 c0             	movzbl %al,%eax
  800a22:	0f b6 12             	movzbl (%edx),%edx
  800a25:	29 d0                	sub    %edx,%eax
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	53                   	push   %ebx
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a33:	89 c3                	mov    %eax,%ebx
  800a35:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a38:	eb 06                	jmp    800a40 <strncmp+0x17>
		n--, p++, q++;
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a40:	39 d8                	cmp    %ebx,%eax
  800a42:	74 16                	je     800a5a <strncmp+0x31>
  800a44:	0f b6 08             	movzbl (%eax),%ecx
  800a47:	84 c9                	test   %cl,%cl
  800a49:	74 04                	je     800a4f <strncmp+0x26>
  800a4b:	3a 0a                	cmp    (%edx),%cl
  800a4d:	74 eb                	je     800a3a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4f:	0f b6 00             	movzbl (%eax),%eax
  800a52:	0f b6 12             	movzbl (%edx),%edx
  800a55:	29 d0                	sub    %edx,%eax
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    
		return 0;
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	eb f6                	jmp    800a57 <strncmp+0x2e>

00800a61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6b:	0f b6 10             	movzbl (%eax),%edx
  800a6e:	84 d2                	test   %dl,%dl
  800a70:	74 09                	je     800a7b <strchr+0x1a>
		if (*s == c)
  800a72:	38 ca                	cmp    %cl,%dl
  800a74:	74 0a                	je     800a80 <strchr+0x1f>
	for (; *s; s++)
  800a76:	83 c0 01             	add    $0x1,%eax
  800a79:	eb f0                	jmp    800a6b <strchr+0xa>
			return (char *) s;
	return 0;
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a8c:	eb 03                	jmp    800a91 <strfind+0xf>
  800a8e:	83 c0 01             	add    $0x1,%eax
  800a91:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a94:	38 ca                	cmp    %cl,%dl
  800a96:	74 04                	je     800a9c <strfind+0x1a>
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	75 f2                	jne    800a8e <strfind+0xc>
			break;
	return (char *) s;
}
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aaa:	85 c9                	test   %ecx,%ecx
  800aac:	74 13                	je     800ac1 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab4:	75 05                	jne    800abb <memset+0x1d>
  800ab6:	f6 c1 03             	test   $0x3,%cl
  800ab9:	74 0d                	je     800ac8 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800abb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abe:	fc                   	cld    
  800abf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac1:	89 f8                	mov    %edi,%eax
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5f                   	pop    %edi
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    
		c &= 0xFF;
  800ac8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800acc:	89 d3                	mov    %edx,%ebx
  800ace:	c1 e3 08             	shl    $0x8,%ebx
  800ad1:	89 d0                	mov    %edx,%eax
  800ad3:	c1 e0 18             	shl    $0x18,%eax
  800ad6:	89 d6                	mov    %edx,%esi
  800ad8:	c1 e6 10             	shl    $0x10,%esi
  800adb:	09 f0                	or     %esi,%eax
  800add:	09 c2                	or     %eax,%edx
  800adf:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ae1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ae4:	89 d0                	mov    %edx,%eax
  800ae6:	fc                   	cld    
  800ae7:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae9:	eb d6                	jmp    800ac1 <memset+0x23>

00800aeb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af9:	39 c6                	cmp    %eax,%esi
  800afb:	73 35                	jae    800b32 <memmove+0x47>
  800afd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b00:	39 c2                	cmp    %eax,%edx
  800b02:	76 2e                	jbe    800b32 <memmove+0x47>
		s += n;
		d += n;
  800b04:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b07:	89 d6                	mov    %edx,%esi
  800b09:	09 fe                	or     %edi,%esi
  800b0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b11:	74 0c                	je     800b1f <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b13:	83 ef 01             	sub    $0x1,%edi
  800b16:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b19:	fd                   	std    
  800b1a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b1c:	fc                   	cld    
  800b1d:	eb 21                	jmp    800b40 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	f6 c1 03             	test   $0x3,%cl
  800b22:	75 ef                	jne    800b13 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b24:	83 ef 04             	sub    $0x4,%edi
  800b27:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b2d:	fd                   	std    
  800b2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b30:	eb ea                	jmp    800b1c <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b32:	89 f2                	mov    %esi,%edx
  800b34:	09 c2                	or     %eax,%edx
  800b36:	f6 c2 03             	test   $0x3,%dl
  800b39:	74 09                	je     800b44 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b3b:	89 c7                	mov    %eax,%edi
  800b3d:	fc                   	cld    
  800b3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b44:	f6 c1 03             	test   $0x3,%cl
  800b47:	75 f2                	jne    800b3b <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b49:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	fc                   	cld    
  800b4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b51:	eb ed                	jmp    800b40 <memmove+0x55>

00800b53 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b56:	ff 75 10             	pushl  0x10(%ebp)
  800b59:	ff 75 0c             	pushl  0xc(%ebp)
  800b5c:	ff 75 08             	pushl  0x8(%ebp)
  800b5f:	e8 87 ff ff ff       	call   800aeb <memmove>
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b71:	89 c6                	mov    %eax,%esi
  800b73:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b76:	39 f0                	cmp    %esi,%eax
  800b78:	74 1c                	je     800b96 <memcmp+0x30>
		if (*s1 != *s2)
  800b7a:	0f b6 08             	movzbl (%eax),%ecx
  800b7d:	0f b6 1a             	movzbl (%edx),%ebx
  800b80:	38 d9                	cmp    %bl,%cl
  800b82:	75 08                	jne    800b8c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b84:	83 c0 01             	add    $0x1,%eax
  800b87:	83 c2 01             	add    $0x1,%edx
  800b8a:	eb ea                	jmp    800b76 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b8c:	0f b6 c1             	movzbl %cl,%eax
  800b8f:	0f b6 db             	movzbl %bl,%ebx
  800b92:	29 d8                	sub    %ebx,%eax
  800b94:	eb 05                	jmp    800b9b <memcmp+0x35>
	}

	return 0;
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ba8:	89 c2                	mov    %eax,%edx
  800baa:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bad:	39 d0                	cmp    %edx,%eax
  800baf:	73 09                	jae    800bba <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb1:	38 08                	cmp    %cl,(%eax)
  800bb3:	74 05                	je     800bba <memfind+0x1b>
	for (; s < ends; s++)
  800bb5:	83 c0 01             	add    $0x1,%eax
  800bb8:	eb f3                	jmp    800bad <memfind+0xe>
			break;
	return (void *) s;
}
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
  800bc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc8:	eb 03                	jmp    800bcd <strtol+0x11>
		s++;
  800bca:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bcd:	0f b6 01             	movzbl (%ecx),%eax
  800bd0:	3c 20                	cmp    $0x20,%al
  800bd2:	74 f6                	je     800bca <strtol+0xe>
  800bd4:	3c 09                	cmp    $0x9,%al
  800bd6:	74 f2                	je     800bca <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bd8:	3c 2b                	cmp    $0x2b,%al
  800bda:	74 2e                	je     800c0a <strtol+0x4e>
	int neg = 0;
  800bdc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800be1:	3c 2d                	cmp    $0x2d,%al
  800be3:	74 2f                	je     800c14 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800beb:	75 05                	jne    800bf2 <strtol+0x36>
  800bed:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf0:	74 2c                	je     800c1e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf2:	85 db                	test   %ebx,%ebx
  800bf4:	75 0a                	jne    800c00 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bf6:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bfb:	80 39 30             	cmpb   $0x30,(%ecx)
  800bfe:	74 28                	je     800c28 <strtol+0x6c>
		base = 10;
  800c00:	b8 00 00 00 00       	mov    $0x0,%eax
  800c05:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c08:	eb 50                	jmp    800c5a <strtol+0x9e>
		s++;
  800c0a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c0d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c12:	eb d1                	jmp    800be5 <strtol+0x29>
		s++, neg = 1;
  800c14:	83 c1 01             	add    $0x1,%ecx
  800c17:	bf 01 00 00 00       	mov    $0x1,%edi
  800c1c:	eb c7                	jmp    800be5 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c22:	74 0e                	je     800c32 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c24:	85 db                	test   %ebx,%ebx
  800c26:	75 d8                	jne    800c00 <strtol+0x44>
		s++, base = 8;
  800c28:	83 c1 01             	add    $0x1,%ecx
  800c2b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c30:	eb ce                	jmp    800c00 <strtol+0x44>
		s += 2, base = 16;
  800c32:	83 c1 02             	add    $0x2,%ecx
  800c35:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3a:	eb c4                	jmp    800c00 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c3c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c3f:	89 f3                	mov    %esi,%ebx
  800c41:	80 fb 19             	cmp    $0x19,%bl
  800c44:	77 29                	ja     800c6f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c46:	0f be d2             	movsbl %dl,%edx
  800c49:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c4f:	7d 30                	jge    800c81 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c51:	83 c1 01             	add    $0x1,%ecx
  800c54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c58:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c5a:	0f b6 11             	movzbl (%ecx),%edx
  800c5d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c60:	89 f3                	mov    %esi,%ebx
  800c62:	80 fb 09             	cmp    $0x9,%bl
  800c65:	77 d5                	ja     800c3c <strtol+0x80>
			dig = *s - '0';
  800c67:	0f be d2             	movsbl %dl,%edx
  800c6a:	83 ea 30             	sub    $0x30,%edx
  800c6d:	eb dd                	jmp    800c4c <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c6f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c72:	89 f3                	mov    %esi,%ebx
  800c74:	80 fb 19             	cmp    $0x19,%bl
  800c77:	77 08                	ja     800c81 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c79:	0f be d2             	movsbl %dl,%edx
  800c7c:	83 ea 37             	sub    $0x37,%edx
  800c7f:	eb cb                	jmp    800c4c <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c85:	74 05                	je     800c8c <strtol+0xd0>
		*endptr = (char *) s;
  800c87:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c8c:	89 c2                	mov    %eax,%edx
  800c8e:	f7 da                	neg    %edx
  800c90:	85 ff                	test   %edi,%edi
  800c92:	0f 45 c2             	cmovne %edx,%eax
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    
  800c9a:	66 90                	xchg   %ax,%ax
  800c9c:	66 90                	xchg   %ax,%ax
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
