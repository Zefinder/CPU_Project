; A few subtraction 8 bits (no carry flag)
; R0 = $50
SUB R0 $70 $20
; R1 = $40
SUB R1 R0 $10
; R2 = $30
SUB R2 $70 R1
; R3 = $20
SUB R3 R0 R2

CMP R0
CMP R1
CMP R2
CMP R3
