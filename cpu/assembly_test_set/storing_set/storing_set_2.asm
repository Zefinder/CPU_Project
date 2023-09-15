; Just a few str operations (coupled with ldr to put in register)
MOV R0 $20
MOV R1 $21
; R10 is a pointer!
MOV R10 $30

STR R0 $10
STR R1 [R10, R2]

