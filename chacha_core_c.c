// chacha_core_c.c
// 2018-06-09  Markku-Juhani O. Saarinen <mjos@iki.fi>

// C version of the ChaCha core (for benchmarking comparison)

#include "chacha.h"

// Rotate 32-bit words left

#ifndef ROTL32
#define ROTL32(x, y)  (((x) << (y)) ^ ((x) >> (32 - (y))))
#endif

// ChaCha Quarter Round unrolled as a macro

#define CHACHA_QR(A, B, C, D) { \
    A += B; D ^= A; D = ROTL32(D, 16);  \
    C += D; B ^= C; B = ROTL32(B, 12);  \
    A += B; D ^= A; D = ROTL32(D, 8);   \
    C += D; B ^= C; B = ROTL32(B, 7);   \
}

// ChaCha permutation -- dr is the number of double rounds

void chacha_perm(uint8_t st[64], uint8_t dr)
{
    uint8_t i;
    uint32_t *v = (uint32_t *) st;

    for (i = 0; i < dr; i++) {
        CHACHA_QR( v[ 0], v[ 4], v[ 8], v[12] );
        CHACHA_QR( v[ 1], v[ 5], v[ 9], v[13] );
        CHACHA_QR( v[ 2], v[ 6], v[10], v[14] );
        CHACHA_QR( v[ 3], v[ 7], v[11], v[15] );
        CHACHA_QR( v[ 0], v[ 5], v[10], v[15] );
        CHACHA_QR( v[ 1], v[ 6], v[11], v[12] );
        CHACHA_QR( v[ 2], v[ 7], v[ 8], v[13] );
        CHACHA_QR( v[ 3], v[ 4], v[ 9], v[14] );
    }
}

