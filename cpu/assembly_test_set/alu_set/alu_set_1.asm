; A few additions 8 bits (no carry flag)
; R0 = $09
ADD R0 $05 $04
; R1 = $0E
ADD R1 R0 $05
; R2 = $17
ADD R2 R1 R0
; R3 = $1A
ADD R3 $03 R2
CMP R0
CMP R1
CMP R2
CMP R3
