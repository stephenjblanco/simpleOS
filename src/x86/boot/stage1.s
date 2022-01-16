.code16

.global _start

.text

_start:
    xor %ax, %ax
    mov %ax, %ds                 # set data segment to 0
    mov %ax, %es                 # set extended segment to 0

    add $0x9000, %ax
    mov %ax, %ss                 # initialize stack segment at 0x9000
    mov $0xF000, %sp             # set bottom of stack 0x9000:0xF000
    cld                          # don't automatically print next string in mem

    mov $num_disk_retries, %di   # set DI to number of disk retries
disk_system_reset:
    cmp $0, %di                  # check if DI has fallen to 0. if so, we've
    je disk_error                # reached max disk retries -> print error

    mov $0x00, %ah
    int $0x13                    # call INT 13,0 - Reset Disk System

    dec %di
    jc disk_system_reset         # retry if failure

    mov $num_disk_retries, %di   # reset DI (max num disk retries)
disk_read:
    push %bp
    mov (stage2_lba_start), %si  # store LBA start in SI for loop
    mov $0x07e0, %bp             # set BP to point to next segment
next_disk_sector:
    call lba_to_chs              # convert current LBA to CHS notation

    mov %bp, %es
    mov $0x0000, %bx             # (ES:BX): buffer pointing to next segment
    add $512>>4, %bp             # move pointer in BP to next segment
disk_sector_read:
    cmp $0, %di                  # max disk retries check
    je disk_error

    mov $0x0201, %ax             # AH: 0x2 (disk read), AL: 0x1 (num sectors)
    pushw %ax                    # push AL to stack (number of sectors to read)
    int $0x13                    # call INT 13,2 - Read Disk Sectors
    popw %bx                     # pop AL from stack -> BL (number of sectors we wanted read)

    dec %di
    jc disk_sector_read          # retry if failure
    cmp %al, %bl                 # compare num sectors read (AL) vs num sectors wanted (BL)
    jne disk_sector_read         # retry if they don't match
    mov $num_disk_retries, %di   # reset DI (max num disk retries)

    inc %si                      # increment SI to next LBA
    cmp %si, (stage2_lba_end)    # compare current LBA (SI) to end LBA
    jne next_disk_sector         # if SI is not at end LBA, read next sector
disk_read_success:
    mov $success_msg, %si
    call print_text              # print success message
    ljmp $0x07e0, $0x0000        # long jump to read segment's location in memory
    jmp finish
disk_error:
    mov $disk_error_msg, %si     # load address of disk_read_error_msg into SI
    call print_text              # call print_text subroutine (text.s)
finish:
    sti                          # terminal loop
    hlt
    jmp finish

##
#  Converts current LBA (logical block address) to Cylinder-Head-Sector notation.
#  Sets relevant input registers for INT 13,2 - Read Disk Sectors.
#
#    Sector = (LBA mod SPT) + 1        where SPT = sectors-per-track
#    Head = (LBA / SPT) mod Heads
#    Cylinder = (LBA / SPT) / Heads
#
#  Inputs:   SI - current LBA (sector number)
#            DL - boot device
#  Outputs:  CH - lower 8-bits of 10-bit cylinder
#            CL - upper 2 bits are upper 2 buts of 10-bit cylinder,
#                 lower 6 bits are sector
#            DH - head
#            DL - boot device
##
lba_to_chs:
    push %dx                      # DL already set to boot device, push to stack
    xor %dx, %dx                  # upper 16-bits (DX) set to 0 for DIV,
    mov %si, %ax                  # lower 16-bits (AX) set to next LBA
    divw (sectors_per_track)      # quotient in AX, remainder (sector) in DX
    mov %dl, %cl                  # CL (lower 6-bits):
    inc %cl                       #     sector = LBA mod sectors-per-track + 1

    xor %dx, %dx                 # upper 16-bits (DX) set to 0 for DIV
    divw (num_heads)             # lower 16-bits (AX) already set to LBA / SPT
    mov %dl, %dh                 # DH:  head = (LBA / sectors-per-track) mod num-heads
    mov %al, %ch                 # CH: cylinder (lower 8-bits) = (LBA / SPT) / num-heads
    shl $6, %ah                  # CL (upper 2-bits):
    or %ah, %cl                  #      upper 2-bits of 10-bit cylinder

    popw %ax
    mov %al, %dl                 # DL: boot device
    ret
    
.include "src/x86/boot/text.s"

##
#  Disk info for converting LBA to CHS notation. Valid for a 1.44 MB floppy.
#  Later on, we'll set these values dynamically using a BIOS function.
#  This way, our bootloader is not restricted to a specific type of media.
##
num_heads: .word 2
sectors_per_track: .word 18

# number of disk-read retries before failing
num_disk_retries: .word 3


# first sector to read, and last sector (which doesn't get read).
stage2_lba_start: .word 1
stage2_lba_end: .word ((stage2_end - stage2_start + 511) / 512) + 1

disk_error_msg: .ascii "Error reading disk."
.byte 0x0A
.byte 0x0D
.byte 0x00

success_msg: .ascii "Success, loading stage 2."
.byte 0x0A
.byte 0x0D
.byte 0x00

# bootloader must be 512 bytes long
.fill 510-(. - _start), 1, 0

# magic number '0x55aa', that tells BIOS this binary is bootable 
.word 0xaa55

# stage 2 binary
stage2_start:

.incbin "dist/x86/boot/stage2.bin"

stage2_end:
