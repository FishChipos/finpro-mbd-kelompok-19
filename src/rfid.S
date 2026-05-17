#define __SFR_OFFSET 0
#include <avr/io.h>

.include "pins.inc"
.include "timing.inc"
.include "usart.inc"

; MFRC522 registers and important bits.
.equ REG_CMD, 0x01
.equ CMD_IDLE, 0b0000
.equ CMD_TRANSCEIVE, 0b1100
.equ CMD_SOFT_RESET, 0b1111

.equ REG_TXCONTROL, 0x14
.equ TXCONTROL_TX2RFE, 1
.equ TXCONTROL_TX1RFE, 0

.equ REG_FIFODATA, 0x09

.equ REG_FIFOLEVEL, 0x0A
.equ FIFOLEVEL_FLUSHBUFFER, 7

.equ REG_BITFRAMING, 0x0D
.equ BITFRAMING_TXLASTBITS, 0
.equ BITFRAMING_STARTSEND, 7

.equ REG_COMIRQ, 0x04
.equ COMIRQ_TIMER, 0
.equ COMIRQ_RX, 5

.equ REG_VERSION, 0x37

; Commands used for the protocol described in ISO 14443.
.equ PCMD_REQA, 0x26
.equ PCMD_SEL, 0x93

.macro RFID_WRITE reg, data
    ldi r16, \reg
    ldi r17, \data
    call rfid_write
.endm

.macro RFID_READ reg
    ldi r16, \reg
    call rfid_read
.endm

.global rfid_init
rfid_init:
    push r16

    USART_PRINT_LINE msg_rfid_init_start

    ldi r16, (1 << PIN_MFRC522_SCK) | (1 << PIN_MFRC522_MOSI) | (1 << PIN_MFRC522_SS) | (1 << PIN_MFRC522_RST)
    out DDRB, r16

    sbi PORTB, PIN_MFRC522_SS

    ldi r16, (1 << SPE) | (1 << MSTR) | (1 << SPR0)
    out SPCR, r16

    rcall rfid_reset
    RFID_WRITE REG_CMD, CMD_SOFT_RESET

    USART_PRINT msg_rfid_init_version
    RFID_READ REG_VERSION
    call usart_puthex

    RFID_WRITE REG_TXCONTROL, (1 << TXCONTROL_TX2RFE) | (1 << TXCONTROL_TX1RFE)

    USART_PRINT_LINE msg_rfid_init_done

    pop r16
    ret

msg_rfid_init_start: .string "Initializing RFID..."
msg_rfid_init_version: .string "RFID version: "
msg_rfid_init_done: .string "RFID initialized."
.balign 2

