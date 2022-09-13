#include "tm_ast.h"

#include <stdbool.h>
#include <string.h>
#include <stdlib.h>

static struct tm_ast_tape* tm_ast_tape_find(const char* name, struct tm_ast_tape* ast)
{
    for (; ast != NULL; ast = ast->next) {
        if (strcmp(name, ast->name) == 0)
            break;
    }
    return ast;
}

static struct tm_ast_symbol* tm_ast_symbol_find(char symbol, struct tm_ast_symbol* ast)
{
    for (; ast != NULL; ast = ast->next) {
        if (symbol == ast->symbol)
            break;
    }
    return ast;
}

static struct tm_ast_state* tm_ast_state_find(const char* name, struct tm_ast_state* ast)
{
    for (; ast != NULL; ast = ast->next) {
        if (strcmp(name, ast->name) == 0)
            break;
    }
    return ast;
}

void tm_ast_symbol_list_bind(struct tm_ast_symbol_list* ast)
{
    for (struct tm_ast_symbol* s = ast->first; s != NULL; s = s->next) {
        if (tm_ast_symbol_find(s->symbol, s->next) != NULL) {
            fprintf(stderr, "Symbol '%c' already declared\n", s->symbol);
            exit(1);
        }
    }
}

void tm_ast_tape_list_bind(struct tm_ast_tape_list* ast)
{
    for (struct tm_ast_tape* t = ast->first; t != NULL; t = t->next) {
        tm_ast_symbol_list_bind(t->symbol_list);
        if (tm_ast_tape_find(t->name, t->next) != NULL) {
            fprintf(stderr, "Tape '%s' already declared\n", t->name);
            exit(1);
        }
    }
}

void tm_ast_reference_bind(struct tm_ast_reference* ast, struct tm_ast_program* program)
{
    struct tm_ast_state* state;
    struct tm_ast_tape* tape;
    switch (ast->tag) {
        case REF_STATE:
            state = tm_ast_state_find(ast->id, program->state_list->first);
            if (state == NULL) {
                fprintf(stderr, "No state '%s' declared\n", ast->id);
                exit(1);
            } else {
                ast->state = state;
            }
            break;
        case REF_TAPE:
            tape = tm_ast_tape_find(ast->id, program->tape_list->first);
            if (tape == NULL) {
                fprintf(stderr, "No tape '%s' declared\n", ast->id);
                exit(1);
            } else {
                ast->tape = tape;
            }
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_ast_exp_bind(struct tm_ast_exp* ast, struct tm_ast_program* program)
{
    switch (ast->tag) {
        case EXP_BLANK:
            break;
        case EXP_LITERAL:
            break;
        case EXP_VARIABLE:
            tm_ast_reference_bind(&ast->u.tape_ref, program);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_ast_cond_bind(struct tm_ast_cond* ast, struct tm_ast_program* program)
{
    switch (ast->tag) {
        case COND_EQ:
        case COND_NEQ:
            tm_ast_exp_bind(ast->u.bin_exp_op.left, program);
            tm_ast_exp_bind(ast->u.bin_exp_op.right, program);
            break;
        case COND_AND:
        case COND_OR:
            tm_ast_cond_bind(ast->u.bin_cond_op.left, program);
            tm_ast_cond_bind(ast->u.bin_cond_op.right, program);
            break;
        case COND_NOT:
            tm_ast_cond_bind(ast->u.un_cond_op, program);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_ast_stmt_bind(struct tm_ast_stmt* ast, struct tm_ast_program* program)
{
    switch (ast->tag) {
        case STMT_PASS:
            break;
        case STMT_SEQ:
            tm_ast_stmt_bind(ast->u.seq.fst_stmt, program);
            tm_ast_stmt_bind(ast->u.seq.snd_stmt, program);
            break;
        case STMT_IFELSE:
            tm_ast_cond_bind(ast->u.ifelse.cond, program);
            tm_ast_stmt_bind(ast->u.ifelse.then_stmt, program);
            tm_ast_stmt_bind(ast->u.ifelse.else_stmt, program);
            break;
        case STMT_WRITE:
            tm_ast_reference_bind(&ast->u.write.tape_ref, program);
            tm_ast_exp_bind(ast->u.write.value_exp, program);
            break;
        case STMT_MOVE:
            tm_ast_reference_bind(&ast->u.move.tape_ref, program);
            break;
        case STMT_CHSTATE:
            tm_ast_reference_bind(&ast->u.chstate.state_ref, program);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_ast_state_bind(struct tm_ast_state* ast, struct tm_ast_program* program)
{
    tm_ast_stmt_bind(ast->stmt, program);
    if (tm_ast_state_find(ast->name, ast->next) != NULL) {
        fprintf(stderr, "State '%s' already declared\n", ast->name);
        exit(1);
    }
}

void tm_ast_state_list_bind(struct tm_ast_state_list* ast, struct tm_ast_program* program)
{
    for (struct tm_ast_state* s = ast->first; s != NULL; s = s->next) {
        tm_ast_state_bind(s, program);
    }
}

void tm_ast_program_bind(struct tm_ast_program* ast)
{
    tm_ast_tape_list_bind(ast->tape_list);
    tm_ast_state_list_bind(ast->state_list, ast);
}
