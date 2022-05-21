#########################################
#
#  stage2.s
#  - enters protected mode
#  - prints message
#
#########################################

.code16

.global _start

.text

_start:
    mov %cs, %ax            # code segment is 0x7e00
    mov %ax, %ds            # set data segment equal to code segment
    mov %ax, %es            # set extended segment equal to code segment
protected_mode:
    call enable_a20
    cmp $1, %ax
    jne _end
boot_success:
    mov $str_boot_success, %si
    call print_text
_end:
    sti                     # terminate with infinite loop
    hlt
    jmp _end

.data

str_boot_success: .ascii "Booted successfully."
.byte 0x0A
.byte 0x0D
.byte 0x00
