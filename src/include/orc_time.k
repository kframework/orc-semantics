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
			"time.ticked" |-> 0.0
			"time.MTE" |-> (MTE:Float => getLesserTE(MTE,A))
			...
		</gVars>
		when anyLesserTE(MTE,A) andBool notBool(anySiteCall(A)) 
	[structural]
		
	rule [Tick-Clock]:
		<threads>
			A:Bag
		</threads> <br/>
		<gVars>
			...
			"time.ticked" |-> (0.0 => MTE)
			"time.clock" |-> (Clk:Float => Clk +Float MTE)
			"time.limit" |-> TL:Float
			"time.MTE"   |-> MTE:Float
			...
		</gVars>
		// <out>... 
			// .List => ListItem("Ticking ") ListItem(Clk)
		// </out>
		when MTE >Float 0.0
			andBool notBool anyLesserTE(MTE,A)
			andBool((Clk +Float MTE) <Float TL)
			andBool notBool(anySiteCall(A)) 
			andBool notBool(anyFreeHandle(A)) 
			andBool notBool(anyPubHandle(A)) 
			andBool anyTimedHandle(A)
			andBool notBool(anyAppliedDelta(A))
	[transition] //WARNING: When this is structural, it will happen even if a timedHandle is ready to publish when other timedHandles still need ticks. Also all timedHandles reaching 0 will not publish!
	
	
	// WARNING: I want this applying concurrently. Apparently it is not. 
	rule [Apply-Delta]:
		<thread>...
			<k> timedHandle(I:Float, SC, A) => timedHandle(I -Float TE, SC, A) </k> <br/>
			<props> S:Set (.Set => SetItem("applied_delta")) </props>
		...</thread>
		<gVars>... 
			"time.ticked" |-> TE:Float
		...</gVars>
		// <out>... 
			// .List => ListItem("One timedHandle applying Delta")
		// </out>
		when I >Float 0.0 andBool TE >Float 0.0 andBool notBool("applied_delta" in S)
	[structural]
	
	// even though rule apply-delta is not applying concurrently, the side condition here will ensure this doesn't fire while apply-delta is still doing its work.
	rule [Delta-Done]:
		<threads>
			A:Bag
		</threads>
		<gVars>... 
			"time.ticked" |-> (T:Float => 0.0)
			"time.MTE" |-> (_:Float => TL)
			"time.limit" |-> TL:Float
		...</gVars>
		// <out>... 
			// .List => ListItem("Delta Off!")// This is very strange. Change the string and it won't compile!
		// </out>
		when T >Float 0.0 andBool allAppliedDelta(A)
	[structural]
	
	// rule after delta done, to remove the flag from timed handles that applied delta
	// TODO: WARNING: must ensure that this will apply to all such threads. What i'm ensuring in the tick rule is that delta will not be applied another time before all such threads are reset.
	rule [Reset-TimedHandles]:
		<thread>...
			<k> _:TimedHandle </k>
			<props>... SetItem("applied_delta") => .Set ...</props>
		...</thread>
		<gVars>... 
			"time.ticked" |-> 0.0
		...</gVars>
		// <out>... 
			// .List => ListItem("One timedHandle is ready to publish or Delta again")
		// </out>
	[structural]

	rule [TimedHandle-Outro]:
		<k> timedHandle(0.0,_,V:Val) => pubHandle(V) </k>
		<gVars>...
			"time.ticked" |-> 0.0
		...</gVars>		
		// <out>... 
			// .List => ListItem("One timedHandle published") ListItem("\n")
		// </out>
	[structural]
		
endmodule