%include "boot.inc"

section loader vstart=LOADER_BASE_ADDR

call ShowGsMsg

jmp $

ShowGsMsg:
    mov byte [gs:0x00], 'F'
    mov byte [gs:0x01], 0xA4

    mov byte [gs:0x02], 'I'
    mov byte [gs:0x03], 0xA4

    mov byte [gs:0x04], 'S'
    mov byte [gs:0x05], 0xA4

    mov byte [gs:0x06], 'H'
    mov byte [gs:0x07], 0xA4

    mov byte [gs:0x08], '!'
    mov byte [gs:0x09], 0xA4
    ret