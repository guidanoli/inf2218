#include "tm_ast.h"

#include <stdlib.h>

void tm_ast_state_destroy(struct tm_ast_state* ast)
{
    free(ast->name);
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
