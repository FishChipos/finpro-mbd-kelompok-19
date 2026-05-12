/*
 * Using HX711 amplifier, which has a rate of 10 Hz. 
 */

#define __SFR_OFFSET 0
#include <avr/io.h>

#include "pins.h"
#include "variables.h"

.global load_cell_init
.global load_cell_calibrate

load_cell_init:
    cbi DDRD, PIN_HX711_DOUT
    cbi PORTD, PIN_HX711_DOUT
    sbi DDRD, PIN_HX711_PD_SCK
    cbi PORTD, PIN_HX711_PD_SCK

    ret

load_cell_calibrate:
    push r16

    rcall load_cell_read
    
    pop r16
    ret

load_cell_read:
    push r17
    
    ldi r17, 24
    rcall load_cell_wait_ready
    
    1:
        
    
    pop r17
    ret

load_cell_wait_ready:
    sbic PIND, PIN_HX711_DOUT
    rjmp wait_ready
    ret
