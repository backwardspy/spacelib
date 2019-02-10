.POSIX:
.SUFFIXES:

ASM = 64tass
ASMFLAGS = --ascii --long-branch --case-sensitive -Iinclude -Wall -Werror --m6502

INCLUDES = include/spacelib/screen.s include/spacelib/util.s include/spacelib/input.s include/spacelib/sprite.s include/spacelib/math.s include/spacelib/memory.s

all: spacegame.prg

spacegame.prg: src/main.s src/player.s src/aliens.s $(INCLUDES)
	$(ASM) $(ASMFLAGS) --list=$@.lst -o $@ $<

clean:
	rm -f spacegame.prg spacegame.prg.lst
