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
    call load_cell_init
    call lcd_init
    DELAY 1 * S
    USART_PRINT_LINE msg_helloworld
    LCD_PRINT msg_lcdtest
    DELAY 1 * S
    call lcd_clear

loop:
    call load_cell_calibrate
    ldi r16, 1
    call delay_s
    rjmp loop

msg_helloworld: .string "Hello, world!"
msg_lcdtest: .string "This is a very long string, look at me being really not short"
.balign 2
