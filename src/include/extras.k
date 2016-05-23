module EXTRAS
  	  
  //@ A rule to work around the bug of list equality. the in operator for list of lists won't work without it.
  rule L1:List =K L2:List => L1 ==K L2
  
  //@ Vector add
	syntax List ::= vAdd(List,List) [function]
	rule vAdd(ListItem(LI1) L1:List, ListItem(LI2) L2:List) => ListItem(LI1 +Int LI2) vAdd(L1,L2) [function, anywhere]
	rule vAdd(.List,.List) => .List	[function, anywhere]
	
	//@ Vector subtract
	syntax List ::= vSub(List,List) [function]
	rule vSub(ListItem(LI1) L1:List, ListItem(LI2) L2:List) => ListItem(LI1 -Int LI2) vSub(L1,L2) [function, anywhere]
	rule vSub(.List,.List) => .List	[function, anywhere]
	
  //@ List roll left and right
	syntax List ::= lror(List) [function]
	syntax List ::= lrol(List) [function]
	rule lror(L:List ListItem(VI)) => ListItem(VI) L	[function, anywhere]
	rule lrol(ListItem(VI) L:List) => L ListItem(VI)	[function, anywhere]

endmodule