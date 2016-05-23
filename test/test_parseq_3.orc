//tests passing parameters in nested sequential composition. publishes 3 and 5
DummyExp(a,b) := Add(a,b)
(Add(0,1) | Add(0,2)) > x > (Add(x,1) > y > Add(x,y))