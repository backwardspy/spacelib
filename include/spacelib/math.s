;;; Add the given byte to the 8-bit value at the given address.
MATH_ADD_8_8 .macro addr, byte
  lda \addr
  clc
  adc #\byte
  sta \addr
.endm

;;; Add the given byte to the 16-bit value at the given hi/lo address.
MATH_ADD_16_8 .macro hi, lo, byte
  lda \lo
  clc
  adc #\byte
  sta \lo
  lda \hi
  adc #0
  sta \hi
.endm

;;; Subtract the given byte from the 8-bit value at the given address.
MATH_SUB_8_8 .macro addr, byte
  lda \addr
  sec
  sbc #\byte
  sta \addr
.endm

;;; Subtract the given byte from the 16-bit value at the given hi/lo address.
MATH_SUB_16_8 .macro hi, lo, byte
  lda \lo
  sec
  sbc #\byte
  sta \lo
  lda \hi
  sbc #0
  sta \hi
.endm

MATH_MIN_8 .macro addr, byte
  lda \addr
  cmp #\byte
  bmi _skip
  lda #\byte
  sta \addr
_skip
.endm

;;; Return the minimum of the given 16-bit values. (hi/lo = addr, msb/lsb = value)
MATH_MIN_16 .macro hi, lo, msb, lsb
  lda \hi
  cmp #\msb
  bmi _skip                     ; skip if hi < msb
  lda #\msb
  sta \hi

  lda #\lsb
  cmp \lo
  bcs _skip                     ; skip if lsb >= lo
  sta \lo
_skip
.endm

MATH_MAX_8 .macro addr, byte
  lda \addr
  cmp #\byte
  bpl _skip
  lda #\byte
  sta \addr
_skip
.endm

;;; Return the maximum of the given 16-bit vaues. (hi/lo = addr, msb/lsb = value)
MATH_MAX_16 .macro hi, lo, msb, lsb
  lda #\msb
  cmp \hi
  bcc _skip                     ; skip if msb < hi
  sta \hi

  lda #\lsb
  cmp \lo
  bcc _skip                     ; skip if lsb < lo
  sta \lo
_skip
.endm
