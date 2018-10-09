
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
f0100015:	b8 00 a0 11 00       	mov    $0x11a000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

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
f010004a:	81 c3 c2 92 01 00    	add    $0x192c2,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %08d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 14 b6 fe ff    	lea    -0x149ec(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 04 38 00 00       	call   f0103867 <cprintf>
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
f0100073:	e8 04 08 00 00       	call   f010087c <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	}
	cprintf("leaving test_backtrace %08d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 32 b6 fe ff    	lea    -0x149ce(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 dc 37 00 00       	call   f0103867 <cprintf>
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
f01000b2:	81 c3 5a 92 01 00    	add    $0x1925a,%ebx
	extern char edata[], end[];
	
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 a0 b0 11 f0    	mov    $0xf011b0a0,%edx
f01000be:	c7 c0 e0 b6 11 f0    	mov    $0xf011b6e0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 ff 43 00 00       	call   f01044ce <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 37 05 00 00       	call   f010060b <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 4f b6 fe ff    	lea    -0x149b1(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 7f 37 00 00       	call   f0103867 <cprintf>

	// test_backtrace(5);

	// Lab 2 memory management initialization functions
	mem_init();
f01000e8:	e8 e3 19 00 00       	call   f0101ad0 <mem_init>
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
f01000f6:	e8 15 0f 00 00       	call   f0101010 <monitor>
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
f010010e:	81 c3 fe 91 01 00    	add    $0x191fe,%ebx
f0100114:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100117:	c7 c0 e4 b6 11 f0    	mov    $0xf011b6e4,%eax
f010011d:	83 38 00             	cmpl   $0x0,(%eax)
f0100120:	74 0f                	je     f0100131 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100122:	83 ec 0c             	sub    $0xc,%esp
f0100125:	6a 00                	push   $0x0
f0100127:	e8 e4 0e 00 00       	call   f0101010 <monitor>
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
f0100141:	8d 83 6a b6 fe ff    	lea    -0x14996(%ebx),%eax
f0100147:	50                   	push   %eax
f0100148:	e8 1a 37 00 00       	call   f0103867 <cprintf>
	vcprintf(fmt, ap);
f010014d:	83 c4 08             	add    $0x8,%esp
f0100150:	56                   	push   %esi
f0100151:	57                   	push   %edi
f0100152:	e8 d9 36 00 00       	call   f0103830 <vcprintf>
	cprintf("\n");
f0100157:	8d 83 05 c9 fe ff    	lea    -0x136fb(%ebx),%eax
f010015d:	89 04 24             	mov    %eax,(%esp)
f0100160:	e8 02 37 00 00       	call   f0103867 <cprintf>
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
f0100174:	81 c3 98 91 01 00    	add    $0x19198,%ebx
	va_list ap;

	va_start(ap, fmt);
f010017a:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010017d:	83 ec 04             	sub    $0x4,%esp
f0100180:	ff 75 0c             	pushl  0xc(%ebp)
f0100183:	ff 75 08             	pushl  0x8(%ebp)
f0100186:	8d 83 82 b6 fe ff    	lea    -0x1497e(%ebx),%eax
f010018c:	50                   	push   %eax
f010018d:	e8 d5 36 00 00       	call   f0103867 <cprintf>
	vcprintf(fmt, ap);
f0100192:	83 c4 08             	add    $0x8,%esp
f0100195:	56                   	push   %esi
f0100196:	ff 75 10             	pushl  0x10(%ebp)
f0100199:	e8 92 36 00 00       	call   f0103830 <vcprintf>
	cprintf("\n");
f010019e:	8d 83 05 c9 fe ff    	lea    -0x136fb(%ebx),%eax
f01001a4:	89 04 24             	mov    %eax,(%esp)
f01001a7:	e8 bb 36 00 00       	call   f0103867 <cprintf>
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
f01001e3:	81 c3 29 91 01 00    	add    $0x19129,%ebx
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
f01001f6:	8b 8b b8 1f 00 00    	mov    0x1fb8(%ebx),%ecx
f01001fc:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ff:	89 93 b8 1f 00 00    	mov    %edx,0x1fb8(%ebx)
f0100205:	88 84 0b b4 1d 00 00 	mov    %al,0x1db4(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f010020c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100212:	75 d7                	jne    f01001eb <cons_intr+0x12>
			cons.wpos = 0;
f0100214:	c7 83 b8 1f 00 00 00 	movl   $0x0,0x1fb8(%ebx)
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
f010022e:	81 c3 de 90 01 00    	add    $0x190de,%ebx
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
f0100262:	8b 8b 94 1d 00 00    	mov    0x1d94(%ebx),%ecx
f0100268:	f6 c1 40             	test   $0x40,%cl
f010026b:	74 0e                	je     f010027b <kbd_proc_data+0x57>
		data |= 0x80;
f010026d:	83 c8 80             	or     $0xffffff80,%eax
f0100270:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100272:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100275:	89 8b 94 1d 00 00    	mov    %ecx,0x1d94(%ebx)
	shift |= shiftcode[data];
f010027b:	0f b6 d2             	movzbl %dl,%edx
f010027e:	0f b6 84 13 d4 b7 fe 	movzbl -0x1482c(%ebx,%edx,1),%eax
f0100285:	ff 
f0100286:	0b 83 94 1d 00 00    	or     0x1d94(%ebx),%eax
	shift ^= togglecode[data];
f010028c:	0f b6 8c 13 d4 b6 fe 	movzbl -0x1492c(%ebx,%edx,1),%ecx
f0100293:	ff 
f0100294:	31 c8                	xor    %ecx,%eax
f0100296:	89 83 94 1d 00 00    	mov    %eax,0x1d94(%ebx)
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
f01002d1:	8d 83 9c b6 fe ff    	lea    -0x14964(%ebx),%eax
f01002d7:	50                   	push   %eax
f01002d8:	e8 8a 35 00 00       	call   f0103867 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002dd:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e2:	ba 92 00 00 00       	mov    $0x92,%edx
f01002e7:	ee                   	out    %al,(%dx)
f01002e8:	83 c4 10             	add    $0x10,%esp
f01002eb:	eb 0c                	jmp    f01002f9 <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002ed:	83 8b 94 1d 00 00 40 	orl    $0x40,0x1d94(%ebx)
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
f0100302:	8b 8b 94 1d 00 00    	mov    0x1d94(%ebx),%ecx
f0100308:	89 ce                	mov    %ecx,%esi
f010030a:	83 e6 40             	and    $0x40,%esi
f010030d:	83 e0 7f             	and    $0x7f,%eax
f0100310:	85 f6                	test   %esi,%esi
f0100312:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100315:	0f b6 d2             	movzbl %dl,%edx
f0100318:	0f b6 84 13 d4 b7 fe 	movzbl -0x1482c(%ebx,%edx,1),%eax
f010031f:	ff 
f0100320:	83 c8 40             	or     $0x40,%eax
f0100323:	0f b6 c0             	movzbl %al,%eax
f0100326:	f7 d0                	not    %eax
f0100328:	21 c8                	and    %ecx,%eax
f010032a:	89 83 94 1d 00 00    	mov    %eax,0x1d94(%ebx)
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
f0100364:	81 c3 a8 8f 01 00    	add    $0x18fa8,%ebx
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
f0100423:	0f b7 83 bc 1f 00 00 	movzwl 0x1fbc(%ebx),%eax
f010042a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100430:	c1 e8 16             	shr    $0x16,%eax
f0100433:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100436:	c1 e0 04             	shl    $0x4,%eax
f0100439:	66 89 83 bc 1f 00 00 	mov    %ax,0x1fbc(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100440:	66 81 bb bc 1f 00 00 	cmpw   $0x7cf,0x1fbc(%ebx)
f0100447:	cf 07 
f0100449:	0f 87 d4 00 00 00    	ja     f0100523 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f010044f:	8b 8b c4 1f 00 00    	mov    0x1fc4(%ebx),%ecx
f0100455:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045a:	89 ca                	mov    %ecx,%edx
f010045c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045d:	0f b7 9b bc 1f 00 00 	movzwl 0x1fbc(%ebx),%ebx
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
f010048a:	0f b7 83 bc 1f 00 00 	movzwl 0x1fbc(%ebx),%eax
f0100491:	66 85 c0             	test   %ax,%ax
f0100494:	74 b9                	je     f010044f <cons_putc+0xf9>
			crt_pos--;
f0100496:	83 e8 01             	sub    $0x1,%eax
f0100499:	66 89 83 bc 1f 00 00 	mov    %ax,0x1fbc(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a0:	0f b7 c0             	movzwl %ax,%eax
f01004a3:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004a7:	b2 00                	mov    $0x0,%dl
f01004a9:	83 ca 20             	or     $0x20,%edx
f01004ac:	8b 8b c0 1f 00 00    	mov    0x1fc0(%ebx),%ecx
f01004b2:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004b6:	eb 88                	jmp    f0100440 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004b8:	66 83 83 bc 1f 00 00 	addw   $0x50,0x1fbc(%ebx)
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
f01004fc:	0f b7 83 bc 1f 00 00 	movzwl 0x1fbc(%ebx),%eax
f0100503:	8d 50 01             	lea    0x1(%eax),%edx
f0100506:	66 89 93 bc 1f 00 00 	mov    %dx,0x1fbc(%ebx)
f010050d:	0f b7 c0             	movzwl %ax,%eax
f0100510:	8b 93 c0 1f 00 00    	mov    0x1fc0(%ebx),%edx
f0100516:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f010051a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010051e:	e9 1d ff ff ff       	jmp    f0100440 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100523:	8b 83 c0 1f 00 00    	mov    0x1fc0(%ebx),%eax
f0100529:	83 ec 04             	sub    $0x4,%esp
f010052c:	68 00 0f 00 00       	push   $0xf00
f0100531:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100537:	52                   	push   %edx
f0100538:	50                   	push   %eax
f0100539:	e8 dd 3f 00 00       	call   f010451b <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010053e:	8b 93 c0 1f 00 00    	mov    0x1fc0(%ebx),%edx
f0100544:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010054a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100550:	83 c4 10             	add    $0x10,%esp
f0100553:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100558:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010055b:	39 d0                	cmp    %edx,%eax
f010055d:	75 f4                	jne    f0100553 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f010055f:	66 83 ab bc 1f 00 00 	subw   $0x50,0x1fbc(%ebx)
f0100566:	50 
f0100567:	e9 e3 fe ff ff       	jmp    f010044f <cons_putc+0xf9>

f010056c <serial_intr>:
{
f010056c:	e8 e7 01 00 00       	call   f0100758 <__x86.get_pc_thunk.ax>
f0100571:	05 9b 8d 01 00       	add    $0x18d9b,%eax
	if (serial_exists)
f0100576:	80 b8 c8 1f 00 00 00 	cmpb   $0x0,0x1fc8(%eax)
f010057d:	75 02                	jne    f0100581 <serial_intr+0x15>
f010057f:	f3 c3                	repz ret 
{
f0100581:	55                   	push   %ebp
f0100582:	89 e5                	mov    %esp,%ebp
f0100584:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100587:	8d 80 ae 6e fe ff    	lea    -0x19152(%eax),%eax
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
f010059f:	05 6d 8d 01 00       	add    $0x18d6d,%eax
	cons_intr(kbd_proc_data);
f01005a4:	8d 80 18 6f fe ff    	lea    -0x190e8(%eax),%eax
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
f01005bd:	81 c3 4f 8d 01 00    	add    $0x18d4f,%ebx
	serial_intr();
f01005c3:	e8 a4 ff ff ff       	call   f010056c <serial_intr>
	kbd_intr();
f01005c8:	e8 c7 ff ff ff       	call   f0100594 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005cd:	8b 93 b4 1f 00 00    	mov    0x1fb4(%ebx),%edx
	return 0;
f01005d3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005d8:	3b 93 b8 1f 00 00    	cmp    0x1fb8(%ebx),%edx
f01005de:	74 19                	je     f01005f9 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e0:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e3:	89 8b b4 1f 00 00    	mov    %ecx,0x1fb4(%ebx)
f01005e9:	0f b6 84 13 b4 1d 00 	movzbl 0x1db4(%ebx,%edx,1),%eax
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
f01005ff:	c7 83 b4 1f 00 00 00 	movl   $0x0,0x1fb4(%ebx)
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
f0100619:	81 c3 f3 8c 01 00    	add    $0x18cf3,%ebx
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
f0100640:	c7 83 c4 1f 00 00 b4 	movl   $0x3b4,0x1fc4(%ebx)
f0100647:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010064a:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100651:	8b bb c4 1f 00 00    	mov    0x1fc4(%ebx),%edi
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
f0100679:	89 bb c0 1f 00 00    	mov    %edi,0x1fc0(%ebx)
	pos |= inb(addr_6845 + 1);
f010067f:	0f b6 c0             	movzbl %al,%eax
f0100682:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100684:	66 89 b3 bc 1f 00 00 	mov    %si,0x1fbc(%ebx)
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
f01006dc:	0f 95 83 c8 1f 00 00 	setne  0x1fc8(%ebx)
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
f0100703:	c7 83 c4 1f 00 00 d4 	movl   $0x3d4,0x1fc4(%ebx)
f010070a:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010070d:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100714:	e9 38 ff ff ff       	jmp    f0100651 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f0100719:	83 ec 0c             	sub    $0xc,%esp
f010071c:	8d 83 a8 b6 fe ff    	lea    -0x14958(%ebx),%eax
f0100722:	50                   	push   %eax
f0100723:	e8 3f 31 00 00       	call   f0103867 <cprintf>
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
f0100762:	83 ec 1c             	sub    $0x1c,%esp
f0100765:	e8 4c fa ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f010076a:	81 c3 a2 8b 01 00    	add    $0x18ba2,%ebx
f0100770:	8d b3 14 1d 00 00    	lea    0x1d14(%ebx),%esi
f0100776:	8d 83 68 1d 00 00    	lea    0x1d68(%ebx),%eax
f010077c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010077f:	8d bb d4 b8 fe ff    	lea    -0x1472c(%ebx),%edi
f0100785:	83 ec 04             	sub    $0x4,%esp
f0100788:	ff 76 04             	pushl  0x4(%esi)
f010078b:	ff 36                	pushl  (%esi)
f010078d:	57                   	push   %edi
f010078e:	e8 d4 30 00 00       	call   f0103867 <cprintf>
f0100793:	83 c6 0c             	add    $0xc,%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100796:	83 c4 10             	add    $0x10,%esp
f0100799:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010079c:	75 e7                	jne    f0100785 <mon_help+0x29>
	return 0;
}
f010079e:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007a6:	5b                   	pop    %ebx
f01007a7:	5e                   	pop    %esi
f01007a8:	5f                   	pop    %edi
f01007a9:	5d                   	pop    %ebp
f01007aa:	c3                   	ret    

f01007ab <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007ab:	55                   	push   %ebp
f01007ac:	89 e5                	mov    %esp,%ebp
f01007ae:	57                   	push   %edi
f01007af:	56                   	push   %esi
f01007b0:	53                   	push   %ebx
f01007b1:	83 ec 18             	sub    $0x18,%esp
f01007b4:	e8 fd f9 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01007b9:	81 c3 53 8b 01 00    	add    $0x18b53,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007bf:	8d 83 dd b8 fe ff    	lea    -0x14723(%ebx),%eax
f01007c5:	50                   	push   %eax
f01007c6:	e8 9c 30 00 00       	call   f0103867 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007cb:	83 c4 08             	add    $0x8,%esp
f01007ce:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f01007d4:	8d 83 cc ba fe ff    	lea    -0x14534(%ebx),%eax
f01007da:	50                   	push   %eax
f01007db:	e8 87 30 00 00       	call   f0103867 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e0:	83 c4 0c             	add    $0xc,%esp
f01007e3:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007e9:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007ef:	50                   	push   %eax
f01007f0:	57                   	push   %edi
f01007f1:	8d 83 f4 ba fe ff    	lea    -0x1450c(%ebx),%eax
f01007f7:	50                   	push   %eax
f01007f8:	e8 6a 30 00 00       	call   f0103867 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007fd:	83 c4 0c             	add    $0xc,%esp
f0100800:	c7 c0 09 49 10 f0    	mov    $0xf0104909,%eax
f0100806:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010080c:	52                   	push   %edx
f010080d:	50                   	push   %eax
f010080e:	8d 83 18 bb fe ff    	lea    -0x144e8(%ebx),%eax
f0100814:	50                   	push   %eax
f0100815:	e8 4d 30 00 00       	call   f0103867 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010081a:	83 c4 0c             	add    $0xc,%esp
f010081d:	c7 c0 a0 b0 11 f0    	mov    $0xf011b0a0,%eax
f0100823:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100829:	52                   	push   %edx
f010082a:	50                   	push   %eax
f010082b:	8d 83 3c bb fe ff    	lea    -0x144c4(%ebx),%eax
f0100831:	50                   	push   %eax
f0100832:	e8 30 30 00 00       	call   f0103867 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100837:	83 c4 0c             	add    $0xc,%esp
f010083a:	c7 c6 e0 b6 11 f0    	mov    $0xf011b6e0,%esi
f0100840:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100846:	50                   	push   %eax
f0100847:	56                   	push   %esi
f0100848:	8d 83 60 bb fe ff    	lea    -0x144a0(%ebx),%eax
f010084e:	50                   	push   %eax
f010084f:	e8 13 30 00 00       	call   f0103867 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100854:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100857:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010085d:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085f:	c1 fe 0a             	sar    $0xa,%esi
f0100862:	56                   	push   %esi
f0100863:	8d 83 84 bb fe ff    	lea    -0x1447c(%ebx),%eax
f0100869:	50                   	push   %eax
f010086a:	e8 f8 2f 00 00       	call   f0103867 <cprintf>
	return 0;
}
f010086f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100874:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100877:	5b                   	pop    %ebx
f0100878:	5e                   	pop    %esi
f0100879:	5f                   	pop    %edi
f010087a:	5d                   	pop    %ebp
f010087b:	c3                   	ret    

f010087c <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010087c:	55                   	push   %ebp
f010087d:	89 e5                	mov    %esp,%ebp
f010087f:	53                   	push   %ebx
f0100880:	83 ec 10             	sub    $0x10,%esp
f0100883:	e8 2e f9 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100888:	81 c3 84 8a 01 00    	add    $0x18a84,%ebx
	// Your code here.
	cprintf("Stack backtrace:\n");
f010088e:	8d 83 f6 b8 fe ff    	lea    -0x1470a(%ebx),%eax
f0100894:	50                   	push   %eax
f0100895:	e8 cd 2f 00 00       	call   f0103867 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010089a:	89 e8                	mov    %ebp,%eax
		fn_name[i] = '\0';
		cprintf("%s:%d: %s+%d\n", info.eip_file, info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (struct Trapframe*)((uint32_t*)ebp + 8);
	}
	return 0;
}
f010089c:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01008a4:	c9                   	leave  
f01008a5:	c3                   	ret    

f01008a6 <mon_mAddr>:
{
	*(uint32_t *)va = info;
	return;
}
int mon_mAddr(int argc, char **argv, struct Trapframe *tf)
{
f01008a6:	55                   	push   %ebp
f01008a7:	89 e5                	mov    %esp,%ebp
f01008a9:	57                   	push   %edi
f01008aa:	56                   	push   %esi
f01008ab:	53                   	push   %ebx
f01008ac:	83 ec 0c             	sub    $0xc,%esp
f01008af:	e8 02 f9 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01008b4:	81 c3 58 8a 01 00    	add    $0x18a58,%ebx
f01008ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
	assert(argc == 3);
f01008bd:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01008c1:	75 52                	jne    f0100915 <mon_mAddr+0x6f>
	uintptr_t va;
	uint32_t info;
	va = strtol(argv[1], NULL, 16);
f01008c3:	83 ec 04             	sub    $0x4,%esp
f01008c6:	6a 10                	push   $0x10
f01008c8:	6a 00                	push   $0x0
f01008ca:	ff 77 04             	pushl  0x4(%edi)
f01008cd:	e8 1a 3d 00 00       	call   f01045ec <strtol>
f01008d2:	89 c6                	mov    %eax,%esi
	info = strtol(argv[2], NULL, 16);
f01008d4:	83 c4 0c             	add    $0xc,%esp
f01008d7:	6a 10                	push   $0x10
f01008d9:	6a 00                	push   $0x0
f01008db:	ff 77 08             	pushl  0x8(%edi)
f01008de:	e8 09 3d 00 00       	call   f01045ec <strtol>
	if (va != ROUNDUP(va, PGSIZE))
f01008e3:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f01008e9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01008ef:	83 c4 10             	add    $0x10,%esp
f01008f2:	39 d6                	cmp    %edx,%esi
f01008f4:	74 3e                	je     f0100934 <mon_mAddr+0x8e>
	{
		cprintf("Command: mAddr 0xva info");
f01008f6:	83 ec 0c             	sub    $0xc,%esp
f01008f9:	8d 83 36 b9 fe ff    	lea    -0x146ca(%ebx),%eax
f01008ff:	50                   	push   %eax
f0100900:	e8 62 2f 00 00       	call   f0103867 <cprintf>
		return 0;
f0100905:	83 c4 10             	add    $0x10,%esp
	}
	mAddr(va, info);
	return 0;
}
f0100908:	b8 00 00 00 00       	mov    $0x0,%eax
f010090d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100910:	5b                   	pop    %ebx
f0100911:	5e                   	pop    %esi
f0100912:	5f                   	pop    %edi
f0100913:	5d                   	pop    %ebp
f0100914:	c3                   	ret    
	assert(argc == 3);
f0100915:	8d 83 08 b9 fe ff    	lea    -0x146f8(%ebx),%eax
f010091b:	50                   	push   %eax
f010091c:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0100922:	50                   	push   %eax
f0100923:	68 24 01 00 00       	push   $0x124
f0100928:	8d 83 27 b9 fe ff    	lea    -0x146d9(%ebx),%eax
f010092e:	50                   	push   %eax
f010092f:	e8 cc f7 ff ff       	call   f0100100 <_panic>
	*(uint32_t *)va = info;
f0100934:	89 06                	mov    %eax,(%esi)
f0100936:	eb d0                	jmp    f0100908 <mon_mAddr+0x62>

f0100938 <showmappings>:
{
f0100938:	55                   	push   %ebp
f0100939:	89 e5                	mov    %esp,%ebp
f010093b:	57                   	push   %edi
f010093c:	56                   	push   %esi
f010093d:	53                   	push   %ebx
f010093e:	83 ec 30             	sub    $0x30,%esp
f0100941:	e8 70 f8 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100946:	81 c3 c6 89 01 00    	add    $0x189c6,%ebx
f010094c:	8b 7d 08             	mov    0x8(%ebp),%edi
	cprintf("Following are address mapping from 0x%x to 0x%x:\n", start, end);
f010094f:	ff 75 0c             	pushl  0xc(%ebp)
f0100952:	57                   	push   %edi
f0100953:	8d 83 b0 bb fe ff    	lea    -0x14450(%ebx),%eax
f0100959:	50                   	push   %eax
f010095a:	e8 08 2f 00 00       	call   f0103867 <cprintf>
	pte_t *pte = NULL;
f010095f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f0100966:	83 c4 10             	add    $0x10,%esp
		page = page_lookup(kern_pgdir, (void *)current_page_address, &pte);
f0100969:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f010096f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100972:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0100978:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f010097b:	eb 19                	jmp    f0100996 <showmappings+0x5e>
			cprintf("  The virtual address 0x%x have no physical page\n", current_page_address);
f010097d:	83 ec 08             	sub    $0x8,%esp
f0100980:	57                   	push   %edi
f0100981:	8d 83 e4 bb fe ff    	lea    -0x1441c(%ebx),%eax
f0100987:	50                   	push   %eax
f0100988:	e8 da 2e 00 00       	call   f0103867 <cprintf>
			continue;
f010098d:	83 c4 10             	add    $0x10,%esp
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f0100990:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0100996:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100999:	0f 87 bb 00 00 00    	ja     f0100a5a <showmappings+0x122>
		page = page_lookup(kern_pgdir, (void *)current_page_address, &pte);
f010099f:	83 ec 04             	sub    $0x4,%esp
f01009a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01009a5:	50                   	push   %eax
f01009a6:	57                   	push   %edi
f01009a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01009aa:	ff 30                	pushl  (%eax)
f01009ac:	e8 e4 0f 00 00       	call   f0101995 <page_lookup>
f01009b1:	89 c6                	mov    %eax,%esi
		if (!page)
f01009b3:	83 c4 10             	add    $0x10,%esp
f01009b6:	85 c0                	test   %eax,%eax
f01009b8:	74 c3                	je     f010097d <showmappings+0x45>
		cprintf("  The virtual address is 0x%x\n", current_page_address);
f01009ba:	83 ec 08             	sub    $0x8,%esp
f01009bd:	57                   	push   %edi
f01009be:	8d 83 18 bc fe ff    	lea    -0x143e8(%ebx),%eax
f01009c4:	50                   	push   %eax
f01009c5:	e8 9d 2e 00 00       	call   f0103867 <cprintf>
		cprintf("    The mapping physical page address is 0x%08x\n", page2pa(page));
f01009ca:	83 c4 08             	add    $0x8,%esp
f01009cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009d0:	2b 30                	sub    (%eax),%esi
f01009d2:	c1 fe 03             	sar    $0x3,%esi
f01009d5:	c1 e6 0c             	shl    $0xc,%esi
f01009d8:	56                   	push   %esi
f01009d9:	8d 83 38 bc fe ff    	lea    -0x143c8(%ebx),%eax
f01009df:	50                   	push   %eax
f01009e0:	e8 82 2e 00 00       	call   f0103867 <cprintf>
		cprintf("    The permissions bits:\n");
f01009e5:	8d 83 4f b9 fe ff    	lea    -0x146b1(%ebx),%eax
f01009eb:	89 04 24             	mov    %eax,(%esp)
f01009ee:	e8 74 2e 00 00       	call   f0103867 <cprintf>
				!!(*pte & PTE_G));
f01009f3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009f6:	8b 00                	mov    (%eax),%eax
		cprintf("      PTE_P: %d PTE_W: %d PTE_U: %d PTE_PWT: %d PTE_PCD: %d PTE_A: %d PTE_D: %d PTE_PS: %d PTE_G: %d\n\n",
f01009f8:	83 c4 08             	add    $0x8,%esp
f01009fb:	89 c2                	mov    %eax,%edx
f01009fd:	c1 ea 08             	shr    $0x8,%edx
f0100a00:	83 e2 01             	and    $0x1,%edx
f0100a03:	52                   	push   %edx
f0100a04:	89 c2                	mov    %eax,%edx
f0100a06:	c1 ea 07             	shr    $0x7,%edx
f0100a09:	83 e2 01             	and    $0x1,%edx
f0100a0c:	52                   	push   %edx
f0100a0d:	89 c2                	mov    %eax,%edx
f0100a0f:	c1 ea 06             	shr    $0x6,%edx
f0100a12:	83 e2 01             	and    $0x1,%edx
f0100a15:	52                   	push   %edx
f0100a16:	89 c2                	mov    %eax,%edx
f0100a18:	c1 ea 05             	shr    $0x5,%edx
f0100a1b:	83 e2 01             	and    $0x1,%edx
f0100a1e:	52                   	push   %edx
f0100a1f:	89 c2                	mov    %eax,%edx
f0100a21:	c1 ea 04             	shr    $0x4,%edx
f0100a24:	83 e2 01             	and    $0x1,%edx
f0100a27:	52                   	push   %edx
f0100a28:	89 c2                	mov    %eax,%edx
f0100a2a:	c1 ea 03             	shr    $0x3,%edx
f0100a2d:	83 e2 01             	and    $0x1,%edx
f0100a30:	52                   	push   %edx
f0100a31:	89 c2                	mov    %eax,%edx
f0100a33:	c1 ea 02             	shr    $0x2,%edx
f0100a36:	83 e2 01             	and    $0x1,%edx
f0100a39:	52                   	push   %edx
f0100a3a:	89 c2                	mov    %eax,%edx
f0100a3c:	d1 ea                	shr    %edx
f0100a3e:	83 e2 01             	and    $0x1,%edx
f0100a41:	52                   	push   %edx
f0100a42:	83 e0 01             	and    $0x1,%eax
f0100a45:	50                   	push   %eax
f0100a46:	8d 83 6c bc fe ff    	lea    -0x14394(%ebx),%eax
f0100a4c:	50                   	push   %eax
f0100a4d:	e8 15 2e 00 00       	call   f0103867 <cprintf>
f0100a52:	83 c4 30             	add    $0x30,%esp
f0100a55:	e9 36 ff ff ff       	jmp    f0100990 <showmappings+0x58>
}
f0100a5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a5d:	5b                   	pop    %ebx
f0100a5e:	5e                   	pop    %esi
f0100a5f:	5f                   	pop    %edi
f0100a60:	5d                   	pop    %ebp
f0100a61:	c3                   	ret    

f0100a62 <mon_showmappings>:
{
f0100a62:	55                   	push   %ebp
f0100a63:	89 e5                	mov    %esp,%ebp
f0100a65:	57                   	push   %edi
f0100a66:	56                   	push   %esi
f0100a67:	53                   	push   %ebx
f0100a68:	83 ec 0c             	sub    $0xc,%esp
f0100a6b:	e8 46 f7 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100a70:	81 c3 9c 88 01 00    	add    $0x1889c,%ebx
f0100a76:	8b 7d 0c             	mov    0xc(%ebp),%edi
	assert(argc == 3);
f0100a79:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100a7d:	75 62                	jne    f0100ae1 <mon_showmappings+0x7f>
	uintptr_t start = strtol(argv[1], NULL, 16), end = strtol(argv[2], NULL, 16);
f0100a7f:	83 ec 04             	sub    $0x4,%esp
f0100a82:	6a 10                	push   $0x10
f0100a84:	6a 00                	push   $0x0
f0100a86:	ff 77 04             	pushl  0x4(%edi)
f0100a89:	e8 5e 3b 00 00       	call   f01045ec <strtol>
f0100a8e:	89 c6                	mov    %eax,%esi
f0100a90:	83 c4 0c             	add    $0xc,%esp
f0100a93:	6a 10                	push   $0x10
f0100a95:	6a 00                	push   $0x0
f0100a97:	ff 77 08             	pushl  0x8(%edi)
f0100a9a:	e8 4d 3b 00 00       	call   f01045ec <strtol>
	if (start != ROUNDUP(start, PGSIZE) || end != ROUNDUP(end, PGSIZE))
f0100a9f:	8d 96 ff 0f 00 00    	lea    0xfff(%esi),%edx
f0100aa5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aab:	83 c4 10             	add    $0x10,%esp
f0100aae:	39 d6                	cmp    %edx,%esi
f0100ab0:	75 10                	jne    f0100ac2 <mon_showmappings+0x60>
f0100ab2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100ab8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100abe:	39 d0                	cmp    %edx,%eax
f0100ac0:	74 3e                	je     f0100b00 <mon_showmappings+0x9e>
		cprintf("Command is showmappings 0xaddr_start 0xaddr_end\n");
f0100ac2:	83 ec 0c             	sub    $0xc,%esp
f0100ac5:	8d 83 d4 bc fe ff    	lea    -0x1432c(%ebx),%eax
f0100acb:	50                   	push   %eax
f0100acc:	e8 96 2d 00 00       	call   f0103867 <cprintf>
		return 0;
f0100ad1:	83 c4 10             	add    $0x10,%esp
}
f0100ad4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100adc:	5b                   	pop    %ebx
f0100add:	5e                   	pop    %esi
f0100ade:	5f                   	pop    %edi
f0100adf:	5d                   	pop    %ebp
f0100ae0:	c3                   	ret    
	assert(argc == 3);
f0100ae1:	8d 83 08 b9 fe ff    	lea    -0x146f8(%ebx),%eax
f0100ae7:	50                   	push   %eax
f0100ae8:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0100aee:	50                   	push   %eax
f0100aef:	68 84 00 00 00       	push   $0x84
f0100af4:	8d 83 27 b9 fe ff    	lea    -0x146d9(%ebx),%eax
f0100afa:	50                   	push   %eax
f0100afb:	e8 00 f6 ff ff       	call   f0100100 <_panic>
	showmappings(start, end);
f0100b00:	83 ec 08             	sub    $0x8,%esp
f0100b03:	50                   	push   %eax
f0100b04:	56                   	push   %esi
f0100b05:	e8 2e fe ff ff       	call   f0100938 <showmappings>
	return 0;
f0100b0a:	83 c4 10             	add    $0x10,%esp
f0100b0d:	eb c5                	jmp    f0100ad4 <mon_showmappings+0x72>

f0100b0f <mPerm>:
{
f0100b0f:	55                   	push   %ebp
f0100b10:	89 e5                	mov    %esp,%ebp
f0100b12:	57                   	push   %edi
f0100b13:	56                   	push   %esi
f0100b14:	53                   	push   %ebx
f0100b15:	83 ec 10             	sub    $0x10,%esp
f0100b18:	e8 99 f6 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100b1d:	81 c3 ef 87 01 00    	add    $0x187ef,%ebx
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)va, 1);
f0100b23:	6a 01                	push   $0x1
f0100b25:	ff 75 0c             	pushl  0xc(%ebp)
f0100b28:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0100b2e:	ff 30                	pushl  (%eax)
f0100b30:	e8 66 0d 00 00       	call   f010189b <pgdir_walk>
f0100b35:	89 c7                	mov    %eax,%edi
	if (new_perm == 1)
f0100b37:	83 c4 08             	add    $0x8,%esp
f0100b3a:	83 7d 14 01          	cmpl   $0x1,0x14(%ebp)
f0100b3e:	0f 95 c0             	setne  %al
f0100b41:	0f b6 c0             	movzbl %al,%eax
f0100b44:	f7 d8                	neg    %eax
f0100b46:	89 c6                	mov    %eax,%esi
	if (strcmp(perm, "PTE_P") == 0)
f0100b48:	8d 83 12 c9 fe ff    	lea    -0x136ee(%ebx),%eax
f0100b4e:	50                   	push   %eax
f0100b4f:	ff 75 10             	pushl  0x10(%ebp)
f0100b52:	e8 dc 38 00 00       	call   f0104433 <strcmp>
f0100b57:	83 c4 10             	add    $0x10,%esp
f0100b5a:	85 c0                	test   %eax,%eax
f0100b5c:	75 17                	jne    f0100b75 <mPerm+0x66>
		tmp = tmp ^ PTE_P;
f0100b5e:	83 f6 01             	xor    $0x1,%esi
	if (new_perm == 1)
f0100b61:	83 7d 14 01          	cmpl   $0x1,0x14(%ebp)
f0100b65:	0f 84 13 01 00 00    	je     f0100c7e <mPerm+0x16f>
		*pte &= tmp;
f0100b6b:	21 37                	and    %esi,(%edi)
}
f0100b6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b70:	5b                   	pop    %ebx
f0100b71:	5e                   	pop    %esi
f0100b72:	5f                   	pop    %edi
f0100b73:	5d                   	pop    %ebp
f0100b74:	c3                   	ret    
	else if (strcmp(perm, "PTE_W") == 0)
f0100b75:	83 ec 08             	sub    $0x8,%esp
f0100b78:	8d 83 23 c9 fe ff    	lea    -0x136dd(%ebx),%eax
f0100b7e:	50                   	push   %eax
f0100b7f:	ff 75 10             	pushl  0x10(%ebp)
f0100b82:	e8 ac 38 00 00       	call   f0104433 <strcmp>
f0100b87:	83 c4 10             	add    $0x10,%esp
f0100b8a:	85 c0                	test   %eax,%eax
f0100b8c:	75 05                	jne    f0100b93 <mPerm+0x84>
		tmp = tmp ^ PTE_W;
f0100b8e:	83 f6 02             	xor    $0x2,%esi
f0100b91:	eb ce                	jmp    f0100b61 <mPerm+0x52>
	else if (strcmp(perm, "PTE_U") == 0)
f0100b93:	83 ec 08             	sub    $0x8,%esp
f0100b96:	8d 83 65 c8 fe ff    	lea    -0x1379b(%ebx),%eax
f0100b9c:	50                   	push   %eax
f0100b9d:	ff 75 10             	pushl  0x10(%ebp)
f0100ba0:	e8 8e 38 00 00       	call   f0104433 <strcmp>
f0100ba5:	83 c4 10             	add    $0x10,%esp
f0100ba8:	85 c0                	test   %eax,%eax
f0100baa:	75 05                	jne    f0100bb1 <mPerm+0xa2>
		tmp = tmp ^ PTE_U;
f0100bac:	83 f6 04             	xor    $0x4,%esi
f0100baf:	eb b0                	jmp    f0100b61 <mPerm+0x52>
	else if (strcmp(perm, "PTE_PWT") == 0)
f0100bb1:	83 ec 08             	sub    $0x8,%esp
f0100bb4:	8d 83 6a b9 fe ff    	lea    -0x14696(%ebx),%eax
f0100bba:	50                   	push   %eax
f0100bbb:	ff 75 10             	pushl  0x10(%ebp)
f0100bbe:	e8 70 38 00 00       	call   f0104433 <strcmp>
f0100bc3:	83 c4 10             	add    $0x10,%esp
f0100bc6:	85 c0                	test   %eax,%eax
f0100bc8:	75 05                	jne    f0100bcf <mPerm+0xc0>
		tmp = tmp ^ PTE_PWT;
f0100bca:	83 f6 08             	xor    $0x8,%esi
f0100bcd:	eb 92                	jmp    f0100b61 <mPerm+0x52>
	else if (strcmp(perm, "PTE_PCD") == 0)
f0100bcf:	83 ec 08             	sub    $0x8,%esp
f0100bd2:	8d 83 72 b9 fe ff    	lea    -0x1468e(%ebx),%eax
f0100bd8:	50                   	push   %eax
f0100bd9:	ff 75 10             	pushl  0x10(%ebp)
f0100bdc:	e8 52 38 00 00       	call   f0104433 <strcmp>
f0100be1:	83 c4 10             	add    $0x10,%esp
f0100be4:	85 c0                	test   %eax,%eax
f0100be6:	75 08                	jne    f0100bf0 <mPerm+0xe1>
		tmp = tmp ^ PTE_PCD;
f0100be8:	83 f6 10             	xor    $0x10,%esi
f0100beb:	e9 71 ff ff ff       	jmp    f0100b61 <mPerm+0x52>
	else if (strcmp(perm, "PTE_A") == 0)
f0100bf0:	83 ec 08             	sub    $0x8,%esp
f0100bf3:	8d 83 7a b9 fe ff    	lea    -0x14686(%ebx),%eax
f0100bf9:	50                   	push   %eax
f0100bfa:	ff 75 10             	pushl  0x10(%ebp)
f0100bfd:	e8 31 38 00 00       	call   f0104433 <strcmp>
f0100c02:	83 c4 10             	add    $0x10,%esp
f0100c05:	85 c0                	test   %eax,%eax
f0100c07:	75 08                	jne    f0100c11 <mPerm+0x102>
		tmp = tmp ^ PTE_A;
f0100c09:	83 f6 20             	xor    $0x20,%esi
f0100c0c:	e9 50 ff ff ff       	jmp    f0100b61 <mPerm+0x52>
	else if (strcmp(perm, "PTE_D") == 0)
f0100c11:	83 ec 08             	sub    $0x8,%esp
f0100c14:	8d 83 80 b9 fe ff    	lea    -0x14680(%ebx),%eax
f0100c1a:	50                   	push   %eax
f0100c1b:	ff 75 10             	pushl  0x10(%ebp)
f0100c1e:	e8 10 38 00 00       	call   f0104433 <strcmp>
f0100c23:	83 c4 10             	add    $0x10,%esp
f0100c26:	85 c0                	test   %eax,%eax
f0100c28:	75 08                	jne    f0100c32 <mPerm+0x123>
		tmp = tmp ^ PTE_D;
f0100c2a:	83 f6 40             	xor    $0x40,%esi
f0100c2d:	e9 2f ff ff ff       	jmp    f0100b61 <mPerm+0x52>
	else if (strcmp(perm, "PTE_PS") == 0)
f0100c32:	83 ec 08             	sub    $0x8,%esp
f0100c35:	8d 83 86 b9 fe ff    	lea    -0x1467a(%ebx),%eax
f0100c3b:	50                   	push   %eax
f0100c3c:	ff 75 10             	pushl  0x10(%ebp)
f0100c3f:	e8 ef 37 00 00       	call   f0104433 <strcmp>
f0100c44:	83 c4 10             	add    $0x10,%esp
f0100c47:	85 c0                	test   %eax,%eax
f0100c49:	75 0b                	jne    f0100c56 <mPerm+0x147>
		tmp = tmp ^ PTE_PS;
f0100c4b:	81 f6 80 00 00 00    	xor    $0x80,%esi
f0100c51:	e9 0b ff ff ff       	jmp    f0100b61 <mPerm+0x52>
	else if (strcmp(perm, "PTE_G") == 0)
f0100c56:	83 ec 08             	sub    $0x8,%esp
f0100c59:	8d 83 8d b9 fe ff    	lea    -0x14673(%ebx),%eax
f0100c5f:	50                   	push   %eax
f0100c60:	ff 75 10             	pushl  0x10(%ebp)
f0100c63:	e8 cb 37 00 00       	call   f0104433 <strcmp>
f0100c68:	83 c4 10             	add    $0x10,%esp
f0100c6b:	85 c0                	test   %eax,%eax
f0100c6d:	0f 85 ee fe ff ff    	jne    f0100b61 <mPerm+0x52>
		tmp = tmp ^ PTE_G;
f0100c73:	81 f6 00 01 00 00    	xor    $0x100,%esi
f0100c79:	e9 e3 fe ff ff       	jmp    f0100b61 <mPerm+0x52>
		*pte |= tmp;
f0100c7e:	09 37                	or     %esi,(%edi)
f0100c80:	e9 e8 fe ff ff       	jmp    f0100b6d <mPerm+0x5e>

f0100c85 <mon_mPerm>:
{
f0100c85:	55                   	push   %ebp
f0100c86:	89 e5                	mov    %esp,%ebp
f0100c88:	57                   	push   %edi
f0100c89:	56                   	push   %esi
f0100c8a:	53                   	push   %ebx
f0100c8b:	83 ec 20             	sub    $0x20,%esp
f0100c8e:	e8 23 f5 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100c93:	81 c3 79 86 01 00    	add    $0x18679,%ebx
	char *ops = argv[1];
f0100c99:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c9c:	8b 78 04             	mov    0x4(%eax),%edi
	uintptr_t va = strtol(argv[2], NULL, 16);
f0100c9f:	6a 10                	push   $0x10
f0100ca1:	6a 00                	push   $0x0
f0100ca3:	ff 70 08             	pushl  0x8(%eax)
f0100ca6:	e8 41 39 00 00       	call   f01045ec <strtol>
f0100cab:	89 c6                	mov    %eax,%esi
	if (va != (uintptr_t)ROUNDUP(va, PGSIZE))
f0100cad:	8d 80 ff 0f 00 00    	lea    0xfff(%eax),%eax
f0100cb3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cb8:	83 c4 10             	add    $0x10,%esp
f0100cbb:	39 c6                	cmp    %eax,%esi
f0100cbd:	74 1f                	je     f0100cde <mon_mPerm+0x59>
		cprintf("The command is mPerm SET|CLEAR|CHANGE perm (new_perm)?\n");
f0100cbf:	83 ec 0c             	sub    $0xc,%esp
f0100cc2:	8d 83 08 bd fe ff    	lea    -0x142f8(%ebx),%eax
f0100cc8:	50                   	push   %eax
f0100cc9:	e8 99 2b 00 00       	call   f0103867 <cprintf>
		return 0;
f0100cce:	83 c4 10             	add    $0x10,%esp
}
f0100cd1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cd9:	5b                   	pop    %ebx
f0100cda:	5e                   	pop    %esi
f0100cdb:	5f                   	pop    %edi
f0100cdc:	5d                   	pop    %ebp
f0100cdd:	c3                   	ret    
	char *perm = argv[3];
f0100cde:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ce1:	8b 40 0c             	mov    0xc(%eax),%eax
f0100ce4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (!strcmp(ops, "CHANGE"))
f0100ce7:	83 ec 08             	sub    $0x8,%esp
f0100cea:	8d 83 93 b9 fe ff    	lea    -0x1466d(%ebx),%eax
f0100cf0:	50                   	push   %eax
f0100cf1:	57                   	push   %edi
f0100cf2:	e8 3c 37 00 00       	call   f0104433 <strcmp>
f0100cf7:	83 c4 10             	add    $0x10,%esp
f0100cfa:	85 c0                	test   %eax,%eax
f0100cfc:	75 4a                	jne    f0100d48 <mon_mPerm+0xc3>
		assert(argc == 5);
f0100cfe:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100d02:	75 25                	jne    f0100d29 <mon_mPerm+0xa4>
		new_perm = strtol(argv[4], NULL, 10);
f0100d04:	83 ec 04             	sub    $0x4,%esp
f0100d07:	6a 0a                	push   $0xa
f0100d09:	6a 00                	push   $0x0
f0100d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d0e:	ff 70 10             	pushl  0x10(%eax)
f0100d11:	e8 d6 38 00 00       	call   f01045ec <strtol>
f0100d16:	83 c4 10             	add    $0x10,%esp
	mPerm(ops, va, perm, new_perm);
f0100d19:	50                   	push   %eax
f0100d1a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d1d:	56                   	push   %esi
f0100d1e:	57                   	push   %edi
f0100d1f:	e8 eb fd ff ff       	call   f0100b0f <mPerm>
	return 0;
f0100d24:	83 c4 10             	add    $0x10,%esp
f0100d27:	eb a8                	jmp    f0100cd1 <mon_mPerm+0x4c>
		assert(argc == 5);
f0100d29:	8d 83 9a b9 fe ff    	lea    -0x14666(%ebx),%eax
f0100d2f:	50                   	push   %eax
f0100d30:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0100d36:	50                   	push   %eax
f0100d37:	68 d1 00 00 00       	push   $0xd1
f0100d3c:	8d 83 27 b9 fe ff    	lea    -0x146d9(%ebx),%eax
f0100d42:	50                   	push   %eax
f0100d43:	e8 b8 f3 ff ff       	call   f0100100 <_panic>
	else if (!strcmp(ops, "SET"))
f0100d48:	83 ec 08             	sub    $0x8,%esp
f0100d4b:	8d 83 a4 b9 fe ff    	lea    -0x1465c(%ebx),%eax
f0100d51:	50                   	push   %eax
f0100d52:	57                   	push   %edi
f0100d53:	e8 db 36 00 00       	call   f0104433 <strcmp>
f0100d58:	83 c4 10             	add    $0x10,%esp
f0100d5b:	85 c0                	test   %eax,%eax
f0100d5d:	75 2c                	jne    f0100d8b <mon_mPerm+0x106>
		assert(argc == 4);
f0100d5f:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100d63:	75 07                	jne    f0100d6c <mon_mPerm+0xe7>
		new_perm = 1;
f0100d65:	b8 01 00 00 00       	mov    $0x1,%eax
f0100d6a:	eb ad                	jmp    f0100d19 <mon_mPerm+0x94>
		assert(argc == 4);
f0100d6c:	8d 83 a8 b9 fe ff    	lea    -0x14658(%ebx),%eax
f0100d72:	50                   	push   %eax
f0100d73:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0100d79:	50                   	push   %eax
f0100d7a:	68 d6 00 00 00       	push   $0xd6
f0100d7f:	8d 83 27 b9 fe ff    	lea    -0x146d9(%ebx),%eax
f0100d85:	50                   	push   %eax
f0100d86:	e8 75 f3 ff ff       	call   f0100100 <_panic>
	else if (!strcmp(ops, "CLEAR"))
f0100d8b:	83 ec 08             	sub    $0x8,%esp
f0100d8e:	8d 83 b2 b9 fe ff    	lea    -0x1464e(%ebx),%eax
f0100d94:	50                   	push   %eax
f0100d95:	57                   	push   %edi
f0100d96:	e8 98 36 00 00       	call   f0104433 <strcmp>
f0100d9b:	83 c4 10             	add    $0x10,%esp
f0100d9e:	85 c0                	test   %eax,%eax
f0100da0:	75 29                	jne    f0100dcb <mon_mPerm+0x146>
		assert(argc == 4);
f0100da2:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100da6:	0f 84 6d ff ff ff    	je     f0100d19 <mon_mPerm+0x94>
f0100dac:	8d 83 a8 b9 fe ff    	lea    -0x14658(%ebx),%eax
f0100db2:	50                   	push   %eax
f0100db3:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0100db9:	50                   	push   %eax
f0100dba:	68 db 00 00 00       	push   $0xdb
f0100dbf:	8d 83 27 b9 fe ff    	lea    -0x146d9(%ebx),%eax
f0100dc5:	50                   	push   %eax
f0100dc6:	e8 35 f3 ff ff       	call   f0100100 <_panic>
		cprintf("INVALID COMMAND\n");
f0100dcb:	83 ec 0c             	sub    $0xc,%esp
f0100dce:	8d 83 b8 b9 fe ff    	lea    -0x14648(%ebx),%eax
f0100dd4:	50                   	push   %eax
f0100dd5:	e8 8d 2a 00 00       	call   f0103867 <cprintf>
f0100dda:	83 c4 10             	add    $0x10,%esp
	int new_perm = 0;
f0100ddd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100de2:	e9 32 ff ff ff       	jmp    f0100d19 <mon_mPerm+0x94>

f0100de7 <dump_v>:
{
f0100de7:	55                   	push   %ebp
f0100de8:	89 e5                	mov    %esp,%ebp
f0100dea:	57                   	push   %edi
f0100deb:	56                   	push   %esi
f0100dec:	53                   	push   %ebx
f0100ded:	83 ec 0c             	sub    $0xc,%esp
f0100df0:	e8 c1 f3 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100df5:	81 c3 17 85 01 00    	add    $0x18517,%ebx
f0100dfb:	8b 75 08             	mov    0x8(%ebp),%esi
		cprintf("The virtual address is 0x%08x and content is 0x%08x\n", current_va, *(uint32_t *)current_va);
f0100dfe:	8d bb 40 bd fe ff    	lea    -0x142c0(%ebx),%edi
	for (current_va = va_start; current_va <= va_end; current_va += PGSIZE)
f0100e04:	eb 15                	jmp    f0100e1b <dump_v+0x34>
		cprintf("The virtual address is 0x%08x and content is 0x%08x\n", current_va, *(uint32_t *)current_va);
f0100e06:	83 ec 04             	sub    $0x4,%esp
f0100e09:	ff 36                	pushl  (%esi)
f0100e0b:	56                   	push   %esi
f0100e0c:	57                   	push   %edi
f0100e0d:	e8 55 2a 00 00       	call   f0103867 <cprintf>
	for (current_va = va_start; current_va <= va_end; current_va += PGSIZE)
f0100e12:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100e18:	83 c4 10             	add    $0x10,%esp
f0100e1b:	3b 75 0c             	cmp    0xc(%ebp),%esi
f0100e1e:	76 e6                	jbe    f0100e06 <dump_v+0x1f>
}
f0100e20:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e23:	5b                   	pop    %ebx
f0100e24:	5e                   	pop    %esi
f0100e25:	5f                   	pop    %edi
f0100e26:	5d                   	pop    %ebp
f0100e27:	c3                   	ret    

f0100e28 <dump_p>:
{
f0100e28:	55                   	push   %ebp
f0100e29:	89 e5                	mov    %esp,%ebp
f0100e2b:	57                   	push   %edi
f0100e2c:	56                   	push   %esi
f0100e2d:	53                   	push   %ebx
f0100e2e:	83 ec 1c             	sub    $0x1c,%esp
f0100e31:	e8 80 f3 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100e36:	81 c3 d6 84 01 00    	add    $0x184d6,%ebx
f0100e3c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (PGNUM(pa) >= npages)
f0100e3f:	c7 c7 e8 b6 11 f0    	mov    $0xf011b6e8,%edi
		cprintf("The physical address is 0x%08x and content is 0x%08x\n", current_pa, *(uint32_t *)KADDR(current_pa));
f0100e45:	8d 83 9c bd fe ff    	lea    -0x14264(%ebx),%eax
f0100e4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (current_pa = pa_start; current_pa <= pa_end; current_pa += PGSIZE)
f0100e4e:	3b 75 0c             	cmp    0xc(%ebp),%esi
f0100e51:	77 3f                	ja     f0100e92 <dump_p+0x6a>
f0100e53:	89 f0                	mov    %esi,%eax
f0100e55:	c1 e8 0c             	shr    $0xc,%eax
f0100e58:	3b 07                	cmp    (%edi),%eax
f0100e5a:	73 1d                	jae    f0100e79 <dump_p+0x51>
		cprintf("The physical address is 0x%08x and content is 0x%08x\n", current_pa, *(uint32_t *)KADDR(current_pa));
f0100e5c:	83 ec 04             	sub    $0x4,%esp
f0100e5f:	ff b6 00 00 00 f0    	pushl  -0x10000000(%esi)
f0100e65:	56                   	push   %esi
f0100e66:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e69:	e8 f9 29 00 00       	call   f0103867 <cprintf>
	for (current_pa = pa_start; current_pa <= pa_end; current_pa += PGSIZE)
f0100e6e:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100e74:	83 c4 10             	add    $0x10,%esp
f0100e77:	eb d5                	jmp    f0100e4e <dump_p+0x26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e79:	56                   	push   %esi
f0100e7a:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f0100e80:	50                   	push   %eax
f0100e81:	68 f3 00 00 00       	push   $0xf3
f0100e86:	8d 83 27 b9 fe ff    	lea    -0x146d9(%ebx),%eax
f0100e8c:	50                   	push   %eax
f0100e8d:	e8 6e f2 ff ff       	call   f0100100 <_panic>
}
f0100e92:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e95:	5b                   	pop    %ebx
f0100e96:	5e                   	pop    %esi
f0100e97:	5f                   	pop    %edi
f0100e98:	5d                   	pop    %ebp
f0100e99:	c3                   	ret    

f0100e9a <mon_dump>:
{
f0100e9a:	55                   	push   %ebp
f0100e9b:	89 e5                	mov    %esp,%ebp
f0100e9d:	57                   	push   %edi
f0100e9e:	56                   	push   %esi
f0100e9f:	53                   	push   %ebx
f0100ea0:	83 ec 0c             	sub    $0xc,%esp
f0100ea3:	e8 0e f3 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0100ea8:	81 c3 64 84 01 00    	add    $0x18464,%ebx
f0100eae:	8b 75 0c             	mov    0xc(%ebp),%esi
	assert(argc == 4);
f0100eb1:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100eb5:	0f 85 80 00 00 00    	jne    f0100f3b <mon_dump+0xa1>
	char *addr_type = argv[1];
f0100ebb:	8b 7e 04             	mov    0x4(%esi),%edi
	if (!strcmp(addr_type, "physical"))
f0100ebe:	83 ec 08             	sub    $0x8,%esp
f0100ec1:	8d 83 c9 b9 fe ff    	lea    -0x14637(%ebx),%eax
f0100ec7:	50                   	push   %eax
f0100ec8:	57                   	push   %edi
f0100ec9:	e8 65 35 00 00       	call   f0104433 <strcmp>
f0100ece:	83 c4 10             	add    $0x10,%esp
f0100ed1:	85 c0                	test   %eax,%eax
f0100ed3:	0f 85 90 00 00 00    	jne    f0100f69 <mon_dump+0xcf>
		p_start = strtol(argv[2], NULL, 16);
f0100ed9:	83 ec 04             	sub    $0x4,%esp
f0100edc:	6a 10                	push   $0x10
f0100ede:	6a 00                	push   $0x0
f0100ee0:	ff 76 08             	pushl  0x8(%esi)
f0100ee3:	e8 04 37 00 00       	call   f01045ec <strtol>
f0100ee8:	89 c7                	mov    %eax,%edi
		p_end = strtol(argv[3], NULL, 16);
f0100eea:	83 c4 0c             	add    $0xc,%esp
f0100eed:	6a 10                	push   $0x10
f0100eef:	6a 00                	push   $0x0
f0100ef1:	ff 76 0c             	pushl  0xc(%esi)
f0100ef4:	e8 f3 36 00 00       	call   f01045ec <strtol>
		if (p_start != ROUNDUP(p_start, PGSIZE) || p_end != ROUNDUP(p_end, PGSIZE))
f0100ef9:	8d 97 ff 0f 00 00    	lea    0xfff(%edi),%edx
f0100eff:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f05:	83 c4 10             	add    $0x10,%esp
f0100f08:	39 fa                	cmp    %edi,%edx
f0100f0a:	75 10                	jne    f0100f1c <mon_dump+0x82>
f0100f0c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100f12:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f18:	39 c2                	cmp    %eax,%edx
f0100f1a:	74 3e                	je     f0100f5a <mon_dump+0xc0>
			cprintf("Command is dump 0xaddr_start 0xaddr_end\n");
f0100f1c:	83 ec 0c             	sub    $0xc,%esp
f0100f1f:	8d 83 d4 bd fe ff    	lea    -0x1422c(%ebx),%eax
f0100f25:	50                   	push   %eax
f0100f26:	e8 3c 29 00 00       	call   f0103867 <cprintf>
			return 0;
f0100f2b:	83 c4 10             	add    $0x10,%esp
}
f0100f2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f33:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f36:	5b                   	pop    %ebx
f0100f37:	5e                   	pop    %esi
f0100f38:	5f                   	pop    %edi
f0100f39:	5d                   	pop    %ebp
f0100f3a:	c3                   	ret    
	assert(argc == 4);
f0100f3b:	8d 83 a8 b9 fe ff    	lea    -0x14658(%ebx),%eax
f0100f41:	50                   	push   %eax
f0100f42:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0100f48:	50                   	push   %eax
f0100f49:	68 fa 00 00 00       	push   $0xfa
f0100f4e:	8d 83 27 b9 fe ff    	lea    -0x146d9(%ebx),%eax
f0100f54:	50                   	push   %eax
f0100f55:	e8 a6 f1 ff ff       	call   f0100100 <_panic>
		dump_p(p_start, p_end);
f0100f5a:	83 ec 08             	sub    $0x8,%esp
f0100f5d:	50                   	push   %eax
f0100f5e:	57                   	push   %edi
f0100f5f:	e8 c4 fe ff ff       	call   f0100e28 <dump_p>
f0100f64:	83 c4 10             	add    $0x10,%esp
f0100f67:	eb c5                	jmp    f0100f2e <mon_dump+0x94>
	else if (!strcmp(addr_type, "virtual"))
f0100f69:	83 ec 08             	sub    $0x8,%esp
f0100f6c:	8d 83 d2 b9 fe ff    	lea    -0x1462e(%ebx),%eax
f0100f72:	50                   	push   %eax
f0100f73:	57                   	push   %edi
f0100f74:	e8 ba 34 00 00       	call   f0104433 <strcmp>
f0100f79:	83 c4 10             	add    $0x10,%esp
f0100f7c:	85 c0                	test   %eax,%eax
f0100f7e:	75 6c                	jne    f0100fec <mon_dump+0x152>
		v_start = strtol(argv[2], NULL, 16);
f0100f80:	83 ec 04             	sub    $0x4,%esp
f0100f83:	6a 10                	push   $0x10
f0100f85:	6a 00                	push   $0x0
f0100f87:	ff 76 08             	pushl  0x8(%esi)
f0100f8a:	e8 5d 36 00 00       	call   f01045ec <strtol>
f0100f8f:	89 c7                	mov    %eax,%edi
		v_end = strtol(argv[3], NULL, 16);
f0100f91:	83 c4 0c             	add    $0xc,%esp
f0100f94:	6a 10                	push   $0x10
f0100f96:	6a 00                	push   $0x0
f0100f98:	ff 76 0c             	pushl  0xc(%esi)
f0100f9b:	e8 4c 36 00 00       	call   f01045ec <strtol>
		if (v_start != ROUNDUP(v_start, PGSIZE) || v_end != ROUNDUP(v_end, PGSIZE))
f0100fa0:	8d 97 ff 0f 00 00    	lea    0xfff(%edi),%edx
f0100fa6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100fac:	83 c4 10             	add    $0x10,%esp
f0100faf:	39 fa                	cmp    %edi,%edx
f0100fb1:	75 10                	jne    f0100fc3 <mon_dump+0x129>
f0100fb3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100fb9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100fbf:	39 d0                	cmp    %edx,%eax
f0100fc1:	74 17                	je     f0100fda <mon_dump+0x140>
			cprintf("Command is dump 0xaddr_start 0xaddr_end\n");
f0100fc3:	83 ec 0c             	sub    $0xc,%esp
f0100fc6:	8d 83 d4 bd fe ff    	lea    -0x1422c(%ebx),%eax
f0100fcc:	50                   	push   %eax
f0100fcd:	e8 95 28 00 00       	call   f0103867 <cprintf>
			return 0;
f0100fd2:	83 c4 10             	add    $0x10,%esp
f0100fd5:	e9 54 ff ff ff       	jmp    f0100f2e <mon_dump+0x94>
		dump_v(v_start, v_end);
f0100fda:	83 ec 08             	sub    $0x8,%esp
f0100fdd:	50                   	push   %eax
f0100fde:	57                   	push   %edi
f0100fdf:	e8 03 fe ff ff       	call   f0100de7 <dump_v>
f0100fe4:	83 c4 10             	add    $0x10,%esp
f0100fe7:	e9 42 ff ff ff       	jmp    f0100f2e <mon_dump+0x94>
		cprintf("INVAILD ADDRESS TYPE\n");
f0100fec:	83 ec 0c             	sub    $0xc,%esp
f0100fef:	8d 83 da b9 fe ff    	lea    -0x14626(%ebx),%eax
f0100ff5:	50                   	push   %eax
f0100ff6:	e8 6c 28 00 00       	call   f0103867 <cprintf>
		return 0;
f0100ffb:	83 c4 10             	add    $0x10,%esp
f0100ffe:	e9 2b ff ff ff       	jmp    f0100f2e <mon_dump+0x94>

f0101003 <mAddr>:
{
f0101003:	55                   	push   %ebp
f0101004:	89 e5                	mov    %esp,%ebp
	*(uint32_t *)va = info;
f0101006:	8b 45 08             	mov    0x8(%ebp),%eax
f0101009:	8b 55 0c             	mov    0xc(%ebp),%edx
f010100c:	89 10                	mov    %edx,(%eax)
}
f010100e:	5d                   	pop    %ebp
f010100f:	c3                   	ret    

f0101010 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0101010:	55                   	push   %ebp
f0101011:	89 e5                	mov    %esp,%ebp
f0101013:	57                   	push   %edi
f0101014:	56                   	push   %esi
f0101015:	53                   	push   %ebx
f0101016:	83 ec 68             	sub    $0x68,%esp
f0101019:	e8 98 f1 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f010101e:	81 c3 ee 82 01 00    	add    $0x182ee,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0101024:	8d 83 00 be fe ff    	lea    -0x14200(%ebx),%eax
f010102a:	50                   	push   %eax
f010102b:	e8 37 28 00 00       	call   f0103867 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0101030:	8d 83 24 be fe ff    	lea    -0x141dc(%ebx),%eax
f0101036:	89 04 24             	mov    %eax,(%esp)
f0101039:	e8 29 28 00 00       	call   f0103867 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 0x0100, "blue", 0x0200, "green", 0x0400, "red");
f010103e:	83 c4 0c             	add    $0xc,%esp
f0101041:	8d 83 f0 b9 fe ff    	lea    -0x14610(%ebx),%eax
f0101047:	50                   	push   %eax
f0101048:	68 00 04 00 00       	push   $0x400
f010104d:	8d 83 f4 b9 fe ff    	lea    -0x1460c(%ebx),%eax
f0101053:	50                   	push   %eax
f0101054:	68 00 02 00 00       	push   $0x200
f0101059:	8d 83 fa b9 fe ff    	lea    -0x14606(%ebx),%eax
f010105f:	50                   	push   %eax
f0101060:	68 00 01 00 00       	push   $0x100
f0101065:	8d 83 ff b9 fe ff    	lea    -0x14601(%ebx),%eax
f010106b:	50                   	push   %eax
f010106c:	e8 f6 27 00 00       	call   f0103867 <cprintf>
f0101071:	83 c4 20             	add    $0x20,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0101074:	8d bb 13 ba fe ff    	lea    -0x145ed(%ebx),%edi
f010107a:	eb 4a                	jmp    f01010c6 <monitor+0xb6>
f010107c:	83 ec 08             	sub    $0x8,%esp
f010107f:	0f be c0             	movsbl %al,%eax
f0101082:	50                   	push   %eax
f0101083:	57                   	push   %edi
f0101084:	e8 08 34 00 00       	call   f0104491 <strchr>
f0101089:	83 c4 10             	add    $0x10,%esp
f010108c:	85 c0                	test   %eax,%eax
f010108e:	74 08                	je     f0101098 <monitor+0x88>
			*buf++ = 0;
f0101090:	c6 06 00             	movb   $0x0,(%esi)
f0101093:	8d 76 01             	lea    0x1(%esi),%esi
f0101096:	eb 79                	jmp    f0101111 <monitor+0x101>
		if (*buf == 0)
f0101098:	80 3e 00             	cmpb   $0x0,(%esi)
f010109b:	74 7f                	je     f010111c <monitor+0x10c>
		if (argc == MAXARGS-1) {
f010109d:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01010a1:	74 0f                	je     f01010b2 <monitor+0xa2>
		argv[argc++] = buf;
f01010a3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01010a6:	8d 48 01             	lea    0x1(%eax),%ecx
f01010a9:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01010ac:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01010b0:	eb 44                	jmp    f01010f6 <monitor+0xe6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01010b2:	83 ec 08             	sub    $0x8,%esp
f01010b5:	6a 10                	push   $0x10
f01010b7:	8d 83 18 ba fe ff    	lea    -0x145e8(%ebx),%eax
f01010bd:	50                   	push   %eax
f01010be:	e8 a4 27 00 00       	call   f0103867 <cprintf>
f01010c3:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01010c6:	8d 83 0f ba fe ff    	lea    -0x145f1(%ebx),%eax
f01010cc:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01010cf:	83 ec 0c             	sub    $0xc,%esp
f01010d2:	ff 75 a4             	pushl  -0x5c(%ebp)
f01010d5:	e8 7f 31 00 00       	call   f0104259 <readline>
f01010da:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01010dc:	83 c4 10             	add    $0x10,%esp
f01010df:	85 c0                	test   %eax,%eax
f01010e1:	74 ec                	je     f01010cf <monitor+0xbf>
	argv[argc] = 0;
f01010e3:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01010ea:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01010f1:	eb 1e                	jmp    f0101111 <monitor+0x101>
			buf++;
f01010f3:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01010f6:	0f b6 06             	movzbl (%esi),%eax
f01010f9:	84 c0                	test   %al,%al
f01010fb:	74 14                	je     f0101111 <monitor+0x101>
f01010fd:	83 ec 08             	sub    $0x8,%esp
f0101100:	0f be c0             	movsbl %al,%eax
f0101103:	50                   	push   %eax
f0101104:	57                   	push   %edi
f0101105:	e8 87 33 00 00       	call   f0104491 <strchr>
f010110a:	83 c4 10             	add    $0x10,%esp
f010110d:	85 c0                	test   %eax,%eax
f010110f:	74 e2                	je     f01010f3 <monitor+0xe3>
		while (*buf && strchr(WHITESPACE, *buf))
f0101111:	0f b6 06             	movzbl (%esi),%eax
f0101114:	84 c0                	test   %al,%al
f0101116:	0f 85 60 ff ff ff    	jne    f010107c <monitor+0x6c>
	argv[argc] = 0;
f010111c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010111f:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0101126:	00 
	if (argc == 0)
f0101127:	85 c0                	test   %eax,%eax
f0101129:	74 9b                	je     f01010c6 <monitor+0xb6>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010112b:	be 00 00 00 00       	mov    $0x0,%esi
		if (strcmp(argv[0], commands[i].name) == 0)
f0101130:	83 ec 08             	sub    $0x8,%esp
f0101133:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0101136:	ff b4 83 14 1d 00 00 	pushl  0x1d14(%ebx,%eax,4)
f010113d:	ff 75 a8             	pushl  -0x58(%ebp)
f0101140:	e8 ee 32 00 00       	call   f0104433 <strcmp>
f0101145:	83 c4 10             	add    $0x10,%esp
f0101148:	85 c0                	test   %eax,%eax
f010114a:	74 22                	je     f010116e <monitor+0x15e>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010114c:	83 c6 01             	add    $0x1,%esi
f010114f:	83 fe 07             	cmp    $0x7,%esi
f0101152:	75 dc                	jne    f0101130 <monitor+0x120>
	cprintf("Unknown command '%s'\n", argv[0]);
f0101154:	83 ec 08             	sub    $0x8,%esp
f0101157:	ff 75 a8             	pushl  -0x58(%ebp)
f010115a:	8d 83 35 ba fe ff    	lea    -0x145cb(%ebx),%eax
f0101160:	50                   	push   %eax
f0101161:	e8 01 27 00 00       	call   f0103867 <cprintf>
f0101166:	83 c4 10             	add    $0x10,%esp
f0101169:	e9 58 ff ff ff       	jmp    f01010c6 <monitor+0xb6>
			return commands[i].func(argc, argv, tf);
f010116e:	83 ec 04             	sub    $0x4,%esp
f0101171:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0101174:	ff 75 08             	pushl  0x8(%ebp)
f0101177:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010117a:	52                   	push   %edx
f010117b:	ff 75 a4             	pushl  -0x5c(%ebp)
f010117e:	ff 94 83 1c 1d 00 00 	call   *0x1d1c(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0101185:	83 c4 10             	add    $0x10,%esp
f0101188:	85 c0                	test   %eax,%eax
f010118a:	0f 89 36 ff ff ff    	jns    f01010c6 <monitor+0xb6>
				break;
	}
f0101190:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101193:	5b                   	pop    %ebx
f0101194:	5e                   	pop    %esi
f0101195:	5f                   	pop    %edi
f0101196:	5d                   	pop    %ebp
f0101197:	c3                   	ret    

f0101198 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101198:	55                   	push   %ebp
f0101199:	89 e5                	mov    %esp,%ebp
f010119b:	57                   	push   %edi
f010119c:	56                   	push   %esi
f010119d:	53                   	push   %ebx
f010119e:	83 ec 18             	sub    $0x18,%esp
f01011a1:	e8 10 f0 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01011a6:	81 c3 66 81 01 00    	add    $0x18166,%ebx
f01011ac:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01011ae:	50                   	push   %eax
f01011af:	e8 2c 26 00 00       	call   f01037e0 <mc146818_read>
f01011b4:	89 c6                	mov    %eax,%esi
f01011b6:	83 c7 01             	add    $0x1,%edi
f01011b9:	89 3c 24             	mov    %edi,(%esp)
f01011bc:	e8 1f 26 00 00       	call   f01037e0 <mc146818_read>
f01011c1:	c1 e0 08             	shl    $0x8,%eax
f01011c4:	09 f0                	or     %esi,%eax
}
f01011c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011c9:	5b                   	pop    %ebx
f01011ca:	5e                   	pop    %esi
f01011cb:	5f                   	pop    %edi
f01011cc:	5d                   	pop    %ebp
f01011cd:	c3                   	ret    

f01011ce <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01011ce:	55                   	push   %ebp
f01011cf:	89 e5                	mov    %esp,%ebp
f01011d1:	56                   	push   %esi
f01011d2:	53                   	push   %ebx
f01011d3:	e8 fc 25 00 00       	call   f01037d4 <__x86.get_pc_thunk.cx>
f01011d8:	81 c1 34 81 01 00    	add    $0x18134,%ecx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01011de:	83 b9 cc 1f 00 00 00 	cmpl   $0x0,0x1fcc(%ecx)
f01011e5:	74 37                	je     f010121e <boot_alloc+0x50>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f01011e7:	8b b1 cc 1f 00 00    	mov    0x1fcc(%ecx),%esi
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f01011ed:	8d 94 06 ff 0f 00 00 	lea    0xfff(%esi,%eax,1),%edx
f01011f4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01011fa:	89 91 cc 1f 00 00    	mov    %edx,0x1fcc(%ecx)
	assert((uint32_t) nextfree - KERNBASE <= (npages * PGSIZE));
f0101200:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101206:	c7 c0 e8 b6 11 f0    	mov    $0xf011b6e8,%eax
f010120c:	8b 18                	mov    (%eax),%ebx
f010120e:	c1 e3 0c             	shl    $0xc,%ebx
f0101211:	39 da                	cmp    %ebx,%edx
f0101213:	77 23                	ja     f0101238 <boot_alloc+0x6a>
	return result;

}
f0101215:	89 f0                	mov    %esi,%eax
f0101217:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010121a:	5b                   	pop    %ebx
f010121b:	5e                   	pop    %esi
f010121c:	5d                   	pop    %ebp
f010121d:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010121e:	c7 c2 e0 b6 11 f0    	mov    $0xf011b6e0,%edx
f0101224:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f010122a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101230:	89 91 cc 1f 00 00    	mov    %edx,0x1fcc(%ecx)
f0101236:	eb af                	jmp    f01011e7 <boot_alloc+0x19>
	assert((uint32_t) nextfree - KERNBASE <= (npages * PGSIZE));
