;Made by Christopher Arredondo-Fallas
extern	printf
section .data
    textIntro db "Bienvenido al algoritmo de encriptacion RSA",10
    textIntro2 db "Que desea hacer?",10
    textIngresarllaves db "1) Ingresar llaves",10
    textGenerarllaves db "2) Generar llaves",10
    textIngresarMensaje db 10,"Por favor ingresar un texto de maximo 32 Characteres: "
    textIngresar_n db "Digitar llave publica n este tiene que ser de 32 bytes o 64 caracteres: "
    textIngresar_d db "Digitar llave privada d este tiene que ser de 32 bytes o 64 caracteres: "
    textIngresar_p db "Digitar numero primo p este tiene que ser de 16 bytes o 32 caracteres: "
    textIngresar_q db "Digitar numero primo q este tiene que ser de 16 bytes o 32 caracteres: "
    textMostrar_n db 10,"Llave publica n: "
    textMostrar_d db 10,"Llave privada d: ", 10
    textMostrar_p db "Llave publica p: "
    textMostrar_q db 10,"Llave privada q: "
    textMostrar_e db 10,"Se toma e=65537",10
    textCript db 10,"Desea 1) encriptar o 2) desencriptar?",10
    textIngresarCif db "Por favor ingresar el texto cifrado: "
    textMostrarMenHex db "Su mensaje en hex es: "
    textMostrarMen db "Su mensaje es: "
    textMostrarCif db 10,"Su texto cifrado es: "
    space db " ",10 
    
    p  dq 0xbadb876f6ad78baf
       dq 0xea1fde9e99f9f180
       dq 0x0000000000000000
       dq 0x0000000000000000
    q  dq 0x17fa77a1a912219f
       dq 0xbeea97ac3d6be309
       dq 0x0000000000000000
       dq 0x0000000000000000
    e  dq 0x10001
       dq 0x0000000000000000
       dq 0x0000000000000000
       dq 0x0000000000000000
 
section .bss
    option resb 2
    digitSpace resb 100
    digitSpacePos resb 8
    temp resb 64
    
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
    m_ resb 32       ;m = c^d mod n
    p_ resb 32
    q_ resb 32
 
section .text
    global main
main:
    mov rbp, rsp; for correct debugging
 
    ;call _generarllaves
    call _Intro
    call _option
 
    mov rax, 60
    mov rdi, 0
    syscall
 

 
_Intro:
    mov rax, 1
    mov rdi, 1
    mov rsi, textIntro
    mov rdx, 44
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, textIntro2
    mov rdx, 17
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, textIngresarllaves
    mov rdx, 19
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, textGenerarllaves
    mov rdx, 18
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, option
    mov rdx, 2
    syscall
    ret
_option:
    cmp byte[option], 50
    je _generarllaves 
    cmp byte[option], 49
    je _ingresarllaves 
    ret
_generarllaves:
    
    ;muestro e
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrar_e
    mov rdx, 17
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, textIngresar_p
    mov rdx, 71
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, temp
    mov rdx, 65
    syscall
    ;lo convierto a hex
    call _convertASCII
    mov qword[temp],0
    mov qword[temp+8],0
    mov qword[temp+16],0
    mov qword[temp+24],0
    ;lo guardo en su variable respectiva
    mov rax, [c_]
    mov [p_], rax
    mov rax, [c_+8]
    mov [p_+8], rax
    mov qword[c_],0
    mov qword[c_+8],0
    mov qword[c_+16],0
    mov qword[c_+24],0
    
    mov rax, 1
    mov rdi, 1
    mov rsi, textIngresar_q
    mov rdx, 71
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, temp
    mov rdx, 65
    syscall
    ;lo convierto a hex
    call _convertASCII
    mov qword[temp],0
    mov qword[temp+8],0
    mov qword[temp+16],0
    mov qword[temp+24],0
    ;lo guardo en su variable respectiva
    mov rax, [c_]
    mov [q_], rax
    mov rax, [c_+8]
    mov [q_+8], rax
    mov qword[c_],0
    mov qword[c_+8],0
    mov qword[c_+16],0
    mov qword[c_+24],0
    
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrar_p
    mov rdx, 17
    syscall
    
    mov r14, p_
    call _printIterator
    
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrar_q
    mov rdx, 18
    syscall 
    
    mov r14, q_
    call _printIterator
    
    ;Generamos las llaves
    call _n
    call _phi
    call _d
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrar_n
    mov rdx, 18
    syscall
    
    mov r14, n
    call _printIterator
    
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrar_d
    mov rdx, 18
    syscall 
    
    mov r14, d
    call _printIterator
        
    jmp _cript
    ret
    
