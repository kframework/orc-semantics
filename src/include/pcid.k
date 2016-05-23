module PCID-SYNTAX-HOOKS
	syntax PascalCaseId ::= Token{[A-Z][\_a-zA-Z0-9]*}       [notInRules, regex("(?<![A-Za-z0-9\\_])[A-Z\\_][A-Za-z0-9\\_]*")]
endmodule

module PCID-HOOKS
  imports PCID-SYNTAX-HOOKS
  imports STRING-HOOKS
  imports K

	syntax String ::= "PascalCaseId2String" "(" PascalCaseId ")"         [function, hook(#CONVERSION:token2string), klabel(PascalCaseId2String)]
	syntax PascalCaseId ::= "String2PascalCaseId" "(" String ")"         [function, hook(#CONVERSION:string2id), klabel(String2PascalCaseId)]
	rule PascalCaseId2String(X:PascalCaseId) => #tokenToString(X)         [function,anywhere]
	rule String2PascalCaseId(S:String) => #parseToken("PascalCaseId", S)  [function,anywhere]

	syntax PascalCaseId ::= freshPascalCaseId(Int)	[freshGenerator, function]
	rule freshPascalCaseId(I:Int) => String2PascalCaseId("Var_" +String Int2String(I))
endmodule

