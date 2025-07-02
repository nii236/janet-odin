package janet

import "core:c"
import "core:strings"
import "core:sync"

// Foreign import for Janet library
foreign import janet "../lib/macos/libjanet.a"

// Janet value - non-nanbox struct version (matches C struct Janet)
Janet :: struct {
	as:   struct #raw_union {
		u64:      u64,
		number:   f64,
		integer:  i32,
		pointer:  rawptr,
		cpointer: rawptr,
	},
	type: Janet_Type,
}

// Janet types
Janet_Type :: enum c.int {
	NUMBER,
	NIL,
	BOOLEAN,
	FIBER,
	STRING,
	SYMBOL,
	KEYWORD,
	ARRAY,
	TUPLE,
	TABLE,
	STRUCT,
	BUFFER,
	FUNCTION,
	CFUNCTION,
	ABSTRACT,
	POINTER,
}

// Janet signals
Janet_Signal :: enum c.int {
	OK,
	ERROR,
	DEBUG,
	YIELD,
	USER0,
	USER1,
	USER2,
	USER3,
	USER4,
	USER5,
	USER6,
	USER7,
	USER8,
	USER9,
}

// Janet fiber status
Janet_Fiber_Status :: enum c.int {
	DEAD,
	ERROR,
	DEBUG,
	PENDING,
	USER0,
	USER1,
	USER2,
	USER3,
	USER4,
	USER5,
	USER6,
	USER7,
	USER8,
	USER9,
	NEW,
	ALIVE,
}

// Opaque types
Janet_Table :: rawptr
Janet_Fiber :: rawptr
Janet_Function :: rawptr
Janet_CFunction :: proc "c" (argc: c.int32_t, argv: ^Janet) -> Janet
Janet_Array :: rawptr
Janet_Buffer :: rawptr
Janet_String :: ^u8

// Janet registry entry for module functions
Janet_Reg :: struct {
	name:          cstring,
	cfun:          Janet_CFunction,
	documentation: cstring,
}

// Janet GC Object and String Head structures
Janet_GCObject :: struct {
	flags: c.int32_t,
	data:  struct #raw_union {
		next:     ^Janet_GCObject,
		refcount: c.int32_t, // For threaded abstract types
	},
}

Janet_StringHead :: struct {
	gc:     Janet_GCObject,
	length: c.int32_t,
	hash:   c.int32_t,
	data:   [0]u8, // Flexible array member
}

