section .data
    p_ dq 0xbadb876f6ad78baf
       dq 0xea1fde9e99f9f180
       dq 0x0000000000000000
       dq 0x0000000000000000
    e  dq 0x10001
       dq 0x0000000000000000
       dq 0x0000000000000000
       dq 0x0000000000000000
 
section .bss
 
    
    a resb 64
    b resb 64
    c resb 64
    r resb 32        ;residuo
    temp1 resb 64
    temp2 resb 64
    n resb 32        ;P*Q
    phi resb 32      ;(P-1)*(Q-1)
    d resb 32        ;d = e-1 mod phi
    
    aphi resb 32
    be resb 32
    divT resb 32
    s resb 32
    s1 resb 32
    s2 resb 32
    t resb 32
    t1 resb 32
    t2 resb 32
    
    
    x resb 32
    y resb 32
    z resb 64
    res resb 32
    xTx resb 64
    resTx resb 64
    yand resb 32
    
    
    N resb 64
    D resb 64
    Q resb 64
    R resb 64        ;residuo
    
    
    c_ resb 32       ;c = m^e mod n
    m_ resb 32
section .text
    global main
main:
    mov rbp, rsp; for correct debugging
    
    mov rax, [p_]
    mov rbx, [p_+8]
    mov rcx, [p_+16]
    mov rdx, [p_+24]
    
    mov [N], rax
    mov [N+8], rbx
    mov [N+16], rcx
    mov [N+24], rdx
    mov [a], rax
    mov [a+8], rbx
    mov [a+16], rcx
    mov [a+24], rdx
    
    mov rax, [e]
    mov rbx, [e+8]
    mov rcx, [e+16]
    mov rdx, [e+24]
    
    mov [D], rax
    mov [D+8], rbx
    mov [D+16], rcx
    mov [D+24], rdx
    mov [b], rax
    mov [b+8], rbx
    mov [b+16], rcx
    mov [b+24], rdx
    
    call _div
    ;call _div64
    
    
    mov rax, 60
    mov rdi, 0
    syscall
    
    
    
_div:
    ;almaceno el Numerador en registros temporalmente
    mov rbx,[N]
    mov rcx,[N+8]
    mov rdx,[N+16]
    mov rsi,[N+24]
    
    ;almaceno datos en variable Q
    mov [Q],rbx
    mov [Q+8],rcx
    mov [Q+16],rdx
    mov [Q+24],rsi
    
    ;almaceno el Numerador en registros temporalmente
    mov rbx,[N+32]
    mov rcx,[N+40]
    mov rdx,[N+48]
    mov rsi,[N+56]
    
    ;almaceno datos en variable Q
    mov [Q+32],rbx
    mov [Q+40],rcx
    mov [Q+48],rdx
    mov [Q+56],rsi

    mov qword[R], 0
    mov qword[R+8], 0
    mov qword[R+16], 0
    mov qword[R+24], 0
    mov qword[R+32], 0
    mov qword[R+40], 0
    mov qword[R+48], 0
    mov qword[R+56], 0
 
    mov rcx, 512
    
_divLoop:
    shl qword[Q], 1
    rcl qword[Q+8],1
    rcl qword[Q+16],1
    rcl qword[Q+24],1
    rcl qword[Q+32],1
    rcl qword[Q+40],1
    rcl qword[Q+48],1
    rcl qword[Q+56],1
    rcl qword[R],1
    rcl qword[R+8],1
    rcl qword[R+16],1
    rcl qword[R+24],1
    rcl qword[R+32],1
    rcl qword[R+40],1
    rcl qword[R+48],1
    rcl qword[R+56],1
    
    mov rax, [R+56]
    cmp rax, [D+56]
    ja true
    jb false

    mov rax, [R+48]
    cmp rax, [D+48]
    ja true;
    jb false;
    
    mov rax, [R+40]
    cmp rax, [D+40]
    ja true;
    jb false;
    
    mov rax, [R+32]
    cmp rax, [D+32]
    ja true;
    jb false;
    
    mov rax, [R+24]
    cmp rax, [D+24]
    ja true;
    jb false;
    
    mov rax, [R+16]
    cmp rax, [D+16]
    ja true;
    jb false;
    
    mov rax, [R+8]
    cmp rax, [D+8]
    ja true;
    jb false;
    
    mov rax, [R]
    cmp rax, [D]
    jb false;    
true:
    mov rax, [D]
    sub [R], rax

    mov rax, [D+8]
    sbb [R+8], rax
    
    mov rax, [D+16]
    sbb [R+16], rax
    
    mov rax, [D+24]
    sbb [R+24], rax
    
    mov rax, [D+32]
    sbb [R+32], rax
    
    mov rax, [D+40]
    sbb [R+40], rax
    
    mov rax, [D+48]
    sbb [R+48], rax
    
    mov rax, [D+56]
    sbb [R+56], rax


    add qword[Q], 1
    adc qword[Q+8],0 
    adc qword[Q+16],0
    adc qword[Q+24],0
    adc qword[Q+32],0
    adc qword[Q+40],0
    adc qword[Q+48],0
    adc qword[Q+56],0
 
