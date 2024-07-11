" Vim syntax file
" Language:		Adrien's Mysterious Assembler? (In Progress)

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case ignore

syn match asmIdentifier		"[a-z_][a-z0-9_]*"

syn match asmNumber		"\<[0-9A-F]\+\>"	 display

syn match asmRegister		"\<R\d\>"
syn match asmRegister		"\<R1[0-5]\>"
syn match asmRegister		"\<LR\>"
syn match asmRegister		"\<PC\>"

syn match asmInstruction	"nop"
syn match asmInstruction	"mov"
syn match asmInstruction	"str"
syn match asmInstruction	"ldr"
syn match asmInstruction	"bcs"
syn match asmInstruction	"bcc"
syn match asmInstruction	"beq"
syn match asmInstruction	"bne"
syn match asmInstruction	"bmi"
syn match asmInstruction	"bpl"
syn match asmInstruction	"bvs"
syn match asmInstruction	"bvc"
syn match asmInstruction	"add"
syn match asmInstruction	"sub"
syn match asmInstruction	"mul"
syn match asmInstruction	"and"
syn match asmInstruction	"or"
syn match asmInstruction	"xor"
syn match asmInstruction	"not"
syn match asmInstruction	"cmp"
syn match asmInstruction	"sec"
syn match asmInstruction	"sez"
syn match asmInstruction	"sen"
syn match asmInstruction	"sev"
syn match asmInstruction	"clc"
syn match asmInstruction	"clz"
syn match asmInstruction	"cln"
syn match asmInstruction	"clv"
syn match asmInstruction	"strmv"
syn match asmInstruction	"stregmv"
syn match asmInstruction	"strmemv"
syn match asmInstruction	"swap"

syn match asmComment		";.*" contains=@Spell

syn match asmDirective		"\.[A-Za-z][0-9A-Za-z-_]*"
syn match asmLabel		"[a-z_][a-z0-9_]*:"he=e-1

syn case match

" Define the default highlighting.
" Only when an item doesn't have highlighting yet

" The default methods for highlighting.  Can be overridden later
hi def link asmComment		Comment
hi def link asmDirective	Macro
hi def link asmLabel		Label

hi def link asmIdentifier	Identifier
hi def link asmNumber		Number
hi def link asmRegister		Constant
hi def link asmInstruction	Statement

let b:current_syntax = "assembly"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: nowrap sw=2 sts=2 ts=8 noet
