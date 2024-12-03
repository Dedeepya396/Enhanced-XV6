#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"
#define MY_SYSCOUNT_IMPLEMENTATION
#include "../kernel/syscount_arr.h"
int is_valid_integer(const char *str)
{
      if (str == 0 || *str == '\0')
      {
            return 0;
      }
      if (*str == '-')
      {
            return 0;
      }
      while (*str != '\0')
      {
            if (*str < '0' || *str > '9')
            {
                  return 0;
            }
            str++;
      }
      return 1;
}
int is_power_of_2(int n) {
    return n > 0 && (n & (n - 1)) == 0;
}
int main(int argc, char *argv[])
{
      if (argc < 3)
      {
            printf("Usage: syscount <mask> command [args]\n");
            exit(0);
      }
      int mask = atoi(argv[1]);
      if (!is_valid_integer(argv[1])|| (!is_power_of_2(mask)))
      {
            printf("Enter a valid mask\n");
            return 0;
      }
      getcount(mask);
      int pid = fork();
      if (pid < 0)
      {
            printf("Error in creating child\n");
            exit(0);
      }
      if (pid == 0)
      {
            exec(argv[2], &argv[2]);
            printf("exec failed\n");
            exit(0);
      }
      else
      {
            int status;
            wait(&status);
            int count = getcount(mask);
            char *arr[31] = {
                "fork", "exit", "wait", "pipe", "read", "kill", "exec", "fstat", "chdir", "dup",
                "getpid", "sbrk", "sleep", "uptime", "open", "write", "mknod", "unlink", "link", "mkdir",
                "close", "waitx"};
            int a = 0;
            for (int i = 0; i < 31; i++)
            {
                  if (1 << i == mask)
                  {
                        a = i;
                        break;
                  }
            }

            printf("PID %d called the %s %d times.\n", pid, arr[a - 1], count);
            for (int i = 0; i < 31; i++)
            {
                  syscount[i] = 0;
            }
      }
      return 0;
}
