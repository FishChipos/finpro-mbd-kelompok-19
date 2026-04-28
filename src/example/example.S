#include <avr/io.h>

; Declare any labels that should be visible to other files this way.
; In other files, the linker will find the symbol automatically.
.global test

test:
    ret

test_func:
    ret
