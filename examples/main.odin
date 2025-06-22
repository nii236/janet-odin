 package main

  import "core:c"
  import "core:fmt"
  import janet "../src"


  main :: proc() {
      // Initialize Janet
      janet.init()
      defer janet.deinit()

      // Simple Janet evaluation

//         result := janet.eval("(+ 1 2 3)")
//   fmt.printf("Janet exit code: %d\n", result)
 result, code := janet.eval("(+ 1 2 3)")
  fmt.printf("Result: %f (exit: %d)\n", result, code)
}
