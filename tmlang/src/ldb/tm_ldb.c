#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

#include "tm.y.h"

extern int yylex();
YYSTYPE yylval;

int main(int argc, char** argv)
{
	int tk;
	while (tk = yylex()) {
		switch (tk) {
			case TOKEN_ID:
				printf("ID \"%s\"\n", yylval.terminal.id);
				free(yylval.terminal.id);
				break;
            case TOKEN_SYMBOLS:
                printf("SYMBOLS\n");
                break;
            case TOKEN_TAPES:
                printf("TAPES\n");
                break;
            case TOKEN_WHEN:
                printf("WHEN\n");
                break;
            case TOKEN_DO:
                printf("DO\n");
                break;
            case TOKEN_END:
                printf("END\n");
                break;
            case TOKEN_PASS:
                printf("PASS\n");
                break;
            case TOKEN_IF:
                printf("IF\n");
                break;
            case TOKEN_THEN:
                printf("THEN\n");
                break;
            case TOKEN_ELSE:
                printf("ELSE\n");
                break;
            case TOKEN_ARROW:
                printf("ARROW\n");
                break;
            case TOKEN_GOTO:
                printf("GOTO\n");
                break;
            case TOKEN_LEFT:
                printf("LEFT\n");
                break;
            case TOKEN_RIGHT:
                printf("RIGHT\n");
                break;
            case TOKEN_CHAR:
                printf("CHAR TOKEN '%c'\n", yylval.terminal.c);
                break;
			default:
				if (tk >= 0 && tk <= UCHAR_MAX)
					printf("CHAR '%c'\n", (char)tk);
				else
					printf("UNKNOWN %d\n", tk);
				break;
		}
	}
	return EXIT_SUCCESS;
}
