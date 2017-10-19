	//================Define and Call Expression==================
	//@ \section{Expression Definitions and Calls}

require "modules/substitution.k"
module ORC_EXPDEF
	imports ORC_SYNTAX
	imports SUBSTITUTION

	//@ Translate Expression definitions to \texttt{def} cells
	rule [Expression-Definition-Prep-1]:
		<thread>...
			<k> (ExpId:ExpId(DefParams:Params) := Body:Exp Ds:ExpDefs => Ds) E:Exp </k> <br/>
			<tid> 0 </tid>
		...</thread>
		(.Bag => <def>...
			<defId> ExpId </defId>
			<defParams> DefParams </defParams>
			<body> Body </body>
		...</def>)
	[structural]
	rule [Expression-Definition-Prep-2]: 
		.ExpDefs E:Exp => E 
		[structural]
	
	/*@ Replace an expression call with the predefined 
	\texttt{exp} body and populate the \texttt{expCall} cell*/
	rule [Expression-Call-Prep-1-Create]:
		<thread>...
			<k> ExpId:ExpId (Args:Args) => expCallPrep(Args, Body, DefParams) </k>
		...</thread>
		<def>...
			<defId> ExpId </defId>
			<defParams> DefParams </defParams>
			<body> Body </body>
		...</def>
	[structural]
  
  //@ Define functions needed for expression calls.
  syntax Exp ::= expCallPrep(Args, Exp, Params) [function]
  syntax Arg ::= Param2Arg(Param) [function]
  rule [Param-To-Arg]:
		Param2Arg(P:Id) => P [function,anywhere]
  
  //@ A rule that uses substitution for expression calls. This runs recursively substituting each parameter in the body with the corresponding argument.
  rule [Expression-Call-Prep-2-Substitute]:
    <thread>...
      <k> expCallPrep(A:Arg, As:Args, Body, P:Param, Ps:Params) => expCallPrep(As, Body[A/Param2Arg(P)], Ps) </k>
    ...</thread> 
    [latex(\label{rule:expcall_sub})]
  
	//@ This rule ends the recursion.
	rule [Expression-Call-Prep-3-End]:
    <thread>...
      <k> expCallPrep(.Args, Body, .Params) => ( Body ) </k>
    ...</thread> 
    // [function] // weirdly enough, in K3.6 the attribute function here causes a ClassCastException during kompile!
  	
  // Syntactic sugar to allow an argument of a call to be a call.
	// rule EI:ExpId(A:Call,As:Args) => (EI(!NewVar,As) < !NewVar:CamelCaseId < A)	[macro, supercool]
	// rule SI:SiteId(A:Call,As:Args) => (SI(!NewVar,As) < !NewVar:CamelCaseId < A)	[macro, supercool]

endmodule