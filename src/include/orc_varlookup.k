	//================VARIABLE LOOKUP==================
	//@	\section{Variable Lookup and Scope Sharing}
	
module ORC_VARLOOKUP
	imports ORC_SYNTAX
	
	//@ Basic Variable lookup
	rule [Basic-Variable-Lookup]:
		<k> X:Param => V ...</k>
		<context>... X |-> V:Val ...</context>
	[structural]
	//TODO: expression calls enforce variable names prefix
	//@ Register a \texttt{varReq} in parent when not finding needed variable, and not expecting the variable to be provided by a managing parent.
	syntax Param ::= varReq(Param, Int)  [function] // the int arg is the state number to keep track to not check more than once unless a transition has happened.
	rule [Create-Variable-Request]:
		<thread>...
			<k> X:Param => varReq(X, Pcount) ...</k>
			<tid> Requester </tid> <br/>
			<parentId> PId </parentId>
			<context> Context </context>
      <props> S:Set </props>
		...</thread> <br/>
		<thread>...
			<k> ParentK:Exp </k>
			<tid> PId </tid>
			<varReqs>... .List => ListItem(Requester) </varReqs>
		...</thread> <br/>
		<gVars>... 
			"publishCount" |-> Pcount:Int
		...</gVars>
		when notBool X in keys(Context) andBool (ParentK =/=K prunCompMgr(X) orBool "prunRightExp" in S)
	[structural]
	
	//@ Push variable request up the thread tree.
	rule [Push-Variable-Request-Up]:
		<thread>...
			<k> varReq(X, _) ...</k>
			<tid> Requester </tid>
		...</thread> <br/>
		<thread>...
			<tid> From </tid>
      <props> S:Set </props>
			<parentId> To </parentId>
			<context> Context </context> <br/>
			<varReqs> ListItem(Requester) => .List ...</varReqs> // same here. not matching if ... in front
		...</thread> <br/>
		<thread>...
			<k> ParentK:Exp </k>
			<tid> To </tid>
			<varReqs>... .List => ListItem(Requester) </varReqs>
		...</thread>
		when notBool X in keys(Context) andBool (ParentK =/=K prunCompMgr(X) orBool "prunRightExp" in S) // this means that if the variable-requesting thread is a child of a pruning manager of that variable, then it must be the right-side child for the rule to apply.
	[structural]
	
	// If variable request reached the root thread, reset it. 
	// I just changed this rule and the way it is done now is less than ideal. We would like it more if we just reset the state to how it was before a variable request was made and leave it to the first rule to re-make the variable request. This is how it was before I changed it, but because of a reason i forgot now, we have to do the job of the first rule. so here is redundancy.
  // If structural, this might create an infinite loop if variable was never resolved or if it needs a transition to be given a value. So I changed it to transition, but still. It was tested on factorial and it gave a wrong result, but didn't get stuck. then i change it to imitate the first rule and it looped forever, even when transition. see previous revision to understand.
  // After that I changed it back to the better way but with a different rule layout. First, I changed all the var lookup rules back to structural. Second, I made the reset conditioned by the passing of at least one transition. So now it won't go into an infinite loop. It will not apply unless a transition happened.
  // After that, I made both structural, and made the reset-var-request not conditioned by it reaching the root. I made it reset whenever a transition has occurred, simply. But I had to enforce that a reset happens only once in each transition.
  // this rule does not increase the number of solutions given by --search. tested on test_vars_example_7.3 with revision 30.
	//@ Reset variable requests once a transition has occurred.
  rule [Reset-Variable-Request]:
		<thread>...
			<k> varReq(X:Param, Pcount:Int) => X ...</k>
			<tid> Requester </tid>
		...</thread> <br/>
		<thread>...
			// <tid> 0 </tid>
			<context> Context </context>
			<varReqs> ListItem(Requester) => .List ...</varReqs>
		...</thread> <br/>
		<gVars>... 
			"publishCount" |-> CurrPcount:Int
		...</gVars>
    when notBool X in keys(Context) andBool CurrPcount >Int Pcount
  [structural]
  
  
	//@ Resolve variable request.
	// todo: warning, potential danger, in case name of variable is repeated, but that is never the case in our semantics.
	rule [Resolve-Variable-Request]:
		<thread>...
			<k> varReq(X:Param, _) => X ...</k>
			<tid> Requester </tid>
			<context>... .Map => X |-> V </context>
		...</thread> <br/>
		<thread>...
			<context>... X |-> V:Val ...</context>
			<varReqs> ListItem(Requester) => .List ...</varReqs> // mysteriously, this won't match if cell begins with ...
		...</thread>
	[structural]
	
endmodule