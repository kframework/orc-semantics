// tests parallel spawning. publishes 4 and 5
DummyExp(a,b) := Add(a,b)
(Add(0,1) | Add(0,2)) > x > Add(x,3)