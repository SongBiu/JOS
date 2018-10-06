
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
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
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
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

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
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %08d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 a0 37 10 f0       	push   $0xf01037a0
f0100050:	e8 c8 27 00 00       	call   f010281d <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
	{
		test_backtrace(x - 1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	}
	else
	{
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 2b 07 00 00       	call   f01007a6 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	}
	cprintf("leaving test_backtrace %08d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 be 37 10 f0       	push   $0xf01037be
f0100087:	e8 91 27 00 00       	call   f010281d <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];
	
	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 40 79 11 f0       	mov    $0xf0117940,%eax
f010009f:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 73 11 f0       	push   $0xf0117300
f01000ac:	e8 4b 32 00 00       	call   f01032fc <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 be 04 00 00       	call   f0100574 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 db 37 10 f0       	push   $0xf01037db
f01000c3:	e8 55 27 00 00       	call   f010281d <cprintf>

	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>

	// Lab 2 memory management initialization functions
	mem_init();
f01000d4:	e8 9e 10 00 00       	call   f0101177 <mem_init>
	cprintf("hahahah I am joker!\n");
f01000d9:	c7 04 24 f6 37 10 f0 	movl   $0xf01037f6,(%esp)
f01000e0:	e8 38 27 00 00       	call   f010281d <cprintf>
	unsigned int i = 0x00646c72;
   	cprintf("x=%d y=%d", 3);
f01000e5:	83 c4 08             	add    $0x8,%esp
f01000e8:	6a 03                	push   $0x3
f01000ea:	68 0b 38 10 f0       	push   $0xf010380b
f01000ef:	e8 29 27 00 00       	call   f010281d <cprintf>
f01000f4:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01000f7:	89 e8                	mov    %ebp,%eax
	// Drop into the kernel monitor.
	while (1)
	{
		struct Trapframe *tf;
		tf = (struct Trapframe *)read_ebp();
		monitor(tf);
f01000f9:	83 ec 0c             	sub    $0xc,%esp
f01000fc:	50                   	push   %eax
f01000fd:	e8 86 07 00 00       	call   f0100888 <monitor>
f0100102:	83 c4 10             	add    $0x10,%esp
f0100105:	eb f0                	jmp    f01000f7 <i386_init+0x63>

f0100107 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100107:	55                   	push   %ebp
f0100108:	89 e5                	mov    %esp,%ebp
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010010f:	83 3d 44 79 11 f0 00 	cmpl   $0x0,0xf0117944
f0100116:	75 37                	jne    f010014f <_panic+0x48>
		goto dead;
	panicstr = fmt;
f0100118:	89 35 44 79 11 f0    	mov    %esi,0xf0117944

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010011e:	fa                   	cli    
f010011f:	fc                   	cld    

	va_start(ap, fmt);
f0100120:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100123:	83 ec 04             	sub    $0x4,%esp
f0100126:	ff 75 0c             	pushl  0xc(%ebp)
f0100129:	ff 75 08             	pushl  0x8(%ebp)
f010012c:	68 15 38 10 f0       	push   $0xf0103815
f0100131:	e8 e7 26 00 00       	call   f010281d <cprintf>
	vcprintf(fmt, ap);
f0100136:	83 c4 08             	add    $0x8,%esp
f0100139:	53                   	push   %ebx
f010013a:	56                   	push   %esi
f010013b:	e8 b7 26 00 00       	call   f01027f7 <vcprintf>
	cprintf("\n");
f0100140:	c7 04 24 0c 40 10 f0 	movl   $0xf010400c,(%esp)
f0100147:	e8 d1 26 00 00       	call   f010281d <cprintf>
	va_end(ap);
f010014c:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010014f:	83 ec 0c             	sub    $0xc,%esp
f0100152:	6a 00                	push   $0x0
f0100154:	e8 2f 07 00 00       	call   f0100888 <monitor>
f0100159:	83 c4 10             	add    $0x10,%esp
f010015c:	eb f1                	jmp    f010014f <_panic+0x48>

f010015e <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010015e:	55                   	push   %ebp
f010015f:	89 e5                	mov    %esp,%ebp
f0100161:	53                   	push   %ebx
f0100162:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100165:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100168:	ff 75 0c             	pushl  0xc(%ebp)
f010016b:	ff 75 08             	pushl  0x8(%ebp)
f010016e:	68 2d 38 10 f0       	push   $0xf010382d
f0100173:	e8 a5 26 00 00       	call   f010281d <cprintf>
	vcprintf(fmt, ap);
f0100178:	83 c4 08             	add    $0x8,%esp
f010017b:	53                   	push   %ebx
f010017c:	ff 75 10             	pushl  0x10(%ebp)
f010017f:	e8 73 26 00 00       	call   f01027f7 <vcprintf>
	cprintf("\n");
f0100184:	c7 04 24 0c 40 10 f0 	movl   $0xf010400c,(%esp)
f010018b:	e8 8d 26 00 00       	call   f010281d <cprintf>
	va_end(ap);
}
f0100190:	83 c4 10             	add    $0x10,%esp
f0100193:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100196:	c9                   	leave  
f0100197:	c3                   	ret    

f0100198 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100198:	55                   	push   %ebp
f0100199:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010019b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001a0:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001a1:	a8 01                	test   $0x1,%al
f01001a3:	74 0b                	je     f01001b0 <serial_proc_data+0x18>
f01001a5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001aa:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ab:	0f b6 c0             	movzbl %al,%eax
f01001ae:	eb 05                	jmp    f01001b5 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001b5:	5d                   	pop    %ebp
f01001b6:	c3                   	ret    

f01001b7 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001b7:	55                   	push   %ebp
f01001b8:	89 e5                	mov    %esp,%ebp
f01001ba:	53                   	push   %ebx
f01001bb:	83 ec 04             	sub    $0x4,%esp
f01001be:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001c0:	eb 2b                	jmp    f01001ed <cons_intr+0x36>
		if (c == 0)
f01001c2:	85 c0                	test   %eax,%eax
f01001c4:	74 27                	je     f01001ed <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001c6:	8b 0d 24 75 11 f0    	mov    0xf0117524,%ecx
f01001cc:	8d 51 01             	lea    0x1(%ecx),%edx
f01001cf:	89 15 24 75 11 f0    	mov    %edx,0xf0117524
f01001d5:	88 81 20 73 11 f0    	mov    %al,-0xfee8ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001db:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001e1:	75 0a                	jne    f01001ed <cons_intr+0x36>
			cons.wpos = 0;
f01001e3:	c7 05 24 75 11 f0 00 	movl   $0x0,0xf0117524
f01001ea:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001ed:	ff d3                	call   *%ebx
f01001ef:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f2:	75 ce                	jne    f01001c2 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001f4:	83 c4 04             	add    $0x4,%esp
f01001f7:	5b                   	pop    %ebx
f01001f8:	5d                   	pop    %ebp
f01001f9:	c3                   	ret    

f01001fa <kbd_proc_data>:
f01001fa:	ba 64 00 00 00       	mov    $0x64,%edx
f01001ff:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100200:	a8 01                	test   $0x1,%al
f0100202:	0f 84 f8 00 00 00    	je     f0100300 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100208:	a8 20                	test   $0x20,%al
f010020a:	0f 85 f6 00 00 00    	jne    f0100306 <kbd_proc_data+0x10c>
f0100210:	ba 60 00 00 00       	mov    $0x60,%edx
f0100215:	ec                   	in     (%dx),%al
f0100216:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100218:	3c e0                	cmp    $0xe0,%al
f010021a:	75 0d                	jne    f0100229 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010021c:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f0100223:	b8 00 00 00 00       	mov    $0x0,%eax
f0100228:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100229:	55                   	push   %ebp
f010022a:	89 e5                	mov    %esp,%ebp
f010022c:	53                   	push   %ebx
f010022d:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100230:	84 c0                	test   %al,%al
f0100232:	79 36                	jns    f010026a <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100234:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f010023a:	89 cb                	mov    %ecx,%ebx
f010023c:	83 e3 40             	and    $0x40,%ebx
f010023f:	83 e0 7f             	and    $0x7f,%eax
f0100242:	85 db                	test   %ebx,%ebx
f0100244:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100247:	0f b6 d2             	movzbl %dl,%edx
f010024a:	0f b6 82 a0 39 10 f0 	movzbl -0xfefc660(%edx),%eax
f0100251:	83 c8 40             	or     $0x40,%eax
f0100254:	0f b6 c0             	movzbl %al,%eax
f0100257:	f7 d0                	not    %eax
f0100259:	21 c8                	and    %ecx,%eax
f010025b:	a3 00 73 11 f0       	mov    %eax,0xf0117300
		return 0;
f0100260:	b8 00 00 00 00       	mov    $0x0,%eax
f0100265:	e9 a4 00 00 00       	jmp    f010030e <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010026a:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f0100270:	f6 c1 40             	test   $0x40,%cl
f0100273:	74 0e                	je     f0100283 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100275:	83 c8 80             	or     $0xffffff80,%eax
f0100278:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010027a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027d:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f0100283:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100286:	0f b6 82 a0 39 10 f0 	movzbl -0xfefc660(%edx),%eax
f010028d:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f0100293:	0f b6 8a a0 38 10 f0 	movzbl -0xfefc760(%edx),%ecx
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f01002a1:	89 c1                	mov    %eax,%ecx
f01002a3:	83 e1 03             	and    $0x3,%ecx
f01002a6:	8b 0c 8d 80 38 10 f0 	mov    -0xfefc780(,%ecx,4),%ecx
f01002ad:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b1:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002b4:	a8 08                	test   $0x8,%al
f01002b6:	74 1b                	je     f01002d3 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01002b8:	89 da                	mov    %ebx,%edx
f01002ba:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002bd:	83 f9 19             	cmp    $0x19,%ecx
f01002c0:	77 05                	ja     f01002c7 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002c2:	83 eb 20             	sub    $0x20,%ebx
f01002c5:	eb 0c                	jmp    f01002d3 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002c7:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002ca:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002cd:	83 fa 19             	cmp    $0x19,%edx
f01002d0:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002d3:	f7 d0                	not    %eax
f01002d5:	a8 06                	test   $0x6,%al
f01002d7:	75 33                	jne    f010030c <kbd_proc_data+0x112>
f01002d9:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002df:	75 2b                	jne    f010030c <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002e1:	83 ec 0c             	sub    $0xc,%esp
f01002e4:	68 47 38 10 f0       	push   $0xf0103847
f01002e9:	e8 2f 25 00 00       	call   f010281d <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ee:	ba 92 00 00 00       	mov    $0x92,%edx
f01002f3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002f8:	ee                   	out    %al,(%dx)
f01002f9:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002fc:	89 d8                	mov    %ebx,%eax
f01002fe:	eb 0e                	jmp    f010030e <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100305:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100306:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010030b:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010030c:	89 d8                	mov    %ebx,%eax
}
f010030e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100311:	c9                   	leave  
f0100312:	c3                   	ret    

f0100313 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100313:	55                   	push   %ebp
f0100314:	89 e5                	mov    %esp,%ebp
f0100316:	57                   	push   %edi
f0100317:	56                   	push   %esi
f0100318:	53                   	push   %ebx
f0100319:	83 ec 1c             	sub    $0x1c,%esp
f010031c:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010031e:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100323:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100328:	b9 84 00 00 00       	mov    $0x84,%ecx
f010032d:	eb 09                	jmp    f0100338 <cons_putc+0x25>
f010032f:	89 ca                	mov    %ecx,%edx
f0100331:	ec                   	in     (%dx),%al
f0100332:	ec                   	in     (%dx),%al
f0100333:	ec                   	in     (%dx),%al
f0100334:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100335:	83 c3 01             	add    $0x1,%ebx
f0100338:	89 f2                	mov    %esi,%edx
f010033a:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010033b:	a8 20                	test   $0x20,%al
f010033d:	75 08                	jne    f0100347 <cons_putc+0x34>
f010033f:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100345:	7e e8                	jle    f010032f <cons_putc+0x1c>
f0100347:	89 f8                	mov    %edi,%eax
f0100349:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100351:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100352:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100357:	be 79 03 00 00       	mov    $0x379,%esi
f010035c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100361:	eb 09                	jmp    f010036c <cons_putc+0x59>
f0100363:	89 ca                	mov    %ecx,%edx
f0100365:	ec                   	in     (%dx),%al
f0100366:	ec                   	in     (%dx),%al
f0100367:	ec                   	in     (%dx),%al
f0100368:	ec                   	in     (%dx),%al
f0100369:	83 c3 01             	add    $0x1,%ebx
f010036c:	89 f2                	mov    %esi,%edx
f010036e:	ec                   	in     (%dx),%al
f010036f:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100375:	7f 04                	jg     f010037b <cons_putc+0x68>
f0100377:	84 c0                	test   %al,%al
f0100379:	79 e8                	jns    f0100363 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037b:	ba 78 03 00 00       	mov    $0x378,%edx
f0100380:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100384:	ee                   	out    %al,(%dx)
f0100385:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010038a:	b8 0d 00 00 00       	mov    $0xd,%eax
f010038f:	ee                   	out    %al,(%dx)
f0100390:	b8 08 00 00 00       	mov    $0x8,%eax
f0100395:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100396:	89 fa                	mov    %edi,%edx
f0100398:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010039e:	89 f8                	mov    %edi,%eax
f01003a0:	80 cc 07             	or     $0x7,%ah
f01003a3:	85 d2                	test   %edx,%edx
f01003a5:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01003a8:	89 f8                	mov    %edi,%eax
f01003aa:	0f b6 c0             	movzbl %al,%eax
f01003ad:	83 f8 09             	cmp    $0x9,%eax
f01003b0:	74 74                	je     f0100426 <cons_putc+0x113>
f01003b2:	83 f8 09             	cmp    $0x9,%eax
f01003b5:	7f 0a                	jg     f01003c1 <cons_putc+0xae>
f01003b7:	83 f8 08             	cmp    $0x8,%eax
f01003ba:	74 14                	je     f01003d0 <cons_putc+0xbd>
f01003bc:	e9 99 00 00 00       	jmp    f010045a <cons_putc+0x147>
f01003c1:	83 f8 0a             	cmp    $0xa,%eax
f01003c4:	74 3a                	je     f0100400 <cons_putc+0xed>
f01003c6:	83 f8 0d             	cmp    $0xd,%eax
f01003c9:	74 3d                	je     f0100408 <cons_putc+0xf5>
f01003cb:	e9 8a 00 00 00       	jmp    f010045a <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003d0:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f01003d7:	66 85 c0             	test   %ax,%ax
f01003da:	0f 84 e6 00 00 00    	je     f01004c6 <cons_putc+0x1b3>
			crt_pos--;
f01003e0:	83 e8 01             	sub    $0x1,%eax
f01003e3:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003e9:	0f b7 c0             	movzwl %ax,%eax
f01003ec:	66 81 e7 00 ff       	and    $0xff00,%di
f01003f1:	83 cf 20             	or     $0x20,%edi
f01003f4:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f01003fa:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003fe:	eb 78                	jmp    f0100478 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100400:	66 83 05 28 75 11 f0 	addw   $0x50,0xf0117528
f0100407:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100408:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f010040f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100415:	c1 e8 16             	shr    $0x16,%eax
f0100418:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010041b:	c1 e0 04             	shl    $0x4,%eax
f010041e:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
f0100424:	eb 52                	jmp    f0100478 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100426:	b8 20 00 00 00       	mov    $0x20,%eax
f010042b:	e8 e3 fe ff ff       	call   f0100313 <cons_putc>
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 d9 fe ff ff       	call   f0100313 <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 cf fe ff ff       	call   f0100313 <cons_putc>
		cons_putc(' ');
f0100444:	b8 20 00 00 00       	mov    $0x20,%eax
f0100449:	e8 c5 fe ff ff       	call   f0100313 <cons_putc>
		cons_putc(' ');
f010044e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100453:	e8 bb fe ff ff       	call   f0100313 <cons_putc>
f0100458:	eb 1e                	jmp    f0100478 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010045a:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f0100461:	8d 50 01             	lea    0x1(%eax),%edx
f0100464:	66 89 15 28 75 11 f0 	mov    %dx,0xf0117528
f010046b:	0f b7 c0             	movzwl %ax,%eax
f010046e:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100474:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100478:	66 81 3d 28 75 11 f0 	cmpw   $0x7cf,0xf0117528
f010047f:	cf 07 
f0100481:	76 43                	jbe    f01004c6 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100483:	a1 2c 75 11 f0       	mov    0xf011752c,%eax
f0100488:	83 ec 04             	sub    $0x4,%esp
f010048b:	68 00 0f 00 00       	push   $0xf00
f0100490:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100496:	52                   	push   %edx
f0100497:	50                   	push   %eax
f0100498:	e8 ac 2e 00 00       	call   f0103349 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010049d:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f01004a3:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004a9:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004af:	83 c4 10             	add    $0x10,%esp
f01004b2:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004b7:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004ba:	39 d0                	cmp    %edx,%eax
f01004bc:	75 f4                	jne    f01004b2 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004be:	66 83 2d 28 75 11 f0 	subw   $0x50,0xf0117528
f01004c5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004c6:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f01004cc:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004d1:	89 ca                	mov    %ecx,%edx
f01004d3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d4:	0f b7 1d 28 75 11 f0 	movzwl 0xf0117528,%ebx
f01004db:	8d 71 01             	lea    0x1(%ecx),%esi
f01004de:	89 d8                	mov    %ebx,%eax
f01004e0:	66 c1 e8 08          	shr    $0x8,%ax
f01004e4:	89 f2                	mov    %esi,%edx
f01004e6:	ee                   	out    %al,(%dx)
f01004e7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ec:	89 ca                	mov    %ecx,%edx
f01004ee:	ee                   	out    %al,(%dx)
f01004ef:	89 d8                	mov    %ebx,%eax
f01004f1:	89 f2                	mov    %esi,%edx
f01004f3:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004f7:	5b                   	pop    %ebx
f01004f8:	5e                   	pop    %esi
f01004f9:	5f                   	pop    %edi
f01004fa:	5d                   	pop    %ebp
f01004fb:	c3                   	ret    

f01004fc <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004fc:	80 3d 34 75 11 f0 00 	cmpb   $0x0,0xf0117534
f0100503:	74 11                	je     f0100516 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100505:	55                   	push   %ebp
f0100506:	89 e5                	mov    %esp,%ebp
f0100508:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010050b:	b8 98 01 10 f0       	mov    $0xf0100198,%eax
f0100510:	e8 a2 fc ff ff       	call   f01001b7 <cons_intr>
}
f0100515:	c9                   	leave  
f0100516:	f3 c3                	repz ret 

f0100518 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100518:	55                   	push   %ebp
f0100519:	89 e5                	mov    %esp,%ebp
f010051b:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010051e:	b8 fa 01 10 f0       	mov    $0xf01001fa,%eax
f0100523:	e8 8f fc ff ff       	call   f01001b7 <cons_intr>
}
f0100528:	c9                   	leave  
f0100529:	c3                   	ret    

f010052a <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010052a:	55                   	push   %ebp
f010052b:	89 e5                	mov    %esp,%ebp
f010052d:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100530:	e8 c7 ff ff ff       	call   f01004fc <serial_intr>
	kbd_intr();
f0100535:	e8 de ff ff ff       	call   f0100518 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010053a:	a1 20 75 11 f0       	mov    0xf0117520,%eax
f010053f:	3b 05 24 75 11 f0    	cmp    0xf0117524,%eax
f0100545:	74 26                	je     f010056d <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100547:	8d 50 01             	lea    0x1(%eax),%edx
f010054a:	89 15 20 75 11 f0    	mov    %edx,0xf0117520
f0100550:	0f b6 88 20 73 11 f0 	movzbl -0xfee8ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100557:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100559:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010055f:	75 11                	jne    f0100572 <cons_getc+0x48>
			cons.rpos = 0;
f0100561:	c7 05 20 75 11 f0 00 	movl   $0x0,0xf0117520
f0100568:	00 00 00 
f010056b:	eb 05                	jmp    f0100572 <cons_getc+0x48>
		return c;
	}
	return 0;
f010056d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100572:	c9                   	leave  
f0100573:	c3                   	ret    

f0100574 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100574:	55                   	push   %ebp
f0100575:	89 e5                	mov    %esp,%ebp
f0100577:	57                   	push   %edi
f0100578:	56                   	push   %esi
f0100579:	53                   	push   %ebx
f010057a:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010057d:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100584:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010058b:	5a a5 
	if (*cp != 0xA55A) {
f010058d:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100594:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100598:	74 11                	je     f01005ab <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010059a:	c7 05 30 75 11 f0 b4 	movl   $0x3b4,0xf0117530
f01005a1:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005a4:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01005a9:	eb 16                	jmp    f01005c1 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005ab:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005b2:	c7 05 30 75 11 f0 d4 	movl   $0x3d4,0xf0117530
f01005b9:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005bc:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005c1:	8b 3d 30 75 11 f0    	mov    0xf0117530,%edi
f01005c7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005cc:	89 fa                	mov    %edi,%edx
f01005ce:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005cf:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d2:	89 da                	mov    %ebx,%edx
f01005d4:	ec                   	in     (%dx),%al
f01005d5:	0f b6 c8             	movzbl %al,%ecx
f01005d8:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005db:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005e0:	89 fa                	mov    %edi,%edx
f01005e2:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e3:	89 da                	mov    %ebx,%edx
f01005e5:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005e6:	89 35 2c 75 11 f0    	mov    %esi,0xf011752c
	crt_pos = pos;
f01005ec:	0f b6 c0             	movzbl %al,%eax
f01005ef:	09 c8                	or     %ecx,%eax
f01005f1:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f7:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100601:	89 f2                	mov    %esi,%edx
f0100603:	ee                   	out    %al,(%dx)
f0100604:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100609:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010060e:	ee                   	out    %al,(%dx)
f010060f:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100614:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100619:	89 da                	mov    %ebx,%edx
f010061b:	ee                   	out    %al,(%dx)
f010061c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100621:	b8 00 00 00 00       	mov    $0x0,%eax
f0100626:	ee                   	out    %al,(%dx)
f0100627:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010062c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100631:	ee                   	out    %al,(%dx)
f0100632:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100637:	b8 00 00 00 00       	mov    $0x0,%eax
f010063c:	ee                   	out    %al,(%dx)
f010063d:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100642:	b8 01 00 00 00       	mov    $0x1,%eax
f0100647:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100648:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010064d:	ec                   	in     (%dx),%al
f010064e:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100650:	3c ff                	cmp    $0xff,%al
f0100652:	0f 95 05 34 75 11 f0 	setne  0xf0117534
f0100659:	89 f2                	mov    %esi,%edx
f010065b:	ec                   	in     (%dx),%al
f010065c:	89 da                	mov    %ebx,%edx
f010065e:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010065f:	80 f9 ff             	cmp    $0xff,%cl
f0100662:	75 10                	jne    f0100674 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100664:	83 ec 0c             	sub    $0xc,%esp
f0100667:	68 53 38 10 f0       	push   $0xf0103853
f010066c:	e8 ac 21 00 00       	call   f010281d <cprintf>
f0100671:	83 c4 10             	add    $0x10,%esp
}
f0100674:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100677:	5b                   	pop    %ebx
f0100678:	5e                   	pop    %esi
f0100679:	5f                   	pop    %edi
f010067a:	5d                   	pop    %ebp
f010067b:	c3                   	ret    

f010067c <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
f010067f:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100682:	8b 45 08             	mov    0x8(%ebp),%eax
f0100685:	e8 89 fc ff ff       	call   f0100313 <cons_putc>
}
f010068a:	c9                   	leave  
f010068b:	c3                   	ret    

f010068c <getchar>:

