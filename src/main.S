#define __SFR_OFFSET 0
#include <avr/io.h>

.global main

.include "usart.inc"

main:
    rcall usart_init
    rcall load_cell_init
    PRINT_LINE msg_helloworld

loop:
    rcall load_cell_calibrate
    ldi r16, 1
    rcall delay_s
    rjmp loop
