# janet-odin

Comprehensive Odin bindings for the Janet programming language, providing complete bidirectional integration, fiber support, and native module capabilities.

## Overview

This library provides complete Odin bindings to embed and interact with Janet, a functional and imperative programming language with advanced features like fibers (coroutines). It includes:

- **Bidirectional Function Calls**: Janet calling Odin functions and Odin calling Janet functions
- **Complete Fiber Integration**: Full support for Janet's coroutine system
- **High-level VM API**: Safe, garbage-collected Janet VM management  
- **Native Module System**: Create proper Janet modules with Odin functions
- **Type-safe value conversion**: Automatic conversion between Odin and Janet types
- **Memory management**: Automatic cleanup and GC integration
- **Legacy compatibility**: Simple eval interface for basic use cases
- **Comprehensive error handling**: Proper error propagation and handling

## Features

- ✅ **Bidirectional Function Calls**: Real C function integration
- ✅ **Janet Fibers**: Complete coroutine support with yield/resume
- ✅ **Native Modules**: Proper Janet module registration with `janet_cfuns`
- ✅ **Error Handling with Fibers**: Structured exception handling using fiber signals
- ✅ **Dynamic Bindings**: Per-fiber context management
- ✅ **Generator Patterns**: Infinite generators and iterators
- ✅ **Full Janet C API bindings**: Complete access to Janet's C interface
- ✅ **Thread-safe VM management**: Safe concurrent usage
- ✅ **Automatic memory management**: GC integration with proper cleanup
- ✅ **Type-safe value conversion**: Support for all Janet types
- ✅ **Pretty printing and value formatting**: Debug-friendly output
- ✅ **Comprehensive test suite**: Extensive testing coverage

## Structure

- `src/janet.odin` - Complete Janet bindings with VM management and C API
- `examples/run/main.odin` - Comprehensive examples including fibers and modules
- `tests/janet_test.odin` - Full test suite
- `lib/` - Janet library files, documentation, and reference implementations

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

### Bidirectional Function Calls

```odin
import janet "src"

// Odin function that Janet can call
odin_multiply :: proc "c" (argc: c.int32_t, argv: ^janet.Janet) -> janet.Janet {
    context = context
    janet.janet_fixarity(argc, 2)
    
    a := janet.janet_getnumber(argv, 0)
    b := janet.janet_getnumber(argv, 1)
    result := a * b
    
    return janet.janet_wrap_number(result)
}

main :: proc() {
    vm, _ := janet.vm_new()
    defer janet.vm_destroy(vm)
    
    // Register Odin function in Janet
    janet.janet_def(vm.env, "odin-multiply", 
                   janet.janet_wrap_cfunction(odin_multiply),
                   "Multiply two numbers using Odin")
    
    // Call Odin function from Janet
    result, _ := janet.vm_eval(vm, "(odin-multiply 6 7)")
    defer janet.value_destroy(result)
    
    if num, ok := janet.value_to_number(result); ok {
        fmt.printf("Result: %f\n", num) // Output: Result: 42.000000
    }
    
    // Call Janet function from Odin
    janet_result, _ := janet.vm_eval(vm, `
        (defn greet [name] (string "Hello, " name "!"))
        (greet "Odin")
    `)
    defer janet.value_destroy(janet_result)
    
    if str, ok := janet.value_to_string(janet_result); ok {
        fmt.printf("Janet says: %s\n", str)
    }
}
```

### Janet Fibers (Coroutines)

```odin
import janet "src"

main :: proc() {
    vm, _ := janet.vm_new()
    defer janet.vm_destroy(vm)
    
    // Create and use a fiber generator
    fiber_code := `
        (def counter (fiber/new (fn []
            (var i 0)
            (forever
                (yield i)
                (set i (+ i 1))))))
        
        # Get first 5 values
        (def results @[])
        (for i 0 5
            (array/push results (resume counter)))
        results
    `
    
    result, _ := janet.vm_eval(vm, fiber_code)
    defer janet.value_destroy(result)
    // Produces: [0 1 2 3 4]
}
```

### Error Handling with Fibers

```odin
import janet "src"

main :: proc() {
    vm, _ := janet.vm_new()
    defer janet.vm_destroy(vm)
    
    error_handling := `
        (defn risky-operation []
            (if (> (math/random) 0.5)
                (error "Something went wrong!")
                "Success!"))
        
        # Use try/catch (built on fibers)
        (try
            (risky-operation)
            ([err] (string "Caught: " err)))
    `
    
    result, _ := janet.vm_eval(vm, error_handling)
    defer janet.value_destroy(result)
    
    if str, ok := janet.value_to_string(result); ok {
        fmt.printf("Result: %s\n", str)
    }
}
```

## API Reference

### VM Management

- `vm_new() -> (^VM, Janet_Error)` - Create a new Janet VM
- `vm_destroy(vm: ^VM)` - Destroy a Janet VM and clean up resources  
- `vm_eval(vm: ^VM, code: string) -> (^Value, Janet_Error)` - Evaluate Janet code

### Bidirectional Function Integration

