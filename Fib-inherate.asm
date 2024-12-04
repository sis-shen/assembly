assume cs:codesg,ds:datasg,ss:stacksg

;初始化数据段，并填入数字
datasg segment
    num dw 10h ;选择斐波那契数列的第num个数
    choose db 'Please choose a num from 1 to 100 : ','$'
    result db 'The result is : ','$'
    pressQ db 'Presss Q to exit','$'
    wrongRange db 'wrong range, try again'
    enter db 13, 10,'$'
    num1 dw 6 dup(0)
    num2 dw 6 dup(0)
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

    mov cx,6    ;12字节长度循环6次
    mov bx,0    ;bx计算偏移量
setZero:
    mov [num1+bx],0
    mov [num2+bx],0
    add bx,2    ;偏移量增加
    loop setZero

    ;debug
    mov [num2],1

    ;打印输入
    mov ah,09h
    lea dx,choose 
    int 21h

    ;获取输入,并存到ax里
    call InputNum
    push ax     

    mov ah,09h
    lea dx,enter;打印回车
    int 21h

    pop ax
    cmp ax,0    ;判断是否为0
    je ProcWrongRange
    cmp ax,99 ;判断是否比100大
    ja ProcWrongRange

    ; call Fib

    mov ah,09h
    lea dx,result
    int 21h

    call FibOutput

    mov ah,09h
    lea dx,enter;打印回车
    int 21h

    mov ah,09h
    lea dx,pressQ
    int 21h

    mov ah,09h
    lea dx,enter;打印回车
    int 21h

    jmp start ;改成循环，循环的退出在字符输入模块内

ProcWrongRange:
    mov ah,09h
    lea dx,wrongRange
    int 21h

    mov ah,09h
    lea dx,enter;打印回车
    int 21h

    jmp start
;===========斐波那契数列递归模块========规定用堆栈输出
Fib:
    cmp ax,3 ;ax <3 ，或者说 ax <= 2时
    jb FibBaseRet

    mov cx,ax
    sub cx,1    ;循环n-1次
    mov dx,0    ;储存进位
    mov ax,0
    mov bx,1
FibLoop:
    push cx ;暂存最外部的循环
    ;内层循环初始化
    mov si,0    ;储存偏移量
    mov cx,6    ;开始逐段相加和交换
    CLC;把CF置零
FibInnerLoop:
    mov ax,[num1+si];//从低位到高位取出一段数据
    mov bx,[num2+si];
    adc ax,bx   ;计算相加

    ;交换ax,bx
    push ax
    push bx
    pop ax
    pop bx

    mov [num1+si],ax    ;将数据写回内存
    mov [num2+si],bx 
    add si,2
    loop FibInnerLoop
    pop cx ;走到这完成了一次数字相加和交换,所以要回到外层循环
    loop FibLoop    

    ;输出参数在num2
    ret 

FibBaseRet:
    ;Fib(1) = Fib(2) = 1
    mov ax,1    ;ax输出参数
    mov [num2],ax;
    ret 
    
;================数字键入模块============
InputNum:
    ;现状保存,除了ax要输出参数
    ;设计为传值传参，所以要保存bx~dx
    push bx  
    push cx  
    push dx  

    mov bx,0    ;要用bx所以提前置0,用于暂存结果
    mov cx,0    ;同理,但用于中间计算
InputLoop:
    mov ah,1h ;使用1号中断输入字符
    int 21h
    ;判断是否为字符Q,为Q则退出程序
    cmp al,'Q'
    je ProcExit
    ;非法字符判断，包括回车时结束输入
    cmp al,'0' ;和字符'0'比较
    jb InputNumEnd  ;jb用于比小，当al < '0'小时跳转
    cmp al,'9'
    ja InputNumEnd  ;ja用于比大，当al > '0'时跳转

    sub al,'0' ;减去'0'获得真实数值   字符->数字
    ;实现bx*=10,即 bx = bx*2^3 + bx + bx
    mov cl,bl   ;备份bl的值
    shl bx,1    ;不能一次性移3位，会报错
    shl bx,1    ;
    shl bx,1    ;左移3位，相当于*8
    add bl,cl   ;
    add bl,cl   ;加两次
    add bl,al   ;把尾数al加上去

    jmp InputLoop ;重新循环

InputNumEnd:
    mov ax,0
    mov al,bl   ;向ax存入结果
    pop dx; 恢复现场
    pop cx;
    pop bx;
    ret    ;函数返回

;==============数字打印模块=============
PrintNum:
    ;现状保存
    push ax   ;设计为传值传参，所以要保存ax~dx
    push bx  
    push cx  
    push dx  
    ;初始化
    mov bx,10  ;这个bx存了除数10
    mov cx,0  ;cx用于记录数字位数/循环次数

ParseLoop:  ;解析数字串
    mov dx,0  ;dx置零
    div bx   ;ax/10取余数在dx中
    add dx,30h;转换成数字字符
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

;========Fib数字输出模块=====
;要先打印高位,答案在num2
LongNumPrint:
    mov bx,10   ;记录除数
    mov cx,0    ;记录打印次数
LongParseLoop:
    mov si,0    ;记录偏移量
    push cx ;暂存cx
;循环遍历一次取模操作
LongModeLoop:
    mov ax,[num2+si]    ;打印一次高位数字
    call PrintNum
    sub si,2;
    loop FibOutputLoop

    ret

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
;=========程序出口======
ProcExit:
    mov ax, 4c00h
    int 21h
codesg ends
end start 
    