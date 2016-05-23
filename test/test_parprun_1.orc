// tests pruning a parallel composition
// test with the --search switch. should have two solutions, one that publishes 11, and one that publishes 21
//mykrun test\test_parprun_1.orc --search --pattern "<gPublish> L:List </gPublish>"
DummyExp(a,b) := Add(a,b)
Add(x,1) < x < (Add(0,20) | Add(0,10))