f0101238:	8d 81 c4 be fe ff    	lea    -0x1413c(%ecx),%eax
f010123e:	50                   	push   %eax
f010123f:	8d 81 12 b9 fe ff    	lea    -0x146ee(%ecx),%eax
f0101245:	50                   	push   %eax
f0101246:	6a 6a                	push   $0x6a
f0101248:	8d 81 4c c6 fe ff    	lea    -0x139b4(%ecx),%eax
f010124e:	50                   	push   %eax
f010124f:	89 cb                	mov    %ecx,%ebx
f0101251:	e8 aa ee ff ff       	call   f0100100 <_panic>

f0101256 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101256:	55                   	push   %ebp
f0101257:	89 e5                	mov    %esp,%ebp
f0101259:	56                   	push   %esi
f010125a:	53                   	push   %ebx
f010125b:	e8 74 25 00 00       	call   f01037d4 <__x86.get_pc_thunk.cx>
f0101260:	81 c1 ac 80 01 00    	add    $0x180ac,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101266:	89 d3                	mov    %edx,%ebx
f0101268:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f010126b:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f010126e:	a8 01                	test   $0x1,%al
f0101270:	74 5a                	je     f01012cc <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101272:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101277:	89 c6                	mov    %eax,%esi
f0101279:	c1 ee 0c             	shr    $0xc,%esi
f010127c:	c7 c3 e8 b6 11 f0    	mov    $0xf011b6e8,%ebx
f0101282:	3b 33                	cmp    (%ebx),%esi
f0101284:	73 2b                	jae    f01012b1 <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0101286:	c1 ea 0c             	shr    $0xc,%edx
f0101289:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010128f:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101296:	89 c2                	mov    %eax,%edx
f0101298:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f010129b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01012a0:	85 d2                	test   %edx,%edx
f01012a2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01012a7:	0f 44 c2             	cmove  %edx,%eax
}
f01012aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012ad:	5b                   	pop    %ebx
f01012ae:	5e                   	pop    %esi
f01012af:	5d                   	pop    %ebp
f01012b0:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012b1:	50                   	push   %eax
f01012b2:	8d 81 78 bd fe ff    	lea    -0x14288(%ecx),%eax
f01012b8:	50                   	push   %eax
f01012b9:	68 00 03 00 00       	push   $0x300
f01012be:	8d 81 4c c6 fe ff    	lea    -0x139b4(%ecx),%eax
f01012c4:	50                   	push   %eax
f01012c5:	89 cb                	mov    %ecx,%ebx
f01012c7:	e8 34 ee ff ff       	call   f0100100 <_panic>
		return ~0;
