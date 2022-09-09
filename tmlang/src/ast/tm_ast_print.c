#include "tm_ast.h"

#include <stdio.h>

static void indent(int depth) {
    while (depth--)
        putchar(' ');
}

void tm_ast_exp_print(struct tm_ast_exp* ast) {
    switch (ast->tag) {
        case EXP_LITERAL:
            printf("'%c'", ast->u.lit);
            break;
        case EXP_VARIABLE:
            printf("%s", ast->u.tape.name);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_ast_cond_print(struct tm_ast_cond* ast) {
    switch (ast->tag) {
        case COND_EQ:
            tm_ast_exp_print(ast->u.eq.left_exp);
            printf(" = ");
            tm_ast_exp_print(ast->u.eq.right_exp);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
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
        case STMT_IFELSE:
            indent(depth);
            printf("if ");
            tm_ast_cond_print(ast->u.ifelse.cond);
            printf(" then\n");
            tm_ast_stmt_print(ast->u.ifelse.then_stmt, depth+1);
            indent(depth);
            printf("else\n");
            tm_ast_stmt_print(ast->u.ifelse.else_stmt, depth+1);
            indent(depth);
            printf("end\n");
            break;
        case STMT_WRITE:
            indent(depth);
            printf("%s <- ", ast->u.write.tape.name);
            tm_ast_exp_print(ast->u.write.value_exp);
            printf("\n");
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
