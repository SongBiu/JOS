/* See COPYRIGHT for copyright information. */

#ifndef JOS_INC_ENV_H
#define JOS_INC_ENV_H

#include <inc/types.h>
#include <inc/trap.h>
#include <inc/memlayout.h>

typedef int32_t envid_t;

// An environment ID 'envid_t' has three parts:
//
// +1+---------------21-----------------+--------10--------+
// |0|          Uniqueifier             |   Environment    |
// | |                                  |      Index       |
// +------------------------------------+------------------+
//                                       \--- ENVX(eid) --/
//
// The environment index ENVX(eid) equals the environment's index in the
// 'envs[]' array.  The uniqueifier distinguishes environments that were
// created at different times, but share the same environment index.
//
// All real environments are greater than 0 (so the sign bit is zero).
// envid_ts less than 0 signify errors.  The envid_t == 0 is special, and
// stands for the current environment.

#define LOG2NENV		10
#define NENV			(1 << LOG2NENV)
#define ENVX(envid)		((envid) & (NENV - 1))

// Values of env_status in struct Env
enum {
	ENV_FREE = 0,
	ENV_DYING,
	ENV_RUNNABLE,
	ENV_RUNNING,
	ENV_NOT_RUNNABLE
};

// Special environment types
enum EnvType {
	ENV_TYPE_USER = 0,
};

struct Env {

	// 保存运行环境的寄存器值，用于恢复状态
	struct Trapframe env_tf;	// Saved registers
	// 指向下一个运行环境
	struct Env *env_link;		// Next free Env

	// 运行环境id
	envid_t env_id;			// Unique environment identifier

	// 父环境的id
	envid_t env_parent_id;		// env_id of this env's parent

	// 运行环境的类型，分为用户态和内核态
	enum EnvType env_type;		// Indicates special system environments
	
	// 运行环境的状态
	/*
		ENV_FREE：等待分配
		ENV_DYING：僵死进程
		ENV_RUNNABLE：就绪状态，等待运行
		ENV_RUNNING：正在运行
		ENV_NOT_RUNNABLE：已经分配但不能运行，在等待另外一个进程的信号
	*/
	unsigned env_status;		// Status of the environment

	// 进程的运行次数
	uint32_t env_runs;		// Number of times environment has run


	// 进程的页目录
	// Address space
	pde_t *env_pgdir;		// Kernel virtual address of page dir
};

#endif // !JOS_INC_ENV_H
