// chacha.h
// 2018-06-09  Markku-Juhani O. Saarinen <mjos@iki.fi>

#ifndef _CHACHA_H_
#define _CHACHA_H_

#include <stdint.h>

// perform the permutation for "dr" doublerounds
void chacha_perm(uint8_t st[64], uint8_t dr);

// generate a block of ChaCha20 keystream as per RFC7539
void chacha20_block(void *block,                // 64 bytes written here
                    const uint8_t key[32],      // 256-bit secret key
                    const uint8_t nonce[12],    // 96-bit nonce
                    uint32_t cnt);              // 32-bit block counter 1, 2..

#endif
