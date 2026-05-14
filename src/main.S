#define __SFR_OFFSET 0
#include <avr/io.h>

.include "load_cell.inc"
.include "pins.inc"
.include "usart.inc"

.global main
main:
    call usart_init
    call load_cell_init
    ldi r16, 1
    call delay_s
    PRINT_LINE msg_helloworld

loop:
    call load_cell_calibrate
    ldi r16, 1
    call delay_s
    rjmp loop

msg_helloworld: .string "Hello, world!"
.balign 2
