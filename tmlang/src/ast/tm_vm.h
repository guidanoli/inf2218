#ifndef tm_vm_h
#define tm_vm_h

#include "tm_ast.h"

struct vm_t {
    struct tm_ast_state* curr_state;
    struct tm_ast_state* next_state;
    int num_tapes;
    char* curr_tapes;
    char* next_tapes;
    enum tm_ast_direction* next_moves;
};

void tm_vm_init(struct tm_ast_program* ast, struct vm_t* vm);
void tm_vm_free(struct vm_t* vm);
void tm_vm_run(struct vm_t* vm);

#endif
