// Factorial definition
//If(false) getting stuck is fine. But rewriting it to a silent handle makes this example go out of memory. This means that a rule is being reapplied infinitely on the handle. In this revision, disabling the rule Site-If-false makes this work, otherwise it gives stack out of memory error.
Factorial(x) := (((if(r) < r < Equals(x,0)) >> 1) | ((if(r) < r < Gr(x,0)) >> (Mul(a,x) < a < (Factorial(b) < b < Sub(x,1)))))
//Factorial(x) := (((If(r) < r < Equals(x,0)) >> 1) | ((If(r) < r < Gr(x,0)) >> ((Sub(x,1) > b > Factorial(b)) > a > Mul(a,x))))
//(Print(f0) < f0 < Factorial(0))
// >> (Print(f1) < f1 < Factorial(1)) 
// >> (Print(f2) < f2 < Factorial(2))
// >> (Print(f3) < f3 < Factorial(3))
//Factorial(0) > f0 > Print(f0) 
//Factorial(1) > f1 > Print(f1)
// Factorial(2)
Factorial(5) > f3 > print(f3)
