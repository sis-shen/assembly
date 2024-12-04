assume cs:codesg,ds:datasg,ss:stacksg

;初始化数据段，并填入数字
datasg segment
    buffer db 80 , 0 , 80 dup(0);第一个字节表示输入缓冲区大小为80，第二个为已写入的字符数量
    match db 'Match','$'
    noMatch db 'No Match!','$'
    enterKeyword db 'Enter keyword:','$'
    enterSentence db 'Enter sentence:' , '$'
    len_key db 0
    len_str db 0
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
    mov ax,0900h
    lea dx,enterKeyword
    int 21h

    mov ax,0A00h
    lea dx,buffer 
    int 21h

    mov al,[buffer+1]
    mov [len_key],al

    
    

loop_start:

    mov ax,4c00h
    int 21h


codesg ends
end start 