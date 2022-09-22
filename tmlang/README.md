# tmlang - A High-Level Programming Language for JFLAP Turing Machines

JFLAP is a great tool to learn about Turing Machines.
It provides step-by-step computations and a nice graphical user interface.
It also provides some abstractions like wildcards and variables that work well on single-tape machines.
For multi-tape machines, I've found these features are quite buggy.
To solve this issue, I've made this Lua-like programming language that helps bring these features to multi-tape machines.
We've decide to use Lua syntax because of its simplicity and ease of implementation.
Also, because most code editors already have syntax highlighters for Lua files.

## Syntax

```
program := tape+ state+
tape := tape_name '=' 'tape' '{' symbol [ ',' symbol ]* '}'
state := 'function' state_name '()' stmt 'end'
stmt := if_stmt | write_stmt | move_stmt | goto_stmt |
if_stmt := 'if' cond 'then' stmt else_stmt 'end'
cond := or_cond
or_cond := or_cond 'or' and_cond | and_cond
and_cond := and_cond 'and' not_cond | not_cond
not_cond := 'not' cmp_cond | cmp_cond
cmp_cond := exp '==' exp | exp '~=' exp | primary_cond
exp := 'nil' | symbol | tape_name
primary_cond := '(' cond ')'
else_stmt := 'else' stmt | 'elseif' cond 'then' stmt else_stmt |
write_stmt := tape_name '=' exp
move_stmt := direction '(' tape_name ')'
direction := 'left' | 'right'
```

## Tapes

Tapes are given names and have a set of valid characters. The compiler prohibits you from writing characters to a tape that are not contained in that set.
There has to be at least 1 tape. There can't be more than 5 tapes because JFLAP does not support it.

## States

Each state has an action associated with it. The compiler runs the action for all the possible values in each tape and produces all the transitions automatically.
There has to be at least one state. The first state is the initial one and the last state is the final one, always. The final state action is ignored and produces no transitions.

## Statements

Some statements might have a misleading effect. For example, write and goto statements aren't immediate like in Lua. Their effect is only applied at the end of the action code.

## Tested environments

* Ubuntu 22.04.1 LTS

## Dependencies

* CMake >= 3.0.0
* Flex >= 2.6.4
* Bison >= 3.8.2

## Setup

1. Setup a build directory

```sh
cmake -B build
```

2. Build the executables

```sh
cmake --build build
```

### Compiling to JFLAP

The compiler always reads from `stdin` and spits out the result to `stdout`.
Use pipes to redirect these streams to the appropriate files.

```sh
./build/src/jff/tm_jff < foo.lua > foo.jff
```

Then, you can load the JFF file on JFLAP.

```sh
java -jar JFLAP.jar foo.jff
```

### Compiling to TM representation

For the universal Turing Machine, we use the following representation:

```
(<Q1*S1*Q1*S1*[ED]>)*
```

The first part stands for the current state.
The second part stands for the current symbol.
The third part stands for the next state.
The fourth part stands for the next symbol.
The fifth part stands for the direction.

Only single-taped Turing machines are supported.

`Q` is the initial machine state and `Q1` is the final machine state.
`S` is the blank character.
`E` stands for left and `D` stands for right.
"Stop" movements are not allowed.

You can compile TMs like so:

```sh
./build/src/repr/tm_repr < foo.lua
```

This will print out a representation of the Turing Machine.

### Example

You can run one of the examples in the `examples/` directory.
Some of them are already compiled!
