
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 70 11 f0       	mov    $0xf0117000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/pmap.h>
#include <kern/kclock.h>

void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 6c 01 00 00       	call   f01001b6 <__x86.get_pc_thunk.bx>
f010004a:	81 c3 c2 82 01 00    	add    $0x182c2,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %08d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 b4 c2 fe ff    	lea    -0x13d4c(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 ae 34 00 00       	call   f0103511 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
	{
		test_backtrace(x - 1);
	}
	else
	{
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 03 08 00 00       	call   f010087b <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	}
	cprintf("leaving test_backtrace %08d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 d2 c2 fe ff    	lea    -0x13d2e(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 86 34 00 00       	call   f0103511 <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x - 1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 04 01 00 00       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 5a 82 01 00    	add    $0x1825a,%ebx
	extern char edata[], end[];
	
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 80 a0 11 f0    	mov    $0xf011a080,%edx
f01000be:	c7 c0 c0 a6 11 f0    	mov    $0xf011a6c0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 a9 40 00 00       	call   f0104178 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 37 05 00 00       	call   f010060b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 ef c2 fe ff    	lea    -0x13d11(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 29 34 00 00       	call   f0103511 <cprintf>

	// test_backtrace(5);

	// Lab 2 memory management initialization functions
	mem_init();
f01000e8:	e8 8d 16 00 00       	call   f010177a <mem_init>
f01000ed:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01000f0:	89 e8                	mov    %ebp,%eax
	// show_mappings();
	while (1)
	{
		struct Trapframe *tf;
		tf = (struct Trapframe *)read_ebp();
		monitor(tf);
f01000f2:	83 ec 0c             	sub    $0xc,%esp
f01000f5:	50                   	push   %eax
f01000f6:	e8 c0 0b 00 00       	call   f0100cbb <monitor>
f01000fb:	83 c4 10             	add    $0x10,%esp
f01000fe:	eb f0                	jmp    f01000f0 <i386_init+0x4a>

f0100100 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100100:	55                   	push   %ebp
f0100101:	89 e5                	mov    %esp,%ebp
f0100103:	57                   	push   %edi
f0100104:	56                   	push   %esi
f0100105:	53                   	push   %ebx
f0100106:	83 ec 0c             	sub    $0xc,%esp
f0100109:	e8 a8 00 00 00       	call   f01001b6 <__x86.get_pc_thunk.bx>
f010010e:	81 c3 fe 81 01 00    	add    $0x181fe,%ebx
f0100114:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100117:	c7 c0 c4 a6 11 f0    	mov    $0xf011a6c4,%eax
f010011d:	83 38 00             	cmpl   $0x0,(%eax)
f0100120:	74 0f                	je     f0100131 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100122:	83 ec 0c             	sub    $0xc,%esp
f0100125:	6a 00                	push   $0x0
f0100127:	e8 8f 0b 00 00       	call   f0100cbb <monitor>
f010012c:	83 c4 10             	add    $0x10,%esp
f010012f:	eb f1                	jmp    f0100122 <_panic+0x22>
	panicstr = fmt;
f0100131:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100133:	fa                   	cli    
f0100134:	fc                   	cld    
	va_start(ap, fmt);
f0100135:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100138:	83 ec 04             	sub    $0x4,%esp
f010013b:	ff 75 0c             	pushl  0xc(%ebp)
f010013e:	ff 75 08             	pushl  0x8(%ebp)
f0100141:	8d 83 0a c3 fe ff    	lea    -0x13cf6(%ebx),%eax
f0100147:	50                   	push   %eax
f0100148:	e8 c4 33 00 00       	call   f0103511 <cprintf>
	vcprintf(fmt, ap);
f010014d:	83 c4 08             	add    $0x8,%esp
f0100150:	56                   	push   %esi
f0100151:	57                   	push   %edi
f0100152:	e8 83 33 00 00       	call   f01034da <vcprintf>
	cprintf("\n");
f0100157:	8d 83 7b cc fe ff    	lea    -0x13385(%ebx),%eax
f010015d:	89 04 24             	mov    %eax,(%esp)
f0100160:	e8 ac 33 00 00       	call   f0103511 <cprintf>
f0100165:	83 c4 10             	add    $0x10,%esp
f0100168:	eb b8                	jmp    f0100122 <_panic+0x22>

f010016a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010016a:	55                   	push   %ebp
f010016b:	89 e5                	mov    %esp,%ebp
f010016d:	56                   	push   %esi
f010016e:	53                   	push   %ebx
f010016f:	e8 42 00 00 00       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100174:	81 c3 98 81 01 00    	add    $0x18198,%ebx
	va_list ap;

	va_start(ap, fmt);
f010017a:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010017d:	83 ec 04             	sub    $0x4,%esp
f0100180:	ff 75 0c             	pushl  0xc(%ebp)
f0100183:	ff 75 08             	pushl  0x8(%ebp)
f0100186:	8d 83 22 c3 fe ff    	lea    -0x13cde(%ebx),%eax
f010018c:	50                   	push   %eax
f010018d:	e8 7f 33 00 00       	call   f0103511 <cprintf>
	vcprintf(fmt, ap);
f0100192:	83 c4 08             	add    $0x8,%esp
f0100195:	56                   	push   %esi
f0100196:	ff 75 10             	pushl  0x10(%ebp)
f0100199:	e8 3c 33 00 00       	call   f01034da <vcprintf>
	cprintf("\n");
f010019e:	8d 83 7b cc fe ff    	lea    -0x13385(%ebx),%eax
f01001a4:	89 04 24             	mov    %eax,(%esp)
f01001a7:	e8 65 33 00 00       	call   f0103511 <cprintf>
	va_end(ap);
}
f01001ac:	83 c4 10             	add    $0x10,%esp
f01001af:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b2:	5b                   	pop    %ebx
f01001b3:	5e                   	pop    %esi
f01001b4:	5d                   	pop    %ebp
f01001b5:	c3                   	ret    

f01001b6 <__x86.get_pc_thunk.bx>:
f01001b6:	8b 1c 24             	mov    (%esp),%ebx
f01001b9:	c3                   	ret    

f01001ba <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001ba:	55                   	push   %ebp
f01001bb:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001bd:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c2:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c3:	a8 01                	test   $0x1,%al
f01001c5:	74 0b                	je     f01001d2 <serial_proc_data+0x18>
f01001c7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001cc:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001cd:	0f b6 c0             	movzbl %al,%eax
}
f01001d0:	5d                   	pop    %ebp
f01001d1:	c3                   	ret    
		return -1;
f01001d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001d7:	eb f7                	jmp    f01001d0 <serial_proc_data+0x16>

f01001d9 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001d9:	55                   	push   %ebp
f01001da:	89 e5                	mov    %esp,%ebp
f01001dc:	56                   	push   %esi
f01001dd:	53                   	push   %ebx
f01001de:	e8 d3 ff ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01001e3:	81 c3 29 81 01 00    	add    $0x18129,%ebx
f01001e9:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001eb:	ff d6                	call   *%esi
f01001ed:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f0:	74 2e                	je     f0100220 <cons_intr+0x47>
		if (c == 0)
f01001f2:	85 c0                	test   %eax,%eax
f01001f4:	74 f5                	je     f01001eb <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001f6:	8b 8b 98 1f 00 00    	mov    0x1f98(%ebx),%ecx
f01001fc:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ff:	89 93 98 1f 00 00    	mov    %edx,0x1f98(%ebx)
f0100205:	88 84 0b 94 1d 00 00 	mov    %al,0x1d94(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f010020c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100212:	75 d7                	jne    f01001eb <cons_intr+0x12>
			cons.wpos = 0;
f0100214:	c7 83 98 1f 00 00 00 	movl   $0x0,0x1f98(%ebx)
f010021b:	00 00 00 
f010021e:	eb cb                	jmp    f01001eb <cons_intr+0x12>
	}
}
f0100220:	5b                   	pop    %ebx
f0100221:	5e                   	pop    %esi
f0100222:	5d                   	pop    %ebp
f0100223:	c3                   	ret    

f0100224 <kbd_proc_data>:
{
f0100224:	55                   	push   %ebp
f0100225:	89 e5                	mov    %esp,%ebp
f0100227:	56                   	push   %esi
f0100228:	53                   	push   %ebx
f0100229:	e8 88 ff ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f010022e:	81 c3 de 80 01 00    	add    $0x180de,%ebx
f0100234:	ba 64 00 00 00       	mov    $0x64,%edx
f0100239:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010023a:	a8 01                	test   $0x1,%al
f010023c:	0f 84 06 01 00 00    	je     f0100348 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100242:	a8 20                	test   $0x20,%al
f0100244:	0f 85 05 01 00 00    	jne    f010034f <kbd_proc_data+0x12b>
f010024a:	ba 60 00 00 00       	mov    $0x60,%edx
f010024f:	ec                   	in     (%dx),%al
f0100250:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100252:	3c e0                	cmp    $0xe0,%al
f0100254:	0f 84 93 00 00 00    	je     f01002ed <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f010025a:	84 c0                	test   %al,%al
f010025c:	0f 88 a0 00 00 00    	js     f0100302 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100262:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f0100268:	f6 c1 40             	test   $0x40,%cl
f010026b:	74 0e                	je     f010027b <kbd_proc_data+0x57>
		data |= 0x80;
f010026d:	83 c8 80             	or     $0xffffff80,%eax
f0100270:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100272:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100275:	89 8b 74 1d 00 00    	mov    %ecx,0x1d74(%ebx)
	shift |= shiftcode[data];
f010027b:	0f b6 d2             	movzbl %dl,%edx
f010027e:	0f b6 84 13 74 c4 fe 	movzbl -0x13b8c(%ebx,%edx,1),%eax
f0100285:	ff 
f0100286:	0b 83 74 1d 00 00    	or     0x1d74(%ebx),%eax
	shift ^= togglecode[data];
f010028c:	0f b6 8c 13 74 c3 fe 	movzbl -0x13c8c(%ebx,%edx,1),%ecx
f0100293:	ff 
f0100294:	31 c8                	xor    %ecx,%eax
f0100296:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010029c:	89 c1                	mov    %eax,%ecx
f010029e:	83 e1 03             	and    $0x3,%ecx
f01002a1:	8b 8c 8b f4 1c 00 00 	mov    0x1cf4(%ebx,%ecx,4),%ecx
f01002a8:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002ac:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002af:	a8 08                	test   $0x8,%al
f01002b1:	74 0d                	je     f01002c0 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b3:	89 f2                	mov    %esi,%edx
f01002b5:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002b8:	83 f9 19             	cmp    $0x19,%ecx
f01002bb:	77 7a                	ja     f0100337 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002bd:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c0:	f7 d0                	not    %eax
f01002c2:	a8 06                	test   $0x6,%al
f01002c4:	75 33                	jne    f01002f9 <kbd_proc_data+0xd5>
f01002c6:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002cc:	75 2b                	jne    f01002f9 <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002ce:	83 ec 0c             	sub    $0xc,%esp
f01002d1:	8d 83 3c c3 fe ff    	lea    -0x13cc4(%ebx),%eax
f01002d7:	50                   	push   %eax
f01002d8:	e8 34 32 00 00       	call   f0103511 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002dd:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e2:	ba 92 00 00 00       	mov    $0x92,%edx
f01002e7:	ee                   	out    %al,(%dx)
f01002e8:	83 c4 10             	add    $0x10,%esp
f01002eb:	eb 0c                	jmp    f01002f9 <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002ed:	83 8b 74 1d 00 00 40 	orl    $0x40,0x1d74(%ebx)
		return 0;
f01002f4:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002f9:	89 f0                	mov    %esi,%eax
f01002fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002fe:	5b                   	pop    %ebx
f01002ff:	5e                   	pop    %esi
f0100300:	5d                   	pop    %ebp
f0100301:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100302:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f0100308:	89 ce                	mov    %ecx,%esi
f010030a:	83 e6 40             	and    $0x40,%esi
f010030d:	83 e0 7f             	and    $0x7f,%eax
f0100310:	85 f6                	test   %esi,%esi
f0100312:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100315:	0f b6 d2             	movzbl %dl,%edx
f0100318:	0f b6 84 13 74 c4 fe 	movzbl -0x13b8c(%ebx,%edx,1),%eax
f010031f:	ff 
f0100320:	83 c8 40             	or     $0x40,%eax
f0100323:	0f b6 c0             	movzbl %al,%eax
f0100326:	f7 d0                	not    %eax
f0100328:	21 c8                	and    %ecx,%eax
f010032a:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
		return 0;
f0100330:	be 00 00 00 00       	mov    $0x0,%esi
f0100335:	eb c2                	jmp    f01002f9 <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f0100337:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010033a:	8d 4e 20             	lea    0x20(%esi),%ecx
f010033d:	83 fa 1a             	cmp    $0x1a,%edx
f0100340:	0f 42 f1             	cmovb  %ecx,%esi
f0100343:	e9 78 ff ff ff       	jmp    f01002c0 <kbd_proc_data+0x9c>
		return -1;
f0100348:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010034d:	eb aa                	jmp    f01002f9 <kbd_proc_data+0xd5>
		return -1;
f010034f:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100354:	eb a3                	jmp    f01002f9 <kbd_proc_data+0xd5>

f0100356 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100356:	55                   	push   %ebp
f0100357:	89 e5                	mov    %esp,%ebp
f0100359:	57                   	push   %edi
f010035a:	56                   	push   %esi
f010035b:	53                   	push   %ebx
f010035c:	83 ec 1c             	sub    $0x1c,%esp
f010035f:	e8 52 fe ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100364:	81 c3 a8 7f 01 00    	add    $0x17fa8,%ebx
f010036a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010036d:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100372:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100377:	b9 84 00 00 00       	mov    $0x84,%ecx
f010037c:	eb 09                	jmp    f0100387 <cons_putc+0x31>
f010037e:	89 ca                	mov    %ecx,%edx
f0100380:	ec                   	in     (%dx),%al
f0100381:	ec                   	in     (%dx),%al
f0100382:	ec                   	in     (%dx),%al
f0100383:	ec                   	in     (%dx),%al
	     i++)
f0100384:	83 c6 01             	add    $0x1,%esi
f0100387:	89 fa                	mov    %edi,%edx
f0100389:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010038a:	a8 20                	test   $0x20,%al
f010038c:	75 08                	jne    f0100396 <cons_putc+0x40>
f010038e:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100394:	7e e8                	jle    f010037e <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f0100396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100399:	89 f8                	mov    %edi,%eax
f010039b:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010039e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a3:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003a4:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a9:	bf 79 03 00 00       	mov    $0x379,%edi
f01003ae:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b3:	eb 09                	jmp    f01003be <cons_putc+0x68>
f01003b5:	89 ca                	mov    %ecx,%edx
f01003b7:	ec                   	in     (%dx),%al
f01003b8:	ec                   	in     (%dx),%al
f01003b9:	ec                   	in     (%dx),%al
f01003ba:	ec                   	in     (%dx),%al
f01003bb:	83 c6 01             	add    $0x1,%esi
f01003be:	89 fa                	mov    %edi,%edx
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003c7:	7f 04                	jg     f01003cd <cons_putc+0x77>
f01003c9:	84 c0                	test   %al,%al
f01003cb:	79 e8                	jns    f01003b5 <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003cd:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d2:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003d6:	ee                   	out    %al,(%dx)
f01003d7:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003dc:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e1:	ee                   	out    %al,(%dx)
f01003e2:	b8 08 00 00 00       	mov    $0x8,%eax
f01003e7:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003eb:	89 fa                	mov    %edi,%edx
f01003ed:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003f3:	89 f8                	mov    %edi,%eax
f01003f5:	80 cc 07             	or     $0x7,%ah
f01003f8:	85 d2                	test   %edx,%edx
f01003fa:	0f 45 c7             	cmovne %edi,%eax
f01003fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100400:	0f b6 c0             	movzbl %al,%eax
f0100403:	83 f8 09             	cmp    $0x9,%eax
f0100406:	0f 84 b9 00 00 00    	je     f01004c5 <cons_putc+0x16f>
f010040c:	83 f8 09             	cmp    $0x9,%eax
f010040f:	7e 74                	jle    f0100485 <cons_putc+0x12f>
f0100411:	83 f8 0a             	cmp    $0xa,%eax
f0100414:	0f 84 9e 00 00 00    	je     f01004b8 <cons_putc+0x162>
f010041a:	83 f8 0d             	cmp    $0xd,%eax
f010041d:	0f 85 d9 00 00 00    	jne    f01004fc <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100423:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f010042a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100430:	c1 e8 16             	shr    $0x16,%eax
f0100433:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100436:	c1 e0 04             	shl    $0x4,%eax
f0100439:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100440:	66 81 bb 9c 1f 00 00 	cmpw   $0x7cf,0x1f9c(%ebx)
f0100447:	cf 07 
f0100449:	0f 87 d4 00 00 00    	ja     f0100523 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f010044f:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f0100455:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045a:	89 ca                	mov    %ecx,%edx
f010045c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045d:	0f b7 9b 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%ebx
f0100464:	8d 71 01             	lea    0x1(%ecx),%esi
f0100467:	89 d8                	mov    %ebx,%eax
f0100469:	66 c1 e8 08          	shr    $0x8,%ax
f010046d:	89 f2                	mov    %esi,%edx
f010046f:	ee                   	out    %al,(%dx)
f0100470:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100475:	89 ca                	mov    %ecx,%edx
f0100477:	ee                   	out    %al,(%dx)
f0100478:	89 d8                	mov    %ebx,%eax
f010047a:	89 f2                	mov    %esi,%edx
f010047c:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010047d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100480:	5b                   	pop    %ebx
f0100481:	5e                   	pop    %esi
f0100482:	5f                   	pop    %edi
f0100483:	5d                   	pop    %ebp
f0100484:	c3                   	ret    
	switch (c & 0xff) {
f0100485:	83 f8 08             	cmp    $0x8,%eax
f0100488:	75 72                	jne    f01004fc <cons_putc+0x1a6>
		if (crt_pos > 0) {
f010048a:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f0100491:	66 85 c0             	test   %ax,%ax
f0100494:	74 b9                	je     f010044f <cons_putc+0xf9>
			crt_pos--;
f0100496:	83 e8 01             	sub    $0x1,%eax
f0100499:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a0:	0f b7 c0             	movzwl %ax,%eax
f01004a3:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004a7:	b2 00                	mov    $0x0,%dl
f01004a9:	83 ca 20             	or     $0x20,%edx
f01004ac:	8b 8b a0 1f 00 00    	mov    0x1fa0(%ebx),%ecx
f01004b2:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004b6:	eb 88                	jmp    f0100440 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004b8:	66 83 83 9c 1f 00 00 	addw   $0x50,0x1f9c(%ebx)
f01004bf:	50 
f01004c0:	e9 5e ff ff ff       	jmp    f0100423 <cons_putc+0xcd>
		cons_putc(' ');
f01004c5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ca:	e8 87 fe ff ff       	call   f0100356 <cons_putc>
		cons_putc(' ');
f01004cf:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d4:	e8 7d fe ff ff       	call   f0100356 <cons_putc>
		cons_putc(' ');
f01004d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004de:	e8 73 fe ff ff       	call   f0100356 <cons_putc>
		cons_putc(' ');
f01004e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e8:	e8 69 fe ff ff       	call   f0100356 <cons_putc>
		cons_putc(' ');
f01004ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f2:	e8 5f fe ff ff       	call   f0100356 <cons_putc>
f01004f7:	e9 44 ff ff ff       	jmp    f0100440 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004fc:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f0100503:	8d 50 01             	lea    0x1(%eax),%edx
f0100506:	66 89 93 9c 1f 00 00 	mov    %dx,0x1f9c(%ebx)
f010050d:	0f b7 c0             	movzwl %ax,%eax
f0100510:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f0100516:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f010051a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010051e:	e9 1d ff ff ff       	jmp    f0100440 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100523:	8b 83 a0 1f 00 00    	mov    0x1fa0(%ebx),%eax
f0100529:	83 ec 04             	sub    $0x4,%esp
f010052c:	68 00 0f 00 00       	push   $0xf00
f0100531:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100537:	52                   	push   %edx
f0100538:	50                   	push   %eax
f0100539:	e8 87 3c 00 00       	call   f01041c5 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010053e:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f0100544:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010054a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100550:	83 c4 10             	add    $0x10,%esp
f0100553:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100558:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010055b:	39 d0                	cmp    %edx,%eax
f010055d:	75 f4                	jne    f0100553 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f010055f:	66 83 ab 9c 1f 00 00 	subw   $0x50,0x1f9c(%ebx)
f0100566:	50 
f0100567:	e9 e3 fe ff ff       	jmp    f010044f <cons_putc+0xf9>

f010056c <serial_intr>:
{
f010056c:	e8 e7 01 00 00       	call   f0100758 <__x86.get_pc_thunk.ax>
f0100571:	05 9b 7d 01 00       	add    $0x17d9b,%eax
	if (serial_exists)
f0100576:	80 b8 a8 1f 00 00 00 	cmpb   $0x0,0x1fa8(%eax)
f010057d:	75 02                	jne    f0100581 <serial_intr+0x15>
f010057f:	f3 c3                	repz ret 
{
f0100581:	55                   	push   %ebp
f0100582:	89 e5                	mov    %esp,%ebp
f0100584:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100587:	8d 80 ae 7e fe ff    	lea    -0x18152(%eax),%eax
f010058d:	e8 47 fc ff ff       	call   f01001d9 <cons_intr>
}
f0100592:	c9                   	leave  
f0100593:	c3                   	ret    

f0100594 <kbd_intr>:
{
f0100594:	55                   	push   %ebp
f0100595:	89 e5                	mov    %esp,%ebp
f0100597:	83 ec 08             	sub    $0x8,%esp
f010059a:	e8 b9 01 00 00       	call   f0100758 <__x86.get_pc_thunk.ax>
f010059f:	05 6d 7d 01 00       	add    $0x17d6d,%eax
	cons_intr(kbd_proc_data);
f01005a4:	8d 80 18 7f fe ff    	lea    -0x180e8(%eax),%eax
f01005aa:	e8 2a fc ff ff       	call   f01001d9 <cons_intr>
}
f01005af:	c9                   	leave  
f01005b0:	c3                   	ret    

f01005b1 <cons_getc>:
{
f01005b1:	55                   	push   %ebp
f01005b2:	89 e5                	mov    %esp,%ebp
f01005b4:	53                   	push   %ebx
f01005b5:	83 ec 04             	sub    $0x4,%esp
f01005b8:	e8 f9 fb ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01005bd:	81 c3 4f 7d 01 00    	add    $0x17d4f,%ebx
	serial_intr();
f01005c3:	e8 a4 ff ff ff       	call   f010056c <serial_intr>
	kbd_intr();
f01005c8:	e8 c7 ff ff ff       	call   f0100594 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005cd:	8b 93 94 1f 00 00    	mov    0x1f94(%ebx),%edx
	return 0;
f01005d3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005d8:	3b 93 98 1f 00 00    	cmp    0x1f98(%ebx),%edx
f01005de:	74 19                	je     f01005f9 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e0:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e3:	89 8b 94 1f 00 00    	mov    %ecx,0x1f94(%ebx)
f01005e9:	0f b6 84 13 94 1d 00 	movzbl 0x1d94(%ebx,%edx,1),%eax
f01005f0:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f1:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005f7:	74 06                	je     f01005ff <cons_getc+0x4e>
}
f01005f9:	83 c4 04             	add    $0x4,%esp
f01005fc:	5b                   	pop    %ebx
f01005fd:	5d                   	pop    %ebp
f01005fe:	c3                   	ret    
			cons.rpos = 0;
f01005ff:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f0100606:	00 00 00 
f0100609:	eb ee                	jmp    f01005f9 <cons_getc+0x48>

f010060b <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f010060b:	55                   	push   %ebp
f010060c:	89 e5                	mov    %esp,%ebp
f010060e:	57                   	push   %edi
f010060f:	56                   	push   %esi
f0100610:	53                   	push   %ebx
f0100611:	83 ec 1c             	sub    $0x1c,%esp
f0100614:	e8 9d fb ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100619:	81 c3 f3 7c 01 00    	add    $0x17cf3,%ebx
	was = *cp;
f010061f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100626:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010062d:	5a a5 
	if (*cp != 0xA55A) {
f010062f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100636:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010063a:	0f 84 bc 00 00 00    	je     f01006fc <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100640:	c7 83 a4 1f 00 00 b4 	movl   $0x3b4,0x1fa4(%ebx)
f0100647:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010064a:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100651:	8b bb a4 1f 00 00    	mov    0x1fa4(%ebx),%edi
f0100657:	b8 0e 00 00 00       	mov    $0xe,%eax
f010065c:	89 fa                	mov    %edi,%edx
f010065e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010065f:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100662:	89 ca                	mov    %ecx,%edx
f0100664:	ec                   	in     (%dx),%al
f0100665:	0f b6 f0             	movzbl %al,%esi
f0100668:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010066b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100670:	89 fa                	mov    %edi,%edx
f0100672:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100673:	89 ca                	mov    %ecx,%edx
f0100675:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100679:	89 bb a0 1f 00 00    	mov    %edi,0x1fa0(%ebx)
	pos |= inb(addr_6845 + 1);
f010067f:	0f b6 c0             	movzbl %al,%eax
f0100682:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100684:	66 89 b3 9c 1f 00 00 	mov    %si,0x1f9c(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100690:	89 c8                	mov    %ecx,%eax
f0100692:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100697:	ee                   	out    %al,(%dx)
f0100698:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010069d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a2:	89 fa                	mov    %edi,%edx
f01006a4:	ee                   	out    %al,(%dx)
f01006a5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006aa:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006af:	ee                   	out    %al,(%dx)
f01006b0:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006b5:	89 c8                	mov    %ecx,%eax
f01006b7:	89 f2                	mov    %esi,%edx
f01006b9:	ee                   	out    %al,(%dx)
f01006ba:	b8 03 00 00 00       	mov    $0x3,%eax
f01006bf:	89 fa                	mov    %edi,%edx
f01006c1:	ee                   	out    %al,(%dx)
f01006c2:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006c7:	89 c8                	mov    %ecx,%eax
f01006c9:	ee                   	out    %al,(%dx)
f01006ca:	b8 01 00 00 00       	mov    $0x1,%eax
f01006cf:	89 f2                	mov    %esi,%edx
f01006d1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006d7:	ec                   	in     (%dx),%al
f01006d8:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006da:	3c ff                	cmp    $0xff,%al
f01006dc:	0f 95 83 a8 1f 00 00 	setne  0x1fa8(%ebx)
f01006e3:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006e8:	ec                   	in     (%dx),%al
f01006e9:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006ee:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006ef:	80 f9 ff             	cmp    $0xff,%cl
f01006f2:	74 25                	je     f0100719 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006f7:	5b                   	pop    %ebx
f01006f8:	5e                   	pop    %esi
f01006f9:	5f                   	pop    %edi
f01006fa:	5d                   	pop    %ebp
f01006fb:	c3                   	ret    
		*cp = was;
f01006fc:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100703:	c7 83 a4 1f 00 00 d4 	movl   $0x3d4,0x1fa4(%ebx)
f010070a:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010070d:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100714:	e9 38 ff ff ff       	jmp    f0100651 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f0100719:	83 ec 0c             	sub    $0xc,%esp
f010071c:	8d 83 48 c3 fe ff    	lea    -0x13cb8(%ebx),%eax
f0100722:	50                   	push   %eax
f0100723:	e8 e9 2d 00 00       	call   f0103511 <cprintf>
f0100728:	83 c4 10             	add    $0x10,%esp
}
f010072b:	eb c7                	jmp    f01006f4 <cons_init+0xe9>

f010072d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010072d:	55                   	push   %ebp
f010072e:	89 e5                	mov    %esp,%ebp
f0100730:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100733:	8b 45 08             	mov    0x8(%ebp),%eax
f0100736:	e8 1b fc ff ff       	call   f0100356 <cons_putc>
}
f010073b:	c9                   	leave  
f010073c:	c3                   	ret    

f010073d <getchar>:

int
getchar(void)
{
f010073d:	55                   	push   %ebp
f010073e:	89 e5                	mov    %esp,%ebp
f0100740:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100743:	e8 69 fe ff ff       	call   f01005b1 <cons_getc>
f0100748:	85 c0                	test   %eax,%eax
f010074a:	74 f7                	je     f0100743 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010074c:	c9                   	leave  
f010074d:	c3                   	ret    

f010074e <iscons>:

int
iscons(int fdnum)
{
f010074e:	55                   	push   %ebp
f010074f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100751:	b8 01 00 00 00       	mov    $0x1,%eax
f0100756:	5d                   	pop    %ebp
f0100757:	c3                   	ret    

f0100758 <__x86.get_pc_thunk.ax>:
f0100758:	8b 04 24             	mov    (%esp),%eax
f010075b:	c3                   	ret    

f010075c <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010075c:	55                   	push   %ebp
f010075d:	89 e5                	mov    %esp,%ebp
f010075f:	57                   	push   %edi
f0100760:	56                   	push   %esi
f0100761:	53                   	push   %ebx
f0100762:	83 ec 0c             	sub    $0xc,%esp
f0100765:	e8 4c fa ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f010076a:	81 c3 a2 7b 01 00    	add    $0x17ba2,%ebx
f0100770:	be 00 00 00 00       	mov    $0x0,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100775:	8d bb 74 c5 fe ff    	lea    -0x13a8c(%ebx),%edi
f010077b:	83 ec 04             	sub    $0x4,%esp
f010077e:	ff b4 1e 18 1d 00 00 	pushl  0x1d18(%esi,%ebx,1)
f0100785:	ff b4 1e 14 1d 00 00 	pushl  0x1d14(%esi,%ebx,1)
f010078c:	57                   	push   %edi
f010078d:	e8 7f 2d 00 00       	call   f0103511 <cprintf>
f0100792:	83 c6 0c             	add    $0xc,%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100795:	83 c4 10             	add    $0x10,%esp
f0100798:	83 fe 3c             	cmp    $0x3c,%esi
f010079b:	75 de                	jne    f010077b <mon_help+0x1f>
	return 0;
}
f010079d:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a5:	5b                   	pop    %ebx
f01007a6:	5e                   	pop    %esi
f01007a7:	5f                   	pop    %edi
f01007a8:	5d                   	pop    %ebp
f01007a9:	c3                   	ret    

f01007aa <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007aa:	55                   	push   %ebp
f01007ab:	89 e5                	mov    %esp,%ebp
f01007ad:	57                   	push   %edi
f01007ae:	56                   	push   %esi
f01007af:	53                   	push   %ebx
f01007b0:	83 ec 18             	sub    $0x18,%esp
f01007b3:	e8 fe f9 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01007b8:	81 c3 54 7b 01 00    	add    $0x17b54,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007be:	8d 83 7d c5 fe ff    	lea    -0x13a83(%ebx),%eax
f01007c4:	50                   	push   %eax
f01007c5:	e8 47 2d 00 00       	call   f0103511 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ca:	83 c4 08             	add    $0x8,%esp
f01007cd:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f01007d3:	8d 83 30 c7 fe ff    	lea    -0x138d0(%ebx),%eax
f01007d9:	50                   	push   %eax
f01007da:	e8 32 2d 00 00       	call   f0103511 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007df:	83 c4 0c             	add    $0xc,%esp
f01007e2:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007e8:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007ee:	50                   	push   %eax
f01007ef:	57                   	push   %edi
f01007f0:	8d 83 58 c7 fe ff    	lea    -0x138a8(%ebx),%eax
f01007f6:	50                   	push   %eax
f01007f7:	e8 15 2d 00 00       	call   f0103511 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007fc:	83 c4 0c             	add    $0xc,%esp
f01007ff:	c7 c0 b9 45 10 f0    	mov    $0xf01045b9,%eax
f0100805:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010080b:	52                   	push   %edx
f010080c:	50                   	push   %eax
f010080d:	8d 83 7c c7 fe ff    	lea    -0x13884(%ebx),%eax
f0100813:	50                   	push   %eax
f0100814:	e8 f8 2c 00 00       	call   f0103511 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100819:	83 c4 0c             	add    $0xc,%esp
f010081c:	c7 c0 80 a0 11 f0    	mov    $0xf011a080,%eax
f0100822:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100828:	52                   	push   %edx
f0100829:	50                   	push   %eax
f010082a:	8d 83 a0 c7 fe ff    	lea    -0x13860(%ebx),%eax
f0100830:	50                   	push   %eax
f0100831:	e8 db 2c 00 00       	call   f0103511 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100836:	83 c4 0c             	add    $0xc,%esp
f0100839:	c7 c6 c0 a6 11 f0    	mov    $0xf011a6c0,%esi
f010083f:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100845:	50                   	push   %eax
f0100846:	56                   	push   %esi
f0100847:	8d 83 c4 c7 fe ff    	lea    -0x1383c(%ebx),%eax
f010084d:	50                   	push   %eax
f010084e:	e8 be 2c 00 00       	call   f0103511 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100853:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100856:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010085c:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085e:	c1 fe 0a             	sar    $0xa,%esi
f0100861:	56                   	push   %esi
f0100862:	8d 83 e8 c7 fe ff    	lea    -0x13818(%ebx),%eax
f0100868:	50                   	push   %eax
f0100869:	e8 a3 2c 00 00       	call   f0103511 <cprintf>
	return 0;
}
f010086e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100873:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100876:	5b                   	pop    %ebx
f0100877:	5e                   	pop    %esi
f0100878:	5f                   	pop    %edi
f0100879:	5d                   	pop    %ebp
f010087a:	c3                   	ret    

f010087b <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010087b:	55                   	push   %ebp
f010087c:	89 e5                	mov    %esp,%ebp
f010087e:	53                   	push   %ebx
f010087f:	83 ec 10             	sub    $0x10,%esp
f0100882:	e8 2f f9 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100887:	81 c3 85 7a 01 00    	add    $0x17a85,%ebx
	// Your code here.
	cprintf("Stack backtrace:\n");
f010088d:	8d 83 96 c5 fe ff    	lea    -0x13a6a(%ebx),%eax
f0100893:	50                   	push   %eax
f0100894:	e8 78 2c 00 00       	call   f0103511 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100899:	89 e8                	mov    %ebp,%eax
		fn_name[i] = '\0';
		cprintf("%s:%d: %s+%d\n", info.eip_file, info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (struct Trapframe*)((uint32_t*)ebp + 8);
	}
	return 0;
}
f010089b:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01008a3:	c9                   	leave  
f01008a4:	c3                   	ret    

f01008a5 <show_mappings>:

int show_mappings(int argc, char **argv, struct Trapframe *tf)
{
f01008a5:	55                   	push   %ebp
f01008a6:	89 e5                	mov    %esp,%ebp
f01008a8:	57                   	push   %edi
f01008a9:	56                   	push   %esi
f01008aa:	53                   	push   %ebx
f01008ab:	83 ec 2c             	sub    $0x2c,%esp
f01008ae:	e8 03 f9 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01008b3:	81 c3 59 7a 01 00    	add    $0x17a59,%ebx
f01008b9:	8b 75 0c             	mov    0xc(%ebp),%esi
	assert(argc == 3);
f01008bc:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01008c0:	75 52                	jne    f0100914 <show_mappings+0x6f>
	uintptr_t start = strtol(argv[1], NULL, 16), end = strtol(argv[2], NULL, 16);
f01008c2:	83 ec 04             	sub    $0x4,%esp
f01008c5:	6a 10                	push   $0x10
f01008c7:	6a 00                	push   $0x0
f01008c9:	ff 76 04             	pushl  0x4(%esi)
f01008cc:	e8 c5 39 00 00       	call   f0104296 <strtol>
f01008d1:	89 c7                	mov    %eax,%edi
f01008d3:	83 c4 0c             	add    $0xc,%esp
f01008d6:	6a 10                	push   $0x10
f01008d8:	6a 00                	push   $0x0
f01008da:	ff 76 08             	pushl  0x8(%esi)
f01008dd:	e8 b4 39 00 00       	call   f0104296 <strtol>
f01008e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	cprintf("Following are address mapping from %x to %x:\n", start, end);
f01008e5:	83 c4 0c             	add    $0xc,%esp
f01008e8:	50                   	push   %eax
f01008e9:	57                   	push   %edi
f01008ea:	8d 83 14 c8 fe ff    	lea    -0x137ec(%ebx),%eax
f01008f0:	50                   	push   %eax
f01008f1:	e8 1b 2c 00 00       	call   f0103511 <cprintf>
	uintptr_t current_page_address;
	struct PageInfo *page = NULL;
	pte_t *pte = NULL;
f01008f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f01008fd:	83 c4 10             	add    $0x10,%esp
	{
		page = page_lookup(kern_pgdir, (void *)current_page_address, &pte);
f0100900:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0100906:	89 45 d0             	mov    %eax,-0x30(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100909:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010090f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f0100912:	eb 35                	jmp    f0100949 <show_mappings+0xa4>
	assert(argc == 3);
f0100914:	8d 83 a8 c5 fe ff    	lea    -0x13a58(%ebx),%eax
f010091a:	50                   	push   %eax
f010091b:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0100921:	50                   	push   %eax
f0100922:	6a 64                	push   $0x64
f0100924:	8d 83 c7 c5 fe ff    	lea    -0x13a39(%ebx),%eax
f010092a:	50                   	push   %eax
f010092b:	e8 d0 f7 ff ff       	call   f0100100 <_panic>
		if (!page)
		{
			cprintf("  The virtual address %x have no physical page\n", current_page_address);
f0100930:	83 ec 08             	sub    $0x8,%esp
f0100933:	57                   	push   %edi
f0100934:	8d 83 44 c8 fe ff    	lea    -0x137bc(%ebx),%eax
f010093a:	50                   	push   %eax
f010093b:	e8 d1 2b 00 00       	call   f0103511 <cprintf>
			continue;
f0100940:	83 c4 10             	add    $0x10,%esp
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f0100943:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0100949:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010094c:	0f 87 bb 00 00 00    	ja     f0100a0d <show_mappings+0x168>
		page = page_lookup(kern_pgdir, (void *)current_page_address, &pte);
f0100952:	83 ec 04             	sub    $0x4,%esp
f0100955:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100958:	50                   	push   %eax
f0100959:	57                   	push   %edi
f010095a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010095d:	ff 30                	pushl  (%eax)
f010095f:	e8 d8 0c 00 00       	call   f010163c <page_lookup>
f0100964:	89 c6                	mov    %eax,%esi
		if (!page)
f0100966:	83 c4 10             	add    $0x10,%esp
f0100969:	85 c0                	test   %eax,%eax
f010096b:	74 c3                	je     f0100930 <show_mappings+0x8b>
		}
		cprintf("  The virtual address is %x\n", current_page_address);
f010096d:	83 ec 08             	sub    $0x8,%esp
f0100970:	57                   	push   %edi
f0100971:	8d 83 d6 c5 fe ff    	lea    -0x13a2a(%ebx),%eax
f0100977:	50                   	push   %eax
f0100978:	e8 94 2b 00 00       	call   f0103511 <cprintf>
		cprintf("    The mapping physical address is %08x\n", page2pa(page));
f010097d:	83 c4 08             	add    $0x8,%esp
f0100980:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100983:	2b 30                	sub    (%eax),%esi
f0100985:	c1 fe 03             	sar    $0x3,%esi
f0100988:	c1 e6 0c             	shl    $0xc,%esi
f010098b:	56                   	push   %esi
f010098c:	8d 83 74 c8 fe ff    	lea    -0x1378c(%ebx),%eax
f0100992:	50                   	push   %eax
f0100993:	e8 79 2b 00 00       	call   f0103511 <cprintf>
		cprintf("    The permissions bits:\n");
f0100998:	8d 83 f3 c5 fe ff    	lea    -0x13a0d(%ebx),%eax
f010099e:	89 04 24             	mov    %eax,(%esp)
f01009a1:	e8 6b 2b 00 00       	call   f0103511 <cprintf>
				(*pte & PTE_PWT) != 0,
				(*pte & PTE_PCD) != 0,
				(*pte & PTE_A) != 0,
				(*pte & PTE_D) != 0,
				(*pte & PTE_PS) != 0,
				(*pte & PTE_G) != 0);
f01009a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009a9:	8b 00                	mov    (%eax),%eax
		cprintf("      PTE_P: %d PTE_W: %d PTE_U: %d PTE_PWT: %d PTE_PCD: %d PTE_A: %d PTE_D: %d PTE_PS: %d PTE_G: %d\n\n",
f01009ab:	83 c4 08             	add    $0x8,%esp
f01009ae:	89 c2                	mov    %eax,%edx
f01009b0:	c1 ea 08             	shr    $0x8,%edx
f01009b3:	83 e2 01             	and    $0x1,%edx
f01009b6:	52                   	push   %edx
f01009b7:	89 c2                	mov    %eax,%edx
f01009b9:	c1 ea 07             	shr    $0x7,%edx
f01009bc:	83 e2 01             	and    $0x1,%edx
f01009bf:	52                   	push   %edx
f01009c0:	89 c2                	mov    %eax,%edx
f01009c2:	c1 ea 06             	shr    $0x6,%edx
f01009c5:	83 e2 01             	and    $0x1,%edx
f01009c8:	52                   	push   %edx
f01009c9:	89 c2                	mov    %eax,%edx
f01009cb:	c1 ea 05             	shr    $0x5,%edx
f01009ce:	83 e2 01             	and    $0x1,%edx
f01009d1:	52                   	push   %edx
f01009d2:	89 c2                	mov    %eax,%edx
f01009d4:	c1 ea 04             	shr    $0x4,%edx
f01009d7:	83 e2 01             	and    $0x1,%edx
f01009da:	52                   	push   %edx
f01009db:	89 c2                	mov    %eax,%edx
f01009dd:	c1 ea 03             	shr    $0x3,%edx
f01009e0:	83 e2 01             	and    $0x1,%edx
f01009e3:	52                   	push   %edx
f01009e4:	89 c2                	mov    %eax,%edx
f01009e6:	c1 ea 02             	shr    $0x2,%edx
f01009e9:	83 e2 01             	and    $0x1,%edx
f01009ec:	52                   	push   %edx
f01009ed:	89 c2                	mov    %eax,%edx
f01009ef:	d1 ea                	shr    %edx
f01009f1:	83 e2 01             	and    $0x1,%edx
f01009f4:	52                   	push   %edx
f01009f5:	83 e0 01             	and    $0x1,%eax
f01009f8:	50                   	push   %eax
f01009f9:	8d 83 a0 c8 fe ff    	lea    -0x13760(%ebx),%eax
f01009ff:	50                   	push   %eax
f0100a00:	e8 0c 2b 00 00       	call   f0103511 <cprintf>
f0100a05:	83 c4 30             	add    $0x30,%esp
f0100a08:	e9 36 ff ff ff       	jmp    f0100943 <show_mappings+0x9e>
	}
	return 0;
}
f0100a0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a12:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a15:	5b                   	pop    %ebx
f0100a16:	5e                   	pop    %esi
f0100a17:	5f                   	pop    %edi
f0100a18:	5d                   	pop    %ebp
f0100a19:	c3                   	ret    

f0100a1a <modify_permission>:
int modify_permission(int argc, char **argv, struct Trapframe *tf)
{
f0100a1a:	55                   	push   %ebp
f0100a1b:	89 e5                	mov    %esp,%ebp
f0100a1d:	57                   	push   %edi
f0100a1e:	56                   	push   %esi
f0100a1f:	53                   	push   %ebx
f0100a20:	83 ec 20             	sub    $0x20,%esp
f0100a23:	e8 8e f7 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100a28:	81 c3 e4 78 01 00    	add    $0x178e4,%ebx
f0100a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
	uintptr_t virtual_address = strtol(argv[2], NULL, 16);
f0100a31:	6a 10                	push   $0x10
f0100a33:	6a 00                	push   $0x0
f0100a35:	ff 76 08             	pushl  0x8(%esi)
f0100a38:	e8 59 38 00 00       	call   f0104296 <strtol>
	// ops: 0-SET 1-CLEAR 2-CHANGE
	char *ops = argv[1];
f0100a3d:	8b 56 04             	mov    0x4(%esi),%edx
f0100a40:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int new_perm = 0;
	char *perm = argv[3];
f0100a43:	8b 7e 0c             	mov    0xc(%esi),%edi
	uint32_t tmp = 0xffffffff;
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)virtual_address, 0);
f0100a46:	83 c4 0c             	add    $0xc,%esp
f0100a49:	6a 00                	push   $0x0
f0100a4b:	50                   	push   %eax
f0100a4c:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0100a52:	ff 30                	pushl  (%eax)
f0100a54:	e8 e9 0a 00 00       	call   f0101542 <pgdir_walk>
f0100a59:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if (!strcmp(ops, "CHANGE"))
f0100a5c:	83 c4 08             	add    $0x8,%esp
f0100a5f:	8d 83 0e c6 fe ff    	lea    -0x139f2(%ebx),%eax
f0100a65:	50                   	push   %eax
f0100a66:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100a69:	e8 6f 36 00 00       	call   f01040dd <strcmp>
f0100a6e:	83 c4 10             	add    $0x10,%esp
f0100a71:	85 c0                	test   %eax,%eax
f0100a73:	0f 85 81 00 00 00    	jne    f0100afa <modify_permission+0xe0>
	{
		assert(argc == 5);
f0100a79:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100a7d:	75 5c                	jne    f0100adb <modify_permission+0xc1>
		new_perm = strtol(argv[4], NULL, 10);
f0100a7f:	83 ec 04             	sub    $0x4,%esp
f0100a82:	6a 0a                	push   $0xa
f0100a84:	6a 00                	push   $0x0
f0100a86:	ff 76 10             	pushl  0x10(%esi)
f0100a89:	e8 08 38 00 00       	call   f0104296 <strtol>
f0100a8e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	}
	else 
	{
		panic("INVALID COMMAND\n");
	}
	if (new_perm == 1)
f0100a91:	83 c4 10             	add    $0x10,%esp
f0100a94:	83 f8 01             	cmp    $0x1,%eax
f0100a97:	0f 95 c0             	setne  %al
f0100a9a:	0f b6 c0             	movzbl %al,%eax
f0100a9d:	f7 d8                	neg    %eax
f0100a9f:	89 c6                	mov    %eax,%esi
	{
		tmp = 0;
	}
	if (strcmp(perm, "PTE_P") == 0)
f0100aa1:	83 ec 08             	sub    $0x8,%esp
f0100aa4:	8d 83 88 cc fe ff    	lea    -0x13378(%ebx),%eax
f0100aaa:	50                   	push   %eax
f0100aab:	57                   	push   %edi
f0100aac:	e8 2c 36 00 00       	call   f01040dd <strcmp>
f0100ab1:	83 c4 10             	add    $0x10,%esp
f0100ab4:	85 c0                	test   %eax,%eax
f0100ab6:	0f 85 f3 00 00 00    	jne    f0100baf <modify_permission+0x195>
	{
		tmp = tmp ^ PTE_P;
f0100abc:	83 f6 01             	xor    $0x1,%esi
	}
	else if (strcmp(perm, "PTE_G") == 0)
	{
		tmp = tmp ^ PTE_G;
	}
	if (new_perm == 1)
f0100abf:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
f0100ac3:	0f 84 e8 01 00 00    	je     f0100cb1 <modify_permission+0x297>
	{
		*pte |= tmp;
	}
	else
	{
		*pte &= tmp;
f0100ac9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100acc:	21 30                	and    %esi,(%eax)
	}
	return 0;
}
f0100ace:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ad3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ad6:	5b                   	pop    %ebx
f0100ad7:	5e                   	pop    %esi
f0100ad8:	5f                   	pop    %edi
f0100ad9:	5d                   	pop    %ebp
f0100ada:	c3                   	ret    
		assert(argc == 5);
f0100adb:	8d 83 15 c6 fe ff    	lea    -0x139eb(%ebx),%eax
f0100ae1:	50                   	push   %eax
f0100ae2:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0100ae8:	50                   	push   %eax
f0100ae9:	68 8d 00 00 00       	push   $0x8d
f0100aee:	8d 83 c7 c5 fe ff    	lea    -0x13a39(%ebx),%eax
f0100af4:	50                   	push   %eax
f0100af5:	e8 06 f6 ff ff       	call   f0100100 <_panic>
	else if (!strcmp(ops, "SET"))
f0100afa:	83 ec 08             	sub    $0x8,%esp
f0100afd:	8d 83 1f c6 fe ff    	lea    -0x139e1(%ebx),%eax
f0100b03:	50                   	push   %eax
f0100b04:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100b07:	e8 d1 35 00 00       	call   f01040dd <strcmp>
f0100b0c:	83 c4 10             	add    $0x10,%esp
f0100b0f:	85 c0                	test   %eax,%eax
f0100b11:	75 36                	jne    f0100b49 <modify_permission+0x12f>
		assert(argc == 4);
f0100b13:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100b17:	75 11                	jne    f0100b2a <modify_permission+0x110>
		new_perm = 1;
f0100b19:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		tmp = 0;
f0100b20:	be 00 00 00 00       	mov    $0x0,%esi
f0100b25:	e9 77 ff ff ff       	jmp    f0100aa1 <modify_permission+0x87>
		assert(argc == 4);
f0100b2a:	8d 83 23 c6 fe ff    	lea    -0x139dd(%ebx),%eax
f0100b30:	50                   	push   %eax
f0100b31:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0100b37:	50                   	push   %eax
f0100b38:	68 92 00 00 00       	push   $0x92
f0100b3d:	8d 83 c7 c5 fe ff    	lea    -0x13a39(%ebx),%eax
f0100b43:	50                   	push   %eax
f0100b44:	e8 b7 f5 ff ff       	call   f0100100 <_panic>
	else if (!strcmp(ops, "CLEAR"))
f0100b49:	83 ec 08             	sub    $0x8,%esp
f0100b4c:	8d 83 2d c6 fe ff    	lea    -0x139d3(%ebx),%eax
f0100b52:	50                   	push   %eax
f0100b53:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100b56:	e8 82 35 00 00       	call   f01040dd <strcmp>
f0100b5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100b5e:	83 c4 10             	add    $0x10,%esp
f0100b61:	85 c0                	test   %eax,%eax
f0100b63:	75 2f                	jne    f0100b94 <modify_permission+0x17a>
		assert(argc == 4);
f0100b65:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100b69:	75 0a                	jne    f0100b75 <modify_permission+0x15b>
	uint32_t tmp = 0xffffffff;
f0100b6b:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100b70:	e9 2c ff ff ff       	jmp    f0100aa1 <modify_permission+0x87>
		assert(argc == 4);
f0100b75:	8d 83 23 c6 fe ff    	lea    -0x139dd(%ebx),%eax
f0100b7b:	50                   	push   %eax
f0100b7c:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0100b82:	50                   	push   %eax
f0100b83:	68 97 00 00 00       	push   $0x97
f0100b88:	8d 83 c7 c5 fe ff    	lea    -0x13a39(%ebx),%eax
f0100b8e:	50                   	push   %eax
f0100b8f:	e8 6c f5 ff ff       	call   f0100100 <_panic>
		panic("INVALID COMMAND\n");
f0100b94:	83 ec 04             	sub    $0x4,%esp
f0100b97:	8d 83 33 c6 fe ff    	lea    -0x139cd(%ebx),%eax
f0100b9d:	50                   	push   %eax
f0100b9e:	68 9c 00 00 00       	push   $0x9c
f0100ba3:	8d 83 c7 c5 fe ff    	lea    -0x13a39(%ebx),%eax
f0100ba9:	50                   	push   %eax
f0100baa:	e8 51 f5 ff ff       	call   f0100100 <_panic>
	else if (strcmp(perm, "PTE_W") == 0)
f0100baf:	83 ec 08             	sub    $0x8,%esp
f0100bb2:	8d 83 99 cc fe ff    	lea    -0x13367(%ebx),%eax
f0100bb8:	50                   	push   %eax
f0100bb9:	57                   	push   %edi
f0100bba:	e8 1e 35 00 00       	call   f01040dd <strcmp>
f0100bbf:	83 c4 10             	add    $0x10,%esp
f0100bc2:	85 c0                	test   %eax,%eax
f0100bc4:	75 08                	jne    f0100bce <modify_permission+0x1b4>
		tmp = tmp ^ PTE_W;
f0100bc6:	83 f6 02             	xor    $0x2,%esi
f0100bc9:	e9 f1 fe ff ff       	jmp    f0100abf <modify_permission+0xa5>
	else if (strcmp(perm, "PTE_U") == 0)
f0100bce:	83 ec 08             	sub    $0x8,%esp
f0100bd1:	8d 83 db cb fe ff    	lea    -0x13425(%ebx),%eax
f0100bd7:	50                   	push   %eax
f0100bd8:	57                   	push   %edi
f0100bd9:	e8 ff 34 00 00       	call   f01040dd <strcmp>
f0100bde:	83 c4 10             	add    $0x10,%esp
f0100be1:	85 c0                	test   %eax,%eax
f0100be3:	75 08                	jne    f0100bed <modify_permission+0x1d3>
		tmp = tmp ^ PTE_U;
f0100be5:	83 f6 04             	xor    $0x4,%esi
f0100be8:	e9 d2 fe ff ff       	jmp    f0100abf <modify_permission+0xa5>
	else if (strcmp(perm, "PTE_PWT") == 0)
f0100bed:	83 ec 08             	sub    $0x8,%esp
f0100bf0:	8d 83 44 c6 fe ff    	lea    -0x139bc(%ebx),%eax
f0100bf6:	50                   	push   %eax
f0100bf7:	57                   	push   %edi
f0100bf8:	e8 e0 34 00 00       	call   f01040dd <strcmp>
f0100bfd:	83 c4 10             	add    $0x10,%esp
f0100c00:	85 c0                	test   %eax,%eax
f0100c02:	75 08                	jne    f0100c0c <modify_permission+0x1f2>
		tmp = tmp ^ PTE_PWT;
f0100c04:	83 f6 08             	xor    $0x8,%esi
f0100c07:	e9 b3 fe ff ff       	jmp    f0100abf <modify_permission+0xa5>
	else if (strcmp(perm, "PTE_PCD") == 0)
f0100c0c:	83 ec 08             	sub    $0x8,%esp
f0100c0f:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0100c15:	50                   	push   %eax
f0100c16:	57                   	push   %edi
f0100c17:	e8 c1 34 00 00       	call   f01040dd <strcmp>
f0100c1c:	83 c4 10             	add    $0x10,%esp
f0100c1f:	85 c0                	test   %eax,%eax
f0100c21:	75 08                	jne    f0100c2b <modify_permission+0x211>
		tmp = tmp ^ PTE_PCD;
f0100c23:	83 f6 10             	xor    $0x10,%esi
f0100c26:	e9 94 fe ff ff       	jmp    f0100abf <modify_permission+0xa5>
	else if (strcmp(perm, "PTE_A") == 0)
f0100c2b:	83 ec 08             	sub    $0x8,%esp
f0100c2e:	8d 83 54 c6 fe ff    	lea    -0x139ac(%ebx),%eax
f0100c34:	50                   	push   %eax
f0100c35:	57                   	push   %edi
f0100c36:	e8 a2 34 00 00       	call   f01040dd <strcmp>
f0100c3b:	83 c4 10             	add    $0x10,%esp
f0100c3e:	85 c0                	test   %eax,%eax
f0100c40:	75 08                	jne    f0100c4a <modify_permission+0x230>
		tmp = tmp ^ PTE_A;
f0100c42:	83 f6 20             	xor    $0x20,%esi
f0100c45:	e9 75 fe ff ff       	jmp    f0100abf <modify_permission+0xa5>
	else if (strcmp(perm, "PTE_D") == 0)
f0100c4a:	83 ec 08             	sub    $0x8,%esp
f0100c4d:	8d 83 5a c6 fe ff    	lea    -0x139a6(%ebx),%eax
f0100c53:	50                   	push   %eax
f0100c54:	57                   	push   %edi
f0100c55:	e8 83 34 00 00       	call   f01040dd <strcmp>
f0100c5a:	83 c4 10             	add    $0x10,%esp
f0100c5d:	85 c0                	test   %eax,%eax
f0100c5f:	75 08                	jne    f0100c69 <modify_permission+0x24f>
		tmp = tmp ^ PTE_D;
f0100c61:	83 f6 40             	xor    $0x40,%esi
f0100c64:	e9 56 fe ff ff       	jmp    f0100abf <modify_permission+0xa5>
	else if (strcmp(perm, "PTE_PS") == 0)
f0100c69:	83 ec 08             	sub    $0x8,%esp
f0100c6c:	8d 83 60 c6 fe ff    	lea    -0x139a0(%ebx),%eax
f0100c72:	50                   	push   %eax
f0100c73:	57                   	push   %edi
f0100c74:	e8 64 34 00 00       	call   f01040dd <strcmp>
f0100c79:	83 c4 10             	add    $0x10,%esp
f0100c7c:	85 c0                	test   %eax,%eax
f0100c7e:	75 0b                	jne    f0100c8b <modify_permission+0x271>
		tmp = tmp ^ PTE_PS;
f0100c80:	81 f6 80 00 00 00    	xor    $0x80,%esi
f0100c86:	e9 34 fe ff ff       	jmp    f0100abf <modify_permission+0xa5>
	else if (strcmp(perm, "PTE_G") == 0)
f0100c8b:	83 ec 08             	sub    $0x8,%esp
f0100c8e:	8d 83 67 c6 fe ff    	lea    -0x13999(%ebx),%eax
f0100c94:	50                   	push   %eax
f0100c95:	57                   	push   %edi
f0100c96:	e8 42 34 00 00       	call   f01040dd <strcmp>
f0100c9b:	83 c4 10             	add    $0x10,%esp
f0100c9e:	85 c0                	test   %eax,%eax
f0100ca0:	0f 85 19 fe ff ff    	jne    f0100abf <modify_permission+0xa5>
		tmp = tmp ^ PTE_G;
f0100ca6:	81 f6 00 01 00 00    	xor    $0x100,%esi
f0100cac:	e9 0e fe ff ff       	jmp    f0100abf <modify_permission+0xa5>
		*pte |= tmp;
f0100cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cb4:	09 30                	or     %esi,(%eax)
f0100cb6:	e9 13 fe ff ff       	jmp    f0100ace <modify_permission+0xb4>

f0100cbb <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100cbb:	55                   	push   %ebp
f0100cbc:	89 e5                	mov    %esp,%ebp
f0100cbe:	57                   	push   %edi
f0100cbf:	56                   	push   %esi
f0100cc0:	53                   	push   %ebx
f0100cc1:	83 ec 68             	sub    $0x68,%esp
f0100cc4:	e8 ed f4 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100cc9:	81 c3 43 76 01 00    	add    $0x17643,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100ccf:	8d 83 08 c9 fe ff    	lea    -0x136f8(%ebx),%eax
f0100cd5:	50                   	push   %eax
f0100cd6:	e8 36 28 00 00       	call   f0103511 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100cdb:	8d 83 2c c9 fe ff    	lea    -0x136d4(%ebx),%eax
f0100ce1:	89 04 24             	mov    %eax,(%esp)
f0100ce4:	e8 28 28 00 00       	call   f0103511 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 0x0100, "blue", 0x0200, "green", 0x0400, "red");
f0100ce9:	83 c4 0c             	add    $0xc,%esp
f0100cec:	8d 83 6d c6 fe ff    	lea    -0x13993(%ebx),%eax
f0100cf2:	50                   	push   %eax
f0100cf3:	68 00 04 00 00       	push   $0x400
f0100cf8:	8d 83 71 c6 fe ff    	lea    -0x1398f(%ebx),%eax
f0100cfe:	50                   	push   %eax
f0100cff:	68 00 02 00 00       	push   $0x200
f0100d04:	8d 83 77 c6 fe ff    	lea    -0x13989(%ebx),%eax
f0100d0a:	50                   	push   %eax
f0100d0b:	68 00 01 00 00       	push   $0x100
f0100d10:	8d 83 7c c6 fe ff    	lea    -0x13984(%ebx),%eax
f0100d16:	50                   	push   %eax
f0100d17:	e8 f5 27 00 00       	call   f0103511 <cprintf>
f0100d1c:	83 c4 20             	add    $0x20,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100d1f:	8d bb 90 c6 fe ff    	lea    -0x13970(%ebx),%edi
f0100d25:	eb 4a                	jmp    f0100d71 <monitor+0xb6>
f0100d27:	83 ec 08             	sub    $0x8,%esp
f0100d2a:	0f be c0             	movsbl %al,%eax
f0100d2d:	50                   	push   %eax
f0100d2e:	57                   	push   %edi
f0100d2f:	e8 07 34 00 00       	call   f010413b <strchr>
f0100d34:	83 c4 10             	add    $0x10,%esp
f0100d37:	85 c0                	test   %eax,%eax
f0100d39:	74 08                	je     f0100d43 <monitor+0x88>
			*buf++ = 0;
f0100d3b:	c6 06 00             	movb   $0x0,(%esi)
f0100d3e:	8d 76 01             	lea    0x1(%esi),%esi
f0100d41:	eb 79                	jmp    f0100dbc <monitor+0x101>
		if (*buf == 0)
f0100d43:	80 3e 00             	cmpb   $0x0,(%esi)
f0100d46:	74 7f                	je     f0100dc7 <monitor+0x10c>
		if (argc == MAXARGS-1) {
f0100d48:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100d4c:	74 0f                	je     f0100d5d <monitor+0xa2>
		argv[argc++] = buf;
f0100d4e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100d51:	8d 48 01             	lea    0x1(%eax),%ecx
f0100d54:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100d57:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100d5b:	eb 44                	jmp    f0100da1 <monitor+0xe6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100d5d:	83 ec 08             	sub    $0x8,%esp
f0100d60:	6a 10                	push   $0x10
f0100d62:	8d 83 95 c6 fe ff    	lea    -0x1396b(%ebx),%eax
f0100d68:	50                   	push   %eax
f0100d69:	e8 a3 27 00 00       	call   f0103511 <cprintf>
f0100d6e:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100d71:	8d 83 8c c6 fe ff    	lea    -0x13974(%ebx),%eax
f0100d77:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100d7a:	83 ec 0c             	sub    $0xc,%esp
f0100d7d:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100d80:	e8 7e 31 00 00       	call   f0103f03 <readline>
f0100d85:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100d87:	83 c4 10             	add    $0x10,%esp
f0100d8a:	85 c0                	test   %eax,%eax
f0100d8c:	74 ec                	je     f0100d7a <monitor+0xbf>
	argv[argc] = 0;
f0100d8e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100d95:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100d9c:	eb 1e                	jmp    f0100dbc <monitor+0x101>
			buf++;
f0100d9e:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100da1:	0f b6 06             	movzbl (%esi),%eax
f0100da4:	84 c0                	test   %al,%al
f0100da6:	74 14                	je     f0100dbc <monitor+0x101>
f0100da8:	83 ec 08             	sub    $0x8,%esp
f0100dab:	0f be c0             	movsbl %al,%eax
f0100dae:	50                   	push   %eax
f0100daf:	57                   	push   %edi
f0100db0:	e8 86 33 00 00       	call   f010413b <strchr>
f0100db5:	83 c4 10             	add    $0x10,%esp
f0100db8:	85 c0                	test   %eax,%eax
f0100dba:	74 e2                	je     f0100d9e <monitor+0xe3>
		while (*buf && strchr(WHITESPACE, *buf))
f0100dbc:	0f b6 06             	movzbl (%esi),%eax
f0100dbf:	84 c0                	test   %al,%al
f0100dc1:	0f 85 60 ff ff ff    	jne    f0100d27 <monitor+0x6c>
	argv[argc] = 0;
f0100dc7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100dca:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100dd1:	00 
	if (argc == 0)
f0100dd2:	85 c0                	test   %eax,%eax
f0100dd4:	74 9b                	je     f0100d71 <monitor+0xb6>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100dd6:	be 00 00 00 00       	mov    $0x0,%esi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100ddb:	83 ec 08             	sub    $0x8,%esp
f0100dde:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100de1:	ff b4 83 14 1d 00 00 	pushl  0x1d14(%ebx,%eax,4)
f0100de8:	ff 75 a8             	pushl  -0x58(%ebp)
f0100deb:	e8 ed 32 00 00       	call   f01040dd <strcmp>
f0100df0:	83 c4 10             	add    $0x10,%esp
f0100df3:	85 c0                	test   %eax,%eax
f0100df5:	74 22                	je     f0100e19 <monitor+0x15e>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100df7:	83 c6 01             	add    $0x1,%esi
f0100dfa:	83 fe 05             	cmp    $0x5,%esi
f0100dfd:	75 dc                	jne    f0100ddb <monitor+0x120>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100dff:	83 ec 08             	sub    $0x8,%esp
f0100e02:	ff 75 a8             	pushl  -0x58(%ebp)
f0100e05:	8d 83 b2 c6 fe ff    	lea    -0x1394e(%ebx),%eax
f0100e0b:	50                   	push   %eax
f0100e0c:	e8 00 27 00 00       	call   f0103511 <cprintf>
f0100e11:	83 c4 10             	add    $0x10,%esp
f0100e14:	e9 58 ff ff ff       	jmp    f0100d71 <monitor+0xb6>
			return commands[i].func(argc, argv, tf);
f0100e19:	83 ec 04             	sub    $0x4,%esp
f0100e1c:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100e1f:	ff 75 08             	pushl  0x8(%ebp)
f0100e22:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100e25:	52                   	push   %edx
f0100e26:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100e29:	ff 94 83 1c 1d 00 00 	call   *0x1d1c(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100e30:	83 c4 10             	add    $0x10,%esp
f0100e33:	85 c0                	test   %eax,%eax
f0100e35:	0f 89 36 ff ff ff    	jns    f0100d71 <monitor+0xb6>
				break;
	}
}
f0100e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e3e:	5b                   	pop    %ebx
f0100e3f:	5e                   	pop    %esi
f0100e40:	5f                   	pop    %edi
f0100e41:	5d                   	pop    %ebp
f0100e42:	c3                   	ret    

f0100e43 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100e43:	55                   	push   %ebp
f0100e44:	89 e5                	mov    %esp,%ebp
f0100e46:	57                   	push   %edi
f0100e47:	56                   	push   %esi
f0100e48:	53                   	push   %ebx
f0100e49:	83 ec 18             	sub    $0x18,%esp
f0100e4c:	e8 65 f3 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100e51:	81 c3 bb 74 01 00    	add    $0x174bb,%ebx
f0100e57:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100e59:	50                   	push   %eax
f0100e5a:	e8 2b 26 00 00       	call   f010348a <mc146818_read>
f0100e5f:	89 c6                	mov    %eax,%esi
f0100e61:	83 c7 01             	add    $0x1,%edi
f0100e64:	89 3c 24             	mov    %edi,(%esp)
f0100e67:	e8 1e 26 00 00       	call   f010348a <mc146818_read>
f0100e6c:	c1 e0 08             	shl    $0x8,%eax
f0100e6f:	09 f0                	or     %esi,%eax
}
f0100e71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e74:	5b                   	pop    %ebx
f0100e75:	5e                   	pop    %esi
f0100e76:	5f                   	pop    %edi
f0100e77:	5d                   	pop    %ebp
f0100e78:	c3                   	ret    

