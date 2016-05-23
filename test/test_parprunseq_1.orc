// tests parallel spawning and pruning. prints either 4 or 5.
//mykrun test\test_parprunseq_1.orc --search --pattern "<out> L:List </out>"
//mykrun test\test_parprunseq_1.orc --ltlmc "<>Ltl isPrinted(4)"
DummyExp(a,b) := Add(a,b)
print(y) < y < (Add(0,1) | Add(0,2)) > x > Add(x,3)