#include "tm_ast.h"

#include <stdbool.h>
#include <string.h>
#include <stdlib.h>

static bool tm_ast_tape_find(const char* name, struct tm_ast_tape* ast, int* index_ptr)
{
    for (int index = 0; ast != NULL; ast = ast->next, index++) {
        if (strcmp(name, ast->name) == 0) {
            *index_ptr = index;
            return true;
        }
    }
    return false;
}

static bool tm_ast_symbol_find(char symbol, struct tm_ast_symbol* ast, int* index_ptr)
{
    for (int index = 0; ast != NULL; ast = ast->next, index++) {
        if (symbol == ast->symbol) {
            *index_ptr = index;
            return true;
        }
    }
    return false;
}

static bool tm_ast_state_find(char* name, struct tm_ast_state* ast, int* index_ptr)
{
    for (int index = 0; ast != NULL; ast = ast->next, index++) {
        if (strcmp(name, ast->name) == 0) {
            *index_ptr = index;
            return true;
        }
    }
    return false;
}

void tm_ast_symbol_list_bind(struct tm_ast_symbol_list* ast)
{
    int index;
    for (struct tm_ast_symbol* s = ast->first; s != NULL; s = s->next) {
        if (tm_ast_symbol_find(s->symbol, s->next, &index)) {
            fprintf(stderr, "Symbol '%c' already declared\n", s->symbol);
            exit(1);
        }
    }
}

void tm_ast_tape_list_bind(struct tm_ast_tape_list* ast)
{
    int index;
    for (struct tm_ast_tape* t = ast->first; t != NULL; t = t->next) {
        tm_ast_symbol_list_bind(t->symbol_list);
        if (tm_ast_tape_find(t->name, t->next, &index)) {
            fprintf(stderr, "Tape '%s' already declared\n", t->name);
            exit(1);
        }
    }
}

void tm_ast_reference_bind(struct tm_ast_reference* ast, struct tm_ast_program* program)
{
    int index;
    switch (ast->tag) {
        case REF_STATE:
            if (tm_ast_state_find(ast->id, program->state_list->first, &index)) {
                ast->index = index;
            } else {
                fprintf(stderr, "No state '%s' declared\n", ast->id);
                exit(1);
            }
            break;
        case REF_TAPE:
            if (tm_ast_tape_find(ast->id, program->tape_list->first, &index)) {
                ast->index = index;
            } else {
                fprintf(stderr, "No tape '%s' declared\n", ast->id);
                exit(1);
            }
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_ast_exp_bind(struct tm_ast_exp* ast, struct tm_ast_program* program)
{
    int index;
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
            tm_ast_exp_bind(ast->u.eq.left_exp, program);
            tm_ast_exp_bind(ast->u.eq.right_exp, program);
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
    int index;
    tm_ast_stmt_bind(ast->stmt, program);
    if (tm_ast_state_find(ast->name, ast->next, &index)) {
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