f0100e79 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100e79:	55                   	push   %ebp
f0100e7a:	89 e5                	mov    %esp,%ebp
f0100e7c:	56                   	push   %esi
f0100e7d:	53                   	push   %ebx
f0100e7e:	e8 fb 25 00 00       	call   f010347e <__x86.get_pc_thunk.cx>
f0100e83:	81 c1 89 74 01 00    	add    $0x17489,%ecx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100e89:	83 b9 ac 1f 00 00 00 	cmpl   $0x0,0x1fac(%ecx)
f0100e90:	74 37                	je     f0100ec9 <boot_alloc+0x50>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100e92:	8b b1 ac 1f 00 00    	mov    0x1fac(%ecx),%esi
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100e98:	8d 94 06 ff 0f 00 00 	lea    0xfff(%esi,%eax,1),%edx
f0100e9f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ea5:	89 91 ac 1f 00 00    	mov    %edx,0x1fac(%ecx)
	if ((uint32_t)nextfree - KERNBASE > (npages * PGSIZE))
f0100eab:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100eb1:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f0100eb7:	8b 18                	mov    (%eax),%ebx
f0100eb9:	c1 e3 0c             	shl    $0xc,%ebx
f0100ebc:	39 da                	cmp    %ebx,%edx
f0100ebe:	77 23                	ja     f0100ee3 <boot_alloc+0x6a>
	{
		panic("Memory is out of numbers\n");
	}
	return result;

}
f0100ec0:	89 f0                	mov    %esi,%eax
f0100ec2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ec5:	5b                   	pop    %ebx
f0100ec6:	5e                   	pop    %esi
f0100ec7:	5d                   	pop    %ebp
f0100ec8:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ec9:	c7 c2 c0 a6 11 f0    	mov    $0xf011a6c0,%edx
f0100ecf:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100ed5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100edb:	89 91 ac 1f 00 00    	mov    %edx,0x1fac(%ecx)
f0100ee1:	eb af                	jmp    f0100e92 <boot_alloc+0x19>
		panic("Memory is out of numbers\n");
f0100ee3:	83 ec 04             	sub    $0x4,%esp
f0100ee6:	8d 81 a8 c9 fe ff    	lea    -0x13658(%ecx),%eax
f0100eec:	50                   	push   %eax
f0100eed:	6a 6c                	push   $0x6c
f0100eef:	8d 81 c2 c9 fe ff    	lea    -0x1363e(%ecx),%eax
f0100ef5:	50                   	push   %eax
f0100ef6:	89 cb                	mov    %ecx,%ebx
f0100ef8:	e8 03 f2 ff ff       	call   f0100100 <_panic>

f0100efd <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100efd:	55                   	push   %ebp
f0100efe:	89 e5                	mov    %esp,%ebp
f0100f00:	56                   	push   %esi
f0100f01:	53                   	push   %ebx
f0100f02:	e8 77 25 00 00       	call   f010347e <__x86.get_pc_thunk.cx>
f0100f07:	81 c1 05 74 01 00    	add    $0x17405,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100f0d:	89 d3                	mov    %edx,%ebx
f0100f0f:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100f12:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100f15:	a8 01                	test   $0x1,%al
f0100f17:	74 5a                	je     f0100f73 <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100f19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100f1e:	89 c6                	mov    %eax,%esi
f0100f20:	c1 ee 0c             	shr    $0xc,%esi
f0100f23:	c7 c3 c8 a6 11 f0    	mov    $0xf011a6c8,%ebx
f0100f29:	3b 33                	cmp    (%ebx),%esi
f0100f2b:	73 2b                	jae    f0100f58 <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100f2d:	c1 ea 0c             	shr    $0xc,%edx
f0100f30:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100f36:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100f3d:	89 c2                	mov    %eax,%edx
f0100f3f:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100f42:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f47:	85 d2                	test   %edx,%edx
f0100f49:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100f4e:	0f 44 c2             	cmove  %edx,%eax
}
f0100f51:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f54:	5b                   	pop    %ebx
f0100f55:	5e                   	pop    %esi
f0100f56:	5d                   	pop    %ebp
f0100f57:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f58:	50                   	push   %eax
f0100f59:	8d 81 b0 cc fe ff    	lea    -0x13350(%ecx),%eax
f0100f5f:	50                   	push   %eax
f0100f60:	68 03 03 00 00       	push   $0x303
f0100f65:	8d 81 c2 c9 fe ff    	lea    -0x1363e(%ecx),%eax
f0100f6b:	50                   	push   %eax
f0100f6c:	89 cb                	mov    %ecx,%ebx
f0100f6e:	e8 8d f1 ff ff       	call   f0100100 <_panic>
		return ~0;
f0100f73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f78:	eb d7                	jmp    f0100f51 <check_va2pa+0x54>

