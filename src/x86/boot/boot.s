# enter 16 bit mode
.code16

.global _start

_start:
    mov $msg, %si  # loads address of msg into SI
    mov $0xe, %ah  # sets AH to 0xE (indicates teletype function)
print_msg:
    lodsb          # loads byte from SI into AL, and increments SI
    cmp $0, %al    # compares byte in AL with 0 (null terminator)
    je done        # if byte in AL == 0, jump to done
    int $0x10      # call teletype function, prints char in AL to screen
    jmp print_msg  # loop back to beginning of print_msg, repeating for next char
done:
    hlt            # stop execution

# store null-terminated String in $msg
msg: .asciz "Hello world!"

# bootloader must be 512 bytes long,
# so fill space before magic number with 0
.fill 510-(.-_start), 1, 0

# magic number '0x55aa', that tells BIOS this binary is bootable 
# NOTE: x86 is little-endian, so we reverse the bytes
.word 0xaa55
