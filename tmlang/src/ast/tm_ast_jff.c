#include "tm_ast.h"

#include <stdbool.h>
#include <stdlib.h>

struct env_t {
	struct tm_ast_state* curr_state;
	struct tm_ast_state* next_state;
	struct tm_ast_symbol** curr_tapes;
	struct tm_ast_symbol** next_tapes;
	enum tm_ast_direction* movements;
	int num_tapes;
	struct tm_ast_program* program;
};

void tm_ast_env_run(struct env_t* env)
{
	struct tm_ast_stmt* stmt = env->curr_state->stmt;
	if (env->next_state == NULL) {
		env->next_state = env->curr_state;
	}
	for (int i = 0; i < env->num_tapes; ++i) {
		if (env->next_tapes[i] == NULL) {
			env->next_tapes[i] = env->curr_tapes[i];
		}
	}
}

void tm_ast_symbol_jff(struct tm_ast_symbol* ast)
{
	if (ast != NULL) {
		printf("%c", ast->symbol);
	}
}

void tm_ast_direction_jff(enum tm_ast_direction dir)
{
	static const char* direction_names[] = {
		[DIRECTION_STOP] = "S",
		[DIRECTION_LEFT] = "L",
		[DIRECTION_RIGHT] = "R",
	};
	
	printf("%s", direction_names[dir]);
}

void tm_ast_env_jff_aux2(struct env_t* env)
{
	env->next_state = NULL;
	for (int i = 0; i < env->num_tapes; ++i) {
		env->next_tapes[i] = NULL;
		env->movements[i] = DIRECTION_STOP;
	}
	tm_ast_env_run(env);
	printf("\t\t<transition>\n");
	printf("\t\t\t<from>%d</from>\n", env->curr_state->index);
	printf("\t\t\t<to>%d</to>\n", env->next_state->index);
	for (int i = 0; i < env->num_tapes; ++i) {
		printf("\t\t\t<read tape=\"%d\">", i+1);
		tm_ast_symbol_jff(env->curr_tapes[i]);
		printf("</read>\n");
		printf("\t\t\t<write tape=\"%d\">", i+1);
		tm_ast_symbol_jff(env->next_tapes[i]);
		printf("</write>\n");
		printf("\t\t\t<move tape=\"%d\">", i+1);
		tm_ast_direction_jff(env->movements[i]);
		printf("</move>\n");
	}
	printf("\t\t</transition>\n");
}

static struct tm_ast_tape* tape_at(struct tm_ast_program* program, int index)
{
	struct tm_ast_tape* tape = program->tape_list->first;
	while (index > 0) {
		tape = tape->next;
		index--;
	}
	return tape;
}

// nested loop with recursion
void tm_ast_env_jff_aux1(struct env_t* env, struct tm_ast_tape* tape, struct tm_ast_symbol** tape_symbol)
{
	if (tape == NULL) {
		tm_ast_env_jff_aux2(env);
	} else {
		struct tm_ast_symbol* symbol = tape->symbol_list->first;
		while (1) {
			*tape_symbol = symbol;
			tm_ast_env_jff_aux1(env, tape->next, tape_symbol + 1);
			if (symbol == NULL) {
				break;
			} else {
				symbol = symbol->next;
			}
		};
	}
}

void tm_ast_env_jff(struct env_t* env)
{
	tm_ast_env_jff_aux1(env, env->program->tape_list->first, env->curr_tapes);
}

void tm_ast_state_jff(struct tm_ast_state* ast)
{
	printf("\t\t<state id=\"%d\" name=\"%s\">\n", ast->index, ast->name);
	printf("\t\t\t<x>0</x>\n");
	printf("\t\t\t<y>0</y>\n");
	if (ast->index == 0) {
		printf("\t\t\t<initial/>\n");
	}
	if (ast->next == NULL) {
		printf("\t\t\t<final/>\n");
	}
	printf("\t\t</state>\n");
}

void tm_ast_state_list_jff(struct tm_ast_state_list* ast, struct env_t* env)
{
	struct tm_ast_state* s;
	printf("\t\t<!--The list of states.-->\n");
	for (s = ast->first; s != NULL; s = s->next) {
		tm_ast_state_jff(s);
	}
	printf("\t\t<!--The list of transitions.-->\n");
	for (s = ast->first; s != NULL; s = s->next) {
		env->curr_state = s;
		tm_ast_env_jff(env);
	}
}

void tm_ast_env_init(struct tm_ast_program* ast, struct env_t* env)
{
	int num_tapes = 0;
	for (struct tm_ast_tape* t = ast->tape_list->first; t != NULL; t = t->next) {
		num_tapes++;
	}
	if (num_tapes > 5) {
		fprintf(stderr, "JFLAP 7.1 doesn't support Turing Machines with more than 5 tapes\n");
		exit(1);
	}
	env->program = ast;
	env->num_tapes = num_tapes;
	env->curr_tapes = (struct tm_ast_symbol**) malloc(5 * sizeof(struct tm_ast_symbol*));
	env->next_tapes = (struct tm_ast_symbol**) malloc(5 * sizeof(struct tm_ast_symbol*));
	env->movements = (enum tm_ast_direction*) malloc(5 * sizeof(enum tm_ast_direction));
}

void tm_ast_env_free(struct env_t* env)
{
	free(env->curr_tapes);
	free(env->next_tapes);
	free(env->movements);
}

void tm_ast_program_jff(struct tm_ast_program* ast)
{
	struct env_t env;
	tm_ast_env_init(ast, &env);

    printf("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n");
	printf("<!--Created with tmlang 0.1-->\n");
	printf("<structure>\n");
	printf("\t<type>turing</type>\n");
	printf("\t<tapes>%d</tapes>\n", env.num_tapes);
	printf("\t<automaton>\n");
	tm_ast_state_list_jff(ast->state_list, &env);
	printf("\t</automaton>\n");
	printf("</structure>\n");

	tm_ast_env_free(&env);
}