// Core Janet C API bindings
foreign janet {
	// Initialization
	janet_init :: proc() ---
	janet_deinit :: proc() ---

	// Environment
	janet_core_env :: proc(replacements: Janet_Table) -> Janet_Table ---

	// Evaluation
	janet_dostring :: proc(env: Janet_Table, str: cstring, sourcePath: cstring, out: ^Janet) -> c.int ---
	janet_dobytes :: proc(env: Janet_Table, bytes: ^u8, len: c.int32_t, sourcePath: cstring, out: ^Janet) -> c.int ---
	janet_pcall :: proc(fun: Janet_Function, argc: c.int32_t, argv: ^Janet, out: ^Janet, fiber: ^Janet_Fiber) -> Janet_Signal ---
	janet_call :: proc(fun: Janet_Function, argc: c.int32_t, argv: ^Janet) -> Janet ---
	janet_continue :: proc(fiber: Janet_Fiber, input: Janet, out: ^Janet) -> Janet_Signal ---

	// Type checking
	janet_type :: proc(x: Janet) -> Janet_Type ---
	janet_checktype :: proc(x: Janet, type: Janet_Type) -> c.int ---
	janet_checktypes :: proc(x: Janet, typeflags: c.int) -> c.int ---

	// Arity checking
	janet_fixarity :: proc(argc: c.int32_t, arity: c.int32_t) ---
	janet_arity :: proc(argc: c.int32_t, min: c.int32_t, max: c.int32_t) ---

	// Argument extraction functions
	janet_getnumber :: proc(argv: ^Janet, n: c.int32_t) -> f64 ---
	janet_getcstring :: proc(argv: ^Janet, n: c.int32_t) -> cstring ---
	janet_getstring :: proc(argv: ^Janet, n: c.int32_t) -> Janet_String ---
	janet_getboolean :: proc(argv: ^Janet, n: c.int32_t) -> c.int ---
	janet_getinteger :: proc(argv: ^Janet, n: c.int32_t) -> c.int32_t ---

	// Wrapping functions
	janet_wrap_nil :: proc() -> Janet ---
	janet_wrap_number :: proc(x: f64) -> Janet ---
	janet_wrap_true :: proc() -> Janet ---
	janet_wrap_false :: proc() -> Janet ---
	janet_wrap_boolean :: proc(x: c.int) -> Janet ---
	janet_wrap_string :: proc(x: Janet_String) -> Janet ---
	janet_wrap_symbol :: proc(x: Janet_String) -> Janet ---
	janet_wrap_keyword :: proc(x: Janet_String) -> Janet ---
	janet_wrap_array :: proc(x: Janet_Array) -> Janet ---
	janet_wrap_tuple :: proc(x: ^Janet) -> Janet ---
	janet_wrap_table :: proc(x: Janet_Table) -> Janet ---
	janet_wrap_struct :: proc(x: rawptr) -> Janet ---
	janet_wrap_fiber :: proc(x: Janet_Fiber) -> Janet ---
	janet_wrap_buffer :: proc(x: Janet_Buffer) -> Janet ---
	janet_wrap_function :: proc(x: Janet_Function) -> Janet ---
	janet_wrap_cfunction :: proc(x: Janet_CFunction) -> Janet ---
	janet_wrap_abstract :: proc(x: rawptr) -> Janet ---
	janet_wrap_pointer :: proc(x: rawptr) -> Janet ---
	janet_wrap_integer :: proc(x: c.int32_t) -> Janet ---

	// Unwrapping functions
	janet_unwrap_number :: proc(x: Janet) -> f64 ---
	janet_unwrap_boolean :: proc(x: Janet) -> c.int ---
	janet_unwrap_string :: proc(x: Janet) -> Janet_String ---
	janet_unwrap_symbol :: proc(x: Janet) -> Janet_String ---
	janet_unwrap_keyword :: proc(x: Janet) -> Janet_String ---
	janet_unwrap_array :: proc(x: Janet) -> Janet_Array ---
	janet_unwrap_tuple :: proc(x: Janet) -> ^Janet ---
	janet_unwrap_table :: proc(x: Janet) -> Janet_Table ---
	janet_unwrap_struct :: proc(x: Janet) -> rawptr ---
	janet_unwrap_fiber :: proc(x: Janet) -> Janet_Fiber ---
	janet_unwrap_buffer :: proc(x: Janet) -> Janet_Buffer ---
	janet_unwrap_function :: proc(x: Janet) -> Janet_Function ---
	janet_unwrap_cfunction :: proc(x: Janet) -> Janet_CFunction ---
	janet_unwrap_abstract :: proc(x: Janet) -> rawptr ---
	janet_unwrap_pointer :: proc(x: Janet) -> rawptr ---
	janet_unwrap_integer :: proc(x: Janet) -> c.int32_t ---

	// String utilities
	janet_cstring :: proc(cstring: cstring) -> Janet_String ---
	janet_csymbol :: proc(str: cstring) -> Janet_String ---
	janet_string_head :: proc(str: Janet_String) -> ^Janet_StringHead ---

	// Memory management
	janet_gcroot :: proc(root: Janet) ---
	janet_gcunroot :: proc(root: Janet) -> c.int ---
	janet_collect :: proc() ---
	janet_gclock :: proc() -> c.int ---
	janet_gcunlock :: proc(handle: c.int) ---

	// Table operations
	janet_table :: proc(capacity: c.int32_t) -> Janet_Table ---
	janet_table_get :: proc(t: Janet_Table, key: Janet) -> Janet ---
	janet_table_put :: proc(t: Janet_Table, key: Janet, value: Janet) ---
	janet_resolve :: proc(env: Janet_Table, sym: Janet_String, out: ^Janet) -> c.int ---
	janet_def :: proc(env: Janet_Table, name: cstring, val: Janet, documentation: cstring) ---
	janet_cfuns :: proc(env: Janet_Table, regprefix: cstring, cfuns: ^Janet_Reg) ---

	// Array operations
	janet_array :: proc(capacity: c.int32_t) -> Janet_Array ---
	janet_array_push :: proc(array: Janet_Array, x: Janet) ---
	janet_array_length :: proc(array: Janet_Array) -> c.int32_t ---
	janet_array_peek :: proc(array: Janet_Array) -> ^Janet ---

	// Fiber operations
	janet_fiber :: proc(function: Janet_Function, capacity: c.int32_t, argc: c.int32_t, argv: ^Janet) -> Janet_Fiber ---
	janet_fiber_reset :: proc(fiber: Janet_Fiber, function: Janet_Function, argc: c.int32_t, argv: ^Janet) -> Janet_Fiber ---
	janet_fiber_status :: proc(fiber: Janet_Fiber) -> Janet_Fiber_Status ---
	janet_current_fiber :: proc() -> Janet_Fiber ---

	// Tuple operations
	janet_tuple_n :: proc(values: ^Janet, n: c.int32_t) -> ^Janet ---
	janet_tuple_length :: proc(tuple: ^Janet) -> c.int32_t ---

	// Pretty printing
	janet_pretty :: proc(buffer: Janet_Buffer, tab_width: c.int32_t, flags: c.int32_t, x: Janet) ---

	// Buffer operations
	janet_buffer :: proc(capacity: c.int32_t) -> Janet_Buffer ---
	janet_buffer_u8_string :: proc(buffer: Janet_Buffer) -> ^u8 ---
}