f01012cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01012d1:	eb d7                	jmp    f01012aa <check_va2pa+0x54>

f01012d3 <check_page_free_list>:
{
f01012d3:	55                   	push   %ebp
f01012d4:	89 e5                	mov    %esp,%ebp
f01012d6:	57                   	push   %edi
f01012d7:	56                   	push   %esi
f01012d8:	53                   	push   %ebx
f01012d9:	83 ec 3c             	sub    $0x3c,%esp
f01012dc:	e8 fb 24 00 00       	call   f01037dc <__x86.get_pc_thunk.di>
f01012e1:	81 c7 2b 80 01 00    	add    $0x1802b,%edi
f01012e7:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012ea:	84 c0                	test   %al,%al
f01012ec:	0f 85 dd 02 00 00    	jne    f01015cf <check_page_free_list+0x2fc>
	if (!page_free_list)
f01012f2:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01012f5:	83 b8 d0 1f 00 00 00 	cmpl   $0x0,0x1fd0(%eax)
f01012fc:	74 0c                	je     f010130a <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012fe:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0101305:	e9 2f 03 00 00       	jmp    f0101639 <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f010130a:	83 ec 04             	sub    $0x4,%esp
f010130d:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101310:	8d 83 f8 be fe ff    	lea    -0x14108(%ebx),%eax
f0101316:	50                   	push   %eax
f0101317:	68 3e 02 00 00       	push   $0x23e
f010131c:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101322:	50                   	push   %eax
f0101323:	e8 d8 ed ff ff       	call   f0100100 <_panic>
f0101328:	50                   	push   %eax
f0101329:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010132c:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f0101332:	50                   	push   %eax
f0101333:	6a 52                	push   $0x52
f0101335:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f010133b:	50                   	push   %eax
f010133c:	e8 bf ed ff ff       	call   f0100100 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101341:	8b 36                	mov    (%esi),%esi
f0101343:	85 f6                	test   %esi,%esi
f0101345:	74 40                	je     f0101387 <check_page_free_list+0xb4>
	return (pp - pages) << PGSHIFT;
f0101347:	89 f0                	mov    %esi,%eax
f0101349:	2b 07                	sub    (%edi),%eax
f010134b:	c1 f8 03             	sar    $0x3,%eax
f010134e:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0101351:	89 c2                	mov    %eax,%edx
f0101353:	c1 ea 16             	shr    $0x16,%edx
f0101356:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101359:	73 e6                	jae    f0101341 <check_page_free_list+0x6e>
	if (PGNUM(pa) >= npages)
f010135b:	89 c2                	mov    %eax,%edx
f010135d:	c1 ea 0c             	shr    $0xc,%edx
f0101360:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101363:	3b 11                	cmp    (%ecx),%edx
f0101365:	73 c1                	jae    f0101328 <check_page_free_list+0x55>
			memset(page2kva(pp), 0x97, 128);
f0101367:	83 ec 04             	sub    $0x4,%esp
f010136a:	68 80 00 00 00       	push   $0x80
f010136f:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101374:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101379:	50                   	push   %eax
f010137a:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010137d:	e8 4c 31 00 00       	call   f01044ce <memset>
f0101382:	83 c4 10             	add    $0x10,%esp
f0101385:	eb ba                	jmp    f0101341 <check_page_free_list+0x6e>
	first_free_page = (char *) boot_alloc(0);
f0101387:	b8 00 00 00 00       	mov    $0x0,%eax
f010138c:	e8 3d fe ff ff       	call   f01011ce <boot_alloc>
f0101391:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101394:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0101397:	8b 97 d0 1f 00 00    	mov    0x1fd0(%edi),%edx
		assert(pp >= pages);
f010139d:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f01013a3:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f01013a5:	c7 c0 e8 b6 11 f0    	mov    $0xf011b6e8,%eax
f01013ab:	8b 00                	mov    (%eax),%eax
f01013ad:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01013b0:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01013b3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f01013b6:	bf 00 00 00 00       	mov    $0x0,%edi
f01013bb:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01013be:	e9 08 01 00 00       	jmp    f01014cb <check_page_free_list+0x1f8>
		assert(pp >= pages);
f01013c3:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01013c6:	8d 83 66 c6 fe ff    	lea    -0x1399a(%ebx),%eax
f01013cc:	50                   	push   %eax
f01013cd:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01013d3:	50                   	push   %eax
f01013d4:	68 58 02 00 00       	push   $0x258
f01013d9:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01013df:	50                   	push   %eax
f01013e0:	e8 1b ed ff ff       	call   f0100100 <_panic>
		assert(pp < pages + npages);
f01013e5:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01013e8:	8d 83 72 c6 fe ff    	lea    -0x1398e(%ebx),%eax
f01013ee:	50                   	push   %eax
f01013ef:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01013f5:	50                   	push   %eax
f01013f6:	68 59 02 00 00       	push   $0x259
f01013fb:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101401:	50                   	push   %eax
f0101402:	e8 f9 ec ff ff       	call   f0100100 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101407:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010140a:	8d 83 1c bf fe ff    	lea    -0x140e4(%ebx),%eax
f0101410:	50                   	push   %eax
f0101411:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101417:	50                   	push   %eax
f0101418:	68 5a 02 00 00       	push   $0x25a
f010141d:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101423:	50                   	push   %eax
f0101424:	e8 d7 ec ff ff       	call   f0100100 <_panic>
		assert(page2pa(pp) != 0);
f0101429:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010142c:	8d 83 86 c6 fe ff    	lea    -0x1397a(%ebx),%eax
f0101432:	50                   	push   %eax
f0101433:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101439:	50                   	push   %eax
f010143a:	68 5d 02 00 00       	push   $0x25d
f010143f:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101445:	50                   	push   %eax
f0101446:	e8 b5 ec ff ff       	call   f0100100 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010144b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010144e:	8d 83 97 c6 fe ff    	lea    -0x13969(%ebx),%eax
f0101454:	50                   	push   %eax
f0101455:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010145b:	50                   	push   %eax
f010145c:	68 5e 02 00 00       	push   $0x25e
f0101461:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101467:	50                   	push   %eax
f0101468:	e8 93 ec ff ff       	call   f0100100 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010146d:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101470:	8d 83 50 bf fe ff    	lea    -0x140b0(%ebx),%eax
f0101476:	50                   	push   %eax
f0101477:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010147d:	50                   	push   %eax
f010147e:	68 5f 02 00 00       	push   $0x25f
f0101483:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101489:	50                   	push   %eax
f010148a:	e8 71 ec ff ff       	call   f0100100 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010148f:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101492:	8d 83 b0 c6 fe ff    	lea    -0x13950(%ebx),%eax
f0101498:	50                   	push   %eax
f0101499:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010149f:	50                   	push   %eax
f01014a0:	68 60 02 00 00       	push   $0x260
f01014a5:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01014ab:	50                   	push   %eax
f01014ac:	e8 4f ec ff ff       	call   f0100100 <_panic>
	if (PGNUM(pa) >= npages)
f01014b1:	89 c6                	mov    %eax,%esi
f01014b3:	c1 ee 0c             	shr    $0xc,%esi
f01014b6:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f01014b9:	76 70                	jbe    f010152b <check_page_free_list+0x258>
	return (void *)(pa + KERNBASE);
f01014bb:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01014c0:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f01014c3:	77 7f                	ja     f0101544 <check_page_free_list+0x271>
			++nfree_extmem;
f01014c5:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01014c9:	8b 12                	mov    (%edx),%edx
f01014cb:	85 d2                	test   %edx,%edx
f01014cd:	0f 84 93 00 00 00    	je     f0101566 <check_page_free_list+0x293>
		assert(pp >= pages);
f01014d3:	39 d1                	cmp    %edx,%ecx
f01014d5:	0f 87 e8 fe ff ff    	ja     f01013c3 <check_page_free_list+0xf0>
		assert(pp < pages + npages);
f01014db:	39 d3                	cmp    %edx,%ebx
f01014dd:	0f 86 02 ff ff ff    	jbe    f01013e5 <check_page_free_list+0x112>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01014e3:	89 d0                	mov    %edx,%eax
f01014e5:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f01014e8:	a8 07                	test   $0x7,%al
f01014ea:	0f 85 17 ff ff ff    	jne    f0101407 <check_page_free_list+0x134>
	return (pp - pages) << PGSHIFT;
f01014f0:	c1 f8 03             	sar    $0x3,%eax
f01014f3:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f01014f6:	85 c0                	test   %eax,%eax
f01014f8:	0f 84 2b ff ff ff    	je     f0101429 <check_page_free_list+0x156>
		assert(page2pa(pp) != IOPHYSMEM);
f01014fe:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101503:	0f 84 42 ff ff ff    	je     f010144b <check_page_free_list+0x178>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101509:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010150e:	0f 84 59 ff ff ff    	je     f010146d <check_page_free_list+0x19a>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101514:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101519:	0f 84 70 ff ff ff    	je     f010148f <check_page_free_list+0x1bc>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010151f:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101524:	77 8b                	ja     f01014b1 <check_page_free_list+0x1de>
			++nfree_basemem;
f0101526:	83 c7 01             	add    $0x1,%edi
f0101529:	eb 9e                	jmp    f01014c9 <check_page_free_list+0x1f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010152b:	50                   	push   %eax
f010152c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010152f:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f0101535:	50                   	push   %eax
f0101536:	6a 52                	push   $0x52
f0101538:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f010153e:	50                   	push   %eax
f010153f:	e8 bc eb ff ff       	call   f0100100 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101544:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101547:	8d 83 74 bf fe ff    	lea    -0x1408c(%ebx),%eax
f010154d:	50                   	push   %eax
f010154e:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101554:	50                   	push   %eax
f0101555:	68 61 02 00 00       	push   $0x261
f010155a:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101560:	50                   	push   %eax
f0101561:	e8 9a eb ff ff       	call   f0100100 <_panic>
f0101566:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0101569:	85 ff                	test   %edi,%edi
f010156b:	7e 1e                	jle    f010158b <check_page_free_list+0x2b8>
	assert(nfree_extmem > 0);
f010156d:	85 f6                	test   %esi,%esi
f010156f:	7e 3c                	jle    f01015ad <check_page_free_list+0x2da>
	cprintf("check_page_free_list() succeeded!\n");
f0101571:	83 ec 0c             	sub    $0xc,%esp
f0101574:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101577:	8d 83 bc bf fe ff    	lea    -0x14044(%ebx),%eax
f010157d:	50                   	push   %eax
f010157e:	e8 e4 22 00 00       	call   f0103867 <cprintf>
}
f0101583:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101586:	5b                   	pop    %ebx
f0101587:	5e                   	pop    %esi
f0101588:	5f                   	pop    %edi
f0101589:	5d                   	pop    %ebp
f010158a:	c3                   	ret    
	assert(nfree_basemem > 0);
f010158b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010158e:	8d 83 ca c6 fe ff    	lea    -0x13936(%ebx),%eax
f0101594:	50                   	push   %eax
f0101595:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010159b:	50                   	push   %eax
f010159c:	68 69 02 00 00       	push   $0x269
f01015a1:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01015a7:	50                   	push   %eax
f01015a8:	e8 53 eb ff ff       	call   f0100100 <_panic>
	assert(nfree_extmem > 0);
f01015ad:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01015b0:	8d 83 dc c6 fe ff    	lea    -0x13924(%ebx),%eax
f01015b6:	50                   	push   %eax
f01015b7:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01015bd:	50                   	push   %eax
f01015be:	68 6a 02 00 00       	push   $0x26a
f01015c3:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01015c9:	50                   	push   %eax
f01015ca:	e8 31 eb ff ff       	call   f0100100 <_panic>
	if (!page_free_list)
f01015cf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01015d2:	8b 80 d0 1f 00 00    	mov    0x1fd0(%eax),%eax
f01015d8:	85 c0                	test   %eax,%eax
f01015da:	0f 84 2a fd ff ff    	je     f010130a <check_page_free_list+0x37>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01015e0:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01015e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01015e6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01015e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f01015ec:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01015ef:	c7 c3 f0 b6 11 f0    	mov    $0xf011b6f0,%ebx
f01015f5:	89 c2                	mov    %eax,%edx
f01015f7:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01015f9:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01015ff:	0f 95 c2             	setne  %dl
f0101602:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101605:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101609:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f010160b:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010160f:	8b 00                	mov    (%eax),%eax
f0101611:	85 c0                	test   %eax,%eax
f0101613:	75 e0                	jne    f01015f5 <check_page_free_list+0x322>
		*tp[1] = 0;
f0101615:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101618:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010161e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101621:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101624:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101626:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101629:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010162c:	89 87 d0 1f 00 00    	mov    %eax,0x1fd0(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101632:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101639:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010163c:	8b b0 d0 1f 00 00    	mov    0x1fd0(%eax),%esi
f0101642:	c7 c7 f0 b6 11 f0    	mov    $0xf011b6f0,%edi
	if (PGNUM(pa) >= npages)
f0101648:	c7 c0 e8 b6 11 f0    	mov    $0xf011b6e8,%eax
f010164e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101651:	e9 ed fc ff ff       	jmp    f0101343 <check_page_free_list+0x70>

f0101656 <page_init>:
{
f0101656:	55                   	push   %ebp
f0101657:	89 e5                	mov    %esp,%ebp
f0101659:	57                   	push   %edi
f010165a:	56                   	push   %esi
f010165b:	53                   	push   %ebx
f010165c:	83 ec 1c             	sub    $0x1c,%esp
f010165f:	e8 74 21 00 00       	call   f01037d8 <__x86.get_pc_thunk.si>
f0101664:	81 c6 a8 7c 01 00    	add    $0x17ca8,%esi
f010166a:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	npages_basemem = nvram_read(NVRAM_BASELO) / (PGSIZE / 1024);
f010166d:	b8 15 00 00 00       	mov    $0x15,%eax
f0101672:	e8 21 fb ff ff       	call   f0101198 <nvram_read>
f0101677:	8d 50 03             	lea    0x3(%eax),%edx
f010167a:	85 c0                	test   %eax,%eax
f010167c:	0f 48 c2             	cmovs  %edx,%eax
f010167f:	c1 f8 02             	sar    $0x2,%eax
f0101682:	89 45 e0             	mov    %eax,-0x20(%ebp)
	ext_allocated = ((size_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f0101685:	b8 00 00 00 00       	mov    $0x0,%eax
f010168a:	e8 3f fb ff ff       	call   f01011ce <boot_alloc>
f010168f:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0101695:	c1 ef 0c             	shr    $0xc,%edi
	pages[0].pp_ref = 1;
f0101698:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f010169e:	8b 00                	mov    (%eax),%eax
f01016a0:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f01016a6:	8b 9e d0 1f 00 00    	mov    0x1fd0(%esi),%ebx
	for (i = 1; i < npages_basemem; i++)
f01016ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01016b1:	ba 01 00 00 00       	mov    $0x1,%edx
		pages[i].pp_ref = 0;
f01016b6:	c7 c6 f0 b6 11 f0    	mov    $0xf011b6f0,%esi
f01016bc:	89 7d dc             	mov    %edi,-0x24(%ebp)
f01016bf:	8b 7d e0             	mov    -0x20(%ebp),%edi
	for (i = 1; i < npages_basemem; i++)
f01016c2:	eb 1f                	jmp    f01016e3 <page_init+0x8d>
		pages[i].pp_ref = 0;
f01016c4:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01016cb:	89 c1                	mov    %eax,%ecx
f01016cd:	03 0e                	add    (%esi),%ecx
f01016cf:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01016d5:	89 19                	mov    %ebx,(%ecx)
	for (i = 1; i < npages_basemem; i++)
f01016d7:	83 c2 01             	add    $0x1,%edx
		page_free_list = &pages[i];
f01016da:	03 06                	add    (%esi),%eax
f01016dc:	89 c3                	mov    %eax,%ebx
f01016de:	b8 01 00 00 00       	mov    $0x1,%eax
	for (i = 1; i < npages_basemem; i++)
f01016e3:	39 fa                	cmp    %edi,%edx
f01016e5:	72 dd                	jb     f01016c4 <page_init+0x6e>
f01016e7:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01016ea:	84 c0                	test   %al,%al
f01016ec:	75 12                	jne    f0101700 <page_init+0xaa>
		pages[i].pp_ref = 1;
f01016ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01016f1:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f01016f7:	8b 08                	mov    (%eax),%ecx
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE + ext_allocated; i++)
f01016f9:	ba a0 00 00 00       	mov    $0xa0,%edx
f01016fe:	eb 15                	jmp    f0101715 <page_init+0xbf>
f0101700:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101703:	89 98 d0 1f 00 00    	mov    %ebx,0x1fd0(%eax)
f0101709:	eb e3                	jmp    f01016ee <page_init+0x98>
		pages[i].pp_ref = 1;
f010170b:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE + ext_allocated; i++)
f0101712:	83 c2 01             	add    $0x1,%edx
f0101715:	8d 87 00 01 00 00    	lea    0x100(%edi),%eax
f010171b:	39 d0                	cmp    %edx,%eax
f010171d:	77 ec                	ja     f010170b <page_init+0xb5>
f010171f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101722:	8b 9e d0 1f 00 00    	mov    0x1fd0(%esi),%ebx
f0101728:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010172f:	b9 00 00 00 00       	mov    $0x0,%ecx
	for (i = EXTPHYSMEM / PGSIZE + ext_allocated; i < npages; i++)
f0101734:	c7 c7 e8 b6 11 f0    	mov    $0xf011b6e8,%edi
		pages[i].pp_ref = 0;
f010173a:	c7 c6 f0 b6 11 f0    	mov    $0xf011b6f0,%esi
f0101740:	eb 1b                	jmp    f010175d <page_init+0x107>
f0101742:	89 d1                	mov    %edx,%ecx
f0101744:	03 0e                	add    (%esi),%ecx
f0101746:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010174c:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f010174e:	89 d3                	mov    %edx,%ebx
f0101750:	03 1e                	add    (%esi),%ebx
	for (i = EXTPHYSMEM / PGSIZE + ext_allocated; i < npages; i++)
f0101752:	83 c0 01             	add    $0x1,%eax
f0101755:	83 c2 08             	add    $0x8,%edx
f0101758:	b9 01 00 00 00       	mov    $0x1,%ecx
f010175d:	39 07                	cmp    %eax,(%edi)
f010175f:	77 e1                	ja     f0101742 <page_init+0xec>
f0101761:	84 c9                	test   %cl,%cl
f0101763:	75 08                	jne    f010176d <page_init+0x117>
}
f0101765:	83 c4 1c             	add    $0x1c,%esp
f0101768:	5b                   	pop    %ebx
f0101769:	5e                   	pop    %esi
f010176a:	5f                   	pop    %edi
f010176b:	5d                   	pop    %ebp
f010176c:	c3                   	ret    
f010176d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101770:	89 98 d0 1f 00 00    	mov    %ebx,0x1fd0(%eax)
f0101776:	eb ed                	jmp    f0101765 <page_init+0x10f>

f0101778 <page_alloc>:
{
f0101778:	55                   	push   %ebp
f0101779:	89 e5                	mov    %esp,%ebp
f010177b:	56                   	push   %esi
f010177c:	53                   	push   %ebx
f010177d:	e8 34 ea ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0101782:	81 c3 8a 7b 01 00    	add    $0x17b8a,%ebx
	if (!page_free_list)
f0101788:	8b b3 d0 1f 00 00    	mov    0x1fd0(%ebx),%esi
f010178e:	85 f6                	test   %esi,%esi
f0101790:	74 14                	je     f01017a6 <page_alloc+0x2e>
	page_free_list = page_free_list->pp_link;
f0101792:	8b 06                	mov    (%esi),%eax
f0101794:	89 83 d0 1f 00 00    	mov    %eax,0x1fd0(%ebx)
	page->pp_link = NULL;
f010179a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO)
f01017a0:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01017a4:	75 09                	jne    f01017af <page_alloc+0x37>
}
f01017a6:	89 f0                	mov    %esi,%eax
f01017a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01017ab:	5b                   	pop    %ebx
f01017ac:	5e                   	pop    %esi
f01017ad:	5d                   	pop    %ebp
f01017ae:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f01017af:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f01017b5:	89 f2                	mov    %esi,%edx
f01017b7:	2b 10                	sub    (%eax),%edx
f01017b9:	89 d0                	mov    %edx,%eax
f01017bb:	c1 f8 03             	sar    $0x3,%eax
f01017be:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01017c1:	89 c1                	mov    %eax,%ecx
f01017c3:	c1 e9 0c             	shr    $0xc,%ecx
f01017c6:	c7 c2 e8 b6 11 f0    	mov    $0xf011b6e8,%edx
f01017cc:	3b 0a                	cmp    (%edx),%ecx
f01017ce:	73 1a                	jae    f01017ea <page_alloc+0x72>
		memset(page2kva(page), 0, PGSIZE);
f01017d0:	83 ec 04             	sub    $0x4,%esp
f01017d3:	68 00 10 00 00       	push   $0x1000
f01017d8:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01017da:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017df:	50                   	push   %eax
f01017e0:	e8 e9 2c 00 00       	call   f01044ce <memset>
f01017e5:	83 c4 10             	add    $0x10,%esp
f01017e8:	eb bc                	jmp    f01017a6 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017ea:	50                   	push   %eax
f01017eb:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f01017f1:	50                   	push   %eax
f01017f2:	6a 52                	push   $0x52
f01017f4:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f01017fa:	50                   	push   %eax
f01017fb:	e8 00 e9 ff ff       	call   f0100100 <_panic>

f0101800 <page_free>:
{
f0101800:	55                   	push   %ebp
f0101801:	89 e5                	mov    %esp,%ebp
f0101803:	53                   	push   %ebx
f0101804:	83 ec 04             	sub    $0x4,%esp
f0101807:	e8 aa e9 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f010180c:	81 c3 00 7b 01 00    	add    $0x17b00,%ebx
f0101812:	8b 45 08             	mov    0x8(%ebp),%eax
	assert(pp->pp_ref == 0);
f0101815:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010181a:	75 18                	jne    f0101834 <page_free+0x34>
	assert(!pp->pp_link);
f010181c:	83 38 00             	cmpl   $0x0,(%eax)
f010181f:	75 32                	jne    f0101853 <page_free+0x53>
	pp->pp_link = page_free_list;
f0101821:	8b 8b d0 1f 00 00    	mov    0x1fd0(%ebx),%ecx
f0101827:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f0101829:	89 83 d0 1f 00 00    	mov    %eax,0x1fd0(%ebx)
}
f010182f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101832:	c9                   	leave  
f0101833:	c3                   	ret    
	assert(pp->pp_ref == 0);
f0101834:	8d 83 ed c6 fe ff    	lea    -0x13913(%ebx),%eax
f010183a:	50                   	push   %eax
f010183b:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101841:	50                   	push   %eax
f0101842:	68 56 01 00 00       	push   $0x156
f0101847:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010184d:	50                   	push   %eax
f010184e:	e8 ad e8 ff ff       	call   f0100100 <_panic>
	assert(!pp->pp_link);
f0101853:	8d 83 fd c6 fe ff    	lea    -0x13903(%ebx),%eax
f0101859:	50                   	push   %eax
f010185a:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101860:	50                   	push   %eax
f0101861:	68 57 01 00 00       	push   $0x157
f0101866:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010186c:	50                   	push   %eax
f010186d:	e8 8e e8 ff ff       	call   f0100100 <_panic>

f0101872 <page_decref>:
{
f0101872:	55                   	push   %ebp
f0101873:	89 e5                	mov    %esp,%ebp
f0101875:	83 ec 08             	sub    $0x8,%esp
f0101878:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010187b:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010187f:	83 e8 01             	sub    $0x1,%eax
f0101882:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101886:	66 85 c0             	test   %ax,%ax
f0101889:	74 02                	je     f010188d <page_decref+0x1b>
}
f010188b:	c9                   	leave  
f010188c:	c3                   	ret    
		page_free(pp);
f010188d:	83 ec 0c             	sub    $0xc,%esp
f0101890:	52                   	push   %edx
f0101891:	e8 6a ff ff ff       	call   f0101800 <page_free>
f0101896:	83 c4 10             	add    $0x10,%esp
}
f0101899:	eb f0                	jmp    f010188b <page_decref+0x19>

f010189b <pgdir_walk>:
{
f010189b:	55                   	push   %ebp
f010189c:	89 e5                	mov    %esp,%ebp
f010189e:	57                   	push   %edi
f010189f:	56                   	push   %esi
f01018a0:	53                   	push   %ebx
f01018a1:	83 ec 0c             	sub    $0xc,%esp
f01018a4:	e8 0d e9 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01018a9:	81 c3 63 7a 01 00    	add    $0x17a63,%ebx
f01018af:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pde = &pgdir[PDX(va)];
f01018b2:	89 fe                	mov    %edi,%esi
f01018b4:	c1 ee 16             	shr    $0x16,%esi
f01018b7:	c1 e6 02             	shl    $0x2,%esi
f01018ba:	03 75 08             	add    0x8(%ebp),%esi
	if (!(*pde & PTE_P))
f01018bd:	f6 06 01             	testb  $0x1,(%esi)
f01018c0:	75 2f                	jne    f01018f1 <pgdir_walk+0x56>
		if (create)
f01018c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01018c6:	74 70                	je     f0101938 <pgdir_walk+0x9d>
			page = page_alloc(1);
f01018c8:	83 ec 0c             	sub    $0xc,%esp
f01018cb:	6a 01                	push   $0x1
f01018cd:	e8 a6 fe ff ff       	call   f0101778 <page_alloc>
			if (!page)
f01018d2:	83 c4 10             	add    $0x10,%esp
f01018d5:	85 c0                	test   %eax,%eax
f01018d7:	74 66                	je     f010193f <pgdir_walk+0xa4>
			page->pp_ref++;
f01018d9:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01018de:	c7 c2 f0 b6 11 f0    	mov    $0xf011b6f0,%edx
f01018e4:	2b 02                	sub    (%edx),%eax
f01018e6:	c1 f8 03             	sar    $0x3,%eax
f01018e9:	c1 e0 0c             	shl    $0xc,%eax
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f01018ec:	83 c8 07             	or     $0x7,%eax
f01018ef:	89 06                	mov    %eax,(%esi)
	page_base = KADDR(PTE_ADDR(*pde));
f01018f1:	8b 06                	mov    (%esi),%eax
f01018f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01018f8:	89 c1                	mov    %eax,%ecx
f01018fa:	c1 e9 0c             	shr    $0xc,%ecx
f01018fd:	c7 c2 e8 b6 11 f0    	mov    $0xf011b6e8,%edx
f0101903:	3b 0a                	cmp    (%edx),%ecx
f0101905:	73 18                	jae    f010191f <pgdir_walk+0x84>
	page_off = PTX(va);
f0101907:	c1 ef 0a             	shr    $0xa,%edi
	return &page_base[page_off];
f010190a:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f0101910:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
}
f0101917:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010191a:	5b                   	pop    %ebx
f010191b:	5e                   	pop    %esi
f010191c:	5f                   	pop    %edi
f010191d:	5d                   	pop    %ebp
f010191e:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010191f:	50                   	push   %eax
f0101920:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f0101926:	50                   	push   %eax
f0101927:	68 98 01 00 00       	push   $0x198
f010192c:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101932:	50                   	push   %eax
f0101933:	e8 c8 e7 ff ff       	call   f0100100 <_panic>
			return NULL;
f0101938:	b8 00 00 00 00       	mov    $0x0,%eax
f010193d:	eb d8                	jmp    f0101917 <pgdir_walk+0x7c>
				return NULL;
f010193f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101944:	eb d1                	jmp    f0101917 <pgdir_walk+0x7c>

f0101946 <boot_map_region>:
{
f0101946:	55                   	push   %ebp
f0101947:	89 e5                	mov    %esp,%ebp
f0101949:	57                   	push   %edi
f010194a:	56                   	push   %esi
f010194b:	53                   	push   %ebx
f010194c:	83 ec 1c             	sub    $0x1c,%esp
f010194f:	89 c7                	mov    %eax,%edi
f0101951:	89 d6                	mov    %edx,%esi
f0101953:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0; i < size; i += PGSIZE)
f0101956:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pte = (pa + i) | perm | PTE_P;
f010195b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010195e:	83 c8 01             	or     $0x1,%eax
f0101961:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0; i < size; i += PGSIZE)
f0101964:	eb 22                	jmp    f0101988 <boot_map_region+0x42>
		pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f0101966:	83 ec 04             	sub    $0x4,%esp
f0101969:	6a 01                	push   $0x1
f010196b:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f010196e:	50                   	push   %eax
f010196f:	57                   	push   %edi
f0101970:	e8 26 ff ff ff       	call   f010189b <pgdir_walk>
		*pte = (pa + i) | perm | PTE_P;
f0101975:	89 da                	mov    %ebx,%edx
f0101977:	03 55 08             	add    0x8(%ebp),%edx
f010197a:	0b 55 e0             	or     -0x20(%ebp),%edx
f010197d:	89 10                	mov    %edx,(%eax)
	for (i = 0; i < size; i += PGSIZE)
f010197f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101985:	83 c4 10             	add    $0x10,%esp
f0101988:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010198b:	72 d9                	jb     f0101966 <boot_map_region+0x20>
}
f010198d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101990:	5b                   	pop    %ebx
f0101991:	5e                   	pop    %esi
f0101992:	5f                   	pop    %edi
f0101993:	5d                   	pop    %ebp
f0101994:	c3                   	ret    

