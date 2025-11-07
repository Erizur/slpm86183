# binaries
GAME_ID         := SLPM_861.83
GAME            := SLPM_86183
SHORT_ID	:= slpm861
SLPM_861        := SLPM_861

# compilers
GCC             := ./bin/gcc -c -B./bin/
CC              := ./bin/cc1 -quiet

CROSS           := mips-linux-gnu-
AS              := $(CROSS)as -EL -32 -march=r3000 -mtune=r3000 -msoft-float -no-pad-sections -Iinclude/
LD              := $(CROSS)ld -EL
CPP             := $(CROSS)cpp
OBJCOPY         := $(CROSS)objcopy
MODERN_GCC      := gcc

AS_FLAGS        := -Wa,-EL,-march=r3000,-mtune=r3000,-msoft-float,-no-pad-sections,-Iinclude
# AS_FLAGS        := -Iinclude -march=r3000 -mtune=r3000 -no-pad-sections -Os

CPP_FLAGS       := -Iinclude -Iinclude/psyq
CPP_FLAGS       += -undef -lang-c -Wall -fno-builtin -fsigned-char
CPP_FLAGS       += -Dmips -D__GNUC__=2 -D__OPTIMIZE__ -D__mips__ -D__mips -Dpsx -D__psx__ -D__psx -D_PSYQ -D__EXTENSIONS__ -D_MIPSEL -D_LANGUAGE_C -DLANGUAGE_C

CC_FLAGS        := -mips1 -mno-abicalls -mel -msplit-addresses -mgpOPT -mgpopt -msoft-float -gcoff
CC_FLAGS        += $(CPP_FLAGS)

CHECK_WARNINGS  := -Wall -Wextra -Wno-format-security -Wno-unknown-pragmas -Wno-unused-parameter -Wno-unused-variable -Wno-missing-braces -Wno-int-conversion
CC_CHECK        := $(MODERN_GCC) -fsyntax-only -std=gnu90 -m32 $(CHECK_WARNINGS) $(CPP_FLAGS)

ifdef PERMUTER
CPP_FLAGS       += -DPERMUTER
endif

# directories
ASM_DIR         := asm
SRC_DIR         := src
INCLUDE_DIR     := include
BUILD_DIR       := build
CONFIG_DIR      := config
LINKER_DIR	:= linker
TOOLS_DIR       := tools

# files
PM_ASM_DIRS   := $(ASM_DIR)/${GAME_ID} $(ASM_DIR)/${GAME_ID}/data
PM_SRC_DIRS   := $(SRC_DIR)/${GAME_ID}
PM_S_FILES    := $(foreach dir,    $(PM_ASM_DIRS),     $(wildcard $(dir)/*.s)) \
                    $(foreach dir,    $(PM_ASM_DIRS),     $(wildcard $(dir)/**/*.s))
PM_C_FILES    := $(foreach dir,    $(PM_SRC_DIRS),     $(wildcard $(dir)/*.c)) \
                    $(foreach dir,    $(PM_SRC_DIRS),     $(wildcard $(dir)/**/*.c))
PM_O_FILES    := $(foreach file,    $(PM_S_FILES),     $(BUILD_DIR)/$(file).o) \
                    $(foreach file,    $(PM_C_FILES),     $(BUILD_DIR)/$(file).o)
PM_TARGET     := $(BUILD_DIR)/$(GAME)

# tools
PYTHON          := python3
SPLAT_DIR       := $(TOOLS_DIR)/splat
SPLAT_APP       := $(SPLAT_DIR)/split.py
SPLAT           := $(PYTHON) $(SPLAT_APP)
ASMDIFFER_DIR   := $(TOOLS_DIR)/asm-differ
ASMDIFFER_APP   := $(ASMDIFFER_DIR)/diff.py
M2CTX_APP       := $(TOOLS_DIR)/m2ctx.py
M2CTX           := $(PYTHON) $(M2CTX_APP)
M2C_DIR         := $(TOOLS_DIR)/m2c
M2C_APP         := $(M2C_DIR)/m2c.py
M2C             := $(PYTHON) $(M2C_APP)
M2C_ARGS        := -P 4
MASPSX_DIR      := $(TOOLS_DIR)/maspsx
MASPSX_APP      := $(MASPSX_DIR)/maspsx.py
MASPSX          := $(PYTHON) $(MASPSX_APP)
MASPSX_ARGS     := --expand-div

# flags
SDATA_LIMIT     := -G4
OPT_FLAGS       := -O2

