N_SPR = 8

spr_anim_start  .fill N_SPR     ; start frame
spr_anim_end    .fill N_SPR     ; end frame
spr_anim_frame  .fill N_SPR     ; current frame
spr_anim_delay  .fill N_SPR     ; delay between frames
spr_anim_timer  .fill N_SPR     ; current frame delay timer
spr_anim_loop   .fill N_SPR     ; animation loop toggle
spr_anim_active .fill N_SPR     ; animation active toggle

SPR_PLAY_ANIM .macro idx, start, end, delay, loop
  .cerror \delay < 1, "delay must be >= 1"
  ldx #\idx

  lda #\start
  sta spr_anim_start, x
  sta spr_anim_frame, x

  lda #\end
  sta spr_anim_end, x

  lda #\delay
  sta spr_anim_delay, x
  sta spr_anim_timer, x

  .if \loop
    lda #1
  .else
    lda #0
  .endif
  sta spr_anim_loop

  lda #1
  sta spr_anim_active, x
.endm

SPR_STOP_ANIM .macro idx
  ldx #\idx
  lda #0
  sta spr_anim_active, x
.endm

SPR_START_ANIM .macro idx
  ldx #\idx
  lda #1
  sta spr_anim_active, x
.endm

SPR_SET_MULTICOLORS .macro mc1, mc2
  lda #\mc1
  sta IO_SPMC0
  lda #\mc2
  sta IO_SPMC1
.endm

SPR_SET_PTR .macro idx, addr
  lda #\addr
  sta VIC_BANK_BASE + $07F8 + \idx
.endm

SPR_SET_COLOR .macro idx, color
  lda #\color
  sta IO_SP0COL + \idx
.endm

SPR_SET_POS .macro idx, x_msb, x_lsb, y
  lda \x_lsb
  sta IO_SP0X + (\idx) * 2
  lda \y
  sta IO_SP0Y + (\idx) * 2

  lda \x_msb
  beq _unset_x_msb
_set_x_msb
  lda IO_MSIGX
  ora #%1 << (\idx)
  sta IO_MSIGX
  bne _end
_unset_x_msb
  lda IO_MSIGX
  and #~(%1 << (\idx))
  sta IO_MSIGX
_end
.endm

SPR_SET_EXPAND .macro idx, x, y
  lda IO_XXPAND

  .if \x
    ora #%1 << (\idx)
  .else
    and #~(%1 << (\idx))
  .endif
  sta IO_XXPAND

  lda IO_YXPAND
  .if \x
    ora #%1 << (\idx)
  .else
    and #~(%1 << (\idx))
  .endif
  sta IO_YXPAND
.endm

SPR_ENABLE .macro idx, multicolor=true
  lda IO_SPENA
  ora #%1 << (\idx)
  sta IO_SPENA

  lda IO_SPMC
  .if \multicolor
    ora #%1 << (\idx)
  .else
    and #~(%1 << (\idx))
  .endif
  sta IO_SPMC
.endm

SPRITE_UPDATE .macro
  ldx #0

_loop
  ;; skip if active is false
  lda spr_anim_active, x
  beq _skip

  ;; skip if we have time left on the delay timer
  dec spr_anim_timer, x
  bne _skip

  ;; reset delay timer
  lda spr_anim_delay, x
  sta spr_anim_timer, x

  ;; increment current frame
  inc spr_anim_frame, x

  ;; if we've passed the end frame, go back to the start
  lda spr_anim_frame, x
  cmp spr_anim_end, x
  bmi _set_frame                ; skip if A >= spr_anim_end,x
  lda spr_anim_start, x
  sta spr_anim_frame, x

_set_frame
  ;; at this point, A = current frame
  ;; add A to SPR0_PTR to get sprite index
  clc
  adc #SPR0_PTR

  ;; set sprite ptr
  sta VIC_BANK_BASE + $07F8, x

_skip
  inx
  cpx #8
  bne _loop                     ; loop until X == 8
.endm
