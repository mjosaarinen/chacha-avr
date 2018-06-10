// chacha20.c
// 2018-06-09  Markku-Juhani O. Saarinen <mjos@iki.fi>

#include <string.h>
#include "chacha.h"

// generate a block of ChaCha20 keystream as per RFC7539

void chacha20_block(void *block,                // 64 bytes written here
                    const uint8_t key[32],      // 256-bit secret key
                    const uint8_t nonce[12],    // 96-bit nonce
                    uint32_t cnt)               // 32-bit block counter 1, 2..
{
    const uint32_t fixed[4] =
        { 0x61707865, 0x3320646e, 0x79622d32, 0x6b206574 };
    size_t i;

    memcpy(block, fixed, 16);
    memcpy(block + 16, key, 32);
    memcpy(block + 48, &cnt, 4);
    memcpy(block + 52, nonce, 12);

    chacha_perm(block, 10);             // 10 double-rounds

    for (i = 0; i < 4; i++)
        ((uint32_t *) block)[i] += fixed[i];
    for (i = 0; i < 8; i++)
        ((uint32_t *) block)[i + 4] += ((const uint32_t *) key)[i];
    ((uint32_t *) block)[12] += cnt;
    for (i = 0; i < 3; i++)
        ((uint32_t *) block)[i + 13] += ((const uint32_t *) nonce)[i];
}

