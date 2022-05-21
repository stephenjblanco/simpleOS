ENTRY(_start)
OUTPUT_FORMAT(binary)
SECTIONS
{
    . = 0x0000;
    .stage2 : { 
        build/x86/boot/stage2.o (.text) 
        build/x86/boot/stage2.o (.data)
    }
    .protected : { 
        build/x86/boot/protected_mode.o (.text)
        build/x86/boot/protected_mode.o (.data)
    }
}