int
getchar(void)
{
f010068c:	55                   	push   %ebp
f010068d:	89 e5                	mov    %esp,%ebp
f010068f:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100692:	e8 93 fe ff ff       	call   f010052a <cons_getc>
f0100697:	85 c0                	test   %eax,%eax
f0100699:	74 f7                	je     f0100692 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010069b:	c9                   	leave  
f010069c:	c3                   	ret    

f010069d <iscons>:

int
iscons(int fdnum)
{
f010069d:	55                   	push   %ebp
f010069e:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006a0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006a5:	5d                   	pop    %ebp
f01006a6:	c3                   	ret    

f01006a7 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006a7:	55                   	push   %ebp
f01006a8:	89 e5                	mov    %esp,%ebp
f01006aa:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006ad:	68 a0 3a 10 f0       	push   $0xf0103aa0
f01006b2:	68 be 3a 10 f0       	push   $0xf0103abe
f01006b7:	68 c3 3a 10 f0       	push   $0xf0103ac3
f01006bc:	e8 5c 21 00 00       	call   f010281d <cprintf>
f01006c1:	83 c4 0c             	add    $0xc,%esp
f01006c4:	68 9c 3b 10 f0       	push   $0xf0103b9c
f01006c9:	68 cc 3a 10 f0       	push   $0xf0103acc
f01006ce:	68 c3 3a 10 f0       	push   $0xf0103ac3
f01006d3:	e8 45 21 00 00       	call   f010281d <cprintf>
f01006d8:	83 c4 0c             	add    $0xc,%esp
f01006db:	68 d5 3a 10 f0       	push   $0xf0103ad5
f01006e0:	68 db 3a 10 f0       	push   $0xf0103adb
f01006e5:	68 c3 3a 10 f0       	push   $0xf0103ac3
f01006ea:	e8 2e 21 00 00       	call   f010281d <cprintf>
	return 0;
}
f01006ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f4:	c9                   	leave  
f01006f5:	c3                   	ret    

f01006f6 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006f6:	55                   	push   %ebp
f01006f7:	89 e5                	mov    %esp,%ebp
f01006f9:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006fc:	68 e5 3a 10 f0       	push   $0xf0103ae5
f0100701:	e8 17 21 00 00       	call   f010281d <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100706:	83 c4 08             	add    $0x8,%esp
f0100709:	68 0c 00 10 00       	push   $0x10000c
f010070e:	68 c4 3b 10 f0       	push   $0xf0103bc4
f0100713:	e8 05 21 00 00       	call   f010281d <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100718:	83 c4 0c             	add    $0xc,%esp
f010071b:	68 0c 00 10 00       	push   $0x10000c
f0100720:	68 0c 00 10 f0       	push   $0xf010000c
f0100725:	68 ec 3b 10 f0       	push   $0xf0103bec
f010072a:	e8 ee 20 00 00       	call   f010281d <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010072f:	83 c4 0c             	add    $0xc,%esp
f0100732:	68 81 37 10 00       	push   $0x103781
f0100737:	68 81 37 10 f0       	push   $0xf0103781
f010073c:	68 10 3c 10 f0       	push   $0xf0103c10
f0100741:	e8 d7 20 00 00       	call   f010281d <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100746:	83 c4 0c             	add    $0xc,%esp
f0100749:	68 00 73 11 00       	push   $0x117300
f010074e:	68 00 73 11 f0       	push   $0xf0117300
f0100753:	68 34 3c 10 f0       	push   $0xf0103c34
f0100758:	e8 c0 20 00 00       	call   f010281d <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010075d:	83 c4 0c             	add    $0xc,%esp
f0100760:	68 40 79 11 00       	push   $0x117940
f0100765:	68 40 79 11 f0       	push   $0xf0117940
f010076a:	68 58 3c 10 f0       	push   $0xf0103c58
f010076f:	e8 a9 20 00 00       	call   f010281d <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100774:	b8 3f 7d 11 f0       	mov    $0xf0117d3f,%eax
f0100779:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010077e:	83 c4 08             	add    $0x8,%esp
f0100781:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100786:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010078c:	85 c0                	test   %eax,%eax
f010078e:	0f 48 c2             	cmovs  %edx,%eax
f0100791:	c1 f8 0a             	sar    $0xa,%eax
f0100794:	50                   	push   %eax
f0100795:	68 7c 3c 10 f0       	push   $0xf0103c7c
f010079a:	e8 7e 20 00 00       	call   f010281d <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010079f:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a4:	c9                   	leave  
f01007a5:	c3                   	ret    

f01007a6 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01007a6:	55                   	push   %ebp
f01007a7:	89 e5                	mov    %esp,%ebp
f01007a9:	57                   	push   %edi
f01007aa:	56                   	push   %esi
f01007ab:	53                   	push   %ebx
f01007ac:	83 ec 58             	sub    $0x58,%esp
	// Your code here.
	cprintf("Stack backtrace:\n");
f01007af:	68 fe 3a 10 f0       	push   $0xf0103afe
f01007b4:	e8 64 20 00 00       	call   f010281d <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01007b9:	89 e8                	mov    %ebp,%eax
	const int MAXNAME = 9;
	int i, len;
	struct Eipdebuginfo info;
	struct Trapframe *ebp;
	ebp = (struct Trapframe *)read_ebp();
f01007bb:	89 c7                	mov    %eax,%edi
	uint32_t eip;
	char fn_name[MAXNAME];
	while (ebp)
f01007bd:	83 c4 10             	add    $0x10,%esp
f01007c0:	e9 ae 00 00 00       	jmp    f0100873 <mon_backtrace+0xcd>
	{
		eip = *((uint32_t *)ebp + 1);
f01007c5:	8b 47 04             	mov    0x4(%edi),%eax
f01007c8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		cprintf("  ebp %08x eip %08x  args", ebp, eip);
f01007cb:	83 ec 04             	sub    $0x4,%esp
f01007ce:	50                   	push   %eax
f01007cf:	57                   	push   %edi
f01007d0:	68 10 3b 10 f0       	push   $0xf0103b10
f01007d5:	e8 43 20 00 00       	call   f010281d <cprintf>
f01007da:	8d 5f 08             	lea    0x8(%edi),%ebx
f01007dd:	8d 77 1c             	lea    0x1c(%edi),%esi
f01007e0:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 5; i++)
		{
			cprintf(" %08x", *((uint32_t *)ebp + 2 + i));
f01007e3:	83 ec 08             	sub    $0x8,%esp
f01007e6:	ff 33                	pushl  (%ebx)
f01007e8:	68 2a 3b 10 f0       	push   $0xf0103b2a
f01007ed:	e8 2b 20 00 00       	call   f010281d <cprintf>
f01007f2:	83 c3 04             	add    $0x4,%ebx
	char fn_name[MAXNAME];
	while (ebp)
	{
		eip = *((uint32_t *)ebp + 1);
		cprintf("  ebp %08x eip %08x  args", ebp, eip);
		for (i = 0; i < 5; i++)
f01007f5:	83 c4 10             	add    $0x10,%esp
f01007f8:	39 f3                	cmp    %esi,%ebx
f01007fa:	75 e7                	jne    f01007e3 <mon_backtrace+0x3d>
		{
			cprintf(" %08x", *((uint32_t *)ebp + 2 + i));
		}
		cprintf("\n");
f01007fc:	83 ec 0c             	sub    $0xc,%esp
f01007ff:	68 0c 40 10 f0       	push   $0xf010400c
f0100804:	e8 14 20 00 00       	call   f010281d <cprintf>
		debuginfo_eip(eip, &info);
f0100809:	83 c4 08             	add    $0x8,%esp
f010080c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
f010080f:	50                   	push   %eax
f0100810:	ff 75 b4             	pushl  -0x4c(%ebp)
f0100813:	e8 0f 21 00 00       	call   f0102927 <debuginfo_eip>
		len = strlen(info.eip_fn_name);
f0100818:	83 c4 04             	add    $0x4,%esp
f010081b:	ff 75 cc             	pushl  -0x34(%ebp)
f010081e:	e8 5b 29 00 00       	call   f010317e <strlen>
		for (i = 0; i < len; i++)
		{
			if (info.eip_fn_name[i] == ':')
f0100823:	8b 55 cc             	mov    -0x34(%ebp),%edx
			cprintf(" %08x", *((uint32_t *)ebp + 2 + i));
		}
		cprintf("\n");
		debuginfo_eip(eip, &info);
		len = strlen(info.eip_fn_name);
		for (i = 0; i < len; i++)
f0100826:	83 c4 10             	add    $0x10,%esp
f0100829:	bb 00 00 00 00       	mov    $0x0,%ebx
f010082e:	eb 09                	jmp    f0100839 <mon_backtrace+0x93>
		{
			if (info.eip_fn_name[i] == ':')
f0100830:	80 3c 1a 3a          	cmpb   $0x3a,(%edx,%ebx,1)
f0100834:	74 07                	je     f010083d <mon_backtrace+0x97>
			cprintf(" %08x", *((uint32_t *)ebp + 2 + i));
		}
		cprintf("\n");
		debuginfo_eip(eip, &info);
		len = strlen(info.eip_fn_name);
		for (i = 0; i < len; i++)
f0100836:	83 c3 01             	add    $0x1,%ebx
f0100839:	39 c3                	cmp    %eax,%ebx
f010083b:	7c f3                	jl     f0100830 <mon_backtrace+0x8a>
			if (info.eip_fn_name[i] == ':')
			{
				break;
			}
		}
		strncpy(fn_name, info.eip_fn_name, i);
f010083d:	83 ec 04             	sub    $0x4,%esp
f0100840:	53                   	push   %ebx
f0100841:	52                   	push   %edx
f0100842:	8d 45 df             	lea    -0x21(%ebp),%eax
f0100845:	50                   	push   %eax
f0100846:	e8 ae 29 00 00       	call   f01031f9 <strncpy>
		fn_name[i] = '\0';
f010084b:	c6 44 1d df 00       	movb   $0x0,-0x21(%ebp,%ebx,1)
		cprintf("%s:%d: %s+%d\n", info.eip_file, info.eip_line, fn_name, eip - info.eip_fn_addr);
f0100850:	8b 45 b4             	mov    -0x4c(%ebp),%eax
f0100853:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100856:	89 04 24             	mov    %eax,(%esp)
f0100859:	8d 45 df             	lea    -0x21(%ebp),%eax
f010085c:	50                   	push   %eax
f010085d:	ff 75 c8             	pushl  -0x38(%ebp)
f0100860:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100863:	68 30 3b 10 f0       	push   $0xf0103b30
f0100868:	e8 b0 1f 00 00       	call   f010281d <cprintf>
		ebp = (struct Trapframe*)((uint32_t*)ebp + 8);
f010086d:	83 c7 20             	add    $0x20,%edi
f0100870:	83 c4 20             	add    $0x20,%esp
	struct Eipdebuginfo info;
	struct Trapframe *ebp;
	ebp = (struct Trapframe *)read_ebp();
	uint32_t eip;
	char fn_name[MAXNAME];
	while (ebp)
f0100873:	85 ff                	test   %edi,%edi
f0100875:	0f 85 4a ff ff ff    	jne    f01007c5 <mon_backtrace+0x1f>
		fn_name[i] = '\0';
		cprintf("%s:%d: %s+%d\n", info.eip_file, info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (struct Trapframe*)((uint32_t*)ebp + 8);
	}
	return 0;
}
f010087b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100880:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100883:	5b                   	pop    %ebx
f0100884:	5e                   	pop    %esi
f0100885:	5f                   	pop    %edi
f0100886:	5d                   	pop    %ebp
f0100887:	c3                   	ret    

f0100888 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100888:	55                   	push   %ebp
f0100889:	89 e5                	mov    %esp,%ebp
f010088b:	57                   	push   %edi
f010088c:	56                   	push   %esi
f010088d:	53                   	push   %ebx
f010088e:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100891:	68 a8 3c 10 f0       	push   $0xf0103ca8
f0100896:	e8 82 1f 00 00       	call   f010281d <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010089b:	c7 04 24 cc 3c 10 f0 	movl   $0xf0103ccc,(%esp)
f01008a2:	e8 76 1f 00 00       	call   f010281d <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 0x0100, "blue", 0x0200, "green", 0x0400, "red");
f01008a7:	83 c4 0c             	add    $0xc,%esp
f01008aa:	68 3e 3b 10 f0       	push   $0xf0103b3e
f01008af:	68 00 04 00 00       	push   $0x400
f01008b4:	68 42 3b 10 f0       	push   $0xf0103b42
f01008b9:	68 00 02 00 00       	push   $0x200
f01008be:	68 48 3b 10 f0       	push   $0xf0103b48
f01008c3:	68 00 01 00 00       	push   $0x100
f01008c8:	68 4d 3b 10 f0       	push   $0xf0103b4d
f01008cd:	e8 4b 1f 00 00       	call   f010281d <cprintf>
f01008d2:	83 c4 20             	add    $0x20,%esp

	while (1) {
		buf = readline("K> ");
f01008d5:	83 ec 0c             	sub    $0xc,%esp
f01008d8:	68 5d 3b 10 f0       	push   $0xf0103b5d
f01008dd:	e8 c3 27 00 00       	call   f01030a5 <readline>
f01008e2:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008e4:	83 c4 10             	add    $0x10,%esp
f01008e7:	85 c0                	test   %eax,%eax
f01008e9:	74 ea                	je     f01008d5 <monitor+0x4d>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008eb:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008f2:	be 00 00 00 00       	mov    $0x0,%esi
f01008f7:	eb 0a                	jmp    f0100903 <monitor+0x7b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008f9:	c6 03 00             	movb   $0x0,(%ebx)
f01008fc:	89 f7                	mov    %esi,%edi
f01008fe:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100901:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100903:	0f b6 03             	movzbl (%ebx),%eax
f0100906:	84 c0                	test   %al,%al
f0100908:	74 63                	je     f010096d <monitor+0xe5>
f010090a:	83 ec 08             	sub    $0x8,%esp
f010090d:	0f be c0             	movsbl %al,%eax
f0100910:	50                   	push   %eax
f0100911:	68 61 3b 10 f0       	push   $0xf0103b61
f0100916:	e8 a4 29 00 00       	call   f01032bf <strchr>
f010091b:	83 c4 10             	add    $0x10,%esp
f010091e:	85 c0                	test   %eax,%eax
f0100920:	75 d7                	jne    f01008f9 <monitor+0x71>
			*buf++ = 0;
		if (*buf == 0)
f0100922:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100925:	74 46                	je     f010096d <monitor+0xe5>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100927:	83 fe 0f             	cmp    $0xf,%esi
f010092a:	75 14                	jne    f0100940 <monitor+0xb8>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010092c:	83 ec 08             	sub    $0x8,%esp
f010092f:	6a 10                	push   $0x10
f0100931:	68 66 3b 10 f0       	push   $0xf0103b66
f0100936:	e8 e2 1e 00 00       	call   f010281d <cprintf>
f010093b:	83 c4 10             	add    $0x10,%esp
f010093e:	eb 95                	jmp    f01008d5 <monitor+0x4d>
			return 0;
		}
		argv[argc++] = buf;
f0100940:	8d 7e 01             	lea    0x1(%esi),%edi
f0100943:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100947:	eb 03                	jmp    f010094c <monitor+0xc4>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100949:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010094c:	0f b6 03             	movzbl (%ebx),%eax
f010094f:	84 c0                	test   %al,%al
f0100951:	74 ae                	je     f0100901 <monitor+0x79>
f0100953:	83 ec 08             	sub    $0x8,%esp
f0100956:	0f be c0             	movsbl %al,%eax
f0100959:	50                   	push   %eax
f010095a:	68 61 3b 10 f0       	push   $0xf0103b61
f010095f:	e8 5b 29 00 00       	call   f01032bf <strchr>
f0100964:	83 c4 10             	add    $0x10,%esp
f0100967:	85 c0                	test   %eax,%eax
f0100969:	74 de                	je     f0100949 <monitor+0xc1>
f010096b:	eb 94                	jmp    f0100901 <monitor+0x79>
			buf++;
	}
	argv[argc] = 0;
f010096d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100974:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100975:	85 f6                	test   %esi,%esi
f0100977:	0f 84 58 ff ff ff    	je     f01008d5 <monitor+0x4d>
f010097d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100982:	83 ec 08             	sub    $0x8,%esp
f0100985:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100988:	ff 34 85 00 3d 10 f0 	pushl  -0xfefc300(,%eax,4)
f010098f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100992:	e8 ca 28 00 00       	call   f0103261 <strcmp>
f0100997:	83 c4 10             	add    $0x10,%esp
f010099a:	85 c0                	test   %eax,%eax
f010099c:	75 21                	jne    f01009bf <monitor+0x137>
			return commands[i].func(argc, argv, tf);
f010099e:	83 ec 04             	sub    $0x4,%esp
f01009a1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009a4:	ff 75 08             	pushl  0x8(%ebp)
f01009a7:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009aa:	52                   	push   %edx
f01009ab:	56                   	push   %esi
f01009ac:	ff 14 85 08 3d 10 f0 	call   *-0xfefc2f8(,%eax,4)
	cprintf("%m%s\n%m%s\n%m%s\n", 0x0100, "blue", 0x0200, "green", 0x0400, "red");

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009b3:	83 c4 10             	add    $0x10,%esp
f01009b6:	85 c0                	test   %eax,%eax
f01009b8:	78 25                	js     f01009df <monitor+0x157>
f01009ba:	e9 16 ff ff ff       	jmp    f01008d5 <monitor+0x4d>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009bf:	83 c3 01             	add    $0x1,%ebx
f01009c2:	83 fb 03             	cmp    $0x3,%ebx
f01009c5:	75 bb                	jne    f0100982 <monitor+0xfa>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009c7:	83 ec 08             	sub    $0x8,%esp
f01009ca:	ff 75 a8             	pushl  -0x58(%ebp)
f01009cd:	68 83 3b 10 f0       	push   $0xf0103b83
f01009d2:	e8 46 1e 00 00       	call   f010281d <cprintf>
f01009d7:	83 c4 10             	add    $0x10,%esp
f01009da:	e9 f6 fe ff ff       	jmp    f01008d5 <monitor+0x4d>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009df:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009e2:	5b                   	pop    %ebx
f01009e3:	5e                   	pop    %esi
f01009e4:	5f                   	pop    %edi
f01009e5:	5d                   	pop    %ebp
f01009e6:	c3                   	ret    

f01009e7 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01009e7:	55                   	push   %ebp
f01009e8:	89 e5                	mov    %esp,%ebp
f01009ea:	56                   	push   %esi
f01009eb:	53                   	push   %ebx
f01009ec:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01009ee:	83 ec 0c             	sub    $0xc,%esp
f01009f1:	50                   	push   %eax
f01009f2:	e8 bf 1d 00 00       	call   f01027b6 <mc146818_read>
f01009f7:	89 c6                	mov    %eax,%esi
f01009f9:	83 c3 01             	add    $0x1,%ebx
f01009fc:	89 1c 24             	mov    %ebx,(%esp)
f01009ff:	e8 b2 1d 00 00       	call   f01027b6 <mc146818_read>
f0100a04:	c1 e0 08             	shl    $0x8,%eax
f0100a07:	09 f0                	or     %esi,%eax
}
f0100a09:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a0c:	5b                   	pop    %ebx
f0100a0d:	5e                   	pop    %esi
f0100a0e:	5d                   	pop    %ebp
f0100a0f:	c3                   	ret    

f0100a10 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a10:	55                   	push   %ebp
f0100a11:	89 e5                	mov    %esp,%ebp
f0100a13:	53                   	push   %ebx
f0100a14:	83 ec 04             	sub    $0x4,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a17:	83 3d 38 75 11 f0 00 	cmpl   $0x0,0xf0117538
f0100a1e:	75 11                	jne    f0100a31 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a20:	ba 3f 89 11 f0       	mov    $0xf011893f,%edx
f0100a25:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a2b:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100a31:	8b 1d 38 75 11 f0    	mov    0xf0117538,%ebx
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100a37:	8d 94 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edx
f0100a3e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a44:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
	if ((uint32_t)nextfree - KERNBASE > (npages * PGSIZE))
f0100a4a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100a50:	8b 0d 48 79 11 f0    	mov    0xf0117948,%ecx
f0100a56:	c1 e1 0c             	shl    $0xc,%ecx
f0100a59:	39 ca                	cmp    %ecx,%edx
f0100a5b:	76 14                	jbe    f0100a71 <boot_alloc+0x61>
	{
		panic("Memory is out of numbers\n");
f0100a5d:	83 ec 04             	sub    $0x4,%esp
f0100a60:	68 24 3d 10 f0       	push   $0xf0103d24
f0100a65:	6a 6c                	push   $0x6c
f0100a67:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100a6c:	e8 96 f6 ff ff       	call   f0100107 <_panic>
	}
	return result;

}
f0100a71:	89 d8                	mov    %ebx,%eax
f0100a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100a76:	c9                   	leave  
f0100a77:	c3                   	ret    

f0100a78 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a78:	89 d1                	mov    %edx,%ecx
f0100a7a:	c1 e9 16             	shr    $0x16,%ecx
f0100a7d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a80:	a8 01                	test   $0x1,%al
f0100a82:	74 52                	je     f0100ad6 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a89:	89 c1                	mov    %eax,%ecx
f0100a8b:	c1 e9 0c             	shr    $0xc,%ecx
f0100a8e:	3b 0d 48 79 11 f0    	cmp    0xf0117948,%ecx
f0100a94:	72 1b                	jb     f0100ab1 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a96:	55                   	push   %ebp
f0100a97:	89 e5                	mov    %esp,%ebp
f0100a99:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a9c:	50                   	push   %eax
f0100a9d:	68 40 40 10 f0       	push   $0xf0104040
f0100aa2:	68 03 03 00 00       	push   $0x303
f0100aa7:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100aac:	e8 56 f6 ff ff       	call   f0100107 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100ab1:	c1 ea 0c             	shr    $0xc,%edx
f0100ab4:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100aba:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ac1:	89 c2                	mov    %eax,%edx
f0100ac3:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ac6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100acb:	85 d2                	test   %edx,%edx
f0100acd:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ad2:	0f 44 c2             	cmove  %edx,%eax
f0100ad5:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100ad6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100adb:	c3                   	ret    

f0100adc <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100adc:	55                   	push   %ebp
f0100add:	89 e5                	mov    %esp,%ebp
f0100adf:	57                   	push   %edi
f0100ae0:	56                   	push   %esi
f0100ae1:	53                   	push   %ebx
f0100ae2:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ae5:	84 c0                	test   %al,%al
f0100ae7:	0f 85 81 02 00 00    	jne    f0100d6e <check_page_free_list+0x292>
f0100aed:	e9 8e 02 00 00       	jmp    f0100d80 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100af2:	83 ec 04             	sub    $0x4,%esp
f0100af5:	68 64 40 10 f0       	push   $0xf0104064
f0100afa:	68 41 02 00 00       	push   $0x241
f0100aff:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100b04:	e8 fe f5 ff ff       	call   f0100107 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b09:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b0c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b0f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b12:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b15:	89 c2                	mov    %eax,%edx
f0100b17:	2b 15 50 79 11 f0    	sub    0xf0117950,%edx
f0100b1d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b23:	0f 95 c2             	setne  %dl
f0100b26:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b29:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b2d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b2f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b33:	8b 00                	mov    (%eax),%eax
f0100b35:	85 c0                	test   %eax,%eax
f0100b37:	75 dc                	jne    f0100b15 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b3c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b42:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b45:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b48:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b4a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b4d:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b52:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b57:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100b5d:	eb 53                	jmp    f0100bb2 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b5f:	89 d8                	mov    %ebx,%eax
f0100b61:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f0100b67:	c1 f8 03             	sar    $0x3,%eax
f0100b6a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b6d:	89 c2                	mov    %eax,%edx
f0100b6f:	c1 ea 16             	shr    $0x16,%edx
f0100b72:	39 f2                	cmp    %esi,%edx
f0100b74:	73 3a                	jae    f0100bb0 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b76:	89 c2                	mov    %eax,%edx
f0100b78:	c1 ea 0c             	shr    $0xc,%edx
f0100b7b:	3b 15 48 79 11 f0    	cmp    0xf0117948,%edx
f0100b81:	72 12                	jb     f0100b95 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b83:	50                   	push   %eax
f0100b84:	68 40 40 10 f0       	push   $0xf0104040
f0100b89:	6a 52                	push   $0x52
f0100b8b:	68 4a 3d 10 f0       	push   $0xf0103d4a
f0100b90:	e8 72 f5 ff ff       	call   f0100107 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b95:	83 ec 04             	sub    $0x4,%esp
f0100b98:	68 80 00 00 00       	push   $0x80
f0100b9d:	68 97 00 00 00       	push   $0x97
f0100ba2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ba7:	50                   	push   %eax
f0100ba8:	e8 4f 27 00 00       	call   f01032fc <memset>
f0100bad:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bb0:	8b 1b                	mov    (%ebx),%ebx
f0100bb2:	85 db                	test   %ebx,%ebx
f0100bb4:	75 a9                	jne    f0100b5f <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100bb6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bbb:	e8 50 fe ff ff       	call   f0100a10 <boot_alloc>
f0100bc0:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bc3:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bc9:	8b 0d 50 79 11 f0    	mov    0xf0117950,%ecx
		assert(pp < pages + npages);
f0100bcf:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f0100bd4:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100bd7:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bda:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bdd:	be 00 00 00 00       	mov    $0x0,%esi
f0100be2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be5:	e9 30 01 00 00       	jmp    f0100d1a <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bea:	39 ca                	cmp    %ecx,%edx
f0100bec:	73 19                	jae    f0100c07 <check_page_free_list+0x12b>
f0100bee:	68 58 3d 10 f0       	push   $0xf0103d58
f0100bf3:	68 64 3d 10 f0       	push   $0xf0103d64
f0100bf8:	68 5b 02 00 00       	push   $0x25b
f0100bfd:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100c02:	e8 00 f5 ff ff       	call   f0100107 <_panic>
		assert(pp < pages + npages);
f0100c07:	39 fa                	cmp    %edi,%edx
f0100c09:	72 19                	jb     f0100c24 <check_page_free_list+0x148>
f0100c0b:	68 79 3d 10 f0       	push   $0xf0103d79
f0100c10:	68 64 3d 10 f0       	push   $0xf0103d64
f0100c15:	68 5c 02 00 00       	push   $0x25c
f0100c1a:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100c1f:	e8 e3 f4 ff ff       	call   f0100107 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c24:	89 d0                	mov    %edx,%eax
f0100c26:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100c29:	a8 07                	test   $0x7,%al
f0100c2b:	74 19                	je     f0100c46 <check_page_free_list+0x16a>
f0100c2d:	68 88 40 10 f0       	push   $0xf0104088
f0100c32:	68 64 3d 10 f0       	push   $0xf0103d64
f0100c37:	68 5d 02 00 00       	push   $0x25d
f0100c3c:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100c41:	e8 c1 f4 ff ff       	call   f0100107 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c46:	c1 f8 03             	sar    $0x3,%eax
f0100c49:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c4c:	85 c0                	test   %eax,%eax
f0100c4e:	75 19                	jne    f0100c69 <check_page_free_list+0x18d>
f0100c50:	68 8d 3d 10 f0       	push   $0xf0103d8d
f0100c55:	68 64 3d 10 f0       	push   $0xf0103d64
f0100c5a:	68 60 02 00 00       	push   $0x260
f0100c5f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100c64:	e8 9e f4 ff ff       	call   f0100107 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c69:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c6e:	75 19                	jne    f0100c89 <check_page_free_list+0x1ad>
f0100c70:	68 9e 3d 10 f0       	push   $0xf0103d9e
f0100c75:	68 64 3d 10 f0       	push   $0xf0103d64
f0100c7a:	68 61 02 00 00       	push   $0x261
f0100c7f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100c84:	e8 7e f4 ff ff       	call   f0100107 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c89:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c8e:	75 19                	jne    f0100ca9 <check_page_free_list+0x1cd>
f0100c90:	68 bc 40 10 f0       	push   $0xf01040bc
f0100c95:	68 64 3d 10 f0       	push   $0xf0103d64
f0100c9a:	68 62 02 00 00       	push   $0x262
f0100c9f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100ca4:	e8 5e f4 ff ff       	call   f0100107 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ca9:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100cae:	75 19                	jne    f0100cc9 <check_page_free_list+0x1ed>
f0100cb0:	68 b7 3d 10 f0       	push   $0xf0103db7
f0100cb5:	68 64 3d 10 f0       	push   $0xf0103d64
f0100cba:	68 63 02 00 00       	push   $0x263
f0100cbf:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100cc4:	e8 3e f4 ff ff       	call   f0100107 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cc9:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cce:	76 3f                	jbe    f0100d0f <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cd0:	89 c3                	mov    %eax,%ebx
f0100cd2:	c1 eb 0c             	shr    $0xc,%ebx
f0100cd5:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100cd8:	77 12                	ja     f0100cec <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cda:	50                   	push   %eax
f0100cdb:	68 40 40 10 f0       	push   $0xf0104040
f0100ce0:	6a 52                	push   $0x52
f0100ce2:	68 4a 3d 10 f0       	push   $0xf0103d4a
f0100ce7:	e8 1b f4 ff ff       	call   f0100107 <_panic>
f0100cec:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cf1:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100cf4:	76 1e                	jbe    f0100d14 <check_page_free_list+0x238>
f0100cf6:	68 e0 40 10 f0       	push   $0xf01040e0
f0100cfb:	68 64 3d 10 f0       	push   $0xf0103d64
f0100d00:	68 64 02 00 00       	push   $0x264
f0100d05:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100d0a:	e8 f8 f3 ff ff       	call   f0100107 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d0f:	83 c6 01             	add    $0x1,%esi
f0100d12:	eb 04                	jmp    f0100d18 <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100d14:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d18:	8b 12                	mov    (%edx),%edx
f0100d1a:	85 d2                	test   %edx,%edx
f0100d1c:	0f 85 c8 fe ff ff    	jne    f0100bea <check_page_free_list+0x10e>
f0100d22:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d25:	85 f6                	test   %esi,%esi
f0100d27:	7f 19                	jg     f0100d42 <check_page_free_list+0x266>
f0100d29:	68 d1 3d 10 f0       	push   $0xf0103dd1
f0100d2e:	68 64 3d 10 f0       	push   $0xf0103d64
f0100d33:	68 6c 02 00 00       	push   $0x26c
f0100d38:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100d3d:	e8 c5 f3 ff ff       	call   f0100107 <_panic>
	assert(nfree_extmem > 0);
f0100d42:	85 db                	test   %ebx,%ebx
f0100d44:	7f 19                	jg     f0100d5f <check_page_free_list+0x283>
f0100d46:	68 e3 3d 10 f0       	push   $0xf0103de3
f0100d4b:	68 64 3d 10 f0       	push   $0xf0103d64
f0100d50:	68 6d 02 00 00       	push   $0x26d
f0100d55:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100d5a:	e8 a8 f3 ff ff       	call   f0100107 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d5f:	83 ec 0c             	sub    $0xc,%esp
f0100d62:	68 28 41 10 f0       	push   $0xf0104128
f0100d67:	e8 b1 1a 00 00       	call   f010281d <cprintf>
}
f0100d6c:	eb 29                	jmp    f0100d97 <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d6e:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100d73:	85 c0                	test   %eax,%eax
f0100d75:	0f 85 8e fd ff ff    	jne    f0100b09 <check_page_free_list+0x2d>
f0100d7b:	e9 72 fd ff ff       	jmp    f0100af2 <check_page_free_list+0x16>
f0100d80:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100d87:	0f 84 65 fd ff ff    	je     f0100af2 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d8d:	be 00 04 00 00       	mov    $0x400,%esi
f0100d92:	e9 c0 fd ff ff       	jmp    f0100b57 <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d9a:	5b                   	pop    %ebx
f0100d9b:	5e                   	pop    %esi
f0100d9c:	5f                   	pop    %edi
f0100d9d:	5d                   	pop    %ebp
f0100d9e:	c3                   	ret    

f0100d9f <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d9f:	55                   	push   %ebp
f0100da0:	89 e5                	mov    %esp,%ebp
f0100da2:	57                   	push   %edi
f0100da3:	56                   	push   %esi
f0100da4:	53                   	push   %ebx
f0100da5:	83 ec 0c             	sub    $0xc,%esp


	size_t i, npages_basemem, ext_allocated;

	// call nvram_read and get the page number of base memory;
	npages_basemem = nvram_read(NVRAM_BASELO) / (PGSIZE / 1024);
