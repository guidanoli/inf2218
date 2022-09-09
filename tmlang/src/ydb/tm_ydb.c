#include <stdio.h>

#include "tm.y.h"
#include "tm_ast.h"

void yyerror(const char* err)
{
    fprintf(stderr, "%s (line %d)\n", err, tm_get_lineno());
}

int main(int argc, char** argv)
{
    int res = yyparse();
    if (!res) {
        // tm_ast_program_bind(root);
        tm_ast_program_print(root);
        tm_ast_program_destroy(root);
    }
    return res;
}
