/*
 * Using HX711 amplifier, which has a rate of 10 Hz. 
 */

#define __SFR_OFFSET 0
#include <avr/io.h>

.include "usart.inc"
.include "pins.inc"

.global load_cell_init
.global load_cell_calibrate
.global load_cell_read

load_cell_init:
    cbi DDRD, PIN_HX711_DOUT
    cbi PORTD, PIN_HX711_DOUT
    sbi DDRD, PIN_HX711_PD_SCK
    cbi PORTD, PIN_HX711_PD_SCK

    ret

load_cell_calibrate:
    push r16
    push r17
    push r18

    rcall load_cell_read
    call usart_puthex
    mov r16, r17
    call usart_puthex
    mov r16, r18
    call usart_puthex
    rcall usart_putnl
    
    pop r18
    pop r17
    pop r16
    ret

load_cell_read:
    push r19
    
    ldi r19, 24
    rcall load_cell_wait_ready
    
    1:
        lsl r16
        rol r17
        rol r18

        PRINT_LINE msg_hi
        sbi PORTD, PIN_HX711_PD_SCK

        push r16
        ldi r16, 1
        rcall delay_us
        pop r16

        sbic PIND, PIN_HX711_DOUT
        ori r16, 1

        PRINT_LINE msg_lo
        cbi PORTD, PIN_HX711_PD_SCK

        push r16
        ldi r16, 1
        rcall delay_us
        pop r16

        dec r19
        brne 1b
    
    sbi PORTD, PIN_HX711_PD_SCK
    push r16
    ldi r16, 1
    rcall delay_us
    pop r16
    cbi PORTD, PIN_HX711_PD_SCK
    
    pop r19
    ret

load_cell_wait_ready:
    sbic PIND, PIN_HX711_DOUT
    rjmp load_cell_wait_ready
    ret

msg_reading: .string "Reading load cell..."
msg_readdone: .string "Done reading load cell"
msg_lo: .string "Clock low"
msg_hi: .string "Clock high"
