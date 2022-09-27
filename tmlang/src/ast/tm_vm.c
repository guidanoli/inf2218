#include "tm_vm.h"

#include <stdbool.h>
#include <stdlib.h>

static char tm_vm_exp_eval(struct vm_t* vm, struct tm_ast_exp* ast)
{
    switch (ast->tag) {
        case EXP_BLANK:
            return '\0';
        case EXP_LITERAL:
            return ast->u.lit;
        case EXP_VARIABLE:
        {
            int tape_index = ast->u.tape_ref.tape->index;
            return vm->curr_tapes[tape_index];
        }
        default:
            warn("unknown tag %d", ast->tag);
    }
}

static bool tm_vm_cond_eval(struct vm_t* vm, struct tm_ast_cond* ast)
{
    char c1, c2;
    bool b1, b2;
    switch (ast->tag) {
        case COND_EQ:
            c1 = tm_vm_exp_eval(vm, ast->u.bin_exp_op.left);
            c2 = tm_vm_exp_eval(vm, ast->u.bin_exp_op.right);
            return c1 == c2;
        case COND_NEQ:
            c1 = tm_vm_exp_eval(vm, ast->u.bin_exp_op.left);
            c2 = tm_vm_exp_eval(vm, ast->u.bin_exp_op.right);
            return c1 != c2;
        case COND_AND:
            b1 = tm_vm_cond_eval(vm, ast->u.bin_cond_op.left);
            b2 = tm_vm_cond_eval(vm, ast->u.bin_cond_op.right);
            return b1 && b2;
        case COND_OR:
            b1 = tm_vm_cond_eval(vm, ast->u.bin_cond_op.left);
            b2 = tm_vm_cond_eval(vm, ast->u.bin_cond_op.right);
            return b1 || b2;
        case COND_NOT:
            b1 = tm_vm_cond_eval(vm, ast->u.un_cond_op);
            return !b1;
        default:
            warn("unknown tag %d", ast->tag);
    }
}

static bool tm_vm_tape_contains_symbol(struct vm_t* vm, struct tm_ast_tape* tape, char symbol)
{
    if (symbol == '\0') {
        return true;
    }
    struct tm_ast_symbol_list* symbol_list = tape->symbol_list;
    for (struct tm_ast_symbol* s = symbol_list->first; s != NULL; s = s->next) {
        if (s->symbol == symbol) {
            return true;
        }
    }
    return false;
}

static void tm_vm_stmt_run(struct vm_t* vm, struct tm_ast_stmt* ast)
{
    switch (ast->tag) {
        case STMT_PASS:
            break;
        case STMT_SEQ:
            tm_vm_stmt_run(vm, ast->u.seq.fst_stmt);
            tm_vm_stmt_run(vm, ast->u.seq.snd_stmt);
            break;
        case STMT_IFELSE:
            if (tm_vm_cond_eval(vm, ast->u.ifelse.cond)) {
                tm_vm_stmt_run(vm, ast->u.ifelse.then_stmt);
            } else {
                tm_vm_stmt_run(vm, ast->u.ifelse.else_stmt);
            }
            break;
        case STMT_WRITE:
        {
            struct tm_ast_tape* tape = ast->u.write.tape_ref.tape;
            char value = tm_vm_exp_eval(vm, ast->u.write.value_exp);
            if (!tm_vm_tape_contains_symbol(vm, tape, value)) {
                fprintf(stderr, "Cannot write symbol '%c' in tape '%s' on state '%s'\n", value, tape->name, vm->curr_state->name);
                exit(1);
            }
            vm->next_tapes[tape->index] = value;
            break;
        }
        case STMT_MOVE:
        {
            struct tm_ast_tape* tape = ast->u.move.tape_ref.tape;
            enum tm_ast_direction dir = ast->u.move.direction;
            vm->next_moves[tape->index] = dir;
            break;
        }
        case STMT_CHSTATE:
        {
            struct tm_ast_state* st = ast->u.chstate.state_ref.state;
            vm->next_state = st;
            break;
        }
        default:
            warn("unknown tag %d", ast->tag);
    }
}

void tm_vm_run(struct vm_t* vm)
{
    // Initialize 'next' fields
    vm->next_state = vm->curr_state;
    for (int i = 0; i < vm->num_tapes; ++i) {
        vm->next_tapes[i] = vm->curr_tapes[i];
        vm->next_moves[i] = DIRECTION_STOP;
    }

    // Run current state's statement
    tm_vm_stmt_run(vm, vm->curr_state->stmt);
}

void tm_vm_init(struct tm_ast_program* ast, struct vm_t* vm)
{
    int num_tapes = ast->tape_list->last->index + 1;
    // TODO: num_tapes > 0
    if (num_tapes > 5) {
        fprintf(stderr, "JFLAP 7.1 doesn't support Turing Machines with more than 5 tapes\n");
        exit(1);
    }
    vm->num_tapes = num_tapes;
    vm->curr_tapes = (char*) malloc(num_tapes * sizeof(char));
    vm->next_tapes = (char*) malloc(num_tapes * sizeof(char));
    vm->next_moves = (enum tm_ast_direction*) malloc(num_tapes * sizeof(enum tm_ast_direction));
}

void tm_vm_free(struct vm_t* vm)
{
    free(vm->curr_tapes);
    free(vm->next_tapes);
    free(vm->next_moves);
}
