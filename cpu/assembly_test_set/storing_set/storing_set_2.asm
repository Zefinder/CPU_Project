; Just a few str operations (coupled with ldr to put in register)
MOV R0 $20
MOV R1 $F0
MOV R3 $10
MOV R4 $20

STR R0 [R3]
STR R1 [R4]

LDR R6 [R3]
LDR R7 [R4]

; R6 = $20
CMP R6
; R7 = $F0
CMP R7
