%{
#include <string.h>
#include "tm_utils.h"
#include "tm.y.h"
#include "tm_ast.h"

extern void yyerror(const char *s);

/* POSIX function */
extern int fileno (FILE *stream);

static int tm_lineno = 1;
%}

ID [a-zA-Z_][a-zA-Z_0-9]*
CHAR ['].[']

%option noyywrap
%%


[\n] { ++tm_lineno; }
[ \t] ;
--[^\n]* ;
"end" { return TOKEN_END; }
"if" { return TOKEN_IF; }
"then" { return TOKEN_THEN; }
"else" { return TOKEN_ELSE; }
"elseif" { return TOKEN_ELSEIF; }
"and" { return TOKEN_AND; }
"or" { return TOKEN_OR; }
"not" { return TOKEN_NOT; }
"goto" { return TOKEN_GOTO; }
"tape" { return TOKEN_TAPE; }
"function" { return TOKEN_FUNCTION; }
"left" {
	yylval.terminal.i = DIRECTION_LEFT;
	return TOKEN_DIRECTION;
}
"right" {
	yylval.terminal.i = DIRECTION_RIGHT;
	return TOKEN_DIRECTION;
}
"BLANK" { return TOKEN_BLANK; }
"==" { return TOKEN_EQ; }
"~=" { return TOKEN_NEQ; }
{ID} {
	yylval.terminal.id = tm_memdup(yytext, yyleng+1);
	return TOKEN_ID;
}
{CHAR} {
	yylval.terminal.c = yytext[1];
	return TOKEN_CHAR;
}
. { return yytext[0]; }
%%
int tm_get_lineno() {
	return tm_lineno;
}
