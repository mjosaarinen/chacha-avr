# Makefile
# 2018-06-09  Markku-Juhani O. Saarinen <mjos@iki.fi>

PROJ		= chacha-avr
TARGET		= atmega2560
CPUFREQ		= 16000000
WIRE		= wiring
DEVICE		= /dev/ttyACM0
CC		= avr-gcc
OBJCOPY		= avr-objcopy
AR		= avr-ar
STRIP		= avr-strip
AVRDUDE		= avrdude

CFLAGS  	= -Wall -Ofast -mmcu=$(TARGET) -DF_CPU=$(CPUFREQ)

# Uncomment this line instead to use the slower C version
# OBJS		= obj/chacha_core_c.o obj/chacha20.o
OBJS 		= obj/chacha_core_avr.o obj/chacha20.o

$(PROJ):	speed.c ser_print.c obj/$(PROJ).a
		$(CC) $(CFLAGS) $^ -o $@

%.hex:		%
		$(OBJCOPY) -O ihex -R .eeprom $^ $@

obj/$(PROJ).a: 	$(OBJS)
		$(AR) -ar cr $@ $^

obj/%.o: %.[cS]
		mkdir -p obj/
		$(CC) $(CFLAGS) -c $^ -o $@

obj/%.S: %.c
		$(CC) $(CFLAGS) -S $^ -o $@

clean:
		rm -rf obj $(PROJ) $(PROJ).hex $(PROJ)-*.tgz

dist:		clean
		cd ..; \
		tar cfvz $(PROJ)/$(PROJ)-`date "+%Y%m%d%H%M"`.tgz $(PROJ)/*

# simulate with simavr
sim:		$(PROJ)
		simavr -v -v -v -m $(TARGET) $(PROJ)

# flash on device, dump serial output
flash:		$(PROJ).hex
		$(AVRDUDE) -v -c $(WIRE) -p m2560 -P $(DEVICE) \
			-U flash:w:$(PROJ).hex -D
		stty -F $(DEVICE) raw icanon eof \^d 38400
		cat < $(DEVICE)