// Helper function to get string length (equivalent to the janet_string_length macro)
janet_string_length :: proc(str: Janet_String) -> c.int32_t {
	if str == nil {
		return 0
	}
	head := janet_string_head(str)
	if head == nil {
		return 0
	}
	return head.length
}

// Helper functions for struct-based Janet values (non-nanbox)
janet_get_type_struct :: proc(x: Janet) -> Janet_Type {
	return x.type
}

janet_is_number_struct :: proc(x: Janet) -> bool {
	return x.type == .NUMBER
}

janet_is_boolean_struct :: proc(x: Janet) -> bool {
	return x.type == .BOOLEAN
}

janet_is_nil_struct :: proc(x: Janet) -> bool {
	return x.type == .NIL
}

janet_is_string_struct :: proc(x: Janet) -> bool {
	return x.type == .STRING
}

// Extract boolean value from struct
janet_unwrap_boolean_struct :: proc(x: Janet) -> bool {
	if x.type != .BOOLEAN do return false
	// Boolean value is stored as integer in the union
	return (x.as.u64 & 0x1) != 0
}

// Type flags for janet_checktypes
JANET_TFLAG_NIL :: 1 << u32(Janet_Type.NIL)
JANET_TFLAG_BOOLEAN :: 1 << u32(Janet_Type.BOOLEAN)
JANET_TFLAG_FIBER :: 1 << u32(Janet_Type.FIBER)
JANET_TFLAG_NUMBER :: 1 << u32(Janet_Type.NUMBER)
JANET_TFLAG_STRING :: 1 << u32(Janet_Type.STRING)
JANET_TFLAG_SYMBOL :: 1 << u32(Janet_Type.SYMBOL)
JANET_TFLAG_KEYWORD :: 1 << u32(Janet_Type.KEYWORD)
JANET_TFLAG_ARRAY :: 1 << u32(Janet_Type.ARRAY)
JANET_TFLAG_TUPLE :: 1 << u32(Janet_Type.TUPLE)
JANET_TFLAG_TABLE :: 1 << u32(Janet_Type.TABLE)
JANET_TFLAG_STRUCT :: 1 << u32(Janet_Type.STRUCT)
JANET_TFLAG_BUFFER :: 1 << u32(Janet_Type.BUFFER)
JANET_TFLAG_FUNCTION :: 1 << u32(Janet_Type.FUNCTION)
JANET_TFLAG_CFUNCTION :: 1 << u32(Janet_Type.CFUNCTION)
JANET_TFLAG_ABSTRACT :: 1 << u32(Janet_Type.ABSTRACT)
JANET_TFLAG_POINTER :: 1 << u32(Janet_Type.POINTER)