f0100da8:	b8 15 00 00 00       	mov    $0x15,%eax
f0100dad:	e8 35 fc ff ff       	call   f01009e7 <nvram_read>
f0100db2:	8d 50 03             	lea    0x3(%eax),%edx
f0100db5:	85 c0                	test   %eax,%eax
f0100db7:	0f 48 c2             	cmovs  %edx,%eax
f0100dba:	89 c3                	mov    %eax,%ebx
f0100dbc:	c1 fb 02             	sar    $0x2,%ebx

	// get the page number of allocated extended memory;
	ext_allocated = ((size_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f0100dbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dc4:	e8 47 fc ff ff       	call   f0100a10 <boot_alloc>
f0100dc9:	05 00 00 00 10       	add    $0x10000000,%eax
f0100dce:	c1 e8 0c             	shr    $0xc,%eax
	// marks the physical page 0 as in use;
	pages[0].pp_ref = 1;
f0100dd1:	8b 15 50 79 11 f0    	mov    0xf0117950,%edx
f0100dd7:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
f0100ddd:	8b 3d 3c 75 11 f0    	mov    0xf011753c,%edi

	// marks the rest base memory is free;
	for (i = 1; i < npages_basemem; i++)
f0100de3:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100de8:	ba 01 00 00 00       	mov    $0x1,%edx
f0100ded:	eb 27                	jmp    f0100e16 <page_init+0x77>
	{
		pages[i].pp_ref = 0;
f0100def:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100df6:	89 ce                	mov    %ecx,%esi
f0100df8:	03 35 50 79 11 f0    	add    0xf0117950,%esi
f0100dfe:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
		pages[i].pp_link = page_free_list;
f0100e04:	89 3e                	mov    %edi,(%esi)
	ext_allocated = ((size_t)boot_alloc(0) - KERNBASE) / PGSIZE;
	// marks the physical page 0 as in use;
	pages[0].pp_ref = 1;

	// marks the rest base memory is free;
	for (i = 1; i < npages_basemem; i++)
f0100e06:	83 c2 01             	add    $0x1,%edx
	{
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100e09:	89 cf                	mov    %ecx,%edi
f0100e0b:	03 3d 50 79 11 f0    	add    0xf0117950,%edi
f0100e11:	b9 01 00 00 00       	mov    $0x1,%ecx
	ext_allocated = ((size_t)boot_alloc(0) - KERNBASE) / PGSIZE;
	// marks the physical page 0 as in use;
	pages[0].pp_ref = 1;

	// marks the rest base memory is free;
	for (i = 1; i < npages_basemem; i++)
f0100e16:	39 da                	cmp    %ebx,%edx
f0100e18:	72 d5                	jb     f0100def <page_init+0x50>
f0100e1a:	84 c9                	test   %cl,%cl
f0100e1c:	74 06                	je     f0100e24 <page_init+0x85>
f0100e1e:	89 3d 3c 75 11 f0    	mov    %edi,0xf011753c
	}

	// marks the IO hole memory and the top extended memory as used;
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE + ext_allocated; i++)
	{
		pages[i].pp_ref = 1;
f0100e24:	8b 1d 50 79 11 f0    	mov    0xf0117950,%ebx
f0100e2a:	b9 a0 00 00 00       	mov    $0xa0,%ecx
f0100e2f:	eb 0a                	jmp    f0100e3b <page_init+0x9c>
f0100e31:	66 c7 44 cb 04 01 00 	movw   $0x1,0x4(%ebx,%ecx,8)
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	// marks the IO hole memory and the top extended memory as used;
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE + ext_allocated; i++)
f0100e38:	83 c1 01             	add    $0x1,%ecx
f0100e3b:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100e41:	39 d1                	cmp    %edx,%ecx
f0100e43:	72 ec                	jb     f0100e31 <page_init+0x92>
f0100e45:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100e4b:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100e52:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e57:	eb 23                	jmp    f0100e7c <page_init+0xdd>
	}

	// marks the rest extended memory as free;
	for (i = EXTPHYSMEM / PGSIZE + ext_allocated; i < npages; i++)
	{
		pages[i].pp_ref = 0;
f0100e59:	89 c1                	mov    %eax,%ecx
f0100e5b:	03 0d 50 79 11 f0    	add    0xf0117950,%ecx
f0100e61:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100e67:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100e69:	89 c3                	mov    %eax,%ebx
f0100e6b:	03 1d 50 79 11 f0    	add    0xf0117950,%ebx
	{
		pages[i].pp_ref = 1;
	}

	// marks the rest extended memory as free;
	for (i = EXTPHYSMEM / PGSIZE + ext_allocated; i < npages; i++)
f0100e71:	83 c2 01             	add    $0x1,%edx
f0100e74:	83 c0 08             	add    $0x8,%eax
f0100e77:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100e7c:	3b 15 48 79 11 f0    	cmp    0xf0117948,%edx
f0100e82:	72 d5                	jb     f0100e59 <page_init+0xba>
f0100e84:	84 c9                	test   %cl,%cl
f0100e86:	74 06                	je     f0100e8e <page_init+0xef>
f0100e88:	89 1d 3c 75 11 f0    	mov    %ebx,0xf011753c
	{
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100e8e:	83 c4 0c             	add    $0xc,%esp
f0100e91:	5b                   	pop    %ebx
f0100e92:	5e                   	pop    %esi
f0100e93:	5f                   	pop    %edi
f0100e94:	5d                   	pop    %ebp
f0100e95:	c3                   	ret    

f0100e96 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e96:	55                   	push   %ebp
f0100e97:	89 e5                	mov    %esp,%ebp
f0100e99:	53                   	push   %ebx
f0100e9a:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo *page;
	if (!page_free_list)
f0100e9d:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100ea3:	85 db                	test   %ebx,%ebx
f0100ea5:	74 58                	je     f0100eff <page_alloc+0x69>
	{
		return NULL;
	}
	page = page_free_list;
	page_free_list = page_free_list->pp_link;
f0100ea7:	8b 03                	mov    (%ebx),%eax
f0100ea9:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	page->pp_link = NULL;
f0100eae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO)
f0100eb4:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100eb8:	74 45                	je     f0100eff <page_alloc+0x69>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100eba:	89 d8                	mov    %ebx,%eax
f0100ebc:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f0100ec2:	c1 f8 03             	sar    $0x3,%eax
f0100ec5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ec8:	89 c2                	mov    %eax,%edx
f0100eca:	c1 ea 0c             	shr    $0xc,%edx
f0100ecd:	3b 15 48 79 11 f0    	cmp    0xf0117948,%edx
f0100ed3:	72 12                	jb     f0100ee7 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ed5:	50                   	push   %eax
f0100ed6:	68 40 40 10 f0       	push   $0xf0104040
f0100edb:	6a 52                	push   $0x52
f0100edd:	68 4a 3d 10 f0       	push   $0xf0103d4a
f0100ee2:	e8 20 f2 ff ff       	call   f0100107 <_panic>
	{
		memset(page2kva(page), 0, PGSIZE);
f0100ee7:	83 ec 04             	sub    $0x4,%esp
f0100eea:	68 00 10 00 00       	push   $0x1000
f0100eef:	6a 00                	push   $0x0
f0100ef1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ef6:	50                   	push   %eax
f0100ef7:	e8 00 24 00 00       	call   f01032fc <memset>
f0100efc:	83 c4 10             	add    $0x10,%esp
	}
	return page;
}
f0100eff:	89 d8                	mov    %ebx,%eax
f0100f01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f04:	c9                   	leave  
f0100f05:	c3                   	ret    

f0100f06 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f06:	55                   	push   %ebp
f0100f07:	89 e5                	mov    %esp,%ebp
f0100f09:	83 ec 08             	sub    $0x8,%esp
f0100f0c:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	assert(pp->pp_ref == 0);
f0100f0f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f14:	74 19                	je     f0100f2f <page_free+0x29>
f0100f16:	68 f4 3d 10 f0       	push   $0xf0103df4
f0100f1b:	68 64 3d 10 f0       	push   $0xf0103d64
f0100f20:	68 59 01 00 00       	push   $0x159
f0100f25:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100f2a:	e8 d8 f1 ff ff       	call   f0100107 <_panic>
	assert(!pp->pp_link);
f0100f2f:	83 38 00             	cmpl   $0x0,(%eax)
f0100f32:	74 19                	je     f0100f4d <page_free+0x47>
f0100f34:	68 04 3e 10 f0       	push   $0xf0103e04
f0100f39:	68 64 3d 10 f0       	push   $0xf0103d64
f0100f3e:	68 5a 01 00 00       	push   $0x15a
f0100f43:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100f48:	e8 ba f1 ff ff       	call   f0100107 <_panic>
	pp->pp_link = page_free_list;
f0100f4d:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100f53:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f55:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
	return;
}
f0100f5a:	c9                   	leave  
f0100f5b:	c3                   	ret    

f0100f5c <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f5c:	55                   	push   %ebp
f0100f5d:	89 e5                	mov    %esp,%ebp
f0100f5f:	83 ec 08             	sub    $0x8,%esp
f0100f62:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f65:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f69:	83 e8 01             	sub    $0x1,%eax
f0100f6c:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f70:	66 85 c0             	test   %ax,%ax
f0100f73:	75 0c                	jne    f0100f81 <page_decref+0x25>
		page_free(pp);
f0100f75:	83 ec 0c             	sub    $0xc,%esp
f0100f78:	52                   	push   %edx
f0100f79:	e8 88 ff ff ff       	call   f0100f06 <page_free>
f0100f7e:	83 c4 10             	add    $0x10,%esp
}
f0100f81:	c9                   	leave  
f0100f82:	c3                   	ret    

f0100f83 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f83:	55                   	push   %ebp
f0100f84:	89 e5                	mov    %esp,%ebp
f0100f86:	56                   	push   %esi
f0100f87:	53                   	push   %ebx
f0100f88:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pde_t *pde = NULL;
	pte_t *page_base = NULL;
	uint32_t page_off;
	struct PageInfo *page = NULL;
	pde = &pgdir[PDX(va)];
f0100f8b:	89 f3                	mov    %esi,%ebx
f0100f8d:	c1 eb 16             	shr    $0x16,%ebx
f0100f90:	c1 e3 02             	shl    $0x2,%ebx
f0100f93:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*pde & PTE_P))
f0100f96:	f6 03 01             	testb  $0x1,(%ebx)
f0100f99:	75 2d                	jne    f0100fc8 <pgdir_walk+0x45>
	{
		if (create)
f0100f9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f9f:	74 62                	je     f0101003 <pgdir_walk+0x80>
		{
			page = page_alloc(1);
f0100fa1:	83 ec 0c             	sub    $0xc,%esp
f0100fa4:	6a 01                	push   $0x1
f0100fa6:	e8 eb fe ff ff       	call   f0100e96 <page_alloc>
			if (!page)
f0100fab:	83 c4 10             	add    $0x10,%esp
f0100fae:	85 c0                	test   %eax,%eax
f0100fb0:	74 58                	je     f010100a <pgdir_walk+0x87>
			{
				return NULL;
			}
			page->pp_ref++;
f0100fb2:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f0100fb7:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f0100fbd:	c1 f8 03             	sar    $0x3,%eax
f0100fc0:	c1 e0 0c             	shl    $0xc,%eax
f0100fc3:	83 c8 07             	or     $0x7,%eax
f0100fc6:	89 03                	mov    %eax,(%ebx)
		else
		{
			return NULL;
		}
	}
	page_base = KADDR(PTE_ADDR(*pde));
f0100fc8:	8b 03                	mov    (%ebx),%eax
f0100fca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fcf:	89 c2                	mov    %eax,%edx
f0100fd1:	c1 ea 0c             	shr    $0xc,%edx
f0100fd4:	3b 15 48 79 11 f0    	cmp    0xf0117948,%edx
f0100fda:	72 15                	jb     f0100ff1 <pgdir_walk+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fdc:	50                   	push   %eax
f0100fdd:	68 40 40 10 f0       	push   $0xf0104040
f0100fe2:	68 9b 01 00 00       	push   $0x19b
f0100fe7:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0100fec:	e8 16 f1 ff ff       	call   f0100107 <_panic>
	page_off = PTX(va);
	return &page_base[page_off];
f0100ff1:	c1 ee 0a             	shr    $0xa,%esi
f0100ff4:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100ffa:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0101001:	eb 0c                	jmp    f010100f <pgdir_walk+0x8c>
			page->pp_ref++;
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
		}	
		else
		{
			return NULL;
f0101003:	b8 00 00 00 00       	mov    $0x0,%eax
f0101008:	eb 05                	jmp    f010100f <pgdir_walk+0x8c>
		if (create)
		{
			page = page_alloc(1);
			if (!page)
			{
				return NULL;
f010100a:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}
	page_base = KADDR(PTE_ADDR(*pde));
	page_off = PTX(va);
	return &page_base[page_off];
}
f010100f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101012:	5b                   	pop    %ebx
f0101013:	5e                   	pop    %esi
f0101014:	5d                   	pop    %ebp
f0101015:	c3                   	ret    

f0101016 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101016:	55                   	push   %ebp
f0101017:	89 e5                	mov    %esp,%ebp
f0101019:	57                   	push   %edi
f010101a:	56                   	push   %esi
f010101b:	53                   	push   %ebx
f010101c:	83 ec 1c             	sub    $0x1c,%esp
f010101f:	89 c7                	mov    %eax,%edi
f0101021:	89 d6                	mov    %edx,%esi
f0101023:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	size_t i;
	pte_t *pte = NULL;
	for (i = 0; i < size; i += PGSIZE)
f0101026:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		*pte = (pa + i) | perm | PTE_P;
f010102b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010102e:	83 c8 01             	or     $0x1,%eax
f0101031:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	size_t i;
	pte_t *pte = NULL;
	for (i = 0; i < size; i += PGSIZE)
f0101034:	eb 22                	jmp    f0101058 <boot_map_region+0x42>
	{
		pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f0101036:	83 ec 04             	sub    $0x4,%esp
f0101039:	6a 01                	push   $0x1
f010103b:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f010103e:	50                   	push   %eax
f010103f:	57                   	push   %edi
f0101040:	e8 3e ff ff ff       	call   f0100f83 <pgdir_walk>
		*pte = (pa + i) | perm | PTE_P;
f0101045:	89 da                	mov    %ebx,%edx
f0101047:	03 55 08             	add    0x8(%ebp),%edx
f010104a:	0b 55 e0             	or     -0x20(%ebp),%edx
f010104d:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	size_t i;
	pte_t *pte = NULL;
	for (i = 0; i < size; i += PGSIZE)
f010104f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101055:	83 c4 10             	add    $0x10,%esp
f0101058:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010105b:	72 d9                	jb     f0101036 <boot_map_region+0x20>
	{
		pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		*pte = (pa + i) | perm | PTE_P;
	}
	return;
}
f010105d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101060:	5b                   	pop    %ebx
f0101061:	5e                   	pop    %esi
f0101062:	5f                   	pop    %edi
f0101063:	5d                   	pop    %ebp
f0101064:	c3                   	ret    

f0101065 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101065:	55                   	push   %ebp
f0101066:	89 e5                	mov    %esp,%ebp
f0101068:	53                   	push   %ebx
f0101069:	83 ec 08             	sub    $0x8,%esp
f010106c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte;
	struct PageInfo *page;
	pte = pgdir_walk(pgdir, va, 0);
f010106f:	6a 00                	push   $0x0
f0101071:	ff 75 0c             	pushl  0xc(%ebp)
f0101074:	ff 75 08             	pushl  0x8(%ebp)
f0101077:	e8 07 ff ff ff       	call   f0100f83 <pgdir_walk>
	if (!pte)
f010107c:	83 c4 10             	add    $0x10,%esp
f010107f:	85 c0                	test   %eax,%eax
f0101081:	74 32                	je     f01010b5 <page_lookup+0x50>
	{
		return NULL;
	}
	if (pte_store)
f0101083:	85 db                	test   %ebx,%ebx
f0101085:	74 02                	je     f0101089 <page_lookup+0x24>
	{
		*pte_store = pte;
f0101087:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101089:	8b 00                	mov    (%eax),%eax
f010108b:	c1 e8 0c             	shr    $0xc,%eax
f010108e:	3b 05 48 79 11 f0    	cmp    0xf0117948,%eax
f0101094:	72 14                	jb     f01010aa <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f0101096:	83 ec 04             	sub    $0x4,%esp
f0101099:	68 4c 41 10 f0       	push   $0xf010414c
f010109e:	6a 4b                	push   $0x4b
f01010a0:	68 4a 3d 10 f0       	push   $0xf0103d4a
f01010a5:	e8 5d f0 ff ff       	call   f0100107 <_panic>
	return &pages[PGNUM(pa)];
f01010aa:	8b 15 50 79 11 f0    	mov    0xf0117950,%edx
f01010b0:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	}
	page = pa2page(PTE_ADDR(*pte));
	return page;
f01010b3:	eb 05                	jmp    f01010ba <page_lookup+0x55>
	pte_t *pte;
	struct PageInfo *page;
	pte = pgdir_walk(pgdir, va, 0);
	if (!pte)
	{
		return NULL;
f01010b5:	b8 00 00 00 00       	mov    $0x0,%eax
	{
		*pte_store = pte;
	}
	page = pa2page(PTE_ADDR(*pte));
	return page;
}
f01010ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010bd:	c9                   	leave  
f01010be:	c3                   	ret    

f01010bf <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01010bf:	55                   	push   %ebp
f01010c0:	89 e5                	mov    %esp,%ebp
f01010c2:	53                   	push   %ebx
f01010c3:	83 ec 18             	sub    $0x18,%esp
f01010c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte = NULL;
f01010c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	pde_t *pde = NULL;
	struct PageInfo *page = NULL;
	pde = &pgdir[PDX(va)];
	page = page_lookup(pgdir, va, &pte);
f01010d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010d3:	50                   	push   %eax
f01010d4:	53                   	push   %ebx
f01010d5:	ff 75 08             	pushl  0x8(%ebp)
f01010d8:	e8 88 ff ff ff       	call   f0101065 <page_lookup>
	if (!page)
f01010dd:	83 c4 10             	add    $0x10,%esp
f01010e0:	85 c0                	test   %eax,%eax
f01010e2:	74 18                	je     f01010fc <page_remove+0x3d>
	{
		return;
	}
	page_decref(page);
f01010e4:	83 ec 0c             	sub    $0xc,%esp
f01010e7:	50                   	push   %eax
f01010e8:	e8 6f fe ff ff       	call   f0100f5c <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010ed:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
	*pte = 0;
f01010f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return;
f01010f9:	83 c4 10             	add    $0x10,%esp
}
f01010fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010ff:	c9                   	leave  
f0101100:	c3                   	ret    

f0101101 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101101:	55                   	push   %ebp
f0101102:	89 e5                	mov    %esp,%ebp
f0101104:	57                   	push   %edi
f0101105:	56                   	push   %esi
f0101106:	53                   	push   %ebx
f0101107:	83 ec 10             	sub    $0x10,%esp
f010110a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
	pde_t *pde;
	pte = pgdir_walk(pgdir, va, 1);
f010110d:	6a 01                	push   $0x1
f010110f:	ff 75 10             	pushl  0x10(%ebp)
f0101112:	ff 75 08             	pushl  0x8(%ebp)
f0101115:	e8 69 fe ff ff       	call   f0100f83 <pgdir_walk>
f010111a:	89 c6                	mov    %eax,%esi
	pde = &pgdir[PDX(va)];
f010111c:	8b 45 10             	mov    0x10(%ebp),%eax
f010111f:	c1 e8 16             	shr    $0x16,%eax
f0101122:	8b 55 08             	mov    0x8(%ebp),%edx
f0101125:	8d 3c 82             	lea    (%edx,%eax,4),%edi
	if (!pte)
f0101128:	83 c4 10             	add    $0x10,%esp
f010112b:	85 f6                	test   %esi,%esi
f010112d:	74 3b                	je     f010116a <page_insert+0x69>
	{
		return -E_NO_MEM;
	}
	pp->pp_ref++;
f010112f:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if ((*pte) & PTE_P)
f0101134:	f6 06 01             	testb  $0x1,(%esi)
f0101137:	74 0f                	je     f0101148 <page_insert+0x47>
	{
		page_remove(pgdir, va);
f0101139:	83 ec 08             	sub    $0x8,%esp
f010113c:	ff 75 10             	pushl  0x10(%ebp)
f010113f:	52                   	push   %edx
f0101140:	e8 7a ff ff ff       	call   f01010bf <page_remove>
f0101145:	83 c4 10             	add    $0x10,%esp
	}
	*pte = page2pa(pp) | perm | PTE_P;
f0101148:	2b 1d 50 79 11 f0    	sub    0xf0117950,%ebx
f010114e:	c1 fb 03             	sar    $0x3,%ebx
f0101151:	c1 e3 0c             	shl    $0xc,%ebx
f0101154:	8b 45 14             	mov    0x14(%ebp),%eax
f0101157:	83 c8 01             	or     $0x1,%eax
f010115a:	09 c3                	or     %eax,%ebx
f010115c:	89 1e                	mov    %ebx,(%esi)
	*pde = *pde | perm;
f010115e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101161:	09 07                	or     %eax,(%edi)
	return 0;
f0101163:	b8 00 00 00 00       	mov    $0x0,%eax
f0101168:	eb 05                	jmp    f010116f <page_insert+0x6e>
	pde_t *pde;
	pte = pgdir_walk(pgdir, va, 1);
	pde = &pgdir[PDX(va)];
	if (!pte)
	{
		return -E_NO_MEM;
f010116a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
		page_remove(pgdir, va);
	}
	*pte = page2pa(pp) | perm | PTE_P;
	*pde = *pde | perm;
	return 0;
}
f010116f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101172:	5b                   	pop    %ebx
f0101173:	5e                   	pop    %esi
f0101174:	5f                   	pop    %edi
f0101175:	5d                   	pop    %ebp
f0101176:	c3                   	ret    

f0101177 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101177:	55                   	push   %ebp
f0101178:	89 e5                	mov    %esp,%ebp
f010117a:	57                   	push   %edi
f010117b:	56                   	push   %esi
f010117c:	53                   	push   %ebx
f010117d:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101180:	b8 15 00 00 00       	mov    $0x15,%eax
f0101185:	e8 5d f8 ff ff       	call   f01009e7 <nvram_read>
f010118a:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010118c:	b8 17 00 00 00       	mov    $0x17,%eax
f0101191:	e8 51 f8 ff ff       	call   f01009e7 <nvram_read>
f0101196:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101198:	b8 34 00 00 00       	mov    $0x34,%eax
f010119d:	e8 45 f8 ff ff       	call   f01009e7 <nvram_read>
f01011a2:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01011a5:	85 c0                	test   %eax,%eax
f01011a7:	74 07                	je     f01011b0 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01011a9:	05 00 40 00 00       	add    $0x4000,%eax
f01011ae:	eb 0b                	jmp    f01011bb <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01011b0:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01011b6:	85 f6                	test   %esi,%esi
f01011b8:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01011bb:	89 c2                	mov    %eax,%edx
f01011bd:	c1 ea 02             	shr    $0x2,%edx
f01011c0:	89 15 48 79 11 f0    	mov    %edx,0xf0117948
	npages_basemem = basemem / (PGSIZE / 1024);
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011c6:	89 c2                	mov    %eax,%edx
f01011c8:	29 da                	sub    %ebx,%edx
f01011ca:	52                   	push   %edx
f01011cb:	53                   	push   %ebx
f01011cc:	50                   	push   %eax
f01011cd:	68 6c 41 10 f0       	push   $0xf010416c
f01011d2:	e8 46 16 00 00       	call   f010281d <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011d7:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011dc:	e8 2f f8 ff ff       	call   f0100a10 <boot_alloc>
f01011e1:	a3 4c 79 11 f0       	mov    %eax,0xf011794c
	memset(kern_pgdir, 0, PGSIZE);
f01011e6:	83 c4 0c             	add    $0xc,%esp
f01011e9:	68 00 10 00 00       	push   $0x1000
f01011ee:	6a 00                	push   $0x0
f01011f0:	50                   	push   %eax
f01011f1:	e8 06 21 00 00       	call   f01032fc <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011f6:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011fb:	83 c4 10             	add    $0x10,%esp
f01011fe:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101203:	77 15                	ja     f010121a <mem_init+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101205:	50                   	push   %eax
f0101206:	68 a8 41 10 f0       	push   $0xf01041a8
f010120b:	68 93 00 00 00       	push   $0x93
f0101210:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101215:	e8 ed ee ff ff       	call   f0100107 <_panic>
f010121a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101220:	83 ca 05             	or     $0x5,%edx
f0101223:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101229:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f010122e:	c1 e0 03             	shl    $0x3,%eax
f0101231:	e8 da f7 ff ff       	call   f0100a10 <boot_alloc>
f0101236:	a3 50 79 11 f0       	mov    %eax,0xf0117950
	memset(pages, 0, npages * sizeof(struct PageInfo));
f010123b:	83 ec 04             	sub    $0x4,%esp
f010123e:	8b 0d 48 79 11 f0    	mov    0xf0117948,%ecx
f0101244:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010124b:	52                   	push   %edx
f010124c:	6a 00                	push   $0x0
f010124e:	50                   	push   %eax
f010124f:	e8 a8 20 00 00       	call   f01032fc <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101254:	e8 46 fb ff ff       	call   f0100d9f <page_init>

	check_page_free_list(1);
f0101259:	b8 01 00 00 00       	mov    $0x1,%eax
f010125e:	e8 79 f8 ff ff       	call   f0100adc <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101263:	83 c4 10             	add    $0x10,%esp
f0101266:	83 3d 50 79 11 f0 00 	cmpl   $0x0,0xf0117950
f010126d:	75 17                	jne    f0101286 <mem_init+0x10f>
		panic("'pages' is a null pointer!");
f010126f:	83 ec 04             	sub    $0x4,%esp
f0101272:	68 11 3e 10 f0       	push   $0xf0103e11
f0101277:	68 80 02 00 00       	push   $0x280
f010127c:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101281:	e8 81 ee ff ff       	call   f0100107 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101286:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010128b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101290:	eb 05                	jmp    f0101297 <mem_init+0x120>
		++nfree;
f0101292:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101295:	8b 00                	mov    (%eax),%eax
f0101297:	85 c0                	test   %eax,%eax
f0101299:	75 f7                	jne    f0101292 <mem_init+0x11b>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010129b:	83 ec 0c             	sub    $0xc,%esp
f010129e:	6a 00                	push   $0x0
f01012a0:	e8 f1 fb ff ff       	call   f0100e96 <page_alloc>
f01012a5:	89 c7                	mov    %eax,%edi
f01012a7:	83 c4 10             	add    $0x10,%esp
f01012aa:	85 c0                	test   %eax,%eax
f01012ac:	75 19                	jne    f01012c7 <mem_init+0x150>
f01012ae:	68 2c 3e 10 f0       	push   $0xf0103e2c
f01012b3:	68 64 3d 10 f0       	push   $0xf0103d64
f01012b8:	68 88 02 00 00       	push   $0x288
f01012bd:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01012c2:	e8 40 ee ff ff       	call   f0100107 <_panic>
	assert((pp1 = page_alloc(0)));
f01012c7:	83 ec 0c             	sub    $0xc,%esp
f01012ca:	6a 00                	push   $0x0
f01012cc:	e8 c5 fb ff ff       	call   f0100e96 <page_alloc>
f01012d1:	89 c6                	mov    %eax,%esi
f01012d3:	83 c4 10             	add    $0x10,%esp
f01012d6:	85 c0                	test   %eax,%eax
f01012d8:	75 19                	jne    f01012f3 <mem_init+0x17c>
f01012da:	68 42 3e 10 f0       	push   $0xf0103e42
f01012df:	68 64 3d 10 f0       	push   $0xf0103d64
f01012e4:	68 89 02 00 00       	push   $0x289
f01012e9:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01012ee:	e8 14 ee ff ff       	call   f0100107 <_panic>
	assert((pp2 = page_alloc(0)));
f01012f3:	83 ec 0c             	sub    $0xc,%esp
f01012f6:	6a 00                	push   $0x0
f01012f8:	e8 99 fb ff ff       	call   f0100e96 <page_alloc>
f01012fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101300:	83 c4 10             	add    $0x10,%esp
f0101303:	85 c0                	test   %eax,%eax
f0101305:	75 19                	jne    f0101320 <mem_init+0x1a9>
f0101307:	68 58 3e 10 f0       	push   $0xf0103e58
f010130c:	68 64 3d 10 f0       	push   $0xf0103d64
f0101311:	68 8a 02 00 00       	push   $0x28a
f0101316:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010131b:	e8 e7 ed ff ff       	call   f0100107 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101320:	39 f7                	cmp    %esi,%edi
f0101322:	75 19                	jne    f010133d <mem_init+0x1c6>
f0101324:	68 6e 3e 10 f0       	push   $0xf0103e6e
f0101329:	68 64 3d 10 f0       	push   $0xf0103d64
f010132e:	68 8d 02 00 00       	push   $0x28d
f0101333:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101338:	e8 ca ed ff ff       	call   f0100107 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010133d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101340:	39 c6                	cmp    %eax,%esi
f0101342:	74 04                	je     f0101348 <mem_init+0x1d1>
f0101344:	39 c7                	cmp    %eax,%edi
f0101346:	75 19                	jne    f0101361 <mem_init+0x1ea>
f0101348:	68 cc 41 10 f0       	push   $0xf01041cc
f010134d:	68 64 3d 10 f0       	push   $0xf0103d64
f0101352:	68 8e 02 00 00       	push   $0x28e
f0101357:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010135c:	e8 a6 ed ff ff       	call   f0100107 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101361:	8b 0d 50 79 11 f0    	mov    0xf0117950,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101367:	8b 15 48 79 11 f0    	mov    0xf0117948,%edx
f010136d:	c1 e2 0c             	shl    $0xc,%edx
f0101370:	89 f8                	mov    %edi,%eax
f0101372:	29 c8                	sub    %ecx,%eax
f0101374:	c1 f8 03             	sar    $0x3,%eax
f0101377:	c1 e0 0c             	shl    $0xc,%eax
f010137a:	39 d0                	cmp    %edx,%eax
f010137c:	72 19                	jb     f0101397 <mem_init+0x220>
f010137e:	68 80 3e 10 f0       	push   $0xf0103e80
f0101383:	68 64 3d 10 f0       	push   $0xf0103d64
f0101388:	68 8f 02 00 00       	push   $0x28f
f010138d:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101392:	e8 70 ed ff ff       	call   f0100107 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101397:	89 f0                	mov    %esi,%eax
f0101399:	29 c8                	sub    %ecx,%eax
f010139b:	c1 f8 03             	sar    $0x3,%eax
f010139e:	c1 e0 0c             	shl    $0xc,%eax
f01013a1:	39 c2                	cmp    %eax,%edx
f01013a3:	77 19                	ja     f01013be <mem_init+0x247>
f01013a5:	68 9d 3e 10 f0       	push   $0xf0103e9d
f01013aa:	68 64 3d 10 f0       	push   $0xf0103d64
f01013af:	68 90 02 00 00       	push   $0x290
f01013b4:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01013b9:	e8 49 ed ff ff       	call   f0100107 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01013be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013c1:	29 c8                	sub    %ecx,%eax
f01013c3:	c1 f8 03             	sar    $0x3,%eax
f01013c6:	c1 e0 0c             	shl    $0xc,%eax
f01013c9:	39 c2                	cmp    %eax,%edx
f01013cb:	77 19                	ja     f01013e6 <mem_init+0x26f>
f01013cd:	68 ba 3e 10 f0       	push   $0xf0103eba
f01013d2:	68 64 3d 10 f0       	push   $0xf0103d64
f01013d7:	68 91 02 00 00       	push   $0x291
f01013dc:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01013e1:	e8 21 ed ff ff       	call   f0100107 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01013e6:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01013eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013ee:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f01013f5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013f8:	83 ec 0c             	sub    $0xc,%esp
f01013fb:	6a 00                	push   $0x0
f01013fd:	e8 94 fa ff ff       	call   f0100e96 <page_alloc>
f0101402:	83 c4 10             	add    $0x10,%esp
f0101405:	85 c0                	test   %eax,%eax
f0101407:	74 19                	je     f0101422 <mem_init+0x2ab>
f0101409:	68 d7 3e 10 f0       	push   $0xf0103ed7
f010140e:	68 64 3d 10 f0       	push   $0xf0103d64
f0101413:	68 98 02 00 00       	push   $0x298
f0101418:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010141d:	e8 e5 ec ff ff       	call   f0100107 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101422:	83 ec 0c             	sub    $0xc,%esp
f0101425:	57                   	push   %edi
f0101426:	e8 db fa ff ff       	call   f0100f06 <page_free>
	page_free(pp1);
f010142b:	89 34 24             	mov    %esi,(%esp)
f010142e:	e8 d3 fa ff ff       	call   f0100f06 <page_free>
	page_free(pp2);
f0101433:	83 c4 04             	add    $0x4,%esp
f0101436:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101439:	e8 c8 fa ff ff       	call   f0100f06 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010143e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101445:	e8 4c fa ff ff       	call   f0100e96 <page_alloc>
f010144a:	89 c6                	mov    %eax,%esi
f010144c:	83 c4 10             	add    $0x10,%esp
f010144f:	85 c0                	test   %eax,%eax
f0101451:	75 19                	jne    f010146c <mem_init+0x2f5>
f0101453:	68 2c 3e 10 f0       	push   $0xf0103e2c
f0101458:	68 64 3d 10 f0       	push   $0xf0103d64
f010145d:	68 9f 02 00 00       	push   $0x29f
f0101462:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101467:	e8 9b ec ff ff       	call   f0100107 <_panic>
	assert((pp1 = page_alloc(0)));
f010146c:	83 ec 0c             	sub    $0xc,%esp
f010146f:	6a 00                	push   $0x0
f0101471:	e8 20 fa ff ff       	call   f0100e96 <page_alloc>
f0101476:	89 c7                	mov    %eax,%edi
f0101478:	83 c4 10             	add    $0x10,%esp
f010147b:	85 c0                	test   %eax,%eax
f010147d:	75 19                	jne    f0101498 <mem_init+0x321>
f010147f:	68 42 3e 10 f0       	push   $0xf0103e42
f0101484:	68 64 3d 10 f0       	push   $0xf0103d64
f0101489:	68 a0 02 00 00       	push   $0x2a0
f010148e:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101493:	e8 6f ec ff ff       	call   f0100107 <_panic>
	assert((pp2 = page_alloc(0)));
