// imitates recursive calls. tests propagation of variable mappings.
DummyExp() := let(0)
signal >> if(false) | signal >> if(false) | Add(b,1) < b < 1
//0 >> If(false) | Add(b,1) < b < 1

/*
krun test.orc --search --pattern "<gPublish> L:List </gPublish>" 
This exercise is to discover the problem of the factorial example by moving from the most simple to more complex. This was tested on revision 29, and the results are given below. On revision 31, where I only changed the var-request-reset rule to structural, the output has not changed at all, even the number of transitions.

Example 1. Works. outputs 2, 3. In K3.6, it loops forever! Perhaps it's the rules that use #configuration. After all it's the only difference between 3.5 and 3.6 versions.
if(false) | (( Add(b,1) | ( Add(b,1) < b < Add(b,1) )) < b < let(1) )

Example 2. Works. outputs 2, 3, 4. Gives 6 solutions. 
Let(freeze) | (( Add(b,1) | ( ( Add(b,1) | ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < Let(1) )

Example 3.1. Works. outputs 2, 3, 4. two transitions more than previous example because of two sequential ops. This gives 56 solutions. This means that the change from example 2 to 3, increased the solutions and tid numbers. Let's minimize to pin-point the probelm.
Signal() >> Let(freeze) | Signal() >> (( Add(b,1) | ( ( Add(b,1) | ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < Let(1) )

Example 3.2 minimizing from example 3.1. this gave 6 solutions.
If(false) | Signal() >> (( Add(b,1) | ( ( Add(b,1) | ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < 1)

Example 3.3 minimizing from example 3.1. this gave 50 solutions.
Signal() >> If(false) | (( Add(b,1) | ( ( Add(b,1) | ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < 1)

Example 3.4 minimizing from example 3.3. removed top pruning. this gave 1 solution.
Signal() >> If(false) | ( Add(b,1) | ( ( Add(b,1) | ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) ))

Example 3.5 minimizing from example 3.3. removed mid pruning. this gave 27 solutions.
Signal() >> If(false) | ( Add(b,1) | ( ( Add(b,1) | ( Add(b,1) < b < Add(b,1) )) ) < b < 1)

Example 3.6 minimizing from example 3.5. removed bottom pruning. this gave 9 solutions.
Signal() >> If(false) | ( Add(b,1) | Add(b,1) | Add(b,1) < b < 1)

Example 3.7 minimizing from example 3.6. this gave 1 solution.
Add(b,1) | Add(b,1) | Add(b,1) < b < 1

Example 3.8 minimizing from example 3.6. this gave 5 solutions.
Signal() >> If(false) | Add(b,1) | Add(b,1) < b < 1

Example 3.9.0 minimizing from example 3.8. this gave 3 solutions. This is as minimal as I can get, I think.
Signal() >> If(false) | Add(b,1) < b < 1

Example 3.9.1 This gave 2 solutions. but that's expected. what's strange is the tid number difference.
Signal() >> If(false) | 1

Example 3.9.2 This too gave two solutions.
Signal() >> If(false) | Signal() >> If(false)

Example 3.9.3 This one is derived from example 3.9.0. This is strange. why this gives two solutions. it should give six, but all the six are actually two. However, example 3.9.0 gives three but it should give only one. It must be the thread getting stuck, the if(false) one.
0 >> 3 | b < b < 1

CONCLUSION for the many solutions problem. It is not a problem. The order at which the transition rule applies for different threads is what makes that many solutions. The weird example is 3.4. No it is not weird. It just has a parentheses problem.

Example 4. Works. outputs 2, 3, 4. added more seq ops. --search takes too long on this and then goes out of memory. This means that 12 concurrent publish transitions are too much for K to handle.
Signal() >> Let(freeze) | Signal() >> (( Signal() >> Add(b,1) | Signal() >> ( ( Signal() >> Add(b,1) | Signal() >> ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < Let(1) )
Example 4.5 This has one less signal. --search takes a long time (about 30 minutes) on this but works giving 1295 solutions. --search-final gave 1295 solutions. --search --depth 5 gave 149 solutions.
Signal() >> Let(freeze) | Signal() >> (( Add(b,1) | Signal() >> ( ( Signal() >> Add(b,1) | Signal() >> ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < Let(1) )
Example 4.6 Same as 4.5 but without varrequest needed for freeze. this same results as 4.5.
Signal() >> If(false) | Signal() >> (( Add(b,1) | Signal() >> ( ( Signal() >> Add(b,1) | Signal() >> ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < Let(1) )

Example 5.1 gives 10. the topmost pruning prunes everything else. so we change something to see the value of the pruning that is below it as in 5.2. then we allow the one below that in 5.3 and see the result of the bottom-most pruning. of course running search on this example should give all three solutions, but it's taking a long time and then gives out of memory error.
Signal() >> Let(freeze) | Signal() >> ( Mul(a,5) < a < (( Signal() >> Add(b,1) | Signal() >> ( Mul(a,5) < a < ( ( Signal() >> Add(b,1) | Signal() >> ( Mul(a,5) < a < ( Add(b,1) < b < Add(b,1) ))) < b < Add(b,1) ))) < b < Let(1) ) )

Example 5.2 gives two solutions: 500 and 75
Signal() >> Let(freeze) | Signal() >> ( Mul(a,5) < a < (( Signal() >> freeze | Signal() >> ( Mul(a,5) < a < ( ( Signal() >> Add(b,1) | Signal() >> ( Mul(a,5) < a < ( Add(b,1) < b < Add(b,1) ))) < b < Add(b,1) ))) < b < Let(1) ) )

Example 5.3 gives 500.
Signal() >> Let(freeze) | Signal() >> ( Mul(a,5) < a < (( Signal() >> freeze | Signal() >> ( Mul(a,5) < a < ( ( Signal() >> freeze | Signal() >> ( Mul(a,5) < a < ( Add(b,1) < b < Add(b,1) ))) < b < Add(b,1) ))) < b < Let(1) ) )

Example 6.1 Let us simplify example 5. It looks like we took it too far. We will remove any seq thread between prll and prun. Running this gave 10. searching gave 48 solutions, even though only one transition rule we have, the publishing. should give three solutions: 10, 75, 500.
Signal() >> If(false) | ( Mul(a,5) < a < (( Signal() >> Add(b,1) | ( Mul(a,5) < a < ( ( Signal() >> Add(b,1) | ( Mul(a,5) < a < ( Add(b,1) < b < Add(b,1) ))) < b < Add(b,1) ))) < b < Let(1) ) )

Example 6.2. should give two solutions: 75 and 500. this gives a solution when executed but runs forever when in --search.
Signal() >> If(false) | ( Mul(a,5) < a < (( Signal() >> If(false) | ( Mul(a,5) < a < ( ( Signal() >> Add(b,1) | ( Mul(a,5) < a < ( Add(b,1) < b < Add(b,1) ))) < b < Add(b,1) ))) < b < Let(1) ) )

Example 6.3. should give 500.
Signal() >> If(false) | ( Mul(a,5) < a < (( Signal() >> If(false) | ( Mul(a,5) < a < ( ( Signal() >> If(false) | ( Mul(a,5) < a < ( Add(b,1) < b < Add(b,1) ))) < b < Add(b,1) ))) < b < Let(1) ) )
Example 6 gave the same results as example 5.

OK I think the multiple solutions are because of all permutations of publishing. Remember that every (signal >> something) needs a transition and Every Let does too. So I'm going to minimize even more, by removing signals and removing Lets and turning all Let(freeze) into If(false). But removing Lets doesn't change anything. A publish will still happen, and it will take a transition.

Example 7.1. should give 10, 75 and 500.
If(false) | ( Mul(a,5) < a < (( Add(b,1) | ( Mul(a,5) < a < ( ( Add(b,1) | ( Mul(a,5) < a < ( Add(b,1) < b < Add(b,1) ))) < b < Add(b,1) ))) < b < 1 ) )
Example 7.2. should give 75 and 500.
If(false) | ( Mul(a,5) < a < (( If(false) | ( Mul(a,5) < a < ( ( Add(b,1) | ( Mul(a,5) < a < ( Add(b,1) < b < Add(b,1) ))) < b < Add(b,1) ))) < b < 1 ) )
Example 7.3. This got stuck. and var requests reached root. should give 500.
If(false) | ( Mul(a,5) < a < (( If(false) | ( Mul(a,5) < a < ( ( If(false) | ( Mul(a,5) < a < ( Add(b,1) < b < Add(b,1) ))) < b < Add(b,1) ))) < b < 1 ) )

These also have the same pattern. let's simplify more. 
Example 8.1 --search should give three solutions, 10, 15 and 20.
If(false) | ( Mul(a,5) < a < (( Add(b,1) | ( ( Add(b,1) | ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < 1 ) )
Example 8.2 --search should give two solutions, 15 and 20.
If(false) | ( Mul(a,5) < a < (( If(false) | ( ( Add(b,1) | ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < 1 ) )
Example 8.3 --search should give one solution, 20.
If(false) | ( Mul(a,5) < a < (( If(false) | ( ( If(false) | ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < 1 ) )

Example 9.2
If(false) | (( If(false) | ( ( Add(b,1) | ( Add(b,1) < b < Add(b,1) )) < b < Add(b,1) )) < b < 1 ) 

Example 10.2
If(false) | (( If(false) | ( ( Add(b,1) | Add(b,1) ) < b < Add(b,1) )) < b < 1 ) 

I found what the problem was. The push-var-request-up rule had a wrong condition. Instead of checking if the thread that is passing up the request is not a prunLeft, it checked the requester thread. I fixed that and the last example worked. Now I'm going back up the examples, testing them one by one.
*/ 