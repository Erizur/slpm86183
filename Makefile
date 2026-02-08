# Configuration
NON_MATCHING   ?= 0
SKIP_ASM       ?= 0

# Names and Paths

GAME_NAME := SLPM-86183

ROM_DIR      := iso
CONFIG_DIR   := config
LINKER_DIR   := linker
BUILD_DIR    := build
OUT_DIR      := $(BUILD_DIR)/out
TOOLS_DIR    := tools
OBJDIFF_DIR  := $(TOOLS_DIR)/objdiff
PERMUTER_DIR := permuter
ASM_DIR      := asm
C_DIR        := src
EXPECTED_DIR := expected

# Tools

CROSS   := mips-linux-gnu
AS      := $(CROSS)-as
LD      := $(CROSS)-ld
OBJCOPY := $(CROSS)-objcopy
OBJDUMP := $(CROSS)-objdump
CPP     := $(CROSS)-cpp
CC      := bin/cc1
OBJDIFF := $(OBJDIFF_DIR)/objdiff

PYTHON          := python3
SPLAT           := $(PYTHON) $(TOOLS_DIR)/splat/split.py
MASPSX          := $(PYTHON) $(TOOLS_DIR)/maspsx/maspsx.py
DUMPSXISO       := $(TOOLS_DIR)/mkpsxiso/build/dumpsxiso
MKPSXISO        := $(TOOLS_DIR)/mkpsxiso/build/mkpsxiso
GET_YAML_TARGET := $(PYTHON) $(TOOLS_DIR)/get_yaml_target.py
PREBUILD        := $(TOOLS_DIR)/prebuild.sh
POSTBUILD       := $(TOOLS_DIR)/postbuild.sh
COMPTEST        := $(TOOLS_DIR)/compilationTest.sh

# Flags
OPT_FLAGS           := -O2
ENDIAN              := -EL
INCLUDE_FLAGS       := -Iinclude -I $(BUILD_DIR) -Iinclude/psyq
DEFINE_FLAGS        := -D_LANGUAGE_C -DUSE_INCLUDE_ASM
CPP_FLAGS           := $(INCLUDE_FLAGS) $(DEFINE_FLAGS) -P -MMD -MP -undef -Wall -lang-c -nostdinc
LD_FLAGS            := $(ENDIAN) $(OPT_FLAGS) -nostdlib --no-check-sections
OBJCOPY_FLAGS       := -O binary
OBJDUMP_FLAGS       := --disassemble-all --reloc --disassemble-zeroes -Mreg-names=32
SPLAT_FLAGS         := --disassemble-all --make-full-disasm-for-code
DUMPSXISO_FLAGS     := -x $(ROM_DIR) -s $(ROM_DIR)/layout.xml popn.bin
MKPSXISO_FLAGS  	:= -y -q -o $(BUILD_DIR)/result.bin -c $(BUILD_DIR)/result.cue $(ROM_DIR)/layout.xml

# Targets that will run tools/prebuild.sh after splat has finished, before being built.
TARGET_PREBUILD  := main

# Adjusts compiler and assembler flags based on source file location.
# - Files under main executable paths use -G8; overlay files use -G0.
# - Enables `--expand-div` for certain `libsd` sources which require it (others can't build with it).
# - Adds overlay-specific compiler flags based on files directory (currently only per-map defines).
define FlagsSwitch
	$(if $(findstring /SLPM_861.83/,$(1)), $(eval DL_FLAGS = -G8), $(eval DL_FLAGS = -G0))
	$(eval AS_FLAGS = $(ENDIAN) $(INCLUDE_FLAGS) $(OPT_FLAGS) $(DL_FLAGS) -march=r3000 -mtune=r3000 -no-pad-sections)
	$(eval CC_FLAGS = $(OPT_FLAGS) $(DL_FLAGS) -mips1 -mcpu=3000 -w -funsigned-char -fpeephole -ffunction-cse -fpcc-struct-return -fcommon -fverbose-asm -msoft-float -mgas -fgnu-linker -quiet)
	
	$(if $(or $(findstring smf_mid,$(1)), $(findstring smf_io,$(1)),), \
		$(eval MASPSX_FLAGS = --aspsx-version=2.77 --run-assembler --expand-div $(AS_FLAGS)), \
		$(eval MASPSX_FLAGS = --aspsx-version=2.77 --run-assembler $(AS_FLAGS)))