f0101498:	83 ec 0c             	sub    $0xc,%esp
f010149b:	6a 00                	push   $0x0
f010149d:	e8 f4 f9 ff ff       	call   f0100e96 <page_alloc>
f01014a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014a5:	83 c4 10             	add    $0x10,%esp
f01014a8:	85 c0                	test   %eax,%eax
f01014aa:	75 19                	jne    f01014c5 <mem_init+0x34e>
f01014ac:	68 58 3e 10 f0       	push   $0xf0103e58
f01014b1:	68 64 3d 10 f0       	push   $0xf0103d64
f01014b6:	68 a1 02 00 00       	push   $0x2a1
f01014bb:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01014c0:	e8 42 ec ff ff       	call   f0100107 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014c5:	39 fe                	cmp    %edi,%esi
f01014c7:	75 19                	jne    f01014e2 <mem_init+0x36b>
f01014c9:	68 6e 3e 10 f0       	push   $0xf0103e6e
f01014ce:	68 64 3d 10 f0       	push   $0xf0103d64
f01014d3:	68 a3 02 00 00       	push   $0x2a3
f01014d8:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01014dd:	e8 25 ec ff ff       	call   f0100107 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014e5:	39 c6                	cmp    %eax,%esi
f01014e7:	74 04                	je     f01014ed <mem_init+0x376>
f01014e9:	39 c7                	cmp    %eax,%edi
f01014eb:	75 19                	jne    f0101506 <mem_init+0x38f>
f01014ed:	68 cc 41 10 f0       	push   $0xf01041cc
f01014f2:	68 64 3d 10 f0       	push   $0xf0103d64
f01014f7:	68 a4 02 00 00       	push   $0x2a4
f01014fc:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101501:	e8 01 ec ff ff       	call   f0100107 <_panic>
	assert(!page_alloc(0));
f0101506:	83 ec 0c             	sub    $0xc,%esp
f0101509:	6a 00                	push   $0x0
f010150b:	e8 86 f9 ff ff       	call   f0100e96 <page_alloc>
f0101510:	83 c4 10             	add    $0x10,%esp
f0101513:	85 c0                	test   %eax,%eax
f0101515:	74 19                	je     f0101530 <mem_init+0x3b9>
f0101517:	68 d7 3e 10 f0       	push   $0xf0103ed7
f010151c:	68 64 3d 10 f0       	push   $0xf0103d64
f0101521:	68 a5 02 00 00       	push   $0x2a5
f0101526:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010152b:	e8 d7 eb ff ff       	call   f0100107 <_panic>
f0101530:	89 f0                	mov    %esi,%eax
f0101532:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f0101538:	c1 f8 03             	sar    $0x3,%eax
f010153b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010153e:	89 c2                	mov    %eax,%edx
f0101540:	c1 ea 0c             	shr    $0xc,%edx
f0101543:	3b 15 48 79 11 f0    	cmp    0xf0117948,%edx
f0101549:	72 12                	jb     f010155d <mem_init+0x3e6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010154b:	50                   	push   %eax
f010154c:	68 40 40 10 f0       	push   $0xf0104040
f0101551:	6a 52                	push   $0x52
f0101553:	68 4a 3d 10 f0       	push   $0xf0103d4a
f0101558:	e8 aa eb ff ff       	call   f0100107 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010155d:	83 ec 04             	sub    $0x4,%esp
f0101560:	68 00 10 00 00       	push   $0x1000
f0101565:	6a 01                	push   $0x1
f0101567:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010156c:	50                   	push   %eax
f010156d:	e8 8a 1d 00 00       	call   f01032fc <memset>
	page_free(pp0);
f0101572:	89 34 24             	mov    %esi,(%esp)
f0101575:	e8 8c f9 ff ff       	call   f0100f06 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010157a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101581:	e8 10 f9 ff ff       	call   f0100e96 <page_alloc>
f0101586:	83 c4 10             	add    $0x10,%esp
f0101589:	85 c0                	test   %eax,%eax
f010158b:	75 19                	jne    f01015a6 <mem_init+0x42f>
f010158d:	68 e6 3e 10 f0       	push   $0xf0103ee6
f0101592:	68 64 3d 10 f0       	push   $0xf0103d64
f0101597:	68 aa 02 00 00       	push   $0x2aa
f010159c:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01015a1:	e8 61 eb ff ff       	call   f0100107 <_panic>
	assert(pp && pp0 == pp);
f01015a6:	39 c6                	cmp    %eax,%esi
f01015a8:	74 19                	je     f01015c3 <mem_init+0x44c>
f01015aa:	68 04 3f 10 f0       	push   $0xf0103f04
f01015af:	68 64 3d 10 f0       	push   $0xf0103d64
f01015b4:	68 ab 02 00 00       	push   $0x2ab
f01015b9:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01015be:	e8 44 eb ff ff       	call   f0100107 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015c3:	89 f0                	mov    %esi,%eax
f01015c5:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f01015cb:	c1 f8 03             	sar    $0x3,%eax
f01015ce:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015d1:	89 c2                	mov    %eax,%edx
f01015d3:	c1 ea 0c             	shr    $0xc,%edx
f01015d6:	3b 15 48 79 11 f0    	cmp    0xf0117948,%edx
f01015dc:	72 12                	jb     f01015f0 <mem_init+0x479>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015de:	50                   	push   %eax
f01015df:	68 40 40 10 f0       	push   $0xf0104040
f01015e4:	6a 52                	push   $0x52
f01015e6:	68 4a 3d 10 f0       	push   $0xf0103d4a
f01015eb:	e8 17 eb ff ff       	call   f0100107 <_panic>
f01015f0:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01015f6:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01015fc:	80 38 00             	cmpb   $0x0,(%eax)
f01015ff:	74 19                	je     f010161a <mem_init+0x4a3>
f0101601:	68 14 3f 10 f0       	push   $0xf0103f14
f0101606:	68 64 3d 10 f0       	push   $0xf0103d64
f010160b:	68 ae 02 00 00       	push   $0x2ae
f0101610:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101615:	e8 ed ea ff ff       	call   f0100107 <_panic>
f010161a:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010161d:	39 d0                	cmp    %edx,%eax
f010161f:	75 db                	jne    f01015fc <mem_init+0x485>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101621:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101624:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f0101629:	83 ec 0c             	sub    $0xc,%esp
f010162c:	56                   	push   %esi
f010162d:	e8 d4 f8 ff ff       	call   f0100f06 <page_free>
	page_free(pp1);
f0101632:	89 3c 24             	mov    %edi,(%esp)
f0101635:	e8 cc f8 ff ff       	call   f0100f06 <page_free>
	page_free(pp2);
f010163a:	83 c4 04             	add    $0x4,%esp
f010163d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101640:	e8 c1 f8 ff ff       	call   f0100f06 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101645:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010164a:	83 c4 10             	add    $0x10,%esp
f010164d:	eb 05                	jmp    f0101654 <mem_init+0x4dd>
		--nfree;
f010164f:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101652:	8b 00                	mov    (%eax),%eax
f0101654:	85 c0                	test   %eax,%eax
f0101656:	75 f7                	jne    f010164f <mem_init+0x4d8>
		--nfree;
	assert(nfree == 0);
f0101658:	85 db                	test   %ebx,%ebx
f010165a:	74 19                	je     f0101675 <mem_init+0x4fe>
f010165c:	68 1e 3f 10 f0       	push   $0xf0103f1e
f0101661:	68 64 3d 10 f0       	push   $0xf0103d64
f0101666:	68 bb 02 00 00       	push   $0x2bb
f010166b:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101670:	e8 92 ea ff ff       	call   f0100107 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101675:	83 ec 0c             	sub    $0xc,%esp
f0101678:	68 ec 41 10 f0       	push   $0xf01041ec
f010167d:	e8 9b 11 00 00       	call   f010281d <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101682:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101689:	e8 08 f8 ff ff       	call   f0100e96 <page_alloc>
f010168e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101691:	83 c4 10             	add    $0x10,%esp
f0101694:	85 c0                	test   %eax,%eax
f0101696:	75 19                	jne    f01016b1 <mem_init+0x53a>
f0101698:	68 2c 3e 10 f0       	push   $0xf0103e2c
f010169d:	68 64 3d 10 f0       	push   $0xf0103d64
f01016a2:	68 17 03 00 00       	push   $0x317
f01016a7:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01016ac:	e8 56 ea ff ff       	call   f0100107 <_panic>
	assert((pp1 = page_alloc(0)));
f01016b1:	83 ec 0c             	sub    $0xc,%esp
f01016b4:	6a 00                	push   $0x0
f01016b6:	e8 db f7 ff ff       	call   f0100e96 <page_alloc>
f01016bb:	89 c3                	mov    %eax,%ebx
f01016bd:	83 c4 10             	add    $0x10,%esp
f01016c0:	85 c0                	test   %eax,%eax
f01016c2:	75 19                	jne    f01016dd <mem_init+0x566>
f01016c4:	68 42 3e 10 f0       	push   $0xf0103e42
f01016c9:	68 64 3d 10 f0       	push   $0xf0103d64
f01016ce:	68 18 03 00 00       	push   $0x318
f01016d3:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01016d8:	e8 2a ea ff ff       	call   f0100107 <_panic>
	assert((pp2 = page_alloc(0)));
f01016dd:	83 ec 0c             	sub    $0xc,%esp
f01016e0:	6a 00                	push   $0x0
f01016e2:	e8 af f7 ff ff       	call   f0100e96 <page_alloc>
f01016e7:	89 c6                	mov    %eax,%esi
f01016e9:	83 c4 10             	add    $0x10,%esp
f01016ec:	85 c0                	test   %eax,%eax
f01016ee:	75 19                	jne    f0101709 <mem_init+0x592>
f01016f0:	68 58 3e 10 f0       	push   $0xf0103e58
f01016f5:	68 64 3d 10 f0       	push   $0xf0103d64
f01016fa:	68 19 03 00 00       	push   $0x319
f01016ff:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101704:	e8 fe e9 ff ff       	call   f0100107 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101709:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010170c:	75 19                	jne    f0101727 <mem_init+0x5b0>
f010170e:	68 6e 3e 10 f0       	push   $0xf0103e6e
f0101713:	68 64 3d 10 f0       	push   $0xf0103d64
f0101718:	68 1c 03 00 00       	push   $0x31c
f010171d:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101722:	e8 e0 e9 ff ff       	call   f0100107 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101727:	39 c3                	cmp    %eax,%ebx
f0101729:	74 05                	je     f0101730 <mem_init+0x5b9>
f010172b:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010172e:	75 19                	jne    f0101749 <mem_init+0x5d2>
f0101730:	68 cc 41 10 f0       	push   $0xf01041cc
f0101735:	68 64 3d 10 f0       	push   $0xf0103d64
f010173a:	68 1d 03 00 00       	push   $0x31d
f010173f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101744:	e8 be e9 ff ff       	call   f0100107 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101749:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f010174e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101751:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101758:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010175b:	83 ec 0c             	sub    $0xc,%esp
f010175e:	6a 00                	push   $0x0
f0101760:	e8 31 f7 ff ff       	call   f0100e96 <page_alloc>
f0101765:	83 c4 10             	add    $0x10,%esp
f0101768:	85 c0                	test   %eax,%eax
f010176a:	74 19                	je     f0101785 <mem_init+0x60e>
f010176c:	68 d7 3e 10 f0       	push   $0xf0103ed7
f0101771:	68 64 3d 10 f0       	push   $0xf0103d64
f0101776:	68 24 03 00 00       	push   $0x324
f010177b:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101780:	e8 82 e9 ff ff       	call   f0100107 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101785:	83 ec 04             	sub    $0x4,%esp
f0101788:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010178b:	50                   	push   %eax
f010178c:	6a 00                	push   $0x0
f010178e:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0101794:	e8 cc f8 ff ff       	call   f0101065 <page_lookup>
f0101799:	83 c4 10             	add    $0x10,%esp
f010179c:	85 c0                	test   %eax,%eax
f010179e:	74 19                	je     f01017b9 <mem_init+0x642>
f01017a0:	68 0c 42 10 f0       	push   $0xf010420c
f01017a5:	68 64 3d 10 f0       	push   $0xf0103d64
f01017aa:	68 27 03 00 00       	push   $0x327
f01017af:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01017b4:	e8 4e e9 ff ff       	call   f0100107 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01017b9:	6a 02                	push   $0x2
f01017bb:	6a 00                	push   $0x0
f01017bd:	53                   	push   %ebx
f01017be:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f01017c4:	e8 38 f9 ff ff       	call   f0101101 <page_insert>
f01017c9:	83 c4 10             	add    $0x10,%esp
f01017cc:	85 c0                	test   %eax,%eax
f01017ce:	78 19                	js     f01017e9 <mem_init+0x672>
f01017d0:	68 44 42 10 f0       	push   $0xf0104244
f01017d5:	68 64 3d 10 f0       	push   $0xf0103d64
f01017da:	68 2a 03 00 00       	push   $0x32a
f01017df:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01017e4:	e8 1e e9 ff ff       	call   f0100107 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017e9:	83 ec 0c             	sub    $0xc,%esp
f01017ec:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017ef:	e8 12 f7 ff ff       	call   f0100f06 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017f4:	6a 02                	push   $0x2
f01017f6:	6a 00                	push   $0x0
f01017f8:	53                   	push   %ebx
f01017f9:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f01017ff:	e8 fd f8 ff ff       	call   f0101101 <page_insert>
f0101804:	83 c4 20             	add    $0x20,%esp
f0101807:	85 c0                	test   %eax,%eax
f0101809:	74 19                	je     f0101824 <mem_init+0x6ad>
f010180b:	68 74 42 10 f0       	push   $0xf0104274
f0101810:	68 64 3d 10 f0       	push   $0xf0103d64
f0101815:	68 2e 03 00 00       	push   $0x32e
f010181a:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010181f:	e8 e3 e8 ff ff       	call   f0100107 <_panic>
	// cprintf("assret %x == %x\n", PTE_ADDR(kern_pgdir[0]), page2pa(pp1));
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101824:	8b 3d 4c 79 11 f0    	mov    0xf011794c,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010182a:	a1 50 79 11 f0       	mov    0xf0117950,%eax
f010182f:	89 c1                	mov    %eax,%ecx
f0101831:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101834:	8b 17                	mov    (%edi),%edx
f0101836:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010183c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010183f:	29 c8                	sub    %ecx,%eax
f0101841:	c1 f8 03             	sar    $0x3,%eax
f0101844:	c1 e0 0c             	shl    $0xc,%eax
f0101847:	39 c2                	cmp    %eax,%edx
f0101849:	74 19                	je     f0101864 <mem_init+0x6ed>
f010184b:	68 a4 42 10 f0       	push   $0xf01042a4
f0101850:	68 64 3d 10 f0       	push   $0xf0103d64
f0101855:	68 30 03 00 00       	push   $0x330
f010185a:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010185f:	e8 a3 e8 ff ff       	call   f0100107 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101864:	ba 00 00 00 00       	mov    $0x0,%edx
f0101869:	89 f8                	mov    %edi,%eax
f010186b:	e8 08 f2 ff ff       	call   f0100a78 <check_va2pa>
f0101870:	89 da                	mov    %ebx,%edx
f0101872:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101875:	c1 fa 03             	sar    $0x3,%edx
f0101878:	c1 e2 0c             	shl    $0xc,%edx
f010187b:	39 d0                	cmp    %edx,%eax
f010187d:	74 19                	je     f0101898 <mem_init+0x721>
f010187f:	68 cc 42 10 f0       	push   $0xf01042cc
f0101884:	68 64 3d 10 f0       	push   $0xf0103d64
f0101889:	68 31 03 00 00       	push   $0x331
f010188e:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101893:	e8 6f e8 ff ff       	call   f0100107 <_panic>
	assert(pp1->pp_ref == 1);
f0101898:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010189d:	74 19                	je     f01018b8 <mem_init+0x741>
f010189f:	68 29 3f 10 f0       	push   $0xf0103f29
f01018a4:	68 64 3d 10 f0       	push   $0xf0103d64
f01018a9:	68 32 03 00 00       	push   $0x332
f01018ae:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01018b3:	e8 4f e8 ff ff       	call   f0100107 <_panic>
	assert(pp0->pp_ref == 1);
f01018b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018bb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01018c0:	74 19                	je     f01018db <mem_init+0x764>
f01018c2:	68 3a 3f 10 f0       	push   $0xf0103f3a
f01018c7:	68 64 3d 10 f0       	push   $0xf0103d64
f01018cc:	68 33 03 00 00       	push   $0x333
f01018d1:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01018d6:	e8 2c e8 ff ff       	call   f0100107 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018db:	6a 02                	push   $0x2
f01018dd:	68 00 10 00 00       	push   $0x1000
f01018e2:	56                   	push   %esi
f01018e3:	57                   	push   %edi
f01018e4:	e8 18 f8 ff ff       	call   f0101101 <page_insert>
f01018e9:	83 c4 10             	add    $0x10,%esp
f01018ec:	85 c0                	test   %eax,%eax
f01018ee:	74 19                	je     f0101909 <mem_init+0x792>
f01018f0:	68 fc 42 10 f0       	push   $0xf01042fc
f01018f5:	68 64 3d 10 f0       	push   $0xf0103d64
f01018fa:	68 36 03 00 00       	push   $0x336
f01018ff:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101904:	e8 fe e7 ff ff       	call   f0100107 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101909:	ba 00 10 00 00       	mov    $0x1000,%edx
f010190e:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f0101913:	e8 60 f1 ff ff       	call   f0100a78 <check_va2pa>
f0101918:	89 f2                	mov    %esi,%edx
f010191a:	2b 15 50 79 11 f0    	sub    0xf0117950,%edx
f0101920:	c1 fa 03             	sar    $0x3,%edx
f0101923:	c1 e2 0c             	shl    $0xc,%edx
f0101926:	39 d0                	cmp    %edx,%eax
f0101928:	74 19                	je     f0101943 <mem_init+0x7cc>
f010192a:	68 38 43 10 f0       	push   $0xf0104338
f010192f:	68 64 3d 10 f0       	push   $0xf0103d64
f0101934:	68 37 03 00 00       	push   $0x337
f0101939:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010193e:	e8 c4 e7 ff ff       	call   f0100107 <_panic>
	assert(pp2->pp_ref == 1);
f0101943:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101948:	74 19                	je     f0101963 <mem_init+0x7ec>
f010194a:	68 4b 3f 10 f0       	push   $0xf0103f4b
f010194f:	68 64 3d 10 f0       	push   $0xf0103d64
f0101954:	68 38 03 00 00       	push   $0x338
f0101959:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010195e:	e8 a4 e7 ff ff       	call   f0100107 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101963:	83 ec 0c             	sub    $0xc,%esp
f0101966:	6a 00                	push   $0x0
f0101968:	e8 29 f5 ff ff       	call   f0100e96 <page_alloc>
f010196d:	83 c4 10             	add    $0x10,%esp
f0101970:	85 c0                	test   %eax,%eax
f0101972:	74 19                	je     f010198d <mem_init+0x816>
f0101974:	68 d7 3e 10 f0       	push   $0xf0103ed7
f0101979:	68 64 3d 10 f0       	push   $0xf0103d64
f010197e:	68 3b 03 00 00       	push   $0x33b
f0101983:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101988:	e8 7a e7 ff ff       	call   f0100107 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010198d:	6a 02                	push   $0x2
f010198f:	68 00 10 00 00       	push   $0x1000
f0101994:	56                   	push   %esi
f0101995:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f010199b:	e8 61 f7 ff ff       	call   f0101101 <page_insert>
f01019a0:	83 c4 10             	add    $0x10,%esp
f01019a3:	85 c0                	test   %eax,%eax
f01019a5:	74 19                	je     f01019c0 <mem_init+0x849>
f01019a7:	68 fc 42 10 f0       	push   $0xf01042fc
f01019ac:	68 64 3d 10 f0       	push   $0xf0103d64
f01019b1:	68 3e 03 00 00       	push   $0x33e
f01019b6:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01019bb:	e8 47 e7 ff ff       	call   f0100107 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019c0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019c5:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f01019ca:	e8 a9 f0 ff ff       	call   f0100a78 <check_va2pa>
f01019cf:	89 f2                	mov    %esi,%edx
f01019d1:	2b 15 50 79 11 f0    	sub    0xf0117950,%edx
f01019d7:	c1 fa 03             	sar    $0x3,%edx
f01019da:	c1 e2 0c             	shl    $0xc,%edx
f01019dd:	39 d0                	cmp    %edx,%eax
f01019df:	74 19                	je     f01019fa <mem_init+0x883>
f01019e1:	68 38 43 10 f0       	push   $0xf0104338
f01019e6:	68 64 3d 10 f0       	push   $0xf0103d64
f01019eb:	68 3f 03 00 00       	push   $0x33f
f01019f0:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01019f5:	e8 0d e7 ff ff       	call   f0100107 <_panic>
	assert(pp2->pp_ref == 1);
f01019fa:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019ff:	74 19                	je     f0101a1a <mem_init+0x8a3>
f0101a01:	68 4b 3f 10 f0       	push   $0xf0103f4b
f0101a06:	68 64 3d 10 f0       	push   $0xf0103d64
f0101a0b:	68 40 03 00 00       	push   $0x340
f0101a10:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101a15:	e8 ed e6 ff ff       	call   f0100107 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a1a:	83 ec 0c             	sub    $0xc,%esp
f0101a1d:	6a 00                	push   $0x0
f0101a1f:	e8 72 f4 ff ff       	call   f0100e96 <page_alloc>
f0101a24:	83 c4 10             	add    $0x10,%esp
f0101a27:	85 c0                	test   %eax,%eax
f0101a29:	74 19                	je     f0101a44 <mem_init+0x8cd>
f0101a2b:	68 d7 3e 10 f0       	push   $0xf0103ed7
f0101a30:	68 64 3d 10 f0       	push   $0xf0103d64
f0101a35:	68 44 03 00 00       	push   $0x344
f0101a3a:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101a3f:	e8 c3 e6 ff ff       	call   f0100107 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a44:	8b 15 4c 79 11 f0    	mov    0xf011794c,%edx
f0101a4a:	8b 02                	mov    (%edx),%eax
f0101a4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a51:	89 c1                	mov    %eax,%ecx
f0101a53:	c1 e9 0c             	shr    $0xc,%ecx
f0101a56:	3b 0d 48 79 11 f0    	cmp    0xf0117948,%ecx
f0101a5c:	72 15                	jb     f0101a73 <mem_init+0x8fc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a5e:	50                   	push   %eax
f0101a5f:	68 40 40 10 f0       	push   $0xf0104040
f0101a64:	68 47 03 00 00       	push   $0x347
f0101a69:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101a6e:	e8 94 e6 ff ff       	call   f0100107 <_panic>
f0101a73:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a7b:	83 ec 04             	sub    $0x4,%esp
f0101a7e:	6a 00                	push   $0x0
f0101a80:	68 00 10 00 00       	push   $0x1000
f0101a85:	52                   	push   %edx
f0101a86:	e8 f8 f4 ff ff       	call   f0100f83 <pgdir_walk>
f0101a8b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a8e:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a91:	83 c4 10             	add    $0x10,%esp
f0101a94:	39 d0                	cmp    %edx,%eax
f0101a96:	74 19                	je     f0101ab1 <mem_init+0x93a>
f0101a98:	68 68 43 10 f0       	push   $0xf0104368
f0101a9d:	68 64 3d 10 f0       	push   $0xf0103d64
f0101aa2:	68 48 03 00 00       	push   $0x348
f0101aa7:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101aac:	e8 56 e6 ff ff       	call   f0100107 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ab1:	6a 06                	push   $0x6
f0101ab3:	68 00 10 00 00       	push   $0x1000
f0101ab8:	56                   	push   %esi
f0101ab9:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0101abf:	e8 3d f6 ff ff       	call   f0101101 <page_insert>
f0101ac4:	83 c4 10             	add    $0x10,%esp
f0101ac7:	85 c0                	test   %eax,%eax
f0101ac9:	74 19                	je     f0101ae4 <mem_init+0x96d>
f0101acb:	68 a8 43 10 f0       	push   $0xf01043a8
f0101ad0:	68 64 3d 10 f0       	push   $0xf0103d64
f0101ad5:	68 4b 03 00 00       	push   $0x34b
f0101ada:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101adf:	e8 23 e6 ff ff       	call   f0100107 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ae4:	8b 3d 4c 79 11 f0    	mov    0xf011794c,%edi
f0101aea:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aef:	89 f8                	mov    %edi,%eax
f0101af1:	e8 82 ef ff ff       	call   f0100a78 <check_va2pa>
f0101af6:	89 f2                	mov    %esi,%edx
f0101af8:	2b 15 50 79 11 f0    	sub    0xf0117950,%edx
f0101afe:	c1 fa 03             	sar    $0x3,%edx
f0101b01:	c1 e2 0c             	shl    $0xc,%edx
f0101b04:	39 d0                	cmp    %edx,%eax
f0101b06:	74 19                	je     f0101b21 <mem_init+0x9aa>
f0101b08:	68 38 43 10 f0       	push   $0xf0104338
f0101b0d:	68 64 3d 10 f0       	push   $0xf0103d64
f0101b12:	68 4c 03 00 00       	push   $0x34c
f0101b17:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101b1c:	e8 e6 e5 ff ff       	call   f0100107 <_panic>
	assert(pp2->pp_ref == 1);
f0101b21:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b26:	74 19                	je     f0101b41 <mem_init+0x9ca>
f0101b28:	68 4b 3f 10 f0       	push   $0xf0103f4b
f0101b2d:	68 64 3d 10 f0       	push   $0xf0103d64
f0101b32:	68 4d 03 00 00       	push   $0x34d
f0101b37:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101b3c:	e8 c6 e5 ff ff       	call   f0100107 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b41:	83 ec 04             	sub    $0x4,%esp
f0101b44:	6a 00                	push   $0x0
f0101b46:	68 00 10 00 00       	push   $0x1000
f0101b4b:	57                   	push   %edi
f0101b4c:	e8 32 f4 ff ff       	call   f0100f83 <pgdir_walk>
f0101b51:	83 c4 10             	add    $0x10,%esp
f0101b54:	f6 00 04             	testb  $0x4,(%eax)
f0101b57:	75 19                	jne    f0101b72 <mem_init+0x9fb>
f0101b59:	68 e8 43 10 f0       	push   $0xf01043e8
f0101b5e:	68 64 3d 10 f0       	push   $0xf0103d64
f0101b63:	68 4e 03 00 00       	push   $0x34e
f0101b68:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101b6d:	e8 95 e5 ff ff       	call   f0100107 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b72:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f0101b77:	f6 00 04             	testb  $0x4,(%eax)
f0101b7a:	75 19                	jne    f0101b95 <mem_init+0xa1e>
f0101b7c:	68 5c 3f 10 f0       	push   $0xf0103f5c
f0101b81:	68 64 3d 10 f0       	push   $0xf0103d64
f0101b86:	68 4f 03 00 00       	push   $0x34f
f0101b8b:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101b90:	e8 72 e5 ff ff       	call   f0100107 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b95:	6a 02                	push   $0x2
f0101b97:	68 00 10 00 00       	push   $0x1000
f0101b9c:	56                   	push   %esi
f0101b9d:	50                   	push   %eax
f0101b9e:	e8 5e f5 ff ff       	call   f0101101 <page_insert>
f0101ba3:	83 c4 10             	add    $0x10,%esp
f0101ba6:	85 c0                	test   %eax,%eax
f0101ba8:	74 19                	je     f0101bc3 <mem_init+0xa4c>
f0101baa:	68 fc 42 10 f0       	push   $0xf01042fc
f0101baf:	68 64 3d 10 f0       	push   $0xf0103d64
f0101bb4:	68 52 03 00 00       	push   $0x352
f0101bb9:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101bbe:	e8 44 e5 ff ff       	call   f0100107 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bc3:	83 ec 04             	sub    $0x4,%esp
f0101bc6:	6a 00                	push   $0x0
f0101bc8:	68 00 10 00 00       	push   $0x1000
f0101bcd:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0101bd3:	e8 ab f3 ff ff       	call   f0100f83 <pgdir_walk>
f0101bd8:	83 c4 10             	add    $0x10,%esp
f0101bdb:	f6 00 02             	testb  $0x2,(%eax)
f0101bde:	75 19                	jne    f0101bf9 <mem_init+0xa82>
f0101be0:	68 1c 44 10 f0       	push   $0xf010441c
f0101be5:	68 64 3d 10 f0       	push   $0xf0103d64
f0101bea:	68 53 03 00 00       	push   $0x353
f0101bef:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101bf4:	e8 0e e5 ff ff       	call   f0100107 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bf9:	83 ec 04             	sub    $0x4,%esp
f0101bfc:	6a 00                	push   $0x0
f0101bfe:	68 00 10 00 00       	push   $0x1000
f0101c03:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0101c09:	e8 75 f3 ff ff       	call   f0100f83 <pgdir_walk>
f0101c0e:	83 c4 10             	add    $0x10,%esp
f0101c11:	f6 00 04             	testb  $0x4,(%eax)
f0101c14:	74 19                	je     f0101c2f <mem_init+0xab8>
f0101c16:	68 50 44 10 f0       	push   $0xf0104450
f0101c1b:	68 64 3d 10 f0       	push   $0xf0103d64
f0101c20:	68 54 03 00 00       	push   $0x354
f0101c25:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101c2a:	e8 d8 e4 ff ff       	call   f0100107 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c2f:	6a 02                	push   $0x2
f0101c31:	68 00 00 40 00       	push   $0x400000
f0101c36:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c39:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0101c3f:	e8 bd f4 ff ff       	call   f0101101 <page_insert>
f0101c44:	83 c4 10             	add    $0x10,%esp
f0101c47:	85 c0                	test   %eax,%eax
f0101c49:	78 19                	js     f0101c64 <mem_init+0xaed>
f0101c4b:	68 88 44 10 f0       	push   $0xf0104488
f0101c50:	68 64 3d 10 f0       	push   $0xf0103d64
f0101c55:	68 57 03 00 00       	push   $0x357
f0101c5a:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101c5f:	e8 a3 e4 ff ff       	call   f0100107 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c64:	6a 02                	push   $0x2
f0101c66:	68 00 10 00 00       	push   $0x1000
f0101c6b:	53                   	push   %ebx
f0101c6c:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0101c72:	e8 8a f4 ff ff       	call   f0101101 <page_insert>
f0101c77:	83 c4 10             	add    $0x10,%esp
f0101c7a:	85 c0                	test   %eax,%eax
f0101c7c:	74 19                	je     f0101c97 <mem_init+0xb20>
f0101c7e:	68 c0 44 10 f0       	push   $0xf01044c0
f0101c83:	68 64 3d 10 f0       	push   $0xf0103d64
f0101c88:	68 5a 03 00 00       	push   $0x35a
f0101c8d:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101c92:	e8 70 e4 ff ff       	call   f0100107 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c97:	83 ec 04             	sub    $0x4,%esp
f0101c9a:	6a 00                	push   $0x0
f0101c9c:	68 00 10 00 00       	push   $0x1000
f0101ca1:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0101ca7:	e8 d7 f2 ff ff       	call   f0100f83 <pgdir_walk>
f0101cac:	83 c4 10             	add    $0x10,%esp
f0101caf:	f6 00 04             	testb  $0x4,(%eax)
f0101cb2:	74 19                	je     f0101ccd <mem_init+0xb56>
f0101cb4:	68 50 44 10 f0       	push   $0xf0104450
f0101cb9:	68 64 3d 10 f0       	push   $0xf0103d64
f0101cbe:	68 5b 03 00 00       	push   $0x35b
f0101cc3:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101cc8:	e8 3a e4 ff ff       	call   f0100107 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ccd:	8b 3d 4c 79 11 f0    	mov    0xf011794c,%edi
f0101cd3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cd8:	89 f8                	mov    %edi,%eax
f0101cda:	e8 99 ed ff ff       	call   f0100a78 <check_va2pa>
f0101cdf:	89 c1                	mov    %eax,%ecx
f0101ce1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ce4:	89 d8                	mov    %ebx,%eax
f0101ce6:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f0101cec:	c1 f8 03             	sar    $0x3,%eax
f0101cef:	c1 e0 0c             	shl    $0xc,%eax
f0101cf2:	39 c1                	cmp    %eax,%ecx
f0101cf4:	74 19                	je     f0101d0f <mem_init+0xb98>
f0101cf6:	68 fc 44 10 f0       	push   $0xf01044fc
f0101cfb:	68 64 3d 10 f0       	push   $0xf0103d64
f0101d00:	68 5e 03 00 00       	push   $0x35e
f0101d05:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101d0a:	e8 f8 e3 ff ff       	call   f0100107 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d0f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d14:	89 f8                	mov    %edi,%eax
f0101d16:	e8 5d ed ff ff       	call   f0100a78 <check_va2pa>
f0101d1b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101d1e:	74 19                	je     f0101d39 <mem_init+0xbc2>
f0101d20:	68 28 45 10 f0       	push   $0xf0104528
f0101d25:	68 64 3d 10 f0       	push   $0xf0103d64
f0101d2a:	68 5f 03 00 00       	push   $0x35f
f0101d2f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101d34:	e8 ce e3 ff ff       	call   f0100107 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d39:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101d3e:	74 19                	je     f0101d59 <mem_init+0xbe2>
f0101d40:	68 72 3f 10 f0       	push   $0xf0103f72
f0101d45:	68 64 3d 10 f0       	push   $0xf0103d64
f0101d4a:	68 61 03 00 00       	push   $0x361
f0101d4f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101d54:	e8 ae e3 ff ff       	call   f0100107 <_panic>
	assert(pp2->pp_ref == 0);
