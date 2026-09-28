OUTPUT_ARCH("riscv")
ENTRY(_start)

/*
 * SimRV maps DRAM at 0x80000000.  Keep the first 64 KiB free because
 * SimRV observes 0x80001000 as a conventional tohost address.
 */
MEMORY
{
    ram (rwx) : ORIGIN = 0x80010000, LENGTH = 0x00ff0000
}

PHDRS
{
    text PT_LOAD FLAGS(5); /* PF_R | PF_X */
    data PT_LOAD FLAGS(6); /* PF_R | PF_W */
}

SECTIONS
{
    .text : {
        . = ALIGN(4);
        KEEP(*(.text.startup))
        *(.text)
        *(.text.*)
        . = ALIGN(4);
    } > ram :text

    .rodata : {
        . = ALIGN(4);
        *(.rodata)
        *(.rodata.*)
        *(.srodata)
        *(.srodata.*)
        . = ALIGN(4);
    } > ram :text

    .data : {
        . = ALIGN(8);
        PROVIDE(__global_pointer$ = . + 0x800);
        __data_start = .;
        *(.data)
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
        . = ALIGN(8);
        __data_end = .;
    } > ram :data

    /* SimRV loads the ELF segment directly into RAM, so LMA equals VMA. */
    __data_org = ADDR(.data);

    .bss (NOLOAD) : {
        . = ALIGN(8);
        __bss_start = .;
        PROVIDE(__noinit_start = .);
        *(.noinit)
        PROVIDE(__noinit_end = .);
        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
        *(COMMON)
        . = ALIGN(8);
        __bss_end = .;
        __end = .;
        PROVIDE(end = .);
    } > ram :data

    _stack_top = ORIGIN(ram) + LENGTH(ram);

    /DISCARD/ : {
        *(.eh_frame)
        *(.eh_frame_hdr)
    }

    ASSERT(__bss_end < _stack_top, "micro T-Kernel SimRV RAM overflow")
}
