#include "common.h"

extern void func_800157A8(void);
extern void *D_8007F9B0;
extern char LBL_POPNSTART[];

/* Note for future development:
 * fprintf is a function declared by KCEJ's MTS library, not the standard libc one.
 * Stubbed since Metal Gear Solid.
 */

int main(void) {
    FUN_80061fbc(2);
    fprintf(-1, LBL_POPNSTART);
    FUN_80060f00(
        3,
        (void*)&func_800157A8,
        (void*)&D_8007F9B0,
        0x800
    );
    return 0;
}