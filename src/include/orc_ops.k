//@ \section{Orc's Combinators}	
module ORC_OPS
	imports ORC_SYNTAX
	
	
	//======================PARALLEL===========================
	/*@ \paragraph{Parallel Combinator}
  \label{appendix:par}
	\blockquote{"The parallel combinator, written $f \mid g$, executes expressions $f$ and 
	$g$ concurrently. They have no direct interaction with each other. Each 
	publication of $f$ or $g$ is published by $f \mid g$. When both $f$ and $g$ 
	have halted, $f \mid g$ halts."\\\cite{kitchin_orchestration_2013}} 
	*/
	
	/*@
	The following rule, when facing a parallel composition, creates two sub-threads 
	placing its thread id in their parentId cells, copying its context into 
	theirs, and creating new ids for them. And this is what we will be doing 
	every time we create a sub-thread. We place each of the two operands, \textsf{F} and \textsf{G}, in a 
	sub-thread because we want them to execute in parallel. \K executes multiple 
	threads concurrently on its own, without us having to specify so.

 	The rule replaces the whole expression with a meta-function we defined called 
	\textsf{prllCompMgr(Int)}; the int argument is the count of sub-threads 
	managed by this manager.
	*/
	//In 'prllCompMgr(Int)', the int keeps count of managed parallel threads
	
	// create manager for parallel composition
	rule [Parallel-Prep-1]:
		<thread>...
			<k> (F:Exp | G:Exp) => prllCompMgr(2) </k>
			<context> Context </context> <br/>
			<tid> ManagerId </tid>
			<props> S:Set </props>
		...</thread> <br/>
		(.Bag => <thread>...
			<k> F </k>
			<context> Context </context> <br/>
			<tid> !NewId1:Int </tid>
			<parentId> ManagerId </parentId> <br/>
			<props> 
				SetItem("prllChild") 
				SetItem("publishUp")
			</props>
		...</thread> <br/>
		<thread>...
			<k> getNewId(G) </k>
			<context> Context </context> <br/>
			<tid> !NewId2:Int </tid>
			<parentId> ManagerId </parentId> <br/>
			<props> 
				SetItem("prllChild")
				SetItem("publishUp")
			</props>
		...</thread>)
		when notBool "prllChild" in S
	[structural]
	
	/*@
	The following rule is applied recursively flattening the tree created 
	by the right-associativity of the parallel operator, thus by 
	effectively making it a fully-associative operator. Let us elaborate.

	Suppose the program has four expressions to be run in parallel like so: \texttt{E1 | 
	E2 | E3 | E4}. Recall that in the syntax module, we declared the parallel 
	operator right-associative. This means that our expression will be parsed 
	effectively as: \texttt{E1 | (E2 | (E3 | (E4)))}. This leads to the previous rule 
	creating two sub-threads, one containing \texttt{E1}, and the other, 
	\texttt{(E2 | (E3 | (E4)))}. Then, we must write a rule to handle the 
	second sub-thread recursively.

 	So in the following rule, we handle the case where the second 
	expression of the previous rule was itself another parallel expression 
	containing two operands, the second of which might itself be a compound 
	parallel expression which will still be handled by this rule 
	recursively.

 	Notice that we increase the count of the 
	\textsf{prllCompMgr}'s children by one. Every time this rule is executed, 
	it creates a new sub-thread until it recursively processes the whole 
	expression of parallel-operator-separated expressions.
	*/
	// flatten complex parallel tree
	rule [Parallel-Prep-2-Flatten]:
		<thread>...
			<k> (F:Exp | G:Exp) => F </k>
			<props>... SetItem("prllChild") ...</props> <br/>
			<parentId> ManagerId </parentId>
		...</thread> <br/>
		<thread>...
			<k> prllCompMgr(N:Int) => prllCompMgr(N +Int 1) </k> <br/>
			<context> Context </context>
			<tid> ManagerId </tid>
		...</thread> <br/>
		(.Bag => <thread>...
			<k> G </k>
			<context> Context </context>
			<tid> !NewId:Int </tid>
			<parentId> ManagerId </parentId> <br/>
			<props>
				SetItem("prllChild")
				SetItem("publishUp") 
			</props>
		...</thread>)
	[structural]
	
	/*@
	The following two rules are cleanup rules. In the first cleanup
	rule, The manager
	destroys a child once it has halted and passed
	any values to be published to the manager. The manager 
	decrements its count of children once it has destroyed one.
	*/
	// cleanup rule 1
	rule [Parallel-Cleanup-1]:
		<thread>...
			<k> prllCompMgr(N:Int) => prllCompMgr(N -Int 1) </k>
			<tid> ManagerId </tid>
		...</thread> <br/>
		<thread>...
			<k> .K => killed(.K) </k>
			<parentId> ManagerId </parentId>
			<publish> .List </publish> <br/>
			<props>...
				SetItem("prllChild") 
			...</props>
		...</thread>
	[structural]

	/*@
	The following is the second cleanup rule of the parallel combinator. 
	The manager ends its own execution once it has zero children to 
	manage and no values to pubilsh. 
	
	It is important to note here that
	in our general structure of thread management, no thread
	deletes itself, rather every parent is responsible for
	deleting its own children. Also, every parent is a manager.
	Therefore, the only threads that are not managers are the leaves
	in our thread tree.
	*/
	// cleanup rule 2
	rule [Parallel-Cleanup-2]:
		<thread>...
			<k> prllCompMgr(0) => .K </k>
			<publish> .List </publish>
		...</thread>
		<verbose> false </verbose>
	[structural]
	
	//====================Spawning/Sequential======================
	/*@ \paragraph{Spawning/Sequential Combinator}
  \label{appendix:seq}
	\blockquote{"The sequential combinator, written $f > x > g$, executes expression $f$. 
	The variable $x$ may appear in expression $g$, wherever a value could 
	appear. Whenever $f$ publishes a value $v$, a new copy of $g$ is executed in 
	parallel with $f > x > g$. In this copy of $g$, the variable $x$ is replaced 
	by $v$.

 	The sequential combinator may be written without a variable 
	name, as $f \gg g$. This is equivalent to writing $f > x > g$ with an $x$ 
	that never appears in $g$. When $f$ and all copies of $g$ have halted, $f > 
	x > g$ halts."\cite{kitchin_orchestration_2013}}
	*/
	
	/*@
	The first rule of the sequential combinator creates a manager and a child
	that will execute the left expression, \texttt{F}. It keeps 
	three pieces of information: the parameter that is going to pass a value
	from left to right, the right expression \texttt{G}, and a count of 
	created instances of the right expression \texttt{G}.
	*/
	
	// create manager for sequential composition
	rule [Sequential-Prep]:
		<thread>...
			<k> (F:Exp > X:Param > G:Exp) => seqCompMgr(X, G, 0) </k> <br/>
			<context> Context </context>
			<tid> ManagerId </tid>
		...</thread> <br/>
		(.Bag => <thread>...
			<k> F </k>
			<context> Context </context>
			<tid> !NewId:Int </tid>
			<parentId> ManagerId </parentId> <br/>
			<props> SetItem("seqLeftExp") </props>
		...</thread>)
	[structural]
	
	/*@
	In the second rule of the sequential combinator, once the left 
	side expression \texttt{F} publishes a value, 
	an instance of the right side expression \texttt{G} is created 
	and passed the published value. It will work independently of
	\texttt{F} and the manager, so in effect, it is working in 
	parallel with the whole composition, as is described in the
	informal semantics.
	*/
	// once left side publishes, an instance of the right side is created and passed the published value
	rule [Sequential-Spawn-Right]:
		<thread>...
			<k> seqCompMgr(X, G, N:Int) => seqCompMgr(X, G, N +Int 1) </k> <br/>
			<context> Context </context>
			<tid> ManagerId </tid>
		...</thread> <br/>
		<thread>...
			<parentId> ManagerId </parentId>
			<publish> ListItem(V:Val) => .List ...</publish> <br/>
			<props>... SetItem("seqLeftExp") ...</props>
		...</thread> <br/>
		(.Bag => <thread>...
			<k> G </k>
			<context> Context (X |-> V) </context>
			<tid> !NewId:Int </tid>
			<parentId> ManagerId </parentId> <br/>
			<props>
				SetItem("seqRightExpInstance") 
				SetItem("publishUp")
			</props>
		...</thread>)
	[structural]
	
	//@ In case of $f \gg g$, we expand it to the general format.
	// case >>
	rule [Sequential-NoVar-Prep]:
    F >> G => F > String2Id("dummy_var") > G	[macro]
	// rule V:Val ~> E:Exp => E	[structural]
	
	/*@
	The following two rules are cleanup rules. In the first cleanup
	rule, The manager
	destroys any instance of the right side expression \texttt{G} 
	once it has halted and passed
	any values to be published to the manager. The manager 
	decrements its count of active instances once it has destroyed one.
	*/
	// cleanup rule 1
	rule [Sequential-Cleanup-1]:
		<thread>...
			<k> seqCompMgr(X, G, N:Int) => seqCompMgr(X, G, N -Int 1) </k>
			<tid> ManagerId </tid>
		...</thread> <br/>
		<thread>...
			<k> .K => killed(.K) </k>
			<parentId> ManagerId </parentId>
			<publish> .List </publish> <br/>
			<props>...
				SetItem("seqRightExpInstance") 
			...</props>
		...</thread>
	[structural]
	
	/*@
	The following is the second cleanup rule of the sequential combinator. 
	The manager ends its own execution once the thread running the left side
	expression \texttt{F} has halted, it has no active instances
	of the right side expression \texttt{G}, and it has no values to pubilsh.
	It also destroys the left side thread.
	*/
	// cleanup rule 2
	rule [Sequential-Cleanup-2]:
		<thread>...
			<k> seqCompMgr(_, _, 0) => .K </k>
			<tid> ManagerId </tid>
			<publish> .List </publish>
		...</thread>
		<thread>...
			<k> .K => killed(.K) </k>
			<parentId> ManagerId </parentId>
			<publish> .List </publish> <br/>
			<props>... SetItem("seqLeftExp") ...</props>
		...</thread>
	[structural]
	
	//=====================PRUNING======================
	/*@ \paragraph{Pruning Combinator}
  \label{appendix:prun}
	\blockquote{"The pruning combinator, written $f < x < g$, executes expressions $f$ and 
	$g$ concurrently. The variable $x$ may appear in expression $f$, wherever a 
	value could appear.

 	When $g$ publishes a value $v$, execution of $g$ is 
	immediately terminated, and all occurrences of $x$ in $f$ are replaced by 
	$v$. If $g$ halts without publishing a value, all occurrences of $x$ in $f$ 
	are instead replaced by \texttt{stop}. A site call with an argument of 
	\texttt{stop} halts immediately.

 	Since $f$ begins executing before $x$ 
	is replaced, execution of $f$ may encounter a site call with an argument of 
	$x$, or even $x$ as its own expression. Execution of such expressions 
	blocks; nothing happens until $x$ is replaced by a value or \texttt{stop}, 
	and then the expression resumes execution. A blocked expression is not 
	considered halted, since it might become unblocked in the future.

 	When 
	$f$ has halted, and $g$ has either published or halted, $f < x < g$ 
	halts."\cite{kitchin_orchestration_2013}}
	*/
	
	/*@
	The idea of the pruning expression is to pass the first value 
	published by \texttt{G} to \texttt{F} as a variable \texttt{X} 
	defined in the context of \texttt{F}. But \texttt{F} should start 
	execution anyway until 	it gets the value of \texttt{X}. So, the 
	first rule creates a thread executing \texttt{F}, and another 
	executing \texttt{G}. 
	*/
  
	
	// create manager for pruning composition
	rule [Pruning-Prep]:
		<thread>...
			<k> (F:Exp < X:Param < G:Exp) => prunCompMgr(X) </k>
			<context> Context </context>
			<tid> ManagerId </tid>
		...</thread> <br/>
		(.Bag => <thread>...
			<k> F </k>
			<context> Context </context>
			<tid> !ChildId1:Int </tid>
			<parentId> ManagerId </parentId> <br/>
			<props> 
				SetItem("prunLeftExp") 
				SetItem("publishUp")
			</props>
		...</thread> <br/>
		<thread>...
			<k> getNewId(G) </k>
			<context> Context </context>
			<tid> !ChildId2:Int </tid>
			<parentId> ManagerId </parentId> <br/>
			<props> 
				SetItem("prunRightExp") 
			</props>
		...</thread>)
	[structural]
	
	/*@
	Once \texttt{G} publishes a value, the following rule 
	ends its execution and passes the published value to the left side.
	*/
	// once right side publishes, terminate it and pass the published value to the left side
	rule [Pruning-Prune-Right-And-Pass-Value-To-Left]:
		<thread>...
			<k> prunCompMgr(X:Param) </k>
			<tid> ManagerId </tid>
		...</thread> <br/>
		<thread>...
			<k> _:K => .K </k>
			<parentId> ManagerId </parentId>
			<publish> ListItem(V:Val) _ => .List </publish> <br/>
			<props>... SetItem("prunRightExp") => SetItem("pruneMe") ...</props>
		...</thread> <br/>
		<thread>...
			<context>... 
				.Map => X |-> V
			</context>
			<parentId> ManagerId </parentId> <br/>
			<props>... 
				SetItem("prunLeftExp") 
			...</props>
		...</thread>
	[structural]
	
	//@ Here is a rule to handle $\ll$
	rule [Pruning-NoVar-Prep]:
	F << G => F < String2Id("dummy_var") < G	[macro]

	
	/*@
	The following rule is a cleanup rule. In this rule, The manager
	destroys the left side thread 
	once it has halted and passed
	any values to be published to the manager. The manager destroys
	the right side thread as well, and
	ends its own execution, marking its job done.
	*/
	// cleanup rule 1
	rule [Pruning-Cleanup-1]:
		<thread>...
			<k> prunCompMgr(_) => .K </k>
			<tid> ManagerId </tid>
		...</thread> <br/>
		<thread>...
			<k> .K => killed(.K) </k>
			<parentId> ManagerId </parentId>
			<publish> .List </publish> <br/>
			<props>... 
				SetItem("prunLeftExp") 
			...</props>
		...</thread> <br/>
		<thread>...
			<k> K:K => killed(K) </k> // not a needed condition. because left already finished. WARNING: this used to cause a problem I remember that '_' didn't match '.K'. I probably mentioned it somewhere or in github.
			// <publish> .List </publish> // this too
			<parentId> ManagerId </parentId>
			<props>... 
				SetItem("pruneMe") 
			...</props>
		...</thread>
	[structural]
	
	//@ We need another cleanup rule in case $F$ halts and $G$ doesn't publish but halts.
	rule [Pruning-Cleanup-2]:
		<thread>...
			<k> prunCompMgr(_) => .K </k>
			<tid> ManagerId </tid>
		...</thread> <br/>
		<thread>...
			<k> .K => killed(.K) </k>
			<parentId> ManagerId </parentId>
			<publish> .List </publish> <br/>
			<props>... 
				SetItem("prunLeftExp") 
			...</props>
		...</thread> <br/>
		<thread>...
			<k> .K => killed(.K) </k> 
			<parentId> ManagerId </parentId>
			<publish> .List </publish> 
			<props>... 
				SetItem("prunRightExp") 
			...</props>
		...</thread>
	[structural]
	
	//================OTHERWISE==================
	/*@ \paragraph{Otherwise Combinator}
  \label{appendix:othr}
	\blockquote{"The otherwise combinator, written $f ; g$, executes expression $f$. If $f$ 
	halts without publishing any values, then $g$ is executed.

 	If $f$ publishes, $f ; g$ halts when $f$ halts. If $f$ halts without publishing, 
	$f ; g$ halts when $g$ halts."\cite{kitchin_orchestration_2013}}
	*/
	
	/*@
	The following rule creates manager for otherwise composition.
	It creates a thread for the left side expression \texttt{F}
	and keeps \texttt{G} for itself.
	*/
	
	// create manager for otherwise composition
	rule [Otherwise-Prep]:
		<thread>...
			<k> (F:Exp ; G:Exp) => othrCompMgr(G) </k>
			<context> Context </context>
			<tid> ManagerId </tid>
		...</thread> <br/>
		(.Bag => <thread>...
			<k> F </k>
			<context> Context </context>
			<tid> !NewId:Int </tid>
			<parentId> ManagerId </parentId> <br/>
			<props> 
				SetItem("othrLeftExp") 
			</props>
		...</thread>)
	[structural]
	
	/*@
	If \texttt{F} published a value, pass it---and any future publications---up to the manager and discard \texttt{G}.
	*/
	// if left side publishes, discard right side and publish up from left.
	rule [Otherwise-Left-Wins]:
		<thread>...
			<k> othrCompMgr(G:Exp) => othrCompMgr(.K) </k>
			<tid> ManagerId </tid>
		...</thread> <br/>
		<thread>...
			<parentId> ManagerId </parentId>
			<publish> L:List </publish> <br/>
			<props>... 
				SetItem("othrLeftExp") 
				(.Set => SetItem("publishUp"))
			...</props>
		...</thread>
		when L =/=K .List andBool G =/=K .K
	[structural]
		
	/*@
	If \texttt{F} halts without publishing,
	kill the left side child and create a new child thread executing \texttt{G}.
	*/
	rule [Otherwise-Right-Wins]:
		<thread>...
			<k> othrCompMgr(G) </k>
			<context> Context </context>
			<tid> ManagerId </tid>
		...</thread> <br/>
		<thread>...
			<k> .K => killed(.K) </k>
			<parentId> ManagerId </parentId>
			<publish> .List </publish> <br/>
			<props>... 
				SetItem("othrLeftExp") 
			...</props>
		...</thread> <br/>
		(.Bag => <thread>...
			<k> G </k>
			<context> Context </context>
			<tid> !NewId1:Int </tid>
			<parentId> ManagerId </parentId> <br/>
			<props> 
				SetItem("othrRightExp") 
				SetItem("publishUp")
			</props>			
		...</thread>)
		when G =/=K .K
	[structural]

	/*@
	If \texttt{F} is silent,
	kill the left side child and create a new child thread executing \texttt{G}.
	This is a cheat. I only made this to make "if(false) ; g" computable easily for my robot example to work. because that is easier than computing "if(b) | ifNot(b)"
	WARNING: Halting a silent thread. Mixing Halt and Silent. Mixing "stop" and "0".
	*/
	// rule [Otherwise-Left-Silent]:
		// <thread>...
			// <k> othrCompMgr(G) </k>
			// <context> Context </context>
			// <tid> ManagerId </tid>
		// ...</thread> <br/>
		// <thread>...
			// <k> _:SilentHandle  => killed(.K) </k>
			// <parentId> ManagerId </parentId>
			// <publish> .List </publish> <br/>
			// <props>... 
				// SetItem("othrLeftExp") 
			// ...</props>
		// ...</thread> <br/>
		// (.Bag => <thread>...
			// <k> G </k>
			// <context> Context </context>
			// <tid> !NewId1:Int </tid>
			// <parentId> ManagerId </parentId> <br/>
			// <props> 
				// SetItem("othrRightExp") 
				// SetItem("publishUp")
			// </props>			
		// ...</thread>)
		// when G =/=K .K
	// [structural]

	/*@
	Clean up. After the child that won, whether left or right, has halted, 
	destroy it and halt the manager.
	*/
	// cleanup after left child has halted
	rule [Otherwise-Cleanup]:
		<thread>...
			<k> othrCompMgr(.K) => .K </k>
			<tid> ManagerId </tid>
		...</thread> <br/>
		<thread>...
			<k> .K => killed(.K) </k>
			<parentId> ManagerId </parentId>
			<publish> .List </publish> <br/>
		...</thread>	
	[structural]

endmodule