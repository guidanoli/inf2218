#include "tm_ast.h"
#include "tm_vm.h"

#include <stdbool.h>
#include <stdlib.h>

static void print_xml_char(char c)
{
    // some characters need to be escaped (XML)
    switch (c) {
        case '\0': break; // blank doesn't need to be printed out
        case '"': printf("&quot;"); break;
        case '\'': printf("&apos;"); break;
        case '<': printf("&lt;"); break;
        case '>': printf("&gt;"); break;
        case '&': printf("&amp;"); break;
        default: putchar(c);
    }
}

static void print_direction(enum tm_ast_direction dir)
{
    static const char* direction_names[] = {
        [DIRECTION_STOP] = "S",
        [DIRECTION_LEFT] = "L",
        [DIRECTION_RIGHT] = "R",
    };
    
    printf("%s", direction_names[dir]);
}

static bool nothing_changed(struct vm_t* vm)
{
    if (vm->curr_state != vm->next_state)
        return false;

    for (int i = 0; i < vm->num_tapes; ++i) {
        if (vm->curr_tapes[i] != vm->next_tapes[i])
            return false;
        if (vm->next_moves[i] != DIRECTION_STOP)
            return false;
    }

    return true;
}

// Returns true if transition was generated
static bool tm_ast_vm_jff_aux2(struct vm_t* vm)
{
    tm_vm_run(vm);

    if (nothing_changed(vm))
        return false;

    printf("\t\t<transition>\n");
    printf("\t\t\t<from>%d</from>\n", vm->curr_state->index);
    printf("\t\t\t<to>%d</to>\n", vm->next_state->index);
    for (int i = 0; i < vm->num_tapes; ++i) {
        printf("\t\t\t<read tape=\"%d\">", i+1);
        print_xml_char(vm->curr_tapes[i]);
        printf("</read>\n");
        printf("\t\t\t<write tape=\"%d\">", i+1);
        print_xml_char(vm->next_tapes[i]);
        printf("</write>\n");
        printf("\t\t\t<move tape=\"%d\">", i+1);
        print_direction(vm->next_moves[i]);
        printf("</move>\n");
    }
    printf("\t\t</transition>\n");

    return true;
}

// nested loop with recursion
// Returns number of ignored transitions
static int tm_ast_vm_jff_aux1(struct vm_t* vm, struct tm_ast_tape* tape)
{
    if (tape == NULL) {
        if (tm_ast_vm_jff_aux2(vm)) {
            return 0;
        } else {
            return 1;
        }
    } else {
        int ignored = 0;
        struct tm_ast_symbol* symbol = tape->symbol_list->first;
        while (1) {
            char c = symbol == NULL ? '\0' : symbol->symbol;
            vm->curr_tapes[tape->index] = c;
            ignored += tm_ast_vm_jff_aux1(vm, tape->next);
            if (symbol == NULL) {
                break;
            } else {
                symbol = symbol->next;
            }
        }
        return ignored;
    }
}

// Return number of ignored transitions
static int tm_ast_transition_jff(struct tm_ast_state* ast, struct tm_ast_tape* tape, struct vm_t* vm)
{
    // Final states cannot have transitions
    if (ast->next == NULL) {
        return 0;
    }

    vm->curr_state = ast;
    return tm_ast_vm_jff_aux1(vm, tape);
}

static void tm_ast_state_jff(struct tm_ast_state* ast)
{
    printf("\t\t<state id=\"%d\" name=\"%s\">\n", ast->index, ast->name);
    printf("\t\t\t<x>0</x>\n");
    printf("\t\t\t<y>0</y>\n");
    if (ast->index == 0) {
        printf("\t\t\t<initial/>\n");
    }
    if (ast->next == NULL) {
        printf("\t\t\t<final/>\n");
    }
    printf("\t\t</state>\n");
}

static void tm_ast_state_list_jff(struct tm_ast_state_list* ast, struct tm_ast_tape* tape, struct vm_t* vm, bool debug)
{
    struct tm_ast_state* s;
    printf("\t\t<!--The list of states.-->\n");
    for (s = ast->first; s != NULL; s = s->next) {
        tm_ast_state_jff(s);
    }
    printf("\t\t<!--The list of transitions.-->\n");
    for (s = ast->first; s != NULL; s = s->next) {
        int ignored = tm_ast_transition_jff(s, tape, vm);
        if (debug && ignored != 0) {
            fprintf(stderr, "Debug: Ignored %d transitions from state %s\n", ignored, s->name);
        }
    }
}

void tm_ast_program_jff(struct tm_ast_program* ast, bool debug)
{
    struct vm_t vm;
    tm_vm_init(ast, &vm);

    printf("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n");
    printf("<!--Created with tmlang 0.1-->\n");
    printf("<structure>\n");
    printf("\t<type>turing</type>\n");
    printf("\t<tapes>%d</tapes>\n", vm.num_tapes);
    printf("\t<automaton>\n");
    tm_ast_state_list_jff(ast->state_list, ast->tape_list->first, &vm, debug);
    printf("\t</automaton>\n");
    printf("</structure>\n");

    tm_vm_free(&vm);
}
