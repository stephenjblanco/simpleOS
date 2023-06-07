/**
 *  gdt.c
 *  - creates GDT segment descriptors as 64-bit uints
 */

#include <stdint.h>

// each define here sets a specific flag in the descriptor
// refer to the Intel Architectures Developer's Manual (3-10, vol 3A)
// or https://wiki.osdev.org/Global_Descriptor_Table#Segment_Descriptor
// for a description of what each one does

#define SEG_DESCTYPE(x) (x << 0x04)           // descriptor type
#define SEG_PRIV(x)     ((x & 0x03) << 0x05)  // privilege level
#define SEG_PRES(x)     (x << 0x07)           // segment present
#define SEG_AVAIL(x)    (x << 0x0C)           // available for system softw.
#define SEG_LONG(x)     (x << 0x0D)           // 64-bit code segment
#define SEG_SIZE(x)     (x << 0x0E)           // default operation size
#define SEG_GRAN(x)     (x << 0x0F)           // granularity

// descriptor type bits

#define SEG_WRITE(x)    (x << 0x01)  // writeable (data only)
#define SEG_DIR(x)      (x << 0x02)  // direction (data only)
#define SEG_READ(x)     (x << 0x01)  // readable (code only)
#define SEG_CONF(x)     (x << 0x02)  // conforming (code only)
#define SEG_EXEC(x)     (x << 0x03)  // executable - sets data or code

// data descriptor types (not comprehensive)

#define SEG_DATA_READ_ONLY  SEG_EXEC(0) | SEG_DIR(0) | SEG_WRITE(0)
#define SEG_DATA_READ_WRITE SEG_EXEC(0) | SEG_DIR(0) | SEG_WRITE(1)

// code descriptor types (not comprehensive)

#define SEG_CODE_EXEC_ONLY  SEG_EXEC(1) | SEG_CONF(0) | SEG_READ(0)
#define SEG_CODE_EXEC_READ  SEG_EXEC(1) | SEG_CONF(0) | SEG_READ(1)

// segment descriptor definitions

#define GDT_NULL_DSC    0

#define GDT_CODE_PL0    SEG_GRAN(1)     | SEG_SIZE(1) | SEG_LONG(0) | \
                        SEG_AVAIL(0)    | SEG_PRES(1) | SEG_PRIV(0) | \
                        SEG_DESCTYPE(1) | SEG_CODE_EXEC_READ

#define GDT_DATA_PL0    SEG_GRAN(1)     | SEG_SIZE(1) | SEG_LONG(0) | \
                        SEG_AVAIL(0)    | SEG_PRES(1) | SEG_PRIV(0) | \
                        SEG_DESCTYPE(1) | SEG_DATA_READ_WRITE

#define GDT_CODE_PL3    SEG_GRAN(1)     | SEG_SIZE(1) | SEG_LONG(0) | \
                        SEG_AVAIL(0)    | SEG_PRES(1) | SEG_PRIV(3) | \
                        SEG_DESCTYPE(1) | SEG_CODE_EXEC_READ

#define GDT_DATA_PL3    SEG_GRAN(1)     | SEG_SIZE(1) | SEG_LONG(0) | \
                        SEG_AVAIL(0)    | SEG_PRES(1) | SEG_PRIV(3) | \
                        SEG_DESCTYPE(1) | SEG_DATA_READ_WRITE

// number of GDT entries, including null descriptor

#define GDT_DSC_CT   5

/**
 * @brief Create a GDT segment descriptor represented as 64-bit uint.
 * 
 * @param base   32-bit address where segment begins
 * @param limit  20-bit value representing last addressable unit
 * @param flags  16-bit value representing set of boolean flags
 * 
 * @return uint64_t  represents GDT segment descriptor
 */
static uint64_t create_descriptor(uint32_t base, uint32_t limit, uint16_t flags) {
    uint64_t descriptor;

    // high 32 bits
    descriptor  =  limit        & 0x000F0000;
    descriptor |= (flags <<  8) & 0x00F0FF00;
    descriptor |= (base  >> 16) & 0x000000FF;
    descriptor |=  base         & 0xFF000000;
    descriptor <<= 32;

    // low 32 bits
    descriptor |= base << 16;
    descriptor |= limit & 0x0000FFFF;

    return descriptor;
}

/**
 * @brief Create GDT with default entries defined above.
 * 
 * @param gdt_ptr  location in mem where GDT should be stored
 * 
 * @return uint8_t  size (in bytes) of GDT
 */
uint16_t set_gdt(uint64_t* gdt_ptr) {
    uint64_t gdt_entries[GDT_DSC_CT] = { 
        create_descriptor(0, 0x00000000, (GDT_NULL_DSC)),
        create_descriptor(0, 0x0000FFFF, (GDT_CODE_PL0)),
        create_descriptor(0, 0x0000FFFF, (GDT_DATA_PL0)),
        create_descriptor(0, 0x0000FFFF, (GDT_CODE_PL3)),
        create_descriptor(0, 0x0000FFFF, (GDT_DATA_PL3)),
    };

    int gdt_index = 0;

    while (gdt_index < GDT_DSC_CT) {
        gdt_ptr[gdt_index] = gdt_entries[gdt_index];

        gdt_index++;
    }

    return (uint16_t) sizeof(gdt_entries);
}

// space in memory for gdt

uint64_t gdt_ptr[GDT_DSC_CT];