f0101995 <page_lookup>:
{
f0101995:	55                   	push   %ebp
f0101996:	89 e5                	mov    %esp,%ebp
f0101998:	56                   	push   %esi
f0101999:	53                   	push   %ebx
f010199a:	e8 17 e8 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f010199f:	81 c3 6d 79 01 00    	add    $0x1796d,%ebx
f01019a5:	8b 75 10             	mov    0x10(%ebp),%esi
	pte = pgdir_walk(pgdir, va, 0);
f01019a8:	83 ec 04             	sub    $0x4,%esp
f01019ab:	6a 00                	push   $0x0
f01019ad:	ff 75 0c             	pushl  0xc(%ebp)
f01019b0:	ff 75 08             	pushl  0x8(%ebp)
f01019b3:	e8 e3 fe ff ff       	call   f010189b <pgdir_walk>
	if (!pte)
f01019b8:	83 c4 10             	add    $0x10,%esp
f01019bb:	85 c0                	test   %eax,%eax
f01019bd:	74 3f                	je     f01019fe <page_lookup+0x69>
	if (pte_store)
f01019bf:	85 f6                	test   %esi,%esi
f01019c1:	74 02                	je     f01019c5 <page_lookup+0x30>
		*pte_store = pte;
f01019c3:	89 06                	mov    %eax,(%esi)
f01019c5:	8b 00                	mov    (%eax),%eax
f01019c7:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019ca:	c7 c2 e8 b6 11 f0    	mov    $0xf011b6e8,%edx
f01019d0:	39 02                	cmp    %eax,(%edx)
f01019d2:	76 12                	jbe    f01019e6 <page_lookup+0x51>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01019d4:	c7 c2 f0 b6 11 f0    	mov    $0xf011b6f0,%edx
f01019da:	8b 12                	mov    (%edx),%edx
f01019dc:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01019df:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01019e2:	5b                   	pop    %ebx
f01019e3:	5e                   	pop    %esi
f01019e4:	5d                   	pop    %ebp
f01019e5:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01019e6:	83 ec 04             	sub    $0x4,%esp
f01019e9:	8d 83 e0 bf fe ff    	lea    -0x14020(%ebx),%eax
f01019ef:	50                   	push   %eax
f01019f0:	6a 4b                	push   $0x4b
f01019f2:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f01019f8:	50                   	push   %eax
f01019f9:	e8 02 e7 ff ff       	call   f0100100 <_panic>
		return NULL;
f01019fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a03:	eb da                	jmp    f01019df <page_lookup+0x4a>

f0101a05 <page_remove>:
{
f0101a05:	55                   	push   %ebp
f0101a06:	89 e5                	mov    %esp,%ebp
f0101a08:	53                   	push   %ebx
f0101a09:	83 ec 18             	sub    $0x18,%esp
f0101a0c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte = NULL;
f0101a0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	page = page_lookup(pgdir, va, &pte);
f0101a16:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101a19:	50                   	push   %eax
f0101a1a:	53                   	push   %ebx
f0101a1b:	ff 75 08             	pushl  0x8(%ebp)
f0101a1e:	e8 72 ff ff ff       	call   f0101995 <page_lookup>
	if (!page)
f0101a23:	83 c4 10             	add    $0x10,%esp
f0101a26:	85 c0                	test   %eax,%eax
f0101a28:	74 15                	je     f0101a3f <page_remove+0x3a>
	page_decref(page);
f0101a2a:	83 ec 0c             	sub    $0xc,%esp
f0101a2d:	50                   	push   %eax
f0101a2e:	e8 3f fe ff ff       	call   f0101872 <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101a33:	0f 01 3b             	invlpg (%ebx)
	(*pte) &= perm;
f0101a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101a39:	83 20 fe             	andl   $0xfffffffe,(%eax)
	return;
f0101a3c:	83 c4 10             	add    $0x10,%esp
}
f0101a3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101a42:	c9                   	leave  
f0101a43:	c3                   	ret    

f0101a44 <page_insert>:
{
f0101a44:	55                   	push   %ebp
f0101a45:	89 e5                	mov    %esp,%ebp
f0101a47:	57                   	push   %edi
f0101a48:	56                   	push   %esi
f0101a49:	53                   	push   %ebx
f0101a4a:	83 ec 10             	sub    $0x10,%esp
f0101a4d:	e8 8a 1d 00 00       	call   f01037dc <__x86.get_pc_thunk.di>
f0101a52:	81 c7 ba 78 01 00    	add    $0x178ba,%edi
	pte = pgdir_walk(pgdir, va, 1);
f0101a58:	6a 01                	push   $0x1
f0101a5a:	ff 75 10             	pushl  0x10(%ebp)
f0101a5d:	ff 75 08             	pushl  0x8(%ebp)
f0101a60:	e8 36 fe ff ff       	call   f010189b <pgdir_walk>
f0101a65:	89 c3                	mov    %eax,%ebx
	pde = &pgdir[PDX(va)];
f0101a67:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a6a:	c1 e8 16             	shr    $0x16,%eax
f0101a6d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101a70:	8d 34 86             	lea    (%esi,%eax,4),%esi
	if (!pte)
f0101a73:	83 c4 10             	add    $0x10,%esp
f0101a76:	85 db                	test   %ebx,%ebx
f0101a78:	74 4f                	je     f0101ac9 <page_insert+0x85>
	pp->pp_ref++;
f0101a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a7d:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	if ((*pte) & PTE_P)
f0101a82:	f6 03 01             	testb  $0x1,(%ebx)
f0101a85:	75 2f                	jne    f0101ab6 <page_insert+0x72>
	return (pp - pages) << PGSHIFT;
f0101a87:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0101a8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101a90:	2b 08                	sub    (%eax),%ecx
f0101a92:	89 c8                	mov    %ecx,%eax
f0101a94:	c1 f8 03             	sar    $0x3,%eax
f0101a97:	c1 e0 0c             	shl    $0xc,%eax
	*pte = page2pa(pp) | perm | PTE_P;
f0101a9a:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a9d:	83 ca 01             	or     $0x1,%edx
f0101aa0:	09 d0                	or     %edx,%eax
f0101aa2:	89 03                	mov    %eax,(%ebx)
	*pde = *pde | perm;
f0101aa4:	8b 45 14             	mov    0x14(%ebp),%eax
f0101aa7:	09 06                	or     %eax,(%esi)
	return 0;
f0101aa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101aae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101ab1:	5b                   	pop    %ebx
f0101ab2:	5e                   	pop    %esi
f0101ab3:	5f                   	pop    %edi
f0101ab4:	5d                   	pop    %ebp
f0101ab5:	c3                   	ret    
		page_remove(pgdir, va);
f0101ab6:	83 ec 08             	sub    $0x8,%esp
f0101ab9:	ff 75 10             	pushl  0x10(%ebp)
f0101abc:	ff 75 08             	pushl  0x8(%ebp)
f0101abf:	e8 41 ff ff ff       	call   f0101a05 <page_remove>
f0101ac4:	83 c4 10             	add    $0x10,%esp
f0101ac7:	eb be                	jmp    f0101a87 <page_insert+0x43>
		return -E_NO_MEM;
f0101ac9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101ace:	eb de                	jmp    f0101aae <page_insert+0x6a>

f0101ad0 <mem_init>:
{
f0101ad0:	55                   	push   %ebp
f0101ad1:	89 e5                	mov    %esp,%ebp
f0101ad3:	57                   	push   %edi
f0101ad4:	56                   	push   %esi
f0101ad5:	53                   	push   %ebx
f0101ad6:	83 ec 3c             	sub    $0x3c,%esp
f0101ad9:	e8 7a ec ff ff       	call   f0100758 <__x86.get_pc_thunk.ax>
f0101ade:	05 2e 78 01 00       	add    $0x1782e,%eax
f0101ae3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f0101ae6:	b8 15 00 00 00       	mov    $0x15,%eax
f0101aeb:	e8 a8 f6 ff ff       	call   f0101198 <nvram_read>
f0101af0:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101af2:	b8 17 00 00 00       	mov    $0x17,%eax
f0101af7:	e8 9c f6 ff ff       	call   f0101198 <nvram_read>
f0101afc:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101afe:	b8 34 00 00 00       	mov    $0x34,%eax
f0101b03:	e8 90 f6 ff ff       	call   f0101198 <nvram_read>
f0101b08:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101b0b:	85 c0                	test   %eax,%eax
f0101b0d:	0f 85 c2 00 00 00    	jne    f0101bd5 <mem_init+0x105>
		totalmem = 1 * 1024 + extmem;
f0101b13:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101b19:	85 f6                	test   %esi,%esi
f0101b1b:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101b1e:	89 c1                	mov    %eax,%ecx
f0101b20:	c1 e9 02             	shr    $0x2,%ecx
f0101b23:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101b26:	c7 c2 e8 b6 11 f0    	mov    $0xf011b6e8,%edx
f0101b2c:	89 0a                	mov    %ecx,(%edx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101b2e:	89 c2                	mov    %eax,%edx
f0101b30:	29 da                	sub    %ebx,%edx
f0101b32:	52                   	push   %edx
f0101b33:	53                   	push   %ebx
f0101b34:	50                   	push   %eax
f0101b35:	8d 87 00 c0 fe ff    	lea    -0x14000(%edi),%eax
f0101b3b:	50                   	push   %eax
f0101b3c:	89 fb                	mov    %edi,%ebx
f0101b3e:	e8 24 1d 00 00       	call   f0103867 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101b43:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101b48:	e8 81 f6 ff ff       	call   f01011ce <boot_alloc>
f0101b4d:	c7 c6 ec b6 11 f0    	mov    $0xf011b6ec,%esi
f0101b53:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f0101b55:	83 c4 0c             	add    $0xc,%esp
f0101b58:	68 00 10 00 00       	push   $0x1000
f0101b5d:	6a 00                	push   $0x0
f0101b5f:	50                   	push   %eax
f0101b60:	e8 69 29 00 00       	call   f01044ce <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101b65:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101b67:	83 c4 10             	add    $0x10,%esp
f0101b6a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101b6f:	76 6e                	jbe    f0101bdf <mem_init+0x10f>
	return (physaddr_t)kva - KERNBASE;
f0101b71:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101b77:	83 ca 05             	or     $0x5,%edx
f0101b7a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101b80:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101b83:	c7 c3 e8 b6 11 f0    	mov    $0xf011b6e8,%ebx
f0101b89:	8b 03                	mov    (%ebx),%eax
f0101b8b:	c1 e0 03             	shl    $0x3,%eax
f0101b8e:	e8 3b f6 ff ff       	call   f01011ce <boot_alloc>
f0101b93:	c7 c6 f0 b6 11 f0    	mov    $0xf011b6f0,%esi
f0101b99:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101b9b:	83 ec 04             	sub    $0x4,%esp
f0101b9e:	8b 13                	mov    (%ebx),%edx
f0101ba0:	c1 e2 03             	shl    $0x3,%edx
f0101ba3:	52                   	push   %edx
f0101ba4:	6a 00                	push   $0x0
f0101ba6:	50                   	push   %eax
f0101ba7:	89 fb                	mov    %edi,%ebx
f0101ba9:	e8 20 29 00 00       	call   f01044ce <memset>
	page_init();
f0101bae:	e8 a3 fa ff ff       	call   f0101656 <page_init>
	check_page_free_list(1);
f0101bb3:	b8 01 00 00 00       	mov    $0x1,%eax
f0101bb8:	e8 16 f7 ff ff       	call   f01012d3 <check_page_free_list>
	if (!pages)
f0101bbd:	83 c4 10             	add    $0x10,%esp
f0101bc0:	83 3e 00             	cmpl   $0x0,(%esi)
f0101bc3:	74 36                	je     f0101bfb <mem_init+0x12b>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101bc5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bc8:	8b 80 d0 1f 00 00    	mov    0x1fd0(%eax),%eax
f0101bce:	be 00 00 00 00       	mov    $0x0,%esi
f0101bd3:	eb 49                	jmp    f0101c1e <mem_init+0x14e>
		totalmem = 16 * 1024 + ext16mem;
f0101bd5:	05 00 40 00 00       	add    $0x4000,%eax
f0101bda:	e9 3f ff ff ff       	jmp    f0101b1e <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101bdf:	50                   	push   %eax
f0101be0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101be3:	8d 83 3c c0 fe ff    	lea    -0x13fc4(%ebx),%eax
f0101be9:	50                   	push   %eax
f0101bea:	68 90 00 00 00       	push   $0x90
f0101bef:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101bf5:	50                   	push   %eax
f0101bf6:	e8 05 e5 ff ff       	call   f0100100 <_panic>
		panic("'pages' is a null pointer!");
f0101bfb:	83 ec 04             	sub    $0x4,%esp
f0101bfe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c01:	8d 83 0a c7 fe ff    	lea    -0x138f6(%ebx),%eax
f0101c07:	50                   	push   %eax
f0101c08:	68 7d 02 00 00       	push   $0x27d
f0101c0d:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101c13:	50                   	push   %eax
f0101c14:	e8 e7 e4 ff ff       	call   f0100100 <_panic>
		++nfree;
f0101c19:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101c1c:	8b 00                	mov    (%eax),%eax
f0101c1e:	85 c0                	test   %eax,%eax
f0101c20:	75 f7                	jne    f0101c19 <mem_init+0x149>
	assert((pp0 = page_alloc(0)));
f0101c22:	83 ec 0c             	sub    $0xc,%esp
f0101c25:	6a 00                	push   $0x0
f0101c27:	e8 4c fb ff ff       	call   f0101778 <page_alloc>
f0101c2c:	89 c3                	mov    %eax,%ebx
f0101c2e:	83 c4 10             	add    $0x10,%esp
f0101c31:	85 c0                	test   %eax,%eax
f0101c33:	0f 84 3b 02 00 00    	je     f0101e74 <mem_init+0x3a4>
	assert((pp1 = page_alloc(0)));
f0101c39:	83 ec 0c             	sub    $0xc,%esp
f0101c3c:	6a 00                	push   $0x0
f0101c3e:	e8 35 fb ff ff       	call   f0101778 <page_alloc>
f0101c43:	89 c7                	mov    %eax,%edi
f0101c45:	83 c4 10             	add    $0x10,%esp
f0101c48:	85 c0                	test   %eax,%eax
f0101c4a:	0f 84 46 02 00 00    	je     f0101e96 <mem_init+0x3c6>
	assert((pp2 = page_alloc(0)));
f0101c50:	83 ec 0c             	sub    $0xc,%esp
f0101c53:	6a 00                	push   $0x0
f0101c55:	e8 1e fb ff ff       	call   f0101778 <page_alloc>
f0101c5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c5d:	83 c4 10             	add    $0x10,%esp
f0101c60:	85 c0                	test   %eax,%eax
f0101c62:	0f 84 50 02 00 00    	je     f0101eb8 <mem_init+0x3e8>
	assert(pp1 && pp1 != pp0);
f0101c68:	39 fb                	cmp    %edi,%ebx
f0101c6a:	0f 84 6a 02 00 00    	je     f0101eda <mem_init+0x40a>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c70:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c73:	39 c3                	cmp    %eax,%ebx
f0101c75:	0f 84 81 02 00 00    	je     f0101efc <mem_init+0x42c>
f0101c7b:	39 c7                	cmp    %eax,%edi
f0101c7d:	0f 84 79 02 00 00    	je     f0101efc <mem_init+0x42c>
	return (pp - pages) << PGSHIFT;
f0101c83:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c86:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0101c8c:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101c8e:	c7 c0 e8 b6 11 f0    	mov    $0xf011b6e8,%eax
f0101c94:	8b 10                	mov    (%eax),%edx
f0101c96:	c1 e2 0c             	shl    $0xc,%edx
f0101c99:	89 d8                	mov    %ebx,%eax
f0101c9b:	29 c8                	sub    %ecx,%eax
f0101c9d:	c1 f8 03             	sar    $0x3,%eax
f0101ca0:	c1 e0 0c             	shl    $0xc,%eax
f0101ca3:	39 d0                	cmp    %edx,%eax
f0101ca5:	0f 83 73 02 00 00    	jae    f0101f1e <mem_init+0x44e>
f0101cab:	89 f8                	mov    %edi,%eax
f0101cad:	29 c8                	sub    %ecx,%eax
f0101caf:	c1 f8 03             	sar    $0x3,%eax
f0101cb2:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101cb5:	39 c2                	cmp    %eax,%edx
f0101cb7:	0f 86 83 02 00 00    	jbe    f0101f40 <mem_init+0x470>
f0101cbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cc0:	29 c8                	sub    %ecx,%eax
f0101cc2:	c1 f8 03             	sar    $0x3,%eax
f0101cc5:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101cc8:	39 c2                	cmp    %eax,%edx
f0101cca:	0f 86 92 02 00 00    	jbe    f0101f62 <mem_init+0x492>
	fl = page_free_list;
f0101cd0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cd3:	8b 88 d0 1f 00 00    	mov    0x1fd0(%eax),%ecx
f0101cd9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101cdc:	c7 80 d0 1f 00 00 00 	movl   $0x0,0x1fd0(%eax)
f0101ce3:	00 00 00 
	assert(!page_alloc(0));
f0101ce6:	83 ec 0c             	sub    $0xc,%esp
f0101ce9:	6a 00                	push   $0x0
f0101ceb:	e8 88 fa ff ff       	call   f0101778 <page_alloc>
f0101cf0:	83 c4 10             	add    $0x10,%esp
f0101cf3:	85 c0                	test   %eax,%eax
f0101cf5:	0f 85 89 02 00 00    	jne    f0101f84 <mem_init+0x4b4>
	page_free(pp0);
f0101cfb:	83 ec 0c             	sub    $0xc,%esp
f0101cfe:	53                   	push   %ebx
f0101cff:	e8 fc fa ff ff       	call   f0101800 <page_free>
	page_free(pp1);
f0101d04:	89 3c 24             	mov    %edi,(%esp)
f0101d07:	e8 f4 fa ff ff       	call   f0101800 <page_free>
	page_free(pp2);
f0101d0c:	83 c4 04             	add    $0x4,%esp
f0101d0f:	ff 75 d0             	pushl  -0x30(%ebp)
f0101d12:	e8 e9 fa ff ff       	call   f0101800 <page_free>
	assert((pp0 = page_alloc(0)));
f0101d17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d1e:	e8 55 fa ff ff       	call   f0101778 <page_alloc>
f0101d23:	89 c7                	mov    %eax,%edi
f0101d25:	83 c4 10             	add    $0x10,%esp
f0101d28:	85 c0                	test   %eax,%eax
f0101d2a:	0f 84 76 02 00 00    	je     f0101fa6 <mem_init+0x4d6>
	assert((pp1 = page_alloc(0)));
f0101d30:	83 ec 0c             	sub    $0xc,%esp
f0101d33:	6a 00                	push   $0x0
f0101d35:	e8 3e fa ff ff       	call   f0101778 <page_alloc>
f0101d3a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101d3d:	83 c4 10             	add    $0x10,%esp
f0101d40:	85 c0                	test   %eax,%eax
f0101d42:	0f 84 80 02 00 00    	je     f0101fc8 <mem_init+0x4f8>
	assert((pp2 = page_alloc(0)));
f0101d48:	83 ec 0c             	sub    $0xc,%esp
f0101d4b:	6a 00                	push   $0x0
f0101d4d:	e8 26 fa ff ff       	call   f0101778 <page_alloc>
f0101d52:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d55:	83 c4 10             	add    $0x10,%esp
f0101d58:	85 c0                	test   %eax,%eax
f0101d5a:	0f 84 8a 02 00 00    	je     f0101fea <mem_init+0x51a>
	assert(pp1 && pp1 != pp0);
f0101d60:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101d63:	0f 84 a3 02 00 00    	je     f010200c <mem_init+0x53c>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d69:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101d6c:	39 c7                	cmp    %eax,%edi
f0101d6e:	0f 84 ba 02 00 00    	je     f010202e <mem_init+0x55e>
f0101d74:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101d77:	0f 84 b1 02 00 00    	je     f010202e <mem_init+0x55e>
	assert(!page_alloc(0));
f0101d7d:	83 ec 0c             	sub    $0xc,%esp
f0101d80:	6a 00                	push   $0x0
f0101d82:	e8 f1 f9 ff ff       	call   f0101778 <page_alloc>
f0101d87:	83 c4 10             	add    $0x10,%esp
f0101d8a:	85 c0                	test   %eax,%eax
f0101d8c:	0f 85 be 02 00 00    	jne    f0102050 <mem_init+0x580>
f0101d92:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d95:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0101d9b:	89 f9                	mov    %edi,%ecx
f0101d9d:	2b 08                	sub    (%eax),%ecx
f0101d9f:	89 c8                	mov    %ecx,%eax
f0101da1:	c1 f8 03             	sar    $0x3,%eax
f0101da4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101da7:	89 c1                	mov    %eax,%ecx
f0101da9:	c1 e9 0c             	shr    $0xc,%ecx
f0101dac:	c7 c2 e8 b6 11 f0    	mov    $0xf011b6e8,%edx
f0101db2:	3b 0a                	cmp    (%edx),%ecx
f0101db4:	0f 83 b8 02 00 00    	jae    f0102072 <mem_init+0x5a2>
	memset(page2kva(pp0), 1, PGSIZE);
f0101dba:	83 ec 04             	sub    $0x4,%esp
f0101dbd:	68 00 10 00 00       	push   $0x1000
f0101dc2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101dc4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dc9:	50                   	push   %eax
f0101dca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101dcd:	e8 fc 26 00 00       	call   f01044ce <memset>
	page_free(pp0);
f0101dd2:	89 3c 24             	mov    %edi,(%esp)
f0101dd5:	e8 26 fa ff ff       	call   f0101800 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101dda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101de1:	e8 92 f9 ff ff       	call   f0101778 <page_alloc>
f0101de6:	83 c4 10             	add    $0x10,%esp
f0101de9:	85 c0                	test   %eax,%eax
f0101deb:	0f 84 97 02 00 00    	je     f0102088 <mem_init+0x5b8>
	assert(pp && pp0 == pp);
f0101df1:	39 c7                	cmp    %eax,%edi
f0101df3:	0f 85 b1 02 00 00    	jne    f01020aa <mem_init+0x5da>
	return (pp - pages) << PGSHIFT;
f0101df9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101dfc:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0101e02:	89 fa                	mov    %edi,%edx
f0101e04:	2b 10                	sub    (%eax),%edx
f0101e06:	c1 fa 03             	sar    $0x3,%edx
f0101e09:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e0c:	89 d1                	mov    %edx,%ecx
f0101e0e:	c1 e9 0c             	shr    $0xc,%ecx
f0101e11:	c7 c0 e8 b6 11 f0    	mov    $0xf011b6e8,%eax
f0101e17:	3b 08                	cmp    (%eax),%ecx
f0101e19:	0f 83 ad 02 00 00    	jae    f01020cc <mem_init+0x5fc>
	return (void *)(pa + KERNBASE);
f0101e1f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101e25:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101e2b:	80 38 00             	cmpb   $0x0,(%eax)
f0101e2e:	0f 85 ae 02 00 00    	jne    f01020e2 <mem_init+0x612>
f0101e34:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101e37:	39 d0                	cmp    %edx,%eax
f0101e39:	75 f0                	jne    f0101e2b <mem_init+0x35b>
	page_free_list = fl;
f0101e3b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e3e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101e41:	89 8b d0 1f 00 00    	mov    %ecx,0x1fd0(%ebx)
	page_free(pp0);
f0101e47:	83 ec 0c             	sub    $0xc,%esp
f0101e4a:	57                   	push   %edi
f0101e4b:	e8 b0 f9 ff ff       	call   f0101800 <page_free>
	page_free(pp1);
f0101e50:	83 c4 04             	add    $0x4,%esp
f0101e53:	ff 75 d0             	pushl  -0x30(%ebp)
f0101e56:	e8 a5 f9 ff ff       	call   f0101800 <page_free>
	page_free(pp2);
f0101e5b:	83 c4 04             	add    $0x4,%esp
f0101e5e:	ff 75 cc             	pushl  -0x34(%ebp)
f0101e61:	e8 9a f9 ff ff       	call   f0101800 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e66:	8b 83 d0 1f 00 00    	mov    0x1fd0(%ebx),%eax
f0101e6c:	83 c4 10             	add    $0x10,%esp
f0101e6f:	e9 95 02 00 00       	jmp    f0102109 <mem_init+0x639>
	assert((pp0 = page_alloc(0)));
f0101e74:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e77:	8d 83 25 c7 fe ff    	lea    -0x138db(%ebx),%eax
f0101e7d:	50                   	push   %eax
f0101e7e:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101e84:	50                   	push   %eax
f0101e85:	68 85 02 00 00       	push   $0x285
f0101e8a:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101e90:	50                   	push   %eax
f0101e91:	e8 6a e2 ff ff       	call   f0100100 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e96:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e99:	8d 83 3b c7 fe ff    	lea    -0x138c5(%ebx),%eax
f0101e9f:	50                   	push   %eax
f0101ea0:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101ea6:	50                   	push   %eax
f0101ea7:	68 86 02 00 00       	push   $0x286
f0101eac:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101eb2:	50                   	push   %eax
f0101eb3:	e8 48 e2 ff ff       	call   f0100100 <_panic>
	assert((pp2 = page_alloc(0)));
f0101eb8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ebb:	8d 83 51 c7 fe ff    	lea    -0x138af(%ebx),%eax
f0101ec1:	50                   	push   %eax
f0101ec2:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101ec8:	50                   	push   %eax
f0101ec9:	68 87 02 00 00       	push   $0x287
f0101ece:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101ed4:	50                   	push   %eax
f0101ed5:	e8 26 e2 ff ff       	call   f0100100 <_panic>
	assert(pp1 && pp1 != pp0);
f0101eda:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101edd:	8d 83 67 c7 fe ff    	lea    -0x13899(%ebx),%eax
f0101ee3:	50                   	push   %eax
f0101ee4:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101eea:	50                   	push   %eax
f0101eeb:	68 8a 02 00 00       	push   $0x28a
f0101ef0:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101ef6:	50                   	push   %eax
f0101ef7:	e8 04 e2 ff ff       	call   f0100100 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101efc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101eff:	8d 83 60 c0 fe ff    	lea    -0x13fa0(%ebx),%eax
f0101f05:	50                   	push   %eax
f0101f06:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101f0c:	50                   	push   %eax
f0101f0d:	68 8b 02 00 00       	push   $0x28b
f0101f12:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101f18:	50                   	push   %eax
f0101f19:	e8 e2 e1 ff ff       	call   f0100100 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101f1e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f21:	8d 83 79 c7 fe ff    	lea    -0x13887(%ebx),%eax
f0101f27:	50                   	push   %eax
f0101f28:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101f2e:	50                   	push   %eax
f0101f2f:	68 8c 02 00 00       	push   $0x28c
f0101f34:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101f3a:	50                   	push   %eax
f0101f3b:	e8 c0 e1 ff ff       	call   f0100100 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101f40:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f43:	8d 83 96 c7 fe ff    	lea    -0x1386a(%ebx),%eax
f0101f49:	50                   	push   %eax
f0101f4a:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101f50:	50                   	push   %eax
f0101f51:	68 8d 02 00 00       	push   $0x28d
f0101f56:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101f5c:	50                   	push   %eax
f0101f5d:	e8 9e e1 ff ff       	call   f0100100 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101f62:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f65:	8d 83 b3 c7 fe ff    	lea    -0x1384d(%ebx),%eax
f0101f6b:	50                   	push   %eax
f0101f6c:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101f72:	50                   	push   %eax
f0101f73:	68 8e 02 00 00       	push   $0x28e
f0101f78:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101f7e:	50                   	push   %eax
f0101f7f:	e8 7c e1 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f0101f84:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f87:	8d 83 d0 c7 fe ff    	lea    -0x13830(%ebx),%eax
f0101f8d:	50                   	push   %eax
f0101f8e:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101f94:	50                   	push   %eax
f0101f95:	68 95 02 00 00       	push   $0x295
f0101f9a:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101fa0:	50                   	push   %eax
f0101fa1:	e8 5a e1 ff ff       	call   f0100100 <_panic>
	assert((pp0 = page_alloc(0)));
f0101fa6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fa9:	8d 83 25 c7 fe ff    	lea    -0x138db(%ebx),%eax
f0101faf:	50                   	push   %eax
f0101fb0:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101fb6:	50                   	push   %eax
f0101fb7:	68 9c 02 00 00       	push   $0x29c
f0101fbc:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101fc2:	50                   	push   %eax
f0101fc3:	e8 38 e1 ff ff       	call   f0100100 <_panic>
	assert((pp1 = page_alloc(0)));
f0101fc8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fcb:	8d 83 3b c7 fe ff    	lea    -0x138c5(%ebx),%eax
f0101fd1:	50                   	push   %eax
f0101fd2:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101fd8:	50                   	push   %eax
f0101fd9:	68 9d 02 00 00       	push   $0x29d
f0101fde:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0101fe4:	50                   	push   %eax
f0101fe5:	e8 16 e1 ff ff       	call   f0100100 <_panic>
	assert((pp2 = page_alloc(0)));
f0101fea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fed:	8d 83 51 c7 fe ff    	lea    -0x138af(%ebx),%eax
f0101ff3:	50                   	push   %eax
f0101ff4:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0101ffa:	50                   	push   %eax
f0101ffb:	68 9e 02 00 00       	push   $0x29e
f0102000:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102006:	50                   	push   %eax
f0102007:	e8 f4 e0 ff ff       	call   f0100100 <_panic>
	assert(pp1 && pp1 != pp0);
f010200c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010200f:	8d 83 67 c7 fe ff    	lea    -0x13899(%ebx),%eax
f0102015:	50                   	push   %eax
f0102016:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010201c:	50                   	push   %eax
f010201d:	68 a0 02 00 00       	push   $0x2a0
f0102022:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102028:	50                   	push   %eax
f0102029:	e8 d2 e0 ff ff       	call   f0100100 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010202e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102031:	8d 83 60 c0 fe ff    	lea    -0x13fa0(%ebx),%eax
f0102037:	50                   	push   %eax
f0102038:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010203e:	50                   	push   %eax
f010203f:	68 a1 02 00 00       	push   $0x2a1
f0102044:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010204a:	50                   	push   %eax
f010204b:	e8 b0 e0 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f0102050:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102053:	8d 83 d0 c7 fe ff    	lea    -0x13830(%ebx),%eax
f0102059:	50                   	push   %eax
f010205a:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102060:	50                   	push   %eax
f0102061:	68 a2 02 00 00       	push   $0x2a2
f0102066:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010206c:	50                   	push   %eax
f010206d:	e8 8e e0 ff ff       	call   f0100100 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102072:	50                   	push   %eax
f0102073:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f0102079:	50                   	push   %eax
f010207a:	6a 52                	push   $0x52
f010207c:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f0102082:	50                   	push   %eax
f0102083:	e8 78 e0 ff ff       	call   f0100100 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102088:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010208b:	8d 83 df c7 fe ff    	lea    -0x13821(%ebx),%eax
f0102091:	50                   	push   %eax
f0102092:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102098:	50                   	push   %eax
f0102099:	68 a7 02 00 00       	push   $0x2a7
f010209e:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01020a4:	50                   	push   %eax
f01020a5:	e8 56 e0 ff ff       	call   f0100100 <_panic>
	assert(pp && pp0 == pp);
f01020aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020ad:	8d 83 fd c7 fe ff    	lea    -0x13803(%ebx),%eax
f01020b3:	50                   	push   %eax
f01020b4:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01020ba:	50                   	push   %eax
f01020bb:	68 a8 02 00 00       	push   $0x2a8
f01020c0:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01020c6:	50                   	push   %eax
f01020c7:	e8 34 e0 ff ff       	call   f0100100 <_panic>
f01020cc:	52                   	push   %edx
f01020cd:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f01020d3:	50                   	push   %eax
f01020d4:	6a 52                	push   $0x52
f01020d6:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f01020dc:	50                   	push   %eax
f01020dd:	e8 1e e0 ff ff       	call   f0100100 <_panic>
		assert(c[i] == 0);
f01020e2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020e5:	8d 83 0d c8 fe ff    	lea    -0x137f3(%ebx),%eax
f01020eb:	50                   	push   %eax
f01020ec:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01020f2:	50                   	push   %eax
f01020f3:	68 ab 02 00 00       	push   $0x2ab
f01020f8:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01020fe:	50                   	push   %eax
f01020ff:	e8 fc df ff ff       	call   f0100100 <_panic>
		--nfree;
f0102104:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102107:	8b 00                	mov    (%eax),%eax
f0102109:	85 c0                	test   %eax,%eax
f010210b:	75 f7                	jne    f0102104 <mem_init+0x634>
	assert(nfree == 0);
f010210d:	85 f6                	test   %esi,%esi
f010210f:	0f 85 55 08 00 00    	jne    f010296a <mem_init+0xe9a>
	cprintf("check_page_alloc() succeeded!\n");
f0102115:	83 ec 0c             	sub    $0xc,%esp
f0102118:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010211b:	8d 83 80 c0 fe ff    	lea    -0x13f80(%ebx),%eax
f0102121:	50                   	push   %eax
f0102122:	e8 40 17 00 00       	call   f0103867 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102127:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010212e:	e8 45 f6 ff ff       	call   f0101778 <page_alloc>
f0102133:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102136:	83 c4 10             	add    $0x10,%esp
f0102139:	85 c0                	test   %eax,%eax
f010213b:	0f 84 4b 08 00 00    	je     f010298c <mem_init+0xebc>
	assert((pp1 = page_alloc(0)));
f0102141:	83 ec 0c             	sub    $0xc,%esp
f0102144:	6a 00                	push   $0x0
f0102146:	e8 2d f6 ff ff       	call   f0101778 <page_alloc>
f010214b:	89 c7                	mov    %eax,%edi
f010214d:	83 c4 10             	add    $0x10,%esp
f0102150:	85 c0                	test   %eax,%eax
f0102152:	0f 84 56 08 00 00    	je     f01029ae <mem_init+0xede>
	assert((pp2 = page_alloc(0)));
f0102158:	83 ec 0c             	sub    $0xc,%esp
f010215b:	6a 00                	push   $0x0
f010215d:	e8 16 f6 ff ff       	call   f0101778 <page_alloc>
f0102162:	89 c6                	mov    %eax,%esi
f0102164:	83 c4 10             	add    $0x10,%esp
f0102167:	85 c0                	test   %eax,%eax
f0102169:	0f 84 61 08 00 00    	je     f01029d0 <mem_init+0xf00>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010216f:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0102172:	0f 84 7a 08 00 00    	je     f01029f2 <mem_init+0xf22>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102178:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010217b:	0f 84 93 08 00 00    	je     f0102a14 <mem_init+0xf44>
f0102181:	39 c7                	cmp    %eax,%edi
f0102183:	0f 84 8b 08 00 00    	je     f0102a14 <mem_init+0xf44>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102189:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010218c:	8b 88 d0 1f 00 00    	mov    0x1fd0(%eax),%ecx
f0102192:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0102195:	c7 80 d0 1f 00 00 00 	movl   $0x0,0x1fd0(%eax)
f010219c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010219f:	83 ec 0c             	sub    $0xc,%esp
f01021a2:	6a 00                	push   $0x0
f01021a4:	e8 cf f5 ff ff       	call   f0101778 <page_alloc>
f01021a9:	83 c4 10             	add    $0x10,%esp
f01021ac:	85 c0                	test   %eax,%eax
f01021ae:	0f 85 82 08 00 00    	jne    f0102a36 <mem_init+0xf66>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01021b4:	83 ec 04             	sub    $0x4,%esp
f01021b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01021ba:	50                   	push   %eax
f01021bb:	6a 00                	push   $0x0
f01021bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021c0:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f01021c6:	ff 30                	pushl  (%eax)
f01021c8:	e8 c8 f7 ff ff       	call   f0101995 <page_lookup>
f01021cd:	83 c4 10             	add    $0x10,%esp
f01021d0:	85 c0                	test   %eax,%eax
f01021d2:	0f 85 80 08 00 00    	jne    f0102a58 <mem_init+0xf88>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01021d8:	6a 02                	push   $0x2
f01021da:	6a 00                	push   $0x0
f01021dc:	57                   	push   %edi
f01021dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021e0:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f01021e6:	ff 30                	pushl  (%eax)
f01021e8:	e8 57 f8 ff ff       	call   f0101a44 <page_insert>
f01021ed:	83 c4 10             	add    $0x10,%esp
f01021f0:	85 c0                	test   %eax,%eax
f01021f2:	0f 89 82 08 00 00    	jns    f0102a7a <mem_init+0xfaa>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01021f8:	83 ec 0c             	sub    $0xc,%esp
f01021fb:	ff 75 d0             	pushl  -0x30(%ebp)
f01021fe:	e8 fd f5 ff ff       	call   f0101800 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102203:	6a 02                	push   $0x2
f0102205:	6a 00                	push   $0x0
f0102207:	57                   	push   %edi
f0102208:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010220b:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0102211:	ff 30                	pushl  (%eax)
f0102213:	e8 2c f8 ff ff       	call   f0101a44 <page_insert>
f0102218:	83 c4 20             	add    $0x20,%esp
f010221b:	85 c0                	test   %eax,%eax
f010221d:	0f 85 79 08 00 00    	jne    f0102a9c <mem_init+0xfcc>
	// cprintf("assret %x == %x\n", PTE_ADDR(kern_pgdir[0]), page2pa(pp1));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102223:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102226:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f010222c:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f010222e:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0102234:	8b 08                	mov    (%eax),%ecx
f0102236:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102239:	8b 13                	mov    (%ebx),%edx
f010223b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102241:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102244:	29 c8                	sub    %ecx,%eax
f0102246:	c1 f8 03             	sar    $0x3,%eax
f0102249:	c1 e0 0c             	shl    $0xc,%eax
f010224c:	39 c2                	cmp    %eax,%edx
f010224e:	0f 85 6a 08 00 00    	jne    f0102abe <mem_init+0xfee>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102254:	ba 00 00 00 00       	mov    $0x0,%edx
f0102259:	89 d8                	mov    %ebx,%eax
f010225b:	e8 f6 ef ff ff       	call   f0101256 <check_va2pa>
f0102260:	89 fa                	mov    %edi,%edx
f0102262:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0102265:	c1 fa 03             	sar    $0x3,%edx
f0102268:	c1 e2 0c             	shl    $0xc,%edx
f010226b:	39 d0                	cmp    %edx,%eax
f010226d:	0f 85 6d 08 00 00    	jne    f0102ae0 <mem_init+0x1010>
	assert(pp1->pp_ref == 1);
f0102273:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102278:	0f 85 84 08 00 00    	jne    f0102b02 <mem_init+0x1032>
	assert(pp0->pp_ref == 1);
f010227e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102281:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102286:	0f 85 98 08 00 00    	jne    f0102b24 <mem_init+0x1054>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010228c:	6a 02                	push   $0x2
f010228e:	68 00 10 00 00       	push   $0x1000
f0102293:	56                   	push   %esi
f0102294:	53                   	push   %ebx
f0102295:	e8 aa f7 ff ff       	call   f0101a44 <page_insert>
f010229a:	83 c4 10             	add    $0x10,%esp
f010229d:	85 c0                	test   %eax,%eax
f010229f:	0f 85 a1 08 00 00    	jne    f0102b46 <mem_init+0x1076>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022a5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022ad:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f01022b3:	8b 00                	mov    (%eax),%eax
f01022b5:	e8 9c ef ff ff       	call   f0101256 <check_va2pa>
f01022ba:	c7 c2 f0 b6 11 f0    	mov    $0xf011b6f0,%edx
f01022c0:	89 f1                	mov    %esi,%ecx
f01022c2:	2b 0a                	sub    (%edx),%ecx
f01022c4:	89 ca                	mov    %ecx,%edx
f01022c6:	c1 fa 03             	sar    $0x3,%edx
f01022c9:	c1 e2 0c             	shl    $0xc,%edx
f01022cc:	39 d0                	cmp    %edx,%eax
f01022ce:	0f 85 94 08 00 00    	jne    f0102b68 <mem_init+0x1098>
	assert(pp2->pp_ref == 1);
f01022d4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022d9:	0f 85 ab 08 00 00    	jne    f0102b8a <mem_init+0x10ba>

	// should be no free memory
	assert(!page_alloc(0));
f01022df:	83 ec 0c             	sub    $0xc,%esp
f01022e2:	6a 00                	push   $0x0
f01022e4:	e8 8f f4 ff ff       	call   f0101778 <page_alloc>
f01022e9:	83 c4 10             	add    $0x10,%esp
f01022ec:	85 c0                	test   %eax,%eax
f01022ee:	0f 85 b8 08 00 00    	jne    f0102bac <mem_init+0x10dc>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022f4:	6a 02                	push   $0x2
f01022f6:	68 00 10 00 00       	push   $0x1000
f01022fb:	56                   	push   %esi
f01022fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022ff:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0102305:	ff 30                	pushl  (%eax)
f0102307:	e8 38 f7 ff ff       	call   f0101a44 <page_insert>
f010230c:	83 c4 10             	add    $0x10,%esp
f010230f:	85 c0                	test   %eax,%eax
f0102311:	0f 85 b7 08 00 00    	jne    f0102bce <mem_init+0x10fe>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102317:	ba 00 10 00 00       	mov    $0x1000,%edx
f010231c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010231f:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0102325:	8b 00                	mov    (%eax),%eax
f0102327:	e8 2a ef ff ff       	call   f0101256 <check_va2pa>
f010232c:	c7 c2 f0 b6 11 f0    	mov    $0xf011b6f0,%edx
f0102332:	89 f1                	mov    %esi,%ecx
f0102334:	2b 0a                	sub    (%edx),%ecx
f0102336:	89 ca                	mov    %ecx,%edx
f0102338:	c1 fa 03             	sar    $0x3,%edx
f010233b:	c1 e2 0c             	shl    $0xc,%edx
f010233e:	39 d0                	cmp    %edx,%eax
f0102340:	0f 85 aa 08 00 00    	jne    f0102bf0 <mem_init+0x1120>
	assert(pp2->pp_ref == 1);
f0102346:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010234b:	0f 85 c1 08 00 00    	jne    f0102c12 <mem_init+0x1142>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102351:	83 ec 0c             	sub    $0xc,%esp
f0102354:	6a 00                	push   $0x0
f0102356:	e8 1d f4 ff ff       	call   f0101778 <page_alloc>
f010235b:	83 c4 10             	add    $0x10,%esp
f010235e:	85 c0                	test   %eax,%eax
f0102360:	0f 85 ce 08 00 00    	jne    f0102c34 <mem_init+0x1164>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102366:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102369:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f010236f:	8b 10                	mov    (%eax),%edx
f0102371:	8b 02                	mov    (%edx),%eax
f0102373:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0102378:	89 c3                	mov    %eax,%ebx
f010237a:	c1 eb 0c             	shr    $0xc,%ebx
f010237d:	c7 c1 e8 b6 11 f0    	mov    $0xf011b6e8,%ecx
f0102383:	3b 19                	cmp    (%ecx),%ebx
f0102385:	0f 83 cb 08 00 00    	jae    f0102c56 <mem_init+0x1186>
	return (void *)(pa + KERNBASE);
f010238b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102390:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102393:	83 ec 04             	sub    $0x4,%esp
f0102396:	6a 00                	push   $0x0
f0102398:	68 00 10 00 00       	push   $0x1000
f010239d:	52                   	push   %edx
f010239e:	e8 f8 f4 ff ff       	call   f010189b <pgdir_walk>
f01023a3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01023a6:	8d 51 04             	lea    0x4(%ecx),%edx
f01023a9:	83 c4 10             	add    $0x10,%esp
f01023ac:	39 d0                	cmp    %edx,%eax
f01023ae:	0f 85 be 08 00 00    	jne    f0102c72 <mem_init+0x11a2>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023b4:	6a 06                	push   $0x6
f01023b6:	68 00 10 00 00       	push   $0x1000
f01023bb:	56                   	push   %esi
f01023bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023bf:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f01023c5:	ff 30                	pushl  (%eax)
f01023c7:	e8 78 f6 ff ff       	call   f0101a44 <page_insert>
f01023cc:	83 c4 10             	add    $0x10,%esp
f01023cf:	85 c0                	test   %eax,%eax
f01023d1:	0f 85 bd 08 00 00    	jne    f0102c94 <mem_init+0x11c4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023da:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f01023e0:	8b 18                	mov    (%eax),%ebx
f01023e2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023e7:	89 d8                	mov    %ebx,%eax
f01023e9:	e8 68 ee ff ff       	call   f0101256 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f01023ee:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01023f1:	c7 c2 f0 b6 11 f0    	mov    $0xf011b6f0,%edx
f01023f7:	89 f1                	mov    %esi,%ecx
f01023f9:	2b 0a                	sub    (%edx),%ecx
f01023fb:	89 ca                	mov    %ecx,%edx
f01023fd:	c1 fa 03             	sar    $0x3,%edx
f0102400:	c1 e2 0c             	shl    $0xc,%edx
f0102403:	39 d0                	cmp    %edx,%eax
f0102405:	0f 85 ab 08 00 00    	jne    f0102cb6 <mem_init+0x11e6>
	assert(pp2->pp_ref == 1);
f010240b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102410:	0f 85 c2 08 00 00    	jne    f0102cd8 <mem_init+0x1208>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102416:	83 ec 04             	sub    $0x4,%esp
f0102419:	6a 00                	push   $0x0
f010241b:	68 00 10 00 00       	push   $0x1000
f0102420:	53                   	push   %ebx
f0102421:	e8 75 f4 ff ff       	call   f010189b <pgdir_walk>
f0102426:	83 c4 10             	add    $0x10,%esp
f0102429:	f6 00 04             	testb  $0x4,(%eax)
f010242c:	0f 84 c8 08 00 00    	je     f0102cfa <mem_init+0x122a>
	assert(kern_pgdir[0] & PTE_U);
f0102432:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102435:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f010243b:	8b 00                	mov    (%eax),%eax
f010243d:	f6 00 04             	testb  $0x4,(%eax)
f0102440:	0f 84 d6 08 00 00    	je     f0102d1c <mem_init+0x124c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102446:	6a 02                	push   $0x2
f0102448:	68 00 10 00 00       	push   $0x1000
f010244d:	56                   	push   %esi
f010244e:	50                   	push   %eax
f010244f:	e8 f0 f5 ff ff       	call   f0101a44 <page_insert>
f0102454:	83 c4 10             	add    $0x10,%esp
f0102457:	85 c0                	test   %eax,%eax
f0102459:	0f 85 df 08 00 00    	jne    f0102d3e <mem_init+0x126e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010245f:	83 ec 04             	sub    $0x4,%esp
f0102462:	6a 00                	push   $0x0
f0102464:	68 00 10 00 00       	push   $0x1000
f0102469:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010246c:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0102472:	ff 30                	pushl  (%eax)
f0102474:	e8 22 f4 ff ff       	call   f010189b <pgdir_walk>
f0102479:	83 c4 10             	add    $0x10,%esp
f010247c:	f6 00 02             	testb  $0x2,(%eax)
f010247f:	0f 84 db 08 00 00    	je     f0102d60 <mem_init+0x1290>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102485:	83 ec 04             	sub    $0x4,%esp
f0102488:	6a 00                	push   $0x0
f010248a:	68 00 10 00 00       	push   $0x1000
f010248f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102492:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0102498:	ff 30                	pushl  (%eax)
f010249a:	e8 fc f3 ff ff       	call   f010189b <pgdir_walk>
f010249f:	83 c4 10             	add    $0x10,%esp
f01024a2:	f6 00 04             	testb  $0x4,(%eax)
f01024a5:	0f 85 d7 08 00 00    	jne    f0102d82 <mem_init+0x12b2>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024ab:	6a 02                	push   $0x2
f01024ad:	68 00 00 40 00       	push   $0x400000
f01024b2:	ff 75 d0             	pushl  -0x30(%ebp)
f01024b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024b8:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f01024be:	ff 30                	pushl  (%eax)
f01024c0:	e8 7f f5 ff ff       	call   f0101a44 <page_insert>
f01024c5:	83 c4 10             	add    $0x10,%esp
f01024c8:	85 c0                	test   %eax,%eax
f01024ca:	0f 89 d4 08 00 00    	jns    f0102da4 <mem_init+0x12d4>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01024d0:	6a 02                	push   $0x2
f01024d2:	68 00 10 00 00       	push   $0x1000
f01024d7:	57                   	push   %edi
f01024d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024db:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f01024e1:	ff 30                	pushl  (%eax)
f01024e3:	e8 5c f5 ff ff       	call   f0101a44 <page_insert>
f01024e8:	83 c4 10             	add    $0x10,%esp
f01024eb:	85 c0                	test   %eax,%eax
f01024ed:	0f 85 d3 08 00 00    	jne    f0102dc6 <mem_init+0x12f6>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024f3:	83 ec 04             	sub    $0x4,%esp
f01024f6:	6a 00                	push   $0x0
f01024f8:	68 00 10 00 00       	push   $0x1000
f01024fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102500:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0102506:	ff 30                	pushl  (%eax)
f0102508:	e8 8e f3 ff ff       	call   f010189b <pgdir_walk>
f010250d:	83 c4 10             	add    $0x10,%esp
f0102510:	f6 00 04             	testb  $0x4,(%eax)
f0102513:	0f 85 cf 08 00 00    	jne    f0102de8 <mem_init+0x1318>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102519:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010251c:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0102522:	8b 18                	mov    (%eax),%ebx
f0102524:	ba 00 00 00 00       	mov    $0x0,%edx
f0102529:	89 d8                	mov    %ebx,%eax
f010252b:	e8 26 ed ff ff       	call   f0101256 <check_va2pa>
f0102530:	89 c2                	mov    %eax,%edx
f0102532:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102535:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102538:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f010253e:	89 f9                	mov    %edi,%ecx
f0102540:	2b 08                	sub    (%eax),%ecx
f0102542:	89 c8                	mov    %ecx,%eax
f0102544:	c1 f8 03             	sar    $0x3,%eax
f0102547:	c1 e0 0c             	shl    $0xc,%eax
f010254a:	39 c2                	cmp    %eax,%edx
f010254c:	0f 85 b8 08 00 00    	jne    f0102e0a <mem_init+0x133a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102552:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102557:	89 d8                	mov    %ebx,%eax
f0102559:	e8 f8 ec ff ff       	call   f0101256 <check_va2pa>
f010255e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102561:	0f 85 c5 08 00 00    	jne    f0102e2c <mem_init+0x135c>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102567:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f010256c:	0f 85 dc 08 00 00    	jne    f0102e4e <mem_init+0x137e>
	assert(pp2->pp_ref == 0);
f0102572:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102577:	0f 85 f3 08 00 00    	jne    f0102e70 <mem_init+0x13a0>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010257d:	83 ec 0c             	sub    $0xc,%esp
f0102580:	6a 00                	push   $0x0
f0102582:	e8 f1 f1 ff ff       	call   f0101778 <page_alloc>
f0102587:	83 c4 10             	add    $0x10,%esp
f010258a:	39 c6                	cmp    %eax,%esi
f010258c:	0f 85 00 09 00 00    	jne    f0102e92 <mem_init+0x13c2>
f0102592:	85 c0                	test   %eax,%eax
f0102594:	0f 84 f8 08 00 00    	je     f0102e92 <mem_init+0x13c2>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010259a:	83 ec 08             	sub    $0x8,%esp
f010259d:	6a 00                	push   $0x0
f010259f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025a2:	c7 c3 ec b6 11 f0    	mov    $0xf011b6ec,%ebx
f01025a8:	ff 33                	pushl  (%ebx)
f01025aa:	e8 56 f4 ff ff       	call   f0101a05 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025af:	8b 1b                	mov    (%ebx),%ebx
f01025b1:	ba 00 00 00 00       	mov    $0x0,%edx
f01025b6:	89 d8                	mov    %ebx,%eax
f01025b8:	e8 99 ec ff ff       	call   f0101256 <check_va2pa>
f01025bd:	83 c4 10             	add    $0x10,%esp
f01025c0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025c3:	0f 85 eb 08 00 00    	jne    f0102eb4 <mem_init+0x13e4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025c9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025ce:	89 d8                	mov    %ebx,%eax
f01025d0:	e8 81 ec ff ff       	call   f0101256 <check_va2pa>
f01025d5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01025d8:	c7 c2 f0 b6 11 f0    	mov    $0xf011b6f0,%edx
f01025de:	89 f9                	mov    %edi,%ecx
f01025e0:	2b 0a                	sub    (%edx),%ecx
f01025e2:	89 ca                	mov    %ecx,%edx
f01025e4:	c1 fa 03             	sar    $0x3,%edx
f01025e7:	c1 e2 0c             	shl    $0xc,%edx
f01025ea:	39 d0                	cmp    %edx,%eax
f01025ec:	0f 85 e4 08 00 00    	jne    f0102ed6 <mem_init+0x1406>
	assert(pp1->pp_ref == 1);
f01025f2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025f7:	0f 85 fb 08 00 00    	jne    f0102ef8 <mem_init+0x1428>
	assert(pp2->pp_ref == 0);
f01025fd:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102602:	0f 85 12 09 00 00    	jne    f0102f1a <mem_init+0x144a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102608:	6a 00                	push   $0x0
f010260a:	68 00 10 00 00       	push   $0x1000
f010260f:	57                   	push   %edi
f0102610:	53                   	push   %ebx
f0102611:	e8 2e f4 ff ff       	call   f0101a44 <page_insert>
f0102616:	83 c4 10             	add    $0x10,%esp
f0102619:	85 c0                	test   %eax,%eax
f010261b:	0f 85 1b 09 00 00    	jne    f0102f3c <mem_init+0x146c>
	assert(pp1->pp_ref);
f0102621:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102626:	0f 84 32 09 00 00    	je     f0102f5e <mem_init+0x148e>
	assert(pp1->pp_link == NULL);
f010262c:	83 3f 00             	cmpl   $0x0,(%edi)
f010262f:	0f 85 4b 09 00 00    	jne    f0102f80 <mem_init+0x14b0>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102635:	83 ec 08             	sub    $0x8,%esp
f0102638:	68 00 10 00 00       	push   $0x1000
f010263d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102640:	c7 c3 ec b6 11 f0    	mov    $0xf011b6ec,%ebx
f0102646:	ff 33                	pushl  (%ebx)
f0102648:	e8 b8 f3 ff ff       	call   f0101a05 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010264d:	8b 1b                	mov    (%ebx),%ebx
f010264f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102654:	89 d8                	mov    %ebx,%eax
f0102656:	e8 fb eb ff ff       	call   f0101256 <check_va2pa>
f010265b:	83 c4 10             	add    $0x10,%esp
f010265e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102661:	0f 85 3b 09 00 00    	jne    f0102fa2 <mem_init+0x14d2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102667:	ba 00 10 00 00       	mov    $0x1000,%edx
f010266c:	89 d8                	mov    %ebx,%eax
f010266e:	e8 e3 eb ff ff       	call   f0101256 <check_va2pa>
f0102673:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102676:	0f 85 48 09 00 00    	jne    f0102fc4 <mem_init+0x14f4>
	assert(pp1->pp_ref == 0);
f010267c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102681:	0f 85 5f 09 00 00    	jne    f0102fe6 <mem_init+0x1516>
	assert(pp2->pp_ref == 0);
f0102687:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010268c:	0f 85 76 09 00 00    	jne    f0103008 <mem_init+0x1538>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102692:	83 ec 0c             	sub    $0xc,%esp
f0102695:	6a 00                	push   $0x0
f0102697:	e8 dc f0 ff ff       	call   f0101778 <page_alloc>
f010269c:	83 c4 10             	add    $0x10,%esp
f010269f:	39 c7                	cmp    %eax,%edi
f01026a1:	0f 85 83 09 00 00    	jne    f010302a <mem_init+0x155a>
f01026a7:	85 c0                	test   %eax,%eax
f01026a9:	0f 84 7b 09 00 00    	je     f010302a <mem_init+0x155a>

	// should be no free memory
	assert(!page_alloc(0));
f01026af:	83 ec 0c             	sub    $0xc,%esp
f01026b2:	6a 00                	push   $0x0
f01026b4:	e8 bf f0 ff ff       	call   f0101778 <page_alloc>
f01026b9:	83 c4 10             	add    $0x10,%esp
f01026bc:	85 c0                	test   %eax,%eax
f01026be:	0f 85 88 09 00 00    	jne    f010304c <mem_init+0x157c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026c4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026c7:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f01026cd:	8b 08                	mov    (%eax),%ecx
f01026cf:	8b 11                	mov    (%ecx),%edx
f01026d1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026d7:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f01026dd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01026e0:	2b 18                	sub    (%eax),%ebx
f01026e2:	89 d8                	mov    %ebx,%eax
f01026e4:	c1 f8 03             	sar    $0x3,%eax
f01026e7:	c1 e0 0c             	shl    $0xc,%eax
f01026ea:	39 c2                	cmp    %eax,%edx
f01026ec:	0f 85 7c 09 00 00    	jne    f010306e <mem_init+0x159e>
	kern_pgdir[0] = 0;
f01026f2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01026f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01026fb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102700:	0f 85 8a 09 00 00    	jne    f0103090 <mem_init+0x15c0>
	pp0->pp_ref = 0;
f0102706:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102709:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010270f:	83 ec 0c             	sub    $0xc,%esp
f0102712:	50                   	push   %eax
f0102713:	e8 e8 f0 ff ff       	call   f0101800 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102718:	83 c4 0c             	add    $0xc,%esp
f010271b:	6a 01                	push   $0x1
f010271d:	68 00 10 40 00       	push   $0x401000
f0102722:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102725:	c7 c3 ec b6 11 f0    	mov    $0xf011b6ec,%ebx
f010272b:	ff 33                	pushl  (%ebx)
f010272d:	e8 69 f1 ff ff       	call   f010189b <pgdir_walk>
f0102732:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102735:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102738:	8b 1b                	mov    (%ebx),%ebx
f010273a:	8b 53 04             	mov    0x4(%ebx),%edx
f010273d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102743:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102746:	c7 c1 e8 b6 11 f0    	mov    $0xf011b6e8,%ecx
f010274c:	8b 09                	mov    (%ecx),%ecx
f010274e:	89 d0                	mov    %edx,%eax
f0102750:	c1 e8 0c             	shr    $0xc,%eax
f0102753:	83 c4 10             	add    $0x10,%esp
f0102756:	39 c8                	cmp    %ecx,%eax
f0102758:	0f 83 54 09 00 00    	jae    f01030b2 <mem_init+0x15e2>
	assert(ptep == ptep1 + PTX(va));
f010275e:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102764:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102767:	0f 85 61 09 00 00    	jne    f01030ce <mem_init+0x15fe>
	kern_pgdir[PDX(va)] = 0;
f010276d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0102774:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102777:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f010277d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102780:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0102786:	2b 18                	sub    (%eax),%ebx
f0102788:	89 d8                	mov    %ebx,%eax
f010278a:	c1 f8 03             	sar    $0x3,%eax
f010278d:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102790:	89 c2                	mov    %eax,%edx
f0102792:	c1 ea 0c             	shr    $0xc,%edx
f0102795:	39 d1                	cmp    %edx,%ecx
f0102797:	0f 86 53 09 00 00    	jbe    f01030f0 <mem_init+0x1620>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010279d:	83 ec 04             	sub    $0x4,%esp
f01027a0:	68 00 10 00 00       	push   $0x1000
f01027a5:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01027aa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027af:	50                   	push   %eax
f01027b0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027b3:	e8 16 1d 00 00       	call   f01044ce <memset>
	page_free(pp0);
f01027b8:	83 c4 04             	add    $0x4,%esp
f01027bb:	ff 75 d0             	pushl  -0x30(%ebp)
f01027be:	e8 3d f0 ff ff       	call   f0101800 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01027c3:	83 c4 0c             	add    $0xc,%esp
f01027c6:	6a 01                	push   $0x1
f01027c8:	6a 00                	push   $0x0
f01027ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027cd:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f01027d3:	ff 30                	pushl  (%eax)
f01027d5:	e8 c1 f0 ff ff       	call   f010189b <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01027da:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f01027e0:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01027e3:	2b 10                	sub    (%eax),%edx
f01027e5:	c1 fa 03             	sar    $0x3,%edx
f01027e8:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01027eb:	89 d1                	mov    %edx,%ecx
f01027ed:	c1 e9 0c             	shr    $0xc,%ecx
f01027f0:	83 c4 10             	add    $0x10,%esp
f01027f3:	c7 c0 e8 b6 11 f0    	mov    $0xf011b6e8,%eax
f01027f9:	3b 08                	cmp    (%eax),%ecx
f01027fb:	0f 83 08 09 00 00    	jae    f0103109 <mem_init+0x1639>
	return (void *)(pa + KERNBASE);
f0102801:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102807:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010280a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102810:	f6 00 01             	testb  $0x1,(%eax)
f0102813:	0f 85 09 09 00 00    	jne    f0103122 <mem_init+0x1652>
f0102819:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f010281c:	39 d0                	cmp    %edx,%eax
f010281e:	75 f0                	jne    f0102810 <mem_init+0xd40>
	kern_pgdir[0] = 0;
f0102820:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102823:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0102829:	8b 00                	mov    (%eax),%eax
f010282b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102831:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102834:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010283a:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010283d:	89 93 d0 1f 00 00    	mov    %edx,0x1fd0(%ebx)

	// free the pages we took
	page_free(pp0);
f0102843:	83 ec 0c             	sub    $0xc,%esp
f0102846:	50                   	push   %eax
f0102847:	e8 b4 ef ff ff       	call   f0101800 <page_free>
	page_free(pp1);
f010284c:	89 3c 24             	mov    %edi,(%esp)
f010284f:	e8 ac ef ff ff       	call   f0101800 <page_free>
	page_free(pp2);
f0102854:	89 34 24             	mov    %esi,(%esp)
f0102857:	e8 a4 ef ff ff       	call   f0101800 <page_free>

	cprintf("check_page() succeeded!\n");
f010285c:	8d 83 ee c8 fe ff    	lea    -0x13712(%ebx),%eax
f0102862:	89 04 24             	mov    %eax,(%esp)
f0102865:	e8 fd 0f 00 00       	call   f0103867 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010286a:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0102870:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102872:	83 c4 10             	add    $0x10,%esp
f0102875:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010287a:	0f 86 c4 08 00 00    	jbe    f0103144 <mem_init+0x1674>
f0102880:	83 ec 08             	sub    $0x8,%esp
f0102883:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102885:	05 00 00 00 10       	add    $0x10000000,%eax
f010288a:	50                   	push   %eax
f010288b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102890:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102895:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102898:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f010289e:	8b 00                	mov    (%eax),%eax
f01028a0:	e8 a1 f0 ff ff       	call   f0101946 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01028a5:	c7 c0 00 00 11 f0    	mov    $0xf0110000,%eax
f01028ab:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01028ae:	83 c4 10             	add    $0x10,%esp
f01028b1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028b6:	0f 86 a4 08 00 00    	jbe    f0103160 <mem_init+0x1690>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01028bc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01028bf:	c7 c3 ec b6 11 f0    	mov    $0xf011b6ec,%ebx
f01028c5:	83 ec 08             	sub    $0x8,%esp
f01028c8:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f01028ca:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01028cd:	05 00 00 00 10       	add    $0x10000000,%eax
f01028d2:	50                   	push   %eax
f01028d3:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01028d8:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01028dd:	8b 03                	mov    (%ebx),%eax
f01028df:	e8 62 f0 ff ff       	call   f0101946 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f01028e4:	83 c4 08             	add    $0x8,%esp
f01028e7:	6a 02                	push   $0x2
f01028e9:	6a 00                	push   $0x0
f01028eb:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01028f0:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01028f5:	8b 03                	mov    (%ebx),%eax
f01028f7:	e8 4a f0 ff ff       	call   f0101946 <boot_map_region>
	pgdir = kern_pgdir;
f01028fc:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01028fe:	c7 c0 e8 b6 11 f0    	mov    $0xf011b6e8,%eax
f0102904:	8b 00                	mov    (%eax),%eax
f0102906:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102909:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102910:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102915:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102918:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f010291e:	8b 00                	mov    (%eax),%eax
f0102920:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102923:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102926:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f010292c:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f010292f:	bf 00 00 00 00       	mov    $0x0,%edi
f0102934:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0102937:	0f 86 84 08 00 00    	jbe    f01031c1 <mem_init+0x16f1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010293d:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f0102943:	89 f0                	mov    %esi,%eax
f0102945:	e8 0c e9 ff ff       	call   f0101256 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010294a:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102951:	0f 86 2a 08 00 00    	jbe    f0103181 <mem_init+0x16b1>
f0102957:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f010295a:	39 c2                	cmp    %eax,%edx
f010295c:	0f 85 3d 08 00 00    	jne    f010319f <mem_init+0x16cf>
	for (i = 0; i < n; i += PGSIZE)
f0102962:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102968:	eb ca                	jmp    f0102934 <mem_init+0xe64>
	assert(nfree == 0);
f010296a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010296d:	8d 83 17 c8 fe ff    	lea    -0x137e9(%ebx),%eax
f0102973:	50                   	push   %eax
f0102974:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010297a:	50                   	push   %eax
f010297b:	68 b8 02 00 00       	push   $0x2b8
f0102980:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102986:	50                   	push   %eax
f0102987:	e8 74 d7 ff ff       	call   f0100100 <_panic>
	assert((pp0 = page_alloc(0)));
f010298c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010298f:	8d 83 25 c7 fe ff    	lea    -0x138db(%ebx),%eax
f0102995:	50                   	push   %eax
f0102996:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010299c:	50                   	push   %eax
f010299d:	68 14 03 00 00       	push   $0x314
f01029a2:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01029a8:	50                   	push   %eax
f01029a9:	e8 52 d7 ff ff       	call   f0100100 <_panic>
	assert((pp1 = page_alloc(0)));
f01029ae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029b1:	8d 83 3b c7 fe ff    	lea    -0x138c5(%ebx),%eax
f01029b7:	50                   	push   %eax
f01029b8:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01029be:	50                   	push   %eax
f01029bf:	68 15 03 00 00       	push   $0x315
f01029c4:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01029ca:	50                   	push   %eax
f01029cb:	e8 30 d7 ff ff       	call   f0100100 <_panic>
	assert((pp2 = page_alloc(0)));
f01029d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029d3:	8d 83 51 c7 fe ff    	lea    -0x138af(%ebx),%eax
f01029d9:	50                   	push   %eax
f01029da:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01029e0:	50                   	push   %eax
f01029e1:	68 16 03 00 00       	push   $0x316
f01029e6:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01029ec:	50                   	push   %eax
f01029ed:	e8 0e d7 ff ff       	call   f0100100 <_panic>
	assert(pp1 && pp1 != pp0);
f01029f2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029f5:	8d 83 67 c7 fe ff    	lea    -0x13899(%ebx),%eax
f01029fb:	50                   	push   %eax
f01029fc:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102a02:	50                   	push   %eax
f0102a03:	68 19 03 00 00       	push   $0x319
f0102a08:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102a0e:	50                   	push   %eax
f0102a0f:	e8 ec d6 ff ff       	call   f0100100 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102a14:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a17:	8d 83 60 c0 fe ff    	lea    -0x13fa0(%ebx),%eax
f0102a1d:	50                   	push   %eax
f0102a1e:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102a24:	50                   	push   %eax
f0102a25:	68 1a 03 00 00       	push   $0x31a
f0102a2a:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102a30:	50                   	push   %eax
f0102a31:	e8 ca d6 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f0102a36:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a39:	8d 83 d0 c7 fe ff    	lea    -0x13830(%ebx),%eax
f0102a3f:	50                   	push   %eax
f0102a40:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102a46:	50                   	push   %eax
f0102a47:	68 21 03 00 00       	push   $0x321
f0102a4c:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102a52:	50                   	push   %eax
f0102a53:	e8 a8 d6 ff ff       	call   f0100100 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102a58:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a5b:	8d 83 a0 c0 fe ff    	lea    -0x13f60(%ebx),%eax
f0102a61:	50                   	push   %eax
f0102a62:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102a68:	50                   	push   %eax
f0102a69:	68 24 03 00 00       	push   $0x324
f0102a6e:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102a74:	50                   	push   %eax
f0102a75:	e8 86 d6 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102a7a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a7d:	8d 83 d8 c0 fe ff    	lea    -0x13f28(%ebx),%eax
f0102a83:	50                   	push   %eax
f0102a84:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102a8a:	50                   	push   %eax
f0102a8b:	68 27 03 00 00       	push   $0x327
f0102a90:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102a96:	50                   	push   %eax
f0102a97:	e8 64 d6 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102a9c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a9f:	8d 83 08 c1 fe ff    	lea    -0x13ef8(%ebx),%eax
f0102aa5:	50                   	push   %eax
f0102aa6:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102aac:	50                   	push   %eax
f0102aad:	68 2b 03 00 00       	push   $0x32b
f0102ab2:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102ab8:	50                   	push   %eax
f0102ab9:	e8 42 d6 ff ff       	call   f0100100 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102abe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ac1:	8d 83 38 c1 fe ff    	lea    -0x13ec8(%ebx),%eax
f0102ac7:	50                   	push   %eax
f0102ac8:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102ace:	50                   	push   %eax
f0102acf:	68 2d 03 00 00       	push   $0x32d
f0102ad4:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102ada:	50                   	push   %eax
f0102adb:	e8 20 d6 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102ae0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ae3:	8d 83 60 c1 fe ff    	lea    -0x13ea0(%ebx),%eax
f0102ae9:	50                   	push   %eax
f0102aea:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102af0:	50                   	push   %eax
f0102af1:	68 2e 03 00 00       	push   $0x32e
f0102af6:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102afc:	50                   	push   %eax
f0102afd:	e8 fe d5 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 1);
f0102b02:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b05:	8d 83 22 c8 fe ff    	lea    -0x137de(%ebx),%eax
f0102b0b:	50                   	push   %eax
f0102b0c:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102b12:	50                   	push   %eax
f0102b13:	68 2f 03 00 00       	push   $0x32f
f0102b18:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102b1e:	50                   	push   %eax
f0102b1f:	e8 dc d5 ff ff       	call   f0100100 <_panic>
	assert(pp0->pp_ref == 1);
f0102b24:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b27:	8d 83 33 c8 fe ff    	lea    -0x137cd(%ebx),%eax
f0102b2d:	50                   	push   %eax
f0102b2e:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102b34:	50                   	push   %eax
f0102b35:	68 30 03 00 00       	push   $0x330
f0102b3a:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102b40:	50                   	push   %eax
f0102b41:	e8 ba d5 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102b46:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b49:	8d 83 90 c1 fe ff    	lea    -0x13e70(%ebx),%eax
f0102b4f:	50                   	push   %eax
f0102b50:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102b56:	50                   	push   %eax
f0102b57:	68 33 03 00 00       	push   $0x333
f0102b5c:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102b62:	50                   	push   %eax
f0102b63:	e8 98 d5 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102b68:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b6b:	8d 83 cc c1 fe ff    	lea    -0x13e34(%ebx),%eax
f0102b71:	50                   	push   %eax
f0102b72:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102b78:	50                   	push   %eax
f0102b79:	68 34 03 00 00       	push   $0x334
f0102b7e:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102b84:	50                   	push   %eax
f0102b85:	e8 76 d5 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 1);
f0102b8a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b8d:	8d 83 44 c8 fe ff    	lea    -0x137bc(%ebx),%eax
f0102b93:	50                   	push   %eax
f0102b94:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102b9a:	50                   	push   %eax
f0102b9b:	68 35 03 00 00       	push   $0x335
f0102ba0:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102ba6:	50                   	push   %eax
f0102ba7:	e8 54 d5 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f0102bac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102baf:	8d 83 d0 c7 fe ff    	lea    -0x13830(%ebx),%eax
f0102bb5:	50                   	push   %eax
f0102bb6:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102bbc:	50                   	push   %eax
f0102bbd:	68 38 03 00 00       	push   $0x338
f0102bc2:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102bc8:	50                   	push   %eax
f0102bc9:	e8 32 d5 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102bce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bd1:	8d 83 90 c1 fe ff    	lea    -0x13e70(%ebx),%eax
f0102bd7:	50                   	push   %eax
f0102bd8:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102bde:	50                   	push   %eax
f0102bdf:	68 3b 03 00 00       	push   $0x33b
f0102be4:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102bea:	50                   	push   %eax
f0102beb:	e8 10 d5 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102bf0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bf3:	8d 83 cc c1 fe ff    	lea    -0x13e34(%ebx),%eax
f0102bf9:	50                   	push   %eax
f0102bfa:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102c00:	50                   	push   %eax
f0102c01:	68 3c 03 00 00       	push   $0x33c
f0102c06:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102c0c:	50                   	push   %eax
f0102c0d:	e8 ee d4 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 1);
f0102c12:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c15:	8d 83 44 c8 fe ff    	lea    -0x137bc(%ebx),%eax
f0102c1b:	50                   	push   %eax
f0102c1c:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102c22:	50                   	push   %eax
f0102c23:	68 3d 03 00 00       	push   $0x33d
f0102c28:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102c2e:	50                   	push   %eax
f0102c2f:	e8 cc d4 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f0102c34:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c37:	8d 83 d0 c7 fe ff    	lea    -0x13830(%ebx),%eax
f0102c3d:	50                   	push   %eax
f0102c3e:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102c44:	50                   	push   %eax
f0102c45:	68 41 03 00 00       	push   $0x341
f0102c4a:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102c50:	50                   	push   %eax
f0102c51:	e8 aa d4 ff ff       	call   f0100100 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c56:	50                   	push   %eax
f0102c57:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c5a:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f0102c60:	50                   	push   %eax
f0102c61:	68 44 03 00 00       	push   $0x344
f0102c66:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102c6c:	50                   	push   %eax
f0102c6d:	e8 8e d4 ff ff       	call   f0100100 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102c72:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c75:	8d 83 fc c1 fe ff    	lea    -0x13e04(%ebx),%eax
f0102c7b:	50                   	push   %eax
f0102c7c:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102c82:	50                   	push   %eax
f0102c83:	68 45 03 00 00       	push   $0x345
f0102c88:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102c8e:	50                   	push   %eax
f0102c8f:	e8 6c d4 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102c94:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c97:	8d 83 3c c2 fe ff    	lea    -0x13dc4(%ebx),%eax
f0102c9d:	50                   	push   %eax
f0102c9e:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102ca4:	50                   	push   %eax
f0102ca5:	68 48 03 00 00       	push   $0x348
f0102caa:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102cb0:	50                   	push   %eax
f0102cb1:	e8 4a d4 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102cb6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cb9:	8d 83 cc c1 fe ff    	lea    -0x13e34(%ebx),%eax
f0102cbf:	50                   	push   %eax
f0102cc0:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102cc6:	50                   	push   %eax
f0102cc7:	68 49 03 00 00       	push   $0x349
f0102ccc:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102cd2:	50                   	push   %eax
f0102cd3:	e8 28 d4 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 1);
f0102cd8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cdb:	8d 83 44 c8 fe ff    	lea    -0x137bc(%ebx),%eax
f0102ce1:	50                   	push   %eax
f0102ce2:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102ce8:	50                   	push   %eax
f0102ce9:	68 4a 03 00 00       	push   $0x34a
f0102cee:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102cf4:	50                   	push   %eax
f0102cf5:	e8 06 d4 ff ff       	call   f0100100 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102cfa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cfd:	8d 83 7c c2 fe ff    	lea    -0x13d84(%ebx),%eax
f0102d03:	50                   	push   %eax
f0102d04:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102d0a:	50                   	push   %eax
f0102d0b:	68 4b 03 00 00       	push   $0x34b
f0102d10:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102d16:	50                   	push   %eax
f0102d17:	e8 e4 d3 ff ff       	call   f0100100 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102d1c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d1f:	8d 83 55 c8 fe ff    	lea    -0x137ab(%ebx),%eax
f0102d25:	50                   	push   %eax
f0102d26:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102d2c:	50                   	push   %eax
f0102d2d:	68 4c 03 00 00       	push   $0x34c
f0102d32:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102d38:	50                   	push   %eax
f0102d39:	e8 c2 d3 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102d3e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d41:	8d 83 90 c1 fe ff    	lea    -0x13e70(%ebx),%eax
f0102d47:	50                   	push   %eax
f0102d48:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102d4e:	50                   	push   %eax
f0102d4f:	68 4f 03 00 00       	push   $0x34f
f0102d54:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102d5a:	50                   	push   %eax
f0102d5b:	e8 a0 d3 ff ff       	call   f0100100 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102d60:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d63:	8d 83 b0 c2 fe ff    	lea    -0x13d50(%ebx),%eax
f0102d69:	50                   	push   %eax
f0102d6a:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102d70:	50                   	push   %eax
f0102d71:	68 50 03 00 00       	push   $0x350
f0102d76:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102d7c:	50                   	push   %eax
f0102d7d:	e8 7e d3 ff ff       	call   f0100100 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102d82:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d85:	8d 83 e4 c2 fe ff    	lea    -0x13d1c(%ebx),%eax
f0102d8b:	50                   	push   %eax
f0102d8c:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102d92:	50                   	push   %eax
f0102d93:	68 51 03 00 00       	push   $0x351
f0102d98:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102d9e:	50                   	push   %eax
f0102d9f:	e8 5c d3 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102da4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102da7:	8d 83 1c c3 fe ff    	lea    -0x13ce4(%ebx),%eax
f0102dad:	50                   	push   %eax
f0102dae:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102db4:	50                   	push   %eax
f0102db5:	68 54 03 00 00       	push   $0x354
f0102dba:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102dc0:	50                   	push   %eax
f0102dc1:	e8 3a d3 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102dc6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dc9:	8d 83 54 c3 fe ff    	lea    -0x13cac(%ebx),%eax
f0102dcf:	50                   	push   %eax
f0102dd0:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102dd6:	50                   	push   %eax
f0102dd7:	68 57 03 00 00       	push   $0x357
f0102ddc:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102de2:	50                   	push   %eax
f0102de3:	e8 18 d3 ff ff       	call   f0100100 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102de8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102deb:	8d 83 e4 c2 fe ff    	lea    -0x13d1c(%ebx),%eax
f0102df1:	50                   	push   %eax
f0102df2:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102df8:	50                   	push   %eax
f0102df9:	68 58 03 00 00       	push   $0x358
f0102dfe:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102e04:	50                   	push   %eax
f0102e05:	e8 f6 d2 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102e0a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e0d:	8d 83 90 c3 fe ff    	lea    -0x13c70(%ebx),%eax
f0102e13:	50                   	push   %eax
f0102e14:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102e1a:	50                   	push   %eax
f0102e1b:	68 5b 03 00 00       	push   $0x35b
f0102e20:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102e26:	50                   	push   %eax
f0102e27:	e8 d4 d2 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102e2c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e2f:	8d 83 bc c3 fe ff    	lea    -0x13c44(%ebx),%eax
f0102e35:	50                   	push   %eax
f0102e36:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102e3c:	50                   	push   %eax
f0102e3d:	68 5c 03 00 00       	push   $0x35c
f0102e42:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102e48:	50                   	push   %eax
f0102e49:	e8 b2 d2 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 2);
f0102e4e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e51:	8d 83 6b c8 fe ff    	lea    -0x13795(%ebx),%eax
f0102e57:	50                   	push   %eax
f0102e58:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102e5e:	50                   	push   %eax
f0102e5f:	68 5e 03 00 00       	push   $0x35e
f0102e64:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102e6a:	50                   	push   %eax
f0102e6b:	e8 90 d2 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 0);
f0102e70:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e73:	8d 83 7c c8 fe ff    	lea    -0x13784(%ebx),%eax
f0102e79:	50                   	push   %eax
f0102e7a:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102e80:	50                   	push   %eax
f0102e81:	68 5f 03 00 00       	push   $0x35f
f0102e86:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102e8c:	50                   	push   %eax
f0102e8d:	e8 6e d2 ff ff       	call   f0100100 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102e92:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e95:	8d 83 ec c3 fe ff    	lea    -0x13c14(%ebx),%eax
f0102e9b:	50                   	push   %eax
f0102e9c:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102ea2:	50                   	push   %eax
f0102ea3:	68 62 03 00 00       	push   $0x362
f0102ea8:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102eae:	50                   	push   %eax
f0102eaf:	e8 4c d2 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102eb4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eb7:	8d 83 10 c4 fe ff    	lea    -0x13bf0(%ebx),%eax
f0102ebd:	50                   	push   %eax
f0102ebe:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102ec4:	50                   	push   %eax
f0102ec5:	68 66 03 00 00       	push   $0x366
f0102eca:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102ed0:	50                   	push   %eax
f0102ed1:	e8 2a d2 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102ed6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ed9:	8d 83 bc c3 fe ff    	lea    -0x13c44(%ebx),%eax
f0102edf:	50                   	push   %eax
f0102ee0:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102ee6:	50                   	push   %eax
f0102ee7:	68 67 03 00 00       	push   $0x367
f0102eec:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102ef2:	50                   	push   %eax
f0102ef3:	e8 08 d2 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 1);
f0102ef8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102efb:	8d 83 22 c8 fe ff    	lea    -0x137de(%ebx),%eax
f0102f01:	50                   	push   %eax
f0102f02:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102f08:	50                   	push   %eax
f0102f09:	68 68 03 00 00       	push   $0x368
f0102f0e:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102f14:	50                   	push   %eax
f0102f15:	e8 e6 d1 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 0);
f0102f1a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f1d:	8d 83 7c c8 fe ff    	lea    -0x13784(%ebx),%eax
f0102f23:	50                   	push   %eax
f0102f24:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102f2a:	50                   	push   %eax
f0102f2b:	68 69 03 00 00       	push   $0x369
f0102f30:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102f36:	50                   	push   %eax
f0102f37:	e8 c4 d1 ff ff       	call   f0100100 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102f3c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f3f:	8d 83 34 c4 fe ff    	lea    -0x13bcc(%ebx),%eax
f0102f45:	50                   	push   %eax
f0102f46:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102f4c:	50                   	push   %eax
f0102f4d:	68 6c 03 00 00       	push   $0x36c
f0102f52:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102f58:	50                   	push   %eax
f0102f59:	e8 a2 d1 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref);
f0102f5e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f61:	8d 83 8d c8 fe ff    	lea    -0x13773(%ebx),%eax
f0102f67:	50                   	push   %eax
f0102f68:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102f6e:	50                   	push   %eax
f0102f6f:	68 6d 03 00 00       	push   $0x36d
f0102f74:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102f7a:	50                   	push   %eax
f0102f7b:	e8 80 d1 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_link == NULL);
f0102f80:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f83:	8d 83 99 c8 fe ff    	lea    -0x13767(%ebx),%eax
f0102f89:	50                   	push   %eax
f0102f8a:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102f90:	50                   	push   %eax
f0102f91:	68 6e 03 00 00       	push   $0x36e
f0102f96:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102f9c:	50                   	push   %eax
f0102f9d:	e8 5e d1 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102fa2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fa5:	8d 83 10 c4 fe ff    	lea    -0x13bf0(%ebx),%eax
f0102fab:	50                   	push   %eax
f0102fac:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102fb2:	50                   	push   %eax
f0102fb3:	68 72 03 00 00       	push   $0x372
f0102fb8:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102fbe:	50                   	push   %eax
f0102fbf:	e8 3c d1 ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102fc4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fc7:	8d 83 6c c4 fe ff    	lea    -0x13b94(%ebx),%eax
f0102fcd:	50                   	push   %eax
f0102fce:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102fd4:	50                   	push   %eax
f0102fd5:	68 73 03 00 00       	push   $0x373
f0102fda:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0102fe0:	50                   	push   %eax
f0102fe1:	e8 1a d1 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 0);
f0102fe6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fe9:	8d 83 ae c8 fe ff    	lea    -0x13752(%ebx),%eax
f0102fef:	50                   	push   %eax
f0102ff0:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0102ff6:	50                   	push   %eax
f0102ff7:	68 74 03 00 00       	push   $0x374
f0102ffc:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0103002:	50                   	push   %eax
f0103003:	e8 f8 d0 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 0);
f0103008:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010300b:	8d 83 7c c8 fe ff    	lea    -0x13784(%ebx),%eax
f0103011:	50                   	push   %eax
f0103012:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103018:	50                   	push   %eax
f0103019:	68 75 03 00 00       	push   $0x375
f010301e:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0103024:	50                   	push   %eax
f0103025:	e8 d6 d0 ff ff       	call   f0100100 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010302a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010302d:	8d 83 94 c4 fe ff    	lea    -0x13b6c(%ebx),%eax
f0103033:	50                   	push   %eax
f0103034:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010303a:	50                   	push   %eax
f010303b:	68 78 03 00 00       	push   $0x378
f0103040:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0103046:	50                   	push   %eax
f0103047:	e8 b4 d0 ff ff       	call   f0100100 <_panic>
	assert(!page_alloc(0));
