#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
typedef struct proc
{
    int syscall[1];
} proc;
proc x[10];
int main()
{
    int pid = fork();
    if (pid == 0)
    {
        printf("Child start\n");
        // x->syscall[0] = 1;
        printf("Child end\n");
        exit(0);
    }
    else
    {
        int status;
        wait(&status);
        printf("Parent start\n");
        printf("%d\n", x->syscall[0]);
        x->syscall[0] = -1;
        printf("Parent end\n");
    }
}