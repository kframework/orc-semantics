module K36FIX
	imports ORC_SYNTAX

	// rule just to undo what k35 needs. It's to minimize changes in the core file.
	rule [GetNewId]: getNewId(K) => K [macro]
endmodule
