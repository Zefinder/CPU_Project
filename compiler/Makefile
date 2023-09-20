all: utils.o lex.yy.c parser.tab.c parser.tab.h
	gcc -o parser parser.tab.c lex.yy.c utils.o -lm

utils.o: utils.h
	gcc utils.c -o utils.o -c -g -Wall

parser.tab.c parser.tab.h: parser.y
	bison -t -v -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

test: all
	cat test.s | ./parser

clean:
	rm *.o *.out *.yy.c *.tab.* *.output parser