; Simple 16 bits subtraction
; We want to compute $0F71 - $01AF = $0DC2
MOV R0 $71
MOV R1 $0F

MOV R2 $AF
MOV R3 $01

SUB R0 R2 R0
SUB R1 R3 R1

CMP R1
CMP R0
