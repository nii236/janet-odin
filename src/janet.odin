 package janet

  import "core:c"
  import "core:fmt"
    import "core:strings"

  // Foreign import for Janet library
  foreign import janet {
      "../lib/macos/libjanet.a",
  }
  Janet :: [8]u8  // Janet is an 8-byte tagged union
  // Basic Janet C API bindings
  foreign janet {
      janet_init :: proc() ---
      janet_deinit :: proc() ---
      janet_dostring :: proc(env: rawptr, str: cstring, sourcePath: cstring, out: ^Janet) -> c.int ---
      janet_core_env :: proc(replacements: rawptr) -> rawptr ---
      janet_to_string :: proc(value: Janet) -> rawptr ---  // Returns JanetString (uint8_t*)
      janet_unwrap_number :: proc(value: Janet) -> f64 ---
}
  // Odin-friendly wrapper procedures
  init :: proc() {
      janet_init()
  }

  deinit :: proc() {
      janet_deinit()
  }

  eval :: proc(code: string) -> (f64, int) {
      code_cstr := strings.clone_to_cstring(code)
      defer delete(code_cstr)

      env := janet_core_env(nil)
      janet_value: Janet

      status_code := int(janet_dostring(env, code_cstr, "repl", &janet_value))

      if status_code == 0 {
          number := janet_unwrap_number(janet_value)
          return number, status_code
      }

      return 0, status_code
  }
