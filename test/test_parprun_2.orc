// tests pruning a parallel composition, precedence of parallel over pruning.
//mykrun test\test_parprun_2.orc --search --pattern "<gPublish> L:List </gPublish>"
DummyExp(a,b) := Add(a,b)
Add(x,1) < x < Add(0,10) | Add(0,20) | Add(0,30) | Add(0,40)
