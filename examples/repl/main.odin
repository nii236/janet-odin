package main

import "core:fmt"
import "core:os"
import "core:strings"
import janet "../../src"

History :: struct {
    commands: [dynamic]string,
    current_index: int,
}

history_add :: proc(hist: ^History, cmd: string) {
    if len(cmd) > 0 && (len(hist.commands) == 0 || hist.commands[len(hist.commands)-1] != cmd) {
        append(&hist.commands, strings.clone(cmd))
    }
    hist.current_index = len(hist.commands)
}

history_prev :: proc(hist: ^History) -> (string, bool) {
    if hist.current_index > 0 {
        hist.current_index -= 1
        return hist.commands[hist.current_index], true
    }
    return "", false
}

history_next :: proc(hist: ^History) -> (string, bool) {
    if hist.current_index < len(hist.commands) - 1 {
        hist.current_index += 1
        return hist.commands[hist.current_index], true
    } else if hist.current_index == len(hist.commands) - 1 {
        hist.current_index = len(hist.commands)
        return "", true
    }
    return "", false
}

history_destroy :: proc(hist: ^History) {
    for cmd in hist.commands {
        delete(cmd)
    }
    delete(hist.commands)
}

read_line :: proc(prompt: string, history: ^History) -> (string, bool) {
    fmt.printf("%s", prompt)
    
    line_buffer: [1024]u8
    line_len := 0
    
    for line_len < len(line_buffer) - 1 {
        char_buffer: [1]u8
        n, read_err := os.read(os.stdin, char_buffer[:])
        if read_err != nil || n == 0 {
            return "", false
        }
        
        char := char_buffer[0]
        
        if char == '\n' {
            break
        } else if char == '\r' {
            continue  
        } else if char == 3 { // Ctrl+C
            return "", false
        } else if char >= 32 && char <= 126 { // Printable ASCII
            line_buffer[line_len] = char
            line_len += 1
        }
    }
    
    line := strings.trim_space(string(line_buffer[:line_len]))
    
    // Check for history commands
    if line == "!!history" {
        fmt.println("Command history:")
        for i in 0..<len(history.commands) {
            fmt.printf("  %d: %s\n", i + 1, history.commands[i])
        }
        return "", true
    }
    
    if line == "!!prev" {
        if cmd, ok := history_prev(history); ok {
            fmt.printf("Previous: %s\n", cmd)
            return strings.clone(cmd), true
        } else {
            fmt.println("No previous command")
            return "", true
        }
    }
    
    if line == "!!next" {
        if cmd, ok := history_next(history); ok {
            fmt.printf("Next: %s\n", cmd)
            return strings.clone(cmd), true
        } else {
            fmt.println("No next command")
            return "", true
        }
    }
    
    return strings.clone(line), true
}

is_complete_expression :: proc(expr: string) -> bool {
    paren_count := 0
    bracket_count := 0
    brace_count := 0
    in_string := false
    escape_next := false
    
    for char in expr {
        if escape_next {
            escape_next = false
            continue
        }
        
        if char == '\\' {
            escape_next = true
            continue
        }
        
        if char == '"' && !escape_next {
            in_string = !in_string
            continue
        }
        
        if in_string {
            continue
        }
        
        switch char {
        case '(':
            paren_count += 1
        case ')':
            paren_count -= 1
        case '[':
            bracket_count += 1
        case ']':
            bracket_count -= 1
        case '{':
            brace_count += 1
        case '}':
            brace_count -= 1
        }
    }
    
    return paren_count == 0 && bracket_count == 0 && brace_count == 0
}

main :: proc() {
    fmt.println("Janet-Odin REPL v1.0")
    fmt.println("Type '(exit)' or Ctrl+C to quit")
    fmt.println("Use !!history, !!prev, !!next for command history")
    fmt.println()

    // Initialize Janet VM
    vm, err := janet.vm_new()
    if err != .NONE {
        fmt.printf("Failed to initialize Janet VM: %v\n", err)
        os.exit(1)
    }
    defer janet.vm_destroy(vm)

    // Initialize command history
    history := History{
        commands = make([dynamic]string),
        current_index = 0,
    }
    defer history_destroy(&history)

    line_number := 1
    accumulated_input := strings.builder_make()
    defer strings.builder_destroy(&accumulated_input)
    
    for {
        // Determine prompt
        prompt: string
        if strings.builder_len(accumulated_input) == 0 {
            prompt = fmt.aprintf("janet:%d> ", line_number)
        } else {
            prompt = fmt.aprintf("janet:%d... ", line_number)
        }
        defer delete(prompt)
        
        // Read line with history support
        line, ok := read_line(prompt, &history)
        if !ok {
            fmt.println("\nGoodbye!")
            break
        }
        defer delete(line)
        
        // Skip empty lines and history commands when no accumulated input
        if len(line) == 0 {
            if strings.builder_len(accumulated_input) == 0 {
                continue
            } else {
                // Empty line while accumulating - continue building
                continue
            }
        }
        
        // Skip history commands when accumulating
        if strings.has_prefix(line, "!!") && strings.builder_len(accumulated_input) == 0 {
            continue
        }
        
        // Add line to accumulated input
        if strings.builder_len(accumulated_input) > 0 {
            strings.write_string(&accumulated_input, "\n")
        }
        strings.write_string(&accumulated_input, line)
        
        current_input := strings.to_string(accumulated_input)
        trimmed := strings.trim_space(current_input)
        
        // Check for exit command
        if (trimmed == "(exit)" || trimmed == "exit" || trimmed == ":q" || trimmed == "quit") {
            fmt.println("Goodbye!")
            break
        }
        
        // Check if expression is complete
        if !is_complete_expression(trimmed) {
            // Expression incomplete, continue reading
            continue
        }
        
        // Add to history before evaluation
        history_add(&history, trimmed)
        
        // Expression is complete, evaluate it
        result, eval_err := janet.vm_eval(vm, trimmed)
        if eval_err != .NONE {
            fmt.printf("Error: %v\n", eval_err)
        } else {
            defer janet.value_destroy(result)
            print_janet_value(result)
            fmt.print("\n")
        }
        
        // Reset for next input
        strings.builder_reset(&accumulated_input)
        line_number += 1
    }
}

print_janet_value :: proc(value: ^janet.Value) {
    vtype := janet.value_type(value)
    
    #partial switch vtype {
    case .NUMBER:
        if num, ok := janet.value_to_number(value); ok {
            if num == f64(int(num)) {
                fmt.printf("%d", int(num))
            } else {
                fmt.printf("%.6g", num)
            }
        } else {
            fmt.print("<number conversion error>")
        }
        
    case .NIL:
        fmt.print("nil")
        
    case .BOOLEAN:
        if b, ok := janet.value_to_boolean(value); ok {
            fmt.printf("%t", b)
        } else {
            fmt.print("<boolean conversion error>")
        }
        
    case .STRING:
        if s, ok := janet.value_to_string(value); ok {
            fmt.printf("\"%s\"", s)
        } else {
            fmt.print("<string conversion error>")
        }
        
    case .SYMBOL:
        if s, ok := janet.value_to_string(value); ok {
            fmt.print(s)
        } else {
            fmt.print("<symbol>")
        }
        
    case .KEYWORD:
        if s, ok := janet.value_to_string(value); ok {
            fmt.printf(":%s", s)
        } else {
            fmt.print("<keyword>")
        }
        
    case:
        fmt.printf("<%v>", vtype)
    }
}