_ingresarllaves:
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrar_e
    mov rdx, 17
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, textIngresar_n
    mov rdx, 72
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, temp
    mov rdx, 65
    syscall
    ;lo convierto a hex
    call _convertASCII
    mov qword[temp],0
    mov qword[temp+8],0
    mov qword[temp+16],0
    mov qword[temp+24],0
    ;lo guardo en su variable respectiva
    mov rax, [c_]
    mov [n], rax
    mov rax, [c_+8]
    mov [n+8], rax
    mov rax, [c_+16]
    mov [n+16], rax
    mov rax, [c_+24]
    mov [n+24], rax
    mov qword[c_],0
    mov qword[c_+8],0
    mov qword[c_+16],0
    mov qword[c_+24],0
    
    mov rax, 1
    mov rdi, 1
    mov rsi, textIngresar_d
    mov rdx, 72
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, temp
    mov rdx, 65
    syscall
    ;lo convierto a hex
    call _convertASCII
    mov qword[temp],0
    mov qword[temp+8],0
    mov qword[temp+16],0
    mov qword[temp+24],0
    ;lo guardo en su variable respectiva
    mov rax, [c_]
    mov [d], rax
    mov rax, [c_+8]
    mov [d+8], rax
    mov rax, [c_+16]
    mov [d+16], rax
    mov rax, [c_+24]
    mov [d+24], rax
    mov qword[c_],0
    mov qword[c_+8],0
    mov qword[c_+16],0
    mov qword[c_+24],0
    
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrar_n
    mov rdx, 18
    syscall
    
    mov r14, n
    call _printIterator
    
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrar_d
    mov rdx, 18
    syscall 
    
    mov r14, d
    call _printIterator
    
    jmp _cript
    ret
    
_cript:
    mov rax, 1
    mov rdi, 1
    mov rsi, textCript
    mov rdx, 39
    syscall
    mov rax, 0
    mov rdi, 0
    mov rsi, option
    mov rdx, 2
    syscall
    cmp byte[option], 50
    je _desencriptar 
    cmp byte[option], 49
    je _encriptar 
    ret
_encriptar:
    ;solicito mensaje
    mov rax, 1
    mov rdi, 1
    mov rsi, textIngresarMensaje
    mov rdx, 55
    syscall
    ;obtengo mensaje
    mov rax, 0
    mov rdi, 0
    mov rsi, m_
    mov rdx, 32
    syscall
    ;imprimo texto
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrarMenHex
    mov rdx, 22
    syscall
    ;imprmio mensaje en hex
    mov r14, m_
    call _printIterator
    ;llamamos la funcion para encriptar
    call _c
    ;texto cifrado
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrarCif
    mov rdx, 22
    syscall
    ;lo muestro
    mov r14, c_
    call _printIterator
    
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 2
    syscall
    
    ret


_desencriptar:
    ;solicito texto cifrado
    mov rax, 1
    mov rdi, 1
    mov rsi, textIngresarCif
    mov rdx, 37
    syscall
    ;obtengo cifrado
    mov rax, 0
    mov rdi, 0
    mov rsi, temp
    mov rdx, 64
    syscall
    call _convertASCII
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 2
    syscall
    ;imprimo texto cifrado
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrarCif
    mov rdx, 22
    syscall
    ;lo muestro
    mov r14, c_
    call _printIterator
    mov rax, 1
    mov rdi, 1
    mov rsi, space
    mov rdx, 2
    syscall
    ;llamamos la funcion para desencriptar
    call _m
    mov rax, 1
    mov rdi, 1
    mov rsi, textMostrarMen
    mov rdx, 15
    syscall
    mov rax, 1
    mov rdi, 1
    mov rsi, m_
    mov rdx, 32
    syscall
    ret