f010304c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010304f:	8d 83 d0 c7 fe ff    	lea    -0x13830(%ebx),%eax
f0103055:	50                   	push   %eax
f0103056:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010305c:	50                   	push   %eax
f010305d:	68 7b 03 00 00       	push   $0x37b
f0103062:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0103068:	50                   	push   %eax
f0103069:	e8 92 d0 ff ff       	call   f0100100 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010306e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103071:	8d 83 38 c1 fe ff    	lea    -0x13ec8(%ebx),%eax
f0103077:	50                   	push   %eax
f0103078:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f010307e:	50                   	push   %eax
f010307f:	68 7e 03 00 00       	push   $0x37e
f0103084:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010308a:	50                   	push   %eax
f010308b:	e8 70 d0 ff ff       	call   f0100100 <_panic>
	assert(pp0->pp_ref == 1);
f0103090:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103093:	8d 83 33 c8 fe ff    	lea    -0x137cd(%ebx),%eax
f0103099:	50                   	push   %eax
f010309a:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01030a0:	50                   	push   %eax
f01030a1:	68 80 03 00 00       	push   $0x380
f01030a6:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01030ac:	50                   	push   %eax
f01030ad:	e8 4e d0 ff ff       	call   f0100100 <_panic>
f01030b2:	52                   	push   %edx
f01030b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030b6:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f01030bc:	50                   	push   %eax
f01030bd:	68 87 03 00 00       	push   $0x387
f01030c2:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01030c8:	50                   	push   %eax
f01030c9:	e8 32 d0 ff ff       	call   f0100100 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01030ce:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030d1:	8d 83 bf c8 fe ff    	lea    -0x13741(%ebx),%eax
f01030d7:	50                   	push   %eax
f01030d8:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01030de:	50                   	push   %eax
f01030df:	68 88 03 00 00       	push   $0x388
f01030e4:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01030ea:	50                   	push   %eax
f01030eb:	e8 10 d0 ff ff       	call   f0100100 <_panic>
f01030f0:	50                   	push   %eax
f01030f1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030f4:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f01030fa:	50                   	push   %eax
f01030fb:	6a 52                	push   $0x52
f01030fd:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f0103103:	50                   	push   %eax
f0103104:	e8 f7 cf ff ff       	call   f0100100 <_panic>
f0103109:	52                   	push   %edx
f010310a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010310d:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f0103113:	50                   	push   %eax
f0103114:	6a 52                	push   $0x52
f0103116:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f010311c:	50                   	push   %eax
f010311d:	e8 de cf ff ff       	call   f0100100 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0103122:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103125:	8d 83 d7 c8 fe ff    	lea    -0x13729(%ebx),%eax
f010312b:	50                   	push   %eax
f010312c:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103132:	50                   	push   %eax
f0103133:	68 92 03 00 00       	push   $0x392
f0103138:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010313e:	50                   	push   %eax
f010313f:	e8 bc cf ff ff       	call   f0100100 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103144:	50                   	push   %eax
f0103145:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103148:	8d 83 3c c0 fe ff    	lea    -0x13fc4(%ebx),%eax
f010314e:	50                   	push   %eax
f010314f:	68 b2 00 00 00       	push   $0xb2
f0103154:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010315a:	50                   	push   %eax
f010315b:	e8 a0 cf ff ff       	call   f0100100 <_panic>
f0103160:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103163:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f0103169:	8d 83 3c c0 fe ff    	lea    -0x13fc4(%ebx),%eax
f010316f:	50                   	push   %eax
f0103170:	68 be 00 00 00       	push   $0xbe
f0103175:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010317b:	50                   	push   %eax
f010317c:	e8 7f cf ff ff       	call   f0100100 <_panic>
f0103181:	ff 75 c0             	pushl  -0x40(%ebp)
f0103184:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103187:	8d 83 3c c0 fe ff    	lea    -0x13fc4(%ebx),%eax
f010318d:	50                   	push   %eax
f010318e:	68 d2 02 00 00       	push   $0x2d2
f0103193:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0103199:	50                   	push   %eax
f010319a:	e8 61 cf ff ff       	call   f0100100 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010319f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031a2:	8d 83 b8 c4 fe ff    	lea    -0x13b48(%ebx),%eax
f01031a8:	50                   	push   %eax
f01031a9:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01031af:	50                   	push   %eax
f01031b0:	68 d2 02 00 00       	push   $0x2d2
f01031b5:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01031bb:	50                   	push   %eax
f01031bc:	e8 3f cf ff ff       	call   f0100100 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01031c1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01031c4:	c1 e7 0c             	shl    $0xc,%edi
f01031c7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01031cc:	eb 17                	jmp    f01031e5 <mem_init+0x1715>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01031ce:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01031d4:	89 f0                	mov    %esi,%eax
f01031d6:	e8 7b e0 ff ff       	call   f0101256 <check_va2pa>
f01031db:	39 c3                	cmp    %eax,%ebx
f01031dd:	75 51                	jne    f0103230 <mem_init+0x1760>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01031df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01031e5:	39 fb                	cmp    %edi,%ebx
f01031e7:	72 e5                	jb     f01031ce <mem_init+0x16fe>
f01031e9:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01031ee:	8b 7d c8             	mov    -0x38(%ebp),%edi
f01031f1:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f01031f7:	89 da                	mov    %ebx,%edx
f01031f9:	89 f0                	mov    %esi,%eax
f01031fb:	e8 56 e0 ff ff       	call   f0101256 <check_va2pa>
f0103200:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0103203:	39 c2                	cmp    %eax,%edx
f0103205:	75 4b                	jne    f0103252 <mem_init+0x1782>
f0103207:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010320d:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0103213:	75 e2                	jne    f01031f7 <mem_init+0x1727>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0103215:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010321a:	89 f0                	mov    %esi,%eax
f010321c:	e8 35 e0 ff ff       	call   f0101256 <check_va2pa>
f0103221:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103224:	75 4e                	jne    f0103274 <mem_init+0x17a4>
	for (i = 0; i < NPDENTRIES; i++) {
f0103226:	b8 00 00 00 00       	mov    $0x0,%eax
f010322b:	e9 8f 00 00 00       	jmp    f01032bf <mem_init+0x17ef>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103230:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103233:	8d 83 ec c4 fe ff    	lea    -0x13b14(%ebx),%eax
f0103239:	50                   	push   %eax
f010323a:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103240:	50                   	push   %eax
f0103241:	68 d8 02 00 00       	push   $0x2d8
f0103246:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010324c:	50                   	push   %eax
f010324d:	e8 ae ce ff ff       	call   f0100100 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103252:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103255:	8d 83 14 c5 fe ff    	lea    -0x13aec(%ebx),%eax
f010325b:	50                   	push   %eax
f010325c:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103262:	50                   	push   %eax
f0103263:	68 dc 02 00 00       	push   $0x2dc
f0103268:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010326e:	50                   	push   %eax
f010326f:	e8 8c ce ff ff       	call   f0100100 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0103274:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103277:	8d 83 5c c5 fe ff    	lea    -0x13aa4(%ebx),%eax
f010327d:	50                   	push   %eax
f010327e:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103284:	50                   	push   %eax
f0103285:	68 dd 02 00 00       	push   $0x2dd
f010328a:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0103290:	50                   	push   %eax
f0103291:	e8 6a ce ff ff       	call   f0100100 <_panic>
			assert(pgdir[i] & PTE_P);
f0103296:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f010329a:	74 52                	je     f01032ee <mem_init+0x181e>
	for (i = 0; i < NPDENTRIES; i++) {
f010329c:	83 c0 01             	add    $0x1,%eax
f010329f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01032a4:	0f 87 bb 00 00 00    	ja     f0103365 <mem_init+0x1895>
		switch (i) {
f01032aa:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01032af:	72 0e                	jb     f01032bf <mem_init+0x17ef>
f01032b1:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01032b6:	76 de                	jbe    f0103296 <mem_init+0x17c6>
f01032b8:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01032bd:	74 d7                	je     f0103296 <mem_init+0x17c6>
			if (i >= PDX(KERNBASE)) {
f01032bf:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01032c4:	77 4a                	ja     f0103310 <mem_init+0x1840>
				assert(pgdir[i] == 0);
f01032c6:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01032ca:	74 d0                	je     f010329c <mem_init+0x17cc>
f01032cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032cf:	8d 83 29 c9 fe ff    	lea    -0x136d7(%ebx),%eax
f01032d5:	50                   	push   %eax
f01032d6:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01032dc:	50                   	push   %eax
f01032dd:	68 ec 02 00 00       	push   $0x2ec
f01032e2:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01032e8:	50                   	push   %eax
f01032e9:	e8 12 ce ff ff       	call   f0100100 <_panic>
			assert(pgdir[i] & PTE_P);
f01032ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032f1:	8d 83 07 c9 fe ff    	lea    -0x136f9(%ebx),%eax
f01032f7:	50                   	push   %eax
f01032f8:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01032fe:	50                   	push   %eax
f01032ff:	68 e5 02 00 00       	push   $0x2e5
f0103304:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010330a:	50                   	push   %eax
f010330b:	e8 f0 cd ff ff       	call   f0100100 <_panic>
				assert(pgdir[i] & PTE_P);
f0103310:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0103313:	f6 c2 01             	test   $0x1,%dl
f0103316:	74 2b                	je     f0103343 <mem_init+0x1873>
				assert(pgdir[i] & PTE_W);
f0103318:	f6 c2 02             	test   $0x2,%dl
f010331b:	0f 85 7b ff ff ff    	jne    f010329c <mem_init+0x17cc>
f0103321:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103324:	8d 83 18 c9 fe ff    	lea    -0x136e8(%ebx),%eax
f010332a:	50                   	push   %eax
f010332b:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103331:	50                   	push   %eax
f0103332:	68 ea 02 00 00       	push   $0x2ea
f0103337:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010333d:	50                   	push   %eax
f010333e:	e8 bd cd ff ff       	call   f0100100 <_panic>
				assert(pgdir[i] & PTE_P);
f0103343:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103346:	8d 83 07 c9 fe ff    	lea    -0x136f9(%ebx),%eax
f010334c:	50                   	push   %eax
f010334d:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103353:	50                   	push   %eax
f0103354:	68 e9 02 00 00       	push   $0x2e9
f0103359:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010335f:	50                   	push   %eax
f0103360:	e8 9b cd ff ff       	call   f0100100 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0103365:	83 ec 0c             	sub    $0xc,%esp
f0103368:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010336b:	8d 87 8c c5 fe ff    	lea    -0x13a74(%edi),%eax
f0103371:	50                   	push   %eax
f0103372:	89 fb                	mov    %edi,%ebx
f0103374:	e8 ee 04 00 00       	call   f0103867 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103379:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f010337f:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103381:	83 c4 10             	add    $0x10,%esp
f0103384:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103389:	0f 86 44 02 00 00    	jbe    f01035d3 <mem_init+0x1b03>
	return (physaddr_t)kva - KERNBASE;
f010338f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103394:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103397:	b8 00 00 00 00       	mov    $0x0,%eax
f010339c:	e8 32 df ff ff       	call   f01012d3 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01033a1:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01033a4:	83 e0 f3             	and    $0xfffffff3,%eax
f01033a7:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01033ac:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01033af:	83 ec 0c             	sub    $0xc,%esp
f01033b2:	6a 00                	push   $0x0
f01033b4:	e8 bf e3 ff ff       	call   f0101778 <page_alloc>
f01033b9:	89 c6                	mov    %eax,%esi
f01033bb:	83 c4 10             	add    $0x10,%esp
f01033be:	85 c0                	test   %eax,%eax
f01033c0:	0f 84 29 02 00 00    	je     f01035ef <mem_init+0x1b1f>
	assert((pp1 = page_alloc(0)));
f01033c6:	83 ec 0c             	sub    $0xc,%esp
f01033c9:	6a 00                	push   $0x0
f01033cb:	e8 a8 e3 ff ff       	call   f0101778 <page_alloc>
f01033d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01033d3:	83 c4 10             	add    $0x10,%esp
f01033d6:	85 c0                	test   %eax,%eax
f01033d8:	0f 84 33 02 00 00    	je     f0103611 <mem_init+0x1b41>
	assert((pp2 = page_alloc(0)));
f01033de:	83 ec 0c             	sub    $0xc,%esp
f01033e1:	6a 00                	push   $0x0
f01033e3:	e8 90 e3 ff ff       	call   f0101778 <page_alloc>
f01033e8:	89 c7                	mov    %eax,%edi
f01033ea:	83 c4 10             	add    $0x10,%esp
f01033ed:	85 c0                	test   %eax,%eax
f01033ef:	0f 84 3e 02 00 00    	je     f0103633 <mem_init+0x1b63>
	page_free(pp0);
f01033f5:	83 ec 0c             	sub    $0xc,%esp
f01033f8:	56                   	push   %esi
f01033f9:	e8 02 e4 ff ff       	call   f0101800 <page_free>
	return (pp - pages) << PGSHIFT;
f01033fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103401:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0103407:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010340a:	2b 08                	sub    (%eax),%ecx
f010340c:	89 c8                	mov    %ecx,%eax
f010340e:	c1 f8 03             	sar    $0x3,%eax
f0103411:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103414:	89 c1                	mov    %eax,%ecx
f0103416:	c1 e9 0c             	shr    $0xc,%ecx
f0103419:	83 c4 10             	add    $0x10,%esp
f010341c:	c7 c2 e8 b6 11 f0    	mov    $0xf011b6e8,%edx
f0103422:	3b 0a                	cmp    (%edx),%ecx
f0103424:	0f 83 2b 02 00 00    	jae    f0103655 <mem_init+0x1b85>
	memset(page2kva(pp1), 1, PGSIZE);
f010342a:	83 ec 04             	sub    $0x4,%esp
f010342d:	68 00 10 00 00       	push   $0x1000
f0103432:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103434:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103439:	50                   	push   %eax
f010343a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010343d:	e8 8c 10 00 00       	call   f01044ce <memset>
	return (pp - pages) << PGSHIFT;
f0103442:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103445:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f010344b:	89 f9                	mov    %edi,%ecx
f010344d:	2b 08                	sub    (%eax),%ecx
f010344f:	89 c8                	mov    %ecx,%eax
f0103451:	c1 f8 03             	sar    $0x3,%eax
f0103454:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103457:	89 c1                	mov    %eax,%ecx
f0103459:	c1 e9 0c             	shr    $0xc,%ecx
f010345c:	83 c4 10             	add    $0x10,%esp
f010345f:	c7 c2 e8 b6 11 f0    	mov    $0xf011b6e8,%edx
f0103465:	3b 0a                	cmp    (%edx),%ecx
f0103467:	0f 83 fe 01 00 00    	jae    f010366b <mem_init+0x1b9b>
	memset(page2kva(pp2), 2, PGSIZE);
f010346d:	83 ec 04             	sub    $0x4,%esp
f0103470:	68 00 10 00 00       	push   $0x1000
f0103475:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0103477:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010347c:	50                   	push   %eax
f010347d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103480:	e8 49 10 00 00       	call   f01044ce <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103485:	6a 02                	push   $0x2
f0103487:	68 00 10 00 00       	push   $0x1000
f010348c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010348f:	53                   	push   %ebx
f0103490:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103493:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0103499:	ff 30                	pushl  (%eax)
f010349b:	e8 a4 e5 ff ff       	call   f0101a44 <page_insert>
	assert(pp1->pp_ref == 1);
f01034a0:	83 c4 20             	add    $0x20,%esp
f01034a3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01034a8:	0f 85 d3 01 00 00    	jne    f0103681 <mem_init+0x1bb1>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01034ae:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01034b5:	01 01 01 
f01034b8:	0f 85 e5 01 00 00    	jne    f01036a3 <mem_init+0x1bd3>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01034be:	6a 02                	push   $0x2
f01034c0:	68 00 10 00 00       	push   $0x1000
f01034c5:	57                   	push   %edi
f01034c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01034c9:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f01034cf:	ff 30                	pushl  (%eax)
f01034d1:	e8 6e e5 ff ff       	call   f0101a44 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01034d6:	83 c4 10             	add    $0x10,%esp
f01034d9:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01034e0:	02 02 02 
f01034e3:	0f 85 dc 01 00 00    	jne    f01036c5 <mem_init+0x1bf5>
	assert(pp2->pp_ref == 1);
f01034e9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01034ee:	0f 85 f3 01 00 00    	jne    f01036e7 <mem_init+0x1c17>
	assert(pp1->pp_ref == 0);
f01034f4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01034f7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01034fc:	0f 85 07 02 00 00    	jne    f0103709 <mem_init+0x1c39>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103502:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103509:	03 03 03 
	return (pp - pages) << PGSHIFT;
f010350c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010350f:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0103515:	89 f9                	mov    %edi,%ecx
f0103517:	2b 08                	sub    (%eax),%ecx
f0103519:	89 c8                	mov    %ecx,%eax
f010351b:	c1 f8 03             	sar    $0x3,%eax
f010351e:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103521:	89 c1                	mov    %eax,%ecx
f0103523:	c1 e9 0c             	shr    $0xc,%ecx
f0103526:	c7 c2 e8 b6 11 f0    	mov    $0xf011b6e8,%edx
f010352c:	3b 0a                	cmp    (%edx),%ecx
f010352e:	0f 83 f7 01 00 00    	jae    f010372b <mem_init+0x1c5b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103534:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010353b:	03 03 03 
f010353e:	0f 85 fd 01 00 00    	jne    f0103741 <mem_init+0x1c71>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103544:	83 ec 08             	sub    $0x8,%esp
f0103547:	68 00 10 00 00       	push   $0x1000
f010354c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010354f:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0103555:	ff 30                	pushl  (%eax)
f0103557:	e8 a9 e4 ff ff       	call   f0101a05 <page_remove>
	assert(pp2->pp_ref == 0);
f010355c:	83 c4 10             	add    $0x10,%esp
f010355f:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103564:	0f 85 f9 01 00 00    	jne    f0103763 <mem_init+0x1c93>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010356a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010356d:	c7 c0 ec b6 11 f0    	mov    $0xf011b6ec,%eax
f0103573:	8b 08                	mov    (%eax),%ecx
f0103575:	8b 11                	mov    (%ecx),%edx
f0103577:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010357d:	c7 c0 f0 b6 11 f0    	mov    $0xf011b6f0,%eax
f0103583:	89 f7                	mov    %esi,%edi
f0103585:	2b 38                	sub    (%eax),%edi
f0103587:	89 f8                	mov    %edi,%eax
f0103589:	c1 f8 03             	sar    $0x3,%eax
f010358c:	c1 e0 0c             	shl    $0xc,%eax
f010358f:	39 c2                	cmp    %eax,%edx
f0103591:	0f 85 ee 01 00 00    	jne    f0103785 <mem_init+0x1cb5>
	kern_pgdir[0] = 0;
f0103597:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010359d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01035a2:	0f 85 ff 01 00 00    	jne    f01037a7 <mem_init+0x1cd7>
	pp0->pp_ref = 0;
f01035a8:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01035ae:	83 ec 0c             	sub    $0xc,%esp
f01035b1:	56                   	push   %esi
f01035b2:	e8 49 e2 ff ff       	call   f0101800 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01035b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035ba:	8d 83 20 c6 fe ff    	lea    -0x139e0(%ebx),%eax
f01035c0:	89 04 24             	mov    %eax,(%esp)
f01035c3:	e8 9f 02 00 00       	call   f0103867 <cprintf>
}
f01035c8:	83 c4 10             	add    $0x10,%esp
f01035cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035ce:	5b                   	pop    %ebx
f01035cf:	5e                   	pop    %esi
f01035d0:	5f                   	pop    %edi
f01035d1:	5d                   	pop    %ebp
f01035d2:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035d3:	50                   	push   %eax
f01035d4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035d7:	8d 83 3c c0 fe ff    	lea    -0x13fc4(%ebx),%eax
f01035dd:	50                   	push   %eax
f01035de:	68 d2 00 00 00       	push   $0xd2
f01035e3:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01035e9:	50                   	push   %eax
f01035ea:	e8 11 cb ff ff       	call   f0100100 <_panic>
	assert((pp0 = page_alloc(0)));
f01035ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035f2:	8d 83 25 c7 fe ff    	lea    -0x138db(%ebx),%eax
f01035f8:	50                   	push   %eax
f01035f9:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01035ff:	50                   	push   %eax
f0103600:	68 ad 03 00 00       	push   $0x3ad
f0103605:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010360b:	50                   	push   %eax
f010360c:	e8 ef ca ff ff       	call   f0100100 <_panic>
	assert((pp1 = page_alloc(0)));
f0103611:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103614:	8d 83 3b c7 fe ff    	lea    -0x138c5(%ebx),%eax
f010361a:	50                   	push   %eax
f010361b:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103621:	50                   	push   %eax
f0103622:	68 ae 03 00 00       	push   $0x3ae
f0103627:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010362d:	50                   	push   %eax
f010362e:	e8 cd ca ff ff       	call   f0100100 <_panic>
	assert((pp2 = page_alloc(0)));
f0103633:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103636:	8d 83 51 c7 fe ff    	lea    -0x138af(%ebx),%eax
f010363c:	50                   	push   %eax
f010363d:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103643:	50                   	push   %eax
f0103644:	68 af 03 00 00       	push   $0x3af
f0103649:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010364f:	50                   	push   %eax
f0103650:	e8 ab ca ff ff       	call   f0100100 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103655:	50                   	push   %eax
f0103656:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f010365c:	50                   	push   %eax
f010365d:	6a 52                	push   $0x52
f010365f:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f0103665:	50                   	push   %eax
f0103666:	e8 95 ca ff ff       	call   f0100100 <_panic>
f010366b:	50                   	push   %eax
f010366c:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f0103672:	50                   	push   %eax
f0103673:	6a 52                	push   $0x52
f0103675:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f010367b:	50                   	push   %eax
f010367c:	e8 7f ca ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 1);
f0103681:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103684:	8d 83 22 c8 fe ff    	lea    -0x137de(%ebx),%eax
f010368a:	50                   	push   %eax
f010368b:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103691:	50                   	push   %eax
f0103692:	68 b4 03 00 00       	push   $0x3b4
f0103697:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010369d:	50                   	push   %eax
f010369e:	e8 5d ca ff ff       	call   f0100100 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01036a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01036a6:	8d 83 ac c5 fe ff    	lea    -0x13a54(%ebx),%eax
f01036ac:	50                   	push   %eax
f01036ad:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01036b3:	50                   	push   %eax
f01036b4:	68 b5 03 00 00       	push   $0x3b5
f01036b9:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01036bf:	50                   	push   %eax
f01036c0:	e8 3b ca ff ff       	call   f0100100 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01036c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01036c8:	8d 83 d0 c5 fe ff    	lea    -0x13a30(%ebx),%eax
f01036ce:	50                   	push   %eax
f01036cf:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01036d5:	50                   	push   %eax
f01036d6:	68 b7 03 00 00       	push   $0x3b7
f01036db:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01036e1:	50                   	push   %eax
f01036e2:	e8 19 ca ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 1);
f01036e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01036ea:	8d 83 44 c8 fe ff    	lea    -0x137bc(%ebx),%eax
f01036f0:	50                   	push   %eax
f01036f1:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01036f7:	50                   	push   %eax
f01036f8:	68 b8 03 00 00       	push   $0x3b8
f01036fd:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0103703:	50                   	push   %eax
f0103704:	e8 f7 c9 ff ff       	call   f0100100 <_panic>
	assert(pp1->pp_ref == 0);
f0103709:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010370c:	8d 83 ae c8 fe ff    	lea    -0x13752(%ebx),%eax
f0103712:	50                   	push   %eax
f0103713:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103719:	50                   	push   %eax
f010371a:	68 b9 03 00 00       	push   $0x3b9
f010371f:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f0103725:	50                   	push   %eax
f0103726:	e8 d5 c9 ff ff       	call   f0100100 <_panic>
f010372b:	50                   	push   %eax
f010372c:	8d 83 78 bd fe ff    	lea    -0x14288(%ebx),%eax
f0103732:	50                   	push   %eax
f0103733:	6a 52                	push   $0x52
f0103735:	8d 83 58 c6 fe ff    	lea    -0x139a8(%ebx),%eax
f010373b:	50                   	push   %eax
f010373c:	e8 bf c9 ff ff       	call   f0100100 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103741:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103744:	8d 83 f4 c5 fe ff    	lea    -0x13a0c(%ebx),%eax
f010374a:	50                   	push   %eax
f010374b:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103751:	50                   	push   %eax
f0103752:	68 bb 03 00 00       	push   $0x3bb
f0103757:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010375d:	50                   	push   %eax
f010375e:	e8 9d c9 ff ff       	call   f0100100 <_panic>
	assert(pp2->pp_ref == 0);
f0103763:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103766:	8d 83 7c c8 fe ff    	lea    -0x13784(%ebx),%eax
f010376c:	50                   	push   %eax
f010376d:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103773:	50                   	push   %eax
f0103774:	68 bd 03 00 00       	push   $0x3bd
f0103779:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f010377f:	50                   	push   %eax
f0103780:	e8 7b c9 ff ff       	call   f0100100 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103785:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103788:	8d 83 38 c1 fe ff    	lea    -0x13ec8(%ebx),%eax
f010378e:	50                   	push   %eax
f010378f:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f0103795:	50                   	push   %eax
f0103796:	68 c0 03 00 00       	push   $0x3c0
f010379b:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01037a1:	50                   	push   %eax
f01037a2:	e8 59 c9 ff ff       	call   f0100100 <_panic>
	assert(pp0->pp_ref == 1);
f01037a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01037aa:	8d 83 33 c8 fe ff    	lea    -0x137cd(%ebx),%eax
f01037b0:	50                   	push   %eax
f01037b1:	8d 83 12 b9 fe ff    	lea    -0x146ee(%ebx),%eax
f01037b7:	50                   	push   %eax
f01037b8:	68 c2 03 00 00       	push   $0x3c2
f01037bd:	8d 83 4c c6 fe ff    	lea    -0x139b4(%ebx),%eax
f01037c3:	50                   	push   %eax
f01037c4:	e8 37 c9 ff ff       	call   f0100100 <_panic>

f01037c9 <tlb_invalidate>:
{
f01037c9:	55                   	push   %ebp
f01037ca:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01037cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037cf:	0f 01 38             	invlpg (%eax)
}
f01037d2:	5d                   	pop    %ebp
f01037d3:	c3                   	ret    

f01037d4 <__x86.get_pc_thunk.cx>:
f01037d4:	8b 0c 24             	mov    (%esp),%ecx
f01037d7:	c3                   	ret    

f01037d8 <__x86.get_pc_thunk.si>:
f01037d8:	8b 34 24             	mov    (%esp),%esi
f01037db:	c3                   	ret    

f01037dc <__x86.get_pc_thunk.di>:
f01037dc:	8b 3c 24             	mov    (%esp),%edi
f01037df:	c3                   	ret    

f01037e0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01037e0:	55                   	push   %ebp
f01037e1:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01037e6:	ba 70 00 00 00       	mov    $0x70,%edx
f01037eb:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01037ec:	ba 71 00 00 00       	mov    $0x71,%edx
f01037f1:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01037f2:	0f b6 c0             	movzbl %al,%eax
}
f01037f5:	5d                   	pop    %ebp
f01037f6:	c3                   	ret    

