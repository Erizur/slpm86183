#include "common.h"

typedef struct SRN_TABLE SRN_TABLE; 

typedef struct {
    char      name[16];
    short     bg_id;
    short     flag;
    unsigned short clut_id;
    short     col_num;
    short     srn_num;
    short     srn_id;
    unsigned char *csr_data;
    unsigned char *mod_data;
    SRN_TABLE     *srn_table;
} BG_TABLE;

extern BG_TABLE bg_table[];

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_StartDaemon);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_Delete);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_DeleteAll);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_SetAnmBG);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001b554);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", func_8001B59C);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_Create2);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", make_module);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001bc7c);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001bee8);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001c158);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001c1e4);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001c208);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001c220);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", vram_write);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001c5cc);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001c930);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001c974);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001c9ec);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", func_8001CAD0);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001cadc);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_MaskStart);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_MaskEnd);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_MaskReset);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", FUN_8001ccb0);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_FadeOutStart);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_FadeOut);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_FadeEnd);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_FadeInStart);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_FadeIn);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", SRN_FadeReset);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", OPD_Free);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", OPD_FreeAll);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", OPD_Trans);

INCLUDE_ASM("asm/SLPM_861.83/nonmatchings/srn", func_8001D644);
