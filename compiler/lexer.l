%option noyywrap
%option noinput
%option nounput

%{
    #include <stdlib.h>
    #include <stdio.h>
    #include "utils.h"
    #include "parser.tab.h"
%}

/* Numbers */
BIN "%"[01]+
DEC "#"[0-9]+
HEX "$"[0-9a-fA-F]+

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
REG [rR][0-9]+
PC  (?i:pc)
LR  (?i:lr)

/* Space */
SPACE [ \t]
LINE_RETURN [\r\n\f]

%%

{ADD}       {return tADD;}
{SUB}       {return tSUB;}
{MUL}       {return tMUL;}
{AND}       {return tAND;}
{OR}        {return tOR;}
{XOR}       {return tXOR;}
{NOT}       {return tNOT;}
{CMP}       {return tCMP;}
{SEC}       {return tSEC;}
{SEZ}       {return tSEZ;}
{SEN}       {return tSEN;}
{SEV}       {return tSEV;}
{CLC}       {return tCLC;}
{CLZ}       {return tCLZ;}
{CLN}       {return tCLN;}
{CLV}       {return tCLV;}

{BCC}       {return tBCC;}
{BCS}       {return tBCS;}
{BNE}       {return tBNE;}
{BEQ}       {return tBEQ;}
{BPL}       {return tBPL;}
{BMI}       {return tBMI;}
{BVC}       {return tBVC;}
{BVS}       {return tBVS;}

{MOV}       {return tMOV;}
{STR}       {return tSTR;}
{LDR}       {return tLDR;}

{NOP}       {return tNOP;}

{BIN}       {yylval.number=btoi(yytext); return tNUMBER;}
{DEC}       {yylval.number=itoi(yytext); return tNUMBER;}
{HEX}       {yylval.number=htoi(yytext); return tNUMBER;}

{REG}       {yylval.number=itoi(yytext); return tREGISTER;}
{PC}        {yylval.number=15; return tREGISTER;}
{LR}        {yylval.number=14; return tREGISTER;}

"~"         {return tTILDE;}
"["         {return tLBRA;}
"]"         {return tRBRA;}
","         {return tCOMMA;}

{SPACE}+    {return tSPACE;}
{LINE_RETURN} {return tRETURN;}
";".* ;

%% 
