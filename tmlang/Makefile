# Makefile
# Guilherme Dantas

CFLAGS = -w
BINFLDR = bin
NAME = tm

all: setup $(BINFLDR)/$(NAME)

setup: $(BINFLDR)

$(BINFLDR):
	mkdir -p $(BINFLDR)

lex.yy.c: $(NAME).l $(NAME).tab.h
	flex $(NAME).l

$(NAME).tab.c $(NAME).tab.h: $(NAME).y
	bison -d $(NAME).y

$(BINFLDR)/$(NAME): lex.yy.c $(NAME).tab.c $(NAME).tab.h
	gcc $(NAME).tab.c lex.yy.c -o $(BINFLDR)/$(NAME) $(CFLAGS)

clean:
	rm lex.yy.c *.tab.* *.o $(BINFLDR)/*
