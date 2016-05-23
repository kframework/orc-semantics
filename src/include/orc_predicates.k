//=========ENVIRONMENT TRAVERSE CONDITIONALS===========
//@ \section{Predicates}	
module ORC_PREDICATES
	imports ORC_SYNTAX

	//@ These functions are used in side conditions of other rules to find if a certain type of thread exists in the current configuration.
	// I could generalize all of these into one rule using one function like: anyThreadWith(KSort,Bag).
	
	//@\par Is there any thread that has a site call that hasn't been done?
	syntax Bool ::= anySiteCall(Bag) [function]
	rule anySiteCall(
		_:Bag
		<thread>... 
			<k> _:SiteCall </k> 
		...</thread> 
		) => true
	rule anySiteCall(
		_:Bag
		<thread>... 
			<k> _ </k> 
		...</thread> 
		) => false
	[owise]
	
	//@\par Is there any thread that has an unprocessed handle?
	syntax Bool ::= anyFreeHandle(Bag) [function]
	rule anyFreeHandle(
		_:Bag
		<thread>... 
			<k> _:FreeHandle </k> 
		...</thread> 
		) => true
	rule anyFreeHandle(
		_:Bag
		<thread>... 
			<k> _ </k> 
		...</thread> 
		) => false
	[owise]
	
	//@\par Is there any thread that has a handle ready to publish?
	syntax Bool ::= anyPubHandle(Bag) [function]
	rule anyPubHandle(
		_:Bag
		<thread>... 
			<k> _:PubHandle </k> 
		...</thread> 
		) => true
	rule anyPubHandle(
		_:Bag
		<thread>... 
			<k> _ </k> 
		...</thread> 
		) => false
	[owise]
	
	//@\par Is there any thread that has a value ready to be published?
	// syntax Bool ::= anyVal(Bag) [function]
	// rule anyVal(
		// _:Bag
		// <thread>... 
			// <k> _:Val </k> 
		// ...</thread> 
		// ) => true
	// rule anyVal(
		// _:Bag
		// <thread>... 
			// <k> _ </k> 
		// ...</thread> 
		// ) => false
	// [owise]
	
	//@\par Is there any thread that has a timed handle
	syntax Bool ::= anyTimedHandle(Bag) [function]
	rule anyTimedHandle(
		_:Bag 					
		<thread>... 
			<k> timedHandle(I:Float,_,_) </k> 
		...</thread> 
		) => true when I >Float 0.0
	rule anyTimedHandle(
		_:Bag 					
		<thread>... 
			<k> _ </k> 
		...</thread> 
		) => false
	[owise]
	rule anyTimedHandle(
		_:Bag 					
		<thread>... 
			<k> timedHandle(0.0,_,_) </k> 
		...</thread> 
		) => false
	
	//@\par Is there any thread that hasn't yet applied delta
	syntax Bool ::= anyNotAppliedDelta(Bag) [function]
	rule anyNotAppliedDelta(
		_:Bag 					
		<thread>... 
			<k> _:TimedHandle </k> 
			<props> S:Set </props>
		...</thread> 
		) => true when notBool "applied_delta" in S
	rule anyNotAppliedDelta(
		_:Bag 					
		<thread>... 
			<k> _ </k> 
			<props> _ </props>
		...</thread> 
		) => false
	[owise]
	
	//@\par This is equivalent to \texttt{notBool anyNotAppliedDelta()}
	syntax Bool ::= allAppliedDelta(Bag) [function]
	rule allAppliedDelta(
		_:Bag 					
		<thread>... 
			<k> _:TimedHandle </k> 
			<props> S:Set </props>
		...</thread> 
		) => false when notBool "applied_delta" in S
	rule allAppliedDelta(
		_:Bag 					
		<thread>... 
			<k> _ </k> 
			<props> _ </props>
		...</thread> 
		) => true
	[owise]
	
	//@\par Is there any thread that has the \texttt{applied\_delta} flag on and is not reset?
	syntax Bool ::= anyAppliedDelta(Bag) [function]
	rule anyAppliedDelta(
		_:Bag 					
		<thread>... 
			<k> _:TimedHandle </k> 
			<props>... SetItem("applied_delta") ...</props>
		...</thread> 
		) => true
	rule anyAppliedDelta(
		_:Bag <thread>... 
			<k> _ </k> <br/>
			<props> _ </props>
		...</thread> 
		) => false
	[owise]

	//@\par Is there any thread that has a timed handle less than MTEtemp
	syntax Bool ::= anyLesserTE(Float,Bag) [function]
	rule anyLesserTE(MTEtemp:Float,
		_:Bag
		<thread>... 
			<k> timedHandle(I:Float,_,_) </k> 
		...</thread> 
		) => true when I <Float MTEtemp andBool I >Float 0.0
	rule anyLesserTE(_,
		_:Bag
		<thread>... 
			<k> _ </k> 
		...</thread> 
		) => false
	[owise]
	
	syntax Float ::= getLesserTE(Float,Bag) [function]
	rule getLesserTE(MTEtemp:Float,
		_:Bag
		<thread>... 
			<k> timedHandle(I:Float,_,_) </k> 
		...</thread> 
		) => I when I <Float MTEtemp andBool I >Float 0.0
	
endmodule