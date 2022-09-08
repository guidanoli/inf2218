%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  // Declare stuff from Flex that Bison needs to know about:
  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;
  extern int line_num;

  void yyerror(const char *s);
%}

%token TOKEN_ID
//%token TOKEN_INTEGER
//%token TOKEN_REAL
//%token TOKEN_AS
//%token TOKEN_ELSE
//%token TOKEN_FUNCTION
//%token TOKEN_IF
//%token TOKEN_NEW
//%token TOKEN_RETURN
//%token TOKEN_VAR
//%token TOKEN_WHILE
//%token TOKEN_EQ
//%token TOKEN_NE
//%token TOKEN_LE
//%token TOKEN_GE
//%token TOKEN_AND
//%token TOKEN_OR
//%token TOKEN_TYPE

%union {
    /* Terminals */
    struct {
        char *id;
        size_t line;
    } terminal;
    /* AST nodes */
    //struct monga_ast_call_t *call;
    //struct monga_ast_condition_t *condition;
    //struct monga_ast_expression_t *expression;
    //struct monga_ast_expression_list_t *expression_list;
    //struct monga_ast_variable_t *variable;
    //struct monga_ast_statement_t *statement;
    //struct monga_ast_statement_list_t *statement_list;
    //struct monga_ast_block_t *block;
    //struct monga_ast_parameter_list_t *parameter_list;
    //struct monga_ast_field_t *field;
    //struct monga_ast_field_list_t *field_list;
    //struct monga_ast_typedesc_t *typedesc;
    //struct monga_ast_def_function_t *def_function;
    //struct monga_ast_def_type_t *def_type;
    //struct monga_ast_def_variable_t *def_variable;
    //struct monga_ast_def_variable_list_t *def_variable_list;
    //struct monga_ast_definition_t *definition;
    //struct monga_ast_definition_list_t *definition_list;
    //struct monga_ast_program_t *program;
}

%type <program> program
//%type <definition_list> definition_list opt_definition_list
//%type <definition> definition
//%type <def_variable_list> def_variable_list opt_def_variable_list parameter_list opt_parameter_list
//%type <def_variable> def_variable parameter
//%type <terminal> type opt_def_function_type
//%type <def_type> def_type
//%type <typedesc> typedesc
//%type <field_list> field_list
//%type <field> field
//%type <def_function> def_function
//%type <block> block opt_else_block
//%type <statement_list> statement_list opt_statement_list
//%type <statement> statement
//%type <expression_list> opt_exp_list exp_list
//%type <expression> exp opt_exp primary_exp postfix_exp new_exp unary_exp multiplicative_exp additive_exp conditional_exp opt_item_access item_access
//%type <variable> var
//%type <condition> cond primary_cond negated_cond relational_cond equality_cond logical_and_cond logical_or_cond
//%type <call> call

%%
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

  return EXIT_SUCCESS;
}

void yyerror(const char *s) {
  printf("Parsing error at line %d: '%s'\n",line_num,s);
}