endef

ifeq ($(NON_MATCHING),1)
	CPP_FLAGS := $(CPP_FLAGS) -DNON_MATCHING
endif

ifeq ($(SKIP_ASM),1)
	CPP_FLAGS := $(CPP_FLAGS) -DSKIP_ASM
endif

# Utils

# Function to find matching .bin files for a target name.
find_bin_files = $(shell find $(ASM_DIR)/$(strip $1) -type f -path "*.bin" 2> /dev/null)

# Function to find matching .s files for a target name.
find_s_files = $(shell find $(ASM_DIR)/$(strip $1) -type f -path "*.s" -not -path "asm/*matchings*" 2> /dev/null)

# Function to find matching .c files for a target name.
find_c_files = $(shell find $(C_DIR)/$(strip $1) -type f -path "*.c" 2> /dev/null)

# Function to generate matching .o files for target name in build directory.
gen_o_files = $(addprefix $(BUILD_DIR)/, \
							$(patsubst %.s, %.s.o, $(call find_s_files, $1)) \
							$(patsubst %.c, %.c.o, $(call find_c_files, $1)) \
							$(patsubst %.bin, %.bin.o, $(call find_bin_files, $1)))

# Function to get path to .yaml file for given target.
get_yaml_path = $(addsuffix .yaml,$(addprefix $(CONFIG_DIR)/,$1))

# Function to get target output path for given target.
get_target_out = $(addprefix $(OUT_DIR)/,$(shell $(GET_YAML_TARGET) $(call get_yaml_path,$1)))

# Template definition for elf target.
# First parameter should be source target with folder (e.g. screens/credits).
# Second parameter should be end target (e.g. build/VIN/STF_ROLL.BIN).
# If we skip the ASM inclusion to determine progress, we will not be able to link. Skip linking, if so.

ifeq ($(SKIP_ASM),1)

define make_elf_target
$2: $2.elf

$2.elf: $(call gen_o_files, $1)
endef

else

define make_elf_target
$2: $2.elf
	$(OBJCOPY) $(OBJCOPY_FLAGS) $$< $$@

$2.elf: $(call gen_o_files, $1)
	@mkdir -p $(dir $2)
	$(LD) $(LD_FLAGS) \
		-Map $2.map \
		-T $(LINKER_DIR)/$1.ld \
		-T $(LINKER_DIR)/$(filter-out ./,$(dir $1))undefined_syms_auto.$(notdir $1).txt \
		-T $(LINKER_DIR)/$(filter-out ./,$(dir $1))undefined_funcs_auto.$(notdir $1).txt \
		-o $$@
endef

endif

# Targets

TARGET_MAIN := SLPM_861.83

# Source Definitions

TARGET_IN  := $(TARGET_MAIN)
TARGET_OUT := $(foreach target,$(TARGET_IN),$(call get_target_out,$(target)))

CONFIG_FILES := $(foreach target,$(TARGET_IN),$(call get_yaml_path,$(target)))
LD_FILES     := $(addsuffix .ld,$(addprefix $(LINKER_DIR)/,$(TARGET_IN)))

# Recursively include any .d dependency files from previous builds.
# Allowing Make to rebuild targets when any included headers/sources change.
-include $(shell [ -d $(BUILD_DIR) ] && find $(BUILD_DIR) -name '*.d' || true)

# Rules

default: all

all: build

build: $(TARGET_OUT)

objdiff-config: regenerate
	@$(MAKE) NON_MATCHING=1 expected
	@$(PYTHON) $(OBJDIFF_DIR)/objdiff_generate.py $(OBJDIFF_DIR)/config.yaml

report:
	@$(MAKE) objdiff-config
	@$(OBJDIFF) report generate > $(BUILD_DIR)/progress.json

check: build
	@sha256sum --ignore-missing --check config/slpm861.sha

