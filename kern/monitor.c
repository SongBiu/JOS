// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/pmap.h>
#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{"help", "Display this list of commands", mon_help},
	{"kerninfo", "Display information about the kernel", mon_kerninfo},
	{"backtrace", "stack backtrace", mon_backtrace},
	{"showmappings", "show the relation of physical page mappings", mon_showmappings},
	{"mPerm", "modify the permission", mon_mPerm},
	{"dump", "dump the memory", mon_dump},
	{"mAddr", "modify the info of virtual memory\n", mon_mAddr}
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	cprintf("Stack backtrace:\n");
	const int MAXNAME = 9;
	int i, len;
	struct Eipdebuginfo info;
	struct Trapframe *ebp;
	ebp = (struct Trapframe *)read_ebp();
	uint32_t eip;
	char fn_name[MAXNAME];
	while (ebp)
	{
		eip = *((uint32_t *)ebp + 1);
		cprintf("  ebp %08x eip %08x  args", ebp, eip);
		for (i = 0; i < 5; i++)
		{
			cprintf(" %08x", *((uint32_t *)ebp + 2 + i));
		}
		cprintf("\n");
		debuginfo_eip(eip, &info);
		len = strlen(info.eip_fn_name);
		for (i = 0; i < len; i++)
		{
			if (info.eip_fn_name[i] == ':')
			{
				break;
			}
		}
		strncpy(fn_name, info.eip_fn_name, i);
		fn_name[i] = '\0';
		cprintf("%s:%d: %s+%d\n", info.eip_file, info.eip_line, fn_name, eip - info.eip_fn_addr);
		ebp = (struct Trapframe*)((uint32_t*)ebp + 8);
	}
	return 0;
}
void showmappings(uintptr_t start, uintptr_t end)
{
	cprintf("Following are address mapping from 0x%x to 0x%x:\n", start, end);
	uintptr_t current_page_address;
	struct PageInfo *page = NULL;
	pte_t *pte = NULL;
	for (current_page_address = start; current_page_address <= end; current_page_address += PGSIZE)
	{
		page = page_lookup(kern_pgdir, (void *)current_page_address, &pte);
		if (!page)
		{
			cprintf("  The virtual address 0x%x have no physical page\n", current_page_address);
			continue;
		}
		cprintf("  The virtual address is 0x%x\n", current_page_address);
		cprintf("    The mapping physical page address is 0x%08x\n", page2pa(page));
		cprintf("    The permissions bits:\n");
		cprintf("      PTE_P: %d PTE_W: %d PTE_U: %d PTE_PWT: %d PTE_PCD: %d PTE_A: %d PTE_D: %d PTE_PS: %d PTE_G: %d\n\n",
				!!(*pte & PTE_P),
				!!(*pte & PTE_W),
				!!(*pte & PTE_U),
				!!(*pte & PTE_PWT),
				!!(*pte & PTE_PCD),
				!!(*pte & PTE_A),
				!!(*pte & PTE_D),
				!!(*pte & PTE_PS),
				!!(*pte & PTE_G));
	}
	return;
}
int mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
	// showmappings start end
	assert(argc == 3);
	uintptr_t start = strtol(argv[1], NULL, 16), end = strtol(argv[2], NULL, 16);
	if (start != ROUNDUP(start, PGSIZE) || end != ROUNDUP(end, PGSIZE))
	{
		cprintf("Command is showmappings 0xaddr_start 0xaddr_end\n");
		return 0;
	}
	showmappings(start, end);
	return 0;
}
void mPerm(char *ops, uintptr_t va, char *perm, int new_perm)
{
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)va, 1);
	uint32_t tmp = 0xffffffff;
	if (new_perm == 1)
	{
		tmp = 0;
	}
	if (strcmp(perm, "PTE_P") == 0)
	{
		tmp = tmp ^ PTE_P;
	}
	else if (strcmp(perm, "PTE_W") == 0)
	{
		tmp = tmp ^ PTE_W;
	}
	else if (strcmp(perm, "PTE_U") == 0)
	{
		tmp = tmp ^ PTE_U;
	}
	else if (strcmp(perm, "PTE_PWT") == 0)
	{
		tmp = tmp ^ PTE_PWT;
	}
	else if (strcmp(perm, "PTE_PCD") == 0)
	{
		tmp = tmp ^ PTE_PCD;
	}
	else if (strcmp(perm, "PTE_A") == 0)
	{
		tmp = tmp ^ PTE_A;
	}
	else if (strcmp(perm, "PTE_D") == 0)
	{
		tmp = tmp ^ PTE_D;
	}
	else if (strcmp(perm, "PTE_PS") == 0)
	{
		tmp = tmp ^ PTE_PS;
	}
	else if (strcmp(perm, "PTE_G") == 0)
	{
		tmp = tmp ^ PTE_G;
	}
	if (new_perm == 1)
	{
		*pte |= tmp;
	}
	else
	{
		*pte &= tmp;
	}
	return;
}
int mon_mPerm(int argc, char **argv, struct Trapframe *tf)
{
	char *ops = argv[1];
	uintptr_t va = strtol(argv[2], NULL, 16);
	char *perm = argv[3];
	int new_perm = 0;
	if (va != (uintptr_t)ROUNDUP(va, PGSIZE))
	{
		cprintf("The command is mPerm SET|CLEAR|CHANGE perm (new_perm)?\n");
		return 0;
	}
	if (!strcmp(ops, "CHANGE"))
	{
		assert(argc == 5);
		new_perm = strtol(argv[4], NULL, 10);
	}
	else if (!strcmp(ops, "SET"))
	{
		assert(argc == 4);
		new_perm = 1;
	}
	else if (!strcmp(ops, "CLEAR"))
	{
		assert(argc == 4);
		new_perm = 0;
	}
	else 
	{
		cprintf("INVALID COMMAND\n");
	}
	mPerm(ops, va, perm, new_perm);
	return 0;
}
void dump_v(uintptr_t va_start, uintptr_t va_end)
{
	uintptr_t current_va;
	for (current_va = va_start; current_va <= va_end; current_va += PGSIZE)
	{
		cprintf("The virtual address is 0x%08x and content is 0x%08x\n", current_va, *(uint32_t *)current_va);
	}
	return;
}
void dump_p(physaddr_t pa_start, physaddr_t pa_end)
{
	physaddr_t current_pa;
	for (current_pa = pa_start; current_pa <= pa_end; current_pa += PGSIZE)
	{
		cprintf("The physical address is 0x%08x and content is 0x%08x\n", current_pa, *(uint32_t *)KADDR(current_pa));
	}
	return;
}
int mon_dump(int argc, char **argv, struct Trapframe *tf)
{
	// dump start end
	assert(argc == 4);
	uintptr_t v_start, v_end;
	physaddr_t p_start, p_end;
	char *addr_type = argv[1];
	if (!strcmp(addr_type, "physical"))
	{
		p_start = strtol(argv[2], NULL, 16);
		p_end = strtol(argv[3], NULL, 16);
		if (p_start != ROUNDUP(p_start, PGSIZE) || p_end != ROUNDUP(p_end, PGSIZE))
		{
			cprintf("Command is dump 0xaddr_start 0xaddr_end\n");
			return 0;
		}
		dump_p(p_start, p_end);
	}
	else if (!strcmp(addr_type, "virtual"))
	{
		v_start = strtol(argv[2], NULL, 16);
		v_end = strtol(argv[3], NULL, 16);
		if (v_start != ROUNDUP(v_start, PGSIZE) || v_end != ROUNDUP(v_end, PGSIZE))
		{
			cprintf("Command is dump 0xaddr_start 0xaddr_end\n");
			return 0;
		}
		dump_v(v_start, v_end);
	}
	else
	{
		cprintf("INVAILD ADDRESS TYPE\n");
		return 0;
	}
	
	
	return 0;
}
void mAddr(uintptr_t va, uint32_t info)
{
	*(uint32_t *)va = info;
	return;
}
int mon_mAddr(int argc, char **argv, struct Trapframe *tf)
{
	assert(argc == 3);
	uintptr_t va;
	uint32_t info;
	va = strtol(argv[1], NULL, 16);
	info = strtol(argv[2], NULL, 16);
	if (va != ROUNDUP(va, PGSIZE))
	{
		cprintf("Command: mAddr 0xva info");
		return 0;
	}
	mAddr(va, info);
	return 0;
}
/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");
	cprintf("%m%s\n%m%s\n%m%s\n", 0x0100, "blue", 0x0200, "green", 0x0400, "red");

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}