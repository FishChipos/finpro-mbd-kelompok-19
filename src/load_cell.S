/*
 * Using HX711 amplifier, which has a rate of 10 Hz. 
 */

#define __SFR_OFFSET 0
#include <avr/io.h>

.include "usart.inc"
.include "pins.inc"

.global load_cell_init
load_cell_init:
    cbi DDRD, PIN_HX711_DOUT
    cbi PORTD, PIN_HX711_DOUT
    sbi DDRD, PIN_HX711_PD_SCK
    cbi PORTD, PIN_HX711_PD_SCK

    ret

.global load_cell_calibrate
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
    call usart_putnl
    
    pop r18
    pop r17
    pop r16
    ret

.global load_cell_read
load_cell_read:
    push r19
    push r20
    
    ldi r20, 24
    rcall load_cell_wait_ready

    clr r19

    ; Wait time can be anywhere from 0.2 to 50 us but wont be too accurate anyway since the instructions take time to execute.
    ldi r16, 10
    
    load_cell_read_data:
        lsl r19
        rol r17
        rol r18

        sbi PORTD, PIN_HX711_PD_SCK

        call delay_us

        sbic PIND, PIN_HX711_DOUT
        ori r19, 1

        cbi PORTD, PIN_HX711_PD_SCK

        call delay_us

        dec r20
        brne load_cell_read_data
    
    sbi PORTD, PIN_HX711_PD_SCK
    call delay_us
    cbi PORTD, PIN_HX711_PD_SCK
    
    mov r16, r19
    
    pop r20
    pop r19
    ret

load_cell_wait_ready:
    sbic PIND, PIN_HX711_DOUT
    rjmp load_cell_wait_ready
    ret