f0101d59:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d5e:	74 19                	je     f0101d79 <mem_init+0xc02>
f0101d60:	68 83 3f 10 f0       	push   $0xf0103f83
f0101d65:	68 64 3d 10 f0       	push   $0xf0103d64
f0101d6a:	68 62 03 00 00       	push   $0x362
f0101d6f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101d74:	e8 8e e3 ff ff       	call   f0100107 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d79:	83 ec 0c             	sub    $0xc,%esp
f0101d7c:	6a 00                	push   $0x0
f0101d7e:	e8 13 f1 ff ff       	call   f0100e96 <page_alloc>
f0101d83:	83 c4 10             	add    $0x10,%esp
f0101d86:	39 c6                	cmp    %eax,%esi
f0101d88:	75 04                	jne    f0101d8e <mem_init+0xc17>
f0101d8a:	85 c0                	test   %eax,%eax
f0101d8c:	75 19                	jne    f0101da7 <mem_init+0xc30>
f0101d8e:	68 58 45 10 f0       	push   $0xf0104558
f0101d93:	68 64 3d 10 f0       	push   $0xf0103d64
f0101d98:	68 65 03 00 00       	push   $0x365
f0101d9d:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101da2:	e8 60 e3 ff ff       	call   f0100107 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101da7:	83 ec 08             	sub    $0x8,%esp
f0101daa:	6a 00                	push   $0x0
f0101dac:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0101db2:	e8 08 f3 ff ff       	call   f01010bf <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101db7:	8b 3d 4c 79 11 f0    	mov    0xf011794c,%edi
f0101dbd:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dc2:	89 f8                	mov    %edi,%eax
f0101dc4:	e8 af ec ff ff       	call   f0100a78 <check_va2pa>
f0101dc9:	83 c4 10             	add    $0x10,%esp
f0101dcc:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dcf:	74 19                	je     f0101dea <mem_init+0xc73>
f0101dd1:	68 7c 45 10 f0       	push   $0xf010457c
f0101dd6:	68 64 3d 10 f0       	push   $0xf0103d64
f0101ddb:	68 69 03 00 00       	push   $0x369
f0101de0:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101de5:	e8 1d e3 ff ff       	call   f0100107 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dea:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101def:	89 f8                	mov    %edi,%eax
f0101df1:	e8 82 ec ff ff       	call   f0100a78 <check_va2pa>
f0101df6:	89 da                	mov    %ebx,%edx
f0101df8:	2b 15 50 79 11 f0    	sub    0xf0117950,%edx
f0101dfe:	c1 fa 03             	sar    $0x3,%edx
f0101e01:	c1 e2 0c             	shl    $0xc,%edx
f0101e04:	39 d0                	cmp    %edx,%eax
f0101e06:	74 19                	je     f0101e21 <mem_init+0xcaa>
f0101e08:	68 28 45 10 f0       	push   $0xf0104528
f0101e0d:	68 64 3d 10 f0       	push   $0xf0103d64
f0101e12:	68 6a 03 00 00       	push   $0x36a
f0101e17:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101e1c:	e8 e6 e2 ff ff       	call   f0100107 <_panic>
	assert(pp1->pp_ref == 1);
f0101e21:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e26:	74 19                	je     f0101e41 <mem_init+0xcca>
f0101e28:	68 29 3f 10 f0       	push   $0xf0103f29
f0101e2d:	68 64 3d 10 f0       	push   $0xf0103d64
f0101e32:	68 6b 03 00 00       	push   $0x36b
f0101e37:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101e3c:	e8 c6 e2 ff ff       	call   f0100107 <_panic>
	assert(pp2->pp_ref == 0);
f0101e41:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e46:	74 19                	je     f0101e61 <mem_init+0xcea>
f0101e48:	68 83 3f 10 f0       	push   $0xf0103f83
f0101e4d:	68 64 3d 10 f0       	push   $0xf0103d64
f0101e52:	68 6c 03 00 00       	push   $0x36c
f0101e57:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101e5c:	e8 a6 e2 ff ff       	call   f0100107 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101e61:	6a 00                	push   $0x0
f0101e63:	68 00 10 00 00       	push   $0x1000
f0101e68:	53                   	push   %ebx
f0101e69:	57                   	push   %edi
f0101e6a:	e8 92 f2 ff ff       	call   f0101101 <page_insert>
f0101e6f:	83 c4 10             	add    $0x10,%esp
f0101e72:	85 c0                	test   %eax,%eax
f0101e74:	74 19                	je     f0101e8f <mem_init+0xd18>
f0101e76:	68 a0 45 10 f0       	push   $0xf01045a0
f0101e7b:	68 64 3d 10 f0       	push   $0xf0103d64
f0101e80:	68 6f 03 00 00       	push   $0x36f
f0101e85:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101e8a:	e8 78 e2 ff ff       	call   f0100107 <_panic>
	assert(pp1->pp_ref);
f0101e8f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e94:	75 19                	jne    f0101eaf <mem_init+0xd38>
f0101e96:	68 94 3f 10 f0       	push   $0xf0103f94
f0101e9b:	68 64 3d 10 f0       	push   $0xf0103d64
f0101ea0:	68 70 03 00 00       	push   $0x370
f0101ea5:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101eaa:	e8 58 e2 ff ff       	call   f0100107 <_panic>
	assert(pp1->pp_link == NULL);
f0101eaf:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101eb2:	74 19                	je     f0101ecd <mem_init+0xd56>
f0101eb4:	68 a0 3f 10 f0       	push   $0xf0103fa0
f0101eb9:	68 64 3d 10 f0       	push   $0xf0103d64
f0101ebe:	68 71 03 00 00       	push   $0x371
f0101ec3:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101ec8:	e8 3a e2 ff ff       	call   f0100107 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101ecd:	83 ec 08             	sub    $0x8,%esp
f0101ed0:	68 00 10 00 00       	push   $0x1000
f0101ed5:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0101edb:	e8 df f1 ff ff       	call   f01010bf <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ee0:	8b 3d 4c 79 11 f0    	mov    0xf011794c,%edi
f0101ee6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eeb:	89 f8                	mov    %edi,%eax
f0101eed:	e8 86 eb ff ff       	call   f0100a78 <check_va2pa>
f0101ef2:	83 c4 10             	add    $0x10,%esp
f0101ef5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ef8:	74 19                	je     f0101f13 <mem_init+0xd9c>
f0101efa:	68 7c 45 10 f0       	push   $0xf010457c
f0101eff:	68 64 3d 10 f0       	push   $0xf0103d64
f0101f04:	68 75 03 00 00       	push   $0x375
f0101f09:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101f0e:	e8 f4 e1 ff ff       	call   f0100107 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f13:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f18:	89 f8                	mov    %edi,%eax
f0101f1a:	e8 59 eb ff ff       	call   f0100a78 <check_va2pa>
f0101f1f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f22:	74 19                	je     f0101f3d <mem_init+0xdc6>
f0101f24:	68 d8 45 10 f0       	push   $0xf01045d8
f0101f29:	68 64 3d 10 f0       	push   $0xf0103d64
f0101f2e:	68 76 03 00 00       	push   $0x376
f0101f33:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101f38:	e8 ca e1 ff ff       	call   f0100107 <_panic>
	assert(pp1->pp_ref == 0);
f0101f3d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f42:	74 19                	je     f0101f5d <mem_init+0xde6>
f0101f44:	68 b5 3f 10 f0       	push   $0xf0103fb5
f0101f49:	68 64 3d 10 f0       	push   $0xf0103d64
f0101f4e:	68 77 03 00 00       	push   $0x377
f0101f53:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101f58:	e8 aa e1 ff ff       	call   f0100107 <_panic>
	assert(pp2->pp_ref == 0);
f0101f5d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f62:	74 19                	je     f0101f7d <mem_init+0xe06>
f0101f64:	68 83 3f 10 f0       	push   $0xf0103f83
f0101f69:	68 64 3d 10 f0       	push   $0xf0103d64
f0101f6e:	68 78 03 00 00       	push   $0x378
f0101f73:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101f78:	e8 8a e1 ff ff       	call   f0100107 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f7d:	83 ec 0c             	sub    $0xc,%esp
f0101f80:	6a 00                	push   $0x0
f0101f82:	e8 0f ef ff ff       	call   f0100e96 <page_alloc>
f0101f87:	83 c4 10             	add    $0x10,%esp
f0101f8a:	85 c0                	test   %eax,%eax
f0101f8c:	74 04                	je     f0101f92 <mem_init+0xe1b>
f0101f8e:	39 c3                	cmp    %eax,%ebx
f0101f90:	74 19                	je     f0101fab <mem_init+0xe34>
f0101f92:	68 00 46 10 f0       	push   $0xf0104600
f0101f97:	68 64 3d 10 f0       	push   $0xf0103d64
f0101f9c:	68 7b 03 00 00       	push   $0x37b
f0101fa1:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101fa6:	e8 5c e1 ff ff       	call   f0100107 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101fab:	83 ec 0c             	sub    $0xc,%esp
f0101fae:	6a 00                	push   $0x0
f0101fb0:	e8 e1 ee ff ff       	call   f0100e96 <page_alloc>
f0101fb5:	83 c4 10             	add    $0x10,%esp
f0101fb8:	85 c0                	test   %eax,%eax
f0101fba:	74 19                	je     f0101fd5 <mem_init+0xe5e>
f0101fbc:	68 d7 3e 10 f0       	push   $0xf0103ed7
f0101fc1:	68 64 3d 10 f0       	push   $0xf0103d64
f0101fc6:	68 7e 03 00 00       	push   $0x37e
f0101fcb:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0101fd0:	e8 32 e1 ff ff       	call   f0100107 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101fd5:	8b 0d 4c 79 11 f0    	mov    0xf011794c,%ecx
f0101fdb:	8b 11                	mov    (%ecx),%edx
f0101fdd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101fe3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fe6:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f0101fec:	c1 f8 03             	sar    $0x3,%eax
f0101fef:	c1 e0 0c             	shl    $0xc,%eax
f0101ff2:	39 c2                	cmp    %eax,%edx
f0101ff4:	74 19                	je     f010200f <mem_init+0xe98>
f0101ff6:	68 a4 42 10 f0       	push   $0xf01042a4
f0101ffb:	68 64 3d 10 f0       	push   $0xf0103d64
f0102000:	68 81 03 00 00       	push   $0x381
f0102005:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010200a:	e8 f8 e0 ff ff       	call   f0100107 <_panic>
	kern_pgdir[0] = 0;
f010200f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102015:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102018:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010201d:	74 19                	je     f0102038 <mem_init+0xec1>
f010201f:	68 3a 3f 10 f0       	push   $0xf0103f3a
f0102024:	68 64 3d 10 f0       	push   $0xf0103d64
f0102029:	68 83 03 00 00       	push   $0x383
f010202e:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102033:	e8 cf e0 ff ff       	call   f0100107 <_panic>
	pp0->pp_ref = 0;
f0102038:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010203b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102041:	83 ec 0c             	sub    $0xc,%esp
f0102044:	50                   	push   %eax
f0102045:	e8 bc ee ff ff       	call   f0100f06 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010204a:	83 c4 0c             	add    $0xc,%esp
f010204d:	6a 01                	push   $0x1
f010204f:	68 00 10 40 00       	push   $0x401000
f0102054:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f010205a:	e8 24 ef ff ff       	call   f0100f83 <pgdir_walk>
f010205f:	89 c7                	mov    %eax,%edi
f0102061:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102064:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f0102069:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010206c:	8b 40 04             	mov    0x4(%eax),%eax
f010206f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102074:	8b 0d 48 79 11 f0    	mov    0xf0117948,%ecx
f010207a:	89 c2                	mov    %eax,%edx
f010207c:	c1 ea 0c             	shr    $0xc,%edx
f010207f:	83 c4 10             	add    $0x10,%esp
f0102082:	39 ca                	cmp    %ecx,%edx
f0102084:	72 15                	jb     f010209b <mem_init+0xf24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102086:	50                   	push   %eax
f0102087:	68 40 40 10 f0       	push   $0xf0104040
f010208c:	68 8a 03 00 00       	push   $0x38a
f0102091:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102096:	e8 6c e0 ff ff       	call   f0100107 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010209b:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01020a0:	39 c7                	cmp    %eax,%edi
f01020a2:	74 19                	je     f01020bd <mem_init+0xf46>
f01020a4:	68 c6 3f 10 f0       	push   $0xf0103fc6
f01020a9:	68 64 3d 10 f0       	push   $0xf0103d64
f01020ae:	68 8b 03 00 00       	push   $0x38b
f01020b3:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01020b8:	e8 4a e0 ff ff       	call   f0100107 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01020bd:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01020c0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01020c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020ca:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020d0:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f01020d6:	c1 f8 03             	sar    $0x3,%eax
f01020d9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020dc:	89 c2                	mov    %eax,%edx
f01020de:	c1 ea 0c             	shr    $0xc,%edx
f01020e1:	39 d1                	cmp    %edx,%ecx
f01020e3:	77 12                	ja     f01020f7 <mem_init+0xf80>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020e5:	50                   	push   %eax
f01020e6:	68 40 40 10 f0       	push   $0xf0104040
f01020eb:	6a 52                	push   $0x52
f01020ed:	68 4a 3d 10 f0       	push   $0xf0103d4a
f01020f2:	e8 10 e0 ff ff       	call   f0100107 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01020f7:	83 ec 04             	sub    $0x4,%esp
f01020fa:	68 00 10 00 00       	push   $0x1000
f01020ff:	68 ff 00 00 00       	push   $0xff
f0102104:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102109:	50                   	push   %eax
f010210a:	e8 ed 11 00 00       	call   f01032fc <memset>
	page_free(pp0);
f010210f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102112:	89 3c 24             	mov    %edi,(%esp)
f0102115:	e8 ec ed ff ff       	call   f0100f06 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010211a:	83 c4 0c             	add    $0xc,%esp
f010211d:	6a 01                	push   $0x1
f010211f:	6a 00                	push   $0x0
f0102121:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0102127:	e8 57 ee ff ff       	call   f0100f83 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010212c:	89 fa                	mov    %edi,%edx
f010212e:	2b 15 50 79 11 f0    	sub    0xf0117950,%edx
f0102134:	c1 fa 03             	sar    $0x3,%edx
f0102137:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010213a:	89 d0                	mov    %edx,%eax
f010213c:	c1 e8 0c             	shr    $0xc,%eax
f010213f:	83 c4 10             	add    $0x10,%esp
f0102142:	3b 05 48 79 11 f0    	cmp    0xf0117948,%eax
f0102148:	72 12                	jb     f010215c <mem_init+0xfe5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010214a:	52                   	push   %edx
f010214b:	68 40 40 10 f0       	push   $0xf0104040
f0102150:	6a 52                	push   $0x52
f0102152:	68 4a 3d 10 f0       	push   $0xf0103d4a
f0102157:	e8 ab df ff ff       	call   f0100107 <_panic>
	return (void *)(pa + KERNBASE);
f010215c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102162:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102165:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010216b:	f6 00 01             	testb  $0x1,(%eax)
f010216e:	74 19                	je     f0102189 <mem_init+0x1012>
f0102170:	68 de 3f 10 f0       	push   $0xf0103fde
f0102175:	68 64 3d 10 f0       	push   $0xf0103d64
f010217a:	68 95 03 00 00       	push   $0x395
f010217f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102184:	e8 7e df ff ff       	call   f0100107 <_panic>
f0102189:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010218c:	39 d0                	cmp    %edx,%eax
f010218e:	75 db                	jne    f010216b <mem_init+0xff4>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102190:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f0102195:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010219b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010219e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01021a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01021a7:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c

	// free the pages we took
	page_free(pp0);
f01021ad:	83 ec 0c             	sub    $0xc,%esp
f01021b0:	50                   	push   %eax
f01021b1:	e8 50 ed ff ff       	call   f0100f06 <page_free>
	page_free(pp1);
f01021b6:	89 1c 24             	mov    %ebx,(%esp)
f01021b9:	e8 48 ed ff ff       	call   f0100f06 <page_free>
	page_free(pp2);
f01021be:	89 34 24             	mov    %esi,(%esp)
f01021c1:	e8 40 ed ff ff       	call   f0100f06 <page_free>

	cprintf("check_page() succeeded!\n");
f01021c6:	c7 04 24 f5 3f 10 f0 	movl   $0xf0103ff5,(%esp)
f01021cd:	e8 4b 06 00 00       	call   f010281d <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f01021d2:	a1 50 79 11 f0       	mov    0xf0117950,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021d7:	83 c4 10             	add    $0x10,%esp
f01021da:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021df:	77 15                	ja     f01021f6 <mem_init+0x107f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021e1:	50                   	push   %eax
f01021e2:	68 a8 41 10 f0       	push   $0xf01041a8
f01021e7:	68 b5 00 00 00       	push   $0xb5
f01021ec:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01021f1:	e8 11 df ff ff       	call   f0100107 <_panic>
f01021f6:	83 ec 08             	sub    $0x8,%esp
f01021f9:	6a 04                	push   $0x4
f01021fb:	05 00 00 00 10       	add    $0x10000000,%eax
f0102200:	50                   	push   %eax
f0102201:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102206:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010220b:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f0102210:	e8 01 ee ff ff       	call   f0101016 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102215:	83 c4 10             	add    $0x10,%esp
f0102218:	b8 00 d0 10 f0       	mov    $0xf010d000,%eax
f010221d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102222:	77 15                	ja     f0102239 <mem_init+0x10c2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102224:	50                   	push   %eax
f0102225:	68 a8 41 10 f0       	push   $0xf01041a8
f010222a:	68 c1 00 00 00       	push   $0xc1
f010222f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102234:	e8 ce de ff ff       	call   f0100107 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102239:	83 ec 08             	sub    $0x8,%esp
f010223c:	6a 02                	push   $0x2
f010223e:	68 00 d0 10 00       	push   $0x10d000
f0102243:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102248:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010224d:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f0102252:	e8 bf ed ff ff       	call   f0101016 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f0102257:	83 c4 08             	add    $0x8,%esp
f010225a:	6a 02                	push   $0x2
f010225c:	6a 00                	push   $0x0
f010225e:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102263:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102268:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
f010226d:	e8 a4 ed ff ff       	call   f0101016 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102272:	8b 35 4c 79 11 f0    	mov    0xf011794c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102278:	a1 48 79 11 f0       	mov    0xf0117948,%eax
f010227d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102280:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102287:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010228c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
	{
		// cprintf("%x == %x\n", check_va2pa(pgdir, UPAGES + i), PADDR(pages) + i);
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010228f:	8b 3d 50 79 11 f0    	mov    0xf0117950,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102295:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102298:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010229b:	bb 00 00 00 00       	mov    $0x0,%ebx
f01022a0:	eb 55                	jmp    f01022f7 <mem_init+0x1180>
	{
		// cprintf("%x == %x\n", check_va2pa(pgdir, UPAGES + i), PADDR(pages) + i);
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022a2:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01022a8:	89 f0                	mov    %esi,%eax
f01022aa:	e8 c9 e7 ff ff       	call   f0100a78 <check_va2pa>
f01022af:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01022b6:	77 15                	ja     f01022cd <mem_init+0x1156>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022b8:	57                   	push   %edi
f01022b9:	68 a8 41 10 f0       	push   $0xf01041a8
f01022be:	68 d5 02 00 00       	push   $0x2d5
f01022c3:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01022c8:	e8 3a de ff ff       	call   f0100107 <_panic>
f01022cd:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f01022d4:	39 c2                	cmp    %eax,%edx
f01022d6:	74 19                	je     f01022f1 <mem_init+0x117a>
f01022d8:	68 24 46 10 f0       	push   $0xf0104624
f01022dd:	68 64 3d 10 f0       	push   $0xf0103d64
f01022e2:	68 d5 02 00 00       	push   $0x2d5
f01022e7:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01022ec:	e8 16 de ff ff       	call   f0100107 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01022f1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01022f7:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01022fa:	77 a6                	ja     f01022a2 <mem_init+0x112b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
		
	}
		
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01022fc:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01022ff:	c1 e7 0c             	shl    $0xc,%edi
f0102302:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102307:	eb 30                	jmp    f0102339 <mem_init+0x11c2>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102309:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010230f:	89 f0                	mov    %esi,%eax
f0102311:	e8 62 e7 ff ff       	call   f0100a78 <check_va2pa>
f0102316:	39 c3                	cmp    %eax,%ebx
f0102318:	74 19                	je     f0102333 <mem_init+0x11bc>
f010231a:	68 58 46 10 f0       	push   $0xf0104658
f010231f:	68 64 3d 10 f0       	push   $0xf0103d64
f0102324:	68 db 02 00 00       	push   $0x2db
f0102329:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010232e:	e8 d4 dd ff ff       	call   f0100107 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
		
	}
		
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102333:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102339:	39 fb                	cmp    %edi,%ebx
f010233b:	72 cc                	jb     f0102309 <mem_init+0x1192>
f010233d:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102342:	89 da                	mov    %ebx,%edx
f0102344:	89 f0                	mov    %esi,%eax
f0102346:	e8 2d e7 ff ff       	call   f0100a78 <check_va2pa>
f010234b:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f0102351:	39 c2                	cmp    %eax,%edx
f0102353:	74 19                	je     f010236e <mem_init+0x11f7>
f0102355:	68 80 46 10 f0       	push   $0xf0104680
f010235a:	68 64 3d 10 f0       	push   $0xf0103d64
f010235f:	68 df 02 00 00       	push   $0x2df
f0102364:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102369:	e8 99 dd ff ff       	call   f0100107 <_panic>
f010236e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102374:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f010237a:	75 c6                	jne    f0102342 <mem_init+0x11cb>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010237c:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102381:	89 f0                	mov    %esi,%eax
f0102383:	e8 f0 e6 ff ff       	call   f0100a78 <check_va2pa>
f0102388:	83 f8 ff             	cmp    $0xffffffff,%eax
f010238b:	74 51                	je     f01023de <mem_init+0x1267>
f010238d:	68 c8 46 10 f0       	push   $0xf01046c8
f0102392:	68 64 3d 10 f0       	push   $0xf0103d64
f0102397:	68 e0 02 00 00       	push   $0x2e0
f010239c:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01023a1:	e8 61 dd ff ff       	call   f0100107 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01023a6:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01023ab:	72 36                	jb     f01023e3 <mem_init+0x126c>
f01023ad:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01023b2:	76 07                	jbe    f01023bb <mem_init+0x1244>
f01023b4:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01023b9:	75 28                	jne    f01023e3 <mem_init+0x126c>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01023bb:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f01023bf:	0f 85 83 00 00 00    	jne    f0102448 <mem_init+0x12d1>
f01023c5:	68 0e 40 10 f0       	push   $0xf010400e
f01023ca:	68 64 3d 10 f0       	push   $0xf0103d64
f01023cf:	68 e8 02 00 00       	push   $0x2e8
f01023d4:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01023d9:	e8 29 dd ff ff       	call   f0100107 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023de:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01023e3:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01023e8:	76 3f                	jbe    f0102429 <mem_init+0x12b2>
				assert(pgdir[i] & PTE_P);
f01023ea:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01023ed:	f6 c2 01             	test   $0x1,%dl
f01023f0:	75 19                	jne    f010240b <mem_init+0x1294>
f01023f2:	68 0e 40 10 f0       	push   $0xf010400e
f01023f7:	68 64 3d 10 f0       	push   $0xf0103d64
f01023fc:	68 ec 02 00 00       	push   $0x2ec
f0102401:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102406:	e8 fc dc ff ff       	call   f0100107 <_panic>
				assert(pgdir[i] & PTE_W);
f010240b:	f6 c2 02             	test   $0x2,%dl
f010240e:	75 38                	jne    f0102448 <mem_init+0x12d1>
f0102410:	68 1f 40 10 f0       	push   $0xf010401f
f0102415:	68 64 3d 10 f0       	push   $0xf0103d64
f010241a:	68 ed 02 00 00       	push   $0x2ed
f010241f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102424:	e8 de dc ff ff       	call   f0100107 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102429:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f010242d:	74 19                	je     f0102448 <mem_init+0x12d1>
f010242f:	68 30 40 10 f0       	push   $0xf0104030
f0102434:	68 64 3d 10 f0       	push   $0xf0103d64
f0102439:	68 ef 02 00 00       	push   $0x2ef
f010243e:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102443:	e8 bf dc ff ff       	call   f0100107 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102448:	83 c0 01             	add    $0x1,%eax
f010244b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102450:	0f 86 50 ff ff ff    	jbe    f01023a6 <mem_init+0x122f>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102456:	83 ec 0c             	sub    $0xc,%esp
f0102459:	68 f8 46 10 f0       	push   $0xf01046f8
f010245e:	e8 ba 03 00 00       	call   f010281d <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102463:	a1 4c 79 11 f0       	mov    0xf011794c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102468:	83 c4 10             	add    $0x10,%esp
f010246b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102470:	77 15                	ja     f0102487 <mem_init+0x1310>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102472:	50                   	push   %eax
f0102473:	68 a8 41 10 f0       	push   $0xf01041a8
f0102478:	68 d5 00 00 00       	push   $0xd5
f010247d:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102482:	e8 80 dc ff ff       	call   f0100107 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102487:	05 00 00 00 10       	add    $0x10000000,%eax
f010248c:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010248f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102494:	e8 43 e6 ff ff       	call   f0100adc <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102499:	0f 20 c0             	mov    %cr0,%eax
f010249c:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010249f:	0d 23 00 05 80       	or     $0x80050023,%eax
f01024a4:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01024a7:	83 ec 0c             	sub    $0xc,%esp
f01024aa:	6a 00                	push   $0x0
f01024ac:	e8 e5 e9 ff ff       	call   f0100e96 <page_alloc>
f01024b1:	89 c3                	mov    %eax,%ebx
f01024b3:	83 c4 10             	add    $0x10,%esp
f01024b6:	85 c0                	test   %eax,%eax
f01024b8:	75 19                	jne    f01024d3 <mem_init+0x135c>
f01024ba:	68 2c 3e 10 f0       	push   $0xf0103e2c
f01024bf:	68 64 3d 10 f0       	push   $0xf0103d64
f01024c4:	68 b0 03 00 00       	push   $0x3b0
f01024c9:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01024ce:	e8 34 dc ff ff       	call   f0100107 <_panic>
	assert((pp1 = page_alloc(0)));
f01024d3:	83 ec 0c             	sub    $0xc,%esp
f01024d6:	6a 00                	push   $0x0
f01024d8:	e8 b9 e9 ff ff       	call   f0100e96 <page_alloc>
f01024dd:	89 c7                	mov    %eax,%edi
f01024df:	83 c4 10             	add    $0x10,%esp
f01024e2:	85 c0                	test   %eax,%eax
f01024e4:	75 19                	jne    f01024ff <mem_init+0x1388>
f01024e6:	68 42 3e 10 f0       	push   $0xf0103e42
f01024eb:	68 64 3d 10 f0       	push   $0xf0103d64
f01024f0:	68 b1 03 00 00       	push   $0x3b1
f01024f5:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01024fa:	e8 08 dc ff ff       	call   f0100107 <_panic>
	assert((pp2 = page_alloc(0)));
