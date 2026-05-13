.macro PRINT addr
    ldi zh, hi8(\addr)
    ldi zl, lo8(\addr)
    rcall usart_puts
.endm

.macro PRINT_LINE addr
    ldi zh, hi8(\addr)
    ldi zl, lo8(\addr)
    rcall usart_putsnl
.endm

