; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur1

%define OFFSET_DATO 4
extern malloc

section .rodata
  nueve: dq 0x0000000900000009

section .text

ASM_blur1:
  ; armo el stack frame
  push rbp
  mov rbp, rsp
  push rbx
  push r12
  push r13 
  push r14 
  push r15 ; la pila esta desalineada por ahora

  ; codigo
  ; edi tengo el width, cantidad de elementos por fila
  ; esi tengo el heigth, cantidad de elementos por columna 
  ; rdx tengo la matriz

  mov ebx, edi ; guardo en rbx la cantidad de elementos por fila
  mov r12d, esi ; guardo en r12 la cantidad de elementos por columna
  mov r13, rdx ; guardo en r14 el puntero a mi imagen

  mov r15, 0 ; dejo r15 en cero 
  lea rdi, [r15 + rbx * OFFSET_DATO] ; guardo en rdi 0+cantidad de elementos por fila * 4

  sub rsp, 8 ; alineo la pila
  call malloc ; creo un vector con tamaño igual a la fila de la matriz
  add rsp, 8 ; desalineo la pila
  ; tengo en rax el vector

  mov r14, rax ; guardo en r14 el primer vector

  mov r15, 0 ; dejo r15 en cero 
  lea rdi, [r15 + rbx * OFFSET_DATO] ; guardo en rdi 0+cantidad de elementos por fila * 4

  sub rsp, 8 ; alineo la pila
  call malloc ; creo un vector con tamaño igual a la fila de la matriz
  add rsp, 8 ; desalineo la pila
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
  .cargoPrimerFila:
    cmp rax, rbx
    je .sigo
    ; en r14 tengo el primer vector
    ; en r13 tengo el puntero a mi imagen
    mov edx, [r13 + rax * OFFSET_DATO] ; guardo en edx el pixel = 4 BYTES
    lea r8, [r14 + rax*OFFSET_DATO]
    mov [r8], edx ; guardo en el vector el pixel copiado de la imagen
    inc rax ; me muevo una columna
    jmp .cargoPrimerFila

  .sigo:  

  lea rdi, [rbx - 4] ; me muevo hasta la columna h-2

  lea rsi, [r12 - 2] ; tengo h-2 iteraciones
  mov r8, 1 ; contador de elementos columna en 1
  .ciclo:
    cmp rsi, 0
    je .fin
    mov rdx, r15 ; guardo en rdx (temp) mi vector 0
    mov r15, r14 ; guardo en r15 (vector 0) r14 (vector 1)
    mov r14, rdx ; guardo en r14 (vector 1) mi vector 0
    mov rax, 0 ; uso rax como mi indice
    lea r13, [r13 + rbx * OFFSET_DATO] ; me paro en la segunda fila 
    
    .cargarSiguienteVector:
      cmp ebx, eax ; me fijo si ya recorri todos los elementos de la fila
      je .prom
      mov edx, [r13 + rax * OFFSET_DATO] ; guardo en edx el pixel = 4 BYTES
      mov [r14 + rax * OFFSET_DATO], edx ; guardo en el vector el pixel copiado de la imagen
      inc rax ; me muevo una columna
      jmp .cargarSiguienteVector

    .prom:
      mov rax, 0
      mov r9, r13 ; r9 apunta a mi segunda fila de la matriz
      lea r9, [r9 + rbx * OFFSET_DATO] ; r9 apunta a la siguiente fila

    .promediar:
      cmp rax, rdi 
      je .decremento
      movdqu xmm0, [r15 + rax * OFFSET_DATO] ; guardo en xmm0 4 pixeles del vector 0
      movdqu xmm1, [r14 + rax * OFFSET_DATO] ; guardo en xmm1 4 pixeles del vector 1

      movdqu xmm2, [r9 + rax * OFFSET_DATO] ; guardo en xmm2 4 pixeles de la tercer fila
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

      pslldq xmm0, 8
      psrldq xmm0, 8

      paddw xmm0, xmm8 ; xmm0 = | 0 | 0 | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A0+A1+A2 | 0 | B0+B1+B2 | 0 | G0+G1+G2 | 0 | R0+R1+R2 |


      pxor xmm7, xmm7 ; xmm7 = 0
      movdqu xmm8, xmm1 ; xmm8 va a tener la parte alta de xmm0
      pslldq xmm8, 4 ; xmm8 =  | px2 | px1 | px0 | 0 | 
      psrldq xmm8, 12 ; xmm8 = |  0  |  0  |  0  |px2|
      punpcklbw xmm1, xmm7 ; xmm1 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0 | 0 | B0 | 0 | G0 | 0 | R0 |
      punpcklbw xmm8, xmm7 ; xmm8 = | 0 | 0  | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A2 | 0 | B2 | 0 | G2 | 0 | R2 |
      
      paddw xmm1, xmm8 ; xmm1 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0+A2 | 0 | B0+B2 | 0 | G0+G2 | 0 | R0+R2 |

      movdqu xmm8, xmm1 ; xmm8 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0+A2 | 0 | B0+B2 | 0 | G0+G2 | 0 | R0+R2 |

      psrldq xmm8, 8 ; xmm8 = | 0 | 0 | 0 | 0 | 0 | 0  | 0 | 0  | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 |

      pslldq xmm1, 8
      psrldq xmm1, 8

      paddw xmm1, xmm8 ; xmm1 = | 0 | 0 | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A0+A1+A2 | 0 | B0+B1+B2 | 0 | G0+G1+G2 | 0 | R0+R1+R2 |


      pxor xmm7, xmm7 ; xmm7 = 0
      movdqu xmm8, xmm2 ; xmm8 va a tener la parte alta de xmm0
      pslldq xmm8, 4 ; xmm8 =  | px2 | px1 | px0 | 0 | 
      psrldq xmm8, 12 ; xmm8 = |  0  |  0  |  0  |px2|
      punpcklbw xmm2, xmm7 ; xmm2 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0 | 0 | B0 | 0 | G0 | 0 | R0 |
      punpcklbw xmm8, xmm7 ; xmm8 = | 0 | 0  | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A2 | 0 | B2 | 0 | G2 | 0 | R2 |
      
      paddw xmm2, xmm8 ; xmm2 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0+A2 | 0 | B0+B2 | 0 | G0+G2 | 0 | R0+R2 |

      movdqu xmm8, xmm2 ; xmm8 = | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 | 0 | A0+A2 | 0 | B0+B2 | 0 | G0+G2 | 0 | R0+R2 |

      psrldq xmm8, 8 ; xmm8 = | 0 | 0 | 0 | 0 | 0 | 0  | 0 | 0  | 0 | A1 | 0 | B1 | 0 | G1 | 0 | R1 |

      pslldq xmm2, 8
      psrldq xmm2, 8

      paddw xmm2, xmm8 ; xmm2 = | 0 | 0 | 0 | 0  | 0 | 0  | 0 | 0  | 0 | A0+A1+A2 | 0 | B0+B1+B2 | 0 | G0+G1+G2 | 0 | R0+R1+R2 |

      paddw xmm1, xmm2
      paddw xmm0, xmm1

      ; xmm0 = 0 | 0 | 0 | 0 | sumA | sumB | sumG | sumR |
      ;xmm0 tiene la suma de los 9 pixeles

      movdqu xmm9, xmm0
      
      pxor xmm5, xmm5
      pxor xmm6, xmm6 
      pxor xmm7, xmm7

      punpcklwd xmm9, xmm7 ; | sumA | sumB | sumG | sumR |

      cvtdq2pd xmm5, xmm9 ; xmm5 = sumG | sumR

      psrldq xmm9, 8 ; xmm9 = 0 | 0 | sumA | sumB

      cvtdq2pd xmm6, xmm9 ; xmm6 = sumA | sumB

      mov r8, nueve 

      movq xmm4, r8 ; xmm4 = 0 | 0 | 9 | 9 |

      cvtdq2pd xmm7, xmm4 ; xmm7 = 9 | 9  

      divpd xmm6, xmm7 ; xmm6 = sumA/9 | sumB/9

      divpd xmm5, xmm7 ; xmm5 = sumG/9 | sumR/9

      pxor xmm10, xmm10

      cvtpd2dq xmm10, xmm6 ; xmm10 = 0 | 0 | 0 | 0 | sumA/9 | sumB/9

      pslldq xmm10, 8 ; xmm10 = sumA/9 | sumB/9 | 0 | 0

      pxor xmm7, xmm7

      cvtpd2dq xmm7, xmm6 ; xmm7 = | 0 | 0 | sumG/9 | sumR/9 |

      paddd xmm10, xmm7

      pxor xmm7, xmm7
      packssdw xmm10, xmm7 ; xmm0 tiene en los primeros 32 bits la suma de los 9 pixeles = | 0 | 0 | 0 | pixel |
      packsswb xmm10, xmm7 ; xmm0 tiene en los primeros 32 bits la suma de los 9 pixeles = | 0 | 0 | 0 | pixel |

      movd r8d, xmm10 ; guardo el pixel en 32 bits

      inc rax
      mov [r13 + rax * OFFSET_DATO], r8d ; guardo el pixel
      jmp .promediar

    .decremento:
      dec rsi
      jmp .ciclo

  .fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
