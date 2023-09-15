; str operations with offset and multiplication
MOV R0 $20
MOV R1 $10

MOV R10 $05
MOV R11 $1A
MOV R12 $24
MOV R13 $38

STR R0 [R1, R10, #1]

LDR R2 [R11]

; R2 = $20
CMP R2

MOV R0 $30
STR R0 [R1, R10, #2]
LDR R2 [R12]

; R2 = $30
CMP R2

MOV R0 $40
STR R0 [R1, R10, #3]
LDR R2 [R13]

; R2 = $40
CMP R2
