// to test this, do krun like the following:
//mykrun test\test_ltlmc1.orc --ltlmc "[]Ltl isGPublished(3)"
// or try the following ltl expressions:
//<>Ltl isGPublished(3)
//gVarEq(\"clock\",0)


DummyExp() := stop
Add(1,r) < r < 2


/*
For a reference to LTL and its operators and how to write them in K, see the Maude book "All about Maude" and the file 'model-checker.k'. 
[] means always, i.e., in every single state along the execution path.
<> means eventually, i.e., in the final state
*/