f01037f7 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01037f7:	55                   	push   %ebp
f01037f8:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01037fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01037fd:	ba 70 00 00 00       	mov    $0x70,%edx
f0103802:	ee                   	out    %al,(%dx)
f0103803:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103806:	ba 71 00 00 00       	mov    $0x71,%edx
f010380b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010380c:	5d                   	pop    %ebp
f010380d:	c3                   	ret    

f010380e <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010380e:	55                   	push   %ebp
f010380f:	89 e5                	mov    %esp,%ebp
f0103811:	53                   	push   %ebx
f0103812:	83 ec 10             	sub    $0x10,%esp
f0103815:	e8 9c c9 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f010381a:	81 c3 f2 5a 01 00    	add    $0x15af2,%ebx
	cputchar(ch);
f0103820:	ff 75 08             	pushl  0x8(%ebp)
f0103823:	e8 05 cf ff ff       	call   f010072d <cputchar>
	*cnt++;
}
f0103828:	83 c4 10             	add    $0x10,%esp
f010382b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010382e:	c9                   	leave  
f010382f:	c3                   	ret    

f0103830 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103830:	55                   	push   %ebp
f0103831:	89 e5                	mov    %esp,%ebp
f0103833:	53                   	push   %ebx
f0103834:	83 ec 14             	sub    $0x14,%esp
f0103837:	e8 7a c9 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f010383c:	81 c3 d0 5a 01 00    	add    $0x15ad0,%ebx
	int cnt = 0;
f0103842:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103849:	ff 75 0c             	pushl  0xc(%ebp)
f010384c:	ff 75 08             	pushl  0x8(%ebp)
f010384f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103852:	50                   	push   %eax
f0103853:	8d 83 02 a5 fe ff    	lea    -0x15afe(%ebx),%eax
f0103859:	50                   	push   %eax
f010385a:	e8 8d 04 00 00       	call   f0103cec <vprintfmt>
	return cnt;
}
f010385f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103865:	c9                   	leave  
f0103866:	c3                   	ret    

f0103867 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103867:	55                   	push   %ebp
f0103868:	89 e5                	mov    %esp,%ebp
f010386a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010386d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103870:	50                   	push   %eax
f0103871:	ff 75 08             	pushl  0x8(%ebp)
f0103874:	e8 b7 ff ff ff       	call   f0103830 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103879:	c9                   	leave  
f010387a:	c3                   	ret    

f010387b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010387b:	55                   	push   %ebp
f010387c:	89 e5                	mov    %esp,%ebp
f010387e:	57                   	push   %edi
f010387f:	56                   	push   %esi
f0103880:	53                   	push   %ebx
f0103881:	83 ec 14             	sub    $0x14,%esp
f0103884:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103887:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010388a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010388d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103890:	8b 32                	mov    (%edx),%esi
f0103892:	8b 01                	mov    (%ecx),%eax
f0103894:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103897:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010389e:	eb 2f                	jmp    f01038cf <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01038a0:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01038a3:	39 c6                	cmp    %eax,%esi
f01038a5:	7f 49                	jg     f01038f0 <stab_binsearch+0x75>
f01038a7:	0f b6 0a             	movzbl (%edx),%ecx
f01038aa:	83 ea 0c             	sub    $0xc,%edx
f01038ad:	39 f9                	cmp    %edi,%ecx
f01038af:	75 ef                	jne    f01038a0 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01038b1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01038b4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01038b7:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01038bb:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01038be:	73 35                	jae    f01038f5 <stab_binsearch+0x7a>
			*region_left = m;
f01038c0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01038c3:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01038c5:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f01038c8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01038cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01038d2:	7f 4e                	jg     f0103922 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f01038d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01038d7:	01 f0                	add    %esi,%eax
f01038d9:	89 c3                	mov    %eax,%ebx
f01038db:	c1 eb 1f             	shr    $0x1f,%ebx
f01038de:	01 c3                	add    %eax,%ebx
f01038e0:	d1 fb                	sar    %ebx
f01038e2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01038e5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01038e8:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01038ec:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f01038ee:	eb b3                	jmp    f01038a3 <stab_binsearch+0x28>
			l = true_m + 1;
f01038f0:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f01038f3:	eb da                	jmp    f01038cf <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f01038f5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01038f8:	76 14                	jbe    f010390e <stab_binsearch+0x93>
			*region_right = m - 1;
f01038fa:	83 e8 01             	sub    $0x1,%eax
f01038fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103900:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103903:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0103905:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010390c:	eb c1                	jmp    f01038cf <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010390e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103911:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0103913:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103917:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0103919:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103920:	eb ad                	jmp    f01038cf <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0103922:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103926:	74 16                	je     f010393e <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103928:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010392b:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010392d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103930:	8b 0e                	mov    (%esi),%ecx
f0103932:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103935:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103938:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f010393c:	eb 12                	jmp    f0103950 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f010393e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103941:	8b 00                	mov    (%eax),%eax
f0103943:	83 e8 01             	sub    $0x1,%eax
f0103946:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103949:	89 07                	mov    %eax,(%edi)
f010394b:	eb 16                	jmp    f0103963 <stab_binsearch+0xe8>
		     l--)
f010394d:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0103950:	39 c1                	cmp    %eax,%ecx
f0103952:	7d 0a                	jge    f010395e <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0103954:	0f b6 1a             	movzbl (%edx),%ebx
f0103957:	83 ea 0c             	sub    $0xc,%edx
f010395a:	39 fb                	cmp    %edi,%ebx
f010395c:	75 ef                	jne    f010394d <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f010395e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103961:	89 07                	mov    %eax,(%edi)
	}
}
f0103963:	83 c4 14             	add    $0x14,%esp
f0103966:	5b                   	pop    %ebx
f0103967:	5e                   	pop    %esi
f0103968:	5f                   	pop    %edi
f0103969:	5d                   	pop    %ebp
f010396a:	c3                   	ret    

f010396b <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010396b:	55                   	push   %ebp
f010396c:	89 e5                	mov    %esp,%ebp
f010396e:	57                   	push   %edi
f010396f:	56                   	push   %esi
f0103970:	53                   	push   %ebx
f0103971:	83 ec 3c             	sub    $0x3c,%esp
f0103974:	e8 3d c8 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0103979:	81 c3 93 59 01 00    	add    $0x15993,%ebx
f010397f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103982:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103985:	8d 83 37 c9 fe ff    	lea    -0x136c9(%ebx),%eax
f010398b:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f010398d:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0103994:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0103997:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010399e:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01039a1:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01039a8:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01039ae:	0f 86 2f 01 00 00    	jbe    f0103ae3 <debuginfo_eip+0x178>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01039b4:	c7 c0 8d d0 10 f0    	mov    $0xf010d08d,%eax
f01039ba:	39 83 f8 ff ff ff    	cmp    %eax,-0x8(%ebx)
f01039c0:	0f 86 00 02 00 00    	jbe    f0103bc6 <debuginfo_eip+0x25b>
f01039c6:	c7 c0 02 f1 10 f0    	mov    $0xf010f102,%eax
f01039cc:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01039d0:	0f 85 f7 01 00 00    	jne    f0103bcd <debuginfo_eip+0x262>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01039d6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01039dd:	c7 c0 5c 5e 10 f0    	mov    $0xf0105e5c,%eax
f01039e3:	c7 c2 8c d0 10 f0    	mov    $0xf010d08c,%edx
f01039e9:	29 c2                	sub    %eax,%edx
f01039eb:	c1 fa 02             	sar    $0x2,%edx
f01039ee:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01039f4:	83 ea 01             	sub    $0x1,%edx
f01039f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01039fa:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01039fd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103a00:	83 ec 08             	sub    $0x8,%esp
f0103a03:	57                   	push   %edi
f0103a04:	6a 64                	push   $0x64
f0103a06:	e8 70 fe ff ff       	call   f010387b <stab_binsearch>
	if (lfile == 0)