# macros
define list_src_files
		$(foreach dir, $(ASM_DIR)/${GAME_ID},         $(wildcard $(dir)/**.s))
		$(foreach dir, $(ASM_DIR)/${GAME_ID}/data,    $(wildcard $(dir)/**.s))
		$(foreach dir, $(SRC_DIR)/${GAME_ID},         $(wildcard $(dir)/**.c))
endef

define list_o_files
		$(foreach file, $(call list_src_files), $(BUILD_DIR)/$(file).o)
endef

define link
		$(LD) -o $(2) \
			-Map $(BUILD_DIR)/$(GAME_ID).map \
			-T $(LINKER_DIR)/$(GAME_ID).ld \
			-T $(LINKER_DIR)/undefined_syms_auto.$(GAME_ID).txt \
			-T $(LINKER_DIR)/undefined_funcs_auto.$(GAME_ID).txt \
			-T $(LINKER_DIR)/undefined_syms.$(GAME_ID).txt \
			--no-check-sections \
			-nostdlib \
			-s
endef

# recipes
all: build check
build: SLPM_86183
clean:
		rm -rf build asm
format:
		clang-format -i $$(find $(SRC_DIR)/ -type f -name "*.c")
		clang-format -i $$(find $(INCLUDE_DIR)/ -type f -name "*.h")
check:
		sha256sum --check $(CONFIG_DIR)/$(SHORT_ID).sha
expected: check
		mkdir expected
		rm -rf expected/build
		cp -r build expected/build

$(SLPM_861).elf: $(PM_O_FILES)
		$(LD) -o $@ \
		-Map $(PM_TARGET).map \
		-T $(LINKER_DIR)/$(GAME_ID).ld \
		-T $(LINKER_DIR)/undefined_syms_auto.$(GAME_ID).txt \
		--no-check-sections \
		-nostdlib \
		-s

SLPM_86183: $(BUILD_DIR)/$(SLPM_861).83
$(BUILD_DIR)/$(SLPM_861).83: $(BUILD_DIR)/$(SLPM_861).elf
		$(OBJCOPY) -O binary $(BUILD_DIR)/$(SLPM_861).elf $@
$(BUILD_DIR)/$(SLPM_861).elf: $(call list_o_files)
		$(call link,SLPM_86183,$@)

dirs:
	$(foreach dir,$(PM_ASM_DIRS) $(PM_SRC_DIRS),$(shell mkdir -p $(BUILD_DIR)/$(dir)))

extract: require-tools dirs
		$(SPLAT) $(CONFIG_DIR)/$(GAME_ID).yaml

decompile: $(M2C_APP)
		$(M2CTX) src/game/$(FILE).c
		$(M2C) $(M2C_ARGS) --target mipsel-gcc-c --context ctx.c asm/game/nonmatchings/$(FILE)/$(FUNC).s

require-tools: $(SPLAT_APP) $(ASMDIFFER_APP)
update-dependencies: require-tools $(M2CTX_APP) $(M2C_APP)
		pip3 install -r $(TOOLS_DIR)/requirements.txt

$(SPLAT_APP):
		git submodule init $(SPLAT_DIR)
		git submodule update $(SPLAT_DIR)
		$(PYTHON) -m pip install -r $(SPLAT_DIR)/requirements.txt
$(ASMDIFFER_APP):
		git submodule init $(ASMDIFFER_DIR)
		git submodule update $(ASMDIFFER_DIR)
$(M2CTX_APP):
		curl -o $@ https://raw.githubusercontent.com/ethteck/m2ctx/main/m2ctx.py
$(M2C_APP):
		git submodule init $(M2C_DIR)
		git submodule update $(M2C_DIR)
		$(PYTHON) -m pip install --upgrade pycparser
$(MASPSX_APP):
		git submodule init $(MASPSX_DIR)
		git submodule update $(MASPSX_DIR)

$(BUILD_DIR)/%.s.o: %.s
	$(AS) -Iinclude -march=r3000 -mtune=r3000 -no-pad-sections -Os -o $@ $<

$(BUILD_DIR)/%.bin.o: %.bin
	$(LD) -r -b binary -o -Map %.map $@ $<

# $(CPP) $(CPP_FLAGS) $< | $(CC) $(CC_FLAGS) $(OPT_FLAGS) $(SDATA_LIMIT) | $(MASPSX) $(MASPSX_ARGS) $(AS_SDATA_LIMIT) | $(AS) $(AS_SDATA_LIMIT) -o $@
$(BUILD_DIR)/%.c.o: %.c $(MASPSX_APP)
	@$(CC_CHECK) $<
	$(GCC) $(CC_FLAGS) $(SDATA_LIMIT) $(OPT_FLAGS) $(AS_FLAGS) $< -o $@

SHELL = /bin/sh -e -o pipefail

.PHONY: all, clean, format, check, expected
.PHONY: SLPM_86183
.PHONY: extract
.PHONY: require-tools, update-dependencies