// Convenience type flags
JANET_TFLAG_BYTES ::
	JANET_TFLAG_STRING | JANET_TFLAG_SYMBOL | JANET_TFLAG_BUFFER | JANET_TFLAG_KEYWORD
JANET_TFLAG_INDEXED :: JANET_TFLAG_ARRAY | JANET_TFLAG_TUPLE
JANET_TFLAG_DICTIONARY :: JANET_TFLAG_TABLE | JANET_TFLAG_STRUCT
JANET_TFLAG_CALLABLE :: JANET_TFLAG_FUNCTION | JANET_TFLAG_CFUNCTION

// Error types
Janet_Error :: enum {
	NONE,
	INIT_FAILED,
	EVAL_FAILED,
	TYPE_ERROR,
	MEMORY_ERROR,
	FIBER_ERROR,
}

// Odin-friendly wrapper types
Value :: struct {
	janet:  Janet,
	vm:     ^VM, // Reference to parent VM for cleanup
	rooted: bool, // Track if value is GC rooted
}

VM :: struct {
	env:           Janet_Table,
	initialized:   bool,
	mutex:         sync.Mutex,

	// Core functions
	eval_func:     Janet_Function,
	format_func:   Janet_Function,

	// Cleanup tracking
	rooted_values: [dynamic]^Value,
}

// Bootstrap Janet code (embedded) - simplified to avoid eval-string issues
BOOTSTRAP_CODE :: `
(defn odin/format
  "Format a Janet value as a string."
  [x]
  (string/format "%j" x))
`


// VM management
vm_new :: proc(allocator := context.allocator) -> (^VM, Janet_Error) {
	vm := new(VM, allocator)
	vm.rooted_values = make([dynamic]^Value, allocator)

	// Mutex is zero-initialized

	janet_init()
	vm.env = janet_core_env(nil)

	if vm.env == nil {
		janet_deinit()
		free(vm, allocator)
		return nil, .INIT_FAILED
	}

	// Skip bootstrap for now - it might be causing the hang
	vm.initialized = true
	return vm, .NONE
}

vm_destroy :: proc(vm: ^VM, allocator := context.allocator) {
	if !vm.initialized {
		return
	}

	sync.mutex_lock(&vm.mutex)
	defer sync.mutex_unlock(&vm.mutex)

	// Unroot all tracked values
	for value in vm.rooted_values {
		if value.rooted {
			janet_gcunroot(value.janet)
			value.rooted = false
		}
	}
	delete(vm.rooted_values)

	janet_deinit()
	vm.initialized = false

	// No need to destroy mutex
	free(vm, allocator)
}

// Value management
value_new :: proc(vm: ^VM, janet_val: Janet, root := true) -> ^Value {
	value := new(Value)
	value.janet = janet_val
	value.vm = vm

	if root {
		janet_gcroot(janet_val)
		value.rooted = true

		sync.mutex_lock(&vm.mutex)
		append(&vm.rooted_values, value)
		sync.mutex_unlock(&vm.mutex)
	}

	return value
}

value_destroy :: proc(value: ^Value) {
	if value.rooted {
		janet_gcunroot(value.janet)
		value.rooted = false

		// Remove from VM's tracking list
		vm := value.vm
		sync.mutex_lock(&vm.mutex)
		for i := 0; i < len(vm.rooted_values); i += 1 {
			if vm.rooted_values[i] == value {
				unordered_remove(&vm.rooted_values, i)
				break
			}
		}
		sync.mutex_unlock(&vm.mutex)
	}

	free(value)
}

