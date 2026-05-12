#define __SFR_OFFSET 0
#include <avr/io.h>

.global delay_s
.global delay_ms
.global delay_us

delay_s:
    ret

delay_ms:
    ret

delay_us:
    ret
