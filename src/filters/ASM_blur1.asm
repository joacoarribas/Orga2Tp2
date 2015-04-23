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
nueve: dd 0x00090009

extern malloc


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

  mov rax, 0

  mov ecx, ebx ; guardo en rcx la cantidad de elementos en una fila
  .cargoPrimerFila:
    ; en r14 tengo el primer vector
    ; en r13 tengo el puntero a mi imagen
    mov edx, [r13 + rax * OFFSET_DATO] ; guardo en edx el pixel = 4 BYTES
    mov [r14 + rax * OFFSET_DATO], edx ; guardo en el vector el pixel copiado de la imagen
    inc rax ; me muevo una columna
    loop .cargoPrimerFila

  mov esi, ebx ; guardo en esi la cantidad de columas
  dec esi ; voy a recorrer salteand el primer y ultimo elemento 

  mov ecx, r12d ; muevo a rcx la cantidad de filas que tengo
  dec ecx ; tengo h-2 iteraciones
  mov qword j, 1 ; contador de elementos columna en 1
  .ciclo:
    cmp ecx, 0
    je .fin
    mov rdx, r15 ; guardo en rdx (temp) mi vector 0
    mov r15, r14 ; guardo en r15 (vector 0) r14 (vector 1)
    mov r14, rdx ; guardo en r14 (vector 1) mi vector 0
    mov qword i, 0 ; limpio mi contador i para recorrer filas
    
    .cargarSiguienteVector:
      cmp ebx, i ; me fijo si ya recorri todos los elementos de la fila
      je .promediar
      mov rax, i ; guardo en rax mi indice
      mov edx, [r13 + rax * OFFSET_DATO] ; guardo en edx el pixel = 4 BYTES
      mov [r14 + rax * OFFSET_DATO], edx ; guardo en el vector el pixel copiado de la imagen
      inc qword i ; me muevo una columna
      jmp .cargarSiguienteVector

    .promediar:
      movdqu xmm0, [r15] ; guardo en xmm0 4 pixeles del vector 0
      movdqu xmm1, [r14] ; guardo en xmm1 4 pixeles del vector 1
      inc qword j 
      mov rax, j ; guardo en rax mi indice
      movdqu xmm2, [r13 + rax * OFFSET_DATO] ; guardo en xmm2 4 pixeles de la tercer fila
      ; desempaquetar, sumar componente a componente, empaquetar
      ; xmmo = 0p3 | 0p2 | 0p1 | 0p0  
      ; xmm1 = 1p3 | 1p2 | 1p1 | 1p0  
      ; xmm2 = 2p3 | 2p2 | 2p1 | 2p0  
      ; agarrar todos los px0, pasarlos registros 128, sumarlos, hasta px3
      pxor xmm7, xmm7 ; xmm7 = 0
      movdqu xmm8, xmm0 ; xmm8 va a tener la parte alta de xmm0
      pslldq xmm8, 4 ; xmm8 =  | px2 | px1 | px0 | 0 | 
      psrldq xmm8, 12 ; xmm8 = |  0  |  0  |  0  |px2|
      punpcklbw xmm0, xmm7 ; xmm0 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0 | 0 | B0 | 0 | G0 | 0 | R0 |
      punpcklbw xmm8, xmm7 ; xmm8 = | 0 | 0  | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A2 | 0 | B2 | 0 | G2 | 0 | R2 |
      
      paddw xmm0, xmm8 ; xmm0 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0+A2 | 0 | B0+B2 | 0 | G0+G2 | 0 | R0+R2 |

      movdqu xmm8, xmm0 ; xmm8 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0+A2 | 0 | B0+B2 | 0 | G0+G2 | 0 | R0+R2 |

      psrldq xmm8, 8 ; xmm8 = | 0 | 0 | 0 | 0 | 0 | 0  | 0 | 0  | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 |

      paddw xmm0, xmm8 ; xmm0 = | 0 | 0 | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A0+A1+A2 | 0 | B0+B1+B2 | 0 | G0+G1+G2 | 0 | R0+R1+R2 |

      packuswb xmm0, xmm7 ; xmm0 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | A0+A1+A2 | B0+B1+B2 | G0+G1+G2 | R0+R1+R2 |


      pxor xmm7, xmm7 ; xmm7 = 0
      movdqu xmm8, xmm1 ; xmm8 va a tener la parte alta de xmm0
      pslldq xmm8, 4 ; xmm8 =  | px2 | px1 | px0 | 0 | 
      psrldq xmm8, 12 ; xmm8 = |  0  |  0  |  0  |px2|
      punpcklbw xmm1, xmm7 ; xmm1 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0 | 0 | B0 | 0 | G0 | 0 | R0 |
      punpcklbw xmm8, xmm7 ; xmm8 = | 0 | 0  | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A2 | 0 | B2 | 0 | G2 | 0 | R2 |
      
      paddw xmm1, xmm8 ; xmm1 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0+A2 | 0 | B0+B2 | 0 | G0+G2 | 0 | R0+R2 |

      movdqu xmm8, xmm1 ; xmm8 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0+A2 | 0 | B0+B2 | 0 | G0+G2 | 0 | R0+R2 |

      psrldq xmm8, 8 ; xmm8 = | 0 | 0 | 0 | 0 | 0 | 0  | 0 | 0  | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 |

      paddw xmm1, xmm8 ; xmm1 = | 0 | 0 | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A0+A1+A2 | 0 | B0+B1+B2 | 0 | G0+G1+G2 | 0 | R0+R1+R2 |

      packuswb xmm1, xmm7 ; xmm1 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | A0+A1+A2 | B0+B1+B2 | G0+G1+G2 | R0+R1+R2 |
      

      pxor xmm7, xmm7 ; xmm7 = 0
      movdqu xmm8, xmm2 ; xmm8 va a tener la parte alta de xmm0
      pslldq xmm8, 4 ; xmm8 =  | px2 | px1 | px0 | 0 | 
      psrldq xmm8, 12 ; xmm8 = |  0  |  0  |  0  |px2|
      punpcklbw xmm2, xmm7 ; xmm2 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0 | 0 | B0 | 0 | G0 | 0 | R0 |
      punpcklbw xmm8, xmm7 ; xmm8 = | 0 | 0  | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A2 | 0 | B2 | 0 | G2 | 0 | R2 |
      
      paddw xmm2, xmm8 ; xmm2 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0+A2 | 0 | B0+B2 | 0 | G0+G2 | 0 | R0+R2 |

      movdqu xmm8, xmm2 ; xmm8 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0+A2 | 0 | B0+B2 | 0 | G0+G2 | 0 | R0+R2 |

      psrldq xmm8, 8 ; xmm8 = | 0 | 0 | 0 | 0 | 0 | 0  | 0 | 0  | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 |

      paddw xmm2, xmm8 ; xmm2 = | 0 | 0 | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A0+A1+A2 | 0 | B0+B1+B2 | 0 | G0+G1+G2 | 0 | R0+R1+R2 |

      packuswb xmm2, xmm7 ; xmm2 = | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | A0+A1+A2 | B0+B1+B2 | G0+G1+G2 | R0+R1+R2 |


      punpcklbw xmm0, xmm7 ; xmm0 = suma de los tres pixeles de la primer fila intercalados con ceros 
      
      punpcklbw xmm1, xmm7 ; xmm1 = suma de los tres pixeles de la segunda fila intercalados con ceros 

      punpcklbw xmm2, xmm7 ; xmm2 = suma de los tres pixeles de la tercer fila intercalados con ceros 

      paddw xmm1, xmm2
      paddw xmm0, xmm1

      ; xmm0 = 0 | 0 | 0 | 0 | sumA | sumB | sumG | sumR |
      ;xmm0 tiene la suma de los 9 pixeles

      movdqu xmm9, xmm0
      
      pxor xmm5, xmm5
      pxor xmm6, xmm6 
      pxor xmm7, xmm7
      cvtdq2pd xmm5, xmm9 ; xmm5 = sumG | sumR

      psrldq xmm9, 4 ; xmm9 = 0 | 0 | 0 | 0 | 0 | 0 | sumA | sumB

      cvtdq2pd xmm6, xmm9 ; xmm6 = sumA | sumB

      mov r8d, nueve 

      movd xmm4, r8d ; xmm4 = 0 | 0 | 0 | 0 | 0 | 0 | 9 | 9 |

      cvtdq2pd xmm7, xmm4 ; xmm7 = 9 | 9  

      divpd xmm6, xmm7 ; xmm6 = sumA/9 | sumB/9

      divpd xmm5, xmm7 ; xmm5 = sumG/9 | sumR/9

      pxor xmm10, xmm10


      cvtpd2dq xmm10, xmm6 ; xmm10 = 0 | 0 | 0 | 0 | sumA/9 | sumB/9

      pslldq xmm10, 8

      cvtpd2dq xmm10, xmm6 ; xmm10 = | sumA/9 | sumB/9 | sumG/9 | sumR/9 |

  

      packusdw xmm10, xmm7 ; xmm0 tiene en los primeros 32 bits la suma de los 9 pixeles = | 0 | 0 | 0 | pixel |
      packuswb xmm10, xmm7 ; xmm0 tiene en los primeros 32 bits la suma de los 9 pixeles = | 0 | 0 | 0 | pixel |


      movd r8d, xmm10 ; guardo el pixel en 32 bits

      dec rax
      mov [r13 + rax * OFFSET_DATO], r8d ; guardo el pixel
      dec ecx
      jmp .ciclo


  .fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    add rsp, 24
    ret
