// chacha_core_avr.S
// 2018-06-09  Markku-Juhani O. Saarinen <mjos@iki.fi>

__tmp_reg__ = 0
__zero_reg__ = 1

// R2  - R17, R28, R29 are call-saved
// R18 - R27, R30, R31 are call-globbered

        .text

// This is the quarter round function

.qr:
        movw    Z,      r24             // input pointer r25:r24

        add     ZL,     r20             // r20: A offset to start
        adc     ZH,     __zero_reg__
        ld      r4,     Z               // load A = (  r4,  r5,  r6,  r7 )
        ldd     r5,     Z + 1
        ldd     r6,     Z + 2
        ldd     r7,     Z + 3

        add     ZL,     r21             // r21: B offset to A
        adc     ZH,     __zero_reg__
        ld      r8,     Z               // load B = (  r8,  r9, r10, r11 )
        ldd     r9,     Z + 1
        ldd     r10,    Z + 2
        ldd     r11,    Z + 3

        add     ZL,     r26             // r26: C offset to B
        adc     ZH,     __zero_reg__
        ld      r12,    Z               // load C = ( r12, r13, r14, r15 )
        ldd     r13,    Z + 1
        ldd     r14,    Z + 2
        ldd     r15,    Z + 3

        add     ZL,     r27             // r27: D offset to C
        adc     ZH,     __zero_reg__
        ld      r16,    Z               // load D = ( r16, r17, r18, r19 )
        ldd     r17,    Z + 1
        ldd     r18,    Z + 2
        ldd     r19,    Z + 3

        add     r4,     r8              // A += B
        adc     r5,     r9
        adc     r6,     r10
        adc     r7,     r11

        eor     r16,    r4              // D ^= A
        eor     r17,    r5
        eor     r18,    r6
        eor     r19,    r7

        //  D = ( r18, r19, r16, r17 )  -- D <<< 16

        add     r12,    r18             // C += D
        adc     r13,    r19
        adc     r14,    r16
        adc     r15,    r17

        eor     r8,     r12             // B ^= C
        eor     r9,     r13
        eor     r10,    r14
        eor     r11,    r15

        ldi     r23,    4               // B <<< 4
.rol1:
        lsl     r8
        rol     r9
        rol     r10
        rol     r11
        adc     r8,     __zero_reg__
        dec     r23
        brne    .rol1

        // B = ( r11,  r8,  r9, r10 )   -- B <<< 8

        add     r4,     r11             // A += B
        adc     r5,     r8
        adc     r6,     r9
        adc     r7,     r10

        eor     r18,    r4              // D ^= A
        eor     r19,    r5
        eor     r16,    r6
        eor     r17,    r7

        //  D = ( r17, r18, r19, r16 )  -- D <<< 8

        add     r12,    r17             // C += D
        adc     r13,    r18
        adc     r14,    r19
        adc     r15,    r16

        eor     r11,    r12             // B ^= C
        eor     r8,     r13
        eor     r9,     r14
        eor     r10,    r15

        mov     __tmp_reg__, r11        // B >>> 1
        lsr     __tmp_reg__             // set carry-in from lsb
        ror     r10
        ror     r9
        ror     r8
        ror     r11

        // B = ( r10, r11,  r8,  r9, )  -- B <<< 8

        movw    Z,      r24             // input pointer r25:r24

        add     ZL,     r20             // r20: A offset from start
        adc     ZH,     __zero_reg__
        st      Z,      r4              // store A
        std     Z + 1,  r5
        std     Z + 2,  r6
        std     Z + 3,  r7

        add     ZL,     r21             // r21: B offset to A
        adc     ZH,     __zero_reg__
        st      Z,      r10             // store B
        std     Z + 1,  r11
        std     Z + 2,  r8
        std     Z + 3,  r9

        add     ZL,     r26             // r26: C offset to B
        adc     ZH,     __zero_reg__
        st      Z,      r12             // store C
        std     Z + 1,  r13
        std     Z + 2,  r14
        std     Z + 3,  r15

        add     ZL,     r27             // r27: D offset to C
        adc     ZH,     __zero_reg__
        st      Z,      r17             // store D
        std     Z + 1,  r18
        std     Z + 2,  r19
        std     Z + 3,  r16

        ret


// void chacha_perm(uint8_t st[64], uint8_t dr)

.global chacha_perm
        .type   chacha_perm, @function

chacha_perm:

        push    r4
        push    r5
        push    r6
        push    r7
        push    r8
        push    r9
        push    r10
        push    r11
        push    r12
        push    r13
        push    r14
        push    r15
        push    r16
        push    r17

.iter:
        ldi     r20,    0
        ldi     r21,    16
        ldi     r26,    16
        ldi     r27,    16
        call    .qr                    //  QR( v[ 0], v[ 4], v[ 8], v[12] )

        ldi     r20,    4
        call    .qr                    //  QR( v[ 1], v[ 5], v[ 9], v[13] )

        ldi     r20,    8
        call    .qr                    //  QR( v[ 2], v[ 6], v[10], v[14] )

        ldi     r20,    12
        call    .qr                    //  QR( v[ 3], v[ 7], v[11], v[15] )

        ldi     r20,    0
        ldi     r21,    20
        ldi     r26,    20
        ldi     r27,    20
        call    .qr                    //  QR( v[ 0], v[ 5], v[10], v[15] )

        ldi     r20,    4
        ldi     r27,    4
        call    .qr                    //  QR( v[ 1], v[ 6], v[11], v[12] )

        ldi     r20,    8
        ldi     r26,    4
        ldi     r27,    20
        call    .qr                    //  QR( v[ 2], v[ 7], v[ 8], v[13] )

        ldi     r20,    12
        ldi     r21,    4
        ldi     r26,    20
        call    .qr                    //  QR( v[ 3], v[ 4], v[ 9], v[14] )

        dec     r22                    //  number of iterations (input)
        brne    .iter

        pop     r17
        pop     r16
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     r11
        pop     r10
        pop     r9
        pop     r8
        pop     r7
        pop     r6
        pop     r5
        pop     r4

        ret
        .size   chacha_perm, .-chacha_perm
