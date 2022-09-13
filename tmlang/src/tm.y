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
%token TOKEN_END
%token TOKEN_IF
%token TOKEN_THEN
%token TOKEN_ELSE
%token TOKEN_ELSEIF
%token TOKEN_AND
%token TOKEN_OR
%token TOKEN_GOTO
%token TOKEN_DIRECTION
%token TOKEN_BLANK
%token TOKEN_EQ
%token TOKEN_NEQ
%token TOKEN_TAPE
%token TOKEN_FUNCTION

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
%type <stmt> opt_stmt_list stmt_list stmt opt_else_stmt
%type <cond> cond primary_cond cmp_cond and_cond or_cond
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

    TOKEN_ID '=' TOKEN_TAPE '{' symbol_list '}'
    {
        $$ = construct(tape);
        $$->name = $<terminal.id>1;
        $$->symbol_list = $5;
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

    TOKEN_FUNCTION TOKEN_ID '(' ')' opt_stmt_list TOKEN_END
    {
        $$ = construct(state);
        $$->name = $<terminal.id>2;
        $$->stmt = $5;
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

    TOKEN_IF cond TOKEN_THEN opt_stmt_list opt_else_stmt TOKEN_END
    {
        $$ = construct(stmt);
        $$->tag = STMT_IFELSE;
        $$->u.ifelse.cond = $2;
        $$->u.ifelse.then_stmt = $4;
        $$->u.ifelse.else_stmt = $5;
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
    TOKEN_ID '.' TOKEN_DIRECTION '(' ')'
    {
        $$ = construct(stmt);
        $$->tag = STMT_MOVE;
        $$->u.move.tape_ref.id = $<terminal.id>1;
        $$->u.move.tape_ref.tag = REF_TAPE;
        $$->u.move.direction = $<terminal.i>3;
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

    or_cond
    {
        $$ = $1;
    }

or_cond :

    or_cond TOKEN_OR and_cond
    {
        $$ = construct(cond);
        $$->tag = COND_OR;
        $$->u.or.left_cond = $1;
        $$->u.or.right_cond = $3;
    }
    |
    and_cond
    {
        $$ = $1;
    }

and_cond :

    and_cond TOKEN_AND cmp_cond
    {
        $$ = construct(cond);
        $$->tag = COND_AND;
        $$->u.and.left_cond = $1;
        $$->u.and.right_cond = $3;
    }
    |
    cmp_cond
    {
        $$ = $1;
    }

cmp_cond :

    exp TOKEN_EQ exp
    {
        $$ = construct(cond);
        $$->tag = COND_EQ;
        $$->u.eq.left_exp = $1;
        $$->u.eq.right_exp = $3;
    }
    |
    exp TOKEN_NEQ exp
    {
        $$ = construct(cond);
        $$->tag = COND_NEQ;
        $$->u.neq.left_exp = $1;
        $$->u.neq.right_exp = $3;
    }
    |
    primary_cond
    {
        $$ = $1;
    }

primary_cond :

    '(' cond ')'
    {
        $$ = $2;
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

opt_else_stmt :

    TOKEN_ELSE opt_stmt_list
    {
        $$ = $2;
    }
    |
    TOKEN_ELSEIF cond TOKEN_THEN opt_stmt_list opt_else_stmt
    {
        $$ = construct(stmt);
        $$->tag = STMT_IFELSE;
        $$->u.ifelse.cond = $2;
        $$->u.ifelse.then_stmt = $4;
        $$->u.ifelse.else_stmt = $5;
    }
    |
    {
        $$ = construct(stmt);
        $$->tag = STMT_PASS;
    }
%%