f01024ff:	83 ec 0c             	sub    $0xc,%esp
f0102502:	6a 00                	push   $0x0
f0102504:	e8 8d e9 ff ff       	call   f0100e96 <page_alloc>
f0102509:	89 c6                	mov    %eax,%esi
f010250b:	83 c4 10             	add    $0x10,%esp
f010250e:	85 c0                	test   %eax,%eax
f0102510:	75 19                	jne    f010252b <mem_init+0x13b4>
f0102512:	68 58 3e 10 f0       	push   $0xf0103e58
f0102517:	68 64 3d 10 f0       	push   $0xf0103d64
f010251c:	68 b2 03 00 00       	push   $0x3b2
f0102521:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102526:	e8 dc db ff ff       	call   f0100107 <_panic>
	page_free(pp0);
f010252b:	83 ec 0c             	sub    $0xc,%esp
f010252e:	53                   	push   %ebx
f010252f:	e8 d2 e9 ff ff       	call   f0100f06 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102534:	89 f8                	mov    %edi,%eax
f0102536:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f010253c:	c1 f8 03             	sar    $0x3,%eax
f010253f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102542:	89 c2                	mov    %eax,%edx
f0102544:	c1 ea 0c             	shr    $0xc,%edx
f0102547:	83 c4 10             	add    $0x10,%esp
f010254a:	3b 15 48 79 11 f0    	cmp    0xf0117948,%edx
f0102550:	72 12                	jb     f0102564 <mem_init+0x13ed>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102552:	50                   	push   %eax
f0102553:	68 40 40 10 f0       	push   $0xf0104040
f0102558:	6a 52                	push   $0x52
f010255a:	68 4a 3d 10 f0       	push   $0xf0103d4a
f010255f:	e8 a3 db ff ff       	call   f0100107 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102564:	83 ec 04             	sub    $0x4,%esp
f0102567:	68 00 10 00 00       	push   $0x1000
f010256c:	6a 01                	push   $0x1
f010256e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102573:	50                   	push   %eax
f0102574:	e8 83 0d 00 00       	call   f01032fc <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102579:	89 f0                	mov    %esi,%eax
f010257b:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f0102581:	c1 f8 03             	sar    $0x3,%eax
f0102584:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102587:	89 c2                	mov    %eax,%edx
f0102589:	c1 ea 0c             	shr    $0xc,%edx
f010258c:	83 c4 10             	add    $0x10,%esp
f010258f:	3b 15 48 79 11 f0    	cmp    0xf0117948,%edx
f0102595:	72 12                	jb     f01025a9 <mem_init+0x1432>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102597:	50                   	push   %eax
f0102598:	68 40 40 10 f0       	push   $0xf0104040
f010259d:	6a 52                	push   $0x52
f010259f:	68 4a 3d 10 f0       	push   $0xf0103d4a
f01025a4:	e8 5e db ff ff       	call   f0100107 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01025a9:	83 ec 04             	sub    $0x4,%esp
f01025ac:	68 00 10 00 00       	push   $0x1000
f01025b1:	6a 02                	push   $0x2
f01025b3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025b8:	50                   	push   %eax
f01025b9:	e8 3e 0d 00 00       	call   f01032fc <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01025be:	6a 02                	push   $0x2
f01025c0:	68 00 10 00 00       	push   $0x1000
f01025c5:	57                   	push   %edi
f01025c6:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f01025cc:	e8 30 eb ff ff       	call   f0101101 <page_insert>
	assert(pp1->pp_ref == 1);
f01025d1:	83 c4 20             	add    $0x20,%esp
f01025d4:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025d9:	74 19                	je     f01025f4 <mem_init+0x147d>
f01025db:	68 29 3f 10 f0       	push   $0xf0103f29
f01025e0:	68 64 3d 10 f0       	push   $0xf0103d64
f01025e5:	68 b7 03 00 00       	push   $0x3b7
f01025ea:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01025ef:	e8 13 db ff ff       	call   f0100107 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01025f4:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01025fb:	01 01 01 
f01025fe:	74 19                	je     f0102619 <mem_init+0x14a2>
f0102600:	68 18 47 10 f0       	push   $0xf0104718
f0102605:	68 64 3d 10 f0       	push   $0xf0103d64
f010260a:	68 b8 03 00 00       	push   $0x3b8
f010260f:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102614:	e8 ee da ff ff       	call   f0100107 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102619:	6a 02                	push   $0x2
f010261b:	68 00 10 00 00       	push   $0x1000
f0102620:	56                   	push   %esi
f0102621:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f0102627:	e8 d5 ea ff ff       	call   f0101101 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010262c:	83 c4 10             	add    $0x10,%esp
f010262f:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102636:	02 02 02 
f0102639:	74 19                	je     f0102654 <mem_init+0x14dd>
f010263b:	68 3c 47 10 f0       	push   $0xf010473c
f0102640:	68 64 3d 10 f0       	push   $0xf0103d64
f0102645:	68 ba 03 00 00       	push   $0x3ba
f010264a:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010264f:	e8 b3 da ff ff       	call   f0100107 <_panic>
	assert(pp2->pp_ref == 1);
f0102654:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102659:	74 19                	je     f0102674 <mem_init+0x14fd>
f010265b:	68 4b 3f 10 f0       	push   $0xf0103f4b
f0102660:	68 64 3d 10 f0       	push   $0xf0103d64
f0102665:	68 bb 03 00 00       	push   $0x3bb
f010266a:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010266f:	e8 93 da ff ff       	call   f0100107 <_panic>
	assert(pp1->pp_ref == 0);
f0102674:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102679:	74 19                	je     f0102694 <mem_init+0x151d>
f010267b:	68 b5 3f 10 f0       	push   $0xf0103fb5
f0102680:	68 64 3d 10 f0       	push   $0xf0103d64
f0102685:	68 bc 03 00 00       	push   $0x3bc
f010268a:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010268f:	e8 73 da ff ff       	call   f0100107 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102694:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010269b:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010269e:	89 f0                	mov    %esi,%eax
f01026a0:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f01026a6:	c1 f8 03             	sar    $0x3,%eax
f01026a9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026ac:	89 c2                	mov    %eax,%edx
f01026ae:	c1 ea 0c             	shr    $0xc,%edx
f01026b1:	3b 15 48 79 11 f0    	cmp    0xf0117948,%edx
f01026b7:	72 12                	jb     f01026cb <mem_init+0x1554>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026b9:	50                   	push   %eax
f01026ba:	68 40 40 10 f0       	push   $0xf0104040
f01026bf:	6a 52                	push   $0x52
f01026c1:	68 4a 3d 10 f0       	push   $0xf0103d4a
f01026c6:	e8 3c da ff ff       	call   f0100107 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01026cb:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01026d2:	03 03 03 
f01026d5:	74 19                	je     f01026f0 <mem_init+0x1579>
f01026d7:	68 60 47 10 f0       	push   $0xf0104760
f01026dc:	68 64 3d 10 f0       	push   $0xf0103d64
f01026e1:	68 be 03 00 00       	push   $0x3be
f01026e6:	68 3e 3d 10 f0       	push   $0xf0103d3e
f01026eb:	e8 17 da ff ff       	call   f0100107 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01026f0:	83 ec 08             	sub    $0x8,%esp
f01026f3:	68 00 10 00 00       	push   $0x1000
f01026f8:	ff 35 4c 79 11 f0    	pushl  0xf011794c
f01026fe:	e8 bc e9 ff ff       	call   f01010bf <page_remove>
	assert(pp2->pp_ref == 0);
f0102703:	83 c4 10             	add    $0x10,%esp
f0102706:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010270b:	74 19                	je     f0102726 <mem_init+0x15af>
f010270d:	68 83 3f 10 f0       	push   $0xf0103f83
f0102712:	68 64 3d 10 f0       	push   $0xf0103d64
f0102717:	68 c0 03 00 00       	push   $0x3c0
f010271c:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102721:	e8 e1 d9 ff ff       	call   f0100107 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102726:	8b 0d 4c 79 11 f0    	mov    0xf011794c,%ecx
f010272c:	8b 11                	mov    (%ecx),%edx
f010272e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102734:	89 d8                	mov    %ebx,%eax
f0102736:	2b 05 50 79 11 f0    	sub    0xf0117950,%eax
f010273c:	c1 f8 03             	sar    $0x3,%eax
f010273f:	c1 e0 0c             	shl    $0xc,%eax
f0102742:	39 c2                	cmp    %eax,%edx
f0102744:	74 19                	je     f010275f <mem_init+0x15e8>
f0102746:	68 a4 42 10 f0       	push   $0xf01042a4
f010274b:	68 64 3d 10 f0       	push   $0xf0103d64
f0102750:	68 c3 03 00 00       	push   $0x3c3
f0102755:	68 3e 3d 10 f0       	push   $0xf0103d3e
f010275a:	e8 a8 d9 ff ff       	call   f0100107 <_panic>
	kern_pgdir[0] = 0;
f010275f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102765:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010276a:	74 19                	je     f0102785 <mem_init+0x160e>
f010276c:	68 3a 3f 10 f0       	push   $0xf0103f3a
f0102771:	68 64 3d 10 f0       	push   $0xf0103d64
f0102776:	68 c5 03 00 00       	push   $0x3c5
f010277b:	68 3e 3d 10 f0       	push   $0xf0103d3e
f0102780:	e8 82 d9 ff ff       	call   f0100107 <_panic>
	pp0->pp_ref = 0;
f0102785:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f010278b:	83 ec 0c             	sub    $0xc,%esp
f010278e:	53                   	push   %ebx
f010278f:	e8 72 e7 ff ff       	call   f0100f06 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102794:	c7 04 24 8c 47 10 f0 	movl   $0xf010478c,(%esp)
f010279b:	e8 7d 00 00 00       	call   f010281d <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01027a0:	83 c4 10             	add    $0x10,%esp
f01027a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01027a6:	5b                   	pop    %ebx
f01027a7:	5e                   	pop    %esi
f01027a8:	5f                   	pop    %edi
f01027a9:	5d                   	pop    %ebp
f01027aa:	c3                   	ret    

f01027ab <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01027ab:	55                   	push   %ebp
f01027ac:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01027ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027b1:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01027b4:	5d                   	pop    %ebp
f01027b5:	c3                   	ret    

f01027b6 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01027b6:	55                   	push   %ebp
f01027b7:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01027b9:	ba 70 00 00 00       	mov    $0x70,%edx
f01027be:	8b 45 08             	mov    0x8(%ebp),%eax
f01027c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01027c2:	ba 71 00 00 00       	mov    $0x71,%edx
f01027c7:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01027c8:	0f b6 c0             	movzbl %al,%eax
}
f01027cb:	5d                   	pop    %ebp
f01027cc:	c3                   	ret    

f01027cd <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01027cd:	55                   	push   %ebp
f01027ce:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01027d0:	ba 70 00 00 00       	mov    $0x70,%edx
f01027d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01027d8:	ee                   	out    %al,(%dx)
f01027d9:	ba 71 00 00 00       	mov    $0x71,%edx
f01027de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027e1:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01027e2:	5d                   	pop    %ebp
f01027e3:	c3                   	ret    

f01027e4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01027e4:	55                   	push   %ebp
f01027e5:	89 e5                	mov    %esp,%ebp
f01027e7:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01027ea:	ff 75 08             	pushl  0x8(%ebp)
f01027ed:	e8 8a de ff ff       	call   f010067c <cputchar>
	*cnt++;
}
f01027f2:	83 c4 10             	add    $0x10,%esp
f01027f5:	c9                   	leave  
f01027f6:	c3                   	ret    

f01027f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01027f7:	55                   	push   %ebp
f01027f8:	89 e5                	mov    %esp,%ebp
f01027fa:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01027fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102804:	ff 75 0c             	pushl  0xc(%ebp)
f0102807:	ff 75 08             	pushl  0x8(%ebp)
f010280a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010280d:	50                   	push   %eax
f010280e:	68 e4 27 10 f0       	push   $0xf01027e4
f0102813:	e8 3a 04 00 00       	call   f0102c52 <vprintfmt>
	return cnt;
}
f0102818:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010281b:	c9                   	leave  
f010281c:	c3                   	ret    

f010281d <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010281d:	55                   	push   %ebp
f010281e:	89 e5                	mov    %esp,%ebp
f0102820:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102823:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102826:	50                   	push   %eax
f0102827:	ff 75 08             	pushl  0x8(%ebp)
f010282a:	e8 c8 ff ff ff       	call   f01027f7 <vcprintf>
	va_end(ap);

	return cnt;
}
f010282f:	c9                   	leave  
f0102830:	c3                   	ret    

f0102831 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102831:	55                   	push   %ebp
f0102832:	89 e5                	mov    %esp,%ebp
f0102834:	57                   	push   %edi
f0102835:	56                   	push   %esi
f0102836:	53                   	push   %ebx
f0102837:	83 ec 14             	sub    $0x14,%esp
f010283a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010283d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102840:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102843:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102846:	8b 1a                	mov    (%edx),%ebx
f0102848:	8b 01                	mov    (%ecx),%eax
f010284a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010284d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102854:	eb 7f                	jmp    f01028d5 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0102856:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102859:	01 d8                	add    %ebx,%eax
f010285b:	89 c6                	mov    %eax,%esi
f010285d:	c1 ee 1f             	shr    $0x1f,%esi
f0102860:	01 c6                	add    %eax,%esi
f0102862:	d1 fe                	sar    %esi
f0102864:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0102867:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010286a:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010286d:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010286f:	eb 03                	jmp    f0102874 <stab_binsearch+0x43>
			m--;
f0102871:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102874:	39 c3                	cmp    %eax,%ebx
f0102876:	7f 0d                	jg     f0102885 <stab_binsearch+0x54>
f0102878:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010287c:	83 ea 0c             	sub    $0xc,%edx
f010287f:	39 f9                	cmp    %edi,%ecx
f0102881:	75 ee                	jne    f0102871 <stab_binsearch+0x40>
f0102883:	eb 05                	jmp    f010288a <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102885:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0102888:	eb 4b                	jmp    f01028d5 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010288a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010288d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102890:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102894:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102897:	76 11                	jbe    f01028aa <stab_binsearch+0x79>
			*region_left = m;
f0102899:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010289c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010289e:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01028a1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01028a8:	eb 2b                	jmp    f01028d5 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01028aa:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01028ad:	73 14                	jae    f01028c3 <stab_binsearch+0x92>
			*region_right = m - 1;
f01028af:	83 e8 01             	sub    $0x1,%eax
f01028b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01028b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01028b8:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01028ba:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01028c1:	eb 12                	jmp    f01028d5 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01028c3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01028c6:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01028c8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01028cc:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01028ce:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01028d5:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01028d8:	0f 8e 78 ff ff ff    	jle    f0102856 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01028de:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01028e2:	75 0f                	jne    f01028f3 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01028e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028e7:	8b 00                	mov    (%eax),%eax
f01028e9:	83 e8 01             	sub    $0x1,%eax
f01028ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01028ef:	89 06                	mov    %eax,(%esi)
f01028f1:	eb 2c                	jmp    f010291f <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01028f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028f6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01028f8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01028fb:	8b 0e                	mov    (%esi),%ecx
f01028fd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102900:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102903:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102906:	eb 03                	jmp    f010290b <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102908:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010290b:	39 c8                	cmp    %ecx,%eax
f010290d:	7e 0b                	jle    f010291a <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010290f:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0102913:	83 ea 0c             	sub    $0xc,%edx
f0102916:	39 df                	cmp    %ebx,%edi
f0102918:	75 ee                	jne    f0102908 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f010291a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010291d:	89 06                	mov    %eax,(%esi)
	}
}
f010291f:	83 c4 14             	add    $0x14,%esp
f0102922:	5b                   	pop    %ebx
f0102923:	5e                   	pop    %esi
f0102924:	5f                   	pop    %edi
f0102925:	5d                   	pop    %ebp
f0102926:	c3                   	ret    

f0102927 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102927:	55                   	push   %ebp
f0102928:	89 e5                	mov    %esp,%ebp
f010292a:	57                   	push   %edi
f010292b:	56                   	push   %esi
f010292c:	53                   	push   %ebx
f010292d:	83 ec 3c             	sub    $0x3c,%esp
f0102930:	8b 75 08             	mov    0x8(%ebp),%esi
f0102933:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102936:	c7 03 b8 47 10 f0    	movl   $0xf01047b8,(%ebx)
	info->eip_line = 0;
f010293c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102943:	c7 43 08 b8 47 10 f0 	movl   $0xf01047b8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010294a:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102951:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102954:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010295b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102961:	76 11                	jbe    f0102974 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102963:	b8 b0 c1 10 f0       	mov    $0xf010c1b0,%eax
f0102968:	3d c9 a3 10 f0       	cmp    $0xf010a3c9,%eax
f010296d:	77 19                	ja     f0102988 <debuginfo_eip+0x61>
f010296f:	e9 a1 01 00 00       	jmp    f0102b15 <debuginfo_eip+0x1ee>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102974:	83 ec 04             	sub    $0x4,%esp
f0102977:	68 c2 47 10 f0       	push   $0xf01047c2
f010297c:	6a 7f                	push   $0x7f
f010297e:	68 cf 47 10 f0       	push   $0xf01047cf
f0102983:	e8 7f d7 ff ff       	call   f0100107 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102988:	80 3d af c1 10 f0 00 	cmpb   $0x0,0xf010c1af
f010298f:	0f 85 87 01 00 00    	jne    f0102b1c <debuginfo_eip+0x1f5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102995:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010299c:	b8 c8 a3 10 f0       	mov    $0xf010a3c8,%eax
f01029a1:	2d ec 49 10 f0       	sub    $0xf01049ec,%eax
f01029a6:	c1 f8 02             	sar    $0x2,%eax
f01029a9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01029af:	83 e8 01             	sub    $0x1,%eax
f01029b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01029b5:	83 ec 08             	sub    $0x8,%esp
f01029b8:	56                   	push   %esi
f01029b9:	6a 64                	push   $0x64
f01029bb:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01029be:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01029c1:	b8 ec 49 10 f0       	mov    $0xf01049ec,%eax
f01029c6:	e8 66 fe ff ff       	call   f0102831 <stab_binsearch>
	if (lfile == 0)
f01029cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01029ce:	83 c4 10             	add    $0x10,%esp
f01029d1:	85 c0                	test   %eax,%eax
f01029d3:	0f 84 4a 01 00 00    	je     f0102b23 <debuginfo_eip+0x1fc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01029d9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01029dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029df:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01029e2:	83 ec 08             	sub    $0x8,%esp
f01029e5:	56                   	push   %esi
f01029e6:	6a 24                	push   $0x24
f01029e8:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01029eb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01029ee:	b8 ec 49 10 f0       	mov    $0xf01049ec,%eax
f01029f3:	e8 39 fe ff ff       	call   f0102831 <stab_binsearch>

	if (lfun <= rfun) {
f01029f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01029fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01029fe:	83 c4 10             	add    $0x10,%esp
f0102a01:	39 d0                	cmp    %edx,%eax
f0102a03:	7f 40                	jg     f0102a45 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102a05:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102a08:	c1 e1 02             	shl    $0x2,%ecx
f0102a0b:	8d b9 ec 49 10 f0    	lea    -0xfefb614(%ecx),%edi
f0102a11:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102a14:	8b b9 ec 49 10 f0    	mov    -0xfefb614(%ecx),%edi
f0102a1a:	b9 b0 c1 10 f0       	mov    $0xf010c1b0,%ecx
f0102a1f:	81 e9 c9 a3 10 f0    	sub    $0xf010a3c9,%ecx
f0102a25:	39 cf                	cmp    %ecx,%edi
f0102a27:	73 09                	jae    f0102a32 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102a29:	81 c7 c9 a3 10 f0    	add    $0xf010a3c9,%edi
f0102a2f:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102a32:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102a35:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102a38:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102a3b:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102a3d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102a40:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102a43:	eb 0f                	jmp    f0102a54 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102a45:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102a48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a4b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102a4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a51:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102a54:	83 ec 08             	sub    $0x8,%esp
f0102a57:	6a 3a                	push   $0x3a
f0102a59:	ff 73 08             	pushl  0x8(%ebx)
f0102a5c:	e8 7f 08 00 00       	call   f01032e0 <strfind>
f0102a61:	2b 43 08             	sub    0x8(%ebx),%eax
f0102a64:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102a67:	83 c4 08             	add    $0x8,%esp
f0102a6a:	56                   	push   %esi
f0102a6b:	6a 44                	push   $0x44
f0102a6d:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102a70:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102a73:	b8 ec 49 10 f0       	mov    $0xf01049ec,%eax
f0102a78:	e8 b4 fd ff ff       	call   f0102831 <stab_binsearch>
	// cprintf("symbol table: %d\n", stabs[lline].n_desc);
	info->eip_line = stabs[lline].n_desc;
f0102a7d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102a80:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102a83:	8d 04 85 ec 49 10 f0 	lea    -0xfefb614(,%eax,4),%eax
f0102a8a:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102a8e:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102a91:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102a94:	83 c4 10             	add    $0x10,%esp
f0102a97:	eb 06                	jmp    f0102a9f <debuginfo_eip+0x178>
f0102a99:	83 ea 01             	sub    $0x1,%edx
f0102a9c:	83 e8 0c             	sub    $0xc,%eax
f0102a9f:	39 d6                	cmp    %edx,%esi
f0102aa1:	7f 34                	jg     f0102ad7 <debuginfo_eip+0x1b0>
	       && stabs[lline].n_type != N_SOL
f0102aa3:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102aa7:	80 f9 84             	cmp    $0x84,%cl
f0102aaa:	74 0b                	je     f0102ab7 <debuginfo_eip+0x190>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102aac:	80 f9 64             	cmp    $0x64,%cl
f0102aaf:	75 e8                	jne    f0102a99 <debuginfo_eip+0x172>
f0102ab1:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102ab5:	74 e2                	je     f0102a99 <debuginfo_eip+0x172>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102ab7:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102aba:	8b 14 85 ec 49 10 f0 	mov    -0xfefb614(,%eax,4),%edx
f0102ac1:	b8 b0 c1 10 f0       	mov    $0xf010c1b0,%eax
f0102ac6:	2d c9 a3 10 f0       	sub    $0xf010a3c9,%eax
f0102acb:	39 c2                	cmp    %eax,%edx
f0102acd:	73 08                	jae    f0102ad7 <debuginfo_eip+0x1b0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102acf:	81 c2 c9 a3 10 f0    	add    $0xf010a3c9,%edx
f0102ad5:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102ad7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102ada:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102add:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102ae2:	39 f2                	cmp    %esi,%edx
f0102ae4:	7d 49                	jge    f0102b2f <debuginfo_eip+0x208>
		for (lline = lfun + 1;
f0102ae6:	83 c2 01             	add    $0x1,%edx
f0102ae9:	89 d0                	mov    %edx,%eax
f0102aeb:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102aee:	8d 14 95 ec 49 10 f0 	lea    -0xfefb614(,%edx,4),%edx
f0102af5:	eb 04                	jmp    f0102afb <debuginfo_eip+0x1d4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102af7:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102afb:	39 c6                	cmp    %eax,%esi
f0102afd:	7e 2b                	jle    f0102b2a <debuginfo_eip+0x203>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102aff:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102b03:	83 c0 01             	add    $0x1,%eax
f0102b06:	83 c2 0c             	add    $0xc,%edx
f0102b09:	80 f9 a0             	cmp    $0xa0,%cl
f0102b0c:	74 e9                	je     f0102af7 <debuginfo_eip+0x1d0>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102b0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b13:	eb 1a                	jmp    f0102b2f <debuginfo_eip+0x208>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102b15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b1a:	eb 13                	jmp    f0102b2f <debuginfo_eip+0x208>
f0102b1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b21:	eb 0c                	jmp    f0102b2f <debuginfo_eip+0x208>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102b23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102b28:	eb 05                	jmp    f0102b2f <debuginfo_eip+0x208>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102b2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102b2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b32:	5b                   	pop    %ebx
f0102b33:	5e                   	pop    %esi
f0102b34:	5f                   	pop    %edi
f0102b35:	5d                   	pop    %ebp
f0102b36:	c3                   	ret    

f0102b37 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102b37:	55                   	push   %ebp
f0102b38:	89 e5                	mov    %esp,%ebp
f0102b3a:	57                   	push   %edi
f0102b3b:	56                   	push   %esi
f0102b3c:	53                   	push   %ebx
f0102b3d:	83 ec 1c             	sub    $0x1c,%esp
f0102b40:	89 c7                	mov    %eax,%edi
f0102b42:	89 d6                	mov    %edx,%esi
f0102b44:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b47:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102b4a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102b4d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102b50:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102b53:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102b58:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102b5b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102b5e:	39 d3                	cmp    %edx,%ebx
f0102b60:	72 05                	jb     f0102b67 <printnum+0x30>
f0102b62:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102b65:	77 45                	ja     f0102bac <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102b67:	83 ec 0c             	sub    $0xc,%esp
f0102b6a:	ff 75 18             	pushl  0x18(%ebp)
f0102b6d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b70:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102b73:	53                   	push   %ebx
f0102b74:	ff 75 10             	pushl  0x10(%ebp)
f0102b77:	83 ec 08             	sub    $0x8,%esp
f0102b7a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b7d:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b80:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b83:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b86:	e8 75 09 00 00       	call   f0103500 <__udivdi3>
f0102b8b:	83 c4 18             	add    $0x18,%esp
f0102b8e:	52                   	push   %edx
f0102b8f:	50                   	push   %eax
f0102b90:	89 f2                	mov    %esi,%edx
f0102b92:	89 f8                	mov    %edi,%eax
f0102b94:	e8 9e ff ff ff       	call   f0102b37 <printnum>
f0102b99:	83 c4 20             	add    $0x20,%esp
f0102b9c:	eb 18                	jmp    f0102bb6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102b9e:	83 ec 08             	sub    $0x8,%esp
f0102ba1:	56                   	push   %esi
f0102ba2:	ff 75 18             	pushl  0x18(%ebp)
f0102ba5:	ff d7                	call   *%edi
f0102ba7:	83 c4 10             	add    $0x10,%esp
f0102baa:	eb 03                	jmp    f0102baf <printnum+0x78>
f0102bac:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102baf:	83 eb 01             	sub    $0x1,%ebx
f0102bb2:	85 db                	test   %ebx,%ebx
f0102bb4:	7f e8                	jg     f0102b9e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102bb6:	83 ec 08             	sub    $0x8,%esp
f0102bb9:	56                   	push   %esi
f0102bba:	83 ec 04             	sub    $0x4,%esp
f0102bbd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102bc0:	ff 75 e0             	pushl  -0x20(%ebp)
f0102bc3:	ff 75 dc             	pushl  -0x24(%ebp)
f0102bc6:	ff 75 d8             	pushl  -0x28(%ebp)
f0102bc9:	e8 62 0a 00 00       	call   f0103630 <__umoddi3>
f0102bce:	83 c4 14             	add    $0x14,%esp
f0102bd1:	0f be 80 dd 47 10 f0 	movsbl -0xfefb823(%eax),%eax
f0102bd8:	50                   	push   %eax
f0102bd9:	ff d7                	call   *%edi
}
f0102bdb:	83 c4 10             	add    $0x10,%esp
f0102bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102be1:	5b                   	pop    %ebx
f0102be2:	5e                   	pop    %esi
f0102be3:	5f                   	pop    %edi
f0102be4:	5d                   	pop    %ebp
f0102be5:	c3                   	ret    

f0102be6 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0102be6:	55                   	push   %ebp
f0102be7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102be9:	83 fa 01             	cmp    $0x1,%edx
f0102bec:	7e 0e                	jle    f0102bfc <getint+0x16>
		return va_arg(*ap, long long);
f0102bee:	8b 10                	mov    (%eax),%edx
f0102bf0:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102bf3:	89 08                	mov    %ecx,(%eax)
f0102bf5:	8b 02                	mov    (%edx),%eax
f0102bf7:	8b 52 04             	mov    0x4(%edx),%edx
f0102bfa:	eb 1a                	jmp    f0102c16 <getint+0x30>
	else if (lflag)
f0102bfc:	85 d2                	test   %edx,%edx
f0102bfe:	74 0c                	je     f0102c0c <getint+0x26>
		return va_arg(*ap, long);
f0102c00:	8b 10                	mov    (%eax),%edx
f0102c02:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102c05:	89 08                	mov    %ecx,(%eax)
f0102c07:	8b 02                	mov    (%edx),%eax
f0102c09:	99                   	cltd   
f0102c0a:	eb 0a                	jmp    f0102c16 <getint+0x30>
	else
		return va_arg(*ap, int);
f0102c0c:	8b 10                	mov    (%eax),%edx
f0102c0e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102c11:	89 08                	mov    %ecx,(%eax)
f0102c13:	8b 02                	mov    (%edx),%eax
f0102c15:	99                   	cltd   
}
f0102c16:	5d                   	pop    %ebp
f0102c17:	c3                   	ret    

f0102c18 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102c18:	55                   	push   %ebp
f0102c19:	89 e5                	mov    %esp,%ebp
f0102c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102c1e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102c22:	8b 10                	mov    (%eax),%edx
f0102c24:	3b 50 04             	cmp    0x4(%eax),%edx
f0102c27:	73 0a                	jae    f0102c33 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102c29:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102c2c:	89 08                	mov    %ecx,(%eax)
f0102c2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c31:	88 02                	mov    %al,(%edx)
}
f0102c33:	5d                   	pop    %ebp
f0102c34:	c3                   	ret    

f0102c35 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102c35:	55                   	push   %ebp
f0102c36:	89 e5                	mov    %esp,%ebp
f0102c38:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102c3b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102c3e:	50                   	push   %eax
f0102c3f:	ff 75 10             	pushl  0x10(%ebp)
f0102c42:	ff 75 0c             	pushl  0xc(%ebp)
f0102c45:	ff 75 08             	pushl  0x8(%ebp)
f0102c48:	e8 05 00 00 00       	call   f0102c52 <vprintfmt>
	va_end(ap);
}
f0102c4d:	83 c4 10             	add    $0x10,%esp
f0102c50:	c9                   	leave  
f0102c51:	c3                   	ret    

