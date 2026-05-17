.macro LCD_PRINT addr
    ldi zh, hi8(\addr)
    ldi zl, lo8(\addr)
    call lcd_puts
.endm

.macro LCD_MOVE row, column
    push r16
    push r17

    ldi r16, row
    ldi r17, column
    call lcd_move

    pop r17
    pop r16
.endm
