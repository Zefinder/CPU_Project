%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%code provides {
  int yylex (void);
  void yyerror (const char *);
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
%token tSPACE

%type<name> alu_bioperand_mnemonic

%%

instructions:
    instruction instructions
  | instruction
  ;

instruction:
    alu_instruction
    ;

alu_instruction:
    alu_bioperand_mnemonic tSPACE tREGISTER tSPACE tREGISTER tSPACE tREGISTER {printf("%s R%d R%d R%d\n", $1, $3, $5, $7);}
  | alu_bioperand_mnemonic tSPACE tREGISTER tSPACE tNUMBER tSPACE tREGISTER   {printf("%s R%d $%X R%d\n", $1, $3, $5, $7);}
  | alu_bioperand_mnemonic tSPACE tREGISTER tSPACE tREGISTER tSPACE tNUMBER   {printf("%s R%d R%d $%X\n", $1, $3, $5, $7);}
  | alu_bioperand_mnemonic tSPACE tREGISTER tSPACE tNUMBER tSPACE tNUMBER     {printf("%s R%d $%X $%X\n", $1, $3, $5, $7);}
    ;

alu_bioperand_mnemonic:
    tADD {$$="ADD";}
  | tSUB {$$="SUB";}
  | tMUL {$$="MUL";}
  | tAND {$$="AND";}
  | tOR  {$$="OR";}
  | tXOR {$$="XOR";}

%%

void yyerror(const char *msg) {
  fprintf(stderr, "error: %s\n", msg);
  exit(1);
}

int main(void) {
  yyparse();
}