// High-level evaluation
vm_eval :: proc(vm: ^VM, code: string, allocator := context.allocator) -> (^Value, Janet_Error) {
	if !vm.initialized {
		return nil, .INIT_FAILED
	}

	code_cstr := strings.clone_to_cstring(code, allocator)
	defer delete(code_cstr, allocator)

	result: Janet
	status := janet_dostring(vm.env, code_cstr, "<eval>", &result)

	if status != 0 {
		return nil, .EVAL_FAILED
	}

	return value_new(vm, result), .NONE
}

// Value type checking and conversion
value_type :: proc(value: ^Value) -> Janet_Type {
	return janet_get_type_struct(value.janet)
}

value_is_nil :: proc(value: ^Value) -> bool {
	return janet_is_nil_struct(value.janet)
}

value_is_number :: proc(value: ^Value) -> bool {
	return janet_is_number_struct(value.janet)
}

value_is_string :: proc(value: ^Value) -> bool {
	return janet_is_string_struct(value.janet)
}

value_is_boolean :: proc(value: ^Value) -> bool {
	return janet_is_boolean_struct(value.janet)
}

// Value extraction
value_to_number :: proc(value: ^Value) -> (f64, bool) {
	if !value_is_number(value) {
		return 0, false
	}
	return janet_unwrap_number(value.janet), true
}

value_to_boolean :: proc(value: ^Value) -> (bool, bool) {
	if !value_is_boolean(value) {
		return false, false
	}
	return janet_unwrap_boolean_struct(value.janet), true
}

value_to_string :: proc(value: ^Value) -> (string, bool) {
	if !value_is_string(value) {
		return "", false
	}

	janet_str := janet_unwrap_string(value.janet)
	if janet_str == nil {
		return "", false
	}

	length := janet_string_length(janet_str)
	if length == 0 {
		return "", true
	}

	// Convert Janet string to Odin string
	bytes := (cast([^]u8)janet_str)[:length]
	return string(bytes), true
}

// Value creation
vm_nil :: proc(vm: ^VM) -> ^Value {
	return value_new(vm, janet_wrap_nil())
}

vm_number :: proc(vm: ^VM, x: f64) -> ^Value {
	return value_new(vm, janet_wrap_number(x))
}

vm_boolean :: proc(vm: ^VM, x: bool) -> ^Value {
	return value_new(vm, janet_wrap_boolean(x ? 1 : 0))
}

vm_string :: proc(vm: ^VM, s: string, allocator := context.allocator) -> ^Value {
	s_cstr := strings.clone_to_cstring(s, allocator)
	defer delete(s_cstr, allocator)

	janet_str := janet_cstring(s_cstr)
	return value_new(vm, janet_wrap_string(janet_str))
}

// Pretty printing
value_format :: proc(value: ^Value, allocator := context.allocator) -> string {
	vm := value.vm
	if vm.format_func == nil {
		return "<unprintable>"
	}

	args := [1]Janet{value.janet}
	result := janet_call(vm.format_func, 1, &args[0])

	if janet_checktype(result, .STRING) == 0 {
		return "<format error>"
	}

	janet_str := janet_unwrap_string(result)
	length := janet_string_length(janet_str)

	bytes := (cast([^]u8)janet_str)[:length]
	return strings.clone(string(bytes), allocator)
}

// Legacy compatibility functions
init :: proc() {
	janet_init()
}

deinit :: proc() {
	janet_deinit()
}

eval :: proc(code: string, allocator := context.allocator) -> (f64, int) {
	env := janet_core_env(nil)
	if env == nil {
		return 0, -1
	}

	code_cstr := strings.clone_to_cstring(code, allocator)
	defer delete(code_cstr, allocator)

	janet_value: Janet
	status_code := int(janet_dostring(env, code_cstr, "repl", &janet_value))

	// Use our struct-based number detection
	if status_code == 0 && janet_is_number_struct(janet_value) {
		number := janet_unwrap_number(janet_value)
		return number, status_code
	}

	return 0, status_code
}
