PLAYER_SPEED = 4

PLAYER_X_MIN = 25
PLAYER_X_MAX = 319

PLAYER_Y_MIN = 180
PLAYER_Y_MAX = 228

PLAYER_X .byte 0, 12 + 320 / 2
PLAYER_Y .byte 220

PLAYER_TX .byte ?               ; tile coordinates
PLAYER_TY .byte ?
PLAYER_TXO .byte ?              ; 0-7 offset into tile
PLAYER_TYO .byte ?

PLAYER_INIT .macro
  #SPR_SET_PTR_VV 0, SPR0_PTR
  #SPR_SET_COLOR_VV 0, C_BLUE
  #SPR_SET_POS_VXXX 0, PLAYER_X, PLAYER_X+1, PLAYER_Y
  #SPR_ENABLE_VV 0
.endm

PLAYER_UPDATE .macro
  #PLAYER_UPDATE_POSITION
  #SCREEN_TO_TILE_POS PLAYER_X, PLAYER_X+1, PLAYER_Y, PLAYER_TX, PLAYER_TY, PLAYER_TXO, PLAYER_TYO
  #PLAYER_UPDATE_FIRING
.endm

PLAYER_UPDATE_POSITION .macro
_check_left
  #KEY_HELD 1, KM_A
  bne _check_right

  ;; Move player left.
  #MATH_SUB_16_8_AAX PLAYER_X, PLAYER_X+1, #PLAYER_SPEED
  #MATH_MAX_16_AAXX PLAYER_X, PLAYER_X+1, #>PLAYER_X_MIN, #<PLAYER_X_MIN

_check_right
  #KEY_HELD 2, KM_D
  bne _check_up

  ;; Move player right.
  #MATH_ADD_16_8_AAX PLAYER_X, PLAYER_X+1, #PLAYER_SPEED
  #MATH_MIN_16_AAXX PLAYER_X, PLAYER_X+1, #>PLAYER_X_MAX, #<PLAYER_X_MAX

_check_up
  #KEY_HELD 1, KM_W
  bne _check_down

  ;; Move player up.
  #MATH_SUB_8_8_AX PLAYER_Y, #PLAYER_SPEED
  #MATH_MAX_8_AX PLAYER_Y, #PLAYER_Y_MIN

_check_down
  #KEY_HELD 1, KM_S
  bne _move_sprite

  ;; Move player down.
  #MATH_ADD_8_8_AX PLAYER_Y, #PLAYER_SPEED
  #MATH_MIN_8_AX PLAYER_Y, #PLAYER_Y_MAX

_move_sprite
  #SPR_SET_POS_VXXX 0, PLAYER_X, PLAYER_X+1, PLAYER_Y

  #KEY_PRESSED 0, KM_DELETE
  bne _end
  #EXPLODE_SPRITE 1
_end
.endm

PLAYER_UPDATE_FIRING .macro
  #KEY_PRESSED 7, KM_SPACE
  bne _end

  #BULLETS_FIRE PLAYER_TX, PLAYER_TY, PLAYER_TXO, C_WHITE, BULLETDIR_UP
_end
.endm
