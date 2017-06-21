%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <ctype.h>
  #include "hw3.h"
  extern int yylex();
  extern FILE *yyin;

  int Cnt=0;
  int startln;

  //

  %}

  %union{
    char lexeme[30];//*lexeme?
    int iValue;
    node* nPtr;
  }

  %token <iValue> INTEGER
  %token <lexeme> STRING
  %token <lexeme> VARIABLE
  %token <lexeme> BINARY_OP Unary_Op
  %token REM
  %token GOTO
  %token LET
  %token DIM
  %token AS
  %token PRINT
  %token INPUT
  %token IF
  %token THEN
  %token EQUAL BRACKOPEN BRACKCLOSE

  %type <nPtr> Expression Command Line
  %start Program
  %left  '+' '-'
  %left  '*' '/'
  %nonassoc  UMINUS

  %%
  Program:
  Line {
    add($1);
  }
  |Line Program {
    add($1);
  }
  ;

  Line:
  INTEGER Command {
    $$=line_n($1,$2);
  }
  ;
  Command:
  REM STRING {
    $$=rem_n($2);
  }
  |GOTO INTEGER {
    $$=goto_n($2);
  }
  |LET VARIABLE EQUAL Expression {
    $$=let(var($2),$4);
  }
  |LET VARIABLE BRACKOPEN Expression BRACKCLOSE EQUAL Expression {
    $$=letdim_n(var($2),$4,$7);
  }
  |DIM VARIABLE AS BRACKOPEN Expression BRACKCLOSE {
    $$=dim_n(var($2),$5);
  }
  |PRINT Expression {
    $$=print_n($2);
  }
  |PRINT Expression BRACKOPEN Expression BRACKCLOSE{
    $$=print_dim($2,$4);
  }
  |INPUT VARIABLE {
    $$=input_n($2);
  }
  |IF Expression THEN INTEGER{
    $$=if_n($2,$4);
  }
  ;

  Expression:
  INTEGER {$$=integer($1);}
  |VARIABLE {
    $$=var($1);
  }
  |STRING {$$=string($1);}
  |Unary_Op Expression{
  }
  |Expression BINARY_OP Expression{
    $$=bin($1,$2,$3);
  }
  |'(' Expression ')'{
    $$=$2;
  }
  ;


  %%

  node *letdim_n(node *var,node *pos, node *val){
    node *p;
    if ((p = malloc(sizeof(node))) == NULL)
    yyerror("out of memory");

    p->type=LetDim_N;
    p->LetDim.var=var;
    p->LetDim.pos=pos;
    p->LetDim.val=val;

    return p;
  }
  node *dim_n(node *var,node *size){
    node *p;
    if ((p = malloc(sizeof(node))) == NULL)
    yyerror("out of memory");
    p->type=Dim_N;
    p->Dim.var=var;
    p->Dim.size=size->Int.value;

    return p;
  }

  node *let(node *var,node *val){
    node *p;
    if ((p = malloc(sizeof(node))) == NULL)
    yyerror("out of memory");
    p->type=let_N;
    p->Let.var=var;
    p->Let.val=val;

    return p;
  }

  node *rem_n(char *str){
    node*p;
    if ((p = malloc(sizeof(node))) == NULL)
    yyerror("out of memory");
    p->type=Rem_N;

    return p;
  }

  node *if_n(node *child,int line){
    node *p;
    if ((p = malloc(sizeof(node))) == NULL)
    yyerror("out of memory");

    p->type=If_N;
    p->If.child=child;
    p->If.linenum=line;

  }

  node *bin(node *n1,char *oper,node *n2){
    node *p;
    if ((p = malloc(sizeof(node))) == NULL)
    yyerror("out of memory");

    p->type=Bin_N;
    p->Bin.n1=n1;
    strcpy(p->Bin.oper,oper);
    p->Bin.n2=n2;

    return p;
  }

  node *nalloc() {
    node *p;
    if ((p = malloc(sizeof(node))) == NULL)
    printf("out of memory");
    return p;
  }

  node *integer(int value){
    node *p;
    if ((p = malloc(sizeof(node))) == NULL)
    yyerror("out of memory");
    p->type=typeInt;
    p->Int.value=value;

    return p;
  }

  node *var(char *str){
    node *p;
    if ((p = malloc(sizeof(node))) == NULL)
    yyerror("out of memory");
    p->type=typeVar;
    strcpy(p->Var.var,str);

    return p;
  }

  node *string(char *str){
    node *p;
    if ((p = malloc(sizeof(node))) == NULL)
    yyerror("out of memory");
    p->type=typeStr;
    strcpy(p->Str.str, str);

    return p;
  }

  node *goto_n(int line){
    node *p;
    if ((p = malloc(sizeof(node))) == NULL)
    yyerror("out of memory");
    p->type=goto_N;
    p->Goto.line=line;

    return p;
  }

  node *print_dim(node *var, node *pos){
    node *p;
    p=nalloc();

    p->type=PrintDim_N;
    p->PrintDim.child=var;
    p->PrintDim.pos=pos;

    return p;
  }

  node *print_n(node *child){
    node *p;
    p=nalloc();

    p->type=print_N;
    p->Print.child=child;

    return p;
  }

  node *input_n(char *str){
    node *p;
    p=nalloc();

    p->type=Input_N;
    strcpy(p->Input.str,str);

    return p;
  }

  node *line_n(int lnum,node *child){
    node *p;
    p=nalloc();

    if ((p->Line.child = malloc(sizeof(child))) == NULL)
    yyerror("out of memory");

    p->type=line_N;
    p->Line.child=child;
    p->Line.linenum=lnum;

    return p;
  }

  void add(node *p){
    ASTtree[Cnt]=p;

    startln=p->Line.linenum;

    Cnt++;
  }

  int getNext(int present){
    int nextline,i;
    for(i=0;i<Cnt;i++){
      if(ASTtree[i]->Line.linenum==present){
        if((i+1)<Cnt){
          return ASTtree[i+1]->Line.linenum;
        }
      }
    }
    return 0;
  }

  node* getNode(int linenum){
    int i;
    node *p;
    for(i=0;i<Cnt;i++){
      if(ASTtree[i]->Line.linenum==linenum){
        p=ASTtree[i]->Line.child;
        return p;
      }
    }
    printf("Undefined line number\n");
    exit(1);
    return p;
  }

  int check(char *str){
    int i;
    for (i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
      if(strcmp(symtab[i].var,"null")==0){
        return 0;
      }
      else{
        if(strcmp(symtab[i].var,str)==0)
        return 1;
      }
    }
    return 0;
  }

  int getNum(char *str){
    int i;
    if(check(str)==1){
      for(i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
        if(strcmp(symtab[i].var,str)==0)
        return symtab[i].val;

      }
    }
    else{
      printf("error\n");
      return 0;
    }
  }

  int BIN(node *p){
    node *temp=malloc(sizeof(node));
    node *temp2=malloc(sizeof(node));

    temp=p->Bin.n1;
    temp2=p->Bin.n2;
    char oper[30];
    strcpy(oper,p->Bin.oper);
    int n1,n2;

    if(temp->type==typeVar){
      n1=getNum(temp->Var.var);
    }
    if(temp->type==typeInt){
      n1=temp->Int.value;
    }
    if(temp2->type==typeVar){
      n2=getNum(temp2->Var.var);
    }
    if(temp2->type==typeInt){
      n2=temp2->Int.value;
    }

    switch (*oper) {
      case '+':
      return (n1+n2);
      break;

      case '-':
      return (n1-n2);
      break;

      case '*':
      return (n1*n2);
      break;

      case '/':
      if(n2==0){//divide by zero
        printf("Divide by Zero\n");
        exit(0);
      }
      else{
        return (n1/n2);
      }
      break;

      case '%':
      return (n1%n2);
      break;

      case '=':
      return (n1==n2);
      break;

      case '<':
      if(oper[1]=='='){
        return (n1<=n2);
        break;
      }
      else if(oper[1]=='>'){
        return (n1!=n2);
        break;
      }
      else{
        return (n1<n2);
        break;
      }

      case'>':
      if(oper[1]=='='){
        return (n1>=n2);
        break;
      }
      else{
        return (n1>n2);
        break;
      }
    }
    return 0;
  }

  int execute(int linenum, node *p){
    int next;
    int i;
    if(!p||linenum==0) return 0;

    node *temp=malloc(sizeof(node));
    node *temp2=malloc(sizeof(node));

    switch (p->type) {
      case line_N:{
        temp=getNode(linenum);
        next=execute(linenum,temp);
        return next;
        break;
      }

      case print_N:{
        temp=p->Print.child;
        if(temp->type==typeInt){
          printf("%d\n",temp->Int.value);
        }
        else if(temp->type==typeStr){
          printf("%s\n",temp->Str.str);
        }
        else if(temp->type==typeVar){
          for(i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
            if(strcmp(symtab[i].var,temp->Var.var)==0)
            printf("%d\n",symtab[i].val);

          }
        }
        else if(temp->type==Bin_N){
          int result;
          result=BIN(temp);
          printf("%d\n",result);
        }
        break;
      }

      case Dim_N:{
        temp=p->Dim.var;
        if(check(temp->Var.var)==1){
          for(i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
            if(strcmp(symtab[i].var,temp->Var.var)==0){
              symtab[i].arr=(int*)malloc(sizeof(int)*p->Dim.size);
              break;
            }
          }
        }
        else{
          for (i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
            if(strcmp(symtab[i].var,"null")==0){
              strcpy(symtab[i].var,temp->Var.var);
              symtab[i].arr=(int*)malloc(sizeof(int)*p->Dim.size);
              break;
            }
          }
        }
        break;
      }

      case PrintDim_N:{
        temp=p->PrintDim.child;
        temp2=p->PrintDim.pos;
        int pos;

        if(temp2->type==typeVar){//position이 variable 이라면
          if(check(temp2->Var.var)==1){//symtab에 있는지 검사
            for (i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
              if(strcmp(symtab[i].var,temp2->Var.var)==0){
                pos=symtab[i].val;
              }
            }
          }
          else{//symtab에 없음
            printf("Not defined Variable\n");
            exit(1);
          }
        }
        else if(temp2->type==typeInt){//position이 integer인 경우
          pos=temp2->Int.value;
        }

        if(check(temp->Var.var)==1){//symtab에서 확인
          for(i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
            if(strcmp(symtab[i].var,temp->Var.var)==0){
              if(symtab[i].arr!=NULL){
                printf("%d\n",symtab[i].arr[pos]);
              }
              else{
                printf("Array Not Defined\n");
                exit(1);
              }
            }
          }
        }
        else{
          printf("Not defined Variable\n");
          exit(1);
        }
        break;
      }

      case LetDim_N:{
        temp=p->LetDim.var;
        temp2=p->LetDim.pos;
        int pos;
        int val;
        //
        if(temp2->type==typeVar){//position이 variable 이라면
          if(check(temp2->Var.var)==1){//symtab에 있는지 검사
            for (i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
              if(strcmp(symtab[i].var,temp2->Var.var)==0){
                pos=symtab[i].val;
              }
            }
          }
          else{//symtab에 없음
            printf("Not defined Variable\n");
            exit(1);
          }
        }
        else if(temp2->type==typeInt){//position이 integer인 경우
          pos=temp2->Int.value;
        }

        //
        temp2=p->LetDim.val;
        if(temp2->type==typeVar){//value가 variable 이라면
          if(check(temp2->Var.var)==1){//symtab에 있는지 검사
            for (i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
              if(strcmp(symtab[i].var,temp2->Var.var)==0){
                val=symtab[i].val;
              }
            }
          }
          else{//symtab에 없음
            printf("Not defined Variable\n");
            exit(1);
          }
        }
        else if(temp2->type==typeInt){//value가 integer인 경우
          val=temp2->Int.value;
        }
        //

        if(check(temp->Var.var)==1){//variable이 symtab에 있는지 검사
          for(i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
            if(strcmp(symtab[i].var,temp->Var.var)==0){
              symtab[i].arr[pos]=val;

            }
          }
        }
        else{//없는경우
          printf("Not defined Variable\n");
          exit(1);
        }
        break;
      }

      case let_N:{
        temp=p->Let.var;
        if(check(temp->Var.var)==1){//이미 선언 되었다면
          for (i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
            if(strcmp(symtab[i].var,temp->Var.var)==0){
              symtab[i].val=p->Let.val->Int.value;
              break;
            }
          }
        }
        else{//이미 선언되지 않았다면
          for (i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
            if(strcmp(symtab[i].var,"null")==0){
              strcpy(symtab[i].var,temp->Var.var);
              symtab[i].val=p->Let.val->Int.value;
              break;
            }
          }
        }
        break;
      }

      case If_N:{
        temp=p->If.child;
        int result;
        if(temp->type==typeVar){
          result=getNum(temp->Var.var);
        }
        else if(temp->type==typeInt){
          result=temp->Int.value;
        }
        else if(temp->type==Bin_N){
          result=BIN(temp);
        }
        if(result!=0){
          next=p->If.linenum;
          return next;
        }

        break;
      }

      case goto_N:{
        next=p->Goto.line;

        return next;
        break;
      }

      case Rem_N:{
        next=getNext(linenum);
        return next;
        break;
      }

      case Input_N:{
        int ip;
        scanf("%d",&ip);
        if(check(p->Input.str)==1){//symtab확인
          for (i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
            if(strcmp(symtab[i].var,p->Input.str)==0){
              symtab[i].val=ip;
              break;
            }
          }
        }
        else{
          for (i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
            if(strcmp(symtab[i].var,"null")==0){
              strcpy(symtab[i].var,p->Input.str);
              symtab[i].val=ip;
              break;
            }
          }
        }
        break;
      }
    }

    next=getNext(linenum);
    return next;
  }

  void sort(){
    int num;
    int i,j;
    node *temp;
    int t;

    for(i=0;i<Cnt;i++){
      for(j=i;j>0;j--){
        if(ASTtree[j-1]->Line.linenum>ASTtree[j]->Line.linenum){
          temp=ASTtree[j-1];
          ASTtree[j-1]=ASTtree[j];
          ASTtree[j]=temp;
        }
      }
    }
  }

  void traverse(){
    sort();
    int re=startln;
    node *p=ASTtree[0];

    while(1){
      re=execute(re,p);

      if(re==0){
        break;
      }
      if(re<0){
        printf("error occured\n");
        break;
      }
    }
  }

  int printline(int l){
    int i;
    for (i=0;i<Cnt;i++){
      if(sourceTree[i].LL==l){
        printf("%s\n",sourceTree[i].source);
        return 1;
      }
    }
    return 0;
  }

  void list(){
    int i;
    for(i=0;i<Cnt;i++){
      printf("%s\n",sourceTree[i].source);
    }
  }

  int yyerror(char const *str) {
    extern char *yytext;
    fprintf(stderr, "parser error near %s\n", yytext);
    return 0;
  }

  int main(int argc, char *argv[]) {
    int i;
    int E;
    for(i=0;i<sizeof(symtab)/sizeof(symtab[0]);i++){
      strcpy(symtab[i].var,"null");
    }

    if(argc==1){
      printf("need input BASIC source\n");
    }
    if(argc>1){
      FILE *p;
      p = fopen(argv[1],"r");
      if(p != NULL) {
        yyin = fopen(argv[1],"r");
        yyparse();
        char cmd[30];
        while(1){
          printf("Enter Command (RUN, LIST, <line-num>, QUIT)\n");
          scanf("%s", cmd);
          if (strcmp(cmd, "RUN") == 0){
            traverse();
          }
          else if(strcmp(cmd,"LIST")==0){
            list();
          }
          else if(isdigit(cmd[0])) {
            int l = atoi(cmd);
            E=printline(l);
            if(E==0)
            printf("Undefined Line number\n");
          }
          else if(strcmp(cmd,"QUIT")==0){
            printf("End the program\n");
            break;
          } else
          printf("WRONG COMMAND\n");

        }
      } else {
        printf("file not found \n");

      }
    }

    return 0;
  }