;
;   Ingreso ASCII
;
_convertASCII:
    mov r14, temp
    mov r15, temp
    add r15, 64  ;ya que son 64 bytes
    call _inputASCIItoHex
    ret
_inputASCIItoHex:
    mov rax, [r14]
    cmp al, 57
    jle _numbers
    jmp _letters

_numbers:
    sub al, 48
    add [c_],al
    jmp _shift
_letters:
    sub al, 87
    add [c_],al
    jmp _shift
_shift:
    inc r14
    mov rax, [r14]
    cmp al, 0
    je _end
    cmp al, 0xa
    je _end
    shl qword[c_],1
    rcl qword[c_+8],1
    rcl qword[c_+16],1
    rcl qword[c_+24],1
    shl qword[c_],1
    rcl qword[c_+8],1
    rcl qword[c_+16],1
    rcl qword[c_+24],1
    shl qword[c_],1
    rcl qword[c_+8],1
    rcl qword[c_+16],1
    rcl qword[c_+24],1
    shl qword[c_],1
    rcl qword[c_+8],1
    rcl qword[c_+16],1
    rcl qword[c_+24],1
    
    jmp _inputASCIItoHex
_end:
    ret
;
;       Impresion Hex
;
_printIterator:
    ;mov rax, [variablePos+24]
    add r14, 24
    mov r15, 0
    mov rax, [r14]
    call _print256HEX
    sub r14, 8
    mov r15, 0
    mov rax, [r14]
    call _print256HEX
    sub r14, 8
    mov r15, 0
    mov rax, [r14]
    call _print256HEX
    sub r14, 8
    mov r15, 0
    mov rax, [r14]
    call _print256HEX
    ret 
_print256HEX:
    cmp qword[r14], 0
    je _end
    mov rcx, digitSpace
    mov [digitSpacePos], rcx
 
_print256HEXLoop:
    mov rdx, 0
    mov rbx, 16
    div rbx
    push rax
    cmp rdx, 9
    jg _ABCDE
    add rdx, 48
_rest: 
    mov rcx, [digitSpacePos]
    mov [rcx], dl
    inc rcx
    inc r15
    mov [digitSpacePos], rcx
   
    pop rax
    ;cmp rax,0
    cmp r15, 16
    
    jne _print256HEXLoop
    jmp _print256HEXLoop2
_ABCDE:
    add rdx, 87
    jmp _rest
 
_print256HEXLoop2:
    
    mov rcx, [digitSpacePos]
    dec rcx
    mov [digitSpacePos], rcx
 
    mov rax, 1
    mov rdi, 1
    mov rsi, rcx
    mov rdx, 1
    syscall
 
    mov rcx, [digitSpacePos]
    
 
    cmp rcx, digitSpace
    jg _print256HEXLoop2
 
    ret
;-------------------------------------------------------------------   
;                                                                   |
;                           RSA Algorithm                           |
;                                                                   |
;-------------------------------------------------------------------
;       
;   m calculator  c^d mod n   
;
_m:
    ;almaceno y en registros temporalmente
    mov rbx,[c_]
    mov rcx,[c_+8]
    mov rdx,[c_+16]
    mov rsi,[c_+24]
    
    ;almaceno datos en variable yand
    mov [x],rbx
    mov [x+8],rcx
    mov [x+16],rdx
    mov [x+24],rsi
    
    ;almaceno y en registros temporalmente
    mov rbx,[d]
    mov rcx,[d+8]
    mov rdx,[d+16]
    mov rsi,[d+24]
    
    ;almaceno datos en variable yand
    mov [y],rbx
    mov [y+8],rcx
    mov [y+16],rdx
    mov [y+24],rsi
    
    ;almaceno y en registros temporalmente
    mov rbx,[n]
    mov rcx,[n+8]
    mov rdx,[n+16]
    mov rsi,[n+24]
    
    ;almaceno datos en variable yand
    mov [z],rbx
    mov [z+8],rcx
    mov [z+16],rdx
    mov [z+24],rsi
    
    
    call _power
    
    ;almaceno y en registros temporalmente
    mov rbx,[res]
    mov rcx,[res+8]
    mov rdx,[res+16]
    mov rsi,[res+24]
    
    ;almaceno datos en variable yand
    mov [m_],rbx
    mov [m_+8],rcx
    mov [m_+16],rdx
    mov [m_+24],rsi
    
    ret
