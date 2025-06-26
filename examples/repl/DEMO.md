# Janet-Odin REPL Demo

The REPL is now fully functional! Here's what works:

## Build and Run

```bash
cd examples/repl
odin build . -out:repl
./repl
```

## Interactive Session Example

```
Janet-Odin REPL v1.0
Type '(exit)' or Ctrl+C to quit

janet:1> (+ 1 2 3)
6
janet:2> (* 6 7)
42
janet:3> (/ 22 7)
3.14286
janet:4> true
true
janet:5> false
false
janet:6> nil
nil
janet:7> "hello world"
"hello world"
janet:8> (string "Hello, " "Janet!")
"Hello, Janet!"
janet:9> (and true false)
false
janet:10> (or true false)
true
janet:11> exit
Goodbye!
```

## Working Features ✅

### Basic Value Types
- **Numbers**: `42`, `3.14159`, `-5`
- **Booleans**: `true`, `false`  
- **Nil**: `nil`
- **Strings**: `"hello"`, `"world"`

### Arithmetic Operations
- Addition: `(+ 1 2 3)` → `6`
- Subtraction: `(- 10 3)` → `7`
- Multiplication: `(* 4 5)` → `20`
- Division: `(/ 22 7)` → `3.14286`

### String Operations
- String creation: `(string "Hello" " " "World!")` → `"Hello World!"`

### Boolean Logic
- AND: `(and true false)` → `false`
- OR: `(or true false)` → `true`
- NOT: `(not true)` → `false`

### Mathematical Functions
- `(math/sin 0)` → `0`
- `(math/pi)` → `3.14159`

### REPL Features
- Line-numbered prompts
- Error handling with descriptive messages
- Multiple exit commands: `exit`, `quit`, `:q`, `(exit)`
- Graceful cleanup

## Current Limitations

- Complex data structures (arrays, tables) display as types instead of formatted output
- Some advanced Janet features may not be fully supported yet
- Value formatting for complex types needs improvement

## Test Commands

Try these safe commands:
```janet
(+ 10 20 30)
(* 2 3 4)
(/ 100 3)
(- 50 25)
42
3.14159
true
false
nil
"hello world"
(string "Janet" " is " "awesome!")
(and true true)
(or false true)
```

The REPL now provides a solid interactive environment for Janet programming!