f0100f7a <check_page_free_list>:
{
f0100f7a:	55                   	push   %ebp
f0100f7b:	89 e5                	mov    %esp,%ebp
f0100f7d:	57                   	push   %edi
f0100f7e:	56                   	push   %esi
f0100f7f:	53                   	push   %ebx
f0100f80:	83 ec 3c             	sub    $0x3c,%esp
f0100f83:	e8 fe 24 00 00       	call   f0103486 <__x86.get_pc_thunk.di>
f0100f88:	81 c7 84 73 01 00    	add    $0x17384,%edi
f0100f8e:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f91:	84 c0                	test   %al,%al
f0100f93:	0f 85 dd 02 00 00    	jne    f0101276 <check_page_free_list+0x2fc>
	if (!page_free_list)
f0100f99:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100f9c:	83 b8 b0 1f 00 00 00 	cmpl   $0x0,0x1fb0(%eax)
f0100fa3:	74 0c                	je     f0100fb1 <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100fa5:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0100fac:	e9 2f 03 00 00       	jmp    f01012e0 <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f0100fb1:	83 ec 04             	sub    $0x4,%esp
f0100fb4:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100fb7:	8d 83 d4 cc fe ff    	lea    -0x1332c(%ebx),%eax
f0100fbd:	50                   	push   %eax
f0100fbe:	68 41 02 00 00       	push   $0x241
f0100fc3:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0100fc9:	50                   	push   %eax
f0100fca:	e8 31 f1 ff ff       	call   f0100100 <_panic>
f0100fcf:	50                   	push   %eax
f0100fd0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100fd3:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f0100fd9:	50                   	push   %eax
f0100fda:	6a 52                	push   $0x52
f0100fdc:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f0100fe2:	50                   	push   %eax
f0100fe3:	e8 18 f1 ff ff       	call   f0100100 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100fe8:	8b 36                	mov    (%esi),%esi
f0100fea:	85 f6                	test   %esi,%esi
f0100fec:	74 40                	je     f010102e <check_page_free_list+0xb4>
	return (pp - pages) << PGSHIFT;
f0100fee:	89 f0                	mov    %esi,%eax
f0100ff0:	2b 07                	sub    (%edi),%eax
f0100ff2:	c1 f8 03             	sar    $0x3,%eax
f0100ff5:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ff8:	89 c2                	mov    %eax,%edx
f0100ffa:	c1 ea 16             	shr    $0x16,%edx
f0100ffd:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101000:	73 e6                	jae    f0100fe8 <check_page_free_list+0x6e>
	if (PGNUM(pa) >= npages)
f0101002:	89 c2                	mov    %eax,%edx
f0101004:	c1 ea 0c             	shr    $0xc,%edx
f0101007:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010100a:	3b 11                	cmp    (%ecx),%edx
f010100c:	73 c1                	jae    f0100fcf <check_page_free_list+0x55>
			memset(page2kva(pp), 0x97, 128);
f010100e:	83 ec 04             	sub    $0x4,%esp
f0101011:	68 80 00 00 00       	push   $0x80
f0101016:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f010101b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101020:	50                   	push   %eax
f0101021:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101024:	e8 4f 31 00 00       	call   f0104178 <memset>
f0101029:	83 c4 10             	add    $0x10,%esp
f010102c:	eb ba                	jmp    f0100fe8 <check_page_free_list+0x6e>
	first_free_page = (char *) boot_alloc(0);
f010102e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101033:	e8 41 fe ff ff       	call   f0100e79 <boot_alloc>
f0101038:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010103b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010103e:	8b 97 b0 1f 00 00    	mov    0x1fb0(%edi),%edx
		assert(pp >= pages);
f0101044:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010104a:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f010104c:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f0101052:	8b 00                	mov    (%eax),%eax
f0101054:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101057:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010105a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f010105d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101062:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101065:	e9 08 01 00 00       	jmp    f0101172 <check_page_free_list+0x1f8>
		assert(pp >= pages);
f010106a:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010106d:	8d 83 dc c9 fe ff    	lea    -0x13624(%ebx),%eax
f0101073:	50                   	push   %eax
f0101074:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010107a:	50                   	push   %eax
f010107b:	68 5b 02 00 00       	push   $0x25b
f0101080:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101086:	50                   	push   %eax
f0101087:	e8 74 f0 ff ff       	call   f0100100 <_panic>
		assert(pp < pages + npages);
f010108c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010108f:	8d 83 e8 c9 fe ff    	lea    -0x13618(%ebx),%eax
f0101095:	50                   	push   %eax
f0101096:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010109c:	50                   	push   %eax
f010109d:	68 5c 02 00 00       	push   $0x25c
f01010a2:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01010a8:	50                   	push   %eax
f01010a9:	e8 52 f0 ff ff       	call   f0100100 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010ae:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01010b1:	8d 83 f8 cc fe ff    	lea    -0x13308(%ebx),%eax
f01010b7:	50                   	push   %eax
f01010b8:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01010be:	50                   	push   %eax
f01010bf:	68 5d 02 00 00       	push   $0x25d
f01010c4:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01010ca:	50                   	push   %eax
f01010cb:	e8 30 f0 ff ff       	call   f0100100 <_panic>
		assert(page2pa(pp) != 0);
f01010d0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01010d3:	8d 83 fc c9 fe ff    	lea    -0x13604(%ebx),%eax
f01010d9:	50                   	push   %eax
f01010da:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01010e0:	50                   	push   %eax
f01010e1:	68 60 02 00 00       	push   $0x260
f01010e6:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01010ec:	50                   	push   %eax
f01010ed:	e8 0e f0 ff ff       	call   f0100100 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01010f2:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01010f5:	8d 83 0d ca fe ff    	lea    -0x135f3(%ebx),%eax
f01010fb:	50                   	push   %eax
f01010fc:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101102:	50                   	push   %eax
f0101103:	68 61 02 00 00       	push   $0x261
f0101108:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010110e:	50                   	push   %eax
f010110f:	e8 ec ef ff ff       	call   f0100100 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101114:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101117:	8d 83 2c cd fe ff    	lea    -0x132d4(%ebx),%eax
f010111d:	50                   	push   %eax
f010111e:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101124:	50                   	push   %eax
f0101125:	68 62 02 00 00       	push   $0x262
f010112a:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101130:	50                   	push   %eax
f0101131:	e8 ca ef ff ff       	call   f0100100 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101136:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101139:	8d 83 26 ca fe ff    	lea    -0x135da(%ebx),%eax
f010113f:	50                   	push   %eax
f0101140:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101146:	50                   	push   %eax
f0101147:	68 63 02 00 00       	push   $0x263
f010114c:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101152:	50                   	push   %eax
f0101153:	e8 a8 ef ff ff       	call   f0100100 <_panic>
	if (PGNUM(pa) >= npages)
f0101158:	89 c6                	mov    %eax,%esi
f010115a:	c1 ee 0c             	shr    $0xc,%esi
f010115d:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0101160:	76 70                	jbe    f01011d2 <check_page_free_list+0x258>
	return (void *)(pa + KERNBASE);
f0101162:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101167:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f010116a:	77 7f                	ja     f01011eb <check_page_free_list+0x271>
			++nfree_extmem;
f010116c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101170:	8b 12                	mov    (%edx),%edx
f0101172:	85 d2                	test   %edx,%edx
f0101174:	0f 84 93 00 00 00    	je     f010120d <check_page_free_list+0x293>
		assert(pp >= pages);
f010117a:	39 d1                	cmp    %edx,%ecx
f010117c:	0f 87 e8 fe ff ff    	ja     f010106a <check_page_free_list+0xf0>
		assert(pp < pages + npages);
f0101182:	39 d3                	cmp    %edx,%ebx
f0101184:	0f 86 02 ff ff ff    	jbe    f010108c <check_page_free_list+0x112>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010118a:	89 d0                	mov    %edx,%eax
f010118c:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f010118f:	a8 07                	test   $0x7,%al
f0101191:	0f 85 17 ff ff ff    	jne    f01010ae <check_page_free_list+0x134>
	return (pp - pages) << PGSHIFT;
f0101197:	c1 f8 03             	sar    $0x3,%eax
f010119a:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f010119d:	85 c0                	test   %eax,%eax
f010119f:	0f 84 2b ff ff ff    	je     f01010d0 <check_page_free_list+0x156>
		assert(page2pa(pp) != IOPHYSMEM);
f01011a5:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01011aa:	0f 84 42 ff ff ff    	je     f01010f2 <check_page_free_list+0x178>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01011b0:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01011b5:	0f 84 59 ff ff ff    	je     f0101114 <check_page_free_list+0x19a>
		assert(page2pa(pp) != EXTPHYSMEM);
f01011bb:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01011c0:	0f 84 70 ff ff ff    	je     f0101136 <check_page_free_list+0x1bc>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011c6:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f01011cb:	77 8b                	ja     f0101158 <check_page_free_list+0x1de>
			++nfree_basemem;
f01011cd:	83 c7 01             	add    $0x1,%edi
f01011d0:	eb 9e                	jmp    f0101170 <check_page_free_list+0x1f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011d2:	50                   	push   %eax
f01011d3:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01011d6:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f01011dc:	50                   	push   %eax
f01011dd:	6a 52                	push   $0x52
f01011df:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f01011e5:	50                   	push   %eax
f01011e6:	e8 15 ef ff ff       	call   f0100100 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01011eb:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01011ee:	8d 83 50 cd fe ff    	lea    -0x132b0(%ebx),%eax
f01011f4:	50                   	push   %eax
f01011f5:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01011fb:	50                   	push   %eax
f01011fc:	68 64 02 00 00       	push   $0x264
f0101201:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101207:	50                   	push   %eax
f0101208:	e8 f3 ee ff ff       	call   f0100100 <_panic>
f010120d:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0101210:	85 ff                	test   %edi,%edi
f0101212:	7e 1e                	jle    f0101232 <check_page_free_list+0x2b8>
	assert(nfree_extmem > 0);
f0101214:	85 f6                	test   %esi,%esi
f0101216:	7e 3c                	jle    f0101254 <check_page_free_list+0x2da>
	cprintf("check_page_free_list() succeeded!\n");
f0101218:	83 ec 0c             	sub    $0xc,%esp
f010121b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010121e:	8d 83 98 cd fe ff    	lea    -0x13268(%ebx),%eax
f0101224:	50                   	push   %eax
f0101225:	e8 e7 22 00 00       	call   f0103511 <cprintf>
}
f010122a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010122d:	5b                   	pop    %ebx
f010122e:	5e                   	pop    %esi
f010122f:	5f                   	pop    %edi
f0101230:	5d                   	pop    %ebp
f0101231:	c3                   	ret    
	assert(nfree_basemem > 0);
f0101232:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101235:	8d 83 40 ca fe ff    	lea    -0x135c0(%ebx),%eax
f010123b:	50                   	push   %eax
f010123c:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101242:	50                   	push   %eax
f0101243:	68 6c 02 00 00       	push   $0x26c
f0101248:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010124e:	50                   	push   %eax
f010124f:	e8 ac ee ff ff       	call   f0100100 <_panic>
	assert(nfree_extmem > 0);
f0101254:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101257:	8d 83 52 ca fe ff    	lea    -0x135ae(%ebx),%eax
f010125d:	50                   	push   %eax
f010125e:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101264:	50                   	push   %eax
f0101265:	68 6d 02 00 00       	push   $0x26d
f010126a:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101270:	50                   	push   %eax
f0101271:	e8 8a ee ff ff       	call   f0100100 <_panic>
	if (!page_free_list)
f0101276:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0101279:	8b 80 b0 1f 00 00    	mov    0x1fb0(%eax),%eax
f010127f:	85 c0                	test   %eax,%eax
f0101281:	0f 84 2a fd ff ff    	je     f0100fb1 <check_page_free_list+0x37>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0101287:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010128a:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010128d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101290:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f0101293:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0101296:	c7 c3 d0 a6 11 f0    	mov    $0xf011a6d0,%ebx
f010129c:	89 c2                	mov    %eax,%edx
f010129e:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01012a0:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01012a6:	0f 95 c2             	setne  %dl
f01012a9:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01012ac:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01012b0:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01012b2:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012b6:	8b 00                	mov    (%eax),%eax
f01012b8:	85 c0                	test   %eax,%eax
f01012ba:	75 e0                	jne    f010129c <check_page_free_list+0x322>
		*tp[1] = 0;
f01012bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01012bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01012c5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01012cb:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01012cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01012d0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01012d3:	89 87 b0 1f 00 00    	mov    %eax,0x1fb0(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012d9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01012e0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01012e3:	8b b0 b0 1f 00 00    	mov    0x1fb0(%eax),%esi
f01012e9:	c7 c7 d0 a6 11 f0    	mov    $0xf011a6d0,%edi
	if (PGNUM(pa) >= npages)
f01012ef:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f01012f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01012f8:	e9 ed fc ff ff       	jmp    f0100fea <check_page_free_list+0x70>

f01012fd <page_init>:
{
f01012fd:	55                   	push   %ebp
f01012fe:	89 e5                	mov    %esp,%ebp
f0101300:	57                   	push   %edi
f0101301:	56                   	push   %esi
f0101302:	53                   	push   %ebx
f0101303:	83 ec 1c             	sub    $0x1c,%esp
f0101306:	e8 77 21 00 00       	call   f0103482 <__x86.get_pc_thunk.si>
f010130b:	81 c6 01 70 01 00    	add    $0x17001,%esi
f0101311:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	npages_basemem = nvram_read(NVRAM_BASELO) / (PGSIZE / 1024);
f0101314:	b8 15 00 00 00       	mov    $0x15,%eax
f0101319:	e8 25 fb ff ff       	call   f0100e43 <nvram_read>
f010131e:	8d 50 03             	lea    0x3(%eax),%edx
f0101321:	85 c0                	test   %eax,%eax
f0101323:	0f 48 c2             	cmovs  %edx,%eax
f0101326:	c1 f8 02             	sar    $0x2,%eax
f0101329:	89 45 e0             	mov    %eax,-0x20(%ebp)
	ext_allocated = ((size_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f010132c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101331:	e8 43 fb ff ff       	call   f0100e79 <boot_alloc>
f0101336:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f010133c:	c1 ef 0c             	shr    $0xc,%edi
	pages[0].pp_ref = 1;
f010133f:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0101345:	8b 00                	mov    (%eax),%eax
f0101347:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f010134d:	8b 9e b0 1f 00 00    	mov    0x1fb0(%esi),%ebx
	for (i = 1; i < npages_basemem; i++)
f0101353:	b8 00 00 00 00       	mov    $0x0,%eax
f0101358:	ba 01 00 00 00       	mov    $0x1,%edx
		pages[i].pp_ref = 0;
f010135d:	c7 c6 d0 a6 11 f0    	mov    $0xf011a6d0,%esi
f0101363:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0101366:	8b 7d e0             	mov    -0x20(%ebp),%edi
	for (i = 1; i < npages_basemem; i++)
f0101369:	eb 1f                	jmp    f010138a <page_init+0x8d>
		pages[i].pp_ref = 0;
f010136b:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0101372:	89 c1                	mov    %eax,%ecx
f0101374:	03 0e                	add    (%esi),%ecx
f0101376:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010137c:	89 19                	mov    %ebx,(%ecx)
	for (i = 1; i < npages_basemem; i++)
f010137e:	83 c2 01             	add    $0x1,%edx
		page_free_list = &pages[i];
f0101381:	03 06                	add    (%esi),%eax
f0101383:	89 c3                	mov    %eax,%ebx
f0101385:	b8 01 00 00 00       	mov    $0x1,%eax
	for (i = 1; i < npages_basemem; i++)
f010138a:	39 fa                	cmp    %edi,%edx
f010138c:	72 dd                	jb     f010136b <page_init+0x6e>
f010138e:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101391:	84 c0                	test   %al,%al
f0101393:	75 12                	jne    f01013a7 <page_init+0xaa>
		pages[i].pp_ref = 1;
f0101395:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101398:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010139e:	8b 08                	mov    (%eax),%ecx
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE + ext_allocated; i++)
f01013a0:	ba a0 00 00 00       	mov    $0xa0,%edx
f01013a5:	eb 15                	jmp    f01013bc <page_init+0xbf>
f01013a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01013aa:	89 98 b0 1f 00 00    	mov    %ebx,0x1fb0(%eax)
f01013b0:	eb e3                	jmp    f0101395 <page_init+0x98>
		pages[i].pp_ref = 1;
f01013b2:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE + ext_allocated; i++)
f01013b9:	83 c2 01             	add    $0x1,%edx
f01013bc:	8d 87 00 01 00 00    	lea    0x100(%edi),%eax
f01013c2:	39 d0                	cmp    %edx,%eax
f01013c4:	77 ec                	ja     f01013b2 <page_init+0xb5>
f01013c6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01013c9:	8b 9e b0 1f 00 00    	mov    0x1fb0(%esi),%ebx
f01013cf:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01013d6:	b9 00 00 00 00       	mov    $0x0,%ecx
	for (i = EXTPHYSMEM / PGSIZE + ext_allocated; i < npages; i++)
f01013db:	c7 c7 c8 a6 11 f0    	mov    $0xf011a6c8,%edi
		pages[i].pp_ref = 0;
f01013e1:	c7 c6 d0 a6 11 f0    	mov    $0xf011a6d0,%esi
f01013e7:	eb 1b                	jmp    f0101404 <page_init+0x107>
f01013e9:	89 d1                	mov    %edx,%ecx
f01013eb:	03 0e                	add    (%esi),%ecx
f01013ed:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01013f3:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01013f5:	89 d3                	mov    %edx,%ebx
f01013f7:	03 1e                	add    (%esi),%ebx
	for (i = EXTPHYSMEM / PGSIZE + ext_allocated; i < npages; i++)
f01013f9:	83 c0 01             	add    $0x1,%eax
f01013fc:	83 c2 08             	add    $0x8,%edx
f01013ff:	b9 01 00 00 00       	mov    $0x1,%ecx
f0101404:	39 07                	cmp    %eax,(%edi)
f0101406:	77 e1                	ja     f01013e9 <page_init+0xec>
f0101408:	84 c9                	test   %cl,%cl
f010140a:	75 08                	jne    f0101414 <page_init+0x117>
}
f010140c:	83 c4 1c             	add    $0x1c,%esp
f010140f:	5b                   	pop    %ebx
f0101410:	5e                   	pop    %esi
f0101411:	5f                   	pop    %edi
f0101412:	5d                   	pop    %ebp
f0101413:	c3                   	ret    
f0101414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101417:	89 98 b0 1f 00 00    	mov    %ebx,0x1fb0(%eax)
f010141d:	eb ed                	jmp    f010140c <page_init+0x10f>

f010141f <page_alloc>:
{
f010141f:	55                   	push   %ebp
f0101420:	89 e5                	mov    %esp,%ebp
f0101422:	56                   	push   %esi
f0101423:	53                   	push   %ebx
f0101424:	e8 8d ed ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0101429:	81 c3 e3 6e 01 00    	add    $0x16ee3,%ebx
	if (!page_free_list)
f010142f:	8b b3 b0 1f 00 00    	mov    0x1fb0(%ebx),%esi
f0101435:	85 f6                	test   %esi,%esi
f0101437:	74 14                	je     f010144d <page_alloc+0x2e>
	page_free_list = page_free_list->pp_link;
f0101439:	8b 06                	mov    (%esi),%eax
f010143b:	89 83 b0 1f 00 00    	mov    %eax,0x1fb0(%ebx)
	page->pp_link = NULL;
f0101441:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO)
f0101447:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010144b:	75 09                	jne    f0101456 <page_alloc+0x37>
}
f010144d:	89 f0                	mov    %esi,%eax
f010144f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101452:	5b                   	pop    %ebx
f0101453:	5e                   	pop    %esi
f0101454:	5d                   	pop    %ebp
f0101455:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0101456:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010145c:	89 f2                	mov    %esi,%edx
f010145e:	2b 10                	sub    (%eax),%edx
f0101460:	89 d0                	mov    %edx,%eax
f0101462:	c1 f8 03             	sar    $0x3,%eax
f0101465:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101468:	89 c1                	mov    %eax,%ecx
f010146a:	c1 e9 0c             	shr    $0xc,%ecx
f010146d:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f0101473:	3b 0a                	cmp    (%edx),%ecx
f0101475:	73 1a                	jae    f0101491 <page_alloc+0x72>
		memset(page2kva(page), 0, PGSIZE);
f0101477:	83 ec 04             	sub    $0x4,%esp
f010147a:	68 00 10 00 00       	push   $0x1000
f010147f:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101481:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101486:	50                   	push   %eax
f0101487:	e8 ec 2c 00 00       	call   f0104178 <memset>
f010148c:	83 c4 10             	add    $0x10,%esp
f010148f:	eb bc                	jmp    f010144d <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101491:	50                   	push   %eax
f0101492:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f0101498:	50                   	push   %eax
f0101499:	6a 52                	push   $0x52
f010149b:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f01014a1:	50                   	push   %eax
f01014a2:	e8 59 ec ff ff       	call   f0100100 <_panic>

f01014a7 <page_free>:
{
f01014a7:	55                   	push   %ebp
f01014a8:	89 e5                	mov    %esp,%ebp
f01014aa:	53                   	push   %ebx
f01014ab:	83 ec 04             	sub    $0x4,%esp
f01014ae:	e8 03 ed ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01014b3:	81 c3 59 6e 01 00    	add    $0x16e59,%ebx
f01014b9:	8b 45 08             	mov    0x8(%ebp),%eax
	assert(pp->pp_ref == 0);
f01014bc:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01014c1:	75 18                	jne    f01014db <page_free+0x34>
	assert(!pp->pp_link);
f01014c3:	83 38 00             	cmpl   $0x0,(%eax)
f01014c6:	75 32                	jne    f01014fa <page_free+0x53>
	pp->pp_link = page_free_list;
f01014c8:	8b 8b b0 1f 00 00    	mov    0x1fb0(%ebx),%ecx
f01014ce:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f01014d0:	89 83 b0 1f 00 00    	mov    %eax,0x1fb0(%ebx)
}
f01014d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014d9:	c9                   	leave  
f01014da:	c3                   	ret    
	assert(pp->pp_ref == 0);
f01014db:	8d 83 63 ca fe ff    	lea    -0x1359d(%ebx),%eax
f01014e1:	50                   	push   %eax
f01014e2:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01014e8:	50                   	push   %eax
f01014e9:	68 59 01 00 00       	push   $0x159
f01014ee:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01014f4:	50                   	push   %eax
f01014f5:	e8 06 ec ff ff       	call   f0100100 <_panic>
	assert(!pp->pp_link);
f01014fa:	8d 83 73 ca fe ff    	lea    -0x1358d(%ebx),%eax
f0101500:	50                   	push   %eax
f0101501:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101507:	50                   	push   %eax
f0101508:	68 5a 01 00 00       	push   $0x15a
f010150d:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101513:	50                   	push   %eax
f0101514:	e8 e7 eb ff ff       	call   f0100100 <_panic>

f0101519 <page_decref>:
{
f0101519:	55                   	push   %ebp
f010151a:	89 e5                	mov    %esp,%ebp
f010151c:	83 ec 08             	sub    $0x8,%esp
f010151f:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101522:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101526:	83 e8 01             	sub    $0x1,%eax
f0101529:	66 89 42 04          	mov    %ax,0x4(%edx)
f010152d:	66 85 c0             	test   %ax,%ax
f0101530:	74 02                	je     f0101534 <page_decref+0x1b>
}
f0101532:	c9                   	leave  
f0101533:	c3                   	ret    
		page_free(pp);
f0101534:	83 ec 0c             	sub    $0xc,%esp
f0101537:	52                   	push   %edx
f0101538:	e8 6a ff ff ff       	call   f01014a7 <page_free>
f010153d:	83 c4 10             	add    $0x10,%esp
}
f0101540:	eb f0                	jmp    f0101532 <page_decref+0x19>

f0101542 <pgdir_walk>:
{
f0101542:	55                   	push   %ebp
f0101543:	89 e5                	mov    %esp,%ebp
f0101545:	57                   	push   %edi
f0101546:	56                   	push   %esi
f0101547:	53                   	push   %ebx
f0101548:	83 ec 0c             	sub    $0xc,%esp
f010154b:	e8 66 ec ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0101550:	81 c3 bc 6d 01 00    	add    $0x16dbc,%ebx
f0101556:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pde = &pgdir[PDX(va)];
f0101559:	89 fe                	mov    %edi,%esi
f010155b:	c1 ee 16             	shr    $0x16,%esi
f010155e:	c1 e6 02             	shl    $0x2,%esi
f0101561:	03 75 08             	add    0x8(%ebp),%esi
	if (!(*pde & PTE_P))
f0101564:	f6 06 01             	testb  $0x1,(%esi)
f0101567:	75 2f                	jne    f0101598 <pgdir_walk+0x56>
		if (create)
f0101569:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010156d:	74 70                	je     f01015df <pgdir_walk+0x9d>
			page = page_alloc(1);
f010156f:	83 ec 0c             	sub    $0xc,%esp
f0101572:	6a 01                	push   $0x1
f0101574:	e8 a6 fe ff ff       	call   f010141f <page_alloc>
			if (!page)
f0101579:	83 c4 10             	add    $0x10,%esp
f010157c:	85 c0                	test   %eax,%eax
f010157e:	74 66                	je     f01015e6 <pgdir_walk+0xa4>
			page->pp_ref++;
f0101580:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101585:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f010158b:	2b 02                	sub    (%edx),%eax
f010158d:	c1 f8 03             	sar    $0x3,%eax
f0101590:	c1 e0 0c             	shl    $0xc,%eax
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f0101593:	83 c8 07             	or     $0x7,%eax
f0101596:	89 06                	mov    %eax,(%esi)
	page_base = KADDR(PTE_ADDR(*pde));
f0101598:	8b 06                	mov    (%esi),%eax
f010159a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f010159f:	89 c1                	mov    %eax,%ecx
f01015a1:	c1 e9 0c             	shr    $0xc,%ecx
f01015a4:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f01015aa:	3b 0a                	cmp    (%edx),%ecx
f01015ac:	73 18                	jae    f01015c6 <pgdir_walk+0x84>
	page_off = PTX(va);
f01015ae:	c1 ef 0a             	shr    $0xa,%edi
	return &page_base[page_off];
f01015b1:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f01015b7:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
}
f01015be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015c1:	5b                   	pop    %ebx
f01015c2:	5e                   	pop    %esi
f01015c3:	5f                   	pop    %edi
f01015c4:	5d                   	pop    %ebp
f01015c5:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015c6:	50                   	push   %eax
f01015c7:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f01015cd:	50                   	push   %eax
f01015ce:	68 9b 01 00 00       	push   $0x19b
f01015d3:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01015d9:	50                   	push   %eax
f01015da:	e8 21 eb ff ff       	call   f0100100 <_panic>
			return NULL;
f01015df:	b8 00 00 00 00       	mov    $0x0,%eax
f01015e4:	eb d8                	jmp    f01015be <pgdir_walk+0x7c>
				return NULL;
f01015e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01015eb:	eb d1                	jmp    f01015be <pgdir_walk+0x7c>

f01015ed <boot_map_region>:
{
f01015ed:	55                   	push   %ebp
f01015ee:	89 e5                	mov    %esp,%ebp
f01015f0:	57                   	push   %edi
f01015f1:	56                   	push   %esi
f01015f2:	53                   	push   %ebx
f01015f3:	83 ec 1c             	sub    $0x1c,%esp
f01015f6:	89 c7                	mov    %eax,%edi
f01015f8:	89 d6                	mov    %edx,%esi
f01015fa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0; i < size; i += PGSIZE)
f01015fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pte = (pa + i) | perm | PTE_P;
f0101602:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101605:	83 c8 01             	or     $0x1,%eax
f0101608:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0; i < size; i += PGSIZE)
f010160b:	eb 22                	jmp    f010162f <boot_map_region+0x42>
		pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f010160d:	83 ec 04             	sub    $0x4,%esp
f0101610:	6a 01                	push   $0x1
f0101612:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101615:	50                   	push   %eax
f0101616:	57                   	push   %edi
f0101617:	e8 26 ff ff ff       	call   f0101542 <pgdir_walk>
		*pte = (pa + i) | perm | PTE_P;
f010161c:	89 da                	mov    %ebx,%edx
f010161e:	03 55 08             	add    0x8(%ebp),%edx
f0101621:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101624:	89 10                	mov    %edx,(%eax)
	for (i = 0; i < size; i += PGSIZE)
f0101626:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010162c:	83 c4 10             	add    $0x10,%esp
f010162f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101632:	72 d9                	jb     f010160d <boot_map_region+0x20>
}
f0101634:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101637:	5b                   	pop    %ebx
f0101638:	5e                   	pop    %esi
f0101639:	5f                   	pop    %edi
f010163a:	5d                   	pop    %ebp
f010163b:	c3                   	ret    

