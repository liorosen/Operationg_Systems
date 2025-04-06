#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_memsize(void)
{
  struct proc *p = myproc(); // קבל את התהליך הנוכחי
  return p->sz; 
}

uint64
sys_exit(void)
{
  int status;
  char msg[32] = {0};

  argint(0, &status); 
  argstr(1, msg, sizeof(msg)); // ארגומנט 2: הודעת יציאה

  struct proc *p = myproc();
  strncpy(p->exit_msg, msg, sizeof(p->exit_msg)); // שמור בהודעת יציאה
  p->exit_msg[31] = '\0'; // ודא סיום תקין

  exit(status); 
  return 0;     
}


uint64
sys_exit2(void)
{
  int status;
  argint(0, &status);
  argstr(1, myproc()->exit_msg, 32);  // copy exit message directly
  exit(status);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 status_addr;
  uint64 msg_addr;
  argaddr(0, &status_addr);
  argaddr(1, &msg_addr);
  return wait(status_addr, msg_addr);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
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

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