false:
    dec rcx
    cmp rcx, 0
    jne _divLoop
    ret    
    
    
    
_div64:
     mov rbx, [b]           ;divisor

     mov rdx, 0
     mov rax, [a+24]        ;EDX:EAX = number to divide
     div rbx
     mov [c+24], rax
    
     mov rax, [a+16]
     div rbx
     mov [c+16], rax
     
     mov rax, [a+8]
     div rbx
     mov [c+8], rax
    
     mov rax, [a]
     div rbx
     mov [c], rax
     
     mov [r], rdx           ;rdx contiene el residuo
     
     ret
     
_sum:
    mov rax, [b]
    add [a], rax
    mov rax, [b+8]
    adc [a+8], rax
    mov rax, [b+16]
    adc [a+16], rax
    mov rax, [b+24]
    adc [a+24], rax
    ret
    
_sub:
    mov rax, [b]
    sub [a], rbx
    mov rax, [b+8]
    sbb [a+8], rcx
    mov rax, [b+16]
    sbb [a+16], rcx
    mov rax, [b+24]
    sbb [a+24], rcx
    ret
    
    
_mul:
    ;a = [upper] [med_upper] [med_lower] [lower]
    ;b = [upper] [med_upper] [med_lower] [lower]
    ;1 b[lower] * a[lower]                                      1
    mov rax, [a]           ;RAX = a[lower]     
    mov rbx, [b]           ;RBX = b[lower]
    mul rbx                ;RDX:RAX = RAX*RBX 
    mov [temp1], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;2 b[lower] * a[med_lower]                                  1 
    mov rax, [a+8]    
    mul rbx                ;RDX:RAX = RAX*RBX     
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    adc rdx, 0
    mov [temp1+8], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;3 b[lower] * a[med_upper]                                  1
    mov rax, [a+16]    
    mul rbx                ;RDX:RAX = RAX*RBX     
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    adc rdx, 0
    mov [temp1+16], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;4 b[lower] * a[upper]                                      1
    mov rax, [a+24]    
    mul rbx                ;RDX:RAX = RAX*RBX     
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    mov [temp1+24], rax	  ;almaceno resultado
    ;sumo el carry de la multiplicacion a la posicion siguiente
    adc [temp1+32],rdx
    
    ;5 b[med_lower] * a[lower]                                  2                     
    mov rax, [a]           ;RAX = a[lower]    
    mov rbx, [b+8]         ;RBX = b[med_lower]
    mul rbx                ;RDX:RAX = RAX*RBX 
    mov [temp2+8], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;6 b[med_lower] * a[med_lower]                              2
    mov rax, [a+8]    
    mul rbx                ;RDX:RAX = RAX*RBX     
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    adc rdx, 0
    mov [temp2+16], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;7 b[med_lower] * a[med_upper]                              2
    mov rax, [a+16]    
    mul rbx                ;RDX:RAX = RAX*RBX     
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    adc rdx, 0
    mov [temp2+24], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;7 b[med_lower] * a[upper]                              2
    mov rax, [a+24]    
    mul rbx                ;RDX:RAX = RAX*RBX     
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    mov [temp2+32], rax	  ;almaceno resultado
    ;sumo el carry de la multiplicacion a la posicion siguiente
    adc [temp2+40], rdx
    
    ;8 c = temp 1 + temp 2
    mov rax, [temp1]
    add [temp2], rax
    mov rax, [temp1+8]
    adc [temp2+8], rax
    mov rax, [temp1+16]
    adc [temp2+16], rax
    mov rax, [temp1+24]
    adc [temp2+24], rax
    mov rax, [temp1+32]
    adc [temp2+32], rax
    mov rax, [temp1+40]
    adc [temp2+40], rax
    mov rax, [temp1+48]
    adc [temp2+48], rax
    mov rax, [temp1+56]
    adc [temp2+56], rax
    
    ;clean
    mov rax, 0
    mov [temp1], rax
    mov [temp1+8], rax
    mov [temp1+16], rax
    mov [temp1+24], rax
    mov [temp1+32], rax
    mov [temp1+40], rax
    mov [temp1+48], rax
    mov [temp1+56], rax
    
    ;9 b[med_upper] * a[lower]                                  3
    mov rax, [a]           ;RAX = a[lower]     
    mov rbx, [b+16]        ;RBX = b[med_upper]
    mul rbx                ;RDX:RAX = RAX*RBX 
    mov [temp1+16], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;10 b[med_upper] * a[med_lower]                             3
    mov rax, [a+8]    
    mul rbx                ;RDX:RAX = RAX*RBX     
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    adc rdx, 0
    mov [temp1+24], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;10 b[med_upper] * a[med_upper]                             3
    mov rax, [a+16]    
    mul rbx                ;RDX:RAX = RAX*RBX     
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    adc rdx, 0
    mov [temp1+32], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;10 b[med_upper] * a[upper]                             3
    mov rax, [a+24]    
    mul rbx                ;RDX:RAX = RAX*RBX     
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    mov [temp1+40], rax	  ;almaceno resultado
    ;muevo el carry de la multiplicacion a la posicion siguiente
    adc [temp1+48], rdx
    
    
    ;11 c = temp 1 + temp 2
    mov rax, [temp1]
    add [temp2], rax
    mov rax, [temp1+8]
    adc [temp2+8], rax
    mov rax, [temp1+16]
    adc [temp2+16], rax
    mov rax, [temp1+24]
    adc [temp2+24], rax
    mov rax, [temp1+32]
    adc [temp2+32], rax
    mov rax, [temp1+40]
    adc [temp2+40], rax
    mov rax, [temp1+48]
    adc [temp2+48], rax
    mov rax, [temp1+56]
    adc [temp2+56], rax
    
    ;clean
    mov rax, 0
    mov [temp1], rax
    mov [temp1+8], rax
    mov [temp1+16], rax
    mov [temp1+24], rax
    mov [temp1+32], rax
    mov [temp1+40], rax
    mov [temp1+48], rax
    mov [temp1+56], rax
    
    ;12 b[upper] * a[lower]                                 4
    mov rax, [a]           ;RAX = a[lower]     
    mov rbx, [b+24]        ;RBX = b[upper] 
    mul rbx                ;RDX:RAX = RAX*RBX 
    mov [temp1+24], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;12 b[upper] * a[med_lower]                                 4
    mov rax, [a+8]           ;RAX = a[lower]     
    mul rbx                ;RDX:RAX = RAX*RBX
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    adc rdx, 0 
    mov [temp1+32], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;12 b[upper] * a[med_upper]                                 4
    mov rax, [a+16]           ;RAX = a[lower]    
    mul rbx                ;RDX:RAX = RAX*RBX 
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    adc rdx, 0
    mov [temp1+40], rax	  ;almaceno resultado
    mov rcx, rdx           ;almaceno el carry en RCX
    ;12 b[upper] * a[upper]                                 4
    mov rax, [a+24]           ;RAX = a[lower]  
    mul rbx                ;RDX:RAX = RAX*RBX 
    add rax, rcx           ;sumo el carry a la multiplicacion pasada
    mov [temp1+48], rax	  ;almaceno resultado
    ;muevo el carry de la multiplicacion a la posicion siguiente
    adc [temp1+56], rdx
    
    ;13 c = temp 1 + temp 2
    mov rax, [temp1]
    add [temp2], rax
    mov rax, [temp1+8]
    adc [temp2+8], rax
    mov rax, [temp1+16]
    adc [temp2+16], rax
    mov rax, [temp1+24]
    adc [temp2+24], rax
    mov rax, [temp1+32]
    adc [temp2+32], rax
    mov rax, [temp1+40]
    adc [temp2+40], rax
    mov rax, [temp1+48]
    adc [temp2+48], rax
    mov rax, [temp1+56]
    adc [temp2+56], rax
    
    ;almaceno temp2 en registros temporalmente
    mov rbx,[temp2]
    mov rcx,[temp2+8]
    mov rdx,[temp2+16]
    mov rsi,[temp2+24]
    
    ;almaceno datos en variable c
    mov [c],rbx
    mov [c+8],rcx
    mov [c+16],rdx
    mov [c+24],rsi
    
    ;almaceno temp2 en registros temporalmente
    mov rbx,[temp2+32]
    mov rcx,[temp2+40]
    mov rdx,[temp2+48]
    mov rsi,[temp2+56]
    
    ;almaceno datos en variable c
    mov [c+32],rbx
    mov [c+40],rcx
    mov [c+48],rdx
    mov [c+56],rsi
    
    call _cleanTemp
    
    ret
       
;       
;   Clean Variables       
;               
_cleanTemp:
    ;reseteo temp1 y temp2 en 0
    mov rax, 0
    mov [temp1],rax
    mov [temp1+8],rax
    mov [temp1+16],rax
    mov [temp1+24],rax
    mov [temp1+32],rax
    mov [temp1+40],rax
    mov [temp1+48],rax
    mov [temp1+56],rax
    mov [temp2],rax
    mov [temp2+8],rax
    mov [temp2+16],rax
    mov [temp2+24],rax
    mov [temp2+32],rax
    mov [temp2+40],rax
    mov [temp2+48],rax
    mov [temp2+56],rax
    ret
_cleanab:
    ;reseteo temp1 y temp2 en 0
    mov rax, 0
    mov [a],rax
    mov [a+8],rax
    mov [a+16],rax
    mov [a+24],rax
    mov [a+32],rax
    mov [a+40],rax
    mov [a+48],rax
    mov [a+56],rax
    mov [b],rax
    mov [b+8],rax
    mov [b+16],rax
    mov [b+24],rax
    mov [b+32],rax
    mov [b+40],rax
    mov [b+48],rax
    mov [b+56],rax
    ret      