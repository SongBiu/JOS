
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
f0100015:	b8 00 f0 18 00       	mov    $0x18f000,%eax
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
f0100034:	bc 00 c0 11 f0       	mov    $0xf011c000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 1b 01 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f010004c:	81 c3 ac e1 08 00    	add    $0x8e1ac,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 20 10 19 f0    	mov    $0xf0191020,%eax
f0100058:	c7 c2 20 01 19 f0    	mov    $0xf0190120,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 bf 56 00 00       	call   f0105728 <memset>
	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4e 05 00 00       	call   f01005bc <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 88 79 f7 ff    	lea    -0x88678(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 bd 41 00 00       	call   f010423f <cprintf>
	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 22 1a 00 00       	call   f0101aa9 <mem_init>
	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 a2 3a 00 00       	call   f0103b2e <env_init>
	trap_init();
f010008c:	e8 61 42 00 00       	call   f01042f2 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f010009c:	e8 ab 3c 00 00       	call   f0103d4c <env_create>
#endif // TEST*
	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 68 03 19 f0    	mov    $0xf0190368,%eax
f01000aa:	ff 30                	pushl  (%eax)
f01000ac:	e8 8e 40 00 00       	call   f010413f <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	57                   	push   %edi
f01000b5:	56                   	push   %esi
f01000b6:	53                   	push   %ebx
f01000b7:	83 ec 0c             	sub    $0xc,%esp
f01000ba:	e8 a8 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f01000bf:	81 c3 39 e1 08 00    	add    $0x8e139,%ebx
f01000c5:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000c8:	c7 c0 24 10 19 f0    	mov    $0xf0191024,%eax
f01000ce:	83 38 00             	cmpl   $0x0,(%eax)
f01000d1:	74 0f                	je     f01000e2 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 3f 0f 00 00       	call   f010101c <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x22>
	panicstr = fmt;
f01000e2:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f01000e4:	fa                   	cli    
f01000e5:	fc                   	cld    
	va_start(ap, fmt);
f01000e6:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000e9:	83 ec 04             	sub    $0x4,%esp
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	8d 83 a3 79 f7 ff    	lea    -0x8865d(%ebx),%eax
f01000f8:	50                   	push   %eax
f01000f9:	e8 41 41 00 00       	call   f010423f <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	56                   	push   %esi
f0100102:	57                   	push   %edi
f0100103:	e8 00 41 00 00       	call   f0104208 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 2e 8c f7 ff    	lea    -0x873d2(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 29 41 00 00       	call   f010423f <cprintf>
f0100116:	83 c4 10             	add    $0x10,%esp
f0100119:	eb b8                	jmp    f01000d3 <_panic+0x22>

f010011b <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010011b:	55                   	push   %ebp
f010011c:	89 e5                	mov    %esp,%ebp
f010011e:	56                   	push   %esi
f010011f:	53                   	push   %ebx
f0100120:	e8 42 00 00 00       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100125:	81 c3 d3 e0 08 00    	add    $0x8e0d3,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	pushl  0xc(%ebp)
f0100134:	ff 75 08             	pushl  0x8(%ebp)
f0100137:	8d 83 bb 79 f7 ff    	lea    -0x88645(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 fc 40 00 00       	call   f010423f <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	pushl  0x10(%ebp)
f010014a:	e8 b9 40 00 00       	call   f0104208 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 2e 8c f7 ff    	lea    -0x873d2(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 e2 40 00 00       	call   f010423f <cprintf>
	va_end(ap);
}
f010015d:	83 c4 10             	add    $0x10,%esp
f0100160:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100163:	5b                   	pop    %ebx
f0100164:	5e                   	pop    %esi
f0100165:	5d                   	pop    %ebp
f0100166:	c3                   	ret    

f0100167 <__x86.get_pc_thunk.bx>:
f0100167:	8b 1c 24             	mov    (%esp),%ebx
f010016a:	c3                   	ret    

f010016b <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010016b:	55                   	push   %ebp
f010016c:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010016e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100173:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100174:	a8 01                	test   $0x1,%al
f0100176:	74 0b                	je     f0100183 <serial_proc_data+0x18>
f0100178:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010017d:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010017e:	0f b6 c0             	movzbl %al,%eax
}
f0100181:	5d                   	pop    %ebp
f0100182:	c3                   	ret    
		return -1;
f0100183:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100188:	eb f7                	jmp    f0100181 <serial_proc_data+0x16>

f010018a <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010018a:	55                   	push   %ebp
f010018b:	89 e5                	mov    %esp,%ebp
f010018d:	56                   	push   %esi
f010018e:	53                   	push   %ebx
f010018f:	e8 d3 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100194:	81 c3 64 e0 08 00    	add    $0x8e064,%ebx
f010019a:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f010019c:	ff d6                	call   *%esi
f010019e:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001a1:	74 2e                	je     f01001d1 <cons_intr+0x47>
		if (c == 0)
f01001a3:	85 c0                	test   %eax,%eax
f01001a5:	74 f5                	je     f010019c <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a7:	8b 8b 4c 21 00 00    	mov    0x214c(%ebx),%ecx
f01001ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b0:	89 93 4c 21 00 00    	mov    %edx,0x214c(%ebx)
f01001b6:	88 84 0b 48 1f 00 00 	mov    %al,0x1f48(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001bd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c3:	75 d7                	jne    f010019c <cons_intr+0x12>
			cons.wpos = 0;
f01001c5:	c7 83 4c 21 00 00 00 	movl   $0x0,0x214c(%ebx)
f01001cc:	00 00 00 
f01001cf:	eb cb                	jmp    f010019c <cons_intr+0x12>
	}
}
f01001d1:	5b                   	pop    %ebx
f01001d2:	5e                   	pop    %esi
f01001d3:	5d                   	pop    %ebp
f01001d4:	c3                   	ret    

f01001d5 <kbd_proc_data>:
{
f01001d5:	55                   	push   %ebp
f01001d6:	89 e5                	mov    %esp,%ebp
f01001d8:	56                   	push   %esi
f01001d9:	53                   	push   %ebx
f01001da:	e8 88 ff ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01001df:	81 c3 19 e0 08 00    	add    $0x8e019,%ebx
f01001e5:	ba 64 00 00 00       	mov    $0x64,%edx
f01001ea:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001eb:	a8 01                	test   $0x1,%al
f01001ed:	0f 84 06 01 00 00    	je     f01002f9 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f01001f3:	a8 20                	test   $0x20,%al
f01001f5:	0f 85 05 01 00 00    	jne    f0100300 <kbd_proc_data+0x12b>
f01001fb:	ba 60 00 00 00       	mov    $0x60,%edx
f0100200:	ec                   	in     (%dx),%al
f0100201:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100203:	3c e0                	cmp    $0xe0,%al
f0100205:	0f 84 93 00 00 00    	je     f010029e <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f010020b:	84 c0                	test   %al,%al
f010020d:	0f 88 a0 00 00 00    	js     f01002b3 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100213:	8b 8b 28 1f 00 00    	mov    0x1f28(%ebx),%ecx
f0100219:	f6 c1 40             	test   $0x40,%cl
f010021c:	74 0e                	je     f010022c <kbd_proc_data+0x57>
		data |= 0x80;
f010021e:	83 c8 80             	or     $0xffffff80,%eax
f0100221:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100223:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100226:	89 8b 28 1f 00 00    	mov    %ecx,0x1f28(%ebx)
	shift |= shiftcode[data];
f010022c:	0f b6 d2             	movzbl %dl,%edx
f010022f:	0f b6 84 13 08 7b f7 	movzbl -0x884f8(%ebx,%edx,1),%eax
f0100236:	ff 
f0100237:	0b 83 28 1f 00 00    	or     0x1f28(%ebx),%eax
	shift ^= togglecode[data];
f010023d:	0f b6 8c 13 08 7a f7 	movzbl -0x885f8(%ebx,%edx,1),%ecx
f0100244:	ff 
f0100245:	31 c8                	xor    %ecx,%eax
f0100247:	89 83 28 1f 00 00    	mov    %eax,0x1f28(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010024d:	89 c1                	mov    %eax,%ecx
f010024f:	83 e1 03             	and    $0x3,%ecx
f0100252:	8b 8c 8b 28 1e 00 00 	mov    0x1e28(%ebx,%ecx,4),%ecx
f0100259:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010025d:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100260:	a8 08                	test   $0x8,%al
f0100262:	74 0d                	je     f0100271 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f0100264:	89 f2                	mov    %esi,%edx
f0100266:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100269:	83 f9 19             	cmp    $0x19,%ecx
f010026c:	77 7a                	ja     f01002e8 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f010026e:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100271:	f7 d0                	not    %eax
f0100273:	a8 06                	test   $0x6,%al
f0100275:	75 33                	jne    f01002aa <kbd_proc_data+0xd5>
f0100277:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010027d:	75 2b                	jne    f01002aa <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f010027f:	83 ec 0c             	sub    $0xc,%esp
f0100282:	8d 83 d5 79 f7 ff    	lea    -0x8862b(%ebx),%eax
f0100288:	50                   	push   %eax
f0100289:	e8 b1 3f 00 00       	call   f010423f <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010028e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100293:	ba 92 00 00 00       	mov    $0x92,%edx
f0100298:	ee                   	out    %al,(%dx)
f0100299:	83 c4 10             	add    $0x10,%esp
f010029c:	eb 0c                	jmp    f01002aa <kbd_proc_data+0xd5>
		shift |= E0ESC;
f010029e:	83 8b 28 1f 00 00 40 	orl    $0x40,0x1f28(%ebx)
		return 0;
f01002a5:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002aa:	89 f0                	mov    %esi,%eax
f01002ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002af:	5b                   	pop    %ebx
f01002b0:	5e                   	pop    %esi
f01002b1:	5d                   	pop    %ebp
f01002b2:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002b3:	8b 8b 28 1f 00 00    	mov    0x1f28(%ebx),%ecx
f01002b9:	89 ce                	mov    %ecx,%esi
f01002bb:	83 e6 40             	and    $0x40,%esi
f01002be:	83 e0 7f             	and    $0x7f,%eax
f01002c1:	85 f6                	test   %esi,%esi
f01002c3:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002c6:	0f b6 d2             	movzbl %dl,%edx
f01002c9:	0f b6 84 13 08 7b f7 	movzbl -0x884f8(%ebx,%edx,1),%eax
f01002d0:	ff 
f01002d1:	83 c8 40             	or     $0x40,%eax
f01002d4:	0f b6 c0             	movzbl %al,%eax
f01002d7:	f7 d0                	not    %eax
f01002d9:	21 c8                	and    %ecx,%eax
f01002db:	89 83 28 1f 00 00    	mov    %eax,0x1f28(%ebx)
		return 0;
f01002e1:	be 00 00 00 00       	mov    $0x0,%esi
f01002e6:	eb c2                	jmp    f01002aa <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f01002e8:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002eb:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002ee:	83 fa 1a             	cmp    $0x1a,%edx
f01002f1:	0f 42 f1             	cmovb  %ecx,%esi
f01002f4:	e9 78 ff ff ff       	jmp    f0100271 <kbd_proc_data+0x9c>
		return -1;
f01002f9:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002fe:	eb aa                	jmp    f01002aa <kbd_proc_data+0xd5>
		return -1;
f0100300:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100305:	eb a3                	jmp    f01002aa <kbd_proc_data+0xd5>

f0100307 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100307:	55                   	push   %ebp
f0100308:	89 e5                	mov    %esp,%ebp
f010030a:	57                   	push   %edi
f010030b:	56                   	push   %esi
f010030c:	53                   	push   %ebx
f010030d:	83 ec 1c             	sub    $0x1c,%esp
f0100310:	e8 52 fe ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100315:	81 c3 e3 de 08 00    	add    $0x8dee3,%ebx
f010031b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f010031e:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100323:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100328:	b9 84 00 00 00       	mov    $0x84,%ecx
f010032d:	eb 09                	jmp    f0100338 <cons_putc+0x31>
f010032f:	89 ca                	mov    %ecx,%edx
f0100331:	ec                   	in     (%dx),%al
f0100332:	ec                   	in     (%dx),%al
f0100333:	ec                   	in     (%dx),%al
f0100334:	ec                   	in     (%dx),%al
	     i++)
f0100335:	83 c6 01             	add    $0x1,%esi
f0100338:	89 fa                	mov    %edi,%edx
f010033a:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010033b:	a8 20                	test   $0x20,%al
f010033d:	75 08                	jne    f0100347 <cons_putc+0x40>
f010033f:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100345:	7e e8                	jle    f010032f <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f0100347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010034a:	89 f8                	mov    %edi,%eax
f010034c:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100354:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100355:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010035a:	bf 79 03 00 00       	mov    $0x379,%edi
f010035f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100364:	eb 09                	jmp    f010036f <cons_putc+0x68>
f0100366:	89 ca                	mov    %ecx,%edx
f0100368:	ec                   	in     (%dx),%al
f0100369:	ec                   	in     (%dx),%al
f010036a:	ec                   	in     (%dx),%al
f010036b:	ec                   	in     (%dx),%al
f010036c:	83 c6 01             	add    $0x1,%esi
f010036f:	89 fa                	mov    %edi,%edx
f0100371:	ec                   	in     (%dx),%al
f0100372:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100378:	7f 04                	jg     f010037e <cons_putc+0x77>
f010037a:	84 c0                	test   %al,%al
f010037c:	79 e8                	jns    f0100366 <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010037e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100383:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f0100387:	ee                   	out    %al,(%dx)
f0100388:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010038d:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100392:	ee                   	out    %al,(%dx)
f0100393:	b8 08 00 00 00       	mov    $0x8,%eax
f0100398:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039c:	89 fa                	mov    %edi,%edx
f010039e:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003a4:	89 f8                	mov    %edi,%eax
f01003a6:	80 cc 07             	or     $0x7,%ah
f01003a9:	85 d2                	test   %edx,%edx
f01003ab:	0f 45 c7             	cmovne %edi,%eax
f01003ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f01003b1:	0f b6 c0             	movzbl %al,%eax
f01003b4:	83 f8 09             	cmp    $0x9,%eax
f01003b7:	0f 84 b9 00 00 00    	je     f0100476 <cons_putc+0x16f>
f01003bd:	83 f8 09             	cmp    $0x9,%eax
f01003c0:	7e 74                	jle    f0100436 <cons_putc+0x12f>
f01003c2:	83 f8 0a             	cmp    $0xa,%eax
f01003c5:	0f 84 9e 00 00 00    	je     f0100469 <cons_putc+0x162>
f01003cb:	83 f8 0d             	cmp    $0xd,%eax
f01003ce:	0f 85 d9 00 00 00    	jne    f01004ad <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f01003d4:	0f b7 83 50 21 00 00 	movzwl 0x2150(%ebx),%eax
f01003db:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e1:	c1 e8 16             	shr    $0x16,%eax
f01003e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e7:	c1 e0 04             	shl    $0x4,%eax
f01003ea:	66 89 83 50 21 00 00 	mov    %ax,0x2150(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01003f1:	66 81 bb 50 21 00 00 	cmpw   $0x7cf,0x2150(%ebx)
f01003f8:	cf 07 
f01003fa:	0f 87 d4 00 00 00    	ja     f01004d4 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100400:	8b 8b 58 21 00 00    	mov    0x2158(%ebx),%ecx
f0100406:	b8 0e 00 00 00       	mov    $0xe,%eax
f010040b:	89 ca                	mov    %ecx,%edx
f010040d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010040e:	0f b7 9b 50 21 00 00 	movzwl 0x2150(%ebx),%ebx
f0100415:	8d 71 01             	lea    0x1(%ecx),%esi
f0100418:	89 d8                	mov    %ebx,%eax
f010041a:	66 c1 e8 08          	shr    $0x8,%ax
f010041e:	89 f2                	mov    %esi,%edx
f0100420:	ee                   	out    %al,(%dx)
f0100421:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100426:	89 ca                	mov    %ecx,%edx
f0100428:	ee                   	out    %al,(%dx)
f0100429:	89 d8                	mov    %ebx,%eax
f010042b:	89 f2                	mov    %esi,%edx
f010042d:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010042e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100431:	5b                   	pop    %ebx
f0100432:	5e                   	pop    %esi
f0100433:	5f                   	pop    %edi
f0100434:	5d                   	pop    %ebp
f0100435:	c3                   	ret    
	switch (c & 0xff) {
f0100436:	83 f8 08             	cmp    $0x8,%eax
f0100439:	75 72                	jne    f01004ad <cons_putc+0x1a6>
		if (crt_pos > 0) {
f010043b:	0f b7 83 50 21 00 00 	movzwl 0x2150(%ebx),%eax
f0100442:	66 85 c0             	test   %ax,%ax
f0100445:	74 b9                	je     f0100400 <cons_putc+0xf9>
			crt_pos--;
f0100447:	83 e8 01             	sub    $0x1,%eax
f010044a:	66 89 83 50 21 00 00 	mov    %ax,0x2150(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100451:	0f b7 c0             	movzwl %ax,%eax
f0100454:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100458:	b2 00                	mov    $0x0,%dl
f010045a:	83 ca 20             	or     $0x20,%edx
f010045d:	8b 8b 54 21 00 00    	mov    0x2154(%ebx),%ecx
f0100463:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100467:	eb 88                	jmp    f01003f1 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f0100469:	66 83 83 50 21 00 00 	addw   $0x50,0x2150(%ebx)
f0100470:	50 
f0100471:	e9 5e ff ff ff       	jmp    f01003d4 <cons_putc+0xcd>
		cons_putc(' ');
f0100476:	b8 20 00 00 00       	mov    $0x20,%eax
f010047b:	e8 87 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f0100480:	b8 20 00 00 00       	mov    $0x20,%eax
f0100485:	e8 7d fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f010048a:	b8 20 00 00 00       	mov    $0x20,%eax
f010048f:	e8 73 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f0100494:	b8 20 00 00 00       	mov    $0x20,%eax
f0100499:	e8 69 fe ff ff       	call   f0100307 <cons_putc>
		cons_putc(' ');
f010049e:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a3:	e8 5f fe ff ff       	call   f0100307 <cons_putc>
f01004a8:	e9 44 ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004ad:	0f b7 83 50 21 00 00 	movzwl 0x2150(%ebx),%eax
f01004b4:	8d 50 01             	lea    0x1(%eax),%edx
f01004b7:	66 89 93 50 21 00 00 	mov    %dx,0x2150(%ebx)
f01004be:	0f b7 c0             	movzwl %ax,%eax
f01004c1:	8b 93 54 21 00 00    	mov    0x2154(%ebx),%edx
f01004c7:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004cf:	e9 1d ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004d4:	8b 83 54 21 00 00    	mov    0x2154(%ebx),%eax
f01004da:	83 ec 04             	sub    $0x4,%esp
f01004dd:	68 00 0f 00 00       	push   $0xf00
f01004e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004e8:	52                   	push   %edx
f01004e9:	50                   	push   %eax
f01004ea:	e8 86 52 00 00       	call   f0105775 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004ef:	8b 93 54 21 00 00    	mov    0x2154(%ebx),%edx
f01004f5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004fb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100501:	83 c4 10             	add    $0x10,%esp
f0100504:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100509:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010050c:	39 d0                	cmp    %edx,%eax
f010050e:	75 f4                	jne    f0100504 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100510:	66 83 ab 50 21 00 00 	subw   $0x50,0x2150(%ebx)
f0100517:	50 
f0100518:	e9 e3 fe ff ff       	jmp    f0100400 <cons_putc+0xf9>

f010051d <serial_intr>:
{
f010051d:	e8 e7 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100522:	05 d6 dc 08 00       	add    $0x8dcd6,%eax
	if (serial_exists)
f0100527:	80 b8 5c 21 00 00 00 	cmpb   $0x0,0x215c(%eax)
f010052e:	75 02                	jne    f0100532 <serial_intr+0x15>
f0100530:	f3 c3                	repz ret 
{
f0100532:	55                   	push   %ebp
f0100533:	89 e5                	mov    %esp,%ebp
f0100535:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100538:	8d 80 73 1f f7 ff    	lea    -0x8e08d(%eax),%eax
f010053e:	e8 47 fc ff ff       	call   f010018a <cons_intr>
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <kbd_intr>:
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	83 ec 08             	sub    $0x8,%esp
f010054b:	e8 b9 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100550:	05 a8 dc 08 00       	add    $0x8dca8,%eax
	cons_intr(kbd_proc_data);
f0100555:	8d 80 dd 1f f7 ff    	lea    -0x8e023(%eax),%eax
f010055b:	e8 2a fc ff ff       	call   f010018a <cons_intr>
}
f0100560:	c9                   	leave  
f0100561:	c3                   	ret    

f0100562 <cons_getc>:
{
f0100562:	55                   	push   %ebp
f0100563:	89 e5                	mov    %esp,%ebp
f0100565:	53                   	push   %ebx
f0100566:	83 ec 04             	sub    $0x4,%esp
f0100569:	e8 f9 fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010056e:	81 c3 8a dc 08 00    	add    $0x8dc8a,%ebx
	serial_intr();
f0100574:	e8 a4 ff ff ff       	call   f010051d <serial_intr>
	kbd_intr();
f0100579:	e8 c7 ff ff ff       	call   f0100545 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010057e:	8b 93 48 21 00 00    	mov    0x2148(%ebx),%edx
	return 0;
f0100584:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100589:	3b 93 4c 21 00 00    	cmp    0x214c(%ebx),%edx
f010058f:	74 19                	je     f01005aa <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f0100591:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100594:	89 8b 48 21 00 00    	mov    %ecx,0x2148(%ebx)
f010059a:	0f b6 84 13 48 1f 00 	movzbl 0x1f48(%ebx,%edx,1),%eax
f01005a1:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005a2:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005a8:	74 06                	je     f01005b0 <cons_getc+0x4e>
}
f01005aa:	83 c4 04             	add    $0x4,%esp
f01005ad:	5b                   	pop    %ebx
f01005ae:	5d                   	pop    %ebp
f01005af:	c3                   	ret    
			cons.rpos = 0;
f01005b0:	c7 83 48 21 00 00 00 	movl   $0x0,0x2148(%ebx)
f01005b7:	00 00 00 
f01005ba:	eb ee                	jmp    f01005aa <cons_getc+0x48>

f01005bc <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005bc:	55                   	push   %ebp
f01005bd:	89 e5                	mov    %esp,%ebp
f01005bf:	57                   	push   %edi
f01005c0:	56                   	push   %esi
f01005c1:	53                   	push   %ebx
f01005c2:	83 ec 1c             	sub    $0x1c,%esp
f01005c5:	e8 9d fb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01005ca:	81 c3 2e dc 08 00    	add    $0x8dc2e,%ebx
	was = *cp;
f01005d0:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005d7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005de:	5a a5 
	if (*cp != 0xA55A) {
f01005e0:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005e7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005eb:	0f 84 bc 00 00 00    	je     f01006ad <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01005f1:	c7 83 58 21 00 00 b4 	movl   $0x3b4,0x2158(%ebx)
f01005f8:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005fb:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100602:	8b bb 58 21 00 00    	mov    0x2158(%ebx),%edi
f0100608:	b8 0e 00 00 00       	mov    $0xe,%eax
f010060d:	89 fa                	mov    %edi,%edx
f010060f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100610:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100613:	89 ca                	mov    %ecx,%edx
f0100615:	ec                   	in     (%dx),%al
f0100616:	0f b6 f0             	movzbl %al,%esi
f0100619:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010061c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100621:	89 fa                	mov    %edi,%edx
f0100623:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100624:	89 ca                	mov    %ecx,%edx
f0100626:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010062a:	89 bb 54 21 00 00    	mov    %edi,0x2154(%ebx)
	pos |= inb(addr_6845 + 1);
f0100630:	0f b6 c0             	movzbl %al,%eax
f0100633:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100635:	66 89 b3 50 21 00 00 	mov    %si,0x2150(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010063c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100641:	89 c8                	mov    %ecx,%eax
f0100643:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100648:	ee                   	out    %al,(%dx)
f0100649:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010064e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100653:	89 fa                	mov    %edi,%edx
f0100655:	ee                   	out    %al,(%dx)
f0100656:	b8 0c 00 00 00       	mov    $0xc,%eax
f010065b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100660:	ee                   	out    %al,(%dx)
f0100661:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100666:	89 c8                	mov    %ecx,%eax
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ee                   	out    %al,(%dx)
f010066b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100670:	89 fa                	mov    %edi,%edx
f0100672:	ee                   	out    %al,(%dx)
f0100673:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100678:	89 c8                	mov    %ecx,%eax
f010067a:	ee                   	out    %al,(%dx)
f010067b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100680:	89 f2                	mov    %esi,%edx
f0100682:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100683:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100688:	ec                   	in     (%dx),%al
f0100689:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010068b:	3c ff                	cmp    $0xff,%al
f010068d:	0f 95 83 5c 21 00 00 	setne  0x215c(%ebx)
f0100694:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100699:	ec                   	in     (%dx),%al
f010069a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069f:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006a0:	80 f9 ff             	cmp    $0xff,%cl
f01006a3:	74 25                	je     f01006ca <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006a8:	5b                   	pop    %ebx
f01006a9:	5e                   	pop    %esi
f01006aa:	5f                   	pop    %edi
f01006ab:	5d                   	pop    %ebp
f01006ac:	c3                   	ret    
		*cp = was;
f01006ad:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b4:	c7 83 58 21 00 00 d4 	movl   $0x3d4,0x2158(%ebx)
f01006bb:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006be:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006c5:	e9 38 ff ff ff       	jmp    f0100602 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006ca:	83 ec 0c             	sub    $0xc,%esp
f01006cd:	8d 83 e1 79 f7 ff    	lea    -0x8861f(%ebx),%eax
f01006d3:	50                   	push   %eax
f01006d4:	e8 66 3b 00 00       	call   f010423f <cprintf>
f01006d9:	83 c4 10             	add    $0x10,%esp
}
f01006dc:	eb c7                	jmp    f01006a5 <cons_init+0xe9>

f01006de <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006de:	55                   	push   %ebp
f01006df:	89 e5                	mov    %esp,%ebp
f01006e1:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01006e7:	e8 1b fc ff ff       	call   f0100307 <cons_putc>
}
f01006ec:	c9                   	leave  
f01006ed:	c3                   	ret    

f01006ee <getchar>:

int
getchar(void)
{
f01006ee:	55                   	push   %ebp
f01006ef:	89 e5                	mov    %esp,%ebp
f01006f1:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006f4:	e8 69 fe ff ff       	call   f0100562 <cons_getc>
f01006f9:	85 c0                	test   %eax,%eax
f01006fb:	74 f7                	je     f01006f4 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006fd:	c9                   	leave  
f01006fe:	c3                   	ret    

f01006ff <iscons>:

int
iscons(int fdnum)
{
f01006ff:	55                   	push   %ebp
f0100700:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100702:	b8 01 00 00 00       	mov    $0x1,%eax
f0100707:	5d                   	pop    %ebp
f0100708:	c3                   	ret    

f0100709 <__x86.get_pc_thunk.ax>:
f0100709:	8b 04 24             	mov    (%esp),%eax
f010070c:	c3                   	ret    

f010070d <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010070d:	55                   	push   %ebp
f010070e:	89 e5                	mov    %esp,%ebp
f0100710:	57                   	push   %edi
f0100711:	56                   	push   %esi
f0100712:	53                   	push   %ebx
f0100713:	83 ec 1c             	sub    $0x1c,%esp
f0100716:	e8 4c fa ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010071b:	81 c3 dd da 08 00    	add    $0x8dadd,%ebx
f0100721:	8d b3 48 1e 00 00    	lea    0x1e48(%ebx),%esi
f0100727:	8d 83 9c 1e 00 00    	lea    0x1e9c(%ebx),%eax
f010072d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100730:	8d bb 08 7c f7 ff    	lea    -0x883f8(%ebx),%edi
f0100736:	83 ec 04             	sub    $0x4,%esp
f0100739:	ff 76 04             	pushl  0x4(%esi)
f010073c:	ff 36                	pushl  (%esi)
f010073e:	57                   	push   %edi
f010073f:	e8 fb 3a 00 00       	call   f010423f <cprintf>
f0100744:	83 c6 0c             	add    $0xc,%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100747:	83 c4 10             	add    $0x10,%esp
f010074a:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010074d:	75 e7                	jne    f0100736 <mon_help+0x29>
	return 0;
}
f010074f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100754:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100757:	5b                   	pop    %ebx
f0100758:	5e                   	pop    %esi
f0100759:	5f                   	pop    %edi
f010075a:	5d                   	pop    %ebp
f010075b:	c3                   	ret    

f010075c <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010075c:	55                   	push   %ebp
f010075d:	89 e5                	mov    %esp,%ebp
f010075f:	57                   	push   %edi
f0100760:	56                   	push   %esi
f0100761:	53                   	push   %ebx
f0100762:	83 ec 18             	sub    $0x18,%esp
f0100765:	e8 fd f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010076a:	81 c3 8e da 08 00    	add    $0x8da8e,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100770:	8d 83 11 7c f7 ff    	lea    -0x883ef(%ebx),%eax
f0100776:	50                   	push   %eax
f0100777:	e8 c3 3a 00 00       	call   f010423f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010077c:	83 c4 08             	add    $0x8,%esp
f010077f:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100785:	8d 83 24 7e f7 ff    	lea    -0x881dc(%ebx),%eax
f010078b:	50                   	push   %eax
f010078c:	e8 ae 3a 00 00       	call   f010423f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100791:	83 c4 0c             	add    $0xc,%esp
f0100794:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010079a:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007a0:	50                   	push   %eax
f01007a1:	57                   	push   %edi
f01007a2:	8d 83 4c 7e f7 ff    	lea    -0x881b4(%ebx),%eax
f01007a8:	50                   	push   %eax
f01007a9:	e8 91 3a 00 00       	call   f010423f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007ae:	83 c4 0c             	add    $0xc,%esp
f01007b1:	c7 c0 69 5b 10 f0    	mov    $0xf0105b69,%eax
f01007b7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007bd:	52                   	push   %edx
f01007be:	50                   	push   %eax
f01007bf:	8d 83 70 7e f7 ff    	lea    -0x88190(%ebx),%eax
f01007c5:	50                   	push   %eax
f01007c6:	e8 74 3a 00 00       	call   f010423f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007cb:	83 c4 0c             	add    $0xc,%esp
f01007ce:	c7 c0 20 01 19 f0    	mov    $0xf0190120,%eax
f01007d4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007da:	52                   	push   %edx
f01007db:	50                   	push   %eax
f01007dc:	8d 83 94 7e f7 ff    	lea    -0x8816c(%ebx),%eax
f01007e2:	50                   	push   %eax
f01007e3:	e8 57 3a 00 00       	call   f010423f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007e8:	83 c4 0c             	add    $0xc,%esp
f01007eb:	c7 c6 20 10 19 f0    	mov    $0xf0191020,%esi
f01007f1:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007f7:	50                   	push   %eax
f01007f8:	56                   	push   %esi
f01007f9:	8d 83 b8 7e f7 ff    	lea    -0x88148(%ebx),%eax
f01007ff:	50                   	push   %eax
f0100800:	e8 3a 3a 00 00       	call   f010423f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100805:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100808:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010080e:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100810:	c1 fe 0a             	sar    $0xa,%esi
f0100813:	56                   	push   %esi
f0100814:	8d 83 dc 7e f7 ff    	lea    -0x88124(%ebx),%eax
f010081a:	50                   	push   %eax
f010081b:	e8 1f 3a 00 00       	call   f010423f <cprintf>
	return 0;
}
f0100820:	b8 00 00 00 00       	mov    $0x0,%eax
f0100825:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100828:	5b                   	pop    %ebx
f0100829:	5e                   	pop    %esi
f010082a:	5f                   	pop    %edi
f010082b:	5d                   	pop    %ebp
f010082c:	c3                   	ret    

f010082d <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010082d:	55                   	push   %ebp
f010082e:	89 e5                	mov    %esp,%ebp
f0100830:	57                   	push   %edi
f0100831:	56                   	push   %esi
f0100832:	53                   	push   %ebx
f0100833:	83 ec 68             	sub    $0x68,%esp
f0100836:	e8 2c f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010083b:	81 c3 bd d9 08 00    	add    $0x8d9bd,%ebx
	// Your code here.


	cprintf("Stack backtrace:\n");
f0100841:	8d 83 2a 7c f7 ff    	lea    -0x883d6(%ebx),%eax
f0100847:	50                   	push   %eax
f0100848:	e8 f2 39 00 00       	call   f010423f <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010084d:	89 e8                	mov    %ebp,%eax
	const int MAXNAME = 9;
	int i, len;
	struct Eipdebuginfo info;
	uint32_t *ebp;
	ebp = (uint32_t *)read_ebp();
f010084f:	89 c7                	mov    %eax,%edi
	uint32_t eip;
	char fn_name[MAXNAME];
	while (ebp)
f0100851:	83 c4 10             	add    $0x10,%esp
	{
		eip = *(ebp + 1);
		if (debuginfo_eip(eip, &info) < 0)
f0100854:	8d 45 c4             	lea    -0x3c(%ebp),%eax
f0100857:	89 45 ac             	mov    %eax,-0x54(%ebp)
		{
			ebp = (uint32_t *)*ebp;
			continue;
		}
		cprintf("  ebp %08x eip %08x  args", ebp, eip);
f010085a:	8d 83 3c 7c f7 ff    	lea    -0x883c4(%ebx),%eax
f0100860:	89 45 a4             	mov    %eax,-0x5c(%ebp)
	while (ebp)
f0100863:	eb 02                	jmp    f0100867 <mon_backtrace+0x3a>
			ebp = (uint32_t *)*ebp;
f0100865:	8b 3f                	mov    (%edi),%edi
	while (ebp)
f0100867:	85 ff                	test   %edi,%edi
f0100869:	0f 84 ca 00 00 00    	je     f0100939 <mon_backtrace+0x10c>
		eip = *(ebp + 1);
f010086f:	8b 47 04             	mov    0x4(%edi),%eax
f0100872:	89 45 b0             	mov    %eax,-0x50(%ebp)
		if (debuginfo_eip(eip, &info) < 0)
f0100875:	83 ec 08             	sub    $0x8,%esp
f0100878:	ff 75 ac             	pushl  -0x54(%ebp)
f010087b:	50                   	push   %eax
f010087c:	e8 c8 42 00 00       	call   f0104b49 <debuginfo_eip>
f0100881:	83 c4 10             	add    $0x10,%esp
f0100884:	85 c0                	test   %eax,%eax
f0100886:	78 dd                	js     f0100865 <mon_backtrace+0x38>
		cprintf("  ebp %08x eip %08x  args", ebp, eip);
f0100888:	83 ec 04             	sub    $0x4,%esp
f010088b:	ff 75 b0             	pushl  -0x50(%ebp)
f010088e:	57                   	push   %edi
f010088f:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100892:	e8 a8 39 00 00       	call   f010423f <cprintf>
f0100897:	8d 77 08             	lea    0x8(%edi),%esi
f010089a:	8d 47 1c             	lea    0x1c(%edi),%eax
f010089d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f01008a0:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 5; i++)
		{
			cprintf(" %08x", *(ebp + 2 + i));
f01008a3:	8d 83 56 7c f7 ff    	lea    -0x883aa(%ebx),%eax
f01008a9:	89 7d a8             	mov    %edi,-0x58(%ebp)
f01008ac:	89 c7                	mov    %eax,%edi
f01008ae:	83 ec 08             	sub    $0x8,%esp
f01008b1:	ff 36                	pushl  (%esi)
f01008b3:	57                   	push   %edi
f01008b4:	e8 86 39 00 00       	call   f010423f <cprintf>
f01008b9:	83 c6 04             	add    $0x4,%esi
		for (i = 0; i < 5; i++)
f01008bc:	83 c4 10             	add    $0x10,%esp
f01008bf:	3b 75 b4             	cmp    -0x4c(%ebp),%esi
f01008c2:	75 ea                	jne    f01008ae <mon_backtrace+0x81>
f01008c4:	8b 7d a8             	mov    -0x58(%ebp),%edi
		}
		cprintf("\n");
f01008c7:	83 ec 0c             	sub    $0xc,%esp
f01008ca:	8d 83 2e 8c f7 ff    	lea    -0x873d2(%ebx),%eax
f01008d0:	50                   	push   %eax
f01008d1:	e8 69 39 00 00       	call   f010423f <cprintf>

		len = strlen(info.eip_fn_name);
f01008d6:	83 c4 04             	add    $0x4,%esp
f01008d9:	ff 75 cc             	pushl  -0x34(%ebp)
f01008dc:	e8 cf 4c 00 00       	call   f01055b0 <strlen>
		for (i = 0; i < len; i++)
		{
			if (info.eip_fn_name[i] == ':')
f01008e1:	8b 55 cc             	mov    -0x34(%ebp),%edx
		for (i = 0; i < len; i++)
f01008e4:	83 c4 10             	add    $0x10,%esp
f01008e7:	be 00 00 00 00       	mov    $0x0,%esi
f01008ec:	39 c6                	cmp    %eax,%esi
f01008ee:	7d 0b                	jge    f01008fb <mon_backtrace+0xce>
			if (info.eip_fn_name[i] == ':')
f01008f0:	80 3c 32 3a          	cmpb   $0x3a,(%edx,%esi,1)
f01008f4:	74 05                	je     f01008fb <mon_backtrace+0xce>
		for (i = 0; i < len; i++)
f01008f6:	83 c6 01             	add    $0x1,%esi
f01008f9:	eb f1                	jmp    f01008ec <mon_backtrace+0xbf>
			{
				break;
			}
		}
		strncpy(fn_name, info.eip_fn_name, i);
f01008fb:	83 ec 04             	sub    $0x4,%esp
f01008fe:	56                   	push   %esi
f01008ff:	52                   	push   %edx
f0100900:	8d 45 df             	lea    -0x21(%ebp),%eax
f0100903:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f0100906:	50                   	push   %eax
f0100907:	e8 1d 4d 00 00       	call   f0105629 <strncpy>
		
		fn_name[i] = '\0';
f010090c:	c6 44 35 df 00       	movb   $0x0,-0x21(%ebp,%esi,1)
		cprintf("%s:%d: %s+%d\n", info.eip_file, info.eip_line, fn_name, eip - info.eip_fn_addr);
f0100911:	8b 4d b0             	mov    -0x50(%ebp),%ecx
f0100914:	2b 4d d4             	sub    -0x2c(%ebp),%ecx
f0100917:	89 0c 24             	mov    %ecx,(%esp)
f010091a:	ff 75 b4             	pushl  -0x4c(%ebp)
f010091d:	ff 75 c8             	pushl  -0x38(%ebp)
f0100920:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100923:	8d 83 5c 7c f7 ff    	lea    -0x883a4(%ebx),%eax
f0100929:	50                   	push   %eax
f010092a:	e8 10 39 00 00       	call   f010423f <cprintf>

		ebp = (uint32_t *)*ebp;
f010092f:	8b 3f                	mov    (%edi),%edi
f0100931:	83 c4 20             	add    $0x20,%esp
f0100934:	e9 2e ff ff ff       	jmp    f0100867 <mon_backtrace+0x3a>
	}
	return 0;
}
f0100939:	b8 00 00 00 00       	mov    $0x0,%eax
f010093e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100941:	5b                   	pop    %ebx
f0100942:	5e                   	pop    %esi
f0100943:	5f                   	pop    %edi
f0100944:	5d                   	pop    %ebp
f0100945:	c3                   	ret    

f0100946 <mon_mAddr>:
{
	*(uint32_t *)va = info;
	return;
}
int mon_mAddr(int argc, char **argv, struct Trapframe *tf)
{
f0100946:	55                   	push   %ebp
f0100947:	89 e5                	mov    %esp,%ebp
f0100949:	57                   	push   %edi
f010094a:	56                   	push   %esi
f010094b:	53                   	push   %ebx
f010094c:	83 ec 0c             	sub    $0xc,%esp
f010094f:	e8 13 f8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100954:	81 c3 a4 d8 08 00    	add    $0x8d8a4,%ebx
f010095a:	8b 75 0c             	mov    0xc(%ebp),%esi
	assert(argc == 3);
f010095d:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100961:	75 2f                	jne    f0100992 <mon_mAddr+0x4c>
	uintptr_t va;
	uint32_t info;
	va = strtol(argv[1], NULL, 16);
f0100963:	83 ec 04             	sub    $0x4,%esp
f0100966:	6a 10                	push   $0x10
f0100968:	6a 00                	push   $0x0
f010096a:	ff 76 04             	pushl  0x4(%esi)
f010096d:	e8 d4 4e 00 00       	call   f0105846 <strtol>
f0100972:	89 c7                	mov    %eax,%edi
	info = strtol(argv[2], NULL, 16);
f0100974:	83 c4 0c             	add    $0xc,%esp
f0100977:	6a 10                	push   $0x10
f0100979:	6a 00                	push   $0x0
f010097b:	ff 76 08             	pushl  0x8(%esi)
f010097e:	e8 c3 4e 00 00       	call   f0105846 <strtol>
	*(uint32_t *)va = info;
f0100983:	89 07                	mov    %eax,(%edi)
	mAddr(va, info);
	return 0;
}
f0100985:	b8 00 00 00 00       	mov    $0x0,%eax
f010098a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010098d:	5b                   	pop    %ebx
f010098e:	5e                   	pop    %esi
f010098f:	5f                   	pop    %edi
f0100990:	5d                   	pop    %ebp
f0100991:	c3                   	ret    
	assert(argc == 3);
f0100992:	8d 83 6a 7c f7 ff    	lea    -0x88396(%ebx),%eax
f0100998:	50                   	push   %eax
f0100999:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010099f:	50                   	push   %eax
f01009a0:	68 1a 01 00 00       	push   $0x11a
f01009a5:	8d 83 89 7c f7 ff    	lea    -0x88377(%ebx),%eax
f01009ab:	50                   	push   %eax
f01009ac:	e8 00 f7 ff ff       	call   f01000b1 <_panic>

f01009b1 <showmappings>:
{
f01009b1:	55                   	push   %ebp
f01009b2:	89 e5                	mov    %esp,%ebp
f01009b4:	57                   	push   %edi
f01009b5:	56                   	push   %esi
f01009b6:	53                   	push   %ebx
f01009b7:	83 ec 30             	sub    $0x30,%esp
f01009ba:	e8 a8 f7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01009bf:	81 c3 39 d8 08 00    	add    $0x8d839,%ebx
f01009c5:	8b 7d 08             	mov    0x8(%ebp),%edi
	cprintf("Following are address mapping from 0x%x to 0x%x:\n", start, end);
f01009c8:	ff 75 0c             	pushl  0xc(%ebp)
f01009cb:	57                   	push   %edi
f01009cc:	8d 83 08 7f f7 ff    	lea    -0x880f8(%ebx),%eax
f01009d2:	50                   	push   %eax
f01009d3:	e8 67 38 00 00       	call   f010423f <cprintf>
	pte_t *pte = NULL;
f01009d8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f01009df:	83 c4 10             	add    $0x10,%esp
		page = page_lookup(kern_pgdir, (void *)current_page_address, &pte);
f01009e2:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01009e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01009eb:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f01009f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f01009f4:	eb 19                	jmp    f0100a0f <showmappings+0x5e>
			cprintf("  The virtual address 0x%x have no physical page\n", current_page_address);
f01009f6:	83 ec 08             	sub    $0x8,%esp
f01009f9:	57                   	push   %edi
f01009fa:	8d 83 3c 7f f7 ff    	lea    -0x880c4(%ebx),%eax
f0100a00:	50                   	push   %eax
f0100a01:	e8 39 38 00 00       	call   f010423f <cprintf>
			continue;
f0100a06:	83 c4 10             	add    $0x10,%esp
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f0100a09:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0100a0f:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100a12:	0f 87 bb 00 00 00    	ja     f0100ad3 <showmappings+0x122>
		page = page_lookup(kern_pgdir, (void *)current_page_address, &pte);
f0100a18:	83 ec 04             	sub    $0x4,%esp
f0100a1b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100a1e:	50                   	push   %eax
f0100a1f:	57                   	push   %edi
f0100a20:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100a23:	ff 30                	pushl  (%eax)
f0100a25:	e8 58 0f 00 00       	call   f0101982 <page_lookup>
f0100a2a:	89 c6                	mov    %eax,%esi
		if (!page)
f0100a2c:	83 c4 10             	add    $0x10,%esp
f0100a2f:	85 c0                	test   %eax,%eax
f0100a31:	74 c3                	je     f01009f6 <showmappings+0x45>
		cprintf("  The virtual address is 0x%x\n", current_page_address);
f0100a33:	83 ec 08             	sub    $0x8,%esp
f0100a36:	57                   	push   %edi
f0100a37:	8d 83 70 7f f7 ff    	lea    -0x88090(%ebx),%eax
f0100a3d:	50                   	push   %eax
f0100a3e:	e8 fc 37 00 00       	call   f010423f <cprintf>
		cprintf("    The mapping physical page address is 0x%08x\n", page2pa(page));
f0100a43:	83 c4 08             	add    $0x8,%esp
f0100a46:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100a49:	2b 30                	sub    (%eax),%esi
f0100a4b:	c1 fe 03             	sar    $0x3,%esi
f0100a4e:	c1 e6 0c             	shl    $0xc,%esi
f0100a51:	56                   	push   %esi
f0100a52:	8d 83 90 7f f7 ff    	lea    -0x88070(%ebx),%eax
f0100a58:	50                   	push   %eax
f0100a59:	e8 e1 37 00 00       	call   f010423f <cprintf>
		cprintf("    The permissions bits:\n");
f0100a5e:	8d 83 98 7c f7 ff    	lea    -0x88368(%ebx),%eax
f0100a64:	89 04 24             	mov    %eax,(%esp)
f0100a67:	e8 d3 37 00 00       	call   f010423f <cprintf>
				!!(*pte & PTE_G));
f0100a6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a6f:	8b 00                	mov    (%eax),%eax
		cprintf("      PTE_P: %d PTE_W: %d PTE_U: %d PTE_PWT: %d PTE_PCD: %d PTE_A: %d PTE_D: %d PTE_PS: %d PTE_G: %d\n\n",
f0100a71:	83 c4 08             	add    $0x8,%esp
f0100a74:	89 c2                	mov    %eax,%edx
f0100a76:	c1 ea 08             	shr    $0x8,%edx
f0100a79:	83 e2 01             	and    $0x1,%edx
f0100a7c:	52                   	push   %edx
f0100a7d:	89 c2                	mov    %eax,%edx
f0100a7f:	c1 ea 07             	shr    $0x7,%edx
f0100a82:	83 e2 01             	and    $0x1,%edx
f0100a85:	52                   	push   %edx
f0100a86:	89 c2                	mov    %eax,%edx
f0100a88:	c1 ea 06             	shr    $0x6,%edx
f0100a8b:	83 e2 01             	and    $0x1,%edx
f0100a8e:	52                   	push   %edx
f0100a8f:	89 c2                	mov    %eax,%edx
f0100a91:	c1 ea 05             	shr    $0x5,%edx
f0100a94:	83 e2 01             	and    $0x1,%edx
f0100a97:	52                   	push   %edx
f0100a98:	89 c2                	mov    %eax,%edx
f0100a9a:	c1 ea 04             	shr    $0x4,%edx
f0100a9d:	83 e2 01             	and    $0x1,%edx
f0100aa0:	52                   	push   %edx
f0100aa1:	89 c2                	mov    %eax,%edx
f0100aa3:	c1 ea 03             	shr    $0x3,%edx
f0100aa6:	83 e2 01             	and    $0x1,%edx
f0100aa9:	52                   	push   %edx
f0100aaa:	89 c2                	mov    %eax,%edx
f0100aac:	c1 ea 02             	shr    $0x2,%edx
f0100aaf:	83 e2 01             	and    $0x1,%edx
f0100ab2:	52                   	push   %edx
f0100ab3:	89 c2                	mov    %eax,%edx
f0100ab5:	d1 ea                	shr    %edx
f0100ab7:	83 e2 01             	and    $0x1,%edx
f0100aba:	52                   	push   %edx
f0100abb:	83 e0 01             	and    $0x1,%eax
f0100abe:	50                   	push   %eax
f0100abf:	8d 83 c4 7f f7 ff    	lea    -0x8803c(%ebx),%eax
f0100ac5:	50                   	push   %eax
f0100ac6:	e8 74 37 00 00       	call   f010423f <cprintf>
f0100acb:	83 c4 30             	add    $0x30,%esp
f0100ace:	e9 36 ff ff ff       	jmp    f0100a09 <showmappings+0x58>
}
f0100ad3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ad6:	5b                   	pop    %ebx
f0100ad7:	5e                   	pop    %esi
f0100ad8:	5f                   	pop    %edi
f0100ad9:	5d                   	pop    %ebp
f0100ada:	c3                   	ret    

f0100adb <mon_showmappings>:
{
f0100adb:	55                   	push   %ebp
f0100adc:	89 e5                	mov    %esp,%ebp
f0100ade:	57                   	push   %edi
f0100adf:	56                   	push   %esi
f0100ae0:	53                   	push   %ebx
f0100ae1:	83 ec 0c             	sub    $0xc,%esp
f0100ae4:	e8 7e f6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100ae9:	81 c3 0f d7 08 00    	add    $0x8d70f,%ebx
f0100aef:	8b 75 0c             	mov    0xc(%ebp),%esi
	assert(argc == 3);
f0100af2:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100af6:	75 3e                	jne    f0100b36 <mon_showmappings+0x5b>
	uintptr_t start = strtol(argv[1], NULL, 16), end = strtol(argv[2], NULL, 16);
f0100af8:	83 ec 04             	sub    $0x4,%esp
f0100afb:	6a 10                	push   $0x10
f0100afd:	6a 00                	push   $0x0
f0100aff:	ff 76 04             	pushl  0x4(%esi)
f0100b02:	e8 3f 4d 00 00       	call   f0105846 <strtol>
f0100b07:	89 c7                	mov    %eax,%edi
f0100b09:	83 c4 0c             	add    $0xc,%esp
f0100b0c:	6a 10                	push   $0x10
f0100b0e:	6a 00                	push   $0x0
f0100b10:	ff 76 08             	pushl  0x8(%esi)
f0100b13:	e8 2e 4d 00 00       	call   f0105846 <strtol>
	assert(start <= end);
f0100b18:	83 c4 10             	add    $0x10,%esp
f0100b1b:	39 c7                	cmp    %eax,%edi
f0100b1d:	77 36                	ja     f0100b55 <mon_showmappings+0x7a>
	showmappings(start, end);
f0100b1f:	83 ec 08             	sub    $0x8,%esp
f0100b22:	50                   	push   %eax
f0100b23:	57                   	push   %edi
f0100b24:	e8 88 fe ff ff       	call   f01009b1 <showmappings>
}
f0100b29:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b31:	5b                   	pop    %ebx
f0100b32:	5e                   	pop    %esi
f0100b33:	5f                   	pop    %edi
f0100b34:	5d                   	pop    %ebp
f0100b35:	c3                   	ret    
	assert(argc == 3);
f0100b36:	8d 83 6a 7c f7 ff    	lea    -0x88396(%ebx),%eax
f0100b3c:	50                   	push   %eax
f0100b3d:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0100b43:	50                   	push   %eax
f0100b44:	68 8d 00 00 00       	push   $0x8d
f0100b49:	8d 83 89 7c f7 ff    	lea    -0x88377(%ebx),%eax
f0100b4f:	50                   	push   %eax
f0100b50:	e8 5c f5 ff ff       	call   f01000b1 <_panic>
	assert(start <= end);
f0100b55:	8d 83 b3 7c f7 ff    	lea    -0x8834d(%ebx),%eax
f0100b5b:	50                   	push   %eax
f0100b5c:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0100b62:	50                   	push   %eax
f0100b63:	68 8f 00 00 00       	push   $0x8f
f0100b68:	8d 83 89 7c f7 ff    	lea    -0x88377(%ebx),%eax
f0100b6e:	50                   	push   %eax
f0100b6f:	e8 3d f5 ff ff       	call   f01000b1 <_panic>

f0100b74 <mPerm>:
{
f0100b74:	55                   	push   %ebp
f0100b75:	89 e5                	mov    %esp,%ebp
f0100b77:	57                   	push   %edi
f0100b78:	56                   	push   %esi
f0100b79:	53                   	push   %ebx
f0100b7a:	83 ec 10             	sub    $0x10,%esp
f0100b7d:	e8 e5 f5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100b82:	81 c3 76 d6 08 00    	add    $0x8d676,%ebx
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)va, 1);
f0100b88:	6a 01                	push   $0x1
f0100b8a:	ff 75 0c             	pushl  0xc(%ebp)
f0100b8d:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0100b93:	ff 30                	pushl  (%eax)
f0100b95:	e8 ee 0c 00 00       	call   f0101888 <pgdir_walk>
f0100b9a:	89 c7                	mov    %eax,%edi
	if (new_perm == 1)
f0100b9c:	83 c4 08             	add    $0x8,%esp
f0100b9f:	83 7d 14 01          	cmpl   $0x1,0x14(%ebp)
f0100ba3:	0f 95 c0             	setne  %al
f0100ba6:	0f b6 c0             	movzbl %al,%eax
f0100ba9:	f7 d8                	neg    %eax
f0100bab:	89 c6                	mov    %eax,%esi
	if (strcmp(perm, "PTE_P") == 0)
f0100bad:	8d 83 3b 8c f7 ff    	lea    -0x873c5(%ebx),%eax
f0100bb3:	50                   	push   %eax
f0100bb4:	ff 75 10             	pushl  0x10(%ebp)
f0100bb7:	e8 d1 4a 00 00       	call   f010568d <strcmp>
f0100bbc:	83 c4 10             	add    $0x10,%esp
f0100bbf:	85 c0                	test   %eax,%eax
f0100bc1:	75 17                	jne    f0100bda <mPerm+0x66>
		tmp = tmp ^ PTE_P;
f0100bc3:	83 f6 01             	xor    $0x1,%esi
	if (new_perm == 1)
f0100bc6:	83 7d 14 01          	cmpl   $0x1,0x14(%ebp)
f0100bca:	0f 84 13 01 00 00    	je     f0100ce3 <mPerm+0x16f>
		*pte &= tmp;
f0100bd0:	21 37                	and    %esi,(%edi)
}
f0100bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bd5:	5b                   	pop    %ebx
f0100bd6:	5e                   	pop    %esi
f0100bd7:	5f                   	pop    %edi
f0100bd8:	5d                   	pop    %ebp
f0100bd9:	c3                   	ret    
	else if (strcmp(perm, "PTE_W") == 0)
f0100bda:	83 ec 08             	sub    $0x8,%esp
f0100bdd:	8d 83 4c 8c f7 ff    	lea    -0x873b4(%ebx),%eax
f0100be3:	50                   	push   %eax
f0100be4:	ff 75 10             	pushl  0x10(%ebp)
f0100be7:	e8 a1 4a 00 00       	call   f010568d <strcmp>
f0100bec:	83 c4 10             	add    $0x10,%esp
f0100bef:	85 c0                	test   %eax,%eax
f0100bf1:	75 05                	jne    f0100bf8 <mPerm+0x84>
		tmp = tmp ^ PTE_W;
f0100bf3:	83 f6 02             	xor    $0x2,%esi
f0100bf6:	eb ce                	jmp    f0100bc6 <mPerm+0x52>
	else if (strcmp(perm, "PTE_U") == 0)
f0100bf8:	83 ec 08             	sub    $0x8,%esp
f0100bfb:	8d 83 8e 8b f7 ff    	lea    -0x87472(%ebx),%eax
f0100c01:	50                   	push   %eax
f0100c02:	ff 75 10             	pushl  0x10(%ebp)
f0100c05:	e8 83 4a 00 00       	call   f010568d <strcmp>
f0100c0a:	83 c4 10             	add    $0x10,%esp
f0100c0d:	85 c0                	test   %eax,%eax
f0100c0f:	75 05                	jne    f0100c16 <mPerm+0xa2>
		tmp = tmp ^ PTE_U;
f0100c11:	83 f6 04             	xor    $0x4,%esi
f0100c14:	eb b0                	jmp    f0100bc6 <mPerm+0x52>
	else if (strcmp(perm, "PTE_PWT") == 0)
f0100c16:	83 ec 08             	sub    $0x8,%esp
f0100c19:	8d 83 c0 7c f7 ff    	lea    -0x88340(%ebx),%eax
f0100c1f:	50                   	push   %eax
f0100c20:	ff 75 10             	pushl  0x10(%ebp)
f0100c23:	e8 65 4a 00 00       	call   f010568d <strcmp>
f0100c28:	83 c4 10             	add    $0x10,%esp
f0100c2b:	85 c0                	test   %eax,%eax
f0100c2d:	75 05                	jne    f0100c34 <mPerm+0xc0>
		tmp = tmp ^ PTE_PWT;
f0100c2f:	83 f6 08             	xor    $0x8,%esi
f0100c32:	eb 92                	jmp    f0100bc6 <mPerm+0x52>
	else if (strcmp(perm, "PTE_PCD") == 0)
f0100c34:	83 ec 08             	sub    $0x8,%esp
f0100c37:	8d 83 c8 7c f7 ff    	lea    -0x88338(%ebx),%eax
f0100c3d:	50                   	push   %eax
f0100c3e:	ff 75 10             	pushl  0x10(%ebp)
f0100c41:	e8 47 4a 00 00       	call   f010568d <strcmp>
f0100c46:	83 c4 10             	add    $0x10,%esp
f0100c49:	85 c0                	test   %eax,%eax
f0100c4b:	75 08                	jne    f0100c55 <mPerm+0xe1>
		tmp = tmp ^ PTE_PCD;
f0100c4d:	83 f6 10             	xor    $0x10,%esi
f0100c50:	e9 71 ff ff ff       	jmp    f0100bc6 <mPerm+0x52>
	else if (strcmp(perm, "PTE_A") == 0)
f0100c55:	83 ec 08             	sub    $0x8,%esp
f0100c58:	8d 83 d0 7c f7 ff    	lea    -0x88330(%ebx),%eax
f0100c5e:	50                   	push   %eax
f0100c5f:	ff 75 10             	pushl  0x10(%ebp)
f0100c62:	e8 26 4a 00 00       	call   f010568d <strcmp>
f0100c67:	83 c4 10             	add    $0x10,%esp
f0100c6a:	85 c0                	test   %eax,%eax
f0100c6c:	75 08                	jne    f0100c76 <mPerm+0x102>
		tmp = tmp ^ PTE_A;
f0100c6e:	83 f6 20             	xor    $0x20,%esi
f0100c71:	e9 50 ff ff ff       	jmp    f0100bc6 <mPerm+0x52>
	else if (strcmp(perm, "PTE_D") == 0)
f0100c76:	83 ec 08             	sub    $0x8,%esp
f0100c79:	8d 83 d6 7c f7 ff    	lea    -0x8832a(%ebx),%eax
f0100c7f:	50                   	push   %eax
f0100c80:	ff 75 10             	pushl  0x10(%ebp)
f0100c83:	e8 05 4a 00 00       	call   f010568d <strcmp>
f0100c88:	83 c4 10             	add    $0x10,%esp
f0100c8b:	85 c0                	test   %eax,%eax
f0100c8d:	75 08                	jne    f0100c97 <mPerm+0x123>
		tmp = tmp ^ PTE_D;
f0100c8f:	83 f6 40             	xor    $0x40,%esi
f0100c92:	e9 2f ff ff ff       	jmp    f0100bc6 <mPerm+0x52>
	else if (strcmp(perm, "PTE_PS") == 0)
f0100c97:	83 ec 08             	sub    $0x8,%esp
f0100c9a:	8d 83 dc 7c f7 ff    	lea    -0x88324(%ebx),%eax
f0100ca0:	50                   	push   %eax
f0100ca1:	ff 75 10             	pushl  0x10(%ebp)
f0100ca4:	e8 e4 49 00 00       	call   f010568d <strcmp>
f0100ca9:	83 c4 10             	add    $0x10,%esp
f0100cac:	85 c0                	test   %eax,%eax
f0100cae:	75 0b                	jne    f0100cbb <mPerm+0x147>
		tmp = tmp ^ PTE_PS;
f0100cb0:	81 f6 80 00 00 00    	xor    $0x80,%esi
f0100cb6:	e9 0b ff ff ff       	jmp    f0100bc6 <mPerm+0x52>
	else if (strcmp(perm, "PTE_G") == 0)
f0100cbb:	83 ec 08             	sub    $0x8,%esp
f0100cbe:	8d 83 e3 7c f7 ff    	lea    -0x8831d(%ebx),%eax
f0100cc4:	50                   	push   %eax
f0100cc5:	ff 75 10             	pushl  0x10(%ebp)
f0100cc8:	e8 c0 49 00 00       	call   f010568d <strcmp>
f0100ccd:	83 c4 10             	add    $0x10,%esp
f0100cd0:	85 c0                	test   %eax,%eax
f0100cd2:	0f 85 ee fe ff ff    	jne    f0100bc6 <mPerm+0x52>
		tmp = tmp ^ PTE_G;
f0100cd8:	81 f6 00 01 00 00    	xor    $0x100,%esi
f0100cde:	e9 e3 fe ff ff       	jmp    f0100bc6 <mPerm+0x52>
		*pte |= tmp;
f0100ce3:	09 37                	or     %esi,(%edi)
f0100ce5:	e9 e8 fe ff ff       	jmp    f0100bd2 <mPerm+0x5e>

f0100cea <mon_mPerm>:
{
f0100cea:	55                   	push   %ebp
f0100ceb:	89 e5                	mov    %esp,%ebp
f0100ced:	57                   	push   %edi
f0100cee:	56                   	push   %esi
f0100cef:	53                   	push   %ebx
f0100cf0:	83 ec 20             	sub    $0x20,%esp
f0100cf3:	e8 6f f4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100cf8:	81 c3 00 d5 08 00    	add    $0x8d500,%ebx
f0100cfe:	8b 75 0c             	mov    0xc(%ebp),%esi
	char *ops = argv[1];
f0100d01:	8b 7e 04             	mov    0x4(%esi),%edi
	uintptr_t va = strtol(argv[2], NULL, 16);
f0100d04:	6a 10                	push   $0x10
f0100d06:	6a 00                	push   $0x0
f0100d08:	ff 76 08             	pushl  0x8(%esi)
f0100d0b:	e8 36 4b 00 00       	call   f0105846 <strtol>
f0100d10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char *perm = argv[3];
f0100d13:	8b 46 0c             	mov    0xc(%esi),%eax
f0100d16:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if (!strcmp(ops, "CHANGE"))
f0100d19:	83 c4 08             	add    $0x8,%esp
f0100d1c:	8d 83 e9 7c f7 ff    	lea    -0x88317(%ebx),%eax
f0100d22:	50                   	push   %eax
f0100d23:	57                   	push   %edi
f0100d24:	e8 64 49 00 00       	call   f010568d <strcmp>
f0100d29:	83 c4 10             	add    $0x10,%esp
f0100d2c:	85 c0                	test   %eax,%eax
f0100d2e:	75 51                	jne    f0100d81 <mon_mPerm+0x97>
		assert(argc == 5);
f0100d30:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100d34:	75 2c                	jne    f0100d62 <mon_mPerm+0x78>
		new_perm = strtol(argv[4], NULL, 10);
f0100d36:	83 ec 04             	sub    $0x4,%esp
f0100d39:	6a 0a                	push   $0xa
f0100d3b:	6a 00                	push   $0x0
f0100d3d:	ff 76 10             	pushl  0x10(%esi)
f0100d40:	e8 01 4b 00 00       	call   f0105846 <strtol>
f0100d45:	83 c4 10             	add    $0x10,%esp
	mPerm(ops, va, perm, new_perm);
f0100d48:	50                   	push   %eax
f0100d49:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d4c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d4f:	57                   	push   %edi
f0100d50:	e8 1f fe ff ff       	call   f0100b74 <mPerm>
}
f0100d55:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d5d:	5b                   	pop    %ebx
f0100d5e:	5e                   	pop    %esi
f0100d5f:	5f                   	pop    %edi
f0100d60:	5d                   	pop    %ebp
f0100d61:	c3                   	ret    
		assert(argc == 5);
f0100d62:	8d 83 f0 7c f7 ff    	lea    -0x88310(%ebx),%eax
f0100d68:	50                   	push   %eax
f0100d69:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0100d6f:	50                   	push   %eax
f0100d70:	68 d1 00 00 00       	push   $0xd1
f0100d75:	8d 83 89 7c f7 ff    	lea    -0x88377(%ebx),%eax
f0100d7b:	50                   	push   %eax
f0100d7c:	e8 30 f3 ff ff       	call   f01000b1 <_panic>
	else if (!strcmp(ops, "SET"))
f0100d81:	83 ec 08             	sub    $0x8,%esp
f0100d84:	8d 83 fa 7c f7 ff    	lea    -0x88306(%ebx),%eax
f0100d8a:	50                   	push   %eax
f0100d8b:	57                   	push   %edi
f0100d8c:	e8 fc 48 00 00       	call   f010568d <strcmp>
f0100d91:	83 c4 10             	add    $0x10,%esp
f0100d94:	85 c0                	test   %eax,%eax
f0100d96:	75 2c                	jne    f0100dc4 <mon_mPerm+0xda>
		assert(argc == 4);
f0100d98:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100d9c:	75 07                	jne    f0100da5 <mon_mPerm+0xbb>
		new_perm = 1;
f0100d9e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100da3:	eb a3                	jmp    f0100d48 <mon_mPerm+0x5e>
		assert(argc == 4);
f0100da5:	8d 83 fe 7c f7 ff    	lea    -0x88302(%ebx),%eax
f0100dab:	50                   	push   %eax
f0100dac:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0100db2:	50                   	push   %eax
f0100db3:	68 d6 00 00 00       	push   $0xd6
f0100db8:	8d 83 89 7c f7 ff    	lea    -0x88377(%ebx),%eax
f0100dbe:	50                   	push   %eax
f0100dbf:	e8 ed f2 ff ff       	call   f01000b1 <_panic>
	else if (!strcmp(ops, "CLEAR"))
f0100dc4:	83 ec 08             	sub    $0x8,%esp
f0100dc7:	8d 83 08 7d f7 ff    	lea    -0x882f8(%ebx),%eax
f0100dcd:	50                   	push   %eax
f0100dce:	57                   	push   %edi
f0100dcf:	e8 b9 48 00 00       	call   f010568d <strcmp>
f0100dd4:	83 c4 10             	add    $0x10,%esp
f0100dd7:	85 c0                	test   %eax,%eax
f0100dd9:	75 29                	jne    f0100e04 <mon_mPerm+0x11a>
		assert(argc == 4);
f0100ddb:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100ddf:	0f 84 63 ff ff ff    	je     f0100d48 <mon_mPerm+0x5e>
f0100de5:	8d 83 fe 7c f7 ff    	lea    -0x88302(%ebx),%eax
f0100deb:	50                   	push   %eax
f0100dec:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0100df2:	50                   	push   %eax
f0100df3:	68 db 00 00 00       	push   $0xdb
f0100df8:	8d 83 89 7c f7 ff    	lea    -0x88377(%ebx),%eax
f0100dfe:	50                   	push   %eax
f0100dff:	e8 ad f2 ff ff       	call   f01000b1 <_panic>
		cprintf("INVALID COMMAND\n");
f0100e04:	83 ec 0c             	sub    $0xc,%esp
f0100e07:	8d 83 0e 7d f7 ff    	lea    -0x882f2(%ebx),%eax
f0100e0d:	50                   	push   %eax
f0100e0e:	e8 2c 34 00 00       	call   f010423f <cprintf>
f0100e13:	83 c4 10             	add    $0x10,%esp
	int new_perm = 0;
f0100e16:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e1b:	e9 28 ff ff ff       	jmp    f0100d48 <mon_mPerm+0x5e>

f0100e20 <dump_v>:
{
f0100e20:	55                   	push   %ebp
f0100e21:	89 e5                	mov    %esp,%ebp
f0100e23:	57                   	push   %edi
f0100e24:	56                   	push   %esi
f0100e25:	53                   	push   %ebx
f0100e26:	83 ec 0c             	sub    $0xc,%esp
f0100e29:	e8 39 f3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100e2e:	81 c3 ca d3 08 00    	add    $0x8d3ca,%ebx
f0100e34:	8b 75 08             	mov    0x8(%ebp),%esi
		cprintf("The virtual address is 0x%08x and content is 0x%08x\n", current_va, *(uint32_t *)current_va);
f0100e37:	8d bb 2c 80 f7 ff    	lea    -0x87fd4(%ebx),%edi
	for (current_va = va_start; current_va <= va_end; current_va += PGSIZE)
f0100e3d:	eb 15                	jmp    f0100e54 <dump_v+0x34>
		cprintf("The virtual address is 0x%08x and content is 0x%08x\n", current_va, *(uint32_t *)current_va);
f0100e3f:	83 ec 04             	sub    $0x4,%esp
f0100e42:	ff 36                	pushl  (%esi)
f0100e44:	56                   	push   %esi
f0100e45:	57                   	push   %edi
f0100e46:	e8 f4 33 00 00       	call   f010423f <cprintf>
	for (current_va = va_start; current_va <= va_end; current_va += PGSIZE)
f0100e4b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100e51:	83 c4 10             	add    $0x10,%esp
f0100e54:	3b 75 0c             	cmp    0xc(%ebp),%esi
f0100e57:	76 e6                	jbe    f0100e3f <dump_v+0x1f>
}
f0100e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e5c:	5b                   	pop    %ebx
f0100e5d:	5e                   	pop    %esi
f0100e5e:	5f                   	pop    %edi
f0100e5f:	5d                   	pop    %ebp
f0100e60:	c3                   	ret    

f0100e61 <dump_p>:
{
f0100e61:	55                   	push   %ebp
f0100e62:	89 e5                	mov    %esp,%ebp
f0100e64:	57                   	push   %edi
f0100e65:	56                   	push   %esi
f0100e66:	53                   	push   %ebx
f0100e67:	83 ec 1c             	sub    $0x1c,%esp
f0100e6a:	e8 f8 f2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100e6f:	81 c3 89 d3 08 00    	add    $0x8d389,%ebx
f0100e75:	8b 75 08             	mov    0x8(%ebp),%esi
	if (PGNUM(pa) >= npages)
f0100e78:	c7 c7 28 10 19 f0    	mov    $0xf0191028,%edi
		cprintf("The physical address is 0x%08x and content is 0x%08x\n", current_pa, *(uint32_t *)KADDR(current_pa));
f0100e7e:	8d 83 88 80 f7 ff    	lea    -0x87f78(%ebx),%eax
f0100e84:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (current_pa = pa_start; current_pa <= pa_end; current_pa += PGSIZE)
f0100e87:	3b 75 0c             	cmp    0xc(%ebp),%esi
f0100e8a:	77 3f                	ja     f0100ecb <dump_p+0x6a>
f0100e8c:	89 f0                	mov    %esi,%eax
f0100e8e:	c1 e8 0c             	shr    $0xc,%eax
f0100e91:	3b 07                	cmp    (%edi),%eax
f0100e93:	73 1d                	jae    f0100eb2 <dump_p+0x51>
		cprintf("The physical address is 0x%08x and content is 0x%08x\n", current_pa, *(uint32_t *)KADDR(current_pa));
f0100e95:	83 ec 04             	sub    $0x4,%esp
f0100e98:	ff b6 00 00 00 f0    	pushl  -0x10000000(%esi)
f0100e9e:	56                   	push   %esi
f0100e9f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100ea2:	e8 98 33 00 00       	call   f010423f <cprintf>
	for (current_pa = pa_start; current_pa <= pa_end; current_pa += PGSIZE)
f0100ea7:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100ead:	83 c4 10             	add    $0x10,%esp
f0100eb0:	eb d5                	jmp    f0100e87 <dump_p+0x26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eb2:	56                   	push   %esi
f0100eb3:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f0100eb9:	50                   	push   %eax
f0100eba:	68 f3 00 00 00       	push   $0xf3
f0100ebf:	8d 83 89 7c f7 ff    	lea    -0x88377(%ebx),%eax
f0100ec5:	50                   	push   %eax
f0100ec6:	e8 e6 f1 ff ff       	call   f01000b1 <_panic>
}
f0100ecb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ece:	5b                   	pop    %ebx
f0100ecf:	5e                   	pop    %esi
f0100ed0:	5f                   	pop    %edi
f0100ed1:	5d                   	pop    %ebp
f0100ed2:	c3                   	ret    

f0100ed3 <mon_dump>:
{
f0100ed3:	55                   	push   %ebp
f0100ed4:	89 e5                	mov    %esp,%ebp
f0100ed6:	57                   	push   %edi
f0100ed7:	56                   	push   %esi
f0100ed8:	53                   	push   %ebx
f0100ed9:	83 ec 0c             	sub    $0xc,%esp
f0100edc:	e8 86 f2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100ee1:	81 c3 17 d3 08 00    	add    $0x8d317,%ebx
f0100ee7:	8b 75 0c             	mov    0xc(%ebp),%esi
	assert(argc == 4);
f0100eea:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100eee:	75 5b                	jne    f0100f4b <mon_dump+0x78>
	char *addr_type = argv[1];
f0100ef0:	8b 7e 04             	mov    0x4(%esi),%edi
	if (!strcmp(addr_type, "physical"))
f0100ef3:	83 ec 08             	sub    $0x8,%esp
f0100ef6:	8d 83 1f 7d f7 ff    	lea    -0x882e1(%ebx),%eax
f0100efc:	50                   	push   %eax
f0100efd:	57                   	push   %edi
f0100efe:	e8 8a 47 00 00       	call   f010568d <strcmp>
f0100f03:	83 c4 10             	add    $0x10,%esp
f0100f06:	85 c0                	test   %eax,%eax
f0100f08:	75 7f                	jne    f0100f89 <mon_dump+0xb6>
		p_start = strtol(argv[2], NULL, 16);
f0100f0a:	83 ec 04             	sub    $0x4,%esp
f0100f0d:	6a 10                	push   $0x10
f0100f0f:	6a 00                	push   $0x0
f0100f11:	ff 76 08             	pushl  0x8(%esi)
f0100f14:	e8 2d 49 00 00       	call   f0105846 <strtol>
f0100f19:	89 c7                	mov    %eax,%edi
		p_end = strtol(argv[3], NULL, 16);
f0100f1b:	83 c4 0c             	add    $0xc,%esp
f0100f1e:	6a 10                	push   $0x10
f0100f20:	6a 00                	push   $0x0
f0100f22:	ff 76 0c             	pushl  0xc(%esi)
f0100f25:	e8 1c 49 00 00       	call   f0105846 <strtol>
		assert(p_start <= p_end);
f0100f2a:	83 c4 10             	add    $0x10,%esp
f0100f2d:	39 c7                	cmp    %eax,%edi
f0100f2f:	77 39                	ja     f0100f6a <mon_dump+0x97>
		dump_p(p_start, p_end);
f0100f31:	83 ec 08             	sub    $0x8,%esp
f0100f34:	50                   	push   %eax
f0100f35:	57                   	push   %edi
f0100f36:	e8 26 ff ff ff       	call   f0100e61 <dump_p>
f0100f3b:	83 c4 10             	add    $0x10,%esp
}
f0100f3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f46:	5b                   	pop    %ebx
f0100f47:	5e                   	pop    %esi
f0100f48:	5f                   	pop    %edi
f0100f49:	5d                   	pop    %ebp
f0100f4a:	c3                   	ret    
	assert(argc == 4);
f0100f4b:	8d 83 fe 7c f7 ff    	lea    -0x88302(%ebx),%eax
f0100f51:	50                   	push   %eax
f0100f52:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0100f58:	50                   	push   %eax
f0100f59:	68 fa 00 00 00       	push   $0xfa
f0100f5e:	8d 83 89 7c f7 ff    	lea    -0x88377(%ebx),%eax
f0100f64:	50                   	push   %eax
f0100f65:	e8 47 f1 ff ff       	call   f01000b1 <_panic>
		assert(p_start <= p_end);
f0100f6a:	8d 83 28 7d f7 ff    	lea    -0x882d8(%ebx),%eax
f0100f70:	50                   	push   %eax
f0100f71:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0100f77:	50                   	push   %eax
f0100f78:	68 02 01 00 00       	push   $0x102
f0100f7d:	8d 83 89 7c f7 ff    	lea    -0x88377(%ebx),%eax
f0100f83:	50                   	push   %eax
f0100f84:	e8 28 f1 ff ff       	call   f01000b1 <_panic>
	else if (!strcmp(addr_type, "virtual"))
f0100f89:	83 ec 08             	sub    $0x8,%esp
f0100f8c:	8d 83 39 7d f7 ff    	lea    -0x882c7(%ebx),%eax
f0100f92:	50                   	push   %eax
f0100f93:	57                   	push   %edi
f0100f94:	e8 f4 46 00 00       	call   f010568d <strcmp>
f0100f99:	83 c4 10             	add    $0x10,%esp
f0100f9c:	85 c0                	test   %eax,%eax
f0100f9e:	75 58                	jne    f0100ff8 <mon_dump+0x125>
		v_start = strtol(argv[2], NULL, 16);
f0100fa0:	83 ec 04             	sub    $0x4,%esp
f0100fa3:	6a 10                	push   $0x10
f0100fa5:	6a 00                	push   $0x0
f0100fa7:	ff 76 08             	pushl  0x8(%esi)
f0100faa:	e8 97 48 00 00       	call   f0105846 <strtol>
f0100faf:	89 c7                	mov    %eax,%edi
		v_end = strtol(argv[3], NULL, 16);
f0100fb1:	83 c4 0c             	add    $0xc,%esp
f0100fb4:	6a 10                	push   $0x10
f0100fb6:	6a 00                	push   $0x0
f0100fb8:	ff 76 0c             	pushl  0xc(%esi)
f0100fbb:	e8 86 48 00 00       	call   f0105846 <strtol>
		assert(v_start <= v_end);
f0100fc0:	83 c4 10             	add    $0x10,%esp
f0100fc3:	39 c7                	cmp    %eax,%edi
f0100fc5:	77 12                	ja     f0100fd9 <mon_dump+0x106>
		dump_v(v_start, v_end);
f0100fc7:	83 ec 08             	sub    $0x8,%esp
f0100fca:	50                   	push   %eax
f0100fcb:	57                   	push   %edi
f0100fcc:	e8 4f fe ff ff       	call   f0100e20 <dump_v>
f0100fd1:	83 c4 10             	add    $0x10,%esp
f0100fd4:	e9 65 ff ff ff       	jmp    f0100f3e <mon_dump+0x6b>
		assert(v_start <= v_end);
f0100fd9:	8d 83 41 7d f7 ff    	lea    -0x882bf(%ebx),%eax
f0100fdf:	50                   	push   %eax
f0100fe0:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0100fe6:	50                   	push   %eax
f0100fe7:	68 09 01 00 00       	push   $0x109
f0100fec:	8d 83 89 7c f7 ff    	lea    -0x88377(%ebx),%eax
f0100ff2:	50                   	push   %eax
f0100ff3:	e8 b9 f0 ff ff       	call   f01000b1 <_panic>
		cprintf("INVAILD ADDRESS TYPE\n");
f0100ff8:	83 ec 0c             	sub    $0xc,%esp
f0100ffb:	8d 83 52 7d f7 ff    	lea    -0x882ae(%ebx),%eax
f0101001:	50                   	push   %eax
f0101002:	e8 38 32 00 00       	call   f010423f <cprintf>
		return 0;
f0101007:	83 c4 10             	add    $0x10,%esp
f010100a:	e9 2f ff ff ff       	jmp    f0100f3e <mon_dump+0x6b>

f010100f <mAddr>:
{
f010100f:	55                   	push   %ebp
f0101010:	89 e5                	mov    %esp,%ebp
	*(uint32_t *)va = info;
f0101012:	8b 45 08             	mov    0x8(%ebp),%eax
f0101015:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101018:	89 10                	mov    %edx,(%eax)
}
f010101a:	5d                   	pop    %ebp
f010101b:	c3                   	ret    

f010101c <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010101c:	55                   	push   %ebp
f010101d:	89 e5                	mov    %esp,%ebp
f010101f:	57                   	push   %edi
f0101020:	56                   	push   %esi
f0101021:	53                   	push   %ebx
f0101022:	83 ec 68             	sub    $0x68,%esp
f0101025:	e8 3d f1 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010102a:	81 c3 ce d1 08 00    	add    $0x8d1ce,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0101030:	8d 83 c0 80 f7 ff    	lea    -0x87f40(%ebx),%eax
f0101036:	50                   	push   %eax
f0101037:	e8 03 32 00 00       	call   f010423f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010103c:	8d 83 e4 80 f7 ff    	lea    -0x87f1c(%ebx),%eax
f0101042:	89 04 24             	mov    %eax,(%esp)
f0101045:	e8 f5 31 00 00       	call   f010423f <cprintf>

	if (tf != NULL)
f010104a:	83 c4 10             	add    $0x10,%esp
f010104d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101051:	74 0e                	je     f0101061 <monitor+0x45>
		print_trapframe(tf);
f0101053:	83 ec 0c             	sub    $0xc,%esp
f0101056:	ff 75 08             	pushl  0x8(%ebp)
f0101059:	e8 dc 33 00 00       	call   f010443a <print_trapframe>
f010105e:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0101061:	8d bb 6c 7d f7 ff    	lea    -0x88294(%ebx),%edi
f0101067:	eb 4a                	jmp    f01010b3 <monitor+0x97>
f0101069:	83 ec 08             	sub    $0x8,%esp
f010106c:	0f be c0             	movsbl %al,%eax
f010106f:	50                   	push   %eax
f0101070:	57                   	push   %edi
f0101071:	e8 75 46 00 00       	call   f01056eb <strchr>
f0101076:	83 c4 10             	add    $0x10,%esp
f0101079:	85 c0                	test   %eax,%eax
f010107b:	74 08                	je     f0101085 <monitor+0x69>
			*buf++ = 0;
f010107d:	c6 06 00             	movb   $0x0,(%esi)
f0101080:	8d 76 01             	lea    0x1(%esi),%esi
f0101083:	eb 79                	jmp    f01010fe <monitor+0xe2>
		if (*buf == 0)
f0101085:	80 3e 00             	cmpb   $0x0,(%esi)
f0101088:	74 7f                	je     f0101109 <monitor+0xed>
		if (argc == MAXARGS-1) {
f010108a:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f010108e:	74 0f                	je     f010109f <monitor+0x83>
		argv[argc++] = buf;
f0101090:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0101093:	8d 48 01             	lea    0x1(%eax),%ecx
f0101096:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0101099:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f010109d:	eb 44                	jmp    f01010e3 <monitor+0xc7>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010109f:	83 ec 08             	sub    $0x8,%esp
f01010a2:	6a 10                	push   $0x10
f01010a4:	8d 83 71 7d f7 ff    	lea    -0x8828f(%ebx),%eax
f01010aa:	50                   	push   %eax
f01010ab:	e8 8f 31 00 00       	call   f010423f <cprintf>
f01010b0:	83 c4 10             	add    $0x10,%esp
	while (1) {
		buf = readline("K> ");
f01010b3:	8d 83 68 7d f7 ff    	lea    -0x88298(%ebx),%eax
f01010b9:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01010bc:	83 ec 0c             	sub    $0xc,%esp
f01010bf:	ff 75 a4             	pushl  -0x5c(%ebp)
f01010c2:	e8 ec 43 00 00       	call   f01054b3 <readline>
f01010c7:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01010c9:	83 c4 10             	add    $0x10,%esp
f01010cc:	85 c0                	test   %eax,%eax
f01010ce:	74 ec                	je     f01010bc <monitor+0xa0>
	argv[argc] = 0;
f01010d0:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01010d7:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f01010de:	eb 1e                	jmp    f01010fe <monitor+0xe2>
			buf++;
f01010e0:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01010e3:	0f b6 06             	movzbl (%esi),%eax
f01010e6:	84 c0                	test   %al,%al
f01010e8:	74 14                	je     f01010fe <monitor+0xe2>
f01010ea:	83 ec 08             	sub    $0x8,%esp
f01010ed:	0f be c0             	movsbl %al,%eax
f01010f0:	50                   	push   %eax
f01010f1:	57                   	push   %edi
f01010f2:	e8 f4 45 00 00       	call   f01056eb <strchr>
f01010f7:	83 c4 10             	add    $0x10,%esp
f01010fa:	85 c0                	test   %eax,%eax
f01010fc:	74 e2                	je     f01010e0 <monitor+0xc4>
		while (*buf && strchr(WHITESPACE, *buf))
f01010fe:	0f b6 06             	movzbl (%esi),%eax
f0101101:	84 c0                	test   %al,%al
f0101103:	0f 85 60 ff ff ff    	jne    f0101069 <monitor+0x4d>
	argv[argc] = 0;
f0101109:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010110c:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0101113:	00 
	if (argc == 0)
f0101114:	85 c0                	test   %eax,%eax
f0101116:	74 9b                	je     f01010b3 <monitor+0x97>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0101118:	be 00 00 00 00       	mov    $0x0,%esi
		if (strcmp(argv[0], commands[i].name) == 0)
f010111d:	83 ec 08             	sub    $0x8,%esp
f0101120:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0101123:	ff b4 83 48 1e 00 00 	pushl  0x1e48(%ebx,%eax,4)
f010112a:	ff 75 a8             	pushl  -0x58(%ebp)
f010112d:	e8 5b 45 00 00       	call   f010568d <strcmp>
f0101132:	83 c4 10             	add    $0x10,%esp
f0101135:	85 c0                	test   %eax,%eax
f0101137:	74 22                	je     f010115b <monitor+0x13f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0101139:	83 c6 01             	add    $0x1,%esi
f010113c:	83 fe 07             	cmp    $0x7,%esi
f010113f:	75 dc                	jne    f010111d <monitor+0x101>
	cprintf("Unknown command '%s'\n", argv[0]);
f0101141:	83 ec 08             	sub    $0x8,%esp
f0101144:	ff 75 a8             	pushl  -0x58(%ebp)
f0101147:	8d 83 8e 7d f7 ff    	lea    -0x88272(%ebx),%eax
f010114d:	50                   	push   %eax
f010114e:	e8 ec 30 00 00       	call   f010423f <cprintf>
f0101153:	83 c4 10             	add    $0x10,%esp
f0101156:	e9 58 ff ff ff       	jmp    f01010b3 <monitor+0x97>
			return commands[i].func(argc, argv, tf);
f010115b:	83 ec 04             	sub    $0x4,%esp
f010115e:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0101161:	ff 75 08             	pushl  0x8(%ebp)
f0101164:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0101167:	52                   	push   %edx
f0101168:	ff 75 a4             	pushl  -0x5c(%ebp)
f010116b:	ff 94 83 50 1e 00 00 	call   *0x1e50(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0101172:	83 c4 10             	add    $0x10,%esp
f0101175:	85 c0                	test   %eax,%eax
f0101177:	0f 89 36 ff ff ff    	jns    f01010b3 <monitor+0x97>
				break;
	}
}
f010117d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101180:	5b                   	pop    %ebx
f0101181:	5e                   	pop    %esi
f0101182:	5f                   	pop    %edi
f0101183:	5d                   	pop    %ebp
f0101184:	c3                   	ret    

f0101185 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101185:	55                   	push   %ebp
f0101186:	89 e5                	mov    %esp,%ebp
f0101188:	57                   	push   %edi
f0101189:	56                   	push   %esi
f010118a:	53                   	push   %ebx
f010118b:	83 ec 18             	sub    $0x18,%esp
f010118e:	e8 d4 ef ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101193:	81 c3 65 d0 08 00    	add    $0x8d065,%ebx
f0101199:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010119b:	50                   	push   %eax
f010119c:	e8 17 30 00 00       	call   f01041b8 <mc146818_read>
f01011a1:	89 c6                	mov    %eax,%esi
f01011a3:	83 c7 01             	add    $0x1,%edi
f01011a6:	89 3c 24             	mov    %edi,(%esp)
f01011a9:	e8 0a 30 00 00       	call   f01041b8 <mc146818_read>
f01011ae:	c1 e0 08             	shl    $0x8,%eax
f01011b1:	09 f0                	or     %esi,%eax
}
f01011b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011b6:	5b                   	pop    %ebx
f01011b7:	5e                   	pop    %esi
f01011b8:	5f                   	pop    %edi
f01011b9:	5d                   	pop    %ebp
f01011ba:	c3                   	ret    

f01011bb <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01011bb:	55                   	push   %ebp
f01011bc:	89 e5                	mov    %esp,%ebp
f01011be:	56                   	push   %esi
f01011bf:	53                   	push   %ebx
f01011c0:	e8 f2 27 00 00       	call   f01039b7 <__x86.get_pc_thunk.cx>
f01011c5:	81 c1 33 d0 08 00    	add    $0x8d033,%ecx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01011cb:	83 b9 60 21 00 00 00 	cmpl   $0x0,0x2160(%ecx)
f01011d2:	74 37                	je     f010120b <boot_alloc+0x50>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f01011d4:	8b b1 60 21 00 00    	mov    0x2160(%ecx),%esi
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f01011da:	8d 94 06 ff 0f 00 00 	lea    0xfff(%esi,%eax,1),%edx
f01011e1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01011e7:	89 91 60 21 00 00    	mov    %edx,0x2160(%ecx)
	assert((uint32_t) nextfree - KERNBASE <= (npages * PGSIZE));
f01011ed:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01011f3:	c7 c0 28 10 19 f0    	mov    $0xf0191028,%eax
f01011f9:	8b 18                	mov    (%eax),%ebx
f01011fb:	c1 e3 0c             	shl    $0xc,%ebx
f01011fe:	39 da                	cmp    %ebx,%edx
f0101200:	77 23                	ja     f0101225 <boot_alloc+0x6a>
	return result;
}
f0101202:	89 f0                	mov    %esi,%eax
f0101204:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101207:	5b                   	pop    %ebx
f0101208:	5e                   	pop    %esi
f0101209:	5d                   	pop    %ebp
f010120a:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010120b:	c7 c2 20 10 19 f0    	mov    $0xf0191020,%edx
f0101211:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0101217:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010121d:	89 91 60 21 00 00    	mov    %edx,0x2160(%ecx)
f0101223:	eb af                	jmp    f01011d4 <boot_alloc+0x19>
	assert((uint32_t) nextfree - KERNBASE <= (npages * PGSIZE));
f0101225:	8d 81 84 81 f7 ff    	lea    -0x87e7c(%ecx),%eax
f010122b:	50                   	push   %eax
f010122c:	8d 81 74 7c f7 ff    	lea    -0x8838c(%ecx),%eax
f0101232:	50                   	push   %eax
f0101233:	6a 6c                	push   $0x6c
f0101235:	8d 81 75 89 f7 ff    	lea    -0x8768b(%ecx),%eax
f010123b:	50                   	push   %eax
f010123c:	89 cb                	mov    %ecx,%ebx
f010123e:	e8 6e ee ff ff       	call   f01000b1 <_panic>

f0101243 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101243:	55                   	push   %ebp
f0101244:	89 e5                	mov    %esp,%ebp
f0101246:	56                   	push   %esi
f0101247:	53                   	push   %ebx
f0101248:	e8 6a 27 00 00       	call   f01039b7 <__x86.get_pc_thunk.cx>
f010124d:	81 c1 ab cf 08 00    	add    $0x8cfab,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101253:	89 d3                	mov    %edx,%ebx
f0101255:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0101258:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f010125b:	a8 01                	test   $0x1,%al
f010125d:	74 5a                	je     f01012b9 <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010125f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101264:	89 c6                	mov    %eax,%esi
f0101266:	c1 ee 0c             	shr    $0xc,%esi
f0101269:	c7 c3 28 10 19 f0    	mov    $0xf0191028,%ebx
f010126f:	3b 33                	cmp    (%ebx),%esi
f0101271:	73 2b                	jae    f010129e <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0101273:	c1 ea 0c             	shr    $0xc,%edx
f0101276:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010127c:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101283:	89 c2                	mov    %eax,%edx
f0101285:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101288:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010128d:	85 d2                	test   %edx,%edx
f010128f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0101294:	0f 44 c2             	cmove  %edx,%eax
}
f0101297:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010129a:	5b                   	pop    %ebx
f010129b:	5e                   	pop    %esi
f010129c:	5d                   	pop    %ebp
f010129d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010129e:	50                   	push   %eax
f010129f:	8d 81 64 80 f7 ff    	lea    -0x87f9c(%ecx),%eax
f01012a5:	50                   	push   %eax
f01012a6:	68 50 03 00 00       	push   $0x350
f01012ab:	8d 81 75 89 f7 ff    	lea    -0x8768b(%ecx),%eax
f01012b1:	50                   	push   %eax
f01012b2:	89 cb                	mov    %ecx,%ebx
f01012b4:	e8 f8 ed ff ff       	call   f01000b1 <_panic>
		return ~0;
f01012b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01012be:	eb d7                	jmp    f0101297 <check_va2pa+0x54>

f01012c0 <check_page_free_list>:
{
f01012c0:	55                   	push   %ebp
f01012c1:	89 e5                	mov    %esp,%ebp
f01012c3:	57                   	push   %edi
f01012c4:	56                   	push   %esi
f01012c5:	53                   	push   %ebx
f01012c6:	83 ec 3c             	sub    $0x3c,%esp
f01012c9:	e8 f1 26 00 00       	call   f01039bf <__x86.get_pc_thunk.di>
f01012ce:	81 c7 2a cf 08 00    	add    $0x8cf2a,%edi
f01012d4:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012d7:	84 c0                	test   %al,%al
f01012d9:	0f 85 dd 02 00 00    	jne    f01015bc <check_page_free_list+0x2fc>
	if (!page_free_list)
f01012df:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01012e2:	83 b8 68 21 00 00 00 	cmpl   $0x0,0x2168(%eax)
f01012e9:	74 0c                	je     f01012f7 <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01012eb:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f01012f2:	e9 2f 03 00 00       	jmp    f0101626 <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f01012f7:	83 ec 04             	sub    $0x4,%esp
f01012fa:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01012fd:	8d 83 b8 81 f7 ff    	lea    -0x87e48(%ebx),%eax
f0101303:	50                   	push   %eax
f0101304:	68 88 02 00 00       	push   $0x288
f0101309:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010130f:	50                   	push   %eax
f0101310:	e8 9c ed ff ff       	call   f01000b1 <_panic>
f0101315:	50                   	push   %eax
f0101316:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101319:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f010131f:	50                   	push   %eax
f0101320:	6a 56                	push   $0x56
f0101322:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f0101328:	50                   	push   %eax
f0101329:	e8 83 ed ff ff       	call   f01000b1 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010132e:	8b 36                	mov    (%esi),%esi
f0101330:	85 f6                	test   %esi,%esi
f0101332:	74 40                	je     f0101374 <check_page_free_list+0xb4>
	return (pp - pages) << PGSHIFT;
f0101334:	89 f0                	mov    %esi,%eax
f0101336:	2b 07                	sub    (%edi),%eax
f0101338:	c1 f8 03             	sar    $0x3,%eax
f010133b:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010133e:	89 c2                	mov    %eax,%edx
f0101340:	c1 ea 16             	shr    $0x16,%edx
f0101343:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101346:	73 e6                	jae    f010132e <check_page_free_list+0x6e>
	if (PGNUM(pa) >= npages)
f0101348:	89 c2                	mov    %eax,%edx
f010134a:	c1 ea 0c             	shr    $0xc,%edx
f010134d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101350:	3b 11                	cmp    (%ecx),%edx
f0101352:	73 c1                	jae    f0101315 <check_page_free_list+0x55>
			memset(page2kva(pp), 0x97, 128);
f0101354:	83 ec 04             	sub    $0x4,%esp
f0101357:	68 80 00 00 00       	push   $0x80
f010135c:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101361:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101366:	50                   	push   %eax
f0101367:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010136a:	e8 b9 43 00 00       	call   f0105728 <memset>
f010136f:	83 c4 10             	add    $0x10,%esp
f0101372:	eb ba                	jmp    f010132e <check_page_free_list+0x6e>
	first_free_page = (char *) boot_alloc(0);
f0101374:	b8 00 00 00 00       	mov    $0x0,%eax
f0101379:	e8 3d fe ff ff       	call   f01011bb <boot_alloc>
f010137e:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101381:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0101384:	8b 97 68 21 00 00    	mov    0x2168(%edi),%edx
		assert(pp >= pages);
f010138a:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0101390:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0101392:	c7 c0 28 10 19 f0    	mov    $0xf0191028,%eax
f0101398:	8b 00                	mov    (%eax),%eax
f010139a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010139d:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01013a0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f01013a3:	bf 00 00 00 00       	mov    $0x0,%edi
f01013a8:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01013ab:	e9 08 01 00 00       	jmp    f01014b8 <check_page_free_list+0x1f8>
		assert(pp >= pages);
f01013b0:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01013b3:	8d 83 8f 89 f7 ff    	lea    -0x87671(%ebx),%eax
f01013b9:	50                   	push   %eax
f01013ba:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01013c0:	50                   	push   %eax
f01013c1:	68 a2 02 00 00       	push   $0x2a2
f01013c6:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01013cc:	50                   	push   %eax
f01013cd:	e8 df ec ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f01013d2:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01013d5:	8d 83 9b 89 f7 ff    	lea    -0x87665(%ebx),%eax
f01013db:	50                   	push   %eax
f01013dc:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01013e2:	50                   	push   %eax
f01013e3:	68 a3 02 00 00       	push   $0x2a3
f01013e8:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01013ee:	50                   	push   %eax
f01013ef:	e8 bd ec ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01013f4:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01013f7:	8d 83 dc 81 f7 ff    	lea    -0x87e24(%ebx),%eax
f01013fd:	50                   	push   %eax
f01013fe:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101404:	50                   	push   %eax
f0101405:	68 a4 02 00 00       	push   $0x2a4
f010140a:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101410:	50                   	push   %eax
f0101411:	e8 9b ec ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0101416:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101419:	8d 83 af 89 f7 ff    	lea    -0x87651(%ebx),%eax
f010141f:	50                   	push   %eax
f0101420:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101426:	50                   	push   %eax
f0101427:	68 a7 02 00 00       	push   $0x2a7
f010142c:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101432:	50                   	push   %eax
f0101433:	e8 79 ec ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101438:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010143b:	8d 83 c0 89 f7 ff    	lea    -0x87640(%ebx),%eax
f0101441:	50                   	push   %eax
f0101442:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101448:	50                   	push   %eax
f0101449:	68 a8 02 00 00       	push   $0x2a8
f010144e:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101454:	50                   	push   %eax
f0101455:	e8 57 ec ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010145a:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010145d:	8d 83 10 82 f7 ff    	lea    -0x87df0(%ebx),%eax
f0101463:	50                   	push   %eax
f0101464:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010146a:	50                   	push   %eax
f010146b:	68 a9 02 00 00       	push   $0x2a9
f0101470:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101476:	50                   	push   %eax
f0101477:	e8 35 ec ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010147c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010147f:	8d 83 d9 89 f7 ff    	lea    -0x87627(%ebx),%eax
f0101485:	50                   	push   %eax
f0101486:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010148c:	50                   	push   %eax
f010148d:	68 aa 02 00 00       	push   $0x2aa
f0101492:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101498:	50                   	push   %eax
f0101499:	e8 13 ec ff ff       	call   f01000b1 <_panic>
	if (PGNUM(pa) >= npages)
f010149e:	89 c6                	mov    %eax,%esi
f01014a0:	c1 ee 0c             	shr    $0xc,%esi
f01014a3:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f01014a6:	76 70                	jbe    f0101518 <check_page_free_list+0x258>
	return (void *)(pa + KERNBASE);
f01014a8:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01014ad:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f01014b0:	77 7f                	ja     f0101531 <check_page_free_list+0x271>
			++nfree_extmem;
f01014b2:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01014b6:	8b 12                	mov    (%edx),%edx
f01014b8:	85 d2                	test   %edx,%edx
f01014ba:	0f 84 93 00 00 00    	je     f0101553 <check_page_free_list+0x293>
		assert(pp >= pages);
f01014c0:	39 d1                	cmp    %edx,%ecx
f01014c2:	0f 87 e8 fe ff ff    	ja     f01013b0 <check_page_free_list+0xf0>
		assert(pp < pages + npages);
f01014c8:	39 d3                	cmp    %edx,%ebx
f01014ca:	0f 86 02 ff ff ff    	jbe    f01013d2 <check_page_free_list+0x112>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01014d0:	89 d0                	mov    %edx,%eax
f01014d2:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f01014d5:	a8 07                	test   $0x7,%al
f01014d7:	0f 85 17 ff ff ff    	jne    f01013f4 <check_page_free_list+0x134>
	return (pp - pages) << PGSHIFT;
f01014dd:	c1 f8 03             	sar    $0x3,%eax
f01014e0:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f01014e3:	85 c0                	test   %eax,%eax
f01014e5:	0f 84 2b ff ff ff    	je     f0101416 <check_page_free_list+0x156>
		assert(page2pa(pp) != IOPHYSMEM);
f01014eb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01014f0:	0f 84 42 ff ff ff    	je     f0101438 <check_page_free_list+0x178>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01014f6:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01014fb:	0f 84 59 ff ff ff    	je     f010145a <check_page_free_list+0x19a>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101501:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101506:	0f 84 70 ff ff ff    	je     f010147c <check_page_free_list+0x1bc>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010150c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101511:	77 8b                	ja     f010149e <check_page_free_list+0x1de>
			++nfree_basemem;
f0101513:	83 c7 01             	add    $0x1,%edi
f0101516:	eb 9e                	jmp    f01014b6 <check_page_free_list+0x1f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101518:	50                   	push   %eax
f0101519:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010151c:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f0101522:	50                   	push   %eax
f0101523:	6a 56                	push   $0x56
f0101525:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f010152b:	50                   	push   %eax
f010152c:	e8 80 eb ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101531:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101534:	8d 83 34 82 f7 ff    	lea    -0x87dcc(%ebx),%eax
f010153a:	50                   	push   %eax
f010153b:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101541:	50                   	push   %eax
f0101542:	68 ab 02 00 00       	push   $0x2ab
f0101547:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010154d:	50                   	push   %eax
f010154e:	e8 5e eb ff ff       	call   f01000b1 <_panic>
f0101553:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0101556:	85 ff                	test   %edi,%edi
f0101558:	7e 1e                	jle    f0101578 <check_page_free_list+0x2b8>
	assert(nfree_extmem > 0);
f010155a:	85 f6                	test   %esi,%esi
f010155c:	7e 3c                	jle    f010159a <check_page_free_list+0x2da>
	cprintf("check_page_free_list() succeeded!\n");
f010155e:	83 ec 0c             	sub    $0xc,%esp
f0101561:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101564:	8d 83 7c 82 f7 ff    	lea    -0x87d84(%ebx),%eax
f010156a:	50                   	push   %eax
f010156b:	e8 cf 2c 00 00       	call   f010423f <cprintf>
}
f0101570:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101573:	5b                   	pop    %ebx
f0101574:	5e                   	pop    %esi
f0101575:	5f                   	pop    %edi
f0101576:	5d                   	pop    %ebp
f0101577:	c3                   	ret    
	assert(nfree_basemem > 0);
f0101578:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010157b:	8d 83 f3 89 f7 ff    	lea    -0x8760d(%ebx),%eax
f0101581:	50                   	push   %eax
f0101582:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101588:	50                   	push   %eax
f0101589:	68 b3 02 00 00       	push   $0x2b3
f010158e:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101594:	50                   	push   %eax
f0101595:	e8 17 eb ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f010159a:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010159d:	8d 83 05 8a f7 ff    	lea    -0x875fb(%ebx),%eax
f01015a3:	50                   	push   %eax
f01015a4:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01015aa:	50                   	push   %eax
f01015ab:	68 b4 02 00 00       	push   $0x2b4
f01015b0:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01015b6:	50                   	push   %eax
f01015b7:	e8 f5 ea ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f01015bc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01015bf:	8b 80 68 21 00 00    	mov    0x2168(%eax),%eax
f01015c5:	85 c0                	test   %eax,%eax
f01015c7:	0f 84 2a fd ff ff    	je     f01012f7 <check_page_free_list+0x37>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01015cd:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01015d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01015d3:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01015d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f01015d9:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01015dc:	c7 c3 30 10 19 f0    	mov    $0xf0191030,%ebx
f01015e2:	89 c2                	mov    %eax,%edx
f01015e4:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01015e6:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01015ec:	0f 95 c2             	setne  %dl
f01015ef:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01015f2:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01015f6:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01015f8:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01015fc:	8b 00                	mov    (%eax),%eax
f01015fe:	85 c0                	test   %eax,%eax
f0101600:	75 e0                	jne    f01015e2 <check_page_free_list+0x322>
		*tp[1] = 0;
f0101602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101605:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010160b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010160e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101611:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101613:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101616:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0101619:	89 87 68 21 00 00    	mov    %eax,0x2168(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010161f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101626:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0101629:	8b b0 68 21 00 00    	mov    0x2168(%eax),%esi
f010162f:	c7 c7 30 10 19 f0    	mov    $0xf0191030,%edi
	if (PGNUM(pa) >= npages)
f0101635:	c7 c0 28 10 19 f0    	mov    $0xf0191028,%eax
f010163b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010163e:	e9 ed fc ff ff       	jmp    f0101330 <check_page_free_list+0x70>

f0101643 <page_init>:
{
f0101643:	55                   	push   %ebp
f0101644:	89 e5                	mov    %esp,%ebp
f0101646:	57                   	push   %edi
f0101647:	56                   	push   %esi
f0101648:	53                   	push   %ebx
f0101649:	83 ec 1c             	sub    $0x1c,%esp
f010164c:	e8 6a 23 00 00       	call   f01039bb <__x86.get_pc_thunk.si>
f0101651:	81 c6 a7 cb 08 00    	add    $0x8cba7,%esi
f0101657:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	npages_basemem = nvram_read(NVRAM_BASELO) / (PGSIZE / 1024);
f010165a:	b8 15 00 00 00       	mov    $0x15,%eax
f010165f:	e8 21 fb ff ff       	call   f0101185 <nvram_read>
f0101664:	8d 50 03             	lea    0x3(%eax),%edx
f0101667:	85 c0                	test   %eax,%eax
f0101669:	0f 48 c2             	cmovs  %edx,%eax
f010166c:	c1 f8 02             	sar    $0x2,%eax
f010166f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	ext_allocated = ((size_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f0101672:	b8 00 00 00 00       	mov    $0x0,%eax
f0101677:	e8 3f fb ff ff       	call   f01011bb <boot_alloc>
f010167c:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0101682:	c1 ef 0c             	shr    $0xc,%edi
	pages[0].pp_ref = 1;
f0101685:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f010168b:	8b 00                	mov    (%eax),%eax
f010168d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f0101693:	8b 9e 68 21 00 00    	mov    0x2168(%esi),%ebx
	for (i = 1; i < npages_basemem; i++)
f0101699:	b8 00 00 00 00       	mov    $0x0,%eax
f010169e:	ba 01 00 00 00       	mov    $0x1,%edx
		pages[i].pp_ref = 0;
f01016a3:	c7 c6 30 10 19 f0    	mov    $0xf0191030,%esi
f01016a9:	89 7d dc             	mov    %edi,-0x24(%ebp)
f01016ac:	8b 7d e0             	mov    -0x20(%ebp),%edi
	for (i = 1; i < npages_basemem; i++)
f01016af:	eb 1f                	jmp    f01016d0 <page_init+0x8d>
		pages[i].pp_ref = 0;
f01016b1:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01016b8:	89 c1                	mov    %eax,%ecx
f01016ba:	03 0e                	add    (%esi),%ecx
f01016bc:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01016c2:	89 19                	mov    %ebx,(%ecx)
	for (i = 1; i < npages_basemem; i++)
f01016c4:	83 c2 01             	add    $0x1,%edx
		page_free_list = &pages[i];
f01016c7:	03 06                	add    (%esi),%eax
f01016c9:	89 c3                	mov    %eax,%ebx
f01016cb:	b8 01 00 00 00       	mov    $0x1,%eax
	for (i = 1; i < npages_basemem; i++)
f01016d0:	39 fa                	cmp    %edi,%edx
f01016d2:	72 dd                	jb     f01016b1 <page_init+0x6e>
f01016d4:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01016d7:	84 c0                	test   %al,%al
f01016d9:	75 12                	jne    f01016ed <page_init+0xaa>
		pages[i].pp_ref = 1;
f01016db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01016de:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f01016e4:	8b 08                	mov    (%eax),%ecx
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE + ext_allocated; i++)
f01016e6:	ba a0 00 00 00       	mov    $0xa0,%edx
f01016eb:	eb 15                	jmp    f0101702 <page_init+0xbf>
f01016ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01016f0:	89 98 68 21 00 00    	mov    %ebx,0x2168(%eax)
f01016f6:	eb e3                	jmp    f01016db <page_init+0x98>
		pages[i].pp_ref = 1;
f01016f8:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE + ext_allocated; i++)
f01016ff:	83 c2 01             	add    $0x1,%edx
f0101702:	8d 87 00 01 00 00    	lea    0x100(%edi),%eax
f0101708:	39 d0                	cmp    %edx,%eax
f010170a:	77 ec                	ja     f01016f8 <page_init+0xb5>
f010170c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010170f:	8b 9e 68 21 00 00    	mov    0x2168(%esi),%ebx
f0101715:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010171c:	b9 00 00 00 00       	mov    $0x0,%ecx
	for (i = EXTPHYSMEM / PGSIZE + ext_allocated; i < npages; i++)
f0101721:	c7 c7 28 10 19 f0    	mov    $0xf0191028,%edi
		pages[i].pp_ref = 0;
f0101727:	c7 c6 30 10 19 f0    	mov    $0xf0191030,%esi
f010172d:	eb 1b                	jmp    f010174a <page_init+0x107>
f010172f:	89 d1                	mov    %edx,%ecx
f0101731:	03 0e                	add    (%esi),%ecx
f0101733:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101739:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f010173b:	89 d3                	mov    %edx,%ebx
f010173d:	03 1e                	add    (%esi),%ebx
	for (i = EXTPHYSMEM / PGSIZE + ext_allocated; i < npages; i++)
f010173f:	83 c0 01             	add    $0x1,%eax
f0101742:	83 c2 08             	add    $0x8,%edx
f0101745:	b9 01 00 00 00       	mov    $0x1,%ecx
f010174a:	39 07                	cmp    %eax,(%edi)
f010174c:	77 e1                	ja     f010172f <page_init+0xec>
f010174e:	84 c9                	test   %cl,%cl
f0101750:	75 08                	jne    f010175a <page_init+0x117>
}
f0101752:	83 c4 1c             	add    $0x1c,%esp
f0101755:	5b                   	pop    %ebx
f0101756:	5e                   	pop    %esi
f0101757:	5f                   	pop    %edi
f0101758:	5d                   	pop    %ebp
f0101759:	c3                   	ret    
f010175a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010175d:	89 98 68 21 00 00    	mov    %ebx,0x2168(%eax)
f0101763:	eb ed                	jmp    f0101752 <page_init+0x10f>

f0101765 <page_alloc>:
{
f0101765:	55                   	push   %ebp
f0101766:	89 e5                	mov    %esp,%ebp
f0101768:	56                   	push   %esi
f0101769:	53                   	push   %ebx
f010176a:	e8 f8 e9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010176f:	81 c3 89 ca 08 00    	add    $0x8ca89,%ebx
	if (!page_free_list)
f0101775:	8b b3 68 21 00 00    	mov    0x2168(%ebx),%esi
f010177b:	85 f6                	test   %esi,%esi
f010177d:	74 14                	je     f0101793 <page_alloc+0x2e>
	page_free_list = page_free_list->pp_link;
f010177f:	8b 06                	mov    (%esi),%eax
f0101781:	89 83 68 21 00 00    	mov    %eax,0x2168(%ebx)
	page->pp_link = NULL;
f0101787:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO)
f010178d:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101791:	75 09                	jne    f010179c <page_alloc+0x37>
}
f0101793:	89 f0                	mov    %esi,%eax
f0101795:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101798:	5b                   	pop    %ebx
f0101799:	5e                   	pop    %esi
f010179a:	5d                   	pop    %ebp
f010179b:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f010179c:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f01017a2:	89 f2                	mov    %esi,%edx
f01017a4:	2b 10                	sub    (%eax),%edx
f01017a6:	89 d0                	mov    %edx,%eax
f01017a8:	c1 f8 03             	sar    $0x3,%eax
f01017ab:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01017ae:	89 c1                	mov    %eax,%ecx
f01017b0:	c1 e9 0c             	shr    $0xc,%ecx
f01017b3:	c7 c2 28 10 19 f0    	mov    $0xf0191028,%edx
f01017b9:	3b 0a                	cmp    (%edx),%ecx
f01017bb:	73 1a                	jae    f01017d7 <page_alloc+0x72>
		memset(page2kva(page), 0, PGSIZE);
f01017bd:	83 ec 04             	sub    $0x4,%esp
f01017c0:	68 00 10 00 00       	push   $0x1000
f01017c5:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01017c7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017cc:	50                   	push   %eax
f01017cd:	e8 56 3f 00 00       	call   f0105728 <memset>
f01017d2:	83 c4 10             	add    $0x10,%esp
f01017d5:	eb bc                	jmp    f0101793 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017d7:	50                   	push   %eax
f01017d8:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f01017de:	50                   	push   %eax
f01017df:	6a 56                	push   $0x56
f01017e1:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f01017e7:	50                   	push   %eax
f01017e8:	e8 c4 e8 ff ff       	call   f01000b1 <_panic>

f01017ed <page_free>:
{
f01017ed:	55                   	push   %ebp
f01017ee:	89 e5                	mov    %esp,%ebp
f01017f0:	53                   	push   %ebx
f01017f1:	83 ec 04             	sub    $0x4,%esp
f01017f4:	e8 6e e9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01017f9:	81 c3 ff c9 08 00    	add    $0x8c9ff,%ebx
f01017ff:	8b 45 08             	mov    0x8(%ebp),%eax
	assert(pp->pp_ref == 0);
f0101802:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101807:	75 18                	jne    f0101821 <page_free+0x34>
	assert(!pp->pp_link);
f0101809:	83 38 00             	cmpl   $0x0,(%eax)
f010180c:	75 32                	jne    f0101840 <page_free+0x53>
	pp->pp_link = page_free_list;
f010180e:	8b 8b 68 21 00 00    	mov    0x2168(%ebx),%ecx
f0101814:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f0101816:	89 83 68 21 00 00    	mov    %eax,0x2168(%ebx)
}
f010181c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010181f:	c9                   	leave  
f0101820:	c3                   	ret    
	assert(pp->pp_ref == 0);
f0101821:	8d 83 16 8a f7 ff    	lea    -0x875ea(%ebx),%eax
f0101827:	50                   	push   %eax
f0101828:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010182e:	50                   	push   %eax
f010182f:	68 69 01 00 00       	push   $0x169
f0101834:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010183a:	50                   	push   %eax
f010183b:	e8 71 e8 ff ff       	call   f01000b1 <_panic>
	assert(!pp->pp_link);
f0101840:	8d 83 26 8a f7 ff    	lea    -0x875da(%ebx),%eax
f0101846:	50                   	push   %eax
f0101847:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010184d:	50                   	push   %eax
f010184e:	68 6a 01 00 00       	push   $0x16a
f0101853:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101859:	50                   	push   %eax
f010185a:	e8 52 e8 ff ff       	call   f01000b1 <_panic>

f010185f <page_decref>:
{
f010185f:	55                   	push   %ebp
f0101860:	89 e5                	mov    %esp,%ebp
f0101862:	83 ec 08             	sub    $0x8,%esp
f0101865:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101868:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010186c:	83 e8 01             	sub    $0x1,%eax
f010186f:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101873:	66 85 c0             	test   %ax,%ax
f0101876:	74 02                	je     f010187a <page_decref+0x1b>
}
f0101878:	c9                   	leave  
f0101879:	c3                   	ret    
		page_free(pp);
f010187a:	83 ec 0c             	sub    $0xc,%esp
f010187d:	52                   	push   %edx
f010187e:	e8 6a ff ff ff       	call   f01017ed <page_free>
f0101883:	83 c4 10             	add    $0x10,%esp
}
f0101886:	eb f0                	jmp    f0101878 <page_decref+0x19>

f0101888 <pgdir_walk>:
{
f0101888:	55                   	push   %ebp
f0101889:	89 e5                	mov    %esp,%ebp
f010188b:	57                   	push   %edi
f010188c:	56                   	push   %esi
f010188d:	53                   	push   %ebx
f010188e:	83 ec 0c             	sub    $0xc,%esp
f0101891:	e8 d1 e8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101896:	81 c3 62 c9 08 00    	add    $0x8c962,%ebx
f010189c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pde = &pgdir[PDX(va)];
f010189f:	89 fe                	mov    %edi,%esi
f01018a1:	c1 ee 16             	shr    $0x16,%esi
f01018a4:	c1 e6 02             	shl    $0x2,%esi
f01018a7:	03 75 08             	add    0x8(%ebp),%esi
	if (!(*pde & PTE_P))
f01018aa:	f6 06 01             	testb  $0x1,(%esi)
f01018ad:	75 2f                	jne    f01018de <pgdir_walk+0x56>
		if (create)
f01018af:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01018b3:	74 70                	je     f0101925 <pgdir_walk+0x9d>
			page = page_alloc(1);
f01018b5:	83 ec 0c             	sub    $0xc,%esp
f01018b8:	6a 01                	push   $0x1
f01018ba:	e8 a6 fe ff ff       	call   f0101765 <page_alloc>
			if (!page)
f01018bf:	83 c4 10             	add    $0x10,%esp
f01018c2:	85 c0                	test   %eax,%eax
f01018c4:	74 66                	je     f010192c <pgdir_walk+0xa4>
			page->pp_ref++;
f01018c6:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01018cb:	c7 c2 30 10 19 f0    	mov    $0xf0191030,%edx
f01018d1:	2b 02                	sub    (%edx),%eax
f01018d3:	c1 f8 03             	sar    $0x3,%eax
f01018d6:	c1 e0 0c             	shl    $0xc,%eax
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f01018d9:	83 c8 07             	or     $0x7,%eax
f01018dc:	89 06                	mov    %eax,(%esi)
	page_base = KADDR(PTE_ADDR(*pde));
f01018de:	8b 06                	mov    (%esi),%eax
f01018e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01018e5:	89 c1                	mov    %eax,%ecx
f01018e7:	c1 e9 0c             	shr    $0xc,%ecx
f01018ea:	c7 c2 28 10 19 f0    	mov    $0xf0191028,%edx
f01018f0:	3b 0a                	cmp    (%edx),%ecx
f01018f2:	73 18                	jae    f010190c <pgdir_walk+0x84>
	page_off = PTX(va);
f01018f4:	c1 ef 0a             	shr    $0xa,%edi
	return &page_base[page_off];
f01018f7:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f01018fd:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
}
f0101904:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101907:	5b                   	pop    %ebx
f0101908:	5e                   	pop    %esi
f0101909:	5f                   	pop    %edi
f010190a:	5d                   	pop    %ebp
f010190b:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010190c:	50                   	push   %eax
f010190d:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f0101913:	50                   	push   %eax
f0101914:	68 ab 01 00 00       	push   $0x1ab
f0101919:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010191f:	50                   	push   %eax
f0101920:	e8 8c e7 ff ff       	call   f01000b1 <_panic>
			return NULL;
f0101925:	b8 00 00 00 00       	mov    $0x0,%eax
f010192a:	eb d8                	jmp    f0101904 <pgdir_walk+0x7c>
				return NULL;
f010192c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101931:	eb d1                	jmp    f0101904 <pgdir_walk+0x7c>

f0101933 <boot_map_region>:
{
f0101933:	55                   	push   %ebp
f0101934:	89 e5                	mov    %esp,%ebp
f0101936:	57                   	push   %edi
f0101937:	56                   	push   %esi
f0101938:	53                   	push   %ebx
f0101939:	83 ec 1c             	sub    $0x1c,%esp
f010193c:	89 c7                	mov    %eax,%edi
f010193e:	89 d6                	mov    %edx,%esi
f0101940:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0; i < size; i += PGSIZE)
f0101943:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pte = (pa + i) | perm | PTE_P;
f0101948:	8b 45 0c             	mov    0xc(%ebp),%eax
f010194b:	83 c8 01             	or     $0x1,%eax
f010194e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0; i < size; i += PGSIZE)
f0101951:	eb 22                	jmp    f0101975 <boot_map_region+0x42>
		pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f0101953:	83 ec 04             	sub    $0x4,%esp
f0101956:	6a 01                	push   $0x1
f0101958:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f010195b:	50                   	push   %eax
f010195c:	57                   	push   %edi
f010195d:	e8 26 ff ff ff       	call   f0101888 <pgdir_walk>
		*pte = (pa + i) | perm | PTE_P;
f0101962:	89 da                	mov    %ebx,%edx
f0101964:	03 55 08             	add    0x8(%ebp),%edx
f0101967:	0b 55 e0             	or     -0x20(%ebp),%edx
f010196a:	89 10                	mov    %edx,(%eax)
	for (i = 0; i < size; i += PGSIZE)
f010196c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101972:	83 c4 10             	add    $0x10,%esp
f0101975:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101978:	72 d9                	jb     f0101953 <boot_map_region+0x20>
}
f010197a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010197d:	5b                   	pop    %ebx
f010197e:	5e                   	pop    %esi
f010197f:	5f                   	pop    %edi
f0101980:	5d                   	pop    %ebp
f0101981:	c3                   	ret    

f0101982 <page_lookup>:
{
f0101982:	55                   	push   %ebp
f0101983:	89 e5                	mov    %esp,%ebp
f0101985:	56                   	push   %esi
f0101986:	53                   	push   %ebx
f0101987:	e8 db e7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010198c:	81 c3 6c c8 08 00    	add    $0x8c86c,%ebx
f0101992:	8b 75 10             	mov    0x10(%ebp),%esi
	pte = pgdir_walk(pgdir, va, 0);
f0101995:	83 ec 04             	sub    $0x4,%esp
f0101998:	6a 00                	push   $0x0
f010199a:	ff 75 0c             	pushl  0xc(%ebp)
f010199d:	ff 75 08             	pushl  0x8(%ebp)
f01019a0:	e8 e3 fe ff ff       	call   f0101888 <pgdir_walk>
	if (!pte)
f01019a5:	83 c4 10             	add    $0x10,%esp
f01019a8:	85 c0                	test   %eax,%eax
f01019aa:	74 3f                	je     f01019eb <page_lookup+0x69>
	if (pte_store)
f01019ac:	85 f6                	test   %esi,%esi
f01019ae:	74 02                	je     f01019b2 <page_lookup+0x30>
		*pte_store = pte;
f01019b0:	89 06                	mov    %eax,(%esi)
f01019b2:	8b 00                	mov    (%eax),%eax
f01019b4:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019b7:	c7 c2 28 10 19 f0    	mov    $0xf0191028,%edx
f01019bd:	39 02                	cmp    %eax,(%edx)
f01019bf:	76 12                	jbe    f01019d3 <page_lookup+0x51>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01019c1:	c7 c2 30 10 19 f0    	mov    $0xf0191030,%edx
f01019c7:	8b 12                	mov    (%edx),%edx
f01019c9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01019cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01019cf:	5b                   	pop    %ebx
f01019d0:	5e                   	pop    %esi
f01019d1:	5d                   	pop    %ebp
f01019d2:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01019d3:	83 ec 04             	sub    $0x4,%esp
f01019d6:	8d 83 a0 82 f7 ff    	lea    -0x87d60(%ebx),%eax
f01019dc:	50                   	push   %eax
f01019dd:	6a 4f                	push   $0x4f
f01019df:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f01019e5:	50                   	push   %eax
f01019e6:	e8 c6 e6 ff ff       	call   f01000b1 <_panic>
		return NULL;
f01019eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01019f0:	eb da                	jmp    f01019cc <page_lookup+0x4a>

f01019f2 <page_remove>:
{
f01019f2:	55                   	push   %ebp
f01019f3:	89 e5                	mov    %esp,%ebp
f01019f5:	53                   	push   %ebx
f01019f6:	83 ec 18             	sub    $0x18,%esp
f01019f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte = NULL;
f01019fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	page = page_lookup(pgdir, va, &pte);
f0101a03:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101a06:	50                   	push   %eax
f0101a07:	53                   	push   %ebx
f0101a08:	ff 75 08             	pushl  0x8(%ebp)
f0101a0b:	e8 72 ff ff ff       	call   f0101982 <page_lookup>
	if (!page)
f0101a10:	83 c4 10             	add    $0x10,%esp
f0101a13:	85 c0                	test   %eax,%eax
f0101a15:	74 15                	je     f0101a2c <page_remove+0x3a>
	page_decref(page);
f0101a17:	83 ec 0c             	sub    $0xc,%esp
f0101a1a:	50                   	push   %eax
f0101a1b:	e8 3f fe ff ff       	call   f010185f <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101a20:	0f 01 3b             	invlpg (%ebx)
	(*pte) &= perm;
f0101a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101a26:	83 20 fe             	andl   $0xfffffffe,(%eax)
	return;
f0101a29:	83 c4 10             	add    $0x10,%esp
}
f0101a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101a2f:	c9                   	leave  
f0101a30:	c3                   	ret    

f0101a31 <page_insert>:
{
f0101a31:	55                   	push   %ebp
f0101a32:	89 e5                	mov    %esp,%ebp
f0101a34:	57                   	push   %edi
f0101a35:	56                   	push   %esi
f0101a36:	53                   	push   %ebx
f0101a37:	83 ec 10             	sub    $0x10,%esp
f0101a3a:	e8 80 1f 00 00       	call   f01039bf <__x86.get_pc_thunk.di>
f0101a3f:	81 c7 b9 c7 08 00    	add    $0x8c7b9,%edi
f0101a45:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte = pgdir_walk(pgdir, va, 1);
f0101a48:	6a 01                	push   $0x1
f0101a4a:	ff 75 10             	pushl  0x10(%ebp)
f0101a4d:	ff 75 08             	pushl  0x8(%ebp)
f0101a50:	e8 33 fe ff ff       	call   f0101888 <pgdir_walk>
	if (!pte)
f0101a55:	83 c4 10             	add    $0x10,%esp
f0101a58:	85 c0                	test   %eax,%eax
f0101a5a:	74 46                	je     f0101aa2 <page_insert+0x71>
f0101a5c:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f0101a5e:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if ((*pte) & PTE_P)
f0101a63:	f6 00 01             	testb  $0x1,(%eax)
f0101a66:	75 27                	jne    f0101a8f <page_insert+0x5e>
	return (pp - pages) << PGSHIFT;
f0101a68:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0101a6e:	2b 30                	sub    (%eax),%esi
f0101a70:	89 f0                	mov    %esi,%eax
f0101a72:	c1 f8 03             	sar    $0x3,%eax
f0101a75:	c1 e0 0c             	shl    $0xc,%eax
	*pte = page2pa(pp) | perm | PTE_P;
f0101a78:	8b 55 14             	mov    0x14(%ebp),%edx
f0101a7b:	83 ca 01             	or     $0x1,%edx
f0101a7e:	09 d0                	or     %edx,%eax
f0101a80:	89 03                	mov    %eax,(%ebx)
	return 0;
f0101a82:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a87:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101a8a:	5b                   	pop    %ebx
f0101a8b:	5e                   	pop    %esi
f0101a8c:	5f                   	pop    %edi
f0101a8d:	5d                   	pop    %ebp
f0101a8e:	c3                   	ret    
		page_remove(pgdir, va);
f0101a8f:	83 ec 08             	sub    $0x8,%esp
f0101a92:	ff 75 10             	pushl  0x10(%ebp)
f0101a95:	ff 75 08             	pushl  0x8(%ebp)
f0101a98:	e8 55 ff ff ff       	call   f01019f2 <page_remove>
f0101a9d:	83 c4 10             	add    $0x10,%esp
f0101aa0:	eb c6                	jmp    f0101a68 <page_insert+0x37>
		return -E_NO_MEM;
f0101aa2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101aa7:	eb de                	jmp    f0101a87 <page_insert+0x56>

f0101aa9 <mem_init>:
{
f0101aa9:	55                   	push   %ebp
f0101aaa:	89 e5                	mov    %esp,%ebp
f0101aac:	57                   	push   %edi
f0101aad:	56                   	push   %esi
f0101aae:	53                   	push   %ebx
f0101aaf:	83 ec 3c             	sub    $0x3c,%esp
f0101ab2:	e8 52 ec ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f0101ab7:	05 41 c7 08 00       	add    $0x8c741,%eax
f0101abc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f0101abf:	b8 15 00 00 00       	mov    $0x15,%eax
f0101ac4:	e8 bc f6 ff ff       	call   f0101185 <nvram_read>
f0101ac9:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101acb:	b8 17 00 00 00       	mov    $0x17,%eax
f0101ad0:	e8 b0 f6 ff ff       	call   f0101185 <nvram_read>
f0101ad5:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101ad7:	b8 34 00 00 00       	mov    $0x34,%eax
f0101adc:	e8 a4 f6 ff ff       	call   f0101185 <nvram_read>
f0101ae1:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101ae4:	85 c0                	test   %eax,%eax
f0101ae6:	0f 85 e8 00 00 00    	jne    f0101bd4 <mem_init+0x12b>
		totalmem = 1 * 1024 + extmem;
f0101aec:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101af2:	85 f6                	test   %esi,%esi
f0101af4:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101af7:	89 c1                	mov    %eax,%ecx
f0101af9:	c1 e9 02             	shr    $0x2,%ecx
f0101afc:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101aff:	c7 c2 28 10 19 f0    	mov    $0xf0191028,%edx
f0101b05:	89 0a                	mov    %ecx,(%edx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101b07:	89 c2                	mov    %eax,%edx
f0101b09:	29 da                	sub    %ebx,%edx
f0101b0b:	52                   	push   %edx
f0101b0c:	53                   	push   %ebx
f0101b0d:	50                   	push   %eax
f0101b0e:	8d 87 c0 82 f7 ff    	lea    -0x87d40(%edi),%eax
f0101b14:	50                   	push   %eax
f0101b15:	89 fb                	mov    %edi,%ebx
f0101b17:	e8 23 27 00 00       	call   f010423f <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101b1c:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101b21:	e8 95 f6 ff ff       	call   f01011bb <boot_alloc>
f0101b26:	c7 c6 2c 10 19 f0    	mov    $0xf019102c,%esi
f0101b2c:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f0101b2e:	83 c4 0c             	add    $0xc,%esp
f0101b31:	68 00 10 00 00       	push   $0x1000
f0101b36:	6a 00                	push   $0x0
f0101b38:	50                   	push   %eax
f0101b39:	e8 ea 3b 00 00       	call   f0105728 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101b3e:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101b40:	83 c4 10             	add    $0x10,%esp
f0101b43:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101b48:	0f 86 90 00 00 00    	jbe    f0101bde <mem_init+0x135>
	return (physaddr_t)kva - KERNBASE;
f0101b4e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101b54:	83 ca 05             	or     $0x5,%edx
f0101b57:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101b5d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101b60:	c7 c3 28 10 19 f0    	mov    $0xf0191028,%ebx
f0101b66:	8b 03                	mov    (%ebx),%eax
f0101b68:	c1 e0 03             	shl    $0x3,%eax
f0101b6b:	e8 4b f6 ff ff       	call   f01011bb <boot_alloc>
f0101b70:	c7 c6 30 10 19 f0    	mov    $0xf0191030,%esi
f0101b76:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101b78:	83 ec 04             	sub    $0x4,%esp
f0101b7b:	8b 13                	mov    (%ebx),%edx
f0101b7d:	c1 e2 03             	shl    $0x3,%edx
f0101b80:	52                   	push   %edx
f0101b81:	6a 00                	push   $0x0
f0101b83:	50                   	push   %eax
f0101b84:	89 fb                	mov    %edi,%ebx
f0101b86:	e8 9d 3b 00 00       	call   f0105728 <memset>
	envs = boot_alloc(NENV * sizeof(struct Env));
f0101b8b:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101b90:	e8 26 f6 ff ff       	call   f01011bb <boot_alloc>
f0101b95:	c7 c2 68 03 19 f0    	mov    $0xf0190368,%edx
f0101b9b:	89 02                	mov    %eax,(%edx)
	memset(envs, 0, NENV * sizeof(struct Env));
f0101b9d:	83 c4 0c             	add    $0xc,%esp
f0101ba0:	68 00 80 01 00       	push   $0x18000
f0101ba5:	6a 00                	push   $0x0
f0101ba7:	50                   	push   %eax
f0101ba8:	e8 7b 3b 00 00       	call   f0105728 <memset>
	page_init();
f0101bad:	e8 91 fa ff ff       	call   f0101643 <page_init>
	check_page_free_list(1);
f0101bb2:	b8 01 00 00 00       	mov    $0x1,%eax
f0101bb7:	e8 04 f7 ff ff       	call   f01012c0 <check_page_free_list>
	if (!pages)
f0101bbc:	83 c4 10             	add    $0x10,%esp
f0101bbf:	83 3e 00             	cmpl   $0x0,(%esi)
f0101bc2:	74 36                	je     f0101bfa <mem_init+0x151>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101bc4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bc7:	8b 80 68 21 00 00    	mov    0x2168(%eax),%eax
f0101bcd:	be 00 00 00 00       	mov    $0x0,%esi
f0101bd2:	eb 49                	jmp    f0101c1d <mem_init+0x174>
		totalmem = 16 * 1024 + ext16mem;
f0101bd4:	05 00 40 00 00       	add    $0x4000,%eax
f0101bd9:	e9 19 ff ff ff       	jmp    f0101af7 <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101bde:	50                   	push   %eax
f0101bdf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101be2:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f0101be8:	50                   	push   %eax
f0101be9:	68 92 00 00 00       	push   $0x92
f0101bee:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101bf4:	50                   	push   %eax
f0101bf5:	e8 b7 e4 ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f0101bfa:	83 ec 04             	sub    $0x4,%esp
f0101bfd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c00:	8d 83 33 8a f7 ff    	lea    -0x875cd(%ebx),%eax
f0101c06:	50                   	push   %eax
f0101c07:	68 c7 02 00 00       	push   $0x2c7
f0101c0c:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101c12:	50                   	push   %eax
f0101c13:	e8 99 e4 ff ff       	call   f01000b1 <_panic>
		++nfree;
f0101c18:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101c1b:	8b 00                	mov    (%eax),%eax
f0101c1d:	85 c0                	test   %eax,%eax
f0101c1f:	75 f7                	jne    f0101c18 <mem_init+0x16f>
	assert((pp0 = page_alloc(0)));
f0101c21:	83 ec 0c             	sub    $0xc,%esp
f0101c24:	6a 00                	push   $0x0
f0101c26:	e8 3a fb ff ff       	call   f0101765 <page_alloc>
f0101c2b:	89 c3                	mov    %eax,%ebx
f0101c2d:	83 c4 10             	add    $0x10,%esp
f0101c30:	85 c0                	test   %eax,%eax
f0101c32:	0f 84 3b 02 00 00    	je     f0101e73 <mem_init+0x3ca>
	assert((pp1 = page_alloc(0)));
f0101c38:	83 ec 0c             	sub    $0xc,%esp
f0101c3b:	6a 00                	push   $0x0
f0101c3d:	e8 23 fb ff ff       	call   f0101765 <page_alloc>
f0101c42:	89 c7                	mov    %eax,%edi
f0101c44:	83 c4 10             	add    $0x10,%esp
f0101c47:	85 c0                	test   %eax,%eax
f0101c49:	0f 84 46 02 00 00    	je     f0101e95 <mem_init+0x3ec>
	assert((pp2 = page_alloc(0)));
f0101c4f:	83 ec 0c             	sub    $0xc,%esp
f0101c52:	6a 00                	push   $0x0
f0101c54:	e8 0c fb ff ff       	call   f0101765 <page_alloc>
f0101c59:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c5c:	83 c4 10             	add    $0x10,%esp
f0101c5f:	85 c0                	test   %eax,%eax
f0101c61:	0f 84 50 02 00 00    	je     f0101eb7 <mem_init+0x40e>
	assert(pp1 && pp1 != pp0);
f0101c67:	39 fb                	cmp    %edi,%ebx
f0101c69:	0f 84 6a 02 00 00    	je     f0101ed9 <mem_init+0x430>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c6f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c72:	39 c3                	cmp    %eax,%ebx
f0101c74:	0f 84 81 02 00 00    	je     f0101efb <mem_init+0x452>
f0101c7a:	39 c7                	cmp    %eax,%edi
f0101c7c:	0f 84 79 02 00 00    	je     f0101efb <mem_init+0x452>
	return (pp - pages) << PGSHIFT;
f0101c82:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c85:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0101c8b:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101c8d:	c7 c0 28 10 19 f0    	mov    $0xf0191028,%eax
f0101c93:	8b 10                	mov    (%eax),%edx
f0101c95:	c1 e2 0c             	shl    $0xc,%edx
f0101c98:	89 d8                	mov    %ebx,%eax
f0101c9a:	29 c8                	sub    %ecx,%eax
f0101c9c:	c1 f8 03             	sar    $0x3,%eax
f0101c9f:	c1 e0 0c             	shl    $0xc,%eax
f0101ca2:	39 d0                	cmp    %edx,%eax
f0101ca4:	0f 83 73 02 00 00    	jae    f0101f1d <mem_init+0x474>
f0101caa:	89 f8                	mov    %edi,%eax
f0101cac:	29 c8                	sub    %ecx,%eax
f0101cae:	c1 f8 03             	sar    $0x3,%eax
f0101cb1:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101cb4:	39 c2                	cmp    %eax,%edx
f0101cb6:	0f 86 83 02 00 00    	jbe    f0101f3f <mem_init+0x496>
f0101cbc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101cbf:	29 c8                	sub    %ecx,%eax
f0101cc1:	c1 f8 03             	sar    $0x3,%eax
f0101cc4:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101cc7:	39 c2                	cmp    %eax,%edx
f0101cc9:	0f 86 92 02 00 00    	jbe    f0101f61 <mem_init+0x4b8>
	fl = page_free_list;
f0101ccf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cd2:	8b 88 68 21 00 00    	mov    0x2168(%eax),%ecx
f0101cd8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101cdb:	c7 80 68 21 00 00 00 	movl   $0x0,0x2168(%eax)
f0101ce2:	00 00 00 
	assert(!page_alloc(0));
f0101ce5:	83 ec 0c             	sub    $0xc,%esp
f0101ce8:	6a 00                	push   $0x0
f0101cea:	e8 76 fa ff ff       	call   f0101765 <page_alloc>
f0101cef:	83 c4 10             	add    $0x10,%esp
f0101cf2:	85 c0                	test   %eax,%eax
f0101cf4:	0f 85 89 02 00 00    	jne    f0101f83 <mem_init+0x4da>
	page_free(pp0);
f0101cfa:	83 ec 0c             	sub    $0xc,%esp
f0101cfd:	53                   	push   %ebx
f0101cfe:	e8 ea fa ff ff       	call   f01017ed <page_free>
	page_free(pp1);
f0101d03:	89 3c 24             	mov    %edi,(%esp)
f0101d06:	e8 e2 fa ff ff       	call   f01017ed <page_free>
	page_free(pp2);
f0101d0b:	83 c4 04             	add    $0x4,%esp
f0101d0e:	ff 75 d0             	pushl  -0x30(%ebp)
f0101d11:	e8 d7 fa ff ff       	call   f01017ed <page_free>
	assert((pp0 = page_alloc(0)));
f0101d16:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d1d:	e8 43 fa ff ff       	call   f0101765 <page_alloc>
f0101d22:	89 c7                	mov    %eax,%edi
f0101d24:	83 c4 10             	add    $0x10,%esp
f0101d27:	85 c0                	test   %eax,%eax
f0101d29:	0f 84 76 02 00 00    	je     f0101fa5 <mem_init+0x4fc>
	assert((pp1 = page_alloc(0)));
f0101d2f:	83 ec 0c             	sub    $0xc,%esp
f0101d32:	6a 00                	push   $0x0
f0101d34:	e8 2c fa ff ff       	call   f0101765 <page_alloc>
f0101d39:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101d3c:	83 c4 10             	add    $0x10,%esp
f0101d3f:	85 c0                	test   %eax,%eax
f0101d41:	0f 84 80 02 00 00    	je     f0101fc7 <mem_init+0x51e>
	assert((pp2 = page_alloc(0)));
f0101d47:	83 ec 0c             	sub    $0xc,%esp
f0101d4a:	6a 00                	push   $0x0
f0101d4c:	e8 14 fa ff ff       	call   f0101765 <page_alloc>
f0101d51:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d54:	83 c4 10             	add    $0x10,%esp
f0101d57:	85 c0                	test   %eax,%eax
f0101d59:	0f 84 8a 02 00 00    	je     f0101fe9 <mem_init+0x540>
	assert(pp1 && pp1 != pp0);
f0101d5f:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101d62:	0f 84 a3 02 00 00    	je     f010200b <mem_init+0x562>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d68:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101d6b:	39 c7                	cmp    %eax,%edi
f0101d6d:	0f 84 ba 02 00 00    	je     f010202d <mem_init+0x584>
f0101d73:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101d76:	0f 84 b1 02 00 00    	je     f010202d <mem_init+0x584>
	assert(!page_alloc(0));
f0101d7c:	83 ec 0c             	sub    $0xc,%esp
f0101d7f:	6a 00                	push   $0x0
f0101d81:	e8 df f9 ff ff       	call   f0101765 <page_alloc>
f0101d86:	83 c4 10             	add    $0x10,%esp
f0101d89:	85 c0                	test   %eax,%eax
f0101d8b:	0f 85 be 02 00 00    	jne    f010204f <mem_init+0x5a6>
f0101d91:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d94:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0101d9a:	89 f9                	mov    %edi,%ecx
f0101d9c:	2b 08                	sub    (%eax),%ecx
f0101d9e:	89 c8                	mov    %ecx,%eax
f0101da0:	c1 f8 03             	sar    $0x3,%eax
f0101da3:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101da6:	89 c1                	mov    %eax,%ecx
f0101da8:	c1 e9 0c             	shr    $0xc,%ecx
f0101dab:	c7 c2 28 10 19 f0    	mov    $0xf0191028,%edx
f0101db1:	3b 0a                	cmp    (%edx),%ecx
f0101db3:	0f 83 b8 02 00 00    	jae    f0102071 <mem_init+0x5c8>
	memset(page2kva(pp0), 1, PGSIZE);
f0101db9:	83 ec 04             	sub    $0x4,%esp
f0101dbc:	68 00 10 00 00       	push   $0x1000
f0101dc1:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101dc3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dc8:	50                   	push   %eax
f0101dc9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101dcc:	e8 57 39 00 00       	call   f0105728 <memset>
	page_free(pp0);
f0101dd1:	89 3c 24             	mov    %edi,(%esp)
f0101dd4:	e8 14 fa ff ff       	call   f01017ed <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101dd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101de0:	e8 80 f9 ff ff       	call   f0101765 <page_alloc>
f0101de5:	83 c4 10             	add    $0x10,%esp
f0101de8:	85 c0                	test   %eax,%eax
f0101dea:	0f 84 97 02 00 00    	je     f0102087 <mem_init+0x5de>
	assert(pp && pp0 == pp);
f0101df0:	39 c7                	cmp    %eax,%edi
f0101df2:	0f 85 b1 02 00 00    	jne    f01020a9 <mem_init+0x600>
	return (pp - pages) << PGSHIFT;
f0101df8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101dfb:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0101e01:	89 fa                	mov    %edi,%edx
f0101e03:	2b 10                	sub    (%eax),%edx
f0101e05:	c1 fa 03             	sar    $0x3,%edx
f0101e08:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e0b:	89 d1                	mov    %edx,%ecx
f0101e0d:	c1 e9 0c             	shr    $0xc,%ecx
f0101e10:	c7 c0 28 10 19 f0    	mov    $0xf0191028,%eax
f0101e16:	3b 08                	cmp    (%eax),%ecx
f0101e18:	0f 83 ad 02 00 00    	jae    f01020cb <mem_init+0x622>
	return (void *)(pa + KERNBASE);
f0101e1e:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101e24:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101e2a:	80 38 00             	cmpb   $0x0,(%eax)
f0101e2d:	0f 85 ae 02 00 00    	jne    f01020e1 <mem_init+0x638>
f0101e33:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101e36:	39 d0                	cmp    %edx,%eax
f0101e38:	75 f0                	jne    f0101e2a <mem_init+0x381>
	page_free_list = fl;
f0101e3a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e3d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101e40:	89 8b 68 21 00 00    	mov    %ecx,0x2168(%ebx)
	page_free(pp0);
f0101e46:	83 ec 0c             	sub    $0xc,%esp
f0101e49:	57                   	push   %edi
f0101e4a:	e8 9e f9 ff ff       	call   f01017ed <page_free>
	page_free(pp1);
f0101e4f:	83 c4 04             	add    $0x4,%esp
f0101e52:	ff 75 d0             	pushl  -0x30(%ebp)
f0101e55:	e8 93 f9 ff ff       	call   f01017ed <page_free>
	page_free(pp2);
f0101e5a:	83 c4 04             	add    $0x4,%esp
f0101e5d:	ff 75 cc             	pushl  -0x34(%ebp)
f0101e60:	e8 88 f9 ff ff       	call   f01017ed <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101e65:	8b 83 68 21 00 00    	mov    0x2168(%ebx),%eax
f0101e6b:	83 c4 10             	add    $0x10,%esp
f0101e6e:	e9 95 02 00 00       	jmp    f0102108 <mem_init+0x65f>
	assert((pp0 = page_alloc(0)));
f0101e73:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e76:	8d 83 4e 8a f7 ff    	lea    -0x875b2(%ebx),%eax
f0101e7c:	50                   	push   %eax
f0101e7d:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101e83:	50                   	push   %eax
f0101e84:	68 cf 02 00 00       	push   $0x2cf
f0101e89:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101e8f:	50                   	push   %eax
f0101e90:	e8 1c e2 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e95:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e98:	8d 83 64 8a f7 ff    	lea    -0x8759c(%ebx),%eax
f0101e9e:	50                   	push   %eax
f0101e9f:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101ea5:	50                   	push   %eax
f0101ea6:	68 d0 02 00 00       	push   $0x2d0
f0101eab:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101eb1:	50                   	push   %eax
f0101eb2:	e8 fa e1 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101eb7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101eba:	8d 83 7a 8a f7 ff    	lea    -0x87586(%ebx),%eax
f0101ec0:	50                   	push   %eax
f0101ec1:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101ec7:	50                   	push   %eax
f0101ec8:	68 d1 02 00 00       	push   $0x2d1
f0101ecd:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101ed3:	50                   	push   %eax
f0101ed4:	e8 d8 e1 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101ed9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101edc:	8d 83 90 8a f7 ff    	lea    -0x87570(%ebx),%eax
f0101ee2:	50                   	push   %eax
f0101ee3:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101ee9:	50                   	push   %eax
f0101eea:	68 d4 02 00 00       	push   $0x2d4
f0101eef:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101ef5:	50                   	push   %eax
f0101ef6:	e8 b6 e1 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101efb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101efe:	8d 83 20 83 f7 ff    	lea    -0x87ce0(%ebx),%eax
f0101f04:	50                   	push   %eax
f0101f05:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101f0b:	50                   	push   %eax
f0101f0c:	68 d5 02 00 00       	push   $0x2d5
f0101f11:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101f17:	50                   	push   %eax
f0101f18:	e8 94 e1 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101f1d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f20:	8d 83 a2 8a f7 ff    	lea    -0x8755e(%ebx),%eax
f0101f26:	50                   	push   %eax
f0101f27:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101f2d:	50                   	push   %eax
f0101f2e:	68 d6 02 00 00       	push   $0x2d6
f0101f33:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101f39:	50                   	push   %eax
f0101f3a:	e8 72 e1 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101f3f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f42:	8d 83 bf 8a f7 ff    	lea    -0x87541(%ebx),%eax
f0101f48:	50                   	push   %eax
f0101f49:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101f4f:	50                   	push   %eax
f0101f50:	68 d7 02 00 00       	push   $0x2d7
f0101f55:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101f5b:	50                   	push   %eax
f0101f5c:	e8 50 e1 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101f61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f64:	8d 83 dc 8a f7 ff    	lea    -0x87524(%ebx),%eax
f0101f6a:	50                   	push   %eax
f0101f6b:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101f71:	50                   	push   %eax
f0101f72:	68 d8 02 00 00       	push   $0x2d8
f0101f77:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101f7d:	50                   	push   %eax
f0101f7e:	e8 2e e1 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101f83:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f86:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0101f8c:	50                   	push   %eax
f0101f8d:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101f93:	50                   	push   %eax
f0101f94:	68 df 02 00 00       	push   $0x2df
f0101f99:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101f9f:	50                   	push   %eax
f0101fa0:	e8 0c e1 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0101fa5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fa8:	8d 83 4e 8a f7 ff    	lea    -0x875b2(%ebx),%eax
f0101fae:	50                   	push   %eax
f0101faf:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101fb5:	50                   	push   %eax
f0101fb6:	68 e6 02 00 00       	push   $0x2e6
f0101fbb:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101fc1:	50                   	push   %eax
f0101fc2:	e8 ea e0 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101fc7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fca:	8d 83 64 8a f7 ff    	lea    -0x8759c(%ebx),%eax
f0101fd0:	50                   	push   %eax
f0101fd1:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101fd7:	50                   	push   %eax
f0101fd8:	68 e7 02 00 00       	push   $0x2e7
f0101fdd:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0101fe3:	50                   	push   %eax
f0101fe4:	e8 c8 e0 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101fe9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fec:	8d 83 7a 8a f7 ff    	lea    -0x87586(%ebx),%eax
f0101ff2:	50                   	push   %eax
f0101ff3:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0101ff9:	50                   	push   %eax
f0101ffa:	68 e8 02 00 00       	push   $0x2e8
f0101fff:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102005:	50                   	push   %eax
f0102006:	e8 a6 e0 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f010200b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010200e:	8d 83 90 8a f7 ff    	lea    -0x87570(%ebx),%eax
f0102014:	50                   	push   %eax
f0102015:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010201b:	50                   	push   %eax
f010201c:	68 ea 02 00 00       	push   $0x2ea
f0102021:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102027:	50                   	push   %eax
f0102028:	e8 84 e0 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010202d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102030:	8d 83 20 83 f7 ff    	lea    -0x87ce0(%ebx),%eax
f0102036:	50                   	push   %eax
f0102037:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010203d:	50                   	push   %eax
f010203e:	68 eb 02 00 00       	push   $0x2eb
f0102043:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102049:	50                   	push   %eax
f010204a:	e8 62 e0 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f010204f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102052:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102058:	50                   	push   %eax
f0102059:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010205f:	50                   	push   %eax
f0102060:	68 ec 02 00 00       	push   $0x2ec
f0102065:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010206b:	50                   	push   %eax
f010206c:	e8 40 e0 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102071:	50                   	push   %eax
f0102072:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f0102078:	50                   	push   %eax
f0102079:	6a 56                	push   $0x56
f010207b:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f0102081:	50                   	push   %eax
f0102082:	e8 2a e0 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102087:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010208a:	8d 83 08 8b f7 ff    	lea    -0x874f8(%ebx),%eax
f0102090:	50                   	push   %eax
f0102091:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102097:	50                   	push   %eax
f0102098:	68 f1 02 00 00       	push   $0x2f1
f010209d:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01020a3:	50                   	push   %eax
f01020a4:	e8 08 e0 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f01020a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020ac:	8d 83 26 8b f7 ff    	lea    -0x874da(%ebx),%eax
f01020b2:	50                   	push   %eax
f01020b3:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01020b9:	50                   	push   %eax
f01020ba:	68 f2 02 00 00       	push   $0x2f2
f01020bf:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01020c5:	50                   	push   %eax
f01020c6:	e8 e6 df ff ff       	call   f01000b1 <_panic>
f01020cb:	52                   	push   %edx
f01020cc:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f01020d2:	50                   	push   %eax
f01020d3:	6a 56                	push   $0x56
f01020d5:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f01020db:	50                   	push   %eax
f01020dc:	e8 d0 df ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f01020e1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01020e4:	8d 83 36 8b f7 ff    	lea    -0x874ca(%ebx),%eax
f01020ea:	50                   	push   %eax
f01020eb:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01020f1:	50                   	push   %eax
f01020f2:	68 f5 02 00 00       	push   $0x2f5
f01020f7:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01020fd:	50                   	push   %eax
f01020fe:	e8 ae df ff ff       	call   f01000b1 <_panic>
		--nfree;
f0102103:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102106:	8b 00                	mov    (%eax),%eax
f0102108:	85 c0                	test   %eax,%eax
f010210a:	75 f7                	jne    f0102103 <mem_init+0x65a>
	assert(nfree == 0);
f010210c:	85 f6                	test   %esi,%esi
f010210e:	0f 85 5f 08 00 00    	jne    f0102973 <mem_init+0xeca>
	cprintf("check_page_alloc() succeeded!\n");
f0102114:	83 ec 0c             	sub    $0xc,%esp
f0102117:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010211a:	8d 83 40 83 f7 ff    	lea    -0x87cc0(%ebx),%eax
f0102120:	50                   	push   %eax
f0102121:	e8 19 21 00 00       	call   f010423f <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102126:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010212d:	e8 33 f6 ff ff       	call   f0101765 <page_alloc>
f0102132:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102135:	83 c4 10             	add    $0x10,%esp
f0102138:	85 c0                	test   %eax,%eax
f010213a:	0f 84 55 08 00 00    	je     f0102995 <mem_init+0xeec>
	assert((pp1 = page_alloc(0)));
f0102140:	83 ec 0c             	sub    $0xc,%esp
f0102143:	6a 00                	push   $0x0
f0102145:	e8 1b f6 ff ff       	call   f0101765 <page_alloc>
f010214a:	89 c7                	mov    %eax,%edi
f010214c:	83 c4 10             	add    $0x10,%esp
f010214f:	85 c0                	test   %eax,%eax
f0102151:	0f 84 60 08 00 00    	je     f01029b7 <mem_init+0xf0e>
	assert((pp2 = page_alloc(0)));
f0102157:	83 ec 0c             	sub    $0xc,%esp
f010215a:	6a 00                	push   $0x0
f010215c:	e8 04 f6 ff ff       	call   f0101765 <page_alloc>
f0102161:	89 c6                	mov    %eax,%esi
f0102163:	83 c4 10             	add    $0x10,%esp
f0102166:	85 c0                	test   %eax,%eax
f0102168:	0f 84 6b 08 00 00    	je     f01029d9 <mem_init+0xf30>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010216e:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0102171:	0f 84 84 08 00 00    	je     f01029fb <mem_init+0xf52>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102177:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010217a:	0f 84 9d 08 00 00    	je     f0102a1d <mem_init+0xf74>
f0102180:	39 c7                	cmp    %eax,%edi
f0102182:	0f 84 95 08 00 00    	je     f0102a1d <mem_init+0xf74>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102188:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010218b:	8b 88 68 21 00 00    	mov    0x2168(%eax),%ecx
f0102191:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0102194:	c7 80 68 21 00 00 00 	movl   $0x0,0x2168(%eax)
f010219b:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010219e:	83 ec 0c             	sub    $0xc,%esp
f01021a1:	6a 00                	push   $0x0
f01021a3:	e8 bd f5 ff ff       	call   f0101765 <page_alloc>
f01021a8:	83 c4 10             	add    $0x10,%esp
f01021ab:	85 c0                	test   %eax,%eax
f01021ad:	0f 85 8c 08 00 00    	jne    f0102a3f <mem_init+0xf96>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01021b3:	83 ec 04             	sub    $0x4,%esp
f01021b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01021b9:	50                   	push   %eax
f01021ba:	6a 00                	push   $0x0
f01021bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021bf:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01021c5:	ff 30                	pushl  (%eax)
f01021c7:	e8 b6 f7 ff ff       	call   f0101982 <page_lookup>
f01021cc:	83 c4 10             	add    $0x10,%esp
f01021cf:	85 c0                	test   %eax,%eax
f01021d1:	0f 85 8a 08 00 00    	jne    f0102a61 <mem_init+0xfb8>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01021d7:	6a 02                	push   $0x2
f01021d9:	6a 00                	push   $0x0
f01021db:	57                   	push   %edi
f01021dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021df:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01021e5:	ff 30                	pushl  (%eax)
f01021e7:	e8 45 f8 ff ff       	call   f0101a31 <page_insert>
f01021ec:	83 c4 10             	add    $0x10,%esp
f01021ef:	85 c0                	test   %eax,%eax
f01021f1:	0f 89 8c 08 00 00    	jns    f0102a83 <mem_init+0xfda>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01021f7:	83 ec 0c             	sub    $0xc,%esp
f01021fa:	ff 75 d0             	pushl  -0x30(%ebp)
f01021fd:	e8 eb f5 ff ff       	call   f01017ed <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102202:	6a 02                	push   $0x2
f0102204:	6a 00                	push   $0x0
f0102206:	57                   	push   %edi
f0102207:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010220a:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0102210:	ff 30                	pushl  (%eax)
f0102212:	e8 1a f8 ff ff       	call   f0101a31 <page_insert>
f0102217:	83 c4 20             	add    $0x20,%esp
f010221a:	85 c0                	test   %eax,%eax
f010221c:	0f 85 83 08 00 00    	jne    f0102aa5 <mem_init+0xffc>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102222:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102225:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f010222b:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f010222d:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0102233:	8b 08                	mov    (%eax),%ecx
f0102235:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102238:	8b 13                	mov    (%ebx),%edx
f010223a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102240:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102243:	29 c8                	sub    %ecx,%eax
f0102245:	c1 f8 03             	sar    $0x3,%eax
f0102248:	c1 e0 0c             	shl    $0xc,%eax
f010224b:	39 c2                	cmp    %eax,%edx
f010224d:	0f 85 74 08 00 00    	jne    f0102ac7 <mem_init+0x101e>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102253:	ba 00 00 00 00       	mov    $0x0,%edx
f0102258:	89 d8                	mov    %ebx,%eax
f010225a:	e8 e4 ef ff ff       	call   f0101243 <check_va2pa>
f010225f:	89 fa                	mov    %edi,%edx
f0102261:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0102264:	c1 fa 03             	sar    $0x3,%edx
f0102267:	c1 e2 0c             	shl    $0xc,%edx
f010226a:	39 d0                	cmp    %edx,%eax
f010226c:	0f 85 77 08 00 00    	jne    f0102ae9 <mem_init+0x1040>
	assert(pp1->pp_ref == 1);
f0102272:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102277:	0f 85 8e 08 00 00    	jne    f0102b0b <mem_init+0x1062>
	assert(pp0->pp_ref == 1);
f010227d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102280:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102285:	0f 85 a2 08 00 00    	jne    f0102b2d <mem_init+0x1084>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010228b:	6a 02                	push   $0x2
f010228d:	68 00 10 00 00       	push   $0x1000
f0102292:	56                   	push   %esi
f0102293:	53                   	push   %ebx
f0102294:	e8 98 f7 ff ff       	call   f0101a31 <page_insert>
f0102299:	83 c4 10             	add    $0x10,%esp
f010229c:	85 c0                	test   %eax,%eax
f010229e:	0f 85 ab 08 00 00    	jne    f0102b4f <mem_init+0x10a6>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022a4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022ac:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01022b2:	8b 00                	mov    (%eax),%eax
f01022b4:	e8 8a ef ff ff       	call   f0101243 <check_va2pa>
f01022b9:	c7 c2 30 10 19 f0    	mov    $0xf0191030,%edx
f01022bf:	89 f1                	mov    %esi,%ecx
f01022c1:	2b 0a                	sub    (%edx),%ecx
f01022c3:	89 ca                	mov    %ecx,%edx
f01022c5:	c1 fa 03             	sar    $0x3,%edx
f01022c8:	c1 e2 0c             	shl    $0xc,%edx
f01022cb:	39 d0                	cmp    %edx,%eax
f01022cd:	0f 85 9e 08 00 00    	jne    f0102b71 <mem_init+0x10c8>
	assert(pp2->pp_ref == 1);
f01022d3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022d8:	0f 85 b5 08 00 00    	jne    f0102b93 <mem_init+0x10ea>

	// should be no free memory
	assert(!page_alloc(0));
f01022de:	83 ec 0c             	sub    $0xc,%esp
f01022e1:	6a 00                	push   $0x0
f01022e3:	e8 7d f4 ff ff       	call   f0101765 <page_alloc>
f01022e8:	83 c4 10             	add    $0x10,%esp
f01022eb:	85 c0                	test   %eax,%eax
f01022ed:	0f 85 c2 08 00 00    	jne    f0102bb5 <mem_init+0x110c>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022f3:	6a 02                	push   $0x2
f01022f5:	68 00 10 00 00       	push   $0x1000
f01022fa:	56                   	push   %esi
f01022fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022fe:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0102304:	ff 30                	pushl  (%eax)
f0102306:	e8 26 f7 ff ff       	call   f0101a31 <page_insert>
f010230b:	83 c4 10             	add    $0x10,%esp
f010230e:	85 c0                	test   %eax,%eax
f0102310:	0f 85 c1 08 00 00    	jne    f0102bd7 <mem_init+0x112e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102316:	ba 00 10 00 00       	mov    $0x1000,%edx
f010231b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010231e:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0102324:	8b 00                	mov    (%eax),%eax
f0102326:	e8 18 ef ff ff       	call   f0101243 <check_va2pa>
f010232b:	c7 c2 30 10 19 f0    	mov    $0xf0191030,%edx
f0102331:	89 f1                	mov    %esi,%ecx
f0102333:	2b 0a                	sub    (%edx),%ecx
f0102335:	89 ca                	mov    %ecx,%edx
f0102337:	c1 fa 03             	sar    $0x3,%edx
f010233a:	c1 e2 0c             	shl    $0xc,%edx
f010233d:	39 d0                	cmp    %edx,%eax
f010233f:	0f 85 b4 08 00 00    	jne    f0102bf9 <mem_init+0x1150>
	assert(pp2->pp_ref == 1);
f0102345:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010234a:	0f 85 cb 08 00 00    	jne    f0102c1b <mem_init+0x1172>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102350:	83 ec 0c             	sub    $0xc,%esp
f0102353:	6a 00                	push   $0x0
f0102355:	e8 0b f4 ff ff       	call   f0101765 <page_alloc>
f010235a:	83 c4 10             	add    $0x10,%esp
f010235d:	85 c0                	test   %eax,%eax
f010235f:	0f 85 d8 08 00 00    	jne    f0102c3d <mem_init+0x1194>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102365:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102368:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f010236e:	8b 10                	mov    (%eax),%edx
f0102370:	8b 02                	mov    (%edx),%eax
f0102372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0102377:	89 c3                	mov    %eax,%ebx
f0102379:	c1 eb 0c             	shr    $0xc,%ebx
f010237c:	c7 c1 28 10 19 f0    	mov    $0xf0191028,%ecx
f0102382:	3b 19                	cmp    (%ecx),%ebx
f0102384:	0f 83 d5 08 00 00    	jae    f0102c5f <mem_init+0x11b6>
	return (void *)(pa + KERNBASE);
f010238a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010238f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102392:	83 ec 04             	sub    $0x4,%esp
f0102395:	6a 00                	push   $0x0
f0102397:	68 00 10 00 00       	push   $0x1000
f010239c:	52                   	push   %edx
f010239d:	e8 e6 f4 ff ff       	call   f0101888 <pgdir_walk>
f01023a2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01023a5:	8d 51 04             	lea    0x4(%ecx),%edx
f01023a8:	83 c4 10             	add    $0x10,%esp
f01023ab:	39 d0                	cmp    %edx,%eax
f01023ad:	0f 85 c8 08 00 00    	jne    f0102c7b <mem_init+0x11d2>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023b3:	6a 06                	push   $0x6
f01023b5:	68 00 10 00 00       	push   $0x1000
f01023ba:	56                   	push   %esi
f01023bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023be:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01023c4:	ff 30                	pushl  (%eax)
f01023c6:	e8 66 f6 ff ff       	call   f0101a31 <page_insert>
f01023cb:	83 c4 10             	add    $0x10,%esp
f01023ce:	85 c0                	test   %eax,%eax
f01023d0:	0f 85 c7 08 00 00    	jne    f0102c9d <mem_init+0x11f4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023d9:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01023df:	8b 18                	mov    (%eax),%ebx
f01023e1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023e6:	89 d8                	mov    %ebx,%eax
f01023e8:	e8 56 ee ff ff       	call   f0101243 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f01023ed:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01023f0:	c7 c2 30 10 19 f0    	mov    $0xf0191030,%edx
f01023f6:	89 f1                	mov    %esi,%ecx
f01023f8:	2b 0a                	sub    (%edx),%ecx
f01023fa:	89 ca                	mov    %ecx,%edx
f01023fc:	c1 fa 03             	sar    $0x3,%edx
f01023ff:	c1 e2 0c             	shl    $0xc,%edx
f0102402:	39 d0                	cmp    %edx,%eax
f0102404:	0f 85 b5 08 00 00    	jne    f0102cbf <mem_init+0x1216>
	assert(pp2->pp_ref == 1);
f010240a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010240f:	0f 85 cc 08 00 00    	jne    f0102ce1 <mem_init+0x1238>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102415:	83 ec 04             	sub    $0x4,%esp
f0102418:	6a 00                	push   $0x0
f010241a:	68 00 10 00 00       	push   $0x1000
f010241f:	53                   	push   %ebx
f0102420:	e8 63 f4 ff ff       	call   f0101888 <pgdir_walk>
f0102425:	83 c4 10             	add    $0x10,%esp
f0102428:	f6 00 04             	testb  $0x4,(%eax)
f010242b:	0f 84 d2 08 00 00    	je     f0102d03 <mem_init+0x125a>
	assert(kern_pgdir[0] & PTE_U);
f0102431:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102434:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f010243a:	8b 00                	mov    (%eax),%eax
f010243c:	f6 00 04             	testb  $0x4,(%eax)
f010243f:	0f 84 e0 08 00 00    	je     f0102d25 <mem_init+0x127c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102445:	6a 02                	push   $0x2
f0102447:	68 00 10 00 00       	push   $0x1000
f010244c:	56                   	push   %esi
f010244d:	50                   	push   %eax
f010244e:	e8 de f5 ff ff       	call   f0101a31 <page_insert>
f0102453:	83 c4 10             	add    $0x10,%esp
f0102456:	85 c0                	test   %eax,%eax
f0102458:	0f 85 e9 08 00 00    	jne    f0102d47 <mem_init+0x129e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010245e:	83 ec 04             	sub    $0x4,%esp
f0102461:	6a 00                	push   $0x0
f0102463:	68 00 10 00 00       	push   $0x1000
f0102468:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010246b:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0102471:	ff 30                	pushl  (%eax)
f0102473:	e8 10 f4 ff ff       	call   f0101888 <pgdir_walk>
f0102478:	83 c4 10             	add    $0x10,%esp
f010247b:	f6 00 02             	testb  $0x2,(%eax)
f010247e:	0f 84 e5 08 00 00    	je     f0102d69 <mem_init+0x12c0>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102484:	83 ec 04             	sub    $0x4,%esp
f0102487:	6a 00                	push   $0x0
f0102489:	68 00 10 00 00       	push   $0x1000
f010248e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102491:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0102497:	ff 30                	pushl  (%eax)
f0102499:	e8 ea f3 ff ff       	call   f0101888 <pgdir_walk>
f010249e:	83 c4 10             	add    $0x10,%esp
f01024a1:	f6 00 04             	testb  $0x4,(%eax)
f01024a4:	0f 85 e1 08 00 00    	jne    f0102d8b <mem_init+0x12e2>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024aa:	6a 02                	push   $0x2
f01024ac:	68 00 00 40 00       	push   $0x400000
f01024b1:	ff 75 d0             	pushl  -0x30(%ebp)
f01024b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024b7:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01024bd:	ff 30                	pushl  (%eax)
f01024bf:	e8 6d f5 ff ff       	call   f0101a31 <page_insert>
f01024c4:	83 c4 10             	add    $0x10,%esp
f01024c7:	85 c0                	test   %eax,%eax
f01024c9:	0f 89 de 08 00 00    	jns    f0102dad <mem_init+0x1304>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01024cf:	6a 02                	push   $0x2
f01024d1:	68 00 10 00 00       	push   $0x1000
f01024d6:	57                   	push   %edi
f01024d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024da:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01024e0:	ff 30                	pushl  (%eax)
f01024e2:	e8 4a f5 ff ff       	call   f0101a31 <page_insert>
f01024e7:	83 c4 10             	add    $0x10,%esp
f01024ea:	85 c0                	test   %eax,%eax
f01024ec:	0f 85 dd 08 00 00    	jne    f0102dcf <mem_init+0x1326>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024f2:	83 ec 04             	sub    $0x4,%esp
f01024f5:	6a 00                	push   $0x0
f01024f7:	68 00 10 00 00       	push   $0x1000
f01024fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024ff:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0102505:	ff 30                	pushl  (%eax)
f0102507:	e8 7c f3 ff ff       	call   f0101888 <pgdir_walk>
f010250c:	83 c4 10             	add    $0x10,%esp
f010250f:	f6 00 04             	testb  $0x4,(%eax)
f0102512:	0f 85 d9 08 00 00    	jne    f0102df1 <mem_init+0x1348>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102518:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010251b:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0102521:	8b 18                	mov    (%eax),%ebx
f0102523:	ba 00 00 00 00       	mov    $0x0,%edx
f0102528:	89 d8                	mov    %ebx,%eax
f010252a:	e8 14 ed ff ff       	call   f0101243 <check_va2pa>
f010252f:	89 c2                	mov    %eax,%edx
f0102531:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102534:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102537:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f010253d:	89 f9                	mov    %edi,%ecx
f010253f:	2b 08                	sub    (%eax),%ecx
f0102541:	89 c8                	mov    %ecx,%eax
f0102543:	c1 f8 03             	sar    $0x3,%eax
f0102546:	c1 e0 0c             	shl    $0xc,%eax
f0102549:	39 c2                	cmp    %eax,%edx
f010254b:	0f 85 c2 08 00 00    	jne    f0102e13 <mem_init+0x136a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102551:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102556:	89 d8                	mov    %ebx,%eax
f0102558:	e8 e6 ec ff ff       	call   f0101243 <check_va2pa>
f010255d:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102560:	0f 85 cf 08 00 00    	jne    f0102e35 <mem_init+0x138c>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102566:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f010256b:	0f 85 e6 08 00 00    	jne    f0102e57 <mem_init+0x13ae>
	assert(pp2->pp_ref == 0);
f0102571:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102576:	0f 85 fd 08 00 00    	jne    f0102e79 <mem_init+0x13d0>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010257c:	83 ec 0c             	sub    $0xc,%esp
f010257f:	6a 00                	push   $0x0
f0102581:	e8 df f1 ff ff       	call   f0101765 <page_alloc>
f0102586:	83 c4 10             	add    $0x10,%esp
f0102589:	39 c6                	cmp    %eax,%esi
f010258b:	0f 85 0a 09 00 00    	jne    f0102e9b <mem_init+0x13f2>
f0102591:	85 c0                	test   %eax,%eax
f0102593:	0f 84 02 09 00 00    	je     f0102e9b <mem_init+0x13f2>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102599:	83 ec 08             	sub    $0x8,%esp
f010259c:	6a 00                	push   $0x0
f010259e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01025a1:	c7 c3 2c 10 19 f0    	mov    $0xf019102c,%ebx
f01025a7:	ff 33                	pushl  (%ebx)
f01025a9:	e8 44 f4 ff ff       	call   f01019f2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01025ae:	8b 1b                	mov    (%ebx),%ebx
f01025b0:	ba 00 00 00 00       	mov    $0x0,%edx
f01025b5:	89 d8                	mov    %ebx,%eax
f01025b7:	e8 87 ec ff ff       	call   f0101243 <check_va2pa>
f01025bc:	83 c4 10             	add    $0x10,%esp
f01025bf:	83 f8 ff             	cmp    $0xffffffff,%eax
f01025c2:	0f 85 f5 08 00 00    	jne    f0102ebd <mem_init+0x1414>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01025c8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01025cd:	89 d8                	mov    %ebx,%eax
f01025cf:	e8 6f ec ff ff       	call   f0101243 <check_va2pa>
f01025d4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01025d7:	c7 c2 30 10 19 f0    	mov    $0xf0191030,%edx
f01025dd:	89 f9                	mov    %edi,%ecx
f01025df:	2b 0a                	sub    (%edx),%ecx
f01025e1:	89 ca                	mov    %ecx,%edx
f01025e3:	c1 fa 03             	sar    $0x3,%edx
f01025e6:	c1 e2 0c             	shl    $0xc,%edx
f01025e9:	39 d0                	cmp    %edx,%eax
f01025eb:	0f 85 ee 08 00 00    	jne    f0102edf <mem_init+0x1436>
	assert(pp1->pp_ref == 1);
f01025f1:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025f6:	0f 85 05 09 00 00    	jne    f0102f01 <mem_init+0x1458>
	assert(pp2->pp_ref == 0);
f01025fc:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102601:	0f 85 1c 09 00 00    	jne    f0102f23 <mem_init+0x147a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102607:	6a 00                	push   $0x0
f0102609:	68 00 10 00 00       	push   $0x1000
f010260e:	57                   	push   %edi
f010260f:	53                   	push   %ebx
f0102610:	e8 1c f4 ff ff       	call   f0101a31 <page_insert>
f0102615:	83 c4 10             	add    $0x10,%esp
f0102618:	85 c0                	test   %eax,%eax
f010261a:	0f 85 25 09 00 00    	jne    f0102f45 <mem_init+0x149c>
	assert(pp1->pp_ref);
f0102620:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102625:	0f 84 3c 09 00 00    	je     f0102f67 <mem_init+0x14be>
	assert(pp1->pp_link == NULL);
f010262b:	83 3f 00             	cmpl   $0x0,(%edi)
f010262e:	0f 85 55 09 00 00    	jne    f0102f89 <mem_init+0x14e0>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102634:	83 ec 08             	sub    $0x8,%esp
f0102637:	68 00 10 00 00       	push   $0x1000
f010263c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010263f:	c7 c3 2c 10 19 f0    	mov    $0xf019102c,%ebx
f0102645:	ff 33                	pushl  (%ebx)
f0102647:	e8 a6 f3 ff ff       	call   f01019f2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010264c:	8b 1b                	mov    (%ebx),%ebx
f010264e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102653:	89 d8                	mov    %ebx,%eax
f0102655:	e8 e9 eb ff ff       	call   f0101243 <check_va2pa>
f010265a:	83 c4 10             	add    $0x10,%esp
f010265d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102660:	0f 85 45 09 00 00    	jne    f0102fab <mem_init+0x1502>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102666:	ba 00 10 00 00       	mov    $0x1000,%edx
f010266b:	89 d8                	mov    %ebx,%eax
f010266d:	e8 d1 eb ff ff       	call   f0101243 <check_va2pa>
f0102672:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102675:	0f 85 52 09 00 00    	jne    f0102fcd <mem_init+0x1524>
	assert(pp1->pp_ref == 0);
f010267b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102680:	0f 85 69 09 00 00    	jne    f0102fef <mem_init+0x1546>
	assert(pp2->pp_ref == 0);
f0102686:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010268b:	0f 85 80 09 00 00    	jne    f0103011 <mem_init+0x1568>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102691:	83 ec 0c             	sub    $0xc,%esp
f0102694:	6a 00                	push   $0x0
f0102696:	e8 ca f0 ff ff       	call   f0101765 <page_alloc>
f010269b:	83 c4 10             	add    $0x10,%esp
f010269e:	39 c7                	cmp    %eax,%edi
f01026a0:	0f 85 8d 09 00 00    	jne    f0103033 <mem_init+0x158a>
f01026a6:	85 c0                	test   %eax,%eax
f01026a8:	0f 84 85 09 00 00    	je     f0103033 <mem_init+0x158a>

	// should be no free memory
	assert(!page_alloc(0));
f01026ae:	83 ec 0c             	sub    $0xc,%esp
f01026b1:	6a 00                	push   $0x0
f01026b3:	e8 ad f0 ff ff       	call   f0101765 <page_alloc>
f01026b8:	83 c4 10             	add    $0x10,%esp
f01026bb:	85 c0                	test   %eax,%eax
f01026bd:	0f 85 92 09 00 00    	jne    f0103055 <mem_init+0x15ac>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026c6:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01026cc:	8b 08                	mov    (%eax),%ecx
f01026ce:	8b 11                	mov    (%ecx),%edx
f01026d0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01026d6:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f01026dc:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01026df:	2b 18                	sub    (%eax),%ebx
f01026e1:	89 d8                	mov    %ebx,%eax
f01026e3:	c1 f8 03             	sar    $0x3,%eax
f01026e6:	c1 e0 0c             	shl    $0xc,%eax
f01026e9:	39 c2                	cmp    %eax,%edx
f01026eb:	0f 85 86 09 00 00    	jne    f0103077 <mem_init+0x15ce>
	kern_pgdir[0] = 0;
f01026f1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01026f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01026fa:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01026ff:	0f 85 94 09 00 00    	jne    f0103099 <mem_init+0x15f0>
	pp0->pp_ref = 0;
f0102705:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102708:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010270e:	83 ec 0c             	sub    $0xc,%esp
f0102711:	50                   	push   %eax
f0102712:	e8 d6 f0 ff ff       	call   f01017ed <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102717:	83 c4 0c             	add    $0xc,%esp
f010271a:	6a 01                	push   $0x1
f010271c:	68 00 10 40 00       	push   $0x401000
f0102721:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102724:	c7 c3 2c 10 19 f0    	mov    $0xf019102c,%ebx
f010272a:	ff 33                	pushl  (%ebx)
f010272c:	e8 57 f1 ff ff       	call   f0101888 <pgdir_walk>
f0102731:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102734:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102737:	8b 1b                	mov    (%ebx),%ebx
f0102739:	8b 53 04             	mov    0x4(%ebx),%edx
f010273c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102742:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102745:	c7 c1 28 10 19 f0    	mov    $0xf0191028,%ecx
f010274b:	8b 09                	mov    (%ecx),%ecx
f010274d:	89 d0                	mov    %edx,%eax
f010274f:	c1 e8 0c             	shr    $0xc,%eax
f0102752:	83 c4 10             	add    $0x10,%esp
f0102755:	39 c8                	cmp    %ecx,%eax
f0102757:	0f 83 5e 09 00 00    	jae    f01030bb <mem_init+0x1612>
	assert(ptep == ptep1 + PTX(va));
f010275d:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102763:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102766:	0f 85 6b 09 00 00    	jne    f01030d7 <mem_init+0x162e>
	kern_pgdir[PDX(va)] = 0;
f010276c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0102773:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102776:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f010277c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010277f:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0102785:	2b 18                	sub    (%eax),%ebx
f0102787:	89 d8                	mov    %ebx,%eax
f0102789:	c1 f8 03             	sar    $0x3,%eax
f010278c:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010278f:	89 c2                	mov    %eax,%edx
f0102791:	c1 ea 0c             	shr    $0xc,%edx
f0102794:	39 d1                	cmp    %edx,%ecx
f0102796:	0f 86 5d 09 00 00    	jbe    f01030f9 <mem_init+0x1650>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010279c:	83 ec 04             	sub    $0x4,%esp
f010279f:	68 00 10 00 00       	push   $0x1000
f01027a4:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01027a9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027ae:	50                   	push   %eax
f01027af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027b2:	e8 71 2f 00 00       	call   f0105728 <memset>
	page_free(pp0);
f01027b7:	83 c4 04             	add    $0x4,%esp
f01027ba:	ff 75 d0             	pushl  -0x30(%ebp)
f01027bd:	e8 2b f0 ff ff       	call   f01017ed <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01027c2:	83 c4 0c             	add    $0xc,%esp
f01027c5:	6a 01                	push   $0x1
f01027c7:	6a 00                	push   $0x0
f01027c9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027cc:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01027d2:	ff 30                	pushl  (%eax)
f01027d4:	e8 af f0 ff ff       	call   f0101888 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01027d9:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f01027df:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01027e2:	2b 10                	sub    (%eax),%edx
f01027e4:	c1 fa 03             	sar    $0x3,%edx
f01027e7:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01027ea:	89 d1                	mov    %edx,%ecx
f01027ec:	c1 e9 0c             	shr    $0xc,%ecx
f01027ef:	83 c4 10             	add    $0x10,%esp
f01027f2:	c7 c0 28 10 19 f0    	mov    $0xf0191028,%eax
f01027f8:	3b 08                	cmp    (%eax),%ecx
f01027fa:	0f 83 12 09 00 00    	jae    f0103112 <mem_init+0x1669>
	return (void *)(pa + KERNBASE);
f0102800:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102806:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102809:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010280f:	f6 00 01             	testb  $0x1,(%eax)
f0102812:	0f 85 13 09 00 00    	jne    f010312b <mem_init+0x1682>
f0102818:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f010281b:	39 d0                	cmp    %edx,%eax
f010281d:	75 f0                	jne    f010280f <mem_init+0xd66>
	kern_pgdir[0] = 0;
f010281f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102822:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0102828:	8b 00                	mov    (%eax),%eax
f010282a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102830:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102833:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102839:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010283c:	89 93 68 21 00 00    	mov    %edx,0x2168(%ebx)

	// free the pages we took
	page_free(pp0);
f0102842:	83 ec 0c             	sub    $0xc,%esp
f0102845:	50                   	push   %eax
f0102846:	e8 a2 ef ff ff       	call   f01017ed <page_free>
	page_free(pp1);
f010284b:	89 3c 24             	mov    %edi,(%esp)
f010284e:	e8 9a ef ff ff       	call   f01017ed <page_free>
	page_free(pp2);
f0102853:	89 34 24             	mov    %esi,(%esp)
f0102856:	e8 92 ef ff ff       	call   f01017ed <page_free>

	cprintf("check_page() succeeded!\n");
f010285b:	8d 83 17 8c f7 ff    	lea    -0x873e9(%ebx),%eax
f0102861:	89 04 24             	mov    %eax,(%esp)
f0102864:	e8 d6 19 00 00       	call   f010423f <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0102869:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f010286f:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102871:	83 c4 10             	add    $0x10,%esp
f0102874:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102879:	0f 86 ce 08 00 00    	jbe    f010314d <mem_init+0x16a4>
f010287f:	83 ec 08             	sub    $0x8,%esp
f0102882:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102884:	05 00 00 00 10       	add    $0x10000000,%eax
f0102889:	50                   	push   %eax
f010288a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010288f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102894:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102897:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f010289d:	8b 00                	mov    (%eax),%eax
f010289f:	e8 8f f0 ff ff       	call   f0101933 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f01028a4:	c7 c0 68 03 19 f0    	mov    $0xf0190368,%eax
f01028aa:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01028ac:	83 c4 10             	add    $0x10,%esp
f01028af:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028b4:	0f 86 af 08 00 00    	jbe    f0103169 <mem_init+0x16c0>
f01028ba:	83 ec 08             	sub    $0x8,%esp
f01028bd:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01028bf:	05 00 00 00 10       	add    $0x10000000,%eax
f01028c4:	50                   	push   %eax
f01028c5:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01028ca:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01028cf:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01028d2:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01028d8:	8b 00                	mov    (%eax),%eax
f01028da:	e8 54 f0 ff ff       	call   f0101933 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01028df:	c7 c0 00 40 11 f0    	mov    $0xf0114000,%eax
f01028e5:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01028e8:	83 c4 10             	add    $0x10,%esp
f01028eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028f0:	0f 86 8f 08 00 00    	jbe    f0103185 <mem_init+0x16dc>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01028f6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01028f9:	c7 c3 2c 10 19 f0    	mov    $0xf019102c,%ebx
f01028ff:	83 ec 08             	sub    $0x8,%esp
f0102902:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0102904:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102907:	05 00 00 00 10       	add    $0x10000000,%eax
f010290c:	50                   	push   %eax
f010290d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102912:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102917:	8b 03                	mov    (%ebx),%eax
f0102919:	e8 15 f0 ff ff       	call   f0101933 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, (uint32_t)0xffffffff - KERNBASE, 0, PTE_W);
f010291e:	83 c4 08             	add    $0x8,%esp
f0102921:	6a 02                	push   $0x2
f0102923:	6a 00                	push   $0x0
f0102925:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010292a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010292f:	8b 03                	mov    (%ebx),%eax
f0102931:	e8 fd ef ff ff       	call   f0101933 <boot_map_region>
	pgdir = kern_pgdir;
f0102936:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102938:	c7 c0 28 10 19 f0    	mov    $0xf0191028,%eax
f010293e:	8b 00                	mov    (%eax),%eax
f0102940:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102943:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010294a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010294f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102952:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0102958:	8b 00                	mov    (%eax),%eax
f010295a:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010295d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102960:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0102966:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f0102969:	bb 00 00 00 00       	mov    $0x0,%ebx
f010296e:	e9 57 08 00 00       	jmp    f01031ca <mem_init+0x1721>
	assert(nfree == 0);
f0102973:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102976:	8d 83 40 8b f7 ff    	lea    -0x874c0(%ebx),%eax
f010297c:	50                   	push   %eax
f010297d:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102983:	50                   	push   %eax
f0102984:	68 02 03 00 00       	push   $0x302
f0102989:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010298f:	50                   	push   %eax
f0102990:	e8 1c d7 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102995:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102998:	8d 83 4e 8a f7 ff    	lea    -0x875b2(%ebx),%eax
f010299e:	50                   	push   %eax
f010299f:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01029a5:	50                   	push   %eax
f01029a6:	68 64 03 00 00       	push   $0x364
f01029ab:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01029b1:	50                   	push   %eax
f01029b2:	e8 fa d6 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01029b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029ba:	8d 83 64 8a f7 ff    	lea    -0x8759c(%ebx),%eax
f01029c0:	50                   	push   %eax
f01029c1:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01029c7:	50                   	push   %eax
f01029c8:	68 65 03 00 00       	push   $0x365
f01029cd:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01029d3:	50                   	push   %eax
f01029d4:	e8 d8 d6 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01029d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029dc:	8d 83 7a 8a f7 ff    	lea    -0x87586(%ebx),%eax
f01029e2:	50                   	push   %eax
f01029e3:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01029e9:	50                   	push   %eax
f01029ea:	68 66 03 00 00       	push   $0x366
f01029ef:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01029f5:	50                   	push   %eax
f01029f6:	e8 b6 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01029fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029fe:	8d 83 90 8a f7 ff    	lea    -0x87570(%ebx),%eax
f0102a04:	50                   	push   %eax
f0102a05:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102a0b:	50                   	push   %eax
f0102a0c:	68 69 03 00 00       	push   $0x369
f0102a11:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102a17:	50                   	push   %eax
f0102a18:	e8 94 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102a1d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a20:	8d 83 20 83 f7 ff    	lea    -0x87ce0(%ebx),%eax
f0102a26:	50                   	push   %eax
f0102a27:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102a2d:	50                   	push   %eax
f0102a2e:	68 6a 03 00 00       	push   $0x36a
f0102a33:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102a39:	50                   	push   %eax
f0102a3a:	e8 72 d6 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102a3f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a42:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102a48:	50                   	push   %eax
f0102a49:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102a4f:	50                   	push   %eax
f0102a50:	68 71 03 00 00       	push   $0x371
f0102a55:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102a5b:	50                   	push   %eax
f0102a5c:	e8 50 d6 ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102a61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a64:	8d 83 60 83 f7 ff    	lea    -0x87ca0(%ebx),%eax
f0102a6a:	50                   	push   %eax
f0102a6b:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102a71:	50                   	push   %eax
f0102a72:	68 74 03 00 00       	push   $0x374
f0102a77:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102a7d:	50                   	push   %eax
f0102a7e:	e8 2e d6 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102a83:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a86:	8d 83 98 83 f7 ff    	lea    -0x87c68(%ebx),%eax
f0102a8c:	50                   	push   %eax
f0102a8d:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102a93:	50                   	push   %eax
f0102a94:	68 77 03 00 00       	push   $0x377
f0102a99:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102a9f:	50                   	push   %eax
f0102aa0:	e8 0c d6 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102aa5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102aa8:	8d 83 c8 83 f7 ff    	lea    -0x87c38(%ebx),%eax
f0102aae:	50                   	push   %eax
f0102aaf:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102ab5:	50                   	push   %eax
f0102ab6:	68 7b 03 00 00       	push   $0x37b
f0102abb:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102ac1:	50                   	push   %eax
f0102ac2:	e8 ea d5 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ac7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102aca:	8d 83 f8 83 f7 ff    	lea    -0x87c08(%ebx),%eax
f0102ad0:	50                   	push   %eax
f0102ad1:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102ad7:	50                   	push   %eax
f0102ad8:	68 7c 03 00 00       	push   $0x37c
f0102add:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102ae3:	50                   	push   %eax
f0102ae4:	e8 c8 d5 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102ae9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102aec:	8d 83 20 84 f7 ff    	lea    -0x87be0(%ebx),%eax
f0102af2:	50                   	push   %eax
f0102af3:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102af9:	50                   	push   %eax
f0102afa:	68 7d 03 00 00       	push   $0x37d
f0102aff:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102b05:	50                   	push   %eax
f0102b06:	e8 a6 d5 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102b0b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b0e:	8d 83 4b 8b f7 ff    	lea    -0x874b5(%ebx),%eax
f0102b14:	50                   	push   %eax
f0102b15:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102b1b:	50                   	push   %eax
f0102b1c:	68 7e 03 00 00       	push   $0x37e
f0102b21:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102b27:	50                   	push   %eax
f0102b28:	e8 84 d5 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102b2d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b30:	8d 83 5c 8b f7 ff    	lea    -0x874a4(%ebx),%eax
f0102b36:	50                   	push   %eax
f0102b37:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102b3d:	50                   	push   %eax
f0102b3e:	68 7f 03 00 00       	push   $0x37f
f0102b43:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102b49:	50                   	push   %eax
f0102b4a:	e8 62 d5 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102b4f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b52:	8d 83 50 84 f7 ff    	lea    -0x87bb0(%ebx),%eax
f0102b58:	50                   	push   %eax
f0102b59:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102b5f:	50                   	push   %eax
f0102b60:	68 82 03 00 00       	push   $0x382
f0102b65:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102b6b:	50                   	push   %eax
f0102b6c:	e8 40 d5 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102b71:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b74:	8d 83 8c 84 f7 ff    	lea    -0x87b74(%ebx),%eax
f0102b7a:	50                   	push   %eax
f0102b7b:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102b81:	50                   	push   %eax
f0102b82:	68 83 03 00 00       	push   $0x383
f0102b87:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102b8d:	50                   	push   %eax
f0102b8e:	e8 1e d5 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102b93:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b96:	8d 83 6d 8b f7 ff    	lea    -0x87493(%ebx),%eax
f0102b9c:	50                   	push   %eax
f0102b9d:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102ba3:	50                   	push   %eax
f0102ba4:	68 84 03 00 00       	push   $0x384
f0102ba9:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102baf:	50                   	push   %eax
f0102bb0:	e8 fc d4 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102bb5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bb8:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102bbe:	50                   	push   %eax
f0102bbf:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102bc5:	50                   	push   %eax
f0102bc6:	68 87 03 00 00       	push   $0x387
f0102bcb:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102bd1:	50                   	push   %eax
f0102bd2:	e8 da d4 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102bd7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bda:	8d 83 50 84 f7 ff    	lea    -0x87bb0(%ebx),%eax
f0102be0:	50                   	push   %eax
f0102be1:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102be7:	50                   	push   %eax
f0102be8:	68 8a 03 00 00       	push   $0x38a
f0102bed:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102bf3:	50                   	push   %eax
f0102bf4:	e8 b8 d4 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102bf9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bfc:	8d 83 8c 84 f7 ff    	lea    -0x87b74(%ebx),%eax
f0102c02:	50                   	push   %eax
f0102c03:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102c09:	50                   	push   %eax
f0102c0a:	68 8b 03 00 00       	push   $0x38b
f0102c0f:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102c15:	50                   	push   %eax
f0102c16:	e8 96 d4 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102c1b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c1e:	8d 83 6d 8b f7 ff    	lea    -0x87493(%ebx),%eax
f0102c24:	50                   	push   %eax
f0102c25:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102c2b:	50                   	push   %eax
f0102c2c:	68 8c 03 00 00       	push   $0x38c
f0102c31:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102c37:	50                   	push   %eax
f0102c38:	e8 74 d4 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102c3d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c40:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f0102c46:	50                   	push   %eax
f0102c47:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102c4d:	50                   	push   %eax
f0102c4e:	68 90 03 00 00       	push   $0x390
f0102c53:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102c59:	50                   	push   %eax
f0102c5a:	e8 52 d4 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c5f:	50                   	push   %eax
f0102c60:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c63:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f0102c69:	50                   	push   %eax
f0102c6a:	68 93 03 00 00       	push   $0x393
f0102c6f:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102c75:	50                   	push   %eax
f0102c76:	e8 36 d4 ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102c7b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c7e:	8d 83 bc 84 f7 ff    	lea    -0x87b44(%ebx),%eax
f0102c84:	50                   	push   %eax
f0102c85:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102c8b:	50                   	push   %eax
f0102c8c:	68 94 03 00 00       	push   $0x394
f0102c91:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102c97:	50                   	push   %eax
f0102c98:	e8 14 d4 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102c9d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ca0:	8d 83 fc 84 f7 ff    	lea    -0x87b04(%ebx),%eax
f0102ca6:	50                   	push   %eax
f0102ca7:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102cad:	50                   	push   %eax
f0102cae:	68 97 03 00 00       	push   $0x397
f0102cb3:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102cb9:	50                   	push   %eax
f0102cba:	e8 f2 d3 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102cbf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cc2:	8d 83 8c 84 f7 ff    	lea    -0x87b74(%ebx),%eax
f0102cc8:	50                   	push   %eax
f0102cc9:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102ccf:	50                   	push   %eax
f0102cd0:	68 98 03 00 00       	push   $0x398
f0102cd5:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102cdb:	50                   	push   %eax
f0102cdc:	e8 d0 d3 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102ce1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ce4:	8d 83 6d 8b f7 ff    	lea    -0x87493(%ebx),%eax
f0102cea:	50                   	push   %eax
f0102ceb:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102cf1:	50                   	push   %eax
f0102cf2:	68 99 03 00 00       	push   $0x399
f0102cf7:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102cfd:	50                   	push   %eax
f0102cfe:	e8 ae d3 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102d03:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d06:	8d 83 3c 85 f7 ff    	lea    -0x87ac4(%ebx),%eax
f0102d0c:	50                   	push   %eax
f0102d0d:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102d13:	50                   	push   %eax
f0102d14:	68 9a 03 00 00       	push   $0x39a
f0102d19:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102d1f:	50                   	push   %eax
f0102d20:	e8 8c d3 ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102d25:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d28:	8d 83 7e 8b f7 ff    	lea    -0x87482(%ebx),%eax
f0102d2e:	50                   	push   %eax
f0102d2f:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102d35:	50                   	push   %eax
f0102d36:	68 9b 03 00 00       	push   $0x39b
f0102d3b:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102d41:	50                   	push   %eax
f0102d42:	e8 6a d3 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102d47:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d4a:	8d 83 50 84 f7 ff    	lea    -0x87bb0(%ebx),%eax
f0102d50:	50                   	push   %eax
f0102d51:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102d57:	50                   	push   %eax
f0102d58:	68 9e 03 00 00       	push   $0x39e
f0102d5d:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102d63:	50                   	push   %eax
f0102d64:	e8 48 d3 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102d69:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d6c:	8d 83 70 85 f7 ff    	lea    -0x87a90(%ebx),%eax
f0102d72:	50                   	push   %eax
f0102d73:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102d79:	50                   	push   %eax
f0102d7a:	68 9f 03 00 00       	push   $0x39f
f0102d7f:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102d85:	50                   	push   %eax
f0102d86:	e8 26 d3 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102d8b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d8e:	8d 83 a4 85 f7 ff    	lea    -0x87a5c(%ebx),%eax
f0102d94:	50                   	push   %eax
f0102d95:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102d9b:	50                   	push   %eax
f0102d9c:	68 a0 03 00 00       	push   $0x3a0
f0102da1:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102da7:	50                   	push   %eax
f0102da8:	e8 04 d3 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102dad:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102db0:	8d 83 dc 85 f7 ff    	lea    -0x87a24(%ebx),%eax
f0102db6:	50                   	push   %eax
f0102db7:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102dbd:	50                   	push   %eax
f0102dbe:	68 a3 03 00 00       	push   $0x3a3
f0102dc3:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102dc9:	50                   	push   %eax
f0102dca:	e8 e2 d2 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102dcf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dd2:	8d 83 14 86 f7 ff    	lea    -0x879ec(%ebx),%eax
f0102dd8:	50                   	push   %eax
f0102dd9:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102ddf:	50                   	push   %eax
f0102de0:	68 a6 03 00 00       	push   $0x3a6
f0102de5:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102deb:	50                   	push   %eax
f0102dec:	e8 c0 d2 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102df1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102df4:	8d 83 a4 85 f7 ff    	lea    -0x87a5c(%ebx),%eax
f0102dfa:	50                   	push   %eax
f0102dfb:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102e01:	50                   	push   %eax
f0102e02:	68 a7 03 00 00       	push   $0x3a7
f0102e07:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102e0d:	50                   	push   %eax
f0102e0e:	e8 9e d2 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102e13:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e16:	8d 83 50 86 f7 ff    	lea    -0x879b0(%ebx),%eax
f0102e1c:	50                   	push   %eax
f0102e1d:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102e23:	50                   	push   %eax
f0102e24:	68 aa 03 00 00       	push   $0x3aa
f0102e29:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102e2f:	50                   	push   %eax
f0102e30:	e8 7c d2 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102e35:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e38:	8d 83 7c 86 f7 ff    	lea    -0x87984(%ebx),%eax
f0102e3e:	50                   	push   %eax
f0102e3f:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102e45:	50                   	push   %eax
f0102e46:	68 ab 03 00 00       	push   $0x3ab
f0102e4b:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102e51:	50                   	push   %eax
f0102e52:	e8 5a d2 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f0102e57:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e5a:	8d 83 94 8b f7 ff    	lea    -0x8746c(%ebx),%eax
f0102e60:	50                   	push   %eax
f0102e61:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102e67:	50                   	push   %eax
f0102e68:	68 ad 03 00 00       	push   $0x3ad
f0102e6d:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102e73:	50                   	push   %eax
f0102e74:	e8 38 d2 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102e79:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e7c:	8d 83 a5 8b f7 ff    	lea    -0x8745b(%ebx),%eax
f0102e82:	50                   	push   %eax
f0102e83:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102e89:	50                   	push   %eax
f0102e8a:	68 ae 03 00 00       	push   $0x3ae
f0102e8f:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102e95:	50                   	push   %eax
f0102e96:	e8 16 d2 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102e9b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e9e:	8d 83 ac 86 f7 ff    	lea    -0x87954(%ebx),%eax
f0102ea4:	50                   	push   %eax
f0102ea5:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102eab:	50                   	push   %eax
f0102eac:	68 b1 03 00 00       	push   $0x3b1
f0102eb1:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102eb7:	50                   	push   %eax
f0102eb8:	e8 f4 d1 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102ebd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ec0:	8d 83 d0 86 f7 ff    	lea    -0x87930(%ebx),%eax
f0102ec6:	50                   	push   %eax
f0102ec7:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102ecd:	50                   	push   %eax
f0102ece:	68 b5 03 00 00       	push   $0x3b5
f0102ed3:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102ed9:	50                   	push   %eax
f0102eda:	e8 d2 d1 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102edf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ee2:	8d 83 7c 86 f7 ff    	lea    -0x87984(%ebx),%eax
f0102ee8:	50                   	push   %eax
f0102ee9:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102eef:	50                   	push   %eax
f0102ef0:	68 b6 03 00 00       	push   $0x3b6
f0102ef5:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102efb:	50                   	push   %eax
f0102efc:	e8 b0 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102f01:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f04:	8d 83 4b 8b f7 ff    	lea    -0x874b5(%ebx),%eax
f0102f0a:	50                   	push   %eax
f0102f0b:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102f11:	50                   	push   %eax
f0102f12:	68 b7 03 00 00       	push   $0x3b7
f0102f17:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102f1d:	50                   	push   %eax
f0102f1e:	e8 8e d1 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102f23:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f26:	8d 83 a5 8b f7 ff    	lea    -0x8745b(%ebx),%eax
f0102f2c:	50                   	push   %eax
f0102f2d:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102f33:	50                   	push   %eax
f0102f34:	68 b8 03 00 00       	push   $0x3b8
f0102f39:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102f3f:	50                   	push   %eax
f0102f40:	e8 6c d1 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102f45:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f48:	8d 83 f4 86 f7 ff    	lea    -0x8790c(%ebx),%eax
f0102f4e:	50                   	push   %eax
f0102f4f:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102f55:	50                   	push   %eax
f0102f56:	68 bb 03 00 00       	push   $0x3bb
f0102f5b:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102f61:	50                   	push   %eax
f0102f62:	e8 4a d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f0102f67:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f6a:	8d 83 b6 8b f7 ff    	lea    -0x8744a(%ebx),%eax
f0102f70:	50                   	push   %eax
f0102f71:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102f77:	50                   	push   %eax
f0102f78:	68 bc 03 00 00       	push   $0x3bc
f0102f7d:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102f83:	50                   	push   %eax
f0102f84:	e8 28 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f0102f89:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f8c:	8d 83 c2 8b f7 ff    	lea    -0x8743e(%ebx),%eax
f0102f92:	50                   	push   %eax
f0102f93:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102f99:	50                   	push   %eax
f0102f9a:	68 bd 03 00 00       	push   $0x3bd
f0102f9f:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102fa5:	50                   	push   %eax
f0102fa6:	e8 06 d1 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102fab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fae:	8d 83 d0 86 f7 ff    	lea    -0x87930(%ebx),%eax
f0102fb4:	50                   	push   %eax
f0102fb5:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102fbb:	50                   	push   %eax
f0102fbc:	68 c1 03 00 00       	push   $0x3c1
f0102fc1:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102fc7:	50                   	push   %eax
f0102fc8:	e8 e4 d0 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102fcd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fd0:	8d 83 2c 87 f7 ff    	lea    -0x878d4(%ebx),%eax
f0102fd6:	50                   	push   %eax
f0102fd7:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102fdd:	50                   	push   %eax
f0102fde:	68 c2 03 00 00       	push   $0x3c2
f0102fe3:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0102fe9:	50                   	push   %eax
f0102fea:	e8 c2 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102fef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ff2:	8d 83 d7 8b f7 ff    	lea    -0x87429(%ebx),%eax
f0102ff8:	50                   	push   %eax
f0102ff9:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0102fff:	50                   	push   %eax
f0103000:	68 c3 03 00 00       	push   $0x3c3
f0103005:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010300b:	50                   	push   %eax
f010300c:	e8 a0 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0103011:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103014:	8d 83 a5 8b f7 ff    	lea    -0x8745b(%ebx),%eax
f010301a:	50                   	push   %eax
f010301b:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103021:	50                   	push   %eax
f0103022:	68 c4 03 00 00       	push   $0x3c4
f0103027:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010302d:	50                   	push   %eax
f010302e:	e8 7e d0 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0103033:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103036:	8d 83 54 87 f7 ff    	lea    -0x878ac(%ebx),%eax
f010303c:	50                   	push   %eax
f010303d:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103043:	50                   	push   %eax
f0103044:	68 c7 03 00 00       	push   $0x3c7
f0103049:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010304f:	50                   	push   %eax
f0103050:	e8 5c d0 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0103055:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103058:	8d 83 f9 8a f7 ff    	lea    -0x87507(%ebx),%eax
f010305e:	50                   	push   %eax
f010305f:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103065:	50                   	push   %eax
f0103066:	68 ca 03 00 00       	push   $0x3ca
f010306b:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103071:	50                   	push   %eax
f0103072:	e8 3a d0 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103077:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010307a:	8d 83 f8 83 f7 ff    	lea    -0x87c08(%ebx),%eax
f0103080:	50                   	push   %eax
f0103081:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103087:	50                   	push   %eax
f0103088:	68 cd 03 00 00       	push   $0x3cd
f010308d:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103093:	50                   	push   %eax
f0103094:	e8 18 d0 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0103099:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010309c:	8d 83 5c 8b f7 ff    	lea    -0x874a4(%ebx),%eax
f01030a2:	50                   	push   %eax
f01030a3:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01030a9:	50                   	push   %eax
f01030aa:	68 cf 03 00 00       	push   $0x3cf
f01030af:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01030b5:	50                   	push   %eax
f01030b6:	e8 f6 cf ff ff       	call   f01000b1 <_panic>
f01030bb:	52                   	push   %edx
f01030bc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030bf:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f01030c5:	50                   	push   %eax
f01030c6:	68 d6 03 00 00       	push   $0x3d6
f01030cb:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01030d1:	50                   	push   %eax
f01030d2:	e8 da cf ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01030d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030da:	8d 83 e8 8b f7 ff    	lea    -0x87418(%ebx),%eax
f01030e0:	50                   	push   %eax
f01030e1:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01030e7:	50                   	push   %eax
f01030e8:	68 d7 03 00 00       	push   $0x3d7
f01030ed:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01030f3:	50                   	push   %eax
f01030f4:	e8 b8 cf ff ff       	call   f01000b1 <_panic>
f01030f9:	50                   	push   %eax
f01030fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030fd:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f0103103:	50                   	push   %eax
f0103104:	6a 56                	push   $0x56
f0103106:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f010310c:	50                   	push   %eax
f010310d:	e8 9f cf ff ff       	call   f01000b1 <_panic>
f0103112:	52                   	push   %edx
f0103113:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103116:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f010311c:	50                   	push   %eax
f010311d:	6a 56                	push   $0x56
f010311f:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f0103125:	50                   	push   %eax
f0103126:	e8 86 cf ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010312b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010312e:	8d 83 00 8c f7 ff    	lea    -0x87400(%ebx),%eax
f0103134:	50                   	push   %eax
f0103135:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010313b:	50                   	push   %eax
f010313c:	68 e1 03 00 00       	push   $0x3e1
f0103141:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103147:	50                   	push   %eax
f0103148:	e8 64 cf ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010314d:	50                   	push   %eax
f010314e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103151:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f0103157:	50                   	push   %eax
f0103158:	68 ba 00 00 00       	push   $0xba
f010315d:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103163:	50                   	push   %eax
f0103164:	e8 48 cf ff ff       	call   f01000b1 <_panic>
f0103169:	50                   	push   %eax
f010316a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010316d:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f0103173:	50                   	push   %eax
f0103174:	68 c2 00 00 00       	push   $0xc2
f0103179:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010317f:	50                   	push   %eax
f0103180:	e8 2c cf ff ff       	call   f01000b1 <_panic>
f0103185:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103188:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f010318e:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f0103194:	50                   	push   %eax
f0103195:	68 ce 00 00 00       	push   $0xce
f010319a:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01031a0:	50                   	push   %eax
f01031a1:	e8 0b cf ff ff       	call   f01000b1 <_panic>
f01031a6:	ff 75 c0             	pushl  -0x40(%ebp)
f01031a9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031ac:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f01031b2:	50                   	push   %eax
f01031b3:	68 1a 03 00 00       	push   $0x31a
f01031b8:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01031be:	50                   	push   %eax
f01031bf:	e8 ed ce ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f01031c4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01031ca:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f01031cd:	76 3f                	jbe    f010320e <mem_init+0x1765>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01031cf:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01031d5:	89 f0                	mov    %esi,%eax
f01031d7:	e8 67 e0 ff ff       	call   f0101243 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01031dc:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01031e3:	76 c1                	jbe    f01031a6 <mem_init+0x16fd>
f01031e5:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f01031e8:	39 d0                	cmp    %edx,%eax
f01031ea:	74 d8                	je     f01031c4 <mem_init+0x171b>
f01031ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031ef:	8d 83 78 87 f7 ff    	lea    -0x87888(%ebx),%eax
f01031f5:	50                   	push   %eax
f01031f6:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01031fc:	50                   	push   %eax
f01031fd:	68 1a 03 00 00       	push   $0x31a
f0103202:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103208:	50                   	push   %eax
f0103209:	e8 a3 ce ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010320e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103211:	c7 c0 68 03 19 f0    	mov    $0xf0190368,%eax
f0103217:	8b 00                	mov    (%eax),%eax
f0103219:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010321c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010321f:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0103224:	8d 98 00 00 40 21    	lea    0x21400000(%eax),%ebx
f010322a:	89 fa                	mov    %edi,%edx
f010322c:	89 f0                	mov    %esi,%eax
f010322e:	e8 10 e0 ff ff       	call   f0101243 <check_va2pa>
f0103233:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010323a:	76 3d                	jbe    f0103279 <mem_init+0x17d0>
f010323c:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f010323f:	39 d0                	cmp    %edx,%eax
f0103241:	75 54                	jne    f0103297 <mem_init+0x17ee>
f0103243:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0103249:	81 ff 00 80 c1 ee    	cmp    $0xeec18000,%edi
f010324f:	75 d9                	jne    f010322a <mem_init+0x1781>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103251:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103254:	c1 e7 0c             	shl    $0xc,%edi
f0103257:	bb 00 00 00 00       	mov    $0x0,%ebx
f010325c:	39 fb                	cmp    %edi,%ebx
f010325e:	73 7b                	jae    f01032db <mem_init+0x1832>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103260:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0103266:	89 f0                	mov    %esi,%eax
f0103268:	e8 d6 df ff ff       	call   f0101243 <check_va2pa>
f010326d:	39 c3                	cmp    %eax,%ebx
f010326f:	75 48                	jne    f01032b9 <mem_init+0x1810>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103271:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103277:	eb e3                	jmp    f010325c <mem_init+0x17b3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103279:	ff 75 cc             	pushl  -0x34(%ebp)
f010327c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010327f:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f0103285:	50                   	push   %eax
f0103286:	68 23 03 00 00       	push   $0x323
f010328b:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103291:	50                   	push   %eax
f0103292:	e8 1a ce ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103297:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010329a:	8d 83 ac 87 f7 ff    	lea    -0x87854(%ebx),%eax
f01032a0:	50                   	push   %eax
f01032a1:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01032a7:	50                   	push   %eax
f01032a8:	68 23 03 00 00       	push   $0x323
f01032ad:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01032b3:	50                   	push   %eax
f01032b4:	e8 f8 cd ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01032b9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032bc:	8d 83 e0 87 f7 ff    	lea    -0x87820(%ebx),%eax
f01032c2:	50                   	push   %eax
f01032c3:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01032c9:	50                   	push   %eax
f01032ca:	68 27 03 00 00       	push   $0x327
f01032cf:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01032d5:	50                   	push   %eax
f01032d6:	e8 d6 cd ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01032db:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01032e0:	8b 7d c8             	mov    -0x38(%ebp),%edi
f01032e3:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f01032e9:	89 da                	mov    %ebx,%edx
f01032eb:	89 f0                	mov    %esi,%eax
f01032ed:	e8 51 df ff ff       	call   f0101243 <check_va2pa>
f01032f2:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f01032f5:	39 c2                	cmp    %eax,%edx
f01032f7:	75 26                	jne    f010331f <mem_init+0x1876>
f01032f9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01032ff:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0103305:	75 e2                	jne    f01032e9 <mem_init+0x1840>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0103307:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010330c:	89 f0                	mov    %esi,%eax
f010330e:	e8 30 df ff ff       	call   f0101243 <check_va2pa>
f0103313:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103316:	75 29                	jne    f0103341 <mem_init+0x1898>
	for (i = 0; i < NPDENTRIES; i++) {
f0103318:	b8 00 00 00 00       	mov    $0x0,%eax
f010331d:	eb 6d                	jmp    f010338c <mem_init+0x18e3>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010331f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103322:	8d 83 08 88 f7 ff    	lea    -0x877f8(%ebx),%eax
f0103328:	50                   	push   %eax
f0103329:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010332f:	50                   	push   %eax
f0103330:	68 2b 03 00 00       	push   $0x32b
f0103335:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010333b:	50                   	push   %eax
f010333c:	e8 70 cd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0103341:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103344:	8d 83 50 88 f7 ff    	lea    -0x877b0(%ebx),%eax
f010334a:	50                   	push   %eax
f010334b:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103351:	50                   	push   %eax
f0103352:	68 2c 03 00 00       	push   $0x32c
f0103357:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010335d:	50                   	push   %eax
f010335e:	e8 4e cd ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0103363:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0103367:	74 52                	je     f01033bb <mem_init+0x1912>
	for (i = 0; i < NPDENTRIES; i++) {
f0103369:	83 c0 01             	add    $0x1,%eax
f010336c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0103371:	0f 87 bb 00 00 00    	ja     f0103432 <mem_init+0x1989>
		switch (i) {
f0103377:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010337c:	72 0e                	jb     f010338c <mem_init+0x18e3>
f010337e:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0103383:	76 de                	jbe    f0103363 <mem_init+0x18ba>
f0103385:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010338a:	74 d7                	je     f0103363 <mem_init+0x18ba>
			if (i >= PDX(KERNBASE)) {
f010338c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103391:	77 4a                	ja     f01033dd <mem_init+0x1934>
				assert(pgdir[i] == 0);
f0103393:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0103397:	74 d0                	je     f0103369 <mem_init+0x18c0>
f0103399:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010339c:	8d 83 52 8c f7 ff    	lea    -0x873ae(%ebx),%eax
f01033a2:	50                   	push   %eax
f01033a3:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01033a9:	50                   	push   %eax
f01033aa:	68 3c 03 00 00       	push   $0x33c
f01033af:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01033b5:	50                   	push   %eax
f01033b6:	e8 f6 cc ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f01033bb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01033be:	8d 83 30 8c f7 ff    	lea    -0x873d0(%ebx),%eax
f01033c4:	50                   	push   %eax
f01033c5:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01033cb:	50                   	push   %eax
f01033cc:	68 35 03 00 00       	push   $0x335
f01033d1:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01033d7:	50                   	push   %eax
f01033d8:	e8 d4 cc ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f01033dd:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01033e0:	f6 c2 01             	test   $0x1,%dl
f01033e3:	74 2b                	je     f0103410 <mem_init+0x1967>
				assert(pgdir[i] & PTE_W);
f01033e5:	f6 c2 02             	test   $0x2,%dl
f01033e8:	0f 85 7b ff ff ff    	jne    f0103369 <mem_init+0x18c0>
f01033ee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01033f1:	8d 83 41 8c f7 ff    	lea    -0x873bf(%ebx),%eax
f01033f7:	50                   	push   %eax
f01033f8:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01033fe:	50                   	push   %eax
f01033ff:	68 3a 03 00 00       	push   $0x33a
f0103404:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010340a:	50                   	push   %eax
f010340b:	e8 a1 cc ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0103410:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103413:	8d 83 30 8c f7 ff    	lea    -0x873d0(%ebx),%eax
f0103419:	50                   	push   %eax
f010341a:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103420:	50                   	push   %eax
f0103421:	68 39 03 00 00       	push   $0x339
f0103426:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010342c:	50                   	push   %eax
f010342d:	e8 7f cc ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0103432:	83 ec 0c             	sub    $0xc,%esp
f0103435:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0103438:	8d 86 80 88 f7 ff    	lea    -0x87780(%esi),%eax
f010343e:	50                   	push   %eax
f010343f:	89 f3                	mov    %esi,%ebx
f0103441:	e8 f9 0d 00 00       	call   f010423f <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103446:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f010344c:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010344e:	83 c4 10             	add    $0x10,%esp
f0103451:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103456:	0f 86 73 02 00 00    	jbe    f01036cf <mem_init+0x1c26>
	return (physaddr_t)kva - KERNBASE;
f010345c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103461:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103464:	b8 00 00 00 00       	mov    $0x0,%eax
f0103469:	e8 52 de ff ff       	call   f01012c0 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010346e:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0103471:	83 e0 f3             	and    $0xfffffff3,%eax
f0103474:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0103479:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010347c:	83 ec 0c             	sub    $0xc,%esp
f010347f:	6a 00                	push   $0x0
f0103481:	e8 df e2 ff ff       	call   f0101765 <page_alloc>
f0103486:	89 c6                	mov    %eax,%esi
f0103488:	83 c4 10             	add    $0x10,%esp
f010348b:	85 c0                	test   %eax,%eax
f010348d:	0f 84 58 02 00 00    	je     f01036eb <mem_init+0x1c42>
	assert((pp1 = page_alloc(0)));
f0103493:	83 ec 0c             	sub    $0xc,%esp
f0103496:	6a 00                	push   $0x0
f0103498:	e8 c8 e2 ff ff       	call   f0101765 <page_alloc>
f010349d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01034a0:	83 c4 10             	add    $0x10,%esp
f01034a3:	85 c0                	test   %eax,%eax
f01034a5:	0f 84 62 02 00 00    	je     f010370d <mem_init+0x1c64>
	assert((pp2 = page_alloc(0)));
f01034ab:	83 ec 0c             	sub    $0xc,%esp
f01034ae:	6a 00                	push   $0x0
f01034b0:	e8 b0 e2 ff ff       	call   f0101765 <page_alloc>
f01034b5:	89 c7                	mov    %eax,%edi
f01034b7:	83 c4 10             	add    $0x10,%esp
f01034ba:	85 c0                	test   %eax,%eax
f01034bc:	0f 84 6d 02 00 00    	je     f010372f <mem_init+0x1c86>
	page_free(pp0);
f01034c2:	83 ec 0c             	sub    $0xc,%esp
f01034c5:	56                   	push   %esi
f01034c6:	e8 22 e3 ff ff       	call   f01017ed <page_free>
	return (pp - pages) << PGSHIFT;
f01034cb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01034ce:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f01034d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01034d7:	2b 08                	sub    (%eax),%ecx
f01034d9:	89 c8                	mov    %ecx,%eax
f01034db:	c1 f8 03             	sar    $0x3,%eax
f01034de:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01034e1:	89 c1                	mov    %eax,%ecx
f01034e3:	c1 e9 0c             	shr    $0xc,%ecx
f01034e6:	83 c4 10             	add    $0x10,%esp
f01034e9:	c7 c2 28 10 19 f0    	mov    $0xf0191028,%edx
f01034ef:	3b 0a                	cmp    (%edx),%ecx
f01034f1:	0f 83 5a 02 00 00    	jae    f0103751 <mem_init+0x1ca8>
	memset(page2kva(pp1), 1, PGSIZE);
f01034f7:	83 ec 04             	sub    $0x4,%esp
f01034fa:	68 00 10 00 00       	push   $0x1000
f01034ff:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103501:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103506:	50                   	push   %eax
f0103507:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010350a:	e8 19 22 00 00       	call   f0105728 <memset>
	return (pp - pages) << PGSHIFT;
f010350f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103512:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0103518:	89 f9                	mov    %edi,%ecx
f010351a:	2b 08                	sub    (%eax),%ecx
f010351c:	89 c8                	mov    %ecx,%eax
f010351e:	c1 f8 03             	sar    $0x3,%eax
f0103521:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103524:	89 c1                	mov    %eax,%ecx
f0103526:	c1 e9 0c             	shr    $0xc,%ecx
f0103529:	83 c4 10             	add    $0x10,%esp
f010352c:	c7 c2 28 10 19 f0    	mov    $0xf0191028,%edx
f0103532:	3b 0a                	cmp    (%edx),%ecx
f0103534:	0f 83 2d 02 00 00    	jae    f0103767 <mem_init+0x1cbe>
	memset(page2kva(pp2), 2, PGSIZE);
f010353a:	83 ec 04             	sub    $0x4,%esp
f010353d:	68 00 10 00 00       	push   $0x1000
f0103542:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0103544:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103549:	50                   	push   %eax
f010354a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010354d:	e8 d6 21 00 00       	call   f0105728 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103552:	6a 02                	push   $0x2
f0103554:	68 00 10 00 00       	push   $0x1000
f0103559:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010355c:	53                   	push   %ebx
f010355d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103560:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0103566:	ff 30                	pushl  (%eax)
f0103568:	e8 c4 e4 ff ff       	call   f0101a31 <page_insert>
	assert(pp1->pp_ref == 1);
f010356d:	83 c4 20             	add    $0x20,%esp
f0103570:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103575:	0f 85 02 02 00 00    	jne    f010377d <mem_init+0x1cd4>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010357b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103582:	01 01 01 
f0103585:	0f 85 14 02 00 00    	jne    f010379f <mem_init+0x1cf6>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010358b:	6a 02                	push   $0x2
f010358d:	68 00 10 00 00       	push   $0x1000
f0103592:	57                   	push   %edi
f0103593:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103596:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f010359c:	ff 30                	pushl  (%eax)
f010359e:	e8 8e e4 ff ff       	call   f0101a31 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01035a3:	83 c4 10             	add    $0x10,%esp
f01035a6:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01035ad:	02 02 02 
f01035b0:	0f 85 0b 02 00 00    	jne    f01037c1 <mem_init+0x1d18>
	assert(pp2->pp_ref == 1);
f01035b6:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01035bb:	0f 85 22 02 00 00    	jne    f01037e3 <mem_init+0x1d3a>
	assert(pp1->pp_ref == 0);
f01035c1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01035c4:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01035c9:	0f 85 36 02 00 00    	jne    f0103805 <mem_init+0x1d5c>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01035cf:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01035d6:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01035d9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035dc:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f01035e2:	89 f9                	mov    %edi,%ecx
f01035e4:	2b 08                	sub    (%eax),%ecx
f01035e6:	89 c8                	mov    %ecx,%eax
f01035e8:	c1 f8 03             	sar    $0x3,%eax
f01035eb:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01035ee:	89 c1                	mov    %eax,%ecx
f01035f0:	c1 e9 0c             	shr    $0xc,%ecx
f01035f3:	c7 c2 28 10 19 f0    	mov    $0xf0191028,%edx
f01035f9:	3b 0a                	cmp    (%edx),%ecx
f01035fb:	0f 83 26 02 00 00    	jae    f0103827 <mem_init+0x1d7e>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103601:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103608:	03 03 03 
f010360b:	0f 85 2c 02 00 00    	jne    f010383d <mem_init+0x1d94>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103611:	83 ec 08             	sub    $0x8,%esp
f0103614:	68 00 10 00 00       	push   $0x1000
f0103619:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010361c:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0103622:	ff 30                	pushl  (%eax)
f0103624:	e8 c9 e3 ff ff       	call   f01019f2 <page_remove>
	assert(pp2->pp_ref == 0);
f0103629:	83 c4 10             	add    $0x10,%esp
f010362c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103631:	0f 85 28 02 00 00    	jne    f010385f <mem_init+0x1db6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103637:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010363a:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0103640:	8b 08                	mov    (%eax),%ecx
f0103642:	8b 11                	mov    (%ecx),%edx
f0103644:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010364a:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0103650:	89 f7                	mov    %esi,%edi
f0103652:	2b 38                	sub    (%eax),%edi
f0103654:	89 f8                	mov    %edi,%eax
f0103656:	c1 f8 03             	sar    $0x3,%eax
f0103659:	c1 e0 0c             	shl    $0xc,%eax
f010365c:	39 c2                	cmp    %eax,%edx
f010365e:	0f 85 1d 02 00 00    	jne    f0103881 <mem_init+0x1dd8>
	kern_pgdir[0] = 0;
f0103664:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010366a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010366f:	0f 85 2e 02 00 00    	jne    f01038a3 <mem_init+0x1dfa>
	pp0->pp_ref = 0;
f0103675:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010367b:	83 ec 0c             	sub    $0xc,%esp
f010367e:	56                   	push   %esi
f010367f:	e8 69 e1 ff ff       	call   f01017ed <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103684:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103687:	8d 87 14 89 f7 ff    	lea    -0x876ec(%edi),%eax
f010368d:	89 04 24             	mov    %eax,(%esp)
f0103690:	89 fb                	mov    %edi,%ebx
f0103692:	e8 a8 0b 00 00       	call   f010423f <cprintf>
	pte_ans = pgdir_walk(kern_pgdir, (void *)0x12345678, 1);
f0103697:	83 c4 0c             	add    $0xc,%esp
f010369a:	6a 01                	push   $0x1
f010369c:	68 78 56 34 12       	push   $0x12345678
f01036a1:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f01036a7:	ff 30                	pushl  (%eax)
f01036a9:	e8 da e1 ff ff       	call   f0101888 <pgdir_walk>
	cprintf("info is %x\n", *(int *)PTE_ADDR(pte_ans));
f01036ae:	83 c4 08             	add    $0x8,%esp
f01036b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01036b6:	ff 30                	pushl  (%eax)
f01036b8:	8d 87 60 8c f7 ff    	lea    -0x873a0(%edi),%eax
f01036be:	50                   	push   %eax
f01036bf:	e8 7b 0b 00 00       	call   f010423f <cprintf>
}
f01036c4:	83 c4 10             	add    $0x10,%esp
f01036c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036ca:	5b                   	pop    %ebx
f01036cb:	5e                   	pop    %esi
f01036cc:	5f                   	pop    %edi
f01036cd:	5d                   	pop    %ebp
f01036ce:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036cf:	50                   	push   %eax
f01036d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01036d3:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f01036d9:	50                   	push   %eax
f01036da:	68 e4 00 00 00       	push   $0xe4
f01036df:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01036e5:	50                   	push   %eax
f01036e6:	e8 c6 c9 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01036eb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01036ee:	8d 83 4e 8a f7 ff    	lea    -0x875b2(%ebx),%eax
f01036f4:	50                   	push   %eax
f01036f5:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01036fb:	50                   	push   %eax
f01036fc:	68 fc 03 00 00       	push   $0x3fc
f0103701:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103707:	50                   	push   %eax
f0103708:	e8 a4 c9 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f010370d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103710:	8d 83 64 8a f7 ff    	lea    -0x8759c(%ebx),%eax
f0103716:	50                   	push   %eax
f0103717:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010371d:	50                   	push   %eax
f010371e:	68 fd 03 00 00       	push   $0x3fd
f0103723:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103729:	50                   	push   %eax
f010372a:	e8 82 c9 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f010372f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103732:	8d 83 7a 8a f7 ff    	lea    -0x87586(%ebx),%eax
f0103738:	50                   	push   %eax
f0103739:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010373f:	50                   	push   %eax
f0103740:	68 fe 03 00 00       	push   $0x3fe
f0103745:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010374b:	50                   	push   %eax
f010374c:	e8 60 c9 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103751:	50                   	push   %eax
f0103752:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f0103758:	50                   	push   %eax
f0103759:	6a 56                	push   $0x56
f010375b:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f0103761:	50                   	push   %eax
f0103762:	e8 4a c9 ff ff       	call   f01000b1 <_panic>
f0103767:	50                   	push   %eax
f0103768:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f010376e:	50                   	push   %eax
f010376f:	6a 56                	push   $0x56
f0103771:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f0103777:	50                   	push   %eax
f0103778:	e8 34 c9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010377d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103780:	8d 83 4b 8b f7 ff    	lea    -0x874b5(%ebx),%eax
f0103786:	50                   	push   %eax
f0103787:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010378d:	50                   	push   %eax
f010378e:	68 03 04 00 00       	push   $0x403
f0103793:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103799:	50                   	push   %eax
f010379a:	e8 12 c9 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010379f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01037a2:	8d 83 a0 88 f7 ff    	lea    -0x87760(%ebx),%eax
f01037a8:	50                   	push   %eax
f01037a9:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01037af:	50                   	push   %eax
f01037b0:	68 04 04 00 00       	push   $0x404
f01037b5:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01037bb:	50                   	push   %eax
f01037bc:	e8 f0 c8 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01037c1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01037c4:	8d 83 c4 88 f7 ff    	lea    -0x8773c(%ebx),%eax
f01037ca:	50                   	push   %eax
f01037cb:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01037d1:	50                   	push   %eax
f01037d2:	68 06 04 00 00       	push   $0x406
f01037d7:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01037dd:	50                   	push   %eax
f01037de:	e8 ce c8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01037e3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01037e6:	8d 83 6d 8b f7 ff    	lea    -0x87493(%ebx),%eax
f01037ec:	50                   	push   %eax
f01037ed:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01037f3:	50                   	push   %eax
f01037f4:	68 07 04 00 00       	push   $0x407
f01037f9:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01037ff:	50                   	push   %eax
f0103800:	e8 ac c8 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0103805:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103808:	8d 83 d7 8b f7 ff    	lea    -0x87429(%ebx),%eax
f010380e:	50                   	push   %eax
f010380f:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103815:	50                   	push   %eax
f0103816:	68 08 04 00 00       	push   $0x408
f010381b:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103821:	50                   	push   %eax
f0103822:	e8 8a c8 ff ff       	call   f01000b1 <_panic>
f0103827:	50                   	push   %eax
f0103828:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f010382e:	50                   	push   %eax
f010382f:	6a 56                	push   $0x56
f0103831:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f0103837:	50                   	push   %eax
f0103838:	e8 74 c8 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010383d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103840:	8d 83 e8 88 f7 ff    	lea    -0x87718(%ebx),%eax
f0103846:	50                   	push   %eax
f0103847:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010384d:	50                   	push   %eax
f010384e:	68 0a 04 00 00       	push   $0x40a
f0103853:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f0103859:	50                   	push   %eax
f010385a:	e8 52 c8 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f010385f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103862:	8d 83 a5 8b f7 ff    	lea    -0x8745b(%ebx),%eax
f0103868:	50                   	push   %eax
f0103869:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010386f:	50                   	push   %eax
f0103870:	68 0c 04 00 00       	push   $0x40c
f0103875:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010387b:	50                   	push   %eax
f010387c:	e8 30 c8 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103881:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103884:	8d 83 f8 83 f7 ff    	lea    -0x87c08(%ebx),%eax
f010388a:	50                   	push   %eax
f010388b:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103891:	50                   	push   %eax
f0103892:	68 0f 04 00 00       	push   $0x40f
f0103897:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f010389d:	50                   	push   %eax
f010389e:	e8 0e c8 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f01038a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01038a6:	8d 83 5c 8b f7 ff    	lea    -0x874a4(%ebx),%eax
f01038ac:	50                   	push   %eax
f01038ad:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f01038b3:	50                   	push   %eax
f01038b4:	68 11 04 00 00       	push   $0x411
f01038b9:	8d 83 75 89 f7 ff    	lea    -0x8768b(%ebx),%eax
f01038bf:	50                   	push   %eax
f01038c0:	e8 ec c7 ff ff       	call   f01000b1 <_panic>

f01038c5 <tlb_invalidate>:
{
f01038c5:	55                   	push   %ebp
f01038c6:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01038c8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038cb:	0f 01 38             	invlpg (%eax)
}
f01038ce:	5d                   	pop    %ebp
f01038cf:	c3                   	ret    

f01038d0 <user_mem_check>:
{
f01038d0:	55                   	push   %ebp
f01038d1:	89 e5                	mov    %esp,%ebp
f01038d3:	57                   	push   %edi
f01038d4:	56                   	push   %esi
f01038d5:	53                   	push   %ebx
f01038d6:	83 ec 20             	sub    $0x20,%esp
f01038d9:	e8 2b ce ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01038de:	05 1a a9 08 00       	add    $0x8a91a,%eax
f01038e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01038e6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01038e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	uintptr_t cur, end = (uintptr_t)ROUNDUP(va + len, PGSIZE);
f01038ec:	89 de                	mov    %ebx,%esi
f01038ee:	03 75 10             	add    0x10(%ebp),%esi
f01038f1:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f01038f7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	pte_t *pte = pgdir_walk(env->env_pgdir, va, 0);
f01038fd:	6a 00                	push   $0x0
f01038ff:	53                   	push   %ebx
f0103900:	ff 77 5c             	pushl  0x5c(%edi)
f0103903:	e8 80 df ff ff       	call   f0101888 <pgdir_walk>
	for (cur = (uintptr_t) va; cur < end; cur = ROUNDDOWN(cur + PGSIZE, PGSIZE))
f0103908:	83 c4 10             	add    $0x10,%esp
f010390b:	39 f3                	cmp    %esi,%ebx
f010390d:	73 48                	jae    f0103957 <user_mem_check+0x87>
		pte = pgdir_walk(env->env_pgdir, (void *)cur, 0);
f010390f:	83 ec 04             	sub    $0x4,%esp
f0103912:	6a 00                	push   $0x0
f0103914:	53                   	push   %ebx
f0103915:	ff 77 5c             	pushl  0x5c(%edi)
f0103918:	e8 6b df ff ff       	call   f0101888 <pgdir_walk>
		if (!pte || cur >= ULIM || !(*pte & perm))
f010391d:	83 c4 10             	add    $0x10,%esp
f0103920:	85 c0                	test   %eax,%eax
f0103922:	74 1d                	je     f0103941 <user_mem_check+0x71>
f0103924:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010392a:	77 15                	ja     f0103941 <user_mem_check+0x71>
f010392c:	8b 00                	mov    (%eax),%eax
f010392e:	85 45 14             	test   %eax,0x14(%ebp)
f0103931:	74 0e                	je     f0103941 <user_mem_check+0x71>
	for (cur = (uintptr_t) va; cur < end; cur = ROUNDDOWN(cur + PGSIZE, PGSIZE))
f0103933:	81 c3 00 20 00 00    	add    $0x2000,%ebx
f0103939:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010393f:	eb ca                	jmp    f010390b <user_mem_check+0x3b>
			user_mem_check_addr = cur;
f0103941:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103944:	89 98 64 21 00 00    	mov    %ebx,0x2164(%eax)
			return -E_FAULT;
f010394a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f010394f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103952:	5b                   	pop    %ebx
f0103953:	5e                   	pop    %esi
f0103954:	5f                   	pop    %edi
f0103955:	5d                   	pop    %ebp
f0103956:	c3                   	ret    
	return 0;
f0103957:	b8 00 00 00 00       	mov    $0x0,%eax
f010395c:	eb f1                	jmp    f010394f <user_mem_check+0x7f>

f010395e <user_mem_assert>:
{
f010395e:	55                   	push   %ebp
f010395f:	89 e5                	mov    %esp,%ebp
f0103961:	56                   	push   %esi
f0103962:	53                   	push   %ebx
f0103963:	e8 ff c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103968:	81 c3 90 a8 08 00    	add    $0x8a890,%ebx
f010396e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103971:	8b 45 14             	mov    0x14(%ebp),%eax
f0103974:	83 c8 04             	or     $0x4,%eax
f0103977:	50                   	push   %eax
f0103978:	ff 75 10             	pushl  0x10(%ebp)
f010397b:	ff 75 0c             	pushl  0xc(%ebp)
f010397e:	56                   	push   %esi
f010397f:	e8 4c ff ff ff       	call   f01038d0 <user_mem_check>
f0103984:	83 c4 10             	add    $0x10,%esp
f0103987:	85 c0                	test   %eax,%eax
f0103989:	78 07                	js     f0103992 <user_mem_assert+0x34>
}
f010398b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010398e:	5b                   	pop    %ebx
f010398f:	5e                   	pop    %esi
f0103990:	5d                   	pop    %ebp
f0103991:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0103992:	83 ec 04             	sub    $0x4,%esp
f0103995:	ff b3 64 21 00 00    	pushl  0x2164(%ebx)
f010399b:	ff 76 48             	pushl  0x48(%esi)
f010399e:	8d 83 40 89 f7 ff    	lea    -0x876c0(%ebx),%eax
f01039a4:	50                   	push   %eax
f01039a5:	e8 95 08 00 00       	call   f010423f <cprintf>
		env_destroy(env);	// may not return
f01039aa:	89 34 24             	mov    %esi,(%esp)
f01039ad:	e8 1f 07 00 00       	call   f01040d1 <env_destroy>
f01039b2:	83 c4 10             	add    $0x10,%esp
}
f01039b5:	eb d4                	jmp    f010398b <user_mem_assert+0x2d>

f01039b7 <__x86.get_pc_thunk.cx>:
f01039b7:	8b 0c 24             	mov    (%esp),%ecx
f01039ba:	c3                   	ret    

f01039bb <__x86.get_pc_thunk.si>:
f01039bb:	8b 34 24             	mov    (%esp),%esi
f01039be:	c3                   	ret    

f01039bf <__x86.get_pc_thunk.di>:
f01039bf:	8b 3c 24             	mov    (%esp),%edi
f01039c2:	c3                   	ret    

f01039c3 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01039c3:	55                   	push   %ebp
f01039c4:	89 e5                	mov    %esp,%ebp
f01039c6:	57                   	push   %edi
f01039c7:	56                   	push   %esi
f01039c8:	53                   	push   %ebx
f01039c9:	83 ec 1c             	sub    $0x1c,%esp
f01039cc:	e8 96 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01039d1:	81 c3 27 a8 08 00    	add    $0x8a827,%ebx
f01039d7:	89 c7                	mov    %eax,%edi
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	struct PageInfo *page = NULL;
	uintptr_t start, end, i;
	
	start = ROUNDDOWN((uintptr_t)va, PGSIZE);
f01039d9:	89 d6                	mov    %edx,%esi
f01039db:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	end = ROUNDUP((uintptr_t)va + len, PGSIZE);
f01039e1:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f01039e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01039ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	for (i = start; i < end; i += PGSIZE)
f01039f0:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01039f3:	73 6a                	jae    f0103a5f <region_alloc+0x9c>
	{
		assert(page = page_alloc(ALLOC_ZERO));
f01039f5:	83 ec 0c             	sub    $0xc,%esp
f01039f8:	6a 01                	push   $0x1
f01039fa:	e8 66 dd ff ff       	call   f0101765 <page_alloc>
f01039ff:	83 c4 10             	add    $0x10,%esp
f0103a02:	85 c0                	test   %eax,%eax
f0103a04:	74 1b                	je     f0103a21 <region_alloc+0x5e>
		assert(!page_insert(e->env_pgdir, page, (void *)i, PTE_U | PTE_W));
f0103a06:	6a 06                	push   $0x6
f0103a08:	56                   	push   %esi
f0103a09:	50                   	push   %eax
f0103a0a:	ff 77 5c             	pushl  0x5c(%edi)
f0103a0d:	e8 1f e0 ff ff       	call   f0101a31 <page_insert>
f0103a12:	83 c4 10             	add    $0x10,%esp
f0103a15:	85 c0                	test   %eax,%eax
f0103a17:	75 27                	jne    f0103a40 <region_alloc+0x7d>
	for (i = start; i < end; i += PGSIZE)
f0103a19:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103a1f:	eb cf                	jmp    f01039f0 <region_alloc+0x2d>
		assert(page = page_alloc(ALLOC_ZERO));
f0103a21:	8d 83 6c 8c f7 ff    	lea    -0x87394(%ebx),%eax
f0103a27:	50                   	push   %eax
f0103a28:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103a2e:	50                   	push   %eax
f0103a2f:	68 27 01 00 00       	push   $0x127
f0103a34:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0103a3a:	50                   	push   %eax
f0103a3b:	e8 71 c6 ff ff       	call   f01000b1 <_panic>
		assert(!page_insert(e->env_pgdir, page, (void *)i, PTE_U | PTE_W));
f0103a40:	8d 83 2c 8d f7 ff    	lea    -0x872d4(%ebx),%eax
f0103a46:	50                   	push   %eax
f0103a47:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103a4d:	50                   	push   %eax
f0103a4e:	68 28 01 00 00       	push   $0x128
f0103a53:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0103a59:	50                   	push   %eax
f0103a5a:	e8 52 c6 ff ff       	call   f01000b1 <_panic>
	}
	return;
}
f0103a5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a62:	5b                   	pop    %ebx
f0103a63:	5e                   	pop    %esi
f0103a64:	5f                   	pop    %edi
f0103a65:	5d                   	pop    %ebp
f0103a66:	c3                   	ret    

f0103a67 <envid2env>:
{
f0103a67:	55                   	push   %ebp
f0103a68:	89 e5                	mov    %esp,%ebp
f0103a6a:	53                   	push   %ebx
f0103a6b:	e8 47 ff ff ff       	call   f01039b7 <__x86.get_pc_thunk.cx>
f0103a70:	81 c1 88 a7 08 00    	add    $0x8a788,%ecx
f0103a76:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	if (envid == 0) {
f0103a7c:	85 d2                	test   %edx,%edx
f0103a7e:	74 41                	je     f0103ac1 <envid2env+0x5a>
	e = &envs[ENVX(envid)];
f0103a80:	89 d0                	mov    %edx,%eax
f0103a82:	25 ff 03 00 00       	and    $0x3ff,%eax
f0103a87:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103a8a:	c1 e0 05             	shl    $0x5,%eax
f0103a8d:	03 81 70 21 00 00    	add    0x2170(%ecx),%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103a93:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0103a97:	74 3a                	je     f0103ad3 <envid2env+0x6c>
f0103a99:	39 50 48             	cmp    %edx,0x48(%eax)
f0103a9c:	75 35                	jne    f0103ad3 <envid2env+0x6c>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103a9e:	84 db                	test   %bl,%bl
f0103aa0:	74 12                	je     f0103ab4 <envid2env+0x4d>
f0103aa2:	8b 91 6c 21 00 00    	mov    0x216c(%ecx),%edx
f0103aa8:	39 c2                	cmp    %eax,%edx
f0103aaa:	74 08                	je     f0103ab4 <envid2env+0x4d>
f0103aac:	8b 5a 48             	mov    0x48(%edx),%ebx
f0103aaf:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f0103ab2:	75 2f                	jne    f0103ae3 <envid2env+0x7c>
	*env_store = e;
f0103ab4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103ab7:	89 03                	mov    %eax,(%ebx)
	return 0;
f0103ab9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103abe:	5b                   	pop    %ebx
f0103abf:	5d                   	pop    %ebp
f0103ac0:	c3                   	ret    
		*env_store = curenv;
f0103ac1:	8b 81 6c 21 00 00    	mov    0x216c(%ecx),%eax
f0103ac7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103aca:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103acc:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ad1:	eb eb                	jmp    f0103abe <envid2env+0x57>
		*env_store = 0;
f0103ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ad6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103adc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103ae1:	eb db                	jmp    f0103abe <envid2env+0x57>
		*env_store = 0;
f0103ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ae6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103aec:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103af1:	eb cb                	jmp    f0103abe <envid2env+0x57>

f0103af3 <env_init_percpu>:
{
f0103af3:	55                   	push   %ebp
f0103af4:	89 e5                	mov    %esp,%ebp
f0103af6:	e8 0e cc ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f0103afb:	05 fd a6 08 00       	add    $0x8a6fd,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103b00:	8d 80 08 1e 00 00    	lea    0x1e08(%eax),%eax
f0103b06:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103b09:	b8 23 00 00 00       	mov    $0x23,%eax
f0103b0e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103b10:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103b12:	b8 10 00 00 00       	mov    $0x10,%eax
f0103b17:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103b19:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103b1b:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103b1d:	ea 24 3b 10 f0 08 00 	ljmp   $0x8,$0xf0103b24
	asm volatile("lldt %0" : : "r" (sel));
f0103b24:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b29:	0f 00 d0             	lldt   %ax
}
f0103b2c:	5d                   	pop    %ebp
f0103b2d:	c3                   	ret    

f0103b2e <env_init>:
{
f0103b2e:	55                   	push   %ebp
f0103b2f:	89 e5                	mov    %esp,%ebp
f0103b31:	53                   	push   %ebx
f0103b32:	e8 7d 06 00 00       	call   f01041b4 <__x86.get_pc_thunk.dx>
f0103b37:	81 c2 c1 a6 08 00    	add    $0x8a6c1,%edx
	env_free_list = envs;
f0103b3d:	8b 82 70 21 00 00    	mov    0x2170(%edx),%eax
f0103b43:	89 82 74 21 00 00    	mov    %eax,0x2174(%edx)
f0103b49:	83 c0 60             	add    $0x60,%eax
	for (i = 0; i < NENV; i++)
f0103b4c:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_link = (i < NENV - 1) ? &envs[i + 1] : NULL;
f0103b51:	bb 00 00 00 00       	mov    $0x0,%ebx
		envs[i].env_id = 0;
f0103b56:	c7 40 e8 00 00 00 00 	movl   $0x0,-0x18(%eax)
		envs[i].env_status = ENV_FREE;
f0103b5d:	c7 40 f4 00 00 00 00 	movl   $0x0,-0xc(%eax)
		envs[i].env_link = (i < NENV - 1) ? &envs[i + 1] : NULL;
f0103b64:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f0103b6a:	89 d9                	mov    %ebx,%ecx
f0103b6c:	0f 42 c8             	cmovb  %eax,%ecx
f0103b6f:	89 48 e4             	mov    %ecx,-0x1c(%eax)
	for (i = 0; i < NENV; i++)
f0103b72:	83 c2 01             	add    $0x1,%edx
f0103b75:	83 c0 60             	add    $0x60,%eax
f0103b78:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103b7e:	75 d6                	jne    f0103b56 <env_init+0x28>
	env_init_percpu();
f0103b80:	e8 6e ff ff ff       	call   f0103af3 <env_init_percpu>
}
f0103b85:	5b                   	pop    %ebx
f0103b86:	5d                   	pop    %ebp
f0103b87:	c3                   	ret    

f0103b88 <env_alloc>:
{
f0103b88:	55                   	push   %ebp
f0103b89:	89 e5                	mov    %esp,%ebp
f0103b8b:	57                   	push   %edi
f0103b8c:	56                   	push   %esi
f0103b8d:	53                   	push   %ebx
f0103b8e:	83 ec 1c             	sub    $0x1c,%esp
f0103b91:	e8 29 fe ff ff       	call   f01039bf <__x86.get_pc_thunk.di>
f0103b96:	81 c7 62 a6 08 00    	add    $0x8a662,%edi
f0103b9c:	89 7d e0             	mov    %edi,-0x20(%ebp)
	if (!(e = env_free_list))
f0103b9f:	8b b7 74 21 00 00    	mov    0x2174(%edi),%esi
f0103ba5:	85 f6                	test   %esi,%esi
f0103ba7:	0f 84 91 01 00 00    	je     f0103d3e <env_alloc+0x1b6>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103bad:	83 ec 0c             	sub    $0xc,%esp
f0103bb0:	6a 01                	push   $0x1
f0103bb2:	89 fb                	mov    %edi,%ebx
f0103bb4:	e8 ac db ff ff       	call   f0101765 <page_alloc>
f0103bb9:	83 c4 10             	add    $0x10,%esp
f0103bbc:	85 c0                	test   %eax,%eax
f0103bbe:	0f 84 81 01 00 00    	je     f0103d45 <env_alloc+0x1bd>
	p->pp_ref++;
f0103bc4:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0103bc9:	c7 c2 30 10 19 f0    	mov    $0xf0191030,%edx
f0103bcf:	2b 02                	sub    (%edx),%eax
f0103bd1:	c1 f8 03             	sar    $0x3,%eax
f0103bd4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103bd7:	89 c1                	mov    %eax,%ecx
f0103bd9:	c1 e9 0c             	shr    $0xc,%ecx
f0103bdc:	c7 c2 28 10 19 f0    	mov    $0xf0191028,%edx
f0103be2:	3b 0a                	cmp    (%edx),%ecx
f0103be4:	73 20                	jae    f0103c06 <env_alloc+0x7e>
	return (void *)(pa + KERNBASE);
f0103be6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103beb:	89 46 5c             	mov    %eax,0x5c(%esi)
	for (i = 0; i < NPDENTRIES; i++)
f0103bee:	b8 00 00 00 00       	mov    $0x0,%eax
		e->env_pgdir[i] = (i < PDX(UTOP)) ? 0 : kern_pgdir[i];
f0103bf3:	bf 00 00 00 00       	mov    $0x0,%edi
f0103bf8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103bfb:	c7 c3 2c 10 19 f0    	mov    $0xf019102c,%ebx
f0103c01:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103c04:	eb 29                	jmp    f0103c2f <env_alloc+0xa7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103c06:	50                   	push   %eax
f0103c07:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103c0a:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f0103c10:	50                   	push   %eax
f0103c11:	6a 56                	push   $0x56
f0103c13:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f0103c19:	50                   	push   %eax
f0103c1a:	e8 92 c4 ff ff       	call   f01000b1 <_panic>
f0103c1f:	8b 4e 5c             	mov    0x5c(%esi),%ecx
f0103c22:	89 14 99             	mov    %edx,(%ecx,%ebx,4)
	for (i = 0; i < NPDENTRIES; i++)
f0103c25:	83 c0 01             	add    $0x1,%eax
f0103c28:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103c2d:	74 15                	je     f0103c44 <env_alloc+0xbc>
f0103c2f:	89 c3                	mov    %eax,%ebx
		e->env_pgdir[i] = (i < PDX(UTOP)) ? 0 : kern_pgdir[i];
f0103c31:	89 fa                	mov    %edi,%edx
f0103c33:	3d ba 03 00 00       	cmp    $0x3ba,%eax
f0103c38:	76 e5                	jbe    f0103c1f <env_alloc+0x97>
f0103c3a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103c3d:	8b 11                	mov    (%ecx),%edx
f0103c3f:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0103c42:	eb db                	jmp    f0103c1f <env_alloc+0x97>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103c44:	8b 46 5c             	mov    0x5c(%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103c47:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c4c:	0f 86 d0 00 00 00    	jbe    f0103d22 <env_alloc+0x19a>
	return (physaddr_t)kva - KERNBASE;
f0103c52:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103c58:	83 ca 05             	or     $0x5,%edx
f0103c5b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103c61:	8b 46 48             	mov    0x48(%esi),%eax
f0103c64:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103c69:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103c6e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103c73:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103c76:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103c79:	89 f2                	mov    %esi,%edx
f0103c7b:	2b 97 70 21 00 00    	sub    0x2170(%edi),%edx
f0103c81:	c1 fa 05             	sar    $0x5,%edx
f0103c84:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103c8a:	09 d0                	or     %edx,%eax
f0103c8c:	89 46 48             	mov    %eax,0x48(%esi)
	e->env_parent_id = parent_id;
f0103c8f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c92:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f0103c95:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103c9c:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f0103ca3:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103caa:	83 ec 04             	sub    $0x4,%esp
f0103cad:	6a 44                	push   $0x44
f0103caf:	6a 00                	push   $0x0
f0103cb1:	56                   	push   %esi
f0103cb2:	89 fb                	mov    %edi,%ebx
f0103cb4:	e8 6f 1a 00 00       	call   f0105728 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103cb9:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0103cbf:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f0103cc5:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103ccb:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0103cd2:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	env_free_list = e->env_link;
f0103cd8:	8b 46 44             	mov    0x44(%esi),%eax
f0103cdb:	89 87 74 21 00 00    	mov    %eax,0x2174(%edi)
	*newenv_store = e;
f0103ce1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ce4:	89 30                	mov    %esi,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103ce6:	8b 4e 48             	mov    0x48(%esi),%ecx
f0103ce9:	8b 87 6c 21 00 00    	mov    0x216c(%edi),%eax
f0103cef:	83 c4 10             	add    $0x10,%esp
f0103cf2:	ba 00 00 00 00       	mov    $0x0,%edx
f0103cf7:	85 c0                	test   %eax,%eax
f0103cf9:	74 03                	je     f0103cfe <env_alloc+0x176>
f0103cfb:	8b 50 48             	mov    0x48(%eax),%edx
f0103cfe:	83 ec 04             	sub    $0x4,%esp
f0103d01:	51                   	push   %ecx
f0103d02:	52                   	push   %edx
f0103d03:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103d06:	8d 83 95 8c f7 ff    	lea    -0x8736b(%ebx),%eax
f0103d0c:	50                   	push   %eax
f0103d0d:	e8 2d 05 00 00       	call   f010423f <cprintf>
	return 0;
f0103d12:	83 c4 10             	add    $0x10,%esp
f0103d15:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103d1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d1d:	5b                   	pop    %ebx
f0103d1e:	5e                   	pop    %esi
f0103d1f:	5f                   	pop    %edi
f0103d20:	5d                   	pop    %ebp
f0103d21:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d22:	50                   	push   %eax
f0103d23:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103d26:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f0103d2c:	50                   	push   %eax
f0103d2d:	68 ca 00 00 00       	push   $0xca
f0103d32:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0103d38:	50                   	push   %eax
f0103d39:	e8 73 c3 ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f0103d3e:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103d43:	eb d5                	jmp    f0103d1a <env_alloc+0x192>
		return -E_NO_MEM;
f0103d45:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103d4a:	eb ce                	jmp    f0103d1a <env_alloc+0x192>

f0103d4c <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103d4c:	55                   	push   %ebp
f0103d4d:	89 e5                	mov    %esp,%ebp
f0103d4f:	57                   	push   %edi
f0103d50:	56                   	push   %esi
f0103d51:	53                   	push   %ebx
f0103d52:	83 ec 34             	sub    $0x34,%esp
f0103d55:	e8 0d c4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103d5a:	81 c3 9e a4 08 00    	add    $0x8a49e,%ebx
	struct Env *e = NULL;
f0103d60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	assert(!env_alloc(&e, 0));
f0103d67:	6a 00                	push   $0x0
f0103d69:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103d6c:	50                   	push   %eax
f0103d6d:	e8 16 fe ff ff       	call   f0103b88 <env_alloc>
f0103d72:	83 c4 10             	add    $0x10,%esp
f0103d75:	85 c0                	test   %eax,%eax
f0103d77:	75 49                	jne    f0103dc2 <env_create+0x76>
	load_icode(e, binary);
f0103d79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	assert(elf_hdr->e_magic == ELF_MAGIC);
f0103d7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d82:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103d88:	75 57                	jne    f0103de1 <env_create+0x95>
	assert(elf_hdr->e_entry);
f0103d8a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d8d:	8b 40 18             	mov    0x18(%eax),%eax
f0103d90:	85 c0                	test   %eax,%eax
f0103d92:	74 6c                	je     f0103e00 <env_create+0xb4>
	e->env_tf.tf_eip = elf_hdr->e_entry;
f0103d94:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103d97:	89 47 30             	mov    %eax,0x30(%edi)
	lcr3(PADDR(e->env_pgdir));
f0103d9a:	8b 47 5c             	mov    0x5c(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103d9d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103da2:	76 7b                	jbe    f0103e1f <env_create+0xd3>
	return (physaddr_t)kva - KERNBASE;
f0103da4:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103da9:	0f 22 d8             	mov    %eax,%cr3
	ph = (struct Proghdr *)((uint8_t *)elf_hdr + elf_hdr->e_phoff);
f0103dac:	8b 45 08             	mov    0x8(%ebp),%eax
f0103daf:	89 c6                	mov    %eax,%esi
f0103db1:	03 70 1c             	add    0x1c(%eax),%esi
	eph = ph + elf_hdr->e_phnum;
f0103db4:	0f b7 78 2c          	movzwl 0x2c(%eax),%edi
f0103db8:	c1 e7 05             	shl    $0x5,%edi
f0103dbb:	01 f7                	add    %esi,%edi
f0103dbd:	e9 98 00 00 00       	jmp    f0103e5a <env_create+0x10e>
	assert(!env_alloc(&e, 0));
f0103dc2:	8d 83 aa 8c f7 ff    	lea    -0x87356(%ebx),%eax
f0103dc8:	50                   	push   %eax
f0103dc9:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103dcf:	50                   	push   %eax
f0103dd0:	68 8b 01 00 00       	push   $0x18b
f0103dd5:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0103ddb:	50                   	push   %eax
f0103ddc:	e8 d0 c2 ff ff       	call   f01000b1 <_panic>
	assert(elf_hdr->e_magic == ELF_MAGIC);
f0103de1:	8d 83 bc 8c f7 ff    	lea    -0x87344(%ebx),%eax
f0103de7:	50                   	push   %eax
f0103de8:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103dee:	50                   	push   %eax
f0103def:	68 66 01 00 00       	push   $0x166
f0103df4:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0103dfa:	50                   	push   %eax
f0103dfb:	e8 b1 c2 ff ff       	call   f01000b1 <_panic>
	assert(elf_hdr->e_entry);
f0103e00:	8d 83 da 8c f7 ff    	lea    -0x87326(%ebx),%eax
f0103e06:	50                   	push   %eax
f0103e07:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103e0d:	50                   	push   %eax
f0103e0e:	68 67 01 00 00       	push   $0x167
f0103e13:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0103e19:	50                   	push   %eax
f0103e1a:	e8 92 c2 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e1f:	50                   	push   %eax
f0103e20:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f0103e26:	50                   	push   %eax
f0103e27:	68 69 01 00 00       	push   $0x169
f0103e2c:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0103e32:	50                   	push   %eax
f0103e33:	e8 79 c2 ff ff       	call   f01000b1 <_panic>
		assert(ph->p_filesz <= ph->p_memsz);
f0103e38:	8d 83 eb 8c f7 ff    	lea    -0x87315(%ebx),%eax
f0103e3e:	50                   	push   %eax
f0103e3f:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0103e45:	50                   	push   %eax
f0103e46:	68 74 01 00 00       	push   $0x174
f0103e4b:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0103e51:	50                   	push   %eax
f0103e52:	e8 5a c2 ff ff       	call   f01000b1 <_panic>
	for (; ph < eph; ph++)
f0103e57:	83 c6 20             	add    $0x20,%esi
f0103e5a:	39 f7                	cmp    %esi,%edi
f0103e5c:	76 49                	jbe    f0103ea7 <env_create+0x15b>
		if (ph->p_type != ELF_PROG_LOAD)
f0103e5e:	83 3e 01             	cmpl   $0x1,(%esi)
f0103e61:	75 f4                	jne    f0103e57 <env_create+0x10b>
		assert(ph->p_filesz <= ph->p_memsz);
f0103e63:	8b 4e 14             	mov    0x14(%esi),%ecx
f0103e66:	39 4e 10             	cmp    %ecx,0x10(%esi)
f0103e69:	77 cd                	ja     f0103e38 <env_create+0xec>
		region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103e6b:	8b 56 08             	mov    0x8(%esi),%edx
f0103e6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103e71:	e8 4d fb ff ff       	call   f01039c3 <region_alloc>
		memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103e76:	83 ec 04             	sub    $0x4,%esp
f0103e79:	ff 76 10             	pushl  0x10(%esi)
f0103e7c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e7f:	03 46 04             	add    0x4(%esi),%eax
f0103e82:	50                   	push   %eax
f0103e83:	ff 76 08             	pushl  0x8(%esi)
f0103e86:	e8 ea 18 00 00       	call   f0105775 <memmove>
		memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f0103e8b:	8b 46 10             	mov    0x10(%esi),%eax
f0103e8e:	83 c4 0c             	add    $0xc,%esp
f0103e91:	8b 56 14             	mov    0x14(%esi),%edx
f0103e94:	29 c2                	sub    %eax,%edx
f0103e96:	52                   	push   %edx
f0103e97:	6a 00                	push   $0x0
f0103e99:	03 46 08             	add    0x8(%esi),%eax
f0103e9c:	50                   	push   %eax
f0103e9d:	e8 86 18 00 00       	call   f0105728 <memset>
f0103ea2:	83 c4 10             	add    $0x10,%esp
f0103ea5:	eb b0                	jmp    f0103e57 <env_create+0x10b>
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103ea7:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103eac:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103eb1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103eb4:	e8 0a fb ff ff       	call   f01039c3 <region_alloc>
	e->env_type = type;
f0103eb9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103ebc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ebf:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ec5:	5b                   	pop    %ebx
f0103ec6:	5e                   	pop    %esi
f0103ec7:	5f                   	pop    %edi
f0103ec8:	5d                   	pop    %ebp
f0103ec9:	c3                   	ret    

f0103eca <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103eca:	55                   	push   %ebp
f0103ecb:	89 e5                	mov    %esp,%ebp
f0103ecd:	57                   	push   %edi
f0103ece:	56                   	push   %esi
f0103ecf:	53                   	push   %ebx
f0103ed0:	83 ec 2c             	sub    $0x2c,%esp
f0103ed3:	e8 8f c2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103ed8:	81 c3 20 a3 08 00    	add    $0x8a320,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ede:	8b 93 6c 21 00 00    	mov    0x216c(%ebx),%edx
f0103ee4:	3b 55 08             	cmp    0x8(%ebp),%edx
f0103ee7:	75 17                	jne    f0103f00 <env_free+0x36>
		lcr3(PADDR(kern_pgdir));
f0103ee9:	c7 c0 2c 10 19 f0    	mov    $0xf019102c,%eax
f0103eef:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103ef1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ef6:	76 46                	jbe    f0103f3e <env_free+0x74>
	return (physaddr_t)kva - KERNBASE;
f0103ef8:	05 00 00 00 10       	add    $0x10000000,%eax
f0103efd:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103f00:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f03:	8b 48 48             	mov    0x48(%eax),%ecx
f0103f06:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f0b:	85 d2                	test   %edx,%edx
f0103f0d:	74 03                	je     f0103f12 <env_free+0x48>
f0103f0f:	8b 42 48             	mov    0x48(%edx),%eax
f0103f12:	83 ec 04             	sub    $0x4,%esp
f0103f15:	51                   	push   %ecx
f0103f16:	50                   	push   %eax
f0103f17:	8d 83 07 8d f7 ff    	lea    -0x872f9(%ebx),%eax
f0103f1d:	50                   	push   %eax
f0103f1e:	e8 1c 03 00 00       	call   f010423f <cprintf>
f0103f23:	83 c4 10             	add    $0x10,%esp
f0103f26:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	if (PGNUM(pa) >= npages)
f0103f2d:	c7 c0 28 10 19 f0    	mov    $0xf0191028,%eax
f0103f33:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f0103f36:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103f39:	e9 9f 00 00 00       	jmp    f0103fdd <env_free+0x113>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f3e:	50                   	push   %eax
f0103f3f:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f0103f45:	50                   	push   %eax
f0103f46:	68 9e 01 00 00       	push   $0x19e
f0103f4b:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0103f51:	50                   	push   %eax
f0103f52:	e8 5a c1 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103f57:	50                   	push   %eax
f0103f58:	8d 83 64 80 f7 ff    	lea    -0x87f9c(%ebx),%eax
f0103f5e:	50                   	push   %eax
f0103f5f:	68 ad 01 00 00       	push   $0x1ad
f0103f64:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0103f6a:	50                   	push   %eax
f0103f6b:	e8 41 c1 ff ff       	call   f01000b1 <_panic>
f0103f70:	83 c6 04             	add    $0x4,%esi
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103f73:	39 fe                	cmp    %edi,%esi
f0103f75:	74 24                	je     f0103f9b <env_free+0xd1>
			if (pt[pteno] & PTE_P)
f0103f77:	f6 06 01             	testb  $0x1,(%esi)
f0103f7a:	74 f4                	je     f0103f70 <env_free+0xa6>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103f7c:	83 ec 08             	sub    $0x8,%esp
f0103f7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103f82:	01 f0                	add    %esi,%eax
f0103f84:	c1 e0 0a             	shl    $0xa,%eax
f0103f87:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103f8a:	50                   	push   %eax
f0103f8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f8e:	ff 70 5c             	pushl  0x5c(%eax)
f0103f91:	e8 5c da ff ff       	call   f01019f2 <page_remove>
f0103f96:	83 c4 10             	add    $0x10,%esp
f0103f99:	eb d5                	jmp    f0103f70 <env_free+0xa6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103f9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f9e:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103fa1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103fa4:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103fab:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103fae:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103fb1:	3b 10                	cmp    (%eax),%edx
f0103fb3:	73 6f                	jae    f0104024 <env_free+0x15a>
		page_decref(pa2page(pa));
f0103fb5:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103fb8:	c7 c0 30 10 19 f0    	mov    $0xf0191030,%eax
f0103fbe:	8b 00                	mov    (%eax),%eax
f0103fc0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103fc3:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103fc6:	50                   	push   %eax
f0103fc7:	e8 93 d8 ff ff       	call   f010185f <page_decref>
f0103fcc:	83 c4 10             	add    $0x10,%esp
f0103fcf:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0103fd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103fd6:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103fdb:	74 5f                	je     f010403c <env_free+0x172>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103fdd:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fe0:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103fe3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103fe6:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103fe9:	a8 01                	test   $0x1,%al
f0103feb:	74 e2                	je     f0103fcf <env_free+0x105>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103fed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103ff2:	89 c2                	mov    %eax,%edx
f0103ff4:	c1 ea 0c             	shr    $0xc,%edx
f0103ff7:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103ffa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103ffd:	39 11                	cmp    %edx,(%ecx)
f0103fff:	0f 86 52 ff ff ff    	jbe    f0103f57 <env_free+0x8d>
	return (void *)(pa + KERNBASE);
f0104005:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010400b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010400e:	c1 e2 14             	shl    $0x14,%edx
f0104011:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104014:	8d b8 00 10 00 f0    	lea    -0xffff000(%eax),%edi
f010401a:	f7 d8                	neg    %eax
f010401c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010401f:	e9 53 ff ff ff       	jmp    f0103f77 <env_free+0xad>
		panic("pa2page called with invalid pa");
f0104024:	83 ec 04             	sub    $0x4,%esp
f0104027:	8d 83 a0 82 f7 ff    	lea    -0x87d60(%ebx),%eax
f010402d:	50                   	push   %eax
f010402e:	6a 4f                	push   $0x4f
f0104030:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f0104036:	50                   	push   %eax
f0104037:	e8 75 c0 ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010403c:	8b 45 08             	mov    0x8(%ebp),%eax
f010403f:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0104042:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104047:	76 57                	jbe    f01040a0 <env_free+0x1d6>
	e->env_pgdir = 0;
f0104049:	8b 55 08             	mov    0x8(%ebp),%edx
f010404c:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f0104053:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0104058:	c1 e8 0c             	shr    $0xc,%eax
f010405b:	c7 c2 28 10 19 f0    	mov    $0xf0191028,%edx
f0104061:	3b 02                	cmp    (%edx),%eax
f0104063:	73 54                	jae    f01040b9 <env_free+0x1ef>
	page_decref(pa2page(pa));
f0104065:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0104068:	c7 c2 30 10 19 f0    	mov    $0xf0191030,%edx
f010406e:	8b 12                	mov    (%edx),%edx
f0104070:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0104073:	50                   	push   %eax
f0104074:	e8 e6 d7 ff ff       	call   f010185f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0104079:	8b 45 08             	mov    0x8(%ebp),%eax
f010407c:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0104083:	8b 83 74 21 00 00    	mov    0x2174(%ebx),%eax
f0104089:	8b 55 08             	mov    0x8(%ebp),%edx
f010408c:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f010408f:	89 93 74 21 00 00    	mov    %edx,0x2174(%ebx)
}
f0104095:	83 c4 10             	add    $0x10,%esp
f0104098:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010409b:	5b                   	pop    %ebx
f010409c:	5e                   	pop    %esi
f010409d:	5f                   	pop    %edi
f010409e:	5d                   	pop    %ebp
f010409f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01040a0:	50                   	push   %eax
f01040a1:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f01040a7:	50                   	push   %eax
f01040a8:	68 bb 01 00 00       	push   $0x1bb
f01040ad:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f01040b3:	50                   	push   %eax
f01040b4:	e8 f8 bf ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f01040b9:	83 ec 04             	sub    $0x4,%esp
f01040bc:	8d 83 a0 82 f7 ff    	lea    -0x87d60(%ebx),%eax
f01040c2:	50                   	push   %eax
f01040c3:	6a 4f                	push   $0x4f
f01040c5:	8d 83 81 89 f7 ff    	lea    -0x8767f(%ebx),%eax
f01040cb:	50                   	push   %eax
f01040cc:	e8 e0 bf ff ff       	call   f01000b1 <_panic>

f01040d1 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01040d1:	55                   	push   %ebp
f01040d2:	89 e5                	mov    %esp,%ebp
f01040d4:	53                   	push   %ebx
f01040d5:	83 ec 10             	sub    $0x10,%esp
f01040d8:	e8 8a c0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01040dd:	81 c3 1b a1 08 00    	add    $0x8a11b,%ebx
	env_free(e);
f01040e3:	ff 75 08             	pushl  0x8(%ebp)
f01040e6:	e8 df fd ff ff       	call   f0103eca <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01040eb:	8d 83 68 8d f7 ff    	lea    -0x87298(%ebx),%eax
f01040f1:	89 04 24             	mov    %eax,(%esp)
f01040f4:	e8 46 01 00 00       	call   f010423f <cprintf>
f01040f9:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f01040fc:	83 ec 0c             	sub    $0xc,%esp
f01040ff:	6a 00                	push   $0x0
f0104101:	e8 16 cf ff ff       	call   f010101c <monitor>
f0104106:	83 c4 10             	add    $0x10,%esp
f0104109:	eb f1                	jmp    f01040fc <env_destroy+0x2b>

f010410b <env_pop_tf>:
// This function does not return.
//
// 注意，这个函数并不会返回
void
env_pop_tf(struct Trapframe *tf)
{
f010410b:	55                   	push   %ebp
f010410c:	89 e5                	mov    %esp,%ebp
f010410e:	53                   	push   %ebx
f010410f:	83 ec 08             	sub    $0x8,%esp
f0104112:	e8 50 c0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104117:	81 c3 e1 a0 08 00    	add    $0x8a0e1,%ebx
	asm volatile(
f010411d:	8b 65 08             	mov    0x8(%ebp),%esp
f0104120:	61                   	popa   
f0104121:	07                   	pop    %es
f0104122:	1f                   	pop    %ds
f0104123:	83 c4 08             	add    $0x8,%esp
f0104126:	cf                   	iret   
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		:
		: "g"(tf)
		: "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0104127:	8d 83 1d 8d f7 ff    	lea    -0x872e3(%ebx),%eax
f010412d:	50                   	push   %eax
f010412e:	68 e7 01 00 00       	push   $0x1e7
f0104133:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0104139:	50                   	push   %eax
f010413a:	e8 72 bf ff ff       	call   f01000b1 <_panic>

f010413f <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010413f:	55                   	push   %ebp
f0104140:	89 e5                	mov    %esp,%ebp
f0104142:	53                   	push   %ebx
f0104143:	83 ec 04             	sub    $0x4,%esp
f0104146:	e8 1c c0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010414b:	81 c3 ad a0 08 00    	add    $0x8a0ad,%ebx
f0104151:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104154:	8b 93 6c 21 00 00    	mov    0x216c(%ebx),%edx
f010415a:	85 d2                	test   %edx,%edx
f010415c:	74 06                	je     f0104164 <env_run+0x25>
f010415e:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0104162:	74 35                	je     f0104199 <env_run+0x5a>
	{
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f0104164:	89 83 6c 21 00 00    	mov    %eax,0x216c(%ebx)
	curenv->env_status = ENV_RUNNING;
f010416a:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0104171:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0104175:	8b 50 5c             	mov    0x5c(%eax),%edx
	if ((uint32_t)kva < KERNBASE)
f0104178:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010417e:	77 22                	ja     f01041a2 <env_run+0x63>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104180:	52                   	push   %edx
f0104181:	8d 83 fc 82 f7 ff    	lea    -0x87d04(%ebx),%eax
f0104187:	50                   	push   %eax
f0104188:	68 0c 02 00 00       	push   $0x20c
f010418d:	8d 83 8a 8c f7 ff    	lea    -0x87376(%ebx),%eax
f0104193:	50                   	push   %eax
f0104194:	e8 18 bf ff ff       	call   f01000b1 <_panic>
		curenv->env_status = ENV_RUNNABLE;
f0104199:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
f01041a0:	eb c2                	jmp    f0104164 <env_run+0x25>
	return (physaddr_t)kva - KERNBASE;
f01041a2:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01041a8:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&curenv->env_tf);
f01041ab:	83 ec 0c             	sub    $0xc,%esp
f01041ae:	50                   	push   %eax
f01041af:	e8 57 ff ff ff       	call   f010410b <env_pop_tf>

f01041b4 <__x86.get_pc_thunk.dx>:
f01041b4:	8b 14 24             	mov    (%esp),%edx
f01041b7:	c3                   	ret    

f01041b8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01041b8:	55                   	push   %ebp
f01041b9:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01041bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01041be:	ba 70 00 00 00       	mov    $0x70,%edx
f01041c3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01041c4:	ba 71 00 00 00       	mov    $0x71,%edx
f01041c9:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01041ca:	0f b6 c0             	movzbl %al,%eax
}
f01041cd:	5d                   	pop    %ebp
f01041ce:	c3                   	ret    

f01041cf <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01041cf:	55                   	push   %ebp
f01041d0:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01041d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01041d5:	ba 70 00 00 00       	mov    $0x70,%edx
f01041da:	ee                   	out    %al,(%dx)
f01041db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041de:	ba 71 00 00 00       	mov    $0x71,%edx
f01041e3:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01041e4:	5d                   	pop    %ebp
f01041e5:	c3                   	ret    

f01041e6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01041e6:	55                   	push   %ebp
f01041e7:	89 e5                	mov    %esp,%ebp
f01041e9:	53                   	push   %ebx
f01041ea:	83 ec 10             	sub    $0x10,%esp
f01041ed:	e8 75 bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01041f2:	81 c3 06 a0 08 00    	add    $0x8a006,%ebx
	cputchar(ch);
f01041f8:	ff 75 08             	pushl  0x8(%ebp)
f01041fb:	e8 de c4 ff ff       	call   f01006de <cputchar>
	*cnt++;
}
f0104200:	83 c4 10             	add    $0x10,%esp
f0104203:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104206:	c9                   	leave  
f0104207:	c3                   	ret    

f0104208 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0104208:	55                   	push   %ebp
f0104209:	89 e5                	mov    %esp,%ebp
f010420b:	53                   	push   %ebx
f010420c:	83 ec 14             	sub    $0x14,%esp
f010420f:	e8 53 bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104214:	81 c3 e4 9f 08 00    	add    $0x89fe4,%ebx
	int cnt = 0;
f010421a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104221:	ff 75 0c             	pushl  0xc(%ebp)
f0104224:	ff 75 08             	pushl  0x8(%ebp)
f0104227:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010422a:	50                   	push   %eax
f010422b:	8d 83 ee 5f f7 ff    	lea    -0x8a012(%ebx),%eax
f0104231:	50                   	push   %eax
f0104232:	e8 0f 0d 00 00       	call   f0104f46 <vprintfmt>
	return cnt;
}
f0104237:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010423a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010423d:	c9                   	leave  
f010423e:	c3                   	ret    

f010423f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010423f:	55                   	push   %ebp
f0104240:	89 e5                	mov    %esp,%ebp
f0104242:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0104245:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0104248:	50                   	push   %eax
f0104249:	ff 75 08             	pushl  0x8(%ebp)
f010424c:	e8 b7 ff ff ff       	call   f0104208 <vcprintf>
	va_end(ap);

	return cnt;
}
f0104251:	c9                   	leave  
f0104252:	c3                   	ret    

f0104253 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104253:	55                   	push   %ebp
f0104254:	89 e5                	mov    %esp,%ebp
f0104256:	57                   	push   %edi
f0104257:	56                   	push   %esi
f0104258:	53                   	push   %ebx
f0104259:	83 ec 04             	sub    $0x4,%esp
f010425c:	e8 06 bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104261:	81 c3 97 9f 08 00    	add    $0x89f97,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0104267:	c7 83 ac 29 00 00 00 	movl   $0xf0000000,0x29ac(%ebx)
f010426e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0104271:	66 c7 83 b0 29 00 00 	movw   $0x10,0x29b0(%ebx)
f0104278:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f010427a:	66 c7 83 0e 2a 00 00 	movw   $0x68,0x2a0e(%ebx)
f0104281:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0104283:	c7 c0 00 d3 11 f0    	mov    $0xf011d300,%eax
f0104289:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f010428f:	8d b3 a8 29 00 00    	lea    0x29a8(%ebx),%esi
f0104295:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0104299:	89 f2                	mov    %esi,%edx
f010429b:	c1 ea 10             	shr    $0x10,%edx
f010429e:	88 50 2c             	mov    %dl,0x2c(%eax)
f01042a1:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f01042a5:	83 e2 f0             	and    $0xfffffff0,%edx
f01042a8:	83 ca 09             	or     $0x9,%edx
f01042ab:	83 e2 9f             	and    $0xffffff9f,%edx
f01042ae:	83 ca 80             	or     $0xffffff80,%edx
f01042b1:	88 55 f3             	mov    %dl,-0xd(%ebp)
f01042b4:	88 50 2d             	mov    %dl,0x2d(%eax)
f01042b7:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f01042bb:	83 e1 c0             	and    $0xffffffc0,%ecx
f01042be:	83 c9 40             	or     $0x40,%ecx
f01042c1:	83 e1 7f             	and    $0x7f,%ecx
f01042c4:	88 48 2e             	mov    %cl,0x2e(%eax)
f01042c7:	c1 ee 18             	shr    $0x18,%esi
f01042ca:	89 f1                	mov    %esi,%ecx
f01042cc:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f01042cf:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f01042d3:	83 e2 ef             	and    $0xffffffef,%edx
f01042d6:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f01042d9:	b8 28 00 00 00       	mov    $0x28,%eax
f01042de:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f01042e1:	8d 83 10 1e 00 00    	lea    0x1e10(%ebx),%eax
f01042e7:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01042ea:	83 c4 04             	add    $0x4,%esp
f01042ed:	5b                   	pop    %ebx
f01042ee:	5e                   	pop    %esi
f01042ef:	5f                   	pop    %edi
f01042f0:	5d                   	pop    %ebp
f01042f1:	c3                   	ret    

f01042f2 <trap_init>:
{
f01042f2:	55                   	push   %ebp
f01042f3:	89 e5                	mov    %esp,%ebp
f01042f5:	57                   	push   %edi
f01042f6:	56                   	push   %esi
f01042f7:	53                   	push   %ebx
f01042f8:	e8 b7 fe ff ff       	call   f01041b4 <__x86.get_pc_thunk.dx>
f01042fd:	81 c2 fb 9e 08 00    	add    $0x89efb,%edx
	for (i = 0; i <= T_SYSCALL; i++)
f0104303:	b8 00 00 00 00       	mov    $0x0,%eax
			SETGATE(idt[i], 0, GD_KT, handles[i], 3);
f0104308:	c7 c7 30 d3 11 f0    	mov    $0xf011d330,%edi
			SETGATE(idt[i], 0, GD_KT, handles[i], 0);
f010430e:	89 fe                	mov    %edi,%esi
f0104310:	eb 37                	jmp    f0104349 <trap_init+0x57>
			SETGATE(idt[i], 0, GD_KT, handles[i], 3);
f0104312:	8b 0c 87             	mov    (%edi,%eax,4),%ecx
f0104315:	66 89 8c c2 88 21 00 	mov    %cx,0x2188(%edx,%eax,8)
f010431c:	00 
f010431d:	8d 9c c2 88 21 00 00 	lea    0x2188(%edx,%eax,8),%ebx
f0104324:	66 c7 43 02 08 00    	movw   $0x8,0x2(%ebx)
f010432a:	c6 84 c2 8c 21 00 00 	movb   $0x0,0x218c(%edx,%eax,8)
f0104331:	00 
f0104332:	c6 84 c2 8d 21 00 00 	movb   $0xee,0x218d(%edx,%eax,8)
f0104339:	ee 
f010433a:	c1 e9 10             	shr    $0x10,%ecx
f010433d:	66 89 4b 06          	mov    %cx,0x6(%ebx)
	for (i = 0; i <= T_SYSCALL; i++)
f0104341:	83 c0 01             	add    $0x1,%eax
f0104344:	83 f8 31             	cmp    $0x31,%eax
f0104347:	74 3b                	je     f0104384 <trap_init+0x92>
		if (i == T_BRKPT || i == T_SYSCALL)
f0104349:	83 f8 03             	cmp    $0x3,%eax
f010434c:	74 c4                	je     f0104312 <trap_init+0x20>
f010434e:	83 f8 30             	cmp    $0x30,%eax
f0104351:	74 bf                	je     f0104312 <trap_init+0x20>
			SETGATE(idt[i], 0, GD_KT, handles[i], 0);
f0104353:	8b 0c 86             	mov    (%esi,%eax,4),%ecx
f0104356:	66 89 8c c2 88 21 00 	mov    %cx,0x2188(%edx,%eax,8)
f010435d:	00 
f010435e:	8d 9c c2 88 21 00 00 	lea    0x2188(%edx,%eax,8),%ebx
f0104365:	66 c7 43 02 08 00    	movw   $0x8,0x2(%ebx)
f010436b:	c6 84 c2 8c 21 00 00 	movb   $0x0,0x218c(%edx,%eax,8)
f0104372:	00 
f0104373:	c6 84 c2 8d 21 00 00 	movb   $0x8e,0x218d(%edx,%eax,8)
f010437a:	8e 
f010437b:	c1 e9 10             	shr    $0x10,%ecx
f010437e:	66 89 4b 06          	mov    %cx,0x6(%ebx)
f0104382:	eb bd                	jmp    f0104341 <trap_init+0x4f>
	trap_init_percpu();
f0104384:	e8 ca fe ff ff       	call   f0104253 <trap_init_percpu>
}
f0104389:	5b                   	pop    %ebx
f010438a:	5e                   	pop    %esi
f010438b:	5f                   	pop    %edi
f010438c:	5d                   	pop    %ebp
f010438d:	c3                   	ret    

f010438e <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010438e:	55                   	push   %ebp
f010438f:	89 e5                	mov    %esp,%ebp
f0104391:	56                   	push   %esi
f0104392:	53                   	push   %ebx
f0104393:	e8 cf bd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104398:	81 c3 60 9e 08 00    	add    $0x89e60,%ebx
f010439e:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01043a1:	83 ec 08             	sub    $0x8,%esp
f01043a4:	ff 36                	pushl  (%esi)
f01043a6:	8d 83 9e 8d f7 ff    	lea    -0x87262(%ebx),%eax
f01043ac:	50                   	push   %eax
f01043ad:	e8 8d fe ff ff       	call   f010423f <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01043b2:	83 c4 08             	add    $0x8,%esp
f01043b5:	ff 76 04             	pushl  0x4(%esi)
f01043b8:	8d 83 ad 8d f7 ff    	lea    -0x87253(%ebx),%eax
f01043be:	50                   	push   %eax
f01043bf:	e8 7b fe ff ff       	call   f010423f <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01043c4:	83 c4 08             	add    $0x8,%esp
f01043c7:	ff 76 08             	pushl  0x8(%esi)
f01043ca:	8d 83 bc 8d f7 ff    	lea    -0x87244(%ebx),%eax
f01043d0:	50                   	push   %eax
f01043d1:	e8 69 fe ff ff       	call   f010423f <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01043d6:	83 c4 08             	add    $0x8,%esp
f01043d9:	ff 76 0c             	pushl  0xc(%esi)
f01043dc:	8d 83 cb 8d f7 ff    	lea    -0x87235(%ebx),%eax
f01043e2:	50                   	push   %eax
f01043e3:	e8 57 fe ff ff       	call   f010423f <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01043e8:	83 c4 08             	add    $0x8,%esp
f01043eb:	ff 76 10             	pushl  0x10(%esi)
f01043ee:	8d 83 da 8d f7 ff    	lea    -0x87226(%ebx),%eax
f01043f4:	50                   	push   %eax
f01043f5:	e8 45 fe ff ff       	call   f010423f <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01043fa:	83 c4 08             	add    $0x8,%esp
f01043fd:	ff 76 14             	pushl  0x14(%esi)
f0104400:	8d 83 e9 8d f7 ff    	lea    -0x87217(%ebx),%eax
f0104406:	50                   	push   %eax
f0104407:	e8 33 fe ff ff       	call   f010423f <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010440c:	83 c4 08             	add    $0x8,%esp
f010440f:	ff 76 18             	pushl  0x18(%esi)
f0104412:	8d 83 f8 8d f7 ff    	lea    -0x87208(%ebx),%eax
f0104418:	50                   	push   %eax
f0104419:	e8 21 fe ff ff       	call   f010423f <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010441e:	83 c4 08             	add    $0x8,%esp
f0104421:	ff 76 1c             	pushl  0x1c(%esi)
f0104424:	8d 83 07 8e f7 ff    	lea    -0x871f9(%ebx),%eax
f010442a:	50                   	push   %eax
f010442b:	e8 0f fe ff ff       	call   f010423f <cprintf>
}
f0104430:	83 c4 10             	add    $0x10,%esp
f0104433:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104436:	5b                   	pop    %ebx
f0104437:	5e                   	pop    %esi
f0104438:	5d                   	pop    %ebp
f0104439:	c3                   	ret    

f010443a <print_trapframe>:
{
f010443a:	55                   	push   %ebp
f010443b:	89 e5                	mov    %esp,%ebp
f010443d:	57                   	push   %edi
f010443e:	56                   	push   %esi
f010443f:	53                   	push   %ebx
f0104440:	83 ec 14             	sub    $0x14,%esp
f0104443:	e8 1f bd ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104448:	81 c3 b0 9d 08 00    	add    $0x89db0,%ebx
f010444e:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0104451:	56                   	push   %esi
f0104452:	8d 83 3d 8f f7 ff    	lea    -0x870c3(%ebx),%eax
f0104458:	50                   	push   %eax
f0104459:	e8 e1 fd ff ff       	call   f010423f <cprintf>
	print_regs(&tf->tf_regs);
f010445e:	89 34 24             	mov    %esi,(%esp)
f0104461:	e8 28 ff ff ff       	call   f010438e <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104466:	83 c4 08             	add    $0x8,%esp
f0104469:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f010446d:	50                   	push   %eax
f010446e:	8d 83 58 8e f7 ff    	lea    -0x871a8(%ebx),%eax
f0104474:	50                   	push   %eax
f0104475:	e8 c5 fd ff ff       	call   f010423f <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010447a:	83 c4 08             	add    $0x8,%esp
f010447d:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0104481:	50                   	push   %eax
f0104482:	8d 83 6b 8e f7 ff    	lea    -0x87195(%ebx),%eax
f0104488:	50                   	push   %eax
f0104489:	e8 b1 fd ff ff       	call   f010423f <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010448e:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0104491:	83 c4 10             	add    $0x10,%esp
f0104494:	83 fa 13             	cmp    $0x13,%edx
f0104497:	0f 86 e9 00 00 00    	jbe    f0104586 <print_trapframe+0x14c>
	return "(unknown trap)";
f010449d:	83 fa 30             	cmp    $0x30,%edx
f01044a0:	8d 83 16 8e f7 ff    	lea    -0x871ea(%ebx),%eax
f01044a6:	8d 8b 22 8e f7 ff    	lea    -0x871de(%ebx),%ecx
f01044ac:	0f 45 c1             	cmovne %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044af:	83 ec 04             	sub    $0x4,%esp
f01044b2:	50                   	push   %eax
f01044b3:	52                   	push   %edx
f01044b4:	8d 83 7e 8e f7 ff    	lea    -0x87182(%ebx),%eax
f01044ba:	50                   	push   %eax
f01044bb:	e8 7f fd ff ff       	call   f010423f <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01044c0:	83 c4 10             	add    $0x10,%esp
f01044c3:	39 b3 88 29 00 00    	cmp    %esi,0x2988(%ebx)
f01044c9:	0f 84 c3 00 00 00    	je     f0104592 <print_trapframe+0x158>
	cprintf("  err  0x%08x", tf->tf_err);
f01044cf:	83 ec 08             	sub    $0x8,%esp
f01044d2:	ff 76 2c             	pushl  0x2c(%esi)
f01044d5:	8d 83 9f 8e f7 ff    	lea    -0x87161(%ebx),%eax
f01044db:	50                   	push   %eax
f01044dc:	e8 5e fd ff ff       	call   f010423f <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f01044e1:	83 c4 10             	add    $0x10,%esp
f01044e4:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f01044e8:	0f 85 c9 00 00 00    	jne    f01045b7 <print_trapframe+0x17d>
			tf->tf_err & 1 ? "protection" : "not-present");
f01044ee:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f01044f1:	89 c2                	mov    %eax,%edx
f01044f3:	83 e2 01             	and    $0x1,%edx
f01044f6:	8d 8b 31 8e f7 ff    	lea    -0x871cf(%ebx),%ecx
f01044fc:	8d 93 3c 8e f7 ff    	lea    -0x871c4(%ebx),%edx
f0104502:	0f 44 ca             	cmove  %edx,%ecx
f0104505:	89 c2                	mov    %eax,%edx
f0104507:	83 e2 02             	and    $0x2,%edx
f010450a:	8d 93 48 8e f7 ff    	lea    -0x871b8(%ebx),%edx
f0104510:	8d bb 4e 8e f7 ff    	lea    -0x871b2(%ebx),%edi
f0104516:	0f 44 d7             	cmove  %edi,%edx
f0104519:	83 e0 04             	and    $0x4,%eax
f010451c:	8d 83 53 8e f7 ff    	lea    -0x871ad(%ebx),%eax
f0104522:	8d bb 68 8f f7 ff    	lea    -0x87098(%ebx),%edi
f0104528:	0f 44 c7             	cmove  %edi,%eax
f010452b:	51                   	push   %ecx
f010452c:	52                   	push   %edx
f010452d:	50                   	push   %eax
f010452e:	8d 83 ad 8e f7 ff    	lea    -0x87153(%ebx),%eax
f0104534:	50                   	push   %eax
f0104535:	e8 05 fd ff ff       	call   f010423f <cprintf>
f010453a:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010453d:	83 ec 08             	sub    $0x8,%esp
f0104540:	ff 76 30             	pushl  0x30(%esi)
f0104543:	8d 83 bc 8e f7 ff    	lea    -0x87144(%ebx),%eax
f0104549:	50                   	push   %eax
f010454a:	e8 f0 fc ff ff       	call   f010423f <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010454f:	83 c4 08             	add    $0x8,%esp
f0104552:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104556:	50                   	push   %eax
f0104557:	8d 83 cb 8e f7 ff    	lea    -0x87135(%ebx),%eax
f010455d:	50                   	push   %eax
f010455e:	e8 dc fc ff ff       	call   f010423f <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104563:	83 c4 08             	add    $0x8,%esp
f0104566:	ff 76 38             	pushl  0x38(%esi)
f0104569:	8d 83 de 8e f7 ff    	lea    -0x87122(%ebx),%eax
f010456f:	50                   	push   %eax
f0104570:	e8 ca fc ff ff       	call   f010423f <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104575:	83 c4 10             	add    $0x10,%esp
f0104578:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f010457c:	75 50                	jne    f01045ce <print_trapframe+0x194>
}
f010457e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104581:	5b                   	pop    %ebx
f0104582:	5e                   	pop    %esi
f0104583:	5f                   	pop    %edi
f0104584:	5d                   	pop    %ebp
f0104585:	c3                   	ret    
		return excnames[trapno];
f0104586:	8b 84 93 a8 1e 00 00 	mov    0x1ea8(%ebx,%edx,4),%eax
f010458d:	e9 1d ff ff ff       	jmp    f01044af <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104592:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104596:	0f 85 33 ff ff ff    	jne    f01044cf <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010459c:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010459f:	83 ec 08             	sub    $0x8,%esp
f01045a2:	50                   	push   %eax
f01045a3:	8d 83 90 8e f7 ff    	lea    -0x87170(%ebx),%eax
f01045a9:	50                   	push   %eax
f01045aa:	e8 90 fc ff ff       	call   f010423f <cprintf>
f01045af:	83 c4 10             	add    $0x10,%esp
f01045b2:	e9 18 ff ff ff       	jmp    f01044cf <print_trapframe+0x95>
		cprintf("\n");
f01045b7:	83 ec 0c             	sub    $0xc,%esp
f01045ba:	8d 83 2e 8c f7 ff    	lea    -0x873d2(%ebx),%eax
f01045c0:	50                   	push   %eax
f01045c1:	e8 79 fc ff ff       	call   f010423f <cprintf>
f01045c6:	83 c4 10             	add    $0x10,%esp
f01045c9:	e9 6f ff ff ff       	jmp    f010453d <print_trapframe+0x103>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01045ce:	83 ec 08             	sub    $0x8,%esp
f01045d1:	ff 76 3c             	pushl  0x3c(%esi)
f01045d4:	8d 83 ed 8e f7 ff    	lea    -0x87113(%ebx),%eax
f01045da:	50                   	push   %eax
f01045db:	e8 5f fc ff ff       	call   f010423f <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01045e0:	83 c4 08             	add    $0x8,%esp
f01045e3:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f01045e7:	50                   	push   %eax
f01045e8:	8d 83 fc 8e f7 ff    	lea    -0x87104(%ebx),%eax
f01045ee:	50                   	push   %eax
f01045ef:	e8 4b fc ff ff       	call   f010423f <cprintf>
f01045f4:	83 c4 10             	add    $0x10,%esp
}
f01045f7:	eb 85                	jmp    f010457e <print_trapframe+0x144>

f01045f9 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01045f9:	55                   	push   %ebp
f01045fa:	89 e5                	mov    %esp,%ebp
f01045fc:	57                   	push   %edi
f01045fd:	56                   	push   %esi
f01045fe:	53                   	push   %ebx
f01045ff:	83 ec 0c             	sub    $0xc,%esp
f0104602:	e8 60 bb ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104607:	81 c3 f1 9b 08 00    	add    $0x89bf1,%ebx
f010460d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104610:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0104613:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0104617:	74 38                	je     f0104651 <page_fault_handler+0x58>
	}
	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104619:	ff 76 30             	pushl  0x30(%esi)
f010461c:	50                   	push   %eax
f010461d:	c7 c7 64 03 19 f0    	mov    $0xf0190364,%edi
f0104623:	8b 07                	mov    (%edi),%eax
f0104625:	ff 70 48             	pushl  0x48(%eax)
f0104628:	8d 83 d8 90 f7 ff    	lea    -0x86f28(%ebx),%eax
f010462e:	50                   	push   %eax
f010462f:	e8 0b fc ff ff       	call   f010423f <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104634:	89 34 24             	mov    %esi,(%esp)
f0104637:	e8 fe fd ff ff       	call   f010443a <print_trapframe>
	env_destroy(curenv);
f010463c:	83 c4 04             	add    $0x4,%esp
f010463f:	ff 37                	pushl  (%edi)
f0104641:	e8 8b fa ff ff       	call   f01040d1 <env_destroy>
}
f0104646:	83 c4 10             	add    $0x10,%esp
f0104649:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010464c:	5b                   	pop    %ebx
f010464d:	5e                   	pop    %esi
f010464e:	5f                   	pop    %edi
f010464f:	5d                   	pop    %ebp
f0104650:	c3                   	ret    
		panic("page fault happen in kernel mode");
f0104651:	83 ec 04             	sub    $0x4,%esp
f0104654:	8d 83 b4 90 f7 ff    	lea    -0x86f4c(%ebx),%eax
f010465a:	50                   	push   %eax
f010465b:	68 f6 00 00 00       	push   $0xf6
f0104660:	8d 83 0f 8f f7 ff    	lea    -0x870f1(%ebx),%eax
f0104666:	50                   	push   %eax
f0104667:	e8 45 ba ff ff       	call   f01000b1 <_panic>

f010466c <trap>:
{
f010466c:	55                   	push   %ebp
f010466d:	89 e5                	mov    %esp,%ebp
f010466f:	57                   	push   %edi
f0104670:	56                   	push   %esi
f0104671:	53                   	push   %ebx
f0104672:	83 ec 0c             	sub    $0xc,%esp
f0104675:	e8 ed ba ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010467a:	81 c3 7e 9b 08 00    	add    $0x89b7e,%ebx
f0104680:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f0104683:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104684:	9c                   	pushf  
f0104685:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f0104686:	f6 c4 02             	test   $0x2,%ah
f0104689:	74 1f                	je     f01046aa <trap+0x3e>
f010468b:	8d 83 1b 8f f7 ff    	lea    -0x870e5(%ebx),%eax
f0104691:	50                   	push   %eax
f0104692:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0104698:	50                   	push   %eax
f0104699:	68 c8 00 00 00       	push   $0xc8
f010469e:	8d 83 0f 8f f7 ff    	lea    -0x870f1(%ebx),%eax
f01046a4:	50                   	push   %eax
f01046a5:	e8 07 ba ff ff       	call   f01000b1 <_panic>
	cprintf("Incoming TRAP frame at %p\n", tf);
f01046aa:	83 ec 08             	sub    $0x8,%esp
f01046ad:	56                   	push   %esi
f01046ae:	8d 83 34 8f f7 ff    	lea    -0x870cc(%ebx),%eax
f01046b4:	50                   	push   %eax
f01046b5:	e8 85 fb ff ff       	call   f010423f <cprintf>
	if ((tf->tf_cs & 3) == 3) {
f01046ba:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01046be:	83 e0 03             	and    $0x3,%eax
f01046c1:	83 c4 10             	add    $0x10,%esp
f01046c4:	66 83 f8 03          	cmp    $0x3,%ax
f01046c8:	75 1d                	jne    f01046e7 <trap+0x7b>
		assert(curenv);
f01046ca:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f01046d0:	8b 00                	mov    (%eax),%eax
f01046d2:	85 c0                	test   %eax,%eax
f01046d4:	74 5d                	je     f0104733 <trap+0xc7>
		curenv->env_tf = *tf;
f01046d6:	b9 11 00 00 00       	mov    $0x11,%ecx
f01046db:	89 c7                	mov    %eax,%edi
f01046dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01046df:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f01046e5:	8b 30                	mov    (%eax),%esi
	last_tf = tf;
f01046e7:	89 b3 88 29 00 00    	mov    %esi,0x2988(%ebx)
	switch (tf->tf_trapno)
f01046ed:	8b 46 28             	mov    0x28(%esi),%eax
f01046f0:	83 f8 0e             	cmp    $0xe,%eax
f01046f3:	0f 84 96 00 00 00    	je     f010478f <trap+0x123>
f01046f9:	83 f8 30             	cmp    $0x30,%eax
f01046fc:	0f 84 9b 00 00 00    	je     f010479d <trap+0x131>
f0104702:	83 f8 03             	cmp    $0x3,%eax
f0104705:	74 4b                	je     f0104752 <trap+0xe6>
		print_trapframe(tf);
f0104707:	83 ec 0c             	sub    $0xc,%esp
f010470a:	56                   	push   %esi
f010470b:	e8 2a fd ff ff       	call   f010443a <print_trapframe>
		if (tf->tf_cs == GD_KT)
f0104710:	83 c4 10             	add    $0x10,%esp
f0104713:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104718:	0f 84 a0 00 00 00    	je     f01047be <trap+0x152>
			env_destroy(curenv);
f010471e:	83 ec 0c             	sub    $0xc,%esp
f0104721:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f0104727:	ff 30                	pushl  (%eax)
f0104729:	e8 a3 f9 ff ff       	call   f01040d1 <env_destroy>
f010472e:	83 c4 10             	add    $0x10,%esp
f0104731:	eb 2b                	jmp    f010475e <trap+0xf2>
		assert(curenv);
f0104733:	8d 83 4f 8f f7 ff    	lea    -0x870b1(%ebx),%eax
f0104739:	50                   	push   %eax
f010473a:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f0104740:	50                   	push   %eax
f0104741:	68 cf 00 00 00       	push   $0xcf
f0104746:	8d 83 0f 8f f7 ff    	lea    -0x870f1(%ebx),%eax
f010474c:	50                   	push   %eax
f010474d:	e8 5f b9 ff ff       	call   f01000b1 <_panic>
		monitor(tf);
f0104752:	83 ec 0c             	sub    $0xc,%esp
f0104755:	56                   	push   %esi
f0104756:	e8 c1 c8 ff ff       	call   f010101c <monitor>
f010475b:	83 c4 10             	add    $0x10,%esp
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010475e:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f0104764:	8b 00                	mov    (%eax),%eax
f0104766:	85 c0                	test   %eax,%eax
f0104768:	74 06                	je     f0104770 <trap+0x104>
f010476a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010476e:	74 69                	je     f01047d9 <trap+0x16d>
f0104770:	8d 83 fc 90 f7 ff    	lea    -0x86f04(%ebx),%eax
f0104776:	50                   	push   %eax
f0104777:	8d 83 74 7c f7 ff    	lea    -0x8838c(%ebx),%eax
f010477d:	50                   	push   %eax
f010477e:	68 e4 00 00 00       	push   $0xe4
f0104783:	8d 83 0f 8f f7 ff    	lea    -0x870f1(%ebx),%eax
f0104789:	50                   	push   %eax
f010478a:	e8 22 b9 ff ff       	call   f01000b1 <_panic>
		page_fault_handler(tf);
f010478f:	83 ec 0c             	sub    $0xc,%esp
f0104792:	56                   	push   %esi
f0104793:	e8 61 fe ff ff       	call   f01045f9 <page_fault_handler>
f0104798:	83 c4 10             	add    $0x10,%esp
f010479b:	eb c1                	jmp    f010475e <trap+0xf2>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, 
f010479d:	83 ec 08             	sub    $0x8,%esp
f01047a0:	ff 76 04             	pushl  0x4(%esi)
f01047a3:	ff 36                	pushl  (%esi)
f01047a5:	ff 76 10             	pushl  0x10(%esi)
f01047a8:	ff 76 18             	pushl  0x18(%esi)
f01047ab:	ff 76 14             	pushl  0x14(%esi)
f01047ae:	ff 76 1c             	pushl  0x1c(%esi)
f01047b1:	e8 c2 01 00 00       	call   f0104978 <syscall>
f01047b6:	89 46 1c             	mov    %eax,0x1c(%esi)
f01047b9:	83 c4 20             	add    $0x20,%esp
f01047bc:	eb a0                	jmp    f010475e <trap+0xf2>
			panic("unhandled trap in kernel");
f01047be:	83 ec 04             	sub    $0x4,%esp
f01047c1:	8d 83 56 8f f7 ff    	lea    -0x870aa(%ebx),%eax
f01047c7:	50                   	push   %eax
f01047c8:	68 b4 00 00 00       	push   $0xb4
f01047cd:	8d 83 0f 8f f7 ff    	lea    -0x870f1(%ebx),%eax
f01047d3:	50                   	push   %eax
f01047d4:	e8 d8 b8 ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f01047d9:	83 ec 0c             	sub    $0xc,%esp
f01047dc:	50                   	push   %eax
f01047dd:	e8 5d f9 ff ff       	call   f010413f <env_run>

f01047e2 <handles0>:

.data
	.globl handles

handles:
	TRAPHANDLER_NOEC(handles0, T_DIVIDE)
f01047e2:	6a 00                	push   $0x0
f01047e4:	6a 00                	push   $0x0
f01047e6:	e9 7b 01 00 00       	jmp    f0104966 <_alltraps>
f01047eb:	90                   	nop

f01047ec <handles1>:
	TRAPHANDLER_NOEC(handles1, T_DEBUG)
f01047ec:	6a 00                	push   $0x0
f01047ee:	6a 01                	push   $0x1
f01047f0:	e9 71 01 00 00       	jmp    f0104966 <_alltraps>
f01047f5:	90                   	nop

f01047f6 <handles2>:
	TRAPHANDLER_NOEC(handles2, T_NMI)
f01047f6:	6a 00                	push   $0x0
f01047f8:	6a 02                	push   $0x2
f01047fa:	e9 67 01 00 00       	jmp    f0104966 <_alltraps>
f01047ff:	90                   	nop

f0104800 <handles3>:
	TRAPHANDLER_NOEC(handles3, T_BRKPT)
f0104800:	6a 00                	push   $0x0
f0104802:	6a 03                	push   $0x3
f0104804:	e9 5d 01 00 00       	jmp    f0104966 <_alltraps>
f0104809:	90                   	nop

f010480a <handles4>:
	TRAPHANDLER_NOEC(handles4, T_OFLOW)
f010480a:	6a 00                	push   $0x0
f010480c:	6a 04                	push   $0x4
f010480e:	e9 53 01 00 00       	jmp    f0104966 <_alltraps>
f0104813:	90                   	nop

f0104814 <handles5>:
	TRAPHANDLER_NOEC(handles5, T_BOUND)
f0104814:	6a 00                	push   $0x0
f0104816:	6a 05                	push   $0x5
f0104818:	e9 49 01 00 00       	jmp    f0104966 <_alltraps>
f010481d:	90                   	nop

f010481e <handles6>:
	TRAPHANDLER_NOEC(handles6, T_ILLOP)
f010481e:	6a 00                	push   $0x0
f0104820:	6a 06                	push   $0x6
f0104822:	e9 3f 01 00 00       	jmp    f0104966 <_alltraps>
f0104827:	90                   	nop

f0104828 <handles7>:
	TRAPHANDLER_NOEC(handles7, T_DEVICE)
f0104828:	6a 00                	push   $0x0
f010482a:	6a 07                	push   $0x7
f010482c:	e9 35 01 00 00       	jmp    f0104966 <_alltraps>
f0104831:	90                   	nop

f0104832 <handles8>:
	TRAPHANDLER(handles8, T_DBLFLT)
f0104832:	6a 08                	push   $0x8
f0104834:	e9 2d 01 00 00       	jmp    f0104966 <_alltraps>
f0104839:	90                   	nop

f010483a <handles9>:
	TRAPHANDLER_NOEC(handles9, 9)
f010483a:	6a 00                	push   $0x0
f010483c:	6a 09                	push   $0x9
f010483e:	e9 23 01 00 00       	jmp    f0104966 <_alltraps>
f0104843:	90                   	nop

f0104844 <handles10>:
	TRAPHANDLER(handles10, T_TSS)
f0104844:	6a 0a                	push   $0xa
f0104846:	e9 1b 01 00 00       	jmp    f0104966 <_alltraps>
f010484b:	90                   	nop

f010484c <handles11>:
	TRAPHANDLER(handles11, T_SEGNP)
f010484c:	6a 0b                	push   $0xb
f010484e:	e9 13 01 00 00       	jmp    f0104966 <_alltraps>
f0104853:	90                   	nop

f0104854 <handles12>:
	TRAPHANDLER(handles12, T_STACK)
f0104854:	6a 0c                	push   $0xc
f0104856:	e9 0b 01 00 00       	jmp    f0104966 <_alltraps>
f010485b:	90                   	nop

f010485c <handles13>:
	TRAPHANDLER(handles13, T_GPFLT)
f010485c:	6a 0d                	push   $0xd
f010485e:	e9 03 01 00 00       	jmp    f0104966 <_alltraps>
f0104863:	90                   	nop

f0104864 <handles14>:
	TRAPHANDLER(handles14, T_PGFLT)
f0104864:	6a 0e                	push   $0xe
f0104866:	e9 fb 00 00 00       	jmp    f0104966 <_alltraps>
f010486b:	90                   	nop

f010486c <handles15>:
	TRAPHANDLER_NOEC(handles15, 15)
f010486c:	6a 00                	push   $0x0
f010486e:	6a 0f                	push   $0xf
f0104870:	e9 f1 00 00 00       	jmp    f0104966 <_alltraps>
f0104875:	90                   	nop

f0104876 <handles16>:
	TRAPHANDLER_NOEC(handles16, T_FPERR)
f0104876:	6a 00                	push   $0x0
f0104878:	6a 10                	push   $0x10
f010487a:	e9 e7 00 00 00       	jmp    f0104966 <_alltraps>
f010487f:	90                   	nop

f0104880 <handles17>:
	TRAPHANDLER(handles17, T_ALIGN)
f0104880:	6a 11                	push   $0x11
f0104882:	e9 df 00 00 00       	jmp    f0104966 <_alltraps>
f0104887:	90                   	nop

f0104888 <handles18>:
	TRAPHANDLER_NOEC(handles18, T_MCHK)
f0104888:	6a 00                	push   $0x0
f010488a:	6a 12                	push   $0x12
f010488c:	e9 d5 00 00 00       	jmp    f0104966 <_alltraps>
f0104891:	90                   	nop

f0104892 <handles19>:
	TRAPHANDLER_NOEC(handles19, T_SIMDERR)
f0104892:	6a 00                	push   $0x0
f0104894:	6a 13                	push   $0x13
f0104896:	e9 cb 00 00 00       	jmp    f0104966 <_alltraps>
f010489b:	90                   	nop

f010489c <handles20>:
	TRAPHANDLER_NOEC(handles20, 20)
f010489c:	6a 00                	push   $0x0
f010489e:	6a 14                	push   $0x14
f01048a0:	e9 c1 00 00 00       	jmp    f0104966 <_alltraps>
f01048a5:	90                   	nop

f01048a6 <handles21>:
	TRAPHANDLER_NOEC(handles21, 21)
f01048a6:	6a 00                	push   $0x0
f01048a8:	6a 15                	push   $0x15
f01048aa:	e9 b7 00 00 00       	jmp    f0104966 <_alltraps>
f01048af:	90                   	nop

f01048b0 <handles22>:
	TRAPHANDLER_NOEC(handles22, 22)
f01048b0:	6a 00                	push   $0x0
f01048b2:	6a 16                	push   $0x16
f01048b4:	e9 ad 00 00 00       	jmp    f0104966 <_alltraps>
f01048b9:	90                   	nop

f01048ba <handles23>:
	TRAPHANDLER_NOEC(handles23, 23)
f01048ba:	6a 00                	push   $0x0
f01048bc:	6a 17                	push   $0x17
f01048be:	e9 a3 00 00 00       	jmp    f0104966 <_alltraps>
f01048c3:	90                   	nop

f01048c4 <handles24>:
	TRAPHANDLER_NOEC(handles24, 24)
f01048c4:	6a 00                	push   $0x0
f01048c6:	6a 18                	push   $0x18
f01048c8:	e9 99 00 00 00       	jmp    f0104966 <_alltraps>
f01048cd:	90                   	nop

f01048ce <handles25>:
	TRAPHANDLER_NOEC(handles25, 25)
f01048ce:	6a 00                	push   $0x0
f01048d0:	6a 19                	push   $0x19
f01048d2:	e9 8f 00 00 00       	jmp    f0104966 <_alltraps>
f01048d7:	90                   	nop

f01048d8 <handles26>:
	TRAPHANDLER_NOEC(handles26, 26)
f01048d8:	6a 00                	push   $0x0
f01048da:	6a 1a                	push   $0x1a
f01048dc:	e9 85 00 00 00       	jmp    f0104966 <_alltraps>
f01048e1:	90                   	nop

f01048e2 <handles27>:
	TRAPHANDLER_NOEC(handles27, 27)
f01048e2:	6a 00                	push   $0x0
f01048e4:	6a 1b                	push   $0x1b
f01048e6:	eb 7e                	jmp    f0104966 <_alltraps>

f01048e8 <handles28>:
	TRAPHANDLER_NOEC(handles28, 28)
f01048e8:	6a 00                	push   $0x0
f01048ea:	6a 1c                	push   $0x1c
f01048ec:	eb 78                	jmp    f0104966 <_alltraps>

f01048ee <handles29>:
	TRAPHANDLER_NOEC(handles29, 29)
f01048ee:	6a 00                	push   $0x0
f01048f0:	6a 1d                	push   $0x1d
f01048f2:	eb 72                	jmp    f0104966 <_alltraps>

f01048f4 <handles30>:
	TRAPHANDLER_NOEC(handles30, 30)
f01048f4:	6a 00                	push   $0x0
f01048f6:	6a 1e                	push   $0x1e
f01048f8:	eb 6c                	jmp    f0104966 <_alltraps>

f01048fa <handles31>:
	TRAPHANDLER_NOEC(handles31, 31)
f01048fa:	6a 00                	push   $0x0
f01048fc:	6a 1f                	push   $0x1f
f01048fe:	eb 66                	jmp    f0104966 <_alltraps>

f0104900 <handles32>:
	TRAPHANDLER_NOEC(handles32, 32)
f0104900:	6a 00                	push   $0x0
f0104902:	6a 20                	push   $0x20
f0104904:	eb 60                	jmp    f0104966 <_alltraps>

f0104906 <handles33>:
	TRAPHANDLER_NOEC(handles33, 33)
f0104906:	6a 00                	push   $0x0
f0104908:	6a 21                	push   $0x21
f010490a:	eb 5a                	jmp    f0104966 <_alltraps>

f010490c <handles34>:
	TRAPHANDLER_NOEC(handles34, 34)
f010490c:	6a 00                	push   $0x0
f010490e:	6a 22                	push   $0x22
f0104910:	eb 54                	jmp    f0104966 <_alltraps>

f0104912 <handles35>:
	TRAPHANDLER_NOEC(handles35, 35)
f0104912:	6a 00                	push   $0x0
f0104914:	6a 23                	push   $0x23
f0104916:	eb 4e                	jmp    f0104966 <_alltraps>

f0104918 <handles36>:
	TRAPHANDLER_NOEC(handles36, 36)
f0104918:	6a 00                	push   $0x0
f010491a:	6a 24                	push   $0x24
f010491c:	eb 48                	jmp    f0104966 <_alltraps>

f010491e <handles37>:
	TRAPHANDLER_NOEC(handles37, 37)
f010491e:	6a 00                	push   $0x0
f0104920:	6a 25                	push   $0x25
f0104922:	eb 42                	jmp    f0104966 <_alltraps>

f0104924 <handles38>:
	TRAPHANDLER_NOEC(handles38, 38)
f0104924:	6a 00                	push   $0x0
f0104926:	6a 26                	push   $0x26
f0104928:	eb 3c                	jmp    f0104966 <_alltraps>

f010492a <handles39>:
	TRAPHANDLER_NOEC(handles39, 39)
f010492a:	6a 00                	push   $0x0
f010492c:	6a 27                	push   $0x27
f010492e:	eb 36                	jmp    f0104966 <_alltraps>

f0104930 <handles40>:
	TRAPHANDLER_NOEC(handles40, 40)
f0104930:	6a 00                	push   $0x0
f0104932:	6a 28                	push   $0x28
f0104934:	eb 30                	jmp    f0104966 <_alltraps>

f0104936 <handles41>:
	TRAPHANDLER_NOEC(handles41, 41)
f0104936:	6a 00                	push   $0x0
f0104938:	6a 29                	push   $0x29
f010493a:	eb 2a                	jmp    f0104966 <_alltraps>

f010493c <handles42>:
	TRAPHANDLER_NOEC(handles42, 42)
f010493c:	6a 00                	push   $0x0
f010493e:	6a 2a                	push   $0x2a
f0104940:	eb 24                	jmp    f0104966 <_alltraps>

f0104942 <handles43>:
	TRAPHANDLER_NOEC(handles43, 43)
f0104942:	6a 00                	push   $0x0
f0104944:	6a 2b                	push   $0x2b
f0104946:	eb 1e                	jmp    f0104966 <_alltraps>

f0104948 <handles44>:
	TRAPHANDLER_NOEC(handles44, 44)
f0104948:	6a 00                	push   $0x0
f010494a:	6a 2c                	push   $0x2c
f010494c:	eb 18                	jmp    f0104966 <_alltraps>

f010494e <handles45>:
	TRAPHANDLER_NOEC(handles45, 45)
f010494e:	6a 00                	push   $0x0
f0104950:	6a 2d                	push   $0x2d
f0104952:	eb 12                	jmp    f0104966 <_alltraps>

f0104954 <handles46>:
	TRAPHANDLER_NOEC(handles46, 46)
f0104954:	6a 00                	push   $0x0
f0104956:	6a 2e                	push   $0x2e
f0104958:	eb 0c                	jmp    f0104966 <_alltraps>

f010495a <handles47>:
	TRAPHANDLER_NOEC(handles47, 47)
f010495a:	6a 00                	push   $0x0
f010495c:	6a 2f                	push   $0x2f
f010495e:	eb 06                	jmp    f0104966 <_alltraps>

f0104960 <handles48>:
	TRAPHANDLER_NOEC(handles48, T_SYSCALL)
f0104960:	6a 00                	push   $0x0
f0104962:	6a 30                	push   $0x30
f0104964:	eb 00                	jmp    f0104966 <_alltraps>

f0104966 <_alltraps>:
*/
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds;
f0104966:	1e                   	push   %ds
	pushl %es;
f0104967:	06                   	push   %es
	pushal;
f0104968:	60                   	pusha  
	movl $GD_KD, %eax;
f0104969:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds;
f010496e:	8e d8                	mov    %eax,%ds
	movw %ax, %es;
f0104970:	8e c0                	mov    %eax,%es
	push %esp;
f0104972:	54                   	push   %esp
f0104973:	e8 f4 fc ff ff       	call   f010466c <trap>

f0104978 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104978:	55                   	push   %ebp
f0104979:	89 e5                	mov    %esp,%ebp
f010497b:	53                   	push   %ebx
f010497c:	83 ec 14             	sub    $0x14,%esp
f010497f:	e8 e3 b7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104984:	81 c3 74 98 08 00    	add    $0x89874,%ebx
f010498a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch (syscallno) {
f010498d:	83 f8 02             	cmp    $0x2,%eax
f0104990:	74 47                	je     f01049d9 <syscall+0x61>
f0104992:	83 f8 03             	cmp    $0x3,%eax
f0104995:	74 4f                	je     f01049e6 <syscall+0x6e>
f0104997:	85 c0                	test   %eax,%eax
f0104999:	74 07                	je     f01049a2 <syscall+0x2a>
	case SYS_getenvid:
		return sys_getenvid();
	case SYS_env_destroy:
		return sys_env_destroy(sys_getenvid());
	default:
		return -E_INVAL;
f010499b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049a0:	eb 32                	jmp    f01049d4 <syscall+0x5c>
	user_mem_assert(curenv, s, len, PTE_U);
f01049a2:	6a 04                	push   $0x4
f01049a4:	ff 75 10             	pushl  0x10(%ebp)
f01049a7:	ff 75 0c             	pushl  0xc(%ebp)
f01049aa:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f01049b0:	ff 30                	pushl  (%eax)
f01049b2:	e8 a7 ef ff ff       	call   f010395e <user_mem_assert>
	cprintf("%.*s", len, s);
f01049b7:	83 c4 0c             	add    $0xc,%esp
f01049ba:	ff 75 0c             	pushl  0xc(%ebp)
f01049bd:	ff 75 10             	pushl  0x10(%ebp)
f01049c0:	8d 83 28 91 f7 ff    	lea    -0x86ed8(%ebx),%eax
f01049c6:	50                   	push   %eax
f01049c7:	e8 73 f8 ff ff       	call   f010423f <cprintf>
f01049cc:	83 c4 10             	add    $0x10,%esp
		return 0;
f01049cf:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
f01049d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01049d7:	c9                   	leave  
f01049d8:	c3                   	ret    
	return curenv->env_id;
f01049d9:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f01049df:	8b 00                	mov    (%eax),%eax
f01049e1:	8b 40 48             	mov    0x48(%eax),%eax
		return sys_getenvid();
f01049e4:	eb ee                	jmp    f01049d4 <syscall+0x5c>
	if ((r = envid2env(envid, &e, 1)) < 0)
f01049e6:	83 ec 04             	sub    $0x4,%esp
f01049e9:	6a 01                	push   $0x1
f01049eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01049ee:	50                   	push   %eax
	return curenv->env_id;
f01049ef:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f01049f5:	8b 00                	mov    (%eax),%eax
	if ((r = envid2env(envid, &e, 1)) < 0)
f01049f7:	ff 70 48             	pushl  0x48(%eax)
f01049fa:	e8 68 f0 ff ff       	call   f0103a67 <envid2env>
f01049ff:	83 c4 10             	add    $0x10,%esp
f0104a02:	85 c0                	test   %eax,%eax
f0104a04:	78 ce                	js     f01049d4 <syscall+0x5c>
	if (e == curenv)
f0104a06:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a09:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f0104a0f:	8b 00                	mov    (%eax),%eax
f0104a11:	39 c2                	cmp    %eax,%edx
f0104a13:	74 2d                	je     f0104a42 <syscall+0xca>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104a15:	83 ec 04             	sub    $0x4,%esp
f0104a18:	ff 72 48             	pushl  0x48(%edx)
f0104a1b:	ff 70 48             	pushl  0x48(%eax)
f0104a1e:	8d 83 48 91 f7 ff    	lea    -0x86eb8(%ebx),%eax
f0104a24:	50                   	push   %eax
f0104a25:	e8 15 f8 ff ff       	call   f010423f <cprintf>
f0104a2a:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104a2d:	83 ec 0c             	sub    $0xc,%esp
f0104a30:	ff 75 f4             	pushl  -0xc(%ebp)
f0104a33:	e8 99 f6 ff ff       	call   f01040d1 <env_destroy>
f0104a38:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104a3b:	b8 00 00 00 00       	mov    $0x0,%eax
		return sys_env_destroy(sys_getenvid());
f0104a40:	eb 92                	jmp    f01049d4 <syscall+0x5c>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104a42:	83 ec 08             	sub    $0x8,%esp
f0104a45:	ff 70 48             	pushl  0x48(%eax)
f0104a48:	8d 83 2d 91 f7 ff    	lea    -0x86ed3(%ebx),%eax
f0104a4e:	50                   	push   %eax
f0104a4f:	e8 eb f7 ff ff       	call   f010423f <cprintf>
f0104a54:	83 c4 10             	add    $0x10,%esp
f0104a57:	eb d4                	jmp    f0104a2d <syscall+0xb5>

f0104a59 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104a59:	55                   	push   %ebp
f0104a5a:	89 e5                	mov    %esp,%ebp
f0104a5c:	57                   	push   %edi
f0104a5d:	56                   	push   %esi
f0104a5e:	53                   	push   %ebx
f0104a5f:	83 ec 14             	sub    $0x14,%esp
f0104a62:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104a65:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104a68:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104a6b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104a6e:	8b 32                	mov    (%edx),%esi
f0104a70:	8b 01                	mov    (%ecx),%eax
f0104a72:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a75:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104a7c:	eb 2f                	jmp    f0104aad <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104a7e:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104a81:	39 c6                	cmp    %eax,%esi
f0104a83:	7f 49                	jg     f0104ace <stab_binsearch+0x75>
f0104a85:	0f b6 0a             	movzbl (%edx),%ecx
f0104a88:	83 ea 0c             	sub    $0xc,%edx
f0104a8b:	39 f9                	cmp    %edi,%ecx
f0104a8d:	75 ef                	jne    f0104a7e <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104a8f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104a92:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a95:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104a99:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104a9c:	73 35                	jae    f0104ad3 <stab_binsearch+0x7a>
			*region_left = m;
f0104a9e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104aa1:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104aa3:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104aa6:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104aad:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104ab0:	7f 4e                	jg     f0104b00 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0104ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104ab5:	01 f0                	add    %esi,%eax
f0104ab7:	89 c3                	mov    %eax,%ebx
f0104ab9:	c1 eb 1f             	shr    $0x1f,%ebx
f0104abc:	01 c3                	add    %eax,%ebx
f0104abe:	d1 fb                	sar    %ebx
f0104ac0:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104ac3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ac6:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104aca:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104acc:	eb b3                	jmp    f0104a81 <stab_binsearch+0x28>
			l = true_m + 1;
f0104ace:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0104ad1:	eb da                	jmp    f0104aad <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104ad3:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104ad6:	76 14                	jbe    f0104aec <stab_binsearch+0x93>
			*region_right = m - 1;
f0104ad8:	83 e8 01             	sub    $0x1,%eax
f0104adb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ade:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104ae1:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0104ae3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104aea:	eb c1                	jmp    f0104aad <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104aec:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104aef:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104af1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104af5:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0104af7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104afe:	eb ad                	jmp    f0104aad <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104b00:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104b04:	74 16                	je     f0104b1c <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b06:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b09:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b0b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b0e:	8b 0e                	mov    (%esi),%ecx
f0104b10:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b13:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104b16:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104b1a:	eb 12                	jmp    f0104b2e <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0104b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b1f:	8b 00                	mov    (%eax),%eax
f0104b21:	83 e8 01             	sub    $0x1,%eax
f0104b24:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104b27:	89 07                	mov    %eax,(%edi)
f0104b29:	eb 16                	jmp    f0104b41 <stab_binsearch+0xe8>
		     l--)
f0104b2b:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104b2e:	39 c1                	cmp    %eax,%ecx
f0104b30:	7d 0a                	jge    f0104b3c <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0104b32:	0f b6 1a             	movzbl (%edx),%ebx
f0104b35:	83 ea 0c             	sub    $0xc,%edx
f0104b38:	39 fb                	cmp    %edi,%ebx
f0104b3a:	75 ef                	jne    f0104b2b <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0104b3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b3f:	89 07                	mov    %eax,(%edi)
	}
}
f0104b41:	83 c4 14             	add    $0x14,%esp
f0104b44:	5b                   	pop    %ebx
f0104b45:	5e                   	pop    %esi
f0104b46:	5f                   	pop    %edi
f0104b47:	5d                   	pop    %ebp
f0104b48:	c3                   	ret    

f0104b49 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104b49:	55                   	push   %ebp
f0104b4a:	89 e5                	mov    %esp,%ebp
f0104b4c:	57                   	push   %edi
f0104b4d:	56                   	push   %esi
f0104b4e:	53                   	push   %ebx
f0104b4f:	83 ec 4c             	sub    $0x4c,%esp
f0104b52:	e8 10 b6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104b57:	81 c3 a1 96 08 00    	add    $0x896a1,%ebx
f0104b5d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104b60:	8d 83 60 91 f7 ff    	lea    -0x86ea0(%ebx),%eax
f0104b66:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0104b68:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0104b6f:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0104b72:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0104b79:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b7c:	89 47 10             	mov    %eax,0x10(%edi)
	info->eip_fn_narg = 0;
f0104b7f:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104b86:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0104b8b:	0f 86 29 01 00 00    	jbe    f0104cba <debuginfo_eip+0x171>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104b91:	c7 c0 04 38 11 f0    	mov    $0xf0113804,%eax
f0104b97:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104b9a:	c7 c0 c5 0a 11 f0    	mov    $0xf0110ac5,%eax
f0104ba0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104ba3:	c7 c6 c4 0a 11 f0    	mov    $0xf0110ac4,%esi
		stabs = __STAB_BEGIN__;
f0104ba9:	c7 c0 54 75 10 f0    	mov    $0xf0107554,%eax
f0104baf:	89 45 bc             	mov    %eax,-0x44(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104bb2:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104bb5:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0104bb8:	0f 83 62 02 00 00    	jae    f0104e20 <debuginfo_eip+0x2d7>
f0104bbe:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104bc2:	0f 85 5f 02 00 00    	jne    f0104e27 <debuginfo_eip+0x2de>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104bc8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104bcf:	2b 75 bc             	sub    -0x44(%ebp),%esi
f0104bd2:	c1 fe 02             	sar    $0x2,%esi
f0104bd5:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104bdb:	83 e8 01             	sub    $0x1,%eax
f0104bde:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104be1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104be4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104be7:	83 ec 08             	sub    $0x8,%esp
f0104bea:	ff 75 08             	pushl  0x8(%ebp)
f0104bed:	6a 64                	push   $0x64
f0104bef:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104bf2:	89 f0                	mov    %esi,%eax
f0104bf4:	e8 60 fe ff ff       	call   f0104a59 <stab_binsearch>
	if (lfile == 0)
f0104bf9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bfc:	83 c4 10             	add    $0x10,%esp
f0104bff:	85 c0                	test   %eax,%eax
f0104c01:	0f 84 27 02 00 00    	je     f0104e2e <debuginfo_eip+0x2e5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c07:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c0a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c0d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104c10:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104c13:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104c16:	83 ec 08             	sub    $0x8,%esp
f0104c19:	ff 75 08             	pushl  0x8(%ebp)
f0104c1c:	6a 24                	push   $0x24
f0104c1e:	89 f0                	mov    %esi,%eax
f0104c20:	e8 34 fe ff ff       	call   f0104a59 <stab_binsearch>

	if (lfun <= rfun) {
f0104c25:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104c28:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104c2b:	83 c4 10             	add    $0x10,%esp
f0104c2e:	39 d0                	cmp    %edx,%eax
f0104c30:	0f 8f 1c 01 00 00    	jg     f0104d52 <debuginfo_eip+0x209>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104c36:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104c39:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104c3c:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104c3f:	8b 36                	mov    (%esi),%esi
f0104c41:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104c44:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f0104c47:	39 ce                	cmp    %ecx,%esi
f0104c49:	73 06                	jae    f0104c51 <debuginfo_eip+0x108>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104c4b:	03 75 b4             	add    -0x4c(%ebp),%esi
f0104c4e:	89 77 08             	mov    %esi,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104c51:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104c54:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104c57:	89 4f 10             	mov    %ecx,0x10(%edi)
		addr -= info->eip_fn_addr;
f0104c5a:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0104c5d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104c60:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104c63:	83 ec 08             	sub    $0x8,%esp
f0104c66:	6a 3a                	push   $0x3a
f0104c68:	ff 77 08             	pushl  0x8(%edi)
f0104c6b:	e8 9c 0a 00 00       	call   f010570c <strfind>
f0104c70:	2b 47 08             	sub    0x8(%edi),%eax
f0104c73:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104c76:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104c79:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104c7c:	83 c4 08             	add    $0x8,%esp
f0104c7f:	ff 75 08             	pushl  0x8(%ebp)
f0104c82:	6a 44                	push   $0x44
f0104c84:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0104c87:	89 d8                	mov    %ebx,%eax
f0104c89:	e8 cb fd ff ff       	call   f0104a59 <stab_binsearch>
	// cprintf("symbol table: %d\n", stabs[lline].n_desc);
	info->eip_line = stabs[lline].n_desc;
f0104c8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104c91:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104c94:	c1 e2 02             	shl    $0x2,%edx
f0104c97:	0f b7 4c 13 06       	movzwl 0x6(%ebx,%edx,1),%ecx
f0104c9c:	89 4f 04             	mov    %ecx,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104c9f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ca2:	8d 54 13 04          	lea    0x4(%ebx,%edx,1),%edx
f0104ca6:	83 c4 10             	add    $0x10,%esp
f0104ca9:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104cad:	bb 01 00 00 00       	mov    $0x1,%ebx
f0104cb2:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0104cb5:	e9 b8 00 00 00       	jmp    f0104d72 <debuginfo_eip+0x229>
		if (user_mem_check(curenv, (void *)USTABDATA, sizeof(struct UserStabData), 0) < 0)
f0104cba:	6a 00                	push   $0x0
f0104cbc:	6a 10                	push   $0x10
f0104cbe:	68 00 00 20 00       	push   $0x200000
f0104cc3:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f0104cc9:	ff 30                	pushl  (%eax)
f0104ccb:	e8 00 ec ff ff       	call   f01038d0 <user_mem_check>
f0104cd0:	83 c4 10             	add    $0x10,%esp
f0104cd3:	85 c0                	test   %eax,%eax
f0104cd5:	0f 88 37 01 00 00    	js     f0104e12 <debuginfo_eip+0x2c9>
		stabs = usd->stabs;
f0104cdb:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f0104ce1:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f0104ce4:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104cea:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104cf0:	89 55 b4             	mov    %edx,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104cf3:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104cf8:	89 45 b8             	mov    %eax,-0x48(%ebp)
		if (user_mem_check(curenv, (void *)stabs, stab_end - stabs, 0) < 0 ||
f0104cfb:	6a 00                	push   $0x0
f0104cfd:	89 f0                	mov    %esi,%eax
f0104cff:	29 c8                	sub    %ecx,%eax
f0104d01:	c1 f8 02             	sar    $0x2,%eax
f0104d04:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104d0a:	50                   	push   %eax
f0104d0b:	51                   	push   %ecx
f0104d0c:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f0104d12:	ff 30                	pushl  (%eax)
f0104d14:	e8 b7 eb ff ff       	call   f01038d0 <user_mem_check>
f0104d19:	83 c4 10             	add    $0x10,%esp
f0104d1c:	85 c0                	test   %eax,%eax
f0104d1e:	0f 88 f5 00 00 00    	js     f0104e19 <debuginfo_eip+0x2d0>
			user_mem_check(curenv, (void *)stabstr, stabstr_end - stabstr, 0) < 0)
f0104d24:	6a 00                	push   $0x0
f0104d26:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104d29:	8b 55 b4             	mov    -0x4c(%ebp),%edx
f0104d2c:	29 d0                	sub    %edx,%eax
f0104d2e:	50                   	push   %eax
f0104d2f:	52                   	push   %edx
f0104d30:	c7 c0 64 03 19 f0    	mov    $0xf0190364,%eax
f0104d36:	ff 30                	pushl  (%eax)
f0104d38:	e8 93 eb ff ff       	call   f01038d0 <user_mem_check>
		if (user_mem_check(curenv, (void *)stabs, stab_end - stabs, 0) < 0 ||
f0104d3d:	83 c4 10             	add    $0x10,%esp
f0104d40:	85 c0                	test   %eax,%eax
f0104d42:	0f 89 6a fe ff ff    	jns    f0104bb2 <debuginfo_eip+0x69>
			return -1;
f0104d48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d4d:	e9 e8 00 00 00       	jmp    f0104e3a <debuginfo_eip+0x2f1>
		info->eip_fn_addr = addr;
f0104d52:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d55:	89 47 10             	mov    %eax,0x10(%edi)
		lline = lfile;
f0104d58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d5b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104d5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d61:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104d64:	e9 fa fe ff ff       	jmp    f0104c63 <debuginfo_eip+0x11a>
f0104d69:	83 e8 01             	sub    $0x1,%eax
f0104d6c:	83 ea 0c             	sub    $0xc,%edx
f0104d6f:	88 5d c4             	mov    %bl,-0x3c(%ebp)
f0104d72:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104d75:	39 c6                	cmp    %eax,%esi
f0104d77:	7f 24                	jg     f0104d9d <debuginfo_eip+0x254>
	       && stabs[lline].n_type != N_SOL
f0104d79:	0f b6 0a             	movzbl (%edx),%ecx
f0104d7c:	80 f9 84             	cmp    $0x84,%cl
f0104d7f:	74 46                	je     f0104dc7 <debuginfo_eip+0x27e>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104d81:	80 f9 64             	cmp    $0x64,%cl
f0104d84:	75 e3                	jne    f0104d69 <debuginfo_eip+0x220>
f0104d86:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104d8a:	74 dd                	je     f0104d69 <debuginfo_eip+0x220>
f0104d8c:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104d8f:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d93:	74 3b                	je     f0104dd0 <debuginfo_eip+0x287>
f0104d95:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104d98:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104d9b:	eb 33                	jmp    f0104dd0 <debuginfo_eip+0x287>
f0104d9d:	8b 7d 0c             	mov    0xc(%ebp),%edi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104da0:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104da3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104da6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104dab:	39 da                	cmp    %ebx,%edx
f0104dad:	0f 8d 87 00 00 00    	jge    f0104e3a <debuginfo_eip+0x2f1>
		for (lline = lfun + 1;
f0104db3:	83 c2 01             	add    $0x1,%edx
f0104db6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104db9:	89 d0                	mov    %edx,%eax
f0104dbb:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104dbe:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104dc1:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f0104dc5:	eb 32                	jmp    f0104df9 <debuginfo_eip+0x2b0>
f0104dc7:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104dca:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104dce:	75 1d                	jne    f0104ded <debuginfo_eip+0x2a4>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104dd0:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104dd3:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104dd6:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0104dd9:	8b 45 b8             	mov    -0x48(%ebp),%eax
f0104ddc:	8b 75 b4             	mov    -0x4c(%ebp),%esi
f0104ddf:	29 f0                	sub    %esi,%eax
f0104de1:	39 c2                	cmp    %eax,%edx
f0104de3:	73 bb                	jae    f0104da0 <debuginfo_eip+0x257>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104de5:	89 f0                	mov    %esi,%eax
f0104de7:	01 d0                	add    %edx,%eax
f0104de9:	89 07                	mov    %eax,(%edi)
f0104deb:	eb b3                	jmp    f0104da0 <debuginfo_eip+0x257>
f0104ded:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104df0:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104df3:	eb db                	jmp    f0104dd0 <debuginfo_eip+0x287>
			info->eip_fn_narg++;
f0104df5:	83 47 14 01          	addl   $0x1,0x14(%edi)
		for (lline = lfun + 1;
f0104df9:	39 c3                	cmp    %eax,%ebx
f0104dfb:	7e 38                	jle    f0104e35 <debuginfo_eip+0x2ec>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104dfd:	0f b6 0a             	movzbl (%edx),%ecx
f0104e00:	83 c0 01             	add    $0x1,%eax
f0104e03:	83 c2 0c             	add    $0xc,%edx
f0104e06:	80 f9 a0             	cmp    $0xa0,%cl
f0104e09:	74 ea                	je     f0104df5 <debuginfo_eip+0x2ac>
	return 0;
f0104e0b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e10:	eb 28                	jmp    f0104e3a <debuginfo_eip+0x2f1>
			return -1;
f0104e12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e17:	eb 21                	jmp    f0104e3a <debuginfo_eip+0x2f1>
			return -1;
f0104e19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e1e:	eb 1a                	jmp    f0104e3a <debuginfo_eip+0x2f1>
		return -1;
f0104e20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e25:	eb 13                	jmp    f0104e3a <debuginfo_eip+0x2f1>
f0104e27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e2c:	eb 0c                	jmp    f0104e3a <debuginfo_eip+0x2f1>
		return -1;
f0104e2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e33:	eb 05                	jmp    f0104e3a <debuginfo_eip+0x2f1>
	return 0;
f0104e35:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e3d:	5b                   	pop    %ebx
f0104e3e:	5e                   	pop    %esi
f0104e3f:	5f                   	pop    %edi
f0104e40:	5d                   	pop    %ebp
f0104e41:	c3                   	ret    

f0104e42 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104e42:	55                   	push   %ebp
f0104e43:	89 e5                	mov    %esp,%ebp
f0104e45:	57                   	push   %edi
f0104e46:	56                   	push   %esi
f0104e47:	53                   	push   %ebx
f0104e48:	83 ec 2c             	sub    $0x2c,%esp
f0104e4b:	e8 67 eb ff ff       	call   f01039b7 <__x86.get_pc_thunk.cx>
f0104e50:	81 c1 a8 93 08 00    	add    $0x893a8,%ecx
f0104e56:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0104e59:	89 c7                	mov    %eax,%edi
f0104e5b:	89 d6                	mov    %edx,%esi
f0104e5d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e60:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e63:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104e66:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104e69:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e6c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e71:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0104e74:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0104e77:	39 d3                	cmp    %edx,%ebx
f0104e79:	72 09                	jb     f0104e84 <printnum+0x42>
f0104e7b:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104e7e:	0f 87 83 00 00 00    	ja     f0104f07 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e84:	83 ec 0c             	sub    $0xc,%esp
f0104e87:	ff 75 18             	pushl  0x18(%ebp)
f0104e8a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e8d:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104e90:	53                   	push   %ebx
f0104e91:	ff 75 10             	pushl  0x10(%ebp)
f0104e94:	83 ec 08             	sub    $0x8,%esp
f0104e97:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e9a:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e9d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104ea0:	ff 75 d0             	pushl  -0x30(%ebp)
f0104ea3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104ea6:	e8 85 0a 00 00       	call   f0105930 <__udivdi3>
f0104eab:	83 c4 18             	add    $0x18,%esp
f0104eae:	52                   	push   %edx
f0104eaf:	50                   	push   %eax
f0104eb0:	89 f2                	mov    %esi,%edx
f0104eb2:	89 f8                	mov    %edi,%eax
f0104eb4:	e8 89 ff ff ff       	call   f0104e42 <printnum>
f0104eb9:	83 c4 20             	add    $0x20,%esp
f0104ebc:	eb 13                	jmp    f0104ed1 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104ebe:	83 ec 08             	sub    $0x8,%esp
f0104ec1:	56                   	push   %esi
f0104ec2:	ff 75 18             	pushl  0x18(%ebp)
f0104ec5:	ff d7                	call   *%edi
f0104ec7:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104eca:	83 eb 01             	sub    $0x1,%ebx
f0104ecd:	85 db                	test   %ebx,%ebx
f0104ecf:	7f ed                	jg     f0104ebe <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104ed1:	83 ec 08             	sub    $0x8,%esp
f0104ed4:	56                   	push   %esi
f0104ed5:	83 ec 04             	sub    $0x4,%esp
f0104ed8:	ff 75 dc             	pushl  -0x24(%ebp)
f0104edb:	ff 75 d8             	pushl  -0x28(%ebp)
f0104ede:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104ee1:	ff 75 d0             	pushl  -0x30(%ebp)
f0104ee4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ee7:	89 f3                	mov    %esi,%ebx
f0104ee9:	e8 62 0b 00 00       	call   f0105a50 <__umoddi3>
f0104eee:	83 c4 14             	add    $0x14,%esp
f0104ef1:	0f be 84 06 6a 91 f7 	movsbl -0x86e96(%esi,%eax,1),%eax
f0104ef8:	ff 
f0104ef9:	50                   	push   %eax
f0104efa:	ff d7                	call   *%edi
}
f0104efc:	83 c4 10             	add    $0x10,%esp
f0104eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f02:	5b                   	pop    %ebx
f0104f03:	5e                   	pop    %esi
f0104f04:	5f                   	pop    %edi
f0104f05:	5d                   	pop    %ebp
f0104f06:	c3                   	ret    
f0104f07:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104f0a:	eb be                	jmp    f0104eca <printnum+0x88>

f0104f0c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104f0c:	55                   	push   %ebp
f0104f0d:	89 e5                	mov    %esp,%ebp
f0104f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104f12:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104f16:	8b 10                	mov    (%eax),%edx
f0104f18:	3b 50 04             	cmp    0x4(%eax),%edx
f0104f1b:	73 0a                	jae    f0104f27 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104f1d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104f20:	89 08                	mov    %ecx,(%eax)
f0104f22:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f25:	88 02                	mov    %al,(%edx)
}
f0104f27:	5d                   	pop    %ebp
f0104f28:	c3                   	ret    

f0104f29 <printfmt>:
{
f0104f29:	55                   	push   %ebp
f0104f2a:	89 e5                	mov    %esp,%ebp
f0104f2c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104f2f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104f32:	50                   	push   %eax
f0104f33:	ff 75 10             	pushl  0x10(%ebp)
f0104f36:	ff 75 0c             	pushl  0xc(%ebp)
f0104f39:	ff 75 08             	pushl  0x8(%ebp)
f0104f3c:	e8 05 00 00 00       	call   f0104f46 <vprintfmt>
}
f0104f41:	83 c4 10             	add    $0x10,%esp
f0104f44:	c9                   	leave  
f0104f45:	c3                   	ret    

f0104f46 <vprintfmt>:
{
f0104f46:	55                   	push   %ebp
f0104f47:	89 e5                	mov    %esp,%ebp
f0104f49:	57                   	push   %edi
f0104f4a:	56                   	push   %esi
f0104f4b:	53                   	push   %ebx
f0104f4c:	83 ec 2c             	sub    $0x2c,%esp
f0104f4f:	e8 13 b2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104f54:	81 c3 a4 92 08 00    	add    $0x892a4,%ebx
f0104f5a:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
f0104f5d:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
f0104f64:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f66:	8d 77 01             	lea    0x1(%edi),%esi
f0104f69:	0f b6 07             	movzbl (%edi),%eax
f0104f6c:	83 f8 25             	cmp    $0x25,%eax
f0104f6f:	74 1c                	je     f0104f8d <vprintfmt+0x47>
			if (ch == '\0')
f0104f71:	85 c0                	test   %eax,%eax
f0104f73:	0f 84 b9 04 00 00    	je     f0105432 <.L21+0x20>
			putch(ch, putdat);
f0104f79:	83 ec 08             	sub    $0x8,%esp
f0104f7c:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
f0104f7f:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
f0104f82:	50                   	push   %eax
f0104f83:	ff 55 08             	call   *0x8(%ebp)
f0104f86:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f89:	89 f7                	mov    %esi,%edi
f0104f8b:	eb d9                	jmp    f0104f66 <vprintfmt+0x20>
		padc = ' ';
f0104f8d:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
f0104f91:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0104f98:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0104f9f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104fa6:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104fab:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104fae:	8d 7e 01             	lea    0x1(%esi),%edi
f0104fb1:	0f b6 16             	movzbl (%esi),%edx
f0104fb4:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104fb7:	3c 55                	cmp    $0x55,%al
f0104fb9:	0f 87 53 04 00 00    	ja     f0105412 <.L21>
f0104fbf:	0f b6 c0             	movzbl %al,%eax
f0104fc2:	89 d9                	mov    %ebx,%ecx
f0104fc4:	03 8c 83 f4 91 f7 ff 	add    -0x86e0c(%ebx,%eax,4),%ecx
f0104fcb:	ff e1                	jmp    *%ecx

f0104fcd <.L73>:
f0104fcd:	89 fe                	mov    %edi,%esi
			padc = '-';
f0104fcf:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f0104fd3:	eb d9                	jmp    f0104fae <vprintfmt+0x68>

f0104fd5 <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
f0104fd5:	89 fe                	mov    %edi,%esi
			padc = '0';
f0104fd7:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f0104fdb:	eb d1                	jmp    f0104fae <vprintfmt+0x68>

f0104fdd <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0104fdd:	0f b6 d2             	movzbl %dl,%edx
f0104fe0:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
f0104fe2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fe7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
f0104fea:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104fed:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104ff1:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
f0104ff4:	8d 7a d0             	lea    -0x30(%edx),%edi
f0104ff7:	83 ff 09             	cmp    $0x9,%edi
f0104ffa:	0f 87 94 00 00 00    	ja     f0105094 <.L33+0x42>
			for (precision = 0; ; ++fmt) {
f0105000:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f0105003:	eb e5                	jmp    f0104fea <.L28+0xd>

f0105005 <.L25>:
			precision = va_arg(ap, int);
f0105005:	8b 45 14             	mov    0x14(%ebp),%eax
f0105008:	8b 00                	mov    (%eax),%eax
f010500a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010500d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105010:	8d 40 04             	lea    0x4(%eax),%eax
f0105013:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105016:	89 fe                	mov    %edi,%esi
			if (width < 0)
f0105018:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010501c:	79 90                	jns    f0104fae <vprintfmt+0x68>
				width = precision, precision = -1;
f010501e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105021:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105024:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f010502b:	eb 81                	jmp    f0104fae <vprintfmt+0x68>

f010502d <.L26>:
f010502d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105030:	85 c0                	test   %eax,%eax
f0105032:	ba 00 00 00 00       	mov    $0x0,%edx
f0105037:	0f 49 d0             	cmovns %eax,%edx
f010503a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010503d:	89 fe                	mov    %edi,%esi
f010503f:	e9 6a ff ff ff       	jmp    f0104fae <vprintfmt+0x68>

f0105044 <.L22>:
f0105044:	89 fe                	mov    %edi,%esi
			altflag = 1;
f0105046:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010504d:	e9 5c ff ff ff       	jmp    f0104fae <vprintfmt+0x68>

f0105052 <.L33>:
f0105052:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0105055:	83 f9 01             	cmp    $0x1,%ecx
f0105058:	7e 16                	jle    f0105070 <.L33+0x1e>
		return va_arg(*ap, long long);
f010505a:	8b 45 14             	mov    0x14(%ebp),%eax
f010505d:	8b 00                	mov    (%eax),%eax
f010505f:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105062:	8d 49 08             	lea    0x8(%ecx),%ecx
f0105065:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
f0105068:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
f010506b:	e9 f6 fe ff ff       	jmp    f0104f66 <vprintfmt+0x20>
	else if (lflag)
f0105070:	85 c9                	test   %ecx,%ecx
f0105072:	75 10                	jne    f0105084 <.L33+0x32>
		return va_arg(*ap, int);
f0105074:	8b 45 14             	mov    0x14(%ebp),%eax
f0105077:	8b 00                	mov    (%eax),%eax
f0105079:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010507c:	8d 49 04             	lea    0x4(%ecx),%ecx
f010507f:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105082:	eb e4                	jmp    f0105068 <.L33+0x16>
		return va_arg(*ap, long);
f0105084:	8b 45 14             	mov    0x14(%ebp),%eax
f0105087:	8b 00                	mov    (%eax),%eax
f0105089:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010508c:	8d 49 04             	lea    0x4(%ecx),%ecx
f010508f:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105092:	eb d4                	jmp    f0105068 <.L33+0x16>
f0105094:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105097:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010509a:	e9 79 ff ff ff       	jmp    f0105018 <.L25+0x13>

f010509f <.L32>:
			lflag++;
f010509f:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01050a3:	89 fe                	mov    %edi,%esi
			goto reswitch;
f01050a5:	e9 04 ff ff ff       	jmp    f0104fae <vprintfmt+0x68>

f01050aa <.L29>:
			putch(va_arg(ap, int), putdat);
f01050aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01050ad:	8d 70 04             	lea    0x4(%eax),%esi
f01050b0:	83 ec 08             	sub    $0x8,%esp
f01050b3:	ff 75 0c             	pushl  0xc(%ebp)
f01050b6:	ff 30                	pushl  (%eax)
f01050b8:	ff 55 08             	call   *0x8(%ebp)
			break;
f01050bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01050be:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
f01050c1:	e9 a0 fe ff ff       	jmp    f0104f66 <vprintfmt+0x20>

f01050c6 <.L31>:
			err = va_arg(ap, int);
f01050c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01050c9:	8d 70 04             	lea    0x4(%eax),%esi
f01050cc:	8b 00                	mov    (%eax),%eax
f01050ce:	99                   	cltd   
f01050cf:	31 d0                	xor    %edx,%eax
f01050d1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01050d3:	83 f8 06             	cmp    $0x6,%eax
f01050d6:	7f 29                	jg     f0105101 <.L31+0x3b>
f01050d8:	8b 94 83 f8 1e 00 00 	mov    0x1ef8(%ebx,%eax,4),%edx
f01050df:	85 d2                	test   %edx,%edx
f01050e1:	74 1e                	je     f0105101 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
f01050e3:	52                   	push   %edx
f01050e4:	8d 83 86 7c f7 ff    	lea    -0x8837a(%ebx),%eax
f01050ea:	50                   	push   %eax
f01050eb:	ff 75 0c             	pushl  0xc(%ebp)
f01050ee:	ff 75 08             	pushl  0x8(%ebp)
f01050f1:	e8 33 fe ff ff       	call   f0104f29 <printfmt>
f01050f6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01050f9:	89 75 14             	mov    %esi,0x14(%ebp)
f01050fc:	e9 65 fe ff ff       	jmp    f0104f66 <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
f0105101:	50                   	push   %eax
f0105102:	8d 83 82 91 f7 ff    	lea    -0x86e7e(%ebx),%eax
f0105108:	50                   	push   %eax
f0105109:	ff 75 0c             	pushl  0xc(%ebp)
f010510c:	ff 75 08             	pushl  0x8(%ebp)
f010510f:	e8 15 fe ff ff       	call   f0104f29 <printfmt>
f0105114:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105117:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010511a:	e9 47 fe ff ff       	jmp    f0104f66 <vprintfmt+0x20>

f010511f <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f010511f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105122:	83 c0 04             	add    $0x4,%eax
f0105125:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105128:	8b 45 14             	mov    0x14(%ebp),%eax
f010512b:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f010512d:	85 f6                	test   %esi,%esi
f010512f:	8d 83 7b 91 f7 ff    	lea    -0x86e85(%ebx),%eax
f0105135:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0105138:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010513c:	0f 8e b4 00 00 00    	jle    f01051f6 <.L36+0xd7>
f0105142:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f0105146:	75 08                	jne    f0105150 <.L36+0x31>
f0105148:	89 7d 10             	mov    %edi,0x10(%ebp)
f010514b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010514e:	eb 6c                	jmp    f01051bc <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105150:	83 ec 08             	sub    $0x8,%esp
f0105153:	ff 75 cc             	pushl  -0x34(%ebp)
f0105156:	56                   	push   %esi
f0105157:	e8 6c 04 00 00       	call   f01055c8 <strnlen>
f010515c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010515f:	29 c2                	sub    %eax,%edx
f0105161:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105164:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0105167:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
f010516b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010516e:	89 d6                	mov    %edx,%esi
f0105170:	89 7d 10             	mov    %edi,0x10(%ebp)
f0105173:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105175:	eb 10                	jmp    f0105187 <.L36+0x68>
					putch(padc, putdat);
f0105177:	83 ec 08             	sub    $0x8,%esp
f010517a:	ff 75 0c             	pushl  0xc(%ebp)
f010517d:	57                   	push   %edi
f010517e:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0105181:	83 ee 01             	sub    $0x1,%esi
f0105184:	83 c4 10             	add    $0x10,%esp
f0105187:	85 f6                	test   %esi,%esi
f0105189:	7f ec                	jg     f0105177 <.L36+0x58>
f010518b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010518e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105191:	85 d2                	test   %edx,%edx
f0105193:	b8 00 00 00 00       	mov    $0x0,%eax
f0105198:	0f 49 c2             	cmovns %edx,%eax
f010519b:	29 c2                	sub    %eax,%edx
f010519d:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01051a0:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01051a3:	eb 17                	jmp    f01051bc <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
f01051a5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01051a9:	75 30                	jne    f01051db <.L36+0xbc>
					putch(ch, putdat);
f01051ab:	83 ec 08             	sub    $0x8,%esp
f01051ae:	ff 75 0c             	pushl  0xc(%ebp)
f01051b1:	50                   	push   %eax
f01051b2:	ff 55 08             	call   *0x8(%ebp)
f01051b5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01051b8:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01051bc:	83 c6 01             	add    $0x1,%esi
f01051bf:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f01051c3:	0f be c2             	movsbl %dl,%eax
f01051c6:	85 c0                	test   %eax,%eax
f01051c8:	74 58                	je     f0105222 <.L36+0x103>
f01051ca:	85 ff                	test   %edi,%edi
f01051cc:	78 d7                	js     f01051a5 <.L36+0x86>
f01051ce:	83 ef 01             	sub    $0x1,%edi
f01051d1:	79 d2                	jns    f01051a5 <.L36+0x86>
f01051d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01051d6:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01051d9:	eb 32                	jmp    f010520d <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
f01051db:	0f be d2             	movsbl %dl,%edx
f01051de:	83 ea 20             	sub    $0x20,%edx
f01051e1:	83 fa 5e             	cmp    $0x5e,%edx
f01051e4:	76 c5                	jbe    f01051ab <.L36+0x8c>
					putch('?', putdat);
f01051e6:	83 ec 08             	sub    $0x8,%esp
f01051e9:	ff 75 0c             	pushl  0xc(%ebp)
f01051ec:	6a 3f                	push   $0x3f
f01051ee:	ff 55 08             	call   *0x8(%ebp)
f01051f1:	83 c4 10             	add    $0x10,%esp
f01051f4:	eb c2                	jmp    f01051b8 <.L36+0x99>
f01051f6:	89 7d 10             	mov    %edi,0x10(%ebp)
f01051f9:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01051fc:	eb be                	jmp    f01051bc <.L36+0x9d>
				putch(' ', putdat);
f01051fe:	83 ec 08             	sub    $0x8,%esp
f0105201:	57                   	push   %edi
f0105202:	6a 20                	push   $0x20
f0105204:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0105207:	83 ee 01             	sub    $0x1,%esi
f010520a:	83 c4 10             	add    $0x10,%esp
f010520d:	85 f6                	test   %esi,%esi
f010520f:	7f ed                	jg     f01051fe <.L36+0xdf>
f0105211:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0105214:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
f0105217:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010521a:	89 45 14             	mov    %eax,0x14(%ebp)
f010521d:	e9 44 fd ff ff       	jmp    f0104f66 <vprintfmt+0x20>
f0105222:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105225:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105228:	eb e3                	jmp    f010520d <.L36+0xee>

f010522a <.L30>:
f010522a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f010522d:	83 f9 01             	cmp    $0x1,%ecx
f0105230:	7e 42                	jle    f0105274 <.L30+0x4a>
		return va_arg(*ap, long long);
f0105232:	8b 45 14             	mov    0x14(%ebp),%eax
f0105235:	8b 50 04             	mov    0x4(%eax),%edx
f0105238:	8b 00                	mov    (%eax),%eax
f010523a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010523d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105240:	8b 45 14             	mov    0x14(%ebp),%eax
f0105243:	8d 40 08             	lea    0x8(%eax),%eax
f0105246:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105249:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010524d:	79 5f                	jns    f01052ae <.L30+0x84>
				putch('-', putdat);
f010524f:	83 ec 08             	sub    $0x8,%esp
f0105252:	ff 75 0c             	pushl  0xc(%ebp)
f0105255:	6a 2d                	push   $0x2d
f0105257:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010525a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010525d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105260:	f7 da                	neg    %edx
f0105262:	83 d1 00             	adc    $0x0,%ecx
f0105265:	f7 d9                	neg    %ecx
f0105267:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010526a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010526f:	e9 b8 00 00 00       	jmp    f010532c <.L34+0x22>
	else if (lflag)
f0105274:	85 c9                	test   %ecx,%ecx
f0105276:	75 1b                	jne    f0105293 <.L30+0x69>
		return va_arg(*ap, int);
f0105278:	8b 45 14             	mov    0x14(%ebp),%eax
f010527b:	8b 30                	mov    (%eax),%esi
f010527d:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0105280:	89 f0                	mov    %esi,%eax
f0105282:	c1 f8 1f             	sar    $0x1f,%eax
f0105285:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105288:	8b 45 14             	mov    0x14(%ebp),%eax
f010528b:	8d 40 04             	lea    0x4(%eax),%eax
f010528e:	89 45 14             	mov    %eax,0x14(%ebp)
f0105291:	eb b6                	jmp    f0105249 <.L30+0x1f>
		return va_arg(*ap, long);
f0105293:	8b 45 14             	mov    0x14(%ebp),%eax
f0105296:	8b 30                	mov    (%eax),%esi
f0105298:	89 75 d8             	mov    %esi,-0x28(%ebp)
f010529b:	89 f0                	mov    %esi,%eax
f010529d:	c1 f8 1f             	sar    $0x1f,%eax
f01052a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01052a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01052a6:	8d 40 04             	lea    0x4(%eax),%eax
f01052a9:	89 45 14             	mov    %eax,0x14(%ebp)
f01052ac:	eb 9b                	jmp    f0105249 <.L30+0x1f>
			num = getint(&ap, lflag);
f01052ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01052b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01052b4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01052b9:	eb 71                	jmp    f010532c <.L34+0x22>

f01052bb <.L37>:
f01052bb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f01052be:	83 f9 01             	cmp    $0x1,%ecx
f01052c1:	7e 15                	jle    f01052d8 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
f01052c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01052c6:	8b 10                	mov    (%eax),%edx
f01052c8:	8b 48 04             	mov    0x4(%eax),%ecx
f01052cb:	8d 40 08             	lea    0x8(%eax),%eax
f01052ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01052d1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01052d6:	eb 54                	jmp    f010532c <.L34+0x22>
	else if (lflag)
f01052d8:	85 c9                	test   %ecx,%ecx
f01052da:	75 17                	jne    f01052f3 <.L37+0x38>
		return va_arg(*ap, unsigned int);
f01052dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01052df:	8b 10                	mov    (%eax),%edx
f01052e1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01052e6:	8d 40 04             	lea    0x4(%eax),%eax
f01052e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01052ec:	b8 0a 00 00 00       	mov    $0xa,%eax
f01052f1:	eb 39                	jmp    f010532c <.L34+0x22>
		return va_arg(*ap, unsigned long);
f01052f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01052f6:	8b 10                	mov    (%eax),%edx
f01052f8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01052fd:	8d 40 04             	lea    0x4(%eax),%eax
f0105300:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105303:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105308:	eb 22                	jmp    f010532c <.L34+0x22>

f010530a <.L34>:
f010530a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f010530d:	83 f9 01             	cmp    $0x1,%ecx
f0105310:	7e 3b                	jle    f010534d <.L34+0x43>
		return va_arg(*ap, long long);
f0105312:	8b 45 14             	mov    0x14(%ebp),%eax
f0105315:	8b 50 04             	mov    0x4(%eax),%edx
f0105318:	8b 00                	mov    (%eax),%eax
f010531a:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010531d:	8d 49 08             	lea    0x8(%ecx),%ecx
f0105320:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
f0105323:	89 d1                	mov    %edx,%ecx
f0105325:	89 c2                	mov    %eax,%edx
			base = 8;
f0105327:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
f010532c:	83 ec 0c             	sub    $0xc,%esp
f010532f:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
f0105333:	56                   	push   %esi
f0105334:	ff 75 e0             	pushl  -0x20(%ebp)
f0105337:	50                   	push   %eax
f0105338:	51                   	push   %ecx
f0105339:	52                   	push   %edx
f010533a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010533d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105340:	e8 fd fa ff ff       	call   f0104e42 <printnum>
			break;
f0105345:	83 c4 20             	add    $0x20,%esp
f0105348:	e9 19 fc ff ff       	jmp    f0104f66 <vprintfmt+0x20>
	else if (lflag)
f010534d:	85 c9                	test   %ecx,%ecx
f010534f:	75 13                	jne    f0105364 <.L34+0x5a>
		return va_arg(*ap, int);
f0105351:	8b 45 14             	mov    0x14(%ebp),%eax
f0105354:	8b 10                	mov    (%eax),%edx
f0105356:	89 d0                	mov    %edx,%eax
f0105358:	99                   	cltd   
f0105359:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010535c:	8d 49 04             	lea    0x4(%ecx),%ecx
f010535f:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105362:	eb bf                	jmp    f0105323 <.L34+0x19>
		return va_arg(*ap, long);
f0105364:	8b 45 14             	mov    0x14(%ebp),%eax
f0105367:	8b 10                	mov    (%eax),%edx
f0105369:	89 d0                	mov    %edx,%eax
f010536b:	99                   	cltd   
f010536c:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010536f:	8d 49 04             	lea    0x4(%ecx),%ecx
f0105372:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0105375:	eb ac                	jmp    f0105323 <.L34+0x19>

f0105377 <.L35>:
			putch('0', putdat);
f0105377:	83 ec 08             	sub    $0x8,%esp
f010537a:	ff 75 0c             	pushl  0xc(%ebp)
f010537d:	6a 30                	push   $0x30
f010537f:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105382:	83 c4 08             	add    $0x8,%esp
f0105385:	ff 75 0c             	pushl  0xc(%ebp)
f0105388:	6a 78                	push   $0x78
f010538a:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f010538d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105390:	8b 10                	mov    (%eax),%edx
f0105392:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105397:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010539a:	8d 40 04             	lea    0x4(%eax),%eax
f010539d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01053a0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01053a5:	eb 85                	jmp    f010532c <.L34+0x22>

f01053a7 <.L38>:
f01053a7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f01053aa:	83 f9 01             	cmp    $0x1,%ecx
f01053ad:	7e 18                	jle    f01053c7 <.L38+0x20>
		return va_arg(*ap, unsigned long long);
f01053af:	8b 45 14             	mov    0x14(%ebp),%eax
f01053b2:	8b 10                	mov    (%eax),%edx
f01053b4:	8b 48 04             	mov    0x4(%eax),%ecx
f01053b7:	8d 40 08             	lea    0x8(%eax),%eax
f01053ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01053bd:	b8 10 00 00 00       	mov    $0x10,%eax
f01053c2:	e9 65 ff ff ff       	jmp    f010532c <.L34+0x22>
	else if (lflag)
f01053c7:	85 c9                	test   %ecx,%ecx
f01053c9:	75 1a                	jne    f01053e5 <.L38+0x3e>
		return va_arg(*ap, unsigned int);
f01053cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01053ce:	8b 10                	mov    (%eax),%edx
f01053d0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01053d5:	8d 40 04             	lea    0x4(%eax),%eax
f01053d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01053db:	b8 10 00 00 00       	mov    $0x10,%eax
f01053e0:	e9 47 ff ff ff       	jmp    f010532c <.L34+0x22>
		return va_arg(*ap, unsigned long);
f01053e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01053e8:	8b 10                	mov    (%eax),%edx
f01053ea:	b9 00 00 00 00       	mov    $0x0,%ecx
f01053ef:	8d 40 04             	lea    0x4(%eax),%eax
f01053f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01053f5:	b8 10 00 00 00       	mov    $0x10,%eax
f01053fa:	e9 2d ff ff ff       	jmp    f010532c <.L34+0x22>

f01053ff <.L24>:
			putch(ch, putdat);
f01053ff:	83 ec 08             	sub    $0x8,%esp
f0105402:	ff 75 0c             	pushl  0xc(%ebp)
f0105405:	6a 25                	push   $0x25
f0105407:	ff 55 08             	call   *0x8(%ebp)
			break;
f010540a:	83 c4 10             	add    $0x10,%esp
f010540d:	e9 54 fb ff ff       	jmp    f0104f66 <vprintfmt+0x20>

f0105412 <.L21>:
			putch('%', putdat);
f0105412:	83 ec 08             	sub    $0x8,%esp
f0105415:	ff 75 0c             	pushl  0xc(%ebp)
f0105418:	6a 25                	push   $0x25
f010541a:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010541d:	83 c4 10             	add    $0x10,%esp
f0105420:	89 f7                	mov    %esi,%edi
f0105422:	eb 03                	jmp    f0105427 <.L21+0x15>
f0105424:	83 ef 01             	sub    $0x1,%edi
f0105427:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010542b:	75 f7                	jne    f0105424 <.L21+0x12>
f010542d:	e9 34 fb ff ff       	jmp    f0104f66 <vprintfmt+0x20>
}
f0105432:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105435:	5b                   	pop    %ebx
f0105436:	5e                   	pop    %esi
f0105437:	5f                   	pop    %edi
f0105438:	5d                   	pop    %ebp
f0105439:	c3                   	ret    

f010543a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010543a:	55                   	push   %ebp
f010543b:	89 e5                	mov    %esp,%ebp
f010543d:	53                   	push   %ebx
f010543e:	83 ec 14             	sub    $0x14,%esp
f0105441:	e8 21 ad ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0105446:	81 c3 b2 8d 08 00    	add    $0x88db2,%ebx
f010544c:	8b 45 08             	mov    0x8(%ebp),%eax
f010544f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105452:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105455:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105459:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010545c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105463:	85 c0                	test   %eax,%eax
f0105465:	74 2b                	je     f0105492 <vsnprintf+0x58>
f0105467:	85 d2                	test   %edx,%edx
f0105469:	7e 27                	jle    f0105492 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010546b:	ff 75 14             	pushl  0x14(%ebp)
f010546e:	ff 75 10             	pushl  0x10(%ebp)
f0105471:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105474:	50                   	push   %eax
f0105475:	8d 83 14 6d f7 ff    	lea    -0x892ec(%ebx),%eax
f010547b:	50                   	push   %eax
f010547c:	e8 c5 fa ff ff       	call   f0104f46 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105481:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105484:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105487:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010548a:	83 c4 10             	add    $0x10,%esp
}
f010548d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105490:	c9                   	leave  
f0105491:	c3                   	ret    
		return -E_INVAL;
f0105492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105497:	eb f4                	jmp    f010548d <vsnprintf+0x53>

f0105499 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105499:	55                   	push   %ebp
f010549a:	89 e5                	mov    %esp,%ebp
f010549c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010549f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01054a2:	50                   	push   %eax
f01054a3:	ff 75 10             	pushl  0x10(%ebp)
f01054a6:	ff 75 0c             	pushl  0xc(%ebp)
f01054a9:	ff 75 08             	pushl  0x8(%ebp)
f01054ac:	e8 89 ff ff ff       	call   f010543a <vsnprintf>
	va_end(ap);

	return rc;
}
f01054b1:	c9                   	leave  
f01054b2:	c3                   	ret    

f01054b3 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01054b3:	55                   	push   %ebp
f01054b4:	89 e5                	mov    %esp,%ebp
f01054b6:	57                   	push   %edi
f01054b7:	56                   	push   %esi
f01054b8:	53                   	push   %ebx
f01054b9:	83 ec 1c             	sub    $0x1c,%esp
f01054bc:	e8 a6 ac ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01054c1:	81 c3 37 8d 08 00    	add    $0x88d37,%ebx
f01054c7:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01054ca:	85 c0                	test   %eax,%eax
f01054cc:	74 13                	je     f01054e1 <readline+0x2e>
		cprintf("%s", prompt);
f01054ce:	83 ec 08             	sub    $0x8,%esp
f01054d1:	50                   	push   %eax
f01054d2:	8d 83 86 7c f7 ff    	lea    -0x8837a(%ebx),%eax
f01054d8:	50                   	push   %eax
f01054d9:	e8 61 ed ff ff       	call   f010423f <cprintf>
f01054de:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01054e1:	83 ec 0c             	sub    $0xc,%esp
f01054e4:	6a 00                	push   $0x0
f01054e6:	e8 14 b2 ff ff       	call   f01006ff <iscons>
f01054eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054ee:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01054f1:	bf 00 00 00 00       	mov    $0x0,%edi
f01054f6:	eb 46                	jmp    f010553e <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01054f8:	83 ec 08             	sub    $0x8,%esp
f01054fb:	50                   	push   %eax
f01054fc:	8d 83 4c 93 f7 ff    	lea    -0x86cb4(%ebx),%eax
f0105502:	50                   	push   %eax
f0105503:	e8 37 ed ff ff       	call   f010423f <cprintf>
			return NULL;
f0105508:	83 c4 10             	add    $0x10,%esp
f010550b:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105510:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105513:	5b                   	pop    %ebx
f0105514:	5e                   	pop    %esi
f0105515:	5f                   	pop    %edi
f0105516:	5d                   	pop    %ebp
f0105517:	c3                   	ret    
			if (echoing)
f0105518:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010551c:	75 05                	jne    f0105523 <readline+0x70>
			i--;
f010551e:	83 ef 01             	sub    $0x1,%edi
f0105521:	eb 1b                	jmp    f010553e <readline+0x8b>
				cputchar('\b');
f0105523:	83 ec 0c             	sub    $0xc,%esp
f0105526:	6a 08                	push   $0x8
f0105528:	e8 b1 b1 ff ff       	call   f01006de <cputchar>
f010552d:	83 c4 10             	add    $0x10,%esp
f0105530:	eb ec                	jmp    f010551e <readline+0x6b>
			buf[i++] = c;
f0105532:	89 f0                	mov    %esi,%eax
f0105534:	88 84 3b 28 2a 00 00 	mov    %al,0x2a28(%ebx,%edi,1)
f010553b:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f010553e:	e8 ab b1 ff ff       	call   f01006ee <getchar>
f0105543:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0105545:	85 c0                	test   %eax,%eax
f0105547:	78 af                	js     f01054f8 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105549:	83 f8 08             	cmp    $0x8,%eax
f010554c:	0f 94 c2             	sete   %dl
f010554f:	83 f8 7f             	cmp    $0x7f,%eax
f0105552:	0f 94 c0             	sete   %al
f0105555:	08 c2                	or     %al,%dl
f0105557:	74 04                	je     f010555d <readline+0xaa>
f0105559:	85 ff                	test   %edi,%edi
f010555b:	7f bb                	jg     f0105518 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010555d:	83 fe 1f             	cmp    $0x1f,%esi
f0105560:	7e 1c                	jle    f010557e <readline+0xcb>
f0105562:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0105568:	7f 14                	jg     f010557e <readline+0xcb>
			if (echoing)
f010556a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010556e:	74 c2                	je     f0105532 <readline+0x7f>
				cputchar(c);
f0105570:	83 ec 0c             	sub    $0xc,%esp
f0105573:	56                   	push   %esi
f0105574:	e8 65 b1 ff ff       	call   f01006de <cputchar>
f0105579:	83 c4 10             	add    $0x10,%esp
f010557c:	eb b4                	jmp    f0105532 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f010557e:	83 fe 0a             	cmp    $0xa,%esi
f0105581:	74 05                	je     f0105588 <readline+0xd5>
f0105583:	83 fe 0d             	cmp    $0xd,%esi
f0105586:	75 b6                	jne    f010553e <readline+0x8b>
			if (echoing)
f0105588:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010558c:	75 13                	jne    f01055a1 <readline+0xee>
			buf[i] = 0;
f010558e:	c6 84 3b 28 2a 00 00 	movb   $0x0,0x2a28(%ebx,%edi,1)
f0105595:	00 
			return buf;
f0105596:	8d 83 28 2a 00 00    	lea    0x2a28(%ebx),%eax
f010559c:	e9 6f ff ff ff       	jmp    f0105510 <readline+0x5d>
				cputchar('\n');
f01055a1:	83 ec 0c             	sub    $0xc,%esp
f01055a4:	6a 0a                	push   $0xa
f01055a6:	e8 33 b1 ff ff       	call   f01006de <cputchar>
f01055ab:	83 c4 10             	add    $0x10,%esp
f01055ae:	eb de                	jmp    f010558e <readline+0xdb>

f01055b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055b0:	55                   	push   %ebp
f01055b1:	89 e5                	mov    %esp,%ebp
f01055b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01055b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01055bb:	eb 03                	jmp    f01055c0 <strlen+0x10>
		n++;
f01055bd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01055c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01055c4:	75 f7                	jne    f01055bd <strlen+0xd>
	return n;
}
f01055c6:	5d                   	pop    %ebp
f01055c7:	c3                   	ret    

f01055c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01055c8:	55                   	push   %ebp
f01055c9:	89 e5                	mov    %esp,%ebp
f01055cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01055ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055d1:	b8 00 00 00 00       	mov    $0x0,%eax
f01055d6:	eb 03                	jmp    f01055db <strnlen+0x13>
		n++;
f01055d8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055db:	39 d0                	cmp    %edx,%eax
f01055dd:	74 06                	je     f01055e5 <strnlen+0x1d>
f01055df:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01055e3:	75 f3                	jne    f01055d8 <strnlen+0x10>
	return n;
}
f01055e5:	5d                   	pop    %ebp
f01055e6:	c3                   	ret    

f01055e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01055e7:	55                   	push   %ebp
f01055e8:	89 e5                	mov    %esp,%ebp
f01055ea:	53                   	push   %ebx
f01055eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01055ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01055f1:	89 c2                	mov    %eax,%edx
f01055f3:	83 c1 01             	add    $0x1,%ecx
f01055f6:	83 c2 01             	add    $0x1,%edx
f01055f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01055fd:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105600:	84 db                	test   %bl,%bl
f0105602:	75 ef                	jne    f01055f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105604:	5b                   	pop    %ebx
f0105605:	5d                   	pop    %ebp
f0105606:	c3                   	ret    

f0105607 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105607:	55                   	push   %ebp
f0105608:	89 e5                	mov    %esp,%ebp
f010560a:	53                   	push   %ebx
f010560b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010560e:	53                   	push   %ebx
f010560f:	e8 9c ff ff ff       	call   f01055b0 <strlen>
f0105614:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105617:	ff 75 0c             	pushl  0xc(%ebp)
f010561a:	01 d8                	add    %ebx,%eax
f010561c:	50                   	push   %eax
f010561d:	e8 c5 ff ff ff       	call   f01055e7 <strcpy>
	return dst;
}
f0105622:	89 d8                	mov    %ebx,%eax
f0105624:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105627:	c9                   	leave  
f0105628:	c3                   	ret    

f0105629 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105629:	55                   	push   %ebp
f010562a:	89 e5                	mov    %esp,%ebp
f010562c:	56                   	push   %esi
f010562d:	53                   	push   %ebx
f010562e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105631:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105634:	89 f3                	mov    %esi,%ebx
f0105636:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105639:	89 f2                	mov    %esi,%edx
f010563b:	eb 0f                	jmp    f010564c <strncpy+0x23>
		*dst++ = *src;
f010563d:	83 c2 01             	add    $0x1,%edx
f0105640:	0f b6 01             	movzbl (%ecx),%eax
f0105643:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105646:	80 39 01             	cmpb   $0x1,(%ecx)
f0105649:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f010564c:	39 da                	cmp    %ebx,%edx
f010564e:	75 ed                	jne    f010563d <strncpy+0x14>
	}
	return ret;
}
f0105650:	89 f0                	mov    %esi,%eax
f0105652:	5b                   	pop    %ebx
f0105653:	5e                   	pop    %esi
f0105654:	5d                   	pop    %ebp
f0105655:	c3                   	ret    

f0105656 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105656:	55                   	push   %ebp
f0105657:	89 e5                	mov    %esp,%ebp
f0105659:	56                   	push   %esi
f010565a:	53                   	push   %ebx
f010565b:	8b 75 08             	mov    0x8(%ebp),%esi
f010565e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105661:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105664:	89 f0                	mov    %esi,%eax
f0105666:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010566a:	85 c9                	test   %ecx,%ecx
f010566c:	75 0b                	jne    f0105679 <strlcpy+0x23>
f010566e:	eb 17                	jmp    f0105687 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105670:	83 c2 01             	add    $0x1,%edx
f0105673:	83 c0 01             	add    $0x1,%eax
f0105676:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105679:	39 d8                	cmp    %ebx,%eax
f010567b:	74 07                	je     f0105684 <strlcpy+0x2e>
f010567d:	0f b6 0a             	movzbl (%edx),%ecx
f0105680:	84 c9                	test   %cl,%cl
f0105682:	75 ec                	jne    f0105670 <strlcpy+0x1a>
		*dst = '\0';
f0105684:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105687:	29 f0                	sub    %esi,%eax
}
f0105689:	5b                   	pop    %ebx
f010568a:	5e                   	pop    %esi
f010568b:	5d                   	pop    %ebp
f010568c:	c3                   	ret    

f010568d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010568d:	55                   	push   %ebp
f010568e:	89 e5                	mov    %esp,%ebp
f0105690:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105693:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105696:	eb 06                	jmp    f010569e <strcmp+0x11>
		p++, q++;
f0105698:	83 c1 01             	add    $0x1,%ecx
f010569b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f010569e:	0f b6 01             	movzbl (%ecx),%eax
f01056a1:	84 c0                	test   %al,%al
f01056a3:	74 04                	je     f01056a9 <strcmp+0x1c>
f01056a5:	3a 02                	cmp    (%edx),%al
f01056a7:	74 ef                	je     f0105698 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01056a9:	0f b6 c0             	movzbl %al,%eax
f01056ac:	0f b6 12             	movzbl (%edx),%edx
f01056af:	29 d0                	sub    %edx,%eax
}
f01056b1:	5d                   	pop    %ebp
f01056b2:	c3                   	ret    

f01056b3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056b3:	55                   	push   %ebp
f01056b4:	89 e5                	mov    %esp,%ebp
f01056b6:	53                   	push   %ebx
f01056b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01056ba:	8b 55 0c             	mov    0xc(%ebp),%edx
f01056bd:	89 c3                	mov    %eax,%ebx
f01056bf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01056c2:	eb 06                	jmp    f01056ca <strncmp+0x17>
		n--, p++, q++;
f01056c4:	83 c0 01             	add    $0x1,%eax
f01056c7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01056ca:	39 d8                	cmp    %ebx,%eax
f01056cc:	74 16                	je     f01056e4 <strncmp+0x31>
f01056ce:	0f b6 08             	movzbl (%eax),%ecx
f01056d1:	84 c9                	test   %cl,%cl
f01056d3:	74 04                	je     f01056d9 <strncmp+0x26>
f01056d5:	3a 0a                	cmp    (%edx),%cl
f01056d7:	74 eb                	je     f01056c4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01056d9:	0f b6 00             	movzbl (%eax),%eax
f01056dc:	0f b6 12             	movzbl (%edx),%edx
f01056df:	29 d0                	sub    %edx,%eax
}
f01056e1:	5b                   	pop    %ebx
f01056e2:	5d                   	pop    %ebp
f01056e3:	c3                   	ret    
		return 0;
f01056e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01056e9:	eb f6                	jmp    f01056e1 <strncmp+0x2e>

f01056eb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01056eb:	55                   	push   %ebp
f01056ec:	89 e5                	mov    %esp,%ebp
f01056ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01056f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01056f5:	0f b6 10             	movzbl (%eax),%edx
f01056f8:	84 d2                	test   %dl,%dl
f01056fa:	74 09                	je     f0105705 <strchr+0x1a>
		if (*s == c)
f01056fc:	38 ca                	cmp    %cl,%dl
f01056fe:	74 0a                	je     f010570a <strchr+0x1f>
	for (; *s; s++)
f0105700:	83 c0 01             	add    $0x1,%eax
f0105703:	eb f0                	jmp    f01056f5 <strchr+0xa>
			return (char *) s;
	return 0;
f0105705:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010570a:	5d                   	pop    %ebp
f010570b:	c3                   	ret    

f010570c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010570c:	55                   	push   %ebp
f010570d:	89 e5                	mov    %esp,%ebp
f010570f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105712:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105716:	eb 03                	jmp    f010571b <strfind+0xf>
f0105718:	83 c0 01             	add    $0x1,%eax
f010571b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010571e:	38 ca                	cmp    %cl,%dl
f0105720:	74 04                	je     f0105726 <strfind+0x1a>
f0105722:	84 d2                	test   %dl,%dl
f0105724:	75 f2                	jne    f0105718 <strfind+0xc>
			break;
	return (char *) s;
}
f0105726:	5d                   	pop    %ebp
f0105727:	c3                   	ret    

f0105728 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105728:	55                   	push   %ebp
f0105729:	89 e5                	mov    %esp,%ebp
f010572b:	57                   	push   %edi
f010572c:	56                   	push   %esi
f010572d:	53                   	push   %ebx
f010572e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105731:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105734:	85 c9                	test   %ecx,%ecx
f0105736:	74 13                	je     f010574b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105738:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010573e:	75 05                	jne    f0105745 <memset+0x1d>
f0105740:	f6 c1 03             	test   $0x3,%cl
f0105743:	74 0d                	je     f0105752 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105745:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105748:	fc                   	cld    
f0105749:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010574b:	89 f8                	mov    %edi,%eax
f010574d:	5b                   	pop    %ebx
f010574e:	5e                   	pop    %esi
f010574f:	5f                   	pop    %edi
f0105750:	5d                   	pop    %ebp
f0105751:	c3                   	ret    
		c &= 0xFF;
f0105752:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105756:	89 d3                	mov    %edx,%ebx
f0105758:	c1 e3 08             	shl    $0x8,%ebx
f010575b:	89 d0                	mov    %edx,%eax
f010575d:	c1 e0 18             	shl    $0x18,%eax
f0105760:	89 d6                	mov    %edx,%esi
f0105762:	c1 e6 10             	shl    $0x10,%esi
f0105765:	09 f0                	or     %esi,%eax
f0105767:	09 c2                	or     %eax,%edx
f0105769:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010576b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010576e:	89 d0                	mov    %edx,%eax
f0105770:	fc                   	cld    
f0105771:	f3 ab                	rep stos %eax,%es:(%edi)
f0105773:	eb d6                	jmp    f010574b <memset+0x23>

f0105775 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105775:	55                   	push   %ebp
f0105776:	89 e5                	mov    %esp,%ebp
f0105778:	57                   	push   %edi
f0105779:	56                   	push   %esi
f010577a:	8b 45 08             	mov    0x8(%ebp),%eax
f010577d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105780:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105783:	39 c6                	cmp    %eax,%esi
f0105785:	73 35                	jae    f01057bc <memmove+0x47>
f0105787:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010578a:	39 c2                	cmp    %eax,%edx
f010578c:	76 2e                	jbe    f01057bc <memmove+0x47>
		s += n;
		d += n;
f010578e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105791:	89 d6                	mov    %edx,%esi
f0105793:	09 fe                	or     %edi,%esi
f0105795:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010579b:	74 0c                	je     f01057a9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010579d:	83 ef 01             	sub    $0x1,%edi
f01057a0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01057a3:	fd                   	std    
f01057a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01057a6:	fc                   	cld    
f01057a7:	eb 21                	jmp    f01057ca <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057a9:	f6 c1 03             	test   $0x3,%cl
f01057ac:	75 ef                	jne    f010579d <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01057ae:	83 ef 04             	sub    $0x4,%edi
f01057b1:	8d 72 fc             	lea    -0x4(%edx),%esi
f01057b4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01057b7:	fd                   	std    
f01057b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057ba:	eb ea                	jmp    f01057a6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057bc:	89 f2                	mov    %esi,%edx
f01057be:	09 c2                	or     %eax,%edx
f01057c0:	f6 c2 03             	test   $0x3,%dl
f01057c3:	74 09                	je     f01057ce <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01057c5:	89 c7                	mov    %eax,%edi
f01057c7:	fc                   	cld    
f01057c8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01057ca:	5e                   	pop    %esi
f01057cb:	5f                   	pop    %edi
f01057cc:	5d                   	pop    %ebp
f01057cd:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01057ce:	f6 c1 03             	test   $0x3,%cl
f01057d1:	75 f2                	jne    f01057c5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01057d3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01057d6:	89 c7                	mov    %eax,%edi
f01057d8:	fc                   	cld    
f01057d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01057db:	eb ed                	jmp    f01057ca <memmove+0x55>

f01057dd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01057dd:	55                   	push   %ebp
f01057de:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01057e0:	ff 75 10             	pushl  0x10(%ebp)
f01057e3:	ff 75 0c             	pushl  0xc(%ebp)
f01057e6:	ff 75 08             	pushl  0x8(%ebp)
f01057e9:	e8 87 ff ff ff       	call   f0105775 <memmove>
}
f01057ee:	c9                   	leave  
f01057ef:	c3                   	ret    

f01057f0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01057f0:	55                   	push   %ebp
f01057f1:	89 e5                	mov    %esp,%ebp
f01057f3:	56                   	push   %esi
f01057f4:	53                   	push   %ebx
f01057f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01057f8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01057fb:	89 c6                	mov    %eax,%esi
f01057fd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105800:	39 f0                	cmp    %esi,%eax
f0105802:	74 1c                	je     f0105820 <memcmp+0x30>
		if (*s1 != *s2)
f0105804:	0f b6 08             	movzbl (%eax),%ecx
f0105807:	0f b6 1a             	movzbl (%edx),%ebx
f010580a:	38 d9                	cmp    %bl,%cl
f010580c:	75 08                	jne    f0105816 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010580e:	83 c0 01             	add    $0x1,%eax
f0105811:	83 c2 01             	add    $0x1,%edx
f0105814:	eb ea                	jmp    f0105800 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105816:	0f b6 c1             	movzbl %cl,%eax
f0105819:	0f b6 db             	movzbl %bl,%ebx
f010581c:	29 d8                	sub    %ebx,%eax
f010581e:	eb 05                	jmp    f0105825 <memcmp+0x35>
	}

	return 0;
f0105820:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105825:	5b                   	pop    %ebx
f0105826:	5e                   	pop    %esi
f0105827:	5d                   	pop    %ebp
f0105828:	c3                   	ret    

f0105829 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105829:	55                   	push   %ebp
f010582a:	89 e5                	mov    %esp,%ebp
f010582c:	8b 45 08             	mov    0x8(%ebp),%eax
f010582f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105832:	89 c2                	mov    %eax,%edx
f0105834:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105837:	39 d0                	cmp    %edx,%eax
f0105839:	73 09                	jae    f0105844 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010583b:	38 08                	cmp    %cl,(%eax)
f010583d:	74 05                	je     f0105844 <memfind+0x1b>
	for (; s < ends; s++)
f010583f:	83 c0 01             	add    $0x1,%eax
f0105842:	eb f3                	jmp    f0105837 <memfind+0xe>
			break;
	return (void *) s;
}
f0105844:	5d                   	pop    %ebp
f0105845:	c3                   	ret    

f0105846 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105846:	55                   	push   %ebp
f0105847:	89 e5                	mov    %esp,%ebp
f0105849:	57                   	push   %edi
f010584a:	56                   	push   %esi
f010584b:	53                   	push   %ebx
f010584c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010584f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105852:	eb 03                	jmp    f0105857 <strtol+0x11>
		s++;
f0105854:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105857:	0f b6 01             	movzbl (%ecx),%eax
f010585a:	3c 20                	cmp    $0x20,%al
f010585c:	74 f6                	je     f0105854 <strtol+0xe>
f010585e:	3c 09                	cmp    $0x9,%al
f0105860:	74 f2                	je     f0105854 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105862:	3c 2b                	cmp    $0x2b,%al
f0105864:	74 2e                	je     f0105894 <strtol+0x4e>
	int neg = 0;
f0105866:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010586b:	3c 2d                	cmp    $0x2d,%al
f010586d:	74 2f                	je     f010589e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010586f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105875:	75 05                	jne    f010587c <strtol+0x36>
f0105877:	80 39 30             	cmpb   $0x30,(%ecx)
f010587a:	74 2c                	je     f01058a8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010587c:	85 db                	test   %ebx,%ebx
f010587e:	75 0a                	jne    f010588a <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105880:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0105885:	80 39 30             	cmpb   $0x30,(%ecx)
f0105888:	74 28                	je     f01058b2 <strtol+0x6c>
		base = 10;
f010588a:	b8 00 00 00 00       	mov    $0x0,%eax
f010588f:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105892:	eb 50                	jmp    f01058e4 <strtol+0x9e>
		s++;
f0105894:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105897:	bf 00 00 00 00       	mov    $0x0,%edi
f010589c:	eb d1                	jmp    f010586f <strtol+0x29>
		s++, neg = 1;
f010589e:	83 c1 01             	add    $0x1,%ecx
f01058a1:	bf 01 00 00 00       	mov    $0x1,%edi
f01058a6:	eb c7                	jmp    f010586f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01058a8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01058ac:	74 0e                	je     f01058bc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01058ae:	85 db                	test   %ebx,%ebx
f01058b0:	75 d8                	jne    f010588a <strtol+0x44>
		s++, base = 8;
f01058b2:	83 c1 01             	add    $0x1,%ecx
f01058b5:	bb 08 00 00 00       	mov    $0x8,%ebx
f01058ba:	eb ce                	jmp    f010588a <strtol+0x44>
		s += 2, base = 16;
f01058bc:	83 c1 02             	add    $0x2,%ecx
f01058bf:	bb 10 00 00 00       	mov    $0x10,%ebx
f01058c4:	eb c4                	jmp    f010588a <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01058c6:	8d 72 9f             	lea    -0x61(%edx),%esi
f01058c9:	89 f3                	mov    %esi,%ebx
f01058cb:	80 fb 19             	cmp    $0x19,%bl
f01058ce:	77 29                	ja     f01058f9 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01058d0:	0f be d2             	movsbl %dl,%edx
f01058d3:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01058d6:	3b 55 10             	cmp    0x10(%ebp),%edx
f01058d9:	7d 30                	jge    f010590b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01058db:	83 c1 01             	add    $0x1,%ecx
f01058de:	0f af 45 10          	imul   0x10(%ebp),%eax
f01058e2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01058e4:	0f b6 11             	movzbl (%ecx),%edx
f01058e7:	8d 72 d0             	lea    -0x30(%edx),%esi
f01058ea:	89 f3                	mov    %esi,%ebx
f01058ec:	80 fb 09             	cmp    $0x9,%bl
f01058ef:	77 d5                	ja     f01058c6 <strtol+0x80>
			dig = *s - '0';
f01058f1:	0f be d2             	movsbl %dl,%edx
f01058f4:	83 ea 30             	sub    $0x30,%edx
f01058f7:	eb dd                	jmp    f01058d6 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f01058f9:	8d 72 bf             	lea    -0x41(%edx),%esi
f01058fc:	89 f3                	mov    %esi,%ebx
f01058fe:	80 fb 19             	cmp    $0x19,%bl
f0105901:	77 08                	ja     f010590b <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105903:	0f be d2             	movsbl %dl,%edx
f0105906:	83 ea 37             	sub    $0x37,%edx
f0105909:	eb cb                	jmp    f01058d6 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010590b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010590f:	74 05                	je     f0105916 <strtol+0xd0>
		*endptr = (char *) s;
f0105911:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105914:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105916:	89 c2                	mov    %eax,%edx
f0105918:	f7 da                	neg    %edx
f010591a:	85 ff                	test   %edi,%edi
f010591c:	0f 45 c2             	cmovne %edx,%eax
}
f010591f:	5b                   	pop    %ebx
f0105920:	5e                   	pop    %esi
f0105921:	5f                   	pop    %edi
f0105922:	5d                   	pop    %ebp
f0105923:	c3                   	ret    
f0105924:	66 90                	xchg   %ax,%ax
f0105926:	66 90                	xchg   %ax,%ax
f0105928:	66 90                	xchg   %ax,%ax
f010592a:	66 90                	xchg   %ax,%ax
f010592c:	66 90                	xchg   %ax,%ax
f010592e:	66 90                	xchg   %ax,%ax

f0105930 <__udivdi3>:
f0105930:	55                   	push   %ebp
f0105931:	57                   	push   %edi
f0105932:	56                   	push   %esi
f0105933:	53                   	push   %ebx
f0105934:	83 ec 1c             	sub    $0x1c,%esp
f0105937:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010593b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010593f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105943:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0105947:	85 d2                	test   %edx,%edx
f0105949:	75 35                	jne    f0105980 <__udivdi3+0x50>
f010594b:	39 f3                	cmp    %esi,%ebx
f010594d:	0f 87 bd 00 00 00    	ja     f0105a10 <__udivdi3+0xe0>
f0105953:	85 db                	test   %ebx,%ebx
f0105955:	89 d9                	mov    %ebx,%ecx
f0105957:	75 0b                	jne    f0105964 <__udivdi3+0x34>
f0105959:	b8 01 00 00 00       	mov    $0x1,%eax
f010595e:	31 d2                	xor    %edx,%edx
f0105960:	f7 f3                	div    %ebx
f0105962:	89 c1                	mov    %eax,%ecx
f0105964:	31 d2                	xor    %edx,%edx
f0105966:	89 f0                	mov    %esi,%eax
f0105968:	f7 f1                	div    %ecx
f010596a:	89 c6                	mov    %eax,%esi
f010596c:	89 e8                	mov    %ebp,%eax
f010596e:	89 f7                	mov    %esi,%edi
f0105970:	f7 f1                	div    %ecx
f0105972:	89 fa                	mov    %edi,%edx
f0105974:	83 c4 1c             	add    $0x1c,%esp
f0105977:	5b                   	pop    %ebx
f0105978:	5e                   	pop    %esi
f0105979:	5f                   	pop    %edi
f010597a:	5d                   	pop    %ebp
f010597b:	c3                   	ret    
f010597c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105980:	39 f2                	cmp    %esi,%edx
f0105982:	77 7c                	ja     f0105a00 <__udivdi3+0xd0>
f0105984:	0f bd fa             	bsr    %edx,%edi
f0105987:	83 f7 1f             	xor    $0x1f,%edi
f010598a:	0f 84 98 00 00 00    	je     f0105a28 <__udivdi3+0xf8>
f0105990:	89 f9                	mov    %edi,%ecx
f0105992:	b8 20 00 00 00       	mov    $0x20,%eax
f0105997:	29 f8                	sub    %edi,%eax
f0105999:	d3 e2                	shl    %cl,%edx
f010599b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010599f:	89 c1                	mov    %eax,%ecx
f01059a1:	89 da                	mov    %ebx,%edx
f01059a3:	d3 ea                	shr    %cl,%edx
f01059a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01059a9:	09 d1                	or     %edx,%ecx
f01059ab:	89 f2                	mov    %esi,%edx
f01059ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01059b1:	89 f9                	mov    %edi,%ecx
f01059b3:	d3 e3                	shl    %cl,%ebx
f01059b5:	89 c1                	mov    %eax,%ecx
f01059b7:	d3 ea                	shr    %cl,%edx
f01059b9:	89 f9                	mov    %edi,%ecx
f01059bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01059bf:	d3 e6                	shl    %cl,%esi
f01059c1:	89 eb                	mov    %ebp,%ebx
f01059c3:	89 c1                	mov    %eax,%ecx
f01059c5:	d3 eb                	shr    %cl,%ebx
f01059c7:	09 de                	or     %ebx,%esi
f01059c9:	89 f0                	mov    %esi,%eax
f01059cb:	f7 74 24 08          	divl   0x8(%esp)
f01059cf:	89 d6                	mov    %edx,%esi
f01059d1:	89 c3                	mov    %eax,%ebx
f01059d3:	f7 64 24 0c          	mull   0xc(%esp)
f01059d7:	39 d6                	cmp    %edx,%esi
f01059d9:	72 0c                	jb     f01059e7 <__udivdi3+0xb7>
f01059db:	89 f9                	mov    %edi,%ecx
f01059dd:	d3 e5                	shl    %cl,%ebp
f01059df:	39 c5                	cmp    %eax,%ebp
f01059e1:	73 5d                	jae    f0105a40 <__udivdi3+0x110>
f01059e3:	39 d6                	cmp    %edx,%esi
f01059e5:	75 59                	jne    f0105a40 <__udivdi3+0x110>
f01059e7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01059ea:	31 ff                	xor    %edi,%edi
f01059ec:	89 fa                	mov    %edi,%edx
f01059ee:	83 c4 1c             	add    $0x1c,%esp
f01059f1:	5b                   	pop    %ebx
f01059f2:	5e                   	pop    %esi
f01059f3:	5f                   	pop    %edi
f01059f4:	5d                   	pop    %ebp
f01059f5:	c3                   	ret    
f01059f6:	8d 76 00             	lea    0x0(%esi),%esi
f01059f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0105a00:	31 ff                	xor    %edi,%edi
f0105a02:	31 c0                	xor    %eax,%eax
f0105a04:	89 fa                	mov    %edi,%edx
f0105a06:	83 c4 1c             	add    $0x1c,%esp
f0105a09:	5b                   	pop    %ebx
f0105a0a:	5e                   	pop    %esi
f0105a0b:	5f                   	pop    %edi
f0105a0c:	5d                   	pop    %ebp
f0105a0d:	c3                   	ret    
f0105a0e:	66 90                	xchg   %ax,%ax
f0105a10:	31 ff                	xor    %edi,%edi
f0105a12:	89 e8                	mov    %ebp,%eax
f0105a14:	89 f2                	mov    %esi,%edx
f0105a16:	f7 f3                	div    %ebx
f0105a18:	89 fa                	mov    %edi,%edx
f0105a1a:	83 c4 1c             	add    $0x1c,%esp
f0105a1d:	5b                   	pop    %ebx
f0105a1e:	5e                   	pop    %esi
f0105a1f:	5f                   	pop    %edi
f0105a20:	5d                   	pop    %ebp
f0105a21:	c3                   	ret    
f0105a22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105a28:	39 f2                	cmp    %esi,%edx
f0105a2a:	72 06                	jb     f0105a32 <__udivdi3+0x102>
f0105a2c:	31 c0                	xor    %eax,%eax
f0105a2e:	39 eb                	cmp    %ebp,%ebx
f0105a30:	77 d2                	ja     f0105a04 <__udivdi3+0xd4>
f0105a32:	b8 01 00 00 00       	mov    $0x1,%eax
f0105a37:	eb cb                	jmp    f0105a04 <__udivdi3+0xd4>
f0105a39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105a40:	89 d8                	mov    %ebx,%eax
f0105a42:	31 ff                	xor    %edi,%edi
f0105a44:	eb be                	jmp    f0105a04 <__udivdi3+0xd4>
f0105a46:	66 90                	xchg   %ax,%ax
f0105a48:	66 90                	xchg   %ax,%ax
f0105a4a:	66 90                	xchg   %ax,%ax
f0105a4c:	66 90                	xchg   %ax,%ax
f0105a4e:	66 90                	xchg   %ax,%ax

f0105a50 <__umoddi3>:
f0105a50:	55                   	push   %ebp
f0105a51:	57                   	push   %edi
f0105a52:	56                   	push   %esi
f0105a53:	53                   	push   %ebx
f0105a54:	83 ec 1c             	sub    $0x1c,%esp
f0105a57:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0105a5b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0105a5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105a63:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105a67:	85 ed                	test   %ebp,%ebp
f0105a69:	89 f0                	mov    %esi,%eax
f0105a6b:	89 da                	mov    %ebx,%edx
f0105a6d:	75 19                	jne    f0105a88 <__umoddi3+0x38>
f0105a6f:	39 df                	cmp    %ebx,%edi
f0105a71:	0f 86 b1 00 00 00    	jbe    f0105b28 <__umoddi3+0xd8>
f0105a77:	f7 f7                	div    %edi
f0105a79:	89 d0                	mov    %edx,%eax
f0105a7b:	31 d2                	xor    %edx,%edx
f0105a7d:	83 c4 1c             	add    $0x1c,%esp
f0105a80:	5b                   	pop    %ebx
f0105a81:	5e                   	pop    %esi
f0105a82:	5f                   	pop    %edi
f0105a83:	5d                   	pop    %ebp
f0105a84:	c3                   	ret    
f0105a85:	8d 76 00             	lea    0x0(%esi),%esi
f0105a88:	39 dd                	cmp    %ebx,%ebp
f0105a8a:	77 f1                	ja     f0105a7d <__umoddi3+0x2d>
f0105a8c:	0f bd cd             	bsr    %ebp,%ecx
f0105a8f:	83 f1 1f             	xor    $0x1f,%ecx
f0105a92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105a96:	0f 84 b4 00 00 00    	je     f0105b50 <__umoddi3+0x100>
f0105a9c:	b8 20 00 00 00       	mov    $0x20,%eax
f0105aa1:	89 c2                	mov    %eax,%edx
f0105aa3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105aa7:	29 c2                	sub    %eax,%edx
f0105aa9:	89 c1                	mov    %eax,%ecx
f0105aab:	89 f8                	mov    %edi,%eax
f0105aad:	d3 e5                	shl    %cl,%ebp
f0105aaf:	89 d1                	mov    %edx,%ecx
f0105ab1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105ab5:	d3 e8                	shr    %cl,%eax
f0105ab7:	09 c5                	or     %eax,%ebp
f0105ab9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0105abd:	89 c1                	mov    %eax,%ecx
f0105abf:	d3 e7                	shl    %cl,%edi
f0105ac1:	89 d1                	mov    %edx,%ecx
f0105ac3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105ac7:	89 df                	mov    %ebx,%edi
f0105ac9:	d3 ef                	shr    %cl,%edi
f0105acb:	89 c1                	mov    %eax,%ecx
f0105acd:	89 f0                	mov    %esi,%eax
f0105acf:	d3 e3                	shl    %cl,%ebx
f0105ad1:	89 d1                	mov    %edx,%ecx
f0105ad3:	89 fa                	mov    %edi,%edx
f0105ad5:	d3 e8                	shr    %cl,%eax
f0105ad7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0105adc:	09 d8                	or     %ebx,%eax
f0105ade:	f7 f5                	div    %ebp
f0105ae0:	d3 e6                	shl    %cl,%esi
f0105ae2:	89 d1                	mov    %edx,%ecx
f0105ae4:	f7 64 24 08          	mull   0x8(%esp)
f0105ae8:	39 d1                	cmp    %edx,%ecx
f0105aea:	89 c3                	mov    %eax,%ebx
f0105aec:	89 d7                	mov    %edx,%edi
f0105aee:	72 06                	jb     f0105af6 <__umoddi3+0xa6>
f0105af0:	75 0e                	jne    f0105b00 <__umoddi3+0xb0>
f0105af2:	39 c6                	cmp    %eax,%esi
f0105af4:	73 0a                	jae    f0105b00 <__umoddi3+0xb0>
f0105af6:	2b 44 24 08          	sub    0x8(%esp),%eax
f0105afa:	19 ea                	sbb    %ebp,%edx
f0105afc:	89 d7                	mov    %edx,%edi
f0105afe:	89 c3                	mov    %eax,%ebx
f0105b00:	89 ca                	mov    %ecx,%edx
f0105b02:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0105b07:	29 de                	sub    %ebx,%esi
f0105b09:	19 fa                	sbb    %edi,%edx
f0105b0b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0105b0f:	89 d0                	mov    %edx,%eax
f0105b11:	d3 e0                	shl    %cl,%eax
f0105b13:	89 d9                	mov    %ebx,%ecx
f0105b15:	d3 ee                	shr    %cl,%esi
f0105b17:	d3 ea                	shr    %cl,%edx
f0105b19:	09 f0                	or     %esi,%eax
f0105b1b:	83 c4 1c             	add    $0x1c,%esp
f0105b1e:	5b                   	pop    %ebx
f0105b1f:	5e                   	pop    %esi
f0105b20:	5f                   	pop    %edi
f0105b21:	5d                   	pop    %ebp
f0105b22:	c3                   	ret    
f0105b23:	90                   	nop
f0105b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105b28:	85 ff                	test   %edi,%edi
f0105b2a:	89 f9                	mov    %edi,%ecx
f0105b2c:	75 0b                	jne    f0105b39 <__umoddi3+0xe9>
f0105b2e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105b33:	31 d2                	xor    %edx,%edx
f0105b35:	f7 f7                	div    %edi
f0105b37:	89 c1                	mov    %eax,%ecx
f0105b39:	89 d8                	mov    %ebx,%eax
f0105b3b:	31 d2                	xor    %edx,%edx
f0105b3d:	f7 f1                	div    %ecx
f0105b3f:	89 f0                	mov    %esi,%eax
f0105b41:	f7 f1                	div    %ecx
f0105b43:	e9 31 ff ff ff       	jmp    f0105a79 <__umoddi3+0x29>
f0105b48:	90                   	nop
f0105b49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105b50:	39 dd                	cmp    %ebx,%ebp
f0105b52:	72 08                	jb     f0105b5c <__umoddi3+0x10c>
f0105b54:	39 f7                	cmp    %esi,%edi
f0105b56:	0f 87 21 ff ff ff    	ja     f0105a7d <__umoddi3+0x2d>
f0105b5c:	89 da                	mov    %ebx,%edx
f0105b5e:	89 f0                	mov    %esi,%eax
f0105b60:	29 f8                	sub    %edi,%eax
f0105b62:	19 ea                	sbb    %ebp,%edx
f0105b64:	e9 14 ff ff ff       	jmp    f0105a7d <__umoddi3+0x2d>
