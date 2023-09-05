OUTPUT_FORMAT("msdos")
OUTPUT_ARCH(i386)
 SEARCH_DIR(/gnu/i386-msdos/lib);
SECTIONS
{
  . = 0x0;
  .text :
  {
    CREATE_OBJECT_SYMBOLS
    *(.text)
    etext = .;
    _etext = .;
    __etext = .;
  }
  .data :
  {
    *(.rodata)
    *(.data)
    CONSTRUCTORS
    edata  =  .;
    _edata  =  .;
    __edata  =  .;
  }
  .bss :
  {
    _bss_start = .;
    __bss_start = .;
   *(.bss)
   *(COMMON)
   end = ALIGN(4) ;
   _end = ALIGN(4) ;
   __end = ALIGN(4) ;
  }
}