;       
;   c calculator  m^e mod n   
;
_c:
    ;almaceno y en registros temporalmente
    mov rbx,[m_]
    mov rcx,[m_+8]
    mov rdx,[m_+16]
    mov rsi,[m_+24]
    
    ;almaceno datos en variable yand
    mov [x],rbx
    mov [x+8],rcx
    mov [x+16],rdx
    mov [x+24],rsi
    
    ;almaceno y en registros temporalmente
    mov rbx,[e]
    mov rcx,[e+8]
    mov rdx,[e+16]
    mov rsi,[e+24]
    
    ;almaceno datos en variable yand
    mov [y],rbx
    mov [y+8],rcx
    mov [y+16],rdx
    mov [y+24],rsi
    
    ;almaceno y en registros temporalmente
    mov rbx,[n]
    mov rcx,[n+8]
    mov rdx,[n+16]
    mov rsi,[n+24]
    
    ;almaceno datos en variable yand
    mov [z],rbx
    mov [z+8],rcx
    mov [z+16],rdx
    mov [z+24],rsi
    
    
    call _power
    
    ;almaceno y en registros temporalmente
    mov rbx,[res]
    mov rcx,[res+8]
    mov rdx,[res+16]
    mov rsi,[res+24]
    
    ;almaceno datos en variable yand
    mov [c_],rbx
    mov [c_+8],rcx
    mov [c_+16],rdx
    mov [c_+24],rsi
    
    ret

;       
;   Power modulus algorithm x^y mod z       
;
_power:
    mov qword[res], 1
    mov qword[res+8], 0
    mov qword[res+16], 0
    mov qword[res+24], 0
    
    call _powerLoop
    
    ret
    
          
_powerLoop:
    ;almaceno y en registros temporalmente
    mov rbx,[y]
    mov rcx,[y+8]
    mov rdx,[y+16]
    mov rsi,[y+24]
    
    ;almaceno datos en variable yand
    mov [yand],rbx
    mov [yand+8],rcx
    mov [yand+16],rdx
    mov [yand+24],rsi
    
    mov rax, 1
    and [yand], rax
    
    cmp [yand], rax
    je odd
