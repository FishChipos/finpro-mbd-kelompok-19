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

loop:
    call rfid_detect
    LCD_PRINT msg_uid
    push r16
    mov r16, r19
    call lcd_puthex
    mov r16, r18
    call lcd_puthex
    mov r16, r17
    call lcd_puthex
    pop r16
    call lcd_puthex
    LCD_MOVE 1, 0
    call load_cell_read
    LCD_PRINT msg_weight
    push r16
    mov r16, r18
    call lcd_puthex
    mov r16, r17
    call lcd_puthex
    pop r16
    call lcd_puthex
    LCD_PRINT msg_weight_unit
    DELAY 1 * S
    rjmp loop

msg_helloworld: .string "Hello, world!"
msg_uid: .string "UID: "
msg_weight: .string "Weight: "
msg_weight_unit: .string " kg"
.balign 2
