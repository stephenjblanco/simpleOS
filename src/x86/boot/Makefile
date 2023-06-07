DIR_SRC := .
DIR_TARGETS := ../../../targets/x86/boot
DIR_DIST := ../../../dist/x86/boot
DIR_OBJ := $(DIR_TARGETS)/obj
DIR_BIN := $(DIR_TARGETS)/bin

GCC := i686-linux-gnu-gcc
LD := i686-linux-gnu-ld

CFLAGS := -ffreestanding -fno-pie -m32
LDFLAGS_STAGE1 := -m elf_i386 --oformat binary -Ttext 0x7c00 -e _stage1

STAGE1_SRC := $(DIR_SRC)/stage1.s

STAGE2_LD := $(DIR_TARGETS)/stage2.ld

STAGE1_OBJ := $(DIR_OBJ)/stage1.o
STAGE2_OBJ := $(DIR_OBJ)/stage2.o
PROTECTEDLIB_OBJ := $(DIR_OBJ)/protected_mode.o
GDTLIB_OBJ := $(DIR_OBJ)/gdt.o
TEXTLIB_OBJ := $(DIR_OBJ)/text.o

STAGE2_BIN := $(DIR_BIN)/stage2.bin
BOOT_BIN := $(DIR_BIN)/boot.bin

# compile C files
$(DIR_OBJ)/%.o: $(DIR_SRC)/%.c
	mkdir -p $(dir $@) && \
	$(GCC) $(CFLAGS) -c $< -o $@

# assemble ASM files
$(DIR_OBJ)/%.o: $(DIR_SRC)/%.s
	mkdir -p $(dir $@) && \
	$(GCC) $(CFLAGS) -c $< -o $@

# link stage 2 ASM and stage 2 libraries
#   --> stage 2 object
$(STAGE2_BIN): $(STAGE2_OBJ) $\
			   $(PROTECTEDLIB_OBJ) $\
			   $(GDTLIB_OBJ) $\
			   $(TEXTLIB_OBJ)
	mkdir -p $(dir $@) && \
	$(LD) \
		-L $(DIR_OBJ) \
		-T $(STAGE2_LD) \
		-o $@

# assemble stage 1 ASM with included stage 2 binary 
#   --> stage 1 object
$(STAGE1_OBJ): $(STAGE1_SRC) $(STAGE2_BIN)
	$(GCC) \
		$(CFLAGS) \
		-I $(DIR_SRC) \
		-I $(DIR_BIN) \
		-c $(STAGE1_SRC) \
		-o $(STAGE1_OBJ)

# link stage1 object 
#   --> bootloader binary
$(BOOT_BIN): $(STAGE1_OBJ)
	mkdir -p $(dir $@) && \
	$(LD) \
		$(LDFLAGS_STAGE1) \
		$(STAGE1_OBJ) \
		-o $(BOOT_BIN)

.PHONY: x86 clean-x86

# build bootloader binary
x86: $(BOOT_BIN)

# clean bootloader build artifacts
clean:
	rm -rf $(DIR_OBJ)
	rm -rf $(DIR_BIN)
	rm -rf $(DIR_DIST)