f010163c <page_lookup>:
{
f010163c:	55                   	push   %ebp
f010163d:	89 e5                	mov    %esp,%ebp
f010163f:	56                   	push   %esi
f0101640:	53                   	push   %ebx
f0101641:	e8 70 eb ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0101646:	81 c3 c6 6c 01 00    	add    $0x16cc6,%ebx
f010164c:	8b 75 10             	mov    0x10(%ebp),%esi
	pte = pgdir_walk(pgdir, va, 0);
f010164f:	83 ec 04             	sub    $0x4,%esp
f0101652:	6a 00                	push   $0x0
f0101654:	ff 75 0c             	pushl  0xc(%ebp)
f0101657:	ff 75 08             	pushl  0x8(%ebp)
f010165a:	e8 e3 fe ff ff       	call   f0101542 <pgdir_walk>
	if (!pte)
f010165f:	83 c4 10             	add    $0x10,%esp
f0101662:	85 c0                	test   %eax,%eax
f0101664:	74 3f                	je     f01016a5 <page_lookup+0x69>
	if (pte_store)
f0101666:	85 f6                	test   %esi,%esi
f0101668:	74 02                	je     f010166c <page_lookup+0x30>
		*pte_store = pte;
f010166a:	89 06                	mov    %eax,(%esi)
f010166c:	8b 00                	mov    (%eax),%eax
f010166e:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101671:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f0101677:	39 02                	cmp    %eax,(%edx)
f0101679:	76 12                	jbe    f010168d <page_lookup+0x51>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f010167b:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f0101681:	8b 12                	mov    (%edx),%edx
f0101683:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f0101686:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101689:	5b                   	pop    %ebx
f010168a:	5e                   	pop    %esi
f010168b:	5d                   	pop    %ebp
f010168c:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010168d:	83 ec 04             	sub    $0x4,%esp
f0101690:	8d 83 bc cd fe ff    	lea    -0x13244(%ebx),%eax
f0101696:	50                   	push   %eax
f0101697:	6a 4b                	push   $0x4b
f0101699:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f010169f:	50                   	push   %eax
f01016a0:	e8 5b ea ff ff       	call   f0100100 <_panic>
		return NULL;
f01016a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01016aa:	eb da                	jmp    f0101686 <page_lookup+0x4a>

f01016ac <page_remove>:
{
f01016ac:	55                   	push   %ebp
f01016ad:	89 e5                	mov    %esp,%ebp
f01016af:	53                   	push   %ebx
f01016b0:	83 ec 18             	sub    $0x18,%esp
f01016b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte = NULL;
f01016b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	page = page_lookup(pgdir, va, &pte);
f01016bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01016c0:	50                   	push   %eax
f01016c1:	53                   	push   %ebx
f01016c2:	ff 75 08             	pushl  0x8(%ebp)
f01016c5:	e8 72 ff ff ff       	call   f010163c <page_lookup>
	if (!page)
f01016ca:	83 c4 10             	add    $0x10,%esp
f01016cd:	85 c0                	test   %eax,%eax
f01016cf:	74 18                	je     f01016e9 <page_remove+0x3d>
	page_decref(page);
f01016d1:	83 ec 0c             	sub    $0xc,%esp
f01016d4:	50                   	push   %eax
f01016d5:	e8 3f fe ff ff       	call   f0101519 <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01016da:	0f 01 3b             	invlpg (%ebx)
	*pte = 0;
f01016dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01016e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return;
f01016e6:	83 c4 10             	add    $0x10,%esp
}
f01016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016ec:	c9                   	leave  
f01016ed:	c3                   	ret    

f01016ee <page_insert>:
{
f01016ee:	55                   	push   %ebp
f01016ef:	89 e5                	mov    %esp,%ebp
f01016f1:	57                   	push   %edi
f01016f2:	56                   	push   %esi
f01016f3:	53                   	push   %ebx
f01016f4:	83 ec 10             	sub    $0x10,%esp
f01016f7:	e8 8a 1d 00 00       	call   f0103486 <__x86.get_pc_thunk.di>
f01016fc:	81 c7 10 6c 01 00    	add    $0x16c10,%edi
	pte = pgdir_walk(pgdir, va, 1);
f0101702:	6a 01                	push   $0x1
f0101704:	ff 75 10             	pushl  0x10(%ebp)
f0101707:	ff 75 08             	pushl  0x8(%ebp)
f010170a:	e8 33 fe ff ff       	call   f0101542 <pgdir_walk>
f010170f:	89 c3                	mov    %eax,%ebx
	pde = &pgdir[PDX(va)];
f0101711:	8b 45 10             	mov    0x10(%ebp),%eax
f0101714:	c1 e8 16             	shr    $0x16,%eax
f0101717:	8b 75 08             	mov    0x8(%ebp),%esi
f010171a:	8d 34 86             	lea    (%esi,%eax,4),%esi
	if (!pte)
f010171d:	83 c4 10             	add    $0x10,%esp
f0101720:	85 db                	test   %ebx,%ebx
f0101722:	74 4f                	je     f0101773 <page_insert+0x85>
	pp->pp_ref++;
f0101724:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101727:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if ((*pte) & PTE_P)
f010172c:	f6 03 01             	testb  $0x1,(%ebx)
f010172f:	75 2f                	jne    f0101760 <page_insert+0x72>
	return (pp - pages) << PGSHIFT;
f0101731:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0101737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010173a:	2b 08                	sub    (%eax),%ecx
f010173c:	89 c8                	mov    %ecx,%eax
f010173e:	c1 f8 03             	sar    $0x3,%eax
f0101741:	c1 e0 0c             	shl    $0xc,%eax
	*pte = page2pa(pp) | perm | PTE_P;
f0101744:	8b 55 14             	mov    0x14(%ebp),%edx
f0101747:	83 ca 01             	or     $0x1,%edx
f010174a:	09 d0                	or     %edx,%eax
f010174c:	89 03                	mov    %eax,(%ebx)
	*pde = *pde | perm;
f010174e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101751:	09 06                	or     %eax,(%esi)
	return 0;
f0101753:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101758:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010175b:	5b                   	pop    %ebx
f010175c:	5e                   	pop    %esi
f010175d:	5f                   	pop    %edi
f010175e:	5d                   	pop    %ebp
f010175f:	c3                   	ret    
		page_remove(pgdir, va);
f0101760:	83 ec 08             	sub    $0x8,%esp
f0101763:	ff 75 10             	pushl  0x10(%ebp)
f0101766:	ff 75 08             	pushl  0x8(%ebp)
f0101769:	e8 3e ff ff ff       	call   f01016ac <page_remove>
f010176e:	83 c4 10             	add    $0x10,%esp
f0101771:	eb be                	jmp    f0101731 <page_insert+0x43>
		return -E_NO_MEM;
f0101773:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101778:	eb de                	jmp    f0101758 <page_insert+0x6a>

f010177a <mem_init>:
{
f010177a:	55                   	push   %ebp
f010177b:	89 e5                	mov    %esp,%ebp
f010177d:	57                   	push   %edi
f010177e:	56                   	push   %esi
f010177f:	53                   	push   %ebx
f0101780:	83 ec 3c             	sub    $0x3c,%esp
f0101783:	e8 d0 ef ff ff       	call   f0100758 <__x86.get_pc_thunk.ax>
f0101788:	05 84 6b 01 00       	add    $0x16b84,%eax
f010178d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f0101790:	b8 15 00 00 00       	mov    $0x15,%eax
f0101795:	e8 a9 f6 ff ff       	call   f0100e43 <nvram_read>
f010179a:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010179c:	b8 17 00 00 00       	mov    $0x17,%eax
f01017a1:	e8 9d f6 ff ff       	call   f0100e43 <nvram_read>
f01017a6:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01017a8:	b8 34 00 00 00       	mov    $0x34,%eax
f01017ad:	e8 91 f6 ff ff       	call   f0100e43 <nvram_read>
f01017b2:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f01017b5:	85 c0                	test   %eax,%eax
f01017b7:	0f 85 c2 00 00 00    	jne    f010187f <mem_init+0x105>
		totalmem = 1 * 1024 + extmem;
f01017bd:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01017c3:	85 f6                	test   %esi,%esi
f01017c5:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f01017c8:	89 c1                	mov    %eax,%ecx
f01017ca:	c1 e9 02             	shr    $0x2,%ecx
f01017cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01017d0:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f01017d6:	89 0a                	mov    %ecx,(%edx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01017d8:	89 c2                	mov    %eax,%edx
f01017da:	29 da                	sub    %ebx,%edx
f01017dc:	52                   	push   %edx
f01017dd:	53                   	push   %ebx
f01017de:	50                   	push   %eax
f01017df:	8d 87 dc cd fe ff    	lea    -0x13224(%edi),%eax
f01017e5:	50                   	push   %eax
f01017e6:	89 fb                	mov    %edi,%ebx
f01017e8:	e8 24 1d 00 00       	call   f0103511 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01017ed:	b8 00 10 00 00       	mov    $0x1000,%eax
f01017f2:	e8 82 f6 ff ff       	call   f0100e79 <boot_alloc>
f01017f7:	c7 c6 cc a6 11 f0    	mov    $0xf011a6cc,%esi
f01017fd:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f01017ff:	83 c4 0c             	add    $0xc,%esp
f0101802:	68 00 10 00 00       	push   $0x1000
f0101807:	6a 00                	push   $0x0
f0101809:	50                   	push   %eax
f010180a:	e8 69 29 00 00       	call   f0104178 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010180f:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101811:	83 c4 10             	add    $0x10,%esp
f0101814:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101819:	76 6e                	jbe    f0101889 <mem_init+0x10f>
	return (physaddr_t)kva - KERNBASE;
f010181b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101821:	83 ca 05             	or     $0x5,%edx
f0101824:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f010182a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010182d:	c7 c3 c8 a6 11 f0    	mov    $0xf011a6c8,%ebx
f0101833:	8b 03                	mov    (%ebx),%eax
f0101835:	c1 e0 03             	shl    $0x3,%eax
f0101838:	e8 3c f6 ff ff       	call   f0100e79 <boot_alloc>
f010183d:	c7 c6 d0 a6 11 f0    	mov    $0xf011a6d0,%esi
f0101843:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101845:	83 ec 04             	sub    $0x4,%esp
f0101848:	8b 13                	mov    (%ebx),%edx
f010184a:	c1 e2 03             	shl    $0x3,%edx
f010184d:	52                   	push   %edx
f010184e:	6a 00                	push   $0x0
f0101850:	50                   	push   %eax
f0101851:	89 fb                	mov    %edi,%ebx
f0101853:	e8 20 29 00 00       	call   f0104178 <memset>
	page_init();
f0101858:	e8 a0 fa ff ff       	call   f01012fd <page_init>
	check_page_free_list(1);
f010185d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101862:	e8 13 f7 ff ff       	call   f0100f7a <check_page_free_list>
	if (!pages)
f0101867:	83 c4 10             	add    $0x10,%esp
f010186a:	83 3e 00             	cmpl   $0x0,(%esi)
f010186d:	74 36                	je     f01018a5 <mem_init+0x12b>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010186f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101872:	8b 80 b0 1f 00 00    	mov    0x1fb0(%eax),%eax
f0101878:	be 00 00 00 00       	mov    $0x0,%esi
f010187d:	eb 49                	jmp    f01018c8 <mem_init+0x14e>
		totalmem = 16 * 1024 + ext16mem;
f010187f:	05 00 40 00 00       	add    $0x4000,%eax
f0101884:	e9 3f ff ff ff       	jmp    f01017c8 <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101889:	50                   	push   %eax
f010188a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010188d:	8d 83 18 ce fe ff    	lea    -0x131e8(%ebx),%eax
f0101893:	50                   	push   %eax
f0101894:	68 93 00 00 00       	push   $0x93
f0101899:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010189f:	50                   	push   %eax
f01018a0:	e8 5b e8 ff ff       	call   f0100100 <_panic>
		panic("'pages' is a null pointer!");
f01018a5:	83 ec 04             	sub    $0x4,%esp
f01018a8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018ab:	8d 83 80 ca fe ff    	lea    -0x13580(%ebx),%eax
f01018b1:	50                   	push   %eax
f01018b2:	68 80 02 00 00       	push   $0x280
f01018b7:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01018bd:	50                   	push   %eax
f01018be:	e8 3d e8 ff ff       	call   f0100100 <_panic>
		++nfree;
f01018c3:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01018c6:	8b 00                	mov    (%eax),%eax
f01018c8:	85 c0                	test   %eax,%eax
f01018ca:	75 f7                	jne    f01018c3 <mem_init+0x149>
	assert((pp0 = page_alloc(0)));
f01018cc:	83 ec 0c             	sub    $0xc,%esp
f01018cf:	6a 00                	push   $0x0
f01018d1:	e8 49 fb ff ff       	call   f010141f <page_alloc>
f01018d6:	89 c3                	mov    %eax,%ebx
f01018d8:	83 c4 10             	add    $0x10,%esp
f01018db:	85 c0                	test   %eax,%eax
f01018dd:	0f 84 3b 02 00 00    	je     f0101b1e <mem_init+0x3a4>
	assert((pp1 = page_alloc(0)));
f01018e3:	83 ec 0c             	sub    $0xc,%esp
f01018e6:	6a 00                	push   $0x0
f01018e8:	e8 32 fb ff ff       	call   f010141f <page_alloc>
f01018ed:	89 c7                	mov    %eax,%edi
f01018ef:	83 c4 10             	add    $0x10,%esp
f01018f2:	85 c0                	test   %eax,%eax
f01018f4:	0f 84 46 02 00 00    	je     f0101b40 <mem_init+0x3c6>
	assert((pp2 = page_alloc(0)));
f01018fa:	83 ec 0c             	sub    $0xc,%esp
f01018fd:	6a 00                	push   $0x0
f01018ff:	e8 1b fb ff ff       	call   f010141f <page_alloc>
f0101904:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101907:	83 c4 10             	add    $0x10,%esp
f010190a:	85 c0                	test   %eax,%eax
f010190c:	0f 84 50 02 00 00    	je     f0101b62 <mem_init+0x3e8>
	assert(pp1 && pp1 != pp0);
f0101912:	39 fb                	cmp    %edi,%ebx
f0101914:	0f 84 6a 02 00 00    	je     f0101b84 <mem_init+0x40a>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010191a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010191d:	39 c3                	cmp    %eax,%ebx
f010191f:	0f 84 81 02 00 00    	je     f0101ba6 <mem_init+0x42c>
f0101925:	39 c7                	cmp    %eax,%edi
f0101927:	0f 84 79 02 00 00    	je     f0101ba6 <mem_init+0x42c>
	return (pp - pages) << PGSHIFT;
f010192d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101930:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0101936:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101938:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f010193e:	8b 10                	mov    (%eax),%edx
f0101940:	c1 e2 0c             	shl    $0xc,%edx
f0101943:	89 d8                	mov    %ebx,%eax
f0101945:	29 c8                	sub    %ecx,%eax
f0101947:	c1 f8 03             	sar    $0x3,%eax
f010194a:	c1 e0 0c             	shl    $0xc,%eax
f010194d:	39 d0                	cmp    %edx,%eax
f010194f:	0f 83 73 02 00 00    	jae    f0101bc8 <mem_init+0x44e>
f0101955:	89 f8                	mov    %edi,%eax
f0101957:	29 c8                	sub    %ecx,%eax
f0101959:	c1 f8 03             	sar    $0x3,%eax
f010195c:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010195f:	39 c2                	cmp    %eax,%edx
f0101961:	0f 86 83 02 00 00    	jbe    f0101bea <mem_init+0x470>
f0101967:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010196a:	29 c8                	sub    %ecx,%eax
f010196c:	c1 f8 03             	sar    $0x3,%eax
f010196f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101972:	39 c2                	cmp    %eax,%edx
f0101974:	0f 86 92 02 00 00    	jbe    f0101c0c <mem_init+0x492>
	fl = page_free_list;
f010197a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010197d:	8b 88 b0 1f 00 00    	mov    0x1fb0(%eax),%ecx
f0101983:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101986:	c7 80 b0 1f 00 00 00 	movl   $0x0,0x1fb0(%eax)
f010198d:	00 00 00 
	assert(!page_alloc(0));
f0101990:	83 ec 0c             	sub    $0xc,%esp
f0101993:	6a 00                	push   $0x0
f0101995:	e8 85 fa ff ff       	call   f010141f <page_alloc>
f010199a:	83 c4 10             	add    $0x10,%esp
f010199d:	85 c0                	test   %eax,%eax
f010199f:	0f 85 89 02 00 00    	jne    f0101c2e <mem_init+0x4b4>
	page_free(pp0);
f01019a5:	83 ec 0c             	sub    $0xc,%esp
f01019a8:	53                   	push   %ebx
f01019a9:	e8 f9 fa ff ff       	call   f01014a7 <page_free>
	page_free(pp1);
f01019ae:	89 3c 24             	mov    %edi,(%esp)
f01019b1:	e8 f1 fa ff ff       	call   f01014a7 <page_free>
	page_free(pp2);
f01019b6:	83 c4 04             	add    $0x4,%esp
f01019b9:	ff 75 d0             	pushl  -0x30(%ebp)
f01019bc:	e8 e6 fa ff ff       	call   f01014a7 <page_free>
	assert((pp0 = page_alloc(0)));
f01019c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019c8:	e8 52 fa ff ff       	call   f010141f <page_alloc>
f01019cd:	89 c7                	mov    %eax,%edi
f01019cf:	83 c4 10             	add    $0x10,%esp
f01019d2:	85 c0                	test   %eax,%eax
f01019d4:	0f 84 76 02 00 00    	je     f0101c50 <mem_init+0x4d6>
	assert((pp1 = page_alloc(0)));
f01019da:	83 ec 0c             	sub    $0xc,%esp
f01019dd:	6a 00                	push   $0x0
f01019df:	e8 3b fa ff ff       	call   f010141f <page_alloc>
f01019e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01019e7:	83 c4 10             	add    $0x10,%esp
f01019ea:	85 c0                	test   %eax,%eax
f01019ec:	0f 84 80 02 00 00    	je     f0101c72 <mem_init+0x4f8>
	assert((pp2 = page_alloc(0)));
f01019f2:	83 ec 0c             	sub    $0xc,%esp
f01019f5:	6a 00                	push   $0x0
f01019f7:	e8 23 fa ff ff       	call   f010141f <page_alloc>
f01019fc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019ff:	83 c4 10             	add    $0x10,%esp
f0101a02:	85 c0                	test   %eax,%eax
f0101a04:	0f 84 8a 02 00 00    	je     f0101c94 <mem_init+0x51a>
	assert(pp1 && pp1 != pp0);
f0101a0a:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101a0d:	0f 84 a3 02 00 00    	je     f0101cb6 <mem_init+0x53c>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a13:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101a16:	39 c7                	cmp    %eax,%edi
f0101a18:	0f 84 ba 02 00 00    	je     f0101cd8 <mem_init+0x55e>
f0101a1e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101a21:	0f 84 b1 02 00 00    	je     f0101cd8 <mem_init+0x55e>
	assert(!page_alloc(0));
f0101a27:	83 ec 0c             	sub    $0xc,%esp
f0101a2a:	6a 00                	push   $0x0
f0101a2c:	e8 ee f9 ff ff       	call   f010141f <page_alloc>
f0101a31:	83 c4 10             	add    $0x10,%esp
f0101a34:	85 c0                	test   %eax,%eax
f0101a36:	0f 85 be 02 00 00    	jne    f0101cfa <mem_init+0x580>
f0101a3c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a3f:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0101a45:	89 f9                	mov    %edi,%ecx
f0101a47:	2b 08                	sub    (%eax),%ecx
f0101a49:	89 c8                	mov    %ecx,%eax
f0101a4b:	c1 f8 03             	sar    $0x3,%eax
f0101a4e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101a51:	89 c1                	mov    %eax,%ecx
f0101a53:	c1 e9 0c             	shr    $0xc,%ecx
f0101a56:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f0101a5c:	3b 0a                	cmp    (%edx),%ecx
f0101a5e:	0f 83 b8 02 00 00    	jae    f0101d1c <mem_init+0x5a2>
	memset(page2kva(pp0), 1, PGSIZE);
f0101a64:	83 ec 04             	sub    $0x4,%esp
f0101a67:	68 00 10 00 00       	push   $0x1000
f0101a6c:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101a6e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a73:	50                   	push   %eax
f0101a74:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a77:	e8 fc 26 00 00       	call   f0104178 <memset>
	page_free(pp0);
f0101a7c:	89 3c 24             	mov    %edi,(%esp)
f0101a7f:	e8 23 fa ff ff       	call   f01014a7 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101a84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101a8b:	e8 8f f9 ff ff       	call   f010141f <page_alloc>
f0101a90:	83 c4 10             	add    $0x10,%esp
f0101a93:	85 c0                	test   %eax,%eax
f0101a95:	0f 84 97 02 00 00    	je     f0101d32 <mem_init+0x5b8>
	assert(pp && pp0 == pp);
f0101a9b:	39 c7                	cmp    %eax,%edi
f0101a9d:	0f 85 b1 02 00 00    	jne    f0101d54 <mem_init+0x5da>
	return (pp - pages) << PGSHIFT;
f0101aa3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101aa6:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0101aac:	89 fa                	mov    %edi,%edx
f0101aae:	2b 10                	sub    (%eax),%edx
f0101ab0:	c1 fa 03             	sar    $0x3,%edx
f0101ab3:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101ab6:	89 d1                	mov    %edx,%ecx
f0101ab8:	c1 e9 0c             	shr    $0xc,%ecx
f0101abb:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f0101ac1:	3b 08                	cmp    (%eax),%ecx
f0101ac3:	0f 83 ad 02 00 00    	jae    f0101d76 <mem_init+0x5fc>
	return (void *)(pa + KERNBASE);
f0101ac9:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101acf:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101ad5:	80 38 00             	cmpb   $0x0,(%eax)
f0101ad8:	0f 85 ae 02 00 00    	jne    f0101d8c <mem_init+0x612>
f0101ade:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101ae1:	39 d0                	cmp    %edx,%eax
f0101ae3:	75 f0                	jne    f0101ad5 <mem_init+0x35b>
	page_free_list = fl;
f0101ae5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ae8:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101aeb:	89 8b b0 1f 00 00    	mov    %ecx,0x1fb0(%ebx)
	page_free(pp0);
f0101af1:	83 ec 0c             	sub    $0xc,%esp
f0101af4:	57                   	push   %edi
f0101af5:	e8 ad f9 ff ff       	call   f01014a7 <page_free>
	page_free(pp1);
f0101afa:	83 c4 04             	add    $0x4,%esp
f0101afd:	ff 75 d0             	pushl  -0x30(%ebp)
f0101b00:	e8 a2 f9 ff ff       	call   f01014a7 <page_free>
	page_free(pp2);
f0101b05:	83 c4 04             	add    $0x4,%esp
f0101b08:	ff 75 cc             	pushl  -0x34(%ebp)
f0101b0b:	e8 97 f9 ff ff       	call   f01014a7 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101b10:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101b16:	83 c4 10             	add    $0x10,%esp
f0101b19:	e9 95 02 00 00       	jmp    f0101db3 <mem_init+0x639>
	assert((pp0 = page_alloc(0)));
f0101b1e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b21:	8d 83 9b ca fe ff    	lea    -0x13565(%ebx),%eax
f0101b27:	50                   	push   %eax
f0101b28:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101b2e:	50                   	push   %eax
f0101b2f:	68 88 02 00 00       	push   $0x288
f0101b34:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101b3a:	50                   	push   %eax
f0101b3b:	e8 c0 e5 ff ff       	call   f0100100 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b40:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b43:	8d 83 b1 ca fe ff    	lea    -0x1354f(%ebx),%eax
f0101b49:	50                   	push   %eax
f0101b4a:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101b50:	50                   	push   %eax
f0101b51:	68 89 02 00 00       	push   $0x289
f0101b56:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101b5c:	50                   	push   %eax
f0101b5d:	e8 9e e5 ff ff       	call   f0100100 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b62:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b65:	8d 83 c7 ca fe ff    	lea    -0x13539(%ebx),%eax
f0101b6b:	50                   	push   %eax
f0101b6c:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101b72:	50                   	push   %eax
f0101b73:	68 8a 02 00 00       	push   $0x28a
f0101b78:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101b7e:	50                   	push   %eax
f0101b7f:	e8 7c e5 ff ff       	call   f0100100 <_panic>
	assert(pp1 && pp1 != pp0);
f0101b84:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b87:	8d 83 dd ca fe ff    	lea    -0x13523(%ebx),%eax
f0101b8d:	50                   	push   %eax
f0101b8e:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101b94:	50                   	push   %eax
f0101b95:	68 8d 02 00 00       	push   $0x28d
f0101b9a:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101ba0:	50                   	push   %eax
f0101ba1:	e8 5a e5 ff ff       	call   f0100100 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ba6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ba9:	8d 83 3c ce fe ff    	lea    -0x131c4(%ebx),%eax
f0101baf:	50                   	push   %eax
f0101bb0:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101bb6:	50                   	push   %eax
f0101bb7:	68 8e 02 00 00       	push   $0x28e
f0101bbc:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101bc2:	50                   	push   %eax
f0101bc3:	e8 38 e5 ff ff       	call   f0100100 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101bc8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101bcb:	8d 83 ef ca fe ff    	lea    -0x13511(%ebx),%eax
f0101bd1:	50                   	push   %eax
f0101bd2:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101bd8:	50                   	push   %eax
f0101bd9:	68 8f 02 00 00       	push   $0x28f
f0101bde:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101be4:	50                   	push   %eax
f0101be5:	e8 16 e5 ff ff       	call   f0100100 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101bea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101bed:	8d 83 0c cb fe ff    	lea    -0x134f4(%ebx),%eax
f0101bf3:	50                   	push   %eax
f0101bf4:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101bfa:	50                   	push   %eax
f0101bfb:	68 90 02 00 00       	push   $0x290
f0101c00:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101c06:	50                   	push   %eax
f0101c07:	e8 f4 e4 ff ff       	call   f0100100 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101c0c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c0f:	8d 83 29 cb fe ff    	lea    -0x134d7(%ebx),%eax
f0101c15:	50                   	push   %eax
f0101c16:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101c1c:	50                   	push   %eax
f0101c1d:	68 91 02 00 00       	push   $0x291
f0101c22:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101c28:	50                   	push   %eax
f0101c29:	e8 d2 e4 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f0101c2e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c31:	8d 83 46 cb fe ff    	lea    -0x134ba(%ebx),%eax
f0101c37:	50                   	push   %eax
f0101c38:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101c3e:	50                   	push   %eax
f0101c3f:	68 98 02 00 00       	push   $0x298
f0101c44:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101c4a:	50                   	push   %eax
f0101c4b:	e8 b0 e4 ff ff       	call   f0100100 <_panic>
	assert((pp0 = page_alloc(0)));
f0101c50:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c53:	8d 83 9b ca fe ff    	lea    -0x13565(%ebx),%eax
f0101c59:	50                   	push   %eax
f0101c5a:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101c60:	50                   	push   %eax
f0101c61:	68 9f 02 00 00       	push   $0x29f
f0101c66:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101c6c:	50                   	push   %eax
f0101c6d:	e8 8e e4 ff ff       	call   f0100100 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c72:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c75:	8d 83 b1 ca fe ff    	lea    -0x1354f(%ebx),%eax
f0101c7b:	50                   	push   %eax
f0101c7c:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101c82:	50                   	push   %eax
f0101c83:	68 a0 02 00 00       	push   $0x2a0
f0101c88:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101c8e:	50                   	push   %eax
f0101c8f:	e8 6c e4 ff ff       	call   f0100100 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c94:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c97:	8d 83 c7 ca fe ff    	lea    -0x13539(%ebx),%eax
f0101c9d:	50                   	push   %eax
f0101c9e:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101ca4:	50                   	push   %eax
f0101ca5:	68 a1 02 00 00       	push   $0x2a1
f0101caa:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101cb0:	50                   	push   %eax
f0101cb1:	e8 4a e4 ff ff       	call   f0100100 <_panic>
	assert(pp1 && pp1 != pp0);
f0101cb6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cb9:	8d 83 dd ca fe ff    	lea    -0x13523(%ebx),%eax
f0101cbf:	50                   	push   %eax
f0101cc0:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101cc6:	50                   	push   %eax
f0101cc7:	68 a3 02 00 00       	push   $0x2a3
f0101ccc:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101cd2:	50                   	push   %eax
f0101cd3:	e8 28 e4 ff ff       	call   f0100100 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cd8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cdb:	8d 83 3c ce fe ff    	lea    -0x131c4(%ebx),%eax
f0101ce1:	50                   	push   %eax
f0101ce2:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101ce8:	50                   	push   %eax
f0101ce9:	68 a4 02 00 00       	push   $0x2a4
f0101cee:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101cf4:	50                   	push   %eax
f0101cf5:	e8 06 e4 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f0101cfa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cfd:	8d 83 46 cb fe ff    	lea    -0x134ba(%ebx),%eax
f0101d03:	50                   	push   %eax
f0101d04:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101d0a:	50                   	push   %eax
f0101d0b:	68 a5 02 00 00       	push   $0x2a5
f0101d10:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101d16:	50                   	push   %eax
f0101d17:	e8 e4 e3 ff ff       	call   f0100100 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d1c:	50                   	push   %eax
f0101d1d:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f0101d23:	50                   	push   %eax
f0101d24:	6a 52                	push   $0x52
f0101d26:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f0101d2c:	50                   	push   %eax
f0101d2d:	e8 ce e3 ff ff       	call   f0100100 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101d32:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d35:	8d 83 55 cb fe ff    	lea    -0x134ab(%ebx),%eax
f0101d3b:	50                   	push   %eax
f0101d3c:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101d42:	50                   	push   %eax
f0101d43:	68 aa 02 00 00       	push   $0x2aa
f0101d48:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101d4e:	50                   	push   %eax
f0101d4f:	e8 ac e3 ff ff       	call   f0100100 <_panic>
	assert(pp && pp0 == pp);
f0101d54:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d57:	8d 83 73 cb fe ff    	lea    -0x1348d(%ebx),%eax
f0101d5d:	50                   	push   %eax
f0101d5e:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101d64:	50                   	push   %eax
f0101d65:	68 ab 02 00 00       	push   $0x2ab
f0101d6a:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101d70:	50                   	push   %eax
f0101d71:	e8 8a e3 ff ff       	call   f0100100 <_panic>
f0101d76:	52                   	push   %edx
f0101d77:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f0101d7d:	50                   	push   %eax
f0101d7e:	6a 52                	push   $0x52
f0101d80:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f0101d86:	50                   	push   %eax
f0101d87:	e8 74 e3 ff ff       	call   f0100100 <_panic>
		assert(c[i] == 0);
f0101d8c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d8f:	8d 83 83 cb fe ff    	lea    -0x1347d(%ebx),%eax
f0101d95:	50                   	push   %eax
f0101d96:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0101d9c:	50                   	push   %eax
f0101d9d:	68 ae 02 00 00       	push   $0x2ae
f0101da2:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0101da8:	50                   	push   %eax
f0101da9:	e8 52 e3 ff ff       	call   f0100100 <_panic>
		--nfree;
f0101dae:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101db1:	8b 00                	mov    (%eax),%eax
f0101db3:	85 c0                	test   %eax,%eax
f0101db5:	75 f7                	jne    f0101dae <mem_init+0x634>
	assert(nfree == 0);
f0101db7:	85 f6                	test   %esi,%esi
f0101db9:	0f 85 55 08 00 00    	jne    f0102614 <mem_init+0xe9a>
	cprintf("check_page_alloc() succeeded!\n");
f0101dbf:	83 ec 0c             	sub    $0xc,%esp
f0101dc2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101dc5:	8d 83 5c ce fe ff    	lea    -0x131a4(%ebx),%eax
f0101dcb:	50                   	push   %eax
f0101dcc:	e8 40 17 00 00       	call   f0103511 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101dd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101dd8:	e8 42 f6 ff ff       	call   f010141f <page_alloc>
f0101ddd:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101de0:	83 c4 10             	add    $0x10,%esp
f0101de3:	85 c0                	test   %eax,%eax
f0101de5:	0f 84 4b 08 00 00    	je     f0102636 <mem_init+0xebc>
	assert((pp1 = page_alloc(0)));
f0101deb:	83 ec 0c             	sub    $0xc,%esp
f0101dee:	6a 00                	push   $0x0
f0101df0:	e8 2a f6 ff ff       	call   f010141f <page_alloc>
f0101df5:	89 c7                	mov    %eax,%edi
f0101df7:	83 c4 10             	add    $0x10,%esp
f0101dfa:	85 c0                	test   %eax,%eax
f0101dfc:	0f 84 56 08 00 00    	je     f0102658 <mem_init+0xede>
	assert((pp2 = page_alloc(0)));
f0101e02:	83 ec 0c             	sub    $0xc,%esp
f0101e05:	6a 00                	push   $0x0
f0101e07:	e8 13 f6 ff ff       	call   f010141f <page_alloc>
f0101e0c:	89 c6                	mov    %eax,%esi
f0101e0e:	83 c4 10             	add    $0x10,%esp
f0101e11:	85 c0                	test   %eax,%eax
f0101e13:	0f 84 61 08 00 00    	je     f010267a <mem_init+0xf00>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101e19:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101e1c:	0f 84 7a 08 00 00    	je     f010269c <mem_init+0xf22>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101e22:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101e25:	0f 84 93 08 00 00    	je     f01026be <mem_init+0xf44>
f0101e2b:	39 c7                	cmp    %eax,%edi
f0101e2d:	0f 84 8b 08 00 00    	je     f01026be <mem_init+0xf44>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101e33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e36:	8b 88 b0 1f 00 00    	mov    0x1fb0(%eax),%ecx
f0101e3c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101e3f:	c7 80 b0 1f 00 00 00 	movl   $0x0,0x1fb0(%eax)
f0101e46:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101e49:	83 ec 0c             	sub    $0xc,%esp
f0101e4c:	6a 00                	push   $0x0
f0101e4e:	e8 cc f5 ff ff       	call   f010141f <page_alloc>
f0101e53:	83 c4 10             	add    $0x10,%esp
f0101e56:	85 c0                	test   %eax,%eax
f0101e58:	0f 85 82 08 00 00    	jne    f01026e0 <mem_init+0xf66>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101e5e:	83 ec 04             	sub    $0x4,%esp
f0101e61:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101e64:	50                   	push   %eax
f0101e65:	6a 00                	push   $0x0
f0101e67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e6a:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101e70:	ff 30                	pushl  (%eax)
f0101e72:	e8 c5 f7 ff ff       	call   f010163c <page_lookup>
f0101e77:	83 c4 10             	add    $0x10,%esp
f0101e7a:	85 c0                	test   %eax,%eax
f0101e7c:	0f 85 80 08 00 00    	jne    f0102702 <mem_init+0xf88>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101e82:	6a 02                	push   $0x2
f0101e84:	6a 00                	push   $0x0
f0101e86:	57                   	push   %edi
f0101e87:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e8a:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101e90:	ff 30                	pushl  (%eax)
f0101e92:	e8 57 f8 ff ff       	call   f01016ee <page_insert>
f0101e97:	83 c4 10             	add    $0x10,%esp
f0101e9a:	85 c0                	test   %eax,%eax
f0101e9c:	0f 89 82 08 00 00    	jns    f0102724 <mem_init+0xfaa>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ea2:	83 ec 0c             	sub    $0xc,%esp
f0101ea5:	ff 75 d0             	pushl  -0x30(%ebp)
f0101ea8:	e8 fa f5 ff ff       	call   f01014a7 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ead:	6a 02                	push   $0x2
f0101eaf:	6a 00                	push   $0x0
f0101eb1:	57                   	push   %edi
f0101eb2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eb5:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101ebb:	ff 30                	pushl  (%eax)
f0101ebd:	e8 2c f8 ff ff       	call   f01016ee <page_insert>
f0101ec2:	83 c4 20             	add    $0x20,%esp
f0101ec5:	85 c0                	test   %eax,%eax
f0101ec7:	0f 85 79 08 00 00    	jne    f0102746 <mem_init+0xfcc>
	// cprintf("assret %x == %x\n", PTE_ADDR(kern_pgdir[0]), page2pa(pp1));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ecd:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101ed0:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101ed6:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101ed8:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0101ede:	8b 08                	mov    (%eax),%ecx
f0101ee0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101ee3:	8b 13                	mov    (%ebx),%edx
f0101ee5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101eeb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101eee:	29 c8                	sub    %ecx,%eax
f0101ef0:	c1 f8 03             	sar    $0x3,%eax
f0101ef3:	c1 e0 0c             	shl    $0xc,%eax
f0101ef6:	39 c2                	cmp    %eax,%edx
f0101ef8:	0f 85 6a 08 00 00    	jne    f0102768 <mem_init+0xfee>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101efe:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f03:	89 d8                	mov    %ebx,%eax
f0101f05:	e8 f3 ef ff ff       	call   f0100efd <check_va2pa>
f0101f0a:	89 fa                	mov    %edi,%edx
f0101f0c:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101f0f:	c1 fa 03             	sar    $0x3,%edx
f0101f12:	c1 e2 0c             	shl    $0xc,%edx
f0101f15:	39 d0                	cmp    %edx,%eax
f0101f17:	0f 85 6d 08 00 00    	jne    f010278a <mem_init+0x1010>
	assert(pp1->pp_ref == 1);
f0101f1d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101f22:	0f 85 84 08 00 00    	jne    f01027ac <mem_init+0x1032>
	assert(pp0->pp_ref == 1);
f0101f28:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101f2b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f30:	0f 85 98 08 00 00    	jne    f01027ce <mem_init+0x1054>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f36:	6a 02                	push   $0x2
f0101f38:	68 00 10 00 00       	push   $0x1000
f0101f3d:	56                   	push   %esi
f0101f3e:	53                   	push   %ebx
f0101f3f:	e8 aa f7 ff ff       	call   f01016ee <page_insert>
f0101f44:	83 c4 10             	add    $0x10,%esp
f0101f47:	85 c0                	test   %eax,%eax
f0101f49:	0f 85 a1 08 00 00    	jne    f01027f0 <mem_init+0x1076>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f4f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f54:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f57:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101f5d:	8b 00                	mov    (%eax),%eax
f0101f5f:	e8 99 ef ff ff       	call   f0100efd <check_va2pa>
f0101f64:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f0101f6a:	89 f1                	mov    %esi,%ecx
f0101f6c:	2b 0a                	sub    (%edx),%ecx
f0101f6e:	89 ca                	mov    %ecx,%edx
f0101f70:	c1 fa 03             	sar    $0x3,%edx
f0101f73:	c1 e2 0c             	shl    $0xc,%edx
f0101f76:	39 d0                	cmp    %edx,%eax
f0101f78:	0f 85 94 08 00 00    	jne    f0102812 <mem_init+0x1098>
	assert(pp2->pp_ref == 1);
f0101f7e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f83:	0f 85 ab 08 00 00    	jne    f0102834 <mem_init+0x10ba>

	// should be no free memory
	assert(!page_alloc(0));
f0101f89:	83 ec 0c             	sub    $0xc,%esp
f0101f8c:	6a 00                	push   $0x0
f0101f8e:	e8 8c f4 ff ff       	call   f010141f <page_alloc>
f0101f93:	83 c4 10             	add    $0x10,%esp
f0101f96:	85 c0                	test   %eax,%eax
f0101f98:	0f 85 b8 08 00 00    	jne    f0102856 <mem_init+0x10dc>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f9e:	6a 02                	push   $0x2
f0101fa0:	68 00 10 00 00       	push   $0x1000
f0101fa5:	56                   	push   %esi
f0101fa6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fa9:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101faf:	ff 30                	pushl  (%eax)
f0101fb1:	e8 38 f7 ff ff       	call   f01016ee <page_insert>
f0101fb6:	83 c4 10             	add    $0x10,%esp
f0101fb9:	85 c0                	test   %eax,%eax
f0101fbb:	0f 85 b7 08 00 00    	jne    f0102878 <mem_init+0x10fe>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101fc1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fc6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fc9:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101fcf:	8b 00                	mov    (%eax),%eax
f0101fd1:	e8 27 ef ff ff       	call   f0100efd <check_va2pa>
f0101fd6:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f0101fdc:	89 f1                	mov    %esi,%ecx
f0101fde:	2b 0a                	sub    (%edx),%ecx
f0101fe0:	89 ca                	mov    %ecx,%edx
f0101fe2:	c1 fa 03             	sar    $0x3,%edx
f0101fe5:	c1 e2 0c             	shl    $0xc,%edx
f0101fe8:	39 d0                	cmp    %edx,%eax
f0101fea:	0f 85 aa 08 00 00    	jne    f010289a <mem_init+0x1120>
	assert(pp2->pp_ref == 1);
f0101ff0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ff5:	0f 85 c1 08 00 00    	jne    f01028bc <mem_init+0x1142>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ffb:	83 ec 0c             	sub    $0xc,%esp
f0101ffe:	6a 00                	push   $0x0
f0102000:	e8 1a f4 ff ff       	call   f010141f <page_alloc>
f0102005:	83 c4 10             	add    $0x10,%esp
f0102008:	85 c0                	test   %eax,%eax
f010200a:	0f 85 ce 08 00 00    	jne    f01028de <mem_init+0x1164>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102010:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102013:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0102019:	8b 10                	mov    (%eax),%edx
f010201b:	8b 02                	mov    (%edx),%eax
f010201d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0102022:	89 c3                	mov    %eax,%ebx
f0102024:	c1 eb 0c             	shr    $0xc,%ebx
f0102027:	c7 c1 c8 a6 11 f0    	mov    $0xf011a6c8,%ecx
f010202d:	3b 19                	cmp    (%ecx),%ebx
f010202f:	0f 83 cb 08 00 00    	jae    f0102900 <mem_init+0x1186>
	return (void *)(pa + KERNBASE);
f0102035:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010203a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010203d:	83 ec 04             	sub    $0x4,%esp
f0102040:	6a 00                	push   $0x0
f0102042:	68 00 10 00 00       	push   $0x1000
f0102047:	52                   	push   %edx
f0102048:	e8 f5 f4 ff ff       	call   f0101542 <pgdir_walk>
f010204d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102050:	8d 51 04             	lea    0x4(%ecx),%edx
f0102053:	83 c4 10             	add    $0x10,%esp
f0102056:	39 d0                	cmp    %edx,%eax
f0102058:	0f 85 be 08 00 00    	jne    f010291c <mem_init+0x11a2>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010205e:	6a 06                	push   $0x6
f0102060:	68 00 10 00 00       	push   $0x1000
f0102065:	56                   	push   %esi
f0102066:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102069:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f010206f:	ff 30                	pushl  (%eax)
f0102071:	e8 78 f6 ff ff       	call   f01016ee <page_insert>
f0102076:	83 c4 10             	add    $0x10,%esp
f0102079:	85 c0                	test   %eax,%eax
f010207b:	0f 85 bd 08 00 00    	jne    f010293e <mem_init+0x11c4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102081:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102084:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f010208a:	8b 18                	mov    (%eax),%ebx
f010208c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102091:	89 d8                	mov    %ebx,%eax
f0102093:	e8 65 ee ff ff       	call   f0100efd <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0102098:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010209b:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f01020a1:	89 f1                	mov    %esi,%ecx
f01020a3:	2b 0a                	sub    (%edx),%ecx
f01020a5:	89 ca                	mov    %ecx,%edx
f01020a7:	c1 fa 03             	sar    $0x3,%edx
f01020aa:	c1 e2 0c             	shl    $0xc,%edx
f01020ad:	39 d0                	cmp    %edx,%eax
f01020af:	0f 85 ab 08 00 00    	jne    f0102960 <mem_init+0x11e6>
	assert(pp2->pp_ref == 1);
f01020b5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01020ba:	0f 85 c2 08 00 00    	jne    f0102982 <mem_init+0x1208>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01020c0:	83 ec 04             	sub    $0x4,%esp
f01020c3:	6a 00                	push   $0x0
f01020c5:	68 00 10 00 00       	push   $0x1000
f01020ca:	53                   	push   %ebx
f01020cb:	e8 72 f4 ff ff       	call   f0101542 <pgdir_walk>
f01020d0:	83 c4 10             	add    $0x10,%esp
f01020d3:	f6 00 04             	testb  $0x4,(%eax)
f01020d6:	0f 84 c8 08 00 00    	je     f01029a4 <mem_init+0x122a>
	assert(kern_pgdir[0] & PTE_U);
f01020dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020df:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f01020e5:	8b 00                	mov    (%eax),%eax
f01020e7:	f6 00 04             	testb  $0x4,(%eax)
f01020ea:	0f 84 d6 08 00 00    	je     f01029c6 <mem_init+0x124c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01020f0:	6a 02                	push   $0x2
f01020f2:	68 00 10 00 00       	push   $0x1000
f01020f7:	56                   	push   %esi
f01020f8:	50                   	push   %eax
f01020f9:	e8 f0 f5 ff ff       	call   f01016ee <page_insert>
f01020fe:	83 c4 10             	add    $0x10,%esp
f0102101:	85 c0                	test   %eax,%eax
f0102103:	0f 85 df 08 00 00    	jne    f01029e8 <mem_init+0x126e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102109:	83 ec 04             	sub    $0x4,%esp
f010210c:	6a 00                	push   $0x0
f010210e:	68 00 10 00 00       	push   $0x1000
f0102113:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102116:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f010211c:	ff 30                	pushl  (%eax)
f010211e:	e8 1f f4 ff ff       	call   f0101542 <pgdir_walk>
f0102123:	83 c4 10             	add    $0x10,%esp
f0102126:	f6 00 02             	testb  $0x2,(%eax)
f0102129:	0f 84 db 08 00 00    	je     f0102a0a <mem_init+0x1290>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010212f:	83 ec 04             	sub    $0x4,%esp
f0102132:	6a 00                	push   $0x0
f0102134:	68 00 10 00 00       	push   $0x1000
f0102139:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010213c:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0102142:	ff 30                	pushl  (%eax)
f0102144:	e8 f9 f3 ff ff       	call   f0101542 <pgdir_walk>
f0102149:	83 c4 10             	add    $0x10,%esp
f010214c:	f6 00 04             	testb  $0x4,(%eax)
f010214f:	0f 85 d7 08 00 00    	jne    f0102a2c <mem_init+0x12b2>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102155:	6a 02                	push   $0x2
f0102157:	68 00 00 40 00       	push   $0x400000
f010215c:	ff 75 d0             	pushl  -0x30(%ebp)
f010215f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102162:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0102168:	ff 30                	pushl  (%eax)
f010216a:	e8 7f f5 ff ff       	call   f01016ee <page_insert>
f010216f:	83 c4 10             	add    $0x10,%esp
f0102172:	85 c0                	test   %eax,%eax
f0102174:	0f 89 d4 08 00 00    	jns    f0102a4e <mem_init+0x12d4>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010217a:	6a 02                	push   $0x2
f010217c:	68 00 10 00 00       	push   $0x1000
f0102181:	57                   	push   %edi
f0102182:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102185:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f010218b:	ff 30                	pushl  (%eax)
f010218d:	e8 5c f5 ff ff       	call   f01016ee <page_insert>
f0102192:	83 c4 10             	add    $0x10,%esp
f0102195:	85 c0                	test   %eax,%eax
f0102197:	0f 85 d3 08 00 00    	jne    f0102a70 <mem_init+0x12f6>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010219d:	83 ec 04             	sub    $0x4,%esp
f01021a0:	6a 00                	push   $0x0
f01021a2:	68 00 10 00 00       	push   $0x1000
f01021a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021aa:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f01021b0:	ff 30                	pushl  (%eax)
f01021b2:	e8 8b f3 ff ff       	call   f0101542 <pgdir_walk>
f01021b7:	83 c4 10             	add    $0x10,%esp
f01021ba:	f6 00 04             	testb  $0x4,(%eax)
f01021bd:	0f 85 cf 08 00 00    	jne    f0102a92 <mem_init+0x1318>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021c6:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f01021cc:	8b 18                	mov    (%eax),%ebx
f01021ce:	ba 00 00 00 00       	mov    $0x0,%edx
f01021d3:	89 d8                	mov    %ebx,%eax
f01021d5:	e8 23 ed ff ff       	call   f0100efd <check_va2pa>
f01021da:	89 c2                	mov    %eax,%edx
f01021dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021df:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01021e2:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f01021e8:	89 f9                	mov    %edi,%ecx
f01021ea:	2b 08                	sub    (%eax),%ecx
f01021ec:	89 c8                	mov    %ecx,%eax
f01021ee:	c1 f8 03             	sar    $0x3,%eax
f01021f1:	c1 e0 0c             	shl    $0xc,%eax
f01021f4:	39 c2                	cmp    %eax,%edx
f01021f6:	0f 85 b8 08 00 00    	jne    f0102ab4 <mem_init+0x133a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021fc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102201:	89 d8                	mov    %ebx,%eax
f0102203:	e8 f5 ec ff ff       	call   f0100efd <check_va2pa>
f0102208:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010220b:	0f 85 c5 08 00 00    	jne    f0102ad6 <mem_init+0x135c>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102211:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102216:	0f 85 dc 08 00 00    	jne    f0102af8 <mem_init+0x137e>
	assert(pp2->pp_ref == 0);
f010221c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102221:	0f 85 f3 08 00 00    	jne    f0102b1a <mem_init+0x13a0>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102227:	83 ec 0c             	sub    $0xc,%esp
f010222a:	6a 00                	push   $0x0
f010222c:	e8 ee f1 ff ff       	call   f010141f <page_alloc>
f0102231:	83 c4 10             	add    $0x10,%esp
f0102234:	39 c6                	cmp    %eax,%esi
f0102236:	0f 85 00 09 00 00    	jne    f0102b3c <mem_init+0x13c2>
f010223c:	85 c0                	test   %eax,%eax
f010223e:	0f 84 f8 08 00 00    	je     f0102b3c <mem_init+0x13c2>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102244:	83 ec 08             	sub    $0x8,%esp
f0102247:	6a 00                	push   $0x0
f0102249:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010224c:	c7 c3 cc a6 11 f0    	mov    $0xf011a6cc,%ebx
f0102252:	ff 33                	pushl  (%ebx)
f0102254:	e8 53 f4 ff ff       	call   f01016ac <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102259:	8b 1b                	mov    (%ebx),%ebx
f010225b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102260:	89 d8                	mov    %ebx,%eax
f0102262:	e8 96 ec ff ff       	call   f0100efd <check_va2pa>
f0102267:	83 c4 10             	add    $0x10,%esp
f010226a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010226d:	0f 85 eb 08 00 00    	jne    f0102b5e <mem_init+0x13e4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102273:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102278:	89 d8                	mov    %ebx,%eax
f010227a:	e8 7e ec ff ff       	call   f0100efd <check_va2pa>
f010227f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102282:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f0102288:	89 f9                	mov    %edi,%ecx
f010228a:	2b 0a                	sub    (%edx),%ecx
f010228c:	89 ca                	mov    %ecx,%edx
f010228e:	c1 fa 03             	sar    $0x3,%edx
f0102291:	c1 e2 0c             	shl    $0xc,%edx
f0102294:	39 d0                	cmp    %edx,%eax
f0102296:	0f 85 e4 08 00 00    	jne    f0102b80 <mem_init+0x1406>
	assert(pp1->pp_ref == 1);
f010229c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01022a1:	0f 85 fb 08 00 00    	jne    f0102ba2 <mem_init+0x1428>
	assert(pp2->pp_ref == 0);
f01022a7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022ac:	0f 85 12 09 00 00    	jne    f0102bc4 <mem_init+0x144a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01022b2:	6a 00                	push   $0x0
f01022b4:	68 00 10 00 00       	push   $0x1000
f01022b9:	57                   	push   %edi
f01022ba:	53                   	push   %ebx
f01022bb:	e8 2e f4 ff ff       	call   f01016ee <page_insert>
f01022c0:	83 c4 10             	add    $0x10,%esp
f01022c3:	85 c0                	test   %eax,%eax
f01022c5:	0f 85 1b 09 00 00    	jne    f0102be6 <mem_init+0x146c>
	assert(pp1->pp_ref);
f01022cb:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01022d0:	0f 84 32 09 00 00    	je     f0102c08 <mem_init+0x148e>
	assert(pp1->pp_link == NULL);
f01022d6:	83 3f 00             	cmpl   $0x0,(%edi)
f01022d9:	0f 85 4b 09 00 00    	jne    f0102c2a <mem_init+0x14b0>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022df:	83 ec 08             	sub    $0x8,%esp
f01022e2:	68 00 10 00 00       	push   $0x1000
f01022e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022ea:	c7 c3 cc a6 11 f0    	mov    $0xf011a6cc,%ebx
f01022f0:	ff 33                	pushl  (%ebx)
f01022f2:	e8 b5 f3 ff ff       	call   f01016ac <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022f7:	8b 1b                	mov    (%ebx),%ebx
f01022f9:	ba 00 00 00 00       	mov    $0x0,%edx
f01022fe:	89 d8                	mov    %ebx,%eax
f0102300:	e8 f8 eb ff ff       	call   f0100efd <check_va2pa>
f0102305:	83 c4 10             	add    $0x10,%esp
f0102308:	83 f8 ff             	cmp    $0xffffffff,%eax
f010230b:	0f 85 3b 09 00 00    	jne    f0102c4c <mem_init+0x14d2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102311:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102316:	89 d8                	mov    %ebx,%eax
f0102318:	e8 e0 eb ff ff       	call   f0100efd <check_va2pa>
f010231d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102320:	0f 85 48 09 00 00    	jne    f0102c6e <mem_init+0x14f4>
	assert(pp1->pp_ref == 0);
f0102326:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010232b:	0f 85 5f 09 00 00    	jne    f0102c90 <mem_init+0x1516>
	assert(pp2->pp_ref == 0);
f0102331:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102336:	0f 85 76 09 00 00    	jne    f0102cb2 <mem_init+0x1538>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010233c:	83 ec 0c             	sub    $0xc,%esp
f010233f:	6a 00                	push   $0x0
f0102341:	e8 d9 f0 ff ff       	call   f010141f <page_alloc>
f0102346:	83 c4 10             	add    $0x10,%esp
f0102349:	39 c7                	cmp    %eax,%edi
f010234b:	0f 85 83 09 00 00    	jne    f0102cd4 <mem_init+0x155a>
f0102351:	85 c0                	test   %eax,%eax
f0102353:	0f 84 7b 09 00 00    	je     f0102cd4 <mem_init+0x155a>

	// should be no free memory
	assert(!page_alloc(0));
f0102359:	83 ec 0c             	sub    $0xc,%esp
f010235c:	6a 00                	push   $0x0
f010235e:	e8 bc f0 ff ff       	call   f010141f <page_alloc>
f0102363:	83 c4 10             	add    $0x10,%esp
f0102366:	85 c0                	test   %eax,%eax
f0102368:	0f 85 88 09 00 00    	jne    f0102cf6 <mem_init+0x157c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010236e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102371:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0102377:	8b 08                	mov    (%eax),%ecx
f0102379:	8b 11                	mov    (%ecx),%edx
f010237b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102381:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0102387:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010238a:	2b 18                	sub    (%eax),%ebx
f010238c:	89 d8                	mov    %ebx,%eax
f010238e:	c1 f8 03             	sar    $0x3,%eax
f0102391:	c1 e0 0c             	shl    $0xc,%eax
f0102394:	39 c2                	cmp    %eax,%edx
f0102396:	0f 85 7c 09 00 00    	jne    f0102d18 <mem_init+0x159e>
	kern_pgdir[0] = 0;
f010239c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01023a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01023a5:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01023aa:	0f 85 8a 09 00 00    	jne    f0102d3a <mem_init+0x15c0>
	pp0->pp_ref = 0;
f01023b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01023b3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01023b9:	83 ec 0c             	sub    $0xc,%esp
f01023bc:	50                   	push   %eax
f01023bd:	e8 e5 f0 ff ff       	call   f01014a7 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023c2:	83 c4 0c             	add    $0xc,%esp
f01023c5:	6a 01                	push   $0x1
f01023c7:	68 00 10 40 00       	push   $0x401000
f01023cc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023cf:	c7 c3 cc a6 11 f0    	mov    $0xf011a6cc,%ebx
f01023d5:	ff 33                	pushl  (%ebx)
f01023d7:	e8 66 f1 ff ff       	call   f0101542 <pgdir_walk>
f01023dc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01023e2:	8b 1b                	mov    (%ebx),%ebx
f01023e4:	8b 53 04             	mov    0x4(%ebx),%edx
f01023e7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f01023ed:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01023f0:	c7 c1 c8 a6 11 f0    	mov    $0xf011a6c8,%ecx
f01023f6:	8b 09                	mov    (%ecx),%ecx
f01023f8:	89 d0                	mov    %edx,%eax
f01023fa:	c1 e8 0c             	shr    $0xc,%eax
f01023fd:	83 c4 10             	add    $0x10,%esp
f0102400:	39 c8                	cmp    %ecx,%eax
f0102402:	0f 83 54 09 00 00    	jae    f0102d5c <mem_init+0x15e2>
	assert(ptep == ptep1 + PTX(va));
f0102408:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010240e:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102411:	0f 85 61 09 00 00    	jne    f0102d78 <mem_init+0x15fe>
	kern_pgdir[PDX(va)] = 0;
f0102417:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f010241e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102421:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f0102427:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010242a:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0102430:	2b 18                	sub    (%eax),%ebx
f0102432:	89 d8                	mov    %ebx,%eax
f0102434:	c1 f8 03             	sar    $0x3,%eax
f0102437:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010243a:	89 c2                	mov    %eax,%edx
f010243c:	c1 ea 0c             	shr    $0xc,%edx
f010243f:	39 d1                	cmp    %edx,%ecx
f0102441:	0f 86 53 09 00 00    	jbe    f0102d9a <mem_init+0x1620>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102447:	83 ec 04             	sub    $0x4,%esp
f010244a:	68 00 10 00 00       	push   $0x1000
f010244f:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102454:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102459:	50                   	push   %eax
f010245a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010245d:	e8 16 1d 00 00       	call   f0104178 <memset>
	page_free(pp0);
f0102462:	83 c4 04             	add    $0x4,%esp
f0102465:	ff 75 d0             	pushl  -0x30(%ebp)
f0102468:	e8 3a f0 ff ff       	call   f01014a7 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010246d:	83 c4 0c             	add    $0xc,%esp
f0102470:	6a 01                	push   $0x1
f0102472:	6a 00                	push   $0x0
f0102474:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102477:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f010247d:	ff 30                	pushl  (%eax)
f010247f:	e8 be f0 ff ff       	call   f0101542 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102484:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010248a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010248d:	2b 10                	sub    (%eax),%edx
f010248f:	c1 fa 03             	sar    $0x3,%edx
f0102492:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102495:	89 d1                	mov    %edx,%ecx
f0102497:	c1 e9 0c             	shr    $0xc,%ecx
f010249a:	83 c4 10             	add    $0x10,%esp
f010249d:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f01024a3:	3b 08                	cmp    (%eax),%ecx
f01024a5:	0f 83 08 09 00 00    	jae    f0102db3 <mem_init+0x1639>
	return (void *)(pa + KERNBASE);
f01024ab:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01024b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01024b4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01024ba:	f6 00 01             	testb  $0x1,(%eax)
f01024bd:	0f 85 09 09 00 00    	jne    f0102dcc <mem_init+0x1652>
f01024c3:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f01024c6:	39 d0                	cmp    %edx,%eax
f01024c8:	75 f0                	jne    f01024ba <mem_init+0xd40>
	kern_pgdir[0] = 0;
f01024ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024cd:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f01024d3:	8b 00                	mov    (%eax),%eax
f01024d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01024db:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01024de:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01024e4:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01024e7:	89 93 b0 1f 00 00    	mov    %edx,0x1fb0(%ebx)

	// free the pages we took
	page_free(pp0);
f01024ed:	83 ec 0c             	sub    $0xc,%esp
f01024f0:	50                   	push   %eax
f01024f1:	e8 b1 ef ff ff       	call   f01014a7 <page_free>
	page_free(pp1);
f01024f6:	89 3c 24             	mov    %edi,(%esp)
f01024f9:	e8 a9 ef ff ff       	call   f01014a7 <page_free>
	page_free(pp2);
f01024fe:	89 34 24             	mov    %esi,(%esp)
f0102501:	e8 a1 ef ff ff       	call   f01014a7 <page_free>

	cprintf("check_page() succeeded!\n");
f0102506:	8d 83 64 cc fe ff    	lea    -0x1339c(%ebx),%eax
f010250c:	89 04 24             	mov    %eax,(%esp)
f010250f:	e8 fd 0f 00 00       	call   f0103511 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102514:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010251a:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010251c:	83 c4 10             	add    $0x10,%esp
f010251f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102524:	0f 86 c4 08 00 00    	jbe    f0102dee <mem_init+0x1674>
f010252a:	83 ec 08             	sub    $0x8,%esp
f010252d:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f010252f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102534:	50                   	push   %eax
f0102535:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010253a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010253f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102542:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0102548:	8b 00                	mov    (%eax),%eax
f010254a:	e8 9e f0 ff ff       	call   f01015ed <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010254f:	c7 c0 00 f0 10 f0    	mov    $0xf010f000,%eax
f0102555:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102558:	83 c4 10             	add    $0x10,%esp
f010255b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102560:	0f 86 a4 08 00 00    	jbe    f0102e0a <mem_init+0x1690>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102566:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102569:	c7 c3 cc a6 11 f0    	mov    $0xf011a6cc,%ebx
f010256f:	83 ec 08             	sub    $0x8,%esp
f0102572:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0102574:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102577:	05 00 00 00 10       	add    $0x10000000,%eax
f010257c:	50                   	push   %eax
f010257d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102582:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102587:	8b 03                	mov    (%ebx),%eax
f0102589:	e8 5f f0 ff ff       	call   f01015ed <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f010258e:	83 c4 08             	add    $0x8,%esp
f0102591:	6a 02                	push   $0x2
f0102593:	6a 00                	push   $0x0
f0102595:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010259a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010259f:	8b 03                	mov    (%ebx),%eax
f01025a1:	e8 47 f0 ff ff       	call   f01015ed <boot_map_region>
	pgdir = kern_pgdir;
f01025a6:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01025a8:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f01025ae:	8b 00                	mov    (%eax),%eax
f01025b0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01025b3:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01025ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01025bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025c2:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f01025c8:	8b 00                	mov    (%eax),%eax
f01025ca:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01025cd:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f01025d0:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f01025d6:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f01025d9:	bf 00 00 00 00       	mov    $0x0,%edi
f01025de:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f01025e1:	0f 86 84 08 00 00    	jbe    f0102e6b <mem_init+0x16f1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025e7:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f01025ed:	89 f0                	mov    %esi,%eax
f01025ef:	e8 09 e9 ff ff       	call   f0100efd <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01025f4:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01025fb:	0f 86 2a 08 00 00    	jbe    f0102e2b <mem_init+0x16b1>
f0102601:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102604:	39 c2                	cmp    %eax,%edx
f0102606:	0f 85 3d 08 00 00    	jne    f0102e49 <mem_init+0x16cf>
	for (i = 0; i < n; i += PGSIZE)
f010260c:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102612:	eb ca                	jmp    f01025de <mem_init+0xe64>
	assert(nfree == 0);
f0102614:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102617:	8d 83 8d cb fe ff    	lea    -0x13473(%ebx),%eax
f010261d:	50                   	push   %eax
f010261e:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102624:	50                   	push   %eax
f0102625:	68 bb 02 00 00       	push   $0x2bb
f010262a:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102630:	50                   	push   %eax
f0102631:	e8 ca da ff ff       	call   f0100100 <_panic>
	assert((pp0 = page_alloc(0)));
f0102636:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102639:	8d 83 9b ca fe ff    	lea    -0x13565(%ebx),%eax
f010263f:	50                   	push   %eax
f0102640:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102646:	50                   	push   %eax
f0102647:	68 17 03 00 00       	push   $0x317
f010264c:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102652:	50                   	push   %eax
f0102653:	e8 a8 da ff ff       	call   f0100100 <_panic>
	assert((pp1 = page_alloc(0)));
f0102658:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010265b:	8d 83 b1 ca fe ff    	lea    -0x1354f(%ebx),%eax
f0102661:	50                   	push   %eax
f0102662:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102668:	50                   	push   %eax
f0102669:	68 18 03 00 00       	push   $0x318
f010266e:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102674:	50                   	push   %eax
f0102675:	e8 86 da ff ff       	call   f0100100 <_panic>
	assert((pp2 = page_alloc(0)));
f010267a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010267d:	8d 83 c7 ca fe ff    	lea    -0x13539(%ebx),%eax
f0102683:	50                   	push   %eax
f0102684:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010268a:	50                   	push   %eax
f010268b:	68 19 03 00 00       	push   $0x319
f0102690:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102696:	50                   	push   %eax
f0102697:	e8 64 da ff ff       	call   f0100100 <_panic>
	assert(pp1 && pp1 != pp0);
f010269c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010269f:	8d 83 dd ca fe ff    	lea    -0x13523(%ebx),%eax
f01026a5:	50                   	push   %eax
f01026a6:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01026ac:	50                   	push   %eax
f01026ad:	68 1c 03 00 00       	push   $0x31c
f01026b2:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01026b8:	50                   	push   %eax
f01026b9:	e8 42 da ff ff       	call   f0100100 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01026be:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026c1:	8d 83 3c ce fe ff    	lea    -0x131c4(%ebx),%eax
f01026c7:	50                   	push   %eax
f01026c8:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01026ce:	50                   	push   %eax
f01026cf:	68 1d 03 00 00       	push   $0x31d
f01026d4:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01026da:	50                   	push   %eax
f01026db:	e8 20 da ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f01026e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026e3:	8d 83 46 cb fe ff    	lea    -0x134ba(%ebx),%eax
f01026e9:	50                   	push   %eax
f01026ea:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01026f0:	50                   	push   %eax
f01026f1:	68 24 03 00 00       	push   $0x324
f01026f6:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01026fc:	50                   	push   %eax
f01026fd:	e8 fe d9 ff ff       	call   f0100100 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102702:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102705:	8d 83 7c ce fe ff    	lea    -0x13184(%ebx),%eax
f010270b:	50                   	push   %eax
f010270c:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102712:	50                   	push   %eax
f0102713:	68 27 03 00 00       	push   $0x327
f0102718:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010271e:	50                   	push   %eax
f010271f:	e8 dc d9 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102724:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102727:	8d 83 b4 ce fe ff    	lea    -0x1314c(%ebx),%eax
f010272d:	50                   	push   %eax
f010272e:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102734:	50                   	push   %eax
f0102735:	68 2a 03 00 00       	push   $0x32a
f010273a:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102740:	50                   	push   %eax
f0102741:	e8 ba d9 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102746:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102749:	8d 83 e4 ce fe ff    	lea    -0x1311c(%ebx),%eax
f010274f:	50                   	push   %eax
f0102750:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102756:	50                   	push   %eax
f0102757:	68 2e 03 00 00       	push   $0x32e
f010275c:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102762:	50                   	push   %eax
f0102763:	e8 98 d9 ff ff       	call   f0100100 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102768:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010276b:	8d 83 14 cf fe ff    	lea    -0x130ec(%ebx),%eax
f0102771:	50                   	push   %eax
f0102772:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102778:	50                   	push   %eax
f0102779:	68 30 03 00 00       	push   $0x330
f010277e:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102784:	50                   	push   %eax
f0102785:	e8 76 d9 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010278a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010278d:	8d 83 3c cf fe ff    	lea    -0x130c4(%ebx),%eax
f0102793:	50                   	push   %eax
f0102794:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010279a:	50                   	push   %eax
f010279b:	68 31 03 00 00       	push   $0x331
f01027a0:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01027a6:	50                   	push   %eax
f01027a7:	e8 54 d9 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 1);
f01027ac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027af:	8d 83 98 cb fe ff    	lea    -0x13468(%ebx),%eax
f01027b5:	50                   	push   %eax
f01027b6:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01027bc:	50                   	push   %eax
f01027bd:	68 32 03 00 00       	push   $0x332
f01027c2:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01027c8:	50                   	push   %eax
f01027c9:	e8 32 d9 ff ff       	call   f0100100 <_panic>
	assert(pp0->pp_ref == 1);
f01027ce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027d1:	8d 83 a9 cb fe ff    	lea    -0x13457(%ebx),%eax
f01027d7:	50                   	push   %eax
f01027d8:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01027de:	50                   	push   %eax
f01027df:	68 33 03 00 00       	push   $0x333
f01027e4:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01027ea:	50                   	push   %eax
f01027eb:	e8 10 d9 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01027f0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027f3:	8d 83 6c cf fe ff    	lea    -0x13094(%ebx),%eax
f01027f9:	50                   	push   %eax
f01027fa:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102800:	50                   	push   %eax
f0102801:	68 36 03 00 00       	push   $0x336
f0102806:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010280c:	50                   	push   %eax
f010280d:	e8 ee d8 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102812:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102815:	8d 83 a8 cf fe ff    	lea    -0x13058(%ebx),%eax
f010281b:	50                   	push   %eax
f010281c:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102822:	50                   	push   %eax
f0102823:	68 37 03 00 00       	push   $0x337
f0102828:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010282e:	50                   	push   %eax
f010282f:	e8 cc d8 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 1);
f0102834:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102837:	8d 83 ba cb fe ff    	lea    -0x13446(%ebx),%eax
f010283d:	50                   	push   %eax
f010283e:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102844:	50                   	push   %eax
f0102845:	68 38 03 00 00       	push   $0x338
f010284a:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102850:	50                   	push   %eax
f0102851:	e8 aa d8 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f0102856:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102859:	8d 83 46 cb fe ff    	lea    -0x134ba(%ebx),%eax
f010285f:	50                   	push   %eax
f0102860:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102866:	50                   	push   %eax
f0102867:	68 3b 03 00 00       	push   $0x33b
f010286c:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102872:	50                   	push   %eax
f0102873:	e8 88 d8 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102878:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010287b:	8d 83 6c cf fe ff    	lea    -0x13094(%ebx),%eax
f0102881:	50                   	push   %eax
f0102882:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102888:	50                   	push   %eax
f0102889:	68 3e 03 00 00       	push   $0x33e
f010288e:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102894:	50                   	push   %eax
f0102895:	e8 66 d8 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010289a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010289d:	8d 83 a8 cf fe ff    	lea    -0x13058(%ebx),%eax
f01028a3:	50                   	push   %eax
f01028a4:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01028aa:	50                   	push   %eax
f01028ab:	68 3f 03 00 00       	push   $0x33f
f01028b0:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01028b6:	50                   	push   %eax
f01028b7:	e8 44 d8 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 1);
f01028bc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028bf:	8d 83 ba cb fe ff    	lea    -0x13446(%ebx),%eax
f01028c5:	50                   	push   %eax
f01028c6:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01028cc:	50                   	push   %eax
f01028cd:	68 40 03 00 00       	push   $0x340
f01028d2:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01028d8:	50                   	push   %eax
f01028d9:	e8 22 d8 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f01028de:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028e1:	8d 83 46 cb fe ff    	lea    -0x134ba(%ebx),%eax
f01028e7:	50                   	push   %eax
f01028e8:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01028ee:	50                   	push   %eax
f01028ef:	68 44 03 00 00       	push   $0x344
f01028f4:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01028fa:	50                   	push   %eax
f01028fb:	e8 00 d8 ff ff       	call   f0100100 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102900:	50                   	push   %eax
f0102901:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102904:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f010290a:	50                   	push   %eax
f010290b:	68 47 03 00 00       	push   $0x347
f0102910:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102916:	50                   	push   %eax
f0102917:	e8 e4 d7 ff ff       	call   f0100100 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010291c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010291f:	8d 83 d8 cf fe ff    	lea    -0x13028(%ebx),%eax
f0102925:	50                   	push   %eax
f0102926:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010292c:	50                   	push   %eax
f010292d:	68 48 03 00 00       	push   $0x348
f0102932:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102938:	50                   	push   %eax
f0102939:	e8 c2 d7 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010293e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102941:	8d 83 18 d0 fe ff    	lea    -0x12fe8(%ebx),%eax
f0102947:	50                   	push   %eax
f0102948:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010294e:	50                   	push   %eax
f010294f:	68 4b 03 00 00       	push   $0x34b
f0102954:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010295a:	50                   	push   %eax
f010295b:	e8 a0 d7 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102960:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102963:	8d 83 a8 cf fe ff    	lea    -0x13058(%ebx),%eax
f0102969:	50                   	push   %eax
f010296a:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102970:	50                   	push   %eax
f0102971:	68 4c 03 00 00       	push   $0x34c
f0102976:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010297c:	50                   	push   %eax
f010297d:	e8 7e d7 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 1);
f0102982:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102985:	8d 83 ba cb fe ff    	lea    -0x13446(%ebx),%eax
f010298b:	50                   	push   %eax
f010298c:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102992:	50                   	push   %eax
f0102993:	68 4d 03 00 00       	push   $0x34d
f0102998:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010299e:	50                   	push   %eax
f010299f:	e8 5c d7 ff ff       	call   f0100100 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01029a4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029a7:	8d 83 58 d0 fe ff    	lea    -0x12fa8(%ebx),%eax
f01029ad:	50                   	push   %eax
f01029ae:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01029b4:	50                   	push   %eax
f01029b5:	68 4e 03 00 00       	push   $0x34e
f01029ba:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01029c0:	50                   	push   %eax
f01029c1:	e8 3a d7 ff ff       	call   f0100100 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01029c6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029c9:	8d 83 cb cb fe ff    	lea    -0x13435(%ebx),%eax
f01029cf:	50                   	push   %eax
f01029d0:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01029d6:	50                   	push   %eax
f01029d7:	68 4f 03 00 00       	push   $0x34f
f01029dc:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01029e2:	50                   	push   %eax
f01029e3:	e8 18 d7 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01029e8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029eb:	8d 83 6c cf fe ff    	lea    -0x13094(%ebx),%eax
f01029f1:	50                   	push   %eax
f01029f2:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01029f8:	50                   	push   %eax
f01029f9:	68 52 03 00 00       	push   $0x352
f01029fe:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102a04:	50                   	push   %eax
f0102a05:	e8 f6 d6 ff ff       	call   f0100100 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102a0a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a0d:	8d 83 8c d0 fe ff    	lea    -0x12f74(%ebx),%eax
f0102a13:	50                   	push   %eax
f0102a14:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102a1a:	50                   	push   %eax
f0102a1b:	68 53 03 00 00       	push   $0x353
f0102a20:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102a26:	50                   	push   %eax
f0102a27:	e8 d4 d6 ff ff       	call   f0100100 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a2c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a2f:	8d 83 c0 d0 fe ff    	lea    -0x12f40(%ebx),%eax
f0102a35:	50                   	push   %eax
f0102a36:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102a3c:	50                   	push   %eax
f0102a3d:	68 54 03 00 00       	push   $0x354
f0102a42:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102a48:	50                   	push   %eax
f0102a49:	e8 b2 d6 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102a4e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a51:	8d 83 f8 d0 fe ff    	lea    -0x12f08(%ebx),%eax
f0102a57:	50                   	push   %eax
f0102a58:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102a5e:	50                   	push   %eax
f0102a5f:	68 57 03 00 00       	push   $0x357
f0102a64:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102a6a:	50                   	push   %eax
f0102a6b:	e8 90 d6 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102a70:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a73:	8d 83 30 d1 fe ff    	lea    -0x12ed0(%ebx),%eax
f0102a79:	50                   	push   %eax
f0102a7a:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102a80:	50                   	push   %eax
f0102a81:	68 5a 03 00 00       	push   $0x35a
f0102a86:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102a8c:	50                   	push   %eax
f0102a8d:	e8 6e d6 ff ff       	call   f0100100 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102a92:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a95:	8d 83 c0 d0 fe ff    	lea    -0x12f40(%ebx),%eax
f0102a9b:	50                   	push   %eax
f0102a9c:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102aa2:	50                   	push   %eax
f0102aa3:	68 5b 03 00 00       	push   $0x35b
f0102aa8:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102aae:	50                   	push   %eax
f0102aaf:	e8 4c d6 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102ab4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ab7:	8d 83 6c d1 fe ff    	lea    -0x12e94(%ebx),%eax
f0102abd:	50                   	push   %eax
f0102abe:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102ac4:	50                   	push   %eax
f0102ac5:	68 5e 03 00 00       	push   $0x35e
f0102aca:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102ad0:	50                   	push   %eax
f0102ad1:	e8 2a d6 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102ad6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ad9:	8d 83 98 d1 fe ff    	lea    -0x12e68(%ebx),%eax
f0102adf:	50                   	push   %eax
f0102ae0:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102ae6:	50                   	push   %eax
f0102ae7:	68 5f 03 00 00       	push   $0x35f
f0102aec:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102af2:	50                   	push   %eax
f0102af3:	e8 08 d6 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 2);
f0102af8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102afb:	8d 83 e1 cb fe ff    	lea    -0x1341f(%ebx),%eax
f0102b01:	50                   	push   %eax
f0102b02:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102b08:	50                   	push   %eax
f0102b09:	68 61 03 00 00       	push   $0x361
f0102b0e:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102b14:	50                   	push   %eax
f0102b15:	e8 e6 d5 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 0);
f0102b1a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b1d:	8d 83 f2 cb fe ff    	lea    -0x1340e(%ebx),%eax
f0102b23:	50                   	push   %eax
f0102b24:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102b2a:	50                   	push   %eax
f0102b2b:	68 62 03 00 00       	push   $0x362
f0102b30:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102b36:	50                   	push   %eax
f0102b37:	e8 c4 d5 ff ff       	call   f0100100 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102b3c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b3f:	8d 83 c8 d1 fe ff    	lea    -0x12e38(%ebx),%eax
f0102b45:	50                   	push   %eax
f0102b46:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102b4c:	50                   	push   %eax
f0102b4d:	68 65 03 00 00       	push   $0x365
f0102b52:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102b58:	50                   	push   %eax
f0102b59:	e8 a2 d5 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b5e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b61:	8d 83 ec d1 fe ff    	lea    -0x12e14(%ebx),%eax
f0102b67:	50                   	push   %eax
f0102b68:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102b6e:	50                   	push   %eax
f0102b6f:	68 69 03 00 00       	push   $0x369
f0102b74:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102b7a:	50                   	push   %eax
f0102b7b:	e8 80 d5 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102b80:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b83:	8d 83 98 d1 fe ff    	lea    -0x12e68(%ebx),%eax
f0102b89:	50                   	push   %eax
f0102b8a:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102b90:	50                   	push   %eax
f0102b91:	68 6a 03 00 00       	push   $0x36a
f0102b96:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102b9c:	50                   	push   %eax
f0102b9d:	e8 5e d5 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 1);
f0102ba2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ba5:	8d 83 98 cb fe ff    	lea    -0x13468(%ebx),%eax
f0102bab:	50                   	push   %eax
f0102bac:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102bb2:	50                   	push   %eax
f0102bb3:	68 6b 03 00 00       	push   $0x36b
f0102bb8:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102bbe:	50                   	push   %eax
f0102bbf:	e8 3c d5 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 0);
f0102bc4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bc7:	8d 83 f2 cb fe ff    	lea    -0x1340e(%ebx),%eax
f0102bcd:	50                   	push   %eax
f0102bce:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102bd4:	50                   	push   %eax
f0102bd5:	68 6c 03 00 00       	push   $0x36c
f0102bda:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102be0:	50                   	push   %eax
f0102be1:	e8 1a d5 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102be6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102be9:	8d 83 10 d2 fe ff    	lea    -0x12df0(%ebx),%eax
f0102bef:	50                   	push   %eax
f0102bf0:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102bf6:	50                   	push   %eax
f0102bf7:	68 6f 03 00 00       	push   $0x36f
f0102bfc:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102c02:	50                   	push   %eax
f0102c03:	e8 f8 d4 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref);
f0102c08:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c0b:	8d 83 03 cc fe ff    	lea    -0x133fd(%ebx),%eax
f0102c11:	50                   	push   %eax
f0102c12:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102c18:	50                   	push   %eax
f0102c19:	68 70 03 00 00       	push   $0x370
f0102c1e:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102c24:	50                   	push   %eax
f0102c25:	e8 d6 d4 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_link == NULL);
f0102c2a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c2d:	8d 83 0f cc fe ff    	lea    -0x133f1(%ebx),%eax
f0102c33:	50                   	push   %eax
f0102c34:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102c3a:	50                   	push   %eax
f0102c3b:	68 71 03 00 00       	push   $0x371
f0102c40:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102c46:	50                   	push   %eax
f0102c47:	e8 b4 d4 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102c4c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c4f:	8d 83 ec d1 fe ff    	lea    -0x12e14(%ebx),%eax
f0102c55:	50                   	push   %eax
f0102c56:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102c5c:	50                   	push   %eax
f0102c5d:	68 75 03 00 00       	push   $0x375
f0102c62:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102c68:	50                   	push   %eax
f0102c69:	e8 92 d4 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102c6e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c71:	8d 83 48 d2 fe ff    	lea    -0x12db8(%ebx),%eax
f0102c77:	50                   	push   %eax
f0102c78:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102c7e:	50                   	push   %eax
f0102c7f:	68 76 03 00 00       	push   $0x376
f0102c84:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102c8a:	50                   	push   %eax
f0102c8b:	e8 70 d4 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 0);
f0102c90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c93:	8d 83 24 cc fe ff    	lea    -0x133dc(%ebx),%eax
f0102c99:	50                   	push   %eax
f0102c9a:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102ca0:	50                   	push   %eax
f0102ca1:	68 77 03 00 00       	push   $0x377
f0102ca6:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102cac:	50                   	push   %eax
f0102cad:	e8 4e d4 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 0);
f0102cb2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cb5:	8d 83 f2 cb fe ff    	lea    -0x1340e(%ebx),%eax
f0102cbb:	50                   	push   %eax
f0102cbc:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102cc2:	50                   	push   %eax
f0102cc3:	68 78 03 00 00       	push   $0x378
f0102cc8:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102cce:	50                   	push   %eax
f0102ccf:	e8 2c d4 ff ff       	call   f0100100 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102cd4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cd7:	8d 83 70 d2 fe ff    	lea    -0x12d90(%ebx),%eax
f0102cdd:	50                   	push   %eax
f0102cde:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102ce4:	50                   	push   %eax
f0102ce5:	68 7b 03 00 00       	push   $0x37b
f0102cea:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102cf0:	50                   	push   %eax
f0102cf1:	e8 0a d4 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f0102cf6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cf9:	8d 83 46 cb fe ff    	lea    -0x134ba(%ebx),%eax
f0102cff:	50                   	push   %eax
f0102d00:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102d06:	50                   	push   %eax
f0102d07:	68 7e 03 00 00       	push   $0x37e
f0102d0c:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102d12:	50                   	push   %eax
f0102d13:	e8 e8 d3 ff ff       	call   f0100100 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d18:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d1b:	8d 83 14 cf fe ff    	lea    -0x130ec(%ebx),%eax
f0102d21:	50                   	push   %eax
f0102d22:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102d28:	50                   	push   %eax
f0102d29:	68 81 03 00 00       	push   $0x381
f0102d2e:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102d34:	50                   	push   %eax
f0102d35:	e8 c6 d3 ff ff       	call   f0100100 <_panic>
	assert(pp0->pp_ref == 1);
