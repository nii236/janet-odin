package main

import janet "../../src"
import "core:c"
import "core:fmt"
import "core:math"
import "core:strings"

// REAL Odin functions that Janet can call directly!
odin_multiply_cfunc :: proc "c" (argc: c.int32_t, argv: ^janet.Janet) -> janet.Janet {
	context = context // Set Odin context for this C function

	// Check arity - exactly 2 arguments required
	janet.janet_fixarity(argc, 2)

	// Extract and type-check arguments using Janet's API
	a := janet.janet_getnumber(argv, 0)
	b := janet.janet_getnumber(argv, 1)

	// Actual Odin computation
	result := a * b

	// Return Janet number
	return janet.janet_wrap_number(result)
}

odin_add_cfunc :: proc "c" (argc: c.int32_t, argv: ^janet.Janet) -> janet.Janet {
	context = context

	janet.janet_fixarity(argc, 2)

	a := janet.janet_getnumber(argv, 0)
	b := janet.janet_getnumber(argv, 1)

	result := a + b

	return janet.janet_wrap_number(result)
}

odin_power_cfunc :: proc "c" (argc: c.int32_t, argv: ^janet.Janet) -> janet.Janet {
	context = context

	janet.janet_fixarity(argc, 2)

	base := janet.janet_getnumber(argv, 0)
	exp := janet.janet_getnumber(argv, 1)

	result := math.pow(base, exp)

	return janet.janet_wrap_number(result)
}

odin_greet_cfunc :: proc "c" (argc: c.int32_t, argv: ^janet.Janet) -> janet.Janet {
	context = context

	janet.janet_fixarity(argc, 1)

	// Get C string from Janet
	name_cstr := janet.janet_getcstring(argv, 0)

	// Create greeting using Odin
	greeting := fmt.ctprintf("Hello from REAL Odin, %s!", name_cstr)

	// Convert back to Janet string
	return janet.janet_wrap_string(janet.janet_cstring(greeting))
}