.global rfid_detect
rfid_detect:
    push r16
    push r17
    push r18
    push r19
    push r20
    push r21
    push r22

    USART_PRINT_LINE msg_rfid_detect_start

    RFID_WRITE REG_FIFOLEVEL, 1 << FIFOLEVEL_FLUSHBUFFER
    RFID_WRITE REG_BITFRAMING, 0b111 << BITFRAMING_TXLASTBITS
    RFID_WRITE REG_FIFODATA, PCMD_REQA
    RFID_WRITE REG_CMD, CMD_TRANSCEIVE
    RFID_WRITE REG_BITFRAMING, (1 << BITFRAMING_STARTSEND) | (0b111 << BITFRAMING_TXLASTBITS)

    rcall rfid_wait_rxirq
    sbrc r16, 0
    rjmp rfid_detect_reqa_fail

    RFID_WRITE REG_CMD, CMD_IDLE

    RFID_READ REG_FIFODATA
    mov r17, r16
    RFID_READ REG_FIFODATA

    RFID_WRITE REG_FIFOLEVEL, 1 << FIFOLEVEL_FLUSHBUFFER
    RFID_WRITE REG_BITFRAMING, 0

    RFID_WRITE REG_FIFODATA, PCMD_SEL
    RFID_WRITE REG_FIFODATA, 2 << 4

    RFID_WRITE REG_CMD, CMD_TRANSCEIVE
    RFID_WRITE REG_BITFRAMING, 1 << BITFRAMING_STARTSEND

    rcall rfid_wait_rxirq
    sbrc r16, 0
    rjmp rfid_detect_anticollision_fail

    RFID_WRITE REG_CMD, CMD_IDLE

    RFID_READ REG_FIFODATA
    mov r22, r16
    RFID_READ REG_FIFODATA
    mov r21, r16
    RFID_READ REG_FIFODATA
    mov r20, r16
    RFID_READ REG_FIFODATA
    mov r19, r16
    RFID_READ REG_FIFODATA
    mov r18, r16

    USART_PRINT msg_rfid_detect_uid
    mov r16, r22
    call usart_puthex
    eor r16, r21
    call usart_puthex
    eor r16, r20
    call usart_puthex
    eor r16, r19
    call usart_puthex
    cp r16, r18
    brne rfid_detect_bcc_fail
    
    mov r16, r18
    call usart_puthex
    call usart_putnl

    RFID_WRITE REG_FIFOLEVEL, 1 << FIFOLEVEL_FLUSHBUFFER
    RFID_WRITE REG_FIFODATA, PCMD_SEL
    RFID_WRITE REG_FIFODATA, 7 << 4

    ldi r16, REG_FIFODATA
    mov r17, r22
    rcall rfid_write

    ldi r16, REG_FIFODATA
    mov r17, r21
    rcall rfid_write

    ldi r16, REG_FIFODATA
    mov r17, r20
    rcall rfid_write

    ldi r16, REG_FIFODATA
    mov r17, r19
    rcall rfid_write

    ldi r16, REG_FIFODATA
    mov r17, r18
    rcall rfid_write

    RFID_WRITE REG_CMD, CMD_TRANSCEIVE
    RFID_WRITE REG_BITFRAMING, 1 << BITFRAMING_STARTSEND

    rcall rfid_wait_rxirq
    sbrc r16, 0
    rjmp rfid_detect_select_fail

    RFID_WRITE REG_CMD, CMD_IDLE

    USART_PRINT msg_rfid_detect_sak
    RFID_READ REG_FIFODATA
    call usart_puthex
    call usart_putnl

    rjmp rfid_detect_done

    rfid_detect_reqa_fail:
        USART_PRINT_LINE msg_rfid_detect_reqa_fail
        rjmp rfid_detect_done

    rfid_detect_anticollision_fail:
        USART_PRINT_LINE msg_rfid_detect_anticollision_fail
        rjmp rfid_detect_done

    rfid_detect_bcc_fail:
        USART_PRINT_LINE msg_rfid_detect_bcc_fail
        USART_PRINT msg_rfid_detect_bcc_actual
        call usart_puthex
        call usart_putnl
        USART_PRINT msg_rfid_detect_bcc_expected
        mov r16, r18
        call usart_puthex
        call usart_putnl
        rjmp rfid_detect_done

    rfid_detect_select_fail:
        USART_PRINT_LINE msg_rfid_detect_select_fail
        rjmp rfid_detect_done

    rfid_detect_done:
    USART_PRINT_LINE msg_rfid_detect_done

    pop r22
    pop r21
    pop r20
    pop r19
    pop r18
    pop r17
    pop r16
    ret

msg_rfid_detect_start: .string "RFID detect starting..."
msg_rfid_detect_uid: .string "UID: "
msg_rfid_detect_sak: .string "SAK: "
msg_rfid_detect_reqa_fail: .string "REQA failed!"
msg_rfid_detect_anticollision_fail: .string "Anticollision failed!"
msg_rfid_detect_bcc_fail: .string "BCC check failed!"
msg_rfid_detect_bcc_actual: .string "Actual BCC: "
msg_rfid_detect_bcc_expected: .string "Expected BCC: "
msg_rfid_detect_select_fail: .string "SELECT failed!"
msg_rfid_detect_done: .string "RFID detect done."
.balign 2

rfid_wait_rxirq:
    1:
        RFID_READ REG_COMIRQ
        sbrc r16, COMIRQ_TIMER
        rjmp 2f
        sbrs r16, COMIRQ_RX
        rjmp 1b
        rjmp 3f
    2:
        ldi r16, 1
        ret
    3:
        clr r16
        ret

rfid_write:
    push r16
    push r17

    cbi PORTB, PIN_MFRC522_SS

    lsl r16
    ; Set MSB to 0 for write.
    andi r16, 0b01111110

    rcall spi_transfer

    mov r16, r17

    rcall spi_transfer

    sbi PORTB, PIN_MFRC522_SS

    pop r17
    pop r16
    ret

rfid_read:
    push r16

    cbi PORTB, PIN_MFRC522_SS

    lsl r16
    ; Set MSB to 1 for read.
    ori r16, 0b10000000

    rcall spi_transfer

    clr r16

    rcall spi_transfer

    sbi PORTB, PIN_MFRC522_SS

    pop r16
    ret

rfid_reset:
    cbi PORTB, PIN_MFRC522_RST
    DELAY 10 * US
    sbi PORTB, PIN_MFRC522_RST

    ret

spi_transfer:
    out SPDR, r16

    1:
        in r16, SPSR
        sbrs r16, SPIF
        rjmp 1b

    in r16, SPDR
    ret
