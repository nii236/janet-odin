package main

import "core:fmt"
import janet "../src"

main :: proc() {
	// Example 1: Legacy API (still works)
	fmt.println("=== Legacy API Demo ===")
	janet.init()
	result, code := janet.eval("(+ 1 2 3)")
	fmt.printf("Legacy eval result: %f (exit: %d)\n\n", result, code)
	janet.deinit()

	// Example 2: New VM-based API
	fmt.println("=== New VM API Demo ===")
	vm, err := janet.vm_new()
	if err != .NONE {
		fmt.printf("Failed to create VM: %v\n", err)
		return
	}
	defer janet.vm_destroy(vm)

	// Basic arithmetic
	value, eval_err := janet.vm_eval(vm, "(+ 10 20 30)")
	if eval_err != .NONE {
		fmt.printf("Eval error: %v\n", eval_err)
		return
	}
	defer janet.value_destroy(value)

	if num, ok := janet.value_to_number(value); ok {
		fmt.printf("Arithmetic result: %f\n", num)
	}

	// String operations
	str_value, _ := janet.vm_eval(vm, `(string "Hello, " "Janet " "from " "Odin!")`)
	defer janet.value_destroy(str_value)

	if str, ok := janet.value_to_string(str_value); ok {
		fmt.printf("String result: %s\n", str)
	}

	// Boolean operations
	bool_value, _ := janet.vm_eval(vm, "(and true false)")
	defer janet.value_destroy(bool_value)

	if b, ok := janet.value_to_boolean(bool_value); ok {
		fmt.printf("Boolean result: %t\n", b)
	}

	// Array operations
	array_value, _ := janet.vm_eval(vm, "(length [1 2 3 4 5])")
	defer janet.value_destroy(array_value)

	if length, ok := janet.value_to_number(array_value); ok {
		fmt.printf("Array length: %f\n", length)
	}

	// Mathematical functions
	math_value, _ := janet.vm_eval(vm, "(math/sin (math/pi))")
	defer janet.value_destroy(math_value)

	if sin_pi, ok := janet.value_to_number(math_value); ok {
		fmt.printf("sin(π): %f\n", sin_pi)
	}

	// Example 3: Creating values from Odin
	fmt.println("\n=== Creating Janet Values from Odin ===")
	odin_num := janet.vm_number(vm, 42.5)
	defer janet.value_destroy(odin_num)
	fmt.printf("Number from Odin: %s\n", janet.value_format(odin_num))

	odin_str := janet.vm_string(vm, "Hello from Odin!")
	defer janet.value_destroy(odin_str)
	fmt.printf("String from Odin: %s\n", janet.value_format(odin_str))

	odin_bool := janet.vm_boolean(vm, true)
	defer janet.value_destroy(odin_bool)
	fmt.printf("Boolean from Odin: %s\n", janet.value_format(odin_bool))

	odin_nil := janet.vm_nil(vm)
	defer janet.value_destroy(odin_nil)
	fmt.printf("Nil from Odin: %s\n", janet.value_format(odin_nil))

	// Example 4: Error handling
	fmt.println("\n=== Error Handling Demo ===")
	error_value, eval_err2 := janet.vm_eval(vm, "(/ 1 0)") // Division by zero
	if eval_err2 != .NONE {
		fmt.printf("Expected error caught: %v\n", eval_err2)
	} else {
		defer janet.value_destroy(error_value)
		fmt.printf("Unexpected success: %s\n", janet.value_format(error_value))
	}

	// Example 5: Complex data structures
	fmt.println("\n=== Complex Data Structures ===")
	table_code := `
	(def person {:name "Alice"
	             :age 30
	             :languages ["Janet" "Odin" "C"]})
	(get person :name)
	`
	table_value, _ := janet.vm_eval(vm, table_code)
	defer janet.value_destroy(table_value)

	if name, ok := janet.value_to_string(table_value); ok {
		fmt.printf("Person name: %s\n", name)
	}

	// Example 6: Function definitions and calls
	fmt.println("\n=== Function Definition and Calls ===")
	func_code := `
	(defn factorial [n]
	  (if (<= n 1)
	    1
	    (* n (factorial (- n 1)))))
	(factorial 5)
	`
	fact_value, _ := janet.vm_eval(vm, func_code)
	defer janet.value_destroy(fact_value)

	if fact, ok := janet.value_to_number(fact_value); ok {
		fmt.printf("Factorial of 5: %f\n", fact)
	}

	fmt.println("\n=== Demo Complete ===")
}
