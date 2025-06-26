# Sample Janet module for preloading demo

(def module-name "sample-math")
(def version "1.0.0")

# Simple math utilities
(defn square [x]
  "Square a number"
  (* x x))

(defn cube [x] 
  "Cube a number"
  (* x x x))

(defn fibonacci [n]
  "Calculate nth Fibonacci number"
  (if (<= n 1)
    n
    (+ (fibonacci (- n 1)) (fibonacci (- n 2)))))

(defn prime? [n]
  "Check if a number is prime"
  (cond
    (< n 2) false
    (= n 2) true
    (= 0 (% n 2)) false
    (do
      (var i 3)
      (var result true)
      (while (and result (<= (* i i) n))
        (when (= 0 (% n i))
          (set result false))
        (+= i 2))
      result)))

# Module exports
(def exports
  {:square square
   :cube cube
   :fibonacci fibonacci
   :prime? prime?
   :name module-name
   :version version})

exports