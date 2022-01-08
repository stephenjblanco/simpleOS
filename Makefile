dir_src := src
dir_build := build
dir_dist := dist

x86_stage1_object := $(dir_build)/x86/boot/stage1.o
x86_stage2_object := $(dir_build)/x86/boot/stage2.o
x86_stage1_bin := $(dir_dist)/x86/boot/stage1.bin
x86_stage2_bin := $(dir_dist)/x86/boot/stage2.bin
x86_image := $(dir_dist)/x86/simpleOS.img

$(dir_build)/%.o: $(dir_src)/%.s
	mkdir -p $(dir $@) && \
	as --32 $< -o $@

$(x86_stage1_bin): $(x86_stage1_object)
	mkdir -p $(dir $@) && \
	ld $< -m elf_i386 --oformat binary -Ttext 0x7c00 -e _start -o $@

$(x86_stage2_bin): $(x86_stage2_object)
	mkdir -p $(dir $@) && \
	ld $< -m elf_i386 --oformat binary -Ttext 0x0000 -e _start -o $@


$(x86_image): $(x86_stage1_bin) $(x86_stage2_bin)
	mkdir -p $(dir $@) && \
 	cat $(x86_stage1_bin) $(x86_stage2_bin) > $@

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
