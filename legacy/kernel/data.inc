;data.inc
stdName 	db	'STDIO   BIN'
ShellName	db	'SHELL   COM'
;messages
HelloMesg	db	'Int 0x21 loaded',0Ah,0Dh,0



;Årror messages
STDload_err	db	'STDIO.BIN not found',0
Shell_load_err	db	'Shell not found',0
;unknown data
stack_seg	dw	?
stack_offset	dw	?
_ds		dw	?

_ASCII	db '0123456789ABCDEF'



