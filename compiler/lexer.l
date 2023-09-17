%{
    #include <stdlib.h>
    #include <stdio.h>
    #include "utils.h"
%}
%option noyywrap
%option noinput
%option nounput

/* Numbers */
BIN "%"[01]*
DEC "#"[0-9]*
HEX "$"[0-9a-fA-F]*

/* ALU (16 operations) */
ADD (?i:add)
SUB (?i:sub)
MUL (?i:mul)
AND (?i:and)
OR  (?i:or)
XOR (?i:xor)
NOT (?i:not)
CMP (?i:cmp)
SEC (?i:sec)
SEZ (?i:sez)
SEN (?i:sen)
SEV (?i:sev)
CLC (?i:clc)
CLZ (?i:clz)
CLN (?i:cln)
CLV (?i:clv)

/* Branches (8 operations) */
BCC (?i:bcc)
BCS (?i:bcs)
BNE (?i:bne)
BEQ (?i:beq)
BPL (?i:bpl)
BMI (?i:bmi)
BVC (?i:bvc)
BVS (?i:bvs)

/* Stores (3 operations) */
MOV (?i:mov)
STR (?i:str)
LDR (?i:ldr)

/* NOP */
NOP (?i:nop)

/* Registers */
PC  (?i:pc)
LR  (?i:lr)
REG [rR][0-9]*

/* Space */
SPACE [ \t]
NON_SPACE [\r\n\f]

%%

{ADD}       {printf("ADD \n");}

{BIN}       {printf("Binary number found: %s\n", btoi(yytext));}
{DEC}       {printf("Decimal number found: %s\n", itoi(yytext));}
{HEX}       {printf("Hexadecimal number found: %s\n", htoi(yytext));}

{REG}       {printf("Register found: %s\n", yytext);}
{PC}        {printf("PC register found\n");}
{LR}        {printf("LR register found\n");}

{SPACE}     {}
{NON_SPACE} {printf("\n");}

<<EOF>> {yyterminate();}

%% 

int main(int argc, char** argv) {
    if (argc == 1) {
        printf("No file to read\n");
        exit(1);
    }

    FILE* file;
    file = fopen(argv[1], "r");
    yyin = file;
    yylex();
    fclose(file);
}