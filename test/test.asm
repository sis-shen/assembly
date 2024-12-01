assume cs:code,ds:data,ss:stack

code segment
    dw 0123h,0456h,0789h
start:  mov ax,0
        mov bx,0
        mov cx,3
    s:  add ax,cs:[bx]
        add bx,2
        loop s
        mov ax,4c00h ;完成函数，返回
        int 21h
code ends
end start