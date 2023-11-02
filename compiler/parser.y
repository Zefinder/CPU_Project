%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "compile.h"
  #include "utils.h"
  #include "symbols.h"

  extern FILE* yyin;
  extern void YY_FLUSH_BUFFER;
%}

%code provides {
  int yylex(void);
  void yyerror(const char *);
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
%token tSPACE tRETURN

%token<name> tLABEL tCONSTANT
%right tOADD tOSUB tOMUL tODIV tOAND tOXOR tOOR
%nonassoc tOLSHIFT tORSHIFT
%token tOLOW tOHIGH tOVHIGH

%token tTILDE tLPAR tRPAR tLBRA tRBRA tCOMMA tEQUALS tCOLUMN

%type<opcode> alu_bioperand_mnemonic alu_nooperand_mnemonic branch_mnemonic memory_mnemonic
%type<number> literal symbol arithmeticExpr xorExpr andExpr shiftExpr additiveExpr multiplicativeExpr unaryExpr parenthesisExpr

%start instructions

%%

// Rightmost derivation
instructions:
    symbolDeclaration line_return {next_line();} instructions
  | symbolDeclaration optionals
  | instruction line_return {next_line();} instructions
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
  | alu_bioperand_mnemonic space tREGISTER comma literal comma tREGISTER   {writeinstruction($1 | SECOND_REGISTER_MASK, $5, $7, $3);}
  | alu_bioperand_mnemonic space tREGISTER comma tREGISTER comma literal   {writeinstruction($1 | FIRST_REGISTER_MASK, $5, $7, $3);}
  | alu_bioperand_mnemonic space tREGISTER comma literal comma literal     {writeinstruction($1, $5, $7, $3);}
  | tNOT space tREGISTER comma tREGISTER                                   {writeinstruction(NOT | FIRST_REGISTER_MASK, $5, 0, $3);}
  | tNOT space tREGISTER comma literal                                     {writeinstruction(NOT, $5, 0, $3);}
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
  | branch_mnemonic space literal                            {writeinstruction($1, $3, 0, 0);}
  | branch_mnemonic space tTILDE tREGISTER                   {writeinstruction($1 | REGISTER_BRANCH_ADDRESS_MASK | USE_REGISTER_OFFSET_MASK, PC, $4, 0);}
  | branch_mnemonic space tTILDE literal                     {writeinstruction($1 | REGISTER_BRANCH_ADDRESS_MASK | USE_CONSTANT_OFFSET_MASK, PC, $4, 0);}
  | branch_mnemonic space tREGISTER comma tTILDE tREGISTER   {writeinstruction($1 | REGISTER_BRANCH_ADDRESS_MASK | USE_REGISTER_OFFSET_MASK, $3, $6, 0);}
  | branch_mnemonic space literal comma tTILDE tREGISTER     {writeinstruction($1 | USE_REGISTER_OFFSET_MASK, $3, $6, 0);}
  | branch_mnemonic space tREGISTER comma tTILDE literal     {writeinstruction($1 | REGISTER_BRANCH_ADDRESS_MASK | USE_CONSTANT_OFFSET_MASK, $3, $6, 0);}
  | branch_mnemonic space literal comma tTILDE literal       {writeinstruction($1 | USE_CONSTANT_OFFSET_MASK, $3, $6, 0);}
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
  | tMOV space tREGISTER comma literal                                          {writeinstruction(MOV, $5, 0, $3);}
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

symbolDeclaration:
    tCONSTANT optional_space tEQUALS optional_space arithmeticExpr {create_symbol($1, $5);}
  | tLABEL tCOLUMN {create_symbol($1, get_line() * INSTRUCTION_SIZE);}
  ;

// Constants and labels
literal: 
    tNUMBER {$$ = $1;}
  | symbol  {$$ = $1;}
  ;

symbol:
    tCONSTANT {$$ = get_symbol($1);}
  | tLABEL    {$$ = get_symbol($1);} 
  ;

arithmeticExpr:
    arithmeticExpr tOOR arithmeticExpr  {$$ = $1 | $3;}
  | xorExpr                             {$$ = $1;}
  ;

xorExpr:
    xorExpr tOXOR xorExpr {$$ = $1 ^ $3;}
  | andExpr               {$$ = $1;}
  ;

andExpr:
    andExpr tOAND andExpr {$$ = $1 & $3;}
  | shiftExpr             {$$ = $1;}
  ;

shiftExpr:
    shiftExpr tOLSHIFT shiftExpr  {$$ = $1 << $3;}
  | shiftExpr tORSHIFT shiftExpr  {$$ = $1 >> $3;}
  | additiveExpr                  {$$ = $1;}
  ;

additiveExpr:
    additiveExpr tOADD additiveExpr {$$ = $1 + $3;}
  | additiveExpr tOSUB additiveExpr {$$ = $1 - $3;}
  | multiplicativeExpr              {$$ = $1;}
  ;

multiplicativeExpr:
    multiplicativeExpr tOMUL multiplicativeExpr {$$ = $1 * $3;}
  | multiplicativeExpr tODIV multiplicativeExpr {$$ = $1 / $3;}
  | parenthesisExpr                             {$$ = $1;}
  | unaryExpr                                   {$$ = $1;}
  | literal                                     {$$ = $1;}
  ;

unaryExpr:
    tOLOW literal           {$$ = $2 & 0xFF;}
  | tOHIGH literal          {$$ = ($2 >> 8) & 0xFF;}
  | tOVHIGH literal         {$$ = ($2 >> 16) & 0xFF;}
  | tOSUB literal           {$$ = -$2;}
  | tTILDE literal          {$$ = ~$2;}
  | tOLOW parenthesisExpr   {$$ = $2 & 0xFF;}
  | tOHIGH parenthesisExpr  {$$ = ($2 >> 8) & 0xFF;}
  | tOVHIGH parenthesisExpr {$$ = ($2 >> 16) & 0xFF;}
  | tOSUB parenthesisExpr   {$$ = -$2;}
  | tTILDE parenthesisExpr  {$$ = ~$2;}
  ;

parenthesisExpr:
    tLPAR arithmeticExpr tRPAR  {$$ = $2;}
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

// [\n\r\f]*
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
  error_message("%s at line %d...\n", msg, get_line());
  exit(1);
}

void next_line() {
  line_number++;
}

int get_line() {
  return line_number;
}

void opensrc(char* filename) {
  // Opening text file
  if(!(yyin = fopen(filename,"r"))){ 
    error_message("cannot open input file!\n");
    exit(1);
  }
}

int main(int argc, char** argv) {
  if (argc != 3) {
    error_message("wrong number of arguments (expected: input_file output_file)!\n");
  }

  // Opening text file
  opensrc(argv[1]);

  // Read symbols
  set_mode(SYMBOL_MODE);
  yyparse();

  // Flush Bison
  fclose(yyin);
  opensrc(argv[1]);
  YY_FLUSH_BUFFER;

  // Open binary file
  openfile(argv[2]);

  // Parse file
  set_mode(INSTRUCTION_MODE);
  yyparse();

  // Clear all symbols
  clear_symbols();

  // Close files
  fclose(yyin);
  closefile();
}