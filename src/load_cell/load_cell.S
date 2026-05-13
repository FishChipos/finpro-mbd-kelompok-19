/*
 * Using HX711 amplifier, which has a rate of 10 Hz. 
 */

#define __SFR_OFFSET 0
#include <avr/io.h>

#include "pins.h"

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
    rcall usart_hex
    mov r16, r17
    rcall usart_hex
    mov r16, r18
    rcall usart_hex
    
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

        ; Should delay here

        sbi PORTD, PIN_HX711_PD_SCK
        sbic PIND, PIN_HX711_DOUT
        ori r16, 1

        ; Should delay here

        dec r19
        brne 1b
    
    sbi PORTD, PIN_HX711_PD_SCK
    ; Should delay here
    cbi PORTD, PIN_HX711_PD_SCK
    
    pop r19
    ret

load_cell_wait_ready:
    sbic PIND, PIN_HX711_DOUT
    rjmp load_cell_wait_ready
    ret
