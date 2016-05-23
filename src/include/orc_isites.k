	//================INTERNAL SITES==================
	//@ \section{Local Site Identifiers}

require "orc_math.k"
module ORC_ISITES
	imports ORC_SYNTAX
	
	/*@	Orc has some built-in sites. We call these local sites. Here, we 
	syntactically declare the Identifiers (names) of these local sites and give 
	semantics to each. We divide them into \textit{Internal}, 
	and \textit{Timed} sites. This division is not based on 
	any particular syntactic or semantic difference; It only provides better 
	organization.
	*/
	//TODO prevent sites from taking more arguments than defined for

	//@ \subsection{Internal Sites}
	
	/*@ \textbf{Signal} 
	\texttt{Signal} Publishes the \texttt{signal} value immediately. It is the same as \texttt{if(true)}
	*/
	syntax ISiteId ::= "Signal"
	rule [Site-Signal]:
		handle(Signal(_)) => pubHandle(signal)	[anywhere]
	
	/*@ \textbf{Stop}
	The expression \texttt{stop}, when executed, halts immediately. And any site 
	call with an argument \texttt{stop} halts as well. A site halting simply 
	means that its execution is complete.
	*/
	rule [Val-stop-1]: A:Arg,stop => stop	[anywhere]
	rule [Val-stop-2]: stop,A:Arg => stop	[anywhere]
	rule [Val-stop-3]: _:SiteId(stop) => .K	[anywhere] //TODO: I think this one is wrong. the site call should halt if it has a stop argument, but that doesn't mean '.K'. It means complete execution without publishing. But am I doing that anywhere? How do I do it? I guess it is right to just make it '.K'. So if it is a right-hand of pruning, then left should get stuck if it needs a value from it. That's something my rules already do. But what my rules don't do is when it is the left-hand of otherwise. 'stop;T' should execute 'T'. I think my rules do that too. OK then!
	// A rule for halted site calls
	// rule [stop-handle]:
		// <k> handle(.K) => .K </k>
		// <gVars>
			// ...
			// "tcount_handle" |-> (I:Int => I -Int 1)
			// ...
		// </gVars>
	
	
	//@ \textbf{let} publishes a tuple consisting of the values of its arguments.
	syntax ISiteId ::= "let"
	rule [Site-Let]:
		handle(let(V:Val)) => pubHandle(V)		[structural]
	
	//@ And any cell containing only a value v is syntactic sugar for let(v), so...
	rule [Val-Let]:
		<k> V:Val => let(V) </k> [structural]
	
	//@ \textbf{print} prints text to the console, then publishes \texttt{signal}, then halts. 
	syntax ISiteId ::= "print"		
	rule [Site-Print-1]:
		<k> handle(print(V:Val, Vs:Vals => Vs)) ...</k>
		<out>... .List => ListItem(V) </out>
	[structural]
	rule [Site-Print-2]:
		handle(print(.Args)) => pubHandle(signal)  [macro]
	/*@ \textbf{Prompt}
	The \texttt{Prompt} site asks the user for text input. 
	\texttt{Prompt("username:")} presents 	a prompt with the text 
	\texttt{username:}, receives a line of input, publishes that line 	of 
	input as a string, and then halts. 
	*/
	syntax ISiteId ::= "Prompt"
	rule [Site-Prompt-1]: <k> Prompt(S:String => .) ...</k> <out>... .List => ListItem(S) </out>	[structural]
	rule [Site-Prompt-2]:<k> Prompt(.Args) => S ...</k> <in> ListItem(S:String) => .List ...</in>	[structural]
	
	/*@ 
	\texttt{if(b)} where \texttt{b} is boolean, publishes a signal if \texttt{b} is true
	and it remains silent (i.e., does not respond) if \texttt{b} is false.
	*/
	syntax ISiteId ::= "if"
	rule [Site-If-true]: handle(if(true)) 	=> pubHandle(signal)	[macro]
	rule [Site-If-false]: handle(if(false)) => silentHandle(if(false))	[macro]
	
	//@ We make a site \texttt{ifNot} for convenience.
	syntax ISiteId ::= "ifNot"
	rule [Site-IfNot]: handle(ifNot(B:Bool)) => handle(if(notBool B))	[macro]
	
	//@ zero should just be silent.
	syntax ISiteId ::= "zero"
	rule handle(zero(.Args)) => silentHandle(zero(.Args)) [macro]
	
	//@ Define sites that exclusively use the \texttt{count} global variable. \texttt{count.inc} increments the count while \texttt{count.read} publishes the current count.
	syntax ISiteId ::= "count.inc"
	syntax ISiteId ::= "count.read"
	rule [count.inc]:
		<k> handle(count.inc(.Args)) => pubHandle(signal) ...</k>
		<gVars>... 
			"count" |-> (C:Int => C +Int 1)
		...</gVars>
	[structural]
	rule [count.read]:
		<k> handle(count.read(.Args)) => pubHandle(C) ...</k>
		<gVars>... 
			"count" |-> C:Int
		...</gVars>
	[structural]

endmodule
