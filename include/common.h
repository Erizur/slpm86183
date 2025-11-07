#ifndef COMMON_H
#define COMMON_H

#include "include_asm.h"
#include "types.h"

extern int fprintf(int fd, const char* fmt, ...);

// ghidra current functions
extern void __main(void);
extern void FUN_80061fbc(int param);
extern void FUN_80060f00(int param1, void* param2, void* param3, int param4);

#endif
