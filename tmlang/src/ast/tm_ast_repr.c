#include "tm_ast.h"
#include "tm_vm.h"

#include <stdbool.h>
#include <stdlib.h>

static void print_number(int n)
{
    while (n--) {
        putchar('1');
    }
}

static void print_state(struct tm_ast_state* state)
{
    putchar('Q');
    if (state->index > 0) {
        if (state->next == NULL) {
            print_number(1);
        } else {
            print_number(state->index + 1);
        }
    }
}

static void print_symbol(char symbol, char* symtable) {
    int index = 0;
    while (symtable[index] != symbol)
    {
        index++;
    }
    putchar('S');
    print_number(index);
}

static void print_direction(enum tm_ast_direction dir)
{
    static char direction_chars[] = {
        [DIRECTION_STOP] = 'S',
        [DIRECTION_LEFT] = 'E',
        [DIRECTION_RIGHT] = 'D',
    };
    
    putchar(direction_chars[dir]);
}

static void tm_ast_vm_repr_aux2(struct vm_t* vm, char* symtable)
{
    tm_vm_run(vm);

    if (vm->next_moves[0] == DIRECTION_STOP) {
        fprintf(stderr, "Cannot represent STOP (state %s, symbol %c)\n", vm->curr_state->index, vm->curr_tapes[0]);
        exit(1);
    }

    putchar('<');
    print_state(vm->curr_state);
    print_symbol(vm->curr_tapes[0], symtable);
    print_state(vm->next_state);
    print_symbol(vm->next_tapes[0], symtable);
    print_direction(vm->next_moves[0]);
    putchar('>');
}

// nested loop with recursion
static void tm_ast_vm_repr_aux1(struct vm_t* vm, char* symtable, struct tm_ast_tape* tape)
{
    if (tape == NULL) {
        tm_ast_vm_repr_aux2(vm, symtable);
    } else {
        struct tm_ast_symbol* symbol = tape->symbol_list->first;
        while (1) {
            char c = symbol == NULL ? '\0' : symbol->symbol;
            vm->curr_tapes[tape->index] = c;
            tm_ast_vm_repr_aux1(vm, symtable, tape->next);
            if (symbol == NULL) {
                break;
            } else {
                symbol = symbol->next;
            }
        };
    }
}

static void tm_ast_transition_repr(struct tm_ast_state* ast, struct tm_ast_tape* tape, char* symtable, struct vm_t* vm)
{
    // Final states cannot have transitions
    if (ast->next == NULL) {
        return;
    }

    vm->curr_state = ast;
    tm_ast_vm_repr_aux1(vm, symtable, tape);
}

static void tm_ast_state_list_repr(struct tm_ast_state_list* ast, struct tm_ast_tape* tape, char* symtable, struct vm_t* vm)
{
    struct tm_ast_state* s;
    for (s = ast->first; s != NULL; s = s->next) {
        tm_ast_transition_repr(s, tape, symtable, vm);
    }
}

static char* new_symtable(struct tm_ast_program* ast)
{
    int num_symbols = 1; // blank
    struct tm_ast_tape* tape = ast->tape_list->first;
    struct tm_ast_symbol* first_symbol = tape->symbol_list->first;
    for (struct tm_ast_symbol* symbol = first_symbol; symbol != NULL; symbol = symbol->next) {
        num_symbols++;
    }
    char* symtable = (char*) malloc(sizeof(char) * num_symbols);
    int index = 0;
    symtable[index++] = '\0';
    for (struct tm_ast_symbol* symbol = first_symbol; symbol != NULL; symbol = symbol->next) {
        symtable[index++] = symbol->symbol;
    }
    return symtable;
}

void tm_ast_program_repr(struct tm_ast_program* ast)
{
    struct vm_t vm;
    if (ast->tape_list->last->index != 0) {
        fprintf(stderr, "Can only represent Turing Machines with 1 tape only\n");
        exit(1);
    }
    char* symtable = new_symtable(ast);
    tm_vm_init(ast, &vm);
    tm_ast_state_list_repr(ast->state_list, ast->tape_list->first, symtable, &vm);
    tm_vm_free(&vm);
    free(symtable);
    putchar('\n');
}
