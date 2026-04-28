#include <avr/io.h>

.global main

main:
    rcall usart_init

loop:
    rjmp loop
