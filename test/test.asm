assume cs:code,ds:datasg

datasg segment
    num db 12 dup(0)

datasg ends

code segment
start:
    mov ax,datasg 
    mov ds,ax  
    
    mov ax,0fffh
    mov [num],ax

    mov bx,0
code ends
end start