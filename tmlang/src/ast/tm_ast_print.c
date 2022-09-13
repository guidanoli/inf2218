#include "tm_ast.h"

#include <stdio.h>

void tm_ast_exp_print(struct tm_ast_exp* ast) {
    switch (ast->tag) {
        case EXP_BLANK:
            printf("BLANK");
            break;
        case EXP_LITERAL:
            printf("'%c'", ast->u.lit);
            break;
        case EXP_VARIABLE:
            printf("%s", ast->u.tape_ref.id);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_ast_cond_print(struct tm_ast_cond* ast) {
    switch (ast->tag) {
        case COND_EQ:
            printf("(");
            tm_ast_exp_print(ast->u.bin_exp_op.left);
            printf(" == ");
            tm_ast_exp_print(ast->u.bin_exp_op.right);
            printf(")");
            break;
        case COND_NEQ:
            printf("(");
            tm_ast_exp_print(ast->u.bin_exp_op.left);
            printf(" ~= ");
            tm_ast_exp_print(ast->u.bin_exp_op.right);
            printf(")");
            break;
        case COND_AND:
            printf("(");
            tm_ast_cond_print(ast->u.bin_cond_op.left);
            printf(" and ");
            tm_ast_cond_print(ast->u.bin_cond_op.right);
            printf(")");
            break;
        case COND_OR:
            printf("(");
            tm_ast_cond_print(ast->u.bin_cond_op.left);
            printf(" or ");
            tm_ast_cond_print(ast->u.bin_cond_op.right);
            printf(")");
            break;
        case COND_NOT:
            printf("(not ");
            tm_ast_cond_print(ast->u.un_cond_op);
            printf(")");
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_ast_stmt_print(struct tm_ast_stmt* ast, int depth) {
    static const char* direction_names[] = {
        [DIRECTION_STOP] = "stop",
        [DIRECTION_LEFT] = "left",
        [DIRECTION_RIGHT] = "right",
    };

    switch (ast->tag) {
        case STMT_PASS:
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
            printf("%s = ", ast->u.write.tape_ref.id);
            tm_ast_exp_print(ast->u.write.value_exp);
            printf("\n");
            break;
        case STMT_MOVE:
            indent(depth);
            printf("go %s in %s\n", direction_names[ast->u.move.direction], ast->u.move.tape_ref.id);
            break;
        case STMT_CHSTATE:
            indent(depth);
            printf("goto %s\n", ast->u.chstate.state_ref.id);
            break;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_ast_state_print(struct tm_ast_state* ast) {
    printf("when on state %s do\n", ast->name);
    tm_ast_stmt_print(ast->stmt, 1);
    printf("end\n");
}

void tm_ast_state_list_print(struct tm_ast_state_list* ast) {
    printf("states:\n");
    for (struct tm_ast_state* s = ast->first; s != NULL; s = s->next)
        tm_ast_state_print(s);
}

void tm_ast_symbol_list_print(struct tm_ast_symbol_list* ast) {
    for (struct tm_ast_symbol* s = ast->first; s != NULL; s = s->next)
        printf(" '%c'", s->symbol);
}

void tm_ast_tape_list_print(struct tm_ast_tape_list* ast) {
    printf("tapes:\n");
    for (struct tm_ast_tape* t = ast->first; t != NULL; t = t->next) {
        printf("%s with", t->name);
        tm_ast_symbol_list_print(t->symbol_list);
        printf("\n");
    }
}

void tm_ast_program_print(struct tm_ast_program* ast) {
    tm_ast_tape_list_print(ast->tape_list);
    tm_ast_state_list_print(ast->state_list);
}
