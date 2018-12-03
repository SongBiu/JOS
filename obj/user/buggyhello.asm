
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
  800049:	e8 8b 00 00 00       	call   8000d9 <sys_cputs>
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
  80005d:	57                   	push   %edi
  80005e:	56                   	push   %esi
  80005f:	53                   	push   %ebx
  800060:	83 ec 0c             	sub    $0xc,%esp
  800063:	e8 ee ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800068:	81 c3 98 1f 00 00    	add    $0x1f98,%ebx
  80006e:	8b 75 08             	mov    0x8(%ebp),%esi
  800071:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800074:	e8 f2 00 00 00       	call   80016b <sys_getenvid>
  800079:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800081:	c1 e0 05             	shl    $0x5,%eax
  800084:	81 c0 00 00 c0 ee    	add    $0xeec00000,%eax
  80008a:	c7 c2 2c 20 80 00    	mov    $0x80202c,%edx
  800090:	89 02                	mov    %eax,(%edx)
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800092:	85 f6                	test   %esi,%esi
  800094:	7e 08                	jle    80009e <libmain+0x44>
		binaryname = argv[0];
  800096:	8b 07                	mov    (%edi),%eax
  800098:	89 83 0c 00 00 00    	mov    %eax,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	e8 8b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 10             	sub    $0x10,%esp
  8000bf:	e8 92 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8000c4:	81 c3 3c 1f 00 00    	add    $0x1f3c,%ebx
	sys_env_destroy(0);
  8000ca:	6a 00                	push   $0x0
  8000cc:	e8 45 00 00 00       	call   800116 <sys_env_destroy>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d7:	c9                   	leave  
  8000d8:	c3                   	ret    

008000d9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000df:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ea:	89 c3                	mov    %eax,%ebx
  8000ec:	89 c7                	mov    %eax,%edi
  8000ee:	89 c6                	mov    %eax,%esi
  8000f0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800102:	b8 01 00 00 00       	mov    $0x1,%eax
  800107:	89 d1                	mov    %edx,%ecx
  800109:	89 d3                	mov    %edx,%ebx
  80010b:	89 d7                	mov    %edx,%edi
  80010d:	89 d6                	mov    %edx,%esi
  80010f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	57                   	push   %edi
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
  80011c:	83 ec 1c             	sub    $0x1c,%esp
  80011f:	e8 66 00 00 00       	call   80018a <__x86.get_pc_thunk.ax>
  800124:	05 dc 1e 00 00       	add    $0x1edc,%eax
  800129:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  80012c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800131:	8b 55 08             	mov    0x8(%ebp),%edx
  800134:	b8 03 00 00 00       	mov    $0x3,%eax
  800139:	89 cb                	mov    %ecx,%ebx
  80013b:	89 cf                	mov    %ecx,%edi
  80013d:	89 ce                	mov    %ecx,%esi
  80013f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800141:	85 c0                	test   %eax,%eax
  800143:	7f 08                	jg     80014d <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80014d:	83 ec 0c             	sub    $0xc,%esp
  800150:	50                   	push   %eax
  800151:	6a 03                	push   $0x3
  800153:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800156:	8d 83 e6 ee ff ff    	lea    -0x111a(%ebx),%eax
  80015c:	50                   	push   %eax
  80015d:	6a 26                	push   $0x26
  80015f:	8d 83 03 ef ff ff    	lea    -0x10fd(%ebx),%eax
  800165:	50                   	push   %eax
  800166:	e8 23 00 00 00       	call   80018e <_panic>

0080016b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	57                   	push   %edi
  80016f:	56                   	push   %esi
  800170:	53                   	push   %ebx
	asm volatile("int %1\n"
  800171:	ba 00 00 00 00       	mov    $0x0,%edx
  800176:	b8 02 00 00 00       	mov    $0x2,%eax
  80017b:	89 d1                	mov    %edx,%ecx
  80017d:	89 d3                	mov    %edx,%ebx
  80017f:	89 d7                	mov    %edx,%edi
  800181:	89 d6                	mov    %edx,%esi
  800183:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <__x86.get_pc_thunk.ax>:
  80018a:	8b 04 24             	mov    (%esp),%eax
  80018d:	c3                   	ret    

0080018e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	57                   	push   %edi
  800192:	56                   	push   %esi
  800193:	53                   	push   %ebx
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	e8 ba fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  80019c:	81 c3 64 1e 00 00    	add    $0x1e64,%ebx
	va_list ap;

	va_start(ap, fmt);
  8001a2:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a5:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  8001ab:	8b 38                	mov    (%eax),%edi
  8001ad:	e8 b9 ff ff ff       	call   80016b <sys_getenvid>
  8001b2:	83 ec 0c             	sub    $0xc,%esp
  8001b5:	ff 75 0c             	pushl  0xc(%ebp)
  8001b8:	ff 75 08             	pushl  0x8(%ebp)
  8001bb:	57                   	push   %edi
  8001bc:	50                   	push   %eax
  8001bd:	8d 83 14 ef ff ff    	lea    -0x10ec(%ebx),%eax
  8001c3:	50                   	push   %eax
  8001c4:	e8 d1 00 00 00       	call   80029a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c9:	83 c4 18             	add    $0x18,%esp
  8001cc:	56                   	push   %esi
  8001cd:	ff 75 10             	pushl  0x10(%ebp)
  8001d0:	e8 63 00 00 00       	call   800238 <vcprintf>
	cprintf("\n");
  8001d5:	8d 83 38 ef ff ff    	lea    -0x10c8(%ebx),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	e8 b7 00 00 00       	call   80029a <cprintf>
  8001e3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e6:	cc                   	int3   
  8001e7:	eb fd                	jmp    8001e6 <_panic+0x58>

008001e9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	e8 63 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8001f3:	81 c3 0d 1e 00 00    	add    $0x1e0d,%ebx
  8001f9:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001fc:	8b 16                	mov    (%esi),%edx
  8001fe:	8d 42 01             	lea    0x1(%edx),%eax
  800201:	89 06                	mov    %eax,(%esi)
  800203:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800206:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  80020a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020f:	74 0b                	je     80021c <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800211:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	68 ff 00 00 00       	push   $0xff
  800224:	8d 46 08             	lea    0x8(%esi),%eax
  800227:	50                   	push   %eax
  800228:	e8 ac fe ff ff       	call   8000d9 <sys_cputs>
		b->idx = 0;
  80022d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	eb d9                	jmp    800211 <putch+0x28>

00800238 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	53                   	push   %ebx
  80023c:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800242:	e8 0f fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800247:	81 c3 b9 1d 00 00    	add    $0x1db9,%ebx
	struct printbuf b;

	b.idx = 0;
  80024d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800254:	00 00 00 
	b.cnt = 0;
  800257:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800261:	ff 75 0c             	pushl  0xc(%ebp)
  800264:	ff 75 08             	pushl  0x8(%ebp)
  800267:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026d:	50                   	push   %eax
  80026e:	8d 83 e9 e1 ff ff    	lea    -0x1e17(%ebx),%eax
  800274:	50                   	push   %eax
  800275:	e8 38 01 00 00       	call   8003b2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80027a:	83 c4 08             	add    $0x8,%esp
  80027d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800283:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	e8 4a fe ff ff       	call   8000d9 <sys_cputs>
	return b.cnt;
}
  80028f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800295:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800298:	c9                   	leave  
  800299:	c3                   	ret    

