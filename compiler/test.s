test=$123456
testConstant = $40
ADD R0, R10, R1
SUB R0, R0, PC
.test:
test2 = testConstant+.test
test3=<test
test4=>test
test5=!test
MUL R2, R1, test3
AND R3, testConstant, R2
OR R0, $4A, %00011100
XOR R3, R4, R5
NOT R0, $5C
NOT R1, R4
CMP LR
SEC
SEZ
SEN
SEV
CLC
CLZ
CLN
CLV
BCC R0
BCS $05
BNE R7, ~R13
BEQ #40, ~R14
BPL PC, ~%01101010
BMI #10, ~$20
BVC ~LR
BVS ~#50
MOV PC, R0
MOV LR, #60
STR R0, [R2]
LDR R1, [R2, R7]
; STR PC, [R3, R8, #2]
