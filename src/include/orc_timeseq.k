//===================TIME====================	
//@ \section{Synchronization and Time}
module ORC_TIMESEQ
	imports ORC_SYNTAX
	
  /*@\label{appendix:time}
	The semantics of our time model are inspired by those of real-time 
	Maude described in \cite{OlveczkyOM:2007a}.
	*/
	
	/* Before applying the $\delta$ function, mark threads 
	that have a time site call on top of their k cell as "timed"*/
	// rule [Mark-Timed-Threads]:
		// <thread>...
			// <k> timedHandle(T:Int,_,_) ...</k>
			// <props> S:Set (.Set => SetItem("timed")) </props>
		// ...</thread> <br/>
		// <gVars>... "is_delta_applied" |-> false ...</gVars>
		// when notBool("timed" in S) andBool T >Int 0
	// [structural]
	
	/*@ The $\delta$ function applies on the whole environment and then 
	moved down the thread tree being applied on individual expressions.*/
	//todo: exclude the possibility of delta(delta(Exp)), even though the global control variable is_delta_applied ensures this does not happen.
	syntax Bag ::= delta(Bag)	[function, latex(\delta{#1}), klabel(deltaOnThreads)]
	syntax Exp ::= delta(Exp)	[function, latex(\delta{#1}), klabel(deltaOnExps)]
	
	/*@ Apply delta to the whole bag of threads if it has at least one
		timed thread.
	*/
  // TODO: Ensure that delta is applied on all timed sites and that it does not miss any. should ask the guys about how structural rules are applied in order or what. EDIT: I don't recall writing this and it doesn't seem like a concern to me now. Therefore, DONE.
	syntax KItem ::= bag(Bag)
	rule [Apply-Delta-Globally]:
		<threads> 
			<thread>
				C1:Bag
				<k> timedHandle(T:Int,SC,A) </k>
				// <props> S:Set </props> 
			</thread> 
			B:Bag 
			=> 
			delta(<thread> C1 <k> timedHandle(T,SC,A) </k> </thread> B) 
		</threads>
		<gVars>... 
			"is_delta_applied" |-> (false => true)
		...</gVars>
		when T >Int 0
	[structural]	
	
	/*@ After delta is applied to the whole bag of threads, the following
		two rules run repeatedly on all threads. Exactly one of these two
		rules will match each thread. The first is for untimed threads, 
		and the second is for timed threads.
	*/
	rule [Delta-On-Thread-1-Skip-1]:
		<threads>... 
			delta(<thread> <k> .K </k> C:Bag </thread> B:Bag) 
			=>
			<thread> <k> .K </k> C </thread>
			delta(B)
		</threads> <br/>
		<gVars>... 
			"threads_applied_delta" |-> (I1:Int => I1 +Int 1)
			"threads_executed_delta" |-> (I2:Int => I2 +Int 1) 
		...</gVars>
	[structural]
	rule [Delta-On-Thread-1-Skip-2]:
		<threads>... 
			delta(<thread> <k> E:Exp </k> C:Bag </thread> B:Bag) 
			=>
			<thread> <k> E </k> C </thread>
			delta(B)
		</threads> <br/>
		<gVars>... 
			"threads_applied_delta" |-> (I1:Int => I1 +Int 1)
			"threads_executed_delta" |-> (I2:Int => I2 +Int 1) 
		...</gVars>
		when isTimedHandle(E) =/=K true
	[structural]
	rule [Delta-On-Thread-2-Hold]:
		<threads>... 
			delta(<thread> <k> timedHandle(T:Int,SC,A) </k> C:Bag </thread> B:Bag) 
			=>
			<thread> <k> delta(timedHandle(T,SC,A)) </k> C </thread>
			delta(B)
		</threads>
		<gVars>... "threads_applied_delta" |-> (I:Int => I +Int 1) ...</gVars>
		when T >Int 0
	[structural]
	
	/*@ After $\delta$ has finished running on the whole environment, perform
	a clock tick, i.e., advance the clock by one time unit.
	*/
	rule [Mark-Delta-Done]:
		<threads>... delta(.Bag) => .Bag </threads>
		<gVars>... 
			"is_delta_executed" |-> (false => true) 
		...</gVars>
	[structural]
	
  // big TODO: delta should be applied after tick not before.. IGNORED
	rule [Tick-Clock]:
		<gVars>... 
			"is_delta_applied" |-> (true => false)
			"is_delta_executed" |-> (true => false)
			"time.clock" |-> (I:Int => I +Int 1)
			"threads_applied_delta" |-> (TsAppdDelta:Int => 0)
			"threads_executed_delta" |-> (TsExecdDelta:Int => 0)
      "time.limit" |-> TimeLimit:Int
		...</gVars>
	when TsAppdDelta ==Int TsExecdDelta andBool I <Int TimeLimit
	[transition] // TODO: should be transition
	
	
  //@$\delta$ applying on handles of timed sites.
  rule [Time-Handle-One-Tick]:
  <thread>...
		<k> delta(timedHandle(I:Int, SC:SiteCall, A)) => timedHandle(I -Int 1, SC, A) </k>
		<props> S:Set .Set => SetItem("applied_delta") </props>
  ...</thread>
		<gVars>... 
			"threads_executed_delta" |-> (N:Int => N +Int 1)
		...</gVars>
	when I >Int 0 andBool notBool "applied_delta" in S
	[structural]
	rule [Time-Handle-Outro]:
  <thread>...
    <k> timedHandle(0,_,V:Val) => pubHandle(V) </k>	
		// <props>... SetItem("timed") => .Set ...</props>
  ...</thread>
  [structural]


endmodule