even:    
    ;shift right
    shr qword[y+24], 1
    rcr qword[y+16], 1
    rcr qword[y+8], 1
    rcr qword[y], 1
    
    ;almaceno x en registros temporalmente
    mov rbx,[x]
    mov rcx,[x+8]
    mov rdx,[x+16]
    mov rsi,[x+24]
    
    ;almaceno datos en variable a
    mov [a],rbx
    mov [a+8],rcx
    mov [a+16],rdx
    mov [a+24],rsi
    
    ;almaceno datos en variable b
    mov [b],rbx
    mov [b+8],rcx
    mov [b+16],rdx
    mov [b+24],rsi
    
    call _mul
    
    ;almaceno x en registros temporalmente
    mov rbx,[c]
    mov rcx,[c+8]
    mov rdx,[c+16]
    mov rsi,[c+24]
    
    ;almaceno datos en variable a
    mov [xTx],rbx
    mov [xTx+8],rcx
    mov [xTx+16],rdx
    mov [xTx+24],rsi
    
    ;almaceno x en registros temporalmente
    mov rbx,[c+32]
    mov rcx,[c+40]
    mov rdx,[c+48]
    mov rsi,[c+56]
    
    ;almaceno datos en variable a
    mov [xTx+32],rbx
    mov [xTx+40],rcx
    mov [xTx+48],rdx
    mov [xTx+56],rsi
    
    ;aqui saco el residuo
    ;almaceno xTx en registros temporalmente
    mov rbx,[xTx]
    mov rcx,[xTx+8]
    mov rdx,[xTx+16]
    mov rsi,[xTx+24]
    
    ;almaceno datos en variable N
    mov [N],rbx
    mov [N+8],rcx
    mov [N+16],rdx
    mov [N+24],rsi
    
    ;almaceno xTx en registros temporalmente
    mov rbx,[xTx+32]
    mov rcx,[xTx+40]
    mov rdx,[xTx+48]
    mov rsi,[xTx+56]
    
    ;almaceno datos en variable N
    mov [N+32],rbx
    mov [N+40],rcx
    mov [N+48],rdx
    mov [N+56],rsi
    ;falta upper part
    ;almaceno z en registros temporalmente
    mov rbx,[z]
    mov rcx,[z+8]
    mov rdx,[z+16]
    mov rsi,[z+24]
    
    ;almaceno datos en variable D
    mov [D],rbx
    mov [D+8],rcx
    mov [D+16],rdx
    mov [D+24],rsi
    
    call _div
    
    ;almaceno el Residuo en registros temporalmente
    mov rbx,[R]
    mov rcx,[R+8]
    mov rdx,[R+16]
    mov rsi,[R+24]
    
    ;almaceno datos en variable x
    mov [x],rbx
    mov [x+8],rcx
    mov [x+16],rdx
    mov [x+24],rsi
    
    ;aqui comparo con 0 osea y > 0
    cmp qword[y+24], 0
    ja _powerLoop;
    jb end;
    
    cmp qword[y], 0
    ja _powerLoop
    
    cmp qword[y+8], 0
    ja _powerLoop;
    
    cmp qword[y+16], 0
    ja _powerLoop;
end:    
    ret    
odd:
    ;almaceno res en registros temporalmente
    mov rbx,[res]
    mov rcx,[res+8]
    mov rdx,[res+16]
    mov rsi,[res+24]
    
    ;almaceno datos en variable a
    mov [a],rbx
    mov [a+8],rcx
    mov [a+16],rdx
    mov [a+24],rsi
    
    
    ;almaceno x en registros temporalmente
    mov rbx,[x]
    mov rcx,[x+8]
    mov rdx,[x+16]
    mov rsi,[x+24]
    
    ;almaceno datos en variable b
    mov [b],rbx
    mov [b+8],rcx
    mov [b+16],rdx
    mov [b+24],rsi
    
    call _mul   
    
             
    ;almaceno x en registros temporalmente
    mov rbx,[c]
    mov rcx,[c+8]
    mov rdx,[c+16]
    mov rsi,[c+24]
    
    ;almaceno datos en variable a
    mov [resTx],rbx
    mov [resTx+8],rcx
    mov [resTx+16],rdx
    mov [resTx+24],rsi 
    
    ;almaceno x en registros temporalmente
    mov rbx,[c+32]
    mov rcx,[c+40]
    mov rdx,[c+48]
    mov rsi,[c+56]
    
    ;almaceno datos en variable a
    mov [resTx+32],rbx
    mov [resTx+40],rcx
    mov [resTx+48],rdx
    mov [resTx+56],rsi  
    
    ; x = resTx % z
    ;almaceno resTx en registros temporalmente
    mov rbx,[resTx]
    mov rcx,[resTx+8]
    mov rdx,[resTx+16]
    mov rsi,[resTx+24]
    
    ;almaceno datos en variable N
    mov [N],rbx
    mov [N+8],rcx
    mov [N+16],rdx
    mov [N+24],rsi
    
    ;almaceno resTx en registros temporalmente
    mov rbx,[resTx+32]
    mov rcx,[resTx+40]
    mov rdx,[resTx+48]
    mov rsi,[resTx+56]
    
    ;almaceno datos en variable N
    mov [N+32],rbx
    mov [N+40],rcx
    mov [N+48],rdx
    mov [N+56],rsi
    
    ;almaceno z en registros temporalmente
    mov rbx,[z]
    mov rcx,[z+8]
    mov rdx,[z+16]
    mov rsi,[z+24]
    
    ;almaceno datos en variable D
    mov [D],rbx
    mov [D+8],rcx
    mov [D+16],rdx
    mov [D+24],rsi
    
    call _div
    
    ;almaceno el Residuo en registros temporalmente
    mov rbx,[R]
    mov rcx,[R+8]
    mov rdx,[R+16]
    mov rsi,[R+24]
    
    ;almaceno datos en variable x
    mov [res],rbx
    mov [res+8],rcx
    mov [res+16],rdx
    mov [res+24],rsi
           
    jmp even
