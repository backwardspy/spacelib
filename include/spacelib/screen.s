SCREEN_BASE = VIC_BANK_BASE + $0400

;;; Screen size constants.
SZ_W = 40
SZ_H = 25
SZ_PXW = 320
SZ_PXH = 200

;;; Colour constants with aliases.
C_BLACK = $0
C_WHITE = $1
C_RED = $2
C_CYAN = $3
C_VIOLET = $4
C_PURPLE = C_VIOLET
C_GREEN = $5
C_BLUE = $6
C_YELLOW = $7
C_ORANGE = $8
C_BROWN = $9
C_LIGHTRED = $A
C_DARKGREY = $B
C_GREY1 = C_DARKGREY
C_GREY = $C
C_GREY2 = C_GREY
C_LIGHTGREEN = $D
C_LIGHTBLUE = $E
C_LIGHTGREY = $F
C_GREY3 = C_LIGHTGREY

;;; Table containing the start address of each row of characters in screen memory.
;;; We can index into this table with Y and then add X to place characters onto the screen.
SCREEN_BASE_ROW_LO              ; Low bytes.
  .for row = 0, row < 24, row += 1
    .byte <(SCREEN_BASE + SZ_W * row)
  .next
SCREEN_BASE_ROW_HI              ; High bytes.
  .for row = 0, row < 24, row += 1
    .byte >(SCREEN_BASE + SZ_W * row)
  .next

;;; Set active VIC bank.
SELECT_VIC_BANK .macro bank=0
  .cerror \bank < 0, "bank cannot be less than 0"
  .cerror \bank > 3, "bank cannot be greater than 3"
  lda IO_CIA2PRA
  and #%11111100
  ora #+~\bank & 3
  sta IO_CIA2PRA
.endm

;;; Tell the VIC-II to find the charset at the given pointer.
;;; The pointer's value is the charset's offset from the bottom of the current
;;; vic bank, divided by $1000.
SELECT_CHARSET .macro ptr
  .cerror \ptr < 0, "ptr cannot be less than 0"
  .cerror \ptr > 7, "ptr cannot be more than 7"
  lda IO_VMCSB
  and #%11110001
  ora #\ptr << 1
  sta IO_VMCSB
.endm

;;; Set border colour.
SET_BORDER_COL .macro colour=C_LIGHTBLUE
  lda #\colour
  sta IO_EXTCOL
.endm

;;; Set background colour.
SET_BG_COL .macro colour=C_BLUE
  lda #\colour
  sta IO_BGCOL0
.endm

;;; Fill screen memory with the given value.
FILL_SCR_MEM .macro value
  ldx #0
  lda #\value
-
  sta SCREEN_BASE+$0000, x
  sta SCREEN_BASE+$0100, x
  sta SCREEN_BASE+$0200, x
  sta SCREEN_BASE+$02E8, x
  inx
  bne -
.endm

;;; Fill colour memory with the value in A.
FILL_COL_MEM .macro value
  ldx #0
  lda #\value
-
  sta IO_COLORRAM+$0000, x
  sta IO_COLORRAM+$0100, x
  sta IO_COLORRAM+$0200, x
  sta IO_COLORRAM+$02E8, x
  inx
  bne -
.endm

;;; Convert the given coordinates into a screen/colour memory offset.
CHAR_POS .function px, py
.endf SZ_W * py + px

;;; Place the value of A into screen memory at the given coordinates.
PUT_CHAR .macro x, y
  sta SCREEN_BASE+CHAR_POS(\x, \y)
.endm

;;; Place the value of A into colour memory at the given coordinates.
PUT_COL .macro x, y
  sta IO_COLORRAM+CHAR_POS(\x, \y)
.endm
