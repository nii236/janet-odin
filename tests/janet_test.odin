package janet_test

import "core:testing"
import "core:fmt"
import janet "../src"

@(test)
test_vm_creation :: proc(t: ^testing.T) {
	vm, err := janet.vm_new()
	testing.expect(t, err == .NONE, "VM creation should succeed")
	testing.expect(t, vm != nil, "VM should not be nil")
	janet.vm_destroy(vm)
}

@(test)
test_basic_arithmetic :: proc(t: ^testing.T) {
	vm, err := janet.vm_new()
	testing.expect(t, err == .NONE)
	defer janet.vm_destroy(vm)

	value, eval_err := janet.vm_eval(vm, "(+ 2 3)")
	testing.expect(t, eval_err == .NONE, "Arithmetic evaluation should succeed")
	defer janet.value_destroy(value)

	if num, ok := janet.value_to_number(value); ok {
		testing.expect(t, num == 5.0, fmt.tprintf("Expected 5.0, got %f", num))
	} else {
		testing.fail(t)
	}
}

@(test)
test_string_operations :: proc(t: ^testing.T) {
	vm, err := janet.vm_new()
	testing.expect(t, err == .NONE)
	defer janet.vm_destroy(vm)

	value, eval_err := janet.vm_eval(vm, `(string "Hello" " " "World")`)
	testing.expect(t, eval_err == .NONE)
	defer janet.value_destroy(value)

	if str, ok := janet.value_to_string(value); ok {
		testing.expect(t, str == "Hello World", fmt.tprintf("Expected 'Hello World', got '%s'", str))
	} else {
		testing.fail(t)
	}
}

@(test)
test_boolean_operations :: proc(t: ^testing.T) {
	vm, err := janet.vm_new()
	testing.expect(t, err == .NONE)
	defer janet.vm_destroy(vm)

	// Test true
	true_value, _ := janet.vm_eval(vm, "true")
	defer janet.value_destroy(true_value)
	
	if b, ok := janet.value_to_boolean(true_value); ok {
		testing.expect(t, b == true, "Expected true")
	} else {
		testing.fail(t)
	}

	// Test false
	false_value, _ := janet.vm_eval(vm, "false")
	defer janet.value_destroy(false_value)
	
	if b, ok := janet.value_to_boolean(false_value); ok {
		testing.expect(t, b == false, "Expected false")
	} else {
		testing.fail(t)
	}
}

@(test)
test_nil_value :: proc(t: ^testing.T) {
	vm, err := janet.vm_new()
	testing.expect(t, err == .NONE)
	defer janet.vm_destroy(vm)

	value, eval_err := janet.vm_eval(vm, "nil")
	testing.expect(t, eval_err == .NONE)
	defer janet.value_destroy(value)

	testing.expect(t, janet.value_is_nil(value), "Value should be nil")
}

@(test)
test_type_checking :: proc(t: ^testing.T) {
	vm, err := janet.vm_new()
	testing.expect(t, err == .NONE)
	defer janet.vm_destroy(vm)

	// Test number type
	num_value, _ := janet.vm_eval(vm, "42")
	defer janet.value_destroy(num_value)
	testing.expect(t, janet.value_is_number(num_value), "Should be a number")
	testing.expect(t, !janet.value_is_string(num_value), "Should not be a string")

	// Test string type
	str_value, _ := janet.vm_eval(vm, `"hello"`)
	defer janet.value_destroy(str_value)
	testing.expect(t, janet.value_is_string(str_value), "Should be a string")
	testing.expect(t, !janet.value_is_number(str_value), "Should not be a number")
}

@(test)
test_odin_to_janet_values :: proc(t: ^testing.T) {
	vm, err := janet.vm_new()
	testing.expect(t, err == .NONE)
	defer janet.vm_destroy(vm)

	// Test number creation
	odin_num := janet.vm_number(vm, 3.14)
	defer janet.value_destroy(odin_num)
	
	if num, ok := janet.value_to_number(odin_num); ok {
		testing.expect(t, num == 3.14, fmt.tprintf("Expected 3.14, got %f", num))
	}

	// Test string creation
	odin_str := janet.vm_string(vm, "test string")
	defer janet.value_destroy(odin_str)
	
	if str, ok := janet.value_to_string(odin_str); ok {
		testing.expect(t, str == "test string", fmt.tprintf("Expected 'test string', got '%s'", str))
	}

	// Test boolean creation
	odin_bool := janet.vm_boolean(vm, true)
	defer janet.value_destroy(odin_bool)
	
	if b, ok := janet.value_to_boolean(odin_bool); ok {
		testing.expect(t, b == true, "Expected true")
	}

	// Test nil creation
	odin_nil := janet.vm_nil(vm)
	defer janet.value_destroy(odin_nil)
	testing.expect(t, janet.value_is_nil(odin_nil), "Should be nil")
}

@(test)
test_complex_expressions :: proc(t: ^testing.T) {
	vm, err := janet.vm_new()
	testing.expect(t, err == .NONE)
	defer janet.vm_destroy(vm)

	// Test array length
	array_value, _ := janet.vm_eval(vm, "(length [1 2 3 4 5])")
	defer janet.value_destroy(array_value)
	
	if length, ok := janet.value_to_number(array_value); ok {
		testing.expect(t, length == 5.0, fmt.tprintf("Expected 5.0, got %f", length))
	}

	// Test function definition and call
	func_value, _ := janet.vm_eval(vm, `
		(defn square [x] (* x x))
		(square 4)
	`)
	defer janet.value_destroy(func_value)
	
	if result, ok := janet.value_to_number(func_value); ok {
		testing.expect(t, result == 16.0, fmt.tprintf("Expected 16.0, got %f", result))
	}
}

@(test)
test_legacy_api :: proc(t: ^testing.T) {
	janet.init()
	defer janet.deinit()

	result, code := janet.eval("(+ 1 2 3)")
	testing.expect(t, code == 0, "Legacy eval should succeed")
	testing.expect(t, result == 6.0, fmt.tprintf("Expected 6.0, got %f", result))
}

@(test)
test_memory_management :: proc(t: ^testing.T) {
	// Test that multiple VM creations/destructions work
	for i in 0..<10 {
		vm, err := janet.vm_new()
		testing.expect(t, err == .NONE, fmt.tprintf("VM creation %d should succeed", i))
		
		value, eval_err := janet.vm_eval(vm, "(+ 1 1)")
		testing.expect(t, eval_err == .NONE, fmt.tprintf("Eval %d should succeed", i))
		janet.value_destroy(value)
		
		janet.vm_destroy(vm)
	}
}