# janet-odin

Comprehensive Odin bindings for the Janet programming language, providing both high-level VM management and low-level C API access.

## Overview

This library provides complete Odin bindings to embed and interact with Janet, a functional and imperative programming language. It includes:

- **High-level VM API**: Safe, garbage-collected Janet VM management
- **Type-safe value conversion**: Automatic conversion between Odin and Janet types
- **Memory management**: Automatic cleanup and GC integration
- **Legacy compatibility**: Simple eval interface for basic use cases
- **Comprehensive error handling**: Proper error propagation and handling

## Features

- ✅ Full Janet C API bindings
- ✅ Thread-safe VM management
- ✅ Automatic memory management with GC integration
- ✅ Type-safe value conversion (numbers, strings, booleans, nil)
- ✅ Error handling and propagation
- ✅ Bootstrap environment with Odin-specific functions
- ✅ Pretty printing and value formatting
- ✅ Legacy API compatibility
- ✅ Comprehensive test suite

## Structure

- `src/janet.odin` - Complete Janet bindings with VM management
- `examples/main.odin` - Comprehensive usage examples
- `tests/janet_test.odin` - Full test suite
- `lib/` - Janet library files, documentation, and Go reference implementation

## Quick Start

### Simple Usage (Legacy API)

```odin
import janet "src"

main :: proc() {
    janet.init()
    defer janet.deinit()
    
    result, code := janet.eval("(+ 1 2 3)")
    fmt.printf("Result: %f (exit: %d)\n", result, code)
}
```

### Advanced Usage (VM API)

```odin
import janet "src"

main :: proc() {
    // Create a Janet VM
    vm, err := janet.vm_new()
    if err != .NONE {
        fmt.printf("Failed to create VM: %v\n", err)
        return
    }
    defer janet.vm_destroy(vm)

    // Evaluate Janet code
    value, eval_err := janet.vm_eval(vm, "(+ 10 20 30)")
    if eval_err != .NONE {
        fmt.printf("Eval error: %v\n", eval_err)
        return
    }
    defer janet.value_destroy(value)

    // Extract the result
    if num, ok := janet.value_to_number(value); ok {
        fmt.printf("Result: %f\n", num) // Output: Result: 60.000000
    }

    // Create values from Odin
    odin_str := janet.vm_string(vm, "Hello from Odin!")
    defer janet.value_destroy(odin_str)
    fmt.printf("String: %s\n", janet.value_format(odin_str))
}
```

## API Reference

### VM Management

- `vm_new() -> (^VM, Janet_Error)` - Create a new Janet VM
- `vm_destroy(vm: ^VM)` - Destroy a Janet VM and clean up resources
- `vm_eval(vm: ^VM, code: string) -> (^Value, Janet_Error)` - Evaluate Janet code

### Value Management

- `value_destroy(value: ^Value)` - Clean up a Janet value
- `value_type(value: ^Value) -> Janet_Type` - Get the type of a value
- `value_format(value: ^Value) -> string` - Format a value as a string

### Type Checking

- `value_is_nil(value: ^Value) -> bool`
- `value_is_number(value: ^Value) -> bool`
- `value_is_string(value: ^Value) -> bool`
- `value_is_boolean(value: ^Value) -> bool`

### Value Conversion (Janet → Odin)

- `value_to_number(value: ^Value) -> (f64, bool)`
- `value_to_string(value: ^Value) -> (string, bool)`
- `value_to_boolean(value: ^Value) -> (bool, bool)`

### Value Creation (Odin → Janet)

- `vm_nil(vm: ^VM) -> ^Value`
- `vm_number(vm: ^VM, x: f64) -> ^Value`
- `vm_string(vm: ^VM, s: string) -> ^Value`
- `vm_boolean(vm: ^VM, x: bool) -> ^Value`

### Error Types

```odin
Janet_Error :: enum {
    NONE,         // No error
    INIT_FAILED,  // VM initialization failed
    EVAL_FAILED,  // Code evaluation failed
    TYPE_ERROR,   // Type conversion error
    MEMORY_ERROR, // Memory allocation error
    FIBER_ERROR,  // Fiber operation error
}
```

## Examples

The `examples/main.odin` file contains comprehensive examples including:

- Basic arithmetic and string operations
- Boolean logic and nil handling
- Array and table operations
- Mathematical functions
- Creating Janet values from Odin data
- Error handling demonstrations
- Complex data structures
- Function definitions and calls

## Testing

Run the test suite:

```bash
odin test tests
```

The test suite covers:
- VM creation and destruction
- Basic operations (arithmetic, strings, booleans)
- Type checking and conversion
- Value creation from Odin
- Complex expressions and function calls
- Memory management
- Legacy API compatibility

## Building

Make sure you have the Odin compiler installed and the Janet library in the `lib/` directory.

```bash
# Build and run examples
odin build examples -out:examples.bin
./examples.bin

# Run tests
odin test tests

# Build with debugging
odin build examples -debug -out:examples_debug.bin
```

## Architecture

The library is structured in layers:

1. **Low-level C bindings**: Direct Janet C API access
2. **VM Management**: Thread-safe Janet VM with proper cleanup
3. **Value System**: Type-safe value conversion and management
4. **High-level API**: Easy-to-use evaluation and interaction functions
5. **Legacy API**: Backward compatibility for simple use cases

### Memory Management

The library uses Janet's garbage collector properly:
- Values are automatically rooted when created
- VM tracks all rooted values for cleanup
- `value_destroy()` unroots values and removes them from tracking
- `vm_destroy()` cleans up all remaining values and deinitializes Janet

### Thread Safety

Each VM instance is thread-local and uses mutexes for internal state management. Multiple VMs can be created in different threads safely.

## Differences from janet-go

This implementation is inspired by the `janet-go` library but adapted for Odin's systems programming approach:

- **No channels/goroutines**: Uses direct function calls instead of async communication
- **Manual memory management**: Explicit cleanup instead of Go's GC
- **Value semantics**: Odin's value types instead of Go's reference types
- **Error handling**: Explicit error returns instead of panics
- **Context integration**: Uses Odin's context system for allocators

## Contributing

Contributions are welcome! Please ensure:
- All new features have corresponding tests
- Memory management follows the established patterns
- API changes maintain backward compatibility where possible
- Documentation is updated for new features

## License

This project follows the same license as Janet itself (MIT).