; A few multiplications 8 bits
MOV R0 $01
; R0 = $0A
MUL R0 R0 $0A
; R1 = $64
MUL R1 R0 R0
; R2 = $00
MUL R2 $00 R0
; R3 = $09
MUL R3 $03 $03
