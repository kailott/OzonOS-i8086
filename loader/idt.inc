INT_GATE equ 1000111000000000b
align 8
IDT:
        dq 0 ; 0
        dq 0
        dq 0 ; 2
        dq 0 ; 3
        dq 0 ; 4
        dq 0 ; 5
        dq 0 ; 6
        dq 0 ; 7
        dq 0 ; 8
        dq 0 ; 9
        dq 0 ; 10
        dq 0 ; 11
        dq 0 ; 12
        DEFINE_INT_GATE exGP_handler , CODE_SELEKTOR  ; 13  #GP
        dq 0  ; 14
        dq 0  ; 15
        dq 0  ; 16
        dq 0  ; 17
        dq 0  ; 18
        dq 0  ; 19
        dq 0  ; 20
        dq 0  ; 21
        dq 0  ; 22
        dq 0  ; 23
        dq 0  ; 24
        dq 0  ; 25
        dq 0  ; 26
        dq 0  ; 27
        dq 0  ; 28
        dq 0  ; 29
        dq 0  ; 30
        dq 0  ; 31
        DEFINE_GATE irq0_handler, CODE_SELEKTOR,INT_GATE  ; 20 (IRQ 0 - ????????? ??????)
        DEFINE_GATE irq1_handler, CODE_SELEKTOR,INT_GATE  ; 21 (IRQ 1 - ??????????)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 22 (IRQ 2 - ??????? ?????????? ??????????)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 23 (IRQ 3 - COM2)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 24 (IRQ 4 - COM1)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 25 (IRQ 7 - LPT2)
        DEFINE_GATE irq6_handler, CODE_SELEKTOR,INT_GATE       ; 26 (IRQ 6 - FDD)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 27 (IRQ 7 - LPT1)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 28 (8)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 29 (9)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 2A (10)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 2B (11)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 2C (12)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 2D (13)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 2E (14)
        DEFINE_INT_GATE int_EOI , CODE_SELEKTOR       ; 2F (15)
        DEFINE_GATE int_0x30, CODE_SELEKTOR,INT_GATE  ; 0x30 SYSTEM CALLS


IDT_END:

label IDTR fword
                dw              IDT_END-IDT
                dd              IDT
