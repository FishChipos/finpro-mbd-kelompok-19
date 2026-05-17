; Delays in microseconds.
.macro DELAY us
    push r16
    .ifge (\us / 1000000) - 1
        ldi r16, \us / 1000000
        call delay_s
    .else
        .ifge (\us / 1000) - 1
            ldi r16, \us / 1000
            call delay_ms
        .else
            ldi r16, \us
            call delay_us
        .endif
    .endif
    pop r16
.endm

; Use these to easily determine the delay units.
.equ S, 1000000
.equ MS, 1000
.equ US, 1
