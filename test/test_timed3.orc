// This one is equivalent to:
// Rtimer(3) >> (print(x) < x < clock)
// but it tests also passing a site as an argument.
// prints 3
DummyExp(a,b) := Add(a,b)
Rtimer(3) >> print(clock)