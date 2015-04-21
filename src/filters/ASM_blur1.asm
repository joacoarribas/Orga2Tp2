; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur1

%define OFFSET_DATO 4

%define j  [rbp-8]  ; defino etiqueta a variable local, utilizada para recorrer la matriz 
%define i  [rbp-16] ; defino etiqueta a variable local, utilizada para recorrer la matriz  
%define k  [rbp-24] ; defino etiqueta a variable local, utilizada para recorrer el byte 



ASM_blur1:
  ; armo el stack frame
  push rbp
  mov rbp, rsp
  sub rsp, 24 ; reservo espacio para las variables locales
  push rbx
  push r12
  push r13 
  push r14 
  push r15 ; la pila esta alineada por ahora

  ; codigo
  ; rdi tengo el width, cantidad de elementos por fila
  ; rsi tengo el heigth, cantidad de elementos por columna 
  ; rcx tengo la matriz

  xor rbx, rbx ; limpio rbx
  mov ebx, edi ; guardo en rbx la cantidad de elementos por fila
  xor r12, r12 ; limpio r12
  mov r12d, esi ; guardo en r12 la cantidad de elementos por columna
  mov r13, rcx ; guardo en r14 el puntero a mi imagen

  mov qword j, 0 ; inicializo j (contador fila) en cero 
  mov qword i, 0 ; inicializo i (contador columna) en cero 
  mov qword k, 0 ; inicializo k en cero 

  mov r15, 0 ; dejo r15 en cero 
  lea rdi, [r15 + rbx * OFFSET_DATO] ; guardo en rdi 0+cantidad de elementos por fila * 4
  call malloc ; creo un vector con tamaño igual a la fila de la matriz
  ; tengo en rax el vector

  mov r14, rax ; guardo en r14 el primer vector

  mov r15, 0 ; dejo r15 en cero 
  lea rdi, [r15 + rbx * OFFSET_DATO] ; guardo en rdi 0+cantidad de elementos por fila * 4
  call malloc ; creo un vector con tamaño igual a la fila de la matriz
  ; tengo en rax el vector

  mov r15, rax ; guardo en r15 el segundo vector 

  ; tengo que cargar en r14 el primer vector 

  cmp r12, 0 ; me fijo si tengo cero filas
  je .fin ; si es asi no tengo nada que hacer

  cmp r12, 1 ; me fijo si tengo una fila
  je .fin ; si es asi no tengo nada que hacer

  cmp r12, 2 ; me fijo si tengo dos filas
  je .fin ; si es asi no tengo nada que hacer


  mov rcx, rbx ; guardo en rcx la cantidad de elementos en una fila
  .cargoPrimerFila:
    ; en r14 tengo el primer vector
    ; en r13 tengo el puntero a mi imagen
    mov rax, i
    mov edx, [r13 + rax * OFFSET_DATO] ; guardo en edx el pixel = 4 BYTES
    mov [r14 + rax * OFFSET_DATO], edx ; guardo en el vector el pixel copiado de la imagen
    inc qword i ; me muevo una columna
    loop .cargoPrimerFila
; preguntar si i esta en memoria o que onda, vale inc i?


  mov rcx, r12 ; muevo a rcx la cantidad de filas que tengo
  dec rcx 
  dec rcx ; tengo h-2 iteraciones
  .ciclo:
    mov rdx, r15 ; guardo en rdx (temp) mi vector 0
    mov r15, r14 ; guardo en r15 (vector 0) r14 (vector 1)
    mov r14, rdx ; guardo en r14 (vector 1) mi vector 0
    .cargarSiguienteVector:
      
    













  ret