0080029a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 10             	sub    $0x10,%esp
	
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002a0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002a3:	50                   	push   %eax
  8002a4:	ff 75 08             	pushl  0x8(%ebp)
  8002a7:	e8 8c ff ff ff       	call   800238 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 2c             	sub    $0x2c,%esp
  8002b7:	e8 63 06 00 00       	call   80091f <__x86.get_pc_thunk.cx>
  8002bc:	81 c1 44 1d 00 00    	add    $0x1d44,%ecx
  8002c2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002c5:	89 c7                	mov    %eax,%edi
  8002c7:	89 d6                	mov    %edx,%esi
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8002e0:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8002e3:	39 d3                	cmp    %edx,%ebx
  8002e5:	72 09                	jb     8002f0 <printnum+0x42>
  8002e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ea:	0f 87 83 00 00 00    	ja     800373 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	ff 75 18             	pushl  0x18(%ebp)
  8002f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002fc:	53                   	push   %ebx
  8002fd:	ff 75 10             	pushl  0x10(%ebp)
  800300:	83 ec 08             	sub    $0x8,%esp
  800303:	ff 75 dc             	pushl  -0x24(%ebp)
  800306:	ff 75 d8             	pushl  -0x28(%ebp)
  800309:	ff 75 d4             	pushl  -0x2c(%ebp)
  80030c:	ff 75 d0             	pushl  -0x30(%ebp)
  80030f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800312:	e8 89 09 00 00       	call   800ca0 <__udivdi3>
  800317:	83 c4 18             	add    $0x18,%esp
  80031a:	52                   	push   %edx
  80031b:	50                   	push   %eax
  80031c:	89 f2                	mov    %esi,%edx
  80031e:	89 f8                	mov    %edi,%eax
  800320:	e8 89 ff ff ff       	call   8002ae <printnum>
  800325:	83 c4 20             	add    $0x20,%esp
  800328:	eb 13                	jmp    80033d <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032a:	83 ec 08             	sub    $0x8,%esp
  80032d:	56                   	push   %esi
  80032e:	ff 75 18             	pushl  0x18(%ebp)
  800331:	ff d7                	call   *%edi
  800333:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800336:	83 eb 01             	sub    $0x1,%ebx
  800339:	85 db                	test   %ebx,%ebx
  80033b:	7f ed                	jg     80032a <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	56                   	push   %esi
  800341:	83 ec 04             	sub    $0x4,%esp
  800344:	ff 75 dc             	pushl  -0x24(%ebp)
  800347:	ff 75 d8             	pushl  -0x28(%ebp)
  80034a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80034d:	ff 75 d0             	pushl  -0x30(%ebp)
  800350:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800353:	89 f3                	mov    %esi,%ebx
  800355:	e8 66 0a 00 00       	call   800dc0 <__umoddi3>
  80035a:	83 c4 14             	add    $0x14,%esp
  80035d:	0f be 84 06 3a ef ff 	movsbl -0x10c6(%esi,%eax,1),%eax
  800364:	ff 
  800365:	50                   	push   %eax
  800366:	ff d7                	call   *%edi
}
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    
  800373:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800376:	eb be                	jmp    800336 <printnum+0x88>

00800378 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800382:	8b 10                	mov    (%eax),%edx
  800384:	3b 50 04             	cmp    0x4(%eax),%edx
  800387:	73 0a                	jae    800393 <sprintputch+0x1b>
		*b->buf++ = ch;
  800389:	8d 4a 01             	lea    0x1(%edx),%ecx
  80038c:	89 08                	mov    %ecx,(%eax)
  80038e:	8b 45 08             	mov    0x8(%ebp),%eax
  800391:	88 02                	mov    %al,(%edx)
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <printfmt>:
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80039b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039e:	50                   	push   %eax
  80039f:	ff 75 10             	pushl  0x10(%ebp)
  8003a2:	ff 75 0c             	pushl  0xc(%ebp)
  8003a5:	ff 75 08             	pushl  0x8(%ebp)
  8003a8:	e8 05 00 00 00       	call   8003b2 <vprintfmt>
}
  8003ad:	83 c4 10             	add    $0x10,%esp
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    

