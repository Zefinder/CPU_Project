all: parser.c
	gcc parser.c -o parser

testlex: lexer.yy.c utils.o
	gcc -lfl utils.o lex.yy.c -lm
	./a.out test.s

utils.o: utils.h
	gcc utils.c -o utils.o -c

parser.c: lexer.yy.c
	bison parser.y

lexer.yy.c: lexer.l
	flex lexer.l

clean:
	rm *.o *.out *.yy.c