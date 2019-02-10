_KEYMASK .segment k0, k1, k2, k3, k4, k5, k6, k7
  KM_\k0 = 1 << 0
  KM_\k1 = 1 << 1
  KM_\k2 = 1 << 2
  KM_\k3 = 1 << 3
  KM_\k4 = 1 << 4
  KM_\k5 = 1 << 5
  KM_\k6 = 1 << 6
  KM_\k7 = 1 << 7
.endm

;;; Keyboard key masks. Rows are CIA1 Port A bits 0-7.
  #_KEYMASK DELETE, RETURN, CRSR_RT, F7, F1, F3, F5, CRSR_DN
  #_KEYMASK 3, W, A, 4, Z, S, E, LSHIFT
  #_KEYMASK 5, R, D, 6, C, F, T, X
  #_KEYMASK 7, Y, G, 8, B, H, U, V
  #_KEYMASK 9, I, J, 0, M, K, O, N
  #_KEYMASK PLUS, P, L, MINUS, PERIOD, COLON, AT_SIGN, COMMA
  #_KEYMASK POUND, ASTERISK, SEMICOLON, HOME, RSHIFT, EQUAL, CARET, SLASH
  #_KEYMASK 1, LEFT_ARROW, CTRL, 2, SPACE, COMMODORE, Q, STOP

;;; Input state variables.
KB_STATE        .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
KB_PREV_STATE   .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
KB_STATE_DIFF   .byte $00, $00, $00, $00, $00, $00, $00, $00

;;; Sets A to zero if the given key was pressed this frame, non-zero otherwise.
KEY_PRESSED .macro row, key_mask
  lda KB_STATE_DIFF+\row
  and #\key_mask
  beq _not_pressed              ; Key hasn't changed this frame.

  lda KB_STATE+\row
  and #\key_mask
  bne _not_pressed              ; Key isn't currently pressed.

  lda #0
  beq _end
_not_pressed
  lda #1
_end
.endm

;;; Sets A to zero if the given key is currently held, non-zero otherwise.
KEY_HELD .macro row, key_mask
  lda KB_STATE+\row
  and #\key_mask
.endm

;;; Initialise input library.
;;; Sets up PRA as RW output and PRB as RO input.
INPUT_INIT .macro
  lda #$FF
  sta IO_CIA1DDRA
  lda #$00
  sta IO_CIA1DDRB
.endm

;;; Update input state variables. Preferably called once per frame.
INPUT_UPDATE .macro
  ;; Copy current state to previous state.
  ldx #8
-
  lda KB_STATE-1, x
  sta KB_PREV_STATE-1, x

  dex
  bne -

  ;; Ask CIA1 for current state.
  ldx #8                        ; iterator
  ldy #$80                      ; row mask
-
  tya
  eor #$FF                      ; invert mask
  sta IO_CIA1PRA
  lda IO_CIA1PRB
  sta KB_STATE-1, x

  tya
  lsr a                         ; shift to next row
  tay

  dex
  bne -

  ;; Diff previous state and previous state.
  ldx #8
-
  lda KB_STATE-1, x
  eor KB_PREV_STATE-1, x
  sta KB_STATE_DIFF-1, x

  dex
  bne -
.endm
