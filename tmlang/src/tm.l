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
"symbols" { return TOKEN_SYMBOLS; }
"tapes" { return TOKEN_TAPES; }
"when" { return TOKEN_WHEN; }
"do" { return TOKEN_DO; }
"end" { return TOKEN_END; }
"pass" { return TOKEN_PASS; }
"if" { return TOKEN_IF; }
"then" { return TOKEN_THEN; }
"else" { return TOKEN_ELSE; }
"<-" { return TOKEN_ARROW; }
"goto" { return TOKEN_GOTO; }
"left" {
	yylval.terminal.i = DIRECTION_LEFT;
	return TOKEN_DIRECTION;
}
"right" {
	yylval.terminal.i = DIRECTION_RIGHT;
	return TOKEN_DIRECTION;
}
"blank" { return TOKEN_BLANK; }
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
