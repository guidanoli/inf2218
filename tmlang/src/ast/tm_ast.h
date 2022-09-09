#ifndef TM_AST_H
#define TM_AST_H

#include "tm_utils.h"

struct tm_ast_state_ref {
    char* name; // owned
    int index;
};

struct tm_ast_tape_ref {
    char* name; // owned
    int index;
};

struct tm_ast_exp {
    enum {
        EXP_LITERAL,
        EXP_VARIABLE,
    } tag;
    union {
        char lit;
        struct tm_ast_tape_ref tape;
    } u;
};

struct tm_ast_cond {
    enum {
        COND_EQ,
    } tag;
    union {
        struct {
            struct tm_ast_exp* left_exp; // owned
            struct tm_ast_exp* right_exp; // owned
        } eq;
    } u;
};

struct tm_ast_stmt {
    enum {
        STMT_PASS,
        STMT_SEQ,
        STMT_IFELSE,
        STMT_WRITE,
        STMT_CHSTATE,
    } tag;
    union {
        struct {
            struct tm_ast_stmt* fst_stmt; // owned
            struct tm_ast_stmt* snd_stmt; // owned
        } seq;
        struct {
            struct tm_ast_cond* cond; // owned
            struct tm_ast_stmt* then_stmt; // owned
            struct tm_ast_stmt* else_stmt; // owned
        } ifelse;
        struct {
            struct tm_ast_tape_ref tape;
            struct tm_ast_exp* value_exp; // owned
        } write;
        struct {
            struct tm_ast_state_ref state;
        } chstate;
    } u;
};

struct tm_ast_state {
    char* name; // owned
    struct tm_ast_stmt* stmt; // owned
    struct tm_ast_state* next; // nullable, owned
};

struct tm_ast_state_list {
    struct tm_ast_state* first; // owned
    struct tm_ast_state* last; // borrowed
};

struct tm_ast_tape {
    char* name; // owned
    struct tm_ast_tape* next; // nullable, owned
};

struct tm_ast_tape_list {
    struct tm_ast_tape* first; // owned
    struct tm_ast_tape* last; // borrowed
};

struct tm_ast_symbol {
    char symbol;
    struct tm_ast_symbol* next; // nullable, owned
};

struct tm_ast_symbol_list {
    struct tm_ast_symbol* first; // owned
    struct tm_ast_symbol* last; // borrowed
};

struct tm_ast_program {
    struct tm_ast_symbol_list* symbol_list; // owned
    struct tm_ast_tape_list* tape_list; // owned
    struct tm_ast_state_list* state_list; // owned
};

/* Program root */

extern struct tm_ast_program *root; // owned

/* Constructors */

#define construct(type) \
((struct tm_ast_ ## type *) malloc(sizeof(struct tm_ast_ ## type)))

/* Operations on the AST */

void tm_ast_program_destroy(struct tm_ast_program* ast);
void tm_ast_program_print(struct tm_ast_program* ast);

#endif
