#define __SFR_OFFSET 0
#include <avr/io.h>

.global main

.include "load_cell.inc"
.include "pins.inc"
.include "usart.inc"

main:
    rcall usart_init
    rcall load_cell_init
    ldi r16, 1
    rcall delay_s
    PRINT_LINE msg_helloworld
    ldi r16, 255
    rcall usart_puthex
    rcall usart_putnl

loop:
    rcall load_cell_calibrate
    ldi r16, 1
    rcall delay_s
    rjmp loop

msg_helloworld: .string "Hello, world!"
