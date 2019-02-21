;;; Debugging functionality.
DEBUG_TRACE_RASTER = false

;;; VIC configuration.
VIC_BANK = 1
VIC_BANK_MASK = ~VIC_BANK & 3
VIC_BANK_BASE = $4000 * VIC_BANK

  .include "spacelib/util.s"

* = $0801
  BASIC_LOADER entry

* = $4000
SPR0_PTR = (* - VIC_BANK_BASE) / $40 ; TODO: let spacelib do this calc
  .binary "sprites.spd", 9

* = $7000
CHAR0_PTR = (* - VIC_BANK_BASE) / $800 ; TODO: let spacelib do this calc
  .binary "charset.bin"

* = $8000
  .include "spacelib/memory.s"
  .include "spacelib/input.s"
  .include "spacelib/screen.s"
  .include "spacelib/sprite.s"
  .include "spacelib/math.s"

EXPLODE_SPRITE .macro idx
  #SPR_SET_COLOR_VV \idx, C_ORANGE
  #SPR_PLAY_ANIM_VVVVV \idx, 3, 7, 8, false
.endm

  .include "player.s"
  .include "aliens.s"
  .include "bullets.s"

entry
  #SELECT_VIC_BANK VIC_BANK
  #SELECT_CHARSET CHAR0_PTR

  #INPUT_INIT

  #FILL_SCR_MEM $20
  #FILL_COL_MEM C_RED
  #SET_BG_COL C_BLACK
  #SET_BORDER_COL C_DARKGREY

  #SPR_SET_MULTICOLORS_VV C_LIGHTGREY, C_GREY

  #PLAYER_INIT
  #ALIENS_INIT

_loop
  lda IO_RASTER
  cmp #$FF
  bne _loop

  ;; Red trace = input library.
  .if DEBUG_TRACE_RASTER
    #SET_BORDER_COL C_RED
  .endif

  #INPUT_UPDATE

  ;; Yellow trace = player code.
  .if DEBUG_TRACE_RASTER
    #SET_BORDER_COL C_YELLOW
  .endif

  #PLAYER_UPDATE

  ;; Green trace = bullet code.
  .if DEBUG_TRACE_RASTER
    #SET_BORDER_COL C_GREEN
  .endif

  #BULLETS_UPDATE

  ;; Blue trace = aliens code.
  .if DEBUG_TRACE_RASTER
    #SET_BORDER_COL C_BLUE
  .endif

  #ALIENS_UPDATE

  ;; Purple trace = sprite library.
  .if DEBUG_TRACE_RASTER
    #SET_BORDER_COL C_PURPLE
  .endif

  #SPRITE_UPDATE

  ;; Reset border.
  .if DEBUG_TRACE_RASTER
    #SET_BORDER_COL C_DARKGREY
  .endif

  jmp _loop
