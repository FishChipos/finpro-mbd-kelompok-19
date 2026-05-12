#define __SFR_OFFSET 0
#include <avr/io.h>

.global main

main:
    rcall usart_init
    rcall load_cell_init

loop:
    rjmp loop
