#include <string.h>
#include <stdio.h>

#include "tm.y.h"
#include "tm_ast.h"

void yyerror(const char* err)
{
    fprintf(stderr, "%s (line %d)\n", err, tm_get_lineno());
}

bool isdebug(int argc, char** argv)
{
    for (int argi = 0; argi < argc; ++argi) {
        if (strcmp(argv[argi], "--debug") == 0)
            return true;
    }
    return false;
}

int main(int argc, char** argv)
{
    bool debug = isdebug(argc, argv);
    int res = yyparse();
    if (!res) {
        tm_ast_program_bind(root);
        tm_ast_program_jff(root, debug);
        tm_ast_program_destroy(root);
    }
    return res;
}
