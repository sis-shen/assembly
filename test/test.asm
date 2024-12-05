assume cs:code,ds:datasg,ss:stacksg


datasg segment
    num db 12 dup(0)
    num2 dw 6 dup(0)
datasg ends

stacksg segment
    db 25565 dup(0)
stacksg ends  
code segment
start:
    mov ax,datasg 
    mov ds,ax  
    
    ; mov ax,0
    ; mov [num2],ax
    mov ax,1
    mov [num2+2],ax

    call isLongZero

    cmp ax,1
    jz Zero
    jmp NoneZero
    
Zero:
    mov dx,'0'
    mov ah,02h;打印字符指令
    int 21h     ;开启中断
    jmp ProcEnd

NoneZero:
    mov dx,'1'
    mov ah,02h;打印字符指令
    int 21h     ;开启中断

ProcEnd:
    mov ax, 4c00h
    int 21h

;========判空模块==========
isLongZero:
    push cx
    mov cx,6  ;循环6次
    mov si,0
isLongZeroLoop:
    mov ax,[num2+si]
    cmp ax,0
    jnz ZeroFalse
    add si,2
    loop isLongZeroLoop

ZeorTrue:
    pop cx
    mov ax,1
    ret
ZeroFalse:
    pop cx
    mov ax,0
    ret
code ends
end start