f0102d3a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d3d:	8d 83 a9 cb fe ff    	lea    -0x13457(%ebx),%eax
f0102d43:	50                   	push   %eax
f0102d44:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102d4a:	50                   	push   %eax
f0102d4b:	68 83 03 00 00       	push   $0x383
f0102d50:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102d56:	50                   	push   %eax
f0102d57:	e8 a4 d3 ff ff       	call   f0100100 <_panic>
f0102d5c:	52                   	push   %edx
f0102d5d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d60:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f0102d66:	50                   	push   %eax
f0102d67:	68 8a 03 00 00       	push   $0x38a
f0102d6c:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102d72:	50                   	push   %eax
f0102d73:	e8 88 d3 ff ff       	call   f0100100 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102d78:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d7b:	8d 83 35 cc fe ff    	lea    -0x133cb(%ebx),%eax
f0102d81:	50                   	push   %eax
f0102d82:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102d88:	50                   	push   %eax
f0102d89:	68 8b 03 00 00       	push   $0x38b
f0102d8e:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102d94:	50                   	push   %eax
f0102d95:	e8 66 d3 ff ff       	call   f0100100 <_panic>
f0102d9a:	50                   	push   %eax
f0102d9b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d9e:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f0102da4:	50                   	push   %eax
f0102da5:	6a 52                	push   $0x52
f0102da7:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f0102dad:	50                   	push   %eax
f0102dae:	e8 4d d3 ff ff       	call   f0100100 <_panic>
f0102db3:	52                   	push   %edx
f0102db4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102db7:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f0102dbd:	50                   	push   %eax
f0102dbe:	6a 52                	push   $0x52
f0102dc0:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f0102dc6:	50                   	push   %eax
f0102dc7:	e8 34 d3 ff ff       	call   f0100100 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102dcc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dcf:	8d 83 4d cc fe ff    	lea    -0x133b3(%ebx),%eax
f0102dd5:	50                   	push   %eax
f0102dd6:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102ddc:	50                   	push   %eax
f0102ddd:	68 95 03 00 00       	push   $0x395
f0102de2:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102de8:	50                   	push   %eax
f0102de9:	e8 12 d3 ff ff       	call   f0100100 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dee:	50                   	push   %eax
f0102def:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102df2:	8d 83 18 ce fe ff    	lea    -0x131e8(%ebx),%eax
f0102df8:	50                   	push   %eax
f0102df9:	68 b5 00 00 00       	push   $0xb5
f0102dfe:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102e04:	50                   	push   %eax
f0102e05:	e8 f6 d2 ff ff       	call   f0100100 <_panic>
f0102e0a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e0d:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f0102e13:	8d 83 18 ce fe ff    	lea    -0x131e8(%ebx),%eax
f0102e19:	50                   	push   %eax
f0102e1a:	68 c1 00 00 00       	push   $0xc1
f0102e1f:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102e25:	50                   	push   %eax
f0102e26:	e8 d5 d2 ff ff       	call   f0100100 <_panic>
f0102e2b:	ff 75 c0             	pushl  -0x40(%ebp)
f0102e2e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e31:	8d 83 18 ce fe ff    	lea    -0x131e8(%ebx),%eax
f0102e37:	50                   	push   %eax
f0102e38:	68 d5 02 00 00       	push   $0x2d5
f0102e3d:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102e43:	50                   	push   %eax
f0102e44:	e8 b7 d2 ff ff       	call   f0100100 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102e49:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e4c:	8d 83 94 d2 fe ff    	lea    -0x12d6c(%ebx),%eax
f0102e52:	50                   	push   %eax
f0102e53:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102e59:	50                   	push   %eax
f0102e5a:	68 d5 02 00 00       	push   $0x2d5
f0102e5f:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102e65:	50                   	push   %eax
f0102e66:	e8 95 d2 ff ff       	call   f0100100 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e6b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102e6e:	c1 e7 0c             	shl    $0xc,%edi
f0102e71:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e76:	eb 17                	jmp    f0102e8f <mem_init+0x1715>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e78:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102e7e:	89 f0                	mov    %esi,%eax
f0102e80:	e8 78 e0 ff ff       	call   f0100efd <check_va2pa>
f0102e85:	39 c3                	cmp    %eax,%ebx
f0102e87:	75 51                	jne    f0102eda <mem_init+0x1760>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e89:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e8f:	39 fb                	cmp    %edi,%ebx
f0102e91:	72 e5                	jb     f0102e78 <mem_init+0x16fe>
f0102e93:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102e98:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102e9b:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f0102ea1:	89 da                	mov    %ebx,%edx
f0102ea3:	89 f0                	mov    %esi,%eax
f0102ea5:	e8 53 e0 ff ff       	call   f0100efd <check_va2pa>
f0102eaa:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102ead:	39 c2                	cmp    %eax,%edx
f0102eaf:	75 4b                	jne    f0102efc <mem_init+0x1782>
f0102eb1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102eb7:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102ebd:	75 e2                	jne    f0102ea1 <mem_init+0x1727>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102ebf:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102ec4:	89 f0                	mov    %esi,%eax
f0102ec6:	e8 32 e0 ff ff       	call   f0100efd <check_va2pa>
f0102ecb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ece:	75 4e                	jne    f0102f1e <mem_init+0x17a4>
	for (i = 0; i < NPDENTRIES; i++) {
f0102ed0:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ed5:	e9 8f 00 00 00       	jmp    f0102f69 <mem_init+0x17ef>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102eda:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102edd:	8d 83 c8 d2 fe ff    	lea    -0x12d38(%ebx),%eax
f0102ee3:	50                   	push   %eax
f0102ee4:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102eea:	50                   	push   %eax
f0102eeb:	68 db 02 00 00       	push   $0x2db
f0102ef0:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102ef6:	50                   	push   %eax
f0102ef7:	e8 04 d2 ff ff       	call   f0100100 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102efc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eff:	8d 83 f0 d2 fe ff    	lea    -0x12d10(%ebx),%eax
f0102f05:	50                   	push   %eax
f0102f06:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102f0c:	50                   	push   %eax
f0102f0d:	68 df 02 00 00       	push   $0x2df
f0102f12:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102f18:	50                   	push   %eax
f0102f19:	e8 e2 d1 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102f1e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f21:	8d 83 38 d3 fe ff    	lea    -0x12cc8(%ebx),%eax
f0102f27:	50                   	push   %eax
f0102f28:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102f2e:	50                   	push   %eax
f0102f2f:	68 e0 02 00 00       	push   $0x2e0
f0102f34:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102f3a:	50                   	push   %eax
f0102f3b:	e8 c0 d1 ff ff       	call   f0100100 <_panic>
			assert(pgdir[i] & PTE_P);
f0102f40:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102f44:	74 52                	je     f0102f98 <mem_init+0x181e>
	for (i = 0; i < NPDENTRIES; i++) {
f0102f46:	83 c0 01             	add    $0x1,%eax
f0102f49:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102f4e:	0f 87 bb 00 00 00    	ja     f010300f <mem_init+0x1895>
		switch (i) {
f0102f54:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102f59:	72 0e                	jb     f0102f69 <mem_init+0x17ef>
f0102f5b:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102f60:	76 de                	jbe    f0102f40 <mem_init+0x17c6>
f0102f62:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102f67:	74 d7                	je     f0102f40 <mem_init+0x17c6>
			if (i >= PDX(KERNBASE)) {
f0102f69:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102f6e:	77 4a                	ja     f0102fba <mem_init+0x1840>
				assert(pgdir[i] == 0);
f0102f70:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102f74:	74 d0                	je     f0102f46 <mem_init+0x17cc>
f0102f76:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f79:	8d 83 9f cc fe ff    	lea    -0x13361(%ebx),%eax
f0102f7f:	50                   	push   %eax
f0102f80:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102f86:	50                   	push   %eax
f0102f87:	68 ef 02 00 00       	push   $0x2ef
f0102f8c:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102f92:	50                   	push   %eax
f0102f93:	e8 68 d1 ff ff       	call   f0100100 <_panic>
			assert(pgdir[i] & PTE_P);
f0102f98:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f9b:	8d 83 7d cc fe ff    	lea    -0x13383(%ebx),%eax
f0102fa1:	50                   	push   %eax
f0102fa2:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102fa8:	50                   	push   %eax
f0102fa9:	68 e8 02 00 00       	push   $0x2e8
f0102fae:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102fb4:	50                   	push   %eax
f0102fb5:	e8 46 d1 ff ff       	call   f0100100 <_panic>
				assert(pgdir[i] & PTE_P);
f0102fba:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102fbd:	f6 c2 01             	test   $0x1,%dl
f0102fc0:	74 2b                	je     f0102fed <mem_init+0x1873>
				assert(pgdir[i] & PTE_W);
f0102fc2:	f6 c2 02             	test   $0x2,%dl
f0102fc5:	0f 85 7b ff ff ff    	jne    f0102f46 <mem_init+0x17cc>
f0102fcb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fce:	8d 83 8e cc fe ff    	lea    -0x13372(%ebx),%eax
f0102fd4:	50                   	push   %eax
f0102fd5:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102fdb:	50                   	push   %eax
f0102fdc:	68 ed 02 00 00       	push   $0x2ed
f0102fe1:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0102fe7:	50                   	push   %eax
f0102fe8:	e8 13 d1 ff ff       	call   f0100100 <_panic>
				assert(pgdir[i] & PTE_P);
f0102fed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ff0:	8d 83 7d cc fe ff    	lea    -0x13383(%ebx),%eax
f0102ff6:	50                   	push   %eax
f0102ff7:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0102ffd:	50                   	push   %eax
f0102ffe:	68 ec 02 00 00       	push   $0x2ec
f0103003:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0103009:	50                   	push   %eax
f010300a:	e8 f1 d0 ff ff       	call   f0100100 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f010300f:	83 ec 0c             	sub    $0xc,%esp
f0103012:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103015:	8d 87 68 d3 fe ff    	lea    -0x12c98(%edi),%eax
f010301b:	50                   	push   %eax
f010301c:	89 fb                	mov    %edi,%ebx
f010301e:	e8 ee 04 00 00       	call   f0103511 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103023:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0103029:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010302b:	83 c4 10             	add    $0x10,%esp
f010302e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103033:	0f 86 44 02 00 00    	jbe    f010327d <mem_init+0x1b03>
	return (physaddr_t)kva - KERNBASE;
f0103039:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010303e:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103041:	b8 00 00 00 00       	mov    $0x0,%eax
f0103046:	e8 2f df ff ff       	call   f0100f7a <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010304b:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010304e:	83 e0 f3             	and    $0xfffffff3,%eax
f0103051:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0103056:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103059:	83 ec 0c             	sub    $0xc,%esp
f010305c:	6a 00                	push   $0x0
f010305e:	e8 bc e3 ff ff       	call   f010141f <page_alloc>
f0103063:	89 c6                	mov    %eax,%esi
f0103065:	83 c4 10             	add    $0x10,%esp
f0103068:	85 c0                	test   %eax,%eax
f010306a:	0f 84 29 02 00 00    	je     f0103299 <mem_init+0x1b1f>
	assert((pp1 = page_alloc(0)));
f0103070:	83 ec 0c             	sub    $0xc,%esp
f0103073:	6a 00                	push   $0x0
f0103075:	e8 a5 e3 ff ff       	call   f010141f <page_alloc>
f010307a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010307d:	83 c4 10             	add    $0x10,%esp
f0103080:	85 c0                	test   %eax,%eax
f0103082:	0f 84 33 02 00 00    	je     f01032bb <mem_init+0x1b41>
	assert((pp2 = page_alloc(0)));
f0103088:	83 ec 0c             	sub    $0xc,%esp
f010308b:	6a 00                	push   $0x0
f010308d:	e8 8d e3 ff ff       	call   f010141f <page_alloc>
f0103092:	89 c7                	mov    %eax,%edi
f0103094:	83 c4 10             	add    $0x10,%esp
f0103097:	85 c0                	test   %eax,%eax
f0103099:	0f 84 3e 02 00 00    	je     f01032dd <mem_init+0x1b63>
	page_free(pp0);
f010309f:	83 ec 0c             	sub    $0xc,%esp
f01030a2:	56                   	push   %esi
f01030a3:	e8 ff e3 ff ff       	call   f01014a7 <page_free>
	return (pp - pages) << PGSHIFT;
f01030a8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030ab:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f01030b1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01030b4:	2b 08                	sub    (%eax),%ecx
f01030b6:	89 c8                	mov    %ecx,%eax
f01030b8:	c1 f8 03             	sar    $0x3,%eax
f01030bb:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01030be:	89 c1                	mov    %eax,%ecx
f01030c0:	c1 e9 0c             	shr    $0xc,%ecx
f01030c3:	83 c4 10             	add    $0x10,%esp
f01030c6:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f01030cc:	3b 0a                	cmp    (%edx),%ecx
f01030ce:	0f 83 2b 02 00 00    	jae    f01032ff <mem_init+0x1b85>
	memset(page2kva(pp1), 1, PGSIZE);
f01030d4:	83 ec 04             	sub    $0x4,%esp
f01030d7:	68 00 10 00 00       	push   $0x1000
f01030dc:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01030de:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01030e3:	50                   	push   %eax
f01030e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030e7:	e8 8c 10 00 00       	call   f0104178 <memset>
	return (pp - pages) << PGSHIFT;
f01030ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030ef:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f01030f5:	89 f9                	mov    %edi,%ecx
f01030f7:	2b 08                	sub    (%eax),%ecx
f01030f9:	89 c8                	mov    %ecx,%eax
f01030fb:	c1 f8 03             	sar    $0x3,%eax
f01030fe:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103101:	89 c1                	mov    %eax,%ecx
f0103103:	c1 e9 0c             	shr    $0xc,%ecx
f0103106:	83 c4 10             	add    $0x10,%esp
f0103109:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f010310f:	3b 0a                	cmp    (%edx),%ecx
f0103111:	0f 83 fe 01 00 00    	jae    f0103315 <mem_init+0x1b9b>
	memset(page2kva(pp2), 2, PGSIZE);
f0103117:	83 ec 04             	sub    $0x4,%esp
f010311a:	68 00 10 00 00       	push   $0x1000
f010311f:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0103121:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103126:	50                   	push   %eax
f0103127:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010312a:	e8 49 10 00 00       	call   f0104178 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010312f:	6a 02                	push   $0x2
f0103131:	68 00 10 00 00       	push   $0x1000
f0103136:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103139:	53                   	push   %ebx
f010313a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010313d:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0103143:	ff 30                	pushl  (%eax)
f0103145:	e8 a4 e5 ff ff       	call   f01016ee <page_insert>
	assert(pp1->pp_ref == 1);
f010314a:	83 c4 20             	add    $0x20,%esp
f010314d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103152:	0f 85 d3 01 00 00    	jne    f010332b <mem_init+0x1bb1>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103158:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010315f:	01 01 01 
f0103162:	0f 85 e5 01 00 00    	jne    f010334d <mem_init+0x1bd3>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103168:	6a 02                	push   $0x2
f010316a:	68 00 10 00 00       	push   $0x1000
f010316f:	57                   	push   %edi
f0103170:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103173:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0103179:	ff 30                	pushl  (%eax)
f010317b:	e8 6e e5 ff ff       	call   f01016ee <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103180:	83 c4 10             	add    $0x10,%esp
f0103183:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010318a:	02 02 02 
f010318d:	0f 85 dc 01 00 00    	jne    f010336f <mem_init+0x1bf5>
	assert(pp2->pp_ref == 1);
f0103193:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103198:	0f 85 f3 01 00 00    	jne    f0103391 <mem_init+0x1c17>
	assert(pp1->pp_ref == 0);
f010319e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01031a1:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01031a6:	0f 85 07 02 00 00    	jne    f01033b3 <mem_init+0x1c39>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01031ac:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01031b3:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01031b6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031b9:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f01031bf:	89 f9                	mov    %edi,%ecx
f01031c1:	2b 08                	sub    (%eax),%ecx
f01031c3:	89 c8                	mov    %ecx,%eax
f01031c5:	c1 f8 03             	sar    $0x3,%eax
f01031c8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01031cb:	89 c1                	mov    %eax,%ecx
f01031cd:	c1 e9 0c             	shr    $0xc,%ecx
f01031d0:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f01031d6:	3b 0a                	cmp    (%edx),%ecx
f01031d8:	0f 83 f7 01 00 00    	jae    f01033d5 <mem_init+0x1c5b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01031de:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01031e5:	03 03 03 
f01031e8:	0f 85 fd 01 00 00    	jne    f01033eb <mem_init+0x1c71>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01031ee:	83 ec 08             	sub    $0x8,%esp
f01031f1:	68 00 10 00 00       	push   $0x1000
f01031f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01031f9:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f01031ff:	ff 30                	pushl  (%eax)
f0103201:	e8 a6 e4 ff ff       	call   f01016ac <page_remove>
	assert(pp2->pp_ref == 0);
f0103206:	83 c4 10             	add    $0x10,%esp
f0103209:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010320e:	0f 85 f9 01 00 00    	jne    f010340d <mem_init+0x1c93>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103214:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103217:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f010321d:	8b 08                	mov    (%eax),%ecx
f010321f:	8b 11                	mov    (%ecx),%edx
f0103221:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0103227:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010322d:	89 f7                	mov    %esi,%edi
f010322f:	2b 38                	sub    (%eax),%edi
f0103231:	89 f8                	mov    %edi,%eax
f0103233:	c1 f8 03             	sar    $0x3,%eax
f0103236:	c1 e0 0c             	shl    $0xc,%eax
f0103239:	39 c2                	cmp    %eax,%edx
f010323b:	0f 85 ee 01 00 00    	jne    f010342f <mem_init+0x1cb5>
	kern_pgdir[0] = 0;
f0103241:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0103247:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010324c:	0f 85 ff 01 00 00    	jne    f0103451 <mem_init+0x1cd7>
	pp0->pp_ref = 0;
f0103252:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103258:	83 ec 0c             	sub    $0xc,%esp
f010325b:	56                   	push   %esi
f010325c:	e8 46 e2 ff ff       	call   f01014a7 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103261:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103264:	8d 83 fc d3 fe ff    	lea    -0x12c04(%ebx),%eax
f010326a:	89 04 24             	mov    %eax,(%esp)
f010326d:	e8 9f 02 00 00       	call   f0103511 <cprintf>
}
f0103272:	83 c4 10             	add    $0x10,%esp
f0103275:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103278:	5b                   	pop    %ebx
f0103279:	5e                   	pop    %esi
f010327a:	5f                   	pop    %edi
f010327b:	5d                   	pop    %ebp
f010327c:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010327d:	50                   	push   %eax
f010327e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103281:	8d 83 18 ce fe ff    	lea    -0x131e8(%ebx),%eax
f0103287:	50                   	push   %eax
f0103288:	68 d5 00 00 00       	push   $0xd5
f010328d:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0103293:	50                   	push   %eax
f0103294:	e8 67 ce ff ff       	call   f0100100 <_panic>
	assert((pp0 = page_alloc(0)));
f0103299:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010329c:	8d 83 9b ca fe ff    	lea    -0x13565(%ebx),%eax
f01032a2:	50                   	push   %eax
f01032a3:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01032a9:	50                   	push   %eax
f01032aa:	68 b0 03 00 00       	push   $0x3b0
f01032af:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01032b5:	50                   	push   %eax
f01032b6:	e8 45 ce ff ff       	call   f0100100 <_panic>
	assert((pp1 = page_alloc(0)));
f01032bb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032be:	8d 83 b1 ca fe ff    	lea    -0x1354f(%ebx),%eax
f01032c4:	50                   	push   %eax
f01032c5:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01032cb:	50                   	push   %eax
f01032cc:	68 b1 03 00 00       	push   $0x3b1
f01032d1:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01032d7:	50                   	push   %eax
f01032d8:	e8 23 ce ff ff       	call   f0100100 <_panic>
	assert((pp2 = page_alloc(0)));
f01032dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032e0:	8d 83 c7 ca fe ff    	lea    -0x13539(%ebx),%eax
f01032e6:	50                   	push   %eax
f01032e7:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01032ed:	50                   	push   %eax
f01032ee:	68 b2 03 00 00       	push   $0x3b2
f01032f3:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01032f9:	50                   	push   %eax
f01032fa:	e8 01 ce ff ff       	call   f0100100 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032ff:	50                   	push   %eax
f0103300:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f0103306:	50                   	push   %eax
f0103307:	6a 52                	push   $0x52
f0103309:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f010330f:	50                   	push   %eax
f0103310:	e8 eb cd ff ff       	call   f0100100 <_panic>
f0103315:	50                   	push   %eax
f0103316:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f010331c:	50                   	push   %eax
f010331d:	6a 52                	push   $0x52
f010331f:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f0103325:	50                   	push   %eax
f0103326:	e8 d5 cd ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 1);
f010332b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010332e:	8d 83 98 cb fe ff    	lea    -0x13468(%ebx),%eax
f0103334:	50                   	push   %eax
f0103335:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010333b:	50                   	push   %eax
f010333c:	68 b7 03 00 00       	push   $0x3b7
f0103341:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0103347:	50                   	push   %eax
f0103348:	e8 b3 cd ff ff       	call   f0100100 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010334d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103350:	8d 83 88 d3 fe ff    	lea    -0x12c78(%ebx),%eax
f0103356:	50                   	push   %eax
f0103357:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010335d:	50                   	push   %eax
f010335e:	68 b8 03 00 00       	push   $0x3b8
f0103363:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0103369:	50                   	push   %eax
f010336a:	e8 91 cd ff ff       	call   f0100100 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010336f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103372:	8d 83 ac d3 fe ff    	lea    -0x12c54(%ebx),%eax
f0103378:	50                   	push   %eax
f0103379:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010337f:	50                   	push   %eax
f0103380:	68 ba 03 00 00       	push   $0x3ba
f0103385:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010338b:	50                   	push   %eax
f010338c:	e8 6f cd ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 1);
f0103391:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103394:	8d 83 ba cb fe ff    	lea    -0x13446(%ebx),%eax
f010339a:	50                   	push   %eax
f010339b:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01033a1:	50                   	push   %eax
f01033a2:	68 bb 03 00 00       	push   $0x3bb
f01033a7:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01033ad:	50                   	push   %eax
f01033ae:	e8 4d cd ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 0);
f01033b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01033b6:	8d 83 24 cc fe ff    	lea    -0x133dc(%ebx),%eax
f01033bc:	50                   	push   %eax
f01033bd:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01033c3:	50                   	push   %eax
f01033c4:	68 bc 03 00 00       	push   $0x3bc
f01033c9:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f01033cf:	50                   	push   %eax
f01033d0:	e8 2b cd ff ff       	call   f0100100 <_panic>
f01033d5:	50                   	push   %eax
f01033d6:	8d 83 b0 cc fe ff    	lea    -0x13350(%ebx),%eax
f01033dc:	50                   	push   %eax
f01033dd:	6a 52                	push   $0x52
f01033df:	8d 83 ce c9 fe ff    	lea    -0x13632(%ebx),%eax
f01033e5:	50                   	push   %eax
f01033e6:	e8 15 cd ff ff       	call   f0100100 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01033eb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01033ee:	8d 83 d0 d3 fe ff    	lea    -0x12c30(%ebx),%eax
f01033f4:	50                   	push   %eax
f01033f5:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f01033fb:	50                   	push   %eax
f01033fc:	68 be 03 00 00       	push   $0x3be
f0103401:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0103407:	50                   	push   %eax
f0103408:	e8 f3 cc ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 0);
f010340d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103410:	8d 83 f2 cb fe ff    	lea    -0x1340e(%ebx),%eax
f0103416:	50                   	push   %eax
f0103417:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010341d:	50                   	push   %eax
f010341e:	68 c0 03 00 00       	push   $0x3c0
f0103423:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f0103429:	50                   	push   %eax
f010342a:	e8 d1 cc ff ff       	call   f0100100 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010342f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103432:	8d 83 14 cf fe ff    	lea    -0x130ec(%ebx),%eax
f0103438:	50                   	push   %eax
f0103439:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f010343f:	50                   	push   %eax
f0103440:	68 c3 03 00 00       	push   $0x3c3
f0103445:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010344b:	50                   	push   %eax
f010344c:	e8 af cc ff ff       	call   f0100100 <_panic>
	assert(pp0->pp_ref == 1);
