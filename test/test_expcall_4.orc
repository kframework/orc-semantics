// tests function definition and calling inside nested pruning and identical variable names
Sum3(x,y,z) := Add(x,a) < a < Add(y,z)

// this should not confuse the two x's. should print 15, not 13.
print(x) < x < (Sum3(4,5,x) < x < Sum3(1,2,3))

// this too should not print 13, but 15.
//Print(f2) < f2 < (Sum3(4,5,x) < x < Sum3(1,2,3))

// this prints 15.
//Print(x) < x < (Sum3(4,5,f1) < f1 < Sum3(1,2,3))

// Even without the parentheses, should print 15.
//Print(x) < x < Sum3(4,5,f1) < f1 < Sum3(1,2,3)

// this prints 15
//(Sum3(4,5,f1) < f1 < Sum3(1,2,3)) > x > Print(x)

// small name change should still print 15, not 13.
//(Sum3(4,5,x) < x < Sum3(1,2,3)) > f2 > Print(f2)


