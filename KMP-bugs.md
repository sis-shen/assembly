1. 对字符输出不熟悉，对dx的调用出错

```
;错误代码
    mov ax,0200h
    lea dx,len_key
    int 21h

;正确代码
    mov ax,0200h
    mov dl,[len_key]
    int 21h
```