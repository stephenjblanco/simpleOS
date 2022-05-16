dir_src := src
dir_targets := targets
dir_build := build
dir_dist := dist

x86_as := i686-linux-gnu-as
x86_ld := i686-linux-gnu-ld

path_x86_boot := x86/boot

x86_stage1_objects := $(dir_build)/$(path_x86_boot)/stage1.o
x86_stage1_bin := $(dir_build)/$(path_x86_boot)/bin/stage1.bin

x86_stage2_objects := $(dir_build)/$(path_x86_boot)/stage2.o $\
	$(dir_build)/$(path_x86_boot)/text.o
x86_stage2_targets := $(dir_targets)/$(path_x86_boot)/stage2.ld
x86_stage2_bin := $(dir_build)/$(path_x86_boot)/bin/stage2.bin

x86_image := $(dir_dist)/x86/simpleOS.img

$(dir_build)/%.o: $(dir_src)/%.s
	mkdir -p $(dir $@) && \
	$(x86_as) --32 $< -o $@

$(x86_stage2_bin): $(x86_stage2_objects) $(x86_stage2_targets)
	mkdir -p $(dir $@) && \
	$(x86_ld) $(x86_stage2_objects) -T $(x86_stage2_targets) -o $@

$(x86_stage1_objects): $(x86_stage2_bin)

$(x86_stage1_bin): $(x86_stage1_objects)
	mkdir -p $(dir $@) && \
	$(x86_ld) $< -m elf_i386 --oformat binary -Ttext 0x7c00 -e _start -o $@

$(x86_image): $(x86_stage1_bin)
	mkdir -p $(dir $@) && \
	cp $< $@

.PHONY: x86 clean

# build 'dist/x86/kernel.bin'
x86: $(x86_image)

# cleans up the development environment
clean:
	rm -f *.out && \
	rm -rf $(dir_build)
	rm -rf $(dir_dist)

# useful for debugging, pass a variable name and it will print it
# e.g. 'make build-x86 print-x86_asm_objects'
print-%  : ; @echo $* = $($*)