f0102c52 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102c52:	55                   	push   %ebp
f0102c53:	89 e5                	mov    %esp,%ebp
f0102c55:	57                   	push   %edi
f0102c56:	56                   	push   %esi
f0102c57:	53                   	push   %ebx
f0102c58:	83 ec 2c             	sub    $0x2c,%esp
f0102c5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	register const char *p;
	register int ch, err;
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int textcolor = 0x0700;
f0102c5e:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
f0102c65:	eb 1a                	jmp    f0102c81 <vprintfmt+0x2f>
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102c67:	85 c0                	test   %eax,%eax
f0102c69:	0f 84 c6 03 00 00    	je     f0103035 <vprintfmt+0x3e3>
			{
				return;
			}
			ch |= textcolor;
			putch(ch, putdat);
f0102c6f:	83 ec 08             	sub    $0x8,%esp
f0102c72:	ff 75 0c             	pushl  0xc(%ebp)
f0102c75:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102c78:	50                   	push   %eax
f0102c79:	ff 55 08             	call   *0x8(%ebp)
f0102c7c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;
	int textcolor = 0x0700;
	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102c7f:	89 fb                	mov    %edi,%ebx
f0102c81:	8d 7b 01             	lea    0x1(%ebx),%edi
f0102c84:	0f b6 03             	movzbl (%ebx),%eax
f0102c87:	83 f8 25             	cmp    $0x25,%eax
f0102c8a:	75 db                	jne    f0102c67 <vprintfmt+0x15>
f0102c8c:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0102c90:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102c97:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0102c9c:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0102ca3:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ca8:	eb 06                	jmp    f0102cb0 <vprintfmt+0x5e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102caa:	89 df                	mov    %ebx,%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102cac:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cb0:	8d 5f 01             	lea    0x1(%edi),%ebx
f0102cb3:	0f b6 07             	movzbl (%edi),%eax
f0102cb6:	0f b6 c8             	movzbl %al,%ecx
f0102cb9:	83 e8 23             	sub    $0x23,%eax
f0102cbc:	3c 55                	cmp    $0x55,%al
f0102cbe:	0f 87 51 03 00 00    	ja     f0103015 <vprintfmt+0x3c3>
f0102cc4:	0f b6 c0             	movzbl %al,%eax
f0102cc7:	ff 24 85 68 48 10 f0 	jmp    *-0xfefb798(,%eax,4)
f0102cce:	89 df                	mov    %ebx,%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102cd0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0102cd4:	eb da                	jmp    f0102cb0 <vprintfmt+0x5e>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cd6:	89 df                	mov    %ebx,%edi
f0102cd8:	be 00 00 00 00       	mov    $0x0,%esi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102cdd:	8d 04 b6             	lea    (%esi,%esi,4),%eax
f0102ce0:	8d 74 41 d0          	lea    -0x30(%ecx,%eax,2),%esi
				ch = *fmt;
f0102ce4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102ce7:	8d 41 d0             	lea    -0x30(%ecx),%eax
f0102cea:	83 f8 09             	cmp    $0x9,%eax
f0102ced:	77 33                	ja     f0102d22 <vprintfmt+0xd0>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102cef:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102cf2:	eb e9                	jmp    f0102cdd <vprintfmt+0x8b>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102cf4:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cf7:	8d 48 04             	lea    0x4(%eax),%ecx
f0102cfa:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102cfd:	8b 30                	mov    (%eax),%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cff:	89 df                	mov    %ebx,%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102d01:	eb 1f                	jmp    f0102d22 <vprintfmt+0xd0>
f0102d03:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102d06:	85 c0                	test   %eax,%eax
f0102d08:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102d0d:	0f 49 c8             	cmovns %eax,%ecx
f0102d10:	89 4d dc             	mov    %ecx,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d13:	89 df                	mov    %ebx,%edi
f0102d15:	eb 99                	jmp    f0102cb0 <vprintfmt+0x5e>
f0102d17:	89 df                	mov    %ebx,%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102d19:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0102d20:	eb 8e                	jmp    f0102cb0 <vprintfmt+0x5e>

		process_precision:
			if (width < 0)
f0102d22:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102d26:	79 88                	jns    f0102cb0 <vprintfmt+0x5e>
				width = precision, precision = -1;
f0102d28:	89 75 dc             	mov    %esi,-0x24(%ebp)
f0102d2b:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0102d30:	e9 7b ff ff ff       	jmp    f0102cb0 <vprintfmt+0x5e>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102d35:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d38:	89 df                	mov    %ebx,%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102d3a:	e9 71 ff ff ff       	jmp    f0102cb0 <vprintfmt+0x5e>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102d3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d42:	8d 50 04             	lea    0x4(%eax),%edx
f0102d45:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d48:	83 ec 08             	sub    $0x8,%esp
f0102d4b:	ff 75 0c             	pushl  0xc(%ebp)
f0102d4e:	ff 30                	pushl  (%eax)
f0102d50:	ff 55 08             	call   *0x8(%ebp)
			break;
f0102d53:	83 c4 10             	add    $0x10,%esp
f0102d56:	e9 26 ff ff ff       	jmp    f0102c81 <vprintfmt+0x2f>
		// set color
		case 'm':
			num = getint(&ap, lflag);
f0102d5b:	8d 45 14             	lea    0x14(%ebp),%eax
f0102d5e:	e8 83 fe ff ff       	call   f0102be6 <getint>
f0102d63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			textcolor = num;
			break;
f0102d66:	e9 16 ff ff ff       	jmp    f0102c81 <vprintfmt+0x2f>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102d6b:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d6e:	8d 50 04             	lea    0x4(%eax),%edx
f0102d71:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d74:	8b 00                	mov    (%eax),%eax
f0102d76:	99                   	cltd   
f0102d77:	31 d0                	xor    %edx,%eax
f0102d79:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102d7b:	83 f8 06             	cmp    $0x6,%eax
f0102d7e:	7f 0b                	jg     f0102d8b <vprintfmt+0x139>
f0102d80:	8b 14 85 c0 49 10 f0 	mov    -0xfefb640(,%eax,4),%edx
f0102d87:	85 d2                	test   %edx,%edx
f0102d89:	75 19                	jne    f0102da4 <vprintfmt+0x152>
				printfmt(putch, putdat, "error %d", err);
f0102d8b:	50                   	push   %eax
f0102d8c:	68 f5 47 10 f0       	push   $0xf01047f5
f0102d91:	ff 75 0c             	pushl  0xc(%ebp)
f0102d94:	ff 75 08             	pushl  0x8(%ebp)
f0102d97:	e8 99 fe ff ff       	call   f0102c35 <printfmt>
f0102d9c:	83 c4 10             	add    $0x10,%esp
f0102d9f:	e9 dd fe ff ff       	jmp    f0102c81 <vprintfmt+0x2f>
			else
				printfmt(putch, putdat, "%s", p);
f0102da4:	52                   	push   %edx
f0102da5:	68 76 3d 10 f0       	push   $0xf0103d76
f0102daa:	ff 75 0c             	pushl  0xc(%ebp)
f0102dad:	ff 75 08             	pushl  0x8(%ebp)
f0102db0:	e8 80 fe ff ff       	call   f0102c35 <printfmt>
f0102db5:	83 c4 10             	add    $0x10,%esp
f0102db8:	e9 c4 fe ff ff       	jmp    f0102c81 <vprintfmt+0x2f>
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102dbd:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dc0:	8d 50 04             	lea    0x4(%eax),%edx
f0102dc3:	89 55 14             	mov    %edx,0x14(%ebp)
f0102dc6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102dc8:	85 ff                	test   %edi,%edi
f0102dca:	b8 ee 47 10 f0       	mov    $0xf01047ee,%eax
f0102dcf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102dd2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102dd6:	0f 8e 93 00 00 00    	jle    f0102e6f <vprintfmt+0x21d>
f0102ddc:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0102de0:	0f 84 91 00 00 00    	je     f0102e77 <vprintfmt+0x225>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102de6:	83 ec 08             	sub    $0x8,%esp
f0102de9:	56                   	push   %esi
f0102dea:	57                   	push   %edi
f0102deb:	e8 a6 03 00 00       	call   f0103196 <strnlen>
f0102df0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102df3:	29 c2                	sub    %eax,%edx
f0102df5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102df8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102dfb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0102dff:	89 7d d8             	mov    %edi,-0x28(%ebp)
f0102e02:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102e05:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102e08:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0102e0b:	89 d3                	mov    %edx,%ebx
f0102e0d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e0f:	eb 0e                	jmp    f0102e1f <vprintfmt+0x1cd>
					putch(padc, putdat);
f0102e11:	83 ec 08             	sub    $0x8,%esp
f0102e14:	56                   	push   %esi
f0102e15:	57                   	push   %edi
f0102e16:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102e19:	83 eb 01             	sub    $0x1,%ebx
f0102e1c:	83 c4 10             	add    $0x10,%esp
f0102e1f:	85 db                	test   %ebx,%ebx
f0102e21:	7f ee                	jg     f0102e11 <vprintfmt+0x1bf>
f0102e23:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0102e26:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102e29:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e2c:	85 d2                	test   %edx,%edx
f0102e2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e33:	0f 49 c2             	cmovns %edx,%eax
f0102e36:	29 c2                	sub    %eax,%edx
f0102e38:	89 d3                	mov    %edx,%ebx
f0102e3a:	eb 41                	jmp    f0102e7d <vprintfmt+0x22b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102e3c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102e40:	74 1b                	je     f0102e5d <vprintfmt+0x20b>
f0102e42:	0f be c0             	movsbl %al,%eax
f0102e45:	83 e8 20             	sub    $0x20,%eax
f0102e48:	83 f8 5e             	cmp    $0x5e,%eax
f0102e4b:	76 10                	jbe    f0102e5d <vprintfmt+0x20b>
					putch('?', putdat);
f0102e4d:	83 ec 08             	sub    $0x8,%esp
f0102e50:	ff 75 0c             	pushl  0xc(%ebp)
f0102e53:	6a 3f                	push   $0x3f
f0102e55:	ff 55 08             	call   *0x8(%ebp)
f0102e58:	83 c4 10             	add    $0x10,%esp
f0102e5b:	eb 0d                	jmp    f0102e6a <vprintfmt+0x218>
				else
					putch(ch, putdat);
f0102e5d:	83 ec 08             	sub    $0x8,%esp
f0102e60:	ff 75 0c             	pushl  0xc(%ebp)
f0102e63:	52                   	push   %edx
f0102e64:	ff 55 08             	call   *0x8(%ebp)
f0102e67:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102e6a:	83 eb 01             	sub    $0x1,%ebx
f0102e6d:	eb 0e                	jmp    f0102e7d <vprintfmt+0x22b>
f0102e6f:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0102e72:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0102e75:	eb 06                	jmp    f0102e7d <vprintfmt+0x22b>
f0102e77:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0102e7a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0102e7d:	83 c7 01             	add    $0x1,%edi
f0102e80:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102e84:	0f be d0             	movsbl %al,%edx
f0102e87:	85 d2                	test   %edx,%edx
f0102e89:	74 25                	je     f0102eb0 <vprintfmt+0x25e>
f0102e8b:	85 f6                	test   %esi,%esi
f0102e8d:	78 ad                	js     f0102e3c <vprintfmt+0x1ea>
f0102e8f:	83 ee 01             	sub    $0x1,%esi
f0102e92:	79 a8                	jns    f0102e3c <vprintfmt+0x1ea>
f0102e94:	89 d8                	mov    %ebx,%eax
f0102e96:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e99:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102e9c:	89 c3                	mov    %eax,%ebx
f0102e9e:	eb 16                	jmp    f0102eb6 <vprintfmt+0x264>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102ea0:	83 ec 08             	sub    $0x8,%esp
f0102ea3:	57                   	push   %edi
f0102ea4:	6a 20                	push   $0x20
f0102ea6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102ea8:	83 eb 01             	sub    $0x1,%ebx
f0102eab:	83 c4 10             	add    $0x10,%esp
f0102eae:	eb 06                	jmp    f0102eb6 <vprintfmt+0x264>
f0102eb0:	8b 75 08             	mov    0x8(%ebp),%esi
f0102eb3:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102eb6:	85 db                	test   %ebx,%ebx
f0102eb8:	7f e6                	jg     f0102ea0 <vprintfmt+0x24e>
f0102eba:	89 75 08             	mov    %esi,0x8(%ebp)
f0102ebd:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0102ec0:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0102ec3:	e9 b9 fd ff ff       	jmp    f0102c81 <vprintfmt+0x2f>
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102ec8:	8d 45 14             	lea    0x14(%ebp),%eax
f0102ecb:	e8 16 fd ff ff       	call   f0102be6 <getint>
f0102ed0:	89 c6                	mov    %eax,%esi
f0102ed2:	89 d7                	mov    %edx,%edi
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102ed4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102ed9:	85 d2                	test   %edx,%edx
f0102edb:	0f 89 01 01 00 00    	jns    f0102fe2 <vprintfmt+0x390>
				putch('-', putdat);
f0102ee1:	83 ec 08             	sub    $0x8,%esp
f0102ee4:	ff 75 0c             	pushl  0xc(%ebp)
f0102ee7:	6a 2d                	push   $0x2d
f0102ee9:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0102eec:	89 f0                	mov    %esi,%eax
f0102eee:	89 fa                	mov    %edi,%edx
f0102ef0:	f7 d8                	neg    %eax
f0102ef2:	83 d2 00             	adc    $0x0,%edx
f0102ef5:	f7 da                	neg    %edx
f0102ef7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102efa:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102eff:	e9 de 00 00 00       	jmp    f0102fe2 <vprintfmt+0x390>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102f04:	83 fa 01             	cmp    $0x1,%edx
f0102f07:	7e 18                	jle    f0102f21 <vprintfmt+0x2cf>
		return va_arg(*ap, unsigned long long);
f0102f09:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f0c:	8d 50 08             	lea    0x8(%eax),%edx
f0102f0f:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f12:	8b 50 04             	mov    0x4(%eax),%edx
f0102f15:	8b 00                	mov    (%eax),%eax
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102f17:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102f1c:	e9 c1 00 00 00       	jmp    f0102fe2 <vprintfmt+0x390>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0102f21:	85 d2                	test   %edx,%edx
f0102f23:	74 1a                	je     f0102f3f <vprintfmt+0x2ed>
		return va_arg(*ap, unsigned long);
f0102f25:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f28:	8d 50 04             	lea    0x4(%eax),%edx
f0102f2b:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f2e:	8b 00                	mov    (%eax),%eax
f0102f30:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102f35:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102f3a:	e9 a3 00 00 00       	jmp    f0102fe2 <vprintfmt+0x390>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0102f3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f42:	8d 50 04             	lea    0x4(%eax),%edx
f0102f45:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f48:	8b 00                	mov    (%eax),%eax
f0102f4a:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102f4f:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102f54:	e9 89 00 00 00       	jmp    f0102fe2 <vprintfmt+0x390>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getint(&ap, lflag);
f0102f59:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f5c:	e8 85 fc ff ff       	call   f0102be6 <getint>
			base = 8;
f0102f61:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0102f66:	eb 7a                	jmp    f0102fe2 <vprintfmt+0x390>

		// pointer
		case 'p':
			putch('0', putdat);
f0102f68:	83 ec 08             	sub    $0x8,%esp
f0102f6b:	ff 75 0c             	pushl  0xc(%ebp)
f0102f6e:	6a 30                	push   $0x30
f0102f70:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0102f73:	83 c4 08             	add    $0x8,%esp
f0102f76:	ff 75 0c             	pushl  0xc(%ebp)
f0102f79:	6a 78                	push   $0x78
f0102f7b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102f7e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f81:	8d 50 04             	lea    0x4(%eax),%edx
f0102f84:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102f87:	8b 00                	mov    (%eax),%eax
f0102f89:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102f8e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102f91:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102f96:	eb 4a                	jmp    f0102fe2 <vprintfmt+0x390>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102f98:	83 fa 01             	cmp    $0x1,%edx
f0102f9b:	7e 15                	jle    f0102fb2 <vprintfmt+0x360>
		return va_arg(*ap, unsigned long long);
f0102f9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fa0:	8d 50 08             	lea    0x8(%eax),%edx
f0102fa3:	89 55 14             	mov    %edx,0x14(%ebp)
f0102fa6:	8b 50 04             	mov    0x4(%eax),%edx
f0102fa9:	8b 00                	mov    (%eax),%eax
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102fab:	b9 10 00 00 00       	mov    $0x10,%ecx
f0102fb0:	eb 30                	jmp    f0102fe2 <vprintfmt+0x390>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0102fb2:	85 d2                	test   %edx,%edx
f0102fb4:	74 17                	je     f0102fcd <vprintfmt+0x37b>
		return va_arg(*ap, unsigned long);
f0102fb6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fb9:	8d 50 04             	lea    0x4(%eax),%edx
f0102fbc:	89 55 14             	mov    %edx,0x14(%ebp)
f0102fbf:	8b 00                	mov    (%eax),%eax
f0102fc1:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102fc6:	b9 10 00 00 00       	mov    $0x10,%ecx
f0102fcb:	eb 15                	jmp    f0102fe2 <vprintfmt+0x390>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0102fcd:	8b 45 14             	mov    0x14(%ebp),%eax
f0102fd0:	8d 50 04             	lea    0x4(%eax),%edx
f0102fd3:	89 55 14             	mov    %edx,0x14(%ebp)
f0102fd6:	8b 00                	mov    (%eax),%eax
f0102fd8:	ba 00 00 00 00       	mov    $0x0,%edx
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102fdd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102fe2:	83 ec 0c             	sub    $0xc,%esp
f0102fe5:	0f be 7d d8          	movsbl -0x28(%ebp),%edi
f0102fe9:	57                   	push   %edi
f0102fea:	ff 75 dc             	pushl  -0x24(%ebp)
f0102fed:	51                   	push   %ecx
f0102fee:	52                   	push   %edx
f0102fef:	50                   	push   %eax
f0102ff0:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102ff3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ff6:	e8 3c fb ff ff       	call   f0102b37 <printnum>
			break;
f0102ffb:	83 c4 20             	add    $0x20,%esp
f0102ffe:	e9 7e fc ff ff       	jmp    f0102c81 <vprintfmt+0x2f>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103003:	83 ec 08             	sub    $0x8,%esp
f0103006:	ff 75 0c             	pushl  0xc(%ebp)
f0103009:	51                   	push   %ecx
f010300a:	ff 55 08             	call   *0x8(%ebp)
			break;
f010300d:	83 c4 10             	add    $0x10,%esp
f0103010:	e9 6c fc ff ff       	jmp    f0102c81 <vprintfmt+0x2f>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103015:	83 ec 08             	sub    $0x8,%esp
f0103018:	ff 75 0c             	pushl  0xc(%ebp)
f010301b:	6a 25                	push   $0x25
f010301d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103020:	83 c4 10             	add    $0x10,%esp
f0103023:	89 fb                	mov    %edi,%ebx
f0103025:	eb 03                	jmp    f010302a <vprintfmt+0x3d8>
f0103027:	83 eb 01             	sub    $0x1,%ebx
f010302a:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f010302e:	75 f7                	jne    f0103027 <vprintfmt+0x3d5>
f0103030:	e9 4c fc ff ff       	jmp    f0102c81 <vprintfmt+0x2f>
				/* do nothing */;
			break;
		}
	}
}
f0103035:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103038:	5b                   	pop    %ebx
f0103039:	5e                   	pop    %esi
f010303a:	5f                   	pop    %edi
f010303b:	5d                   	pop    %ebp
f010303c:	c3                   	ret    

f010303d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010303d:	55                   	push   %ebp
f010303e:	89 e5                	mov    %esp,%ebp
f0103040:	83 ec 18             	sub    $0x18,%esp
f0103043:	8b 45 08             	mov    0x8(%ebp),%eax
f0103046:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103049:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010304c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103050:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103053:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010305a:	85 c0                	test   %eax,%eax
f010305c:	74 26                	je     f0103084 <vsnprintf+0x47>
f010305e:	85 d2                	test   %edx,%edx
f0103060:	7e 22                	jle    f0103084 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103062:	ff 75 14             	pushl  0x14(%ebp)
f0103065:	ff 75 10             	pushl  0x10(%ebp)
f0103068:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010306b:	50                   	push   %eax
f010306c:	68 18 2c 10 f0       	push   $0xf0102c18
f0103071:	e8 dc fb ff ff       	call   f0102c52 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103076:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103079:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010307c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010307f:	83 c4 10             	add    $0x10,%esp
f0103082:	eb 05                	jmp    f0103089 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103084:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103089:	c9                   	leave  
f010308a:	c3                   	ret    

f010308b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010308b:	55                   	push   %ebp
f010308c:	89 e5                	mov    %esp,%ebp
f010308e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103091:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103094:	50                   	push   %eax
f0103095:	ff 75 10             	pushl  0x10(%ebp)
f0103098:	ff 75 0c             	pushl  0xc(%ebp)
f010309b:	ff 75 08             	pushl  0x8(%ebp)
f010309e:	e8 9a ff ff ff       	call   f010303d <vsnprintf>
	va_end(ap);

	return rc;
}
f01030a3:	c9                   	leave  
f01030a4:	c3                   	ret    

f01030a5 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01030a5:	55                   	push   %ebp
f01030a6:	89 e5                	mov    %esp,%ebp
f01030a8:	57                   	push   %edi
f01030a9:	56                   	push   %esi
f01030aa:	53                   	push   %ebx
f01030ab:	83 ec 0c             	sub    $0xc,%esp
f01030ae:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01030b1:	85 c0                	test   %eax,%eax
f01030b3:	74 11                	je     f01030c6 <readline+0x21>
		cprintf("%s", prompt);
f01030b5:	83 ec 08             	sub    $0x8,%esp
f01030b8:	50                   	push   %eax
f01030b9:	68 76 3d 10 f0       	push   $0xf0103d76
f01030be:	e8 5a f7 ff ff       	call   f010281d <cprintf>
f01030c3:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01030c6:	83 ec 0c             	sub    $0xc,%esp
f01030c9:	6a 00                	push   $0x0
f01030cb:	e8 cd d5 ff ff       	call   f010069d <iscons>
f01030d0:	89 c7                	mov    %eax,%edi
f01030d2:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01030d5:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01030da:	e8 ad d5 ff ff       	call   f010068c <getchar>
f01030df:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01030e1:	85 c0                	test   %eax,%eax
f01030e3:	79 18                	jns    f01030fd <readline+0x58>
			cprintf("read error: %e\n", c);
f01030e5:	83 ec 08             	sub    $0x8,%esp
f01030e8:	50                   	push   %eax
f01030e9:	68 dc 49 10 f0       	push   $0xf01049dc
f01030ee:	e8 2a f7 ff ff       	call   f010281d <cprintf>
			return NULL;
f01030f3:	83 c4 10             	add    $0x10,%esp
f01030f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01030fb:	eb 79                	jmp    f0103176 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01030fd:	83 f8 08             	cmp    $0x8,%eax
f0103100:	0f 94 c2             	sete   %dl
f0103103:	83 f8 7f             	cmp    $0x7f,%eax
f0103106:	0f 94 c0             	sete   %al
f0103109:	08 c2                	or     %al,%dl
f010310b:	74 1a                	je     f0103127 <readline+0x82>
f010310d:	85 f6                	test   %esi,%esi
f010310f:	7e 16                	jle    f0103127 <readline+0x82>
			if (echoing)
f0103111:	85 ff                	test   %edi,%edi
f0103113:	74 0d                	je     f0103122 <readline+0x7d>
				cputchar('\b');
f0103115:	83 ec 0c             	sub    $0xc,%esp
f0103118:	6a 08                	push   $0x8
f010311a:	e8 5d d5 ff ff       	call   f010067c <cputchar>
f010311f:	83 c4 10             	add    $0x10,%esp
			i--;
f0103122:	83 ee 01             	sub    $0x1,%esi
f0103125:	eb b3                	jmp    f01030da <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103127:	83 fb 1f             	cmp    $0x1f,%ebx
f010312a:	7e 23                	jle    f010314f <readline+0xaa>
f010312c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103132:	7f 1b                	jg     f010314f <readline+0xaa>
			if (echoing)
f0103134:	85 ff                	test   %edi,%edi
f0103136:	74 0c                	je     f0103144 <readline+0x9f>
				cputchar(c);
f0103138:	83 ec 0c             	sub    $0xc,%esp
f010313b:	53                   	push   %ebx
f010313c:	e8 3b d5 ff ff       	call   f010067c <cputchar>
f0103141:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103144:	88 9e 40 75 11 f0    	mov    %bl,-0xfee8ac0(%esi)
f010314a:	8d 76 01             	lea    0x1(%esi),%esi
f010314d:	eb 8b                	jmp    f01030da <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010314f:	83 fb 0a             	cmp    $0xa,%ebx
f0103152:	74 05                	je     f0103159 <readline+0xb4>
f0103154:	83 fb 0d             	cmp    $0xd,%ebx
f0103157:	75 81                	jne    f01030da <readline+0x35>
			if (echoing)
f0103159:	85 ff                	test   %edi,%edi
f010315b:	74 0d                	je     f010316a <readline+0xc5>
				cputchar('\n');
f010315d:	83 ec 0c             	sub    $0xc,%esp
f0103160:	6a 0a                	push   $0xa
f0103162:	e8 15 d5 ff ff       	call   f010067c <cputchar>
f0103167:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010316a:	c6 86 40 75 11 f0 00 	movb   $0x0,-0xfee8ac0(%esi)
			return buf;
f0103171:	b8 40 75 11 f0       	mov    $0xf0117540,%eax
		}
	}
}
f0103176:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103179:	5b                   	pop    %ebx
f010317a:	5e                   	pop    %esi
f010317b:	5f                   	pop    %edi
f010317c:	5d                   	pop    %ebp
f010317d:	c3                   	ret    

f010317e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010317e:	55                   	push   %ebp
f010317f:	89 e5                	mov    %esp,%ebp
f0103181:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103184:	b8 00 00 00 00       	mov    $0x0,%eax
f0103189:	eb 03                	jmp    f010318e <strlen+0x10>
		n++;
f010318b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010318e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103192:	75 f7                	jne    f010318b <strlen+0xd>
		n++;
	return n;
}
f0103194:	5d                   	pop    %ebp
f0103195:	c3                   	ret    

f0103196 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103196:	55                   	push   %ebp
f0103197:	89 e5                	mov    %esp,%ebp
f0103199:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010319c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010319f:	ba 00 00 00 00       	mov    $0x0,%edx
f01031a4:	eb 03                	jmp    f01031a9 <strnlen+0x13>
		n++;
f01031a6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01031a9:	39 c2                	cmp    %eax,%edx
f01031ab:	74 08                	je     f01031b5 <strnlen+0x1f>
f01031ad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01031b1:	75 f3                	jne    f01031a6 <strnlen+0x10>
f01031b3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01031b5:	5d                   	pop    %ebp
f01031b6:	c3                   	ret    

f01031b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01031b7:	55                   	push   %ebp
f01031b8:	89 e5                	mov    %esp,%ebp
f01031ba:	53                   	push   %ebx
f01031bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01031be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01031c1:	89 c2                	mov    %eax,%edx
f01031c3:	83 c2 01             	add    $0x1,%edx
f01031c6:	83 c1 01             	add    $0x1,%ecx
f01031c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01031cd:	88 5a ff             	mov    %bl,-0x1(%edx)
f01031d0:	84 db                	test   %bl,%bl
f01031d2:	75 ef                	jne    f01031c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01031d4:	5b                   	pop    %ebx
f01031d5:	5d                   	pop    %ebp
f01031d6:	c3                   	ret    

f01031d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01031d7:	55                   	push   %ebp
f01031d8:	89 e5                	mov    %esp,%ebp
f01031da:	53                   	push   %ebx
f01031db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01031de:	53                   	push   %ebx
f01031df:	e8 9a ff ff ff       	call   f010317e <strlen>
f01031e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01031e7:	ff 75 0c             	pushl  0xc(%ebp)
f01031ea:	01 d8                	add    %ebx,%eax
f01031ec:	50                   	push   %eax
f01031ed:	e8 c5 ff ff ff       	call   f01031b7 <strcpy>
	return dst;
}
f01031f2:	89 d8                	mov    %ebx,%eax
f01031f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01031f7:	c9                   	leave  
f01031f8:	c3                   	ret    

f01031f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01031f9:	55                   	push   %ebp
f01031fa:	89 e5                	mov    %esp,%ebp
f01031fc:	56                   	push   %esi
f01031fd:	53                   	push   %ebx
f01031fe:	8b 75 08             	mov    0x8(%ebp),%esi
f0103201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103204:	89 f3                	mov    %esi,%ebx
f0103206:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103209:	89 f2                	mov    %esi,%edx
f010320b:	eb 0f                	jmp    f010321c <strncpy+0x23>
		*dst++ = *src;
f010320d:	83 c2 01             	add    $0x1,%edx
f0103210:	0f b6 01             	movzbl (%ecx),%eax
f0103213:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103216:	80 39 01             	cmpb   $0x1,(%ecx)
f0103219:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010321c:	39 da                	cmp    %ebx,%edx
f010321e:	75 ed                	jne    f010320d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103220:	89 f0                	mov    %esi,%eax
f0103222:	5b                   	pop    %ebx
f0103223:	5e                   	pop    %esi
f0103224:	5d                   	pop    %ebp
f0103225:	c3                   	ret    

