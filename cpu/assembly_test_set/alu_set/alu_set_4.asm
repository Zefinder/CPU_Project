; Simple 16 bits subtraction
; We want to compute $0F71 - $01AF = $0DC2
MOV R0 $71
MOV R1 $0F

MOV R2 $AF
MOV R3 $01

SUB R0 R0 R2
SUB R1 R1 R3
