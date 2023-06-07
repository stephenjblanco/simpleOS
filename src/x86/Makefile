DIR_TARGETS := ../../targets/x86
DIR_DIST := ../../dist/x86
DIR_BOOT := boot

BOOT_BIN := $(DIR_TARGETS)/$(DIR_BOOT)/bin/boot.bin

DIST := $(DIR_DIST)/simpleOS.img

# build bootloader binary
$(BOOT_BIN):
	$(MAKE) -C $(DIR_BOOT) x86

# build OS image from bootloader
#   --> simpleOS.img
$(DIST): $(BOOT_BIN)
	mkdir -p $(dir $@) && \
	cp $(BOOT_BIN) $@

.PHONY: x86 clean

# build x86 OS image
x86: $(DIST)

clean:
	$(MAKE) -C $(DIR_BOOT) clean && \
	rm -rf $(DIR_DIST)
