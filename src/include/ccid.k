module CCID-SYNTAX-HOOKS
	syntax CamelCaseId ::= Token{[a-z][\_a-zA-Z0-9]*}       [notInRules, regex("(?<![A-Za-z0-9\\_])[a-z\\_][A-Za-z0-9\\_]*")]
endmodule

module CCID-HOOKS
  imports CCID-SYNTAX-HOOKS
  imports STRING-HOOKS
  imports K

	syntax String ::= "CamelCaseId2String" "(" CamelCaseId ")"         [function, hook(#CONVERSION:token2string), klabel(CamelCaseId2String)]
	syntax CamelCaseId ::= "String2CamelCaseId" "(" String ")"         [function, hook(#CONVERSION:string2id), klabel(String2CamelCaseId)]
	rule CamelCaseId2String(X:CamelCaseId) => #tokenToString(X)         [function,anywhere]
	rule String2CamelCaseId(S:String) => #parseToken("CamelCaseId", S)  [function,anywhere]

	syntax CamelCaseId ::= freshCamelCaseId(Int)	[freshGenerator, function]
	rule freshCamelCaseId(I:Int) => String2CamelCaseId("var_" +String Int2String(I))
endmodule

