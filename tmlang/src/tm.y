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
%token TOKEN_WHILE
%token TOKEN_DO
%token TOKEN_END
%token TOKEN_PASS
%token TOKEN_IF
%token TOKEN_THEN
%token TOKEN_ELSE
%token TOKEN_GOTO
%token TOKEN_DIRECTION
%token TOKEN_BLANK
%token TOKEN_EQ

%union {
    /* Terminals */
    struct {
        union {
            char *id;
            char c;
            int i;
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
%type <stmt> opt_stmt_list stmt_list stmt
%type <cond> cond
%type <exp> exp

%%
program:

    tape_list state_list
    {
        $$ = construct(program);
        $$->tape_list = $1;
        $$->state_list = $2;
        root = $$;
    }

tape_list :

    tape_list tape
    {
        $$ = $1;
        $2->index = $$->last->index + 1;
        $$->last->next = $2;
        $$->last = $2;
    }
    |
    tape
    {
        $$ = construct(tape_list);
        $$->first = $$->last = $1;
        $1->index = 0;
    }

tape :

    TOKEN_ID '=' '{' symbol_list '}'
    {
        $$ = construct(tape);
        $$->name = $<terminal.id>1;
        $$->symbol_list = $4;
        $$->next = NULL;
    }

symbol_list :

    symbol_list ',' symbol
    {
        $$ = $1;
        $$->last->next = $3;
        $$->last = $3;
    }
    |
    symbol
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

state_list :

    state_list state
    {
        $$ = $1;
        $2->index = $$->last->index + 1;
        $$->last->next = $2;
        $$->last = $2;
    }
    |
    state
    {
        $$ = construct(state_list);
        $$->first = $$->last = $1;
        $1->index = 0;
    }

state :

    TOKEN_WHILE TOKEN_ID TOKEN_DO opt_stmt_list TOKEN_END
    {
        $$ = construct(state);
        $$->name = $<terminal.id>2;
        $$->stmt = $4;
        $$->next = NULL;
    }

opt_stmt_list :

    stmt_list
    {
        $$ = $1;
    }
    |
    {
        $$ = construct(stmt);
        $$->tag = STMT_PASS;
    }

stmt_list :

    stmt_list stmt
    {
        $$ = construct(stmt);
        $$->tag = STMT_SEQ;
        $$->u.seq.fst_stmt = $1;
        $$->u.seq.snd_stmt = $2;
    }
    |
    stmt
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
    TOKEN_IF cond TOKEN_THEN opt_stmt_list TOKEN_ELSE opt_stmt_list TOKEN_END
    {
        $$ = construct(stmt);
        $$->tag = STMT_IFELSE;
        $$->u.ifelse.cond = $2;
        $$->u.ifelse.then_stmt = $4;
        $$->u.ifelse.else_stmt = $6;
    }
    |
    TOKEN_ID '=' exp
    {
        $$ = construct(stmt);
        $$->tag = STMT_WRITE;
        $$->u.write.tape_ref.id = $<terminal.id>1;
        $$->u.write.tape_ref.tag = REF_TAPE;
        $$->u.write.value_exp = $3;
    }
    |
    TOKEN_DIRECTION '(' TOKEN_ID ')'
    {
        $$ = construct(stmt);
        $$->tag = STMT_MOVE;
        $$->u.move.direction = $<terminal.i>1;
        $$->u.move.tape_ref.id = $<terminal.id>3;
        $$->u.move.tape_ref.tag = REF_TAPE;
    }
    |
    TOKEN_GOTO TOKEN_ID
    {
        $$ = construct(stmt);
        $$->tag = STMT_CHSTATE;
        $$->u.chstate.state_ref.id = $<terminal.id>2;
        $$->u.chstate.state_ref.tag = REF_STATE;
    }

cond :

    exp TOKEN_EQ exp
    {
        $$ = construct(cond);
        $$->tag = COND_EQ;
        $$->u.eq.left_exp = $1;
        $$->u.eq.right_exp = $3;
    }

exp :

    TOKEN_BLANK
    {
        $$ = construct(exp);
        $$->tag = EXP_BLANK;
    }
    |
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
        $$->u.tape_ref.id = $<terminal.id>1;
        $$->u.tape_ref.tag = REF_TAPE;
    }
%%
