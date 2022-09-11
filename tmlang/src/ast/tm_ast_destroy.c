#include "tm_ast.h"

#include <stdlib.h>

void tm_ast_exp_destroy(struct tm_ast_exp* ast)
{
    switch (ast->tag) {
        case EXP_BLANK:
            break;
        case EXP_LITERAL:
            break;
        case EXP_VARIABLE:
            free(ast->u.tape_ref.id);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
    free(ast);
}

void tm_ast_cond_destroy(struct tm_ast_cond* ast)
{
    switch (ast->tag) {
        case COND_EQ:
            tm_ast_exp_destroy(ast->u.eq.left_exp);
            tm_ast_exp_destroy(ast->u.eq.right_exp);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
    free(ast);
}

void tm_ast_stmt_destroy(struct tm_ast_stmt* ast)
{
    switch (ast->tag) {
        case STMT_PASS:
            break;
        case STMT_SEQ:
            tm_ast_stmt_destroy(ast->u.seq.fst_stmt);
            tm_ast_stmt_destroy(ast->u.seq.snd_stmt);
            break;
        case STMT_IFELSE:
            tm_ast_cond_destroy(ast->u.ifelse.cond);
            tm_ast_stmt_destroy(ast->u.ifelse.then_stmt);
            tm_ast_stmt_destroy(ast->u.ifelse.else_stmt);
            break;
        case STMT_WRITE:
            free(ast->u.write.tape_ref.id);
            tm_ast_exp_destroy(ast->u.write.value_exp);
            break;
        case STMT_MOVE:
            free(ast->u.move.tape_ref.id);
            break;
        case STMT_CHSTATE:
            free(ast->u.chstate.state_ref.id);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
    free(ast);
}

void tm_ast_state_destroy(struct tm_ast_state* ast)
{
    free(ast->name);
    tm_ast_stmt_destroy(ast->stmt);
    if (ast->next)
        tm_ast_state_destroy(ast->next);
    free(ast);
}

void tm_ast_tape_destroy(struct tm_ast_tape* ast)
{
    free(ast->name);
    if (ast->next)
        tm_ast_tape_destroy(ast->next);
    free(ast);
}

void tm_ast_symbol_destroy(struct tm_ast_symbol* ast)
{
    if (ast->next)
        tm_ast_symbol_destroy(ast->next);
    free(ast);
}

void tm_ast_program_destroy(struct tm_ast_program* ast)
{
    tm_ast_symbol_destroy(ast->symbol_list->first);
    free(ast->symbol_list);
    tm_ast_tape_destroy(ast->tape_list->first);
    free(ast->tape_list);
    tm_ast_state_destroy(ast->state_list->first);
    free(ast->state_list);
    free(ast);
}
