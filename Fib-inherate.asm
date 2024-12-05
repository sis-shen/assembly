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

    numlen dw 0 ;储存余数

    tmpcx1 dw 0
    tmpcx2 dw 0

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

    ; ;debug
    mov ax,999
    mov [num2],ax
    mov ax,1
    ; mov [num2+2],ax
    mov [num2+4],ax

    mov ah,09h
    lea dx,result
    int 21h

    call LongNumPrint

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
FarProcExit:
    jmp far ptr ProcExit
    ret

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
    je FarProcExit
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
    jnz ThreeLoopStart  ;不为零则进入循环
    ;循环出口
    ;为0则处理一下
    mov cx,[tmpcx1] ;取回栈里的cx
    jmp LongNumPrintOutput
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
    push dx
    loop ThreeLoopStart

    mov cx,[tmpcx1]
    add si,2 ;增加偏移量
    loop LongParseLoop

ThreeLoopZero:
    mov dx,'0'
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
    