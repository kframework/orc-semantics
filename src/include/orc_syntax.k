//@\section{Syntax Module}
module ORC_SYNTAX

	/*@ \subsection{The Orc Calculus}
	\blockquote{"The Orc process calculus is based on the execution of \textit{expressions}. 
	As an expression executes, it may interact with external services (called 
	\textit{sites}), and may \textit{publish} values during its execution. An 
	expression may also \textit{halt}, explicitly indicating that its execution 
	is complete. 
	
	Simple expressions are built up into more complex ones by 
	using \textit{combinators} and by defining \textit{functions}."\cite{kitchin_orchestration_2013}}
	*/

	/*@ \subsection{Expressions}
	Looking at Figure \ref{fig:syntax} showing the grammar of the Orc calculus, the 
	following grammar defined in \K syntax is almost identical. There are a few 
	extra semantic elements that \K allows to define within the syntax module. The first 
	is precedence, denoted by the \textgreater operator. As is clearly stated in the Orc  
	paper, the order of precedence of the four combinators from higher to lower 
	is: Sequential, Parallel, Pruning, Otherwise. In addition, we prefer for 
	simpler expressions to be matched before complex ones; so, we put on top, 
	\texttt{Arg} and \texttt{Call}.
	
	The second semantic element that is defined within the 
	syntax module of \K is \texttt{right}- or \texttt{left}-associativity, and strictness. 
	It is important to note that for the parallel operator, being fully-associative, 
	defining it here as right-associative is to help in parsing. 
	In other words, it is defined this 
	way only for technical reasons that become clear when we define the rules 
	later.
	
	\texttt{strict} means that the terms in the right hand side of the 
	production must be evaluated before the production is matched. 
	strict can also take integer arguments denoting, by order from left
	to right which non-terminals are strict.
	*/
	syntax Pgm ::= Exp
				 > ExpDefs Exp
	syntax Exp ::= Arg  
				 > Exp ">" Param ">" Exp 		[right] 	//Sequential Combinator
				 | Exp ">>" Exp	 			[right] 	//Sequential Combinator
				 > Exp "|"  Exp 			[right] //Parallel Combinator ( Exp1 | Exp2 | Exp3 | ...)
				 > Exp "<" Param "<" Exp 		[left] //Pruning Combinator
				 | Exp "<<" Exp 			[left] //Pruning Combinator
				 > Exp ";" Exp 				[left]	//Otherwise Combinator
	
	syntax ExpDefs ::= List{ExpDef, ""}
	syntax ExpDef  ::= Decl ":=" Exp  
	syntax Decl	   ::= ExpId "(" Params ")" [klabel(Decl)]
	
	syntax ExpId ::= PascalCaseId
	
	/*@ \subsection{Parameters and Arguments}
	\textit{Arguments} are what is called Actual Parameters in the Orc grammar, while our \textit{Parameters} are what they called Formal Parameters.
	*/	
	syntax Arg ::= Val
				 // | "zero"
				 | "clock"
				 > CamelCaseId  //[binder]
				 > Tuple		// tuple of values
				 > Call
	syntax Param::= CamelCaseId
	
	//@ \subsection{Site Calls and Expression Calls}
	syntax Call ::= SiteCall
					| Handle
			    | ExpCall
	syntax SiteCall ::= SiteId "(" Args ")"		[strict(2)]
									  // | RsrvdSite
	syntax ExpCall  ::= ExpId "(" Args ")" [klabel(ExpCall)]
	syntax Handle ::= FreeHandle
									| PubHandle
									| SilentHandle
									| TimedHandle
	syntax FreeHandle ::= handle(SiteCall)
	syntax PubHandle ::= pubHandle(Val)  [klabel(pubHandle)]
	syntax SilentHandle ::= silentHandle(SiteCall) [klabel(silentHandle)]
	syntax TimedHandle ::= timedHandle(Float, SiteCall, Arg) [klabel(timedHandle)] // the klabel changes nothing regarding eagerness
											 | timedHandle(Float, SiteCall)
	
	syntax SiteId  ::= ISiteId	// Internal Site Identifier
	syntax SiteId  ::= TSiteId	// Timed Sites
  syntax ISiteId // to define ISiteId and TSiteId as sorts here in the syntax module
  syntax TSiteId
	//@ \subsection{Values}
	syntax Val ::= Int | Float | Bool | String | "signal" | "stop"
	//@	Exclude reserved keywords from the Identifier category
	syntax "signal" -/- [a-zA-Z0-9]
	syntax "stop" -/- [a-zA-Z0-9]
	syntax "tuple" -/- [a-zA-Z0-9]
	syntax "clock" -/- [a-zA-Z0-9]
	syntax "zero" -/- [a-zA-Z0-9]
	syntax "count" -/- [a-zA-Z0-9]
	
	/*@ \subsection{KResult}
	To tell \K what sorts are accepted as final evaluations of a \texttt{k} cell, we declare them as the \K built-in syntactic category \texttt{KResult}. Note that \textit{Val} is not accepted as a final evaluation because it is syntactic sugar for a call to $\mathit{let(v)}$ where \textit{v} is of sort \textit{Val}. However, \texttt{silentHandle} is accepted because otherwise the program will get stuck on sites that never respond.
	*/
	syntax KResult ::= SilentHandle
  
	//@ \subsection{Secondary Syntax Productions}
	//@ Variable is also a \K built-in syntactic category that is necessary when using the substitution module.
	syntax Variable ::= CamelCaseId
	
	//@ Sites/Expressions may publish a tuple of values. So, we declare lists to handle that in rules ahead.
	syntax Exps ::= List{Exp,","}
	syntax Args ::= List{Arg,","}		[strict]
	syntax Params ::= List{Param,","}	
	syntax Vals   ::= List{Val,","}
	syntax Ids	  ::= List{Id, ","}
	syntax Tuple  ::= "<" Vals ">"		[strict]
	
	//@	Here we declare the parentheses used for grouping as brackets.
	syntax Exp 	  ::= "(" Exp ")"		[bracket]				
	
	//@ Thread managing functions
	syntax KItem ::= killed(K)
	syntax Exp ::= getNewId(Exp) [function]
	syntax Exp ::= prllCompMgr(Int) //the int keeps count of managed parallel threads
	syntax Exp ::= seqCompMgr(Param, Exp, Int)
	syntax Exp ::= prunCompMgr(Param)
	syntax Exp ::= othrCompMgr(Exp)
	
	//@ Convert Orc Tuple to KList
	syntax List ::= tuple2Klist(Tuple) [function]
	rule tuple2Klist(<V:Val, Vs:Vals>) => ListItem(V) tuple2Klist(<Vs>) [anywhere]
	rule tuple2Klist(<.Vals>) => .List [anywhere]
	
endmodule
