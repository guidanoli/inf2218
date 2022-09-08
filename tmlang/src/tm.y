%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  #include "tm_ast.h"

  // Declare stuff from Flex that Bison needs to know about:
  extern int yylex();
  void yyerror(const char *s);
  struct tm_ast_program* root = NULL;
%}

%token TOKEN_ID
%token TOKEN_CHAR
%token TOKEN_SYMBOLS
%token TOKEN_TAPES
%token TOKEN_WHEN
%token TOKEN_DO
%token TOKEN_END
%token TOKEN_PASS
%token TOKEN_IF
%token TOKEN_THEN
%token TOKEN_ELSE
%token TOKEN_ARROW
%token TOKEN_GOTO
%token TOKEN_LEFT
%token TOKEN_RIGHT

%union {
    /* Terminals */
    struct {
        union {
            char *id;
            char c;
        };
        size_t line;
    } terminal;
    /* AST nodes */
    struct tm_ast_program *program;
    struct tm_ast_symbol_list *symbol_list;
    struct tm_ast_symbol *symbol;
}

%type <program> program
%type <symbol_list> symbol_list
%type <symbol> symbol
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

    symbol_list
    {
        $$ = construct(program);
        $$->symbol_list = $1;
        root = $$;
    }

symbol_list :

    symbol_list symbol
    {
        $$ = $1;
        $$->last->next = $2;
        $$->last = $2;
    }
    | symbol
    {
        $$ = construct(symbol_list);
        $$->first = $$->last = $1;
    }

symbol :

    TOKEN_CHAR
    {
        $$ = construct(symbol);
        $$->symbol = $<terminal.c>1;
        $$->next = NULL;
    }
%%
