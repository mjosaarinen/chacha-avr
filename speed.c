//  speed.c
//  2018-06-09  Markku-Juhani O. Saarinen <mjos@iki.fi>

//  Test / benchmark code

#include <avr/io.h>
#include <avr/interrupt.h>
#include "ser_print.h"

#include "chacha.h"

/* === speed-testing code === */

uint64_t tick_ticks;
static uint8_t tick_init_done = 0;

// intialize timers

static void tick_init(void)
{
    tick_ticks = 0;
#ifdef __AVR_ATmega128__
    TCCR1B = (1 << CS12);
    TIMSK |= (1 << TOIE1);
#else
    TCCR0B = (1 << CS00);
    TCCR1B = (1 << CS12);
    TIMSK1 |= (1 << TOIE1);
#endif
    TCNT0 = 0;
    TCNT1 = 0;
    sei(); // Enable global interrupts
    tick_init_done = 1;
}

// interrupt handler on TIMER1 overflow

ISR(TIMER1_OVF_vect)
{
    tick_ticks += (1UL << 24);
}

unsigned long long tick_cycles(void)
{
    if (!tick_init_done)
        tick_init();

    return tick_ticks | (((uint64_t) TCNT1) << 8) | ((uint64_t) TCNT0);
}

/*
    Test keystream output from section 2.4.2 of RFC 7539

    224F51F3401BD9E12FDE276FB8631DED8C131F823D2C06E27E4FCAEC9EF3CF78
    8A3B0AA372600A92B57974CDED2B9334794CBA40C63E34CDEA212C4CF07D41B7
    69A6749F3F630F4122CAFE28EC4DC47E26D4346D70B98C73F3E9C53AC40C5945
    398B6EDA1A832C89C167EACD901D7E2BF363
*/

int main(void)
{
    // ChaCha20 test vectors from RFC 7539

    const uint8_t key[32] = {
        0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
        0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
        0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
        0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F
    };
    const uint8_t nonce[12] = {
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4a,
        0x00, 0x00, 0x00, 0x00
    };

    size_t i, run;
    uint64_t t;

    uint8_t st[64];

    // Output keystream

    chacha20_block(st, key, nonce, 1);
    for (i = 0; i < 64; i++)
        ser_hex8(st[i]);
    chacha20_block(st, key, nonce, 2);
    for (i = 0; i < 114 - 64; i++)
        ser_hex8(st[i]);
    ser_write('\n');

    // time ChaCha8

    tick_init();

    for (run = 0; run < 10; run++) {

        ser_print("Run #");
        ser_hex8(run);
        ser_print(" ");

        t = tick_cycles();
        for (i = 1 << run; i > 0; i--) {
            chacha_perm(st, 4);
            chacha_perm(st, 4);
            chacha_perm(st, 4);
            chacha_perm(st, 4);
        }
        t = tick_cycles() - t;
        t >>= run + 2;

        ser_dec64(t);
        ser_print(" ticks / block\n");
    }

    ser_end();

    return 0;
}

