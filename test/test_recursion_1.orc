// The following command verifies that at time 3, it must be the case that 4 or 5 or 6 publishes happened.
// krun ..\test\test_recursion_1.orc -cTL=3 -cV=false -w none --ltlmc "[]Ltl (gVarEq(\"time.clock\",3) =>Ltl (gVarEq(\"publishCount\",4) \/Ltl gVarEq(\"publishCount\",5) \/Ltl gVarEq(\"publishCount\",6)))"
E() := Rtimer(1) >> (let(1) | E())
E()
