%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "compile.h"
%}

%code provides {
  int yylex (void);
  void yyerror (const char *);
  int correct_shift_offset(int shift);
  void next_line();
  int get_line();
}

%union {
    char* name;
    int number;
    char opcode;
}

%token tADD tSUB tMUL tAND tOR tXOR tNOT tCMP
%token tSEC tSEZ tSEN tSEV
%token tCLC tCLZ tCLN tCLV
%token tBCC tBCS tBNE tBEQ tBPL tBMI tBVC tBVS
%token tMOV tSTR tLDR
%token tNOP
%token<number> tNUMBER tREGISTER
%token tTILDE tLBRA tRBRA tCOMMA
%token tSPACE tRETURN

%type<opcode> alu_bioperand_mnemonic alu_nooperand_mnemonic branch_mnemonic memory_mnemonic

%start instructions

%%

// Rightmost derivation
instructions:
    instruction line_return {next_line();} instructions
  | instruction optionals
  ;

// Three types of instructions: ALU, branch and storing
instruction:
    alu_instruction
  | branch_instruction
  | storing_instruction 
  | tNOP                {writeinstruction(NOP, 0, 0, 0);}
  ;

// All ALU instructions
alu_instruction:
    alu_bioperand_mnemonic space tREGISTER comma tREGISTER comma tREGISTER {writeinstruction($1 | BOTH_REGISTER_MASK, $5, $7, $3);}
  | alu_bioperand_mnemonic space tREGISTER comma tNUMBER comma tREGISTER   {writeinstruction($1 | SECOND_REGISTER_MASK, $5, $7, $3);}
  | alu_bioperand_mnemonic space tREGISTER comma tREGISTER comma tNUMBER   {writeinstruction($1 | FIRST_REGISTER_MASK, $5, $7, $3);}
  | alu_bioperand_mnemonic space tREGISTER comma tNUMBER comma tNUMBER     {writeinstruction($1, $5, $7, $3);}
  | tNOT space tREGISTER comma tREGISTER                                   {writeinstruction(NOT | FIRST_REGISTER_MASK, $5, 0, $3);}
  | tNOT space tREGISTER comma tNUMBER                                     {writeinstruction(NOT, $5, 0, $3);}
  | tCMP space tREGISTER                                                   {writeinstruction(CMP | FIRST_REGISTER_MASK, $3, 0, 0);}
  | alu_nooperand_mnemonic                                                 {writeinstruction($1, 0, 0, 0);}
  ;

// Instruction mnemonics with 2 operands for ALU
alu_bioperand_mnemonic:
    tADD {$$=ADD;}
  | tSUB {$$=SUB;}
  | tMUL {$$=MUL;}
  | tAND {$$=AND;}
  | tOR  {$$=OR;}
  | tXOR {$$=XOR;}
  ;

// Instruction mnemonics with no operands for ALU
alu_nooperand_mnemonic:
    tSEC {$$=SEC;}
  | tSEZ {$$=SEZ;}
  | tSEN {$$=SEN;}
  | tSEV {$$=SEV;}
  | tCLC {$$=CLC;}
  | tCLZ {$$=CLZ;}
  | tCLN {$$=CLN;}
  | tCLV {$$=CLV;}
  ;

// All branching instructions
branch_instruction:
    branch_mnemonic space tREGISTER                          {writeinstruction($1 | REGISTER_BRANCH_ADDRESS_MASK, $3, 0, 0);}
  | branch_mnemonic space tNUMBER                            {writeinstruction($1, $3, 0, 0);}
  | branch_mnemonic space tTILDE tREGISTER                   {writeinstruction($1 | REGISTER_BRANCH_ADDRESS_MASK | USE_REGISTER_OFFSET_MASK, PC, $4, 0);}
  | branch_mnemonic space tTILDE tNUMBER                     {writeinstruction($1 | REGISTER_BRANCH_ADDRESS_MASK | USE_CONSTANT_OFFSET_MASK, PC, $4, 0);}
  | branch_mnemonic space tREGISTER comma tTILDE tREGISTER   {writeinstruction($1 | REGISTER_BRANCH_ADDRESS_MASK | USE_REGISTER_OFFSET_MASK, $3, $6, 0);}
  | branch_mnemonic space tNUMBER comma tTILDE tREGISTER     {writeinstruction($1 | USE_REGISTER_OFFSET_MASK, $3, $6, 0);}
  | branch_mnemonic space tREGISTER comma tTILDE tNUMBER     {writeinstruction($1 | REGISTER_BRANCH_ADDRESS_MASK | USE_CONSTANT_OFFSET_MASK, $3, $6, 0);}
  | branch_mnemonic space tNUMBER comma tTILDE tNUMBER       {writeinstruction($1 | USE_CONSTANT_OFFSET_MASK, $3, $6, 0);}
  ;

// Instruction mnemonics for branching
branch_mnemonic:
    tBCC {$$=BCC;}
  | tBCS {$$=BCS;}
  | tBNE {$$=BNE;}
  | tBEQ {$$=BEQ;}
  | tBPL {$$=BPL;}
  | tBMI {$$=BMI;}
  | tBVC {$$=BVC;}
  | tBVS {$$=BVS;}
  ;

// All storing instructions
storing_instruction:
    tMOV space tREGISTER comma tREGISTER                                        {writeinstruction(MOV | DIRECT_REGISTER_MASK, $5, 0, $3);}
  | tMOV space tREGISTER comma tNUMBER                                          {writeinstruction(MOV, $5, 0, $3);}
  | memory_mnemonic space tREGISTER comma tLBRA tREGISTER tRBRA                 {writeinstruction($1, $6, 0, $3);}
  | memory_mnemonic space tREGISTER comma tLBRA tREGISTER comma tREGISTER tRBRA {writeinstruction($1 | MEMORY_OFFSET_MASK, $6, $8, $3);}
  /* | memory_mnemonic space tREGISTER comma tLBRA tREGISTER comma tREGISTER        WIP !
      comma tNUMBER tRBRA                 {if (!correct_shift_offset($10)) {
                                             yyerror("Incorrect offset (must be in [0;3])");
                                           }
                                           printf("%s R%d [R%d, R%d, #%d]\n", $1, $3, $6, $8, $10);}*/
  ;

// Instruction mnemonics for memory
memory_mnemonic:
    tSTR {$$=STR;}
  | tLDR {$$=LDR;}
  ;

// [ \t]+
space:
    tSPACE optional_space
  ;

// [ \t]*
optional_space:
    tSPACE optional_space
  | %empty
  ;

// ,[ \t]*
comma:
  tCOMMA optional_space
  ;

// [\n\r\f][ \t]*
line_return:
  tRETURN optional_return
  ;

optional_return:
    tRETURN optional_return
  | %empty
  ;

// [ \t\n\r\f]*
optionals:
  tSPACE optionals
  | tRETURN optionals
  | %empty
  ;

%%

int line_number = 1;

int correct_shift_offset(int shift) {
  return 0 <= shift && shift <= 3;
}

void yyerror(const char *msg) {
  fprintf(stderr, "[ERROR]: %s at line %d\n", msg, get_line());
  exit(1);
}

void next_line() {
  line_number++;
}

int get_line() {
  return line_number;
}

int main(int argc, char** argv) {
  if (argc != 2) {
    yyerror("Wrong number of arguments!");
  }

  // Opening binary file
  openfile(argv[1]);

  // Parsing
  yyparse();

  // Closing file
  closefile();
}