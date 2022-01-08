.code16

.global _start

_start:
    mov %cs, %ax            # code segment is 0x7e00
    mov %ax, %ds            # set data segment equal to code segment
    mov %ax, %es            # set extended segment equal to code segment
    
    mov $hello_world, %si
    call print_text
_end:
    sti                     # terminate with infinite loop
    hlt
    jmp _end

.include "src/x86/boot/text.s"

hello_world: .ascii "Hello world!"
.byte 0x0A
.byte 0x0D
.byte 0x00
