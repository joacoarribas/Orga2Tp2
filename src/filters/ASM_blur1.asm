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

  ; xor rbx, rbx ; limpio rbx
  mov ebx, edi ; guardo en rbx la cantidad de elementos por fila
  ; xor r12, r12 ; limpio r12
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


  mov ecx, ebx ; guardo en rcx la cantidad de elementos en una fila
  .cargoPrimerFila:
    ; en r14 tengo el primer vector
    ; en r13 tengo el puntero a mi imagen
    mov rax, i
    movd edx, [r13 + rax * OFFSET_DATO] ; guardo en edx el pixel = 4 BYTES
    movd [r14 + rax * OFFSET_DATO], edx ; guardo en el vector el pixel copiado de la imagen
    inc qword i ; me muevo una columna
    loop .cargoPrimerFila

  mov esi, ebx ; guardo en esi la cantidad de columas
  dec esi ; voy a recorrer salteand el primer y ultimo elemento 

  mov ecx, r12d ; muevo a rcx la cantidad de filas que tengo
  dec ecx ; tengo h-2 iteraciones
  mov qword j, 1 ; contador de elementos columna en 1
  .ciclo:
    mov rdx, r15 ; guardo en rdx (temp) mi vector 0
    mov r15, r14 ; guardo en r15 (vector 0) r14 (vector 1)
    mov r14, rdx ; guardo en r14 (vector 1) mi vector 0
    mov qword i, 0 ; limpio mi contador i para recorrer filas
    
    .cargarSiguienteVector:
      cmp ebx, i ; me fijo si ya recorri todos los elementos de la fila
      je .promediar
      mov rax, i ; guardo en rax mi indice
      movd edx, [r13 + rax * OFFSET_DATO] ; guardo en edx el pixel = 4 BYTES
      movd [r14 + rax * OFFSET_DATO], edx ; guardo en el vector el pixel copiado de la imagen
      inc qword i ; me muevo una columna
      jmp .cargarSiguienteVector

    .promediar:
      movdqu xmm0, [r15] ; guardo en xmm0 4 pixeles del vector 0
      movdqu xmm1, [r14] ; guardo en xmm1 4 pixeles del vector 1
      inc j 
      mov rax, j ; guardo en rax mi indice
      movdqu xmm2, [r13 + rax * OFFSET_DATO] ; guardo en xmm2 4 pixeles de la tercer fila
      ; desempaquetar, sumar componente a componente, empaquetar
      ; xmmo = m0p3 | m0p2 | m0p1 | m0p0  
      ; xmm1 = m1p3 | m1p2 | m1p1 | m1p0  
      ; xmm2 = m2p3 | m2p2 | m2p1 | m2p0  
      ; agarrar todos los px0, pasarlos registros 128, sumarlos, hasta px3
      pxor xmm7, xmm7 ; xmm7 = 0
      movdqu xmm8, xmm0 ; xmm8 va a tener la parte alta de xmm0
      punpcklwd xmm0, xmm7 ; intercalo ceros con px0 y px1 | 0 | px1h | 0 | px1l | 0 | px0h | 0 | px0l 
      punpckhwd xmm8, xmm7 ; intercalo ceros con px2 y px3 | 0 | px3h | 0 | px3l | 0 | px2h | 0 | px2l
      ; packuswb x
      punpcklwd xmm0, xmm1 ; | m1p1H | m0p1H | m1p1L | m0p1L | m1p0H | m0p0H | m1p0L | m0p0L













  ret
