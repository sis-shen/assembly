assume cs:codesg,ds:datasg,ss:stacksg

datasg segment



datasg ends

stacksg segment
    dd 10 dup (0)
stacksg ends  

codesg segment
s:mov ax,bx   
    mov si,offset s    
    mov di,offset s0   
    mov ax,codesg:si
    mov codesg:di,ax
s0:nop
    nop
codesg ends


; codesg segment
; start:  
;     mov ax,datasg
;     mov ds,ax 
;     mov ax,stacksg
;     mov ss,ax
;     add ax,10
;     mov sp,ax 
;     mov bx,0
;     mov cx,4 
; s0: push cx
;     mov si,3
;     mov cx,3  
; s1: mov al,[bx+3+si]
;     and al,11011111B
;     mov [bx+3+si],al  
;     inc si 
;     loop s1
;     pop cx  
;     add bx,16 
;     loop s0  
; codesg end
; ends start


; codesg segment
; start:  mov ax,datasg
;     mov ds,ax
;     mov ax,1000H
;     mov ss,ax
;     mov ax,1010H
;     mov cx 4
;     mov bx,0
; s:  mov dx,cx
;     mov cx,3
;     mov si,0
; m:  mov al,[bx+si]
;     and al,11011111B
;     mov [bx+si],al
;     inc si
;     loop m

;     mov bx,16
;     mov cx,dx
;     loop s 
; codesg ends
; end start