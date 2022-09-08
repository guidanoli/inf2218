#ifndef TM_AST_H
#define TM_AST_H

#include "tm_utils.h"

struct tm_ast_symbol {
    char symbol;
    struct tm_ast_symbol* next; // nullable
};

struct tm_ast_symbol_list {
    struct tm_ast_symbol* first;
    struct tm_ast_symbol* last;
};

struct tm_ast_program {
    struct tm_ast_symbol_list* symbol_list;
};

/* Program root */

extern struct tm_ast_program *root;

/* Constructors */

#define construct(type) \
((struct tm_ast_ ## type *) malloc(sizeof(struct tm_ast_ ## type)))

#endif
