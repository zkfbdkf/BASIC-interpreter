all: hw3

y.tab.c: hw3.y
	bison -yd hw3.y

lex.yy.c: hw3.l
	flex hw3.l

hw3: y.tab.c lex.yy.c
	gcc -o hw3 y.tab.c lex.yy.c -lfl -ly
