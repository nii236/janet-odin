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

// Odin function that works with fibers - demonstrates fiber status checking
odin_fiber_runner_cfunc :: proc "c" (argc: c.int32_t, argv: ^janet.Janet) -> janet.Janet {
	context = context

	janet.janet_fixarity(argc, 1)

	// Get the fiber argument using array access pattern
	argv_slice := ([^]janet.Janet)(argv)[:argc]
	fiber_val := argv_slice[0]
	
	// Check if it's actually a fiber
	if janet.janet_checktype(fiber_val, .FIBER) == 0 {
		return janet.janet_wrap_string(janet.janet_cstring("Error: Expected a fiber"))
	}

	fiber := janet.janet_unwrap_fiber(fiber_val)
	status := janet.janet_fiber_status(fiber)
	
	// Return status information
	status_name: cstring
	#partial switch status {
	case .NEW: status_name = "new"
	case .ALIVE: status_name = "alive" 
	case .DEAD: status_name = "dead"
	case .ERROR: status_name = "error"
	case .PENDING: status_name = "pending"
	case .DEBUG: status_name = "debug"
	case: status_name = "unknown"
	}

	result_str := fmt.ctprintf("Fiber status: %s", status_name)
	return janet.janet_wrap_string(janet.janet_cstring(result_str))
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

