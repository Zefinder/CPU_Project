#ifndef COMPILE
#define COMPILE

#define FIRST_REGISTER_MASK 0x10
#define SECOND_REGISTER_MASK 0x20
#define BOTH_REGISTER_MASK 0x30

#define REGISTER_BRANCH_ADDRESS_MASK 0x10
// Constant offset mask useless, to change...
#define USE_CONSTANT_OFFSET_MASK 0x01
#define USE_REGISTER_OFFSET_MASK 0x21

// Only for MOV
#define DIRECT_REGISTER_MASK 0x01

// For STR and LDR
#define MEMORY_OFFSET_MASK 0x10
#define MEMORY_OFFSET_SHIFT_MASK 0x14

#define ADD 0x08
#define SUB 0x09
#define MUL 0x0A
#define AND 0x0B
#define OR 0x0C
#define XOR 0x0D
#define NOT 0x0E
#define CMP 0x0F

#define SEC 0x48
#define SEZ 0x49
#define SEN 0x4A
#define SEV 0x4B
#define CLC 0x4C
#define CLZ 0x4D
#define CLN 0x4E
#define CLV 0x4F

#define BCC 0x06
#define BCS 0x02
#define BNE 0x46
#define BEQ 0x42
#define BPL 0x86
#define BMI 0x82
#define BVC 0xC6
#define BVS 0xC2

#define MOV 0x40
#define STR 0x80
#define LDR 0x60

#define NOP 0x00

#define LR 0x0E
#define PC 0x0F

void openfile(char* filename); 
void closefile();

void writeinstruction(char opcode, char a, char b, char address);

#endif