# janet-odin

Odin bindings for the Janet programming language.

## Overview

This library provides Odin bindings to embed and interact with Janet, a functional and imperative programming language.

## Structure

- `src/janet.odin` - Core Janet bindings and wrapper functions
- `examples/` - Usage examples
- `lib/` - Janet library files and documentation

## Usage

```odin
import janet "src"

main :: proc() {
    janet.init()
    defer janet.deinit()
    
    result, code := janet.eval("(+ 1 2 3)")
    fmt.printf("Result: %f (exit: %d)\n", result, code)
}
```

## Building

Make sure you have the Odin compiler installed and the Janet library in the `lib/` directory.

```bash
odin build examples -out:examples.bin
./examples.bin
```