#include <avr/io.h>

.global main

main:
    rcall test

loop:
    rjmp loop