f0103a0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a0e:	83 c4 10             	add    $0x10,%esp
f0103a11:	85 c0                	test   %eax,%eax
f0103a13:	0f 84 bb 01 00 00    	je     f0103bd4 <debuginfo_eip+0x269>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103a19:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103a1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103a22:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103a25:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103a28:	83 ec 08             	sub    $0x8,%esp
f0103a2b:	57                   	push   %edi
f0103a2c:	6a 24                	push   $0x24
f0103a2e:	c7 c0 5c 5e 10 f0    	mov    $0xf0105e5c,%eax
f0103a34:	e8 42 fe ff ff       	call   f010387b <stab_binsearch>

	if (lfun <= rfun) {
f0103a39:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103a3c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0103a3f:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0103a42:	83 c4 10             	add    $0x10,%esp
f0103a45:	39 c8                	cmp    %ecx,%eax
f0103a47:	0f 8f ae 00 00 00    	jg     f0103afb <debuginfo_eip+0x190>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103a4d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103a50:	c7 c1 5c 5e 10 f0    	mov    $0xf0105e5c,%ecx
f0103a56:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0103a59:	8b 11                	mov    (%ecx),%edx
f0103a5b:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0103a5e:	c7 c2 02 f1 10 f0    	mov    $0xf010f102,%edx
f0103a64:	81 ea 8d d0 10 f0    	sub    $0xf010d08d,%edx
f0103a6a:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0103a6d:	73 0c                	jae    f0103a7b <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103a6f:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103a72:	81 c2 8d d0 10 f0    	add    $0xf010d08d,%edx
f0103a78:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103a7b:	8b 51 08             	mov    0x8(%ecx),%edx
f0103a7e:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0103a81:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0103a83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103a86:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103a89:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103a8c:	83 ec 08             	sub    $0x8,%esp
f0103a8f:	6a 3a                	push   $0x3a
f0103a91:	ff 76 08             	pushl  0x8(%esi)
f0103a94:	e8 19 0a 00 00       	call   f01044b2 <strfind>
f0103a99:	2b 46 08             	sub    0x8(%esi),%eax
f0103a9c:	89 46 0c             	mov    %eax,0xc(%esi)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103a9f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103aa2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103aa5:	83 c4 08             	add    $0x8,%esp
f0103aa8:	57                   	push   %edi
f0103aa9:	6a 44                	push   $0x44
f0103aab:	c7 c7 5c 5e 10 f0    	mov    $0xf0105e5c,%edi
f0103ab1:	89 f8                	mov    %edi,%eax
f0103ab3:	e8 c3 fd ff ff       	call   f010387b <stab_binsearch>
	// cprintf("symbol table: %d\n", stabs[lline].n_desc);
	info->eip_line = stabs[lline].n_desc;
f0103ab8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103abb:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103abe:	c1 e2 02             	shl    $0x2,%edx
f0103ac1:	0f b7 4c 3a 06       	movzwl 0x6(%edx,%edi,1),%ecx
f0103ac6:	89 4e 04             	mov    %ecx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ac9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103acc:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f0103ad0:	83 c4 10             	add    $0x10,%esp
f0103ad3:	c6 45 c0 00          	movb   $0x0,-0x40(%ebp)
f0103ad7:	bf 01 00 00 00       	mov    $0x1,%edi
f0103adc:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103adf:	89 ce                	mov    %ecx,%esi
f0103ae1:	eb 34                	jmp    f0103b17 <debuginfo_eip+0x1ac>
  	        panic("User address");
f0103ae3:	83 ec 04             	sub    $0x4,%esp
f0103ae6:	8d 83 41 c9 fe ff    	lea    -0x136bf(%ebx),%eax
f0103aec:	50                   	push   %eax
f0103aed:	6a 7f                	push   $0x7f
f0103aef:	8d 83 4e c9 fe ff    	lea    -0x136b2(%ebx),%eax
f0103af5:	50                   	push   %eax
f0103af6:	e8 05 c6 ff ff       	call   f0100100 <_panic>
		info->eip_fn_addr = addr;
f0103afb:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0103afe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b01:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103b04:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b07:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103b0a:	eb 80                	jmp    f0103a8c <debuginfo_eip+0x121>
f0103b0c:	83 e8 01             	sub    $0x1,%eax
f0103b0f:	83 ea 0c             	sub    $0xc,%edx
f0103b12:	89 f9                	mov    %edi,%ecx
f0103b14:	88 4d c0             	mov    %cl,-0x40(%ebp)
f0103b17:	89 45 bc             	mov    %eax,-0x44(%ebp)
	while (lline >= lfile
f0103b1a:	39 c6                	cmp    %eax,%esi
f0103b1c:	7f 2a                	jg     f0103b48 <debuginfo_eip+0x1dd>
f0103b1e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
	       && stabs[lline].n_type != N_SOL
f0103b21:	0f b6 0a             	movzbl (%edx),%ecx
f0103b24:	80 f9 84             	cmp    $0x84,%cl
f0103b27:	74 49                	je     f0103b72 <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103b29:	80 f9 64             	cmp    $0x64,%cl
f0103b2c:	75 de                	jne    f0103b0c <debuginfo_eip+0x1a1>
f0103b2e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0103b31:	83 79 04 00          	cmpl   $0x0,0x4(%ecx)
f0103b35:	74 d5                	je     f0103b0c <debuginfo_eip+0x1a1>
f0103b37:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103b3a:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0103b3e:	74 3b                	je     f0103b7b <debuginfo_eip+0x210>
f0103b40:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103b43:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103b46:	eb 33                	jmp    f0103b7b <debuginfo_eip+0x210>
f0103b48:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103b4b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b4e:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103b51:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0103b56:	39 fa                	cmp    %edi,%edx
f0103b58:	0f 8d 82 00 00 00    	jge    f0103be0 <debuginfo_eip+0x275>
		for (lline = lfun + 1;
f0103b5e:	83 c2 01             	add    $0x1,%edx
f0103b61:	89 d0                	mov    %edx,%eax
f0103b63:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0103b66:	c7 c2 5c 5e 10 f0    	mov    $0xf0105e5c,%edx
f0103b6c:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0103b70:	eb 3b                	jmp    f0103bad <debuginfo_eip+0x242>
f0103b72:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103b75:	80 7d c0 00          	cmpb   $0x0,-0x40(%ebp)
f0103b79:	75 26                	jne    f0103ba1 <debuginfo_eip+0x236>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103b7b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103b7e:	c7 c0 5c 5e 10 f0    	mov    $0xf0105e5c,%eax
f0103b84:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0103b87:	c7 c0 02 f1 10 f0    	mov    $0xf010f102,%eax
f0103b8d:	81 e8 8d d0 10 f0    	sub    $0xf010d08d,%eax
f0103b93:	39 c2                	cmp    %eax,%edx
f0103b95:	73 b4                	jae    f0103b4b <debuginfo_eip+0x1e0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103b97:	81 c2 8d d0 10 f0    	add    $0xf010d08d,%edx
f0103b9d:	89 16                	mov    %edx,(%esi)
f0103b9f:	eb aa                	jmp    f0103b4b <debuginfo_eip+0x1e0>
f0103ba1:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103ba4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103ba7:	eb d2                	jmp    f0103b7b <debuginfo_eip+0x210>
			info->eip_fn_narg++;
f0103ba9:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0103bad:	39 c7                	cmp    %eax,%edi
f0103baf:	7e 2a                	jle    f0103bdb <debuginfo_eip+0x270>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103bb1:	0f b6 0a             	movzbl (%edx),%ecx
f0103bb4:	83 c0 01             	add    $0x1,%eax
f0103bb7:	83 c2 0c             	add    $0xc,%edx
f0103bba:	80 f9 a0             	cmp    $0xa0,%cl
f0103bbd:	74 ea                	je     f0103ba9 <debuginfo_eip+0x23e>
	return 0;
f0103bbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bc4:	eb 1a                	jmp    f0103be0 <debuginfo_eip+0x275>
		return -1;
f0103bc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103bcb:	eb 13                	jmp    f0103be0 <debuginfo_eip+0x275>
f0103bcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103bd2:	eb 0c                	jmp    f0103be0 <debuginfo_eip+0x275>
		return -1;
f0103bd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103bd9:	eb 05                	jmp    f0103be0 <debuginfo_eip+0x275>
	return 0;
f0103bdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103be0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103be3:	5b                   	pop    %ebx
f0103be4:	5e                   	pop    %esi
f0103be5:	5f                   	pop    %edi
f0103be6:	5d                   	pop    %ebp
f0103be7:	c3                   	ret    

f0103be8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103be8:	55                   	push   %ebp
f0103be9:	89 e5                	mov    %esp,%ebp
f0103beb:	57                   	push   %edi
f0103bec:	56                   	push   %esi
f0103bed:	53                   	push   %ebx
f0103bee:	83 ec 2c             	sub    $0x2c,%esp
f0103bf1:	e8 de fb ff ff       	call   f01037d4 <__x86.get_pc_thunk.cx>
f0103bf6:	81 c1 16 57 01 00    	add    $0x15716,%ecx
f0103bfc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103bff:	89 c7                	mov    %eax,%edi
f0103c01:	89 d6                	mov    %edx,%esi
f0103c03:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c06:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103c09:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103c0c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103c0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103c12:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103c17:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0103c1a:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0103c1d:	39 d3                	cmp    %edx,%ebx
f0103c1f:	72 09                	jb     f0103c2a <printnum+0x42>
f0103c21:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103c24:	0f 87 83 00 00 00    	ja     f0103cad <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103c2a:	83 ec 0c             	sub    $0xc,%esp
f0103c2d:	ff 75 18             	pushl  0x18(%ebp)
f0103c30:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c33:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103c36:	53                   	push   %ebx
f0103c37:	ff 75 10             	pushl  0x10(%ebp)
f0103c3a:	83 ec 08             	sub    $0x8,%esp
f0103c3d:	ff 75 dc             	pushl  -0x24(%ebp)
f0103c40:	ff 75 d8             	pushl  -0x28(%ebp)
f0103c43:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103c46:	ff 75 d0             	pushl  -0x30(%ebp)
f0103c49:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103c4c:	e8 7f 0a 00 00       	call   f01046d0 <__udivdi3>
f0103c51:	83 c4 18             	add    $0x18,%esp
f0103c54:	52                   	push   %edx
f0103c55:	50                   	push   %eax
f0103c56:	89 f2                	mov    %esi,%edx
f0103c58:	89 f8                	mov    %edi,%eax
f0103c5a:	e8 89 ff ff ff       	call   f0103be8 <printnum>
f0103c5f:	83 c4 20             	add    $0x20,%esp
f0103c62:	eb 13                	jmp    f0103c77 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103c64:	83 ec 08             	sub    $0x8,%esp
f0103c67:	56                   	push   %esi
f0103c68:	ff 75 18             	pushl  0x18(%ebp)
f0103c6b:	ff d7                	call   *%edi
f0103c6d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103c70:	83 eb 01             	sub    $0x1,%ebx
f0103c73:	85 db                	test   %ebx,%ebx
f0103c75:	7f ed                	jg     f0103c64 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103c77:	83 ec 08             	sub    $0x8,%esp
f0103c7a:	56                   	push   %esi
f0103c7b:	83 ec 04             	sub    $0x4,%esp
f0103c7e:	ff 75 dc             	pushl  -0x24(%ebp)
f0103c81:	ff 75 d8             	pushl  -0x28(%ebp)
f0103c84:	ff 75 d4             	pushl  -0x2c(%ebp)
f0103c87:	ff 75 d0             	pushl  -0x30(%ebp)
f0103c8a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103c8d:	89 f3                	mov    %esi,%ebx
f0103c8f:	e8 5c 0b 00 00       	call   f01047f0 <__umoddi3>
f0103c94:	83 c4 14             	add    $0x14,%esp
f0103c97:	0f be 84 06 5c c9 fe 	movsbl -0x136a4(%esi,%eax,1),%eax
f0103c9e:	ff 
f0103c9f:	50                   	push   %eax
f0103ca0:	ff d7                	call   *%edi
}
f0103ca2:	83 c4 10             	add    $0x10,%esp
f0103ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ca8:	5b                   	pop    %ebx
f0103ca9:	5e                   	pop    %esi
f0103caa:	5f                   	pop    %edi
f0103cab:	5d                   	pop    %ebp
f0103cac:	c3                   	ret    
f0103cad:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103cb0:	eb be                	jmp    f0103c70 <printnum+0x88>

f0103cb2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103cb2:	55                   	push   %ebp
f0103cb3:	89 e5                	mov    %esp,%ebp
f0103cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103cb8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103cbc:	8b 10                	mov    (%eax),%edx
f0103cbe:	3b 50 04             	cmp    0x4(%eax),%edx
f0103cc1:	73 0a                	jae    f0103ccd <sprintputch+0x1b>
		*b->buf++ = ch;
f0103cc3:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103cc6:	89 08                	mov    %ecx,(%eax)
f0103cc8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ccb:	88 02                	mov    %al,(%edx)
}
f0103ccd:	5d                   	pop    %ebp
f0103cce:	c3                   	ret    

f0103ccf <printfmt>:
{
f0103ccf:	55                   	push   %ebp
f0103cd0:	89 e5                	mov    %esp,%ebp
f0103cd2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0103cd5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103cd8:	50                   	push   %eax
f0103cd9:	ff 75 10             	pushl  0x10(%ebp)
f0103cdc:	ff 75 0c             	pushl  0xc(%ebp)
f0103cdf:	ff 75 08             	pushl  0x8(%ebp)
f0103ce2:	e8 05 00 00 00       	call   f0103cec <vprintfmt>
}
f0103ce7:	83 c4 10             	add    $0x10,%esp
f0103cea:	c9                   	leave  
f0103ceb:	c3                   	ret    

f0103cec <vprintfmt>:
{
f0103cec:	55                   	push   %ebp
f0103ced:	89 e5                	mov    %esp,%ebp
f0103cef:	57                   	push   %edi
f0103cf0:	56                   	push   %esi
f0103cf1:	53                   	push   %ebx
f0103cf2:	83 ec 2c             	sub    $0x2c,%esp
f0103cf5:	e8 bc c4 ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0103cfa:	81 c3 12 56 01 00    	add    $0x15612,%ebx
f0103d00:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
f0103d03:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
f0103d0a:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103d0c:	8d 77 01             	lea    0x1(%edi),%esi
f0103d0f:	0f b6 07             	movzbl (%edi),%eax
f0103d12:	83 f8 25             	cmp    $0x25,%eax
f0103d15:	74 1c                	je     f0103d33 <vprintfmt+0x47>
			if (ch == '\0')
f0103d17:	85 c0                	test   %eax,%eax
f0103d19:	0f 84 b9 04 00 00    	je     f01041d8 <.L21+0x20>
			putch(ch, putdat);
f0103d1f:	83 ec 08             	sub    $0x8,%esp
f0103d22:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
f0103d25:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
f0103d28:	50                   	push   %eax
f0103d29:	ff 55 08             	call   *0x8(%ebp)
f0103d2c:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103d2f:	89 f7                	mov    %esi,%edi
f0103d31:	eb d9                	jmp    f0103d0c <vprintfmt+0x20>
		padc = ' ';
f0103d33:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
f0103d37:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0103d3e:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0103d45:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103d4c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d51:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103d54:	8d 7e 01             	lea    0x1(%esi),%edi
f0103d57:	0f b6 16             	movzbl (%esi),%edx
f0103d5a:	8d 42 dd             	lea    -0x23(%edx),%eax
f0103d5d:	3c 55                	cmp    $0x55,%al
f0103d5f:	0f 87 53 04 00 00    	ja     f01041b8 <.L21>
f0103d65:	0f b6 c0             	movzbl %al,%eax
f0103d68:	89 d9                	mov    %ebx,%ecx
f0103d6a:	03 8c 83 e8 c9 fe ff 	add    -0x13618(%ebx,%eax,4),%ecx
f0103d71:	ff e1                	jmp    *%ecx

f0103d73 <.L73>:
f0103d73:	89 fe                	mov    %edi,%esi
			padc = '-';
f0103d75:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0103d79:	eb d9                	jmp    f0103d54 <vprintfmt+0x68>

f0103d7b <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
f0103d7b:	89 fe                	mov    %edi,%esi
			padc = '0';
f0103d7d:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0103d81:	eb d1                	jmp    f0103d54 <vprintfmt+0x68>

f0103d83 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0103d83:	0f b6 d2             	movzbl %dl,%edx
f0103d86:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
f0103d88:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d8d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
f0103d90:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103d93:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103d97:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
f0103d9a:	8d 7a d0             	lea    -0x30(%edx),%edi
f0103d9d:	83 ff 09             	cmp    $0x9,%edi
f0103da0:	0f 87 94 00 00 00    	ja     f0103e3a <.L33+0x42>
			for (precision = 0; ; ++fmt) {
f0103da6:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0103da9:	eb e5                	jmp    f0103d90 <.L28+0xd>

f0103dab <.L25>:
			precision = va_arg(ap, int);
f0103dab:	8b 45 14             	mov    0x14(%ebp),%eax
f0103dae:	8b 00                	mov    (%eax),%eax
f0103db0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103db3:	8b 45 14             	mov    0x14(%ebp),%eax
f0103db6:	8d 40 04             	lea    0x4(%eax),%eax
f0103db9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103dbc:	89 fe                	mov    %edi,%esi
			if (width < 0)
f0103dbe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103dc2:	79 90                	jns    f0103d54 <vprintfmt+0x68>
				width = precision, precision = -1;
f0103dc4:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103dc7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103dca:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0103dd1:	eb 81                	jmp    f0103d54 <vprintfmt+0x68>

f0103dd3 <.L26>:
f0103dd3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103dd6:	85 c0                	test   %eax,%eax
f0103dd8:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ddd:	0f 49 d0             	cmovns %eax,%edx
f0103de0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103de3:	89 fe                	mov    %edi,%esi
f0103de5:	e9 6a ff ff ff       	jmp    f0103d54 <vprintfmt+0x68>

f0103dea <.L22>:
f0103dea:	89 fe                	mov    %edi,%esi
			altflag = 1;
f0103dec:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103df3:	e9 5c ff ff ff       	jmp    f0103d54 <vprintfmt+0x68>

f0103df8 <.L33>:
f0103df8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0103dfb:	83 f9 01             	cmp    $0x1,%ecx
f0103dfe:	7e 16                	jle    f0103e16 <.L33+0x1e>
		return va_arg(*ap, long long);
f0103e00:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e03:	8b 00                	mov    (%eax),%eax
f0103e05:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103e08:	8d 49 08             	lea    0x8(%ecx),%ecx
f0103e0b:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
f0103e0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
f0103e11:	e9 f6 fe ff ff       	jmp    f0103d0c <vprintfmt+0x20>
	else if (lflag)
f0103e16:	85 c9                	test   %ecx,%ecx
f0103e18:	75 10                	jne    f0103e2a <.L33+0x32>
		return va_arg(*ap, int);
f0103e1a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e1d:	8b 00                	mov    (%eax),%eax
f0103e1f:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103e22:	8d 49 04             	lea    0x4(%ecx),%ecx
f0103e25:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103e28:	eb e4                	jmp    f0103e0e <.L33+0x16>
		return va_arg(*ap, long);
f0103e2a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e2d:	8b 00                	mov    (%eax),%eax
f0103e2f:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103e32:	8d 49 04             	lea    0x4(%ecx),%ecx
f0103e35:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103e38:	eb d4                	jmp    f0103e0e <.L33+0x16>
f0103e3a:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103e3d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103e40:	e9 79 ff ff ff       	jmp    f0103dbe <.L25+0x13>

f0103e45 <.L32>:
			lflag++;
f0103e45:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103e49:	89 fe                	mov    %edi,%esi
			goto reswitch;
f0103e4b:	e9 04 ff ff ff       	jmp    f0103d54 <vprintfmt+0x68>

f0103e50 <.L29>:
			putch(va_arg(ap, int), putdat);
f0103e50:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e53:	8d 70 04             	lea    0x4(%eax),%esi
f0103e56:	83 ec 08             	sub    $0x8,%esp
f0103e59:	ff 75 0c             	pushl  0xc(%ebp)
f0103e5c:	ff 30                	pushl  (%eax)
f0103e5e:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103e61:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0103e64:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
f0103e67:	e9 a0 fe ff ff       	jmp    f0103d0c <vprintfmt+0x20>

f0103e6c <.L31>:
			err = va_arg(ap, int);
f0103e6c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e6f:	8d 70 04             	lea    0x4(%eax),%esi
f0103e72:	8b 00                	mov    (%eax),%eax
f0103e74:	99                   	cltd   
f0103e75:	31 d0                	xor    %edx,%eax
f0103e77:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103e79:	83 f8 06             	cmp    $0x6,%eax
f0103e7c:	7f 29                	jg     f0103ea7 <.L31+0x3b>
f0103e7e:	8b 94 83 68 1d 00 00 	mov    0x1d68(%ebx,%eax,4),%edx
f0103e85:	85 d2                	test   %edx,%edx
f0103e87:	74 1e                	je     f0103ea7 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
f0103e89:	52                   	push   %edx
f0103e8a:	8d 83 24 b9 fe ff    	lea    -0x146dc(%ebx),%eax
f0103e90:	50                   	push   %eax
f0103e91:	ff 75 0c             	pushl  0xc(%ebp)
f0103e94:	ff 75 08             	pushl  0x8(%ebp)
f0103e97:	e8 33 fe ff ff       	call   f0103ccf <printfmt>
f0103e9c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103e9f:	89 75 14             	mov    %esi,0x14(%ebp)
f0103ea2:	e9 65 fe ff ff       	jmp    f0103d0c <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
f0103ea7:	50                   	push   %eax
f0103ea8:	8d 83 74 c9 fe ff    	lea    -0x1368c(%ebx),%eax
f0103eae:	50                   	push   %eax
f0103eaf:	ff 75 0c             	pushl  0xc(%ebp)
f0103eb2:	ff 75 08             	pushl  0x8(%ebp)
f0103eb5:	e8 15 fe ff ff       	call   f0103ccf <printfmt>
f0103eba:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103ebd:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103ec0:	e9 47 fe ff ff       	jmp    f0103d0c <vprintfmt+0x20>

f0103ec5 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0103ec5:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ec8:	83 c0 04             	add    $0x4,%eax
f0103ecb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103ece:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ed1:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0103ed3:	85 f6                	test   %esi,%esi
f0103ed5:	8d 83 6d c9 fe ff    	lea    -0x13693(%ebx),%eax
f0103edb:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0103ede:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103ee2:	0f 8e b4 00 00 00    	jle    f0103f9c <.L36+0xd7>
f0103ee8:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0103eec:	75 08                	jne    f0103ef6 <.L36+0x31>
f0103eee:	89 7d 10             	mov    %edi,0x10(%ebp)
f0103ef1:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103ef4:	eb 6c                	jmp    f0103f62 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103ef6:	83 ec 08             	sub    $0x8,%esp
f0103ef9:	ff 75 cc             	pushl  -0x34(%ebp)
f0103efc:	56                   	push   %esi
f0103efd:	e8 6c 04 00 00       	call   f010436e <strnlen>
f0103f02:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103f05:	29 c2                	sub    %eax,%edx
f0103f07:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0103f0a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103f0d:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
f0103f11:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0103f14:	89 d6                	mov    %edx,%esi
f0103f16:	89 7d 10             	mov    %edi,0x10(%ebp)
f0103f19:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f1b:	eb 10                	jmp    f0103f2d <.L36+0x68>
					putch(padc, putdat);
f0103f1d:	83 ec 08             	sub    $0x8,%esp
f0103f20:	ff 75 0c             	pushl  0xc(%ebp)
f0103f23:	57                   	push   %edi
f0103f24:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0103f27:	83 ee 01             	sub    $0x1,%esi
f0103f2a:	83 c4 10             	add    $0x10,%esp
f0103f2d:	85 f6                	test   %esi,%esi
f0103f2f:	7f ec                	jg     f0103f1d <.L36+0x58>
f0103f31:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103f34:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103f37:	85 d2                	test   %edx,%edx
f0103f39:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f3e:	0f 49 c2             	cmovns %edx,%eax
f0103f41:	29 c2                	sub    %eax,%edx
f0103f43:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0103f46:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103f49:	eb 17                	jmp    f0103f62 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
f0103f4b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103f4f:	75 30                	jne    f0103f81 <.L36+0xbc>
					putch(ch, putdat);
f0103f51:	83 ec 08             	sub    $0x8,%esp
f0103f54:	ff 75 0c             	pushl  0xc(%ebp)
f0103f57:	50                   	push   %eax
f0103f58:	ff 55 08             	call   *0x8(%ebp)
f0103f5b:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103f5e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0103f62:	83 c6 01             	add    $0x1,%esi
f0103f65:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0103f69:	0f be c2             	movsbl %dl,%eax
f0103f6c:	85 c0                	test   %eax,%eax
f0103f6e:	74 58                	je     f0103fc8 <.L36+0x103>
f0103f70:	85 ff                	test   %edi,%edi
f0103f72:	78 d7                	js     f0103f4b <.L36+0x86>
f0103f74:	83 ef 01             	sub    $0x1,%edi
f0103f77:	79 d2                	jns    f0103f4b <.L36+0x86>
f0103f79:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103f7c:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103f7f:	eb 32                	jmp    f0103fb3 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
f0103f81:	0f be d2             	movsbl %dl,%edx
f0103f84:	83 ea 20             	sub    $0x20,%edx
f0103f87:	83 fa 5e             	cmp    $0x5e,%edx
f0103f8a:	76 c5                	jbe    f0103f51 <.L36+0x8c>
					putch('?', putdat);
f0103f8c:	83 ec 08             	sub    $0x8,%esp
f0103f8f:	ff 75 0c             	pushl  0xc(%ebp)
f0103f92:	6a 3f                	push   $0x3f
f0103f94:	ff 55 08             	call   *0x8(%ebp)
f0103f97:	83 c4 10             	add    $0x10,%esp
f0103f9a:	eb c2                	jmp    f0103f5e <.L36+0x99>
f0103f9c:	89 7d 10             	mov    %edi,0x10(%ebp)
f0103f9f:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103fa2:	eb be                	jmp    f0103f62 <.L36+0x9d>
				putch(' ', putdat);
f0103fa4:	83 ec 08             	sub    $0x8,%esp
f0103fa7:	57                   	push   %edi
f0103fa8:	6a 20                	push   $0x20
f0103faa:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0103fad:	83 ee 01             	sub    $0x1,%esi
f0103fb0:	83 c4 10             	add    $0x10,%esp
f0103fb3:	85 f6                	test   %esi,%esi
f0103fb5:	7f ed                	jg     f0103fa4 <.L36+0xdf>
f0103fb7:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0103fba:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
f0103fbd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103fc0:	89 45 14             	mov    %eax,0x14(%ebp)
f0103fc3:	e9 44 fd ff ff       	jmp    f0103d0c <vprintfmt+0x20>
f0103fc8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103fcb:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103fce:	eb e3                	jmp    f0103fb3 <.L36+0xee>

f0103fd0 <.L30>:
f0103fd0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0103fd3:	83 f9 01             	cmp    $0x1,%ecx
f0103fd6:	7e 42                	jle    f010401a <.L30+0x4a>
		return va_arg(*ap, long long);
f0103fd8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fdb:	8b 50 04             	mov    0x4(%eax),%edx
f0103fde:	8b 00                	mov    (%eax),%eax
f0103fe0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103fe3:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103fe6:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fe9:	8d 40 08             	lea    0x8(%eax),%eax
f0103fec:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103fef:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103ff3:	79 5f                	jns    f0104054 <.L30+0x84>
				putch('-', putdat);
f0103ff5:	83 ec 08             	sub    $0x8,%esp
f0103ff8:	ff 75 0c             	pushl  0xc(%ebp)
f0103ffb:	6a 2d                	push   $0x2d
f0103ffd:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104000:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104003:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104006:	f7 da                	neg    %edx
f0104008:	83 d1 00             	adc    $0x0,%ecx
f010400b:	f7 d9                	neg    %ecx
f010400d:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104010:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104015:	e9 b8 00 00 00       	jmp    f01040d2 <.L34+0x22>
	else if (lflag)
f010401a:	85 c9                	test   %ecx,%ecx
f010401c:	75 1b                	jne    f0104039 <.L30+0x69>
		return va_arg(*ap, int);
f010401e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104021:	8b 30                	mov    (%eax),%esi
f0104023:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0104026:	89 f0                	mov    %esi,%eax
f0104028:	c1 f8 1f             	sar    $0x1f,%eax
f010402b:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010402e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104031:	8d 40 04             	lea    0x4(%eax),%eax
f0104034:	89 45 14             	mov    %eax,0x14(%ebp)
f0104037:	eb b6                	jmp    f0103fef <.L30+0x1f>
		return va_arg(*ap, long);
f0104039:	8b 45 14             	mov    0x14(%ebp),%eax
f010403c:	8b 30                	mov    (%eax),%esi
f010403e:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0104041:	89 f0                	mov    %esi,%eax
f0104043:	c1 f8 1f             	sar    $0x1f,%eax
f0104046:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104049:	8b 45 14             	mov    0x14(%ebp),%eax
f010404c:	8d 40 04             	lea    0x4(%eax),%eax
f010404f:	89 45 14             	mov    %eax,0x14(%ebp)
f0104052:	eb 9b                	jmp    f0103fef <.L30+0x1f>
			num = getint(&ap, lflag);
f0104054:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104057:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010405a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010405f:	eb 71                	jmp    f01040d2 <.L34+0x22>

f0104061 <.L37>:
f0104061:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0104064:	83 f9 01             	cmp    $0x1,%ecx
f0104067:	7e 15                	jle    f010407e <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
f0104069:	8b 45 14             	mov    0x14(%ebp),%eax
f010406c:	8b 10                	mov    (%eax),%edx
f010406e:	8b 48 04             	mov    0x4(%eax),%ecx
f0104071:	8d 40 08             	lea    0x8(%eax),%eax
f0104074:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104077:	b8 0a 00 00 00       	mov    $0xa,%eax
f010407c:	eb 54                	jmp    f01040d2 <.L34+0x22>
	else if (lflag)
f010407e:	85 c9                	test   %ecx,%ecx
f0104080:	75 17                	jne    f0104099 <.L37+0x38>
		return va_arg(*ap, unsigned int);
f0104082:	8b 45 14             	mov    0x14(%ebp),%eax
f0104085:	8b 10                	mov    (%eax),%edx
f0104087:	b9 00 00 00 00       	mov    $0x0,%ecx
f010408c:	8d 40 04             	lea    0x4(%eax),%eax
f010408f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104092:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104097:	eb 39                	jmp    f01040d2 <.L34+0x22>
		return va_arg(*ap, unsigned long);
f0104099:	8b 45 14             	mov    0x14(%ebp),%eax
f010409c:	8b 10                	mov    (%eax),%edx
f010409e:	b9 00 00 00 00       	mov    $0x0,%ecx
f01040a3:	8d 40 04             	lea    0x4(%eax),%eax
f01040a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01040a9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01040ae:	eb 22                	jmp    f01040d2 <.L34+0x22>

f01040b0 <.L34>:
f01040b0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f01040b3:	83 f9 01             	cmp    $0x1,%ecx
f01040b6:	7e 3b                	jle    f01040f3 <.L34+0x43>
		return va_arg(*ap, long long);
f01040b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01040bb:	8b 50 04             	mov    0x4(%eax),%edx
f01040be:	8b 00                	mov    (%eax),%eax
f01040c0:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01040c3:	8d 49 08             	lea    0x8(%ecx),%ecx
f01040c6:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
f01040c9:	89 d1                	mov    %edx,%ecx
f01040cb:	89 c2                	mov    %eax,%edx
			base = 8;
f01040cd:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
f01040d2:	83 ec 0c             	sub    $0xc,%esp
f01040d5:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
f01040d9:	56                   	push   %esi
f01040da:	ff 75 e0             	pushl  -0x20(%ebp)
f01040dd:	50                   	push   %eax
f01040de:	51                   	push   %ecx
f01040df:	52                   	push   %edx
f01040e0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01040e6:	e8 fd fa ff ff       	call   f0103be8 <printnum>
			break;
f01040eb:	83 c4 20             	add    $0x20,%esp
f01040ee:	e9 19 fc ff ff       	jmp    f0103d0c <vprintfmt+0x20>
	else if (lflag)
f01040f3:	85 c9                	test   %ecx,%ecx
f01040f5:	75 13                	jne    f010410a <.L34+0x5a>
		return va_arg(*ap, int);
f01040f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01040fa:	8b 10                	mov    (%eax),%edx
f01040fc:	89 d0                	mov    %edx,%eax
f01040fe:	99                   	cltd   
f01040ff:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104102:	8d 49 04             	lea    0x4(%ecx),%ecx
f0104105:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104108:	eb bf                	jmp    f01040c9 <.L34+0x19>
		return va_arg(*ap, long);
f010410a:	8b 45 14             	mov    0x14(%ebp),%eax
f010410d:	8b 10                	mov    (%eax),%edx
f010410f:	89 d0                	mov    %edx,%eax
f0104111:	99                   	cltd   
f0104112:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104115:	8d 49 04             	lea    0x4(%ecx),%ecx
f0104118:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010411b:	eb ac                	jmp    f01040c9 <.L34+0x19>

f010411d <.L35>:
			putch('0', putdat);
f010411d:	83 ec 08             	sub    $0x8,%esp
f0104120:	ff 75 0c             	pushl  0xc(%ebp)
f0104123:	6a 30                	push   $0x30
f0104125:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104128:	83 c4 08             	add    $0x8,%esp
f010412b:	ff 75 0c             	pushl  0xc(%ebp)
f010412e:	6a 78                	push   $0x78
f0104130:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0104133:	8b 45 14             	mov    0x14(%ebp),%eax
f0104136:	8b 10                	mov    (%eax),%edx
f0104138:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010413d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104140:	8d 40 04             	lea    0x4(%eax),%eax
f0104143:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104146:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010414b:	eb 85                	jmp    f01040d2 <.L34+0x22>

f010414d <.L38>:
f010414d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0104150:	83 f9 01             	cmp    $0x1,%ecx
f0104153:	7e 18                	jle    f010416d <.L38+0x20>
		return va_arg(*ap, unsigned long long);
f0104155:	8b 45 14             	mov    0x14(%ebp),%eax
f0104158:	8b 10                	mov    (%eax),%edx
f010415a:	8b 48 04             	mov    0x4(%eax),%ecx
f010415d:	8d 40 08             	lea    0x8(%eax),%eax
f0104160:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104163:	b8 10 00 00 00       	mov    $0x10,%eax
f0104168:	e9 65 ff ff ff       	jmp    f01040d2 <.L34+0x22>
	else if (lflag)
f010416d:	85 c9                	test   %ecx,%ecx
f010416f:	75 1a                	jne    f010418b <.L38+0x3e>
		return va_arg(*ap, unsigned int);
f0104171:	8b 45 14             	mov    0x14(%ebp),%eax
f0104174:	8b 10                	mov    (%eax),%edx
f0104176:	b9 00 00 00 00       	mov    $0x0,%ecx
f010417b:	8d 40 04             	lea    0x4(%eax),%eax
f010417e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104181:	b8 10 00 00 00       	mov    $0x10,%eax
f0104186:	e9 47 ff ff ff       	jmp    f01040d2 <.L34+0x22>
		return va_arg(*ap, unsigned long);
f010418b:	8b 45 14             	mov    0x14(%ebp),%eax
f010418e:	8b 10                	mov    (%eax),%edx
f0104190:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104195:	8d 40 04             	lea    0x4(%eax),%eax
f0104198:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010419b:	b8 10 00 00 00       	mov    $0x10,%eax
f01041a0:	e9 2d ff ff ff       	jmp    f01040d2 <.L34+0x22>

f01041a5 <.L24>:
			putch(ch, putdat);
f01041a5:	83 ec 08             	sub    $0x8,%esp
f01041a8:	ff 75 0c             	pushl  0xc(%ebp)
f01041ab:	6a 25                	push   $0x25
f01041ad:	ff 55 08             	call   *0x8(%ebp)
			break;
f01041b0:	83 c4 10             	add    $0x10,%esp
f01041b3:	e9 54 fb ff ff       	jmp    f0103d0c <vprintfmt+0x20>

f01041b8 <.L21>:
			putch('%', putdat);
f01041b8:	83 ec 08             	sub    $0x8,%esp
f01041bb:	ff 75 0c             	pushl  0xc(%ebp)
f01041be:	6a 25                	push   $0x25
f01041c0:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01041c3:	83 c4 10             	add    $0x10,%esp
f01041c6:	89 f7                	mov    %esi,%edi
f01041c8:	eb 03                	jmp    f01041cd <.L21+0x15>
f01041ca:	83 ef 01             	sub    $0x1,%edi
f01041cd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01041d1:	75 f7                	jne    f01041ca <.L21+0x12>
f01041d3:	e9 34 fb ff ff       	jmp    f0103d0c <vprintfmt+0x20>
}
f01041d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041db:	5b                   	pop    %ebx
f01041dc:	5e                   	pop    %esi
f01041dd:	5f                   	pop    %edi
f01041de:	5d                   	pop    %ebp
f01041df:	c3                   	ret    

f01041e0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01041e0:	55                   	push   %ebp
f01041e1:	89 e5                	mov    %esp,%ebp
f01041e3:	53                   	push   %ebx
f01041e4:	83 ec 14             	sub    $0x14,%esp
f01041e7:	e8 ca bf ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f01041ec:	81 c3 20 51 01 00    	add    $0x15120,%ebx
f01041f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01041f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01041f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01041fb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01041ff:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104202:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104209:	85 c0                	test   %eax,%eax
f010420b:	74 2b                	je     f0104238 <vsnprintf+0x58>
f010420d:	85 d2                	test   %edx,%edx
f010420f:	7e 27                	jle    f0104238 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104211:	ff 75 14             	pushl  0x14(%ebp)
f0104214:	ff 75 10             	pushl  0x10(%ebp)
f0104217:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010421a:	50                   	push   %eax
f010421b:	8d 83 a6 a9 fe ff    	lea    -0x1565a(%ebx),%eax
f0104221:	50                   	push   %eax
f0104222:	e8 c5 fa ff ff       	call   f0103cec <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104227:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010422a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010422d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104230:	83 c4 10             	add    $0x10,%esp
}
f0104233:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104236:	c9                   	leave  
f0104237:	c3                   	ret    
		return -E_INVAL;
f0104238:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010423d:	eb f4                	jmp    f0104233 <vsnprintf+0x53>

f010423f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010423f:	55                   	push   %ebp
f0104240:	89 e5                	mov    %esp,%ebp
f0104242:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104245:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104248:	50                   	push   %eax
f0104249:	ff 75 10             	pushl  0x10(%ebp)
f010424c:	ff 75 0c             	pushl  0xc(%ebp)
f010424f:	ff 75 08             	pushl  0x8(%ebp)
f0104252:	e8 89 ff ff ff       	call   f01041e0 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104257:	c9                   	leave  
f0104258:	c3                   	ret    

f0104259 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104259:	55                   	push   %ebp
f010425a:	89 e5                	mov    %esp,%ebp
f010425c:	57                   	push   %edi
f010425d:	56                   	push   %esi
f010425e:	53                   	push   %ebx
f010425f:	83 ec 1c             	sub    $0x1c,%esp
f0104262:	e8 4f bf ff ff       	call   f01001b6 <__x86.get_pc_thunk.bx>
f0104267:	81 c3 a5 50 01 00    	add    $0x150a5,%ebx
f010426d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104270:	85 c0                	test   %eax,%eax
f0104272:	74 13                	je     f0104287 <readline+0x2e>
		cprintf("%s", prompt);
f0104274:	83 ec 08             	sub    $0x8,%esp
f0104277:	50                   	push   %eax
f0104278:	8d 83 24 b9 fe ff    	lea    -0x146dc(%ebx),%eax
f010427e:	50                   	push   %eax
f010427f:	e8 e3 f5 ff ff       	call   f0103867 <cprintf>
f0104284:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104287:	83 ec 0c             	sub    $0xc,%esp
f010428a:	6a 00                	push   $0x0
f010428c:	e8 bd c4 ff ff       	call   f010074e <iscons>
f0104291:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104294:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104297:	bf 00 00 00 00       	mov    $0x0,%edi
f010429c:	eb 46                	jmp    f01042e4 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010429e:	83 ec 08             	sub    $0x8,%esp
f01042a1:	50                   	push   %eax
f01042a2:	8d 83 40 cb fe ff    	lea    -0x134c0(%ebx),%eax
f01042a8:	50                   	push   %eax
f01042a9:	e8 b9 f5 ff ff       	call   f0103867 <cprintf>
			return NULL;
f01042ae:	83 c4 10             	add    $0x10,%esp
f01042b1:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01042b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01042b9:	5b                   	pop    %ebx
f01042ba:	5e                   	pop    %esi
f01042bb:	5f                   	pop    %edi
f01042bc:	5d                   	pop    %ebp
f01042bd:	c3                   	ret    
			if (echoing)
f01042be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01042c2:	75 05                	jne    f01042c9 <readline+0x70>
			i--;
f01042c4:	83 ef 01             	sub    $0x1,%edi
f01042c7:	eb 1b                	jmp    f01042e4 <readline+0x8b>
				cputchar('\b');
f01042c9:	83 ec 0c             	sub    $0xc,%esp
f01042cc:	6a 08                	push   $0x8
f01042ce:	e8 5a c4 ff ff       	call   f010072d <cputchar>
f01042d3:	83 c4 10             	add    $0x10,%esp
f01042d6:	eb ec                	jmp    f01042c4 <readline+0x6b>
			buf[i++] = c;
f01042d8:	89 f0                	mov    %esi,%eax
f01042da:	88 84 3b d4 1f 00 00 	mov    %al,0x1fd4(%ebx,%edi,1)
f01042e1:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01042e4:	e8 54 c4 ff ff       	call   f010073d <getchar>
f01042e9:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01042eb:	85 c0                	test   %eax,%eax
f01042ed:	78 af                	js     f010429e <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01042ef:	83 f8 08             	cmp    $0x8,%eax
f01042f2:	0f 94 c2             	sete   %dl
f01042f5:	83 f8 7f             	cmp    $0x7f,%eax
f01042f8:	0f 94 c0             	sete   %al
f01042fb:	08 c2                	or     %al,%dl
f01042fd:	74 04                	je     f0104303 <readline+0xaa>
f01042ff:	85 ff                	test   %edi,%edi
f0104301:	7f bb                	jg     f01042be <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104303:	83 fe 1f             	cmp    $0x1f,%esi
f0104306:	7e 1c                	jle    f0104324 <readline+0xcb>
f0104308:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f010430e:	7f 14                	jg     f0104324 <readline+0xcb>
			if (echoing)
f0104310:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104314:	74 c2                	je     f01042d8 <readline+0x7f>
				cputchar(c);
f0104316:	83 ec 0c             	sub    $0xc,%esp
f0104319:	56                   	push   %esi
f010431a:	e8 0e c4 ff ff       	call   f010072d <cputchar>
f010431f:	83 c4 10             	add    $0x10,%esp
f0104322:	eb b4                	jmp    f01042d8 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0104324:	83 fe 0a             	cmp    $0xa,%esi
f0104327:	74 05                	je     f010432e <readline+0xd5>
f0104329:	83 fe 0d             	cmp    $0xd,%esi
f010432c:	75 b6                	jne    f01042e4 <readline+0x8b>
			if (echoing)
f010432e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104332:	75 13                	jne    f0104347 <readline+0xee>
			buf[i] = 0;
f0104334:	c6 84 3b d4 1f 00 00 	movb   $0x0,0x1fd4(%ebx,%edi,1)
f010433b:	00 
			return buf;
f010433c:	8d 83 d4 1f 00 00    	lea    0x1fd4(%ebx),%eax
f0104342:	e9 6f ff ff ff       	jmp    f01042b6 <readline+0x5d>
				cputchar('\n');
f0104347:	83 ec 0c             	sub    $0xc,%esp
f010434a:	6a 0a                	push   $0xa
f010434c:	e8 dc c3 ff ff       	call   f010072d <cputchar>
f0104351:	83 c4 10             	add    $0x10,%esp
f0104354:	eb de                	jmp    f0104334 <readline+0xdb>

f0104356 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104356:	55                   	push   %ebp
f0104357:	89 e5                	mov    %esp,%ebp
f0104359:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010435c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104361:	eb 03                	jmp    f0104366 <strlen+0x10>
		n++;
f0104363:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104366:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010436a:	75 f7                	jne    f0104363 <strlen+0xd>
	return n;
}
f010436c:	5d                   	pop    %ebp
f010436d:	c3                   	ret    

