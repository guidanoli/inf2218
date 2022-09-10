#include "tm_ast.h"

#include <stdbool.h>
#include <string.h>
#include <stdlib.h>

void tm_ast_state_bind(struct tm_ast_state* state, struct tm_ast_symbol* symbol, struct tm_ast_tape* tape)
{
    // TODO
}

bool tm_ast_tape_find(const char* name, struct tm_ast_tape* ast)
{
    for (; ast != NULL; ast = ast->next) {
        if (strcmp(name, ast->name) == 0) {
            return true;
        }
    }
    return false;
}

void tm_ast_tape_bind(struct tm_ast_tape* ast)
{
    for (; ast != NULL; ast = ast->next) {
        if (tm_ast_tape_find(ast->name, ast->next)) {
            fprintf(stderr, "Tape '%s' already defined\n", ast->name);
            exit(1);
        }
    }
}

bool tm_ast_symbol_find(char symbol, struct tm_ast_symbol* ast)
{
    for (; ast != NULL; ast = ast->next) {
        if (symbol == ast->symbol) {
            return true;
        }
    }
    return false;
}

void tm_ast_symbol_bind(struct tm_ast_symbol* ast)
{
    for (; ast != NULL; ast = ast->next) {
        if (tm_ast_symbol_find(ast->symbol, ast->next)) {
            fprintf(stderr, "Symbol '%c' already defined\n", ast->symbol);
            exit(1);
        }
    }
}

void tm_ast_program_bind(struct tm_ast_program* ast)
{
    tm_ast_symbol_bind(ast->symbol_list->first);
    tm_ast_tape_bind(ast->tape_list->first);
    tm_ast_state_bind(ast->state_list->first, ast->symbol_list->first, ast->tape_list->first);
}
