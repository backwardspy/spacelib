MAX_ALIENS = 7

ALIEN_SHOT_DELAY = 10           ; frames
ALIEN_SHOT_TIMER .byte ALIEN_SHOT_DELAY

ALIEN_X_HI .byte 0, 0, 0, 0, 0, 1, 1
ALIEN_X_LO .byte 48, 90, 132, 174, 216, 258-256, 300-256
ALIEN_Y .byte 70, 90, 70, 90, 70, 90, 70

ALIEN_TX .fill 8
ALIEN_TY .fill 8
ALIEN_TXO .fill 8
ALIEN_TYO .fill 8

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

ALIENS_INIT .macro
  #ALIENS_INIT_SPRITES

  ;; Larger initial delay to give player a chance to catch up.
  lda #60
  sta ALIEN_SHOT_TIMER
.endm

ALIENS_INIT_SPRITES .macro
  .bfor idx = 0, idx < MAX_ALIENS, idx += 1
    #SPR_SET_PTR idx+1, SPR0_PTR + 1 + (idx & 1)
    #SPR_SET_COLOR idx+1, C_RED
    #SPR_SET_POS idx+1, ALIEN_X_HI + idx, ALIEN_X_LO + idx, ALIEN_Y + idx
    #SPR_ENABLE idx+1
  .next
.endm

ALIENS_UPDATE .macro
  .bfor idx = 0, idx < MAX_ALIENS, idx += 1
    #SCREEN_TO_TILE_POS ALIEN_X_HI + idx, ALIEN_X_LO + idx, ALIEN_Y + idx, ALIEN_TX + idx, ALIEN_TY + idx, ALIEN_TXO + idx, ALIEN_TYO + idx
  .next
  #ALIENS_UPDATE_SHOOTING
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
