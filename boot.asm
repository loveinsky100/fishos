%include "boot.inc"

org  07c00h  ; 告诉编译器程序加载到7c00处
    mov    ax, cs
    mov    ds, ax
    mov    es, ax

    mov ax, 0xb800
    mov gs, ax

    call    CleanConsole

    mov eax, LOADER_START_SECTOR
    mov bx, LOADER_BASE_ADDR
    mov cx, 1
    call LoadDisk

    jmp LOADER_BASE_ADDR

CleanConsole:
    mov ax, 0600h
    mov bx, 0700h
    mov cx, 0
    mov dx, 184fh
    int 10h

ShowBootMsg:
    mov    ax, BootMessage
    mov    bp, ax            ; ES:BP = 串地址
    mov    cx, 13            ; CX = 串长度
    mov    ax, 01301h        ; AH = 13,  AL = 01h
    mov    bx, 000ch        ; 页号为0(BH = 0) 黑底红字(BL = 0Ch,高亮)
    mov    dl, 0
    int    10h            ; 10h 号中断
    ret

LoadDisk:
    mov esi, eax
    mov di, cx

    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov eax, esi

    mov dx, 0x1f3
    out dx, al

    mov cl, 8
    shr eax, cl
    mov dx, 0x1f4
    out dx, al

    shr eax, cl
    mov dx, 0x1f5
    out dx, al

    shr eax, cl
    and al, 0x0f
    or al, 0xe0
    mov dx, 0x1f6
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.not_ready:
    nop
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz .not_ready

    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax
    mov dx, 0x1f0

.go_on_read:
    in ax, dx
    mov [bx], ax
    add bx, 2
    loop .go_on_read
    ret

BootMessage:        db    "Hello, FishOS!"
times     510-($-$$)    db    0    ; 填充剩下的空间，使生成的二进制代码恰好为512字节
dw     0xaa55                ; 结束标志