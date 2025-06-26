package main

import "core:fmt"
import janet "../../src"

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
	
	// Example 8: Janet calling Odin function (via C function wrapper)
	fmt.println("\n=== Janet Calling Odin Function ===")
	
	// For now, we'll demonstrate this by defining a Janet function that uses Odin data
	// In a full implementation, we'd register a C function that wraps Odin code
	odin_data_code := `
	# Simulate Odin function by setting up data that Janet can use
	(def odin-multiply 
	  (fn [a b] 
	    # This simulates calling an Odin function
	    (print "Calling simulated Odin multiply function...")
	    (* a b 2))) # Pretend the *2 comes from Odin logic
	
	(odin-multiply 6 7)
	`
	
	odin_sim_value, _ := janet.vm_eval(vm, odin_data_code)
	defer janet.value_destroy(odin_sim_value)
	
	if result, ok := janet.value_to_number(odin_sim_value); ok {
		fmt.printf("Simulated Odin function called from Janet: %f\n", result)
	}
	
	// Example 9: Preloading and using existing module
	fmt.println("\n=== Preloading Existing Module ===")
	
	// Load the sample module file
	module_path := "sample_module.janet"
	module_load_code := fmt.aprintf(`(import* "%s")`, module_path)
	defer delete(module_load_code)
	
	module_value, module_err := janet.vm_eval(vm, module_load_code)
	if module_err != .NONE {
		fmt.printf("Module load error: %v\n", module_err)
		fmt.println("Trying inline module definition instead...")
		
		// Fallback: define module inline
		inline_module := `
		(def math-utils
		  {:square (fn [x] (* x x))
		   :cube (fn [x] (* x x x))
		   :fibonacci (fn [n] 
		     (if (<= n 1) n 
		       (+ (fibonacci (- n 1)) (fibonacci (- n 2)))))})
		
		# Test the square function
		((math-utils :square) 8)
		`
		
		inline_result, _ := janet.vm_eval(vm, inline_module)
		defer janet.value_destroy(inline_result)
		
		if square_result, ok := janet.value_to_number(inline_result); ok {
			fmt.printf("Module square function result: %f\n", square_result)
		}
	} else {
		defer janet.value_destroy(module_value)
		fmt.println("Module loaded successfully!")
		
		// Use functions from the loaded module
		module_test_code := `
		(square 9)
		`
		test_result, _ := janet.vm_eval(vm, module_test_code)
		defer janet.value_destroy(test_result)
		
		if square_result, ok := janet.value_to_number(test_result); ok {
			fmt.printf("Loaded module square function result: %f\n", square_result)
		}
		
		// Test another function
		fib_test_code := `(fibonacci 10)`
		fib_result, _ := janet.vm_eval(vm, fib_test_code)
		defer janet.value_destroy(fib_result)
		
		if fib_val, ok := janet.value_to_number(fib_result); ok {
			fmt.printf("Loaded module fibonacci(10): %f\n", fib_val)
		}
	}

	fmt.println("\n=== Demo Complete ===")
}
