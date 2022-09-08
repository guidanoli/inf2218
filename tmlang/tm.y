%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  #define OVFLW_ERROR "symbol table overflow"
  #define MEM_ERROR "could not allocate memory"

  // Declare stuff from Flex that Bison needs to know about:
  extern int yylex();
  extern int yyparse();
  extern void free_tape_names();
  extern FILE *yyin;
  extern int line_num;

  void yyerror(const char *s);
  int tape_count = 0;
  unsigned int state = 0;
%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  Initially (by default), yystype
// is merely a typedef of "int", but for non-trivial projects, tokens could
// be of any arbitrary data type.  So, to deal with that, the idea is to
// override yystype's default typedef to be a C union instead.  Unions can
// hold all of the types of tokens that Flex could return, and this this means
// we can return ints or floats or strings cleanly.  Bison implements this
// mechanism with the %union directive:
%union {
  int ival;
  char * sval;
}

// define the constant-string tokens:

// Define the "terminal symbol" token types and associate each with a field of the %union:
%token <ival> TAPE_INDEX

// Define the "non-terminal symbols" types and associate each with a field of the %union:

%%
// This is the actual grammar that bison will parse, but for right now it's just
// something silly to echo to the screen what bison gets from flex.  We'll
// make a real one shortly:
program:
%%

int main(int argc, char** argv) {
  // Check if file name was passed as argument
  // If not provided, reads from stdin
  if( argc > 1 )
  {
    char *file_path = argv[1];
    // Open a file handle to a particular file:
    FILE *input_file = fopen(file_path, "r");
    // Make sure it is valid:
    if (!input_file) {
      fprintf(stderr, "Can't open file '%s'.\n",file_path);
      return EXIT_FAILURE;
    }
    // Set Flex to read from it instead of defaulting to STDIN:
    yyin = input_file;
  }

  // Parse through the input:
  yyparse();

  free_tape_names();
  return EXIT_SUCCESS;
}

void yyerror(const char *s) {
  printf("Parsing error at line %d: '%s'\n",line_num,s);
}