008003b2 <vprintfmt>:
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
  8003b8:	83 ec 2c             	sub    $0x2c,%esp
  8003bb:	e8 96 fc ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8003c0:	81 c3 40 1c 00 00    	add    $0x1c40,%ebx
  8003c6:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
  8003c9:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
  8003d0:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d2:	8d 77 01             	lea    0x1(%edi),%esi
  8003d5:	0f b6 07             	movzbl (%edi),%eax
  8003d8:	83 f8 25             	cmp    $0x25,%eax
  8003db:	74 1c                	je     8003f9 <vprintfmt+0x47>
			if (ch == '\0')
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	0f 84 b9 04 00 00    	je     80089e <.L21+0x20>
			putch(ch, putdat);
  8003e5:	83 ec 08             	sub    $0x8,%esp
  8003e8:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
  8003eb:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
  8003ee:	50                   	push   %eax
  8003ef:	ff 55 08             	call   *0x8(%ebp)
  8003f2:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f5:	89 f7                	mov    %esi,%edi
  8003f7:	eb d9                	jmp    8003d2 <vprintfmt+0x20>
		padc = ' ';
  8003f9:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
  8003fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800404:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
  80040b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800412:	b9 00 00 00 00       	mov    $0x0,%ecx
  800417:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8d 7e 01             	lea    0x1(%esi),%edi
  80041d:	0f b6 16             	movzbl (%esi),%edx
  800420:	8d 42 dd             	lea    -0x23(%edx),%eax
  800423:	3c 55                	cmp    $0x55,%al
  800425:	0f 87 53 04 00 00    	ja     80087e <.L21>
  80042b:	0f b6 c0             	movzbl %al,%eax
  80042e:	89 d9                	mov    %ebx,%ecx
  800430:	03 8c 83 c8 ef ff ff 	add    -0x1038(%ebx,%eax,4),%ecx
  800437:	ff e1                	jmp    *%ecx

00800439 <.L73>:
  800439:	89 fe                	mov    %edi,%esi
			padc = '-';
  80043b:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
  80043f:	eb d9                	jmp    80041a <vprintfmt+0x68>

00800441 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	89 fe                	mov    %edi,%esi
			padc = '0';
  800443:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
  800447:	eb d1                	jmp    80041a <vprintfmt+0x68>

00800449 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	0f b6 d2             	movzbl %dl,%edx
  80044c:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
  800456:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800459:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80045d:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
  800460:	8d 7a d0             	lea    -0x30(%edx),%edi
  800463:	83 ff 09             	cmp    $0x9,%edi
  800466:	0f 87 94 00 00 00    	ja     800500 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
  80046c:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
  80046f:	eb e5                	jmp    800456 <.L28+0xd>

00800471 <.L25>:
			precision = va_arg(ap, int);
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8b 00                	mov    (%eax),%eax
  800476:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 40 04             	lea    0x4(%eax),%eax
  80047f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800482:	89 fe                	mov    %edi,%esi
			if (width < 0)
  800484:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800488:	79 90                	jns    80041a <vprintfmt+0x68>
				width = precision, precision = -1;
  80048a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80048d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800490:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800497:	eb 81                	jmp    80041a <vprintfmt+0x68>

00800499 <.L26>:
  800499:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049c:	85 c0                	test   %eax,%eax
  80049e:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a3:	0f 49 d0             	cmovns %eax,%edx
  8004a6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	89 fe                	mov    %edi,%esi
  8004ab:	e9 6a ff ff ff       	jmp    80041a <vprintfmt+0x68>

008004b0 <.L22>:
  8004b0:	89 fe                	mov    %edi,%esi
			altflag = 1;
  8004b2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004b9:	e9 5c ff ff ff       	jmp    80041a <vprintfmt+0x68>

008004be <.L33>:
  8004be:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  8004c1:	83 f9 01             	cmp    $0x1,%ecx
  8004c4:	7e 16                	jle    8004dc <.L33+0x1e>
		return va_arg(*ap, long long);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004ce:	8d 49 08             	lea    0x8(%ecx),%ecx
  8004d1:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
  8004d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
  8004d7:	e9 f6 fe ff ff       	jmp    8003d2 <vprintfmt+0x20>
	else if (lflag)
  8004dc:	85 c9                	test   %ecx,%ecx
  8004de:	75 10                	jne    8004f0 <.L33+0x32>
		return va_arg(*ap, int);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8b 00                	mov    (%eax),%eax
  8004e5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004e8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004eb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ee:	eb e4                	jmp    8004d4 <.L33+0x16>
		return va_arg(*ap, long);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8b 00                	mov    (%eax),%eax
  8004f5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8004f8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8004fb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004fe:	eb d4                	jmp    8004d4 <.L33+0x16>
  800500:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800503:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800506:	e9 79 ff ff ff       	jmp    800484 <.L25+0x13>

0080050b <.L32>:
			lflag++;
  80050b:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	89 fe                	mov    %edi,%esi
			goto reswitch;
  800511:	e9 04 ff ff ff       	jmp    80041a <vprintfmt+0x68>

00800516 <.L29>:
			putch(va_arg(ap, int), putdat);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 70 04             	lea    0x4(%eax),%esi
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	ff 75 0c             	pushl  0xc(%ebp)
  800522:	ff 30                	pushl  (%eax)
  800524:	ff 55 08             	call   *0x8(%ebp)
			break;
  800527:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80052a:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
  80052d:	e9 a0 fe ff ff       	jmp    8003d2 <vprintfmt+0x20>

