#define __SFR_OFFSET 0
#include <avr/io.h>

.global delay_s
.global delay_ms
.global delay_us

delay_s:
    push r17
    
    clr r17
    sts TCNT1H, r17
    sts TCNT1L, r17

    ldi r17, hi8(15625)
    sts OCR1AH, r17
    ldi r17, lo8(15625)
    sts OCR1AL, r17

    ldi r17, (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts TCCR1B, r17
    
    2:
        1:
            sbis TIFR1, OCF1A
            rjmp 1b
            sbi TIFR1, OCF1A
        dec r16
        brne 2b
    
    clr r17
    sts TCCR1B, r17

    pop r17
    ret

delay_ms:
    push r17
    
    clr r17
    sts TCNT1H, r17
    sts TCNT1L, r17

    ldi r17, hi8(250)
    sts OCR1AH, r17
    ldi r17, lo8(250)
    sts OCR1AL, r17

    ldi r17, (1 << WGM12) | (1 << CS11) | (1 << CS10)
    sts TCCR1B, r17
    
    2:
        1:
            sbis TIFR1, OCF1A
            rjmp 1b
            sbi TIFR1, OCF1A
        dec r16
        brne 2b
    
    clr r17
    sts TCCR1B, r17

    pop r17
    ret

delay_us:
    push r17
    
    clr r17
    sts TCNT1H, r17
    sts TCNT1L, r17

    ldi r17, hi8(16)
    sts OCR1AH, r17
    ldi r17, lo8(16)
    sts OCR1AL, r17

    ldi r17, (1 << WGM12) | (1 << CS10)
    sts TCCR1B, r17
    
    2:
        1:
            sbis TIFR1, OCF1A
            rjmp 1b
            sbi TIFR1, OCF1A
        dec r16
        brne 2b
    
    clr r17
    sts TCCR1B, r17

    pop r17
    ret