- `janet_def(env: Janet_Table, name: cstring, val: Janet, documentation: cstring)` - Register function in environment
- `janet_cfuns(env: Janet_Table, regprefix: cstring, cfuns: ^Janet_Reg)` - Register module functions
- `janet_wrap_cfunction(x: Janet_CFunction) -> Janet` - Wrap Odin function for Janet
- `janet_fixarity(argc: c.int32_t, arity: c.int32_t)` - Check function arity
- `janet_getnumber(argv: ^Janet, n: c.int32_t) -> f64` - Extract number argument
- `janet_getcstring(argv: ^Janet, n: c.int32_t) -> cstring` - Extract string argument

### Fiber Operations

- `janet_fiber(function: Janet_Function, capacity: c.int32_t, argc: c.int32_t, argv: ^Janet) -> Janet_Fiber`
- `janet_fiber_status(fiber: Janet_Fiber) -> Janet_Fiber_Status` - Get fiber status
- `janet_current_fiber() -> Janet_Fiber` - Get current fiber
- `janet_unwrap_fiber(x: Janet) -> Janet_Fiber` - Extract fiber from value

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

### Fiber Status Types

```odin
Janet_Fiber_Status :: enum c.int {
    DEAD,     // Fiber has completed
    ERROR,    // Fiber threw an error
    DEBUG,    // Fiber is in debug mode
    PENDING,  // Fiber is suspended (yielded)
    NEW,      // Fiber hasn't been resumed yet
    ALIVE,    // Fiber is currently running
    // USER0-USER9 for custom signals
}
```

## Examples

The `examples/run/main.odin` file contains comprehensive examples including:

- **Bidirectional Function Calls**: Janet calling Odin and vice versa
- **Janet Fibers**: Basic yield/resume, generators, error handling
- **Dynamic Bindings**: Per-fiber context management
- **Producer/Consumer Patterns**: Fiber coordination
- **Native Modules**: Proper module registration with namespacing
- **Error Handling**: try/catch and fiber-based exception handling
- **Complex Data Structures**: Tables, arrays, and nested operations
- **Type Conversion**: All supported type conversions between Odin and Janet

## Fiber Features

Janet's fiber system provides:

1. **Coroutines**: Functions that can yield and resume execution
2. **Generators**: Infinite sequences with internal state
3. **Error Handling**: Structured exception handling via fiber signals
4. **Dynamic Bindings**: Per-fiber environment variables
5. **Concurrency**: Cooperative multitasking without OS threads

Example patterns:

```odin
// Generator pattern
counter := (fiber/new (fn [] (var i 0) (forever (yield i) (set i (+ i 1)))))

// Error handling pattern  
error-fiber := (fiber/new risky-function :e)  // :e flag traps errors

// Producer/consumer pattern
producer := (fiber/new (fn [] (for i 1 10 (yield i))))
```

## Testing

Run the test suite:

```bash
odin test tests
```

The test suite covers:
- VM creation and destruction
- Bidirectional function calls
- Fiber operations and lifecycle
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
cd examples/run
odin run main.odin -file

# Run tests  
odin test tests

# Build with debugging
odin build examples/run -debug -out:examples_debug.bin
```

## Architecture

The library is structured in layers:

1. **Low-level C bindings**: Direct Janet C API access
2. **VM Management**: Thread-safe Janet VM with proper cleanup
3. **Fiber Integration**: Complete coroutine support
4. **Function Registration**: Bidirectional function call system
5. **Value System**: Type-safe value conversion and management
6. **High-level API**: Easy-to-use evaluation and interaction functions
7. **Legacy API**: Backward compatibility for simple use cases

### Memory Management

The library uses Janet's garbage collector properly:
- Values are automatically rooted when created
- VM tracks all rooted values for cleanup
- `value_destroy()` unroots values and removes them from tracking
- `vm_destroy()` cleans up all remaining values and deinitializes Janet
- C functions use proper Janet memory management APIs

### Thread Safety

Each VM instance is thread-local and uses mutexes for internal state management. Multiple VMs can be created in different threads safely.

### Function Integration

Odin functions can be called from Janet by:
1. Using `proc "c"` calling convention
2. Proper argument extraction with `janet_getnumber`, `janet_getcstring`, etc.
3. Type checking with `janet_fixarity`
4. Return value wrapping with `janet_wrap_*` functions
5. Registration via `janet_def` or `janet_cfuns`

## Real-World Usage Patterns

### 1. Embedded Scripting
Use Janet as a configuration and scripting language in Odin applications:

```odin
// Register application functions
janet.janet_def(vm.env, "log", odin_log_function, "Log a message")
janet.janet_def(vm.env, "get-config", odin_config_function, "Get configuration")

// Load and run user scripts
config_result, _ := janet.vm_eval(vm, load_file("config.janet"))
```

### 2. Data Processing Pipeline
Use fibers for streaming data processing:

```odin
// Producer fiber generates data
// Consumer fiber processes data
// Error handling fiber manages failures
```

### 3. Plugin System
Create a plugin architecture where Janet scripts extend Odin applications:

```odin
// Register core API functions
// Load plugin scripts
// Call plugin functions from Odin
```

## Contributing

Contributions are welcome! Please ensure:
- All new features have corresponding tests
- Memory management follows the established patterns
- API changes maintain backward compatibility where possible
- Documentation is updated for new features
- Fiber integration follows Janet's patterns
- Function registration uses proper Janet conventions

## License

This project follows the same license as Janet itself (MIT).