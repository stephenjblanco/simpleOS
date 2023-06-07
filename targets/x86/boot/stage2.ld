ENTRY(_stage2)
OUTPUT_FORMAT(binary)
SECTIONS
{
    . = 0x0000;
    .stage2 : { 
        stage2.o (.text) 
    }
    .lib : { 
        text.o (.text)
        protected_mode.o (.text)
        gdt.o (.text)
    }
    .data : {
        stage2.o (.data)
        protected_mode.o (.data)
    }
    .gdt : {
        gdt.o (.data)
    }
}
