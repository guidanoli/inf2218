#include "tm_ast.h"

#include <stdbool.h>
#include <stdlib.h>

struct env_t {
	struct tm_ast_state* curr_state;
	struct tm_ast_state* next_state;
	char* curr_tapes;
	char* next_tapes;
	enum tm_ast_direction* next_move;
	int num_tapes;
	struct tm_ast_program* program;
};

void tm_ast_env_prerun(struct env_t* env)
{
	env->next_state = env->curr_state;
	for (int i = 0; i < env->num_tapes; ++i) {
		env->next_tapes[i] = env->curr_tapes[i];
		env->next_move[i] = DIRECTION_STOP;
	}
}

char tm_ast_exp_eval(struct env_t* env, struct tm_ast_exp* ast)
{
    switch (ast->tag) {
        case EXP_BLANK:
			return '\0';
        case EXP_LITERAL:
			return ast->u.lit;
        case EXP_VARIABLE:
		{
			int tape_index = ast->u.tape_ref.tape->index;
			return env->curr_tapes[tape_index];
		}
        default:
            warn("unknown tag %d", ast->tag);
    }
}

bool tm_ast_cond_eval(struct env_t* env, struct tm_ast_cond* ast)
{
	char c1, c2;
	bool b1, b2;
	switch (ast->tag) {
        case COND_EQ:
            c1 = tm_ast_exp_eval(env, ast->u.eq.left_exp);
            c2 = tm_ast_exp_eval(env, ast->u.eq.right_exp);
			return c1 == c2;
		case COND_NEQ:
            c1 = tm_ast_exp_eval(env, ast->u.neq.left_exp);
            c2 = tm_ast_exp_eval(env, ast->u.neq.right_exp);
			return c1 != c2;
		case COND_AND:
			b1 = tm_ast_cond_eval(env, ast->u.and.left_cond);
			b2 = tm_ast_cond_eval(env, ast->u.and.right_cond);
			return b1 && b2;
		case COND_OR:
			b1 = tm_ast_cond_eval(env, ast->u.or.left_cond);
			b2 = tm_ast_cond_eval(env, ast->u.or.right_cond);
			return b1 || b2;
        default:
            warn("unknown tag %d", ast->tag);
	}
}

void tm_ast_stmt_run(struct env_t* env, struct tm_ast_stmt* ast)
{
	switch (ast->tag) {
        case STMT_PASS:
            break;
        case STMT_SEQ:
            tm_ast_stmt_run(env, ast->u.seq.fst_stmt);
            tm_ast_stmt_run(env, ast->u.seq.snd_stmt);
            break;
        case STMT_IFELSE:
            if (tm_ast_cond_eval(env, ast->u.ifelse.cond)) {
				tm_ast_stmt_run(env, ast->u.ifelse.then_stmt);
			} else {
				tm_ast_stmt_run(env, ast->u.ifelse.else_stmt);
			}
            break;
        case STMT_WRITE:
		{
			int tape_index = ast->u.write.tape_ref.tape->index;
			char value = tm_ast_exp_eval(env, ast->u.write.value_exp);
			env->next_tapes[tape_index] = value;
            break;
		}
        case STMT_MOVE:
		{
			int tape_index = ast->u.move.tape_ref.tape->index;
			enum tm_ast_direction dir = ast->u.move.direction;
			env->next_move[tape_index] = dir;
            break;
		}
        case STMT_CHSTATE:
		{
			struct tm_ast_state* st = ast->u.chstate.state_ref.state;
			env->next_state = st;
            break;
		}
        default:
            warn("unknown tag %d", ast->tag);
	}
}

void tm_ast_env_run(struct env_t* env)
{
	tm_ast_stmt_run(env, env->curr_state->stmt);
}

void tm_ast_symbol_jff(char c)
{
	if (c != '\0') {
		putchar(c);
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

void tm_ast_env_postrun(struct env_t* env)
{
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
		tm_ast_direction_jff(env->next_move[i]);
		printf("</move>\n");
	}
	printf("\t\t</transition>\n");
}

void tm_ast_env_jff_aux2(struct env_t* env)
{
	tm_ast_env_prerun(env);
	tm_ast_env_run(env);
	tm_ast_env_postrun(env);
}

// nested loop with recursion
void tm_ast_env_jff_aux1(struct env_t* env, struct tm_ast_tape* tape)
{
	if (tape == NULL) {
		tm_ast_env_jff_aux2(env);
	} else {
		struct tm_ast_symbol* symbol = tape->symbol_list->first;
		while (1) {
			char c = symbol == NULL ? '\0' : symbol->symbol;
			env->curr_tapes[tape->index] = c;
			tm_ast_env_jff_aux1(env, tape->next);
			if (symbol == NULL) {
				break;
			} else {
				symbol = symbol->next;
			}
		};
	}
}

void tm_ast_transition_jff(struct tm_ast_state* ast, struct env_t* env)
{
	// Final states cannot have transitions
	if (ast->next == NULL) {
		return;
	}

	env->curr_state = ast;
	tm_ast_env_jff_aux1(env, env->program->tape_list->first);
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
		tm_ast_transition_jff(s, env);
	}
}

void tm_ast_env_init(struct tm_ast_program* ast, struct env_t* env)
{
	int num_tapes = ast->tape_list->last->index + 1;
	if (num_tapes > 5) {
		fprintf(stderr, "JFLAP 7.1 doesn't support Turing Machines with more than 5 tapes\n");
		exit(1);
	}
	env->program = ast;
	env->num_tapes = num_tapes;
	env->curr_tapes = (char*) malloc(num_tapes * sizeof(char));
	env->next_tapes = (char*) malloc(num_tapes * sizeof(char));
	env->next_move = (enum tm_ast_direction*) malloc(num_tapes * sizeof(enum tm_ast_direction));
}

void tm_ast_env_free(struct env_t* env)
{
	free(env->curr_tapes);
	free(env->next_tapes);
	free(env->next_move);
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
