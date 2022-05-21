#########################################
#
#  protected_mode.s
#  - utilities to enter protected mode
#
#########################################

.code16

.global enable_a20

.type enable_a20, @function

.text

# Function:  Enable A20 Gate
#
# Purpose:   Enables A20 gate. Prints error and enters fail state
#            if A20 not available.
#
# Returns:   0 in AX if disabled.
#            1 in AX if enabled.
enable_a20:
    call check_a20
    cmp $1, %ax
    je enable_a20_return

    mov $0x2401, %ax
    int $0x15             # int 0x15,0x2401 - enable A20 gate

    call check_a20
    cmp $1, %ax
    je enable_a20_return
enable_a20_failure:
    mov $str_error_protected_mode, %si
    call print_text

    mov $str_reason_enabling_A20, %si
    call print_text
enable_a20_return:
    ret

# Function:  Check A20
#
# Purpose:   Checks status of A20 gate.
#
# Returns:   0 in AX if disabled.
#            1 in AX if enabled.
check_a20:
    pushf
    push %es
    push %ds

    cli

    xor %ax, %ax
    mov %ax, %es            # ES = 0x0000
    not %ax
    mov %ax, %ds            # DS = 0xFFFF

    movb %es:0x0500, %al
    push %ax

    movb %ds:0x0510, %al
    push %ax                # save vals from mem

    movb $0x00, %es:0x0500  # set [0x0000:0x7DFE] := 0x00
    movb $0xff, %ds:0x0510  # set val 1 MiB higher [0xFFFF:0x7E0E] := 0xFF

    cmpb $0xff, %es:0x0500  # if [0x0000:0x7DFE] := 0xFF then A20 not enabled

    pop %ax
    movb %al, %ds:0x0510 

    pop %ax
    movb %al, %es:0x0500   # restore vals to mem

    mov $0, %ax
    je check_a20_return    # return 0 if A20 not enabled

    mov $1, %ax            # return 1 if A20
check_a20_return:
    pop %ds
    pop %es
    popf

    ret

.data

str_error_protected_mode: .ascii "ERROR: Could not enter protected mode."
.byte 0x0A
.byte 0x0D
.byte 0x00

str_reason_enabling_A20: .ascii "REASON: Could not enable A20 gate."
.byte 0x0A
.byte 0x0D
.byte 0x00
