
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
f0100015:	b8 00 e0 18 00       	mov    $0x18e000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

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
f010004c:	81 c3 e8 d0 08 00    	add    $0x8d0e8,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c0 20 00 19 f0    	mov    $0xf0190020,%eax
f0100058:	c7 c2 20 f1 18 f0    	mov    $0xf018f120,%edx
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 d7 4d 00 00       	call   f0104e40 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 4e 05 00 00       	call   f01005bc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 4c 81 f7 ff    	lea    -0x87eb4(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 cd 3c 00 00       	call   f0103d4f <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 33 19 00 00       	call   f01019ba <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100087:	e8 f8 37 00 00       	call   f0103884 <env_init>
	trap_init();
f010008c:	e8 71 3d 00 00       	call   f0103e02 <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100091:	83 c4 08             	add    $0x8,%esp
f0100094:	6a 00                	push   $0x0
f0100096:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f010009c:	e8 83 39 00 00       	call   f0103a24 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a1:	83 c4 04             	add    $0x4,%esp
f01000a4:	c7 c0 64 f3 18 f0    	mov    $0xf018f364,%eax
f01000aa:	ff 30                	pushl  (%eax)
f01000ac:	e8 ed 3b 00 00       	call   f0103c9e <env_run>

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
f01000bf:	81 c3 75 d0 08 00    	add    $0x8d075,%ebx
f01000c5:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000c8:	c7 c0 24 00 19 f0    	mov    $0xf0190024,%eax
f01000ce:	83 38 00             	cmpl   $0x0,(%eax)
f01000d1:	74 0f                	je     f01000e2 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 50 0e 00 00       	call   f0100f2d <monitor>
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
f01000f2:	8d 83 67 81 f7 ff    	lea    -0x87e99(%ebx),%eax
f01000f8:	50                   	push   %eax
f01000f9:	e8 51 3c 00 00       	call   f0103d4f <cprintf>
	vcprintf(fmt, ap);
f01000fe:	83 c4 08             	add    $0x8,%esp
f0100101:	56                   	push   %esi
f0100102:	57                   	push   %edi
f0100103:	e8 10 3c 00 00       	call   f0103d18 <vcprintf>
	cprintf("\n");
f0100108:	8d 83 8e 93 f7 ff    	lea    -0x86c72(%ebx),%eax
f010010e:	89 04 24             	mov    %eax,(%esp)
f0100111:	e8 39 3c 00 00       	call   f0103d4f <cprintf>
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
f0100125:	81 c3 0f d0 08 00    	add    $0x8d00f,%ebx
	va_list ap;

	va_start(ap, fmt);
f010012b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f010012e:	83 ec 04             	sub    $0x4,%esp
f0100131:	ff 75 0c             	pushl  0xc(%ebp)
f0100134:	ff 75 08             	pushl  0x8(%ebp)
f0100137:	8d 83 7f 81 f7 ff    	lea    -0x87e81(%ebx),%eax
f010013d:	50                   	push   %eax
f010013e:	e8 0c 3c 00 00       	call   f0103d4f <cprintf>
	vcprintf(fmt, ap);
f0100143:	83 c4 08             	add    $0x8,%esp
f0100146:	56                   	push   %esi
f0100147:	ff 75 10             	pushl  0x10(%ebp)
f010014a:	e8 c9 3b 00 00       	call   f0103d18 <vcprintf>
	cprintf("\n");
f010014f:	8d 83 8e 93 f7 ff    	lea    -0x86c72(%ebx),%eax
f0100155:	89 04 24             	mov    %eax,(%esp)
f0100158:	e8 f2 3b 00 00       	call   f0103d4f <cprintf>
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
f0100194:	81 c3 a0 cf 08 00    	add    $0x8cfa0,%ebx
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
f01001a7:	8b 8b 10 22 00 00    	mov    0x2210(%ebx),%ecx
f01001ad:	8d 51 01             	lea    0x1(%ecx),%edx
f01001b0:	89 93 10 22 00 00    	mov    %edx,0x2210(%ebx)
f01001b6:	88 84 0b 0c 20 00 00 	mov    %al,0x200c(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001bd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c3:	75 d7                	jne    f010019c <cons_intr+0x12>
			cons.wpos = 0;
f01001c5:	c7 83 10 22 00 00 00 	movl   $0x0,0x2210(%ebx)
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
f01001df:	81 c3 55 cf 08 00    	add    $0x8cf55,%ebx
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
f0100213:	8b 8b ec 1f 00 00    	mov    0x1fec(%ebx),%ecx
f0100219:	f6 c1 40             	test   $0x40,%cl
f010021c:	74 0e                	je     f010022c <kbd_proc_data+0x57>
		data |= 0x80;
f010021e:	83 c8 80             	or     $0xffffff80,%eax
f0100221:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100223:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100226:	89 8b ec 1f 00 00    	mov    %ecx,0x1fec(%ebx)
	shift |= shiftcode[data];
f010022c:	0f b6 d2             	movzbl %dl,%edx
f010022f:	0f b6 84 13 cc 82 f7 	movzbl -0x87d34(%ebx,%edx,1),%eax
f0100236:	ff 
f0100237:	0b 83 ec 1f 00 00    	or     0x1fec(%ebx),%eax
	shift ^= togglecode[data];
f010023d:	0f b6 8c 13 cc 81 f7 	movzbl -0x87e34(%ebx,%edx,1),%ecx
f0100244:	ff 
f0100245:	31 c8                	xor    %ecx,%eax
f0100247:	89 83 ec 1f 00 00    	mov    %eax,0x1fec(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f010024d:	89 c1                	mov    %eax,%ecx
f010024f:	83 e1 03             	and    $0x3,%ecx
f0100252:	8b 8c 8b ec 1e 00 00 	mov    0x1eec(%ebx,%ecx,4),%ecx
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
f0100282:	8d 83 99 81 f7 ff    	lea    -0x87e67(%ebx),%eax
f0100288:	50                   	push   %eax
f0100289:	e8 c1 3a 00 00       	call   f0103d4f <cprintf>
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
f010029e:	83 8b ec 1f 00 00 40 	orl    $0x40,0x1fec(%ebx)
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
f01002b3:	8b 8b ec 1f 00 00    	mov    0x1fec(%ebx),%ecx
f01002b9:	89 ce                	mov    %ecx,%esi
f01002bb:	83 e6 40             	and    $0x40,%esi
f01002be:	83 e0 7f             	and    $0x7f,%eax
f01002c1:	85 f6                	test   %esi,%esi
f01002c3:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002c6:	0f b6 d2             	movzbl %dl,%edx
f01002c9:	0f b6 84 13 cc 82 f7 	movzbl -0x87d34(%ebx,%edx,1),%eax
f01002d0:	ff 
f01002d1:	83 c8 40             	or     $0x40,%eax
f01002d4:	0f b6 c0             	movzbl %al,%eax
f01002d7:	f7 d0                	not    %eax
f01002d9:	21 c8                	and    %ecx,%eax
f01002db:	89 83 ec 1f 00 00    	mov    %eax,0x1fec(%ebx)
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
f0100315:	81 c3 1f ce 08 00    	add    $0x8ce1f,%ebx
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
f01003d4:	0f b7 83 14 22 00 00 	movzwl 0x2214(%ebx),%eax
f01003db:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e1:	c1 e8 16             	shr    $0x16,%eax
f01003e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e7:	c1 e0 04             	shl    $0x4,%eax
f01003ea:	66 89 83 14 22 00 00 	mov    %ax,0x2214(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01003f1:	66 81 bb 14 22 00 00 	cmpw   $0x7cf,0x2214(%ebx)
f01003f8:	cf 07 
f01003fa:	0f 87 d4 00 00 00    	ja     f01004d4 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100400:	8b 8b 1c 22 00 00    	mov    0x221c(%ebx),%ecx
f0100406:	b8 0e 00 00 00       	mov    $0xe,%eax
f010040b:	89 ca                	mov    %ecx,%edx
f010040d:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010040e:	0f b7 9b 14 22 00 00 	movzwl 0x2214(%ebx),%ebx
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
f010043b:	0f b7 83 14 22 00 00 	movzwl 0x2214(%ebx),%eax
f0100442:	66 85 c0             	test   %ax,%ax
f0100445:	74 b9                	je     f0100400 <cons_putc+0xf9>
			crt_pos--;
f0100447:	83 e8 01             	sub    $0x1,%eax
f010044a:	66 89 83 14 22 00 00 	mov    %ax,0x2214(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100451:	0f b7 c0             	movzwl %ax,%eax
f0100454:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100458:	b2 00                	mov    $0x0,%dl
f010045a:	83 ca 20             	or     $0x20,%edx
f010045d:	8b 8b 18 22 00 00    	mov    0x2218(%ebx),%ecx
f0100463:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100467:	eb 88                	jmp    f01003f1 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f0100469:	66 83 83 14 22 00 00 	addw   $0x50,0x2214(%ebx)
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
f01004ad:	0f b7 83 14 22 00 00 	movzwl 0x2214(%ebx),%eax
f01004b4:	8d 50 01             	lea    0x1(%eax),%edx
f01004b7:	66 89 93 14 22 00 00 	mov    %dx,0x2214(%ebx)
f01004be:	0f b7 c0             	movzwl %ax,%eax
f01004c1:	8b 93 18 22 00 00    	mov    0x2218(%ebx),%edx
f01004c7:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004cf:	e9 1d ff ff ff       	jmp    f01003f1 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004d4:	8b 83 18 22 00 00    	mov    0x2218(%ebx),%eax
f01004da:	83 ec 04             	sub    $0x4,%esp
f01004dd:	68 00 0f 00 00       	push   $0xf00
f01004e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004e8:	52                   	push   %edx
f01004e9:	50                   	push   %eax
f01004ea:	e8 9e 49 00 00       	call   f0104e8d <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004ef:	8b 93 18 22 00 00    	mov    0x2218(%ebx),%edx
f01004f5:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004fb:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100501:	83 c4 10             	add    $0x10,%esp
f0100504:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100509:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010050c:	39 d0                	cmp    %edx,%eax
f010050e:	75 f4                	jne    f0100504 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100510:	66 83 ab 14 22 00 00 	subw   $0x50,0x2214(%ebx)
f0100517:	50 
f0100518:	e9 e3 fe ff ff       	jmp    f0100400 <cons_putc+0xf9>

f010051d <serial_intr>:
{
f010051d:	e8 e7 01 00 00       	call   f0100709 <__x86.get_pc_thunk.ax>
f0100522:	05 12 cc 08 00       	add    $0x8cc12,%eax
	if (serial_exists)
f0100527:	80 b8 20 22 00 00 00 	cmpb   $0x0,0x2220(%eax)
f010052e:	75 02                	jne    f0100532 <serial_intr+0x15>
f0100530:	f3 c3                	repz ret 
{
f0100532:	55                   	push   %ebp
f0100533:	89 e5                	mov    %esp,%ebp
f0100535:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100538:	8d 80 37 30 f7 ff    	lea    -0x8cfc9(%eax),%eax
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
f0100550:	05 e4 cb 08 00       	add    $0x8cbe4,%eax
	cons_intr(kbd_proc_data);
f0100555:	8d 80 a1 30 f7 ff    	lea    -0x8cf5f(%eax),%eax
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
f010056e:	81 c3 c6 cb 08 00    	add    $0x8cbc6,%ebx
	serial_intr();
f0100574:	e8 a4 ff ff ff       	call   f010051d <serial_intr>
	kbd_intr();
f0100579:	e8 c7 ff ff ff       	call   f0100545 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010057e:	8b 93 0c 22 00 00    	mov    0x220c(%ebx),%edx
	return 0;
f0100584:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100589:	3b 93 10 22 00 00    	cmp    0x2210(%ebx),%edx
f010058f:	74 19                	je     f01005aa <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f0100591:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100594:	89 8b 0c 22 00 00    	mov    %ecx,0x220c(%ebx)
f010059a:	0f b6 84 13 0c 20 00 	movzbl 0x200c(%ebx,%edx,1),%eax
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
f01005b0:	c7 83 0c 22 00 00 00 	movl   $0x0,0x220c(%ebx)
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
f01005ca:	81 c3 6a cb 08 00    	add    $0x8cb6a,%ebx
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
f01005f1:	c7 83 1c 22 00 00 b4 	movl   $0x3b4,0x221c(%ebx)
f01005f8:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005fb:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100602:	8b bb 1c 22 00 00    	mov    0x221c(%ebx),%edi
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
f010062a:	89 bb 18 22 00 00    	mov    %edi,0x2218(%ebx)
	pos |= inb(addr_6845 + 1);
f0100630:	0f b6 c0             	movzbl %al,%eax
f0100633:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100635:	66 89 b3 14 22 00 00 	mov    %si,0x2214(%ebx)
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
f010068d:	0f 95 83 20 22 00 00 	setne  0x2220(%ebx)
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
f01006b4:	c7 83 1c 22 00 00 d4 	movl   $0x3d4,0x221c(%ebx)
f01006bb:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006be:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006c5:	e9 38 ff ff ff       	jmp    f0100602 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006ca:	83 ec 0c             	sub    $0xc,%esp
f01006cd:	8d 83 a5 81 f7 ff    	lea    -0x87e5b(%ebx),%eax
f01006d3:	50                   	push   %eax
f01006d4:	e8 76 36 00 00       	call   f0103d4f <cprintf>
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
f010071b:	81 c3 19 ca 08 00    	add    $0x8ca19,%ebx
f0100721:	8d b3 0c 1f 00 00    	lea    0x1f0c(%ebx),%esi
f0100727:	8d 83 60 1f 00 00    	lea    0x1f60(%ebx),%eax
f010072d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100730:	8d bb cc 83 f7 ff    	lea    -0x87c34(%ebx),%edi
f0100736:	83 ec 04             	sub    $0x4,%esp
f0100739:	ff 76 04             	pushl  0x4(%esi)
f010073c:	ff 36                	pushl  (%esi)
f010073e:	57                   	push   %edi
f010073f:	e8 0b 36 00 00       	call   f0103d4f <cprintf>
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
f010076a:	81 c3 ca c9 08 00    	add    $0x8c9ca,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100770:	8d 83 d5 83 f7 ff    	lea    -0x87c2b(%ebx),%eax
f0100776:	50                   	push   %eax
f0100777:	e8 d3 35 00 00       	call   f0103d4f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010077c:	83 c4 08             	add    $0x8,%esp
f010077f:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100785:	8d 83 bc 85 f7 ff    	lea    -0x87a44(%ebx),%eax
f010078b:	50                   	push   %eax
f010078c:	e8 be 35 00 00       	call   f0103d4f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100791:	83 c4 0c             	add    $0xc,%esp
f0100794:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010079a:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007a0:	50                   	push   %eax
f01007a1:	57                   	push   %edi
f01007a2:	8d 83 e4 85 f7 ff    	lea    -0x87a1c(%ebx),%eax
f01007a8:	50                   	push   %eax
f01007a9:	e8 a1 35 00 00       	call   f0103d4f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007ae:	83 c4 0c             	add    $0xc,%esp
f01007b1:	c7 c0 79 52 10 f0    	mov    $0xf0105279,%eax
f01007b7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007bd:	52                   	push   %edx
f01007be:	50                   	push   %eax
f01007bf:	8d 83 08 86 f7 ff    	lea    -0x879f8(%ebx),%eax
f01007c5:	50                   	push   %eax
f01007c6:	e8 84 35 00 00       	call   f0103d4f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007cb:	83 c4 0c             	add    $0xc,%esp
f01007ce:	c7 c0 20 f1 18 f0    	mov    $0xf018f120,%eax
f01007d4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007da:	52                   	push   %edx
f01007db:	50                   	push   %eax
f01007dc:	8d 83 2c 86 f7 ff    	lea    -0x879d4(%ebx),%eax
f01007e2:	50                   	push   %eax
f01007e3:	e8 67 35 00 00       	call   f0103d4f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007e8:	83 c4 0c             	add    $0xc,%esp
f01007eb:	c7 c6 20 00 19 f0    	mov    $0xf0190020,%esi
f01007f1:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007f7:	50                   	push   %eax
f01007f8:	56                   	push   %esi
f01007f9:	8d 83 50 86 f7 ff    	lea    -0x879b0(%ebx),%eax
f01007ff:	50                   	push   %eax
f0100800:	e8 4a 35 00 00       	call   f0103d4f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100805:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100808:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f010080e:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100810:	c1 fe 0a             	sar    $0xa,%esi
f0100813:	56                   	push   %esi
f0100814:	8d 83 74 86 f7 ff    	lea    -0x8798c(%ebx),%eax
f010081a:	50                   	push   %eax
f010081b:	e8 2f 35 00 00       	call   f0103d4f <cprintf>
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
f0100830:	53                   	push   %ebx
f0100831:	83 ec 10             	sub    $0x10,%esp
f0100834:	e8 2e f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100839:	81 c3 fb c8 08 00    	add    $0x8c8fb,%ebx
	// Your code here.
	cprintf("Stack backtrace:\n");
f010083f:	8d 83 ee 83 f7 ff    	lea    -0x87c12(%ebx),%eax
f0100845:	50                   	push   %eax
f0100846:	e8 04 35 00 00       	call   f0103d4f <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010084b:	89 e8                	mov    %ebp,%eax
		fn_name[i] = '\0';
		cprintf("%s:%d: %s+%d\n", info.eip_file, info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (struct Trapframe*)((uint32_t*)ebp + 8);
	}
	return 0;
}
f010084d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100855:	c9                   	leave  
f0100856:	c3                   	ret    

f0100857 <mon_mAddr>:
{
	*(uint32_t *)va = info;
	return;
}
int mon_mAddr(int argc, char **argv, struct Trapframe *tf)
{
f0100857:	55                   	push   %ebp
f0100858:	89 e5                	mov    %esp,%ebp
f010085a:	57                   	push   %edi
f010085b:	56                   	push   %esi
f010085c:	53                   	push   %ebx
f010085d:	83 ec 0c             	sub    $0xc,%esp
f0100860:	e8 02 f9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100865:	81 c3 cf c8 08 00    	add    $0x8c8cf,%ebx
f010086b:	8b 75 0c             	mov    0xc(%ebp),%esi
	assert(argc == 3);
f010086e:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100872:	75 2f                	jne    f01008a3 <mon_mAddr+0x4c>
	uintptr_t va;
	uint32_t info;
	va = strtol(argv[1], NULL, 16);
f0100874:	83 ec 04             	sub    $0x4,%esp
f0100877:	6a 10                	push   $0x10
f0100879:	6a 00                	push   $0x0
f010087b:	ff 76 04             	pushl  0x4(%esi)
f010087e:	e8 db 46 00 00       	call   f0104f5e <strtol>
f0100883:	89 c7                	mov    %eax,%edi
	info = strtol(argv[2], NULL, 16);
f0100885:	83 c4 0c             	add    $0xc,%esp
f0100888:	6a 10                	push   $0x10
f010088a:	6a 00                	push   $0x0
f010088c:	ff 76 08             	pushl  0x8(%esi)
f010088f:	e8 ca 46 00 00       	call   f0104f5e <strtol>
	*(uint32_t *)va = info;
f0100894:	89 07                	mov    %eax,(%edi)
	mAddr(va, info);
	return 0;
}
f0100896:	b8 00 00 00 00       	mov    $0x0,%eax
f010089b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010089e:	5b                   	pop    %ebx
f010089f:	5e                   	pop    %esi
f01008a0:	5f                   	pop    %edi
f01008a1:	5d                   	pop    %ebp
f01008a2:	c3                   	ret    
	assert(argc == 3);
f01008a3:	8d 83 00 84 f7 ff    	lea    -0x87c00(%ebx),%eax
f01008a9:	50                   	push   %eax
f01008aa:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01008b0:	50                   	push   %eax
f01008b1:	68 11 01 00 00       	push   $0x111
f01008b6:	8d 83 1f 84 f7 ff    	lea    -0x87be1(%ebx),%eax
f01008bc:	50                   	push   %eax
f01008bd:	e8 ef f7 ff ff       	call   f01000b1 <_panic>

f01008c2 <showmappings>:
{
f01008c2:	55                   	push   %ebp
f01008c3:	89 e5                	mov    %esp,%ebp
f01008c5:	57                   	push   %edi
f01008c6:	56                   	push   %esi
f01008c7:	53                   	push   %ebx
f01008c8:	83 ec 30             	sub    $0x30,%esp
f01008cb:	e8 97 f8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01008d0:	81 c3 64 c8 08 00    	add    $0x8c864,%ebx
f01008d6:	8b 7d 08             	mov    0x8(%ebp),%edi
	cprintf("Following are address mapping from 0x%x to 0x%x:\n", start, end);
f01008d9:	ff 75 0c             	pushl  0xc(%ebp)
f01008dc:	57                   	push   %edi
f01008dd:	8d 83 a0 86 f7 ff    	lea    -0x87960(%ebx),%eax
f01008e3:	50                   	push   %eax
f01008e4:	e8 66 34 00 00       	call   f0103d4f <cprintf>
	pte_t *pte = NULL;
f01008e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f01008f0:	83 c4 10             	add    $0x10,%esp
		page = page_lookup(kern_pgdir, (void *)current_page_address, &pte);
f01008f3:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01008f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01008fc:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0100902:	89 45 d0             	mov    %eax,-0x30(%ebp)
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f0100905:	eb 19                	jmp    f0100920 <showmappings+0x5e>
			cprintf("  The virtual address 0x%x have no physical page\n", current_page_address);
f0100907:	83 ec 08             	sub    $0x8,%esp
f010090a:	57                   	push   %edi
f010090b:	8d 83 d4 86 f7 ff    	lea    -0x8792c(%ebx),%eax
f0100911:	50                   	push   %eax
f0100912:	e8 38 34 00 00       	call   f0103d4f <cprintf>
			continue;
f0100917:	83 c4 10             	add    $0x10,%esp
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
f010091a:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0100920:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100923:	0f 87 bb 00 00 00    	ja     f01009e4 <showmappings+0x122>
		page = page_lookup(kern_pgdir, (void *)current_page_address, &pte);
f0100929:	83 ec 04             	sub    $0x4,%esp
f010092c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010092f:	50                   	push   %eax
f0100930:	57                   	push   %edi
f0100931:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100934:	ff 30                	pushl  (%eax)
f0100936:	e8 58 0f 00 00       	call   f0101893 <page_lookup>
f010093b:	89 c6                	mov    %eax,%esi
		if (!page)
f010093d:	83 c4 10             	add    $0x10,%esp
f0100940:	85 c0                	test   %eax,%eax
f0100942:	74 c3                	je     f0100907 <showmappings+0x45>
		cprintf("  The virtual address is 0x%x\n", current_page_address);
f0100944:	83 ec 08             	sub    $0x8,%esp
f0100947:	57                   	push   %edi
f0100948:	8d 83 08 87 f7 ff    	lea    -0x878f8(%ebx),%eax
f010094e:	50                   	push   %eax
f010094f:	e8 fb 33 00 00       	call   f0103d4f <cprintf>
		cprintf("    The mapping physical page address is 0x%08x\n", page2pa(page));
f0100954:	83 c4 08             	add    $0x8,%esp
f0100957:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010095a:	2b 30                	sub    (%eax),%esi
f010095c:	c1 fe 03             	sar    $0x3,%esi
f010095f:	c1 e6 0c             	shl    $0xc,%esi
f0100962:	56                   	push   %esi
f0100963:	8d 83 28 87 f7 ff    	lea    -0x878d8(%ebx),%eax
f0100969:	50                   	push   %eax
f010096a:	e8 e0 33 00 00       	call   f0103d4f <cprintf>
		cprintf("    The permissions bits:\n");
f010096f:	8d 83 2e 84 f7 ff    	lea    -0x87bd2(%ebx),%eax
f0100975:	89 04 24             	mov    %eax,(%esp)
f0100978:	e8 d2 33 00 00       	call   f0103d4f <cprintf>
				!!(*pte & PTE_G));
f010097d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100980:	8b 00                	mov    (%eax),%eax
		cprintf("      PTE_P: %d PTE_W: %d PTE_U: %d PTE_PWT: %d PTE_PCD: %d PTE_A: %d PTE_D: %d PTE_PS: %d PTE_G: %d\n\n",
f0100982:	83 c4 08             	add    $0x8,%esp
f0100985:	89 c2                	mov    %eax,%edx
f0100987:	c1 ea 08             	shr    $0x8,%edx
f010098a:	83 e2 01             	and    $0x1,%edx
f010098d:	52                   	push   %edx
f010098e:	89 c2                	mov    %eax,%edx
f0100990:	c1 ea 07             	shr    $0x7,%edx
f0100993:	83 e2 01             	and    $0x1,%edx
f0100996:	52                   	push   %edx
f0100997:	89 c2                	mov    %eax,%edx
f0100999:	c1 ea 06             	shr    $0x6,%edx
f010099c:	83 e2 01             	and    $0x1,%edx
f010099f:	52                   	push   %edx
f01009a0:	89 c2                	mov    %eax,%edx
f01009a2:	c1 ea 05             	shr    $0x5,%edx
f01009a5:	83 e2 01             	and    $0x1,%edx
f01009a8:	52                   	push   %edx
f01009a9:	89 c2                	mov    %eax,%edx
f01009ab:	c1 ea 04             	shr    $0x4,%edx
f01009ae:	83 e2 01             	and    $0x1,%edx
f01009b1:	52                   	push   %edx
f01009b2:	89 c2                	mov    %eax,%edx
f01009b4:	c1 ea 03             	shr    $0x3,%edx
f01009b7:	83 e2 01             	and    $0x1,%edx
f01009ba:	52                   	push   %edx
f01009bb:	89 c2                	mov    %eax,%edx
f01009bd:	c1 ea 02             	shr    $0x2,%edx
f01009c0:	83 e2 01             	and    $0x1,%edx
f01009c3:	52                   	push   %edx
f01009c4:	89 c2                	mov    %eax,%edx
f01009c6:	d1 ea                	shr    %edx
f01009c8:	83 e2 01             	and    $0x1,%edx
f01009cb:	52                   	push   %edx
f01009cc:	83 e0 01             	and    $0x1,%eax
f01009cf:	50                   	push   %eax
f01009d0:	8d 83 5c 87 f7 ff    	lea    -0x878a4(%ebx),%eax
f01009d6:	50                   	push   %eax
f01009d7:	e8 73 33 00 00       	call   f0103d4f <cprintf>
f01009dc:	83 c4 30             	add    $0x30,%esp
f01009df:	e9 36 ff ff ff       	jmp    f010091a <showmappings+0x58>
}
f01009e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009e7:	5b                   	pop    %ebx
f01009e8:	5e                   	pop    %esi
f01009e9:	5f                   	pop    %edi
f01009ea:	5d                   	pop    %ebp
f01009eb:	c3                   	ret    

f01009ec <mon_showmappings>:
{
f01009ec:	55                   	push   %ebp
f01009ed:	89 e5                	mov    %esp,%ebp
f01009ef:	57                   	push   %edi
f01009f0:	56                   	push   %esi
f01009f1:	53                   	push   %ebx
f01009f2:	83 ec 0c             	sub    $0xc,%esp
f01009f5:	e8 6d f7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01009fa:	81 c3 3a c7 08 00    	add    $0x8c73a,%ebx
f0100a00:	8b 75 0c             	mov    0xc(%ebp),%esi
	assert(argc == 3);
f0100a03:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100a07:	75 3e                	jne    f0100a47 <mon_showmappings+0x5b>
	uintptr_t start = strtol(argv[1], NULL, 16), end = strtol(argv[2], NULL, 16);
f0100a09:	83 ec 04             	sub    $0x4,%esp
f0100a0c:	6a 10                	push   $0x10
f0100a0e:	6a 00                	push   $0x0
f0100a10:	ff 76 04             	pushl  0x4(%esi)
f0100a13:	e8 46 45 00 00       	call   f0104f5e <strtol>
f0100a18:	89 c7                	mov    %eax,%edi
f0100a1a:	83 c4 0c             	add    $0xc,%esp
f0100a1d:	6a 10                	push   $0x10
f0100a1f:	6a 00                	push   $0x0
f0100a21:	ff 76 08             	pushl  0x8(%esi)
f0100a24:	e8 35 45 00 00       	call   f0104f5e <strtol>
	assert(start <= end);
f0100a29:	83 c4 10             	add    $0x10,%esp
f0100a2c:	39 c7                	cmp    %eax,%edi
f0100a2e:	77 36                	ja     f0100a66 <mon_showmappings+0x7a>
	showmappings(start, end);
f0100a30:	83 ec 08             	sub    $0x8,%esp
f0100a33:	50                   	push   %eax
f0100a34:	57                   	push   %edi
f0100a35:	e8 88 fe ff ff       	call   f01008c2 <showmappings>
}
f0100a3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a42:	5b                   	pop    %ebx
f0100a43:	5e                   	pop    %esi
f0100a44:	5f                   	pop    %edi
f0100a45:	5d                   	pop    %ebp
f0100a46:	c3                   	ret    
	assert(argc == 3);
f0100a47:	8d 83 00 84 f7 ff    	lea    -0x87c00(%ebx),%eax
f0100a4d:	50                   	push   %eax
f0100a4e:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0100a54:	50                   	push   %eax
f0100a55:	68 84 00 00 00       	push   $0x84
f0100a5a:	8d 83 1f 84 f7 ff    	lea    -0x87be1(%ebx),%eax
f0100a60:	50                   	push   %eax
f0100a61:	e8 4b f6 ff ff       	call   f01000b1 <_panic>
	assert(start <= end);
f0100a66:	8d 83 49 84 f7 ff    	lea    -0x87bb7(%ebx),%eax
f0100a6c:	50                   	push   %eax
f0100a6d:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0100a73:	50                   	push   %eax
f0100a74:	68 86 00 00 00       	push   $0x86
f0100a79:	8d 83 1f 84 f7 ff    	lea    -0x87be1(%ebx),%eax
f0100a7f:	50                   	push   %eax
f0100a80:	e8 2c f6 ff ff       	call   f01000b1 <_panic>

f0100a85 <mPerm>:
{
f0100a85:	55                   	push   %ebp
f0100a86:	89 e5                	mov    %esp,%ebp
f0100a88:	57                   	push   %edi
f0100a89:	56                   	push   %esi
f0100a8a:	53                   	push   %ebx
f0100a8b:	83 ec 10             	sub    $0x10,%esp
f0100a8e:	e8 d4 f6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100a93:	81 c3 a1 c6 08 00    	add    $0x8c6a1,%ebx
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)va, 1);
f0100a99:	6a 01                	push   $0x1
f0100a9b:	ff 75 0c             	pushl  0xc(%ebp)
f0100a9e:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0100aa4:	ff 30                	pushl  (%eax)
f0100aa6:	e8 ee 0c 00 00       	call   f0101799 <pgdir_walk>
f0100aab:	89 c7                	mov    %eax,%edi
	if (new_perm == 1)
f0100aad:	83 c4 08             	add    $0x8,%esp
f0100ab0:	83 7d 14 01          	cmpl   $0x1,0x14(%ebp)
f0100ab4:	0f 95 c0             	setne  %al
f0100ab7:	0f b6 c0             	movzbl %al,%eax
f0100aba:	f7 d8                	neg    %eax
f0100abc:	89 c6                	mov    %eax,%esi
	if (strcmp(perm, "PTE_P") == 0)
f0100abe:	8d 83 9b 93 f7 ff    	lea    -0x86c65(%ebx),%eax
f0100ac4:	50                   	push   %eax
f0100ac5:	ff 75 10             	pushl  0x10(%ebp)
f0100ac8:	e8 d8 42 00 00       	call   f0104da5 <strcmp>
f0100acd:	83 c4 10             	add    $0x10,%esp
f0100ad0:	85 c0                	test   %eax,%eax
f0100ad2:	75 17                	jne    f0100aeb <mPerm+0x66>
		tmp = tmp ^ PTE_P;
f0100ad4:	83 f6 01             	xor    $0x1,%esi
	if (new_perm == 1)
f0100ad7:	83 7d 14 01          	cmpl   $0x1,0x14(%ebp)
f0100adb:	0f 84 13 01 00 00    	je     f0100bf4 <mPerm+0x16f>
		*pte &= tmp;
f0100ae1:	21 37                	and    %esi,(%edi)
}
f0100ae3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ae6:	5b                   	pop    %ebx
f0100ae7:	5e                   	pop    %esi
f0100ae8:	5f                   	pop    %edi
f0100ae9:	5d                   	pop    %ebp
f0100aea:	c3                   	ret    
	else if (strcmp(perm, "PTE_W") == 0)
f0100aeb:	83 ec 08             	sub    $0x8,%esp
f0100aee:	8d 83 ac 93 f7 ff    	lea    -0x86c54(%ebx),%eax
f0100af4:	50                   	push   %eax
f0100af5:	ff 75 10             	pushl  0x10(%ebp)
f0100af8:	e8 a8 42 00 00       	call   f0104da5 <strcmp>
f0100afd:	83 c4 10             	add    $0x10,%esp
f0100b00:	85 c0                	test   %eax,%eax
f0100b02:	75 05                	jne    f0100b09 <mPerm+0x84>
		tmp = tmp ^ PTE_W;
f0100b04:	83 f6 02             	xor    $0x2,%esi
f0100b07:	eb ce                	jmp    f0100ad7 <mPerm+0x52>
	else if (strcmp(perm, "PTE_U") == 0)
f0100b09:	83 ec 08             	sub    $0x8,%esp
f0100b0c:	8d 83 ee 92 f7 ff    	lea    -0x86d12(%ebx),%eax
f0100b12:	50                   	push   %eax
f0100b13:	ff 75 10             	pushl  0x10(%ebp)
f0100b16:	e8 8a 42 00 00       	call   f0104da5 <strcmp>
f0100b1b:	83 c4 10             	add    $0x10,%esp
f0100b1e:	85 c0                	test   %eax,%eax
f0100b20:	75 05                	jne    f0100b27 <mPerm+0xa2>
		tmp = tmp ^ PTE_U;
f0100b22:	83 f6 04             	xor    $0x4,%esi
f0100b25:	eb b0                	jmp    f0100ad7 <mPerm+0x52>
	else if (strcmp(perm, "PTE_PWT") == 0)
f0100b27:	83 ec 08             	sub    $0x8,%esp
f0100b2a:	8d 83 56 84 f7 ff    	lea    -0x87baa(%ebx),%eax
f0100b30:	50                   	push   %eax
f0100b31:	ff 75 10             	pushl  0x10(%ebp)
f0100b34:	e8 6c 42 00 00       	call   f0104da5 <strcmp>
f0100b39:	83 c4 10             	add    $0x10,%esp
f0100b3c:	85 c0                	test   %eax,%eax
f0100b3e:	75 05                	jne    f0100b45 <mPerm+0xc0>
		tmp = tmp ^ PTE_PWT;
f0100b40:	83 f6 08             	xor    $0x8,%esi
f0100b43:	eb 92                	jmp    f0100ad7 <mPerm+0x52>
	else if (strcmp(perm, "PTE_PCD") == 0)
f0100b45:	83 ec 08             	sub    $0x8,%esp
f0100b48:	8d 83 5e 84 f7 ff    	lea    -0x87ba2(%ebx),%eax
f0100b4e:	50                   	push   %eax
f0100b4f:	ff 75 10             	pushl  0x10(%ebp)
f0100b52:	e8 4e 42 00 00       	call   f0104da5 <strcmp>
f0100b57:	83 c4 10             	add    $0x10,%esp
f0100b5a:	85 c0                	test   %eax,%eax
f0100b5c:	75 08                	jne    f0100b66 <mPerm+0xe1>
		tmp = tmp ^ PTE_PCD;
f0100b5e:	83 f6 10             	xor    $0x10,%esi
f0100b61:	e9 71 ff ff ff       	jmp    f0100ad7 <mPerm+0x52>
	else if (strcmp(perm, "PTE_A") == 0)
f0100b66:	83 ec 08             	sub    $0x8,%esp
f0100b69:	8d 83 66 84 f7 ff    	lea    -0x87b9a(%ebx),%eax
f0100b6f:	50                   	push   %eax
f0100b70:	ff 75 10             	pushl  0x10(%ebp)
f0100b73:	e8 2d 42 00 00       	call   f0104da5 <strcmp>
f0100b78:	83 c4 10             	add    $0x10,%esp
f0100b7b:	85 c0                	test   %eax,%eax
f0100b7d:	75 08                	jne    f0100b87 <mPerm+0x102>
		tmp = tmp ^ PTE_A;
f0100b7f:	83 f6 20             	xor    $0x20,%esi
f0100b82:	e9 50 ff ff ff       	jmp    f0100ad7 <mPerm+0x52>
	else if (strcmp(perm, "PTE_D") == 0)
f0100b87:	83 ec 08             	sub    $0x8,%esp
f0100b8a:	8d 83 6c 84 f7 ff    	lea    -0x87b94(%ebx),%eax
f0100b90:	50                   	push   %eax
f0100b91:	ff 75 10             	pushl  0x10(%ebp)
f0100b94:	e8 0c 42 00 00       	call   f0104da5 <strcmp>
f0100b99:	83 c4 10             	add    $0x10,%esp
f0100b9c:	85 c0                	test   %eax,%eax
f0100b9e:	75 08                	jne    f0100ba8 <mPerm+0x123>
		tmp = tmp ^ PTE_D;
f0100ba0:	83 f6 40             	xor    $0x40,%esi
f0100ba3:	e9 2f ff ff ff       	jmp    f0100ad7 <mPerm+0x52>
	else if (strcmp(perm, "PTE_PS") == 0)
f0100ba8:	83 ec 08             	sub    $0x8,%esp
f0100bab:	8d 83 72 84 f7 ff    	lea    -0x87b8e(%ebx),%eax
f0100bb1:	50                   	push   %eax
f0100bb2:	ff 75 10             	pushl  0x10(%ebp)
f0100bb5:	e8 eb 41 00 00       	call   f0104da5 <strcmp>
f0100bba:	83 c4 10             	add    $0x10,%esp
f0100bbd:	85 c0                	test   %eax,%eax
f0100bbf:	75 0b                	jne    f0100bcc <mPerm+0x147>
		tmp = tmp ^ PTE_PS;
f0100bc1:	81 f6 80 00 00 00    	xor    $0x80,%esi
f0100bc7:	e9 0b ff ff ff       	jmp    f0100ad7 <mPerm+0x52>
	else if (strcmp(perm, "PTE_G") == 0)
f0100bcc:	83 ec 08             	sub    $0x8,%esp
f0100bcf:	8d 83 79 84 f7 ff    	lea    -0x87b87(%ebx),%eax
f0100bd5:	50                   	push   %eax
f0100bd6:	ff 75 10             	pushl  0x10(%ebp)
f0100bd9:	e8 c7 41 00 00       	call   f0104da5 <strcmp>
f0100bde:	83 c4 10             	add    $0x10,%esp
f0100be1:	85 c0                	test   %eax,%eax
f0100be3:	0f 85 ee fe ff ff    	jne    f0100ad7 <mPerm+0x52>
		tmp = tmp ^ PTE_G;
f0100be9:	81 f6 00 01 00 00    	xor    $0x100,%esi
f0100bef:	e9 e3 fe ff ff       	jmp    f0100ad7 <mPerm+0x52>
		*pte |= tmp;
f0100bf4:	09 37                	or     %esi,(%edi)
f0100bf6:	e9 e8 fe ff ff       	jmp    f0100ae3 <mPerm+0x5e>

f0100bfb <mon_mPerm>:
{
f0100bfb:	55                   	push   %ebp
f0100bfc:	89 e5                	mov    %esp,%ebp
f0100bfe:	57                   	push   %edi
f0100bff:	56                   	push   %esi
f0100c00:	53                   	push   %ebx
f0100c01:	83 ec 20             	sub    $0x20,%esp
f0100c04:	e8 5e f5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100c09:	81 c3 2b c5 08 00    	add    $0x8c52b,%ebx
f0100c0f:	8b 75 0c             	mov    0xc(%ebp),%esi
	char *ops = argv[1];
f0100c12:	8b 7e 04             	mov    0x4(%esi),%edi
	uintptr_t va = strtol(argv[2], NULL, 16);
f0100c15:	6a 10                	push   $0x10
f0100c17:	6a 00                	push   $0x0
f0100c19:	ff 76 08             	pushl  0x8(%esi)
f0100c1c:	e8 3d 43 00 00       	call   f0104f5e <strtol>
f0100c21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	char *perm = argv[3];
f0100c24:	8b 46 0c             	mov    0xc(%esi),%eax
f0100c27:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if (!strcmp(ops, "CHANGE"))
f0100c2a:	83 c4 08             	add    $0x8,%esp
f0100c2d:	8d 83 7f 84 f7 ff    	lea    -0x87b81(%ebx),%eax
f0100c33:	50                   	push   %eax
f0100c34:	57                   	push   %edi
f0100c35:	e8 6b 41 00 00       	call   f0104da5 <strcmp>
f0100c3a:	83 c4 10             	add    $0x10,%esp
f0100c3d:	85 c0                	test   %eax,%eax
f0100c3f:	75 51                	jne    f0100c92 <mon_mPerm+0x97>
		assert(argc == 5);
f0100c41:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
f0100c45:	75 2c                	jne    f0100c73 <mon_mPerm+0x78>
		new_perm = strtol(argv[4], NULL, 10);
f0100c47:	83 ec 04             	sub    $0x4,%esp
f0100c4a:	6a 0a                	push   $0xa
f0100c4c:	6a 00                	push   $0x0
f0100c4e:	ff 76 10             	pushl  0x10(%esi)
f0100c51:	e8 08 43 00 00       	call   f0104f5e <strtol>
f0100c56:	83 c4 10             	add    $0x10,%esp
	mPerm(ops, va, perm, new_perm);
f0100c59:	50                   	push   %eax
f0100c5a:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c5d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c60:	57                   	push   %edi
f0100c61:	e8 1f fe ff ff       	call   f0100a85 <mPerm>
}
f0100c66:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c6e:	5b                   	pop    %ebx
f0100c6f:	5e                   	pop    %esi
f0100c70:	5f                   	pop    %edi
f0100c71:	5d                   	pop    %ebp
f0100c72:	c3                   	ret    
		assert(argc == 5);
f0100c73:	8d 83 86 84 f7 ff    	lea    -0x87b7a(%ebx),%eax
f0100c79:	50                   	push   %eax
f0100c7a:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0100c80:	50                   	push   %eax
f0100c81:	68 c8 00 00 00       	push   $0xc8
f0100c86:	8d 83 1f 84 f7 ff    	lea    -0x87be1(%ebx),%eax
f0100c8c:	50                   	push   %eax
f0100c8d:	e8 1f f4 ff ff       	call   f01000b1 <_panic>
	else if (!strcmp(ops, "SET"))
f0100c92:	83 ec 08             	sub    $0x8,%esp
f0100c95:	8d 83 90 84 f7 ff    	lea    -0x87b70(%ebx),%eax
f0100c9b:	50                   	push   %eax
f0100c9c:	57                   	push   %edi
f0100c9d:	e8 03 41 00 00       	call   f0104da5 <strcmp>
f0100ca2:	83 c4 10             	add    $0x10,%esp
f0100ca5:	85 c0                	test   %eax,%eax
f0100ca7:	75 2c                	jne    f0100cd5 <mon_mPerm+0xda>
		assert(argc == 4);
f0100ca9:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100cad:	75 07                	jne    f0100cb6 <mon_mPerm+0xbb>
		new_perm = 1;
f0100caf:	b8 01 00 00 00       	mov    $0x1,%eax
f0100cb4:	eb a3                	jmp    f0100c59 <mon_mPerm+0x5e>
		assert(argc == 4);
f0100cb6:	8d 83 94 84 f7 ff    	lea    -0x87b6c(%ebx),%eax
f0100cbc:	50                   	push   %eax
f0100cbd:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0100cc3:	50                   	push   %eax
f0100cc4:	68 cd 00 00 00       	push   $0xcd
f0100cc9:	8d 83 1f 84 f7 ff    	lea    -0x87be1(%ebx),%eax
f0100ccf:	50                   	push   %eax
f0100cd0:	e8 dc f3 ff ff       	call   f01000b1 <_panic>
	else if (!strcmp(ops, "CLEAR"))
f0100cd5:	83 ec 08             	sub    $0x8,%esp
f0100cd8:	8d 83 9e 84 f7 ff    	lea    -0x87b62(%ebx),%eax
f0100cde:	50                   	push   %eax
f0100cdf:	57                   	push   %edi
f0100ce0:	e8 c0 40 00 00       	call   f0104da5 <strcmp>
f0100ce5:	83 c4 10             	add    $0x10,%esp
f0100ce8:	85 c0                	test   %eax,%eax
f0100cea:	75 29                	jne    f0100d15 <mon_mPerm+0x11a>
		assert(argc == 4);
f0100cec:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100cf0:	0f 84 63 ff ff ff    	je     f0100c59 <mon_mPerm+0x5e>
f0100cf6:	8d 83 94 84 f7 ff    	lea    -0x87b6c(%ebx),%eax
f0100cfc:	50                   	push   %eax
f0100cfd:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0100d03:	50                   	push   %eax
f0100d04:	68 d2 00 00 00       	push   $0xd2
f0100d09:	8d 83 1f 84 f7 ff    	lea    -0x87be1(%ebx),%eax
f0100d0f:	50                   	push   %eax
f0100d10:	e8 9c f3 ff ff       	call   f01000b1 <_panic>
		cprintf("INVALID COMMAND\n");
f0100d15:	83 ec 0c             	sub    $0xc,%esp
f0100d18:	8d 83 a4 84 f7 ff    	lea    -0x87b5c(%ebx),%eax
f0100d1e:	50                   	push   %eax
f0100d1f:	e8 2b 30 00 00       	call   f0103d4f <cprintf>
f0100d24:	83 c4 10             	add    $0x10,%esp
	int new_perm = 0;
f0100d27:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d2c:	e9 28 ff ff ff       	jmp    f0100c59 <mon_mPerm+0x5e>

f0100d31 <dump_v>:
{
f0100d31:	55                   	push   %ebp
f0100d32:	89 e5                	mov    %esp,%ebp
f0100d34:	57                   	push   %edi
f0100d35:	56                   	push   %esi
f0100d36:	53                   	push   %ebx
f0100d37:	83 ec 0c             	sub    $0xc,%esp
f0100d3a:	e8 28 f4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100d3f:	81 c3 f5 c3 08 00    	add    $0x8c3f5,%ebx
f0100d45:	8b 75 08             	mov    0x8(%ebp),%esi
		cprintf("The virtual address is 0x%08x and content is 0x%08x\n", current_va, *(uint32_t *)current_va);
f0100d48:	8d bb c4 87 f7 ff    	lea    -0x8783c(%ebx),%edi
	for (current_va = va_start; current_va <= va_end; current_va += PGSIZE)
f0100d4e:	eb 15                	jmp    f0100d65 <dump_v+0x34>
		cprintf("The virtual address is 0x%08x and content is 0x%08x\n", current_va, *(uint32_t *)current_va);
f0100d50:	83 ec 04             	sub    $0x4,%esp
f0100d53:	ff 36                	pushl  (%esi)
f0100d55:	56                   	push   %esi
f0100d56:	57                   	push   %edi
f0100d57:	e8 f3 2f 00 00       	call   f0103d4f <cprintf>
	for (current_va = va_start; current_va <= va_end; current_va += PGSIZE)
f0100d5c:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100d62:	83 c4 10             	add    $0x10,%esp
f0100d65:	3b 75 0c             	cmp    0xc(%ebp),%esi
f0100d68:	76 e6                	jbe    f0100d50 <dump_v+0x1f>
}
f0100d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d6d:	5b                   	pop    %ebx
f0100d6e:	5e                   	pop    %esi
f0100d6f:	5f                   	pop    %edi
f0100d70:	5d                   	pop    %ebp
f0100d71:	c3                   	ret    

f0100d72 <dump_p>:
{
f0100d72:	55                   	push   %ebp
f0100d73:	89 e5                	mov    %esp,%ebp
f0100d75:	57                   	push   %edi
f0100d76:	56                   	push   %esi
f0100d77:	53                   	push   %ebx
f0100d78:	83 ec 1c             	sub    $0x1c,%esp
f0100d7b:	e8 e7 f3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100d80:	81 c3 b4 c3 08 00    	add    $0x8c3b4,%ebx
f0100d86:	8b 75 08             	mov    0x8(%ebp),%esi
	if (PGNUM(pa) >= npages)
f0100d89:	c7 c7 28 00 19 f0    	mov    $0xf0190028,%edi
		cprintf("The physical address is 0x%08x and content is 0x%08x\n", current_pa, *(uint32_t *)KADDR(current_pa));
f0100d8f:	8d 83 20 88 f7 ff    	lea    -0x877e0(%ebx),%eax
f0100d95:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (current_pa = pa_start; current_pa <= pa_end; current_pa += PGSIZE)
f0100d98:	3b 75 0c             	cmp    0xc(%ebp),%esi
f0100d9b:	77 3f                	ja     f0100ddc <dump_p+0x6a>
f0100d9d:	89 f0                	mov    %esi,%eax
f0100d9f:	c1 e8 0c             	shr    $0xc,%eax
f0100da2:	3b 07                	cmp    (%edi),%eax
f0100da4:	73 1d                	jae    f0100dc3 <dump_p+0x51>
		cprintf("The physical address is 0x%08x and content is 0x%08x\n", current_pa, *(uint32_t *)KADDR(current_pa));
f0100da6:	83 ec 04             	sub    $0x4,%esp
f0100da9:	ff b6 00 00 00 f0    	pushl  -0x10000000(%esi)
f0100daf:	56                   	push   %esi
f0100db0:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100db3:	e8 97 2f 00 00       	call   f0103d4f <cprintf>
	for (current_pa = pa_start; current_pa <= pa_end; current_pa += PGSIZE)
f0100db8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100dbe:	83 c4 10             	add    $0x10,%esp
f0100dc1:	eb d5                	jmp    f0100d98 <dump_p+0x26>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dc3:	56                   	push   %esi
f0100dc4:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0100dca:	50                   	push   %eax
f0100dcb:	68 ea 00 00 00       	push   $0xea
f0100dd0:	8d 83 1f 84 f7 ff    	lea    -0x87be1(%ebx),%eax
f0100dd6:	50                   	push   %eax
f0100dd7:	e8 d5 f2 ff ff       	call   f01000b1 <_panic>
}
f0100ddc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ddf:	5b                   	pop    %ebx
f0100de0:	5e                   	pop    %esi
f0100de1:	5f                   	pop    %edi
f0100de2:	5d                   	pop    %ebp
f0100de3:	c3                   	ret    

f0100de4 <mon_dump>:
{
f0100de4:	55                   	push   %ebp
f0100de5:	89 e5                	mov    %esp,%ebp
f0100de7:	57                   	push   %edi
f0100de8:	56                   	push   %esi
f0100de9:	53                   	push   %ebx
f0100dea:	83 ec 0c             	sub    $0xc,%esp
f0100ded:	e8 75 f3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100df2:	81 c3 42 c3 08 00    	add    $0x8c342,%ebx
f0100df8:	8b 75 0c             	mov    0xc(%ebp),%esi
	assert(argc == 4);
f0100dfb:	83 7d 08 04          	cmpl   $0x4,0x8(%ebp)
f0100dff:	75 5b                	jne    f0100e5c <mon_dump+0x78>
	char *addr_type = argv[1];
f0100e01:	8b 7e 04             	mov    0x4(%esi),%edi
	if (!strcmp(addr_type, "physical"))
f0100e04:	83 ec 08             	sub    $0x8,%esp
f0100e07:	8d 83 b5 84 f7 ff    	lea    -0x87b4b(%ebx),%eax
f0100e0d:	50                   	push   %eax
f0100e0e:	57                   	push   %edi
f0100e0f:	e8 91 3f 00 00       	call   f0104da5 <strcmp>
f0100e14:	83 c4 10             	add    $0x10,%esp
f0100e17:	85 c0                	test   %eax,%eax
f0100e19:	75 7f                	jne    f0100e9a <mon_dump+0xb6>
		p_start = strtol(argv[2], NULL, 16);
f0100e1b:	83 ec 04             	sub    $0x4,%esp
f0100e1e:	6a 10                	push   $0x10
f0100e20:	6a 00                	push   $0x0
f0100e22:	ff 76 08             	pushl  0x8(%esi)
f0100e25:	e8 34 41 00 00       	call   f0104f5e <strtol>
f0100e2a:	89 c7                	mov    %eax,%edi
		p_end = strtol(argv[3], NULL, 16);
f0100e2c:	83 c4 0c             	add    $0xc,%esp
f0100e2f:	6a 10                	push   $0x10
f0100e31:	6a 00                	push   $0x0
f0100e33:	ff 76 0c             	pushl  0xc(%esi)
f0100e36:	e8 23 41 00 00       	call   f0104f5e <strtol>
		assert(p_start <= p_end);
f0100e3b:	83 c4 10             	add    $0x10,%esp
f0100e3e:	39 c7                	cmp    %eax,%edi
f0100e40:	77 39                	ja     f0100e7b <mon_dump+0x97>
		dump_p(p_start, p_end);
f0100e42:	83 ec 08             	sub    $0x8,%esp
f0100e45:	50                   	push   %eax
f0100e46:	57                   	push   %edi
f0100e47:	e8 26 ff ff ff       	call   f0100d72 <dump_p>
f0100e4c:	83 c4 10             	add    $0x10,%esp
}
f0100e4f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e54:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e57:	5b                   	pop    %ebx
f0100e58:	5e                   	pop    %esi
f0100e59:	5f                   	pop    %edi
f0100e5a:	5d                   	pop    %ebp
f0100e5b:	c3                   	ret    
	assert(argc == 4);
f0100e5c:	8d 83 94 84 f7 ff    	lea    -0x87b6c(%ebx),%eax
f0100e62:	50                   	push   %eax
f0100e63:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0100e69:	50                   	push   %eax
f0100e6a:	68 f1 00 00 00       	push   $0xf1
f0100e6f:	8d 83 1f 84 f7 ff    	lea    -0x87be1(%ebx),%eax
f0100e75:	50                   	push   %eax
f0100e76:	e8 36 f2 ff ff       	call   f01000b1 <_panic>
		assert(p_start <= p_end);
f0100e7b:	8d 83 be 84 f7 ff    	lea    -0x87b42(%ebx),%eax
f0100e81:	50                   	push   %eax
f0100e82:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0100e88:	50                   	push   %eax
f0100e89:	68 f9 00 00 00       	push   $0xf9
f0100e8e:	8d 83 1f 84 f7 ff    	lea    -0x87be1(%ebx),%eax
f0100e94:	50                   	push   %eax
f0100e95:	e8 17 f2 ff ff       	call   f01000b1 <_panic>
	else if (!strcmp(addr_type, "virtual"))
f0100e9a:	83 ec 08             	sub    $0x8,%esp
f0100e9d:	8d 83 cf 84 f7 ff    	lea    -0x87b31(%ebx),%eax
f0100ea3:	50                   	push   %eax
f0100ea4:	57                   	push   %edi
f0100ea5:	e8 fb 3e 00 00       	call   f0104da5 <strcmp>
f0100eaa:	83 c4 10             	add    $0x10,%esp
f0100ead:	85 c0                	test   %eax,%eax
f0100eaf:	75 58                	jne    f0100f09 <mon_dump+0x125>
		v_start = strtol(argv[2], NULL, 16);
f0100eb1:	83 ec 04             	sub    $0x4,%esp
f0100eb4:	6a 10                	push   $0x10
f0100eb6:	6a 00                	push   $0x0
f0100eb8:	ff 76 08             	pushl  0x8(%esi)
f0100ebb:	e8 9e 40 00 00       	call   f0104f5e <strtol>
f0100ec0:	89 c7                	mov    %eax,%edi
		v_end = strtol(argv[3], NULL, 16);
f0100ec2:	83 c4 0c             	add    $0xc,%esp
f0100ec5:	6a 10                	push   $0x10
f0100ec7:	6a 00                	push   $0x0
f0100ec9:	ff 76 0c             	pushl  0xc(%esi)
f0100ecc:	e8 8d 40 00 00       	call   f0104f5e <strtol>
		assert(v_start <= v_end);
f0100ed1:	83 c4 10             	add    $0x10,%esp
f0100ed4:	39 c7                	cmp    %eax,%edi
f0100ed6:	77 12                	ja     f0100eea <mon_dump+0x106>
		dump_v(v_start, v_end);
f0100ed8:	83 ec 08             	sub    $0x8,%esp
f0100edb:	50                   	push   %eax
f0100edc:	57                   	push   %edi
f0100edd:	e8 4f fe ff ff       	call   f0100d31 <dump_v>
f0100ee2:	83 c4 10             	add    $0x10,%esp
f0100ee5:	e9 65 ff ff ff       	jmp    f0100e4f <mon_dump+0x6b>
		assert(v_start <= v_end);
f0100eea:	8d 83 d7 84 f7 ff    	lea    -0x87b29(%ebx),%eax
f0100ef0:	50                   	push   %eax
f0100ef1:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0100ef7:	50                   	push   %eax
f0100ef8:	68 00 01 00 00       	push   $0x100
f0100efd:	8d 83 1f 84 f7 ff    	lea    -0x87be1(%ebx),%eax
f0100f03:	50                   	push   %eax
f0100f04:	e8 a8 f1 ff ff       	call   f01000b1 <_panic>
		cprintf("INVAILD ADDRESS TYPE\n");
f0100f09:	83 ec 0c             	sub    $0xc,%esp
f0100f0c:	8d 83 e8 84 f7 ff    	lea    -0x87b18(%ebx),%eax
f0100f12:	50                   	push   %eax
f0100f13:	e8 37 2e 00 00       	call   f0103d4f <cprintf>
		return 0;
f0100f18:	83 c4 10             	add    $0x10,%esp
f0100f1b:	e9 2f ff ff ff       	jmp    f0100e4f <mon_dump+0x6b>

f0100f20 <mAddr>:
{
f0100f20:	55                   	push   %ebp
f0100f21:	89 e5                	mov    %esp,%ebp
	*(uint32_t *)va = info;
f0100f23:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f26:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f29:	89 10                	mov    %edx,(%eax)
}
f0100f2b:	5d                   	pop    %ebp
f0100f2c:	c3                   	ret    

f0100f2d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100f2d:	55                   	push   %ebp
f0100f2e:	89 e5                	mov    %esp,%ebp
f0100f30:	57                   	push   %edi
f0100f31:	56                   	push   %esi
f0100f32:	53                   	push   %ebx
f0100f33:	83 ec 68             	sub    $0x68,%esp
f0100f36:	e8 2c f2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0100f3b:	81 c3 f9 c1 08 00    	add    $0x8c1f9,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100f41:	8d 83 58 88 f7 ff    	lea    -0x877a8(%ebx),%eax
f0100f47:	50                   	push   %eax
f0100f48:	e8 02 2e 00 00       	call   f0103d4f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100f4d:	8d 83 7c 88 f7 ff    	lea    -0x87784(%ebx),%eax
f0100f53:	89 04 24             	mov    %eax,(%esp)
f0100f56:	e8 f4 2d 00 00       	call   f0103d4f <cprintf>

	if (tf != NULL)
f0100f5b:	83 c4 10             	add    $0x10,%esp
f0100f5e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100f62:	74 0e                	je     f0100f72 <monitor+0x45>
		print_trapframe(tf);
f0100f64:	83 ec 0c             	sub    $0xc,%esp
f0100f67:	ff 75 08             	pushl  0x8(%ebp)
f0100f6a:	e8 49 2f 00 00       	call   f0103eb8 <print_trapframe>
f0100f6f:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100f72:	8d bb 02 85 f7 ff    	lea    -0x87afe(%ebx),%edi
f0100f78:	eb 4a                	jmp    f0100fc4 <monitor+0x97>
f0100f7a:	83 ec 08             	sub    $0x8,%esp
f0100f7d:	0f be c0             	movsbl %al,%eax
f0100f80:	50                   	push   %eax
f0100f81:	57                   	push   %edi
f0100f82:	e8 7c 3e 00 00       	call   f0104e03 <strchr>
f0100f87:	83 c4 10             	add    $0x10,%esp
f0100f8a:	85 c0                	test   %eax,%eax
f0100f8c:	74 08                	je     f0100f96 <monitor+0x69>
			*buf++ = 0;
f0100f8e:	c6 06 00             	movb   $0x0,(%esi)
f0100f91:	8d 76 01             	lea    0x1(%esi),%esi
f0100f94:	eb 79                	jmp    f010100f <monitor+0xe2>
		if (*buf == 0)
f0100f96:	80 3e 00             	cmpb   $0x0,(%esi)
f0100f99:	74 7f                	je     f010101a <monitor+0xed>
		if (argc == MAXARGS-1) {
f0100f9b:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100f9f:	74 0f                	je     f0100fb0 <monitor+0x83>
		argv[argc++] = buf;
f0100fa1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100fa4:	8d 48 01             	lea    0x1(%eax),%ecx
f0100fa7:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100faa:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100fae:	eb 44                	jmp    f0100ff4 <monitor+0xc7>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100fb0:	83 ec 08             	sub    $0x8,%esp
f0100fb3:	6a 10                	push   $0x10
f0100fb5:	8d 83 07 85 f7 ff    	lea    -0x87af9(%ebx),%eax
f0100fbb:	50                   	push   %eax
f0100fbc:	e8 8e 2d 00 00       	call   f0103d4f <cprintf>
f0100fc1:	83 c4 10             	add    $0x10,%esp
	while (1) {
		buf = readline("K> ");
f0100fc4:	8d 83 fe 84 f7 ff    	lea    -0x87b02(%ebx),%eax
f0100fca:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100fcd:	83 ec 0c             	sub    $0xc,%esp
f0100fd0:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100fd3:	e8 f3 3b 00 00       	call   f0104bcb <readline>
f0100fd8:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100fda:	83 c4 10             	add    $0x10,%esp
f0100fdd:	85 c0                	test   %eax,%eax
f0100fdf:	74 ec                	je     f0100fcd <monitor+0xa0>
	argv[argc] = 0;
f0100fe1:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100fe8:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100fef:	eb 1e                	jmp    f010100f <monitor+0xe2>
			buf++;
f0100ff1:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ff4:	0f b6 06             	movzbl (%esi),%eax
f0100ff7:	84 c0                	test   %al,%al
f0100ff9:	74 14                	je     f010100f <monitor+0xe2>
f0100ffb:	83 ec 08             	sub    $0x8,%esp
f0100ffe:	0f be c0             	movsbl %al,%eax
f0101001:	50                   	push   %eax
f0101002:	57                   	push   %edi
f0101003:	e8 fb 3d 00 00       	call   f0104e03 <strchr>
f0101008:	83 c4 10             	add    $0x10,%esp
f010100b:	85 c0                	test   %eax,%eax
f010100d:	74 e2                	je     f0100ff1 <monitor+0xc4>
		while (*buf && strchr(WHITESPACE, *buf))
f010100f:	0f b6 06             	movzbl (%esi),%eax
f0101012:	84 c0                	test   %al,%al
f0101014:	0f 85 60 ff ff ff    	jne    f0100f7a <monitor+0x4d>
	argv[argc] = 0;
f010101a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010101d:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0101024:	00 
	if (argc == 0)
f0101025:	85 c0                	test   %eax,%eax
f0101027:	74 9b                	je     f0100fc4 <monitor+0x97>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0101029:	be 00 00 00 00       	mov    $0x0,%esi
		if (strcmp(argv[0], commands[i].name) == 0)
f010102e:	83 ec 08             	sub    $0x8,%esp
f0101031:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0101034:	ff b4 83 0c 1f 00 00 	pushl  0x1f0c(%ebx,%eax,4)
f010103b:	ff 75 a8             	pushl  -0x58(%ebp)
f010103e:	e8 62 3d 00 00       	call   f0104da5 <strcmp>
f0101043:	83 c4 10             	add    $0x10,%esp
f0101046:	85 c0                	test   %eax,%eax
f0101048:	74 22                	je     f010106c <monitor+0x13f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010104a:	83 c6 01             	add    $0x1,%esi
f010104d:	83 fe 07             	cmp    $0x7,%esi
f0101050:	75 dc                	jne    f010102e <monitor+0x101>
	cprintf("Unknown command '%s'\n", argv[0]);
f0101052:	83 ec 08             	sub    $0x8,%esp
f0101055:	ff 75 a8             	pushl  -0x58(%ebp)
f0101058:	8d 83 24 85 f7 ff    	lea    -0x87adc(%ebx),%eax
f010105e:	50                   	push   %eax
f010105f:	e8 eb 2c 00 00       	call   f0103d4f <cprintf>
f0101064:	83 c4 10             	add    $0x10,%esp
f0101067:	e9 58 ff ff ff       	jmp    f0100fc4 <monitor+0x97>
			return commands[i].func(argc, argv, tf);
f010106c:	83 ec 04             	sub    $0x4,%esp
f010106f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0101072:	ff 75 08             	pushl  0x8(%ebp)
f0101075:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0101078:	52                   	push   %edx
f0101079:	ff 75 a4             	pushl  -0x5c(%ebp)
f010107c:	ff 94 83 14 1f 00 00 	call   *0x1f14(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0101083:	83 c4 10             	add    $0x10,%esp
f0101086:	85 c0                	test   %eax,%eax
f0101088:	0f 89 36 ff ff ff    	jns    f0100fc4 <monitor+0x97>
				break;
	}
}
f010108e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101091:	5b                   	pop    %ebx
f0101092:	5e                   	pop    %esi
f0101093:	5f                   	pop    %edi
f0101094:	5d                   	pop    %ebp
f0101095:	c3                   	ret    

f0101096 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0101096:	55                   	push   %ebp
f0101097:	89 e5                	mov    %esp,%ebp
f0101099:	57                   	push   %edi
f010109a:	56                   	push   %esi
f010109b:	53                   	push   %ebx
f010109c:	83 ec 18             	sub    $0x18,%esp
f010109f:	e8 c3 f0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01010a4:	81 c3 90 c0 08 00    	add    $0x8c090,%ebx
f01010aa:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010ac:	50                   	push   %eax
f01010ad:	e8 16 2c 00 00       	call   f0103cc8 <mc146818_read>
f01010b2:	89 c6                	mov    %eax,%esi
f01010b4:	83 c7 01             	add    $0x1,%edi
f01010b7:	89 3c 24             	mov    %edi,(%esp)
f01010ba:	e8 09 2c 00 00       	call   f0103cc8 <mc146818_read>
f01010bf:	c1 e0 08             	shl    $0x8,%eax
f01010c2:	09 f0                	or     %esi,%eax
}
f01010c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010c7:	5b                   	pop    %ebx
f01010c8:	5e                   	pop    %esi
f01010c9:	5f                   	pop    %edi
f01010ca:	5d                   	pop    %ebp
f01010cb:	c3                   	ret    

f01010cc <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01010cc:	55                   	push   %ebp
f01010cd:	89 e5                	mov    %esp,%ebp
f01010cf:	56                   	push   %esi
f01010d0:	53                   	push   %ebx
f01010d1:	e8 db 26 00 00       	call   f01037b1 <__x86.get_pc_thunk.cx>
f01010d6:	81 c1 5e c0 08 00    	add    $0x8c05e,%ecx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01010dc:	83 b9 24 22 00 00 00 	cmpl   $0x0,0x2224(%ecx)
f01010e3:	74 37                	je     f010111c <boot_alloc+0x50>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f01010e5:	8b b1 24 22 00 00    	mov    0x2224(%ecx),%esi
	nextfree = ROUNDUP(nextfree + n, PGSIZE);
f01010eb:	8d 94 06 ff 0f 00 00 	lea    0xfff(%esi,%eax,1),%edx
f01010f2:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01010f8:	89 91 24 22 00 00    	mov    %edx,0x2224(%ecx)
	assert((uint32_t) nextfree - KERNBASE <= (npages * PGSIZE));
f01010fe:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101104:	c7 c0 28 00 19 f0    	mov    $0xf0190028,%eax
f010110a:	8b 18                	mov    (%eax),%ebx
f010110c:	c1 e3 0c             	shl    $0xc,%ebx
f010110f:	39 da                	cmp    %ebx,%edx
f0101111:	77 23                	ja     f0101136 <boot_alloc+0x6a>
	return result;
}
f0101113:	89 f0                	mov    %esi,%eax
f0101115:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101118:	5b                   	pop    %ebx
f0101119:	5e                   	pop    %esi
f010111a:	5d                   	pop    %ebp
f010111b:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010111c:	c7 c2 20 00 19 f0    	mov    $0xf0190020,%edx
f0101122:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0101128:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010112e:	89 91 24 22 00 00    	mov    %edx,0x2224(%ecx)
f0101134:	eb af                	jmp    f01010e5 <boot_alloc+0x19>
	assert((uint32_t) nextfree - KERNBASE <= (npages * PGSIZE));
f0101136:	8d 81 1c 89 f7 ff    	lea    -0x876e4(%ecx),%eax
f010113c:	50                   	push   %eax
f010113d:	8d 81 0a 84 f7 ff    	lea    -0x87bf6(%ecx),%eax
f0101143:	50                   	push   %eax
f0101144:	6a 6c                	push   $0x6c
f0101146:	8d 81 d5 90 f7 ff    	lea    -0x86f2b(%ecx),%eax
f010114c:	50                   	push   %eax
f010114d:	89 cb                	mov    %ecx,%ebx
f010114f:	e8 5d ef ff ff       	call   f01000b1 <_panic>

f0101154 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0101154:	55                   	push   %ebp
f0101155:	89 e5                	mov    %esp,%ebp
f0101157:	56                   	push   %esi
f0101158:	53                   	push   %ebx
f0101159:	e8 53 26 00 00       	call   f01037b1 <__x86.get_pc_thunk.cx>
f010115e:	81 c1 d6 bf 08 00    	add    $0x8bfd6,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0101164:	89 d3                	mov    %edx,%ebx
f0101166:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0101169:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f010116c:	a8 01                	test   $0x1,%al
f010116e:	74 5a                	je     f01011ca <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0101170:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101175:	89 c6                	mov    %eax,%esi
f0101177:	c1 ee 0c             	shr    $0xc,%esi
f010117a:	c7 c3 28 00 19 f0    	mov    $0xf0190028,%ebx
f0101180:	3b 33                	cmp    (%ebx),%esi
f0101182:	73 2b                	jae    f01011af <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0101184:	c1 ea 0c             	shr    $0xc,%edx
f0101187:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010118d:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0101194:	89 c2                	mov    %eax,%edx
f0101196:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0101199:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010119e:	85 d2                	test   %edx,%edx
f01011a0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01011a5:	0f 44 c2             	cmove  %edx,%eax
}
f01011a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011ab:	5b                   	pop    %ebx
f01011ac:	5e                   	pop    %esi
f01011ad:	5d                   	pop    %ebp
f01011ae:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011af:	50                   	push   %eax
f01011b0:	8d 81 fc 87 f7 ff    	lea    -0x87804(%ecx),%eax
f01011b6:	50                   	push   %eax
f01011b7:	68 40 03 00 00       	push   $0x340
f01011bc:	8d 81 d5 90 f7 ff    	lea    -0x86f2b(%ecx),%eax
f01011c2:	50                   	push   %eax
f01011c3:	89 cb                	mov    %ecx,%ebx
f01011c5:	e8 e7 ee ff ff       	call   f01000b1 <_panic>
		return ~0;
f01011ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01011cf:	eb d7                	jmp    f01011a8 <check_va2pa+0x54>

f01011d1 <check_page_free_list>:
{
f01011d1:	55                   	push   %ebp
f01011d2:	89 e5                	mov    %esp,%ebp
f01011d4:	57                   	push   %edi
f01011d5:	56                   	push   %esi
f01011d6:	53                   	push   %ebx
f01011d7:	83 ec 3c             	sub    $0x3c,%esp
f01011da:	e8 da 25 00 00       	call   f01037b9 <__x86.get_pc_thunk.di>
f01011df:	81 c7 55 bf 08 00    	add    $0x8bf55,%edi
f01011e5:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01011e8:	84 c0                	test   %al,%al
f01011ea:	0f 85 dd 02 00 00    	jne    f01014cd <check_page_free_list+0x2fc>
	if (!page_free_list)
f01011f0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01011f3:	83 b8 28 22 00 00 00 	cmpl   $0x0,0x2228(%eax)
f01011fa:	74 0c                	je     f0101208 <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01011fc:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0101203:	e9 2f 03 00 00       	jmp    f0101537 <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f0101208:	83 ec 04             	sub    $0x4,%esp
f010120b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010120e:	8d 83 50 89 f7 ff    	lea    -0x876b0(%ebx),%eax
f0101214:	50                   	push   %eax
f0101215:	68 78 02 00 00       	push   $0x278
f010121a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101220:	50                   	push   %eax
f0101221:	e8 8b ee ff ff       	call   f01000b1 <_panic>
f0101226:	50                   	push   %eax
f0101227:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010122a:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0101230:	50                   	push   %eax
f0101231:	6a 56                	push   $0x56
f0101233:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f0101239:	50                   	push   %eax
f010123a:	e8 72 ee ff ff       	call   f01000b1 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010123f:	8b 36                	mov    (%esi),%esi
f0101241:	85 f6                	test   %esi,%esi
f0101243:	74 40                	je     f0101285 <check_page_free_list+0xb4>
	return (pp - pages) << PGSHIFT;
f0101245:	89 f0                	mov    %esi,%eax
f0101247:	2b 07                	sub    (%edi),%eax
f0101249:	c1 f8 03             	sar    $0x3,%eax
f010124c:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f010124f:	89 c2                	mov    %eax,%edx
f0101251:	c1 ea 16             	shr    $0x16,%edx
f0101254:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0101257:	73 e6                	jae    f010123f <check_page_free_list+0x6e>
	if (PGNUM(pa) >= npages)
f0101259:	89 c2                	mov    %eax,%edx
f010125b:	c1 ea 0c             	shr    $0xc,%edx
f010125e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101261:	3b 11                	cmp    (%ecx),%edx
f0101263:	73 c1                	jae    f0101226 <check_page_free_list+0x55>
			memset(page2kva(pp), 0x97, 128);
f0101265:	83 ec 04             	sub    $0x4,%esp
f0101268:	68 80 00 00 00       	push   $0x80
f010126d:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0101272:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101277:	50                   	push   %eax
f0101278:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010127b:	e8 c0 3b 00 00       	call   f0104e40 <memset>
f0101280:	83 c4 10             	add    $0x10,%esp
f0101283:	eb ba                	jmp    f010123f <check_page_free_list+0x6e>
	first_free_page = (char *) boot_alloc(0);
f0101285:	b8 00 00 00 00       	mov    $0x0,%eax
f010128a:	e8 3d fe ff ff       	call   f01010cc <boot_alloc>
f010128f:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101292:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0101295:	8b 97 28 22 00 00    	mov    0x2228(%edi),%edx
		assert(pp >= pages);
f010129b:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f01012a1:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f01012a3:	c7 c0 28 00 19 f0    	mov    $0xf0190028,%eax
f01012a9:	8b 00                	mov    (%eax),%eax
f01012ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01012ae:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01012b1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f01012b4:	bf 00 00 00 00       	mov    $0x0,%edi
f01012b9:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01012bc:	e9 08 01 00 00       	jmp    f01013c9 <check_page_free_list+0x1f8>
		assert(pp >= pages);
f01012c1:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01012c4:	8d 83 ef 90 f7 ff    	lea    -0x86f11(%ebx),%eax
f01012ca:	50                   	push   %eax
f01012cb:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01012d1:	50                   	push   %eax
f01012d2:	68 92 02 00 00       	push   $0x292
f01012d7:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01012dd:	50                   	push   %eax
f01012de:	e8 ce ed ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f01012e3:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01012e6:	8d 83 fb 90 f7 ff    	lea    -0x86f05(%ebx),%eax
f01012ec:	50                   	push   %eax
f01012ed:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01012f3:	50                   	push   %eax
f01012f4:	68 93 02 00 00       	push   $0x293
f01012f9:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01012ff:	50                   	push   %eax
f0101300:	e8 ac ed ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101305:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101308:	8d 83 74 89 f7 ff    	lea    -0x8768c(%ebx),%eax
f010130e:	50                   	push   %eax
f010130f:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101315:	50                   	push   %eax
f0101316:	68 94 02 00 00       	push   $0x294
f010131b:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101321:	50                   	push   %eax
f0101322:	e8 8a ed ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != 0);
f0101327:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010132a:	8d 83 0f 91 f7 ff    	lea    -0x86ef1(%ebx),%eax
f0101330:	50                   	push   %eax
f0101331:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101337:	50                   	push   %eax
f0101338:	68 97 02 00 00       	push   $0x297
f010133d:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101343:	50                   	push   %eax
f0101344:	e8 68 ed ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0101349:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010134c:	8d 83 20 91 f7 ff    	lea    -0x86ee0(%ebx),%eax
f0101352:	50                   	push   %eax
f0101353:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101359:	50                   	push   %eax
f010135a:	68 98 02 00 00       	push   $0x298
f010135f:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101365:	50                   	push   %eax
f0101366:	e8 46 ed ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010136b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010136e:	8d 83 a8 89 f7 ff    	lea    -0x87658(%ebx),%eax
f0101374:	50                   	push   %eax
f0101375:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f010137b:	50                   	push   %eax
f010137c:	68 99 02 00 00       	push   $0x299
f0101381:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101387:	50                   	push   %eax
f0101388:	e8 24 ed ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010138d:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101390:	8d 83 39 91 f7 ff    	lea    -0x86ec7(%ebx),%eax
f0101396:	50                   	push   %eax
f0101397:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f010139d:	50                   	push   %eax
f010139e:	68 9a 02 00 00       	push   $0x29a
f01013a3:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01013a9:	50                   	push   %eax
f01013aa:	e8 02 ed ff ff       	call   f01000b1 <_panic>
	if (PGNUM(pa) >= npages)
f01013af:	89 c6                	mov    %eax,%esi
f01013b1:	c1 ee 0c             	shr    $0xc,%esi
f01013b4:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f01013b7:	76 70                	jbe    f0101429 <check_page_free_list+0x258>
	return (void *)(pa + KERNBASE);
f01013b9:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01013be:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f01013c1:	77 7f                	ja     f0101442 <check_page_free_list+0x271>
			++nfree_extmem;
f01013c3:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01013c7:	8b 12                	mov    (%edx),%edx
f01013c9:	85 d2                	test   %edx,%edx
f01013cb:	0f 84 93 00 00 00    	je     f0101464 <check_page_free_list+0x293>
		assert(pp >= pages);
f01013d1:	39 d1                	cmp    %edx,%ecx
f01013d3:	0f 87 e8 fe ff ff    	ja     f01012c1 <check_page_free_list+0xf0>
		assert(pp < pages + npages);
f01013d9:	39 d3                	cmp    %edx,%ebx
f01013db:	0f 86 02 ff ff ff    	jbe    f01012e3 <check_page_free_list+0x112>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01013e1:	89 d0                	mov    %edx,%eax
f01013e3:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f01013e6:	a8 07                	test   $0x7,%al
f01013e8:	0f 85 17 ff ff ff    	jne    f0101305 <check_page_free_list+0x134>
	return (pp - pages) << PGSHIFT;
f01013ee:	c1 f8 03             	sar    $0x3,%eax
f01013f1:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f01013f4:	85 c0                	test   %eax,%eax
f01013f6:	0f 84 2b ff ff ff    	je     f0101327 <check_page_free_list+0x156>
		assert(page2pa(pp) != IOPHYSMEM);
f01013fc:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101401:	0f 84 42 ff ff ff    	je     f0101349 <check_page_free_list+0x178>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101407:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010140c:	0f 84 59 ff ff ff    	je     f010136b <check_page_free_list+0x19a>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101412:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101417:	0f 84 70 ff ff ff    	je     f010138d <check_page_free_list+0x1bc>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010141d:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101422:	77 8b                	ja     f01013af <check_page_free_list+0x1de>
			++nfree_basemem;
f0101424:	83 c7 01             	add    $0x1,%edi
f0101427:	eb 9e                	jmp    f01013c7 <check_page_free_list+0x1f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101429:	50                   	push   %eax
f010142a:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010142d:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0101433:	50                   	push   %eax
f0101434:	6a 56                	push   $0x56
f0101436:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f010143c:	50                   	push   %eax
f010143d:	e8 6f ec ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101442:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101445:	8d 83 cc 89 f7 ff    	lea    -0x87634(%ebx),%eax
f010144b:	50                   	push   %eax
f010144c:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101452:	50                   	push   %eax
f0101453:	68 9b 02 00 00       	push   $0x29b
f0101458:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010145e:	50                   	push   %eax
f010145f:	e8 4d ec ff ff       	call   f01000b1 <_panic>
f0101464:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0101467:	85 ff                	test   %edi,%edi
f0101469:	7e 1e                	jle    f0101489 <check_page_free_list+0x2b8>
	assert(nfree_extmem > 0);
f010146b:	85 f6                	test   %esi,%esi
f010146d:	7e 3c                	jle    f01014ab <check_page_free_list+0x2da>
	cprintf("check_page_free_list() succeeded!\n");
f010146f:	83 ec 0c             	sub    $0xc,%esp
f0101472:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101475:	8d 83 14 8a f7 ff    	lea    -0x875ec(%ebx),%eax
f010147b:	50                   	push   %eax
f010147c:	e8 ce 28 00 00       	call   f0103d4f <cprintf>
}
f0101481:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101484:	5b                   	pop    %ebx
f0101485:	5e                   	pop    %esi
f0101486:	5f                   	pop    %edi
f0101487:	5d                   	pop    %ebp
f0101488:	c3                   	ret    
	assert(nfree_basemem > 0);
f0101489:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010148c:	8d 83 53 91 f7 ff    	lea    -0x86ead(%ebx),%eax
f0101492:	50                   	push   %eax
f0101493:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101499:	50                   	push   %eax
f010149a:	68 a3 02 00 00       	push   $0x2a3
f010149f:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01014a5:	50                   	push   %eax
f01014a6:	e8 06 ec ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f01014ab:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01014ae:	8d 83 65 91 f7 ff    	lea    -0x86e9b(%ebx),%eax
f01014b4:	50                   	push   %eax
f01014b5:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01014bb:	50                   	push   %eax
f01014bc:	68 a4 02 00 00       	push   $0x2a4
f01014c1:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01014c7:	50                   	push   %eax
f01014c8:	e8 e4 eb ff ff       	call   f01000b1 <_panic>
	if (!page_free_list)
f01014cd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01014d0:	8b 80 28 22 00 00    	mov    0x2228(%eax),%eax
f01014d6:	85 c0                	test   %eax,%eax
f01014d8:	0f 84 2a fd ff ff    	je     f0101208 <check_page_free_list+0x37>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01014de:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01014e1:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01014e4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01014e7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f01014ea:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01014ed:	c7 c3 30 00 19 f0    	mov    $0xf0190030,%ebx
f01014f3:	89 c2                	mov    %eax,%edx
f01014f5:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01014f7:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01014fd:	0f 95 c2             	setne  %dl
f0101500:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101503:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101507:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0101509:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010150d:	8b 00                	mov    (%eax),%eax
f010150f:	85 c0                	test   %eax,%eax
f0101511:	75 e0                	jne    f01014f3 <check_page_free_list+0x322>
		*tp[1] = 0;
f0101513:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101516:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010151c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010151f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101522:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101524:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101527:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010152a:	89 87 28 22 00 00    	mov    %eax,0x2228(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101530:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101537:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010153a:	8b b0 28 22 00 00    	mov    0x2228(%eax),%esi
f0101540:	c7 c7 30 00 19 f0    	mov    $0xf0190030,%edi
	if (PGNUM(pa) >= npages)
f0101546:	c7 c0 28 00 19 f0    	mov    $0xf0190028,%eax
f010154c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010154f:	e9 ed fc ff ff       	jmp    f0101241 <check_page_free_list+0x70>

f0101554 <page_init>:
{
f0101554:	55                   	push   %ebp
f0101555:	89 e5                	mov    %esp,%ebp
f0101557:	57                   	push   %edi
f0101558:	56                   	push   %esi
f0101559:	53                   	push   %ebx
f010155a:	83 ec 1c             	sub    $0x1c,%esp
f010155d:	e8 53 22 00 00       	call   f01037b5 <__x86.get_pc_thunk.si>
f0101562:	81 c6 d2 bb 08 00    	add    $0x8bbd2,%esi
f0101568:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	npages_basemem = nvram_read(NVRAM_BASELO) / (PGSIZE / 1024);
f010156b:	b8 15 00 00 00       	mov    $0x15,%eax
f0101570:	e8 21 fb ff ff       	call   f0101096 <nvram_read>
f0101575:	8d 50 03             	lea    0x3(%eax),%edx
f0101578:	85 c0                	test   %eax,%eax
f010157a:	0f 48 c2             	cmovs  %edx,%eax
f010157d:	c1 f8 02             	sar    $0x2,%eax
f0101580:	89 45 e0             	mov    %eax,-0x20(%ebp)
	ext_allocated = ((size_t)boot_alloc(0) - KERNBASE) / PGSIZE;
f0101583:	b8 00 00 00 00       	mov    $0x0,%eax
f0101588:	e8 3f fb ff ff       	call   f01010cc <boot_alloc>
f010158d:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0101593:	c1 ef 0c             	shr    $0xc,%edi
	pages[0].pp_ref = 1;
f0101596:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f010159c:	8b 00                	mov    (%eax),%eax
f010159e:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
f01015a4:	8b 9e 28 22 00 00    	mov    0x2228(%esi),%ebx
	for (i = 1; i < npages_basemem; i++)
f01015aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01015af:	ba 01 00 00 00       	mov    $0x1,%edx
		pages[i].pp_ref = 0;
f01015b4:	c7 c6 30 00 19 f0    	mov    $0xf0190030,%esi
f01015ba:	89 7d dc             	mov    %edi,-0x24(%ebp)
f01015bd:	8b 7d e0             	mov    -0x20(%ebp),%edi
	for (i = 1; i < npages_basemem; i++)
f01015c0:	eb 1f                	jmp    f01015e1 <page_init+0x8d>
		pages[i].pp_ref = 0;
f01015c2:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f01015c9:	89 c1                	mov    %eax,%ecx
f01015cb:	03 0e                	add    (%esi),%ecx
f01015cd:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01015d3:	89 19                	mov    %ebx,(%ecx)
	for (i = 1; i < npages_basemem; i++)
f01015d5:	83 c2 01             	add    $0x1,%edx
		page_free_list = &pages[i];
f01015d8:	03 06                	add    (%esi),%eax
f01015da:	89 c3                	mov    %eax,%ebx
f01015dc:	b8 01 00 00 00       	mov    $0x1,%eax
	for (i = 1; i < npages_basemem; i++)
f01015e1:	39 fa                	cmp    %edi,%edx
f01015e3:	72 dd                	jb     f01015c2 <page_init+0x6e>
f01015e5:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01015e8:	84 c0                	test   %al,%al
f01015ea:	75 12                	jne    f01015fe <page_init+0xaa>
		pages[i].pp_ref = 1;
f01015ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01015ef:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f01015f5:	8b 08                	mov    (%eax),%ecx
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE + ext_allocated; i++)
f01015f7:	ba a0 00 00 00       	mov    $0xa0,%edx
f01015fc:	eb 15                	jmp    f0101613 <page_init+0xbf>
f01015fe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101601:	89 98 28 22 00 00    	mov    %ebx,0x2228(%eax)
f0101607:	eb e3                	jmp    f01015ec <page_init+0x98>
		pages[i].pp_ref = 1;
f0101609:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
	for (i = IOPHYSMEM / PGSIZE; i < EXTPHYSMEM / PGSIZE + ext_allocated; i++)
f0101610:	83 c2 01             	add    $0x1,%edx
f0101613:	8d 87 00 01 00 00    	lea    0x100(%edi),%eax
f0101619:	39 d0                	cmp    %edx,%eax
f010161b:	77 ec                	ja     f0101609 <page_init+0xb5>
f010161d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101620:	8b 9e 28 22 00 00    	mov    0x2228(%esi),%ebx
f0101626:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010162d:	b9 00 00 00 00       	mov    $0x0,%ecx
	for (i = EXTPHYSMEM / PGSIZE + ext_allocated; i < npages; i++)
f0101632:	c7 c7 28 00 19 f0    	mov    $0xf0190028,%edi
		pages[i].pp_ref = 0;
f0101638:	c7 c6 30 00 19 f0    	mov    $0xf0190030,%esi
f010163e:	eb 1b                	jmp    f010165b <page_init+0x107>
f0101640:	89 d1                	mov    %edx,%ecx
f0101642:	03 0e                	add    (%esi),%ecx
f0101644:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010164a:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f010164c:	89 d3                	mov    %edx,%ebx
f010164e:	03 1e                	add    (%esi),%ebx
	for (i = EXTPHYSMEM / PGSIZE + ext_allocated; i < npages; i++)
f0101650:	83 c0 01             	add    $0x1,%eax
f0101653:	83 c2 08             	add    $0x8,%edx
f0101656:	b9 01 00 00 00       	mov    $0x1,%ecx
f010165b:	39 07                	cmp    %eax,(%edi)
f010165d:	77 e1                	ja     f0101640 <page_init+0xec>
f010165f:	84 c9                	test   %cl,%cl
f0101661:	75 08                	jne    f010166b <page_init+0x117>
}
f0101663:	83 c4 1c             	add    $0x1c,%esp
f0101666:	5b                   	pop    %ebx
f0101667:	5e                   	pop    %esi
f0101668:	5f                   	pop    %edi
f0101669:	5d                   	pop    %ebp
f010166a:	c3                   	ret    
f010166b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010166e:	89 98 28 22 00 00    	mov    %ebx,0x2228(%eax)
f0101674:	eb ed                	jmp    f0101663 <page_init+0x10f>

f0101676 <page_alloc>:
{
f0101676:	55                   	push   %ebp
f0101677:	89 e5                	mov    %esp,%ebp
f0101679:	56                   	push   %esi
f010167a:	53                   	push   %ebx
f010167b:	e8 e7 ea ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0101680:	81 c3 b4 ba 08 00    	add    $0x8bab4,%ebx
	if (!page_free_list)
f0101686:	8b b3 28 22 00 00    	mov    0x2228(%ebx),%esi
f010168c:	85 f6                	test   %esi,%esi
f010168e:	74 14                	je     f01016a4 <page_alloc+0x2e>
	page_free_list = page_free_list->pp_link;
f0101690:	8b 06                	mov    (%esi),%eax
f0101692:	89 83 28 22 00 00    	mov    %eax,0x2228(%ebx)
	page->pp_link = NULL;
f0101698:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (alloc_flags & ALLOC_ZERO)
f010169e:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01016a2:	75 09                	jne    f01016ad <page_alloc+0x37>
}
f01016a4:	89 f0                	mov    %esi,%eax
f01016a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01016a9:	5b                   	pop    %ebx
f01016aa:	5e                   	pop    %esi
f01016ab:	5d                   	pop    %ebp
f01016ac:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f01016ad:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f01016b3:	89 f2                	mov    %esi,%edx
f01016b5:	2b 10                	sub    (%eax),%edx
f01016b7:	89 d0                	mov    %edx,%eax
f01016b9:	c1 f8 03             	sar    $0x3,%eax
f01016bc:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01016bf:	89 c1                	mov    %eax,%ecx
f01016c1:	c1 e9 0c             	shr    $0xc,%ecx
f01016c4:	c7 c2 28 00 19 f0    	mov    $0xf0190028,%edx
f01016ca:	3b 0a                	cmp    (%edx),%ecx
f01016cc:	73 1a                	jae    f01016e8 <page_alloc+0x72>
		memset(page2kva(page), 0, PGSIZE);
f01016ce:	83 ec 04             	sub    $0x4,%esp
f01016d1:	68 00 10 00 00       	push   $0x1000
f01016d6:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01016d8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016dd:	50                   	push   %eax
f01016de:	e8 5d 37 00 00       	call   f0104e40 <memset>
f01016e3:	83 c4 10             	add    $0x10,%esp
f01016e6:	eb bc                	jmp    f01016a4 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016e8:	50                   	push   %eax
f01016e9:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f01016ef:	50                   	push   %eax
f01016f0:	6a 56                	push   $0x56
f01016f2:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f01016f8:	50                   	push   %eax
f01016f9:	e8 b3 e9 ff ff       	call   f01000b1 <_panic>

f01016fe <page_free>:
{
f01016fe:	55                   	push   %ebp
f01016ff:	89 e5                	mov    %esp,%ebp
f0101701:	53                   	push   %ebx
f0101702:	83 ec 04             	sub    $0x4,%esp
f0101705:	e8 5d ea ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010170a:	81 c3 2a ba 08 00    	add    $0x8ba2a,%ebx
f0101710:	8b 45 08             	mov    0x8(%ebp),%eax
	assert(pp->pp_ref == 0);
f0101713:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101718:	75 18                	jne    f0101732 <page_free+0x34>
	assert(!pp->pp_link);
f010171a:	83 38 00             	cmpl   $0x0,(%eax)
f010171d:	75 32                	jne    f0101751 <page_free+0x53>
	pp->pp_link = page_free_list;
f010171f:	8b 8b 28 22 00 00    	mov    0x2228(%ebx),%ecx
f0101725:	89 08                	mov    %ecx,(%eax)
	page_free_list = pp;
f0101727:	89 83 28 22 00 00    	mov    %eax,0x2228(%ebx)
}
f010172d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101730:	c9                   	leave  
f0101731:	c3                   	ret    
	assert(pp->pp_ref == 0);
f0101732:	8d 83 76 91 f7 ff    	lea    -0x86e8a(%ebx),%eax
f0101738:	50                   	push   %eax
f0101739:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f010173f:	50                   	push   %eax
f0101740:	68 64 01 00 00       	push   $0x164
f0101745:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010174b:	50                   	push   %eax
f010174c:	e8 60 e9 ff ff       	call   f01000b1 <_panic>
	assert(!pp->pp_link);
f0101751:	8d 83 86 91 f7 ff    	lea    -0x86e7a(%ebx),%eax
f0101757:	50                   	push   %eax
f0101758:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f010175e:	50                   	push   %eax
f010175f:	68 65 01 00 00       	push   $0x165
f0101764:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010176a:	50                   	push   %eax
f010176b:	e8 41 e9 ff ff       	call   f01000b1 <_panic>

f0101770 <page_decref>:
{
f0101770:	55                   	push   %ebp
f0101771:	89 e5                	mov    %esp,%ebp
f0101773:	83 ec 08             	sub    $0x8,%esp
f0101776:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101779:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010177d:	83 e8 01             	sub    $0x1,%eax
f0101780:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101784:	66 85 c0             	test   %ax,%ax
f0101787:	74 02                	je     f010178b <page_decref+0x1b>
}
f0101789:	c9                   	leave  
f010178a:	c3                   	ret    
		page_free(pp);
f010178b:	83 ec 0c             	sub    $0xc,%esp
f010178e:	52                   	push   %edx
f010178f:	e8 6a ff ff ff       	call   f01016fe <page_free>
f0101794:	83 c4 10             	add    $0x10,%esp
}
f0101797:	eb f0                	jmp    f0101789 <page_decref+0x19>

f0101799 <pgdir_walk>:
{
f0101799:	55                   	push   %ebp
f010179a:	89 e5                	mov    %esp,%ebp
f010179c:	57                   	push   %edi
f010179d:	56                   	push   %esi
f010179e:	53                   	push   %ebx
f010179f:	83 ec 0c             	sub    $0xc,%esp
f01017a2:	e8 c0 e9 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01017a7:	81 c3 8d b9 08 00    	add    $0x8b98d,%ebx
f01017ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
	pde = &pgdir[PDX(va)];
f01017b0:	89 fe                	mov    %edi,%esi
f01017b2:	c1 ee 16             	shr    $0x16,%esi
f01017b5:	c1 e6 02             	shl    $0x2,%esi
f01017b8:	03 75 08             	add    0x8(%ebp),%esi
	if (!(*pde & PTE_P))
f01017bb:	f6 06 01             	testb  $0x1,(%esi)
f01017be:	75 2f                	jne    f01017ef <pgdir_walk+0x56>
		if (create)
f01017c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01017c4:	74 70                	je     f0101836 <pgdir_walk+0x9d>
			page = page_alloc(1);
f01017c6:	83 ec 0c             	sub    $0xc,%esp
f01017c9:	6a 01                	push   $0x1
f01017cb:	e8 a6 fe ff ff       	call   f0101676 <page_alloc>
			if (!page)
f01017d0:	83 c4 10             	add    $0x10,%esp
f01017d3:	85 c0                	test   %eax,%eax
f01017d5:	74 66                	je     f010183d <pgdir_walk+0xa4>
			page->pp_ref++;
f01017d7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01017dc:	c7 c2 30 00 19 f0    	mov    $0xf0190030,%edx
f01017e2:	2b 02                	sub    (%edx),%eax
f01017e4:	c1 f8 03             	sar    $0x3,%eax
f01017e7:	c1 e0 0c             	shl    $0xc,%eax
			*pde = page2pa(page) | PTE_P | PTE_U | PTE_W;
f01017ea:	83 c8 07             	or     $0x7,%eax
f01017ed:	89 06                	mov    %eax,(%esi)
	page_base = KADDR(PTE_ADDR(*pde));
f01017ef:	8b 06                	mov    (%esi),%eax
f01017f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01017f6:	89 c1                	mov    %eax,%ecx
f01017f8:	c1 e9 0c             	shr    $0xc,%ecx
f01017fb:	c7 c2 28 00 19 f0    	mov    $0xf0190028,%edx
f0101801:	3b 0a                	cmp    (%edx),%ecx
f0101803:	73 18                	jae    f010181d <pgdir_walk+0x84>
	page_off = PTX(va);
f0101805:	c1 ef 0a             	shr    $0xa,%edi
	return &page_base[page_off];
f0101808:	81 e7 fc 0f 00 00    	and    $0xffc,%edi
f010180e:	8d 84 38 00 00 00 f0 	lea    -0x10000000(%eax,%edi,1),%eax
}
f0101815:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101818:	5b                   	pop    %ebx
f0101819:	5e                   	pop    %esi
f010181a:	5f                   	pop    %edi
f010181b:	5d                   	pop    %ebp
f010181c:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010181d:	50                   	push   %eax
f010181e:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0101824:	50                   	push   %eax
f0101825:	68 a6 01 00 00       	push   $0x1a6
f010182a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101830:	50                   	push   %eax
f0101831:	e8 7b e8 ff ff       	call   f01000b1 <_panic>
			return NULL;
f0101836:	b8 00 00 00 00       	mov    $0x0,%eax
f010183b:	eb d8                	jmp    f0101815 <pgdir_walk+0x7c>
				return NULL;
f010183d:	b8 00 00 00 00       	mov    $0x0,%eax
f0101842:	eb d1                	jmp    f0101815 <pgdir_walk+0x7c>

f0101844 <boot_map_region>:
{
f0101844:	55                   	push   %ebp
f0101845:	89 e5                	mov    %esp,%ebp
f0101847:	57                   	push   %edi
f0101848:	56                   	push   %esi
f0101849:	53                   	push   %ebx
f010184a:	83 ec 1c             	sub    $0x1c,%esp
f010184d:	89 c7                	mov    %eax,%edi
f010184f:	89 d6                	mov    %edx,%esi
f0101851:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (i = 0; i < size; i += PGSIZE)
f0101854:	bb 00 00 00 00       	mov    $0x0,%ebx
		*pte = (pa + i) | perm | PTE_P;
f0101859:	8b 45 0c             	mov    0xc(%ebp),%eax
f010185c:	83 c8 01             	or     $0x1,%eax
f010185f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (i = 0; i < size; i += PGSIZE)
f0101862:	eb 22                	jmp    f0101886 <boot_map_region+0x42>
		pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f0101864:	83 ec 04             	sub    $0x4,%esp
f0101867:	6a 01                	push   $0x1
f0101869:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f010186c:	50                   	push   %eax
f010186d:	57                   	push   %edi
f010186e:	e8 26 ff ff ff       	call   f0101799 <pgdir_walk>
		*pte = (pa + i) | perm | PTE_P;
f0101873:	89 da                	mov    %ebx,%edx
f0101875:	03 55 08             	add    0x8(%ebp),%edx
f0101878:	0b 55 e0             	or     -0x20(%ebp),%edx
f010187b:	89 10                	mov    %edx,(%eax)
	for (i = 0; i < size; i += PGSIZE)
f010187d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101883:	83 c4 10             	add    $0x10,%esp
f0101886:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101889:	72 d9                	jb     f0101864 <boot_map_region+0x20>
}
f010188b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010188e:	5b                   	pop    %ebx
f010188f:	5e                   	pop    %esi
f0101890:	5f                   	pop    %edi
f0101891:	5d                   	pop    %ebp
f0101892:	c3                   	ret    

f0101893 <page_lookup>:
{
f0101893:	55                   	push   %ebp
f0101894:	89 e5                	mov    %esp,%ebp
f0101896:	56                   	push   %esi
f0101897:	53                   	push   %ebx
f0101898:	e8 ca e8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010189d:	81 c3 97 b8 08 00    	add    $0x8b897,%ebx
f01018a3:	8b 75 10             	mov    0x10(%ebp),%esi
	pte = pgdir_walk(pgdir, va, 0);
f01018a6:	83 ec 04             	sub    $0x4,%esp
f01018a9:	6a 00                	push   $0x0
f01018ab:	ff 75 0c             	pushl  0xc(%ebp)
f01018ae:	ff 75 08             	pushl  0x8(%ebp)
f01018b1:	e8 e3 fe ff ff       	call   f0101799 <pgdir_walk>
	if (!pte)
f01018b6:	83 c4 10             	add    $0x10,%esp
f01018b9:	85 c0                	test   %eax,%eax
f01018bb:	74 3f                	je     f01018fc <page_lookup+0x69>
	if (pte_store)
f01018bd:	85 f6                	test   %esi,%esi
f01018bf:	74 02                	je     f01018c3 <page_lookup+0x30>
		*pte_store = pte;
f01018c1:	89 06                	mov    %eax,(%esi)
f01018c3:	8b 00                	mov    (%eax),%eax
f01018c5:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018c8:	c7 c2 28 00 19 f0    	mov    $0xf0190028,%edx
f01018ce:	39 02                	cmp    %eax,(%edx)
f01018d0:	76 12                	jbe    f01018e4 <page_lookup+0x51>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01018d2:	c7 c2 30 00 19 f0    	mov    $0xf0190030,%edx
f01018d8:	8b 12                	mov    (%edx),%edx
f01018da:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01018dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01018e0:	5b                   	pop    %ebx
f01018e1:	5e                   	pop    %esi
f01018e2:	5d                   	pop    %ebp
f01018e3:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01018e4:	83 ec 04             	sub    $0x4,%esp
f01018e7:	8d 83 38 8a f7 ff    	lea    -0x875c8(%ebx),%eax
f01018ed:	50                   	push   %eax
f01018ee:	6a 4f                	push   $0x4f
f01018f0:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f01018f6:	50                   	push   %eax
f01018f7:	e8 b5 e7 ff ff       	call   f01000b1 <_panic>
		return NULL;
f01018fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0101901:	eb da                	jmp    f01018dd <page_lookup+0x4a>

f0101903 <page_remove>:
{
f0101903:	55                   	push   %ebp
f0101904:	89 e5                	mov    %esp,%ebp
f0101906:	53                   	push   %ebx
f0101907:	83 ec 18             	sub    $0x18,%esp
f010190a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte = NULL;
f010190d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	page = page_lookup(pgdir, va, &pte);
f0101914:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101917:	50                   	push   %eax
f0101918:	53                   	push   %ebx
f0101919:	ff 75 08             	pushl  0x8(%ebp)
f010191c:	e8 72 ff ff ff       	call   f0101893 <page_lookup>
	if (!page)
f0101921:	83 c4 10             	add    $0x10,%esp
f0101924:	85 c0                	test   %eax,%eax
f0101926:	74 15                	je     f010193d <page_remove+0x3a>
	page_decref(page);
f0101928:	83 ec 0c             	sub    $0xc,%esp
f010192b:	50                   	push   %eax
f010192c:	e8 3f fe ff ff       	call   f0101770 <page_decref>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101931:	0f 01 3b             	invlpg (%ebx)
	(*pte) &= perm;
f0101934:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101937:	83 20 fe             	andl   $0xfffffffe,(%eax)
	return;
f010193a:	83 c4 10             	add    $0x10,%esp
}
f010193d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101940:	c9                   	leave  
f0101941:	c3                   	ret    

f0101942 <page_insert>:
{
f0101942:	55                   	push   %ebp
f0101943:	89 e5                	mov    %esp,%ebp
f0101945:	57                   	push   %edi
f0101946:	56                   	push   %esi
f0101947:	53                   	push   %ebx
f0101948:	83 ec 10             	sub    $0x10,%esp
f010194b:	e8 69 1e 00 00       	call   f01037b9 <__x86.get_pc_thunk.di>
f0101950:	81 c7 e4 b7 08 00    	add    $0x8b7e4,%edi
f0101956:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte = pgdir_walk(pgdir, va, 1);
f0101959:	6a 01                	push   $0x1
f010195b:	ff 75 10             	pushl  0x10(%ebp)
f010195e:	ff 75 08             	pushl  0x8(%ebp)
f0101961:	e8 33 fe ff ff       	call   f0101799 <pgdir_walk>
	if (!pte)
f0101966:	83 c4 10             	add    $0x10,%esp
f0101969:	85 c0                	test   %eax,%eax
f010196b:	74 46                	je     f01019b3 <page_insert+0x71>
f010196d:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f010196f:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if ((*pte) & PTE_P)
f0101974:	f6 00 01             	testb  $0x1,(%eax)
f0101977:	75 27                	jne    f01019a0 <page_insert+0x5e>
	return (pp - pages) << PGSHIFT;
f0101979:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f010197f:	2b 30                	sub    (%eax),%esi
f0101981:	89 f0                	mov    %esi,%eax
f0101983:	c1 f8 03             	sar    $0x3,%eax
f0101986:	c1 e0 0c             	shl    $0xc,%eax
	*pte = page2pa(pp) | perm | PTE_P;
f0101989:	8b 55 14             	mov    0x14(%ebp),%edx
f010198c:	83 ca 01             	or     $0x1,%edx
f010198f:	09 d0                	or     %edx,%eax
f0101991:	89 03                	mov    %eax,(%ebx)
	return 0;
f0101993:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101998:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010199b:	5b                   	pop    %ebx
f010199c:	5e                   	pop    %esi
f010199d:	5f                   	pop    %edi
f010199e:	5d                   	pop    %ebp
f010199f:	c3                   	ret    
		page_remove(pgdir, va);
f01019a0:	83 ec 08             	sub    $0x8,%esp
f01019a3:	ff 75 10             	pushl  0x10(%ebp)
f01019a6:	ff 75 08             	pushl  0x8(%ebp)
f01019a9:	e8 55 ff ff ff       	call   f0101903 <page_remove>
f01019ae:	83 c4 10             	add    $0x10,%esp
f01019b1:	eb c6                	jmp    f0101979 <page_insert+0x37>
		return -E_NO_MEM;
f01019b3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01019b8:	eb de                	jmp    f0101998 <page_insert+0x56>

f01019ba <mem_init>:
{
f01019ba:	55                   	push   %ebp
f01019bb:	89 e5                	mov    %esp,%ebp
f01019bd:	57                   	push   %edi
f01019be:	56                   	push   %esi
f01019bf:	53                   	push   %ebx
f01019c0:	83 ec 3c             	sub    $0x3c,%esp
f01019c3:	e8 41 ed ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f01019c8:	05 6c b7 08 00       	add    $0x8b76c,%eax
f01019cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f01019d0:	b8 15 00 00 00       	mov    $0x15,%eax
f01019d5:	e8 bc f6 ff ff       	call   f0101096 <nvram_read>
f01019da:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01019dc:	b8 17 00 00 00       	mov    $0x17,%eax
f01019e1:	e8 b0 f6 ff ff       	call   f0101096 <nvram_read>
f01019e6:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01019e8:	b8 34 00 00 00       	mov    $0x34,%eax
f01019ed:	e8 a4 f6 ff ff       	call   f0101096 <nvram_read>
f01019f2:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f01019f5:	85 c0                	test   %eax,%eax
f01019f7:	0f 85 d8 00 00 00    	jne    f0101ad5 <mem_init+0x11b>
		totalmem = 1 * 1024 + extmem;
f01019fd:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101a03:	85 f6                	test   %esi,%esi
f0101a05:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101a08:	89 c1                	mov    %eax,%ecx
f0101a0a:	c1 e9 02             	shr    $0x2,%ecx
f0101a0d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101a10:	c7 c2 28 00 19 f0    	mov    $0xf0190028,%edx
f0101a16:	89 0a                	mov    %ecx,(%edx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101a18:	89 c2                	mov    %eax,%edx
f0101a1a:	29 da                	sub    %ebx,%edx
f0101a1c:	52                   	push   %edx
f0101a1d:	53                   	push   %ebx
f0101a1e:	50                   	push   %eax
f0101a1f:	8d 87 58 8a f7 ff    	lea    -0x875a8(%edi),%eax
f0101a25:	50                   	push   %eax
f0101a26:	89 fb                	mov    %edi,%ebx
f0101a28:	e8 22 23 00 00       	call   f0103d4f <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101a2d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101a32:	e8 95 f6 ff ff       	call   f01010cc <boot_alloc>
f0101a37:	c7 c6 2c 00 19 f0    	mov    $0xf019002c,%esi
f0101a3d:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f0101a3f:	83 c4 0c             	add    $0xc,%esp
f0101a42:	68 00 10 00 00       	push   $0x1000
f0101a47:	6a 00                	push   $0x0
f0101a49:	50                   	push   %eax
f0101a4a:	e8 f1 33 00 00       	call   f0104e40 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101a4f:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101a51:	83 c4 10             	add    $0x10,%esp
f0101a54:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101a59:	0f 86 80 00 00 00    	jbe    f0101adf <mem_init+0x125>
	return (physaddr_t)kva - KERNBASE;
f0101a5f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101a65:	83 ca 05             	or     $0x5,%edx
f0101a68:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101a6e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101a71:	c7 c3 28 00 19 f0    	mov    $0xf0190028,%ebx
f0101a77:	8b 03                	mov    (%ebx),%eax
f0101a79:	c1 e0 03             	shl    $0x3,%eax
f0101a7c:	e8 4b f6 ff ff       	call   f01010cc <boot_alloc>
f0101a81:	c7 c6 30 00 19 f0    	mov    $0xf0190030,%esi
f0101a87:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101a89:	83 ec 04             	sub    $0x4,%esp
f0101a8c:	8b 13                	mov    (%ebx),%edx
f0101a8e:	c1 e2 03             	shl    $0x3,%edx
f0101a91:	52                   	push   %edx
f0101a92:	6a 00                	push   $0x0
f0101a94:	50                   	push   %eax
f0101a95:	89 fb                	mov    %edi,%ebx
f0101a97:	e8 a4 33 00 00       	call   f0104e40 <memset>
	envs = boot_alloc(NENV * sizeof(struct Env));
f0101a9c:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101aa1:	e8 26 f6 ff ff       	call   f01010cc <boot_alloc>
f0101aa6:	c7 c2 64 f3 18 f0    	mov    $0xf018f364,%edx
f0101aac:	89 02                	mov    %eax,(%edx)
	page_init();
f0101aae:	e8 a1 fa ff ff       	call   f0101554 <page_init>
	check_page_free_list(1);
f0101ab3:	b8 01 00 00 00       	mov    $0x1,%eax
f0101ab8:	e8 14 f7 ff ff       	call   f01011d1 <check_page_free_list>
	if (!pages)
f0101abd:	83 c4 10             	add    $0x10,%esp
f0101ac0:	83 3e 00             	cmpl   $0x0,(%esi)
f0101ac3:	74 36                	je     f0101afb <mem_init+0x141>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101ac5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ac8:	8b 80 28 22 00 00    	mov    0x2228(%eax),%eax
f0101ace:	be 00 00 00 00       	mov    $0x0,%esi
f0101ad3:	eb 49                	jmp    f0101b1e <mem_init+0x164>
		totalmem = 16 * 1024 + ext16mem;
f0101ad5:	05 00 40 00 00       	add    $0x4000,%eax
f0101ada:	e9 29 ff ff ff       	jmp    f0101a08 <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101adf:	50                   	push   %eax
f0101ae0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ae3:	8d 83 94 8a f7 ff    	lea    -0x8756c(%ebx),%eax
f0101ae9:	50                   	push   %eax
f0101aea:	68 91 00 00 00       	push   $0x91
f0101aef:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101af5:	50                   	push   %eax
f0101af6:	e8 b6 e5 ff ff       	call   f01000b1 <_panic>
		panic("'pages' is a null pointer!");
f0101afb:	83 ec 04             	sub    $0x4,%esp
f0101afe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b01:	8d 83 93 91 f7 ff    	lea    -0x86e6d(%ebx),%eax
f0101b07:	50                   	push   %eax
f0101b08:	68 b7 02 00 00       	push   $0x2b7
f0101b0d:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101b13:	50                   	push   %eax
f0101b14:	e8 98 e5 ff ff       	call   f01000b1 <_panic>
		++nfree;
f0101b19:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101b1c:	8b 00                	mov    (%eax),%eax
f0101b1e:	85 c0                	test   %eax,%eax
f0101b20:	75 f7                	jne    f0101b19 <mem_init+0x15f>
	assert((pp0 = page_alloc(0)));
f0101b22:	83 ec 0c             	sub    $0xc,%esp
f0101b25:	6a 00                	push   $0x0
f0101b27:	e8 4a fb ff ff       	call   f0101676 <page_alloc>
f0101b2c:	89 c3                	mov    %eax,%ebx
f0101b2e:	83 c4 10             	add    $0x10,%esp
f0101b31:	85 c0                	test   %eax,%eax
f0101b33:	0f 84 3b 02 00 00    	je     f0101d74 <mem_init+0x3ba>
	assert((pp1 = page_alloc(0)));
f0101b39:	83 ec 0c             	sub    $0xc,%esp
f0101b3c:	6a 00                	push   $0x0
f0101b3e:	e8 33 fb ff ff       	call   f0101676 <page_alloc>
f0101b43:	89 c7                	mov    %eax,%edi
f0101b45:	83 c4 10             	add    $0x10,%esp
f0101b48:	85 c0                	test   %eax,%eax
f0101b4a:	0f 84 46 02 00 00    	je     f0101d96 <mem_init+0x3dc>
	assert((pp2 = page_alloc(0)));
f0101b50:	83 ec 0c             	sub    $0xc,%esp
f0101b53:	6a 00                	push   $0x0
f0101b55:	e8 1c fb ff ff       	call   f0101676 <page_alloc>
f0101b5a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101b5d:	83 c4 10             	add    $0x10,%esp
f0101b60:	85 c0                	test   %eax,%eax
f0101b62:	0f 84 50 02 00 00    	je     f0101db8 <mem_init+0x3fe>
	assert(pp1 && pp1 != pp0);
f0101b68:	39 fb                	cmp    %edi,%ebx
f0101b6a:	0f 84 6a 02 00 00    	je     f0101dda <mem_init+0x420>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b70:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b73:	39 c3                	cmp    %eax,%ebx
f0101b75:	0f 84 81 02 00 00    	je     f0101dfc <mem_init+0x442>
f0101b7b:	39 c7                	cmp    %eax,%edi
f0101b7d:	0f 84 79 02 00 00    	je     f0101dfc <mem_init+0x442>
	return (pp - pages) << PGSHIFT;
f0101b83:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101b86:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0101b8c:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101b8e:	c7 c0 28 00 19 f0    	mov    $0xf0190028,%eax
f0101b94:	8b 10                	mov    (%eax),%edx
f0101b96:	c1 e2 0c             	shl    $0xc,%edx
f0101b99:	89 d8                	mov    %ebx,%eax
f0101b9b:	29 c8                	sub    %ecx,%eax
f0101b9d:	c1 f8 03             	sar    $0x3,%eax
f0101ba0:	c1 e0 0c             	shl    $0xc,%eax
f0101ba3:	39 d0                	cmp    %edx,%eax
f0101ba5:	0f 83 73 02 00 00    	jae    f0101e1e <mem_init+0x464>
f0101bab:	89 f8                	mov    %edi,%eax
f0101bad:	29 c8                	sub    %ecx,%eax
f0101baf:	c1 f8 03             	sar    $0x3,%eax
f0101bb2:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f0101bb5:	39 c2                	cmp    %eax,%edx
f0101bb7:	0f 86 83 02 00 00    	jbe    f0101e40 <mem_init+0x486>
f0101bbd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101bc0:	29 c8                	sub    %ecx,%eax
f0101bc2:	c1 f8 03             	sar    $0x3,%eax
f0101bc5:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101bc8:	39 c2                	cmp    %eax,%edx
f0101bca:	0f 86 92 02 00 00    	jbe    f0101e62 <mem_init+0x4a8>
	fl = page_free_list;
f0101bd0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bd3:	8b 88 28 22 00 00    	mov    0x2228(%eax),%ecx
f0101bd9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101bdc:	c7 80 28 22 00 00 00 	movl   $0x0,0x2228(%eax)
f0101be3:	00 00 00 
	assert(!page_alloc(0));
f0101be6:	83 ec 0c             	sub    $0xc,%esp
f0101be9:	6a 00                	push   $0x0
f0101beb:	e8 86 fa ff ff       	call   f0101676 <page_alloc>
f0101bf0:	83 c4 10             	add    $0x10,%esp
f0101bf3:	85 c0                	test   %eax,%eax
f0101bf5:	0f 85 89 02 00 00    	jne    f0101e84 <mem_init+0x4ca>
	page_free(pp0);
f0101bfb:	83 ec 0c             	sub    $0xc,%esp
f0101bfe:	53                   	push   %ebx
f0101bff:	e8 fa fa ff ff       	call   f01016fe <page_free>
	page_free(pp1);
f0101c04:	89 3c 24             	mov    %edi,(%esp)
f0101c07:	e8 f2 fa ff ff       	call   f01016fe <page_free>
	page_free(pp2);
f0101c0c:	83 c4 04             	add    $0x4,%esp
f0101c0f:	ff 75 d0             	pushl  -0x30(%ebp)
f0101c12:	e8 e7 fa ff ff       	call   f01016fe <page_free>
	assert((pp0 = page_alloc(0)));
f0101c17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c1e:	e8 53 fa ff ff       	call   f0101676 <page_alloc>
f0101c23:	89 c7                	mov    %eax,%edi
f0101c25:	83 c4 10             	add    $0x10,%esp
f0101c28:	85 c0                	test   %eax,%eax
f0101c2a:	0f 84 76 02 00 00    	je     f0101ea6 <mem_init+0x4ec>
	assert((pp1 = page_alloc(0)));
f0101c30:	83 ec 0c             	sub    $0xc,%esp
f0101c33:	6a 00                	push   $0x0
f0101c35:	e8 3c fa ff ff       	call   f0101676 <page_alloc>
f0101c3a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c3d:	83 c4 10             	add    $0x10,%esp
f0101c40:	85 c0                	test   %eax,%eax
f0101c42:	0f 84 80 02 00 00    	je     f0101ec8 <mem_init+0x50e>
	assert((pp2 = page_alloc(0)));
f0101c48:	83 ec 0c             	sub    $0xc,%esp
f0101c4b:	6a 00                	push   $0x0
f0101c4d:	e8 24 fa ff ff       	call   f0101676 <page_alloc>
f0101c52:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c55:	83 c4 10             	add    $0x10,%esp
f0101c58:	85 c0                	test   %eax,%eax
f0101c5a:	0f 84 8a 02 00 00    	je     f0101eea <mem_init+0x530>
	assert(pp1 && pp1 != pp0);
f0101c60:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f0101c63:	0f 84 a3 02 00 00    	je     f0101f0c <mem_init+0x552>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c69:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101c6c:	39 c7                	cmp    %eax,%edi
f0101c6e:	0f 84 ba 02 00 00    	je     f0101f2e <mem_init+0x574>
f0101c74:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101c77:	0f 84 b1 02 00 00    	je     f0101f2e <mem_init+0x574>
	assert(!page_alloc(0));
f0101c7d:	83 ec 0c             	sub    $0xc,%esp
f0101c80:	6a 00                	push   $0x0
f0101c82:	e8 ef f9 ff ff       	call   f0101676 <page_alloc>
f0101c87:	83 c4 10             	add    $0x10,%esp
f0101c8a:	85 c0                	test   %eax,%eax
f0101c8c:	0f 85 be 02 00 00    	jne    f0101f50 <mem_init+0x596>
f0101c92:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c95:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0101c9b:	89 f9                	mov    %edi,%ecx
f0101c9d:	2b 08                	sub    (%eax),%ecx
f0101c9f:	89 c8                	mov    %ecx,%eax
f0101ca1:	c1 f8 03             	sar    $0x3,%eax
f0101ca4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101ca7:	89 c1                	mov    %eax,%ecx
f0101ca9:	c1 e9 0c             	shr    $0xc,%ecx
f0101cac:	c7 c2 28 00 19 f0    	mov    $0xf0190028,%edx
f0101cb2:	3b 0a                	cmp    (%edx),%ecx
f0101cb4:	0f 83 b8 02 00 00    	jae    f0101f72 <mem_init+0x5b8>
	memset(page2kva(pp0), 1, PGSIZE);
f0101cba:	83 ec 04             	sub    $0x4,%esp
f0101cbd:	68 00 10 00 00       	push   $0x1000
f0101cc2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0101cc4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cc9:	50                   	push   %eax
f0101cca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ccd:	e8 6e 31 00 00       	call   f0104e40 <memset>
	page_free(pp0);
f0101cd2:	89 3c 24             	mov    %edi,(%esp)
f0101cd5:	e8 24 fa ff ff       	call   f01016fe <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101cda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101ce1:	e8 90 f9 ff ff       	call   f0101676 <page_alloc>
f0101ce6:	83 c4 10             	add    $0x10,%esp
f0101ce9:	85 c0                	test   %eax,%eax
f0101ceb:	0f 84 97 02 00 00    	je     f0101f88 <mem_init+0x5ce>
	assert(pp && pp0 == pp);
f0101cf1:	39 c7                	cmp    %eax,%edi
f0101cf3:	0f 85 b1 02 00 00    	jne    f0101faa <mem_init+0x5f0>
	return (pp - pages) << PGSHIFT;
f0101cf9:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101cfc:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0101d02:	89 fa                	mov    %edi,%edx
f0101d04:	2b 10                	sub    (%eax),%edx
f0101d06:	c1 fa 03             	sar    $0x3,%edx
f0101d09:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101d0c:	89 d1                	mov    %edx,%ecx
f0101d0e:	c1 e9 0c             	shr    $0xc,%ecx
f0101d11:	c7 c0 28 00 19 f0    	mov    $0xf0190028,%eax
f0101d17:	3b 08                	cmp    (%eax),%ecx
f0101d19:	0f 83 ad 02 00 00    	jae    f0101fcc <mem_init+0x612>
	return (void *)(pa + KERNBASE);
f0101d1f:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101d25:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101d2b:	80 38 00             	cmpb   $0x0,(%eax)
f0101d2e:	0f 85 ae 02 00 00    	jne    f0101fe2 <mem_init+0x628>
f0101d34:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101d37:	39 d0                	cmp    %edx,%eax
f0101d39:	75 f0                	jne    f0101d2b <mem_init+0x371>
	page_free_list = fl;
f0101d3b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d3e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101d41:	89 8b 28 22 00 00    	mov    %ecx,0x2228(%ebx)
	page_free(pp0);
f0101d47:	83 ec 0c             	sub    $0xc,%esp
f0101d4a:	57                   	push   %edi
f0101d4b:	e8 ae f9 ff ff       	call   f01016fe <page_free>
	page_free(pp1);
f0101d50:	83 c4 04             	add    $0x4,%esp
f0101d53:	ff 75 d0             	pushl  -0x30(%ebp)
f0101d56:	e8 a3 f9 ff ff       	call   f01016fe <page_free>
	page_free(pp2);
f0101d5b:	83 c4 04             	add    $0x4,%esp
f0101d5e:	ff 75 cc             	pushl  -0x34(%ebp)
f0101d61:	e8 98 f9 ff ff       	call   f01016fe <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101d66:	8b 83 28 22 00 00    	mov    0x2228(%ebx),%eax
f0101d6c:	83 c4 10             	add    $0x10,%esp
f0101d6f:	e9 95 02 00 00       	jmp    f0102009 <mem_init+0x64f>
	assert((pp0 = page_alloc(0)));
f0101d74:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d77:	8d 83 ae 91 f7 ff    	lea    -0x86e52(%ebx),%eax
f0101d7d:	50                   	push   %eax
f0101d7e:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101d84:	50                   	push   %eax
f0101d85:	68 bf 02 00 00       	push   $0x2bf
f0101d8a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101d90:	50                   	push   %eax
f0101d91:	e8 1b e3 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d96:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101d99:	8d 83 c4 91 f7 ff    	lea    -0x86e3c(%ebx),%eax
f0101d9f:	50                   	push   %eax
f0101da0:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101da6:	50                   	push   %eax
f0101da7:	68 c0 02 00 00       	push   $0x2c0
f0101dac:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101db2:	50                   	push   %eax
f0101db3:	e8 f9 e2 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101db8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101dbb:	8d 83 da 91 f7 ff    	lea    -0x86e26(%ebx),%eax
f0101dc1:	50                   	push   %eax
f0101dc2:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101dc8:	50                   	push   %eax
f0101dc9:	68 c1 02 00 00       	push   $0x2c1
f0101dce:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101dd4:	50                   	push   %eax
f0101dd5:	e8 d7 e2 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101dda:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ddd:	8d 83 f0 91 f7 ff    	lea    -0x86e10(%ebx),%eax
f0101de3:	50                   	push   %eax
f0101de4:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101dea:	50                   	push   %eax
f0101deb:	68 c4 02 00 00       	push   $0x2c4
f0101df0:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101df6:	50                   	push   %eax
f0101df7:	e8 b5 e2 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101dfc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101dff:	8d 83 b8 8a f7 ff    	lea    -0x87548(%ebx),%eax
f0101e05:	50                   	push   %eax
f0101e06:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101e0c:	50                   	push   %eax
f0101e0d:	68 c5 02 00 00       	push   $0x2c5
f0101e12:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101e18:	50                   	push   %eax
f0101e19:	e8 93 e2 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101e1e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e21:	8d 83 02 92 f7 ff    	lea    -0x86dfe(%ebx),%eax
f0101e27:	50                   	push   %eax
f0101e28:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101e2e:	50                   	push   %eax
f0101e2f:	68 c6 02 00 00       	push   $0x2c6
f0101e34:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101e3a:	50                   	push   %eax
f0101e3b:	e8 71 e2 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101e40:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e43:	8d 83 1f 92 f7 ff    	lea    -0x86de1(%ebx),%eax
f0101e49:	50                   	push   %eax
f0101e4a:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101e50:	50                   	push   %eax
f0101e51:	68 c7 02 00 00       	push   $0x2c7
f0101e56:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101e5c:	50                   	push   %eax
f0101e5d:	e8 4f e2 ff ff       	call   f01000b1 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101e62:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e65:	8d 83 3c 92 f7 ff    	lea    -0x86dc4(%ebx),%eax
f0101e6b:	50                   	push   %eax
f0101e6c:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101e72:	50                   	push   %eax
f0101e73:	68 c8 02 00 00       	push   $0x2c8
f0101e78:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101e7e:	50                   	push   %eax
f0101e7f:	e8 2d e2 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101e84:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e87:	8d 83 59 92 f7 ff    	lea    -0x86da7(%ebx),%eax
f0101e8d:	50                   	push   %eax
f0101e8e:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101e94:	50                   	push   %eax
f0101e95:	68 cf 02 00 00       	push   $0x2cf
f0101e9a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101ea0:	50                   	push   %eax
f0101ea1:	e8 0b e2 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0101ea6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ea9:	8d 83 ae 91 f7 ff    	lea    -0x86e52(%ebx),%eax
f0101eaf:	50                   	push   %eax
f0101eb0:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101eb6:	50                   	push   %eax
f0101eb7:	68 d6 02 00 00       	push   $0x2d6
f0101ebc:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101ec2:	50                   	push   %eax
f0101ec3:	e8 e9 e1 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ec8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ecb:	8d 83 c4 91 f7 ff    	lea    -0x86e3c(%ebx),%eax
f0101ed1:	50                   	push   %eax
f0101ed2:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101ed8:	50                   	push   %eax
f0101ed9:	68 d7 02 00 00       	push   $0x2d7
f0101ede:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101ee4:	50                   	push   %eax
f0101ee5:	e8 c7 e1 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101eea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101eed:	8d 83 da 91 f7 ff    	lea    -0x86e26(%ebx),%eax
f0101ef3:	50                   	push   %eax
f0101ef4:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101efa:	50                   	push   %eax
f0101efb:	68 d8 02 00 00       	push   $0x2d8
f0101f00:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101f06:	50                   	push   %eax
f0101f07:	e8 a5 e1 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f0101f0c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f0f:	8d 83 f0 91 f7 ff    	lea    -0x86e10(%ebx),%eax
f0101f15:	50                   	push   %eax
f0101f16:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101f1c:	50                   	push   %eax
f0101f1d:	68 da 02 00 00       	push   $0x2da
f0101f22:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101f28:	50                   	push   %eax
f0101f29:	e8 83 e1 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101f2e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f31:	8d 83 b8 8a f7 ff    	lea    -0x87548(%ebx),%eax
f0101f37:	50                   	push   %eax
f0101f38:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101f3e:	50                   	push   %eax
f0101f3f:	68 db 02 00 00       	push   $0x2db
f0101f44:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101f4a:	50                   	push   %eax
f0101f4b:	e8 61 e1 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0101f50:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f53:	8d 83 59 92 f7 ff    	lea    -0x86da7(%ebx),%eax
f0101f59:	50                   	push   %eax
f0101f5a:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101f60:	50                   	push   %eax
f0101f61:	68 dc 02 00 00       	push   $0x2dc
f0101f66:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101f6c:	50                   	push   %eax
f0101f6d:	e8 3f e1 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f72:	50                   	push   %eax
f0101f73:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0101f79:	50                   	push   %eax
f0101f7a:	6a 56                	push   $0x56
f0101f7c:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f0101f82:	50                   	push   %eax
f0101f83:	e8 29 e1 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101f88:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101f8b:	8d 83 68 92 f7 ff    	lea    -0x86d98(%ebx),%eax
f0101f91:	50                   	push   %eax
f0101f92:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101f98:	50                   	push   %eax
f0101f99:	68 e1 02 00 00       	push   $0x2e1
f0101f9e:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101fa4:	50                   	push   %eax
f0101fa5:	e8 07 e1 ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f0101faa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fad:	8d 83 86 92 f7 ff    	lea    -0x86d7a(%ebx),%eax
f0101fb3:	50                   	push   %eax
f0101fb4:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101fba:	50                   	push   %eax
f0101fbb:	68 e2 02 00 00       	push   $0x2e2
f0101fc0:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101fc6:	50                   	push   %eax
f0101fc7:	e8 e5 e0 ff ff       	call   f01000b1 <_panic>
f0101fcc:	52                   	push   %edx
f0101fcd:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0101fd3:	50                   	push   %eax
f0101fd4:	6a 56                	push   $0x56
f0101fd6:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f0101fdc:	50                   	push   %eax
f0101fdd:	e8 cf e0 ff ff       	call   f01000b1 <_panic>
		assert(c[i] == 0);
f0101fe2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101fe5:	8d 83 96 92 f7 ff    	lea    -0x86d6a(%ebx),%eax
f0101feb:	50                   	push   %eax
f0101fec:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0101ff2:	50                   	push   %eax
f0101ff3:	68 e5 02 00 00       	push   $0x2e5
f0101ff8:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0101ffe:	50                   	push   %eax
f0101fff:	e8 ad e0 ff ff       	call   f01000b1 <_panic>
		--nfree;
f0102004:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102007:	8b 00                	mov    (%eax),%eax
f0102009:	85 c0                	test   %eax,%eax
f010200b:	75 f7                	jne    f0102004 <mem_init+0x64a>
	assert(nfree == 0);
f010200d:	85 f6                	test   %esi,%esi
f010200f:	0f 85 5f 08 00 00    	jne    f0102874 <mem_init+0xeba>
	cprintf("check_page_alloc() succeeded!\n");
f0102015:	83 ec 0c             	sub    $0xc,%esp
f0102018:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010201b:	8d 83 d8 8a f7 ff    	lea    -0x87528(%ebx),%eax
f0102021:	50                   	push   %eax
f0102022:	e8 28 1d 00 00       	call   f0103d4f <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102027:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010202e:	e8 43 f6 ff ff       	call   f0101676 <page_alloc>
f0102033:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102036:	83 c4 10             	add    $0x10,%esp
f0102039:	85 c0                	test   %eax,%eax
f010203b:	0f 84 55 08 00 00    	je     f0102896 <mem_init+0xedc>
	assert((pp1 = page_alloc(0)));
f0102041:	83 ec 0c             	sub    $0xc,%esp
f0102044:	6a 00                	push   $0x0
f0102046:	e8 2b f6 ff ff       	call   f0101676 <page_alloc>
f010204b:	89 c7                	mov    %eax,%edi
f010204d:	83 c4 10             	add    $0x10,%esp
f0102050:	85 c0                	test   %eax,%eax
f0102052:	0f 84 60 08 00 00    	je     f01028b8 <mem_init+0xefe>
	assert((pp2 = page_alloc(0)));
f0102058:	83 ec 0c             	sub    $0xc,%esp
f010205b:	6a 00                	push   $0x0
f010205d:	e8 14 f6 ff ff       	call   f0101676 <page_alloc>
f0102062:	89 c6                	mov    %eax,%esi
f0102064:	83 c4 10             	add    $0x10,%esp
f0102067:	85 c0                	test   %eax,%eax
f0102069:	0f 84 6b 08 00 00    	je     f01028da <mem_init+0xf20>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010206f:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0102072:	0f 84 84 08 00 00    	je     f01028fc <mem_init+0xf42>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102078:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f010207b:	0f 84 9d 08 00 00    	je     f010291e <mem_init+0xf64>
f0102081:	39 c7                	cmp    %eax,%edi
f0102083:	0f 84 95 08 00 00    	je     f010291e <mem_init+0xf64>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102089:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010208c:	8b 88 28 22 00 00    	mov    0x2228(%eax),%ecx
f0102092:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0102095:	c7 80 28 22 00 00 00 	movl   $0x0,0x2228(%eax)
f010209c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010209f:	83 ec 0c             	sub    $0xc,%esp
f01020a2:	6a 00                	push   $0x0
f01020a4:	e8 cd f5 ff ff       	call   f0101676 <page_alloc>
f01020a9:	83 c4 10             	add    $0x10,%esp
f01020ac:	85 c0                	test   %eax,%eax
f01020ae:	0f 85 8c 08 00 00    	jne    f0102940 <mem_init+0xf86>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01020b4:	83 ec 04             	sub    $0x4,%esp
f01020b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01020ba:	50                   	push   %eax
f01020bb:	6a 00                	push   $0x0
f01020bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020c0:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01020c6:	ff 30                	pushl  (%eax)
f01020c8:	e8 c6 f7 ff ff       	call   f0101893 <page_lookup>
f01020cd:	83 c4 10             	add    $0x10,%esp
f01020d0:	85 c0                	test   %eax,%eax
f01020d2:	0f 85 8a 08 00 00    	jne    f0102962 <mem_init+0xfa8>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01020d8:	6a 02                	push   $0x2
f01020da:	6a 00                	push   $0x0
f01020dc:	57                   	push   %edi
f01020dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020e0:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01020e6:	ff 30                	pushl  (%eax)
f01020e8:	e8 55 f8 ff ff       	call   f0101942 <page_insert>
f01020ed:	83 c4 10             	add    $0x10,%esp
f01020f0:	85 c0                	test   %eax,%eax
f01020f2:	0f 89 8c 08 00 00    	jns    f0102984 <mem_init+0xfca>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01020f8:	83 ec 0c             	sub    $0xc,%esp
f01020fb:	ff 75 d0             	pushl  -0x30(%ebp)
f01020fe:	e8 fb f5 ff ff       	call   f01016fe <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102103:	6a 02                	push   $0x2
f0102105:	6a 00                	push   $0x0
f0102107:	57                   	push   %edi
f0102108:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010210b:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0102111:	ff 30                	pushl  (%eax)
f0102113:	e8 2a f8 ff ff       	call   f0101942 <page_insert>
f0102118:	83 c4 20             	add    $0x20,%esp
f010211b:	85 c0                	test   %eax,%eax
f010211d:	0f 85 83 08 00 00    	jne    f01029a6 <mem_init+0xfec>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102123:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102126:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f010212c:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f010212e:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0102134:	8b 08                	mov    (%eax),%ecx
f0102136:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102139:	8b 13                	mov    (%ebx),%edx
f010213b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102141:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102144:	29 c8                	sub    %ecx,%eax
f0102146:	c1 f8 03             	sar    $0x3,%eax
f0102149:	c1 e0 0c             	shl    $0xc,%eax
f010214c:	39 c2                	cmp    %eax,%edx
f010214e:	0f 85 74 08 00 00    	jne    f01029c8 <mem_init+0x100e>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102154:	ba 00 00 00 00       	mov    $0x0,%edx
f0102159:	89 d8                	mov    %ebx,%eax
f010215b:	e8 f4 ef ff ff       	call   f0101154 <check_va2pa>
f0102160:	89 fa                	mov    %edi,%edx
f0102162:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0102165:	c1 fa 03             	sar    $0x3,%edx
f0102168:	c1 e2 0c             	shl    $0xc,%edx
f010216b:	39 d0                	cmp    %edx,%eax
f010216d:	0f 85 77 08 00 00    	jne    f01029ea <mem_init+0x1030>
	assert(pp1->pp_ref == 1);
f0102173:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102178:	0f 85 8e 08 00 00    	jne    f0102a0c <mem_init+0x1052>
	assert(pp0->pp_ref == 1);
f010217e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102181:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102186:	0f 85 a2 08 00 00    	jne    f0102a2e <mem_init+0x1074>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010218c:	6a 02                	push   $0x2
f010218e:	68 00 10 00 00       	push   $0x1000
f0102193:	56                   	push   %esi
f0102194:	53                   	push   %ebx
f0102195:	e8 a8 f7 ff ff       	call   f0101942 <page_insert>
f010219a:	83 c4 10             	add    $0x10,%esp
f010219d:	85 c0                	test   %eax,%eax
f010219f:	0f 85 ab 08 00 00    	jne    f0102a50 <mem_init+0x1096>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01021a5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021ad:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01021b3:	8b 00                	mov    (%eax),%eax
f01021b5:	e8 9a ef ff ff       	call   f0101154 <check_va2pa>
f01021ba:	c7 c2 30 00 19 f0    	mov    $0xf0190030,%edx
f01021c0:	89 f1                	mov    %esi,%ecx
f01021c2:	2b 0a                	sub    (%edx),%ecx
f01021c4:	89 ca                	mov    %ecx,%edx
f01021c6:	c1 fa 03             	sar    $0x3,%edx
f01021c9:	c1 e2 0c             	shl    $0xc,%edx
f01021cc:	39 d0                	cmp    %edx,%eax
f01021ce:	0f 85 9e 08 00 00    	jne    f0102a72 <mem_init+0x10b8>
	assert(pp2->pp_ref == 1);
f01021d4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01021d9:	0f 85 b5 08 00 00    	jne    f0102a94 <mem_init+0x10da>

	// should be no free memory
	assert(!page_alloc(0));
f01021df:	83 ec 0c             	sub    $0xc,%esp
f01021e2:	6a 00                	push   $0x0
f01021e4:	e8 8d f4 ff ff       	call   f0101676 <page_alloc>
f01021e9:	83 c4 10             	add    $0x10,%esp
f01021ec:	85 c0                	test   %eax,%eax
f01021ee:	0f 85 c2 08 00 00    	jne    f0102ab6 <mem_init+0x10fc>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01021f4:	6a 02                	push   $0x2
f01021f6:	68 00 10 00 00       	push   $0x1000
f01021fb:	56                   	push   %esi
f01021fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021ff:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0102205:	ff 30                	pushl  (%eax)
f0102207:	e8 36 f7 ff ff       	call   f0101942 <page_insert>
f010220c:	83 c4 10             	add    $0x10,%esp
f010220f:	85 c0                	test   %eax,%eax
f0102211:	0f 85 c1 08 00 00    	jne    f0102ad8 <mem_init+0x111e>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102217:	ba 00 10 00 00       	mov    $0x1000,%edx
f010221c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010221f:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0102225:	8b 00                	mov    (%eax),%eax
f0102227:	e8 28 ef ff ff       	call   f0101154 <check_va2pa>
f010222c:	c7 c2 30 00 19 f0    	mov    $0xf0190030,%edx
f0102232:	89 f1                	mov    %esi,%ecx
f0102234:	2b 0a                	sub    (%edx),%ecx
f0102236:	89 ca                	mov    %ecx,%edx
f0102238:	c1 fa 03             	sar    $0x3,%edx
f010223b:	c1 e2 0c             	shl    $0xc,%edx
f010223e:	39 d0                	cmp    %edx,%eax
f0102240:	0f 85 b4 08 00 00    	jne    f0102afa <mem_init+0x1140>
	assert(pp2->pp_ref == 1);
f0102246:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010224b:	0f 85 cb 08 00 00    	jne    f0102b1c <mem_init+0x1162>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102251:	83 ec 0c             	sub    $0xc,%esp
f0102254:	6a 00                	push   $0x0
f0102256:	e8 1b f4 ff ff       	call   f0101676 <page_alloc>
f010225b:	83 c4 10             	add    $0x10,%esp
f010225e:	85 c0                	test   %eax,%eax
f0102260:	0f 85 d8 08 00 00    	jne    f0102b3e <mem_init+0x1184>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102266:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102269:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f010226f:	8b 10                	mov    (%eax),%edx
f0102271:	8b 02                	mov    (%edx),%eax
f0102273:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0102278:	89 c3                	mov    %eax,%ebx
f010227a:	c1 eb 0c             	shr    $0xc,%ebx
f010227d:	c7 c1 28 00 19 f0    	mov    $0xf0190028,%ecx
f0102283:	3b 19                	cmp    (%ecx),%ebx
f0102285:	0f 83 d5 08 00 00    	jae    f0102b60 <mem_init+0x11a6>
	return (void *)(pa + KERNBASE);
f010228b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102290:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102293:	83 ec 04             	sub    $0x4,%esp
f0102296:	6a 00                	push   $0x0
f0102298:	68 00 10 00 00       	push   $0x1000
f010229d:	52                   	push   %edx
f010229e:	e8 f6 f4 ff ff       	call   f0101799 <pgdir_walk>
f01022a3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01022a6:	8d 51 04             	lea    0x4(%ecx),%edx
f01022a9:	83 c4 10             	add    $0x10,%esp
f01022ac:	39 d0                	cmp    %edx,%eax
f01022ae:	0f 85 c8 08 00 00    	jne    f0102b7c <mem_init+0x11c2>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01022b4:	6a 06                	push   $0x6
f01022b6:	68 00 10 00 00       	push   $0x1000
f01022bb:	56                   	push   %esi
f01022bc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022bf:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01022c5:	ff 30                	pushl  (%eax)
f01022c7:	e8 76 f6 ff ff       	call   f0101942 <page_insert>
f01022cc:	83 c4 10             	add    $0x10,%esp
f01022cf:	85 c0                	test   %eax,%eax
f01022d1:	0f 85 c7 08 00 00    	jne    f0102b9e <mem_init+0x11e4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022da:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01022e0:	8b 18                	mov    (%eax),%ebx
f01022e2:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022e7:	89 d8                	mov    %ebx,%eax
f01022e9:	e8 66 ee ff ff       	call   f0101154 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f01022ee:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01022f1:	c7 c2 30 00 19 f0    	mov    $0xf0190030,%edx
f01022f7:	89 f1                	mov    %esi,%ecx
f01022f9:	2b 0a                	sub    (%edx),%ecx
f01022fb:	89 ca                	mov    %ecx,%edx
f01022fd:	c1 fa 03             	sar    $0x3,%edx
f0102300:	c1 e2 0c             	shl    $0xc,%edx
f0102303:	39 d0                	cmp    %edx,%eax
f0102305:	0f 85 b5 08 00 00    	jne    f0102bc0 <mem_init+0x1206>
	assert(pp2->pp_ref == 1);
f010230b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102310:	0f 85 cc 08 00 00    	jne    f0102be2 <mem_init+0x1228>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102316:	83 ec 04             	sub    $0x4,%esp
f0102319:	6a 00                	push   $0x0
f010231b:	68 00 10 00 00       	push   $0x1000
f0102320:	53                   	push   %ebx
f0102321:	e8 73 f4 ff ff       	call   f0101799 <pgdir_walk>
f0102326:	83 c4 10             	add    $0x10,%esp
f0102329:	f6 00 04             	testb  $0x4,(%eax)
f010232c:	0f 84 d2 08 00 00    	je     f0102c04 <mem_init+0x124a>
	assert(kern_pgdir[0] & PTE_U);
f0102332:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102335:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f010233b:	8b 00                	mov    (%eax),%eax
f010233d:	f6 00 04             	testb  $0x4,(%eax)
f0102340:	0f 84 e0 08 00 00    	je     f0102c26 <mem_init+0x126c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102346:	6a 02                	push   $0x2
f0102348:	68 00 10 00 00       	push   $0x1000
f010234d:	56                   	push   %esi
f010234e:	50                   	push   %eax
f010234f:	e8 ee f5 ff ff       	call   f0101942 <page_insert>
f0102354:	83 c4 10             	add    $0x10,%esp
f0102357:	85 c0                	test   %eax,%eax
f0102359:	0f 85 e9 08 00 00    	jne    f0102c48 <mem_init+0x128e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010235f:	83 ec 04             	sub    $0x4,%esp
f0102362:	6a 00                	push   $0x0
f0102364:	68 00 10 00 00       	push   $0x1000
f0102369:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010236c:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0102372:	ff 30                	pushl  (%eax)
f0102374:	e8 20 f4 ff ff       	call   f0101799 <pgdir_walk>
f0102379:	83 c4 10             	add    $0x10,%esp
f010237c:	f6 00 02             	testb  $0x2,(%eax)
f010237f:	0f 84 e5 08 00 00    	je     f0102c6a <mem_init+0x12b0>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102385:	83 ec 04             	sub    $0x4,%esp
f0102388:	6a 00                	push   $0x0
f010238a:	68 00 10 00 00       	push   $0x1000
f010238f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102392:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0102398:	ff 30                	pushl  (%eax)
f010239a:	e8 fa f3 ff ff       	call   f0101799 <pgdir_walk>
f010239f:	83 c4 10             	add    $0x10,%esp
f01023a2:	f6 00 04             	testb  $0x4,(%eax)
f01023a5:	0f 85 e1 08 00 00    	jne    f0102c8c <mem_init+0x12d2>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01023ab:	6a 02                	push   $0x2
f01023ad:	68 00 00 40 00       	push   $0x400000
f01023b2:	ff 75 d0             	pushl  -0x30(%ebp)
f01023b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023b8:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01023be:	ff 30                	pushl  (%eax)
f01023c0:	e8 7d f5 ff ff       	call   f0101942 <page_insert>
f01023c5:	83 c4 10             	add    $0x10,%esp
f01023c8:	85 c0                	test   %eax,%eax
f01023ca:	0f 89 de 08 00 00    	jns    f0102cae <mem_init+0x12f4>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01023d0:	6a 02                	push   $0x2
f01023d2:	68 00 10 00 00       	push   $0x1000
f01023d7:	57                   	push   %edi
f01023d8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023db:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01023e1:	ff 30                	pushl  (%eax)
f01023e3:	e8 5a f5 ff ff       	call   f0101942 <page_insert>
f01023e8:	83 c4 10             	add    $0x10,%esp
f01023eb:	85 c0                	test   %eax,%eax
f01023ed:	0f 85 dd 08 00 00    	jne    f0102cd0 <mem_init+0x1316>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01023f3:	83 ec 04             	sub    $0x4,%esp
f01023f6:	6a 00                	push   $0x0
f01023f8:	68 00 10 00 00       	push   $0x1000
f01023fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102400:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0102406:	ff 30                	pushl  (%eax)
f0102408:	e8 8c f3 ff ff       	call   f0101799 <pgdir_walk>
f010240d:	83 c4 10             	add    $0x10,%esp
f0102410:	f6 00 04             	testb  $0x4,(%eax)
f0102413:	0f 85 d9 08 00 00    	jne    f0102cf2 <mem_init+0x1338>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102419:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010241c:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0102422:	8b 18                	mov    (%eax),%ebx
f0102424:	ba 00 00 00 00       	mov    $0x0,%edx
f0102429:	89 d8                	mov    %ebx,%eax
f010242b:	e8 24 ed ff ff       	call   f0101154 <check_va2pa>
f0102430:	89 c2                	mov    %eax,%edx
f0102432:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102435:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102438:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f010243e:	89 f9                	mov    %edi,%ecx
f0102440:	2b 08                	sub    (%eax),%ecx
f0102442:	89 c8                	mov    %ecx,%eax
f0102444:	c1 f8 03             	sar    $0x3,%eax
f0102447:	c1 e0 0c             	shl    $0xc,%eax
f010244a:	39 c2                	cmp    %eax,%edx
f010244c:	0f 85 c2 08 00 00    	jne    f0102d14 <mem_init+0x135a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102452:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102457:	89 d8                	mov    %ebx,%eax
f0102459:	e8 f6 ec ff ff       	call   f0101154 <check_va2pa>
f010245e:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102461:	0f 85 cf 08 00 00    	jne    f0102d36 <mem_init+0x137c>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102467:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f010246c:	0f 85 e6 08 00 00    	jne    f0102d58 <mem_init+0x139e>
	assert(pp2->pp_ref == 0);
f0102472:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102477:	0f 85 fd 08 00 00    	jne    f0102d7a <mem_init+0x13c0>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010247d:	83 ec 0c             	sub    $0xc,%esp
f0102480:	6a 00                	push   $0x0
f0102482:	e8 ef f1 ff ff       	call   f0101676 <page_alloc>
f0102487:	83 c4 10             	add    $0x10,%esp
f010248a:	39 c6                	cmp    %eax,%esi
f010248c:	0f 85 0a 09 00 00    	jne    f0102d9c <mem_init+0x13e2>
f0102492:	85 c0                	test   %eax,%eax
f0102494:	0f 84 02 09 00 00    	je     f0102d9c <mem_init+0x13e2>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010249a:	83 ec 08             	sub    $0x8,%esp
f010249d:	6a 00                	push   $0x0
f010249f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024a2:	c7 c3 2c 00 19 f0    	mov    $0xf019002c,%ebx
f01024a8:	ff 33                	pushl  (%ebx)
f01024aa:	e8 54 f4 ff ff       	call   f0101903 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024af:	8b 1b                	mov    (%ebx),%ebx
f01024b1:	ba 00 00 00 00       	mov    $0x0,%edx
f01024b6:	89 d8                	mov    %ebx,%eax
f01024b8:	e8 97 ec ff ff       	call   f0101154 <check_va2pa>
f01024bd:	83 c4 10             	add    $0x10,%esp
f01024c0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024c3:	0f 85 f5 08 00 00    	jne    f0102dbe <mem_init+0x1404>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024c9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024ce:	89 d8                	mov    %ebx,%eax
f01024d0:	e8 7f ec ff ff       	call   f0101154 <check_va2pa>
f01024d5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01024d8:	c7 c2 30 00 19 f0    	mov    $0xf0190030,%edx
f01024de:	89 f9                	mov    %edi,%ecx
f01024e0:	2b 0a                	sub    (%edx),%ecx
f01024e2:	89 ca                	mov    %ecx,%edx
f01024e4:	c1 fa 03             	sar    $0x3,%edx
f01024e7:	c1 e2 0c             	shl    $0xc,%edx
f01024ea:	39 d0                	cmp    %edx,%eax
f01024ec:	0f 85 ee 08 00 00    	jne    f0102de0 <mem_init+0x1426>
	assert(pp1->pp_ref == 1);
f01024f2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01024f7:	0f 85 05 09 00 00    	jne    f0102e02 <mem_init+0x1448>
	assert(pp2->pp_ref == 0);
f01024fd:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102502:	0f 85 1c 09 00 00    	jne    f0102e24 <mem_init+0x146a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102508:	6a 00                	push   $0x0
f010250a:	68 00 10 00 00       	push   $0x1000
f010250f:	57                   	push   %edi
f0102510:	53                   	push   %ebx
f0102511:	e8 2c f4 ff ff       	call   f0101942 <page_insert>
f0102516:	83 c4 10             	add    $0x10,%esp
f0102519:	85 c0                	test   %eax,%eax
f010251b:	0f 85 25 09 00 00    	jne    f0102e46 <mem_init+0x148c>
	assert(pp1->pp_ref);
f0102521:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102526:	0f 84 3c 09 00 00    	je     f0102e68 <mem_init+0x14ae>
	assert(pp1->pp_link == NULL);
f010252c:	83 3f 00             	cmpl   $0x0,(%edi)
f010252f:	0f 85 55 09 00 00    	jne    f0102e8a <mem_init+0x14d0>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102535:	83 ec 08             	sub    $0x8,%esp
f0102538:	68 00 10 00 00       	push   $0x1000
f010253d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102540:	c7 c3 2c 00 19 f0    	mov    $0xf019002c,%ebx
f0102546:	ff 33                	pushl  (%ebx)
f0102548:	e8 b6 f3 ff ff       	call   f0101903 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010254d:	8b 1b                	mov    (%ebx),%ebx
f010254f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102554:	89 d8                	mov    %ebx,%eax
f0102556:	e8 f9 eb ff ff       	call   f0101154 <check_va2pa>
f010255b:	83 c4 10             	add    $0x10,%esp
f010255e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102561:	0f 85 45 09 00 00    	jne    f0102eac <mem_init+0x14f2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102567:	ba 00 10 00 00       	mov    $0x1000,%edx
f010256c:	89 d8                	mov    %ebx,%eax
f010256e:	e8 e1 eb ff ff       	call   f0101154 <check_va2pa>
f0102573:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102576:	0f 85 52 09 00 00    	jne    f0102ece <mem_init+0x1514>
	assert(pp1->pp_ref == 0);
f010257c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102581:	0f 85 69 09 00 00    	jne    f0102ef0 <mem_init+0x1536>
	assert(pp2->pp_ref == 0);
f0102587:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010258c:	0f 85 80 09 00 00    	jne    f0102f12 <mem_init+0x1558>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102592:	83 ec 0c             	sub    $0xc,%esp
f0102595:	6a 00                	push   $0x0
f0102597:	e8 da f0 ff ff       	call   f0101676 <page_alloc>
f010259c:	83 c4 10             	add    $0x10,%esp
f010259f:	39 c7                	cmp    %eax,%edi
f01025a1:	0f 85 8d 09 00 00    	jne    f0102f34 <mem_init+0x157a>
f01025a7:	85 c0                	test   %eax,%eax
f01025a9:	0f 84 85 09 00 00    	je     f0102f34 <mem_init+0x157a>

	// should be no free memory
	assert(!page_alloc(0));
f01025af:	83 ec 0c             	sub    $0xc,%esp
f01025b2:	6a 00                	push   $0x0
f01025b4:	e8 bd f0 ff ff       	call   f0101676 <page_alloc>
f01025b9:	83 c4 10             	add    $0x10,%esp
f01025bc:	85 c0                	test   %eax,%eax
f01025be:	0f 85 92 09 00 00    	jne    f0102f56 <mem_init+0x159c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025c4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025c7:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01025cd:	8b 08                	mov    (%eax),%ecx
f01025cf:	8b 11                	mov    (%ecx),%edx
f01025d1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01025d7:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f01025dd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01025e0:	2b 18                	sub    (%eax),%ebx
f01025e2:	89 d8                	mov    %ebx,%eax
f01025e4:	c1 f8 03             	sar    $0x3,%eax
f01025e7:	c1 e0 0c             	shl    $0xc,%eax
f01025ea:	39 c2                	cmp    %eax,%edx
f01025ec:	0f 85 86 09 00 00    	jne    f0102f78 <mem_init+0x15be>
	kern_pgdir[0] = 0;
f01025f2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01025f8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01025fb:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102600:	0f 85 94 09 00 00    	jne    f0102f9a <mem_init+0x15e0>
	pp0->pp_ref = 0;
f0102606:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102609:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010260f:	83 ec 0c             	sub    $0xc,%esp
f0102612:	50                   	push   %eax
f0102613:	e8 e6 f0 ff ff       	call   f01016fe <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102618:	83 c4 0c             	add    $0xc,%esp
f010261b:	6a 01                	push   $0x1
f010261d:	68 00 10 40 00       	push   $0x401000
f0102622:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102625:	c7 c3 2c 00 19 f0    	mov    $0xf019002c,%ebx
f010262b:	ff 33                	pushl  (%ebx)
f010262d:	e8 67 f1 ff ff       	call   f0101799 <pgdir_walk>
f0102632:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102635:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102638:	8b 1b                	mov    (%ebx),%ebx
f010263a:	8b 53 04             	mov    0x4(%ebx),%edx
f010263d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0102643:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102646:	c7 c1 28 00 19 f0    	mov    $0xf0190028,%ecx
f010264c:	8b 09                	mov    (%ecx),%ecx
f010264e:	89 d0                	mov    %edx,%eax
f0102650:	c1 e8 0c             	shr    $0xc,%eax
f0102653:	83 c4 10             	add    $0x10,%esp
f0102656:	39 c8                	cmp    %ecx,%eax
f0102658:	0f 83 5e 09 00 00    	jae    f0102fbc <mem_init+0x1602>
	assert(ptep == ptep1 + PTX(va));
f010265e:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102664:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102667:	0f 85 6b 09 00 00    	jne    f0102fd8 <mem_init+0x161e>
	kern_pgdir[PDX(va)] = 0;
f010266d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0102674:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102677:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f010267d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102680:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0102686:	2b 18                	sub    (%eax),%ebx
f0102688:	89 d8                	mov    %ebx,%eax
f010268a:	c1 f8 03             	sar    $0x3,%eax
f010268d:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102690:	89 c2                	mov    %eax,%edx
f0102692:	c1 ea 0c             	shr    $0xc,%edx
f0102695:	39 d1                	cmp    %edx,%ecx
f0102697:	0f 86 5d 09 00 00    	jbe    f0102ffa <mem_init+0x1640>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010269d:	83 ec 04             	sub    $0x4,%esp
f01026a0:	68 00 10 00 00       	push   $0x1000
f01026a5:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01026aa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026af:	50                   	push   %eax
f01026b0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026b3:	e8 88 27 00 00       	call   f0104e40 <memset>
	page_free(pp0);
f01026b8:	83 c4 04             	add    $0x4,%esp
f01026bb:	ff 75 d0             	pushl  -0x30(%ebp)
f01026be:	e8 3b f0 ff ff       	call   f01016fe <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01026c3:	83 c4 0c             	add    $0xc,%esp
f01026c6:	6a 01                	push   $0x1
f01026c8:	6a 00                	push   $0x0
f01026ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026cd:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01026d3:	ff 30                	pushl  (%eax)
f01026d5:	e8 bf f0 ff ff       	call   f0101799 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01026da:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f01026e0:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01026e3:	2b 10                	sub    (%eax),%edx
f01026e5:	c1 fa 03             	sar    $0x3,%edx
f01026e8:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01026eb:	89 d1                	mov    %edx,%ecx
f01026ed:	c1 e9 0c             	shr    $0xc,%ecx
f01026f0:	83 c4 10             	add    $0x10,%esp
f01026f3:	c7 c0 28 00 19 f0    	mov    $0xf0190028,%eax
f01026f9:	3b 08                	cmp    (%eax),%ecx
f01026fb:	0f 83 12 09 00 00    	jae    f0103013 <mem_init+0x1659>
	return (void *)(pa + KERNBASE);
f0102701:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102707:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010270a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102710:	f6 00 01             	testb  $0x1,(%eax)
f0102713:	0f 85 13 09 00 00    	jne    f010302c <mem_init+0x1672>
f0102719:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f010271c:	39 d0                	cmp    %edx,%eax
f010271e:	75 f0                	jne    f0102710 <mem_init+0xd56>
	kern_pgdir[0] = 0;
f0102720:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102723:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0102729:	8b 00                	mov    (%eax),%eax
f010272b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102731:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102734:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010273a:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010273d:	89 93 28 22 00 00    	mov    %edx,0x2228(%ebx)

	// free the pages we took
	page_free(pp0);
f0102743:	83 ec 0c             	sub    $0xc,%esp
f0102746:	50                   	push   %eax
f0102747:	e8 b2 ef ff ff       	call   f01016fe <page_free>
	page_free(pp1);
f010274c:	89 3c 24             	mov    %edi,(%esp)
f010274f:	e8 aa ef ff ff       	call   f01016fe <page_free>
	page_free(pp2);
f0102754:	89 34 24             	mov    %esi,(%esp)
f0102757:	e8 a2 ef ff ff       	call   f01016fe <page_free>

	cprintf("check_page() succeeded!\n");
f010275c:	8d 83 77 93 f7 ff    	lea    -0x86c89(%ebx),%eax
f0102762:	89 04 24             	mov    %eax,(%esp)
f0102765:	e8 e5 15 00 00       	call   f0103d4f <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f010276a:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0102770:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102772:	83 c4 10             	add    $0x10,%esp
f0102775:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010277a:	0f 86 ce 08 00 00    	jbe    f010304e <mem_init+0x1694>
f0102780:	83 ec 08             	sub    $0x8,%esp
f0102783:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102785:	05 00 00 00 10       	add    $0x10000000,%eax
f010278a:	50                   	push   %eax
f010278b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102790:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102795:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102798:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f010279e:	8b 00                	mov    (%eax),%eax
f01027a0:	e8 9f f0 ff ff       	call   f0101844 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f01027a5:	c7 c0 64 f3 18 f0    	mov    $0xf018f364,%eax
f01027ab:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01027ad:	83 c4 10             	add    $0x10,%esp
f01027b0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027b5:	0f 86 af 08 00 00    	jbe    f010306a <mem_init+0x16b0>
f01027bb:	83 ec 08             	sub    $0x8,%esp
f01027be:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01027c0:	05 00 00 00 10       	add    $0x10000000,%eax
f01027c5:	50                   	push   %eax
f01027c6:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01027cb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01027d0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01027d3:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f01027d9:	8b 00                	mov    (%eax),%eax
f01027db:	e8 64 f0 ff ff       	call   f0101844 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01027e0:	c7 c0 00 30 11 f0    	mov    $0xf0113000,%eax
f01027e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01027e9:	83 c4 10             	add    $0x10,%esp
f01027ec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027f1:	0f 86 8f 08 00 00    	jbe    f0103086 <mem_init+0x16cc>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01027f7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01027fa:	c7 c3 2c 00 19 f0    	mov    $0xf019002c,%ebx
f0102800:	83 ec 08             	sub    $0x8,%esp
f0102803:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0102805:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102808:	05 00 00 00 10       	add    $0x10000000,%eax
f010280d:	50                   	push   %eax
f010280e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102813:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102818:	8b 03                	mov    (%ebx),%eax
f010281a:	e8 25 f0 ff ff       	call   f0101844 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, (uint32_t)0xffffffff - KERNBASE, 0, PTE_W);
f010281f:	83 c4 08             	add    $0x8,%esp
f0102822:	6a 02                	push   $0x2
f0102824:	6a 00                	push   $0x0
f0102826:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f010282b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102830:	8b 03                	mov    (%ebx),%eax
f0102832:	e8 0d f0 ff ff       	call   f0101844 <boot_map_region>
	pgdir = kern_pgdir;
f0102837:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102839:	c7 c0 28 00 19 f0    	mov    $0xf0190028,%eax
f010283f:	8b 00                	mov    (%eax),%eax
f0102841:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102844:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010284b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102850:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102853:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0102859:	8b 00                	mov    (%eax),%eax
f010285b:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010285e:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102861:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0102867:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f010286a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010286f:	e9 57 08 00 00       	jmp    f01030cb <mem_init+0x1711>
	assert(nfree == 0);
f0102874:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102877:	8d 83 a0 92 f7 ff    	lea    -0x86d60(%ebx),%eax
f010287d:	50                   	push   %eax
f010287e:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102884:	50                   	push   %eax
f0102885:	68 f2 02 00 00       	push   $0x2f2
f010288a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102890:	50                   	push   %eax
f0102891:	e8 1b d8 ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f0102896:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102899:	8d 83 ae 91 f7 ff    	lea    -0x86e52(%ebx),%eax
f010289f:	50                   	push   %eax
f01028a0:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01028a6:	50                   	push   %eax
f01028a7:	68 54 03 00 00       	push   $0x354
f01028ac:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01028b2:	50                   	push   %eax
f01028b3:	e8 f9 d7 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01028b8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028bb:	8d 83 c4 91 f7 ff    	lea    -0x86e3c(%ebx),%eax
f01028c1:	50                   	push   %eax
f01028c2:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01028c8:	50                   	push   %eax
f01028c9:	68 55 03 00 00       	push   $0x355
f01028ce:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01028d4:	50                   	push   %eax
f01028d5:	e8 d7 d7 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01028da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028dd:	8d 83 da 91 f7 ff    	lea    -0x86e26(%ebx),%eax
f01028e3:	50                   	push   %eax
f01028e4:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01028ea:	50                   	push   %eax
f01028eb:	68 56 03 00 00       	push   $0x356
f01028f0:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01028f6:	50                   	push   %eax
f01028f7:	e8 b5 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp1 && pp1 != pp0);
f01028fc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028ff:	8d 83 f0 91 f7 ff    	lea    -0x86e10(%ebx),%eax
f0102905:	50                   	push   %eax
f0102906:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f010290c:	50                   	push   %eax
f010290d:	68 59 03 00 00       	push   $0x359
f0102912:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102918:	50                   	push   %eax
f0102919:	e8 93 d7 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010291e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102921:	8d 83 b8 8a f7 ff    	lea    -0x87548(%ebx),%eax
f0102927:	50                   	push   %eax
f0102928:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f010292e:	50                   	push   %eax
f010292f:	68 5a 03 00 00       	push   $0x35a
f0102934:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010293a:	50                   	push   %eax
f010293b:	e8 71 d7 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102940:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102943:	8d 83 59 92 f7 ff    	lea    -0x86da7(%ebx),%eax
f0102949:	50                   	push   %eax
f010294a:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102950:	50                   	push   %eax
f0102951:	68 61 03 00 00       	push   $0x361
f0102956:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010295c:	50                   	push   %eax
f010295d:	e8 4f d7 ff ff       	call   f01000b1 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102962:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102965:	8d 83 f8 8a f7 ff    	lea    -0x87508(%ebx),%eax
f010296b:	50                   	push   %eax
f010296c:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102972:	50                   	push   %eax
f0102973:	68 64 03 00 00       	push   $0x364
f0102978:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010297e:	50                   	push   %eax
f010297f:	e8 2d d7 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102984:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102987:	8d 83 30 8b f7 ff    	lea    -0x874d0(%ebx),%eax
f010298d:	50                   	push   %eax
f010298e:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102994:	50                   	push   %eax
f0102995:	68 67 03 00 00       	push   $0x367
f010299a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01029a0:	50                   	push   %eax
f01029a1:	e8 0b d7 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01029a6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029a9:	8d 83 60 8b f7 ff    	lea    -0x874a0(%ebx),%eax
f01029af:	50                   	push   %eax
f01029b0:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01029b6:	50                   	push   %eax
f01029b7:	68 6b 03 00 00       	push   $0x36b
f01029bc:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01029c2:	50                   	push   %eax
f01029c3:	e8 e9 d6 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01029c8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029cb:	8d 83 90 8b f7 ff    	lea    -0x87470(%ebx),%eax
f01029d1:	50                   	push   %eax
f01029d2:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01029d8:	50                   	push   %eax
f01029d9:	68 6c 03 00 00       	push   $0x36c
f01029de:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01029e4:	50                   	push   %eax
f01029e5:	e8 c7 d6 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01029ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029ed:	8d 83 b8 8b f7 ff    	lea    -0x87448(%ebx),%eax
f01029f3:	50                   	push   %eax
f01029f4:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01029fa:	50                   	push   %eax
f01029fb:	68 6d 03 00 00       	push   $0x36d
f0102a00:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102a06:	50                   	push   %eax
f0102a07:	e8 a5 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102a0c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a0f:	8d 83 ab 92 f7 ff    	lea    -0x86d55(%ebx),%eax
f0102a15:	50                   	push   %eax
f0102a16:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102a1c:	50                   	push   %eax
f0102a1d:	68 6e 03 00 00       	push   $0x36e
f0102a22:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102a28:	50                   	push   %eax
f0102a29:	e8 83 d6 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102a2e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a31:	8d 83 bc 92 f7 ff    	lea    -0x86d44(%ebx),%eax
f0102a37:	50                   	push   %eax
f0102a38:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102a3e:	50                   	push   %eax
f0102a3f:	68 6f 03 00 00       	push   $0x36f
f0102a44:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102a4a:	50                   	push   %eax
f0102a4b:	e8 61 d6 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102a50:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a53:	8d 83 e8 8b f7 ff    	lea    -0x87418(%ebx),%eax
f0102a59:	50                   	push   %eax
f0102a5a:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102a60:	50                   	push   %eax
f0102a61:	68 72 03 00 00       	push   $0x372
f0102a66:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102a6c:	50                   	push   %eax
f0102a6d:	e8 3f d6 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102a72:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a75:	8d 83 24 8c f7 ff    	lea    -0x873dc(%ebx),%eax
f0102a7b:	50                   	push   %eax
f0102a7c:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102a82:	50                   	push   %eax
f0102a83:	68 73 03 00 00       	push   $0x373
f0102a88:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102a8e:	50                   	push   %eax
f0102a8f:	e8 1d d6 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102a94:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a97:	8d 83 cd 92 f7 ff    	lea    -0x86d33(%ebx),%eax
f0102a9d:	50                   	push   %eax
f0102a9e:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102aa4:	50                   	push   %eax
f0102aa5:	68 74 03 00 00       	push   $0x374
f0102aaa:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102ab0:	50                   	push   %eax
f0102ab1:	e8 fb d5 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102ab6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ab9:	8d 83 59 92 f7 ff    	lea    -0x86da7(%ebx),%eax
f0102abf:	50                   	push   %eax
f0102ac0:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102ac6:	50                   	push   %eax
f0102ac7:	68 77 03 00 00       	push   $0x377
f0102acc:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102ad2:	50                   	push   %eax
f0102ad3:	e8 d9 d5 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102ad8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102adb:	8d 83 e8 8b f7 ff    	lea    -0x87418(%ebx),%eax
f0102ae1:	50                   	push   %eax
f0102ae2:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102ae8:	50                   	push   %eax
f0102ae9:	68 7a 03 00 00       	push   $0x37a
f0102aee:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102af4:	50                   	push   %eax
f0102af5:	e8 b7 d5 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102afa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102afd:	8d 83 24 8c f7 ff    	lea    -0x873dc(%ebx),%eax
f0102b03:	50                   	push   %eax
f0102b04:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102b0a:	50                   	push   %eax
f0102b0b:	68 7b 03 00 00       	push   $0x37b
f0102b10:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102b16:	50                   	push   %eax
f0102b17:	e8 95 d5 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102b1c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b1f:	8d 83 cd 92 f7 ff    	lea    -0x86d33(%ebx),%eax
f0102b25:	50                   	push   %eax
f0102b26:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102b2c:	50                   	push   %eax
f0102b2d:	68 7c 03 00 00       	push   $0x37c
f0102b32:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102b38:	50                   	push   %eax
f0102b39:	e8 73 d5 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102b3e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b41:	8d 83 59 92 f7 ff    	lea    -0x86da7(%ebx),%eax
f0102b47:	50                   	push   %eax
f0102b48:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102b4e:	50                   	push   %eax
f0102b4f:	68 80 03 00 00       	push   $0x380
f0102b54:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102b5a:	50                   	push   %eax
f0102b5b:	e8 51 d5 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b60:	50                   	push   %eax
f0102b61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b64:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0102b6a:	50                   	push   %eax
f0102b6b:	68 83 03 00 00       	push   $0x383
f0102b70:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102b76:	50                   	push   %eax
f0102b77:	e8 35 d5 ff ff       	call   f01000b1 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102b7c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b7f:	8d 83 54 8c f7 ff    	lea    -0x873ac(%ebx),%eax
f0102b85:	50                   	push   %eax
f0102b86:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102b8c:	50                   	push   %eax
f0102b8d:	68 84 03 00 00       	push   $0x384
f0102b92:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102b98:	50                   	push   %eax
f0102b99:	e8 13 d5 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102b9e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ba1:	8d 83 94 8c f7 ff    	lea    -0x8736c(%ebx),%eax
f0102ba7:	50                   	push   %eax
f0102ba8:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102bae:	50                   	push   %eax
f0102baf:	68 87 03 00 00       	push   $0x387
f0102bb4:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102bba:	50                   	push   %eax
f0102bbb:	e8 f1 d4 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102bc0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bc3:	8d 83 24 8c f7 ff    	lea    -0x873dc(%ebx),%eax
f0102bc9:	50                   	push   %eax
f0102bca:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102bd0:	50                   	push   %eax
f0102bd1:	68 88 03 00 00       	push   $0x388
f0102bd6:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102bdc:	50                   	push   %eax
f0102bdd:	e8 cf d4 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102be2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102be5:	8d 83 cd 92 f7 ff    	lea    -0x86d33(%ebx),%eax
f0102beb:	50                   	push   %eax
f0102bec:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102bf2:	50                   	push   %eax
f0102bf3:	68 89 03 00 00       	push   $0x389
f0102bf8:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102bfe:	50                   	push   %eax
f0102bff:	e8 ad d4 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102c04:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c07:	8d 83 d4 8c f7 ff    	lea    -0x8732c(%ebx),%eax
f0102c0d:	50                   	push   %eax
f0102c0e:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102c14:	50                   	push   %eax
f0102c15:	68 8a 03 00 00       	push   $0x38a
f0102c1a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102c20:	50                   	push   %eax
f0102c21:	e8 8b d4 ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102c26:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c29:	8d 83 de 92 f7 ff    	lea    -0x86d22(%ebx),%eax
f0102c2f:	50                   	push   %eax
f0102c30:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102c36:	50                   	push   %eax
f0102c37:	68 8b 03 00 00       	push   $0x38b
f0102c3c:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102c42:	50                   	push   %eax
f0102c43:	e8 69 d4 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102c48:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c4b:	8d 83 e8 8b f7 ff    	lea    -0x87418(%ebx),%eax
f0102c51:	50                   	push   %eax
f0102c52:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102c58:	50                   	push   %eax
f0102c59:	68 8e 03 00 00       	push   $0x38e
f0102c5e:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102c64:	50                   	push   %eax
f0102c65:	e8 47 d4 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102c6a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c6d:	8d 83 08 8d f7 ff    	lea    -0x872f8(%ebx),%eax
f0102c73:	50                   	push   %eax
f0102c74:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102c7a:	50                   	push   %eax
f0102c7b:	68 8f 03 00 00       	push   $0x38f
f0102c80:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102c86:	50                   	push   %eax
f0102c87:	e8 25 d4 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102c8c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c8f:	8d 83 3c 8d f7 ff    	lea    -0x872c4(%ebx),%eax
f0102c95:	50                   	push   %eax
f0102c96:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102c9c:	50                   	push   %eax
f0102c9d:	68 90 03 00 00       	push   $0x390
f0102ca2:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102ca8:	50                   	push   %eax
f0102ca9:	e8 03 d4 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102cae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cb1:	8d 83 74 8d f7 ff    	lea    -0x8728c(%ebx),%eax
f0102cb7:	50                   	push   %eax
f0102cb8:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102cbe:	50                   	push   %eax
f0102cbf:	68 93 03 00 00       	push   $0x393
f0102cc4:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102cca:	50                   	push   %eax
f0102ccb:	e8 e1 d3 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102cd0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cd3:	8d 83 ac 8d f7 ff    	lea    -0x87254(%ebx),%eax
f0102cd9:	50                   	push   %eax
f0102cda:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102ce0:	50                   	push   %eax
f0102ce1:	68 96 03 00 00       	push   $0x396
f0102ce6:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102cec:	50                   	push   %eax
f0102ced:	e8 bf d3 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102cf2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cf5:	8d 83 3c 8d f7 ff    	lea    -0x872c4(%ebx),%eax
f0102cfb:	50                   	push   %eax
f0102cfc:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102d02:	50                   	push   %eax
f0102d03:	68 97 03 00 00       	push   $0x397
f0102d08:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102d0e:	50                   	push   %eax
f0102d0f:	e8 9d d3 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102d14:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d17:	8d 83 e8 8d f7 ff    	lea    -0x87218(%ebx),%eax
f0102d1d:	50                   	push   %eax
f0102d1e:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102d24:	50                   	push   %eax
f0102d25:	68 9a 03 00 00       	push   $0x39a
f0102d2a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102d30:	50                   	push   %eax
f0102d31:	e8 7b d3 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102d36:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d39:	8d 83 14 8e f7 ff    	lea    -0x871ec(%ebx),%eax
f0102d3f:	50                   	push   %eax
f0102d40:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102d46:	50                   	push   %eax
f0102d47:	68 9b 03 00 00       	push   $0x39b
f0102d4c:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102d52:	50                   	push   %eax
f0102d53:	e8 59 d3 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 2);
f0102d58:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d5b:	8d 83 f4 92 f7 ff    	lea    -0x86d0c(%ebx),%eax
f0102d61:	50                   	push   %eax
f0102d62:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102d68:	50                   	push   %eax
f0102d69:	68 9d 03 00 00       	push   $0x39d
f0102d6e:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102d74:	50                   	push   %eax
f0102d75:	e8 37 d3 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102d7a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d7d:	8d 83 05 93 f7 ff    	lea    -0x86cfb(%ebx),%eax
f0102d83:	50                   	push   %eax
f0102d84:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102d8a:	50                   	push   %eax
f0102d8b:	68 9e 03 00 00       	push   $0x39e
f0102d90:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102d96:	50                   	push   %eax
f0102d97:	e8 15 d3 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102d9c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d9f:	8d 83 44 8e f7 ff    	lea    -0x871bc(%ebx),%eax
f0102da5:	50                   	push   %eax
f0102da6:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102dac:	50                   	push   %eax
f0102dad:	68 a1 03 00 00       	push   $0x3a1
f0102db2:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102db8:	50                   	push   %eax
f0102db9:	e8 f3 d2 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102dbe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dc1:	8d 83 68 8e f7 ff    	lea    -0x87198(%ebx),%eax
f0102dc7:	50                   	push   %eax
f0102dc8:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102dce:	50                   	push   %eax
f0102dcf:	68 a5 03 00 00       	push   $0x3a5
f0102dd4:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102dda:	50                   	push   %eax
f0102ddb:	e8 d1 d2 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102de0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102de3:	8d 83 14 8e f7 ff    	lea    -0x871ec(%ebx),%eax
f0102de9:	50                   	push   %eax
f0102dea:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102df0:	50                   	push   %eax
f0102df1:	68 a6 03 00 00       	push   $0x3a6
f0102df6:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102dfc:	50                   	push   %eax
f0102dfd:	e8 af d2 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102e02:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e05:	8d 83 ab 92 f7 ff    	lea    -0x86d55(%ebx),%eax
f0102e0b:	50                   	push   %eax
f0102e0c:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102e12:	50                   	push   %eax
f0102e13:	68 a7 03 00 00       	push   $0x3a7
f0102e18:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102e1e:	50                   	push   %eax
f0102e1f:	e8 8d d2 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102e24:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e27:	8d 83 05 93 f7 ff    	lea    -0x86cfb(%ebx),%eax
f0102e2d:	50                   	push   %eax
f0102e2e:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102e34:	50                   	push   %eax
f0102e35:	68 a8 03 00 00       	push   $0x3a8
f0102e3a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102e40:	50                   	push   %eax
f0102e41:	e8 6b d2 ff ff       	call   f01000b1 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102e46:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e49:	8d 83 8c 8e f7 ff    	lea    -0x87174(%ebx),%eax
f0102e4f:	50                   	push   %eax
f0102e50:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102e56:	50                   	push   %eax
f0102e57:	68 ab 03 00 00       	push   $0x3ab
f0102e5c:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102e62:	50                   	push   %eax
f0102e63:	e8 49 d2 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f0102e68:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e6b:	8d 83 16 93 f7 ff    	lea    -0x86cea(%ebx),%eax
f0102e71:	50                   	push   %eax
f0102e72:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102e78:	50                   	push   %eax
f0102e79:	68 ac 03 00 00       	push   $0x3ac
f0102e7e:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102e84:	50                   	push   %eax
f0102e85:	e8 27 d2 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f0102e8a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e8d:	8d 83 22 93 f7 ff    	lea    -0x86cde(%ebx),%eax
f0102e93:	50                   	push   %eax
f0102e94:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102e9a:	50                   	push   %eax
f0102e9b:	68 ad 03 00 00       	push   $0x3ad
f0102ea0:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102ea6:	50                   	push   %eax
f0102ea7:	e8 05 d2 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102eac:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102eaf:	8d 83 68 8e f7 ff    	lea    -0x87198(%ebx),%eax
f0102eb5:	50                   	push   %eax
f0102eb6:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102ebc:	50                   	push   %eax
f0102ebd:	68 b1 03 00 00       	push   $0x3b1
f0102ec2:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102ec8:	50                   	push   %eax
f0102ec9:	e8 e3 d1 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102ece:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ed1:	8d 83 c4 8e f7 ff    	lea    -0x8713c(%ebx),%eax
f0102ed7:	50                   	push   %eax
f0102ed8:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102ede:	50                   	push   %eax
f0102edf:	68 b2 03 00 00       	push   $0x3b2
f0102ee4:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102eea:	50                   	push   %eax
f0102eeb:	e8 c1 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102ef0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ef3:	8d 83 37 93 f7 ff    	lea    -0x86cc9(%ebx),%eax
f0102ef9:	50                   	push   %eax
f0102efa:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102f00:	50                   	push   %eax
f0102f01:	68 b3 03 00 00       	push   $0x3b3
f0102f06:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102f0c:	50                   	push   %eax
f0102f0d:	e8 9f d1 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102f12:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f15:	8d 83 05 93 f7 ff    	lea    -0x86cfb(%ebx),%eax
f0102f1b:	50                   	push   %eax
f0102f1c:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102f22:	50                   	push   %eax
f0102f23:	68 b4 03 00 00       	push   $0x3b4
f0102f28:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102f2e:	50                   	push   %eax
f0102f2f:	e8 7d d1 ff ff       	call   f01000b1 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102f34:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f37:	8d 83 ec 8e f7 ff    	lea    -0x87114(%ebx),%eax
f0102f3d:	50                   	push   %eax
f0102f3e:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102f44:	50                   	push   %eax
f0102f45:	68 b7 03 00 00       	push   $0x3b7
f0102f4a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102f50:	50                   	push   %eax
f0102f51:	e8 5b d1 ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f0102f56:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f59:	8d 83 59 92 f7 ff    	lea    -0x86da7(%ebx),%eax
f0102f5f:	50                   	push   %eax
f0102f60:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102f66:	50                   	push   %eax
f0102f67:	68 ba 03 00 00       	push   $0x3ba
f0102f6c:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102f72:	50                   	push   %eax
f0102f73:	e8 39 d1 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102f78:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f7b:	8d 83 90 8b f7 ff    	lea    -0x87470(%ebx),%eax
f0102f81:	50                   	push   %eax
f0102f82:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102f88:	50                   	push   %eax
f0102f89:	68 bd 03 00 00       	push   $0x3bd
f0102f8e:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102f94:	50                   	push   %eax
f0102f95:	e8 17 d1 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0102f9a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f9d:	8d 83 bc 92 f7 ff    	lea    -0x86d44(%ebx),%eax
f0102fa3:	50                   	push   %eax
f0102fa4:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102faa:	50                   	push   %eax
f0102fab:	68 bf 03 00 00       	push   $0x3bf
f0102fb0:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102fb6:	50                   	push   %eax
f0102fb7:	e8 f5 d0 ff ff       	call   f01000b1 <_panic>
f0102fbc:	52                   	push   %edx
f0102fbd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fc0:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0102fc6:	50                   	push   %eax
f0102fc7:	68 c6 03 00 00       	push   $0x3c6
f0102fcc:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102fd2:	50                   	push   %eax
f0102fd3:	e8 d9 d0 ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102fd8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102fdb:	8d 83 48 93 f7 ff    	lea    -0x86cb8(%ebx),%eax
f0102fe1:	50                   	push   %eax
f0102fe2:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0102fe8:	50                   	push   %eax
f0102fe9:	68 c7 03 00 00       	push   $0x3c7
f0102fee:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0102ff4:	50                   	push   %eax
f0102ff5:	e8 b7 d0 ff ff       	call   f01000b1 <_panic>
f0102ffa:	50                   	push   %eax
f0102ffb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ffe:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0103004:	50                   	push   %eax
f0103005:	6a 56                	push   $0x56
f0103007:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f010300d:	50                   	push   %eax
f010300e:	e8 9e d0 ff ff       	call   f01000b1 <_panic>
f0103013:	52                   	push   %edx
f0103014:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103017:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f010301d:	50                   	push   %eax
f010301e:	6a 56                	push   $0x56
f0103020:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f0103026:	50                   	push   %eax
f0103027:	e8 85 d0 ff ff       	call   f01000b1 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f010302c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010302f:	8d 83 60 93 f7 ff    	lea    -0x86ca0(%ebx),%eax
f0103035:	50                   	push   %eax
f0103036:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f010303c:	50                   	push   %eax
f010303d:	68 d1 03 00 00       	push   $0x3d1
f0103042:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0103048:	50                   	push   %eax
f0103049:	e8 63 d0 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010304e:	50                   	push   %eax
f010304f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103052:	8d 83 94 8a f7 ff    	lea    -0x8756c(%ebx),%eax
f0103058:	50                   	push   %eax
f0103059:	68 b8 00 00 00       	push   $0xb8
f010305e:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0103064:	50                   	push   %eax
f0103065:	e8 47 d0 ff ff       	call   f01000b1 <_panic>
f010306a:	50                   	push   %eax
f010306b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010306e:	8d 83 94 8a f7 ff    	lea    -0x8756c(%ebx),%eax
f0103074:	50                   	push   %eax
f0103075:	68 c0 00 00 00       	push   $0xc0
f010307a:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0103080:	50                   	push   %eax
f0103081:	e8 2b d0 ff ff       	call   f01000b1 <_panic>
f0103086:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103089:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f010308f:	8d 83 94 8a f7 ff    	lea    -0x8756c(%ebx),%eax
f0103095:	50                   	push   %eax
f0103096:	68 cc 00 00 00       	push   $0xcc
f010309b:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01030a1:	50                   	push   %eax
f01030a2:	e8 0a d0 ff ff       	call   f01000b1 <_panic>
f01030a7:	ff 75 c0             	pushl  -0x40(%ebp)
f01030aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030ad:	8d 83 94 8a f7 ff    	lea    -0x8756c(%ebx),%eax
f01030b3:	50                   	push   %eax
f01030b4:	68 0a 03 00 00       	push   $0x30a
f01030b9:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01030bf:	50                   	push   %eax
f01030c0:	e8 ec cf ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f01030c5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01030cb:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f01030ce:	76 3f                	jbe    f010310f <mem_init+0x1755>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01030d0:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01030d6:	89 f0                	mov    %esi,%eax
f01030d8:	e8 77 e0 ff ff       	call   f0101154 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01030dd:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01030e4:	76 c1                	jbe    f01030a7 <mem_init+0x16ed>
f01030e6:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f01030e9:	39 d0                	cmp    %edx,%eax
f01030eb:	74 d8                	je     f01030c5 <mem_init+0x170b>
f01030ed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030f0:	8d 83 10 8f f7 ff    	lea    -0x870f0(%ebx),%eax
f01030f6:	50                   	push   %eax
f01030f7:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01030fd:	50                   	push   %eax
f01030fe:	68 0a 03 00 00       	push   $0x30a
f0103103:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0103109:	50                   	push   %eax
f010310a:	e8 a2 cf ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010310f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103112:	c7 c0 64 f3 18 f0    	mov    $0xf018f364,%eax
f0103118:	8b 00                	mov    (%eax),%eax
f010311a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010311d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103120:	bf 00 00 c0 ee       	mov    $0xeec00000,%edi
f0103125:	8d 98 00 00 40 21    	lea    0x21400000(%eax),%ebx
f010312b:	89 fa                	mov    %edi,%edx
f010312d:	89 f0                	mov    %esi,%eax
f010312f:	e8 20 e0 ff ff       	call   f0101154 <check_va2pa>
f0103134:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010313b:	76 3d                	jbe    f010317a <mem_init+0x17c0>
f010313d:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0103140:	39 d0                	cmp    %edx,%eax
f0103142:	75 54                	jne    f0103198 <mem_init+0x17de>
f0103144:	81 c7 00 10 00 00    	add    $0x1000,%edi
	for (i = 0; i < n; i += PGSIZE)
f010314a:	81 ff 00 80 c1 ee    	cmp    $0xeec18000,%edi
f0103150:	75 d9                	jne    f010312b <mem_init+0x1771>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103152:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103155:	c1 e7 0c             	shl    $0xc,%edi
f0103158:	bb 00 00 00 00       	mov    $0x0,%ebx
f010315d:	39 fb                	cmp    %edi,%ebx
f010315f:	73 7b                	jae    f01031dc <mem_init+0x1822>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103161:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0103167:	89 f0                	mov    %esi,%eax
f0103169:	e8 e6 df ff ff       	call   f0101154 <check_va2pa>
f010316e:	39 c3                	cmp    %eax,%ebx
f0103170:	75 48                	jne    f01031ba <mem_init+0x1800>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103172:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103178:	eb e3                	jmp    f010315d <mem_init+0x17a3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010317a:	ff 75 cc             	pushl  -0x34(%ebp)
f010317d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103180:	8d 83 94 8a f7 ff    	lea    -0x8756c(%ebx),%eax
f0103186:	50                   	push   %eax
f0103187:	68 13 03 00 00       	push   $0x313
f010318c:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0103192:	50                   	push   %eax
f0103193:	e8 19 cf ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103198:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010319b:	8d 83 44 8f f7 ff    	lea    -0x870bc(%ebx),%eax
f01031a1:	50                   	push   %eax
f01031a2:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01031a8:	50                   	push   %eax
f01031a9:	68 13 03 00 00       	push   $0x313
f01031ae:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01031b4:	50                   	push   %eax
f01031b5:	e8 f7 ce ff ff       	call   f01000b1 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01031ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031bd:	8d 83 78 8f f7 ff    	lea    -0x87088(%ebx),%eax
f01031c3:	50                   	push   %eax
f01031c4:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01031ca:	50                   	push   %eax
f01031cb:	68 17 03 00 00       	push   $0x317
f01031d0:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01031d6:	50                   	push   %eax
f01031d7:	e8 d5 ce ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01031dc:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01031e1:	8b 7d c8             	mov    -0x38(%ebp),%edi
f01031e4:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f01031ea:	89 da                	mov    %ebx,%edx
f01031ec:	89 f0                	mov    %esi,%eax
f01031ee:	e8 61 df ff ff       	call   f0101154 <check_va2pa>
f01031f3:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f01031f6:	39 c2                	cmp    %eax,%edx
f01031f8:	75 26                	jne    f0103220 <mem_init+0x1866>
f01031fa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103200:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0103206:	75 e2                	jne    f01031ea <mem_init+0x1830>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0103208:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010320d:	89 f0                	mov    %esi,%eax
f010320f:	e8 40 df ff ff       	call   f0101154 <check_va2pa>
f0103214:	83 f8 ff             	cmp    $0xffffffff,%eax
f0103217:	75 29                	jne    f0103242 <mem_init+0x1888>
	for (i = 0; i < NPDENTRIES; i++) {
f0103219:	b8 00 00 00 00       	mov    $0x0,%eax
f010321e:	eb 6d                	jmp    f010328d <mem_init+0x18d3>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0103220:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103223:	8d 83 a0 8f f7 ff    	lea    -0x87060(%ebx),%eax
f0103229:	50                   	push   %eax
f010322a:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0103230:	50                   	push   %eax
f0103231:	68 1b 03 00 00       	push   $0x31b
f0103236:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010323c:	50                   	push   %eax
f010323d:	e8 6f ce ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0103242:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103245:	8d 83 e8 8f f7 ff    	lea    -0x87018(%ebx),%eax
f010324b:	50                   	push   %eax
f010324c:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0103252:	50                   	push   %eax
f0103253:	68 1c 03 00 00       	push   $0x31c
f0103258:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010325e:	50                   	push   %eax
f010325f:	e8 4d ce ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f0103264:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0103268:	74 52                	je     f01032bc <mem_init+0x1902>
	for (i = 0; i < NPDENTRIES; i++) {
f010326a:	83 c0 01             	add    $0x1,%eax
f010326d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0103272:	0f 87 bb 00 00 00    	ja     f0103333 <mem_init+0x1979>
		switch (i) {
f0103278:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010327d:	72 0e                	jb     f010328d <mem_init+0x18d3>
f010327f:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0103284:	76 de                	jbe    f0103264 <mem_init+0x18aa>
f0103286:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010328b:	74 d7                	je     f0103264 <mem_init+0x18aa>
			if (i >= PDX(KERNBASE)) {
f010328d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103292:	77 4a                	ja     f01032de <mem_init+0x1924>
				assert(pgdir[i] == 0);
f0103294:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0103298:	74 d0                	je     f010326a <mem_init+0x18b0>
f010329a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010329d:	8d 83 b2 93 f7 ff    	lea    -0x86c4e(%ebx),%eax
f01032a3:	50                   	push   %eax
f01032a4:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01032aa:	50                   	push   %eax
f01032ab:	68 2c 03 00 00       	push   $0x32c
f01032b0:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01032b6:	50                   	push   %eax
f01032b7:	e8 f5 cd ff ff       	call   f01000b1 <_panic>
			assert(pgdir[i] & PTE_P);
f01032bc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032bf:	8d 83 90 93 f7 ff    	lea    -0x86c70(%ebx),%eax
f01032c5:	50                   	push   %eax
f01032c6:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01032cc:	50                   	push   %eax
f01032cd:	68 25 03 00 00       	push   $0x325
f01032d2:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01032d8:	50                   	push   %eax
f01032d9:	e8 d3 cd ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f01032de:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01032e1:	f6 c2 01             	test   $0x1,%dl
f01032e4:	74 2b                	je     f0103311 <mem_init+0x1957>
				assert(pgdir[i] & PTE_W);
f01032e6:	f6 c2 02             	test   $0x2,%dl
f01032e9:	0f 85 7b ff ff ff    	jne    f010326a <mem_init+0x18b0>
f01032ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032f2:	8d 83 a1 93 f7 ff    	lea    -0x86c5f(%ebx),%eax
f01032f8:	50                   	push   %eax
f01032f9:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01032ff:	50                   	push   %eax
f0103300:	68 2a 03 00 00       	push   $0x32a
f0103305:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010330b:	50                   	push   %eax
f010330c:	e8 a0 cd ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_P);
f0103311:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103314:	8d 83 90 93 f7 ff    	lea    -0x86c70(%ebx),%eax
f010331a:	50                   	push   %eax
f010331b:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0103321:	50                   	push   %eax
f0103322:	68 29 03 00 00       	push   $0x329
f0103327:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010332d:	50                   	push   %eax
f010332e:	e8 7e cd ff ff       	call   f01000b1 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0103333:	83 ec 0c             	sub    $0xc,%esp
f0103336:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103339:	8d 87 18 90 f7 ff    	lea    -0x86fe8(%edi),%eax
f010333f:	50                   	push   %eax
f0103340:	89 fb                	mov    %edi,%ebx
f0103342:	e8 08 0a 00 00       	call   f0103d4f <cprintf>
	lcr3(PADDR(kern_pgdir));
f0103347:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f010334d:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010334f:	83 c4 10             	add    $0x10,%esp
f0103352:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103357:	0f 86 44 02 00 00    	jbe    f01035a1 <mem_init+0x1be7>
	return (physaddr_t)kva - KERNBASE;
f010335d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103362:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0103365:	b8 00 00 00 00       	mov    $0x0,%eax
f010336a:	e8 62 de ff ff       	call   f01011d1 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010336f:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0103372:	83 e0 f3             	and    $0xfffffff3,%eax
f0103375:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010337a:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010337d:	83 ec 0c             	sub    $0xc,%esp
f0103380:	6a 00                	push   $0x0
f0103382:	e8 ef e2 ff ff       	call   f0101676 <page_alloc>
f0103387:	89 c6                	mov    %eax,%esi
f0103389:	83 c4 10             	add    $0x10,%esp
f010338c:	85 c0                	test   %eax,%eax
f010338e:	0f 84 29 02 00 00    	je     f01035bd <mem_init+0x1c03>
	assert((pp1 = page_alloc(0)));
f0103394:	83 ec 0c             	sub    $0xc,%esp
f0103397:	6a 00                	push   $0x0
f0103399:	e8 d8 e2 ff ff       	call   f0101676 <page_alloc>
f010339e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01033a1:	83 c4 10             	add    $0x10,%esp
f01033a4:	85 c0                	test   %eax,%eax
f01033a6:	0f 84 33 02 00 00    	je     f01035df <mem_init+0x1c25>
	assert((pp2 = page_alloc(0)));
f01033ac:	83 ec 0c             	sub    $0xc,%esp
f01033af:	6a 00                	push   $0x0
f01033b1:	e8 c0 e2 ff ff       	call   f0101676 <page_alloc>
f01033b6:	89 c7                	mov    %eax,%edi
f01033b8:	83 c4 10             	add    $0x10,%esp
f01033bb:	85 c0                	test   %eax,%eax
f01033bd:	0f 84 3e 02 00 00    	je     f0103601 <mem_init+0x1c47>
	page_free(pp0);
f01033c3:	83 ec 0c             	sub    $0xc,%esp
f01033c6:	56                   	push   %esi
f01033c7:	e8 32 e3 ff ff       	call   f01016fe <page_free>
	return (pp - pages) << PGSHIFT;
f01033cc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01033cf:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f01033d5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01033d8:	2b 08                	sub    (%eax),%ecx
f01033da:	89 c8                	mov    %ecx,%eax
f01033dc:	c1 f8 03             	sar    $0x3,%eax
f01033df:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01033e2:	89 c1                	mov    %eax,%ecx
f01033e4:	c1 e9 0c             	shr    $0xc,%ecx
f01033e7:	83 c4 10             	add    $0x10,%esp
f01033ea:	c7 c2 28 00 19 f0    	mov    $0xf0190028,%edx
f01033f0:	3b 0a                	cmp    (%edx),%ecx
f01033f2:	0f 83 2b 02 00 00    	jae    f0103623 <mem_init+0x1c69>
	memset(page2kva(pp1), 1, PGSIZE);
f01033f8:	83 ec 04             	sub    $0x4,%esp
f01033fb:	68 00 10 00 00       	push   $0x1000
f0103400:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103402:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103407:	50                   	push   %eax
f0103408:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010340b:	e8 30 1a 00 00       	call   f0104e40 <memset>
	return (pp - pages) << PGSHIFT;
f0103410:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103413:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0103419:	89 f9                	mov    %edi,%ecx
f010341b:	2b 08                	sub    (%eax),%ecx
f010341d:	89 c8                	mov    %ecx,%eax
f010341f:	c1 f8 03             	sar    $0x3,%eax
f0103422:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103425:	89 c1                	mov    %eax,%ecx
f0103427:	c1 e9 0c             	shr    $0xc,%ecx
f010342a:	83 c4 10             	add    $0x10,%esp
f010342d:	c7 c2 28 00 19 f0    	mov    $0xf0190028,%edx
f0103433:	3b 0a                	cmp    (%edx),%ecx
f0103435:	0f 83 fe 01 00 00    	jae    f0103639 <mem_init+0x1c7f>
	memset(page2kva(pp2), 2, PGSIZE);
f010343b:	83 ec 04             	sub    $0x4,%esp
f010343e:	68 00 10 00 00       	push   $0x1000
f0103443:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0103445:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010344a:	50                   	push   %eax
f010344b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010344e:	e8 ed 19 00 00       	call   f0104e40 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103453:	6a 02                	push   $0x2
f0103455:	68 00 10 00 00       	push   $0x1000
f010345a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010345d:	53                   	push   %ebx
f010345e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103461:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0103467:	ff 30                	pushl  (%eax)
f0103469:	e8 d4 e4 ff ff       	call   f0101942 <page_insert>
	assert(pp1->pp_ref == 1);
f010346e:	83 c4 20             	add    $0x20,%esp
f0103471:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103476:	0f 85 d3 01 00 00    	jne    f010364f <mem_init+0x1c95>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010347c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103483:	01 01 01 
f0103486:	0f 85 e5 01 00 00    	jne    f0103671 <mem_init+0x1cb7>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010348c:	6a 02                	push   $0x2
f010348e:	68 00 10 00 00       	push   $0x1000
f0103493:	57                   	push   %edi
f0103494:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103497:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f010349d:	ff 30                	pushl  (%eax)
f010349f:	e8 9e e4 ff ff       	call   f0101942 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01034a4:	83 c4 10             	add    $0x10,%esp
f01034a7:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01034ae:	02 02 02 
f01034b1:	0f 85 dc 01 00 00    	jne    f0103693 <mem_init+0x1cd9>
	assert(pp2->pp_ref == 1);
f01034b7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01034bc:	0f 85 f3 01 00 00    	jne    f01036b5 <mem_init+0x1cfb>
	assert(pp1->pp_ref == 0);
f01034c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01034c5:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01034ca:	0f 85 07 02 00 00    	jne    f01036d7 <mem_init+0x1d1d>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01034d0:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01034d7:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01034da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01034dd:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f01034e3:	89 f9                	mov    %edi,%ecx
f01034e5:	2b 08                	sub    (%eax),%ecx
f01034e7:	89 c8                	mov    %ecx,%eax
f01034e9:	c1 f8 03             	sar    $0x3,%eax
f01034ec:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01034ef:	89 c1                	mov    %eax,%ecx
f01034f1:	c1 e9 0c             	shr    $0xc,%ecx
f01034f4:	c7 c2 28 00 19 f0    	mov    $0xf0190028,%edx
f01034fa:	3b 0a                	cmp    (%edx),%ecx
f01034fc:	0f 83 f7 01 00 00    	jae    f01036f9 <mem_init+0x1d3f>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103502:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103509:	03 03 03 
f010350c:	0f 85 fd 01 00 00    	jne    f010370f <mem_init+0x1d55>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103512:	83 ec 08             	sub    $0x8,%esp
f0103515:	68 00 10 00 00       	push   $0x1000
f010351a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010351d:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0103523:	ff 30                	pushl  (%eax)
f0103525:	e8 d9 e3 ff ff       	call   f0101903 <page_remove>
	assert(pp2->pp_ref == 0);
f010352a:	83 c4 10             	add    $0x10,%esp
f010352d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103532:	0f 85 f9 01 00 00    	jne    f0103731 <mem_init+0x1d77>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103538:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010353b:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0103541:	8b 08                	mov    (%eax),%ecx
f0103543:	8b 11                	mov    (%ecx),%edx
f0103545:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f010354b:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0103551:	89 f7                	mov    %esi,%edi
f0103553:	2b 38                	sub    (%eax),%edi
f0103555:	89 f8                	mov    %edi,%eax
f0103557:	c1 f8 03             	sar    $0x3,%eax
f010355a:	c1 e0 0c             	shl    $0xc,%eax
f010355d:	39 c2                	cmp    %eax,%edx
f010355f:	0f 85 ee 01 00 00    	jne    f0103753 <mem_init+0x1d99>
	kern_pgdir[0] = 0;
f0103565:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010356b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103570:	0f 85 ff 01 00 00    	jne    f0103775 <mem_init+0x1dbb>
	pp0->pp_ref = 0;
f0103576:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010357c:	83 ec 0c             	sub    $0xc,%esp
f010357f:	56                   	push   %esi
f0103580:	e8 79 e1 ff ff       	call   f01016fe <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103585:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103588:	8d 83 ac 90 f7 ff    	lea    -0x86f54(%ebx),%eax
f010358e:	89 04 24             	mov    %eax,(%esp)
f0103591:	e8 b9 07 00 00       	call   f0103d4f <cprintf>
}
f0103596:	83 c4 10             	add    $0x10,%esp
f0103599:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010359c:	5b                   	pop    %ebx
f010359d:	5e                   	pop    %esi
f010359e:	5f                   	pop    %edi
f010359f:	5d                   	pop    %ebp
f01035a0:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a1:	50                   	push   %eax
f01035a2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035a5:	8d 83 94 8a f7 ff    	lea    -0x8756c(%ebx),%eax
f01035ab:	50                   	push   %eax
f01035ac:	68 e0 00 00 00       	push   $0xe0
f01035b1:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01035b7:	50                   	push   %eax
f01035b8:	e8 f4 ca ff ff       	call   f01000b1 <_panic>
	assert((pp0 = page_alloc(0)));
f01035bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035c0:	8d 83 ae 91 f7 ff    	lea    -0x86e52(%ebx),%eax
f01035c6:	50                   	push   %eax
f01035c7:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01035cd:	50                   	push   %eax
f01035ce:	68 ec 03 00 00       	push   $0x3ec
f01035d3:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01035d9:	50                   	push   %eax
f01035da:	e8 d2 ca ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01035df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035e2:	8d 83 c4 91 f7 ff    	lea    -0x86e3c(%ebx),%eax
f01035e8:	50                   	push   %eax
f01035e9:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01035ef:	50                   	push   %eax
f01035f0:	68 ed 03 00 00       	push   $0x3ed
f01035f5:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01035fb:	50                   	push   %eax
f01035fc:	e8 b0 ca ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0103601:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103604:	8d 83 da 91 f7 ff    	lea    -0x86e26(%ebx),%eax
f010360a:	50                   	push   %eax
f010360b:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0103611:	50                   	push   %eax
f0103612:	68 ee 03 00 00       	push   $0x3ee
f0103617:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010361d:	50                   	push   %eax
f010361e:	e8 8e ca ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103623:	50                   	push   %eax
f0103624:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f010362a:	50                   	push   %eax
f010362b:	6a 56                	push   $0x56
f010362d:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f0103633:	50                   	push   %eax
f0103634:	e8 78 ca ff ff       	call   f01000b1 <_panic>
f0103639:	50                   	push   %eax
f010363a:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0103640:	50                   	push   %eax
f0103641:	6a 56                	push   $0x56
f0103643:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f0103649:	50                   	push   %eax
f010364a:	e8 62 ca ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010364f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103652:	8d 83 ab 92 f7 ff    	lea    -0x86d55(%ebx),%eax
f0103658:	50                   	push   %eax
f0103659:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f010365f:	50                   	push   %eax
f0103660:	68 f3 03 00 00       	push   $0x3f3
f0103665:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010366b:	50                   	push   %eax
f010366c:	e8 40 ca ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103671:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103674:	8d 83 38 90 f7 ff    	lea    -0x86fc8(%ebx),%eax
f010367a:	50                   	push   %eax
f010367b:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0103681:	50                   	push   %eax
f0103682:	68 f4 03 00 00       	push   $0x3f4
f0103687:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010368d:	50                   	push   %eax
f010368e:	e8 1e ca ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103693:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103696:	8d 83 5c 90 f7 ff    	lea    -0x86fa4(%ebx),%eax
f010369c:	50                   	push   %eax
f010369d:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01036a3:	50                   	push   %eax
f01036a4:	68 f6 03 00 00       	push   $0x3f6
f01036a9:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01036af:	50                   	push   %eax
f01036b0:	e8 fc c9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f01036b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01036b8:	8d 83 cd 92 f7 ff    	lea    -0x86d33(%ebx),%eax
f01036be:	50                   	push   %eax
f01036bf:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01036c5:	50                   	push   %eax
f01036c6:	68 f7 03 00 00       	push   $0x3f7
f01036cb:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01036d1:	50                   	push   %eax
f01036d2:	e8 da c9 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f01036d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01036da:	8d 83 37 93 f7 ff    	lea    -0x86cc9(%ebx),%eax
f01036e0:	50                   	push   %eax
f01036e1:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01036e7:	50                   	push   %eax
f01036e8:	68 f8 03 00 00       	push   $0x3f8
f01036ed:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f01036f3:	50                   	push   %eax
f01036f4:	e8 b8 c9 ff ff       	call   f01000b1 <_panic>
f01036f9:	50                   	push   %eax
f01036fa:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0103700:	50                   	push   %eax
f0103701:	6a 56                	push   $0x56
f0103703:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f0103709:	50                   	push   %eax
f010370a:	e8 a2 c9 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010370f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103712:	8d 83 80 90 f7 ff    	lea    -0x86f80(%ebx),%eax
f0103718:	50                   	push   %eax
f0103719:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f010371f:	50                   	push   %eax
f0103720:	68 fa 03 00 00       	push   $0x3fa
f0103725:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010372b:	50                   	push   %eax
f010372c:	e8 80 c9 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0103731:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103734:	8d 83 05 93 f7 ff    	lea    -0x86cfb(%ebx),%eax
f010373a:	50                   	push   %eax
f010373b:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0103741:	50                   	push   %eax
f0103742:	68 fc 03 00 00       	push   $0x3fc
f0103747:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010374d:	50                   	push   %eax
f010374e:	e8 5e c9 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103753:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103756:	8d 83 90 8b f7 ff    	lea    -0x87470(%ebx),%eax
f010375c:	50                   	push   %eax
f010375d:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0103763:	50                   	push   %eax
f0103764:	68 ff 03 00 00       	push   $0x3ff
f0103769:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f010376f:	50                   	push   %eax
f0103770:	e8 3c c9 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0103775:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103778:	8d 83 bc 92 f7 ff    	lea    -0x86d44(%ebx),%eax
f010377e:	50                   	push   %eax
f010377f:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0103785:	50                   	push   %eax
f0103786:	68 01 04 00 00       	push   $0x401
f010378b:	8d 83 d5 90 f7 ff    	lea    -0x86f2b(%ebx),%eax
f0103791:	50                   	push   %eax
f0103792:	e8 1a c9 ff ff       	call   f01000b1 <_panic>

f0103797 <tlb_invalidate>:
{
f0103797:	55                   	push   %ebp
f0103798:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010379a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010379d:	0f 01 38             	invlpg (%eax)
}
f01037a0:	5d                   	pop    %ebp
f01037a1:	c3                   	ret    

f01037a2 <user_mem_check>:
{
f01037a2:	55                   	push   %ebp
f01037a3:	89 e5                	mov    %esp,%ebp
}
f01037a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01037aa:	5d                   	pop    %ebp
f01037ab:	c3                   	ret    

f01037ac <user_mem_assert>:
{
f01037ac:	55                   	push   %ebp
f01037ad:	89 e5                	mov    %esp,%ebp
}
f01037af:	5d                   	pop    %ebp
f01037b0:	c3                   	ret    

f01037b1 <__x86.get_pc_thunk.cx>:
f01037b1:	8b 0c 24             	mov    (%esp),%ecx
f01037b4:	c3                   	ret    

f01037b5 <__x86.get_pc_thunk.si>:
f01037b5:	8b 34 24             	mov    (%esp),%esi
f01037b8:	c3                   	ret    

f01037b9 <__x86.get_pc_thunk.di>:
f01037b9:	8b 3c 24             	mov    (%esp),%edi
f01037bc:	c3                   	ret    

f01037bd <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01037bd:	55                   	push   %ebp
f01037be:	89 e5                	mov    %esp,%ebp
f01037c0:	53                   	push   %ebx
f01037c1:	e8 eb ff ff ff       	call   f01037b1 <__x86.get_pc_thunk.cx>
f01037c6:	81 c1 6e 99 08 00    	add    $0x8996e,%ecx
f01037cc:	8b 55 08             	mov    0x8(%ebp),%edx
f01037cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01037d2:	85 d2                	test   %edx,%edx
f01037d4:	74 41                	je     f0103817 <envid2env+0x5a>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01037d6:	89 d0                	mov    %edx,%eax
f01037d8:	25 ff 03 00 00       	and    $0x3ff,%eax
f01037dd:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01037e0:	c1 e0 05             	shl    $0x5,%eax
f01037e3:	03 81 30 22 00 00    	add    0x2230(%ecx),%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01037e9:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f01037ed:	74 3a                	je     f0103829 <envid2env+0x6c>
f01037ef:	39 50 48             	cmp    %edx,0x48(%eax)
f01037f2:	75 35                	jne    f0103829 <envid2env+0x6c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01037f4:	84 db                	test   %bl,%bl
f01037f6:	74 12                	je     f010380a <envid2env+0x4d>
f01037f8:	8b 91 2c 22 00 00    	mov    0x222c(%ecx),%edx
f01037fe:	39 c2                	cmp    %eax,%edx
f0103800:	74 08                	je     f010380a <envid2env+0x4d>
f0103802:	8b 5a 48             	mov    0x48(%edx),%ebx
f0103805:	39 58 4c             	cmp    %ebx,0x4c(%eax)
f0103808:	75 2f                	jne    f0103839 <envid2env+0x7c>
		*env_store = 0;
		return -E_BAD_ENV;
	}

	*env_store = e;
f010380a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010380d:	89 03                	mov    %eax,(%ebx)
	return 0;
f010380f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103814:	5b                   	pop    %ebx
f0103815:	5d                   	pop    %ebp
f0103816:	c3                   	ret    
		*env_store = curenv;
f0103817:	8b 81 2c 22 00 00    	mov    0x222c(%ecx),%eax
f010381d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103820:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103822:	b8 00 00 00 00       	mov    $0x0,%eax
f0103827:	eb eb                	jmp    f0103814 <envid2env+0x57>
		*env_store = 0;
f0103829:	8b 45 0c             	mov    0xc(%ebp),%eax
f010382c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103832:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103837:	eb db                	jmp    f0103814 <envid2env+0x57>
		*env_store = 0;
f0103839:	8b 45 0c             	mov    0xc(%ebp),%eax
f010383c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103842:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103847:	eb cb                	jmp    f0103814 <envid2env+0x57>

f0103849 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103849:	55                   	push   %ebp
f010384a:	89 e5                	mov    %esp,%ebp
f010384c:	e8 b8 ce ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f0103851:	05 e3 98 08 00       	add    $0x898e3,%eax
	asm volatile("lgdt (%0)" : : "r" (p));
f0103856:	8d 80 cc 1e 00 00    	lea    0x1ecc(%eax),%eax
f010385c:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f010385f:	b8 23 00 00 00       	mov    $0x23,%eax
f0103864:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103866:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103868:	b8 10 00 00 00       	mov    $0x10,%eax
f010386d:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f010386f:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103871:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103873:	ea 7a 38 10 f0 08 00 	ljmp   $0x8,$0xf010387a
	asm volatile("lldt %0" : : "r" (sel));
f010387a:	b8 00 00 00 00       	mov    $0x0,%eax
f010387f:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103882:	5d                   	pop    %ebp
f0103883:	c3                   	ret    

f0103884 <env_init>:
{
f0103884:	55                   	push   %ebp
f0103885:	89 e5                	mov    %esp,%ebp
f0103887:	e8 7d ce ff ff       	call   f0100709 <__x86.get_pc_thunk.ax>
f010388c:	05 a8 98 08 00       	add    $0x898a8,%eax
	env_free_list = envs;
f0103891:	8b 90 30 22 00 00    	mov    0x2230(%eax),%edx
f0103897:	89 90 34 22 00 00    	mov    %edx,0x2234(%eax)
f010389d:	8d 42 48             	lea    0x48(%edx),%eax
f01038a0:	81 c2 48 80 01 00    	add    $0x18048,%edx
		envs[i].env_id = 0;
f01038a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01038ac:	83 c0 60             	add    $0x60,%eax
	for (i = 0; i < NENV; i++)
f01038af:	39 d0                	cmp    %edx,%eax
f01038b1:	75 f3                	jne    f01038a6 <env_init+0x22>
	env_init_percpu();
f01038b3:	e8 91 ff ff ff       	call   f0103849 <env_init_percpu>
}
f01038b8:	5d                   	pop    %ebp
f01038b9:	c3                   	ret    

f01038ba <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01038ba:	55                   	push   %ebp
f01038bb:	89 e5                	mov    %esp,%ebp
f01038bd:	56                   	push   %esi
f01038be:	53                   	push   %ebx
f01038bf:	e8 a3 c8 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01038c4:	81 c3 70 98 08 00    	add    $0x89870,%ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01038ca:	8b b3 34 22 00 00    	mov    0x2234(%ebx),%esi
f01038d0:	85 f6                	test   %esi,%esi
f01038d2:	0f 84 3e 01 00 00    	je     f0103a16 <env_alloc+0x15c>
	if (!(p = page_alloc(ALLOC_ZERO)))
f01038d8:	83 ec 0c             	sub    $0xc,%esp
f01038db:	6a 01                	push   $0x1
f01038dd:	e8 94 dd ff ff       	call   f0101676 <page_alloc>
f01038e2:	83 c4 10             	add    $0x10,%esp
f01038e5:	85 c0                	test   %eax,%eax
f01038e7:	0f 84 30 01 00 00    	je     f0103a1d <env_alloc+0x163>
	return (pp - pages) << PGSHIFT;
f01038ed:	c7 c2 30 00 19 f0    	mov    $0xf0190030,%edx
f01038f3:	2b 02                	sub    (%edx),%eax
f01038f5:	c1 f8 03             	sar    $0x3,%eax
f01038f8:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01038fb:	89 c1                	mov    %eax,%ecx
f01038fd:	c1 e9 0c             	shr    $0xc,%ecx
f0103900:	c7 c2 28 00 19 f0    	mov    $0xf0190028,%edx
f0103906:	3b 0a                	cmp    (%edx),%ecx
f0103908:	0f 83 d6 00 00 00    	jae    f01039e4 <env_alloc+0x12a>
	return (void *)(pa + KERNBASE);
f010390e:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	e->env_pgdir = KADDR(page2pa(p));
f0103914:	89 56 5c             	mov    %edx,0x5c(%esi)
	if ((uint32_t)kva < KERNBASE)
f0103917:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010391d:	0f 86 da 00 00 00    	jbe    f01039fd <env_alloc+0x143>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103923:	83 c8 05             	or     $0x5,%eax
f0103926:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010392c:	8b 46 48             	mov    0x48(%esi),%eax
f010392f:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103934:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103939:	ba 00 10 00 00       	mov    $0x1000,%edx
f010393e:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103941:	89 f2                	mov    %esi,%edx
f0103943:	2b 93 30 22 00 00    	sub    0x2230(%ebx),%edx
f0103949:	c1 fa 05             	sar    $0x5,%edx
f010394c:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103952:	09 d0                	or     %edx,%eax
f0103954:	89 46 48             	mov    %eax,0x48(%esi)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103957:	8b 45 0c             	mov    0xc(%ebp),%eax
f010395a:	89 46 4c             	mov    %eax,0x4c(%esi)
	e->env_type = ENV_TYPE_USER;
f010395d:	c7 46 50 00 00 00 00 	movl   $0x0,0x50(%esi)
	e->env_status = ENV_RUNNABLE;
f0103964:	c7 46 54 02 00 00 00 	movl   $0x2,0x54(%esi)
	e->env_runs = 0;
f010396b:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103972:	83 ec 04             	sub    $0x4,%esp
f0103975:	6a 44                	push   $0x44
f0103977:	6a 00                	push   $0x0
f0103979:	56                   	push   %esi
f010397a:	e8 c1 14 00 00       	call   f0104e40 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010397f:	66 c7 46 24 23 00    	movw   $0x23,0x24(%esi)
	e->env_tf.tf_es = GD_UD | 3;
f0103985:	66 c7 46 20 23 00    	movw   $0x23,0x20(%esi)
	e->env_tf.tf_ss = GD_UD | 3;
f010398b:	66 c7 46 40 23 00    	movw   $0x23,0x40(%esi)
	e->env_tf.tf_esp = USTACKTOP;
f0103991:	c7 46 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%esi)
	e->env_tf.tf_cs = GD_UT | 3;
f0103998:	66 c7 46 34 1b 00    	movw   $0x1b,0x34(%esi)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010399e:	8b 46 44             	mov    0x44(%esi),%eax
f01039a1:	89 83 34 22 00 00    	mov    %eax,0x2234(%ebx)
	*newenv_store = e;
f01039a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01039aa:	89 30                	mov    %esi,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01039ac:	8b 4e 48             	mov    0x48(%esi),%ecx
f01039af:	8b 83 2c 22 00 00    	mov    0x222c(%ebx),%eax
f01039b5:	83 c4 10             	add    $0x10,%esp
f01039b8:	ba 00 00 00 00       	mov    $0x0,%edx
f01039bd:	85 c0                	test   %eax,%eax
f01039bf:	74 03                	je     f01039c4 <env_alloc+0x10a>
f01039c1:	8b 50 48             	mov    0x48(%eax),%edx
f01039c4:	83 ec 04             	sub    $0x4,%esp
f01039c7:	51                   	push   %ecx
f01039c8:	52                   	push   %edx
f01039c9:	8d 83 01 94 f7 ff    	lea    -0x86bff(%ebx),%eax
f01039cf:	50                   	push   %eax
f01039d0:	e8 7a 03 00 00       	call   f0103d4f <cprintf>
	return 0;
f01039d5:	83 c4 10             	add    $0x10,%esp
f01039d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01039dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01039e0:	5b                   	pop    %ebx
f01039e1:	5e                   	pop    %esi
f01039e2:	5d                   	pop    %ebp
f01039e3:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01039e4:	50                   	push   %eax
f01039e5:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f01039eb:	50                   	push   %eax
f01039ec:	68 bb 00 00 00       	push   $0xbb
f01039f1:	8d 83 f6 93 f7 ff    	lea    -0x86c0a(%ebx),%eax
f01039f7:	50                   	push   %eax
f01039f8:	e8 b4 c6 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039fd:	52                   	push   %edx
f01039fe:	8d 83 94 8a f7 ff    	lea    -0x8756c(%ebx),%eax
f0103a04:	50                   	push   %eax
f0103a05:	68 be 00 00 00       	push   $0xbe
f0103a0a:	8d 83 f6 93 f7 ff    	lea    -0x86c0a(%ebx),%eax
f0103a10:	50                   	push   %eax
f0103a11:	e8 9b c6 ff ff       	call   f01000b1 <_panic>
		return -E_NO_FREE_ENV;
f0103a16:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103a1b:	eb c0                	jmp    f01039dd <env_alloc+0x123>
		return -E_NO_MEM;
f0103a1d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103a22:	eb b9                	jmp    f01039dd <env_alloc+0x123>

f0103a24 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103a24:	55                   	push   %ebp
f0103a25:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0103a27:	5d                   	pop    %ebp
f0103a28:	c3                   	ret    

f0103a29 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a29:	55                   	push   %ebp
f0103a2a:	89 e5                	mov    %esp,%ebp
f0103a2c:	57                   	push   %edi
f0103a2d:	56                   	push   %esi
f0103a2e:	53                   	push   %ebx
f0103a2f:	83 ec 2c             	sub    $0x2c,%esp
f0103a32:	e8 30 c7 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103a37:	81 c3 fd 96 08 00    	add    $0x896fd,%ebx
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a3d:	8b 93 2c 22 00 00    	mov    0x222c(%ebx),%edx
f0103a43:	3b 55 08             	cmp    0x8(%ebp),%edx
f0103a46:	75 17                	jne    f0103a5f <env_free+0x36>
		lcr3(PADDR(kern_pgdir));
f0103a48:	c7 c0 2c 00 19 f0    	mov    $0xf019002c,%eax
f0103a4e:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103a50:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a55:	76 46                	jbe    f0103a9d <env_free+0x74>
	return (physaddr_t)kva - KERNBASE;
f0103a57:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103a5c:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103a5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a62:	8b 48 48             	mov    0x48(%eax),%ecx
f0103a65:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a6a:	85 d2                	test   %edx,%edx
f0103a6c:	74 03                	je     f0103a71 <env_free+0x48>
f0103a6e:	8b 42 48             	mov    0x48(%edx),%eax
f0103a71:	83 ec 04             	sub    $0x4,%esp
f0103a74:	51                   	push   %ecx
f0103a75:	50                   	push   %eax
f0103a76:	8d 83 16 94 f7 ff    	lea    -0x86bea(%ebx),%eax
f0103a7c:	50                   	push   %eax
f0103a7d:	e8 cd 02 00 00       	call   f0103d4f <cprintf>
f0103a82:	83 c4 10             	add    $0x10,%esp
f0103a85:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	if (PGNUM(pa) >= npages)
f0103a8c:	c7 c0 28 00 19 f0    	mov    $0xf0190028,%eax
f0103a92:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	if (PGNUM(pa) >= npages)
f0103a95:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103a98:	e9 9f 00 00 00       	jmp    f0103b3c <env_free+0x113>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a9d:	50                   	push   %eax
f0103a9e:	8d 83 94 8a f7 ff    	lea    -0x8756c(%ebx),%eax
f0103aa4:	50                   	push   %eax
f0103aa5:	68 6d 01 00 00       	push   $0x16d
f0103aaa:	8d 83 f6 93 f7 ff    	lea    -0x86c0a(%ebx),%eax
f0103ab0:	50                   	push   %eax
f0103ab1:	e8 fb c5 ff ff       	call   f01000b1 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103ab6:	50                   	push   %eax
f0103ab7:	8d 83 fc 87 f7 ff    	lea    -0x87804(%ebx),%eax
f0103abd:	50                   	push   %eax
f0103abe:	68 7c 01 00 00       	push   $0x17c
f0103ac3:	8d 83 f6 93 f7 ff    	lea    -0x86c0a(%ebx),%eax
f0103ac9:	50                   	push   %eax
f0103aca:	e8 e2 c5 ff ff       	call   f01000b1 <_panic>
f0103acf:	83 c6 04             	add    $0x4,%esi
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103ad2:	39 fe                	cmp    %edi,%esi
f0103ad4:	74 24                	je     f0103afa <env_free+0xd1>
			if (pt[pteno] & PTE_P)
f0103ad6:	f6 06 01             	testb  $0x1,(%esi)
f0103ad9:	74 f4                	je     f0103acf <env_free+0xa6>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103adb:	83 ec 08             	sub    $0x8,%esp
f0103ade:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ae1:	01 f0                	add    %esi,%eax
f0103ae3:	c1 e0 0a             	shl    $0xa,%eax
f0103ae6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103ae9:	50                   	push   %eax
f0103aea:	8b 45 08             	mov    0x8(%ebp),%eax
f0103aed:	ff 70 5c             	pushl  0x5c(%eax)
f0103af0:	e8 0e de ff ff       	call   f0101903 <page_remove>
f0103af5:	83 c4 10             	add    $0x10,%esp
f0103af8:	eb d5                	jmp    f0103acf <env_free+0xa6>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103afa:	8b 45 08             	mov    0x8(%ebp),%eax
f0103afd:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103b00:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b03:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f0103b0a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103b0d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b10:	3b 10                	cmp    (%eax),%edx
f0103b12:	73 6f                	jae    f0103b83 <env_free+0x15a>
		page_decref(pa2page(pa));
f0103b14:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103b17:	c7 c0 30 00 19 f0    	mov    $0xf0190030,%eax
f0103b1d:	8b 00                	mov    (%eax),%eax
f0103b1f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103b22:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103b25:	50                   	push   %eax
f0103b26:	e8 45 dc ff ff       	call   f0101770 <page_decref>
f0103b2b:	83 c4 10             	add    $0x10,%esp
f0103b2e:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f0103b32:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b35:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0103b3a:	74 5f                	je     f0103b9b <env_free+0x172>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103b3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b3f:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103b42:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b45:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103b48:	a8 01                	test   $0x1,%al
f0103b4a:	74 e2                	je     f0103b2e <env_free+0x105>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103b4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103b51:	89 c2                	mov    %eax,%edx
f0103b53:	c1 ea 0c             	shr    $0xc,%edx
f0103b56:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0103b59:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103b5c:	39 11                	cmp    %edx,(%ecx)
f0103b5e:	0f 86 52 ff ff ff    	jbe    f0103ab6 <env_free+0x8d>
	return (void *)(pa + KERNBASE);
f0103b64:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b6d:	c1 e2 14             	shl    $0x14,%edx
f0103b70:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103b73:	8d b8 00 10 00 f0    	lea    -0xffff000(%eax),%edi
f0103b79:	f7 d8                	neg    %eax
f0103b7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103b7e:	e9 53 ff ff ff       	jmp    f0103ad6 <env_free+0xad>
		panic("pa2page called with invalid pa");
f0103b83:	83 ec 04             	sub    $0x4,%esp
f0103b86:	8d 83 38 8a f7 ff    	lea    -0x875c8(%ebx),%eax
f0103b8c:	50                   	push   %eax
f0103b8d:	6a 4f                	push   $0x4f
f0103b8f:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f0103b95:	50                   	push   %eax
f0103b96:	e8 16 c5 ff ff       	call   f01000b1 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103b9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b9e:	8b 40 5c             	mov    0x5c(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103ba1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ba6:	76 57                	jbe    f0103bff <env_free+0x1d6>
	e->env_pgdir = 0;
f0103ba8:	8b 55 08             	mov    0x8(%ebp),%edx
f0103bab:	c7 42 5c 00 00 00 00 	movl   $0x0,0x5c(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103bb2:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103bb7:	c1 e8 0c             	shr    $0xc,%eax
f0103bba:	c7 c2 28 00 19 f0    	mov    $0xf0190028,%edx
f0103bc0:	3b 02                	cmp    (%edx),%eax
f0103bc2:	73 54                	jae    f0103c18 <env_free+0x1ef>
	page_decref(pa2page(pa));
f0103bc4:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103bc7:	c7 c2 30 00 19 f0    	mov    $0xf0190030,%edx
f0103bcd:	8b 12                	mov    (%edx),%edx
f0103bcf:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103bd2:	50                   	push   %eax
f0103bd3:	e8 98 db ff ff       	call   f0101770 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103bd8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bdb:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f0103be2:	8b 83 34 22 00 00    	mov    0x2234(%ebx),%eax
f0103be8:	8b 55 08             	mov    0x8(%ebp),%edx
f0103beb:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f0103bee:	89 93 34 22 00 00    	mov    %edx,0x2234(%ebx)
}
f0103bf4:	83 c4 10             	add    $0x10,%esp
f0103bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103bfa:	5b                   	pop    %ebx
f0103bfb:	5e                   	pop    %esi
f0103bfc:	5f                   	pop    %edi
f0103bfd:	5d                   	pop    %ebp
f0103bfe:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bff:	50                   	push   %eax
f0103c00:	8d 83 94 8a f7 ff    	lea    -0x8756c(%ebx),%eax
f0103c06:	50                   	push   %eax
f0103c07:	68 8a 01 00 00       	push   $0x18a
f0103c0c:	8d 83 f6 93 f7 ff    	lea    -0x86c0a(%ebx),%eax
f0103c12:	50                   	push   %eax
f0103c13:	e8 99 c4 ff ff       	call   f01000b1 <_panic>
		panic("pa2page called with invalid pa");
f0103c18:	83 ec 04             	sub    $0x4,%esp
f0103c1b:	8d 83 38 8a f7 ff    	lea    -0x875c8(%ebx),%eax
f0103c21:	50                   	push   %eax
f0103c22:	6a 4f                	push   $0x4f
f0103c24:	8d 83 e1 90 f7 ff    	lea    -0x86f1f(%ebx),%eax
f0103c2a:	50                   	push   %eax
f0103c2b:	e8 81 c4 ff ff       	call   f01000b1 <_panic>

f0103c30 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0103c30:	55                   	push   %ebp
f0103c31:	89 e5                	mov    %esp,%ebp
f0103c33:	53                   	push   %ebx
f0103c34:	83 ec 10             	sub    $0x10,%esp
f0103c37:	e8 2b c5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103c3c:	81 c3 f8 94 08 00    	add    $0x894f8,%ebx
	env_free(e);
f0103c42:	ff 75 08             	pushl  0x8(%ebp)
f0103c45:	e8 df fd ff ff       	call   f0103a29 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0103c4a:	8d 83 c0 93 f7 ff    	lea    -0x86c40(%ebx),%eax
f0103c50:	89 04 24             	mov    %eax,(%esp)
f0103c53:	e8 f7 00 00 00       	call   f0103d4f <cprintf>
f0103c58:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103c5b:	83 ec 0c             	sub    $0xc,%esp
f0103c5e:	6a 00                	push   $0x0
f0103c60:	e8 c8 d2 ff ff       	call   f0100f2d <monitor>
f0103c65:	83 c4 10             	add    $0x10,%esp
f0103c68:	eb f1                	jmp    f0103c5b <env_destroy+0x2b>

f0103c6a <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103c6a:	55                   	push   %ebp
f0103c6b:	89 e5                	mov    %esp,%ebp
f0103c6d:	53                   	push   %ebx
f0103c6e:	83 ec 08             	sub    $0x8,%esp
f0103c71:	e8 f1 c4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103c76:	81 c3 be 94 08 00    	add    $0x894be,%ebx
	asm volatile(
f0103c7c:	8b 65 08             	mov    0x8(%ebp),%esp
f0103c7f:	61                   	popa   
f0103c80:	07                   	pop    %es
f0103c81:	1f                   	pop    %ds
f0103c82:	83 c4 08             	add    $0x8,%esp
f0103c85:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103c86:	8d 83 2c 94 f7 ff    	lea    -0x86bd4(%ebx),%eax
f0103c8c:	50                   	push   %eax
f0103c8d:	68 b3 01 00 00       	push   $0x1b3
f0103c92:	8d 83 f6 93 f7 ff    	lea    -0x86c0a(%ebx),%eax
f0103c98:	50                   	push   %eax
f0103c99:	e8 13 c4 ff ff       	call   f01000b1 <_panic>

f0103c9e <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103c9e:	55                   	push   %ebp
f0103c9f:	89 e5                	mov    %esp,%ebp
f0103ca1:	53                   	push   %ebx
f0103ca2:	83 ec 08             	sub    $0x8,%esp
f0103ca5:	e8 bd c4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103caa:	81 c3 8a 94 08 00    	add    $0x8948a,%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f0103cb0:	8d 83 38 94 f7 ff    	lea    -0x86bc8(%ebx),%eax
f0103cb6:	50                   	push   %eax
f0103cb7:	68 d2 01 00 00       	push   $0x1d2
f0103cbc:	8d 83 f6 93 f7 ff    	lea    -0x86c0a(%ebx),%eax
f0103cc2:	50                   	push   %eax
f0103cc3:	e8 e9 c3 ff ff       	call   f01000b1 <_panic>

f0103cc8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103cc8:	55                   	push   %ebp
f0103cc9:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103ccb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cce:	ba 70 00 00 00       	mov    $0x70,%edx
f0103cd3:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103cd4:	ba 71 00 00 00       	mov    $0x71,%edx
f0103cd9:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103cda:	0f b6 c0             	movzbl %al,%eax
}
f0103cdd:	5d                   	pop    %ebp
f0103cde:	c3                   	ret    

f0103cdf <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103cdf:	55                   	push   %ebp
f0103ce0:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103ce2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ce5:	ba 70 00 00 00       	mov    $0x70,%edx
f0103cea:	ee                   	out    %al,(%dx)
f0103ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103cee:	ba 71 00 00 00       	mov    $0x71,%edx
f0103cf3:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103cf4:	5d                   	pop    %ebp
f0103cf5:	c3                   	ret    

f0103cf6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103cf6:	55                   	push   %ebp
f0103cf7:	89 e5                	mov    %esp,%ebp
f0103cf9:	53                   	push   %ebx
f0103cfa:	83 ec 10             	sub    $0x10,%esp
f0103cfd:	e8 65 c4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103d02:	81 c3 32 94 08 00    	add    $0x89432,%ebx
	cputchar(ch);
f0103d08:	ff 75 08             	pushl  0x8(%ebp)
f0103d0b:	e8 ce c9 ff ff       	call   f01006de <cputchar>
	*cnt++;
}
f0103d10:	83 c4 10             	add    $0x10,%esp
f0103d13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d16:	c9                   	leave  
f0103d17:	c3                   	ret    

f0103d18 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103d18:	55                   	push   %ebp
f0103d19:	89 e5                	mov    %esp,%ebp
f0103d1b:	53                   	push   %ebx
f0103d1c:	83 ec 14             	sub    $0x14,%esp
f0103d1f:	e8 43 c4 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103d24:	81 c3 10 94 08 00    	add    $0x89410,%ebx
	int cnt = 0;
f0103d2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103d31:	ff 75 0c             	pushl  0xc(%ebp)
f0103d34:	ff 75 08             	pushl  0x8(%ebp)
f0103d37:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103d3a:	50                   	push   %eax
f0103d3b:	8d 83 c2 6b f7 ff    	lea    -0x8943e(%ebx),%eax
f0103d41:	50                   	push   %eax
f0103d42:	e8 17 09 00 00       	call   f010465e <vprintfmt>
	return cnt;
}
f0103d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103d4d:	c9                   	leave  
f0103d4e:	c3                   	ret    

f0103d4f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103d4f:	55                   	push   %ebp
f0103d50:	89 e5                	mov    %esp,%ebp
f0103d52:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103d55:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103d58:	50                   	push   %eax
f0103d59:	ff 75 08             	pushl  0x8(%ebp)
f0103d5c:	e8 b7 ff ff ff       	call   f0103d18 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103d61:	c9                   	leave  
f0103d62:	c3                   	ret    

f0103d63 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103d63:	55                   	push   %ebp
f0103d64:	89 e5                	mov    %esp,%ebp
f0103d66:	57                   	push   %edi
f0103d67:	56                   	push   %esi
f0103d68:	53                   	push   %ebx
f0103d69:	83 ec 04             	sub    $0x4,%esp
f0103d6c:	e8 f6 c3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103d71:	81 c3 c3 93 08 00    	add    $0x893c3,%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103d77:	c7 83 70 2a 00 00 00 	movl   $0xf0000000,0x2a70(%ebx)
f0103d7e:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103d81:	66 c7 83 74 2a 00 00 	movw   $0x10,0x2a74(%ebx)
f0103d88:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f0103d8a:	66 c7 83 d2 2a 00 00 	movw   $0x68,0x2ad2(%ebx)
f0103d91:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103d93:	c7 c0 00 c3 11 f0    	mov    $0xf011c300,%eax
f0103d99:	66 c7 40 28 67 00    	movw   $0x67,0x28(%eax)
f0103d9f:	8d b3 6c 2a 00 00    	lea    0x2a6c(%ebx),%esi
f0103da5:	66 89 70 2a          	mov    %si,0x2a(%eax)
f0103da9:	89 f2                	mov    %esi,%edx
f0103dab:	c1 ea 10             	shr    $0x10,%edx
f0103dae:	88 50 2c             	mov    %dl,0x2c(%eax)
f0103db1:	0f b6 50 2d          	movzbl 0x2d(%eax),%edx
f0103db5:	83 e2 f0             	and    $0xfffffff0,%edx
f0103db8:	83 ca 09             	or     $0x9,%edx
f0103dbb:	83 e2 9f             	and    $0xffffff9f,%edx
f0103dbe:	83 ca 80             	or     $0xffffff80,%edx
f0103dc1:	88 55 f3             	mov    %dl,-0xd(%ebp)
f0103dc4:	88 50 2d             	mov    %dl,0x2d(%eax)
f0103dc7:	0f b6 48 2e          	movzbl 0x2e(%eax),%ecx
f0103dcb:	83 e1 c0             	and    $0xffffffc0,%ecx
f0103dce:	83 c9 40             	or     $0x40,%ecx
f0103dd1:	83 e1 7f             	and    $0x7f,%ecx
f0103dd4:	88 48 2e             	mov    %cl,0x2e(%eax)
f0103dd7:	c1 ee 18             	shr    $0x18,%esi
f0103dda:	89 f1                	mov    %esi,%ecx
f0103ddc:	88 48 2f             	mov    %cl,0x2f(%eax)
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103ddf:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
f0103de3:	83 e2 ef             	and    $0xffffffef,%edx
f0103de6:	88 50 2d             	mov    %dl,0x2d(%eax)
	asm volatile("ltr %0" : : "r" (sel));
f0103de9:	b8 28 00 00 00       	mov    $0x28,%eax
f0103dee:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103df1:	8d 83 d4 1e 00 00    	lea    0x1ed4(%ebx),%eax
f0103df7:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103dfa:	83 c4 04             	add    $0x4,%esp
f0103dfd:	5b                   	pop    %ebx
f0103dfe:	5e                   	pop    %esi
f0103dff:	5f                   	pop    %edi
f0103e00:	5d                   	pop    %ebp
f0103e01:	c3                   	ret    

f0103e02 <trap_init>:
{
f0103e02:	55                   	push   %ebp
f0103e03:	89 e5                	mov    %esp,%ebp
	trap_init_percpu();
f0103e05:	e8 59 ff ff ff       	call   f0103d63 <trap_init_percpu>
}
f0103e0a:	5d                   	pop    %ebp
f0103e0b:	c3                   	ret    

f0103e0c <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103e0c:	55                   	push   %ebp
f0103e0d:	89 e5                	mov    %esp,%ebp
f0103e0f:	56                   	push   %esi
f0103e10:	53                   	push   %ebx
f0103e11:	e8 51 c3 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103e16:	81 c3 1e 93 08 00    	add    $0x8931e,%ebx
f0103e1c:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103e1f:	83 ec 08             	sub    $0x8,%esp
f0103e22:	ff 36                	pushl  (%esi)
f0103e24:	8d 83 54 94 f7 ff    	lea    -0x86bac(%ebx),%eax
f0103e2a:	50                   	push   %eax
f0103e2b:	e8 1f ff ff ff       	call   f0103d4f <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103e30:	83 c4 08             	add    $0x8,%esp
f0103e33:	ff 76 04             	pushl  0x4(%esi)
f0103e36:	8d 83 63 94 f7 ff    	lea    -0x86b9d(%ebx),%eax
f0103e3c:	50                   	push   %eax
f0103e3d:	e8 0d ff ff ff       	call   f0103d4f <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103e42:	83 c4 08             	add    $0x8,%esp
f0103e45:	ff 76 08             	pushl  0x8(%esi)
f0103e48:	8d 83 72 94 f7 ff    	lea    -0x86b8e(%ebx),%eax
f0103e4e:	50                   	push   %eax
f0103e4f:	e8 fb fe ff ff       	call   f0103d4f <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103e54:	83 c4 08             	add    $0x8,%esp
f0103e57:	ff 76 0c             	pushl  0xc(%esi)
f0103e5a:	8d 83 81 94 f7 ff    	lea    -0x86b7f(%ebx),%eax
f0103e60:	50                   	push   %eax
f0103e61:	e8 e9 fe ff ff       	call   f0103d4f <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103e66:	83 c4 08             	add    $0x8,%esp
f0103e69:	ff 76 10             	pushl  0x10(%esi)
f0103e6c:	8d 83 90 94 f7 ff    	lea    -0x86b70(%ebx),%eax
f0103e72:	50                   	push   %eax
f0103e73:	e8 d7 fe ff ff       	call   f0103d4f <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103e78:	83 c4 08             	add    $0x8,%esp
f0103e7b:	ff 76 14             	pushl  0x14(%esi)
f0103e7e:	8d 83 9f 94 f7 ff    	lea    -0x86b61(%ebx),%eax
f0103e84:	50                   	push   %eax
f0103e85:	e8 c5 fe ff ff       	call   f0103d4f <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103e8a:	83 c4 08             	add    $0x8,%esp
f0103e8d:	ff 76 18             	pushl  0x18(%esi)
f0103e90:	8d 83 ae 94 f7 ff    	lea    -0x86b52(%ebx),%eax
f0103e96:	50                   	push   %eax
f0103e97:	e8 b3 fe ff ff       	call   f0103d4f <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103e9c:	83 c4 08             	add    $0x8,%esp
f0103e9f:	ff 76 1c             	pushl  0x1c(%esi)
f0103ea2:	8d 83 bd 94 f7 ff    	lea    -0x86b43(%ebx),%eax
f0103ea8:	50                   	push   %eax
f0103ea9:	e8 a1 fe ff ff       	call   f0103d4f <cprintf>
}
f0103eae:	83 c4 10             	add    $0x10,%esp
f0103eb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103eb4:	5b                   	pop    %ebx
f0103eb5:	5e                   	pop    %esi
f0103eb6:	5d                   	pop    %ebp
f0103eb7:	c3                   	ret    

f0103eb8 <print_trapframe>:
{
f0103eb8:	55                   	push   %ebp
f0103eb9:	89 e5                	mov    %esp,%ebp
f0103ebb:	57                   	push   %edi
f0103ebc:	56                   	push   %esi
f0103ebd:	53                   	push   %ebx
f0103ebe:	83 ec 14             	sub    $0x14,%esp
f0103ec1:	e8 a1 c2 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0103ec6:	81 c3 6e 92 08 00    	add    $0x8926e,%ebx
f0103ecc:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("TRAP frame at %p\n", tf);
f0103ecf:	56                   	push   %esi
f0103ed0:	8d 83 f3 95 f7 ff    	lea    -0x86a0d(%ebx),%eax
f0103ed6:	50                   	push   %eax
f0103ed7:	e8 73 fe ff ff       	call   f0103d4f <cprintf>
	print_regs(&tf->tf_regs);
f0103edc:	89 34 24             	mov    %esi,(%esp)
f0103edf:	e8 28 ff ff ff       	call   f0103e0c <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ee4:	83 c4 08             	add    $0x8,%esp
f0103ee7:	0f b7 46 20          	movzwl 0x20(%esi),%eax
f0103eeb:	50                   	push   %eax
f0103eec:	8d 83 0e 95 f7 ff    	lea    -0x86af2(%ebx),%eax
f0103ef2:	50                   	push   %eax
f0103ef3:	e8 57 fe ff ff       	call   f0103d4f <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ef8:	83 c4 08             	add    $0x8,%esp
f0103efb:	0f b7 46 24          	movzwl 0x24(%esi),%eax
f0103eff:	50                   	push   %eax
f0103f00:	8d 83 21 95 f7 ff    	lea    -0x86adf(%ebx),%eax
f0103f06:	50                   	push   %eax
f0103f07:	e8 43 fe ff ff       	call   f0103d4f <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f0c:	8b 56 28             	mov    0x28(%esi),%edx
	if (trapno < ARRAY_SIZE(excnames))
f0103f0f:	83 c4 10             	add    $0x10,%esp
f0103f12:	83 fa 13             	cmp    $0x13,%edx
f0103f15:	0f 86 e9 00 00 00    	jbe    f0104004 <print_trapframe+0x14c>
	return "(unknown trap)";
f0103f1b:	83 fa 30             	cmp    $0x30,%edx
f0103f1e:	8d 83 cc 94 f7 ff    	lea    -0x86b34(%ebx),%eax
f0103f24:	8d 8b d8 94 f7 ff    	lea    -0x86b28(%ebx),%ecx
f0103f2a:	0f 45 c1             	cmovne %ecx,%eax
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103f2d:	83 ec 04             	sub    $0x4,%esp
f0103f30:	50                   	push   %eax
f0103f31:	52                   	push   %edx
f0103f32:	8d 83 34 95 f7 ff    	lea    -0x86acc(%ebx),%eax
f0103f38:	50                   	push   %eax
f0103f39:	e8 11 fe ff ff       	call   f0103d4f <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f3e:	83 c4 10             	add    $0x10,%esp
f0103f41:	39 b3 4c 2a 00 00    	cmp    %esi,0x2a4c(%ebx)
f0103f47:	0f 84 c3 00 00 00    	je     f0104010 <print_trapframe+0x158>
	cprintf("  err  0x%08x", tf->tf_err);
f0103f4d:	83 ec 08             	sub    $0x8,%esp
f0103f50:	ff 76 2c             	pushl  0x2c(%esi)
f0103f53:	8d 83 55 95 f7 ff    	lea    -0x86aab(%ebx),%eax
f0103f59:	50                   	push   %eax
f0103f5a:	e8 f0 fd ff ff       	call   f0103d4f <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103f5f:	83 c4 10             	add    $0x10,%esp
f0103f62:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0103f66:	0f 85 c9 00 00 00    	jne    f0104035 <print_trapframe+0x17d>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103f6c:	8b 46 2c             	mov    0x2c(%esi),%eax
		cprintf(" [%s, %s, %s]\n",
f0103f6f:	89 c2                	mov    %eax,%edx
f0103f71:	83 e2 01             	and    $0x1,%edx
f0103f74:	8d 8b e7 94 f7 ff    	lea    -0x86b19(%ebx),%ecx
f0103f7a:	8d 93 f2 94 f7 ff    	lea    -0x86b0e(%ebx),%edx
f0103f80:	0f 44 ca             	cmove  %edx,%ecx
f0103f83:	89 c2                	mov    %eax,%edx
f0103f85:	83 e2 02             	and    $0x2,%edx
f0103f88:	8d 93 fe 94 f7 ff    	lea    -0x86b02(%ebx),%edx
f0103f8e:	8d bb 04 95 f7 ff    	lea    -0x86afc(%ebx),%edi
f0103f94:	0f 44 d7             	cmove  %edi,%edx
f0103f97:	83 e0 04             	and    $0x4,%eax
f0103f9a:	8d 83 09 95 f7 ff    	lea    -0x86af7(%ebx),%eax
f0103fa0:	8d bb 1e 96 f7 ff    	lea    -0x869e2(%ebx),%edi
f0103fa6:	0f 44 c7             	cmove  %edi,%eax
f0103fa9:	51                   	push   %ecx
f0103faa:	52                   	push   %edx
f0103fab:	50                   	push   %eax
f0103fac:	8d 83 63 95 f7 ff    	lea    -0x86a9d(%ebx),%eax
f0103fb2:	50                   	push   %eax
f0103fb3:	e8 97 fd ff ff       	call   f0103d4f <cprintf>
f0103fb8:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103fbb:	83 ec 08             	sub    $0x8,%esp
f0103fbe:	ff 76 30             	pushl  0x30(%esi)
f0103fc1:	8d 83 72 95 f7 ff    	lea    -0x86a8e(%ebx),%eax
f0103fc7:	50                   	push   %eax
f0103fc8:	e8 82 fd ff ff       	call   f0103d4f <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103fcd:	83 c4 08             	add    $0x8,%esp
f0103fd0:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103fd4:	50                   	push   %eax
f0103fd5:	8d 83 81 95 f7 ff    	lea    -0x86a7f(%ebx),%eax
f0103fdb:	50                   	push   %eax
f0103fdc:	e8 6e fd ff ff       	call   f0103d4f <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103fe1:	83 c4 08             	add    $0x8,%esp
f0103fe4:	ff 76 38             	pushl  0x38(%esi)
f0103fe7:	8d 83 94 95 f7 ff    	lea    -0x86a6c(%ebx),%eax
f0103fed:	50                   	push   %eax
f0103fee:	e8 5c fd ff ff       	call   f0103d4f <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103ff3:	83 c4 10             	add    $0x10,%esp
f0103ff6:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0103ffa:	75 50                	jne    f010404c <print_trapframe+0x194>
}
f0103ffc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103fff:	5b                   	pop    %ebx
f0104000:	5e                   	pop    %esi
f0104001:	5f                   	pop    %edi
f0104002:	5d                   	pop    %ebp
f0104003:	c3                   	ret    
		return excnames[trapno];
f0104004:	8b 84 93 6c 1f 00 00 	mov    0x1f6c(%ebx,%edx,4),%eax
f010400b:	e9 1d ff ff ff       	jmp    f0103f2d <print_trapframe+0x75>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104010:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f0104014:	0f 85 33 ff ff ff    	jne    f0103f4d <print_trapframe+0x95>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010401a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010401d:	83 ec 08             	sub    $0x8,%esp
f0104020:	50                   	push   %eax
f0104021:	8d 83 46 95 f7 ff    	lea    -0x86aba(%ebx),%eax
f0104027:	50                   	push   %eax
f0104028:	e8 22 fd ff ff       	call   f0103d4f <cprintf>
f010402d:	83 c4 10             	add    $0x10,%esp
f0104030:	e9 18 ff ff ff       	jmp    f0103f4d <print_trapframe+0x95>
		cprintf("\n");
f0104035:	83 ec 0c             	sub    $0xc,%esp
f0104038:	8d 83 8e 93 f7 ff    	lea    -0x86c72(%ebx),%eax
f010403e:	50                   	push   %eax
f010403f:	e8 0b fd ff ff       	call   f0103d4f <cprintf>
f0104044:	83 c4 10             	add    $0x10,%esp
f0104047:	e9 6f ff ff ff       	jmp    f0103fbb <print_trapframe+0x103>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010404c:	83 ec 08             	sub    $0x8,%esp
f010404f:	ff 76 3c             	pushl  0x3c(%esi)
f0104052:	8d 83 a3 95 f7 ff    	lea    -0x86a5d(%ebx),%eax
f0104058:	50                   	push   %eax
f0104059:	e8 f1 fc ff ff       	call   f0103d4f <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010405e:	83 c4 08             	add    $0x8,%esp
f0104061:	0f b7 46 40          	movzwl 0x40(%esi),%eax
f0104065:	50                   	push   %eax
f0104066:	8d 83 b2 95 f7 ff    	lea    -0x86a4e(%ebx),%eax
f010406c:	50                   	push   %eax
f010406d:	e8 dd fc ff ff       	call   f0103d4f <cprintf>
f0104072:	83 c4 10             	add    $0x10,%esp
}
f0104075:	eb 85                	jmp    f0103ffc <print_trapframe+0x144>

f0104077 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104077:	55                   	push   %ebp
f0104078:	89 e5                	mov    %esp,%ebp
f010407a:	57                   	push   %edi
f010407b:	56                   	push   %esi
f010407c:	53                   	push   %ebx
f010407d:	83 ec 0c             	sub    $0xc,%esp
f0104080:	e8 e2 c0 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104085:	81 c3 af 90 08 00    	add    $0x890af,%ebx
f010408b:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010408e:	fc                   	cld    
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f010408f:	9c                   	pushf  
f0104090:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104091:	f6 c4 02             	test   $0x2,%ah
f0104094:	74 1f                	je     f01040b5 <trap+0x3e>
f0104096:	8d 83 c5 95 f7 ff    	lea    -0x86a3b(%ebx),%eax
f010409c:	50                   	push   %eax
f010409d:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f01040a3:	50                   	push   %eax
f01040a4:	68 a8 00 00 00       	push   $0xa8
f01040a9:	8d 83 de 95 f7 ff    	lea    -0x86a22(%ebx),%eax
f01040af:	50                   	push   %eax
f01040b0:	e8 fc bf ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01040b5:	83 ec 08             	sub    $0x8,%esp
f01040b8:	56                   	push   %esi
f01040b9:	8d 83 ea 95 f7 ff    	lea    -0x86a16(%ebx),%eax
f01040bf:	50                   	push   %eax
f01040c0:	e8 8a fc ff ff       	call   f0103d4f <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01040c5:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01040c9:	83 e0 03             	and    $0x3,%eax
f01040cc:	83 c4 10             	add    $0x10,%esp
f01040cf:	66 83 f8 03          	cmp    $0x3,%ax
f01040d3:	75 1d                	jne    f01040f2 <trap+0x7b>
		// Trapped from user mode.
		assert(curenv);
f01040d5:	c7 c0 60 f3 18 f0    	mov    $0xf018f360,%eax
f01040db:	8b 00                	mov    (%eax),%eax
f01040dd:	85 c0                	test   %eax,%eax
f01040df:	74 68                	je     f0104149 <trap+0xd2>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01040e1:	b9 11 00 00 00       	mov    $0x11,%ecx
f01040e6:	89 c7                	mov    %eax,%edi
f01040e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01040ea:	c7 c0 60 f3 18 f0    	mov    $0xf018f360,%eax
f01040f0:	8b 30                	mov    (%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01040f2:	89 b3 4c 2a 00 00    	mov    %esi,0x2a4c(%ebx)
	print_trapframe(tf);
f01040f8:	83 ec 0c             	sub    $0xc,%esp
f01040fb:	56                   	push   %esi
f01040fc:	e8 b7 fd ff ff       	call   f0103eb8 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104101:	83 c4 10             	add    $0x10,%esp
f0104104:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104109:	74 5d                	je     f0104168 <trap+0xf1>
		env_destroy(curenv);
f010410b:	83 ec 0c             	sub    $0xc,%esp
f010410e:	c7 c6 60 f3 18 f0    	mov    $0xf018f360,%esi
f0104114:	ff 36                	pushl  (%esi)
f0104116:	e8 15 fb ff ff       	call   f0103c30 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010411b:	8b 06                	mov    (%esi),%eax
f010411d:	83 c4 10             	add    $0x10,%esp
f0104120:	85 c0                	test   %eax,%eax
f0104122:	74 06                	je     f010412a <trap+0xb3>
f0104124:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104128:	74 59                	je     f0104183 <trap+0x10c>
f010412a:	8d 83 68 97 f7 ff    	lea    -0x86898(%ebx),%eax
f0104130:	50                   	push   %eax
f0104131:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0104137:	50                   	push   %eax
f0104138:	68 c0 00 00 00       	push   $0xc0
f010413d:	8d 83 de 95 f7 ff    	lea    -0x86a22(%ebx),%eax
f0104143:	50                   	push   %eax
f0104144:	e8 68 bf ff ff       	call   f01000b1 <_panic>
		assert(curenv);
f0104149:	8d 83 05 96 f7 ff    	lea    -0x869fb(%ebx),%eax
f010414f:	50                   	push   %eax
f0104150:	8d 83 0a 84 f7 ff    	lea    -0x87bf6(%ebx),%eax
f0104156:	50                   	push   %eax
f0104157:	68 ae 00 00 00       	push   $0xae
f010415c:	8d 83 de 95 f7 ff    	lea    -0x86a22(%ebx),%eax
f0104162:	50                   	push   %eax
f0104163:	e8 49 bf ff ff       	call   f01000b1 <_panic>
		panic("unhandled trap in kernel");
f0104168:	83 ec 04             	sub    $0x4,%esp
f010416b:	8d 83 0c 96 f7 ff    	lea    -0x869f4(%ebx),%eax
f0104171:	50                   	push   %eax
f0104172:	68 97 00 00 00       	push   $0x97
f0104177:	8d 83 de 95 f7 ff    	lea    -0x86a22(%ebx),%eax
f010417d:	50                   	push   %eax
f010417e:	e8 2e bf ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0104183:	83 ec 0c             	sub    $0xc,%esp
f0104186:	50                   	push   %eax
f0104187:	e8 12 fb ff ff       	call   f0103c9e <env_run>

f010418c <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010418c:	55                   	push   %ebp
f010418d:	89 e5                	mov    %esp,%ebp
f010418f:	57                   	push   %edi
f0104190:	56                   	push   %esi
f0104191:	53                   	push   %ebx
f0104192:	83 ec 0c             	sub    $0xc,%esp
f0104195:	e8 cd bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010419a:	81 c3 9a 8f 08 00    	add    $0x88f9a,%ebx
f01041a0:	8b 7d 08             	mov    0x8(%ebp),%edi
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01041a3:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01041a6:	ff 77 30             	pushl  0x30(%edi)
f01041a9:	50                   	push   %eax
f01041aa:	c7 c6 60 f3 18 f0    	mov    $0xf018f360,%esi
f01041b0:	8b 06                	mov    (%esi),%eax
f01041b2:	ff 70 48             	pushl  0x48(%eax)
f01041b5:	8d 83 94 97 f7 ff    	lea    -0x8686c(%ebx),%eax
f01041bb:	50                   	push   %eax
f01041bc:	e8 8e fb ff ff       	call   f0103d4f <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01041c1:	89 3c 24             	mov    %edi,(%esp)
f01041c4:	e8 ef fc ff ff       	call   f0103eb8 <print_trapframe>
	env_destroy(curenv);
f01041c9:	83 c4 04             	add    $0x4,%esp
f01041cc:	ff 36                	pushl  (%esi)
f01041ce:	e8 5d fa ff ff       	call   f0103c30 <env_destroy>
}
f01041d3:	83 c4 10             	add    $0x10,%esp
f01041d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041d9:	5b                   	pop    %ebx
f01041da:	5e                   	pop    %esi
f01041db:	5f                   	pop    %edi
f01041dc:	5d                   	pop    %ebp
f01041dd:	c3                   	ret    

f01041de <syscall>:
f01041de:	55                   	push   %ebp
f01041df:	89 e5                	mov    %esp,%ebp
f01041e1:	53                   	push   %ebx
f01041e2:	83 ec 08             	sub    $0x8,%esp
f01041e5:	e8 7d bf ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f01041ea:	81 c3 4a 8f 08 00    	add    $0x88f4a,%ebx
f01041f0:	8d 83 b8 97 f7 ff    	lea    -0x86848(%ebx),%eax
f01041f6:	50                   	push   %eax
f01041f7:	6a 49                	push   $0x49
f01041f9:	8d 83 d0 97 f7 ff    	lea    -0x86830(%ebx),%eax
f01041ff:	50                   	push   %eax
f0104200:	e8 ac be ff ff       	call   f01000b1 <_panic>

f0104205 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104205:	55                   	push   %ebp
f0104206:	89 e5                	mov    %esp,%ebp
f0104208:	57                   	push   %edi
f0104209:	56                   	push   %esi
f010420a:	53                   	push   %ebx
f010420b:	83 ec 14             	sub    $0x14,%esp
f010420e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104211:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104214:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104217:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010421a:	8b 32                	mov    (%edx),%esi
f010421c:	8b 01                	mov    (%ecx),%eax
f010421e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104221:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104228:	eb 2f                	jmp    f0104259 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f010422a:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f010422d:	39 c6                	cmp    %eax,%esi
f010422f:	7f 49                	jg     f010427a <stab_binsearch+0x75>
f0104231:	0f b6 0a             	movzbl (%edx),%ecx
f0104234:	83 ea 0c             	sub    $0xc,%edx
f0104237:	39 f9                	cmp    %edi,%ecx
f0104239:	75 ef                	jne    f010422a <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010423b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010423e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104241:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104245:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104248:	73 35                	jae    f010427f <stab_binsearch+0x7a>
			*region_left = m;
f010424a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010424d:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f010424f:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104252:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104259:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f010425c:	7f 4e                	jg     f01042ac <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f010425e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104261:	01 f0                	add    %esi,%eax
f0104263:	89 c3                	mov    %eax,%ebx
f0104265:	c1 eb 1f             	shr    $0x1f,%ebx
f0104268:	01 c3                	add    %eax,%ebx
f010426a:	d1 fb                	sar    %ebx
f010426c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010426f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104272:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104276:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104278:	eb b3                	jmp    f010422d <stab_binsearch+0x28>
			l = true_m + 1;
f010427a:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f010427d:	eb da                	jmp    f0104259 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f010427f:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104282:	76 14                	jbe    f0104298 <stab_binsearch+0x93>
			*region_right = m - 1;
f0104284:	83 e8 01             	sub    $0x1,%eax
f0104287:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010428a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010428d:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f010428f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104296:	eb c1                	jmp    f0104259 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104298:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010429b:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010429d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01042a1:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f01042a3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01042aa:	eb ad                	jmp    f0104259 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f01042ac:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01042b0:	74 16                	je     f01042c8 <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01042b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042b5:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01042b7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01042ba:	8b 0e                	mov    (%esi),%ecx
f01042bc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01042bf:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01042c2:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f01042c6:	eb 12                	jmp    f01042da <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f01042c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042cb:	8b 00                	mov    (%eax),%eax
f01042cd:	83 e8 01             	sub    $0x1,%eax
f01042d0:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01042d3:	89 07                	mov    %eax,(%edi)
f01042d5:	eb 16                	jmp    f01042ed <stab_binsearch+0xe8>
		     l--)
f01042d7:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01042da:	39 c1                	cmp    %eax,%ecx
f01042dc:	7d 0a                	jge    f01042e8 <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f01042de:	0f b6 1a             	movzbl (%edx),%ebx
f01042e1:	83 ea 0c             	sub    $0xc,%edx
f01042e4:	39 fb                	cmp    %edi,%ebx
f01042e6:	75 ef                	jne    f01042d7 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f01042e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01042eb:	89 07                	mov    %eax,(%edi)
	}
}
f01042ed:	83 c4 14             	add    $0x14,%esp
f01042f0:	5b                   	pop    %ebx
f01042f1:	5e                   	pop    %esi
f01042f2:	5f                   	pop    %edi
f01042f3:	5d                   	pop    %ebp
f01042f4:	c3                   	ret    

f01042f5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01042f5:	55                   	push   %ebp
f01042f6:	89 e5                	mov    %esp,%ebp
f01042f8:	57                   	push   %edi
f01042f9:	56                   	push   %esi
f01042fa:	53                   	push   %ebx
f01042fb:	83 ec 4c             	sub    $0x4c,%esp
f01042fe:	e8 b6 f4 ff ff       	call   f01037b9 <__x86.get_pc_thunk.di>
f0104303:	81 c7 31 8e 08 00    	add    $0x88e31,%edi
f0104309:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010430c:	8d 87 df 97 f7 ff    	lea    -0x86821(%edi),%eax
f0104312:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0104314:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010431b:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f010431e:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104325:	8b 45 08             	mov    0x8(%ebp),%eax
f0104328:	89 46 10             	mov    %eax,0x10(%esi)
	info->eip_fn_narg = 0;
f010432b:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104332:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0104337:	77 21                	ja     f010435a <debuginfo_eip+0x65>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104339:	a1 00 00 20 00       	mov    0x200000,%eax
f010433e:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0104341:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104346:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f010434c:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f010434f:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f0104355:	89 5d bc             	mov    %ebx,-0x44(%ebp)
f0104358:	eb 21                	jmp    f010437b <debuginfo_eip+0x86>
		stabstr_end = __STABSTR_END__;
f010435a:	c7 c0 2b 20 11 f0    	mov    $0xf011202b,%eax
f0104360:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104363:	c7 c0 15 f4 10 f0    	mov    $0xf010f415,%eax
f0104369:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stab_end = __STAB_END__;
f010436c:	c7 c0 14 f4 10 f0    	mov    $0xf010f414,%eax
		stabs = __STAB_BEGIN__;
f0104372:	c7 c3 10 6b 10 f0    	mov    $0xf0106b10,%ebx
f0104378:	89 5d b8             	mov    %ebx,-0x48(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010437b:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010437e:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0104381:	0f 83 b1 01 00 00    	jae    f0104538 <debuginfo_eip+0x243>
f0104387:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010438b:	0f 85 ae 01 00 00    	jne    f010453f <debuginfo_eip+0x24a>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104391:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104398:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f010439b:	29 d8                	sub    %ebx,%eax
f010439d:	c1 f8 02             	sar    $0x2,%eax
f01043a0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01043a6:	83 e8 01             	sub    $0x1,%eax
f01043a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01043ac:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01043af:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01043b2:	ff 75 08             	pushl  0x8(%ebp)
f01043b5:	6a 64                	push   $0x64
f01043b7:	89 d8                	mov    %ebx,%eax
f01043b9:	e8 47 fe ff ff       	call   f0104205 <stab_binsearch>
	if (lfile == 0)
f01043be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043c1:	83 c4 08             	add    $0x8,%esp
f01043c4:	85 c0                	test   %eax,%eax
f01043c6:	0f 84 7a 01 00 00    	je     f0104546 <debuginfo_eip+0x251>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01043cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01043cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01043d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01043d5:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01043d8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01043db:	ff 75 08             	pushl  0x8(%ebp)
f01043de:	6a 24                	push   $0x24
f01043e0:	89 d8                	mov    %ebx,%eax
f01043e2:	e8 1e fe ff ff       	call   f0104205 <stab_binsearch>

	if (lfun <= rfun) {
f01043e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01043ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01043ed:	83 c4 08             	add    $0x8,%esp
f01043f0:	39 d0                	cmp    %edx,%eax
f01043f2:	0f 8f 85 00 00 00    	jg     f010447d <debuginfo_eip+0x188>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01043f8:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01043fb:	8d 1c 8b             	lea    (%ebx,%ecx,4),%ebx
f01043fe:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0104401:	8b 0b                	mov    (%ebx),%ecx
f0104403:	89 cb                	mov    %ecx,%ebx
f0104405:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104408:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f010440b:	39 cb                	cmp    %ecx,%ebx
f010440d:	73 06                	jae    f0104415 <debuginfo_eip+0x120>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010440f:	03 5d b4             	add    -0x4c(%ebp),%ebx
f0104412:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104415:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0104418:	8b 4b 08             	mov    0x8(%ebx),%ecx
f010441b:	89 4e 10             	mov    %ecx,0x10(%esi)
		addr -= info->eip_fn_addr;
f010441e:	29 4d 08             	sub    %ecx,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0104421:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104424:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104427:	83 ec 08             	sub    $0x8,%esp
f010442a:	6a 3a                	push   $0x3a
f010442c:	ff 76 08             	pushl  0x8(%esi)
f010442f:	89 fb                	mov    %edi,%ebx
f0104431:	e8 ee 09 00 00       	call   f0104e24 <strfind>
f0104436:	2b 46 08             	sub    0x8(%esi),%eax
f0104439:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010443c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010443f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104442:	83 c4 08             	add    $0x8,%esp
f0104445:	ff 75 08             	pushl  0x8(%ebp)
f0104448:	6a 44                	push   $0x44
f010444a:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010444d:	89 f8                	mov    %edi,%eax
f010444f:	e8 b1 fd ff ff       	call   f0104205 <stab_binsearch>
	// cprintf("symbol table: %d\n", stabs[lline].n_desc);
	info->eip_line = stabs[lline].n_desc;
f0104454:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104457:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010445a:	c1 e2 02             	shl    $0x2,%edx
f010445d:	0f b7 4c 17 06       	movzwl 0x6(%edi,%edx,1),%ecx
f0104462:	89 4e 04             	mov    %ecx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104465:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104468:	8d 54 17 04          	lea    0x4(%edi,%edx,1),%edx
f010446c:	83 c4 10             	add    $0x10,%esp
f010446f:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104473:	bf 01 00 00 00       	mov    $0x1,%edi
f0104478:	89 75 0c             	mov    %esi,0xc(%ebp)
f010447b:	eb 1f                	jmp    f010449c <debuginfo_eip+0x1a7>
		info->eip_fn_addr = addr;
f010447d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104480:	89 46 10             	mov    %eax,0x10(%esi)
		lline = lfile;
f0104483:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104486:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104489:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010448c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010448f:	eb 96                	jmp    f0104427 <debuginfo_eip+0x132>
f0104491:	83 e8 01             	sub    $0x1,%eax
f0104494:	83 ea 0c             	sub    $0xc,%edx
f0104497:	89 f9                	mov    %edi,%ecx
f0104499:	88 4d c4             	mov    %cl,-0x3c(%ebp)
f010449c:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f010449f:	39 c3                	cmp    %eax,%ebx
f01044a1:	7f 24                	jg     f01044c7 <debuginfo_eip+0x1d2>
	       && stabs[lline].n_type != N_SOL
f01044a3:	0f b6 0a             	movzbl (%edx),%ecx
f01044a6:	80 f9 84             	cmp    $0x84,%cl
f01044a9:	74 42                	je     f01044ed <debuginfo_eip+0x1f8>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01044ab:	80 f9 64             	cmp    $0x64,%cl
f01044ae:	75 e1                	jne    f0104491 <debuginfo_eip+0x19c>
f01044b0:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f01044b4:	74 db                	je     f0104491 <debuginfo_eip+0x19c>
f01044b6:	8b 75 0c             	mov    0xc(%ebp),%esi
f01044b9:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01044bd:	74 37                	je     f01044f6 <debuginfo_eip+0x201>
f01044bf:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01044c2:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01044c5:	eb 2f                	jmp    f01044f6 <debuginfo_eip+0x201>
f01044c7:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01044ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01044cd:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01044d0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01044d5:	39 da                	cmp    %ebx,%edx
f01044d7:	7d 79                	jge    f0104552 <debuginfo_eip+0x25d>
		for (lline = lfun + 1;
f01044d9:	83 c2 01             	add    $0x1,%edx
f01044dc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01044df:	89 d0                	mov    %edx,%eax
f01044e1:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01044e4:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01044e7:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01044eb:	eb 32                	jmp    f010451f <debuginfo_eip+0x22a>
f01044ed:	8b 75 0c             	mov    0xc(%ebp),%esi
f01044f0:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01044f4:	75 1d                	jne    f0104513 <debuginfo_eip+0x21e>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01044f6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01044f9:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01044fc:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01044ff:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104502:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104505:	29 f8                	sub    %edi,%eax
f0104507:	39 c2                	cmp    %eax,%edx
f0104509:	73 bf                	jae    f01044ca <debuginfo_eip+0x1d5>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010450b:	89 f8                	mov    %edi,%eax
f010450d:	01 d0                	add    %edx,%eax
f010450f:	89 06                	mov    %eax,(%esi)
f0104511:	eb b7                	jmp    f01044ca <debuginfo_eip+0x1d5>
f0104513:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104516:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104519:	eb db                	jmp    f01044f6 <debuginfo_eip+0x201>
			info->eip_fn_narg++;
f010451b:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f010451f:	39 c3                	cmp    %eax,%ebx
f0104521:	7e 2a                	jle    f010454d <debuginfo_eip+0x258>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104523:	0f b6 0a             	movzbl (%edx),%ecx
f0104526:	83 c0 01             	add    $0x1,%eax
f0104529:	83 c2 0c             	add    $0xc,%edx
f010452c:	80 f9 a0             	cmp    $0xa0,%cl
f010452f:	74 ea                	je     f010451b <debuginfo_eip+0x226>
	return 0;
f0104531:	b8 00 00 00 00       	mov    $0x0,%eax
f0104536:	eb 1a                	jmp    f0104552 <debuginfo_eip+0x25d>
		return -1;
f0104538:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010453d:	eb 13                	jmp    f0104552 <debuginfo_eip+0x25d>
f010453f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104544:	eb 0c                	jmp    f0104552 <debuginfo_eip+0x25d>
		return -1;
f0104546:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010454b:	eb 05                	jmp    f0104552 <debuginfo_eip+0x25d>
	return 0;
f010454d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104552:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104555:	5b                   	pop    %ebx
f0104556:	5e                   	pop    %esi
f0104557:	5f                   	pop    %edi
f0104558:	5d                   	pop    %ebp
f0104559:	c3                   	ret    

f010455a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010455a:	55                   	push   %ebp
f010455b:	89 e5                	mov    %esp,%ebp
f010455d:	57                   	push   %edi
f010455e:	56                   	push   %esi
f010455f:	53                   	push   %ebx
f0104560:	83 ec 2c             	sub    $0x2c,%esp
f0104563:	e8 49 f2 ff ff       	call   f01037b1 <__x86.get_pc_thunk.cx>
f0104568:	81 c1 cc 8b 08 00    	add    $0x88bcc,%ecx
f010456e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0104571:	89 c7                	mov    %eax,%edi
f0104573:	89 d6                	mov    %edx,%esi
f0104575:	8b 45 08             	mov    0x8(%ebp),%eax
f0104578:	8b 55 0c             	mov    0xc(%ebp),%edx
f010457b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010457e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104581:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104584:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104589:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f010458c:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f010458f:	39 d3                	cmp    %edx,%ebx
f0104591:	72 09                	jb     f010459c <printnum+0x42>
f0104593:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104596:	0f 87 83 00 00 00    	ja     f010461f <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010459c:	83 ec 0c             	sub    $0xc,%esp
f010459f:	ff 75 18             	pushl  0x18(%ebp)
f01045a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01045a5:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01045a8:	53                   	push   %ebx
f01045a9:	ff 75 10             	pushl  0x10(%ebp)
f01045ac:	83 ec 08             	sub    $0x8,%esp
f01045af:	ff 75 dc             	pushl  -0x24(%ebp)
f01045b2:	ff 75 d8             	pushl  -0x28(%ebp)
f01045b5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01045b8:	ff 75 d0             	pushl  -0x30(%ebp)
f01045bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01045be:	e8 7d 0a 00 00       	call   f0105040 <__udivdi3>
f01045c3:	83 c4 18             	add    $0x18,%esp
f01045c6:	52                   	push   %edx
f01045c7:	50                   	push   %eax
f01045c8:	89 f2                	mov    %esi,%edx
f01045ca:	89 f8                	mov    %edi,%eax
f01045cc:	e8 89 ff ff ff       	call   f010455a <printnum>
f01045d1:	83 c4 20             	add    $0x20,%esp
f01045d4:	eb 13                	jmp    f01045e9 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01045d6:	83 ec 08             	sub    $0x8,%esp
f01045d9:	56                   	push   %esi
f01045da:	ff 75 18             	pushl  0x18(%ebp)
f01045dd:	ff d7                	call   *%edi
f01045df:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f01045e2:	83 eb 01             	sub    $0x1,%ebx
f01045e5:	85 db                	test   %ebx,%ebx
f01045e7:	7f ed                	jg     f01045d6 <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01045e9:	83 ec 08             	sub    $0x8,%esp
f01045ec:	56                   	push   %esi
f01045ed:	83 ec 04             	sub    $0x4,%esp
f01045f0:	ff 75 dc             	pushl  -0x24(%ebp)
f01045f3:	ff 75 d8             	pushl  -0x28(%ebp)
f01045f6:	ff 75 d4             	pushl  -0x2c(%ebp)
f01045f9:	ff 75 d0             	pushl  -0x30(%ebp)
f01045fc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01045ff:	89 f3                	mov    %esi,%ebx
f0104601:	e8 5a 0b 00 00       	call   f0105160 <__umoddi3>
f0104606:	83 c4 14             	add    $0x14,%esp
f0104609:	0f be 84 06 e9 97 f7 	movsbl -0x86817(%esi,%eax,1),%eax
f0104610:	ff 
f0104611:	50                   	push   %eax
f0104612:	ff d7                	call   *%edi
}
f0104614:	83 c4 10             	add    $0x10,%esp
f0104617:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010461a:	5b                   	pop    %ebx
f010461b:	5e                   	pop    %esi
f010461c:	5f                   	pop    %edi
f010461d:	5d                   	pop    %ebp
f010461e:	c3                   	ret    
f010461f:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104622:	eb be                	jmp    f01045e2 <printnum+0x88>

f0104624 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104624:	55                   	push   %ebp
f0104625:	89 e5                	mov    %esp,%ebp
f0104627:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010462a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010462e:	8b 10                	mov    (%eax),%edx
f0104630:	3b 50 04             	cmp    0x4(%eax),%edx
f0104633:	73 0a                	jae    f010463f <sprintputch+0x1b>
		*b->buf++ = ch;
f0104635:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104638:	89 08                	mov    %ecx,(%eax)
f010463a:	8b 45 08             	mov    0x8(%ebp),%eax
f010463d:	88 02                	mov    %al,(%edx)
}
f010463f:	5d                   	pop    %ebp
f0104640:	c3                   	ret    

f0104641 <printfmt>:
{
f0104641:	55                   	push   %ebp
f0104642:	89 e5                	mov    %esp,%ebp
f0104644:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104647:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010464a:	50                   	push   %eax
f010464b:	ff 75 10             	pushl  0x10(%ebp)
f010464e:	ff 75 0c             	pushl  0xc(%ebp)
f0104651:	ff 75 08             	pushl  0x8(%ebp)
f0104654:	e8 05 00 00 00       	call   f010465e <vprintfmt>
}
f0104659:	83 c4 10             	add    $0x10,%esp
f010465c:	c9                   	leave  
f010465d:	c3                   	ret    

f010465e <vprintfmt>:
{
f010465e:	55                   	push   %ebp
f010465f:	89 e5                	mov    %esp,%ebp
f0104661:	57                   	push   %edi
f0104662:	56                   	push   %esi
f0104663:	53                   	push   %ebx
f0104664:	83 ec 2c             	sub    $0x2c,%esp
f0104667:	e8 fb ba ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f010466c:	81 c3 c8 8a 08 00    	add    $0x88ac8,%ebx
f0104672:	8b 75 10             	mov    0x10(%ebp),%esi
	int textcolor = 0x0700;
f0104675:	c7 45 e4 00 07 00 00 	movl   $0x700,-0x1c(%ebp)
f010467c:	89 f7                	mov    %esi,%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010467e:	8d 77 01             	lea    0x1(%edi),%esi
f0104681:	0f b6 07             	movzbl (%edi),%eax
f0104684:	83 f8 25             	cmp    $0x25,%eax
f0104687:	74 1c                	je     f01046a5 <vprintfmt+0x47>
			if (ch == '\0')
f0104689:	85 c0                	test   %eax,%eax
f010468b:	0f 84 b9 04 00 00    	je     f0104b4a <.L21+0x20>
			putch(ch, putdat);
f0104691:	83 ec 08             	sub    $0x8,%esp
f0104694:	ff 75 0c             	pushl  0xc(%ebp)
			ch |= textcolor;
f0104697:	0b 45 e4             	or     -0x1c(%ebp),%eax
			putch(ch, putdat);
f010469a:	50                   	push   %eax
f010469b:	ff 55 08             	call   *0x8(%ebp)
f010469e:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01046a1:	89 f7                	mov    %esi,%edi
f01046a3:	eb d9                	jmp    f010467e <vprintfmt+0x20>
		padc = ' ';
f01046a5:	c6 45 d0 20          	movb   $0x20,-0x30(%ebp)
		altflag = 0;
f01046a9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f01046b0:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f01046b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f01046be:	b9 00 00 00 00       	mov    $0x0,%ecx
f01046c3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01046c6:	8d 7e 01             	lea    0x1(%esi),%edi
f01046c9:	0f b6 16             	movzbl (%esi),%edx
f01046cc:	8d 42 dd             	lea    -0x23(%edx),%eax
f01046cf:	3c 55                	cmp    $0x55,%al
f01046d1:	0f 87 53 04 00 00    	ja     f0104b2a <.L21>
f01046d7:	0f b6 c0             	movzbl %al,%eax
f01046da:	89 d9                	mov    %ebx,%ecx
f01046dc:	03 8c 83 74 98 f7 ff 	add    -0x8678c(%ebx,%eax,4),%ecx
f01046e3:	ff e1                	jmp    *%ecx

f01046e5 <.L73>:
f01046e5:	89 fe                	mov    %edi,%esi
			padc = '-';
f01046e7:	c6 45 d0 2d          	movb   $0x2d,-0x30(%ebp)
f01046eb:	eb d9                	jmp    f01046c6 <vprintfmt+0x68>

f01046ed <.L27>:
		switch (ch = *(unsigned char *) fmt++) {
f01046ed:	89 fe                	mov    %edi,%esi
			padc = '0';
f01046ef:	c6 45 d0 30          	movb   $0x30,-0x30(%ebp)
f01046f3:	eb d1                	jmp    f01046c6 <vprintfmt+0x68>

f01046f5 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f01046f5:	0f b6 d2             	movzbl %dl,%edx
f01046f8:	89 fe                	mov    %edi,%esi
			for (precision = 0; ; ++fmt) {
f01046fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01046ff:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
				precision = precision * 10 + ch - '0';
f0104702:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104705:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104709:	0f be 16             	movsbl (%esi),%edx
				if (ch < '0' || ch > '9')
f010470c:	8d 7a d0             	lea    -0x30(%edx),%edi
f010470f:	83 ff 09             	cmp    $0x9,%edi
f0104712:	0f 87 94 00 00 00    	ja     f01047ac <.L33+0x42>
			for (precision = 0; ; ++fmt) {
f0104718:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
f010471b:	eb e5                	jmp    f0104702 <.L28+0xd>

f010471d <.L25>:
			precision = va_arg(ap, int);
f010471d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104720:	8b 00                	mov    (%eax),%eax
f0104722:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104725:	8b 45 14             	mov    0x14(%ebp),%eax
f0104728:	8d 40 04             	lea    0x4(%eax),%eax
f010472b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010472e:	89 fe                	mov    %edi,%esi
			if (width < 0)
f0104730:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104734:	79 90                	jns    f01046c6 <vprintfmt+0x68>
				width = precision, precision = -1;
f0104736:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104739:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010473c:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0104743:	eb 81                	jmp    f01046c6 <vprintfmt+0x68>

f0104745 <.L26>:
f0104745:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104748:	85 c0                	test   %eax,%eax
f010474a:	ba 00 00 00 00       	mov    $0x0,%edx
f010474f:	0f 49 d0             	cmovns %eax,%edx
f0104752:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104755:	89 fe                	mov    %edi,%esi
f0104757:	e9 6a ff ff ff       	jmp    f01046c6 <vprintfmt+0x68>

f010475c <.L22>:
f010475c:	89 fe                	mov    %edi,%esi
			altflag = 1;
f010475e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104765:	e9 5c ff ff ff       	jmp    f01046c6 <vprintfmt+0x68>

f010476a <.L33>:
f010476a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f010476d:	83 f9 01             	cmp    $0x1,%ecx
f0104770:	7e 16                	jle    f0104788 <.L33+0x1e>
		return va_arg(*ap, long long);
f0104772:	8b 45 14             	mov    0x14(%ebp),%eax
f0104775:	8b 00                	mov    (%eax),%eax
f0104777:	8b 4d 14             	mov    0x14(%ebp),%ecx
f010477a:	8d 49 08             	lea    0x8(%ecx),%ecx
f010477d:	89 4d 14             	mov    %ecx,0x14(%ebp)
			textcolor = getint(&ap, lflag);
f0104780:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;
f0104783:	e9 f6 fe ff ff       	jmp    f010467e <vprintfmt+0x20>
	else if (lflag)
f0104788:	85 c9                	test   %ecx,%ecx
f010478a:	75 10                	jne    f010479c <.L33+0x32>
		return va_arg(*ap, int);
f010478c:	8b 45 14             	mov    0x14(%ebp),%eax
f010478f:	8b 00                	mov    (%eax),%eax
f0104791:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104794:	8d 49 04             	lea    0x4(%ecx),%ecx
f0104797:	89 4d 14             	mov    %ecx,0x14(%ebp)
f010479a:	eb e4                	jmp    f0104780 <.L33+0x16>
		return va_arg(*ap, long);
f010479c:	8b 45 14             	mov    0x14(%ebp),%eax
f010479f:	8b 00                	mov    (%eax),%eax
f01047a1:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01047a4:	8d 49 04             	lea    0x4(%ecx),%ecx
f01047a7:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01047aa:	eb d4                	jmp    f0104780 <.L33+0x16>
f01047ac:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01047af:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01047b2:	e9 79 ff ff ff       	jmp    f0104730 <.L25+0x13>

f01047b7 <.L32>:
			lflag++;
f01047b7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01047bb:	89 fe                	mov    %edi,%esi
			goto reswitch;
f01047bd:	e9 04 ff ff ff       	jmp    f01046c6 <vprintfmt+0x68>

f01047c2 <.L29>:
			putch(va_arg(ap, int), putdat);
f01047c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01047c5:	8d 70 04             	lea    0x4(%eax),%esi
f01047c8:	83 ec 08             	sub    $0x8,%esp
f01047cb:	ff 75 0c             	pushl  0xc(%ebp)
f01047ce:	ff 30                	pushl  (%eax)
f01047d0:	ff 55 08             	call   *0x8(%ebp)
			break;
f01047d3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01047d6:	89 75 14             	mov    %esi,0x14(%ebp)
			break;
f01047d9:	e9 a0 fe ff ff       	jmp    f010467e <vprintfmt+0x20>

f01047de <.L31>:
			err = va_arg(ap, int);
f01047de:	8b 45 14             	mov    0x14(%ebp),%eax
f01047e1:	8d 70 04             	lea    0x4(%eax),%esi
f01047e4:	8b 00                	mov    (%eax),%eax
f01047e6:	99                   	cltd   
f01047e7:	31 d0                	xor    %edx,%eax
f01047e9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01047eb:	83 f8 06             	cmp    $0x6,%eax
f01047ee:	7f 29                	jg     f0104819 <.L31+0x3b>
f01047f0:	8b 94 83 bc 1f 00 00 	mov    0x1fbc(%ebx,%eax,4),%edx
f01047f7:	85 d2                	test   %edx,%edx
f01047f9:	74 1e                	je     f0104819 <.L31+0x3b>
				printfmt(putch, putdat, "%s", p);
f01047fb:	52                   	push   %edx
f01047fc:	8d 83 1c 84 f7 ff    	lea    -0x87be4(%ebx),%eax
f0104802:	50                   	push   %eax
f0104803:	ff 75 0c             	pushl  0xc(%ebp)
f0104806:	ff 75 08             	pushl  0x8(%ebp)
f0104809:	e8 33 fe ff ff       	call   f0104641 <printfmt>
f010480e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0104811:	89 75 14             	mov    %esi,0x14(%ebp)
f0104814:	e9 65 fe ff ff       	jmp    f010467e <vprintfmt+0x20>
				printfmt(putch, putdat, "error %d", err);
f0104819:	50                   	push   %eax
f010481a:	8d 83 01 98 f7 ff    	lea    -0x867ff(%ebx),%eax
f0104820:	50                   	push   %eax
f0104821:	ff 75 0c             	pushl  0xc(%ebp)
f0104824:	ff 75 08             	pushl  0x8(%ebp)
f0104827:	e8 15 fe ff ff       	call   f0104641 <printfmt>
f010482c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010482f:	89 75 14             	mov    %esi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0104832:	e9 47 fe ff ff       	jmp    f010467e <vprintfmt+0x20>

f0104837 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0104837:	8b 45 14             	mov    0x14(%ebp),%eax
f010483a:	83 c0 04             	add    $0x4,%eax
f010483d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104840:	8b 45 14             	mov    0x14(%ebp),%eax
f0104843:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0104845:	85 f6                	test   %esi,%esi
f0104847:	8d 83 fa 97 f7 ff    	lea    -0x86806(%ebx),%eax
f010484d:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0104850:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104854:	0f 8e b4 00 00 00    	jle    f010490e <.L36+0xd7>
f010485a:	80 7d d0 2d          	cmpb   $0x2d,-0x30(%ebp)
f010485e:	75 08                	jne    f0104868 <.L36+0x31>
f0104860:	89 7d 10             	mov    %edi,0x10(%ebp)
f0104863:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104866:	eb 6c                	jmp    f01048d4 <.L36+0x9d>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104868:	83 ec 08             	sub    $0x8,%esp
f010486b:	ff 75 cc             	pushl  -0x34(%ebp)
f010486e:	56                   	push   %esi
f010486f:	e8 6c 04 00 00       	call   f0104ce0 <strnlen>
f0104874:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104877:	29 c2                	sub    %eax,%edx
f0104879:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010487c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010487f:	0f be 45 d0          	movsbl -0x30(%ebp),%eax
f0104883:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0104886:	89 d6                	mov    %edx,%esi
f0104888:	89 7d 10             	mov    %edi,0x10(%ebp)
f010488b:	89 c7                	mov    %eax,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f010488d:	eb 10                	jmp    f010489f <.L36+0x68>
					putch(padc, putdat);
f010488f:	83 ec 08             	sub    $0x8,%esp
f0104892:	ff 75 0c             	pushl  0xc(%ebp)
f0104895:	57                   	push   %edi
f0104896:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0104899:	83 ee 01             	sub    $0x1,%esi
f010489c:	83 c4 10             	add    $0x10,%esp
f010489f:	85 f6                	test   %esi,%esi
f01048a1:	7f ec                	jg     f010488f <.L36+0x58>
f01048a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01048a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01048a9:	85 d2                	test   %edx,%edx
f01048ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01048b0:	0f 49 c2             	cmovns %edx,%eax
f01048b3:	29 c2                	sub    %eax,%edx
f01048b5:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01048b8:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01048bb:	eb 17                	jmp    f01048d4 <.L36+0x9d>
				if (altflag && (ch < ' ' || ch > '~'))
f01048bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01048c1:	75 30                	jne    f01048f3 <.L36+0xbc>
					putch(ch, putdat);
f01048c3:	83 ec 08             	sub    $0x8,%esp
f01048c6:	ff 75 0c             	pushl  0xc(%ebp)
f01048c9:	50                   	push   %eax
f01048ca:	ff 55 08             	call   *0x8(%ebp)
f01048cd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01048d0:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01048d4:	83 c6 01             	add    $0x1,%esi
f01048d7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f01048db:	0f be c2             	movsbl %dl,%eax
f01048de:	85 c0                	test   %eax,%eax
f01048e0:	74 58                	je     f010493a <.L36+0x103>
f01048e2:	85 ff                	test   %edi,%edi
f01048e4:	78 d7                	js     f01048bd <.L36+0x86>
f01048e6:	83 ef 01             	sub    $0x1,%edi
f01048e9:	79 d2                	jns    f01048bd <.L36+0x86>
f01048eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01048ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01048f1:	eb 32                	jmp    f0104925 <.L36+0xee>
				if (altflag && (ch < ' ' || ch > '~'))
f01048f3:	0f be d2             	movsbl %dl,%edx
f01048f6:	83 ea 20             	sub    $0x20,%edx
f01048f9:	83 fa 5e             	cmp    $0x5e,%edx
f01048fc:	76 c5                	jbe    f01048c3 <.L36+0x8c>
					putch('?', putdat);
f01048fe:	83 ec 08             	sub    $0x8,%esp
f0104901:	ff 75 0c             	pushl  0xc(%ebp)
f0104904:	6a 3f                	push   $0x3f
f0104906:	ff 55 08             	call   *0x8(%ebp)
f0104909:	83 c4 10             	add    $0x10,%esp
f010490c:	eb c2                	jmp    f01048d0 <.L36+0x99>
f010490e:	89 7d 10             	mov    %edi,0x10(%ebp)
f0104911:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104914:	eb be                	jmp    f01048d4 <.L36+0x9d>
				putch(' ', putdat);
f0104916:	83 ec 08             	sub    $0x8,%esp
f0104919:	57                   	push   %edi
f010491a:	6a 20                	push   $0x20
f010491c:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f010491f:	83 ee 01             	sub    $0x1,%esi
f0104922:	83 c4 10             	add    $0x10,%esp
f0104925:	85 f6                	test   %esi,%esi
f0104927:	7f ed                	jg     f0104916 <.L36+0xdf>
f0104929:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010492c:	8b 7d 10             	mov    0x10(%ebp),%edi
			if ((p = va_arg(ap, char *)) == NULL)
f010492f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104932:	89 45 14             	mov    %eax,0x14(%ebp)
f0104935:	e9 44 fd ff ff       	jmp    f010467e <vprintfmt+0x20>
f010493a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010493d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104940:	eb e3                	jmp    f0104925 <.L36+0xee>

f0104942 <.L30>:
f0104942:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0104945:	83 f9 01             	cmp    $0x1,%ecx
f0104948:	7e 42                	jle    f010498c <.L30+0x4a>
		return va_arg(*ap, long long);
f010494a:	8b 45 14             	mov    0x14(%ebp),%eax
f010494d:	8b 50 04             	mov    0x4(%eax),%edx
f0104950:	8b 00                	mov    (%eax),%eax
f0104952:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104955:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104958:	8b 45 14             	mov    0x14(%ebp),%eax
f010495b:	8d 40 08             	lea    0x8(%eax),%eax
f010495e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0104961:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104965:	79 5f                	jns    f01049c6 <.L30+0x84>
				putch('-', putdat);
f0104967:	83 ec 08             	sub    $0x8,%esp
f010496a:	ff 75 0c             	pushl  0xc(%ebp)
f010496d:	6a 2d                	push   $0x2d
f010496f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104972:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104975:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104978:	f7 da                	neg    %edx
f010497a:	83 d1 00             	adc    $0x0,%ecx
f010497d:	f7 d9                	neg    %ecx
f010497f:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0104982:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104987:	e9 b8 00 00 00       	jmp    f0104a44 <.L34+0x22>
	else if (lflag)
f010498c:	85 c9                	test   %ecx,%ecx
f010498e:	75 1b                	jne    f01049ab <.L30+0x69>
		return va_arg(*ap, int);
f0104990:	8b 45 14             	mov    0x14(%ebp),%eax
f0104993:	8b 30                	mov    (%eax),%esi
f0104995:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0104998:	89 f0                	mov    %esi,%eax
f010499a:	c1 f8 1f             	sar    $0x1f,%eax
f010499d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01049a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01049a3:	8d 40 04             	lea    0x4(%eax),%eax
f01049a6:	89 45 14             	mov    %eax,0x14(%ebp)
f01049a9:	eb b6                	jmp    f0104961 <.L30+0x1f>
		return va_arg(*ap, long);
f01049ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01049ae:	8b 30                	mov    (%eax),%esi
f01049b0:	89 75 d8             	mov    %esi,-0x28(%ebp)
f01049b3:	89 f0                	mov    %esi,%eax
f01049b5:	c1 f8 1f             	sar    $0x1f,%eax
f01049b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01049bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01049be:	8d 40 04             	lea    0x4(%eax),%eax
f01049c1:	89 45 14             	mov    %eax,0x14(%ebp)
f01049c4:	eb 9b                	jmp    f0104961 <.L30+0x1f>
			num = getint(&ap, lflag);
f01049c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01049c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01049cc:	b8 0a 00 00 00       	mov    $0xa,%eax
f01049d1:	eb 71                	jmp    f0104a44 <.L34+0x22>

f01049d3 <.L37>:
f01049d3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f01049d6:	83 f9 01             	cmp    $0x1,%ecx
f01049d9:	7e 15                	jle    f01049f0 <.L37+0x1d>
		return va_arg(*ap, unsigned long long);
f01049db:	8b 45 14             	mov    0x14(%ebp),%eax
f01049de:	8b 10                	mov    (%eax),%edx
f01049e0:	8b 48 04             	mov    0x4(%eax),%ecx
f01049e3:	8d 40 08             	lea    0x8(%eax),%eax
f01049e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01049e9:	b8 0a 00 00 00       	mov    $0xa,%eax
f01049ee:	eb 54                	jmp    f0104a44 <.L34+0x22>
	else if (lflag)
f01049f0:	85 c9                	test   %ecx,%ecx
f01049f2:	75 17                	jne    f0104a0b <.L37+0x38>
		return va_arg(*ap, unsigned int);
f01049f4:	8b 45 14             	mov    0x14(%ebp),%eax
f01049f7:	8b 10                	mov    (%eax),%edx
f01049f9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01049fe:	8d 40 04             	lea    0x4(%eax),%eax
f0104a01:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104a04:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a09:	eb 39                	jmp    f0104a44 <.L34+0x22>
		return va_arg(*ap, unsigned long);
f0104a0b:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a0e:	8b 10                	mov    (%eax),%edx
f0104a10:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104a15:	8d 40 04             	lea    0x4(%eax),%eax
f0104a18:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0104a1b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104a20:	eb 22                	jmp    f0104a44 <.L34+0x22>

f0104a22 <.L34>:
f0104a22:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0104a25:	83 f9 01             	cmp    $0x1,%ecx
f0104a28:	7e 3b                	jle    f0104a65 <.L34+0x43>
		return va_arg(*ap, long long);
f0104a2a:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a2d:	8b 50 04             	mov    0x4(%eax),%edx
f0104a30:	8b 00                	mov    (%eax),%eax
f0104a32:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104a35:	8d 49 08             	lea    0x8(%ecx),%ecx
f0104a38:	89 4d 14             	mov    %ecx,0x14(%ebp)
			num = getint(&ap, lflag);
f0104a3b:	89 d1                	mov    %edx,%ecx
f0104a3d:	89 c2                	mov    %eax,%edx
			base = 8;
f0104a3f:	b8 08 00 00 00       	mov    $0x8,%eax
			printnum(putch, putdat, num, base, width, padc);
f0104a44:	83 ec 0c             	sub    $0xc,%esp
f0104a47:	0f be 75 d0          	movsbl -0x30(%ebp),%esi
f0104a4b:	56                   	push   %esi
f0104a4c:	ff 75 e0             	pushl  -0x20(%ebp)
f0104a4f:	50                   	push   %eax
f0104a50:	51                   	push   %ecx
f0104a51:	52                   	push   %edx
f0104a52:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104a55:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a58:	e8 fd fa ff ff       	call   f010455a <printnum>
			break;
f0104a5d:	83 c4 20             	add    $0x20,%esp
f0104a60:	e9 19 fc ff ff       	jmp    f010467e <vprintfmt+0x20>
	else if (lflag)
f0104a65:	85 c9                	test   %ecx,%ecx
f0104a67:	75 13                	jne    f0104a7c <.L34+0x5a>
		return va_arg(*ap, int);
f0104a69:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a6c:	8b 10                	mov    (%eax),%edx
f0104a6e:	89 d0                	mov    %edx,%eax
f0104a70:	99                   	cltd   
f0104a71:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104a74:	8d 49 04             	lea    0x4(%ecx),%ecx
f0104a77:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104a7a:	eb bf                	jmp    f0104a3b <.L34+0x19>
		return va_arg(*ap, long);
f0104a7c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a7f:	8b 10                	mov    (%eax),%edx
f0104a81:	89 d0                	mov    %edx,%eax
f0104a83:	99                   	cltd   
f0104a84:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104a87:	8d 49 04             	lea    0x4(%ecx),%ecx
f0104a8a:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104a8d:	eb ac                	jmp    f0104a3b <.L34+0x19>

f0104a8f <.L35>:
			putch('0', putdat);
f0104a8f:	83 ec 08             	sub    $0x8,%esp
f0104a92:	ff 75 0c             	pushl  0xc(%ebp)
f0104a95:	6a 30                	push   $0x30
f0104a97:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104a9a:	83 c4 08             	add    $0x8,%esp
f0104a9d:	ff 75 0c             	pushl  0xc(%ebp)
f0104aa0:	6a 78                	push   $0x78
f0104aa2:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0104aa5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104aa8:	8b 10                	mov    (%eax),%edx
f0104aaa:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0104aaf:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0104ab2:	8d 40 04             	lea    0x4(%eax),%eax
f0104ab5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104ab8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104abd:	eb 85                	jmp    f0104a44 <.L34+0x22>

f0104abf <.L38>:
f0104abf:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
	if (lflag >= 2)
f0104ac2:	83 f9 01             	cmp    $0x1,%ecx
f0104ac5:	7e 18                	jle    f0104adf <.L38+0x20>
		return va_arg(*ap, unsigned long long);
f0104ac7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104aca:	8b 10                	mov    (%eax),%edx
f0104acc:	8b 48 04             	mov    0x4(%eax),%ecx
f0104acf:	8d 40 08             	lea    0x8(%eax),%eax
f0104ad2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104ad5:	b8 10 00 00 00       	mov    $0x10,%eax
f0104ada:	e9 65 ff ff ff       	jmp    f0104a44 <.L34+0x22>
	else if (lflag)
f0104adf:	85 c9                	test   %ecx,%ecx
f0104ae1:	75 1a                	jne    f0104afd <.L38+0x3e>
		return va_arg(*ap, unsigned int);
f0104ae3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ae6:	8b 10                	mov    (%eax),%edx
f0104ae8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104aed:	8d 40 04             	lea    0x4(%eax),%eax
f0104af0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104af3:	b8 10 00 00 00       	mov    $0x10,%eax
f0104af8:	e9 47 ff ff ff       	jmp    f0104a44 <.L34+0x22>
		return va_arg(*ap, unsigned long);
f0104afd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b00:	8b 10                	mov    (%eax),%edx
f0104b02:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104b07:	8d 40 04             	lea    0x4(%eax),%eax
f0104b0a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104b0d:	b8 10 00 00 00       	mov    $0x10,%eax
f0104b12:	e9 2d ff ff ff       	jmp    f0104a44 <.L34+0x22>

f0104b17 <.L24>:
			putch(ch, putdat);
f0104b17:	83 ec 08             	sub    $0x8,%esp
f0104b1a:	ff 75 0c             	pushl  0xc(%ebp)
f0104b1d:	6a 25                	push   $0x25
f0104b1f:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104b22:	83 c4 10             	add    $0x10,%esp
f0104b25:	e9 54 fb ff ff       	jmp    f010467e <vprintfmt+0x20>

f0104b2a <.L21>:
			putch('%', putdat);
f0104b2a:	83 ec 08             	sub    $0x8,%esp
f0104b2d:	ff 75 0c             	pushl  0xc(%ebp)
f0104b30:	6a 25                	push   $0x25
f0104b32:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104b35:	83 c4 10             	add    $0x10,%esp
f0104b38:	89 f7                	mov    %esi,%edi
f0104b3a:	eb 03                	jmp    f0104b3f <.L21+0x15>
f0104b3c:	83 ef 01             	sub    $0x1,%edi
f0104b3f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104b43:	75 f7                	jne    f0104b3c <.L21+0x12>
f0104b45:	e9 34 fb ff ff       	jmp    f010467e <vprintfmt+0x20>
}
f0104b4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b4d:	5b                   	pop    %ebx
f0104b4e:	5e                   	pop    %esi
f0104b4f:	5f                   	pop    %edi
f0104b50:	5d                   	pop    %ebp
f0104b51:	c3                   	ret    

f0104b52 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104b52:	55                   	push   %ebp
f0104b53:	89 e5                	mov    %esp,%ebp
f0104b55:	53                   	push   %ebx
f0104b56:	83 ec 14             	sub    $0x14,%esp
f0104b59:	e8 09 b6 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104b5e:	81 c3 d6 85 08 00    	add    $0x885d6,%ebx
f0104b64:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b67:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104b6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b6d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104b71:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104b74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104b7b:	85 c0                	test   %eax,%eax
f0104b7d:	74 2b                	je     f0104baa <vsnprintf+0x58>
f0104b7f:	85 d2                	test   %edx,%edx
f0104b81:	7e 27                	jle    f0104baa <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104b83:	ff 75 14             	pushl  0x14(%ebp)
f0104b86:	ff 75 10             	pushl  0x10(%ebp)
f0104b89:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104b8c:	50                   	push   %eax
f0104b8d:	8d 83 f0 74 f7 ff    	lea    -0x88b10(%ebx),%eax
f0104b93:	50                   	push   %eax
f0104b94:	e8 c5 fa ff ff       	call   f010465e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104b99:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104b9c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ba2:	83 c4 10             	add    $0x10,%esp
}
f0104ba5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104ba8:	c9                   	leave  
f0104ba9:	c3                   	ret    
		return -E_INVAL;
f0104baa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104baf:	eb f4                	jmp    f0104ba5 <vsnprintf+0x53>

f0104bb1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104bb1:	55                   	push   %ebp
f0104bb2:	89 e5                	mov    %esp,%ebp
f0104bb4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104bb7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104bba:	50                   	push   %eax
f0104bbb:	ff 75 10             	pushl  0x10(%ebp)
f0104bbe:	ff 75 0c             	pushl  0xc(%ebp)
f0104bc1:	ff 75 08             	pushl  0x8(%ebp)
f0104bc4:	e8 89 ff ff ff       	call   f0104b52 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104bc9:	c9                   	leave  
f0104bca:	c3                   	ret    

f0104bcb <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104bcb:	55                   	push   %ebp
f0104bcc:	89 e5                	mov    %esp,%ebp
f0104bce:	57                   	push   %edi
f0104bcf:	56                   	push   %esi
f0104bd0:	53                   	push   %ebx
f0104bd1:	83 ec 1c             	sub    $0x1c,%esp
f0104bd4:	e8 8e b5 ff ff       	call   f0100167 <__x86.get_pc_thunk.bx>
f0104bd9:	81 c3 5b 85 08 00    	add    $0x8855b,%ebx
f0104bdf:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104be2:	85 c0                	test   %eax,%eax
f0104be4:	74 13                	je     f0104bf9 <readline+0x2e>
		cprintf("%s", prompt);
f0104be6:	83 ec 08             	sub    $0x8,%esp
f0104be9:	50                   	push   %eax
f0104bea:	8d 83 1c 84 f7 ff    	lea    -0x87be4(%ebx),%eax
f0104bf0:	50                   	push   %eax
f0104bf1:	e8 59 f1 ff ff       	call   f0103d4f <cprintf>
f0104bf6:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104bf9:	83 ec 0c             	sub    $0xc,%esp
f0104bfc:	6a 00                	push   $0x0
f0104bfe:	e8 fc ba ff ff       	call   f01006ff <iscons>
f0104c03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104c06:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0104c09:	bf 00 00 00 00       	mov    $0x0,%edi
f0104c0e:	eb 46                	jmp    f0104c56 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0104c10:	83 ec 08             	sub    $0x8,%esp
f0104c13:	50                   	push   %eax
f0104c14:	8d 83 cc 99 f7 ff    	lea    -0x86634(%ebx),%eax
f0104c1a:	50                   	push   %eax
f0104c1b:	e8 2f f1 ff ff       	call   f0103d4f <cprintf>
			return NULL;
f0104c20:	83 c4 10             	add    $0x10,%esp
f0104c23:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0104c28:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c2b:	5b                   	pop    %ebx
f0104c2c:	5e                   	pop    %esi
f0104c2d:	5f                   	pop    %edi
f0104c2e:	5d                   	pop    %ebp
f0104c2f:	c3                   	ret    
			if (echoing)
f0104c30:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104c34:	75 05                	jne    f0104c3b <readline+0x70>
			i--;
f0104c36:	83 ef 01             	sub    $0x1,%edi
f0104c39:	eb 1b                	jmp    f0104c56 <readline+0x8b>
				cputchar('\b');
f0104c3b:	83 ec 0c             	sub    $0xc,%esp
f0104c3e:	6a 08                	push   $0x8
f0104c40:	e8 99 ba ff ff       	call   f01006de <cputchar>
f0104c45:	83 c4 10             	add    $0x10,%esp
f0104c48:	eb ec                	jmp    f0104c36 <readline+0x6b>
			buf[i++] = c;
f0104c4a:	89 f0                	mov    %esi,%eax
f0104c4c:	88 84 3b ec 2a 00 00 	mov    %al,0x2aec(%ebx,%edi,1)
f0104c53:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0104c56:	e8 93 ba ff ff       	call   f01006ee <getchar>
f0104c5b:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0104c5d:	85 c0                	test   %eax,%eax
f0104c5f:	78 af                	js     f0104c10 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104c61:	83 f8 08             	cmp    $0x8,%eax
f0104c64:	0f 94 c2             	sete   %dl
f0104c67:	83 f8 7f             	cmp    $0x7f,%eax
f0104c6a:	0f 94 c0             	sete   %al
f0104c6d:	08 c2                	or     %al,%dl
f0104c6f:	74 04                	je     f0104c75 <readline+0xaa>
f0104c71:	85 ff                	test   %edi,%edi
f0104c73:	7f bb                	jg     f0104c30 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104c75:	83 fe 1f             	cmp    $0x1f,%esi
f0104c78:	7e 1c                	jle    f0104c96 <readline+0xcb>
f0104c7a:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0104c80:	7f 14                	jg     f0104c96 <readline+0xcb>
			if (echoing)
f0104c82:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104c86:	74 c2                	je     f0104c4a <readline+0x7f>
				cputchar(c);
f0104c88:	83 ec 0c             	sub    $0xc,%esp
f0104c8b:	56                   	push   %esi
f0104c8c:	e8 4d ba ff ff       	call   f01006de <cputchar>
f0104c91:	83 c4 10             	add    $0x10,%esp
f0104c94:	eb b4                	jmp    f0104c4a <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0104c96:	83 fe 0a             	cmp    $0xa,%esi
f0104c99:	74 05                	je     f0104ca0 <readline+0xd5>
f0104c9b:	83 fe 0d             	cmp    $0xd,%esi
f0104c9e:	75 b6                	jne    f0104c56 <readline+0x8b>
			if (echoing)
f0104ca0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104ca4:	75 13                	jne    f0104cb9 <readline+0xee>
			buf[i] = 0;
f0104ca6:	c6 84 3b ec 2a 00 00 	movb   $0x0,0x2aec(%ebx,%edi,1)
f0104cad:	00 
			return buf;
f0104cae:	8d 83 ec 2a 00 00    	lea    0x2aec(%ebx),%eax
f0104cb4:	e9 6f ff ff ff       	jmp    f0104c28 <readline+0x5d>
				cputchar('\n');
f0104cb9:	83 ec 0c             	sub    $0xc,%esp
f0104cbc:	6a 0a                	push   $0xa
f0104cbe:	e8 1b ba ff ff       	call   f01006de <cputchar>
f0104cc3:	83 c4 10             	add    $0x10,%esp
f0104cc6:	eb de                	jmp    f0104ca6 <readline+0xdb>

f0104cc8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104cc8:	55                   	push   %ebp
f0104cc9:	89 e5                	mov    %esp,%ebp
f0104ccb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104cce:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cd3:	eb 03                	jmp    f0104cd8 <strlen+0x10>
		n++;
f0104cd5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0104cd8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104cdc:	75 f7                	jne    f0104cd5 <strlen+0xd>
	return n;
}
f0104cde:	5d                   	pop    %ebp
f0104cdf:	c3                   	ret    

f0104ce0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104ce0:	55                   	push   %ebp
f0104ce1:	89 e5                	mov    %esp,%ebp
f0104ce3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104ce6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104ce9:	b8 00 00 00 00       	mov    $0x0,%eax
f0104cee:	eb 03                	jmp    f0104cf3 <strnlen+0x13>
		n++;
f0104cf0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104cf3:	39 d0                	cmp    %edx,%eax
f0104cf5:	74 06                	je     f0104cfd <strnlen+0x1d>
f0104cf7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104cfb:	75 f3                	jne    f0104cf0 <strnlen+0x10>
	return n;
}
f0104cfd:	5d                   	pop    %ebp
f0104cfe:	c3                   	ret    

f0104cff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104cff:	55                   	push   %ebp
f0104d00:	89 e5                	mov    %esp,%ebp
f0104d02:	53                   	push   %ebx
f0104d03:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104d09:	89 c2                	mov    %eax,%edx
f0104d0b:	83 c1 01             	add    $0x1,%ecx
f0104d0e:	83 c2 01             	add    $0x1,%edx
f0104d11:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104d15:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104d18:	84 db                	test   %bl,%bl
f0104d1a:	75 ef                	jne    f0104d0b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104d1c:	5b                   	pop    %ebx
f0104d1d:	5d                   	pop    %ebp
f0104d1e:	c3                   	ret    

f0104d1f <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104d1f:	55                   	push   %ebp
f0104d20:	89 e5                	mov    %esp,%ebp
f0104d22:	53                   	push   %ebx
f0104d23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104d26:	53                   	push   %ebx
f0104d27:	e8 9c ff ff ff       	call   f0104cc8 <strlen>
f0104d2c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104d2f:	ff 75 0c             	pushl  0xc(%ebp)
f0104d32:	01 d8                	add    %ebx,%eax
f0104d34:	50                   	push   %eax
f0104d35:	e8 c5 ff ff ff       	call   f0104cff <strcpy>
	return dst;
}
f0104d3a:	89 d8                	mov    %ebx,%eax
f0104d3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104d3f:	c9                   	leave  
f0104d40:	c3                   	ret    

f0104d41 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104d41:	55                   	push   %ebp
f0104d42:	89 e5                	mov    %esp,%ebp
f0104d44:	56                   	push   %esi
f0104d45:	53                   	push   %ebx
f0104d46:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104d4c:	89 f3                	mov    %esi,%ebx
f0104d4e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104d51:	89 f2                	mov    %esi,%edx
f0104d53:	eb 0f                	jmp    f0104d64 <strncpy+0x23>
		*dst++ = *src;
f0104d55:	83 c2 01             	add    $0x1,%edx
f0104d58:	0f b6 01             	movzbl (%ecx),%eax
f0104d5b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104d5e:	80 39 01             	cmpb   $0x1,(%ecx)
f0104d61:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0104d64:	39 da                	cmp    %ebx,%edx
f0104d66:	75 ed                	jne    f0104d55 <strncpy+0x14>
	}
	return ret;
}
f0104d68:	89 f0                	mov    %esi,%eax
f0104d6a:	5b                   	pop    %ebx
f0104d6b:	5e                   	pop    %esi
f0104d6c:	5d                   	pop    %ebp
f0104d6d:	c3                   	ret    

f0104d6e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104d6e:	55                   	push   %ebp
f0104d6f:	89 e5                	mov    %esp,%ebp
f0104d71:	56                   	push   %esi
f0104d72:	53                   	push   %ebx
f0104d73:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d76:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d79:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104d7c:	89 f0                	mov    %esi,%eax
f0104d7e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104d82:	85 c9                	test   %ecx,%ecx
f0104d84:	75 0b                	jne    f0104d91 <strlcpy+0x23>
f0104d86:	eb 17                	jmp    f0104d9f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104d88:	83 c2 01             	add    $0x1,%edx
f0104d8b:	83 c0 01             	add    $0x1,%eax
f0104d8e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0104d91:	39 d8                	cmp    %ebx,%eax
f0104d93:	74 07                	je     f0104d9c <strlcpy+0x2e>
f0104d95:	0f b6 0a             	movzbl (%edx),%ecx
f0104d98:	84 c9                	test   %cl,%cl
f0104d9a:	75 ec                	jne    f0104d88 <strlcpy+0x1a>
		*dst = '\0';
f0104d9c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104d9f:	29 f0                	sub    %esi,%eax
}
f0104da1:	5b                   	pop    %ebx
f0104da2:	5e                   	pop    %esi
f0104da3:	5d                   	pop    %ebp
f0104da4:	c3                   	ret    

f0104da5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104da5:	55                   	push   %ebp
f0104da6:	89 e5                	mov    %esp,%ebp
f0104da8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104dab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104dae:	eb 06                	jmp    f0104db6 <strcmp+0x11>
		p++, q++;
f0104db0:	83 c1 01             	add    $0x1,%ecx
f0104db3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0104db6:	0f b6 01             	movzbl (%ecx),%eax
f0104db9:	84 c0                	test   %al,%al
f0104dbb:	74 04                	je     f0104dc1 <strcmp+0x1c>
f0104dbd:	3a 02                	cmp    (%edx),%al
f0104dbf:	74 ef                	je     f0104db0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104dc1:	0f b6 c0             	movzbl %al,%eax
f0104dc4:	0f b6 12             	movzbl (%edx),%edx
f0104dc7:	29 d0                	sub    %edx,%eax
}
f0104dc9:	5d                   	pop    %ebp
f0104dca:	c3                   	ret    

f0104dcb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104dcb:	55                   	push   %ebp
f0104dcc:	89 e5                	mov    %esp,%ebp
f0104dce:	53                   	push   %ebx
f0104dcf:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104dd5:	89 c3                	mov    %eax,%ebx
f0104dd7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104dda:	eb 06                	jmp    f0104de2 <strncmp+0x17>
		n--, p++, q++;
f0104ddc:	83 c0 01             	add    $0x1,%eax
f0104ddf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0104de2:	39 d8                	cmp    %ebx,%eax
f0104de4:	74 16                	je     f0104dfc <strncmp+0x31>
f0104de6:	0f b6 08             	movzbl (%eax),%ecx
f0104de9:	84 c9                	test   %cl,%cl
f0104deb:	74 04                	je     f0104df1 <strncmp+0x26>
f0104ded:	3a 0a                	cmp    (%edx),%cl
f0104def:	74 eb                	je     f0104ddc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104df1:	0f b6 00             	movzbl (%eax),%eax
f0104df4:	0f b6 12             	movzbl (%edx),%edx
f0104df7:	29 d0                	sub    %edx,%eax
}
f0104df9:	5b                   	pop    %ebx
f0104dfa:	5d                   	pop    %ebp
f0104dfb:	c3                   	ret    
		return 0;
f0104dfc:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e01:	eb f6                	jmp    f0104df9 <strncmp+0x2e>

f0104e03 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104e03:	55                   	push   %ebp
f0104e04:	89 e5                	mov    %esp,%ebp
f0104e06:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104e0d:	0f b6 10             	movzbl (%eax),%edx
f0104e10:	84 d2                	test   %dl,%dl
f0104e12:	74 09                	je     f0104e1d <strchr+0x1a>
		if (*s == c)
f0104e14:	38 ca                	cmp    %cl,%dl
f0104e16:	74 0a                	je     f0104e22 <strchr+0x1f>
	for (; *s; s++)
f0104e18:	83 c0 01             	add    $0x1,%eax
f0104e1b:	eb f0                	jmp    f0104e0d <strchr+0xa>
			return (char *) s;
	return 0;
f0104e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104e22:	5d                   	pop    %ebp
f0104e23:	c3                   	ret    

f0104e24 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104e24:	55                   	push   %ebp
f0104e25:	89 e5                	mov    %esp,%ebp
f0104e27:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e2a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104e2e:	eb 03                	jmp    f0104e33 <strfind+0xf>
f0104e30:	83 c0 01             	add    $0x1,%eax
f0104e33:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104e36:	38 ca                	cmp    %cl,%dl
f0104e38:	74 04                	je     f0104e3e <strfind+0x1a>
f0104e3a:	84 d2                	test   %dl,%dl
f0104e3c:	75 f2                	jne    f0104e30 <strfind+0xc>
			break;
	return (char *) s;
}
f0104e3e:	5d                   	pop    %ebp
f0104e3f:	c3                   	ret    

f0104e40 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104e40:	55                   	push   %ebp
f0104e41:	89 e5                	mov    %esp,%ebp
f0104e43:	57                   	push   %edi
f0104e44:	56                   	push   %esi
f0104e45:	53                   	push   %ebx
f0104e46:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104e49:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104e4c:	85 c9                	test   %ecx,%ecx
f0104e4e:	74 13                	je     f0104e63 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104e50:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104e56:	75 05                	jne    f0104e5d <memset+0x1d>
f0104e58:	f6 c1 03             	test   $0x3,%cl
f0104e5b:	74 0d                	je     f0104e6a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104e60:	fc                   	cld    
f0104e61:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104e63:	89 f8                	mov    %edi,%eax
f0104e65:	5b                   	pop    %ebx
f0104e66:	5e                   	pop    %esi
f0104e67:	5f                   	pop    %edi
f0104e68:	5d                   	pop    %ebp
f0104e69:	c3                   	ret    
		c &= 0xFF;
f0104e6a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104e6e:	89 d3                	mov    %edx,%ebx
f0104e70:	c1 e3 08             	shl    $0x8,%ebx
f0104e73:	89 d0                	mov    %edx,%eax
f0104e75:	c1 e0 18             	shl    $0x18,%eax
f0104e78:	89 d6                	mov    %edx,%esi
f0104e7a:	c1 e6 10             	shl    $0x10,%esi
f0104e7d:	09 f0                	or     %esi,%eax
f0104e7f:	09 c2                	or     %eax,%edx
f0104e81:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0104e83:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0104e86:	89 d0                	mov    %edx,%eax
f0104e88:	fc                   	cld    
f0104e89:	f3 ab                	rep stos %eax,%es:(%edi)
f0104e8b:	eb d6                	jmp    f0104e63 <memset+0x23>

f0104e8d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104e8d:	55                   	push   %ebp
f0104e8e:	89 e5                	mov    %esp,%ebp
f0104e90:	57                   	push   %edi
f0104e91:	56                   	push   %esi
f0104e92:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e95:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e98:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104e9b:	39 c6                	cmp    %eax,%esi
f0104e9d:	73 35                	jae    f0104ed4 <memmove+0x47>
f0104e9f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104ea2:	39 c2                	cmp    %eax,%edx
f0104ea4:	76 2e                	jbe    f0104ed4 <memmove+0x47>
		s += n;
		d += n;
f0104ea6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104ea9:	89 d6                	mov    %edx,%esi
f0104eab:	09 fe                	or     %edi,%esi
f0104ead:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104eb3:	74 0c                	je     f0104ec1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104eb5:	83 ef 01             	sub    $0x1,%edi
f0104eb8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0104ebb:	fd                   	std    
f0104ebc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104ebe:	fc                   	cld    
f0104ebf:	eb 21                	jmp    f0104ee2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104ec1:	f6 c1 03             	test   $0x3,%cl
f0104ec4:	75 ef                	jne    f0104eb5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104ec6:	83 ef 04             	sub    $0x4,%edi
f0104ec9:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104ecc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104ecf:	fd                   	std    
f0104ed0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104ed2:	eb ea                	jmp    f0104ebe <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104ed4:	89 f2                	mov    %esi,%edx
f0104ed6:	09 c2                	or     %eax,%edx
f0104ed8:	f6 c2 03             	test   $0x3,%dl
f0104edb:	74 09                	je     f0104ee6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104edd:	89 c7                	mov    %eax,%edi
f0104edf:	fc                   	cld    
f0104ee0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104ee2:	5e                   	pop    %esi
f0104ee3:	5f                   	pop    %edi
f0104ee4:	5d                   	pop    %ebp
f0104ee5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104ee6:	f6 c1 03             	test   $0x3,%cl
f0104ee9:	75 f2                	jne    f0104edd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104eeb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104eee:	89 c7                	mov    %eax,%edi
f0104ef0:	fc                   	cld    
f0104ef1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104ef3:	eb ed                	jmp    f0104ee2 <memmove+0x55>

f0104ef5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104ef5:	55                   	push   %ebp
f0104ef6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104ef8:	ff 75 10             	pushl  0x10(%ebp)
f0104efb:	ff 75 0c             	pushl  0xc(%ebp)
f0104efe:	ff 75 08             	pushl  0x8(%ebp)
f0104f01:	e8 87 ff ff ff       	call   f0104e8d <memmove>
}
f0104f06:	c9                   	leave  
f0104f07:	c3                   	ret    

f0104f08 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104f08:	55                   	push   %ebp
f0104f09:	89 e5                	mov    %esp,%ebp
f0104f0b:	56                   	push   %esi
f0104f0c:	53                   	push   %ebx
f0104f0d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f10:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104f13:	89 c6                	mov    %eax,%esi
f0104f15:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104f18:	39 f0                	cmp    %esi,%eax
f0104f1a:	74 1c                	je     f0104f38 <memcmp+0x30>
		if (*s1 != *s2)
f0104f1c:	0f b6 08             	movzbl (%eax),%ecx
f0104f1f:	0f b6 1a             	movzbl (%edx),%ebx
f0104f22:	38 d9                	cmp    %bl,%cl
f0104f24:	75 08                	jne    f0104f2e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0104f26:	83 c0 01             	add    $0x1,%eax
f0104f29:	83 c2 01             	add    $0x1,%edx
f0104f2c:	eb ea                	jmp    f0104f18 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104f2e:	0f b6 c1             	movzbl %cl,%eax
f0104f31:	0f b6 db             	movzbl %bl,%ebx
f0104f34:	29 d8                	sub    %ebx,%eax
f0104f36:	eb 05                	jmp    f0104f3d <memcmp+0x35>
	}

	return 0;
f0104f38:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104f3d:	5b                   	pop    %ebx
f0104f3e:	5e                   	pop    %esi
f0104f3f:	5d                   	pop    %ebp
f0104f40:	c3                   	ret    

f0104f41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104f41:	55                   	push   %ebp
f0104f42:	89 e5                	mov    %esp,%ebp
f0104f44:	8b 45 08             	mov    0x8(%ebp),%eax
f0104f47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104f4a:	89 c2                	mov    %eax,%edx
f0104f4c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104f4f:	39 d0                	cmp    %edx,%eax
f0104f51:	73 09                	jae    f0104f5c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104f53:	38 08                	cmp    %cl,(%eax)
f0104f55:	74 05                	je     f0104f5c <memfind+0x1b>
	for (; s < ends; s++)
f0104f57:	83 c0 01             	add    $0x1,%eax
f0104f5a:	eb f3                	jmp    f0104f4f <memfind+0xe>
			break;
	return (void *) s;
}
f0104f5c:	5d                   	pop    %ebp
f0104f5d:	c3                   	ret    

f0104f5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104f5e:	55                   	push   %ebp
f0104f5f:	89 e5                	mov    %esp,%ebp
f0104f61:	57                   	push   %edi
f0104f62:	56                   	push   %esi
f0104f63:	53                   	push   %ebx
f0104f64:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104f67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104f6a:	eb 03                	jmp    f0104f6f <strtol+0x11>
		s++;
f0104f6c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0104f6f:	0f b6 01             	movzbl (%ecx),%eax
f0104f72:	3c 20                	cmp    $0x20,%al
f0104f74:	74 f6                	je     f0104f6c <strtol+0xe>
f0104f76:	3c 09                	cmp    $0x9,%al
f0104f78:	74 f2                	je     f0104f6c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0104f7a:	3c 2b                	cmp    $0x2b,%al
f0104f7c:	74 2e                	je     f0104fac <strtol+0x4e>
	int neg = 0;
f0104f7e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0104f83:	3c 2d                	cmp    $0x2d,%al
f0104f85:	74 2f                	je     f0104fb6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104f87:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104f8d:	75 05                	jne    f0104f94 <strtol+0x36>
f0104f8f:	80 39 30             	cmpb   $0x30,(%ecx)
f0104f92:	74 2c                	je     f0104fc0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104f94:	85 db                	test   %ebx,%ebx
f0104f96:	75 0a                	jne    f0104fa2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104f98:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0104f9d:	80 39 30             	cmpb   $0x30,(%ecx)
f0104fa0:	74 28                	je     f0104fca <strtol+0x6c>
		base = 10;
f0104fa2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fa7:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104faa:	eb 50                	jmp    f0104ffc <strtol+0x9e>
		s++;
f0104fac:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0104faf:	bf 00 00 00 00       	mov    $0x0,%edi
f0104fb4:	eb d1                	jmp    f0104f87 <strtol+0x29>
		s++, neg = 1;
f0104fb6:	83 c1 01             	add    $0x1,%ecx
f0104fb9:	bf 01 00 00 00       	mov    $0x1,%edi
f0104fbe:	eb c7                	jmp    f0104f87 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104fc0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104fc4:	74 0e                	je     f0104fd4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0104fc6:	85 db                	test   %ebx,%ebx
f0104fc8:	75 d8                	jne    f0104fa2 <strtol+0x44>
		s++, base = 8;
f0104fca:	83 c1 01             	add    $0x1,%ecx
f0104fcd:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104fd2:	eb ce                	jmp    f0104fa2 <strtol+0x44>
		s += 2, base = 16;
f0104fd4:	83 c1 02             	add    $0x2,%ecx
f0104fd7:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104fdc:	eb c4                	jmp    f0104fa2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104fde:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104fe1:	89 f3                	mov    %esi,%ebx
f0104fe3:	80 fb 19             	cmp    $0x19,%bl
f0104fe6:	77 29                	ja     f0105011 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0104fe8:	0f be d2             	movsbl %dl,%edx
f0104feb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104fee:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104ff1:	7d 30                	jge    f0105023 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0104ff3:	83 c1 01             	add    $0x1,%ecx
f0104ff6:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104ffa:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104ffc:	0f b6 11             	movzbl (%ecx),%edx
f0104fff:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105002:	89 f3                	mov    %esi,%ebx
f0105004:	80 fb 09             	cmp    $0x9,%bl
f0105007:	77 d5                	ja     f0104fde <strtol+0x80>
			dig = *s - '0';
f0105009:	0f be d2             	movsbl %dl,%edx
f010500c:	83 ea 30             	sub    $0x30,%edx
f010500f:	eb dd                	jmp    f0104fee <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0105011:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105014:	89 f3                	mov    %esi,%ebx
f0105016:	80 fb 19             	cmp    $0x19,%bl
f0105019:	77 08                	ja     f0105023 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010501b:	0f be d2             	movsbl %dl,%edx
f010501e:	83 ea 37             	sub    $0x37,%edx
f0105021:	eb cb                	jmp    f0104fee <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105023:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105027:	74 05                	je     f010502e <strtol+0xd0>
		*endptr = (char *) s;
f0105029:	8b 75 0c             	mov    0xc(%ebp),%esi
f010502c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010502e:	89 c2                	mov    %eax,%edx
f0105030:	f7 da                	neg    %edx
f0105032:	85 ff                	test   %edi,%edi
f0105034:	0f 45 c2             	cmovne %edx,%eax
}
f0105037:	5b                   	pop    %ebx
f0105038:	5e                   	pop    %esi
f0105039:	5f                   	pop    %edi
f010503a:	5d                   	pop    %ebp
f010503b:	c3                   	ret    
f010503c:	66 90                	xchg   %ax,%ax
f010503e:	66 90                	xchg   %ax,%ax

f0105040 <__udivdi3>:
f0105040:	55                   	push   %ebp
f0105041:	57                   	push   %edi
f0105042:	56                   	push   %esi
f0105043:	53                   	push   %ebx
f0105044:	83 ec 1c             	sub    $0x1c,%esp
f0105047:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010504b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010504f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105053:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0105057:	85 d2                	test   %edx,%edx
f0105059:	75 35                	jne    f0105090 <__udivdi3+0x50>
f010505b:	39 f3                	cmp    %esi,%ebx
f010505d:	0f 87 bd 00 00 00    	ja     f0105120 <__udivdi3+0xe0>
f0105063:	85 db                	test   %ebx,%ebx
f0105065:	89 d9                	mov    %ebx,%ecx
f0105067:	75 0b                	jne    f0105074 <__udivdi3+0x34>
f0105069:	b8 01 00 00 00       	mov    $0x1,%eax
f010506e:	31 d2                	xor    %edx,%edx
f0105070:	f7 f3                	div    %ebx
f0105072:	89 c1                	mov    %eax,%ecx
f0105074:	31 d2                	xor    %edx,%edx
f0105076:	89 f0                	mov    %esi,%eax
f0105078:	f7 f1                	div    %ecx
f010507a:	89 c6                	mov    %eax,%esi
f010507c:	89 e8                	mov    %ebp,%eax
f010507e:	89 f7                	mov    %esi,%edi
f0105080:	f7 f1                	div    %ecx
f0105082:	89 fa                	mov    %edi,%edx
f0105084:	83 c4 1c             	add    $0x1c,%esp
f0105087:	5b                   	pop    %ebx
f0105088:	5e                   	pop    %esi
f0105089:	5f                   	pop    %edi
f010508a:	5d                   	pop    %ebp
f010508b:	c3                   	ret    
f010508c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105090:	39 f2                	cmp    %esi,%edx
f0105092:	77 7c                	ja     f0105110 <__udivdi3+0xd0>
f0105094:	0f bd fa             	bsr    %edx,%edi
f0105097:	83 f7 1f             	xor    $0x1f,%edi
f010509a:	0f 84 98 00 00 00    	je     f0105138 <__udivdi3+0xf8>
f01050a0:	89 f9                	mov    %edi,%ecx
f01050a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01050a7:	29 f8                	sub    %edi,%eax
f01050a9:	d3 e2                	shl    %cl,%edx
f01050ab:	89 54 24 08          	mov    %edx,0x8(%esp)
f01050af:	89 c1                	mov    %eax,%ecx
f01050b1:	89 da                	mov    %ebx,%edx
f01050b3:	d3 ea                	shr    %cl,%edx
f01050b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01050b9:	09 d1                	or     %edx,%ecx
f01050bb:	89 f2                	mov    %esi,%edx
f01050bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01050c1:	89 f9                	mov    %edi,%ecx
f01050c3:	d3 e3                	shl    %cl,%ebx
f01050c5:	89 c1                	mov    %eax,%ecx
f01050c7:	d3 ea                	shr    %cl,%edx
f01050c9:	89 f9                	mov    %edi,%ecx
f01050cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01050cf:	d3 e6                	shl    %cl,%esi
f01050d1:	89 eb                	mov    %ebp,%ebx
f01050d3:	89 c1                	mov    %eax,%ecx
f01050d5:	d3 eb                	shr    %cl,%ebx
f01050d7:	09 de                	or     %ebx,%esi
f01050d9:	89 f0                	mov    %esi,%eax
f01050db:	f7 74 24 08          	divl   0x8(%esp)
f01050df:	89 d6                	mov    %edx,%esi
f01050e1:	89 c3                	mov    %eax,%ebx
f01050e3:	f7 64 24 0c          	mull   0xc(%esp)
f01050e7:	39 d6                	cmp    %edx,%esi
f01050e9:	72 0c                	jb     f01050f7 <__udivdi3+0xb7>
f01050eb:	89 f9                	mov    %edi,%ecx
f01050ed:	d3 e5                	shl    %cl,%ebp
f01050ef:	39 c5                	cmp    %eax,%ebp
f01050f1:	73 5d                	jae    f0105150 <__udivdi3+0x110>
f01050f3:	39 d6                	cmp    %edx,%esi
f01050f5:	75 59                	jne    f0105150 <__udivdi3+0x110>
f01050f7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01050fa:	31 ff                	xor    %edi,%edi
f01050fc:	89 fa                	mov    %edi,%edx
f01050fe:	83 c4 1c             	add    $0x1c,%esp
f0105101:	5b                   	pop    %ebx
f0105102:	5e                   	pop    %esi
f0105103:	5f                   	pop    %edi
f0105104:	5d                   	pop    %ebp
f0105105:	c3                   	ret    
f0105106:	8d 76 00             	lea    0x0(%esi),%esi
f0105109:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0105110:	31 ff                	xor    %edi,%edi
f0105112:	31 c0                	xor    %eax,%eax
f0105114:	89 fa                	mov    %edi,%edx
f0105116:	83 c4 1c             	add    $0x1c,%esp
f0105119:	5b                   	pop    %ebx
f010511a:	5e                   	pop    %esi
f010511b:	5f                   	pop    %edi
f010511c:	5d                   	pop    %ebp
f010511d:	c3                   	ret    
f010511e:	66 90                	xchg   %ax,%ax
f0105120:	31 ff                	xor    %edi,%edi
f0105122:	89 e8                	mov    %ebp,%eax
f0105124:	89 f2                	mov    %esi,%edx
f0105126:	f7 f3                	div    %ebx
f0105128:	89 fa                	mov    %edi,%edx
f010512a:	83 c4 1c             	add    $0x1c,%esp
f010512d:	5b                   	pop    %ebx
f010512e:	5e                   	pop    %esi
f010512f:	5f                   	pop    %edi
f0105130:	5d                   	pop    %ebp
f0105131:	c3                   	ret    
f0105132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105138:	39 f2                	cmp    %esi,%edx
f010513a:	72 06                	jb     f0105142 <__udivdi3+0x102>
f010513c:	31 c0                	xor    %eax,%eax
f010513e:	39 eb                	cmp    %ebp,%ebx
f0105140:	77 d2                	ja     f0105114 <__udivdi3+0xd4>
f0105142:	b8 01 00 00 00       	mov    $0x1,%eax
f0105147:	eb cb                	jmp    f0105114 <__udivdi3+0xd4>
f0105149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105150:	89 d8                	mov    %ebx,%eax
f0105152:	31 ff                	xor    %edi,%edi
f0105154:	eb be                	jmp    f0105114 <__udivdi3+0xd4>
f0105156:	66 90                	xchg   %ax,%ax
f0105158:	66 90                	xchg   %ax,%ax
f010515a:	66 90                	xchg   %ax,%ax
f010515c:	66 90                	xchg   %ax,%ax
f010515e:	66 90                	xchg   %ax,%ax

f0105160 <__umoddi3>:
f0105160:	55                   	push   %ebp
f0105161:	57                   	push   %edi
f0105162:	56                   	push   %esi
f0105163:	53                   	push   %ebx
f0105164:	83 ec 1c             	sub    $0x1c,%esp
f0105167:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010516b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010516f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0105173:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105177:	85 ed                	test   %ebp,%ebp
f0105179:	89 f0                	mov    %esi,%eax
f010517b:	89 da                	mov    %ebx,%edx
f010517d:	75 19                	jne    f0105198 <__umoddi3+0x38>
f010517f:	39 df                	cmp    %ebx,%edi
f0105181:	0f 86 b1 00 00 00    	jbe    f0105238 <__umoddi3+0xd8>
f0105187:	f7 f7                	div    %edi
f0105189:	89 d0                	mov    %edx,%eax
f010518b:	31 d2                	xor    %edx,%edx
f010518d:	83 c4 1c             	add    $0x1c,%esp
f0105190:	5b                   	pop    %ebx
f0105191:	5e                   	pop    %esi
f0105192:	5f                   	pop    %edi
f0105193:	5d                   	pop    %ebp
f0105194:	c3                   	ret    
f0105195:	8d 76 00             	lea    0x0(%esi),%esi
f0105198:	39 dd                	cmp    %ebx,%ebp
f010519a:	77 f1                	ja     f010518d <__umoddi3+0x2d>
f010519c:	0f bd cd             	bsr    %ebp,%ecx
f010519f:	83 f1 1f             	xor    $0x1f,%ecx
f01051a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01051a6:	0f 84 b4 00 00 00    	je     f0105260 <__umoddi3+0x100>
f01051ac:	b8 20 00 00 00       	mov    $0x20,%eax
f01051b1:	89 c2                	mov    %eax,%edx
f01051b3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01051b7:	29 c2                	sub    %eax,%edx
f01051b9:	89 c1                	mov    %eax,%ecx
f01051bb:	89 f8                	mov    %edi,%eax
f01051bd:	d3 e5                	shl    %cl,%ebp
f01051bf:	89 d1                	mov    %edx,%ecx
f01051c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01051c5:	d3 e8                	shr    %cl,%eax
f01051c7:	09 c5                	or     %eax,%ebp
f01051c9:	8b 44 24 04          	mov    0x4(%esp),%eax
f01051cd:	89 c1                	mov    %eax,%ecx
f01051cf:	d3 e7                	shl    %cl,%edi
f01051d1:	89 d1                	mov    %edx,%ecx
f01051d3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01051d7:	89 df                	mov    %ebx,%edi
f01051d9:	d3 ef                	shr    %cl,%edi
f01051db:	89 c1                	mov    %eax,%ecx
f01051dd:	89 f0                	mov    %esi,%eax
f01051df:	d3 e3                	shl    %cl,%ebx
f01051e1:	89 d1                	mov    %edx,%ecx
f01051e3:	89 fa                	mov    %edi,%edx
f01051e5:	d3 e8                	shr    %cl,%eax
f01051e7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01051ec:	09 d8                	or     %ebx,%eax
f01051ee:	f7 f5                	div    %ebp
f01051f0:	d3 e6                	shl    %cl,%esi
f01051f2:	89 d1                	mov    %edx,%ecx
f01051f4:	f7 64 24 08          	mull   0x8(%esp)
f01051f8:	39 d1                	cmp    %edx,%ecx
f01051fa:	89 c3                	mov    %eax,%ebx
f01051fc:	89 d7                	mov    %edx,%edi
f01051fe:	72 06                	jb     f0105206 <__umoddi3+0xa6>
f0105200:	75 0e                	jne    f0105210 <__umoddi3+0xb0>
f0105202:	39 c6                	cmp    %eax,%esi
f0105204:	73 0a                	jae    f0105210 <__umoddi3+0xb0>
f0105206:	2b 44 24 08          	sub    0x8(%esp),%eax
f010520a:	19 ea                	sbb    %ebp,%edx
f010520c:	89 d7                	mov    %edx,%edi
f010520e:	89 c3                	mov    %eax,%ebx
f0105210:	89 ca                	mov    %ecx,%edx
f0105212:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0105217:	29 de                	sub    %ebx,%esi
f0105219:	19 fa                	sbb    %edi,%edx
f010521b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010521f:	89 d0                	mov    %edx,%eax
f0105221:	d3 e0                	shl    %cl,%eax
f0105223:	89 d9                	mov    %ebx,%ecx
f0105225:	d3 ee                	shr    %cl,%esi
f0105227:	d3 ea                	shr    %cl,%edx
f0105229:	09 f0                	or     %esi,%eax
f010522b:	83 c4 1c             	add    $0x1c,%esp
f010522e:	5b                   	pop    %ebx
f010522f:	5e                   	pop    %esi
f0105230:	5f                   	pop    %edi
f0105231:	5d                   	pop    %ebp
f0105232:	c3                   	ret    
f0105233:	90                   	nop
f0105234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105238:	85 ff                	test   %edi,%edi
f010523a:	89 f9                	mov    %edi,%ecx
f010523c:	75 0b                	jne    f0105249 <__umoddi3+0xe9>
f010523e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105243:	31 d2                	xor    %edx,%edx
f0105245:	f7 f7                	div    %edi
f0105247:	89 c1                	mov    %eax,%ecx
f0105249:	89 d8                	mov    %ebx,%eax
f010524b:	31 d2                	xor    %edx,%edx
f010524d:	f7 f1                	div    %ecx
f010524f:	89 f0                	mov    %esi,%eax
f0105251:	f7 f1                	div    %ecx
f0105253:	e9 31 ff ff ff       	jmp    f0105189 <__umoddi3+0x29>
f0105258:	90                   	nop
f0105259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105260:	39 dd                	cmp    %ebx,%ebp
f0105262:	72 08                	jb     f010526c <__umoddi3+0x10c>
f0105264:	39 f7                	cmp    %esi,%edi
f0105266:	0f 87 21 ff ff ff    	ja     f010518d <__umoddi3+0x2d>
f010526c:	89 da                	mov    %ebx,%edx
f010526e:	89 f0                	mov    %esi,%eax
f0105270:	29 f8                	sub    %edi,%eax
f0105272:	19 ea                	sbb    %ebp,%edx
f0105274:	e9 14 ff ff ff       	jmp    f010518d <__umoddi3+0x2d>