00800532 <.L31>:
			err = va_arg(ap, int);
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 70 04             	lea    0x4(%eax),%esi
  800538:	8b 00                	mov    (%eax),%eax
  80053a:	99                   	cltd   
  80053b:	31 d0                	xor    %edx,%eax
  80053d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053f:	83 f8 06             	cmp    $0x6,%eax
  800542:	7f 29                	jg     80056d <.L31+0x3b>
  800544:	8b 94 83 10 00 00 00 	mov    0x10(%ebx,%eax,4),%edx
  80054b:	85 d2                	test   %edx,%edx
  80054d:	74 1e                	je     80056d <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
  80054f:	52                   	push   %edx
  800550:	8d 83 5b ef ff ff    	lea    -0x10a5(%ebx),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 0c             	pushl  0xc(%ebp)
  80055a:	ff 75 08             	pushl  0x8(%ebp)
  80055d:	e8 33 fe ff ff       	call   800395 <printfmt>
  800562:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800565:	89 75 14             	mov    %esi,0x14(%ebp)
  800568:	e9 65 fe ff ff       	jmp    8003d2 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
  80056d:	50                   	push   %eax
  80056e:	8d 83 52 ef ff ff    	lea    -0x10ae(%ebx),%eax
  800574:	50                   	push   %eax
  800575:	ff 75 0c             	pushl  0xc(%ebp)
  800578:	ff 75 08             	pushl  0x8(%ebp)
  80057b:	e8 15 fe ff ff       	call   800395 <printfmt>
  800580:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800583:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800586:	e9 47 fe ff ff       	jmp    8003d2 <vprintfmt+0x20>

