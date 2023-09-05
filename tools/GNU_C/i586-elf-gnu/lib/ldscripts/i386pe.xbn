OUTPUT_FORMAT(pei-i386)
 SEARCH_DIR(/gnu/i386-pe/lib);
ENTRY(_mainCRTStartup)
SECTIONS
{
  .text  __image_base__ + __section_alignment__  : 
  {
     *(.init)
    *(.text)
    *(.text$*)
    *(.glue_7t)
    *(.glue_7)
     ___CTOR_LIST__ = .; __CTOR_LIST__ = . ; 
			LONG (-1); *(.ctors); *(.ctor); LONG (0); 
     ___DTOR_LIST__ = .; __DTOR_LIST__ = . ; 
			LONG (-1); *(.dtors); *(.dtor);  LONG (0); 
     *(.fini)
    /* ??? Why is .gcc_exc here?  */
     *(.gcc_exc)
     etext = .;
    *(.gcc_except_table)
  }
  /* The Cygwin32 library uses a section to avoid copying certain data
     on fork.  This used to be named ".data".  The linker used
     to include this between __data_start__ and __data_end__, but that
     breaks building the cygwin32 dll.  Instead, we name the section
     ".data_cygwin_nocopy" and explictly include it after __data_end__. */
  .data BLOCK(__section_alignment__) : 
  {
    __data_start__ = . ;
    *(.data)
    *(.data2)
    *(.data$*)
    __data_end__ = . ;
    *(.data_cygwin_nocopy)
  }
  .bss BLOCK(__section_alignment__) :
  {
    __bss_start__ = . ;
    *(.bss)
    *(COMMON)
    __bss_end__ = . ;
  }
  .rdata BLOCK(__section_alignment__) :
  {
    *(.rdata)
    *(.rdata$*)
    *(.eh_frame)
  }
  .edata BLOCK(__section_alignment__) :
  {
    *(.edata)
  }
  /DISCARD/ :
  {
    *(.debug$S)
    *(.debug$T)
    *(.debug$F)
    *(.drectve)
  }
  .idata BLOCK(__section_alignment__) :
  {
    /* This cannot currently be handled with grouped sections.
	See pe.em:sort_sections.  */
    *(.idata$2)
    *(.idata$3)
    /* These zeroes mark the end of the import list.  */
    LONG (0); LONG (0); LONG (0); LONG (0); LONG (0);
    *(.idata$4)
    *(.idata$5)
    *(.idata$6)
    *(.idata$7)
  }
  .CRT BLOCK(__section_alignment__) :
  { 					
    *(.CRT$*)
  }
  .endjunk BLOCK(__section_alignment__) :
  {
    /* end is deprecated, don't use it */
     end = .;
     __end__ = .;
  }
  .reloc BLOCK(__section_alignment__) :
  { 					
    *(.reloc)
  }
  .rsrc BLOCK(__section_alignment__) :
  { 					
    *(.rsrc)
    *(.rsrc$*)
  }
  .stab BLOCK(__section_alignment__) (NOLOAD) :
  {
    [ .stab ]
  }
  .stabstr BLOCK(__section_alignment__) (NOLOAD) :
  {
    [ .stabstr ]
  }
}
