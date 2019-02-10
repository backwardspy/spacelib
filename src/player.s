PLAYER_SPEED = 4

PLAYER_X_MIN = 25
PLAYER_X_MAX = 319

PLAYER_Y_MIN = 180
PLAYER_Y_MAX = 228

PLAYER_X .byte 0, (320 - 24) / 2
PLAYER_Y .byte 220

PLAYER_TX .byte ?               ; tile coordinates
PLAYER_TY .byte ?
PLAYER_TXO .byte ?              ; 0-7 offset into tile
PLAYER_TYO .byte ?

PLAYER_INIT .macro
  #SPR_SET_PTR 0, SPR0_PTR
  #SPR_SET_COLOR 0, C_BLUE
  #SPR_SET_POS 0, PLAYER_X, PLAYER_X+1, PLAYER_Y
  #SPR_ENABLE 0
.endm

PLAYER_UPDATE .macro
  #PLAYER_UPDATE_POSITION
  #PLAYER_UPDATE_TILE_POSITION
  #PLAYER_UPDATE_FIRING
.endm

PLAYER_UPDATE_POSITION .macro
_check_left
  #KEY_HELD 1, KM_A
  bne _check_right

  ;; Move player left.
  MATH_SUB_16_8 PLAYER_X, PLAYER_X+1, PLAYER_SPEED
  MATH_MAX_16 PLAYER_X, PLAYER_X+1, >PLAYER_X_MIN, <PLAYER_X_MIN

_check_right
  #KEY_HELD 2, KM_D
  bne _check_up

  ;; Move player right.
  MATH_ADD_16_8 PLAYER_X, PLAYER_X+1, PLAYER_SPEED
  MATH_MIN_16 PLAYER_X, PLAYER_X+1, >PLAYER_X_MAX, <PLAYER_X_MAX

_check_up
  #KEY_HELD 1, KM_W
  bne _check_down

  ;; Move player up.
  MATH_SUB_8_8 PLAYER_Y, PLAYER_SPEED
  MATH_MAX_8 PLAYER_Y, PLAYER_Y_MIN

_check_down
  #KEY_HELD 1, KM_S
  bne _move_sprite

  ;; Move player down.
  MATH_ADD_8_8 PLAYER_Y, PLAYER_SPEED
  MATH_MIN_8 PLAYER_Y, PLAYER_Y_MAX

_move_sprite
  #SPR_SET_POS 0, PLAYER_X, PLAYER_X+1, PLAYER_Y
.endm

PLAYER_UPDATE_TILE_POSITION .macro
  ;; Sprite becomes fully visible at X = 24.
  ;; We subtract to account for this, with an offset of 12 for the sprite's center.
  lda PLAYER_X
  sta ZP_0
  lda PLAYER_X+1
  sta ZP_1
  #MATH_SUB_16_8 ZP_0, ZP_1, 12

  ;; Divide LSB by 8.
  lda ZP_1
  lsr a
  lsr a
  lsr a

  ;; Adjust for X MSB.
  ldx ZP_0
  beq _store_tx                 ; Skip if X MSB isn't set.
  clc
  adc #256 / 8
_store_tx
  sta PLAYER_TX

  ;; Mask bottom 4 bits of X position to get X offset into tile.
  lda ZP_1
  and #7
  sta PLAYER_TXO

  ;; Y is a single byte so it's simpler than X.
  lda PLAYER_Y
  sec
  sbc #50                       ; Offset by 50 to account for screen border.
  lsr a                         ; Divide by 8.
  lsr a
  lsr a
  sta PLAYER_TY

  ;; Mask bottom 4 bits of Y position to get Y offset into tile.
  lda PLAYER_Y
  and #7
  sta PLAYER_TYO
.endm

PLAYER_UPDATE_FIRING .macro
  #KEY_PRESSED 7, KM_SPACE
  bne _end

  #BULLETS_FIRE PLAYER_TX, PLAYER_TY, PLAYER_TXO, C_WHITE, BULLETDIR_UP

_end
.endm