f0103451:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103454:	8d 83 a9 cb fe ff    	lea    -0x13457(%ebx),%eax
f010345a:	50                   	push   %eax
f010345b:	8d 83 b2 c5 fe ff    	lea    -0x13a4e(%ebx),%eax
f0103461:	50                   	push   %eax
f0103462:	68 c5 03 00 00       	push   $0x3c5
f0103467:	8d 83 c2 c9 fe ff    	lea    -0x1363e(%ebx),%eax
f010346d:	50                   	push   %eax
f010346e:	e8 8d cc ff ff       	call   f0100100 <_panic>

f0103473 <tlb_invalidate>:
{
f0103473:	55                   	push   %ebp
f0103474:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0103476:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103479:	0f 01 38             	invlpg (%eax)
}
f010347c:	5d                   	pop    %ebp
f010347d:	c3                   	ret    

f010347e <__x86.get_pc_thunk.cx>:
f010347e:	8b 0c 24             	mov    (%esp),%ecx
f0103481:	c3                   	ret    

f0103482 <__x86.get_pc_thunk.si>:
f0103482:	8b 34 24             	mov    (%esp),%esi
f0103485:	c3                   	ret    

f0103486 <__x86.get_pc_thunk.di>:
f0103486:	8b 3c 24             	mov    (%esp),%edi
f0103489:	c3                   	ret    

f010348a <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010348a:	55                   	push   %ebp
f010348b:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010348d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103490:	ba 70 00 00 00       	mov    $0x70,%edx
f0103495:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103496:	ba 71 00 00 00       	mov    $0x71,%edx
f010349b:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010349c:	0f b6 c0             	movzbl %al,%eax
}
f010349f:	5d                   	pop    %ebp
f01034a0:	c3                   	ret    

f01034a1 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034a1:	55                   	push   %ebp
f01034a2:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034a4:	8b 45 08             	mov    0x8(%ebp),%eax
f01034a7:	ba 70 00 00 00       	mov    $0x70,%edx
f01034ac:	ee                   	out    %al,(%dx)
f01034ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034b0:	ba 71 00 00 00       	mov    $0x71,%edx
f01034b5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01034b6:	5d                   	pop    %ebp
f01034b7:	c3                   	ret    

f01034b8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01034b8:	55                   	push   %ebp
f01034b9:	89 e5                	mov    %esp,%ebp
f01034bb:	53                   	push   %ebx
f01034bc:	83 ec 10             	sub    $0x10,%esp
f01034bf:	e8 f2 cc ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01034c4:	81 c3 48 4e 01 00    	add    $0x14e48,%ebx
	cputchar(ch);
f01034ca:	ff 75 08             	pushl  0x8(%ebp)
f01034cd:	e8 5b d2 ff ff       	call   f010072d <cputchar>
	*cnt++;
}
f01034d2:	83 c4 10             	add    $0x10,%esp
f01034d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01034d8:	c9                   	leave  
f01034d9:	c3                   	ret    

f01034da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01034da:	55                   	push   %ebp
f01034db:	89 e5                	mov    %esp,%ebp
f01034dd:	53                   	push   %ebx
f01034de:	83 ec 14             	sub    $0x14,%esp
f01034e1:	e8 d0 cc ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01034e6:	81 c3 26 4e 01 00    	add    $0x14e26,%ebx
	int cnt = 0;
f01034ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01034f3:	ff 75 0c             	pushl  0xc(%ebp)
f01034f6:	ff 75 08             	pushl  0x8(%ebp)
f01034f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01034fc:	50                   	push   %eax
f01034fd:	8d 83 ac b1 fe ff    	lea    -0x14e54(%ebx),%eax
f0103503:	50                   	push   %eax
f0103504:	e8 8d 04 00 00       	call   f0103996 <vprintfmt>
	return cnt;
}
f0103509:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010350c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010350f:	c9                   	leave  
f0103510:	c3                   	ret    

f0103511 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103511:	55                   	push   %ebp
f0103512:	89 e5                	mov    %esp,%ebp
f0103514:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103517:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010351a:	50                   	push   %eax
f010351b:	ff 75 08             	pushl  0x8(%ebp)
f010351e:	e8 b7 ff ff ff       	call   f01034da <vcprintf>
	va_end(ap);

	return cnt;
}
f0103523:	c9                   	leave  
f0103524:	c3                   	ret    

f0103525 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103525:	55                   	push   %ebp
f0103526:	89 e5                	mov    %esp,%ebp
f0103528:	57                   	push   %edi
f0103529:	56                   	push   %esi
f010352a:	53                   	push   %ebx
f010352b:	83 ec 14             	sub    $0x14,%esp
f010352e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103531:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103534:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103537:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010353a:	8b 32                	mov    (%edx),%esi
f010353c:	8b 01                	mov    (%ecx),%eax
f010353e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103541:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103548:	eb 2f                	jmp    f0103579 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010354a:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010354d:	39 c6                	cmp    %eax,%esi
f010354f:	7f 49                	jg     f010359a <stab_binsearch+0x75>
f0103551:	0f b6 0a             	movzbl (%edx),%ecx
f0103554:	83 ea 0c             	sub    $0xc,%edx
f0103557:	39 f9                	cmp    %edi,%ecx
f0103559:	75 ef                	jne    f010354a <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010355b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010355e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103561:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103565:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103568:	73 35                	jae    f010359f <stab_binsearch+0x7a>
			*region_left = m;
f010356a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010356d:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f010356f:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0103572:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0103579:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010357c:	7f 4e                	jg     f01035cc <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f010357e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103581:	01 f0                	add    %esi,%eax
f0103583:	89 c3                	mov    %eax,%ebx
f0103585:	c1 eb 1f             	shr    $0x1f,%ebx
f0103588:	01 c3                	add    %eax,%ebx
f010358a:	d1 fb                	sar    %ebx
f010358c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010358f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103592:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0103596:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0103598:	eb b3                	jmp    f010354d <stab_binsearch+0x28>
			l = true_m + 1;
f010359a:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010359d:	eb da                	jmp    f0103579 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f010359f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01035a2:	76 14                	jbe    f01035b8 <stab_binsearch+0x93>
			*region_right = m - 1;
f01035a4:	83 e8 01             	sub    $0x1,%eax
f01035a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01035aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01035ad:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f01035af:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01035b6:	eb c1                	jmp    f0103579 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01035b8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01035bb:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01035bd:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01035c1:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01035c3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01035ca:	eb ad                	jmp    f0103579 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01035cc:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01035d0:	74 16                	je     f01035e8 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01035d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01035d5:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01035d7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01035da:	8b 0e                	mov    (%esi),%ecx
f01035dc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01035df:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01035e2:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01035e6:	eb 12                	jmp    f01035fa <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f01035e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035eb:	8b 00                	mov    (%eax),%eax
f01035ed:	83 e8 01             	sub    $0x1,%eax
f01035f0:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01035f3:	89 07                	mov    %eax,(%edi)
f01035f5:	eb 16                	jmp    f010360d <stab_binsearch+0xe8>
		     l--)
f01035f7:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01035fa:	39 c1                	cmp    %eax,%ecx
f01035fc:	7d 0a                	jge    f0103608 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f01035fe:	0f b6 1a             	movzbl (%edx),%ebx
f0103601:	83 ea 0c             	sub    $0xc,%edx
f0103604:	39 fb                	cmp    %edi,%ebx
f0103606:	75 ef                	jne    f01035f7 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0103608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010360b:	89 07                	mov    %eax,(%edi)
	}
}
f010360d:	83 c4 14             	add    $0x14,%esp
f0103610:	5b                   	pop    %ebx
f0103611:	5e                   	pop    %esi
f0103612:	5f                   	pop    %edi
f0103613:	5d                   	pop    %ebp
f0103614:	c3                   	ret    

f0103615 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103615:	55                   	push   %ebp
f0103616:	89 e5                	mov    %esp,%ebp
f0103618:	57                   	push   %edi
f0103619:	56                   	push   %esi
f010361a:	53                   	push   %ebx
f010361b:	83 ec 3c             	sub    $0x3c,%esp
f010361e:	e8 93 cb ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0103623:	81 c3 e9 4c 01 00    	add    $0x14ce9,%ebx
f0103629:	8b 7d 08             	mov    0x8(%ebp),%edi
f010362c:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010362f:	8d 83 28 d4 fe ff    	lea    -0x12bd8(%ebx),%eax
f0103635:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0103637:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010363e:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103641:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0103648:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f010364b:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103652:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103658:	0f 86 2f 01 00 00    	jbe    f010378d <debuginfo_eip+0x178>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010365e:	c7 c0 dd c5 10 f0    	mov    $0xf010c5dd,%eax
f0103664:	39 83 f8 ff ff ff    	cmp    %eax,-0x8(%ebx)
f010366a:	0f 86 00 02 00 00    	jbe    f0103870 <debuginfo_eip+0x25b>
f0103670:	c7 c0 a4 e4 10 f0    	mov    $0xf010e4a4,%eax
f0103676:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010367a:	0f 85 f7 01 00 00    	jne    f0103877 <debuginfo_eip+0x262>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103680:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103687:	c7 c0 4c 59 10 f0    	mov    $0xf010594c,%eax
f010368d:	c7 c2 dc c5 10 f0    	mov    $0xf010c5dc,%edx
f0103693:	29 c2                	sub    %eax,%edx
f0103695:	c1 fa 02             	sar    $0x2,%edx
f0103698:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010369e:	83 ea 01             	sub    $0x1,%edx
f01036a1:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01036a4:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01036a7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01036aa:	83 ec 08             	sub    $0x8,%esp
f01036ad:	57                   	push   %edi
f01036ae:	6a 64                	push   $0x64
f01036b0:	e8 70 fe ff ff       	call   f0103525 <stab_binsearch>
	if (lfile == 0)
