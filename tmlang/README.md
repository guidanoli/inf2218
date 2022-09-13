# tmlang - A High-Level Programming Language for JFLAP Turing Machines

JFLAP is a great tool to learn about Turing Machines.
It provides step-by-step computations and a nice graphical user interface.
It also provides some abstractions like wildcards and variables that work well on single-tape machines.
For multi-tape machines, I've found these features are quite buggy.
To solve this issue, I've made this Lua-like programming language that helps bring these features to multi-tape machines.
We've decide to use Lua syntax because of its simplicity and ease of implementation.
Also, because most code editors already have syntax highlighters for Lua files.

## Setup

1. Install CMake
2. Setup a build directory

```sh
cmake -B build
```

3. Build the executables

```sh
cmake --build build
```

### Usage

The compiler always reads from `stdin` and spits out the result to `stdout`.
Use pipes to redirect these streams to the appropriate files.

```sh
./build/src/jff/tm_jff < foo.lua > foo.jff
```

Then, you can run the JFLAP jar file and load the JFF file through the GUI.

```sh
java -jar JFLAP.jar
```

### Example

You can run one of the examples in the `examples/` directory.
