.code16

.global _start

.text

_start:
    xor %ax, %ax
    mov %ax, %ds               # set data segment to 0
    mov %ax, %es               # set extended segment to 0

    add $0x9000, %ax
    mov %ax, %ss               # initialize stack segment at 0x9000
    mov $0xF000, %sp           # set bottom of stack 0x9000:0xF000
    cld                        # don't automatically print next string in mem

    mov $0x00, %ah
    int $0x13                  # call INT 13,0 - Reset Disk System
    jc disk_error              # print disk_error_msg if failure
disk_read:
    mov $0x07e0, %ax
    mov %ax, %es               # set up buffer for read
    mov $0x0000, %bx           # buffer pointing to 0x07e0:0x0000 -> 0x7e00

    mov $0x2, %ah              # sets AH to 0x2 (indicates disk read)
    mov $0x1, %al              # sets AL to 0x1 (number of sectors to read)
    mov $0x0, %ch              # sets CH to 0x0 (track number)
    mov $0x2, %cl              # sets CL to 0x0 (sector number)
    mov $0x0, %dh              # sets DH to 0x0 (head number)
    pushw %ax                  # push AL to stack (number of sectors to read)
    int $0x13                  # call INT 13,2 - Read Disk Sectors

    jc disk_error              # print disk_error_msg if failure
    popw %dx     
    cmp %al, %dl               # compare num sectors we wanted vs num sectors actually read
    jne disk_error             # print disk_error_msg if they don't match
disk_read_success:
    mov $success_msg, %si
    call print_text
    ljmp $0x07e0, $0x0000      # long jump to read segment's location in memory
disk_error:
    mov $disk_error_msg, %si   # load address of disk_read_error_msg into SI
    call print_text            # call print_text subroutine (text.s)
    hlt

.include "src/x86/boot/text.s"

stage2_offset: .word 0x0000
stage2_segment: .word 0xe007

disk_error_msg: .ascii "Error reading disk."
.byte 0x0A
.byte 0x0D
.byte 0x00

success_msg: .ascii "Success, loading stage 2."
.byte 0x0A
.byte 0x0D
.byte 0x00

# bootloader must be 512 bytes long
.fill 510-(.-_start), 1, 0

# magic number '0x55aa', that tells BIOS this binary is bootable 
.word 0xaa55
