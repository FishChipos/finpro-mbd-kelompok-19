#define __SFR_OFFSET 0
#include <avr/io.h>

.global delay_s
delay_s:
    push r16
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
    pop r16
    ret

.global delay_ms
delay_ms:
    push r16
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
    pop r16
    ret

; TODO: This could still be more accurate, maybe do set up outside of this function?
.global delay_us
delay_us:
    push r16
    push r17
    
    clr r17
    sts TCNT1H, r17
    sts TCNT1L, r17

    clr r17
    sts OCR1AH, r17
    ldi r17, 16
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
    pop r16
    ret
