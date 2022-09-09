#include "tm_ast.h"

#include <stdio.h>

static void indent(int depth) {
    while (depth--)
        putchar(' ');
}

void tm_ast_stmt_print(struct tm_ast_stmt* ast, int depth) {
    switch (ast->tag) {
        case STMT_PASS:
            indent(depth);
            printf("pass\n");
            break;
        case STMT_SEQ:
            tm_ast_stmt_print(ast->u.seq.fst_stmt, depth);
            tm_ast_stmt_print(ast->u.seq.snd_stmt, depth);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_ast_state_print(struct tm_ast_state* ast) {
    printf("when %s do\n", ast->name);
    tm_ast_stmt_print(ast->stmt, 1);
    printf("end\n");
}

void tm_ast_state_list_print(struct tm_ast_state_list* ast) {
    printf("states:\n");
    for (struct tm_ast_state* s = ast->first; s != NULL; s = s->next)
        tm_ast_state_print(s);
}

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
    tm_ast_state_list_print(ast->state_list);
}
