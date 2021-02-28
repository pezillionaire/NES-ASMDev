.segment "HEADER"
.byte "NES"
.byte $1a
.byte $02 ; 2 x 16kb PRG ROM
.byte $01 ; 1 x 8kb CHR ROM
.byte %00000000 ; mapper and mirroring
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00 ; filler bytes
.segment "ZEROPAGE" ; LSB 0 - FF
.segment "STARTUP"
Reset:
  SEI ; Disables all interupts
  CLD ; Disable decimal mode

  ; Disable sound IRQ
  LDX #$40
  STX $4017

  ; init stack register
  LDX #$FF
  TXS

  INX ; #$FF + 1 = #$00

  ; Zero out PPU registers
  STX $2000
  STX $2001
  ; Disable PCM Channel
  STX $4010
; wait for vblank
:
  BIT $2002 ; vblank bit 7 check
  BPL :-

  TXA

CLEARMEM:
  STA $0000, X ; $0000 => $00FF
  STA $0100, X ; $0100 => $01FF

  STA $0300, X ; $0300 => $03FF
  STA $0400, X ; $0400 => $04FF
  STA $0500, X ; $0400 => $05FF
  STA $0600, X ; $0600 => $06FF
  STA $0700, X ; $0700 => $07FF
  LDA #$FF
  STA $0200, X ; $0200 => $02FF
  LDA #$00
  INX
  BNE CLEARMEM
; wait for vblank again
:
  BIT $2002
  BPL :-
; clean PPU Memory
  LDA #$02 ; range of memory (0200 block)
  STA $4014 ; store to 4014
  NOP ; burn a CPU cyle to give PPU time to catch up

  ; write to address $3F00
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006

  LDX #$00

LoadPalettes:
  LDA PalletteData, X
  STA $2007 ; $3F00, $3F01, … $3F1F
  INX
  CPX #$20
  BNE LoadPalettes

  LDX #$00
LoadSprites:
  LDA SpriteData, X
  STA $0200, X
  INX
  CPX #$20
  BNE LoadSprites

; Enable Interrupts
  CLI

  LDA #%10010000 ; enable NMI change BG to use second set of tiles($1000)
  STA $2000
  ; enable sprites and Bg for leftmost 8px
  ; enable sprites and BG
  LDA #%00011110
  STA $2001

Loop:
  JMP Loop

NMI:
  LDA #$02 ;copy sprite data from $0200
  STA $4014 ; into PPU for display
  RTI ; Interupt Return

PalletteData:
  .byte $22,$29,$1A,$0F,$22,$36,$17,$0F,$22,$30,$21,$0F,$22,$27,$17,$0F ;bg palette data
  .byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17 ;sprite palette data

; Y-offset, sprite tile, ?? atributes, X-offset
SpriteData:
  .byte $08, $00, $00, $08
  .byte $08, $01, $00, $10
  .byte $10, $02, $00, $08
  .byte $10, $03, $00, $10
  .byte $18, $04, $00, $08
  .byte $18, $05, $00, $10
  .byte $20, $06, $00, $08
  .byte $20, $07, $00, $10


.segment "VECTORS"
  .word NMI
  .word Reset
  ;
.segment "CHARS"
  .incbin "hellomario.chr"
