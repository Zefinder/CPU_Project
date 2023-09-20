%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
%}

%code provides {
  int yylex (void);
  void yyerror (const char *);
  int correct_shift_offset(int shift);
  void print_warning(char* message);
}

%union {
    char* name;
    int number;
}

%token tADD tSUB tMUL tAND tOR tXOR tNOT tCMP
%token tSEC tSEZ tSEN tSEV
%token tCLC tCLZ tCLN tCLV
%token tBCC tBCS tBNE tBEQ tBPL tBMI tBVC tBVS
%token tMOV tSTR tLDR
%token tNOP
%token<number> tNUMBER tREGISTER
%token tTILDE tLBRA tRBRA tCOMMA
%token tSPACE

%type<name> alu_bioperand_mnemonic alu_nooperand_mnemonic branch_mnemonic

%start instructions

%%

// Rightmost derivation
instructions:
    instruction instructions
  | instruction
  ;

// Three types of instructions: ALU, branch and storing
instruction:
    alu_instruction
  | branch_instruction
  | tSPACE // Here to allow spaces after an instruction
  ;

// All ALU instructions
alu_instruction:
    alu_bioperand_mnemonic tSPACE tREGISTER tSPACE tREGISTER tSPACE tREGISTER {printf("%s R%d R%d R%d\n", $1, $3, $5, $7);}
  | alu_bioperand_mnemonic tSPACE tREGISTER tSPACE tNUMBER tSPACE tREGISTER   {printf("%s R%d $%X R%d\n", $1, $3, $5, $7);}
  | alu_bioperand_mnemonic tSPACE tREGISTER tSPACE tREGISTER tSPACE tNUMBER   {printf("%s R%d R%d $%X\n", $1, $3, $5, $7);}
  | alu_bioperand_mnemonic tSPACE tREGISTER tSPACE tNUMBER tSPACE tNUMBER     {printf("%s R%d $%X $%X\n", $1, $3, $5, $7);}
  | tNOT tSPACE tREGISTER                                                     {printf("NOT R%d\n", $3);}
  | tNOT tSPACE tNUMBER                                                       {printf("NOT $%d\n", $3);}
  | tCMP tSPACE tREGISTER                                                     {printf("CMP R%d\n", $3);}
  | alu_nooperand_mnemonic                                                    {printf("%s\n", $1);}
  ;

// Instruction mnemonics with 2 operands for ALU
alu_bioperand_mnemonic:
    tADD {$$="ADD";}
  | tSUB {$$="SUB";}
  | tMUL {$$="MUL";}
  | tAND {$$="AND";}
  | tOR  {$$="OR";}
  | tXOR {$$="XOR";}
  ;

// Instruction mnemonics with no operands for ALU
alu_nooperand_mnemonic:
    tSEC {$$="SEC";}
  | tSEZ {$$="SEZ";}
  | tSEN {$$="SEN";}
  | tSEV {$$="SEV";}
  | tCLC {$$="CLC";}
  | tCLZ {$$="CLZ";}
  | tCLN {$$="CLN";}
  | tCLV {$$="CLV";}
  ;

// All branching instructions
branch_instruction:
    branch_mnemonic tSPACE tREGISTER                          {printf("%s R%d\n", $1, $3);}
  | branch_mnemonic tSPACE tNUMBER                            {printf("%s $%X\n", $1, $3);}
  | branch_mnemonic tSPACE tTILDE tREGISTER                   {printf("%s (PC) ~R%d\n", $1, $4);}
  | branch_mnemonic tSPACE tTILDE tNUMBER                     {printf("%s (PC) ~$%X\n", $1, $4);}
  | branch_mnemonic tSPACE tREGISTER tSPACE tTILDE tREGISTER  {printf("%s R%d ~R%d\n", $1, $3, $6);}
  | branch_mnemonic tSPACE tNUMBER tSPACE tTILDE tREGISTER    {printf("%s $%X ~R%d\n", $1, $3, $6);}
  | branch_mnemonic tSPACE tREGISTER tSPACE tTILDE tNUMBER    {printf("%s R%d ~$%X\n", $1, $3, $6);}
  | branch_mnemonic tSPACE tNUMBER tSPACE tTILDE tNUMBER      {printf("%s $%X ~$%X\n", $1, $3, $6);}
  ;

// Instruction mnemonics for branching
branch_mnemonic:
    tBCC {$$="BCC";}
  | tBCS {$$="BCS";}
  | tBNE {$$="BNE";}
  | tBEQ {$$="BEQ";}
  | tBPL {$$="BPL";}
  | tBMI {$$="BMI";}
  | tBVC {$$="BVC";}
  | tBVS {$$="BVS";}
  ;

%%

int correct_shift_offset(int shift) {
  return 0 <= shift && shift <= 3;
}

void print_warning(char* message) {
  printf("[WARNING]: %s\n", message);
}

void yyerror(const char *msg) {
  fprintf(stderr, "[ERROR]: %s\n", msg);
  exit(1);
}

int main(void) {
  yyparse();
}