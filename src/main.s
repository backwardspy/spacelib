  .include "spacelib/util.s"

VIC_BANK = 1
VIC_BANK_MASK = ~VIC_BANK & 3
VIC_BANK_BASE = $4000 * VIC_BANK

* = $0801
  BASIC_LOADER entry

* = $4000
SPR0_PTR = (* - VIC_BANK_BASE) / $40 ; TODO: let spacelib do this calc
  .binary "ships.spd", 9

* = $7000
CHAR0_PTR = (* - VIC_BANK_BASE) / $800 ; TODO: let spacelib do this calc
  .binary "charset.bin"

* = $8000
  .include "spacelib/memory.s"
  .include "spacelib/input.s"
  .include "spacelib/screen.s"
  .include "spacelib/sprite.s"
  .include "spacelib/math.s"

  .include "player.s"
  .include "aliens.s"

entry
  #SELECT_VIC_BANK VIC_BANK
  #SELECT_CHARSET CHAR0_PTR

  #INPUT_INIT

  #FILL_SCR_MEM $20
  #FILL_COL_MEM C_RED
  #SET_BG_COL C_BLACK
  #SET_BORDER_COL C_DARKGREY

  #SPR_SET_MULTICOLORS C_LIGHTGREY, C_GREY

  #PLAYER_INIT
  #ALIENS_INIT

_loop
  lda IO_RASTER
  cmp #$FF
  bne _loop

  #INPUT_UPDATE

  #PLAYER_UPDATE

  #SPRITE_UPDATE

  jmp _loop
