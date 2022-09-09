#include "tm_ast.h"

#include <stdio.h>

void tm_ast_tape_list_print(struct tm_ast_tape_list* ast) {
    printf("tapes:");
    for (struct tm_ast_tape* t = ast->first; t != NULL; t = t->next)
        printf(" %s", t->name);
    printf("\n");
}

void tm_ast_symbol_list_print(struct tm_ast_symbol_list* ast) {
    printf("symbols:");
    for (struct tm_ast_symbol* s = ast->first; s != NULL; s = s->next)
        printf(" '%c'", s->symbol);
    printf("\n");
}

void tm_ast_program_print(struct tm_ast_program* ast) {
    tm_ast_symbol_list_print(ast->symbol_list);
    tm_ast_tape_list_print(ast->tape_list);
}
