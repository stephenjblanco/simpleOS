DIR_DIST := dist

DIR_X86_SRC := src/x86

.PHONY: x86 clean

# build 'dist/x86/simpleOS.img'
x86:
	$(MAKE) -C $(DIR_X86_SRC) x86

clean-x86:
	$(MAKE) -C $(DIR_X86_SRC) clean 

# cleans up the development environment
clean: clean-x86
	rm -rf $(DIR_DIST)
