// Mini Cloud Log Analyzer - Variante D
// Detectar 3 errores consecutivos (codigos 5xx)
// Autor: Andres Ramirez

// Variante D - lectura byte a byte
.global _start
.text

_start:
    mov x19, #0          // contador errores consecutivos

leer_linea:
    mov x20, #0          // posición en linebuf

leer_byte:
    mov x0, #0
    ldr x1, =bytebuf
    mov x2, #1           // leer 1 byte a la vez
    mov x8, #63
    svc #0

    cmp x0, #0           // EOF
    ble salir_ok

    ldrb w2, [x1]
    cmp w2, #10          // ¿es '\n'?
    beq procesar_linea

    // guardar byte en linebuf
    ldr x1, =linebuf
    strb w2, [x1, x20]
    add x20, x20, #1
    b leer_byte

procesar_linea:
    // linebuf tiene la línea, x20 = longitud
    cmp x20, #3
    blt reiniciar        // menos de 3 chars, no es 5xx

    ldr x1, =linebuf
    ldrb w2, [x1]        // primer char
    cmp w2, #53          // '5'
    bne reiniciar

    ldrb w3, [x1, #1]    // segundo char
    cmp w3, #48
    blt reiniciar
    cmp w3, #57
    bgt reiniciar

    ldrb w4, [x1, #2]    // tercer char
    cmp w4, #48
    blt reiniciar
    cmp w4, #57
    bgt reiniciar

    // Es 5xx
    add x19, x19, #1
    cmp x19, #3
    beq mostrar_alerta
    b leer_linea

reiniciar:
    mov x19, #0
    b leer_linea

mostrar_alerta:
    mov x0, #1
    ldr x1, =msg
    mov x2, #42
    mov x8, #64
    svc #0
    mov x19, #0
    b leer_linea

salir_ok:
    mov x0, #0
    mov x8, #93
    svc #0

.data
bytebuf:  .space 1
linebuf:  .space 16
msg:      .ascii "ALERTA: 3 errores consecutivos detectados\n"
