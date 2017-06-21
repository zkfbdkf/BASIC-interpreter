
/*-----------------------------------------------------*/
/* This program is a Simple BASIC Interpreter          */
/* Using flex and Bison which outputs hw3 by Makefile  */
/* This program is a Simple BASIC Interpreter          */
/* 					               */
/* 					               */
/* 					               */
/* 					               */
/* implementation date: 2017. 06. 16		       */
/*-----------------------------------------------------*/

/*-----------------------------------------------------*/
   Prerequisites 

   flex;
   bison; 	

/*-----------------------------------------------------*/
  Directory must contain following files 

~$ ls
example.bas  hw3.h  hw3.l  hw3.y  Makefile

/*-----------------------------------------------------*/
  To Run the program by compiling each source file, 

~$ flex hw3.l
~$ bison -yd hw3.y
~$ gcc -o hw3 y.tab.c lex.yy.c -lfl -ly
~$ ./hw3 example.bas

/*-----------------------------------------------------*/
  When you just enter 'make', then an object file 
  called hw3 will be automatically created

~$ make
~$ ls
example.bas  hw3  hw3.h  hw3.l  hw3.y  lex.yy.c  Makefile  y.tab.c  y.tab.h

/*-----------------------------------------------------*/
  hw3 will be used to run the interpreter as follows 
  You must give the basic program source as an argument
  by putting the file name next to ./hw3 <filename>.bas

  following is an example when example.bas source code is
  given as an argument 

  This program provides a user interface as console

~$ ./hw3 example.bas 
Enter Command (RUN, LIST, <line-num>, QUIT)
LIST
10 PRINT "Give the hidden number: "
20 INPUT N
25 DIM A AS [20]
30 PRINT "Give a number: "
35 LET B = 5
40 INPUT R
45 LET A [B] = R
50 IF R = N THEN 110
60 IF R < N THEN 90
70 PRINT "C-"
80 GOTO 30
90 PRINT "C+"
100 GOTO 30
110 PRINT "CONGRATULATIONS"
115 PRINT A [B]
120 REM "print out answer"
Enter Command (RUN, LIST, <line-num>, QUIT)
RUN
"Give the hidden number: "
100
"Give a number: "
50
"C+"
"Give a number: "
200
"C-"
"Give a number: "
100
"CONGRATULATIONS"
100
Enter Command (RUN, LIST, <line-num>, QUIT)
10
10 PRINT "Give the hidden number: "
Enter Command (RUN, LIST, <line-num>, QUIT)
5
Undefined Line number
Enter Command (RUN, LIST, <line-num>, QUIT)
QUIT
End the program

/*-----------------------------------------------------*/
			AUTHOR

		HynnSik Baik 	21200349
		Yoona Kim 	21400850
	    
	     (HW3 Compiler Theory 2017-Spring)
;
/*-----------------------------------------------------*/