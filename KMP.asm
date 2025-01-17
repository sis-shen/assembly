assume cs:codesg,ds:datasg,ss:stacksg

;初始化数据段，并填入数字
datasg segment
    debugKey db 0,3,'key'
    debugSen db 0,6,'nonono'
    buffer db 80 , 0 , 80 dup('$');第一个字节表示输入缓冲区大小为80，第二个为已写入的字符数量
    str db 80 dup('$')
    match db 'Match at location:','$'
    noMatch db 'No Match!','$'
    enterKeyword db 'Enter keyword:','$'
    enterSentence db 'Enter sentence:' , '$'
    enter db 13, 10,'$'
    H_vector db '123456789ABCDEF' 

    len_key db 0
    len_sen db 0

    sum_len db 0

    pi db 80 dup(0)
datasg ends  

;初始化栈段，置空
stacksg segment
    db 25565 dup(0)
stacksg ends  

codesg segment
start:
    mov ax,datasg 
    mov ds,ax;
    mov ax,stacksg;
    mov ss,ax;
    mov sp,25565;初始化栈

    ;=====获取keyWord======
    ; mov ax,0900h
    ; lea dx,enterKeyword
    ; int 21h

    ; mov ax,0A00h
    ; lea dx,buffer 
    ; int 21h

    ; mov ax,0900h
    ; lea dx,enter
    ; int 21h

    ; mov al,[buffer+1]
    ; mov [len_key],al
    ;DEBUG
    mov al,[debugKey+1]
    mov [len_key],al

    mov cx,0
    mov cl,[len_key]
    mov bx,0
    mov al,0
keyCopyLoop:
    ; mov al,[buffer][bx]
    mov al,[debugKey][bx]
    mov [str][bx],al
    add bx,1
    loop keyCopyLoop

    mov al,'$'
    mov [str][bx],al    ;把str拼接为 key + '$' + sentence

ParseSentence:
    ; mov ax,0900h
    ; lea dx,enterSentence
    ; int 21h

    ; mov ax,0A00h
    ; lea dx,buffer 
    ; int 21h

    ; mov ax,0900h
    ; lea dx,enter
    ; int 21h
    
    ; mov al,[buffer+1]
    ; mov [len_sen],al
    
    mov al,[debugSen+1]
    mov [len_sen],al
    
    mov cx,0
    mov cl,[len_sen]
    mov ax,0
    mov al,[len_key]
    mov si,ax
    mov bx,0
    mov al,0
senCopyLoop:
    ; mov al,[buffer][bx]
    mov al,[debugSen][bx]
    mov [str+si+bx],al
    add bx,1
    loop senCopyLoop

callPI:
    call makePi

    cmp bx,0
    jz noMatchOutput

    push ax ;暂存答案

    mov ax,0A00h
    lea dx,Match
    int 21h

noMatchOutput:
    mov ax,0A00h
    lea dx,noMatch
    int 21h

    mov ax,0A00h
    lea dx,buffer+2 
    int 21h

    jmp ParseSentence
;============KMP求解模块==========

makePi:
    mov ax,0
    mov cx,0
    mov cl,[len_key]
    add cl,1
    add cl,[len_sen];
    sub cl,1    ;循环次数是总长度-1，因为从下标为1开始
    mov bx,1    ;bx作为下标
makePiLoop:
    mov si,bx
    sub si,1    ;求i-1
    mov al,[pi+si]  ;求len

LoopOne:
    cmp al,0    ;判断len == 0
    jz Judge
    mov dl,[str+bx]
    mov di,ax
    cmp dl,[str+di]
    jz Judge    ;字符相等时也跳转
    ;否则缩小len
    mov di,ax;
    sub di,1
    mov al,[pi+di]
    jmp LoopOne
Judge:
    mov dl,[str+bx]
    mov di,ax
    cmp dl,[str+di]
    jnz piZero
    ;相等时
    add al,1    ;求len+1
    mov [pi+bx],al;
    cmp al,[len_key]
    jz FindOutput   ;找到则跳转
    inc bx  ;下标++
    loop makePiLoop ;找不到则继续循环

piZero:
    mov al,0
    mov [pi+bx],al
    loop makePiLoop

FailOutput:
;找不到
    mov bx,0
    ret

FindOutput:
    mov al,[len_key];
    add al,al;al*=2
    sub bl,al   ;减去al里的值，答案存在bl里
    mov al,bl   ;答案存在al里
    mov bx,1
    ret

;======无符号整型十六进制输出模块=======
PrintNum:
    ;现状保存
    push ax   ;设计为传值传参，所以要保存ax~dx
    push bx  
    push cx  
    push dx  
    ;初始化
    mov bx,'H'
    push bx;最后要输出一个H表示16进制
    mov bx,16  ;这个bx存了除数10
    mov cx,0  ;cx用于记录数字位数/循环次数

ParseLoop:  ;解析数字串
    mov dx,0  ;dx置零
    div bx   ;ax/10取余数在dx中
    mov si,dx
    mov dl,[H_vector+si];利用偏移量转换成数字字符
    push dx  ;将余数压栈（正好最后一个数字先压栈，后出栈）
    inc cx   ;增加打印计数
    cmp ax,0 ;判断ax是否为0
    jnz ParseLoop   ;循环调用

PrintNumStr:
    pop dx    ;出栈
    mov ah,02h;打印字符指令
    int 21h     ;开启中断
    loop PrintNumStr

    pop dx; 恢复现场
    pop cx;
    pop bx;
    pop ax;
    ret    ;函数返回
;=========程序出口=========
procEnd:
    mov ax,4c00h
    int 21h


codesg ends
end start 