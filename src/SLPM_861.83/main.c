#include "common.h"

extern void PopnMain(void);
extern void *DAT_8007f9b0;
extern char LBL_POPNSTART[];

/* Note for future development:
 * fprintf is a function declared by KCEJ's MTS library, not the standard libc one.
 * Stubbed since Metal Gear Solid.
 */

int main(void) {
    init_sio(2);
    fprintf(-1, LBL_POPNSTART);
    mts_boot_task(
        3,
        (void*)&PopnMain,
                  (void*)&DAT_8007f9b0,
                  0x800
    );
    return 0;
}

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/main", PopnMain);