progress: build
	@$(PYTHON) tools/report_progress.py

progress-shield: build
	@$(PYTHON) tools/report_progress.py --shield

expected: build
	mkdir -p $(EXPECTED_DIR)
	mv $(BUILD_DIR)/asm $(EXPECTED_DIR)/asm

iso:
	@cp -v $(OUT_DIR)/$(TARGET_MAIN) $(ROM_DIR)/$(TARGET_MAIN)
	$(MKPSXISO) $(MKPSXISO_FLAGS)

extract:
	$(DUMPSXISO) $(DUMPSXISO_FLAGS)

generate: $(LD_FILES)

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(PERMUTER_DIR)

reset: clean
	rm -rf $(ASM_DIR)
	rm -rf $(LINKER_DIR)
	rm -rf $(EXPECTED_DIR)

clean-rom:
	find rom -maxdepth 1 -type f -delete

regenerate: reset
	$(MAKE) generate

setup: reset
	$(MAKE) extract
	$(MAKE) generate

clean-build: clean
	rm -rf $(LINKER_DIR)
	$(MAKE) generate
	$(MAKE) build

clean-check: clean
	rm -rf $(ASM_DIR)
	rm -rf $(LINKER_DIR)
	$(MAKE) generate
	$(MAKE) check

clean-progress: clean
	rm -rf $(ASM_DIR)
	rm -rf $(LINKER_DIR)
	$(MAKE) generate
	$(MAKE) progress

compilation-test:
	$(COMPTEST)

compilation-test-sm:
	$(COMPTEST) --skip-maps

# Recipes

# .elf targets
# Generate .elf target for each target from TARGET_IN.
$(foreach target,$(TARGET_IN),$(eval $(call make_elf_target,$(target),$(call get_target_out,$(target)))))

# Generate objects.
# (Running make with MAKE_COMPILE_LOG=1 will create a compile.log that can be passed to tools/create_compile_commands.py)
$(BUILD_DIR)/%.i: %.c
	@mkdir -p $(dir $@)
	$(call FlagsSwitch, $@)
ifeq ($(MAKE_COMPILE_LOG),1)
	@echo "$(CPP) -P -MMD -MP -MT $@ -MF $@.d $(CPP_FLAGS) $(OVL_FLAGS) -o $@ $<" >> compile.log
endif
	$(CPP) -P -MMD -MP -MT $@ -MF $@.d $(CPP_FLAGS) $(OVL_FLAGS) -o $@ $<

$(BUILD_DIR)/%.sjis.i: $(BUILD_DIR)/%.i
	iconv -f UTF-8 -t SHIFT-JIS $< -o $@

$(BUILD_DIR)/%.c.s: $(BUILD_DIR)/%.sjis.i
	@mkdir -p $(dir $@)
	$(call FlagsSwitch, $@)
	$(CC) $(CC_FLAGS) -o $@ $<

$(BUILD_DIR)/%.c.o: $(BUILD_DIR)/%.c.s
	@mkdir -p $(dir $@)
	$(call FlagsSwitch, $@)
	-$(MASPSX) $(MASPSX_FLAGS) -o $@ $<
	-$(OBJDUMP) $(OBJDUMP_FLAGS) $@ > $(@:.o=.dump.s)

$(BUILD_DIR)/%.s.o: %.s
	@mkdir -p $(dir $@)
	$(call FlagsSwitch, $@)
	$(AS) $(AS_FLAGS) -o $@ $<

$(BUILD_DIR)/%.bin.o: %.bin
	@mkdir -p $(dir $@)
	$(LD) $(LD_FLAGS) -r -b binary -o $@ $<

# Split .yaml.
$(LINKER_DIR)/%.ld: $(CONFIG_DIR)/%.yaml
	@mkdir -p $(dir $@)
	$(SPLAT) $(SPLAT_FLAGS) $<
	$(if $(filter $*,$(TARGET_PREBUILD)),@-$(PREBUILD) $*,@true)

### Settings
.SECONDARY:
.PHONY: all clean default iso
SHELL = /bin/sh -e -o pipefail
