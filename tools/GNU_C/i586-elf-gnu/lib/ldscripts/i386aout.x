OUTPUT_FORMAT("a.out-i386", "a.out-i386",
	      "a.out-i386")
OUTPUT_ARCH(i386)
 SEARCH_DIR(/gnu/i386-msdos/lib);
PROVIDE (__stack = 0);
SECTIONS
{
  . = 0;
  .text :
  {
    CREATE_OBJECT_SYMBOLS
    *(.text)
    /* The next six sections are for SunOS dynamic linking.  The order
       is important.  */
    *(.dynrel)
    *(.hash)
    *(.dynsym)
    *(.dynstr)
    *(.rules)
    *(.need)
    _etext = .;
    __etext = .;
  }
  . = ALIGN(0x1000);
  .data :
  {
    /* The first three sections are for SunOS dynamic linking.  */
    *(.dynamic)
    *(.got)
    *(.plt)
    *(.data)
    *(.linux-dynamic) /* For Linux dynamic linking.  */
    CONSTRUCTORS
    _edata  =  .;
    __edata  =  .;
  }
  .bss :
  {
    __bss_start = .;
   *(.bss)
   *(COMMON)
   _end = ALIGN(4) ;
   __end = ALIGN(4) ;
  }
}
