	//================PUBLISHING==================
	//@\section{Publishing}
module ORC_PUB
	imports ORC_SYNTAX
	imports ORC_PREDICATES

	
	//@ Generic Rule: Once an expression is fully evaluated, it publishes the value. But it is allowed to happen only if (1) all site calls are done, i.e., made into handles; and (2) if all handles that are ready to publish have been marked so, and therefore are on the same level with other threads ready to publish like those that carry values.
	rule [Publish-Value]:
		<threads>
			A:Bag
			<thread>...
				<k> pubHandle(V:Val) => .K ...</k>
				<publish>... .List => ListItem(V) </publish>
			...</thread>
		</threads>
		<gVars>... 
			"publishCount" |-> (I:Int => I +Int 1)
		...</gVars>
		// <out>... 
			// .List => ListItem("Any SC while publishing?") ListItem(anySiteCall(A)) ListItem("\n")
		// </out>
		when notBool(anySiteCall(A)) 
			andBool notBool(anyFreeHandle(A))
	[transition] //TODO DONE make sure that no other rules are writing directly to the publish list.
	
	//@ Replicate the previous rule for the case of only one thread. the previous rule will not work because it expects a non empty Bag next to the thread.
	rule 
		<threads>
			<thread>...
				<k> pubHandle(V:Val) => .K ...</k>
				<publish>... .List => ListItem(V) </publish>
			...</thread>
		</threads>
		<gVars>... 
			"publishCount" |-> (I:Int => I +Int 1)
		...</gVars>
	[transition]
	
	//@ Generic rule to move published values up to managing parent.
	rule [Push-Published-Value-Up]:
		<thread>...
			<tid> ManagerId </tid>
			<publish>... .List => ListItem(V) </publish>
		...</thread> <br/>
		<thread>...
			<parentId> ManagerId </parentId>
			<publish> ListItem(V:Val) => .List ...</publish> <br/>
			<props>... SetItem("publishUp") ...</props>
		...</thread>
	[structural]
	
	//@ Root thread publishes to \texttt{gPublish} cell.
	rule [Root-Publish-To-Global]:
		<thread>...
			<tid> 0 </tid>
			<parentId> -1 </parentId>
			<publish> ListItem(V:Val) => .List ...</publish>
		...</thread>
		<gPublish>... .List => ListItem(V) </gPublish>
	[structural]
		
endmodule