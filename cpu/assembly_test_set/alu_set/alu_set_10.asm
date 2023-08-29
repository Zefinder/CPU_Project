; Test of sec and sev on additions and subtractions 
; R0 = $10, carry off
SEC
ADD R0 R0 $0F
; R1 = $1F
; Put carry
ADD R1 R0 $FF
SEV
ADD R1 R0 $0F