f01036b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01036b8:	83 c4 10             	add    $0x10,%esp
f01036bb:	85 c0                	test   %eax,%eax
f01036bd:	0f 84 bb 01 00 00    	je     f010387e <debuginfo_eip+0x269>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01036c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01036c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01036c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01036cc:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01036cf:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01036d2:	83 ec 08             	sub    $0x8,%esp
f01036d5:	57                   	push   %edi
f01036d6:	6a 24                	push   $0x24
f01036d8:	c7 c0 4c 59 10 f0    	mov    $0xf010594c,%eax
f01036de:	e8 42 fe ff ff       	call   f0103525 <stab_binsearch>

	if (lfun <= rfun) {
f01036e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01036e6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01036e9:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01036ec:	83 c4 10             	add    $0x10,%esp
f01036ef:	39 c8                	cmp    %ecx,%eax
f01036f1:	0f 8f ae 00 00 00    	jg     f01037a5 <debuginfo_eip+0x190>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01036f7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01036fa:	c7 c1 4c 59 10 f0    	mov    $0xf010594c,%ecx
f0103700:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0103703:	8b 11                	mov    (%ecx),%edx
f0103705:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0103708:	c7 c2 a4 e4 10 f0    	mov    $0xf010e4a4,%edx
f010370e:	81 ea dd c5 10 f0    	sub    $0xf010c5dd,%edx
f0103714:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0103717:	73 0c                	jae    f0103725 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103719:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010371c:	81 c2 dd c5 10 f0    	add    $0xf010c5dd,%edx
f0103722:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103725:	8b 51 08             	mov    0x8(%ecx),%edx
f0103728:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f010372b:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f010372d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103730:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103733:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103736:	83 ec 08             	sub    $0x8,%esp
f0103739:	6a 3a                	push   $0x3a
f010373b:	ff 76 08             	pushl  0x8(%esi)
f010373e:	e8 19 0a 00 00       	call   f010415c <strfind>
f0103743:	2b 46 08             	sub    0x8(%esi),%eax
f0103746:	89 46 0c             	mov    %eax,0xc(%esi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103749:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010374c:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010374f:	83 c4 08             	add    $0x8,%esp
f0103752:	57                   	push   %edi
f0103753:	6a 44                	push   $0x44
f0103755:	c7 c7 4c 59 10 f0    	mov    $0xf010594c,%edi
f010375b:	89 f8                	mov    %edi,%eax
f010375d:	e8 c3 fd ff ff       	call   f0103525 <stab_binsearch>
	// cprintf("symbol table: %d\n", stabs[lline].n_desc);
	info->eip_line = stabs[lline].n_desc;
f0103762:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103765:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103768:	c1 e2 02             	shl    $0x2,%edx
f010376b:	0f b7 4c 3a 06       	movzwl 0x6(%edx,%edi,1),%ecx
f0103770:	89 4e 04             	mov    %ecx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103773:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103776:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f010377a:	83 c4 10             	add    $0x10,%esp
f010377d:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f0103781:	bf 01 00 00 00       	mov    $0x1,%edi
f0103786:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103789:	89 ce                	mov    %ecx,%esi
f010378b:	eb 34                	jmp    f01037c1 <debuginfo_eip+0x1ac>
  	        panic("User address");
f010378d:	83 ec 04             	sub    $0x4,%esp
f0103790:	8d 83 32 d4 fe ff    	lea    -0x12bce(%ebx),%eax
f0103796:	50                   	push   %eax
f0103797:	6a 7f                	push   $0x7f
f0103799:	8d 83 3f d4 fe ff    	lea    -0x12bc1(%ebx),%eax
f010379f:	50                   	push   %eax
f01037a0:	e8 5b c9 ff ff       	call   f0100100 <_panic>
		info->eip_fn_addr = addr;
f01037a5:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f01037a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01037ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01037ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01037b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01037b4:	eb 80                	jmp    f0103736 <debuginfo_eip+0x121>
f01037b6:	83 e8 01             	sub    $0x1,%eax
f01037b9:	83 ea 0c             	sub    $0xc,%edx
f01037bc:	89 f9                	mov    %edi,%ecx
f01037be:	88 4d c0             	mov    %cl,-0x40(%ebp)
f01037c1:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f01037c4:	39 c6                	cmp    %eax,%esi
f01037c6:	7f 2a                	jg     f01037f2 <debuginfo_eip+0x1dd>
f01037c8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	       && stabs[lline].n_type != N_SOL
f01037cb:	0f b6 0a             	movzbl (%edx),%ecx
f01037ce:	80 f9 84             	cmp    $0x84,%cl
f01037d1:	74 49                	je     f010381c <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01037d3:	80 f9 64             	cmp    $0x64,%cl
f01037d6:	75 de                	jne    f01037b6 <debuginfo_eip+0x1a1>
f01037d8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01037db:	83 79 04 00          	cmpl   $0x0,0x4(%ecx)
f01037df:	74 d5                	je     f01037b6 <debuginfo_eip+0x1a1>
f01037e1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01037e4:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f01037e8:	74 3b                	je     f0103825 <debuginfo_eip+0x210>
f01037ea:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01037ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01037f0:	eb 33                	jmp    f0103825 <debuginfo_eip+0x210>
f01037f2:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01037f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01037f8:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01037fb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0103800:	39 fa                	cmp    %edi,%edx
f0103802:	0f 8d 82 00 00 00    	jge    f010388a <debuginfo_eip+0x275>
		for (lline = lfun + 1;
f0103808:	83 c2 01             	add    $0x1,%edx
f010380b:	89 d0                	mov    %edx,%eax
f010380d:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0103810:	c7 c2 4c 59 10 f0    	mov    $0xf010594c,%edx
f0103816:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f010381a:	eb 3b                	jmp    f0103857 <debuginfo_eip+0x242>
f010381c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010381f:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0103823:	75 26                	jne    f010384b <debuginfo_eip+0x236>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103825:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103828:	c7 c0 4c 59 10 f0    	mov    $0xf010594c,%eax
f010382e:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0103831:	c7 c0 a4 e4 10 f0    	mov    $0xf010e4a4,%eax
f0103837:	81 e8 dd c5 10 f0    	sub    $0xf010c5dd,%eax
f010383d:	39 c2                	cmp    %eax,%edx
f010383f:	73 b4                	jae    f01037f5 <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103841:	81 c2 dd c5 10 f0    	add    $0xf010c5dd,%edx
f0103847:	89 16                	mov    %edx,(%esi)
f0103849:	eb aa                	jmp    f01037f5 <debuginfo_eip+0x1e0>
f010384b:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010384e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103851:	eb d2                	jmp    f0103825 <debuginfo_eip+0x210>
			info->eip_fn_narg++;
f0103853:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0103857:	39 c7                	cmp    %eax,%edi
f0103859:	7e 2a                	jle    f0103885 <debuginfo_eip+0x270>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010385b:	0f b6 0a             	movzbl (%edx),%ecx
f010385e:	83 c0 01             	add    $0x1,%eax
f0103861:	83 c2 0c             	add    $0xc,%edx
f0103864:	80 f9 a0             	cmp    $0xa0,%cl
f0103867:	74 ea                	je     f0103853 <debuginfo_eip+0x23e>
	return 0;
f0103869:	b8 00 00 00 00       	mov    $0x0,%eax
f010386e:	eb 1a                	jmp    f010388a <debuginfo_eip+0x275>
		return -1;
f0103870:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103875:	eb 13                	jmp    f010388a <debuginfo_eip+0x275>
f0103877:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010387c:	eb 0c                	jmp    f010388a <debuginfo_eip+0x275>
		return -1;
f010387e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103883:	eb 05                	jmp    f010388a <debuginfo_eip+0x275>
	return 0;
f0103885:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010388a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010388d:	5b                   	pop    %ebx
f010388e:	5e                   	pop    %esi
f010388f:	5f                   	pop    %edi
f0103890:	5d                   	pop    %ebp
f0103891:	c3                   	ret    

f0103892 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103892:	55                   	push   %ebp
f0103893:	89 e5                	mov    %esp,%ebp
f0103895:	57                   	push   %edi
f0103896:	56                   	push   %esi
f0103897:	53                   	push   %ebx
f0103898:	83 ec 2c             	sub    $0x2c,%esp
f010389b:	e8 de fb ff ff       	call   f010347e <__x86.get_pc_thunk.cx>
f01038a0:	81 c1 6c 4a 01 00    	add    $0x14a6c,%ecx
f01038a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01038a9:	89 c7                	mov    %eax,%edi
f01038ab:	89 d6                	mov    %edx,%esi
f01038ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01038b0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01038b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01038b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01038b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01038bc:	bb 00 00 00 00       	mov    $0x0,%ebx
f01038c1:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f01038c4:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f01038c7:	39 d3                	cmp    %edx,%ebx
f01038c9:	72 09                	jb     f01038d4 <printnum+0x42>
f01038cb:	39 45 10             	cmp    %eax,0x10(%ebp)
f01038ce:	0f 87 83 00 00 00    	ja     f0103957 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01038d4:	83 ec 0c             	sub    $0xc,%esp
f01038d7:	ff 75 18             	pushl  0x18(%ebp)
f01038da:	8b 45 14             	mov    0x14(%ebp),%eax
f01038dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01038e0:	53                   	push   %ebx
f01038e1:	ff 75 10             	pushl  0x10(%ebp)
f01038e4:	83 ec 08             	sub    $0x8,%esp
f01038e7:	ff 75 dc             	pushl  -0x24(%ebp)
f01038ea:	ff 75 d8             	pushl  -0x28(%ebp)
f01038ed:	ff 75 d4             	pushl  -0x2c(%ebp)
f01038f0:	ff 75 d0             	pushl  -0x30(%ebp)
f01038f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01038f6:	e8 85 0a 00 00       	call   f0104380 <__udivdi3>
f01038fb:	83 c4 18             	add    $0x18,%esp
f01038fe:	52                   	push   %edx
f01038ff:	50                   	push   %eax
f0103900:	89 f2                	mov    %esi,%edx
f0103902:	89 f8                	mov    %edi,%eax
f0103904:	e8 89 ff ff ff       	call   f0103892 <printnum>
f0103909:	83 c4 20             	add    $0x20,%esp
f010390c:	eb 13                	jmp    f0103921 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010390e:	83 ec 08             	sub    $0x8,%esp
f0103911:	56                   	push   %esi
f0103912:	ff 75 18             	pushl  0x18(%ebp)
f0103915:	ff d7                	call   *%edi
f0103917:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010391a:	83 eb 01             	sub    $0x1,%ebx
f010391d:	85 db                	test   %ebx,%ebx
f010391f:	7f ed                	jg     f010390e <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103921:	83 ec 08             	sub    $0x8,%esp
f0103924:	56                   	push   %esi
f0103925:	83 ec 04             	sub    $0x4,%esp
f0103928:	ff 75 dc             	pushl  -0x24(%ebp)
f010392b:	ff 75 d8             	pushl  -0x28(%ebp)
f010392e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103931:	ff 75 d0             	pushl  -0x30(%ebp)
f0103934:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103937:	89 f3                	mov    %esi,%ebx
f0103939:	e8 62 0b 00 00       	call   f01044a0 <__umoddi3>
f010393e:	83 c4 14             	add    $0x14,%esp
f0103941:	0f be 84 06 4d d4 fe 	movsbl -0x12bb3(%esi,%eax,1),%eax
f0103948:	ff 
f0103949:	50                   	push   %eax
f010394a:	ff d7                	call   *%edi
}
f010394c:	83 c4 10             	add    $0x10,%esp
f010394f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103952:	5b                   	pop    %ebx
f0103953:	5e                   	pop    %esi
f0103954:	5f                   	pop    %edi
f0103955:	5d                   	pop    %ebp
f0103956:	c3                   	ret    
f0103957:	8b 5d 14             	mov    0x14(%ebp),%ebx
f010395a:	eb be                	jmp    f010391a <printnum+0x88>

f010395c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010395c:	55                   	push   %ebp
f010395d:	89 e5                	mov    %esp,%ebp
f010395f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103962:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103966:	8b 10                	mov    (%eax),%edx
f0103968:	3b 50 04             	cmp    0x4(%eax),%edx
f010396b:	73 0a                	jae    f0103977 <sprintputch+0x1b>
		*b->buf++ = ch;
f010396d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103970:	89 08                	mov    %ecx,(%eax)
f0103972:	8b 45 08             	mov    0x8(%ebp),%eax
f0103975:	88 02                	mov    %al,(%edx)
}
f0103977:	5d                   	pop    %ebp
f0103978:	c3                   	ret    

f0103979 <printfmt>:
{
f0103979:	55                   	push   %ebp
f010397a:	89 e5                	mov    %esp,%ebp
f010397c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010397f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103982:	50                   	push   %eax
f0103983:	ff 75 10             	pushl  0x10(%ebp)
f0103986:	ff 75 0c             	pushl  0xc(%ebp)
f0103989:	ff 75 08             	pushl  0x8(%ebp)
f010398c:	e8 05 00 00 00       	call   f0103996 <vprintfmt>
}
f0103991:	83 c4 10             	add    $0x10,%esp
f0103994:	c9                   	leave  
f0103995:	c3                   	ret    

f0103996 <vprintfmt>:
{
f0103996:	55                   	push   %ebp
f0103997:	89 e5                	mov    %esp,%ebp
f0103999:	57                   	push   %edi
f010399a:	56                   	push   %esi
f010399b:	53                   	push   %ebx
f010399c:	83 ec 2c             	sub    $0x2c,%esp
f010399f:	e8 12 c8 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01039a4:	81 c3 68 49 01 00    	add    $0x14968,%ebx
f01039aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
f01039ad:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
f01039b4:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01039b6:	8d 77 01             	lea    0x1(%edi),%esi
f01039b9:	0f b6 07             	movzbl (%edi),%eax
f01039bc:	83 f8 25             	cmp    $0x25,%eax
f01039bf:	74 1c                	je     f01039dd <vprintfmt+0x47>
			if (ch == '\0')
f01039c1:	85 c0                	test   %eax,%eax
f01039c3:	0f 84 b9 04 00 00    	je     f0103e82 <.L21+0x20>
			putch(ch, putdat);
f01039c9:	83 ec 08             	sub    $0x8,%esp
f01039cc:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
f01039cf:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
f01039d2:	50                   	push   %eax
f01039d3:	ff 55 08             	call   *0x8(%ebp)
f01039d6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01039d9:	89 f7                	mov    %esi,%edi
f01039db:	eb d9                	jmp    f01039b6 <vprintfmt+0x20>
		padc = ' ';
f01039dd:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
f01039e1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01039e8:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f01039ef:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01039f6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01039fb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01039fe:	8d 7e 01             	lea    0x1(%esi),%edi
f0103a01:	0f b6 16             	movzbl (%esi),%edx
f0103a04:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103a07:	3c 55                	cmp    $0x55,%al
f0103a09:	0f 87 53 04 00 00    	ja     f0103e62 <.L21>
f0103a0f:	0f b6 c0             	movzbl %al,%eax
f0103a12:	89 d9                	mov    %ebx,%ecx
f0103a14:	03 8c 83 d8 d4 fe ff 	add    -0x12b28(%ebx,%eax,4),%ecx
f0103a1b:	ff e1                	jmp    *%ecx

f0103a1d <.L73>:
f0103a1d:	89 fe                	mov    %edi,%esi
			padc = '-';
f0103a1f:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0103a23:	eb d9                	jmp    f01039fe <vprintfmt+0x68>

f0103a25 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
f0103a25:	89 fe                	mov    %edi,%esi
			padc = '0';
f0103a27:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0103a2b:	eb d1                	jmp    f01039fe <vprintfmt+0x68>

f0103a2d <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0103a2d:	0f b6 d2             	movzbl %dl,%edx
f0103a30:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
f0103a32:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a37:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
f0103a3a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103a3d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103a41:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
f0103a44:	8d 7a d0             	lea    -0x30(%edx),%edi
f0103a47:	83 ff 09             	cmp    $0x9,%edi
f0103a4a:	0f 87 94 00 00 00    	ja     f0103ae4 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
f0103a50:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0103a53:	eb e5                	jmp    f0103a3a <.L28+0xd>

f0103a55 <.L25>:
			precision = va_arg(ap, int);
f0103a55:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a58:	8b 00                	mov    (%eax),%eax
f0103a5a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103a5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a60:	8d 40 04             	lea    0x4(%eax),%eax
f0103a63:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103a66:	89 fe                	mov    %edi,%esi
			if (width < 0)
f0103a68:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103a6c:	79 90                	jns    f01039fe <vprintfmt+0x68>
				width = precision, precision = -1;
f0103a6e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103a71:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103a74:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0103a7b:	eb 81                	jmp    f01039fe <vprintfmt+0x68>

f0103a7d <.L26>:
f0103a7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a80:	85 c0                	test   %eax,%eax
f0103a82:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a87:	0f 49 d0             	cmovns %eax,%edx
f0103a8a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103a8d:	89 fe                	mov    %edi,%esi
f0103a8f:	e9 6a ff ff ff       	jmp    f01039fe <vprintfmt+0x68>

f0103a94 <.L22>:
f0103a94:	89 fe                	mov    %edi,%esi
			altflag = 1;
f0103a96:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103a9d:	e9 5c ff ff ff       	jmp    f01039fe <vprintfmt+0x68>

f0103aa2 <.L33>:
f0103aa2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0103aa5:	83 f9 01             	cmp    $0x1,%ecx
f0103aa8:	7e 16                	jle    f0103ac0 <.L33+0x1e>
		return va_arg(*ap, long long);
f0103aaa:	8b 45 14             	mov    0x14(%ebp),%eax
f0103aad:	8b 00                	mov    (%eax),%eax
f0103aaf:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103ab2:	8d 49 08             	lea    0x8(%ecx),%ecx
f0103ab5:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
f0103ab8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
f0103abb:	e9 f6 fe ff ff       	jmp    f01039b6 <vprintfmt+0x20>
	else if (lflag)
f0103ac0:	85 c9                	test   %ecx,%ecx
f0103ac2:	75 10                	jne    f0103ad4 <.L33+0x32>
		return va_arg(*ap, int);
f0103ac4:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ac7:	8b 00                	mov    (%eax),%eax
f0103ac9:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103acc:	8d 49 04             	lea    0x4(%ecx),%ecx
f0103acf:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103ad2:	eb e4                	jmp    f0103ab8 <.L33+0x16>
		return va_arg(*ap, long);
f0103ad4:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ad7:	8b 00                	mov    (%eax),%eax
f0103ad9:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103adc:	8d 49 04             	lea    0x4(%ecx),%ecx
f0103adf:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103ae2:	eb d4                	jmp    f0103ab8 <.L33+0x16>
f0103ae4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103ae7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103aea:	e9 79 ff ff ff       	jmp    f0103a68 <.L25+0x13>

f0103aef <.L32>:
			lflag++;
f0103aef:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103af3:	89 fe                	mov    %edi,%esi
			goto reswitch;
f0103af5:	e9 04 ff ff ff       	jmp    f01039fe <vprintfmt+0x68>

f0103afa <.L29>:
			putch(va_arg(ap, int), putdat);
f0103afa:	8b 45 14             	mov    0x14(%ebp),%eax
f0103afd:	8d 70 04             	lea    0x4(%eax),%esi
f0103b00:	83 ec 08             	sub    $0x8,%esp
f0103b03:	ff 75 0c             	pushl  0xc(%ebp)
f0103b06:	ff 30                	pushl  (%eax)
f0103b08:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103b0b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103b0e:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
f0103b11:	e9 a0 fe ff ff       	jmp    f01039b6 <vprintfmt+0x20>

f0103b16 <.L31>:
			err = va_arg(ap, int);
f0103b16:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b19:	8d 70 04             	lea    0x4(%eax),%esi
f0103b1c:	8b 00                	mov    (%eax),%eax
f0103b1e:	99                   	cltd   
f0103b1f:	31 d0                	xor    %edx,%eax
f0103b21:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103b23:	83 f8 06             	cmp    $0x6,%eax
f0103b26:	7f 29                	jg     f0103b51 <.L31+0x3b>
f0103b28:	8b 94 83 50 1d 00 00 	mov    0x1d50(%ebx,%eax,4),%edx
f0103b2f:	85 d2                	test   %edx,%edx
f0103b31:	74 1e                	je     f0103b51 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
f0103b33:	52                   	push   %edx
f0103b34:	8d 83 c4 c5 fe ff    	lea    -0x13a3c(%ebx),%eax
f0103b3a:	50                   	push   %eax
f0103b3b:	ff 75 0c             	pushl  0xc(%ebp)
f0103b3e:	ff 75 08             	pushl  0x8(%ebp)
f0103b41:	e8 33 fe ff ff       	call   f0103979 <printfmt>
f0103b46:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103b49:	89 75 14             	mov    %esi,0x14(%ebp)
f0103b4c:	e9 65 fe ff ff       	jmp    f01039b6 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
f0103b51:	50                   	push   %eax
f0103b52:	8d 83 65 d4 fe ff    	lea    -0x12b9b(%ebx),%eax
f0103b58:	50                   	push   %eax
f0103b59:	ff 75 0c             	pushl  0xc(%ebp)
f0103b5c:	ff 75 08             	pushl  0x8(%ebp)
f0103b5f:	e8 15 fe ff ff       	call   f0103979 <printfmt>
f0103b64:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103b67:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103b6a:	e9 47 fe ff ff       	jmp    f01039b6 <vprintfmt+0x20>

f0103b6f <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0103b6f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b72:	83 c0 04             	add    $0x4,%eax
f0103b75:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103b78:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b7b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0103b7d:	85 f6                	test   %esi,%esi
f0103b7f:	8d 83 5e d4 fe ff    	lea    -0x12ba2(%ebx),%eax
f0103b85:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0103b88:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103b8c:	0f 8e b4 00 00 00    	jle    f0103c46 <.L36+0xd7>
f0103b92:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0103b96:	75 08                	jne    f0103ba0 <.L36+0x31>
f0103b98:	89 7d 10             	mov    %edi,0x10(%ebp)
f0103b9b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103b9e:	eb 6c                	jmp    f0103c0c <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103ba0:	83 ec 08             	sub    $0x8,%esp
f0103ba3:	ff 75 cc             	pushl  -0x34(%ebp)
f0103ba6:	56                   	push   %esi
f0103ba7:	e8 6c 04 00 00       	call   f0104018 <strnlen>
f0103bac:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103baf:	29 c2                	sub    %eax,%edx
f0103bb1:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0103bb4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103bb7:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
f0103bbb:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0103bbe:	89 d6                	mov    %edx,%esi
f0103bc0:	89 7d 10             	mov    %edi,0x10(%ebp)
f0103bc3:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103bc5:	eb 10                	jmp    f0103bd7 <.L36+0x68>
					putch(padc, putdat);
f0103bc7:	83 ec 08             	sub    $0x8,%esp
f0103bca:	ff 75 0c             	pushl  0xc(%ebp)
f0103bcd:	57                   	push   %edi
f0103bce:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0103bd1:	83 ee 01             	sub    $0x1,%esi
f0103bd4:	83 c4 10             	add    $0x10,%esp
f0103bd7:	85 f6                	test   %esi,%esi
f0103bd9:	7f ec                	jg     f0103bc7 <.L36+0x58>
f0103bdb:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103bde:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103be1:	85 d2                	test   %edx,%edx
f0103be3:	b8 00 00 00 00       	mov    $0x0,%eax
f0103be8:	0f 49 c2             	cmovns %edx,%eax
f0103beb:	29 c2                	sub    %eax,%edx
f0103bed:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0103bf0:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103bf3:	eb 17                	jmp    f0103c0c <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
f0103bf5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103bf9:	75 30                	jne    f0103c2b <.L36+0xbc>
					putch(ch, putdat);
f0103bfb:	83 ec 08             	sub    $0x8,%esp
f0103bfe:	ff 75 0c             	pushl  0xc(%ebp)
f0103c01:	50                   	push   %eax
f0103c02:	ff 55 08             	call   *0x8(%ebp)
f0103c05:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103c08:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0103c0c:	83 c6 01             	add    $0x1,%esi
f0103c0f:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0103c13:	0f be c2             	movsbl %dl,%eax
f0103c16:	85 c0                	test   %eax,%eax
f0103c18:	74 58                	je     f0103c72 <.L36+0x103>
f0103c1a:	85 ff                	test   %edi,%edi
f0103c1c:	78 d7                	js     f0103bf5 <.L36+0x86>
f0103c1e:	83 ef 01             	sub    $0x1,%edi
f0103c21:	79 d2                	jns    f0103bf5 <.L36+0x86>
f0103c23:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103c26:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103c29:	eb 32                	jmp    f0103c5d <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
f0103c2b:	0f be d2             	movsbl %dl,%edx
f0103c2e:	83 ea 20             	sub    $0x20,%edx
f0103c31:	83 fa 5e             	cmp    $0x5e,%edx
f0103c34:	76 c5                	jbe    f0103bfb <.L36+0x8c>
					putch('?', putdat);
f0103c36:	83 ec 08             	sub    $0x8,%esp
f0103c39:	ff 75 0c             	pushl  0xc(%ebp)
f0103c3c:	6a 3f                	push   $0x3f
f0103c3e:	ff 55 08             	call   *0x8(%ebp)
f0103c41:	83 c4 10             	add    $0x10,%esp
f0103c44:	eb c2                	jmp    f0103c08 <.L36+0x99>
f0103c46:	89 7d 10             	mov    %edi,0x10(%ebp)
f0103c49:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103c4c:	eb be                	jmp    f0103c0c <.L36+0x9d>
				putch(' ', putdat);
f0103c4e:	83 ec 08             	sub    $0x8,%esp
f0103c51:	57                   	push   %edi
f0103c52:	6a 20                	push   $0x20
f0103c54:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0103c57:	83 ee 01             	sub    $0x1,%esi
f0103c5a:	83 c4 10             	add    $0x10,%esp
f0103c5d:	85 f6                	test   %esi,%esi
f0103c5f:	7f ed                	jg     f0103c4e <.L36+0xdf>
f0103c61:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0103c64:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
f0103c67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103c6a:	89 45 14             	mov    %eax,0x14(%ebp)
f0103c6d:	e9 44 fd ff ff       	jmp    f01039b6 <vprintfmt+0x20>
f0103c72:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103c75:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103c78:	eb e3                	jmp    f0103c5d <.L36+0xee>

f0103c7a <.L30>:
f0103c7a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0103c7d:	83 f9 01             	cmp    $0x1,%ecx
f0103c80:	7e 42                	jle    f0103cc4 <.L30+0x4a>
		return va_arg(*ap, long long);
f0103c82:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c85:	8b 50 04             	mov    0x4(%eax),%edx
f0103c88:	8b 00                	mov    (%eax),%eax
f0103c8a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103c8d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103c90:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c93:	8d 40 08             	lea    0x8(%eax),%eax
f0103c96:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103c99:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103c9d:	79 5f                	jns    f0103cfe <.L30+0x84>
				putch('-', putdat);
f0103c9f:	83 ec 08             	sub    $0x8,%esp
f0103ca2:	ff 75 0c             	pushl  0xc(%ebp)
f0103ca5:	6a 2d                	push   $0x2d
f0103ca7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103caa:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103cad:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103cb0:	f7 da                	neg    %edx
f0103cb2:	83 d1 00             	adc    $0x0,%ecx
f0103cb5:	f7 d9                	neg    %ecx
f0103cb7:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0103cba:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103cbf:	e9 b8 00 00 00       	jmp    f0103d7c <.L34+0x22>
	else if (lflag)
f0103cc4:	85 c9                	test   %ecx,%ecx
f0103cc6:	75 1b                	jne    f0103ce3 <.L30+0x69>
		return va_arg(*ap, int);
f0103cc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ccb:	8b 30                	mov    (%eax),%esi
f0103ccd:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0103cd0:	89 f0                	mov    %esi,%eax
f0103cd2:	c1 f8 1f             	sar    $0x1f,%eax
f0103cd5:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103cd8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103cdb:	8d 40 04             	lea    0x4(%eax),%eax
f0103cde:	89 45 14             	mov    %eax,0x14(%ebp)
f0103ce1:	eb b6                	jmp    f0103c99 <.L30+0x1f>
		return va_arg(*ap, long);
f0103ce3:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ce6:	8b 30                	mov    (%eax),%esi
f0103ce8:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0103ceb:	89 f0                	mov    %esi,%eax
f0103ced:	c1 f8 1f             	sar    $0x1f,%eax
f0103cf0:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103cf3:	8b 45 14             	mov    0x14(%ebp),%eax
f0103cf6:	8d 40 04             	lea    0x4(%eax),%eax
f0103cf9:	89 45 14             	mov    %eax,0x14(%ebp)
f0103cfc:	eb 9b                	jmp    f0103c99 <.L30+0x1f>
			num = getint(&ap, lflag);
f0103cfe:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d01:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0103d04:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d09:	eb 71                	jmp    f0103d7c <.L34+0x22>

f0103d0b <.L37>:
f0103d0b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0103d0e:	83 f9 01             	cmp    $0x1,%ecx
f0103d11:	7e 15                	jle    f0103d28 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
f0103d13:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d16:	8b 10                	mov    (%eax),%edx
f0103d18:	8b 48 04             	mov    0x4(%eax),%ecx
f0103d1b:	8d 40 08             	lea    0x8(%eax),%eax
f0103d1e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103d21:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d26:	eb 54                	jmp    f0103d7c <.L34+0x22>
	else if (lflag)
f0103d28:	85 c9                	test   %ecx,%ecx
f0103d2a:	75 17                	jne    f0103d43 <.L37+0x38>
		return va_arg(*ap, unsigned int);
f0103d2c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d2f:	8b 10                	mov    (%eax),%edx
f0103d31:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d36:	8d 40 04             	lea    0x4(%eax),%eax
f0103d39:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103d3c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d41:	eb 39                	jmp    f0103d7c <.L34+0x22>
		return va_arg(*ap, unsigned long);
f0103d43:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d46:	8b 10                	mov    (%eax),%edx
f0103d48:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d4d:	8d 40 04             	lea    0x4(%eax),%eax
f0103d50:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103d53:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103d58:	eb 22                	jmp    f0103d7c <.L34+0x22>

f0103d5a <.L34>:
f0103d5a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0103d5d:	83 f9 01             	cmp    $0x1,%ecx
f0103d60:	7e 3b                	jle    f0103d9d <.L34+0x43>
		return va_arg(*ap, long long);
f0103d62:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d65:	8b 50 04             	mov    0x4(%eax),%edx
f0103d68:	8b 00                	mov    (%eax),%eax
f0103d6a:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103d6d:	8d 49 08             	lea    0x8(%ecx),%ecx
f0103d70:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
f0103d73:	89 d1                	mov    %edx,%ecx
f0103d75:	89 c2                	mov    %eax,%edx
			base = 8;
f0103d77:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
f0103d7c:	83 ec 0c             	sub    $0xc,%esp
f0103d7f:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
f0103d83:	56                   	push   %esi
f0103d84:	ff 75 e0             	pushl  -0x20(%ebp)
f0103d87:	50                   	push   %eax
f0103d88:	51                   	push   %ecx
f0103d89:	52                   	push   %edx
f0103d8a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d90:	e8 fd fa ff ff       	call   f0103892 <printnum>
			break;
f0103d95:	83 c4 20             	add    $0x20,%esp
f0103d98:	e9 19 fc ff ff       	jmp    f01039b6 <vprintfmt+0x20>
	else if (lflag)
f0103d9d:	85 c9                	test   %ecx,%ecx
f0103d9f:	75 13                	jne    f0103db4 <.L34+0x5a>
		return va_arg(*ap, int);
f0103da1:	8b 45 14             	mov    0x14(%ebp),%eax
f0103da4:	8b 10                	mov    (%eax),%edx
f0103da6:	89 d0                	mov    %edx,%eax
f0103da8:	99                   	cltd   
f0103da9:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103dac:	8d 49 04             	lea    0x4(%ecx),%ecx
f0103daf:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103db2:	eb bf                	jmp    f0103d73 <.L34+0x19>
		return va_arg(*ap, long);
f0103db4:	8b 45 14             	mov    0x14(%ebp),%eax
f0103db7:	8b 10                	mov    (%eax),%edx
f0103db9:	89 d0                	mov    %edx,%eax
f0103dbb:	99                   	cltd   
f0103dbc:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103dbf:	8d 49 04             	lea    0x4(%ecx),%ecx
f0103dc2:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103dc5:	eb ac                	jmp    f0103d73 <.L34+0x19>

f0103dc7 <.L35>:
			putch('0', putdat);
f0103dc7:	83 ec 08             	sub    $0x8,%esp
f0103dca:	ff 75 0c             	pushl  0xc(%ebp)
f0103dcd:	6a 30                	push   $0x30
f0103dcf:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103dd2:	83 c4 08             	add    $0x8,%esp
f0103dd5:	ff 75 0c             	pushl  0xc(%ebp)
f0103dd8:	6a 78                	push   $0x78
f0103dda:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0103ddd:	8b 45 14             	mov    0x14(%ebp),%eax
f0103de0:	8b 10                	mov    (%eax),%edx
f0103de2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0103de7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103dea:	8d 40 04             	lea    0x4(%eax),%eax
f0103ded:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103df0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103df5:	eb 85                	jmp    f0103d7c <.L34+0x22>

f0103df7 <.L38>:
f0103df7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0103dfa:	83 f9 01             	cmp    $0x1,%ecx
f0103dfd:	7e 18                	jle    f0103e17 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
f0103dff:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e02:	8b 10                	mov    (%eax),%edx
f0103e04:	8b 48 04             	mov    0x4(%eax),%ecx
f0103e07:	8d 40 08             	lea    0x8(%eax),%eax
f0103e0a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e0d:	b8 10 00 00 00       	mov    $0x10,%eax
f0103e12:	e9 65 ff ff ff       	jmp    f0103d7c <.L34+0x22>
	else if (lflag)
f0103e17:	85 c9                	test   %ecx,%ecx
f0103e19:	75 1a                	jne    f0103e35 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
f0103e1b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e1e:	8b 10                	mov    (%eax),%edx
f0103e20:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e25:	8d 40 04             	lea    0x4(%eax),%eax
f0103e28:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e2b:	b8 10 00 00 00       	mov    $0x10,%eax
f0103e30:	e9 47 ff ff ff       	jmp    f0103d7c <.L34+0x22>
		return va_arg(*ap, unsigned long);
f0103e35:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e38:	8b 10                	mov    (%eax),%edx
f0103e3a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e3f:	8d 40 04             	lea    0x4(%eax),%eax
f0103e42:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e45:	b8 10 00 00 00       	mov    $0x10,%eax
f0103e4a:	e9 2d ff ff ff       	jmp    f0103d7c <.L34+0x22>

f0103e4f <.L24>:
			putch(ch, putdat);
f0103e4f:	83 ec 08             	sub    $0x8,%esp
f0103e52:	ff 75 0c             	pushl  0xc(%ebp)
f0103e55:	6a 25                	push   $0x25
f0103e57:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103e5a:	83 c4 10             	add    $0x10,%esp
f0103e5d:	e9 54 fb ff ff       	jmp    f01039b6 <vprintfmt+0x20>

f0103e62 <.L21>:
			putch('%', putdat);
f0103e62:	83 ec 08             	sub    $0x8,%esp
f0103e65:	ff 75 0c             	pushl  0xc(%ebp)
f0103e68:	6a 25                	push   $0x25
f0103e6a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103e6d:	83 c4 10             	add    $0x10,%esp
f0103e70:	89 f7                	mov    %esi,%edi
f0103e72:	eb 03                	jmp    f0103e77 <.L21+0x15>
f0103e74:	83 ef 01             	sub    $0x1,%edi
f0103e77:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103e7b:	75 f7                	jne    f0103e74 <.L21+0x12>
f0103e7d:	e9 34 fb ff ff       	jmp    f01039b6 <vprintfmt+0x20>
}
f0103e82:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e85:	5b                   	pop    %ebx
f0103e86:	5e                   	pop    %esi
f0103e87:	5f                   	pop    %edi
f0103e88:	5d                   	pop    %ebp
f0103e89:	c3                   	ret    

f0103e8a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103e8a:	55                   	push   %ebp
f0103e8b:	89 e5                	mov    %esp,%ebp
f0103e8d:	53                   	push   %ebx
f0103e8e:	83 ec 14             	sub    $0x14,%esp
f0103e91:	e8 20 c3 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0103e96:	81 c3 76 44 01 00    	add    $0x14476,%ebx
f0103e9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e9f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103ea2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ea5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103ea9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103eac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103eb3:	85 c0                	test   %eax,%eax
f0103eb5:	74 2b                	je     f0103ee2 <vsnprintf+0x58>
f0103eb7:	85 d2                	test   %edx,%edx
f0103eb9:	7e 27                	jle    f0103ee2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103ebb:	ff 75 14             	pushl  0x14(%ebp)
f0103ebe:	ff 75 10             	pushl  0x10(%ebp)
f0103ec1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103ec4:	50                   	push   %eax
f0103ec5:	8d 83 50 b6 fe ff    	lea    -0x149b0(%ebx),%eax
f0103ecb:	50                   	push   %eax
f0103ecc:	e8 c5 fa ff ff       	call   f0103996 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103ed1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103ed4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103ed7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103eda:	83 c4 10             	add    $0x10,%esp
}
f0103edd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103ee0:	c9                   	leave  
f0103ee1:	c3                   	ret    
		return -E_INVAL;
f0103ee2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103ee7:	eb f4                	jmp    f0103edd <vsnprintf+0x53>

f0103ee9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103ee9:	55                   	push   %ebp
f0103eea:	89 e5                	mov    %esp,%ebp
f0103eec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103eef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103ef2:	50                   	push   %eax
f0103ef3:	ff 75 10             	pushl  0x10(%ebp)
f0103ef6:	ff 75 0c             	pushl  0xc(%ebp)
f0103ef9:	ff 75 08             	pushl  0x8(%ebp)
f0103efc:	e8 89 ff ff ff       	call   f0103e8a <vsnprintf>
	va_end(ap);

	return rc;
}
f0103f01:	c9                   	leave  
f0103f02:	c3                   	ret    

f0103f03 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103f03:	55                   	push   %ebp
f0103f04:	89 e5                	mov    %esp,%ebp
f0103f06:	57                   	push   %edi
f0103f07:	56                   	push   %esi
f0103f08:	53                   	push   %ebx
f0103f09:	83 ec 1c             	sub    $0x1c,%esp
f0103f0c:	e8 a5 c2 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0103f11:	81 c3 fb 43 01 00    	add    $0x143fb,%ebx
f0103f17:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103f1a:	85 c0                	test   %eax,%eax
f0103f1c:	74 13                	je     f0103f31 <readline+0x2e>
		cprintf("%s", prompt);
f0103f1e:	83 ec 08             	sub    $0x8,%esp
f0103f21:	50                   	push   %eax
f0103f22:	8d 83 c4 c5 fe ff    	lea    -0x13a3c(%ebx),%eax
f0103f28:	50                   	push   %eax
f0103f29:	e8 e3 f5 ff ff       	call   f0103511 <cprintf>
f0103f2e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103f31:	83 ec 0c             	sub    $0xc,%esp
f0103f34:	6a 00                	push   $0x0
f0103f36:	e8 13 c8 ff ff       	call   f010074e <iscons>
f0103f3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103f3e:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103f41:	bf 00 00 00 00       	mov    $0x0,%edi
f0103f46:	eb 46                	jmp    f0103f8e <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103f48:	83 ec 08             	sub    $0x8,%esp
f0103f4b:	50                   	push   %eax
f0103f4c:	8d 83 30 d6 fe ff    	lea    -0x129d0(%ebx),%eax
f0103f52:	50                   	push   %eax
f0103f53:	e8 b9 f5 ff ff       	call   f0103511 <cprintf>
			return NULL;