;       
;   d calculation  1/e mod phi
;                     
_d:
    
    
    call _egcd
    
    ;almaceno c en registros temporalmente
    mov rbx,[t1]
    mov rcx,[t1+8]
    mov rdx,[t1+16]
    mov rsi,[t1+24]
    
    ;almaceno datos en variable n
    mov [d],rbx
    mov [d+8],rcx
    mov [d+16],rdx
    mov [d+24],rsi
    
    ;limpiar variables
    call _cleanab
    
    ret
    
;       
;   Extended Euclidean algorithm to calculate d      
;   
_egcd:
    ;almaceno 1 en registros temporalmente
    mov rbx,1
    mov rcx,0
    
    ;almaceno 1 en variable s1 y t2 
    mov [s1],rbx
    mov [s1+8],rcx
    mov [s1+16],rcx
    mov [s1+24],rcx
    mov [t2],rbx
    mov [t2+8],rcx
    mov [t2+16],rcx
    mov [t2+24],rcx
    
    ;almaceno 0 en registro temporalmente
    mov rbx,0
    
    ;almaceno datos en variable s2 y t1
    mov [s2],rbx
    mov [s2+8],rbx
    mov [s2+16],rbx
    mov [s2+24],rbx
    mov [t1],rbx
    mov [t1+8],rbx
    mov [t1+16],rbx
    mov [t1+24],rbx
    
    ;--------------------------------------
    ;almaceno phi temporalmente en registros
    mov rbx,[phi]
    mov rcx,[phi+8]
    mov rdx,[phi+16]
    mov rsi,[phi+24]
    
    ;almaceno datos en variable aphi
    mov [aphi],rbx
    mov [aphi+8],rcx
    mov [aphi+16],rdx
    mov [aphi+24],rsi
    
    ;--------------------------------------
    ;almaceno e temporalmente en registros
    mov rbx,[e]
    mov rcx,0
    mov rdx,0
    mov rsi,0
    
    ;almaceno datos en variable be
    mov [be],rbx
    mov [be+8],rcx
    mov [be+16],rdx
    mov [be+24],rsi
    
    call _egcdLoop
    
    mov rax,0
    cmp [t1+24], rax
    jl _fix
    ;almaceno t1 temporalmente en registros
    mov rbx,[t1]
    mov rcx,[t1+8]
    mov rdx,[t1+16]
    mov rsi,[t1+24]
    
    ;almaceno datos en variable phi
    mov [d],rbx
    mov [d+8],rcx
    mov [d+16],rdx
    mov [d+24],rsi
    
    ret

