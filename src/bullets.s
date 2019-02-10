BULLETDIR_UP = 0
BULLETDIR_DOWN = 1

MAX_BULLETS = 16

BULLET_CHAR0 = 64

BULLET_ACTIVE .fill MAX_BULLETS, 0
BULLET_TX .fill MAX_BULLETS, 0
BULLET_TY .fill MAX_BULLETS, 0
BULLET_CHAR .fill MAX_BULLETS, 0
BULLET_COLOUR .fill MAX_BULLETS, 0
BULLET_DIRECTION .fill MAX_BULLETS, 0

BULLETS_FIRE .macro tx, ty, txo, colour, direction
  ldx #0

_loop
  lda BULLET_ACTIVE, x
  bne _skip                     ; Skip until we find an inactive bullet.

  lda \tx
  sta BULLET_TX, x
  lda \ty
  sta BULLET_TY, x

  lda #BULLET_CHAR0
  clc
  adc \txo
  sta BULLET_CHAR, x

  lda #\colour
  sta BULLET_COLOUR, x

  lda #\direction
  sta BULLET_DIRECTION, x

  lda #1
  sta BULLET_ACTIVE, x

  bne _end                      ; Stop iteration.

_skip
  inx
  cpx #MAX_BULLETS
  bne _loop

_end
.endm

BULLETS_UPDATE .macro
  ldx #0

_loop
  lda BULLET_ACTIVE, x
  beq _next                     ; Skip inactive bullets.

  ;; Store bullet position in ZP.
  lda BULLET_TX, x
  sta ZP_0
  lda BULLET_TY, x
  sta ZP_1

  ;; Clear old position.
  #PUT_CHAR_ADDR ZP_0, ZP_1, #$20

  ;; Update Y position on ZP.
  ldy ZP_1
  dey
  cpy #0
  beq _kill_bullet
  sty ZP_1

  ;; Draw at new position.
  lda BULLET_CHAR, x
  sta ZP_2
  #PUT_CHAR_ADDR ZP_0, ZP_1, ZP_2

  ;; Update stored Y position.
  lda ZP_1
  sta BULLET_TY, x
  jmp _next

_kill_bullet
  lda #0
  sta BULLET_ACTIVE, x

_next
  inx
  cpx #MAX_BULLETS
  bne _loop
.endm
