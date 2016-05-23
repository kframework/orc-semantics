module K35FIX
	imports ORC_SYNTAX
	//@ A rule to work around the bug of not being able to create two unique thread IDs in the same rule
	rule [GetNewId]:
		<k> getNewId(E:Exp) => E </k> 
		<tid> _ => !NewId:Int </tid>
	[structural]

	// this is just a dummy function to make 3.5 compatible. I'm not sure if this hook works in 3.5. It shouldn't. because if it did, then that is all it takes to make 3.5 get the configuration and traverse which means I don't need 3.6.
	// syntax Bag ::= "#configuration" [function, impure, hook(KREFLECTION.configuration)]
	//Not needed anymore since I got rid of "#configuration".

endmodule
