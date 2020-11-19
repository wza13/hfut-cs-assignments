.text
    ; This idea is from code examples in UMN.
    ; https://www.d.umn.edu/~gshute/arch/loop-unrolling.xhtml

    ; double dotProduct = 0;
    ; for (int i = 0; i < 100; i++) {
    ;   dotProduct += A[i]*B[i];
    ; }

    ; Initialize loop count ($7) to 100.
    ; Initialize dotProduct ($f10) to 0.
    ; Initialize A[i] pointer ($5) to the base address of A.
    ; Initialize B[i] pointer ($6) to the base address of B. 
    ld      $7, loop_count(r0)

    loop3:
            ; ; initial loop
            ; l.d     f10, 0($5)        ; $f10 ← A[i]
            ; l.d     f12, 0($6)        ; $f12 ← B[i]
            ; mul.d   f10, f10, f12     ; $f10 ← A[i]*B[i]
            ; add.d   f8, f8, f10       ; $f8 ← $f8 + A[i]*B[i]
            ; daddi   $5, $5, 8         ; increment pointer for A[i]
            ; daddi   $6, $6, 8         ; increment pointer for B[i]
            ; daddi   $7, $7, -1        ; decrement loop count

            ; loop unrolling
            l.d     f10, 0($5)         ; iteration with displacement 0
            l.d     f12, 0($6)
            l.d     f14, 8($5)         ; iteration with displacement 8
            l.d     f16, 8($6)
            l.d     f18, 16($5)        ; iteration with displacement 16
            l.d     f20, 16($6)
            l.d     f22, 24($5)        ; iteration with displacement 24
            l.d     f24, 24($6)
            mul.d   f10, f10, f12
            daddi   $6, $6, 32
            add.d   f8, f8, f10
            mul.d   f14, f14, f16
            daddi   $5, $5, 32
            add.d   f8, f8, f14
            mul.d   f18, f18, f20
            daddi   $7, $7, -4         ; decrement loop count
            add.d   f8, f8, f18
            mul.d   f22, f22, f24
            add.d   f8, f8, f22
    test:
            bnez    $7, loop3          ; Continue if loop count > 0

    halt

.data

    loop_count:     .word   4
