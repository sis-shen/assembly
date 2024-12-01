assume cs:codesg,ds:datasg,ss:stacksg

;初始化数据段，并填入数字
datasg segment
    num dw 10h ;选择斐波那契数列的第num个数
    choose db 'Please choose a num from 1 to 100 : ','$'
    result db 'The result is : ','$'
    pressQ db 'Presss Q to exit','$'
    wrongRange db 'wrong range, try again'
    enter db 13, 10,'$'
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

    call Fib
    push ax ;暂存结果

    mov ah,09h
    lea dx,result
    int 21h

    pop ax
    call PrintNum

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

    dec ax    
    push ax     ;暂存 n - 1
    call Fib ;递归调用求Fib(n - 1); 规定Fib调用前后栈的状态不变
    ;下面几句顺序 有严格要求
    mov bx,ax  ;bx暂存数据
    pop ax      ;取出暂存的ax-1
    push bx     ;bx的内容存入栈内暂存
    dec ax    ; n - 2   ;后面就不用n了，所以就不保存了
    call Fib ;递归调用求Fib(n - 2)

    pop bx      ;取出暂存的bx的值
    add ax,bx   ;运算前ax = Fib(n-2), bx = Fib(n-1)
    ret 

FibBaseRet:
    ;Fib(1) = Fib(2) = 1
    mov ax,1    ;ax输出参数
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
;=========程序出口======
ProcExit:
    mov ax, 4c00h
    int 21h
codesg ends
end start 
    