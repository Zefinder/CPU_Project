; Simple 16 bits addition
; We want to compute $01AF + $0F71 = $1120
MOV R0 $AF
MOV R1 $01

MOV R2 $71
MOV R3 $0F

ADD R0 R0 R2
ADD R1 R1 R3
