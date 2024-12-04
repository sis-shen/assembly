1. 对中断指令不熟悉，把`mov ah`写成了`mov ax`,出现了如下报错

![](https://picbed0521.oss-cn-shanghai.aliyuncs.com/blogpic/202411271922654.webp)


3. 这段代码会影响整个程序
```
Fib:
    ;函数传参压栈
    push ax    
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
    ret 2

FibBaseRet:
    ;Fib(1) = Fib(2) = 1
    pop ax  ;参数出栈，防止栈空间浪费
    mov ax,1    ;ax输出参数
    ret 2
```

![](https://picbed0521.oss-cn-shanghai.aliyuncs.com/blogpic/202411280846874.webp)


原因：瞎用`ret 2`导致栈空间使用紊乱，程序乱跳转