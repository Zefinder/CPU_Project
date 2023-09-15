; str operations with offset
MOV R0 $20
MOV R1 $10

MOV R10 $05
MOV R11 $15

STR R0 [R1, R10]

LDR R2 [R11]

; R2 = $20
CMP R2
