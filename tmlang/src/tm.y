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
    struct tm_ast_tape_list *tape_list;
    struct tm_ast_tape *tape;
}

%type <program> program
%type <symbol_list> symbol_list
%type <symbol> symbol
%type <tape_list> tape_list
%type <tape> tape

%%
program:

    TOKEN_SYMBOLS symbol_list TOKEN_TAPES tape_list
    {
        $$ = construct(program);
        $$->symbol_list = $2;
        $$->tape_list = $4;
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

tape_list :

    tape_list tape
    {
        $$ = $1;
        $$->last->next = $2;
        $$->last = $2;
    }
    | tape
    {
        $$ = construct(tape_list);
        $$->first = $$->last = $1;
    }

tape :

    TOKEN_ID
    {
        $$ = construct(tape);
        $$->name = $<terminal.id>1;
        $$->next = NULL;
    }
%%
