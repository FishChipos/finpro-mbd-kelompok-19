.macro USART_PRINT addr
    ldi zh, hi8(\addr)
    ldi zl, lo8(\addr)
    call usart_puts
.endm

.macro USART_PRINT_LINE addr
    ldi zh, hi8(\addr)
    ldi zl, lo8(\addr)
    call usart_putsnl
.endm

