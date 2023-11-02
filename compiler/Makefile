.PHONY: all

test: clean all
	./parser test.s test

all: utils.o compile.o symbols.o lex.yy.c parser.tab.c parser.tab.h
	gcc -o parser parser.tab.c lex.yy.c utils.o compile.o symbols.o -lm

utils.o: utils.h
	gcc utils.c -o utils.o -c -g -Wall

compile.o: compile.h
	gcc compile.c -o compile.o -c -g -Wall

symbols.o: symbols.h
	gcc symbols.c -o symbols.o -c -g -Wall

parser.tab.c parser.tab.h: parser.y
	bison -t -v -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

clean:
	rm -f *.o *.out *.yy.c *.tab.* *.output parser test