f0103226 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103226:	55                   	push   %ebp
f0103227:	89 e5                	mov    %esp,%ebp
f0103229:	56                   	push   %esi
f010322a:	53                   	push   %ebx
f010322b:	8b 75 08             	mov    0x8(%ebp),%esi
f010322e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103231:	8b 55 10             	mov    0x10(%ebp),%edx
f0103234:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103236:	85 d2                	test   %edx,%edx
f0103238:	74 21                	je     f010325b <strlcpy+0x35>
f010323a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010323e:	89 f2                	mov    %esi,%edx
f0103240:	eb 09                	jmp    f010324b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103242:	83 c2 01             	add    $0x1,%edx
f0103245:	83 c1 01             	add    $0x1,%ecx
f0103248:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010324b:	39 c2                	cmp    %eax,%edx
f010324d:	74 09                	je     f0103258 <strlcpy+0x32>
f010324f:	0f b6 19             	movzbl (%ecx),%ebx
f0103252:	84 db                	test   %bl,%bl
f0103254:	75 ec                	jne    f0103242 <strlcpy+0x1c>
f0103256:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103258:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010325b:	29 f0                	sub    %esi,%eax
}
f010325d:	5b                   	pop    %ebx
f010325e:	5e                   	pop    %esi
f010325f:	5d                   	pop    %ebp
f0103260:	c3                   	ret    

f0103261 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103261:	55                   	push   %ebp
f0103262:	89 e5                	mov    %esp,%ebp
f0103264:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103267:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010326a:	eb 06                	jmp    f0103272 <strcmp+0x11>
		p++, q++;
f010326c:	83 c1 01             	add    $0x1,%ecx
f010326f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103272:	0f b6 01             	movzbl (%ecx),%eax
f0103275:	84 c0                	test   %al,%al
f0103277:	74 04                	je     f010327d <strcmp+0x1c>
f0103279:	3a 02                	cmp    (%edx),%al
f010327b:	74 ef                	je     f010326c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010327d:	0f b6 c0             	movzbl %al,%eax
f0103280:	0f b6 12             	movzbl (%edx),%edx
f0103283:	29 d0                	sub    %edx,%eax
}
f0103285:	5d                   	pop    %ebp
f0103286:	c3                   	ret    

f0103287 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103287:	55                   	push   %ebp
f0103288:	89 e5                	mov    %esp,%ebp
f010328a:	53                   	push   %ebx
f010328b:	8b 45 08             	mov    0x8(%ebp),%eax
f010328e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103291:	89 c3                	mov    %eax,%ebx
f0103293:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103296:	eb 06                	jmp    f010329e <strncmp+0x17>
		n--, p++, q++;
f0103298:	83 c0 01             	add    $0x1,%eax
f010329b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010329e:	39 d8                	cmp    %ebx,%eax
f01032a0:	74 15                	je     f01032b7 <strncmp+0x30>
f01032a2:	0f b6 08             	movzbl (%eax),%ecx
f01032a5:	84 c9                	test   %cl,%cl
f01032a7:	74 04                	je     f01032ad <strncmp+0x26>
f01032a9:	3a 0a                	cmp    (%edx),%cl
f01032ab:	74 eb                	je     f0103298 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01032ad:	0f b6 00             	movzbl (%eax),%eax
f01032b0:	0f b6 12             	movzbl (%edx),%edx
f01032b3:	29 d0                	sub    %edx,%eax
f01032b5:	eb 05                	jmp    f01032bc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01032b7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01032bc:	5b                   	pop    %ebx
f01032bd:	5d                   	pop    %ebp
f01032be:	c3                   	ret    

f01032bf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01032bf:	55                   	push   %ebp
f01032c0:	89 e5                	mov    %esp,%ebp
f01032c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01032c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01032c9:	eb 07                	jmp    f01032d2 <strchr+0x13>
		if (*s == c)
f01032cb:	38 ca                	cmp    %cl,%dl
f01032cd:	74 0f                	je     f01032de <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01032cf:	83 c0 01             	add    $0x1,%eax
f01032d2:	0f b6 10             	movzbl (%eax),%edx
f01032d5:	84 d2                	test   %dl,%dl
f01032d7:	75 f2                	jne    f01032cb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01032d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01032de:	5d                   	pop    %ebp
f01032df:	c3                   	ret    

f01032e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01032e0:	55                   	push   %ebp
f01032e1:	89 e5                	mov    %esp,%ebp
f01032e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01032e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01032ea:	eb 03                	jmp    f01032ef <strfind+0xf>
f01032ec:	83 c0 01             	add    $0x1,%eax
f01032ef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01032f2:	38 ca                	cmp    %cl,%dl
f01032f4:	74 04                	je     f01032fa <strfind+0x1a>
f01032f6:	84 d2                	test   %dl,%dl
f01032f8:	75 f2                	jne    f01032ec <strfind+0xc>
			break;
	return (char *) s;
}
f01032fa:	5d                   	pop    %ebp
f01032fb:	c3                   	ret    

f01032fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01032fc:	55                   	push   %ebp
f01032fd:	89 e5                	mov    %esp,%ebp
f01032ff:	57                   	push   %edi
f0103300:	56                   	push   %esi
f0103301:	53                   	push   %ebx
f0103302:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103305:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103308:	85 c9                	test   %ecx,%ecx
f010330a:	74 36                	je     f0103342 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010330c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103312:	75 28                	jne    f010333c <memset+0x40>
f0103314:	f6 c1 03             	test   $0x3,%cl
f0103317:	75 23                	jne    f010333c <memset+0x40>
		c &= 0xFF;
f0103319:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010331d:	89 d3                	mov    %edx,%ebx
f010331f:	c1 e3 08             	shl    $0x8,%ebx
f0103322:	89 d6                	mov    %edx,%esi
f0103324:	c1 e6 18             	shl    $0x18,%esi
f0103327:	89 d0                	mov    %edx,%eax
f0103329:	c1 e0 10             	shl    $0x10,%eax
f010332c:	09 f0                	or     %esi,%eax
f010332e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0103330:	89 d8                	mov    %ebx,%eax
f0103332:	09 d0                	or     %edx,%eax
f0103334:	c1 e9 02             	shr    $0x2,%ecx
f0103337:	fc                   	cld    
f0103338:	f3 ab                	rep stos %eax,%es:(%edi)
f010333a:	eb 06                	jmp    f0103342 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010333c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010333f:	fc                   	cld    
f0103340:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103342:	89 f8                	mov    %edi,%eax
f0103344:	5b                   	pop    %ebx
f0103345:	5e                   	pop    %esi
f0103346:	5f                   	pop    %edi
f0103347:	5d                   	pop    %ebp
f0103348:	c3                   	ret    

f0103349 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103349:	55                   	push   %ebp
f010334a:	89 e5                	mov    %esp,%ebp
f010334c:	57                   	push   %edi
f010334d:	56                   	push   %esi
f010334e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103351:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103354:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103357:	39 c6                	cmp    %eax,%esi
f0103359:	73 35                	jae    f0103390 <memmove+0x47>
f010335b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010335e:	39 d0                	cmp    %edx,%eax
f0103360:	73 2e                	jae    f0103390 <memmove+0x47>
		s += n;
		d += n;
f0103362:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103365:	89 d6                	mov    %edx,%esi
f0103367:	09 fe                	or     %edi,%esi
f0103369:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010336f:	75 13                	jne    f0103384 <memmove+0x3b>
f0103371:	f6 c1 03             	test   $0x3,%cl
f0103374:	75 0e                	jne    f0103384 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103376:	83 ef 04             	sub    $0x4,%edi
f0103379:	8d 72 fc             	lea    -0x4(%edx),%esi
f010337c:	c1 e9 02             	shr    $0x2,%ecx
f010337f:	fd                   	std    
f0103380:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103382:	eb 09                	jmp    f010338d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103384:	83 ef 01             	sub    $0x1,%edi
f0103387:	8d 72 ff             	lea    -0x1(%edx),%esi
f010338a:	fd                   	std    
f010338b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010338d:	fc                   	cld    
f010338e:	eb 1d                	jmp    f01033ad <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103390:	89 f2                	mov    %esi,%edx
f0103392:	09 c2                	or     %eax,%edx
f0103394:	f6 c2 03             	test   $0x3,%dl
f0103397:	75 0f                	jne    f01033a8 <memmove+0x5f>
f0103399:	f6 c1 03             	test   $0x3,%cl
f010339c:	75 0a                	jne    f01033a8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010339e:	c1 e9 02             	shr    $0x2,%ecx
f01033a1:	89 c7                	mov    %eax,%edi
f01033a3:	fc                   	cld    
f01033a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01033a6:	eb 05                	jmp    f01033ad <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01033a8:	89 c7                	mov    %eax,%edi
f01033aa:	fc                   	cld    
f01033ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01033ad:	5e                   	pop    %esi
f01033ae:	5f                   	pop    %edi
f01033af:	5d                   	pop    %ebp
f01033b0:	c3                   	ret    

f01033b1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01033b1:	55                   	push   %ebp
f01033b2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01033b4:	ff 75 10             	pushl  0x10(%ebp)
f01033b7:	ff 75 0c             	pushl  0xc(%ebp)
f01033ba:	ff 75 08             	pushl  0x8(%ebp)
f01033bd:	e8 87 ff ff ff       	call   f0103349 <memmove>
}
f01033c2:	c9                   	leave  
f01033c3:	c3                   	ret    

f01033c4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01033c4:	55                   	push   %ebp
f01033c5:	89 e5                	mov    %esp,%ebp
f01033c7:	56                   	push   %esi
f01033c8:	53                   	push   %ebx
f01033c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01033cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033cf:	89 c6                	mov    %eax,%esi
f01033d1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01033d4:	eb 1a                	jmp    f01033f0 <memcmp+0x2c>
		if (*s1 != *s2)
f01033d6:	0f b6 08             	movzbl (%eax),%ecx
f01033d9:	0f b6 1a             	movzbl (%edx),%ebx
f01033dc:	38 d9                	cmp    %bl,%cl
f01033de:	74 0a                	je     f01033ea <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01033e0:	0f b6 c1             	movzbl %cl,%eax
f01033e3:	0f b6 db             	movzbl %bl,%ebx
f01033e6:	29 d8                	sub    %ebx,%eax
f01033e8:	eb 0f                	jmp    f01033f9 <memcmp+0x35>
		s1++, s2++;
f01033ea:	83 c0 01             	add    $0x1,%eax
f01033ed:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01033f0:	39 f0                	cmp    %esi,%eax
f01033f2:	75 e2                	jne    f01033d6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01033f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033f9:	5b                   	pop    %ebx
f01033fa:	5e                   	pop    %esi
f01033fb:	5d                   	pop    %ebp
f01033fc:	c3                   	ret    

f01033fd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01033fd:	55                   	push   %ebp
f01033fe:	89 e5                	mov    %esp,%ebp
f0103400:	53                   	push   %ebx
f0103401:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103404:	89 c1                	mov    %eax,%ecx
f0103406:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103409:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010340d:	eb 0a                	jmp    f0103419 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010340f:	0f b6 10             	movzbl (%eax),%edx
f0103412:	39 da                	cmp    %ebx,%edx
f0103414:	74 07                	je     f010341d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103416:	83 c0 01             	add    $0x1,%eax
f0103419:	39 c8                	cmp    %ecx,%eax
f010341b:	72 f2                	jb     f010340f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010341d:	5b                   	pop    %ebx
f010341e:	5d                   	pop    %ebp
f010341f:	c3                   	ret    

f0103420 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103420:	55                   	push   %ebp
f0103421:	89 e5                	mov    %esp,%ebp
f0103423:	57                   	push   %edi
f0103424:	56                   	push   %esi
f0103425:	53                   	push   %ebx
f0103426:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103429:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010342c:	eb 03                	jmp    f0103431 <strtol+0x11>
		s++;
f010342e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103431:	0f b6 01             	movzbl (%ecx),%eax
f0103434:	3c 20                	cmp    $0x20,%al
f0103436:	74 f6                	je     f010342e <strtol+0xe>
f0103438:	3c 09                	cmp    $0x9,%al
f010343a:	74 f2                	je     f010342e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010343c:	3c 2b                	cmp    $0x2b,%al
f010343e:	75 0a                	jne    f010344a <strtol+0x2a>
		s++;
f0103440:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103443:	bf 00 00 00 00       	mov    $0x0,%edi
f0103448:	eb 11                	jmp    f010345b <strtol+0x3b>
f010344a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010344f:	3c 2d                	cmp    $0x2d,%al
f0103451:	75 08                	jne    f010345b <strtol+0x3b>
		s++, neg = 1;
f0103453:	83 c1 01             	add    $0x1,%ecx
f0103456:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010345b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103461:	75 15                	jne    f0103478 <strtol+0x58>
f0103463:	80 39 30             	cmpb   $0x30,(%ecx)
f0103466:	75 10                	jne    f0103478 <strtol+0x58>
f0103468:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010346c:	75 7c                	jne    f01034ea <strtol+0xca>
		s += 2, base = 16;
f010346e:	83 c1 02             	add    $0x2,%ecx
f0103471:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103476:	eb 16                	jmp    f010348e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103478:	85 db                	test   %ebx,%ebx
f010347a:	75 12                	jne    f010348e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010347c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103481:	80 39 30             	cmpb   $0x30,(%ecx)
f0103484:	75 08                	jne    f010348e <strtol+0x6e>
		s++, base = 8;
f0103486:	83 c1 01             	add    $0x1,%ecx
f0103489:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010348e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103493:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103496:	0f b6 11             	movzbl (%ecx),%edx
f0103499:	8d 72 d0             	lea    -0x30(%edx),%esi
f010349c:	89 f3                	mov    %esi,%ebx
f010349e:	80 fb 09             	cmp    $0x9,%bl
f01034a1:	77 08                	ja     f01034ab <strtol+0x8b>
			dig = *s - '0';
f01034a3:	0f be d2             	movsbl %dl,%edx
f01034a6:	83 ea 30             	sub    $0x30,%edx
f01034a9:	eb 22                	jmp    f01034cd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01034ab:	8d 72 9f             	lea    -0x61(%edx),%esi
f01034ae:	89 f3                	mov    %esi,%ebx
f01034b0:	80 fb 19             	cmp    $0x19,%bl
f01034b3:	77 08                	ja     f01034bd <strtol+0x9d>
			dig = *s - 'a' + 10;
f01034b5:	0f be d2             	movsbl %dl,%edx
f01034b8:	83 ea 57             	sub    $0x57,%edx
f01034bb:	eb 10                	jmp    f01034cd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01034bd:	8d 72 bf             	lea    -0x41(%edx),%esi
f01034c0:	89 f3                	mov    %esi,%ebx
f01034c2:	80 fb 19             	cmp    $0x19,%bl
f01034c5:	77 16                	ja     f01034dd <strtol+0xbd>
			dig = *s - 'A' + 10;
f01034c7:	0f be d2             	movsbl %dl,%edx
f01034ca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01034cd:	3b 55 10             	cmp    0x10(%ebp),%edx
f01034d0:	7d 0b                	jge    f01034dd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01034d2:	83 c1 01             	add    $0x1,%ecx
f01034d5:	0f af 45 10          	imul   0x10(%ebp),%eax
f01034d9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01034db:	eb b9                	jmp    f0103496 <strtol+0x76>

	if (endptr)
f01034dd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01034e1:	74 0d                	je     f01034f0 <strtol+0xd0>
		*endptr = (char *) s;
f01034e3:	8b 75 0c             	mov    0xc(%ebp),%esi
f01034e6:	89 0e                	mov    %ecx,(%esi)
f01034e8:	eb 06                	jmp    f01034f0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01034ea:	85 db                	test   %ebx,%ebx
f01034ec:	74 98                	je     f0103486 <strtol+0x66>
f01034ee:	eb 9e                	jmp    f010348e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01034f0:	89 c2                	mov    %eax,%edx
f01034f2:	f7 da                	neg    %edx
f01034f4:	85 ff                	test   %edi,%edi
f01034f6:	0f 45 c2             	cmovne %edx,%eax
}
f01034f9:	5b                   	pop    %ebx
f01034fa:	5e                   	pop    %esi
f01034fb:	5f                   	pop    %edi
f01034fc:	5d                   	pop    %ebp
f01034fd:	c3                   	ret    
f01034fe:	66 90                	xchg   %ax,%ax

f0103500 <__udivdi3>:
f0103500:	55                   	push   %ebp
f0103501:	57                   	push   %edi
f0103502:	56                   	push   %esi
f0103503:	53                   	push   %ebx
f0103504:	83 ec 1c             	sub    $0x1c,%esp
f0103507:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010350b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010350f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103513:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103517:	85 f6                	test   %esi,%esi
f0103519:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010351d:	89 ca                	mov    %ecx,%edx
f010351f:	89 f8                	mov    %edi,%eax
f0103521:	75 3d                	jne    f0103560 <__udivdi3+0x60>
f0103523:	39 cf                	cmp    %ecx,%edi
f0103525:	0f 87 c5 00 00 00    	ja     f01035f0 <__udivdi3+0xf0>
f010352b:	85 ff                	test   %edi,%edi
f010352d:	89 fd                	mov    %edi,%ebp
f010352f:	75 0b                	jne    f010353c <__udivdi3+0x3c>
f0103531:	b8 01 00 00 00       	mov    $0x1,%eax
f0103536:	31 d2                	xor    %edx,%edx
f0103538:	f7 f7                	div    %edi
f010353a:	89 c5                	mov    %eax,%ebp
f010353c:	89 c8                	mov    %ecx,%eax
f010353e:	31 d2                	xor    %edx,%edx
f0103540:	f7 f5                	div    %ebp
f0103542:	89 c1                	mov    %eax,%ecx
f0103544:	89 d8                	mov    %ebx,%eax
f0103546:	89 cf                	mov    %ecx,%edi
f0103548:	f7 f5                	div    %ebp
f010354a:	89 c3                	mov    %eax,%ebx
f010354c:	89 d8                	mov    %ebx,%eax
f010354e:	89 fa                	mov    %edi,%edx
f0103550:	83 c4 1c             	add    $0x1c,%esp
f0103553:	5b                   	pop    %ebx
f0103554:	5e                   	pop    %esi
f0103555:	5f                   	pop    %edi
f0103556:	5d                   	pop    %ebp
f0103557:	c3                   	ret    
f0103558:	90                   	nop
f0103559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103560:	39 ce                	cmp    %ecx,%esi
f0103562:	77 74                	ja     f01035d8 <__udivdi3+0xd8>
f0103564:	0f bd fe             	bsr    %esi,%edi
f0103567:	83 f7 1f             	xor    $0x1f,%edi
f010356a:	0f 84 98 00 00 00    	je     f0103608 <__udivdi3+0x108>
f0103570:	bb 20 00 00 00       	mov    $0x20,%ebx
f0103575:	89 f9                	mov    %edi,%ecx
f0103577:	89 c5                	mov    %eax,%ebp
f0103579:	29 fb                	sub    %edi,%ebx
f010357b:	d3 e6                	shl    %cl,%esi
f010357d:	89 d9                	mov    %ebx,%ecx
f010357f:	d3 ed                	shr    %cl,%ebp
f0103581:	89 f9                	mov    %edi,%ecx
f0103583:	d3 e0                	shl    %cl,%eax
f0103585:	09 ee                	or     %ebp,%esi
f0103587:	89 d9                	mov    %ebx,%ecx
f0103589:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010358d:	89 d5                	mov    %edx,%ebp
f010358f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0103593:	d3 ed                	shr    %cl,%ebp
f0103595:	89 f9                	mov    %edi,%ecx
f0103597:	d3 e2                	shl    %cl,%edx
f0103599:	89 d9                	mov    %ebx,%ecx
f010359b:	d3 e8                	shr    %cl,%eax
f010359d:	09 c2                	or     %eax,%edx
f010359f:	89 d0                	mov    %edx,%eax
f01035a1:	89 ea                	mov    %ebp,%edx
f01035a3:	f7 f6                	div    %esi
f01035a5:	89 d5                	mov    %edx,%ebp
f01035a7:	89 c3                	mov    %eax,%ebx
f01035a9:	f7 64 24 0c          	mull   0xc(%esp)
f01035ad:	39 d5                	cmp    %edx,%ebp
f01035af:	72 10                	jb     f01035c1 <__udivdi3+0xc1>
f01035b1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01035b5:	89 f9                	mov    %edi,%ecx
f01035b7:	d3 e6                	shl    %cl,%esi
f01035b9:	39 c6                	cmp    %eax,%esi
f01035bb:	73 07                	jae    f01035c4 <__udivdi3+0xc4>
f01035bd:	39 d5                	cmp    %edx,%ebp
f01035bf:	75 03                	jne    f01035c4 <__udivdi3+0xc4>
f01035c1:	83 eb 01             	sub    $0x1,%ebx
f01035c4:	31 ff                	xor    %edi,%edi
f01035c6:	89 d8                	mov    %ebx,%eax
f01035c8:	89 fa                	mov    %edi,%edx
f01035ca:	83 c4 1c             	add    $0x1c,%esp
f01035cd:	5b                   	pop    %ebx
f01035ce:	5e                   	pop    %esi
f01035cf:	5f                   	pop    %edi
f01035d0:	5d                   	pop    %ebp
f01035d1:	c3                   	ret    
f01035d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01035d8:	31 ff                	xor    %edi,%edi
f01035da:	31 db                	xor    %ebx,%ebx
f01035dc:	89 d8                	mov    %ebx,%eax
f01035de:	89 fa                	mov    %edi,%edx
f01035e0:	83 c4 1c             	add    $0x1c,%esp
f01035e3:	5b                   	pop    %ebx
f01035e4:	5e                   	pop    %esi
f01035e5:	5f                   	pop    %edi
f01035e6:	5d                   	pop    %ebp
f01035e7:	c3                   	ret    
f01035e8:	90                   	nop
f01035e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01035f0:	89 d8                	mov    %ebx,%eax
f01035f2:	f7 f7                	div    %edi
f01035f4:	31 ff                	xor    %edi,%edi
f01035f6:	89 c3                	mov    %eax,%ebx
f01035f8:	89 d8                	mov    %ebx,%eax
f01035fa:	89 fa                	mov    %edi,%edx
f01035fc:	83 c4 1c             	add    $0x1c,%esp
f01035ff:	5b                   	pop    %ebx
f0103600:	5e                   	pop    %esi
f0103601:	5f                   	pop    %edi
f0103602:	5d                   	pop    %ebp
f0103603:	c3                   	ret    
f0103604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103608:	39 ce                	cmp    %ecx,%esi
f010360a:	72 0c                	jb     f0103618 <__udivdi3+0x118>
f010360c:	31 db                	xor    %ebx,%ebx
f010360e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103612:	0f 87 34 ff ff ff    	ja     f010354c <__udivdi3+0x4c>
f0103618:	bb 01 00 00 00       	mov    $0x1,%ebx
f010361d:	e9 2a ff ff ff       	jmp    f010354c <__udivdi3+0x4c>
f0103622:	66 90                	xchg   %ax,%ax
f0103624:	66 90                	xchg   %ax,%ax
f0103626:	66 90                	xchg   %ax,%ax
f0103628:	66 90                	xchg   %ax,%ax
f010362a:	66 90                	xchg   %ax,%ax
f010362c:	66 90                	xchg   %ax,%ax
f010362e:	66 90                	xchg   %ax,%ax

f0103630 <__umoddi3>:
f0103630:	55                   	push   %ebp
f0103631:	57                   	push   %edi
f0103632:	56                   	push   %esi
f0103633:	53                   	push   %ebx
f0103634:	83 ec 1c             	sub    $0x1c,%esp
f0103637:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010363b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010363f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103643:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103647:	85 d2                	test   %edx,%edx
f0103649:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010364d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103651:	89 f3                	mov    %esi,%ebx
f0103653:	89 3c 24             	mov    %edi,(%esp)
f0103656:	89 74 24 04          	mov    %esi,0x4(%esp)
f010365a:	75 1c                	jne    f0103678 <__umoddi3+0x48>
f010365c:	39 f7                	cmp    %esi,%edi
f010365e:	76 50                	jbe    f01036b0 <__umoddi3+0x80>
f0103660:	89 c8                	mov    %ecx,%eax
f0103662:	89 f2                	mov    %esi,%edx
f0103664:	f7 f7                	div    %edi
f0103666:	89 d0                	mov    %edx,%eax
f0103668:	31 d2                	xor    %edx,%edx
f010366a:	83 c4 1c             	add    $0x1c,%esp
f010366d:	5b                   	pop    %ebx
f010366e:	5e                   	pop    %esi
f010366f:	5f                   	pop    %edi
f0103670:	5d                   	pop    %ebp
f0103671:	c3                   	ret    
f0103672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103678:	39 f2                	cmp    %esi,%edx
f010367a:	89 d0                	mov    %edx,%eax
f010367c:	77 52                	ja     f01036d0 <__umoddi3+0xa0>
f010367e:	0f bd ea             	bsr    %edx,%ebp
f0103681:	83 f5 1f             	xor    $0x1f,%ebp
f0103684:	75 5a                	jne    f01036e0 <__umoddi3+0xb0>
f0103686:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010368a:	0f 82 e0 00 00 00    	jb     f0103770 <__umoddi3+0x140>
f0103690:	39 0c 24             	cmp    %ecx,(%esp)
f0103693:	0f 86 d7 00 00 00    	jbe    f0103770 <__umoddi3+0x140>
f0103699:	8b 44 24 08          	mov    0x8(%esp),%eax
f010369d:	8b 54 24 04          	mov    0x4(%esp),%edx
f01036a1:	83 c4 1c             	add    $0x1c,%esp
f01036a4:	5b                   	pop    %ebx
f01036a5:	5e                   	pop    %esi
f01036a6:	5f                   	pop    %edi
f01036a7:	5d                   	pop    %ebp
f01036a8:	c3                   	ret    
f01036a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01036b0:	85 ff                	test   %edi,%edi
f01036b2:	89 fd                	mov    %edi,%ebp
f01036b4:	75 0b                	jne    f01036c1 <__umoddi3+0x91>
f01036b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01036bb:	31 d2                	xor    %edx,%edx
f01036bd:	f7 f7                	div    %edi
f01036bf:	89 c5                	mov    %eax,%ebp
f01036c1:	89 f0                	mov    %esi,%eax
f01036c3:	31 d2                	xor    %edx,%edx
f01036c5:	f7 f5                	div    %ebp
f01036c7:	89 c8                	mov    %ecx,%eax
f01036c9:	f7 f5                	div    %ebp
f01036cb:	89 d0                	mov    %edx,%eax
f01036cd:	eb 99                	jmp    f0103668 <__umoddi3+0x38>
f01036cf:	90                   	nop
f01036d0:	89 c8                	mov    %ecx,%eax
f01036d2:	89 f2                	mov    %esi,%edx
f01036d4:	83 c4 1c             	add    $0x1c,%esp
f01036d7:	5b                   	pop    %ebx
f01036d8:	5e                   	pop    %esi
f01036d9:	5f                   	pop    %edi
f01036da:	5d                   	pop    %ebp
f01036db:	c3                   	ret    
f01036dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01036e0:	8b 34 24             	mov    (%esp),%esi
f01036e3:	bf 20 00 00 00       	mov    $0x20,%edi
f01036e8:	89 e9                	mov    %ebp,%ecx
f01036ea:	29 ef                	sub    %ebp,%edi
f01036ec:	d3 e0                	shl    %cl,%eax
f01036ee:	89 f9                	mov    %edi,%ecx
f01036f0:	89 f2                	mov    %esi,%edx
f01036f2:	d3 ea                	shr    %cl,%edx
f01036f4:	89 e9                	mov    %ebp,%ecx
f01036f6:	09 c2                	or     %eax,%edx
f01036f8:	89 d8                	mov    %ebx,%eax
f01036fa:	89 14 24             	mov    %edx,(%esp)
f01036fd:	89 f2                	mov    %esi,%edx
f01036ff:	d3 e2                	shl    %cl,%edx
f0103701:	89 f9                	mov    %edi,%ecx
f0103703:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103707:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010370b:	d3 e8                	shr    %cl,%eax
f010370d:	89 e9                	mov    %ebp,%ecx
f010370f:	89 c6                	mov    %eax,%esi
f0103711:	d3 e3                	shl    %cl,%ebx
f0103713:	89 f9                	mov    %edi,%ecx
f0103715:	89 d0                	mov    %edx,%eax
f0103717:	d3 e8                	shr    %cl,%eax
f0103719:	89 e9                	mov    %ebp,%ecx
f010371b:	09 d8                	or     %ebx,%eax
f010371d:	89 d3                	mov    %edx,%ebx
f010371f:	89 f2                	mov    %esi,%edx
f0103721:	f7 34 24             	divl   (%esp)
f0103724:	89 d6                	mov    %edx,%esi
f0103726:	d3 e3                	shl    %cl,%ebx
f0103728:	f7 64 24 04          	mull   0x4(%esp)
f010372c:	39 d6                	cmp    %edx,%esi
f010372e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103732:	89 d1                	mov    %edx,%ecx
f0103734:	89 c3                	mov    %eax,%ebx
f0103736:	72 08                	jb     f0103740 <__umoddi3+0x110>
f0103738:	75 11                	jne    f010374b <__umoddi3+0x11b>
f010373a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010373e:	73 0b                	jae    f010374b <__umoddi3+0x11b>
f0103740:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103744:	1b 14 24             	sbb    (%esp),%edx
f0103747:	89 d1                	mov    %edx,%ecx
f0103749:	89 c3                	mov    %eax,%ebx
f010374b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010374f:	29 da                	sub    %ebx,%edx
f0103751:	19 ce                	sbb    %ecx,%esi
f0103753:	89 f9                	mov    %edi,%ecx
f0103755:	89 f0                	mov    %esi,%eax
f0103757:	d3 e0                	shl    %cl,%eax
f0103759:	89 e9                	mov    %ebp,%ecx
f010375b:	d3 ea                	shr    %cl,%edx
f010375d:	89 e9                	mov    %ebp,%ecx
f010375f:	d3 ee                	shr    %cl,%esi
f0103761:	09 d0                	or     %edx,%eax
f0103763:	89 f2                	mov    %esi,%edx
f0103765:	83 c4 1c             	add    $0x1c,%esp
f0103768:	5b                   	pop    %ebx
f0103769:	5e                   	pop    %esi
f010376a:	5f                   	pop    %edi
f010376b:	5d                   	pop    %ebp
f010376c:	c3                   	ret    
f010376d:	8d 76 00             	lea    0x0(%esi),%esi
f0103770:	29 f9                	sub    %edi,%ecx
f0103772:	19 d6                	sbb    %edx,%esi
f0103774:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103778:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010377c:	e9 18 ff ff ff       	jmp    f0103699 <__umoddi3+0x69>