0080058b <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	83 c0 04             	add    $0x4,%eax
  800591:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 30                	mov    (%eax),%esi
				p = "(null)";
  800599:	85 f6                	test   %esi,%esi
  80059b:	8d 83 4b ef ff ff    	lea    -0x10b5(%ebx),%eax
  8005a1:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
  8005a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a8:	0f 8e b4 00 00 00    	jle    800662 <.L36+0xd7>
  8005ae:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
  8005b2:	75 08                	jne    8005bc <.L36+0x31>
  8005b4:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005b7:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8005ba:	eb 6c                	jmp    800628 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	ff 75 cc             	pushl  -0x34(%ebp)
  8005c2:	56                   	push   %esi
  8005c3:	e8 73 03 00 00       	call   80093b <strnlen>
  8005c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005cb:	29 c2                	sub    %eax,%edx
  8005cd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005d0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005d3:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
  8005d7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005da:	89 d6                	mov    %edx,%esi
  8005dc:	89 7d 10             	mov    %edi,0x10(%ebp)
  8005df:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	eb 10                	jmp    8005f3 <.L36+0x68>
					putch(padc, putdat);
  8005e3:	83 ec 08             	sub    $0x8,%esp
  8005e6:	ff 75 0c             	pushl  0xc(%ebp)
  8005e9:	57                   	push   %edi
  8005ea:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ed:	83 ee 01             	sub    $0x1,%esi
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	85 f6                	test   %esi,%esi
  8005f5:	7f ec                	jg     8005e3 <.L36+0x58>
  8005f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005fd:	85 d2                	test   %edx,%edx
  8005ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800604:	0f 49 c2             	cmovns %edx,%eax
  800607:	29 c2                	sub    %eax,%edx
  800609:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80060c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80060f:	eb 17                	jmp    800628 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
  800611:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800615:	75 30                	jne    800647 <.L36+0xbc>
					putch(ch, putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	ff 75 0c             	pushl  0xc(%ebp)
  80061d:	50                   	push   %eax
  80061e:	ff 55 08             	call   *0x8(%ebp)
  800621:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800624:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800628:	83 c6 01             	add    $0x1,%esi
  80062b:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80062f:	0f be c2             	movsbl %dl,%eax
  800632:	85 c0                	test   %eax,%eax
  800634:	74 58                	je     80068e <.L36+0x103>
  800636:	85 ff                	test   %edi,%edi
  800638:	78 d7                	js     800611 <.L36+0x86>
  80063a:	83 ef 01             	sub    $0x1,%edi
  80063d:	79 d2                	jns    800611 <.L36+0x86>
  80063f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800642:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800645:	eb 32                	jmp    800679 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
  800647:	0f be d2             	movsbl %dl,%edx
  80064a:	83 ea 20             	sub    $0x20,%edx
  80064d:	83 fa 5e             	cmp    $0x5e,%edx
  800650:	76 c5                	jbe    800617 <.L36+0x8c>
					putch('?', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	ff 75 0c             	pushl  0xc(%ebp)
  800658:	6a 3f                	push   $0x3f
  80065a:	ff 55 08             	call   *0x8(%ebp)
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb c2                	jmp    800624 <.L36+0x99>
  800662:	89 7d 10             	mov    %edi,0x10(%ebp)
  800665:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800668:	eb be                	jmp    800628 <.L36+0x9d>
				putch(' ', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	57                   	push   %edi
  80066e:	6a 20                	push   $0x20
  800670:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
  800673:	83 ee 01             	sub    $0x1,%esi
  800676:	83 c4 10             	add    $0x10,%esp
  800679:	85 f6                	test   %esi,%esi
  80067b:	7f ed                	jg     80066a <.L36+0xdf>
  80067d:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800680:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
  800689:	e9 44 fd ff ff       	jmp    8003d2 <vprintfmt+0x20>
  80068e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800691:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800694:	eb e3                	jmp    800679 <.L36+0xee>

00800696 <.L30>:
  800696:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800699:	83 f9 01             	cmp    $0x1,%ecx
  80069c:	7e 42                	jle    8006e0 <.L30+0x4a>
		return va_arg(*ap, long long);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8b 50 04             	mov    0x4(%eax),%edx
  8006a4:	8b 00                	mov    (%eax),%eax
  8006a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 40 08             	lea    0x8(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006b5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006b9:	79 5f                	jns    80071a <.L30+0x84>
				putch('-', putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	6a 2d                	push   $0x2d
  8006c3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006cc:	f7 da                	neg    %edx
  8006ce:	83 d1 00             	adc    $0x0,%ecx
  8006d1:	f7 d9                	neg    %ecx
  8006d3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006db:	e9 b8 00 00 00       	jmp    800798 <.L34+0x22>
	else if (lflag)
  8006e0:	85 c9                	test   %ecx,%ecx
  8006e2:	75 1b                	jne    8006ff <.L30+0x69>
		return va_arg(*ap, int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 30                	mov    (%eax),%esi
  8006e9:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8006ec:	89 f0                	mov    %esi,%eax
  8006ee:	c1 f8 1f             	sar    $0x1f,%eax
  8006f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 40 04             	lea    0x4(%eax),%eax
  8006fa:	89 45 14             	mov    %eax,0x14(%ebp)
  8006fd:	eb b6                	jmp    8006b5 <.L30+0x1f>
		return va_arg(*ap, long);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 30                	mov    (%eax),%esi
  800704:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800707:	89 f0                	mov    %esi,%eax
  800709:	c1 f8 1f             	sar    $0x1f,%eax
  80070c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 40 04             	lea    0x4(%eax),%eax
  800715:	89 45 14             	mov    %eax,0x14(%ebp)
  800718:	eb 9b                	jmp    8006b5 <.L30+0x1f>
			num = getint(&ap, lflag);
  80071a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80071d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800720:	b8 0a 00 00 00       	mov    $0xa,%eax
  800725:	eb 71                	jmp    800798 <.L34+0x22>

00800727 <.L37>:
  800727:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  80072a:	83 f9 01             	cmp    $0x1,%ecx
  80072d:	7e 15                	jle    800744 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8b 10                	mov    (%eax),%edx
  800734:	8b 48 04             	mov    0x4(%eax),%ecx
  800737:	8d 40 08             	lea    0x8(%eax),%eax
  80073a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800742:	eb 54                	jmp    800798 <.L34+0x22>
	else if (lflag)
  800744:	85 c9                	test   %ecx,%ecx
  800746:	75 17                	jne    80075f <.L37+0x38>
		return va_arg(*ap, unsigned int);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 10                	mov    (%eax),%edx
  80074d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800752:	8d 40 04             	lea    0x4(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800758:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075d:	eb 39                	jmp    800798 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8b 10                	mov    (%eax),%edx
  800764:	b9 00 00 00 00       	mov    $0x0,%ecx
  800769:	8d 40 04             	lea    0x4(%eax),%eax
  80076c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80076f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800774:	eb 22                	jmp    800798 <.L34+0x22>

00800776 <.L34>:
  800776:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800779:	83 f9 01             	cmp    $0x1,%ecx
  80077c:	7e 3b                	jle    8007b9 <.L34+0x43>
		return va_arg(*ap, long long);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8b 50 04             	mov    0x4(%eax),%edx
  800784:	8b 00                	mov    (%eax),%eax
  800786:	8b 4d 14             	mov    0x14(%ebp),%ecx
  800789:	8d 49 08             	lea    0x8(%ecx),%ecx
  80078c:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
  80078f:	89 d1                	mov    %edx,%ecx
  800791:	89 c2                	mov    %eax,%edx
			base = 8;
  800793:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
  800798:	83 ec 0c             	sub    $0xc,%esp
  80079b:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
  80079f:	56                   	push   %esi
  8007a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a3:	50                   	push   %eax
  8007a4:	51                   	push   %ecx
  8007a5:	52                   	push   %edx
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	e8 fd fa ff ff       	call   8002ae <printnum>
			break;
  8007b1:	83 c4 20             	add    $0x20,%esp
  8007b4:	e9 19 fc ff ff       	jmp    8003d2 <vprintfmt+0x20>
	else if (lflag)
  8007b9:	85 c9                	test   %ecx,%ecx
  8007bb:	75 13                	jne    8007d0 <.L34+0x5a>
		return va_arg(*ap, int);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8b 10                	mov    (%eax),%edx
  8007c2:	89 d0                	mov    %edx,%eax
  8007c4:	99                   	cltd   
  8007c5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007c8:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007cb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007ce:	eb bf                	jmp    80078f <.L34+0x19>
		return va_arg(*ap, long);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8b 10                	mov    (%eax),%edx
  8007d5:	89 d0                	mov    %edx,%eax
  8007d7:	99                   	cltd   
  8007d8:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8007db:	8d 49 04             	lea    0x4(%ecx),%ecx
  8007de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007e1:	eb ac                	jmp    80078f <.L34+0x19>

008007e3 <.L35>:
			putch('0', putdat);
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	ff 75 0c             	pushl  0xc(%ebp)
  8007e9:	6a 30                	push   $0x30
  8007eb:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8007ee:	83 c4 08             	add    $0x8,%esp
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	6a 78                	push   $0x78
  8007f6:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8b 10                	mov    (%eax),%edx
  8007fe:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800803:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800806:	8d 40 04             	lea    0x4(%eax),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800811:	eb 85                	jmp    800798 <.L34+0x22>

00800813 <.L38>:
  800813:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
  800816:	83 f9 01             	cmp    $0x1,%ecx
  800819:	7e 18                	jle    800833 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	8b 10                	mov    (%eax),%edx
  800820:	8b 48 04             	mov    0x4(%eax),%ecx
  800823:	8d 40 08             	lea    0x8(%eax),%eax
  800826:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800829:	b8 10 00 00 00       	mov    $0x10,%eax
  80082e:	e9 65 ff ff ff       	jmp    800798 <.L34+0x22>
	else if (lflag)
  800833:	85 c9                	test   %ecx,%ecx
  800835:	75 1a                	jne    800851 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	8b 10                	mov    (%eax),%edx
  80083c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800841:	8d 40 04             	lea    0x4(%eax),%eax
  800844:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800847:	b8 10 00 00 00       	mov    $0x10,%eax
  80084c:	e9 47 ff ff ff       	jmp    800798 <.L34+0x22>
		return va_arg(*ap, unsigned long);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 10                	mov    (%eax),%edx
  800856:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085b:	8d 40 04             	lea    0x4(%eax),%eax
  80085e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800861:	b8 10 00 00 00       	mov    $0x10,%eax
  800866:	e9 2d ff ff ff       	jmp    800798 <.L34+0x22>

0080086b <.L24>:
			putch(ch, putdat);
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	ff 75 0c             	pushl  0xc(%ebp)
  800871:	6a 25                	push   $0x25
  800873:	ff 55 08             	call   *0x8(%ebp)
			break;
  800876:	83 c4 10             	add    $0x10,%esp
  800879:	e9 54 fb ff ff       	jmp    8003d2 <vprintfmt+0x20>

0080087e <.L21>:
			putch('%', putdat);
  80087e:	83 ec 08             	sub    $0x8,%esp
  800881:	ff 75 0c             	pushl  0xc(%ebp)
  800884:	6a 25                	push   $0x25
  800886:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800889:	83 c4 10             	add    $0x10,%esp
  80088c:	89 f7                	mov    %esi,%edi
  80088e:	eb 03                	jmp    800893 <.L21+0x15>
  800890:	83 ef 01             	sub    $0x1,%edi
  800893:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800897:	75 f7                	jne    800890 <.L21+0x12>
  800899:	e9 34 fb ff ff       	jmp    8003d2 <vprintfmt+0x20>
}
  80089e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5f                   	pop    %edi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	53                   	push   %ebx
  8008aa:	83 ec 14             	sub    $0x14,%esp
  8008ad:	e8 a4 f7 ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8008b2:	81 c3 4e 17 00 00    	add    $0x174e,%ebx
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008c1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008c5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008cf:	85 c0                	test   %eax,%eax
  8008d1:	74 2b                	je     8008fe <vsnprintf+0x58>
  8008d3:	85 d2                	test   %edx,%edx
  8008d5:	7e 27                	jle    8008fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d7:	ff 75 14             	pushl  0x14(%ebp)
  8008da:	ff 75 10             	pushl  0x10(%ebp)
  8008dd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e0:	50                   	push   %eax
  8008e1:	8d 83 78 e3 ff ff    	lea    -0x1c88(%ebx),%eax
  8008e7:	50                   	push   %eax
  8008e8:	e8 c5 fa ff ff       	call   8003b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f6:	83 c4 10             	add    $0x10,%esp
}
  8008f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fc:	c9                   	leave  
  8008fd:	c3                   	ret    
		return -E_INVAL;
  8008fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800903:	eb f4                	jmp    8008f9 <vsnprintf+0x53>

00800905 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80090e:	50                   	push   %eax
  80090f:	ff 75 10             	pushl  0x10(%ebp)
  800912:	ff 75 0c             	pushl  0xc(%ebp)
  800915:	ff 75 08             	pushl  0x8(%ebp)
  800918:	e8 89 ff ff ff       	call   8008a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <__x86.get_pc_thunk.cx>:
  80091f:	8b 0c 24             	mov    (%esp),%ecx
  800922:	c3                   	ret    

00800923 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800929:	b8 00 00 00 00       	mov    $0x0,%eax
  80092e:	eb 03                	jmp    800933 <strlen+0x10>
		n++;
  800930:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800933:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800937:	75 f7                	jne    800930 <strlen+0xd>
	return n;
}
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
  800949:	eb 03                	jmp    80094e <strnlen+0x13>
		n++;
  80094b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094e:	39 d0                	cmp    %edx,%eax
  800950:	74 06                	je     800958 <strnlen+0x1d>
  800952:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800956:	75 f3                	jne    80094b <strnlen+0x10>
	return n;
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800964:	89 c2                	mov    %eax,%edx
  800966:	83 c1 01             	add    $0x1,%ecx
  800969:	83 c2 01             	add    $0x1,%edx
  80096c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800970:	88 5a ff             	mov    %bl,-0x1(%edx)
  800973:	84 db                	test   %bl,%bl
  800975:	75 ef                	jne    800966 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800981:	53                   	push   %ebx
  800982:	e8 9c ff ff ff       	call   800923 <strlen>
  800987:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80098a:	ff 75 0c             	pushl  0xc(%ebp)
  80098d:	01 d8                	add    %ebx,%eax
  80098f:	50                   	push   %eax
  800990:	e8 c5 ff ff ff       	call   80095a <strcpy>
	return dst;
}
  800995:	89 d8                	mov    %ebx,%eax
  800997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a7:	89 f3                	mov    %esi,%ebx
  8009a9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ac:	89 f2                	mov    %esi,%edx
  8009ae:	eb 0f                	jmp    8009bf <strncpy+0x23>
		*dst++ = *src;
  8009b0:	83 c2 01             	add    $0x1,%edx
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b9:	80 39 01             	cmpb   $0x1,(%ecx)
  8009bc:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009bf:	39 da                	cmp    %ebx,%edx
  8009c1:	75 ed                	jne    8009b0 <strncpy+0x14>
	}
	return ret;
}
  8009c3:	89 f0                	mov    %esi,%eax
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	56                   	push   %esi
  8009cd:	53                   	push   %ebx
  8009ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009d7:	89 f0                	mov    %esi,%eax
  8009d9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009dd:	85 c9                	test   %ecx,%ecx
  8009df:	75 0b                	jne    8009ec <strlcpy+0x23>
  8009e1:	eb 17                	jmp    8009fa <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e3:	83 c2 01             	add    $0x1,%edx
  8009e6:	83 c0 01             	add    $0x1,%eax
  8009e9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009ec:	39 d8                	cmp    %ebx,%eax
  8009ee:	74 07                	je     8009f7 <strlcpy+0x2e>
  8009f0:	0f b6 0a             	movzbl (%edx),%ecx
  8009f3:	84 c9                	test   %cl,%cl
  8009f5:	75 ec                	jne    8009e3 <strlcpy+0x1a>
		*dst = '\0';
  8009f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009fa:	29 f0                	sub    %esi,%eax
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a09:	eb 06                	jmp    800a11 <strcmp+0x11>
		p++, q++;
  800a0b:	83 c1 01             	add    $0x1,%ecx
  800a0e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a11:	0f b6 01             	movzbl (%ecx),%eax
  800a14:	84 c0                	test   %al,%al
  800a16:	74 04                	je     800a1c <strcmp+0x1c>
  800a18:	3a 02                	cmp    (%edx),%al
  800a1a:	74 ef                	je     800a0b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1c:	0f b6 c0             	movzbl %al,%eax
  800a1f:	0f b6 12             	movzbl (%edx),%edx
  800a22:	29 d0                	sub    %edx,%eax
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	53                   	push   %ebx
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a30:	89 c3                	mov    %eax,%ebx
  800a32:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a35:	eb 06                	jmp    800a3d <strncmp+0x17>
		n--, p++, q++;
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a3d:	39 d8                	cmp    %ebx,%eax
  800a3f:	74 16                	je     800a57 <strncmp+0x31>
  800a41:	0f b6 08             	movzbl (%eax),%ecx
  800a44:	84 c9                	test   %cl,%cl
  800a46:	74 04                	je     800a4c <strncmp+0x26>
  800a48:	3a 0a                	cmp    (%edx),%cl
  800a4a:	74 eb                	je     800a37 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4c:	0f b6 00             	movzbl (%eax),%eax
  800a4f:	0f b6 12             	movzbl (%edx),%edx
  800a52:	29 d0                	sub    %edx,%eax
}
  800a54:	5b                   	pop    %ebx
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    
		return 0;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	eb f6                	jmp    800a54 <strncmp+0x2e>

