;;; Generate a BASIC loader at $0801 to the given address.
BASIC_LOADER .macro address, line_number=2019
* = $0801
  .word (+), \line_number
  .null $9E, format("%d", \address) ; SYS \address
+ .word 0                           ; BASIC line ending
.endm

;;; Place the high byte of vector at address, and the low byte at address+1
MAKE_VECTOR .macro vector, address
  lda #<\vector
  sta \address
  lda #>\vector
  sta \address+1
.endm
