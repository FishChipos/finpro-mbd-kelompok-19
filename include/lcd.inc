.macro LCD_PRINT addr
    ldi zh, hi8(\addr)
    ldi zl, lo8(\addr)
    call lcd_puts
.endm