00800a5e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a68:	0f b6 10             	movzbl (%eax),%edx
  800a6b:	84 d2                	test   %dl,%dl
  800a6d:	74 09                	je     800a78 <strchr+0x1a>
		if (*s == c)
  800a6f:	38 ca                	cmp    %cl,%dl
  800a71:	74 0a                	je     800a7d <strchr+0x1f>
	for (; *s; s++)
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	eb f0                	jmp    800a68 <strchr+0xa>
			return (char *) s;
	return 0;
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	8b 45 08             	mov    0x8(%ebp),%eax
  800a85:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a89:	eb 03                	jmp    800a8e <strfind+0xf>
  800a8b:	83 c0 01             	add    $0x1,%eax
  800a8e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a91:	38 ca                	cmp    %cl,%dl
  800a93:	74 04                	je     800a99 <strfind+0x1a>
  800a95:	84 d2                	test   %dl,%dl
  800a97:	75 f2                	jne    800a8b <strfind+0xc>
			break;
	return (char *) s;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa7:	85 c9                	test   %ecx,%ecx
  800aa9:	74 13                	je     800abe <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab1:	75 05                	jne    800ab8 <memset+0x1d>
  800ab3:	f6 c1 03             	test   $0x3,%cl
  800ab6:	74 0d                	je     800ac5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abb:	fc                   	cld    
  800abc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800abe:	89 f8                	mov    %edi,%eax
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    
		c &= 0xFF;
  800ac5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac9:	89 d3                	mov    %edx,%ebx
  800acb:	c1 e3 08             	shl    $0x8,%ebx
  800ace:	89 d0                	mov    %edx,%eax
  800ad0:	c1 e0 18             	shl    $0x18,%eax
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	c1 e6 10             	shl    $0x10,%esi
  800ad8:	09 f0                	or     %esi,%eax
  800ada:	09 c2                	or     %eax,%edx
  800adc:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ade:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ae1:	89 d0                	mov    %edx,%eax
  800ae3:	fc                   	cld    
  800ae4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae6:	eb d6                	jmp    800abe <memset+0x23>

