# paths to assembly source files
x86_asm_source_files := $(shell find src/x86 -name *.s)

# paths to object files to be assembled
x86_asm_object_files := $(patsubst src/x86/%.s, build/x86/%.o, $(x86_asm_source_files))

# garbage output files to be erased
x86_asm_out_files := $(shell find -name *.out)

# assembles objects from modified assembly source files
$(x86_asm_object_files): build/x86/%.o: src/x86/%.s
	mkdir -p $(dir $@) && \
	as $(patsubst build/x86/%.o, src/x86/%.s, $@) -o $@

# build 'dist/x86/kernel.bin'
.PHONY: x86
x86: $(x86_asm_object_files)
	mkdir -p dist/x86 && \
	ld $(x86_asm_object_files) --oformat binary -Ttext 0x7c00 -e _start -o dist/x86/kernel.bin 

# cleans up the development environment
# handles:  .out files
.PHONY: clean
clean: $(x86_asm_out_files)
	if [ "$(x86_asm_out_files)" != "" ]; then rm "$(x86_asm_out_files)"; fi

# useful for debugging, pass a variable name and it will print it
# e.g. 'make build-x86 print-x86_asm_objects'
print-%  : ; @echo $* = $($*)
