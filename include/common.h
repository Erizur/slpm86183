#ifndef COMMON_H
#define COMMON_H

#include <sys/types.h>
#include <libgte.h>
#include <libgpu.h>

// Our types
typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef signed char s8;
typedef signed short s16;
typedef signed int s32;

extern int fprintf(int fd, const char* fmt, ...);

// ghidra current functions
extern void __main(void);
extern void FUN_80061fbc(int param);
extern void FUN_80060f00(int param1, void* param2, void* param3, int param4);

#endif
