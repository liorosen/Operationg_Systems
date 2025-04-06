#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

extern int forkn(int, int*);
extern int waitall(int*, int*);


uint64 sys_exit(void)
{
  int status;
  argint(0, &status);
  exit_num(status);  
  return 0; // never returns
}

uint64 sys_exitmsg(void)
{
  /*
  char msg[32];
  argstr(0, msg, sizeof(msg));
  exit_msg(msg);
  return 0; // never returns
  */

  char msg[32];
  if (argstr(0, msg, sizeof(msg)) < 0)
    return -1;

  exit_msg(msg);
  return 0;

  
}

uint64 sys_getpid(void)
{
  return myproc()->pid;
}

uint64 sys_fork(void)
{
  return fork();
}

/*
uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}
*/
uint64 sys_wait(void)
{
  uint64 status_addr;
  uint64 msg_addr;

  argaddr(0, &status_addr);
  argaddr(1, &msg_addr);


  //if (argaddr(0, &status_addr) < 0 || argaddr(1, &msg_addr) < 0)
    //return -1;

  return wait(status_addr, msg_addr);
}


uint64 sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64 sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64 sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64 sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}


//I Added
uint64 sys_memsize(void)
{
  struct proc *p = myproc();
  return p->sz;
}

uint64 sys_forkn(void)
{
  int n;
  uint64 pids_addr;

  // Get args from userspace
  if (argint(0, &n) < 0 || argaddr(1, &pids_addr) < 0)
    return -1;

  // Check for invalid input
  if (n < 1 || n > 16 || pids_addr == 0)
    return -1;

  int pids[16]; // Temporary kernel buffer

  int result = forkn(n, pids);  
  if (result == 0) {
    struct proc *p = myproc();
    if (copyout(p->pagetable, pids_addr, (char *)pids, n * sizeof(int)) < 0)
      return -1;
  }

  return result;
}

uint64 sys_waitall(void)
{
  uint64 n_addr, statuses_addr;

  argaddr(0, &n_addr);
  argaddr(1, &statuses_addr);

  if (n_addr == 0 || statuses_addr == 0)
    return -1;

  return waitall((int *)n_addr, (int *)statuses_addr);
}

uint64 sys_exit_num(void) {
  int status;
  if(argint(0, &status) < 0)
    return -1;
  exit_num(status);
  return 0; 
}