f010436e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010436e:	55                   	push   %ebp
f010436f:	89 e5                	mov    %esp,%ebp
f0104371:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104374:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104377:	b8 00 00 00 00       	mov    $0x0,%eax
f010437c:	eb 03                	jmp    f0104381 <strnlen+0x13>
		n++;
f010437e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104381:	39 d0                	cmp    %edx,%eax
f0104383:	74 06                	je     f010438b <strnlen+0x1d>
f0104385:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104389:	75 f3                	jne    f010437e <strnlen+0x10>
	return n;
}
f010438b:	5d                   	pop    %ebp
f010438c:	c3                   	ret    

f010438d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010438d:	55                   	push   %ebp
f010438e:	89 e5                	mov    %esp,%ebp
f0104390:	53                   	push   %ebx
f0104391:	8b 45 08             	mov    0x8(%ebp),%eax
f0104394:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104397:	89 c2                	mov    %eax,%edx
f0104399:	83 c1 01             	add    $0x1,%ecx
f010439c:	83 c2 01             	add    $0x1,%edx
f010439f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01043a3:	88 5a ff             	mov    %bl,-0x1(%edx)
f01043a6:	84 db                	test   %bl,%bl
f01043a8:	75 ef                	jne    f0104399 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01043aa:	5b                   	pop    %ebx
f01043ab:	5d                   	pop    %ebp
f01043ac:	c3                   	ret    

f01043ad <strcat>:

char *
strcat(char *dst, const char *src)
{
f01043ad:	55                   	push   %ebp
f01043ae:	89 e5                	mov    %esp,%ebp
f01043b0:	53                   	push   %ebx
f01043b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01043b4:	53                   	push   %ebx
f01043b5:	e8 9c ff ff ff       	call   f0104356 <strlen>
f01043ba:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01043bd:	ff 75 0c             	pushl  0xc(%ebp)
f01043c0:	01 d8                	add    %ebx,%eax
f01043c2:	50                   	push   %eax
f01043c3:	e8 c5 ff ff ff       	call   f010438d <strcpy>
	return dst;
}
f01043c8:	89 d8                	mov    %ebx,%eax
f01043ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01043cd:	c9                   	leave  
f01043ce:	c3                   	ret    

f01043cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01043cf:	55                   	push   %ebp
f01043d0:	89 e5                	mov    %esp,%ebp
f01043d2:	56                   	push   %esi
f01043d3:	53                   	push   %ebx
f01043d4:	8b 75 08             	mov    0x8(%ebp),%esi
f01043d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01043da:	89 f3                	mov    %esi,%ebx
f01043dc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01043df:	89 f2                	mov    %esi,%edx
f01043e1:	eb 0f                	jmp    f01043f2 <strncpy+0x23>
		*dst++ = *src;
f01043e3:	83 c2 01             	add    $0x1,%edx
f01043e6:	0f b6 01             	movzbl (%ecx),%eax
f01043e9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01043ec:	80 39 01             	cmpb   $0x1,(%ecx)
f01043ef:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f01043f2:	39 da                	cmp    %ebx,%edx
f01043f4:	75 ed                	jne    f01043e3 <strncpy+0x14>
	}
	return ret;
}
f01043f6:	89 f0                	mov    %esi,%eax
f01043f8:	5b                   	pop    %ebx
f01043f9:	5e                   	pop    %esi
f01043fa:	5d                   	pop    %ebp
f01043fb:	c3                   	ret    

f01043fc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01043fc:	55                   	push   %ebp
f01043fd:	89 e5                	mov    %esp,%ebp
f01043ff:	56                   	push   %esi
f0104400:	53                   	push   %ebx
f0104401:	8b 75 08             	mov    0x8(%ebp),%esi
f0104404:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104407:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010440a:	89 f0                	mov    %esi,%eax
f010440c:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104410:	85 c9                	test   %ecx,%ecx
f0104412:	75 0b                	jne    f010441f <strlcpy+0x23>
f0104414:	eb 17                	jmp    f010442d <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104416:	83 c2 01             	add    $0x1,%edx
f0104419:	83 c0 01             	add    $0x1,%eax
f010441c:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010441f:	39 d8                	cmp    %ebx,%eax
f0104421:	74 07                	je     f010442a <strlcpy+0x2e>
f0104423:	0f b6 0a             	movzbl (%edx),%ecx
f0104426:	84 c9                	test   %cl,%cl
f0104428:	75 ec                	jne    f0104416 <strlcpy+0x1a>
		*dst = '\0';
f010442a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010442d:	29 f0                	sub    %esi,%eax
}
f010442f:	5b                   	pop    %ebx
f0104430:	5e                   	pop    %esi
f0104431:	5d                   	pop    %ebp
f0104432:	c3                   	ret    

f0104433 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104433:	55                   	push   %ebp
f0104434:	89 e5                	mov    %esp,%ebp
f0104436:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104439:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010443c:	eb 06                	jmp    f0104444 <strcmp+0x11>
		p++, q++;
f010443e:	83 c1 01             	add    $0x1,%ecx
f0104441:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0104444:	0f b6 01             	movzbl (%ecx),%eax
f0104447:	84 c0                	test   %al,%al
f0104449:	74 04                	je     f010444f <strcmp+0x1c>
f010444b:	3a 02                	cmp    (%edx),%al
f010444d:	74 ef                	je     f010443e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010444f:	0f b6 c0             	movzbl %al,%eax
f0104452:	0f b6 12             	movzbl (%edx),%edx
f0104455:	29 d0                	sub    %edx,%eax
}
f0104457:	5d                   	pop    %ebp
f0104458:	c3                   	ret    

f0104459 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104459:	55                   	push   %ebp
f010445a:	89 e5                	mov    %esp,%ebp
f010445c:	53                   	push   %ebx
f010445d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104460:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104463:	89 c3                	mov    %eax,%ebx
f0104465:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104468:	eb 06                	jmp    f0104470 <strncmp+0x17>
		n--, p++, q++;
f010446a:	83 c0 01             	add    $0x1,%eax
f010446d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104470:	39 d8                	cmp    %ebx,%eax
f0104472:	74 16                	je     f010448a <strncmp+0x31>
f0104474:	0f b6 08             	movzbl (%eax),%ecx
f0104477:	84 c9                	test   %cl,%cl
f0104479:	74 04                	je     f010447f <strncmp+0x26>
f010447b:	3a 0a                	cmp    (%edx),%cl
f010447d:	74 eb                	je     f010446a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010447f:	0f b6 00             	movzbl (%eax),%eax
f0104482:	0f b6 12             	movzbl (%edx),%edx
f0104485:	29 d0                	sub    %edx,%eax
}
f0104487:	5b                   	pop    %ebx
f0104488:	5d                   	pop    %ebp
f0104489:	c3                   	ret    
		return 0;
f010448a:	b8 00 00 00 00       	mov    $0x0,%eax
f010448f:	eb f6                	jmp    f0104487 <strncmp+0x2e>

f0104491 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104491:	55                   	push   %ebp
f0104492:	89 e5                	mov    %esp,%ebp
f0104494:	8b 45 08             	mov    0x8(%ebp),%eax
f0104497:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010449b:	0f b6 10             	movzbl (%eax),%edx
f010449e:	84 d2                	test   %dl,%dl
f01044a0:	74 09                	je     f01044ab <strchr+0x1a>
		if (*s == c)
f01044a2:	38 ca                	cmp    %cl,%dl
f01044a4:	74 0a                	je     f01044b0 <strchr+0x1f>
	for (; *s; s++)
f01044a6:	83 c0 01             	add    $0x1,%eax
f01044a9:	eb f0                	jmp    f010449b <strchr+0xa>
			return (char *) s;
	return 0;
f01044ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01044b0:	5d                   	pop    %ebp
f01044b1:	c3                   	ret    

f01044b2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01044b2:	55                   	push   %ebp
f01044b3:	89 e5                	mov    %esp,%ebp
f01044b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01044b8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01044bc:	eb 03                	jmp    f01044c1 <strfind+0xf>
f01044be:	83 c0 01             	add    $0x1,%eax
f01044c1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01044c4:	38 ca                	cmp    %cl,%dl
f01044c6:	74 04                	je     f01044cc <strfind+0x1a>
f01044c8:	84 d2                	test   %dl,%dl
f01044ca:	75 f2                	jne    f01044be <strfind+0xc>
			break;
	return (char *) s;
}
f01044cc:	5d                   	pop    %ebp
f01044cd:	c3                   	ret    

f01044ce <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01044ce:	55                   	push   %ebp
f01044cf:	89 e5                	mov    %esp,%ebp
f01044d1:	57                   	push   %edi
f01044d2:	56                   	push   %esi
f01044d3:	53                   	push   %ebx
f01044d4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01044d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01044da:	85 c9                	test   %ecx,%ecx
f01044dc:	74 13                	je     f01044f1 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01044de:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01044e4:	75 05                	jne    f01044eb <memset+0x1d>
f01044e6:	f6 c1 03             	test   $0x3,%cl
f01044e9:	74 0d                	je     f01044f8 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01044eb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01044ee:	fc                   	cld    
f01044ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01044f1:	89 f8                	mov    %edi,%eax
f01044f3:	5b                   	pop    %ebx
f01044f4:	5e                   	pop    %esi
f01044f5:	5f                   	pop    %edi
f01044f6:	5d                   	pop    %ebp
f01044f7:	c3                   	ret    
		c &= 0xFF;
f01044f8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01044fc:	89 d3                	mov    %edx,%ebx
f01044fe:	c1 e3 08             	shl    $0x8,%ebx
f0104501:	89 d0                	mov    %edx,%eax
f0104503:	c1 e0 18             	shl    $0x18,%eax
f0104506:	89 d6                	mov    %edx,%esi
f0104508:	c1 e6 10             	shl    $0x10,%esi
f010450b:	09 f0                	or     %esi,%eax
f010450d:	09 c2                	or     %eax,%edx
f010450f:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0104511:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104514:	89 d0                	mov    %edx,%eax
f0104516:	fc                   	cld    
f0104517:	f3 ab                	rep stos %eax,%es:(%edi)
f0104519:	eb d6                	jmp    f01044f1 <memset+0x23>

f010451b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010451b:	55                   	push   %ebp
f010451c:	89 e5                	mov    %esp,%ebp
f010451e:	57                   	push   %edi
f010451f:	56                   	push   %esi
f0104520:	8b 45 08             	mov    0x8(%ebp),%eax
f0104523:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104526:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104529:	39 c6                	cmp    %eax,%esi
f010452b:	73 35                	jae    f0104562 <memmove+0x47>
f010452d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104530:	39 c2                	cmp    %eax,%edx
f0104532:	76 2e                	jbe    f0104562 <memmove+0x47>
		s += n;
		d += n;
f0104534:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104537:	89 d6                	mov    %edx,%esi
f0104539:	09 fe                	or     %edi,%esi
f010453b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104541:	74 0c                	je     f010454f <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104543:	83 ef 01             	sub    $0x1,%edi
f0104546:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104549:	fd                   	std    
f010454a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010454c:	fc                   	cld    
f010454d:	eb 21                	jmp    f0104570 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010454f:	f6 c1 03             	test   $0x3,%cl
f0104552:	75 ef                	jne    f0104543 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104554:	83 ef 04             	sub    $0x4,%edi
f0104557:	8d 72 fc             	lea    -0x4(%edx),%esi
f010455a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010455d:	fd                   	std    
f010455e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104560:	eb ea                	jmp    f010454c <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104562:	89 f2                	mov    %esi,%edx
f0104564:	09 c2                	or     %eax,%edx
f0104566:	f6 c2 03             	test   $0x3,%dl
f0104569:	74 09                	je     f0104574 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010456b:	89 c7                	mov    %eax,%edi
f010456d:	fc                   	cld    
f010456e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104570:	5e                   	pop    %esi
f0104571:	5f                   	pop    %edi
f0104572:	5d                   	pop    %ebp
f0104573:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104574:	f6 c1 03             	test   $0x3,%cl
f0104577:	75 f2                	jne    f010456b <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104579:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010457c:	89 c7                	mov    %eax,%edi
f010457e:	fc                   	cld    
f010457f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104581:	eb ed                	jmp    f0104570 <memmove+0x55>

f0104583 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104583:	55                   	push   %ebp
f0104584:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104586:	ff 75 10             	pushl  0x10(%ebp)
f0104589:	ff 75 0c             	pushl  0xc(%ebp)
f010458c:	ff 75 08             	pushl  0x8(%ebp)
f010458f:	e8 87 ff ff ff       	call   f010451b <memmove>
}
f0104594:	c9                   	leave  
f0104595:	c3                   	ret    

f0104596 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104596:	55                   	push   %ebp
f0104597:	89 e5                	mov    %esp,%ebp
f0104599:	56                   	push   %esi
f010459a:	53                   	push   %ebx
f010459b:	8b 45 08             	mov    0x8(%ebp),%eax
f010459e:	8b 55 0c             	mov    0xc(%ebp),%edx
f01045a1:	89 c6                	mov    %eax,%esi
f01045a3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01045a6:	39 f0                	cmp    %esi,%eax
f01045a8:	74 1c                	je     f01045c6 <memcmp+0x30>
		if (*s1 != *s2)
f01045aa:	0f b6 08             	movzbl (%eax),%ecx
f01045ad:	0f b6 1a             	movzbl (%edx),%ebx
f01045b0:	38 d9                	cmp    %bl,%cl
f01045b2:	75 08                	jne    f01045bc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01045b4:	83 c0 01             	add    $0x1,%eax
f01045b7:	83 c2 01             	add    $0x1,%edx
f01045ba:	eb ea                	jmp    f01045a6 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f01045bc:	0f b6 c1             	movzbl %cl,%eax
f01045bf:	0f b6 db             	movzbl %bl,%ebx
f01045c2:	29 d8                	sub    %ebx,%eax
f01045c4:	eb 05                	jmp    f01045cb <memcmp+0x35>
	}

	return 0;
f01045c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01045cb:	5b                   	pop    %ebx
f01045cc:	5e                   	pop    %esi
f01045cd:	5d                   	pop    %ebp
f01045ce:	c3                   	ret    

f01045cf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01045cf:	55                   	push   %ebp
f01045d0:	89 e5                	mov    %esp,%ebp
f01045d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01045d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01045d8:	89 c2                	mov    %eax,%edx
f01045da:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01045dd:	39 d0                	cmp    %edx,%eax
f01045df:	73 09                	jae    f01045ea <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f01045e1:	38 08                	cmp    %cl,(%eax)
f01045e3:	74 05                	je     f01045ea <memfind+0x1b>
	for (; s < ends; s++)
f01045e5:	83 c0 01             	add    $0x1,%eax
f01045e8:	eb f3                	jmp    f01045dd <memfind+0xe>
			break;
	return (void *) s;
}
f01045ea:	5d                   	pop    %ebp
f01045eb:	c3                   	ret    

f01045ec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01045ec:	55                   	push   %ebp
f01045ed:	89 e5                	mov    %esp,%ebp
f01045ef:	57                   	push   %edi
f01045f0:	56                   	push   %esi
f01045f1:	53                   	push   %ebx
f01045f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01045f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01045f8:	eb 03                	jmp    f01045fd <strtol+0x11>
		s++;
f01045fa:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01045fd:	0f b6 01             	movzbl (%ecx),%eax
f0104600:	3c 20                	cmp    $0x20,%al
f0104602:	74 f6                	je     f01045fa <strtol+0xe>
f0104604:	3c 09                	cmp    $0x9,%al
f0104606:	74 f2                	je     f01045fa <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0104608:	3c 2b                	cmp    $0x2b,%al
f010460a:	74 2e                	je     f010463a <strtol+0x4e>
	int neg = 0;
f010460c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104611:	3c 2d                	cmp    $0x2d,%al
f0104613:	74 2f                	je     f0104644 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104615:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010461b:	75 05                	jne    f0104622 <strtol+0x36>
f010461d:	80 39 30             	cmpb   $0x30,(%ecx)
f0104620:	74 2c                	je     f010464e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104622:	85 db                	test   %ebx,%ebx
f0104624:	75 0a                	jne    f0104630 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104626:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f010462b:	80 39 30             	cmpb   $0x30,(%ecx)
f010462e:	74 28                	je     f0104658 <strtol+0x6c>
		base = 10;
f0104630:	b8 00 00 00 00       	mov    $0x0,%eax
f0104635:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104638:	eb 50                	jmp    f010468a <strtol+0x9e>
		s++;
f010463a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010463d:	bf 00 00 00 00       	mov    $0x0,%edi
f0104642:	eb d1                	jmp    f0104615 <strtol+0x29>
		s++, neg = 1;
f0104644:	83 c1 01             	add    $0x1,%ecx
f0104647:	bf 01 00 00 00       	mov    $0x1,%edi
f010464c:	eb c7                	jmp    f0104615 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010464e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104652:	74 0e                	je     f0104662 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0104654:	85 db                	test   %ebx,%ebx
f0104656:	75 d8                	jne    f0104630 <strtol+0x44>
		s++, base = 8;
f0104658:	83 c1 01             	add    $0x1,%ecx
f010465b:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104660:	eb ce                	jmp    f0104630 <strtol+0x44>
		s += 2, base = 16;
f0104662:	83 c1 02             	add    $0x2,%ecx
f0104665:	bb 10 00 00 00       	mov    $0x10,%ebx
f010466a:	eb c4                	jmp    f0104630 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f010466c:	8d 72 9f             	lea    -0x61(%edx),%esi
f010466f:	89 f3                	mov    %esi,%ebx
f0104671:	80 fb 19             	cmp    $0x19,%bl
f0104674:	77 29                	ja     f010469f <strtol+0xb3>
			dig = *s - 'a' + 10;
f0104676:	0f be d2             	movsbl %dl,%edx
f0104679:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010467c:	3b 55 10             	cmp    0x10(%ebp),%edx
f010467f:	7d 30                	jge    f01046b1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0104681:	83 c1 01             	add    $0x1,%ecx
f0104684:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104688:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f010468a:	0f b6 11             	movzbl (%ecx),%edx
f010468d:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104690:	89 f3                	mov    %esi,%ebx
f0104692:	80 fb 09             	cmp    $0x9,%bl
f0104695:	77 d5                	ja     f010466c <strtol+0x80>
			dig = *s - '0';
f0104697:	0f be d2             	movsbl %dl,%edx
f010469a:	83 ea 30             	sub    $0x30,%edx
f010469d:	eb dd                	jmp    f010467c <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f010469f:	8d 72 bf             	lea    -0x41(%edx),%esi
f01046a2:	89 f3                	mov    %esi,%ebx
f01046a4:	80 fb 19             	cmp    $0x19,%bl
f01046a7:	77 08                	ja     f01046b1 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01046a9:	0f be d2             	movsbl %dl,%edx
f01046ac:	83 ea 37             	sub    $0x37,%edx
f01046af:	eb cb                	jmp    f010467c <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f01046b1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01046b5:	74 05                	je     f01046bc <strtol+0xd0>
		*endptr = (char *) s;
f01046b7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01046ba:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01046bc:	89 c2                	mov    %eax,%edx
f01046be:	f7 da                	neg    %edx
f01046c0:	85 ff                	test   %edi,%edi
f01046c2:	0f 45 c2             	cmovne %edx,%eax
}
f01046c5:	5b                   	pop    %ebx
f01046c6:	5e                   	pop    %esi
f01046c7:	5f                   	pop    %edi
f01046c8:	5d                   	pop    %ebp
f01046c9:	c3                   	ret    
f01046ca:	66 90                	xchg   %ax,%ax
f01046cc:	66 90                	xchg   %ax,%ax
f01046ce:	66 90                	xchg   %ax,%ax

f01046d0 <__udivdi3>:
f01046d0:	55                   	push   %ebp
f01046d1:	57                   	push   %edi
f01046d2:	56                   	push   %esi
f01046d3:	53                   	push   %ebx
f01046d4:	83 ec 1c             	sub    $0x1c,%esp
f01046d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01046db:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01046df:	8b 74 24 34          	mov    0x34(%esp),%esi
f01046e3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01046e7:	85 d2                	test   %edx,%edx
f01046e9:	75 35                	jne    f0104720 <__udivdi3+0x50>
f01046eb:	39 f3                	cmp    %esi,%ebx
f01046ed:	0f 87 bd 00 00 00    	ja     f01047b0 <__udivdi3+0xe0>
f01046f3:	85 db                	test   %ebx,%ebx
f01046f5:	89 d9                	mov    %ebx,%ecx
f01046f7:	75 0b                	jne    f0104704 <__udivdi3+0x34>
f01046f9:	b8 01 00 00 00       	mov    $0x1,%eax
f01046fe:	31 d2                	xor    %edx,%edx
f0104700:	f7 f3                	div    %ebx
f0104702:	89 c1                	mov    %eax,%ecx
f0104704:	31 d2                	xor    %edx,%edx
f0104706:	89 f0                	mov    %esi,%eax
f0104708:	f7 f1                	div    %ecx
f010470a:	89 c6                	mov    %eax,%esi
f010470c:	89 e8                	mov    %ebp,%eax
f010470e:	89 f7                	mov    %esi,%edi
f0104710:	f7 f1                	div    %ecx
f0104712:	89 fa                	mov    %edi,%edx
f0104714:	83 c4 1c             	add    $0x1c,%esp
f0104717:	5b                   	pop    %ebx
f0104718:	5e                   	pop    %esi
f0104719:	5f                   	pop    %edi
f010471a:	5d                   	pop    %ebp
f010471b:	c3                   	ret    
f010471c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104720:	39 f2                	cmp    %esi,%edx
f0104722:	77 7c                	ja     f01047a0 <__udivdi3+0xd0>
f0104724:	0f bd fa             	bsr    %edx,%edi
f0104727:	83 f7 1f             	xor    $0x1f,%edi
f010472a:	0f 84 98 00 00 00    	je     f01047c8 <__udivdi3+0xf8>
f0104730:	89 f9                	mov    %edi,%ecx
f0104732:	b8 20 00 00 00       	mov    $0x20,%eax
f0104737:	29 f8                	sub    %edi,%eax
f0104739:	d3 e2                	shl    %cl,%edx
f010473b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010473f:	89 c1                	mov    %eax,%ecx
f0104741:	89 da                	mov    %ebx,%edx
f0104743:	d3 ea                	shr    %cl,%edx
f0104745:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104749:	09 d1                	or     %edx,%ecx
f010474b:	89 f2                	mov    %esi,%edx
f010474d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104751:	89 f9                	mov    %edi,%ecx
f0104753:	d3 e3                	shl    %cl,%ebx
f0104755:	89 c1                	mov    %eax,%ecx
f0104757:	d3 ea                	shr    %cl,%edx
f0104759:	89 f9                	mov    %edi,%ecx
f010475b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010475f:	d3 e6                	shl    %cl,%esi
f0104761:	89 eb                	mov    %ebp,%ebx
f0104763:	89 c1                	mov    %eax,%ecx
f0104765:	d3 eb                	shr    %cl,%ebx
f0104767:	09 de                	or     %ebx,%esi
f0104769:	89 f0                	mov    %esi,%eax
f010476b:	f7 74 24 08          	divl   0x8(%esp)
f010476f:	89 d6                	mov    %edx,%esi
f0104771:	89 c3                	mov    %eax,%ebx
f0104773:	f7 64 24 0c          	mull   0xc(%esp)
f0104777:	39 d6                	cmp    %edx,%esi
f0104779:	72 0c                	jb     f0104787 <__udivdi3+0xb7>
f010477b:	89 f9                	mov    %edi,%ecx
f010477d:	d3 e5                	shl    %cl,%ebp
f010477f:	39 c5                	cmp    %eax,%ebp
f0104781:	73 5d                	jae    f01047e0 <__udivdi3+0x110>
f0104783:	39 d6                	cmp    %edx,%esi
f0104785:	75 59                	jne    f01047e0 <__udivdi3+0x110>
f0104787:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010478a:	31 ff                	xor    %edi,%edi
f010478c:	89 fa                	mov    %edi,%edx
f010478e:	83 c4 1c             	add    $0x1c,%esp
f0104791:	5b                   	pop    %ebx
f0104792:	5e                   	pop    %esi
f0104793:	5f                   	pop    %edi
f0104794:	5d                   	pop    %ebp
f0104795:	c3                   	ret    
f0104796:	8d 76 00             	lea    0x0(%esi),%esi
f0104799:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01047a0:	31 ff                	xor    %edi,%edi
f01047a2:	31 c0                	xor    %eax,%eax
f01047a4:	89 fa                	mov    %edi,%edx
f01047a6:	83 c4 1c             	add    $0x1c,%esp
f01047a9:	5b                   	pop    %ebx
f01047aa:	5e                   	pop    %esi
f01047ab:	5f                   	pop    %edi
f01047ac:	5d                   	pop    %ebp
f01047ad:	c3                   	ret    
f01047ae:	66 90                	xchg   %ax,%ax
f01047b0:	31 ff                	xor    %edi,%edi
f01047b2:	89 e8                	mov    %ebp,%eax
f01047b4:	89 f2                	mov    %esi,%edx
f01047b6:	f7 f3                	div    %ebx
f01047b8:	89 fa                	mov    %edi,%edx
f01047ba:	83 c4 1c             	add    $0x1c,%esp
f01047bd:	5b                   	pop    %ebx
f01047be:	5e                   	pop    %esi
f01047bf:	5f                   	pop    %edi
f01047c0:	5d                   	pop    %ebp
f01047c1:	c3                   	ret    
f01047c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01047c8:	39 f2                	cmp    %esi,%edx
f01047ca:	72 06                	jb     f01047d2 <__udivdi3+0x102>
f01047cc:	31 c0                	xor    %eax,%eax
f01047ce:	39 eb                	cmp    %ebp,%ebx
f01047d0:	77 d2                	ja     f01047a4 <__udivdi3+0xd4>
f01047d2:	b8 01 00 00 00       	mov    $0x1,%eax
f01047d7:	eb cb                	jmp    f01047a4 <__udivdi3+0xd4>
f01047d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01047e0:	89 d8                	mov    %ebx,%eax
f01047e2:	31 ff                	xor    %edi,%edi
f01047e4:	eb be                	jmp    f01047a4 <__udivdi3+0xd4>
f01047e6:	66 90                	xchg   %ax,%ax
f01047e8:	66 90                	xchg   %ax,%ax
f01047ea:	66 90                	xchg   %ax,%ax
f01047ec:	66 90                	xchg   %ax,%ax
f01047ee:	66 90                	xchg   %ax,%ax

f01047f0 <__umoddi3>:
f01047f0:	55                   	push   %ebp
f01047f1:	57                   	push   %edi
f01047f2:	56                   	push   %esi
f01047f3:	53                   	push   %ebx
f01047f4:	83 ec 1c             	sub    $0x1c,%esp
f01047f7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01047fb:	8b 74 24 30          	mov    0x30(%esp),%esi
f01047ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0104803:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104807:	85 ed                	test   %ebp,%ebp
f0104809:	89 f0                	mov    %esi,%eax
f010480b:	89 da                	mov    %ebx,%edx
f010480d:	75 19                	jne    f0104828 <__umoddi3+0x38>
f010480f:	39 df                	cmp    %ebx,%edi
f0104811:	0f 86 b1 00 00 00    	jbe    f01048c8 <__umoddi3+0xd8>
f0104817:	f7 f7                	div    %edi
f0104819:	89 d0                	mov    %edx,%eax
f010481b:	31 d2                	xor    %edx,%edx
f010481d:	83 c4 1c             	add    $0x1c,%esp
f0104820:	5b                   	pop    %ebx
f0104821:	5e                   	pop    %esi
f0104822:	5f                   	pop    %edi
f0104823:	5d                   	pop    %ebp
f0104824:	c3                   	ret    
f0104825:	8d 76 00             	lea    0x0(%esi),%esi
f0104828:	39 dd                	cmp    %ebx,%ebp
f010482a:	77 f1                	ja     f010481d <__umoddi3+0x2d>
f010482c:	0f bd cd             	bsr    %ebp,%ecx
f010482f:	83 f1 1f             	xor    $0x1f,%ecx
f0104832:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104836:	0f 84 b4 00 00 00    	je     f01048f0 <__umoddi3+0x100>
f010483c:	b8 20 00 00 00       	mov    $0x20,%eax
f0104841:	89 c2                	mov    %eax,%edx
f0104843:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104847:	29 c2                	sub    %eax,%edx
f0104849:	89 c1                	mov    %eax,%ecx
f010484b:	89 f8                	mov    %edi,%eax
f010484d:	d3 e5                	shl    %cl,%ebp
f010484f:	89 d1                	mov    %edx,%ecx
f0104851:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104855:	d3 e8                	shr    %cl,%eax
f0104857:	09 c5                	or     %eax,%ebp
f0104859:	8b 44 24 04          	mov    0x4(%esp),%eax
f010485d:	89 c1                	mov    %eax,%ecx
f010485f:	d3 e7                	shl    %cl,%edi
f0104861:	89 d1                	mov    %edx,%ecx
f0104863:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104867:	89 df                	mov    %ebx,%edi
f0104869:	d3 ef                	shr    %cl,%edi
f010486b:	89 c1                	mov    %eax,%ecx
f010486d:	89 f0                	mov    %esi,%eax
f010486f:	d3 e3                	shl    %cl,%ebx
f0104871:	89 d1                	mov    %edx,%ecx
f0104873:	89 fa                	mov    %edi,%edx
f0104875:	d3 e8                	shr    %cl,%eax
f0104877:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010487c:	09 d8                	or     %ebx,%eax
f010487e:	f7 f5                	div    %ebp
f0104880:	d3 e6                	shl    %cl,%esi
f0104882:	89 d1                	mov    %edx,%ecx
f0104884:	f7 64 24 08          	mull   0x8(%esp)
f0104888:	39 d1                	cmp    %edx,%ecx
f010488a:	89 c3                	mov    %eax,%ebx
f010488c:	89 d7                	mov    %edx,%edi
f010488e:	72 06                	jb     f0104896 <__umoddi3+0xa6>
f0104890:	75 0e                	jne    f01048a0 <__umoddi3+0xb0>
f0104892:	39 c6                	cmp    %eax,%esi
f0104894:	73 0a                	jae    f01048a0 <__umoddi3+0xb0>
f0104896:	2b 44 24 08          	sub    0x8(%esp),%eax
f010489a:	19 ea                	sbb    %ebp,%edx
f010489c:	89 d7                	mov    %edx,%edi
f010489e:	89 c3                	mov    %eax,%ebx
f01048a0:	89 ca                	mov    %ecx,%edx
f01048a2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f01048a7:	29 de                	sub    %ebx,%esi
f01048a9:	19 fa                	sbb    %edi,%edx
f01048ab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f01048af:	89 d0                	mov    %edx,%eax
f01048b1:	d3 e0                	shl    %cl,%eax
f01048b3:	89 d9                	mov    %ebx,%ecx
f01048b5:	d3 ee                	shr    %cl,%esi
f01048b7:	d3 ea                	shr    %cl,%edx
f01048b9:	09 f0                	or     %esi,%eax
f01048bb:	83 c4 1c             	add    $0x1c,%esp
f01048be:	5b                   	pop    %ebx
f01048bf:	5e                   	pop    %esi
f01048c0:	5f                   	pop    %edi
f01048c1:	5d                   	pop    %ebp
f01048c2:	c3                   	ret    
f01048c3:	90                   	nop
f01048c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01048c8:	85 ff                	test   %edi,%edi
f01048ca:	89 f9                	mov    %edi,%ecx
f01048cc:	75 0b                	jne    f01048d9 <__umoddi3+0xe9>
f01048ce:	b8 01 00 00 00       	mov    $0x1,%eax
f01048d3:	31 d2                	xor    %edx,%edx
f01048d5:	f7 f7                	div    %edi
f01048d7:	89 c1                	mov    %eax,%ecx
f01048d9:	89 d8                	mov    %ebx,%eax
f01048db:	31 d2                	xor    %edx,%edx
f01048dd:	f7 f1                	div    %ecx
f01048df:	89 f0                	mov    %esi,%eax
f01048e1:	f7 f1                	div    %ecx
f01048e3:	e9 31 ff ff ff       	jmp    f0104819 <__umoddi3+0x29>
f01048e8:	90                   	nop
f01048e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01048f0:	39 dd                	cmp    %ebx,%ebp
f01048f2:	72 08                	jb     f01048fc <__umoddi3+0x10c>
f01048f4:	39 f7                	cmp    %esi,%edi
f01048f6:	0f 87 21 ff ff ff    	ja     f010481d <__umoddi3+0x2d>
f01048fc:	89 da                	mov    %ebx,%edx
f01048fe:	89 f0                	mov    %esi,%eax
f0104900:	29 f8                	sub    %edi,%eax
f0104902:	19 ea                	sbb    %ebp,%edx
f0104904:	e9 14 ff ff ff       	jmp    f010481d <__umoddi3+0x2d>
