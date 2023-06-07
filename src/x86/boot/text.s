.code16

.global print_text

.type print_text, @function

.text

print_text:
    pushf
    push %ax

    mov $0xe, %ah      # sets AH to 0xE (indicates teletype function)
print_char:
    lodsb              # loads byte from SI into AL, and increments SI
    cmp $0, %al        # compares byte in AL with 0 (null terminator)
    je print_done      # if byte in AL == 0, we're done - return from print_buffer
    int $0x10          # call teletype function, prints char in AL to screen
    jmp print_char     # loop back, print next char
print_done:
    pop %ax
    popf
    ret
