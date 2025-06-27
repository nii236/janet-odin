# janet-odin

Odin bindings for the [Janet programming language](https://janet-lang.org/), providing comprehensive FFI between Odin and Janet with full support for VM management, value conversion, memory management, fibers (coroutines), and bidirectional function calls.

## Quick Start

```odin
import janet "./src"

// Create a Janet VM
vm, err := janet.vm_new()
defer janet.vm_destroy(vm)

// Evaluate Janet code
result, eval_err := janet.vm_eval(vm, "(+ 2 3)")
defer janet.value_destroy(result)

if num, ok := janet.value_to_number(result); ok {
    fmt.printf("Result: %f\n", num) // Result: 5.000000
}
```

## Examples

### Basic Usage

```odin
// Arithmetic
result, _ := janet.vm_eval(vm, "(+ 10 20 30)")
if num, ok := janet.value_to_number(result); ok {
    fmt.printf("Sum: %f\n", num) // Sum: 60.000000
}

// String operations
str_result, _ := janet.vm_eval(vm, `(string "Hello, " "Janet!")`)
if str, ok := janet.value_to_string(str_result); ok {
    fmt.printf("String: %s\n", str) // String: Hello, Janet!
}

// Functions
func_result, _ := janet.vm_eval(vm, `
    (defn square [x] (* x x))
    (square 7)
`)
if num, ok := janet.value_to_number(func_result); ok {
    fmt.printf("Square: %f\n", num) // Square: 49.000000
}
```

### Fiber (Coroutine) Support

```odin
fiber_code := `
(def f (fiber/new (fn []
                   (yield 1)
                   (yield 2)
                   3)))

(resume f) // Returns 1
(resume f) // Returns 2
(resume f) // Returns 3
`
```

### Odin Functions in Janet

```odin
// Define Odin function callable from Janet
odin_multiply :: proc "c" (argc: c.int32_t, argv: ^janet.Janet) -> janet.Janet {
    context = context
    janet.janet_fixarity(argc, 2)

    a := janet.janet_getnumber(argv, 0)
    b := janet.janet_getnumber(argv, 1)

    return janet.janet_wrap_number(a * b)
}

// Register with Janet
multiply_func := janet.janet_wrap_cfunction(odin_multiply)
janet.janet_def(vm.env, "odin-multiply", multiply_func, "Multiply two numbers")

// Use from Janet
result, _ := janet.vm_eval(vm, "(odin-multiply 6 7)")
// Returns 42
```

## Project Structure

- `src/janet.odin` - Complete Janet C API bindings and high-level wrapper
- `examples/repl/` - Interactive REPL with history and multiline support
- `examples/run/` - Comprehensive demonstration of all features
- `tests/` - Test suite covering all functionality
- `lib/` - Static Janet library (macOS)

## Building

Requires:

- Odin compiler
- Janet library (included for macOS, build from source for other platforms)

```bash
# Run examples
odin run examples/repl
odin run examples/run

# Run tests
odin test tests
```

## API Overview

### VM Management

- `vm_new()` - Create new Janet VM
- `vm_destroy()` - Clean up VM and all associated values
- `vm_eval()` - Evaluate Janet source code

### Value Operations

- `value_to_number()`, `value_to_string()`, `value_to_boolean()` - Type conversion
- `vm_number()`, `vm_string()`, `vm_boolean()`, `vm_nil()` - Create Janet values
- `value_destroy()` - Clean up individual values

### Type Checking

- `value_is_number()`, `value_is_string()`, `value_is_boolean()`, `value_is_nil()`
- `value_type()` - Get Janet type enum

### Memory Management

All values are automatically GC-rooted when created and unrooted when destroyed. The VM tracks all values for cleanup.

## Error Handling

```odin
result, err := janet.vm_eval(vm, "(/ 1 0)")
if err != .NONE {
    fmt.printf("Evaluation failed: %v\n", err)
}
```

## License

MIT License - see project for details.