// Create a proper Janet module using janet_cfuns (following Janet documentation pattern)
register_odin_module :: proc(vm: ^janet.VM) {
	fmt.println("Registering Odin module with proper namespacing...")

	// Method 1: Manual registration with module-style naming (works in embedded contexts)
	multiply_name := strings.clone_to_cstring("odin/multiply")
	defer delete(multiply_name)
	multiply_func := janet.janet_wrap_cfunction(odin_multiply_cfunc)
	janet.janet_def(vm.env, multiply_name, multiply_func, "Multiply two numbers using Odin")

	add_name := strings.clone_to_cstring("odin/add")
	defer delete(add_name)
	add_func := janet.janet_wrap_cfunction(odin_add_cfunc)
	janet.janet_def(vm.env, add_name, add_func, "Add two numbers using Odin")

	power_name := strings.clone_to_cstring("odin/power")
	defer delete(power_name)
	power_func := janet.janet_wrap_cfunction(odin_power_cfunc)
	janet.janet_def(vm.env, power_name, power_func, "Raise base to power using Odin")

	greet_name := strings.clone_to_cstring("odin/greet")
	defer delete(greet_name)
	greet_func := janet.janet_wrap_cfunction(odin_greet_cfunc)
	janet.janet_def(vm.env, greet_name, greet_func, "Greet someone using Odin")

	fiber_status_name := strings.clone_to_cstring("odin/fiber-status")
	defer delete(fiber_status_name)
	fiber_status_func := janet.janet_wrap_cfunction(odin_fiber_runner_cfunc)
	janet.janet_def(vm.env, fiber_status_name, fiber_status_func, "Get fiber status from Odin")

	fmt.println("Module registration complete!")
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

	// Example 9: Proper Janet Module with Namespacing
	fmt.println("\n=== Proper Janet Module with Namespacing ===")

	// Register the module using proper module naming conventions
	register_odin_module(vm)

	// Janet's janet_cfuns registers functions with the prefix as part of the name
	// So "odin" prefix + "multiply" function = "odin/multiply" in the environment

	// Test module function calls
	mod_multiply_result, err1 := janet.vm_eval(vm, "(odin/multiply 8 9)")
	if err1 == .NONE {
		defer janet.value_destroy(mod_multiply_result)
		if num, ok := janet.value_to_number(mod_multiply_result); ok {
			fmt.printf("odin/multiply(8, 9) = %f\n", num)
		}
	} else {
		fmt.printf("odin/multiply failed, error: %v\n", err1)
	}

	mod_add_result, err2 := janet.vm_eval(vm, "(odin/add 15 25)")
	if err2 == .NONE {
		defer janet.value_destroy(mod_add_result)
		if num, ok := janet.value_to_number(mod_add_result); ok {
			fmt.printf("odin/add(15, 25) = %f\n", num)
		}
	} else {
		fmt.printf("odin/add failed, error: %v\n", err2)
	}

	mod_power_result, err3 := janet.vm_eval(vm, "(odin/power 3 4)")
	if err3 == .NONE {
		defer janet.value_destroy(mod_power_result)
		if num, ok := janet.value_to_number(mod_power_result); ok {
			fmt.printf("odin/power(3, 4) = %f\n", num)
		}
	} else {
		fmt.printf("odin/power failed, error: %v\n", err3)
	}

	mod_greet_result, err4 := janet.vm_eval(vm, `(odin/greet "Module")`)
	if err4 == .NONE {
		defer janet.value_destroy(mod_greet_result)
		if str, ok := janet.value_to_string(mod_greet_result); ok {
			fmt.printf("odin/greet(\"Module\") = %s\n", str)
		}
	} else {
		fmt.printf("odin/greet failed, error: %v\n", err4)
	}

	// Example 10: Janet Fibers (Coroutines and Error Handling)
	fmt.println("\n=== Janet Fibers Demo ===")

	// Fiber Example 1: Basic yield/resume coroutine
	fmt.println("--- Basic Fiber (yield/resume) ---")
	fiber_code := `
	(def f (fiber/new (fn []
	                   (yield 1)
	                   (yield 2)
	                   (yield 3)
	                   4)))
	
	# Resume the fiber multiple times and print each result
	(print "Fiber results:")
	(print "  Resume 1:" (resume f))
	(print "  Resume 2:" (resume f))
	(print "  Resume 3:" (resume f))
	(print "  Resume 4:" (resume f))
	(print "  Status:" (fiber/status f))
	"Fiber sequence complete"
	`
	
	fiber_result, _ := janet.vm_eval(vm, fiber_code)
	defer janet.value_destroy(fiber_result)
	if str, ok := janet.value_to_string(fiber_result); ok {
		fmt.printf("Result: %s\n", str)
	}

	// Fiber Example 2: Generator pattern
	fmt.println("--- Fiber Generator Pattern ---")
	generator_code := `
	(defn make-counter [start step]
	  (fiber/new (fn []
	    (var i start)
	    (forever
	      (yield i)
	      (set i (+ i step))))))
	
	(def counter (make-counter 10 5))
	
	# Generate sequence and print each value
	(print "Generator sequence:")
	(print "  Gen 1:" (resume counter))
	(print "  Gen 2:" (resume counter))
	(print "  Gen 3:" (resume counter))
	(print "  Status:" (fiber/status counter))
	"Generator pattern complete"
	`
	
	gen_result, _ := janet.vm_eval(vm, generator_code)
	defer janet.value_destroy(gen_result)
	if str, ok := janet.value_to_string(gen_result); ok {
		fmt.printf("Result: %s\n", str)
	}

	// Fiber Example 3: Error handling with fibers
	fmt.println("--- Fiber Error Handling ---")
	error_code := `
	(defn risky-function []
	  (if (> (math/random) 0.5)
	    (error "Something went wrong!")
	    "Success!"))
	
	# Create fiber that traps errors (:e flag)
	(def error-fiber (fiber/new risky-function :e))
	(def result (resume error-fiber))
	(def status (fiber/status error-fiber))
	
	(print "Error handling results:")
	(print "  Result:" result)
	(print "  Status:" status)
	"Error handling complete"
	`
	
	error_result, _ := janet.vm_eval(vm, error_code)
	defer janet.value_destroy(error_result)
	if str, ok := janet.value_to_string(error_result); ok {
		fmt.printf("Result: %s\n", str)
	}

	// Fiber Example 4: Using try/catch (built on fibers)
	fmt.println("--- Try/Catch with Fibers ---")
	try_code := `
	(defn might-fail []
	  (if (> (math/random) 0.3)
	    (error "Random failure!")
	    "Operation succeeded"))
	
	(try
	  (might-fail)
	  ([err]
	    (string "Caught error: " err)))
	`
	
	try_result, _ := janet.vm_eval(vm, try_code)
	defer janet.value_destroy(try_result)
	if str, ok := janet.value_to_string(try_result); ok {
		fmt.printf("Try/catch result: %s\n", str)
	}

	// Fiber Example 5: Dynamic bindings with fibers
	fmt.println("--- Dynamic Bindings ---")
	dynamic_code := `
	(defn print-with-context []
	  (print "Context value: " (dyn :my-context)))
	
	# Set a dynamic binding in current fiber
	(setdyn :my-context "main-fiber")
	(print-with-context)
	
	# Create new fiber with different context
	(def f (fiber/new (fn []
	  (setdyn :my-context "child-fiber")
	  (print-with-context))))
	
	(resume f)
	
	# Back to main fiber context
	(print-with-context)
	
	"Dynamic bindings demo complete"
	`
	
	dyn_result, _ := janet.vm_eval(vm, dynamic_code)
	defer janet.value_destroy(dyn_result)
	if str, ok := janet.value_to_string(dyn_result); ok {
		fmt.printf("Dynamic bindings result: %s\n", str)
	}

	// Fiber Example 6: Complex fiber coordination
	fmt.println("--- Fiber Coordination ---")
	coordination_code := `
	(defn producer [channel]
	  (fiber/new (fn []
	    (for i 1 6
	      (yield {:type :data :value i}))
	    {:type :done})))
	
	(defn consumer [prod-fiber]
	  (var running true)
	  (def results @[])
	  (while running
	    (def msg (resume prod-fiber))
	    (if (= (get msg :type) :done)
	      (set running false)
	      (array/push results (get msg :value))))
	  results)
	
	(def prod (producer nil))
	(def collected (consumer prod))
	(print "Coordination results:" collected)
	"Fiber coordination complete"
	`
	
	coord_result, _ := janet.vm_eval(vm, coordination_code)
	defer janet.value_destroy(coord_result)
	if str, ok := janet.value_to_string(coord_result); ok {
		fmt.printf("Result: %s\n", str)
	}

	// Fiber Example 7: Odin function working with fibers
	fmt.println("--- Odin Function with Fibers ---")
	odin_fiber_code := `
	# Create a fiber
	(def test-fiber (fiber/new (fn []
	  (yield "first")
	  (yield "second")
	  "final")))
	
	# Check status before resuming
	(def status1 (odin/fiber-status test-fiber))
	(print "Initial status:" status1)
	
	# Resume once
	(def result1 (resume test-fiber))
	(print "First resume result:" result1)
	
	# Check status after first resume
	(def status2 (odin/fiber-status test-fiber))
	(print "After first resume:" status2)
	
	# Resume until completion
	(def result2 (resume test-fiber))
	(print "Second resume result:" result2)
	(def result3 (resume test-fiber))
	(print "Final resume result:" result3)
	
	# Check final status
	(def status3 (odin/fiber-status test-fiber))
	(print "Final status:" status3)
	
	"Odin fiber status demo complete"
	`
	
	odin_fiber_result, _ := janet.vm_eval(vm, odin_fiber_code)
	defer janet.value_destroy(odin_fiber_result)
	if str, ok := janet.value_to_string(odin_fiber_result); ok {
		fmt.printf("Result: %s\n", str)
	}

	fmt.println("\n=== Demo Complete ===")
}
