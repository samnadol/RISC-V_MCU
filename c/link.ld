MEMORY
{
    IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 0x1000   /* 4KB,  1024 x 32-bit words */
    DMEM (rw) : ORIGIN = 0x00000000, LENGTH = 0x2000   /* 8KB,  2048 x 32-bit words */
}

ENTRY(_start)

SECTIONS
{
    .text.start : { *(.text.start) } > IMEM
    .text       : { *(.text) *(.text.*) } > IMEM
    .rodata     : { *(.rodata) *(.rodata.*) } > IMEM

    .data : {
        __data_start = .;
        *(.data) *(.data.*)
        __data_end = .;
    } > DMEM

    .bss : {
        __bss_start = .;
        *(.bss) *(.bss.*)
        *(COMMON)
        __bss_end = .;
    } > DMEM

    _stack_top = ORIGIN(DMEM) + LENGTH(DMEM);

    /DISCARD/ : { *(.comment) *(.eh_frame) *(.riscv.attributes) }
}