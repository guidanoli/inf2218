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
    struct tm_ast_state_list *state_list;
    struct tm_ast_state *state;
    struct tm_ast_stmt *stmt;
    struct tm_ast_cond *cond;
    struct tm_ast_exp *exp;
}

%type <program> program
%type <symbol_list> symbol_list
%type <symbol> symbol
%type <tape_list> tape_list
%type <tape> tape
%type <state_list> state_list
%type <state> state
%type <stmt> stmt_list stmt
%type <cond> cond
%type <exp> exp

%%
program:

    TOKEN_SYMBOLS symbol_list TOKEN_TAPES tape_list state_list
    {
        $$ = construct(program);
        $$->symbol_list = $2;
        $$->tape_list = $4;
        $$->state_list = $5;
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

state_list :

    state_list state
    {
        $$ = $1;
        $$->last->next = $2;
        $$->last = $2;
    }
    | state
    {
        $$ = construct(state_list);
        $$->first = $$->last = $1;
    }

state :

    TOKEN_WHEN TOKEN_ID TOKEN_DO stmt_list TOKEN_END
    {
        $$ = construct(state);
        $$->name = $<terminal.id>2;
        $$->stmt = $4;
        $$->next = NULL;
    }

stmt_list :

    stmt_list stmt
    {
        $$ = construct(stmt);
        $$->tag = STMT_SEQ;
        $$->u.seq.fst_stmt = $1;
        $$->u.seq.snd_stmt = $2;
    }
    | stmt
    {
        $$ = $1;
    }

stmt :

    TOKEN_PASS
    {
        $$ = construct(stmt);
        $$->tag = STMT_PASS;
    }
    |
    TOKEN_IF cond TOKEN_THEN stmt_list TOKEN_ELSE stmt_list TOKEN_END
    {
        $$ = construct(stmt);
        $$->tag = STMT_IFELSE;
        $$->u.ifelse.cond = $2;
        $$->u.ifelse.then_stmt = $4;
        $$->u.ifelse.else_stmt = $6;
    }

cond :

    exp '=' exp
    {
        $$ = construct(cond);
        $$->tag = COND_EQ;
        $$->u.eq.left_exp = $1;
        $$->u.eq.right_exp = $3;
    }

exp :

    TOKEN_CHAR
    {
        $$ = construct(exp);
        $$->tag = EXP_LITERAL;
        $$->u.lit = $<terminal.c>1;
    }
    |
    TOKEN_ID
    {
        $$ = construct(exp);
        $$->tag = EXP_VARIABLE;
        $$->u.var.name = $<terminal.id>1;
        $$->u.var.index = -1;
    }
%%
