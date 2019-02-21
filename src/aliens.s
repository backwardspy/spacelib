MAX_ALIENS = 7

ALIEN_SHOT_DELAY = 10           ; frames
ALIEN_SHOT_TIMER .byte ALIEN_SHOT_DELAY

ALIEN_X_HI .byte 0, 0, 0, 0, 0, 0, 1
ALIEN_X_LO .byte 38, 80, 122, 164, 206, 248, 290-256
ALIEN_Y .byte 70, 90, 70, 90, 70, 90, 70

ALIEN_TX .fill MAX_ALIENS
ALIEN_TY .fill MAX_ALIENS
ALIEN_TXO .fill MAX_ALIENS
ALIEN_TYO .fill MAX_ALIENS

ALIEN_CUR_IDX .byte ?
ALIEN_CUR_X_HI .byte ?
ALIEN_CUR_X_LO .byte ?
ALIEN_CUR_Y .byte ?
ALIEN_CUR_TX .byte ?
ALIEN_CUR_TY .byte ?
ALIEN_CUR_TXO .byte ?
ALIEN_CUR_TYO .byte ?

ALIEN_FIRE_SEQ
  .byte 3, 6, 0, 2, 5, 1, 4
  .byte 4, 5, 1, 6, 5, 2, 0
  .byte 3, 2, 4, 5, 0, 6, 1
  .byte 0, 6, 4, 1, 3, 2, 5

ALIEN_FIRE_SEQ_COUNT = 7 * 4

ALIEN_FIRE_SEQ_IDX .byte 0

;;; [int(25 * (1 + -cos((i / 64) * pi * 2)) / 2) for i in range(64)]
ALIEN_MOVE_TABLE
  .byte 0, 0, 0, 0, 0, 1, 2, 2
  .byte 3, 4, 5, 6, 7, 8, 10, 11
  .byte 12, 13, 14, 16, 17, 18, 19, 20
  .byte 21, 22, 22, 23, 24, 24, 24, 24
  .byte 25, 24, 24, 24, 24, 23, 22, 22
  .byte 21, 20, 19, 18, 17, 16, 14, 13
  .byte 12, 11, 10, 8, 7, 6, 5, 4
  .byte 3, 2, 2, 1, 0, 0, 0, 0

ALIEN_MOVE_TABLE_SIZE = * - ALIEN_MOVE_TABLE

ALIEN_MOVE_TABLE_IDX .byte 0, 32, 8, 40, 16, 48, 24

ALIENS_INIT .macro
  #ALIENS_INIT_SPRITES

  ;; Larger initial delay to give player a chance to catch up.
  lda #60
  sta ALIEN_SHOT_TIMER
.endm

ALIENS_INIT_SPRITES .macro
  .bfor idx = 0, idx < MAX_ALIENS, idx += 1
    #SPR_SET_PTR_VV idx+1, SPR0_PTR + 1 + (idx & 1)
    #SPR_SET_COLOR_VV idx+1, C_RED
    #SPR_SET_POS_VXXX idx+1, ALIEN_X_HI + idx, ALIEN_X_LO + idx, ALIEN_Y + idx
    #SPR_ENABLE_VV idx+1
  .next
.endm

ALIENS_UPDATE .macro
  #ALIENS_UPDATE_MOVEMENT
  .bfor idx = 0, idx < MAX_ALIENS, idx += 1
    #SCREEN_TO_TILE_POS ALIEN_X_HI + idx, ALIEN_X_LO + idx, ALIEN_Y + idx, ALIEN_TX + idx, ALIEN_TY + idx, ALIEN_TXO + idx, ALIEN_TYO + idx
  .next
  #ALIENS_UPDATE_SHOOTING
.endm

ALIENS_UPDATE_MOVEMENT .macro
  ldx #0
_loop
  lda ALIEN_X_HI, x
  sta ALIEN_CUR_X_HI
  lda ALIEN_X_LO, x
  sta ALIEN_CUR_X_LO
  lda ALIEN_Y, x
  sta ALIEN_CUR_Y

  ldy ALIEN_MOVE_TABLE_IDX, x
  lda ALIEN_MOVE_TABLE, y
  sta ZP_0

  #MATH_ADD_16_8_AAX ALIEN_CUR_X_HI, ALIEN_CUR_X_LO, ZP_0

  stx ALIEN_CUR_IDX
  inc ALIEN_CUR_IDX             ; aliens start at 1
  #SPR_SET_POS_AXXX ALIEN_CUR_IDX, ALIEN_CUR_X_HI, ALIEN_CUR_X_LO, ALIEN_CUR_Y

  inc ALIEN_MOVE_TABLE_IDX, x
  lda ALIEN_MOVE_TABLE_IDX, x
  cmp #ALIEN_MOVE_TABLE_SIZE
  bne _noreset
  lda #0
_noreset
  sta ALIEN_MOVE_TABLE_IDX, x

  inx
  cpx #MAX_ALIENS
  bne _loop
.endm

ALIENS_UPDATE_SHOOTING .macro
  ldx ALIEN_SHOT_TIMER
  beq _fire
  dex
  stx ALIEN_SHOT_TIMER
  jmp _end
_fire
  ldx ALIEN_FIRE_SEQ_IDX
  lda ALIEN_FIRE_SEQ, x
  tax

  lda ALIEN_TX, x
  sta ALIEN_CUR_TX
  lda ALIEN_TY, x
  sta ALIEN_CUR_TY
  lda ALIEN_TXO, x
  sta ALIEN_CUR_TXO, x
  lda ALIEN_TYO, x
  sta ALIEN_CUR_TYO, x

  ldx ALIEN_FIRE_SEQ_IDX
  inx
  cpx #ALIEN_FIRE_SEQ_COUNT
  beq _reset_seq
  stx ALIEN_FIRE_SEQ_IDX
  jmp _fire_bullet
_reset_seq
  ldx #0
  stx ALIEN_FIRE_SEQ_IDX
_fire_bullet
  BULLETS_FIRE ALIEN_CUR_TX, ALIEN_CUR_TY, ALIEN_CUR_TXO, C_YELLOW, BULLETDIR_DOWN
_reset_timer
  ldx #ALIEN_SHOT_DELAY
  stx ALIEN_SHOT_TIMER
_end
.endm
