//=================SiteCall and Handle Management===================
//@ \section{Site-Call and Handle Management}	
module ORC_SITECALL
	imports ORC_SYNTAX
  imports ORC_PREDICATES

	// WARNING: This might need some control to not occur when applying delta for example
	//@ In this module, site calls are processed by rewriting them into handles. From thereon, individual rules that handle individual sites such as \texttt{if} or \texttt{add} rewrite the handles into the appropriate type of handle. Those rules can be viewed in the Internal Sites module and Timed Sites module. Once a site is ready to publish, the handle is rewritten into a \texttt{pubHandle} where it comes back to be processed in this module.
	//@ \par First, a rule to process site calls. Rewriting the call into a handle simply makes the call. Since calling sites is the topmost priority, this rule has no conditions.
	rule [Site-Call]:
		// <threads>
			// A:Bag
			// <thread>
				// ...
				// <k> 
					SC:SiteCall => handle(SC) 
				// </k>
				// <props>
					// S:Set
					// (.Set => SetItem("called"))
				// </props>
				// ...
			// </thread>
		// </threads>
		// <out>... 
			// .List => ListItem("Any SC?  ") ListItem(anySiteCall(A))
		// </out>
		// when notBool "called" in S
	[structural]
	
	//DONE: Because I only need \texttt{pubHandle(Val)}, I should get rid of \texttt{pubHandle(SiteCall, Val)} because once I'm publishing, I don't need information of the site. I already have that information when it's just a handle. So the following rule does that.
	// rule pubHandle(_,V:Val) => pubHandle(V) [macro]
	
	// This rule replaces publishing handles by the values they carry. It only does so if no thread in the whole environment contains a site call ready to be made, or a handle that hasn't been processed.
	// I removed this because now only pubHandle publishes. No more Val publishing.
	// rule [pubHandleToVal]:
		// <threads>
			// A:Bag
			// <thread>...
				// <k> pubHandle(Val) => Val </k>
			// ...</thread>
		// </threads>
		// when notBool (anySiteCall(A))
			// andBool notBool(anyFreeHandle(A))
	// [structural]
	
	

endmodule