00800ae8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af6:	39 c6                	cmp    %eax,%esi
  800af8:	73 35                	jae    800b2f <memmove+0x47>
  800afa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800afd:	39 c2                	cmp    %eax,%edx
  800aff:	76 2e                	jbe    800b2f <memmove+0x47>
		s += n;
		d += n;
  800b01:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	09 fe                	or     %edi,%esi
  800b08:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0e:	74 0c                	je     800b1c <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b10:	83 ef 01             	sub    $0x1,%edi
  800b13:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b16:	fd                   	std    
  800b17:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b19:	fc                   	cld    
  800b1a:	eb 21                	jmp    800b3d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1c:	f6 c1 03             	test   $0x3,%cl
  800b1f:	75 ef                	jne    800b10 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b21:	83 ef 04             	sub    $0x4,%edi
  800b24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b27:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b2a:	fd                   	std    
  800b2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2d:	eb ea                	jmp    800b19 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2f:	89 f2                	mov    %esi,%edx
  800b31:	09 c2                	or     %eax,%edx
  800b33:	f6 c2 03             	test   $0x3,%dl
  800b36:	74 09                	je     800b41 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b38:	89 c7                	mov    %eax,%edi
  800b3a:	fc                   	cld    
  800b3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b41:	f6 c1 03             	test   $0x3,%cl
  800b44:	75 f2                	jne    800b38 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b46:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	fc                   	cld    
  800b4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4e:	eb ed                	jmp    800b3d <memmove+0x55>

