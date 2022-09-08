#include "tm_ast_destroy.h"

#include <stdlib.h>

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
    free(ast);
}
