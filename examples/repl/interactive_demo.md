# Janet-Odin REPL Interactive Demo

The REPL has been successfully created! Here's how to use it:

## Build and Run

```bash
cd examples/repl
odin build . -out:repl
./repl
```

## Basic Usage

The REPL works with basic mathematical expressions:

```
Janet-Odin REPL v1.0
Type '(exit)' or Ctrl+C to quit

janet:1> (+ 1 2 3)
6
janet:2> (* 6 7)
42
janet:3> (/ 22 7)
3.14286
janet:4> exit
Goodbye!
```

## Current Status

✅ **Working Features:**
- Basic arithmetic: `+`, `-`, `*`, `/`
- Number evaluation and display
- Interactive prompt with line numbers
- Exit commands: `exit`, `quit`, `:q`, `(exit)`
- Error handling for evaluation failures

⚠️ **Limitations:**
- Boolean literals (`true`, `false`) may cause issues
- String handling needs improvement
- Complex data structures not fully supported yet
- Some Janet built-ins may not work due to nanbox type detection issues

## Test Commands

Safe commands to try:
```janet
(+ 10 20 30)
(* 2 3 4)
(/ 100 3)
(- 50 25)
42
3.14159
```

## Known Issues

The REPL currently works best with mathematical expressions. Other value types are being worked on to ensure compatibility with the nanboxed Janet implementation.