_egcdLoop:
    ;almaceno aphi temporalmente en registros
    mov rbx,[aphi]
    mov rcx,[aphi+8]
    mov rdx,[aphi+16]
    mov rsi,[aphi+24]
    
    ;almaceno datos en variable a
    mov [a],rbx
    mov [a+8],rcx
    mov [a+16],rdx
    mov [a+24],rsi
    
    ;--------------------------------------
    ;almaceno be temporalmente en registros
    mov rbx,[be]
    mov rcx,[be+8]
    mov rdx,[be+16]
    mov rsi,[be+24]
    
    ;almaceno datos en variable b
    mov [b],rbx
    mov [b+8],rcx
    mov [b+16],rdx
    mov [b+24],rsi
    
    call _div64
    
    ;--------------------------------------
    ;almaceno c temporalmente en registros
    mov rbx,[c]
    mov rcx,[c+8]
    mov rdx,[c+16]
    mov rsi,[c+24]
    
    ;almaceno datos en variable divT
    mov [divT],rbx
    mov [divT+8],rcx
    mov [divT+16],rdx
    mov [divT+24],rsi
    
    ;--------------------------------------
    ;almaceno be temporalmente en registros
    mov rbx,[be]
    mov rcx,[be+8]
    mov rdx,[be+16]
    mov rsi,[be+24]
    
    ;almaceno datos en variable aphi
    mov [aphi],rbx
    mov [aphi+8],rcx
    mov [aphi+16],rdx
    mov [aphi+24],rsi
    
    ;--------------------------------------
    ;almaceno r temporalmente en registros
    mov rbx,[r]
    mov rcx,[r+8]
    mov rdx,[r+16]
    mov rsi,[r+24]
    
    ;almaceno datos en variable be
    mov [be],rbx
    mov [be+8],rcx
    mov [be+16],rdx
    mov [be+24],rsi
    
    ;--------------------------------------
    ;almaceno s1 temporalmente en registros
    mov rbx,[s1]
    mov rcx,[s1+8]
    mov rdx,[s1+16]
    mov rsi,[s1+24]
    
    ;almaceno datos en variable s
    mov [s],rbx
    mov [s+8],rcx
    mov [s+16],rdx
    mov [s+24],rsi
    
    ;--------------------------------------
    ;almaceno divT temporalmente en registros
    mov rbx,[divT]
    mov rcx,[divT+8]
    mov rdx,[divT+16]
    mov rsi,[divT+24]
    
    ;almaceno datos en variable a
    mov [a],rbx
    mov [a+8],rcx
    mov [a+16],rdx
    mov [a+24],rsi
    
    ;--------------------------------------
    ;almaceno s2 temporalmente en registros
    mov rbx,[s2]
    mov rcx,[s2+8]
    mov rdx,[s2+16]
    mov rsi,[s2+24]
    
    ;almaceno datos en variable b
    mov [b],rbx
    mov [b+8],rcx
    mov [b+16],rdx
    mov [b+24],rsi
    
    ;--------------------------------------
    call _mul
    
    mov rax, [c]
    sub [s], rax
    mov rax, [c+8]
    sbb [s+8], rax
    mov rax, [c+16]
    sbb [s+16], rax
    mov rax, [c+24]
    sbb [s+24], rax
    
    ;--------------------------------------
    ;almaceno s2 temporalmente en registros
    mov rbx,[s2]
    mov rcx,[s2+8]
    mov rdx,[s2+16]
    mov rsi,[s2+24]
    
    ;almaceno datos en variable s1
    mov [s1],rbx
    mov [s1+8],rcx
    mov [s1+16],rdx
    mov [s1+24],rsi
    
    ;--------------------------------------
    ;almaceno s temporalmente en registros
    mov rbx,[s]
    mov rcx,[s+8]
    mov rdx,[s+16]
    mov rsi,[s+24]
    
    ;almaceno datos en variable s2
    mov [s2],rbx
    mov [s2+8],rcx
    mov [s2+16],rdx
    mov [s2+24],rsi
    
    ;--------------------------------------
    ;almaceno t1 temporalmente en registros
    mov rbx,[t1]
    mov rcx,[t1+8]
    mov rdx,[t1+16]
    mov rsi,[t1+24]
    
    ;almaceno datos en variable s
    mov [t],rbx
    mov [t+8],rcx
    mov [t+16],rdx
    mov [t+24],rsi
    
    ;--------------------------------------
    ;almaceno divT temporalmente en registros
    mov rbx,[divT]
    mov rcx,[divT+8]
    mov rdx,[divT+16]
    mov rsi,[divT+24]
    
    ;almaceno datos en variable a
    mov [a],rbx
    mov [a+8],rcx
    mov [a+16],rdx
    mov [a+24],rsi
    
    ;--------------------------------------
    ;almaceno t2 temporalmente en registros
    mov rbx,[t2]
    mov rcx,[t2+8]
    mov rdx,[t2+16]
    mov rsi,[t2+24]
    
    ;almaceno datos en variable b
    mov [b],rbx
    mov [b+8],rcx
    mov [b+16],rdx
    mov [b+24],rsi
    
    ;--------------------------------------
    call _mul
    
    mov rax, [c]
    sub [t], rax
    mov rax, [c+8]
    sbb [t+8], rax
    mov rax, [c+16]
    sbb [t+16], rax
    mov rax, [c+24]
    sbb [t+24], rax
    
    ;--------------------------------------
    ;almaceno t2 temporalmente en registros
    mov rbx,[t2]
    mov rcx,[t2+8]
    mov rdx,[t2+16]
    mov rsi,[t2+24]
    
    ;almaceno datos en variable t1
    mov [t1],rbx
    mov [t1+8],rcx
    mov [t1+16],rdx
    mov [t1+24],rsi
    
    ;--------------------------------------
    ;almaceno t temporalmente en registros
    mov rbx,[t]
    mov rcx,[t+8]
    mov rdx,[t+16]
    mov rsi,[t+24]
    
    ;almaceno datos en variable t2
    mov [t2],rbx
    mov [t2+8],rcx
    mov [t2+16],rdx
    mov [t2+24],rsi
    
    mov rax, 0
    cmp [be], rax
    jne _egcdLoop
    
    ret
       
