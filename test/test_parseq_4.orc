// prints 100 and publishes 2, 3 and signal
DummyExp(a,b) := Add(a,b)
(Add(0,1) | Add(0,2)) > x > Add(x,1) | print(100)