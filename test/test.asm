assume cs:code,ds:datasg,ss:stacksg


datasg segment
    num db 12 dup(0)
    num2 dw 6 dup(0)

    numlen dw 0
    tmpcx1 dw 0
datasg ends

stacksg segment
    db 25565 dup(0)
stacksg ends  
code segment
start:
    mov ax,datasg 
    mov ds,ax  
    
    mov ax,1
    mov [num2],ax
    mov [num2+4],ax
    mov ax,0
    mov [num2+2],ax


    call LongNumPrint
    
    jmp ProcEnd
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

;========Fib数字输出模块=====
;要先打印高位,答案在num2
LongNumPrintZero:
    mov dx,'0'    ;打印0
    mov ah,02h;打印字符指令
    int 21h     ;开启中断
    ret

LongNumPrint:
    mov ax,0
    mov [numlen],ax  ;numlen储存输出长度
    call isLongZero ;判0
    cmp ax,1    ;为0时直接打印0
    jz LongNumPrintZero

    mov si,0  ;存储偏移量
    mov cx,6 ;6个字
LongParseLoop:
    call isLongZero
    cmp ax,1  
    jz LongNumPrintOutput   ;为0则停止分析,开始打印输出

    mov [tmpcx1],cx ;暂存cx
    mov cx,3   ;每个单元最多存储999,所以要固定打印3位数字
ThreeLoop:
    call isLongZero
    cmp ax,1    ;判断是否为0
    jz LongNumPrintOutput  ;为0则停止分析,开始打印输出

ThreeLoopStart:
    add [numlen],1

    mov ax,[num2+si]
    cmp ax,0 
    jz ThreeLoopZero    ;分流
    ; jmp ThreeLoopZero ;debug

    mov dx,0
    mov bx,10
    div bx
    mov [num2+si],ax    ;写回内存
    add dx,'0'  ;转换为字符
    jmp ThreeLoopAdd

ThreeLoopZero:
    mov dx,'0'
ThreeLoopAdd:
    push dx
    loop ThreeLoopStart

    mov cx,[tmpcx1]
    add si,2 ;增加偏移量
    loop LongParseLoop

LongNumPrintOutput:
    mov cx,[numlen] ;取出数字长度
LongNumPrintOutputLoop:
    pop dx    ;出栈
    mov ah,02h;打印字符指令
    int 21h     ;开启中断
    loop LongNumPrintOutputLoop

    ret

;========判空模块==========
isLongZero:
    push cx
    push si
    mov cx,6  ;循环6次
    mov si,0
isLongZeroLoop:
    mov ax,[num2+si]
    cmp ax,0
    jnz ZeroFalse
    add si,2
    loop isLongZeroLoop

ZeorTrue:
    pop si
    pop cx
    mov ax,1
    ret
ZeroFalse:
    pop si
    pop cx
    mov ax,0
    ret
code ends
end start