_fix:
    mov rax, [phi]
    add [t1], rax
    mov rax, [phi+8]
    adc [t1+8], rax
    mov rax, [phi+16]
    adc [t1+16], rax
    mov rax, [phi+24]
    adc [t1+24], rax
    ret
;       
;   n calculation (P*Q)       
;     
_n:
    ;almaceno p en registros temporalmente
    mov rbx,[p_]
    mov rcx,[p_+8]
    mov rdx,[p_+16]
    mov rsi,[p_+24]
    
    ;almaceno datos en variable a
    mov [a],rbx
    mov [a+8],rcx
    mov [a+16],rdx
    mov [a+24],rsi
    
    ;almaceno q en registros temporalmente
    mov rbx,[q_]
    mov rcx,[q_+8]
    mov rdx,[q_+16]
    mov rsi,[q_+24]
    
    ;almaceno datos en variable b
    mov [b],rbx
    mov [b+8],rcx
    mov [b+16],rdx
    mov [b+24],rsi
    
    call _mul
    
    ;almaceno c en registros temporalmente
    mov rbx,[c]
    mov rcx,[c+8]
    mov rdx,[c+16]
    mov rsi,[c+24]
    
    ;almaceno datos en variable n
    mov [n],rbx
    mov [n+8],rcx
    mov [n+16],rdx
    mov [n+24],rsi
    
    ;limpiar variables
    call _cleanab
    
    ret
;       
;   phi calculation  (p-1)*(q-1)     
; 
_phi:
    mov rbx,[p_]
    mov rcx,[p_+8]
    mov rdx,[p_+16]
    mov rsi,[p_+24]

    mov [a],rbx
    mov [a+8],rcx
    mov [a+16],rdx
    mov [a+24],rsi
    
    mov rbx,[q_]
    mov rcx,[q_+8]
    mov rdx,[q_+16]
    mov rsi,[q_+24]

    mov [b],rbx
    mov [b+8],rcx
    mov [b+16],rdx
    mov [b+24],rsi
    
    mov rbx, 1
    mov rcx, 0
    ;p-1
    sub [a], rbx
    mov rax, [a+8]
    sbb [a+8], rcx
    mov rax, [a+16]
    sbb [a+16], rcx
    mov rax, [a+24]
    sbb [a+24], rcx
    ;q-1
    sub [b], rbx
    mov rax, [b+8]
    sbb [b+8], rcx
    mov rax, [b+16]
    sbb [b+16], rcx
    mov rax, [b+24]
    sbb [b+24], rcx
    ;c=(p-1)*(q-1)
    call _mul
    
    ;almaceno c temporalmente en registros
    mov rbx,[c]
    mov rcx,[c+8]
    mov rdx,[c+16]
    mov rsi,[c+24]
    
    ;almaceno datos en variable phi
    mov [phi],rbx
    mov [phi+8],rcx
    mov [phi+16],rdx
    mov [phi+24],rsi
    
    ;limpiar variables
    call _cleanab
    
    ret
;       
;   multiregister Division with 256 bit divisor       
; 
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
;       
;   multiregister Division with 64 bit divisor       
;     
   
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
     
;       
;   multiregister Multiplication       
;      
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