// Register C functions using proper Janet module style
register_odin_functions :: proc(vm: ^janet.VM) {
	fmt.println("Registering Odin C functions...")

	// Direct function registration using janet_def
	multiply_name := strings.clone_to_cstring("odin-multiply")
	defer delete(multiply_name)
	multiply_sym := janet.janet_csymbol(multiply_name)
	multiply_func := janet.janet_wrap_cfunction(odin_multiply_cfunc)
	janet.janet_def(vm.env, multiply_name, multiply_func, "Multiply two numbers using Odin")

	add_name := strings.clone_to_cstring("odin-add")
	defer delete(add_name)
	add_sym := janet.janet_csymbol(add_name)
	add_func := janet.janet_wrap_cfunction(odin_add_cfunc)
	janet.janet_def(vm.env, add_name, add_func, "Add two numbers using Odin")

	power_name := strings.clone_to_cstring("odin-power")
	defer delete(power_name)
	power_sym := janet.janet_csymbol(power_name)
	power_func := janet.janet_wrap_cfunction(odin_power_cfunc)
	janet.janet_def(vm.env, power_name, power_func, "Raise base to power using Odin")

	greet_name := strings.clone_to_cstring("odin-greet")
	defer delete(greet_name)
	greet_sym := janet.janet_csymbol(greet_name)
	greet_func := janet.janet_wrap_cfunction(odin_greet_cfunc)
	janet.janet_def(vm.env, greet_name, greet_func, "Greet someone using Odin")

	fmt.println("Function registration complete!")
}

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
	math_value, eval_err3 := janet.vm_eval(vm, "(math/sin math/pi)")
	if eval_err3 != .NONE {
		fmt.printf("Math eval error: %v\n", eval_err3)
	} else {
		defer janet.value_destroy(math_value)
		if sin_pi, ok := janet.value_to_number(math_value); ok {
			fmt.printf("sin(π): %f\n", sin_pi)
		}
	}

	// Example 3: Creating values from Odin
	fmt.println("\n=== Creating Janet Values from Odin ===")
	odin_num := janet.vm_number(vm, 42.5)
	defer janet.value_destroy(odin_num)
	if num, ok := janet.value_to_number(odin_num); ok {
		fmt.printf("Number from Odin: %f\n", num)
	}

	odin_str := janet.vm_string(vm, "Hello from Odin!")
	defer janet.value_destroy(odin_str)
	if str, ok := janet.value_to_string(odin_str); ok {
		fmt.printf("String from Odin: %s\n", str)
	}

	odin_bool := janet.vm_boolean(vm, true)
	defer janet.value_destroy(odin_bool)
	if b, ok := janet.value_to_boolean(odin_bool); ok {
		fmt.printf("Boolean from Odin: %t\n", b)
	}

	odin_nil := janet.vm_nil(vm)
	defer janet.value_destroy(odin_nil)
	fmt.printf("Nil from Odin: nil\n")

	// Example 4: Error handling
	fmt.println("\n=== Error Handling Demo ===")
	error_value, eval_err2 := janet.vm_eval(vm, "(/ 1 0)") // Division by zero
	if eval_err2 != .NONE {
		fmt.printf("Expected error caught: %v\n", eval_err2)
	} else {
		defer janet.value_destroy(error_value)
		if val, ok := janet.value_to_number(error_value); ok {
			fmt.printf("Unexpected success: %f\n", val)
		} else {
			fmt.printf("Unexpected success: <unknown type>\n")
		}
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

	// Example 7: Odin calling Janet function
	fmt.println("\n=== Odin Calling Janet Function ===")

	// Define a Janet function and get a reference to it
	janet_func_code := `
	(defn greet [name]
	  (string "Hello, " name " from Janet!"))
	greet
	`


	janet_func_value, _ := janet.vm_eval(vm, janet_func_code)
	defer janet.value_destroy(janet_func_value)

	// Call the Janet function from Odin using eval (simpler approach)
	call_code := `(greet "Odin")`
	greeting_result, call_err := janet.vm_eval(vm, call_code)
	if call_err == .NONE {
		defer janet.value_destroy(greeting_result)
		if greeting, ok := janet.value_to_string(greeting_result); ok {
			fmt.printf("Janet function result: %s\n", greeting)
		}
	} else {
		fmt.printf("Function call error: %v\n", call_err)
	}

	// Example 8: Janet calling Odin functions (REAL IMPLEMENTATION!)
	fmt.println("\n=== Janet Calling Odin Functions ===")

	// Register REAL Odin C functions with Janet
	register_odin_functions(vm)

	// Test multiply function
	multiply_result, _ := janet.vm_eval(vm, "(odin-multiply 6 7)")
	defer janet.value_destroy(multiply_result)
	if num, ok := janet.value_to_number(multiply_result); ok {
		fmt.printf("odin-multiply(6, 7) = %f\n", num)
	}

	// Test add function
	add_result, _ := janet.vm_eval(vm, "(odin-add 10 20)")
	defer janet.value_destroy(add_result)
	if num, ok := janet.value_to_number(add_result); ok {
		fmt.printf("odin-add(10, 20) = %f\n", num)
	}

	// Test power function
	power_result, _ := janet.vm_eval(vm, "(odin-power 2 8)")
	defer janet.value_destroy(power_result)
	if num, ok := janet.value_to_number(power_result); ok {
		fmt.printf("odin-power(2, 8) = %f\n", num)
	}

	// Test greet function
	greet_result, _ := janet.vm_eval(vm, `(odin-greet "World")`)
	defer janet.value_destroy(greet_result)
	if str, ok := janet.value_to_string(greet_result); ok {
		fmt.printf("odin-greet(\"World\") = %s\n", str)
	}

	// Test complex expression using Odin functions
	complex_result, _ := janet.vm_eval(vm, "(odin-add (odin-multiply 3 4) (odin-power 2 3))")
	defer janet.value_destroy(complex_result)
	if num, ok := janet.value_to_number(complex_result); ok {
		fmt.printf("odin-add(odin-multiply(3, 4), odin-power(2, 3)) = %f\n", num)
	}

	fmt.println("\n=== Demo Complete ===")
}
