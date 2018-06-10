chacha-avr
==========

2018-06-10  Markku-Juhani O. Saarinen <mjos@iki.fi>

A public domain constant-time implementation of **ChaCha20** on 8-bit 
AVR microcontroller, just because *you never know when you might need one* !

We implement the raw ChaCha permutation and include ChaCha20 keystream block 
generation per [RFC 7539](https://tools.ietf.org/html/rfc7539) as an higher 
level use case.

The actual assembly language implementation is in `chacha_core_avr.S`, the
rest is basically for serial output, testing, and benchmarking.

# Running on Arduino

The flashing code is incorporated into Makefile. You need to install 
(just `apt install` on Debian/Ubuntu) at least `avr-gcc` and `avrdude` 
packages. 

Plug Arduino into a USB port and do a `make flash`. Now the thing will compile 
code, flash it, and dump output via UART with stty magic to your standard 
output. Most relevant settings are in `Makefile` -- you should edit that
first if something fails. The default settings work with my Arduino Mega 2560
with Ubuntu 18.04. 

```
$ make flash
mkdir -p obj/
avr-gcc -Wall -Ofast -mmcu=atmega2560 -DF_CPU=16000000 -c chacha_core_avr.S -o obj/chacha_core_avr.o
mkdir -p obj/
```
.. more stuff.. and then the interesting bit:
```
stty -F /dev/ttyACM0 raw icanon eof \^d 38400
cat < /dev/ttyACM0
224F51F3401BD9E12FDE276FB8631DED8C131F823D2C06E27E4FCAEC9EF3CF788A3B0AA372600A92B57974CDED2B9334794CBA40C63E34CDEA212C4CF07D41B769A6749F3F630F4122CAFE28EC4DC47E26D4346D70B98C73F3E9C53AC40C5945398B6EDA1A832C89C167EACD901D7E2BF363
Run #00 5363 ticks / block
Run #01 5353 ticks / block
Run #02 5347 ticks / block
Run #03 5345 ticks / block
Run #04 5343 ticks / block
Run #05 5342 ticks / block
Run #06 5342 ticks / block
Run #07 5342 ticks / block
Run #08 5342 ticks / block
Run #09 5342 ticks / block
```
That's a success. The long hex string there should match with keystream from 
section 2.4.2 of RFC 7539 and can be used to verify correctness. 

The performance numbers are for a ChaCha8 block operation, not ChaCha20.

# Running on SIMAVR

If you don't have an Arduino lying about, you can fetch
`simavr` (https://github.com/buserror/simavr) and test using it with
`make sim`.

This cycle-perfect simulator simulates even the UART so the output will be
basically equivalent to above:
```
simavr -v -v -v -m atmega2560 chacha-avr
Loaded 3822 .text at address 0x0
Loaded 72 .data
UART: 0 configured to 0019 = 2403.8462 bps (x1), 8 data 1 stop
UART: Roughly 4576 usec per byte
224F51F3401BD9E12FDE276FB8631DED8C131F823D2C06E27E4FCAEC9EF3CF788A3B0AA372600A92B57974CDED2B9334794CBA40C63E34CDEA212C4CF07D41B769A6749F3F630F4122CAFE28EC4DC47E26D4346D70B98C73F3E9C53AC40C5945398B6EDA1A832C89C167EACD901D7E2BF363.
Run #00 5363 ticks / block.
Run #01 5353 ticks / block.
Run #02 5347 ticks / block.
Run #03 5345 ticks / block.
Run #04 5343 ticks / block.
Run #05 5340 ticks / block.
Run #06 5342 ticks / block.
Run #07 5342 ticks / block.
Run #08 5342 ticks / block.
Run #09 5342 ticks / block.
^Csignal caught, simavr terminating
```

Have fun.

Cheers, -markku

**ABSOLUTELY NO WARRANTY WHATSOEVER**

