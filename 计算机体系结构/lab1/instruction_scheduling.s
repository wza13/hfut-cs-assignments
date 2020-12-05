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
            ; ; before scheduling
            ; l.d     f10, 0($5)        ; $f10 ← A[i]
            ; l.d     f12, 0($6)        ; $f12 ← B[i]
            ; mul.d   f10, f10, f12     ; $f10 ← A[i]*B[i]
            ; add.d   f8, f8, f10       ; $f8 ← $f8 + A[i]*B[i]
            ; daddi   $5, $5, 8         ; increment pointer for A[i]
            ; daddi   $6, $6, 8         ; increment pointer for B[i]
            ; daddi   $7, $7, -1        ; decrement loop count

            ; after scheduling
            l.d     f10, 0($5)        ; $f10 ← A[i]
            l.d     f12, 0($6)        ; $f12 ← B[i]
            daddi   $7, $7, -1        ; decrement loop count
            mul.d   f10, f10, f12     ; $f10 ← A[i]*B[i]
            daddi   $5, $5, 8         ; increment pointer for A[i]
            daddi   $6, $6, 8         ; increment pointer for B[i]
            add.d   f8, f8, f10       ; $f8 ← $f8 + A[i]*B[i]

    test:
            bnez    $7, loop3         ; Continue if loop count > 0
    halt

.data

    loop_count:     .word   4
