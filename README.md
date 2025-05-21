# Enhanced xv-6
## Syscalls Added
- Syscall `getSysCount` keeps a track of the number of times a particular syscall has been called.
- If any application calls syscall `sigalaram(n,fn)` after every n  ”ticks” of CPU time that the program consumes, the kernel will cause application function fn  to be called. 
When fn  returns, the application will resume where it left off.
- Syscall `sigreturn()` returns to the state before handler was called

## Schedulers

Implemented two schedulers

- Lottery based scheduler, where processes are assigned lottery tickets, and the scheduler selects the next process by drawing a random ticket from the pool of tickets
- MLFQ scheduling divides processes into multiple queues based on their priority levels, priority of a process can be changed based on the amount of cpu time a process is consuming.
-   Each process in a queue is given a particular time slice, if it uses that time slice its priority goes down.
-   Priority boost has been implemented where all processes are sent to high priority queue to avoid starvation
