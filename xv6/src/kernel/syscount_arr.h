#ifndef MY_SYSCOUNT_H
#define MY_SYSCOUNT_H
#ifdef MY_SYSCOUNT_IMPLEMENTATION
// declare syscount array
int syscount[31];
#else
extern int syscount[31];
#endif

#endif