f0103f58:	83 c4 10             	add    $0x10,%esp
f0103f5b:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f63:	5b                   	pop    %ebx
f0103f64:	5e                   	pop    %esi
f0103f65:	5f                   	pop    %edi
f0103f66:	5d                   	pop    %ebp
f0103f67:	c3                   	ret    
			if (echoing)
f0103f68:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103f6c:	75 05                	jne    f0103f73 <readline+0x70>
			i--;
f0103f6e:	83 ef 01             	sub    $0x1,%edi
f0103f71:	eb 1b                	jmp    f0103f8e <readline+0x8b>
				cputchar('\b');
f0103f73:	83 ec 0c             	sub    $0xc,%esp
f0103f76:	6a 08                	push   $0x8
f0103f78:	e8 b0 c7 ff ff       	call   f010072d <cputchar>
f0103f7d:	83 c4 10             	add    $0x10,%esp
f0103f80:	eb ec                	jmp    f0103f6e <readline+0x6b>
			buf[i++] = c;
f0103f82:	89 f0                	mov    %esi,%eax
f0103f84:	88 84 3b b4 1f 00 00 	mov    %al,0x1fb4(%ebx,%edi,1)
f0103f8b:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0103f8e:	e8 aa c7 ff ff       	call   f010073d <getchar>
f0103f93:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0103f95:	85 c0                	test   %eax,%eax
f0103f97:	78 af                	js     f0103f48 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103f99:	83 f8 08             	cmp    $0x8,%eax
f0103f9c:	0f 94 c2             	sete   %dl
f0103f9f:	83 f8 7f             	cmp    $0x7f,%eax
f0103fa2:	0f 94 c0             	sete   %al
f0103fa5:	08 c2                	or     %al,%dl
f0103fa7:	74 04                	je     f0103fad <readline+0xaa>
f0103fa9:	85 ff                	test   %edi,%edi
f0103fab:	7f bb                	jg     f0103f68 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103fad:	83 fe 1f             	cmp    $0x1f,%esi
f0103fb0:	7e 1c                	jle    f0103fce <readline+0xcb>
f0103fb2:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0103fb8:	7f 14                	jg     f0103fce <readline+0xcb>
			if (echoing)
f0103fba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103fbe:	74 c2                	je     f0103f82 <readline+0x7f>
				cputchar(c);
f0103fc0:	83 ec 0c             	sub    $0xc,%esp
f0103fc3:	56                   	push   %esi
f0103fc4:	e8 64 c7 ff ff       	call   f010072d <cputchar>
f0103fc9:	83 c4 10             	add    $0x10,%esp
f0103fcc:	eb b4                	jmp    f0103f82 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0103fce:	83 fe 0a             	cmp    $0xa,%esi
f0103fd1:	74 05                	je     f0103fd8 <readline+0xd5>
f0103fd3:	83 fe 0d             	cmp    $0xd,%esi
f0103fd6:	75 b6                	jne    f0103f8e <readline+0x8b>
			if (echoing)
f0103fd8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103fdc:	75 13                	jne    f0103ff1 <readline+0xee>
			buf[i] = 0;
f0103fde:	c6 84 3b b4 1f 00 00 	movb   $0x0,0x1fb4(%ebx,%edi,1)
f0103fe5:	00 
			return buf;
f0103fe6:	8d 83 b4 1f 00 00    	lea    0x1fb4(%ebx),%eax
f0103fec:	e9 6f ff ff ff       	jmp    f0103f60 <readline+0x5d>
				cputchar('\n');
f0103ff1:	83 ec 0c             	sub    $0xc,%esp
f0103ff4:	6a 0a                	push   $0xa
f0103ff6:	e8 32 c7 ff ff       	call   f010072d <cputchar>
f0103ffb:	83 c4 10             	add    $0x10,%esp
f0103ffe:	eb de                	jmp    f0103fde <readline+0xdb>

f0104000 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104000:	55                   	push   %ebp
f0104001:	89 e5                	mov    %esp,%ebp
f0104003:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104006:	b8 00 00 00 00       	mov    $0x0,%eax
f010400b:	eb 03                	jmp    f0104010 <strlen+0x10>
		n++;
f010400d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104010:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104014:	75 f7                	jne    f010400d <strlen+0xd>
	return n;
}
f0104016:	5d                   	pop    %ebp
f0104017:	c3                   	ret    

f0104018 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104018:	55                   	push   %ebp
f0104019:	89 e5                	mov    %esp,%ebp
f010401b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010401e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104021:	b8 00 00 00 00       	mov    $0x0,%eax
f0104026:	eb 03                	jmp    f010402b <strnlen+0x13>
		n++;
f0104028:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010402b:	39 d0                	cmp    %edx,%eax
f010402d:	74 06                	je     f0104035 <strnlen+0x1d>
f010402f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104033:	75 f3                	jne    f0104028 <strnlen+0x10>
	return n;
}
f0104035:	5d                   	pop    %ebp
f0104036:	c3                   	ret    

f0104037 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104037:	55                   	push   %ebp
f0104038:	89 e5                	mov    %esp,%ebp
f010403a:	53                   	push   %ebx
f010403b:	8b 45 08             	mov    0x8(%ebp),%eax
f010403e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104041:	89 c2                	mov    %eax,%edx
f0104043:	83 c1 01             	add    $0x1,%ecx
f0104046:	83 c2 01             	add    $0x1,%edx
f0104049:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010404d:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104050:	84 db                	test   %bl,%bl
f0104052:	75 ef                	jne    f0104043 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104054:	5b                   	pop    %ebx
f0104055:	5d                   	pop    %ebp
f0104056:	c3                   	ret    

f0104057 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104057:	55                   	push   %ebp
f0104058:	89 e5                	mov    %esp,%ebp
f010405a:	53                   	push   %ebx
f010405b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010405e:	53                   	push   %ebx
f010405f:	e8 9c ff ff ff       	call   f0104000 <strlen>
f0104064:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104067:	ff 75 0c             	pushl  0xc(%ebp)
f010406a:	01 d8                	add    %ebx,%eax
f010406c:	50                   	push   %eax
f010406d:	e8 c5 ff ff ff       	call   f0104037 <strcpy>
	return dst;
}
f0104072:	89 d8                	mov    %ebx,%eax
f0104074:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104077:	c9                   	leave  
f0104078:	c3                   	ret    

f0104079 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104079:	55                   	push   %ebp
f010407a:	89 e5                	mov    %esp,%ebp
f010407c:	56                   	push   %esi
f010407d:	53                   	push   %ebx
f010407e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104081:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104084:	89 f3                	mov    %esi,%ebx
f0104086:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104089:	89 f2                	mov    %esi,%edx
f010408b:	eb 0f                	jmp    f010409c <strncpy+0x23>
		*dst++ = *src;
f010408d:	83 c2 01             	add    $0x1,%edx
f0104090:	0f b6 01             	movzbl (%ecx),%eax
f0104093:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104096:	80 39 01             	cmpb   $0x1,(%ecx)
f0104099:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f010409c:	39 da                	cmp    %ebx,%edx
f010409e:	75 ed                	jne    f010408d <strncpy+0x14>
	}
	return ret;
}
f01040a0:	89 f0                	mov    %esi,%eax
f01040a2:	5b                   	pop    %ebx
f01040a3:	5e                   	pop    %esi
f01040a4:	5d                   	pop    %ebp
f01040a5:	c3                   	ret    

f01040a6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01040a6:	55                   	push   %ebp
f01040a7:	89 e5                	mov    %esp,%ebp
f01040a9:	56                   	push   %esi
f01040aa:	53                   	push   %ebx
f01040ab:	8b 75 08             	mov    0x8(%ebp),%esi
f01040ae:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01040b4:	89 f0                	mov    %esi,%eax
f01040b6:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01040ba:	85 c9                	test   %ecx,%ecx
f01040bc:	75 0b                	jne    f01040c9 <strlcpy+0x23>
f01040be:	eb 17                	jmp    f01040d7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01040c0:	83 c2 01             	add    $0x1,%edx
f01040c3:	83 c0 01             	add    $0x1,%eax
f01040c6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f01040c9:	39 d8                	cmp    %ebx,%eax
f01040cb:	74 07                	je     f01040d4 <strlcpy+0x2e>
f01040cd:	0f b6 0a             	movzbl (%edx),%ecx
f01040d0:	84 c9                	test   %cl,%cl
f01040d2:	75 ec                	jne    f01040c0 <strlcpy+0x1a>
		*dst = '\0';
f01040d4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01040d7:	29 f0                	sub    %esi,%eax
}
f01040d9:	5b                   	pop    %ebx
f01040da:	5e                   	pop    %esi
f01040db:	5d                   	pop    %ebp
f01040dc:	c3                   	ret    

f01040dd <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01040dd:	55                   	push   %ebp
f01040de:	89 e5                	mov    %esp,%ebp
f01040e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01040e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01040e6:	eb 06                	jmp    f01040ee <strcmp+0x11>
		p++, q++;
f01040e8:	83 c1 01             	add    $0x1,%ecx
f01040eb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01040ee:	0f b6 01             	movzbl (%ecx),%eax
f01040f1:	84 c0                	test   %al,%al
f01040f3:	74 04                	je     f01040f9 <strcmp+0x1c>
f01040f5:	3a 02                	cmp    (%edx),%al
f01040f7:	74 ef                	je     f01040e8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01040f9:	0f b6 c0             	movzbl %al,%eax
f01040fc:	0f b6 12             	movzbl (%edx),%edx
f01040ff:	29 d0                	sub    %edx,%eax
}
f0104101:	5d                   	pop    %ebp
f0104102:	c3                   	ret    

f0104103 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104103:	55                   	push   %ebp
f0104104:	89 e5                	mov    %esp,%ebp
f0104106:	53                   	push   %ebx
f0104107:	8b 45 08             	mov    0x8(%ebp),%eax
f010410a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010410d:	89 c3                	mov    %eax,%ebx
f010410f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104112:	eb 06                	jmp    f010411a <strncmp+0x17>
		n--, p++, q++;
f0104114:	83 c0 01             	add    $0x1,%eax
f0104117:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f010411a:	39 d8                	cmp    %ebx,%eax
f010411c:	74 16                	je     f0104134 <strncmp+0x31>
f010411e:	0f b6 08             	movzbl (%eax),%ecx
f0104121:	84 c9                	test   %cl,%cl
f0104123:	74 04                	je     f0104129 <strncmp+0x26>
f0104125:	3a 0a                	cmp    (%edx),%cl
f0104127:	74 eb                	je     f0104114 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104129:	0f b6 00             	movzbl (%eax),%eax
f010412c:	0f b6 12             	movzbl (%edx),%edx
f010412f:	29 d0                	sub    %edx,%eax
}
f0104131:	5b                   	pop    %ebx
f0104132:	5d                   	pop    %ebp
f0104133:	c3                   	ret    
		return 0;
f0104134:	b8 00 00 00 00       	mov    $0x0,%eax
f0104139:	eb f6                	jmp    f0104131 <strncmp+0x2e>

f010413b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010413b:	55                   	push   %ebp
f010413c:	89 e5                	mov    %esp,%ebp
f010413e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104141:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104145:	0f b6 10             	movzbl (%eax),%edx
f0104148:	84 d2                	test   %dl,%dl
f010414a:	74 09                	je     f0104155 <strchr+0x1a>
		if (*s == c)
f010414c:	38 ca                	cmp    %cl,%dl
f010414e:	74 0a                	je     f010415a <strchr+0x1f>
	for (; *s; s++)
f0104150:	83 c0 01             	add    $0x1,%eax
f0104153:	eb f0                	jmp    f0104145 <strchr+0xa>
			return (char *) s;
	return 0;
f0104155:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010415a:	5d                   	pop    %ebp
f010415b:	c3                   	ret    

f010415c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010415c:	55                   	push   %ebp
f010415d:	89 e5                	mov    %esp,%ebp
f010415f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104162:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104166:	eb 03                	jmp    f010416b <strfind+0xf>
f0104168:	83 c0 01             	add    $0x1,%eax
f010416b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010416e:	38 ca                	cmp    %cl,%dl
f0104170:	74 04                	je     f0104176 <strfind+0x1a>
f0104172:	84 d2                	test   %dl,%dl
f0104174:	75 f2                	jne    f0104168 <strfind+0xc>
			break;
	return (char *) s;
}
f0104176:	5d                   	pop    %ebp
f0104177:	c3                   	ret    

f0104178 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104178:	55                   	push   %ebp
f0104179:	89 e5                	mov    %esp,%ebp
f010417b:	57                   	push   %edi
f010417c:	56                   	push   %esi
f010417d:	53                   	push   %ebx
f010417e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104181:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104184:	85 c9                	test   %ecx,%ecx
f0104186:	74 13                	je     f010419b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104188:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010418e:	75 05                	jne    f0104195 <memset+0x1d>
f0104190:	f6 c1 03             	test   $0x3,%cl
f0104193:	74 0d                	je     f01041a2 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104195:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104198:	fc                   	cld    
f0104199:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010419b:	89 f8                	mov    %edi,%eax
f010419d:	5b                   	pop    %ebx
f010419e:	5e                   	pop    %esi
f010419f:	5f                   	pop    %edi
f01041a0:	5d                   	pop    %ebp
f01041a1:	c3                   	ret    
		c &= 0xFF;
f01041a2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01041a6:	89 d3                	mov    %edx,%ebx
f01041a8:	c1 e3 08             	shl    $0x8,%ebx
f01041ab:	89 d0                	mov    %edx,%eax
f01041ad:	c1 e0 18             	shl    $0x18,%eax
f01041b0:	89 d6                	mov    %edx,%esi
f01041b2:	c1 e6 10             	shl    $0x10,%esi
f01041b5:	09 f0                	or     %esi,%eax
f01041b7:	09 c2                	or     %eax,%edx
f01041b9:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f01041bb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f01041be:	89 d0                	mov    %edx,%eax
f01041c0:	fc                   	cld    
f01041c1:	f3 ab                	rep stos %eax,%es:(%edi)
f01041c3:	eb d6                	jmp    f010419b <memset+0x23>

f01041c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01041c5:	55                   	push   %ebp
f01041c6:	89 e5                	mov    %esp,%ebp
f01041c8:	57                   	push   %edi
f01041c9:	56                   	push   %esi
f01041ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01041cd:	8b 75 0c             	mov    0xc(%ebp),%esi
f01041d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01041d3:	39 c6                	cmp    %eax,%esi
f01041d5:	73 35                	jae    f010420c <memmove+0x47>
f01041d7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01041da:	39 c2                	cmp    %eax,%edx
f01041dc:	76 2e                	jbe    f010420c <memmove+0x47>
		s += n;
		d += n;
f01041de:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01041e1:	89 d6                	mov    %edx,%esi
f01041e3:	09 fe                	or     %edi,%esi
f01041e5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01041eb:	74 0c                	je     f01041f9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01041ed:	83 ef 01             	sub    $0x1,%edi
f01041f0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01041f3:	fd                   	std    
f01041f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01041f6:	fc                   	cld    
f01041f7:	eb 21                	jmp    f010421a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01041f9:	f6 c1 03             	test   $0x3,%cl
f01041fc:	75 ef                	jne    f01041ed <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01041fe:	83 ef 04             	sub    $0x4,%edi
f0104201:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104204:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104207:	fd                   	std    
f0104208:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010420a:	eb ea                	jmp    f01041f6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010420c:	89 f2                	mov    %esi,%edx
f010420e:	09 c2                	or     %eax,%edx
f0104210:	f6 c2 03             	test   $0x3,%dl
f0104213:	74 09                	je     f010421e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104215:	89 c7                	mov    %eax,%edi
f0104217:	fc                   	cld    
f0104218:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010421a:	5e                   	pop    %esi
f010421b:	5f                   	pop    %edi
f010421c:	5d                   	pop    %ebp
f010421d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010421e:	f6 c1 03             	test   $0x3,%cl
f0104221:	75 f2                	jne    f0104215 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104223:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104226:	89 c7                	mov    %eax,%edi
f0104228:	fc                   	cld    
f0104229:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010422b:	eb ed                	jmp    f010421a <memmove+0x55>

f010422d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010422d:	55                   	push   %ebp
f010422e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104230:	ff 75 10             	pushl  0x10(%ebp)
f0104233:	ff 75 0c             	pushl  0xc(%ebp)
f0104236:	ff 75 08             	pushl  0x8(%ebp)
f0104239:	e8 87 ff ff ff       	call   f01041c5 <memmove>
}
f010423e:	c9                   	leave  
f010423f:	c3                   	ret    

f0104240 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104240:	55                   	push   %ebp
f0104241:	89 e5                	mov    %esp,%ebp
f0104243:	56                   	push   %esi
f0104244:	53                   	push   %ebx
f0104245:	8b 45 08             	mov    0x8(%ebp),%eax
f0104248:	8b 55 0c             	mov    0xc(%ebp),%edx
f010424b:	89 c6                	mov    %eax,%esi
f010424d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104250:	39 f0                	cmp    %esi,%eax
f0104252:	74 1c                	je     f0104270 <memcmp+0x30>
		if (*s1 != *s2)
f0104254:	0f b6 08             	movzbl (%eax),%ecx
f0104257:	0f b6 1a             	movzbl (%edx),%ebx
f010425a:	38 d9                	cmp    %bl,%cl
f010425c:	75 08                	jne    f0104266 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010425e:	83 c0 01             	add    $0x1,%eax
f0104261:	83 c2 01             	add    $0x1,%edx
f0104264:	eb ea                	jmp    f0104250 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104266:	0f b6 c1             	movzbl %cl,%eax
f0104269:	0f b6 db             	movzbl %bl,%ebx
f010426c:	29 d8                	sub    %ebx,%eax
f010426e:	eb 05                	jmp    f0104275 <memcmp+0x35>
	}

	return 0;
f0104270:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104275:	5b                   	pop    %ebx
f0104276:	5e                   	pop    %esi
f0104277:	5d                   	pop    %ebp
f0104278:	c3                   	ret    

f0104279 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104279:	55                   	push   %ebp
f010427a:	89 e5                	mov    %esp,%ebp
f010427c:	8b 45 08             	mov    0x8(%ebp),%eax
f010427f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104282:	89 c2                	mov    %eax,%edx
f0104284:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104287:	39 d0                	cmp    %edx,%eax
f0104289:	73 09                	jae    f0104294 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010428b:	38 08                	cmp    %cl,(%eax)
f010428d:	74 05                	je     f0104294 <memfind+0x1b>
	for (; s < ends; s++)
f010428f:	83 c0 01             	add    $0x1,%eax
f0104292:	eb f3                	jmp    f0104287 <memfind+0xe>
			break;
	return (void *) s;
}
f0104294:	5d                   	pop    %ebp
f0104295:	c3                   	ret    

f0104296 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104296:	55                   	push   %ebp
f0104297:	89 e5                	mov    %esp,%ebp
f0104299:	57                   	push   %edi
f010429a:	56                   	push   %esi
f010429b:	53                   	push   %ebx
f010429c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010429f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01042a2:	eb 03                	jmp    f01042a7 <strtol+0x11>
		s++;
f01042a4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01042a7:	0f b6 01             	movzbl (%ecx),%eax
f01042aa:	3c 20                	cmp    $0x20,%al
f01042ac:	74 f6                	je     f01042a4 <strtol+0xe>
f01042ae:	3c 09                	cmp    $0x9,%al
f01042b0:	74 f2                	je     f01042a4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01042b2:	3c 2b                	cmp    $0x2b,%al
f01042b4:	74 2e                	je     f01042e4 <strtol+0x4e>
	int neg = 0;
f01042b6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01042bb:	3c 2d                	cmp    $0x2d,%al
f01042bd:	74 2f                	je     f01042ee <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01042bf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01042c5:	75 05                	jne    f01042cc <strtol+0x36>
f01042c7:	80 39 30             	cmpb   $0x30,(%ecx)
f01042ca:	74 2c                	je     f01042f8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01042cc:	85 db                	test   %ebx,%ebx
f01042ce:	75 0a                	jne    f01042da <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01042d0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01042d5:	80 39 30             	cmpb   $0x30,(%ecx)
f01042d8:	74 28                	je     f0104302 <strtol+0x6c>
		base = 10;
f01042da:	b8 00 00 00 00       	mov    $0x0,%eax
f01042df:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01042e2:	eb 50                	jmp    f0104334 <strtol+0x9e>
		s++;
f01042e4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01042e7:	bf 00 00 00 00       	mov    $0x0,%edi
f01042ec:	eb d1                	jmp    f01042bf <strtol+0x29>
		s++, neg = 1;
f01042ee:	83 c1 01             	add    $0x1,%ecx
f01042f1:	bf 01 00 00 00       	mov    $0x1,%edi
f01042f6:	eb c7                	jmp    f01042bf <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01042f8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01042fc:	74 0e                	je     f010430c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01042fe:	85 db                	test   %ebx,%ebx
f0104300:	75 d8                	jne    f01042da <strtol+0x44>
		s++, base = 8;
f0104302:	83 c1 01             	add    $0x1,%ecx
f0104305:	bb 08 00 00 00       	mov    $0x8,%ebx
f010430a:	eb ce                	jmp    f01042da <strtol+0x44>
		s += 2, base = 16;
f010430c:	83 c1 02             	add    $0x2,%ecx
f010430f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104314:	eb c4                	jmp    f01042da <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104316:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104319:	89 f3                	mov    %esi,%ebx
f010431b:	80 fb 19             	cmp    $0x19,%bl
f010431e:	77 29                	ja     f0104349 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0104320:	0f be d2             	movsbl %dl,%edx
f0104323:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104326:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104329:	7d 30                	jge    f010435b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010432b:	83 c1 01             	add    $0x1,%ecx
f010432e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104332:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104334:	0f b6 11             	movzbl (%ecx),%edx
f0104337:	8d 72 d0             	lea    -0x30(%edx),%esi
f010433a:	89 f3                	mov    %esi,%ebx
f010433c:	80 fb 09             	cmp    $0x9,%bl
f010433f:	77 d5                	ja     f0104316 <strtol+0x80>
			dig = *s - '0';
f0104341:	0f be d2             	movsbl %dl,%edx
f0104344:	83 ea 30             	sub    $0x30,%edx
f0104347:	eb dd                	jmp    f0104326 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0104349:	8d 72 bf             	lea    -0x41(%edx),%esi
f010434c:	89 f3                	mov    %esi,%ebx
f010434e:	80 fb 19             	cmp    $0x19,%bl
f0104351:	77 08                	ja     f010435b <strtol+0xc5>
			dig = *s - 'A' + 10;
f0104353:	0f be d2             	movsbl %dl,%edx
f0104356:	83 ea 37             	sub    $0x37,%edx
f0104359:	eb cb                	jmp    f0104326 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010435b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010435f:	74 05                	je     f0104366 <strtol+0xd0>
		*endptr = (char *) s;
f0104361:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104364:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104366:	89 c2                	mov    %eax,%edx
f0104368:	f7 da                	neg    %edx
f010436a:	85 ff                	test   %edi,%edi
f010436c:	0f 45 c2             	cmovne %edx,%eax
}
f010436f:	5b                   	pop    %ebx
f0104370:	5e                   	pop    %esi
f0104371:	5f                   	pop    %edi
f0104372:	5d                   	pop    %ebp
f0104373:	c3                   	ret    
f0104374:	66 90                	xchg   %ax,%ax
f0104376:	66 90                	xchg   %ax,%ax
f0104378:	66 90                	xchg   %ax,%ax
f010437a:	66 90                	xchg   %ax,%ax
f010437c:	66 90                	xchg   %ax,%ax
f010437e:	66 90                	xchg   %ax,%ax

f0104380 <__udivdi3>:
f0104380:	55                   	push   %ebp
f0104381:	57                   	push   %edi
f0104382:	56                   	push   %esi
f0104383:	53                   	push   %ebx
f0104384:	83 ec 1c             	sub    $0x1c,%esp
f0104387:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010438b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010438f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104393:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0104397:	85 d2                	test   %edx,%edx
f0104399:	75 35                	jne    f01043d0 <__udivdi3+0x50>
f010439b:	39 f3                	cmp    %esi,%ebx
f010439d:	0f 87 bd 00 00 00    	ja     f0104460 <__udivdi3+0xe0>
f01043a3:	85 db                	test   %ebx,%ebx
f01043a5:	89 d9                	mov    %ebx,%ecx
f01043a7:	75 0b                	jne    f01043b4 <__udivdi3+0x34>
f01043a9:	b8 01 00 00 00       	mov    $0x1,%eax
f01043ae:	31 d2                	xor    %edx,%edx
f01043b0:	f7 f3                	div    %ebx
f01043b2:	89 c1                	mov    %eax,%ecx
f01043b4:	31 d2                	xor    %edx,%edx
f01043b6:	89 f0                	mov    %esi,%eax
f01043b8:	f7 f1                	div    %ecx
f01043ba:	89 c6                	mov    %eax,%esi
f01043bc:	89 e8                	mov    %ebp,%eax
f01043be:	89 f7                	mov    %esi,%edi
f01043c0:	f7 f1                	div    %ecx
f01043c2:	89 fa                	mov    %edi,%edx
f01043c4:	83 c4 1c             	add    $0x1c,%esp
f01043c7:	5b                   	pop    %ebx
f01043c8:	5e                   	pop    %esi
f01043c9:	5f                   	pop    %edi
f01043ca:	5d                   	pop    %ebp
f01043cb:	c3                   	ret    
f01043cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01043d0:	39 f2                	cmp    %esi,%edx
f01043d2:	77 7c                	ja     f0104450 <__udivdi3+0xd0>
f01043d4:	0f bd fa             	bsr    %edx,%edi
f01043d7:	83 f7 1f             	xor    $0x1f,%edi
f01043da:	0f 84 98 00 00 00    	je     f0104478 <__udivdi3+0xf8>
f01043e0:	89 f9                	mov    %edi,%ecx
f01043e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01043e7:	29 f8                	sub    %edi,%eax
f01043e9:	d3 e2                	shl    %cl,%edx
f01043eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01043ef:	89 c1                	mov    %eax,%ecx
f01043f1:	89 da                	mov    %ebx,%edx
f01043f3:	d3 ea                	shr    %cl,%edx
f01043f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01043f9:	09 d1                	or     %edx,%ecx
f01043fb:	89 f2                	mov    %esi,%edx
f01043fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104401:	89 f9                	mov    %edi,%ecx
f0104403:	d3 e3                	shl    %cl,%ebx
f0104405:	89 c1                	mov    %eax,%ecx
f0104407:	d3 ea                	shr    %cl,%edx
f0104409:	89 f9                	mov    %edi,%ecx
f010440b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010440f:	d3 e6                	shl    %cl,%esi
f0104411:	89 eb                	mov    %ebp,%ebx
f0104413:	89 c1                	mov    %eax,%ecx
f0104415:	d3 eb                	shr    %cl,%ebx
f0104417:	09 de                	or     %ebx,%esi
f0104419:	89 f0                	mov    %esi,%eax
f010441b:	f7 74 24 08          	divl   0x8(%esp)
f010441f:	89 d6                	mov    %edx,%esi
f0104421:	89 c3                	mov    %eax,%ebx
f0104423:	f7 64 24 0c          	mull   0xc(%esp)
f0104427:	39 d6                	cmp    %edx,%esi
f0104429:	72 0c                	jb     f0104437 <__udivdi3+0xb7>
f010442b:	89 f9                	mov    %edi,%ecx
f010442d:	d3 e5                	shl    %cl,%ebp
f010442f:	39 c5                	cmp    %eax,%ebp
f0104431:	73 5d                	jae    f0104490 <__udivdi3+0x110>
f0104433:	39 d6                	cmp    %edx,%esi
f0104435:	75 59                	jne    f0104490 <__udivdi3+0x110>
f0104437:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010443a:	31 ff                	xor    %edi,%edi
f010443c:	89 fa                	mov    %edi,%edx
f010443e:	83 c4 1c             	add    $0x1c,%esp
f0104441:	5b                   	pop    %ebx
f0104442:	5e                   	pop    %esi
f0104443:	5f                   	pop    %edi
f0104444:	5d                   	pop    %ebp
f0104445:	c3                   	ret    
f0104446:	8d 76 00             	lea    0x0(%esi),%esi
f0104449:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0104450:	31 ff                	xor    %edi,%edi
f0104452:	31 c0                	xor    %eax,%eax
f0104454:	89 fa                	mov    %edi,%edx
f0104456:	83 c4 1c             	add    $0x1c,%esp
f0104459:	5b                   	pop    %ebx
f010445a:	5e                   	pop    %esi
f010445b:	5f                   	pop    %edi
f010445c:	5d                   	pop    %ebp
f010445d:	c3                   	ret    
f010445e:	66 90                	xchg   %ax,%ax
f0104460:	31 ff                	xor    %edi,%edi
f0104462:	89 e8                	mov    %ebp,%eax
f0104464:	89 f2                	mov    %esi,%edx
f0104466:	f7 f3                	div    %ebx
f0104468:	89 fa                	mov    %edi,%edx
f010446a:	83 c4 1c             	add    $0x1c,%esp
f010446d:	5b                   	pop    %ebx
f010446e:	5e                   	pop    %esi
f010446f:	5f                   	pop    %edi
f0104470:	5d                   	pop    %ebp
f0104471:	c3                   	ret    
f0104472:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104478:	39 f2                	cmp    %esi,%edx
f010447a:	72 06                	jb     f0104482 <__udivdi3+0x102>
f010447c:	31 c0                	xor    %eax,%eax
f010447e:	39 eb                	cmp    %ebp,%ebx
f0104480:	77 d2                	ja     f0104454 <__udivdi3+0xd4>
f0104482:	b8 01 00 00 00       	mov    $0x1,%eax
f0104487:	eb cb                	jmp    f0104454 <__udivdi3+0xd4>
f0104489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104490:	89 d8                	mov    %ebx,%eax
f0104492:	31 ff                	xor    %edi,%edi
f0104494:	eb be                	jmp    f0104454 <__udivdi3+0xd4>
f0104496:	66 90                	xchg   %ax,%ax
f0104498:	66 90                	xchg   %ax,%ax
f010449a:	66 90                	xchg   %ax,%ax
f010449c:	66 90                	xchg   %ax,%ax
f010449e:	66 90                	xchg   %ax,%ax

f01044a0 <__umoddi3>:
f01044a0:	55                   	push   %ebp
f01044a1:	57                   	push   %edi
f01044a2:	56                   	push   %esi
f01044a3:	53                   	push   %ebx
f01044a4:	83 ec 1c             	sub    $0x1c,%esp
f01044a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01044ab:	8b 74 24 30          	mov    0x30(%esp),%esi
f01044af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01044b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01044b7:	85 ed                	test   %ebp,%ebp
f01044b9:	89 f0                	mov    %esi,%eax
f01044bb:	89 da                	mov    %ebx,%edx
f01044bd:	75 19                	jne    f01044d8 <__umoddi3+0x38>
f01044bf:	39 df                	cmp    %ebx,%edi
f01044c1:	0f 86 b1 00 00 00    	jbe    f0104578 <__umoddi3+0xd8>
f01044c7:	f7 f7                	div    %edi
f01044c9:	89 d0                	mov    %edx,%eax
f01044cb:	31 d2                	xor    %edx,%edx
f01044cd:	83 c4 1c             	add    $0x1c,%esp
f01044d0:	5b                   	pop    %ebx
f01044d1:	5e                   	pop    %esi
f01044d2:	5f                   	pop    %edi
f01044d3:	5d                   	pop    %ebp
f01044d4:	c3                   	ret    
f01044d5:	8d 76 00             	lea    0x0(%esi),%esi
f01044d8:	39 dd                	cmp    %ebx,%ebp
f01044da:	77 f1                	ja     f01044cd <__umoddi3+0x2d>
f01044dc:	0f bd cd             	bsr    %ebp,%ecx
f01044df:	83 f1 1f             	xor    $0x1f,%ecx
f01044e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01044e6:	0f 84 b4 00 00 00    	je     f01045a0 <__umoddi3+0x100>
f01044ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01044f1:	89 c2                	mov    %eax,%edx
f01044f3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01044f7:	29 c2                	sub    %eax,%edx
f01044f9:	89 c1                	mov    %eax,%ecx
f01044fb:	89 f8                	mov    %edi,%eax
f01044fd:	d3 e5                	shl    %cl,%ebp
f01044ff:	89 d1                	mov    %edx,%ecx
f0104501:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104505:	d3 e8                	shr    %cl,%eax
f0104507:	09 c5                	or     %eax,%ebp
f0104509:	8b 44 24 04          	mov    0x4(%esp),%eax
f010450d:	89 c1                	mov    %eax,%ecx
f010450f:	d3 e7                	shl    %cl,%edi
f0104511:	89 d1                	mov    %edx,%ecx
f0104513:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104517:	89 df                	mov    %ebx,%edi
f0104519:	d3 ef                	shr    %cl,%edi
f010451b:	89 c1                	mov    %eax,%ecx
f010451d:	89 f0                	mov    %esi,%eax
f010451f:	d3 e3                	shl    %cl,%ebx
f0104521:	89 d1                	mov    %edx,%ecx
f0104523:	89 fa                	mov    %edi,%edx
f0104525:	d3 e8                	shr    %cl,%eax
f0104527:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010452c:	09 d8                	or     %ebx,%eax
f010452e:	f7 f5                	div    %ebp
f0104530:	d3 e6                	shl    %cl,%esi
f0104532:	89 d1                	mov    %edx,%ecx
f0104534:	f7 64 24 08          	mull   0x8(%esp)
f0104538:	39 d1                	cmp    %edx,%ecx
f010453a:	89 c3                	mov    %eax,%ebx
f010453c:	89 d7                	mov    %edx,%edi
f010453e:	72 06                	jb     f0104546 <__umoddi3+0xa6>
f0104540:	75 0e                	jne    f0104550 <__umoddi3+0xb0>
f0104542:	39 c6                	cmp    %eax,%esi
f0104544:	73 0a                	jae    f0104550 <__umoddi3+0xb0>
f0104546:	2b 44 24 08          	sub    0x8(%esp),%eax
f010454a:	19 ea                	sbb    %ebp,%edx
f010454c:	89 d7                	mov    %edx,%edi
f010454e:	89 c3                	mov    %eax,%ebx
f0104550:	89 ca                	mov    %ecx,%edx
f0104552:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0104557:	29 de                	sub    %ebx,%esi
f0104559:	19 fa                	sbb    %edi,%edx
f010455b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010455f:	89 d0                	mov    %edx,%eax
f0104561:	d3 e0                	shl    %cl,%eax
f0104563:	89 d9                	mov    %ebx,%ecx
f0104565:	d3 ee                	shr    %cl,%esi
f0104567:	d3 ea                	shr    %cl,%edx
f0104569:	09 f0                	or     %esi,%eax
f010456b:	83 c4 1c             	add    $0x1c,%esp
f010456e:	5b                   	pop    %ebx
f010456f:	5e                   	pop    %esi
f0104570:	5f                   	pop    %edi
f0104571:	5d                   	pop    %ebp
f0104572:	c3                   	ret    
f0104573:	90                   	nop
f0104574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104578:	85 ff                	test   %edi,%edi
f010457a:	89 f9                	mov    %edi,%ecx
f010457c:	75 0b                	jne    f0104589 <__umoddi3+0xe9>
f010457e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104583:	31 d2                	xor    %edx,%edx
f0104585:	f7 f7                	div    %edi
f0104587:	89 c1                	mov    %eax,%ecx
f0104589:	89 d8                	mov    %ebx,%eax
f010458b:	31 d2                	xor    %edx,%edx
f010458d:	f7 f1                	div    %ecx
f010458f:	89 f0                	mov    %esi,%eax
f0104591:	f7 f1                	div    %ecx
f0104593:	e9 31 ff ff ff       	jmp    f01044c9 <__umoddi3+0x29>
f0104598:	90                   	nop
f0104599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01045a0:	39 dd                	cmp    %ebx,%ebp
f01045a2:	72 08                	jb     f01045ac <__umoddi3+0x10c>
f01045a4:	39 f7                	cmp    %esi,%edi
f01045a6:	0f 87 21 ff ff ff    	ja     f01044cd <__umoddi3+0x2d>
f01045ac:	89 da                	mov    %ebx,%edx
f01045ae:	89 f0                	mov    %esi,%eax
f01045b0:	29 f8                	sub    %edi,%eax
f01045b2:	19 ea                	sbb    %ebp,%edx
f01045b4:	e9 14 ff ff ff       	jmp    f01044cd <__umoddi3+0x2d>
