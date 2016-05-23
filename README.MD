See [LICENSE](LICENSE) for licensing information.

Orc Semantics
=============

This version of the Orc semantics uses version 3.5 of the K tool, which is the last version to support the Maude backend. Download it [here](http://github.com/kframework/k/releases/tag/v3.5.2).

After placing K3.5's binaries in your path, you can use the following commands:

To compile
- `kompile src\orc.k`

To run an Orc program
- `krun test\orcexmp1.orc -cTL=30 -cV=false`
	- `TL`: Time Limit, the maximum logical time allowed. After that the program will not progress time further, and will halt.
	- `V`: Verbose, a boolean to show all threads even those that have finished execution, i.e., to not fire the cleanup rules.

`krun` Search Patterns
======================

To write search patterns, you have to specify variables inside the cells and then check them using a `when`/`requires` condition. And the output will show only those variables specified. The pattern should be enclosed in double quotes. The command looks like: `krun program.orc --search --pattern "thePattern"`
Following are some tested patterns:
`<gPublish> L:List </gPublish> when 11 in L //shows only what's in L`
`<T> B:Bag <gPublish> L:List </gPublish> </T> when L =/=K .List // shows the whole solution where something is in gpublish.`
`<gVars>... "BotVars" |-> (M:Map \"is_bumper_hit\" |-> B) </gVars> when B ==K true // Similarly, this shows what's in M and B.`
`<T> B:Bag <gVars>... "BotVars" |-> (M:Map \"is_bumper_hit\" |-> Hit) </gVars> </T> when Hit ==K true // This works.`

Following are some wrong ways to write patterns:
`<gPublish> ListItem(11) </gPublish> // doesn't work`
`<gPublish> _:List </gPublish> // doesn't work`