00800b50 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b53:	ff 75 10             	pushl  0x10(%ebp)
  800b56:	ff 75 0c             	pushl  0xc(%ebp)
  800b59:	ff 75 08             	pushl  0x8(%ebp)
  800b5c:	e8 87 ff ff ff       	call   800ae8 <memmove>
}
  800b61:	c9                   	leave  
  800b62:	c3                   	ret    

00800b63 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6e:	89 c6                	mov    %eax,%esi
  800b70:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b73:	39 f0                	cmp    %esi,%eax
  800b75:	74 1c                	je     800b93 <memcmp+0x30>
		if (*s1 != *s2)
  800b77:	0f b6 08             	movzbl (%eax),%ecx
  800b7a:	0f b6 1a             	movzbl (%edx),%ebx
  800b7d:	38 d9                	cmp    %bl,%cl
  800b7f:	75 08                	jne    800b89 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b81:	83 c0 01             	add    $0x1,%eax
  800b84:	83 c2 01             	add    $0x1,%edx
  800b87:	eb ea                	jmp    800b73 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b89:	0f b6 c1             	movzbl %cl,%eax
  800b8c:	0f b6 db             	movzbl %bl,%ebx
  800b8f:	29 d8                	sub    %ebx,%eax
  800b91:	eb 05                	jmp    800b98 <memcmp+0x35>
	}

	return 0;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ba5:	89 c2                	mov    %eax,%edx
  800ba7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800baa:	39 d0                	cmp    %edx,%eax
  800bac:	73 09                	jae    800bb7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bae:	38 08                	cmp    %cl,(%eax)
  800bb0:	74 05                	je     800bb7 <memfind+0x1b>
	for (; s < ends; s++)
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	eb f3                	jmp    800baa <memfind+0xe>
			break;
	return (void *) s;
}
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc5:	eb 03                	jmp    800bca <strtol+0x11>
		s++;
  800bc7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bca:	0f b6 01             	movzbl (%ecx),%eax
  800bcd:	3c 20                	cmp    $0x20,%al
  800bcf:	74 f6                	je     800bc7 <strtol+0xe>
  800bd1:	3c 09                	cmp    $0x9,%al
  800bd3:	74 f2                	je     800bc7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bd5:	3c 2b                	cmp    $0x2b,%al
  800bd7:	74 2e                	je     800c07 <strtol+0x4e>
	int neg = 0;
  800bd9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bde:	3c 2d                	cmp    $0x2d,%al
  800be0:	74 2f                	je     800c11 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800be8:	75 05                	jne    800bef <strtol+0x36>
  800bea:	80 39 30             	cmpb   $0x30,(%ecx)
  800bed:	74 2c                	je     800c1b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bef:	85 db                	test   %ebx,%ebx
  800bf1:	75 0a                	jne    800bfd <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bf3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800bf8:	80 39 30             	cmpb   $0x30,(%ecx)
  800bfb:	74 28                	je     800c25 <strtol+0x6c>
		base = 10;
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800c02:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c05:	eb 50                	jmp    800c57 <strtol+0x9e>
		s++;
  800c07:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0f:	eb d1                	jmp    800be2 <strtol+0x29>
		s++, neg = 1;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	bf 01 00 00 00       	mov    $0x1,%edi
  800c19:	eb c7                	jmp    800be2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c1f:	74 0e                	je     800c2f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c21:	85 db                	test   %ebx,%ebx
  800c23:	75 d8                	jne    800bfd <strtol+0x44>
		s++, base = 8;
  800c25:	83 c1 01             	add    $0x1,%ecx
  800c28:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c2d:	eb ce                	jmp    800bfd <strtol+0x44>
		s += 2, base = 16;
  800c2f:	83 c1 02             	add    $0x2,%ecx
  800c32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c37:	eb c4                	jmp    800bfd <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c39:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c3c:	89 f3                	mov    %esi,%ebx
  800c3e:	80 fb 19             	cmp    $0x19,%bl
  800c41:	77 29                	ja     800c6c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c43:	0f be d2             	movsbl %dl,%edx
  800c46:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c49:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c4c:	7d 30                	jge    800c7e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c4e:	83 c1 01             	add    $0x1,%ecx
  800c51:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c55:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c57:	0f b6 11             	movzbl (%ecx),%edx
  800c5a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c5d:	89 f3                	mov    %esi,%ebx
  800c5f:	80 fb 09             	cmp    $0x9,%bl
  800c62:	77 d5                	ja     800c39 <strtol+0x80>
			dig = *s - '0';
  800c64:	0f be d2             	movsbl %dl,%edx
  800c67:	83 ea 30             	sub    $0x30,%edx
  800c6a:	eb dd                	jmp    800c49 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c6c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c6f:	89 f3                	mov    %esi,%ebx
  800c71:	80 fb 19             	cmp    $0x19,%bl
  800c74:	77 08                	ja     800c7e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c76:	0f be d2             	movsbl %dl,%edx
  800c79:	83 ea 37             	sub    $0x37,%edx
  800c7c:	eb cb                	jmp    800c49 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c82:	74 05                	je     800c89 <strtol+0xd0>
		*endptr = (char *) s;
  800c84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c87:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c89:	89 c2                	mov    %eax,%edx
  800c8b:	f7 da                	neg    %edx
  800c8d:	85 ff                	test   %edi,%edi
  800c8f:	0f 45 c2             	cmovne %edx,%eax
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    
  800c97:	66 90                	xchg   %ax,%ax
  800c99:	66 90                	xchg   %ax,%ax
  800c9b:	66 90                	xchg   %ax,%ax
  800c9d:	66 90                	xchg   %ax,%ax
  800c9f:	90                   	nop

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
