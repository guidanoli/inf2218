%{
  #include <string.h>
  #include "tm.tab.h"

  #define MAX_TAPE_CNT 5

  extern void yyerror(const char *s);
  extern int tape_count;

  char *tape_names[MAX_TAPE_CNT];
  int line_num = 1;
%}
%option noyywrap
%%
[ \t]         ;
[a-zA-Z]+       {
  for( int i = 0 ; i < tape_count ; i++ )
  {
    if( strcmp(tape_names[i],yytext) == 0 )
    {
      yylval.ival = i;
      return TAPE_INDEX;
    }
  }
  if( tape_count == MAX_TAPE_CNT )
  {
    yylval.ival = -1; // Error!
  }
  else
  {
    tape_names[tape_count] = strdup(yytext);
    yylval.ival = tape_count;
  }
  return TAPE_INDEX;
}
\n              { ++line_num; }
.               ;
%%
void free_tape_names()
{
  for(int i = 0; i < tape_count; i++) {
      free(tape_names[i]);
  }
}
