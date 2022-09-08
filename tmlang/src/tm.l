%{
#include <string.h>
#include "tm_utils.h"
#include "tm.y.h"

extern void yyerror(const char *s);

int line_num = 1;
%}

ID [a-zA-Z_][a-zA-Z_0-9]*

%option noyywrap
%%


[\n] { ++line_num; }
[ \t] ;
--[^\n]* ;
{ID} {
	yylval.terminal.id = tm_memdup(yytext, yyleng+1);
	return TOKEN_ID;
}
. ;
%%
