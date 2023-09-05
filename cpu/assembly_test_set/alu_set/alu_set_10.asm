; Test of sec and clc on additions and subtractions 
; R0 = $10, carry off
SEC
ADD R0 R0 $0F
; R1 = $1F
; Put carry
ADD R1 R0 $FF
CLC
ADD R1 R0 $0F

CMP R0
CMP R1
