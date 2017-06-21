typedef enum { typeInt, typeStr,typeVar, print_N, line_N,goto_N,let_N,Input_N,Bin_N,If_N,Rem_N, Dim_N,LetDim_N,PrintDim_N} nodeEnum;

typedef struct {
    int value;
} IntegerType;

typedef struct {
    char var[30];
    int val;
} VarType;

typedef struct {
    char str[30];
} StringType;

typedef struct{
  struct Node *var;
  struct Node *val;
} LetNode;

typedef struct{
  struct Node *var;
  int size;
} DimNode;

typedef struct{
  struct Node *var;
  struct Node *pos;
  struct Node *val;
} LetDimNode;

typedef struct{
  int line;
} GotoNode;

typedef struct{
  int line;
} RemNode;

typedef struct {
	struct Node *child;
} PrintNode;

typedef struct {
	struct Node *child;
  struct Node *pos;
} PrintDimNode;

typedef struct {
	struct Node *n1;
  char oper[30];
  struct Node *n2;
} BinNode;

typedef struct {
	char str[30];
} InputNode;

typedef struct {
	int linenum;
  struct Node *child;
} LineNode;

typedef struct {
	int linenum;
  struct Node *child;
} IfNode;

typedef struct Node {
    nodeEnum type;              /* type of node */
    union {
        IntegerType Int;
        VarType Var;
        StringType Str;
        PrintNode Print;
        LineNode Line;
        GotoNode Goto;
        LetNode Let;
        InputNode Input;
        BinNode Bin;
        IfNode If;
        RemNode Rem;
        DimNode Dim;
        LetDimNode LetDim;
        PrintDimNode PrintDim;
    };
} node;

struct symbol{
  char var[30];
  int val;
  int *arr;
};

struct source{
  int LL;
  char source[100];
};

node *integer(int value);
node *var(char *str);
node *string(char *str);
node *print_n(node *child);
node *line_n(int lnum, node *child);
node *goto_n(int line);
node *let(node *var,node *value);
node *input_n(char *str);
node *bin(node *n1,char *oper,node *n2);
node *if_n(node *p,int line);
node *rem_n(char *str);
node *dim_n(node *var,node *size);
node *letdim_n(node *var,node *pos, node *val);
node *print_dim(node *var, node *pos);

int execute(int linenum,node *p);
void traverse();
void add(node *p);

node* ASTtree[50];

struct symbol symtab[50];
struct source sourceTree[50];
