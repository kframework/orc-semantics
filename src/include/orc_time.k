	//===================TIME====================	
	/*@ \section{Synchronization and Time}
  \label{appendix:time}
	The semantics of our time model are inspired by those of real-time 
	Maude described in \cite{OlveczkyOM:2007a}.
	*/
	
module ORC_TIME
	imports ORC_SYNTAX
	imports ORC_PREDICATES
	
	// WARNING: This is very lax and might fire prematurely and might cause infinite looping.
	rule [Find-MTE]:
		<threads>
			A:Bag
		</threads> <br/>
		<gVars>
			...
			"time.ticked" |-> 0
			"time.MTE" |-> (MTE:Int => getLesserTE(MTE,A))
			...
		</gVars>
		when anyLesserTE(MTE,A) andBool notBool(anySiteCall(A)) 
	[structural]
		
	syntax Int ::= myMinInt(Int, Int) [function]
	rule myMinInt(A,B) => #if A <Int B #then A #else B #fi
	
	rule [Tick-Clock]:
		<threads>
			A:Bag
		</threads> <br/>
		<gVars>
			...
			"time.ticked" |-> (0 => myMinInt(MTE, TL -Int Clk))
			"time.clock" |-> (Clk:Int => myMinInt(Clk +Int MTE, TL))
			"time.limit" |-> TL:Int
			"time.MTE"   |-> MTE:Int
			...
		</gVars>
		// <out>... 
			// .List => ListItem("Ticking ") ListItem(Clk)
		// </out>
		when MTE >Int 0
			// andBool MinTick ==Int minInt(MTE, TL -Int Clk)
			// andBool MinClk ==Int minInt(Clk +Int MTE, TL)
			andBool notBool anyLesserTE(MTE,A)
			// andBool((Clk +Int MTE) <Int TL)
			andBool notBool(anySiteCall(A)) 
			andBool notBool(anyFreeHandle(A)) 
			andBool notBool(anyPubHandle(A)) 
			// andBool anyTimedHandle(A) // I removed this because I want time to pass regardless of timed site calls. This will ensure that the program always terminates, given the TTL-terminate rule.
			andBool notBool(anyAppliedDelta(A))
	[transition] //WARNING: When this is structural, it will happen even if a timedHandle is ready to publish when other timedHandles still need ticks. Also all timedHandles reaching 0 will not publish!
	
	// when no pubHandles and no site calls, but only silentHandles, and managers and freeHandles that are effectively silent, then just terminate all threads.
	// WARNING: This is a dangerous rule that takes more control than it should. There bound to be some error spawning from this.
	rule [TTL-terminate]:
		<threads> A:Bag </threads>
		<gVars>
			...
			"time.clock" |-> TL:Int
			"time.limit" |-> TL:Int
			"terminate" |-> (false => true)
			...
		</gVars>
		when notBool(anySiteCall(A)) 
		andBool notBool(anyFreeHandle(A)) 
		andBool notBool(anyPubHandle(A)) 
	[transition]
	
	rule [execute-terminate]:
		<threads>...
			<thread>...
				<k> _:SilentHandle => .K </k>
				<publish> .List </publish>
			...</thread>
		...</threads>
		<gVars>...
			"terminate" |-> true
		...</gVars>
	[structural]
	
	// WARNING: I want this applying concurrently. Apparently it is not. 
	rule [Apply-Delta]:
		<thread>...
			<k> timedHandle(I:Int, SC, A) => timedHandle(I -Int TE, SC, A) </k> <br/>
			<props> S:Set (.Set => SetItem("applied_delta")) </props>
		...</thread>
		<gVars>... 
			"time.ticked" |-> TE:Int
		...</gVars>
		// <out>... 
			// .List => ListItem("One timedHandle applying Delta")
		// </out>
		when I >Int 0 andBool TE >Int 0 andBool notBool("applied_delta" in S)
	[structural]
	
	// even though rule apply-delta is not applying concurrently, the side condition here will ensure this doesn't fire while apply-delta is still doing its work.
	rule [Delta-Done]:
		<threads>
			A:Bag
		</threads>
		<gVars>... 
			"time.ticked" |-> (T:Int => 0)
			"time.MTE" |-> (_:Int => TL)
			"time.limit" |-> TL:Int
		...</gVars>
		// <out>... 
			// .List => ListItem("Delta Off!")// This is very strange. Change the string and it won't compile!
		// </out>
		when T >Int 0 andBool allAppliedDelta(A)
	[structural]
	
	// rule after delta done, to remove the flag from timed handles that applied delta
	// TODO: WARNING: must ensure that this will apply to all such threads. What i'm ensuring in the tick rule is that delta will not be applied another time before all such threads are reset.
	rule [Reset-TimedHandles]:
		<thread>...
			<k> _:TimedHandle </k>
			<props>... SetItem("applied_delta") => .Set ...</props>
		...</thread>
		<gVars>... 
			"time.ticked" |-> 0
		...</gVars>
		// <out>... 
			// .List => ListItem("One timedHandle is ready to publish or Delta again")
		// </out>
	[structural]

	rule [TimedHandle-Outro]:
		<k> timedHandle(0,_,V:Val) => pubHandle(V) </k>
		<gVars>...
			"time.ticked" |-> 0
		...</gVars>		
		// <out>... 
			// .List => ListItem("One timedHandle published") ListItem("\n")
		// </out>
	[structural]
		
endmodule