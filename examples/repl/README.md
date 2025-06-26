# Janet-Odin REPL

A simple Read-Eval-Print Loop (REPL) for Janet written in Odin.

## Building

```bash
cd examples/repl
odin build . -out:repl
```

## Running

```bash
./repl
```

## Usage

The REPL provides an interactive environment to evaluate Janet expressions:

```
Janet-Odin REPL v1.0
Type '(exit)' or Ctrl+C to quit

janet:1> (+ 1 2 3)
6
janet:2> (* 6 7)
42
janet:3> (string "Hello, " "World!")
"Hello, World!"
janet:4> (def x 10)
10
janet:5> (* x x)
100
janet:6> (exit)
Goodbye!
```

## Supported Features

- Arithmetic operations: `+`, `-`, `*`, `/`
- String operations: `string`, string concatenation
- Variable definitions: `def`, `var`
- Function definitions: `defn`
- Control flow: `if`, `when`, `unless`, `cond`
- Data structures: arrays `[]`, tuples `()`, tables `{}`
- Mathematical functions: `math/sin`, `math/cos`, etc.
- All standard Janet language features

## Commands

- `(exit)` or `exit` - Quit the REPL
- Ctrl+C - Force quit

## Examples

### Basic Arithmetic
```janet
janet:1> (+ 10 20 30)
60
janet:2> (/ 22 7)
3.14286
```

### String Operations
```janet
janet:3> (string "Janet" " is " "awesome!")
"Janet is awesome!"
```

### Functions
```janet
janet:4> (defn square [x] (* x x))
<function square>
janet:5> (square 5)
25
```

### Data Structures
```janet
janet:6> [1 2 3 4 5]
@[1 2 3 4 5]
janet:7> {:name "Alice" :age 30}
{:age 30 :name "Alice"}
```