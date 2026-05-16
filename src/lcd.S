; Slave address of 0x27.
; The PCF8574 has a maximum SCL of 100 kHz.

#define __SFR_OFFSET 0
#include <avr/io.h>

.include "twi_addresses.inc"

.equ MODE_WRITE, 0
.equ MODE_READ, 1

.equ RS, 0
.equ RW, 1
.equ E, 2
.equ BT, 3

; Clear display.
.equ INSTR_CD, 0b00000001
; Return home.
.equ INSTR_RH, 0b00000010
; Display control.
.equ INSTR_DC, 0b00000100
.equ DC_D, 2
.equ DC_C, 1
.equ DC_B, 0
; Function set.
.equ INSTR_FS, 0b00100000
.equ FS_DL, 4
.equ FS_N, 3
.equ FS_F, 2

.global lcd_init
lcd_init:
    push r16

    ; These settings should result in a SCL of 25 kHz.
    ldi r16, 156
    sts TWBR, r16
    ldi r16, (1 << TWPS0)
    sts TWSR, r16
    ldi r16, (1 << TWEN)
    sts TWCR, r16

    ldi r16, 20
    call delay_ms

    rcall twi_start

    rcall twi_lcd_address

    ; We first need to initialize the LCD in 8-bit mode.
    ldi r16, 0b00110000 | (1 << BT) | (1 << E)
    rcall twi_write
    ldi r16, 0b00110000 | (1 << BT)
    rcall twi_write
    ldi r16, 25
    call delay_ms

    ldi r16, 0b00110000 | (1 << BT) | (1 << E)
    rcall twi_write
    ldi r16, 0b00110000 | (1 << BT)
    rcall twi_write
    ldi r16, 1
    call delay_ms

    ldi r16, 0b00110000 | (1 << BT) | (1 << E)
    rcall twi_write
    ldi r16, 0b00110000 | (1 << BT)
    rcall twi_write
    ldi r16, 1
    call delay_ms

    ; Then we can set 4-bit mode.
    ldi r16, 0b00100000 | (1 << BT) | (1 << E)
    rcall twi_write
    ldi r16, 0b00100000 | (1 << BT)
    rcall twi_write
    ldi r16, 1
    call delay_ms

    ; Then we can set two lines.
    ldi r17, (1 << BT)
    ldi r16, 0b00101000
    rcall lcd_write

    ; Then enable display, disable cursor.
    ldi r16, 0b00001100
    rcall lcd_write

    ; And a display clear.
    ldi r16, 0b00000001
    rcall lcd_write
    ldi r16, 25
    call delay_ms
    
    rcall twi_stop

    pop r16
    ret

.global lcd_clear
lcd_clear:
    push r16

    rcall twi_start

    rcall twi_lcd_address

    ldi r17, (1 << BT)
    ldi r16, 0b00000001
    rcall lcd_write
    ldi r16, 25
    call delay_ms
    
    rcall twi_stop

    pop r16
    ret
    
; 0x00 to 0x13, 0x40 to 0x53, 0x14 to 0x27, and 0x54 to 0x67
.global lcd_move
lcd_move:
    push r16
    push r17
    push r18

    clr r18

    sbrc r16, 0
    subi r18, -0x40
    sbrc r16, 1
    subi r18, -0x14

    add r18, r17

    rcall twi_start

    rcall twi_lcd_address

    ldi r17, (1 << BT)
    mov r16, r18
    ori r16, 0b10000000
    rcall lcd_write

    rcall twi_stop
    
    pop r18
    pop r17
    pop r16
    ret

.global lcd_putc
lcd_putc:
    push r17

    rcall twi_start

    rcall twi_lcd_address

    ldi r17, (1 << BT) | (1 << RS)
    rcall lcd_write

    rcall twi_stop

    pop r17
    ret

.global lcd_puts
lcd_puts:
    push r16
    push r17

    rcall twi_start

    rcall twi_lcd_address

    ldi r17, (1 << BT) | (1 << RS)

    1:
        lpm r16, z+
        tst r16
        breq 2f
        rcall lcd_write
        rjmp 1b

    2:
    rcall twi_stop

    pop r17
    pop r16
    ret

.global lcd_puthex
lcd_puthex:
    push r16
    push r17
    push r18

    mov r18, r16
    swap r16

    andi r16, 0b00001111
    andi r18, 0b00001111
    
    cpi r16, 10
    brlo lcd_puthex_hi_ascii_adjust
    subi r16, -('A' - ':')

    lcd_puthex_hi_ascii_adjust:
    subi r16, -'0'

    cpi r18, 10
    brlo lcd_puthex_lo_ascii_adjust
    subi r18, -('A' - ':')

    lcd_puthex_lo_ascii_adjust:
    subi r18, -'0'

    rcall twi_start

    rcall twi_lcd_address

    ldi r17, (1 << BT) | (1 << RS)
    rcall lcd_write
    mov r16, r18
    rcall lcd_write

    rcall twi_stop

    pop r18
    pop r17
    pop r16
    ret

lcd_write:
    push r16
    push r18

    mov r18, r16
    swap r18
    andi r16, 0b11110000
    andi r18, 0b11110000

    ori r16, (1 << E)
    or r16, r17
    rcall twi_write
    andi r16, ~(1 << E)
    rcall twi_write
    ldi r16, 1
    call delay_ms
    
    mov r16, r18
    ori r16, (1 << E)
    or r16, r17
    rcall twi_write
    andi r16, ~(1 << E)
    rcall twi_write
    ldi r16, 1
    call delay_ms

    pop r18
    pop r16
    ret

twi_lcd_address:
    push r16

    ldi r16, (TWI_ADDRESS_LCD << 1)
    rcall twi_write

    pop r16
    ret

twi_write:
    push r17

    sts TWDR, r16
    ldi r17, (1 << TWEN) | (1 << TWINT)
    sts TWCR, r17

    rcall twi_wait_int

    pop r17
    ret

twi_start:
    push r16
    
    ldi r16, (1 << TWEN) | (1 << TWSTA)
    sts TWCR, r16

    rcall twi_wait_int

    pop r16
    ret

twi_stop:
    push r16
    
    ldi r16, (1 << TWEN) | (1 << TWSTO) | (1 << TWINT)
    sts TWCR, r16

    1:
        lds r16, TWCR
        sbrc r16, TWSTO
        rjmp 1b

    pop r16
    ret

twi_wait_int:
    push r16
    
    1:
        lds r16, TWCR
        sbrs r16, TWINT
        rjmp 1b

    pop r16
    ret
