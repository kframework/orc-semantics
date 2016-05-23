// tests nested expression definition and call
// tests scope of variables, that vars with the same name don't mix up
// prints 5
Sum3(x,y,z) := Add(x,a) < a < Add(y,z)
Sum2(x,y) := Sum3(x,y,0)
Sum2(2,3) > x > print(x)