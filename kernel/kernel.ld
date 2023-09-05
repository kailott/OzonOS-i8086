OUTPUT_FORMAT("binary")
ENTRY(_start)

SECTIONS {
 	.text 0x400000 : {
		*(.text)
		*(.code)
		*(.data)
		*(.rodata*)

	}
	.bss : {
		*(.bss*)
	}
}