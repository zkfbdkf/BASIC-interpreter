%{}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "hw3.h"
#include "y.tab.h"

char Source[100]="";
int IND=0;
int flag=0;
int ll=0;

%}

digit [0-9][0-9]*
letter  [a-zA-Z]
text  (({digit}|{letter}))*
unaryop "-"|"!"
binaryop  "+"|"*"|"-"|"/"|"%"|"="|"<"|">"|"<="|">="|"<>"|"&"|"|"
variable  {letter}+({text}|[_]{letter})*
print  "PRINT"
rem "REM"
goto "GOTO"
let "LET"
dim "DIM"
as "AS"
input "INPUT"
if "IF"
then "THEN"
equal "="
brackopen "["
brackclose "]"

%x L1 L2 L3 L4 L5 L6 L7 L8 L9

%%
{brackclose} {
  strcat(Source,yytext);
  return BRACKCLOSE;
}
{brackopen} {
  strcat(Source,yytext);
  return BRACKOPEN;
}
{digit} {
  yylval.iValue = atoi(yytext);
  strcat(Source,yytext);
  if(flag==0){
    ll=atoi(yytext);
    flag=1;
  }
  return INTEGER;
}
{print} {
  strcat(Source,yytext);
  return PRINT;
}
{rem} {
  strcat(Source,yytext);
  return REM;
}
{goto} {
  strcat(Source,yytext);
  return GOTO;
}
{dim} {
  strcat(Source,yytext);
  return DIM;
}
{as} {
  strcat(Source,yytext);
  return AS;
}
{input} {
  strcat(Source,yytext);
  return INPUT;
}
{if} {
  strcat(Source,yytext);
  return IF;
}
{then} {
  strcat(Source,yytext);
  return THEN;
}

{let}[ ]* {
  strcat(Source,yytext);
  BEGIN(L1);
  return LET;
}
<L1>[ ]*{variable} {BEGIN(L2);
  strcat(Source,yytext);strcpy(yylval.lexeme,yytext);return VARIABLE;}
<L2>[ ]*{equal}[ ]* {BEGIN(L3);strcat(Source,yytext);  return EQUAL;}
<L2>[ ]*{brackopen} {BEGIN(L4);strcat(Source,yytext); return BRACKOPEN;}

<L3>[ ]*{digit} {BEGIN(INITIAL);strcat(Source,yytext);yylval.iValue = atoi(yytext);return INTEGER;}

<L3>[ ]*{variable}[ ]* {BEGIN(L8);strcat(Source,yytext);strcpy(yylval.lexeme,yytext);return VARIABLE;}
<L8>[ ]*{binaryop}[ ]* {BEGIN(L9);strcat(Source,yytext);strcpy(yylval.lexeme,yytext);
return BINARY_OP;}
<L9>[ ]*{variable}[ ]* {BEGIN(INITIAL);strcat(Source,yytext);strcpy(yylval.lexeme,yytext);return VARIABLE;}
<L9>[ ]*{digit}[ ]* {BEGIN(INITIAL);strcat(Source,yytext);yylval.iValue = atoi(yytext);return INTEGER;}

<L4>[ ]*{variable} {BEGIN(L5);strcat(Source,yytext);strcpy(yylval.lexeme,yytext);return VARIABLE;}
<L4>[ ]*{digit} {BEGIN(L5);strcat(Source,yytext);yylval.iValue = atoi(yytext);return INTEGER;}
<L5>[ ]*{brackclose} {BEGIN(L6);strcat(Source,yytext);return BRACKCLOSE;}
<L6>[ ]*{equal}[ ]* {BEGIN(L7);strcat(Source,yytext);return EQUAL;}
<L7>{variable} {BEGIN(INITIAL);strcat(Source,yytext);strcpy(yylval.lexeme,yytext);return VARIABLE;}
<L7>{digit} {BEGIN(INITIAL);strcat(Source,yytext);yylval.iValue = atoi(yytext);return INTEGER;}


["][^"]*["] {
  strcat(Source,yytext);
  strcpy(yylval.lexeme,yytext); return STRING;
}

{variable} {
  strcat(Source,yytext);
  strcpy(yylval.lexeme,yytext);
  return (VARIABLE);
}

{binaryop}/[ ]*({variable}|{digit}) {
  strcat(Source,yytext);
  strcpy(yylval.lexeme,yytext);
  return BINARY_OP;
}

(^{variable})*[ ]*{unaryop}/[ ]*({variable}|{digit}) {
  strcat(Source,yytext);
  strcpy(yylval.lexeme,yytext);
  return Unary_Op;
}



[ \t] {strcat(Source,yytext);} /* skip whitespace */
[\n ]+ {/*store the source code for printout*/
strcpy(sourceTree[IND].source,Source);
sourceTree[IND].LL=ll;
strcpy(Source,"");
IND++;
flag=0;
}
\n|.   { return yytext[0]; }


%%
int yywrap(void) {
 return 1;
}
