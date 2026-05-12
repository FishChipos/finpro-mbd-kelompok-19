#define __SFR_OFFSET 0
#include <avr/io.h>

.global usart_init
.global usart_enable
.global usart_disable
.global usart_putc ; Put one character (byte).
.global usart_puts ; Put a null-terminated string.
.global usart_getc ; Get one character (byte).

#define UCSR0B_CONF \
    (0b11 << UCSZ00)

usart_init:
    push r16

    rcall usart_enable

    ldi r16, hi8(8)
    sts UBRR0H, r16
    ldi r16, lo8(8)
    sts UBRR0L, r16

    pop r16
    ret

usart_enable:
    push r16

    ldi r16, (1 << RXEN0) | (1 << TXEN0) | UCSR0B_CONF
    sts UCSR0B, r16

    pop r16
    ret

usart_disable:
    push r16

    ldi r16, UCSR0B_CONF
    sts UCSR0B, r16

    pop r16
    ret

usart_putc:
    push r17

    usart_putc_wait:
        lds r17, UCSR0A
        sbrs r17, UDRE0
        rjmp usart_putc_wait

    sts UDR0, r16

    pop r16
    ret

usart_puts:
    push r16

    usart_puts_loadc:
        lpm r16, z+
        breq usart_puts_done
        rcall usart_putc
        rjmp usart_puts_loadc

    usart_puts_done:
    pop r16
    ret

usart_getc:
    push r17

    usart_getc_wait:
        lds r17, UCSR0A
        sbrs r17, RXC0
        rjmp usart_getc_wait

    lds r16, UDR0

    pop r17
    ret
