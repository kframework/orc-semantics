See [LICENSE](LICENSE) for licensing information.

Orc Semantics
=============

Orc is a minimal calculus for modeling concurrent sevice-oriented computations based on the theory of service orchestration by J. Misra. This project is a formal semantics of the Orc calculus written in K. 

Relevant Publications
---------------------
- Orc's introductory paper: [Computaion Orchestration](http://dx.doi.org/10.1007/s10270-006-0012-1).
- FM'15 conference paper: [Towards Formal Verification of Orchestration Computations using the K Framework](http://dx.doi.org/10.1007/978-3-319-19249-9_4).
- MS thesis: [A Formal Executable Semantics of Orc using the K Framework](http://dx.doi.org/10.13140/RG.2.1.3260.1203).

Orc Language
------------
The [Orc programming language](https://orc.csres.utexas.edu/index.shtml) is based on the Orc calculus. This semantics does not cover all of the Orc language's constructs. However, because any program of the Orc language can be expressed in Orc calculus, this semantics can effectively be used to execute programs written in the Orc language.
In this work, the term *Orc* refers to the Orc calculus.

How to Build and Run
====================
This version of the Orc semantics uses version 3.5 of the K tool, which is the last version to support the Maude backend. Download it [here](http://github.com/kframework/k/releases/tag/v3.5.2).

After placing K3.5's binaries folder `k/bin` in your environment path, you can use the following commands:

To compile
- `kompile src/orc.k`

To run an Orc program
- `krun test/orcexmp1.orc -cTL=30 -cV=false`
	- `TL`: Time Limit, the maximum logical time allowed. After that the program will not progress time further, and will halt.
	- `V`: Verbose, a boolean to show all threads even those that have finished execution, i.e., to not fire the cleanup rules.

`krun` Search Patterns
----------------------

To write search patterns, you have to specify variables inside the cells and then check them using a `when`/`requires` condition. And the output will show only those variables specified. The pattern should be enclosed in double quotes. The command looks like: 
`krun program.orc --search --pattern "thePattern"`.

Following are some tested patterns:
- `<gPublish> L:List </gPublish> when 11 in L`, shows only what's in L.
- `<T> B:Bag <gPublish> L:List </gPublish> </T> when L =/=K .List`, shows `B` and `L` when `gpublish` is not empty.
- `<gVars>... "BotVars" |-> (M:Map \"is_bumper_hit\" |-> Hit) </gVars> when Hit ==K true`, shows `M` and `Hit`.
- `<T> B:Bag <gVars>... "BotVars" |-> (M:Map \"is_bumper_hit\" |-> Hit) </gVars> </T> when Hit ==K true`.

Following are some wrong ways to write patterns:
- `<gPublish> ListItem(11) </gPublish>`
- `<gPublish> _:List </gPublish>`

Sample Orc Programs
-------------------
The [test](test) folder contains a number of Orc programs. The ones prefixed with `robot_demo` such as [`robot_demo_1.orc`](test/robot_demo_1.orc) correspond to published case studies.
