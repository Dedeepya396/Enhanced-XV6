#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "syscount_arr.h"
uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
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
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if (growproc(n) < 0)
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
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
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

uint64
sys_waitx(void)
{
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
  argaddr(1, &addr1); // user virtual memory
  argaddr(2, &addr2);
  int ret = waitx(addr, &wtime, &rtime);
  struct proc *p = myproc();
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    return -1;
  return ret;
}

uint64
sys_setmask(void)
{
  int mask;
  if (argint(0, &mask) < 0)
    return -1;
  struct proc *p = myproc();
  p->mask = mask; // Set the mask for the current process
  return 0;
}

uint64
sys_getcount(void)
{

  int mask;
  if (argint(0, &mask) < 0)
    return -1;
  // printf("%d\n", mask);
  struct proc *p = myproc();
  int count = 0;
  struct proc *temp;
  for (temp = proc; temp < &proc[NPROC]; temp++)
  {
    if (temp == p || temp->parent == p)
    {

      for (int i = 1; i < 31; i++)
      {
        if (mask == 1 << i)
        {
          count = syscount[i];
          syscount[i] = 0;
          return count;
        }
        syscount[i] = 0;
      }
    }
  }
  return count;
}
int sys_sigalarm(void)
{
  int ticks;
  if (argint(0, &ticks) < 0)
    return -1;
  if (ticks < 0)
  {
    printf("Invalid number\n");
  }
  
  uint64 handler_address;

  if (argaddr(1, &handler_address) < 0)
    return -1;

  void (*handler)() = (void (*)())handler_address;

  struct proc *p = myproc();
  p->alarmticks = ticks;
  p->alarmhandler = handler;
  p->ticks_passed = 0;
  return 0;
}

int sys_sigreturn(void)
{
  struct proc *p = myproc();
  memmove(p->trapframe, &p->alarm_tf, sizeof(struct trapframe));
  p->handling_alarm = 0;
  return p->alarm_tf.a0;
}

// Sets the number of tickets for the calling process.
int sys_settickets(int number)
{
  struct proc *p = myproc(); // get the current process
  if (number < 1)
  {
    return -1; // invalid number of tickets
  }
  acquire(&p->lock);  // acquire lock to modify process state
  p->ticket = number; // set the new ticket count
  release(&p->lock);
  return 0;
}
