#define __SFR_OFFSET 0
#include <avr/io.h>

.include "pins.inc"
.include "timing.inc"
.include "load_cell.inc"
.include "usart.inc"
.include "lcd.inc"

.global main
main:
    call usart_init
    call lcd_init
    call load_cell_init
    call rfid_init
    DELAY 1 * S
    USART_PRINT_LINE msg_helloworld
    ldi r16, 2
    ldi r17, 0
    call lcd_move
    LCD_PRINT msg_calibrate

loop:
    call rfid_detect
    DELAY 1 * S
    rjmp loop

msg_helloworld: .string "Hello, world!"
msg_calibrate: .string "Read value: "
.balign 2
