//@ \subsection{Timed Sites}
module ORC_TSITES
	imports ORC_SYNTAX
	/*@
	\blockquote{"The timer sites---\textit{Clock}, \textit{Atimer}
	and \textit{Rtimer}---are used for computations involving time.
	Time is measured locally by the server on which the computation is performed. Since the timer is a local site, the
	client experiences no network delay in calling the timer
	or receiving a response from it; this means that the signal
	from the timer can be delivered at exactly the right moment. With \textit{t} = 0, \textit{Rtimer} responds immediately. Sites
	\textit{Atimer} and \textit{Rtimer} differ only in having absolute and
	relative values of time as their arguments, respectively."\cite{MisraMC:2007}}
	*/
	/*@\textit{Clock} publishes the current time. Even though it is a timer site,
	it does not affect the time, so we define it as an internal site instead, so 
	that it doesn't receive the "timed" property thus by not requiring its own
	$\delta$ rule.*/
	syntax ISiteId  ::= "Clock"
	rule [Val-clock]: clock => Clock(.Args)	[macro]
	rule [Site-Clock]:
		<k> handle(Clock(.Args)) => pubHandle(T) ...</k>
		<gVars>... 
			"time.clock" |-> T:Int
		...</gVars>
	[structural]
	
	//@The semantics of the Rtimer and Atimer sites are only realizable through the $\delta$ function.
	//@\textit{Rtimer(t)} publishes a signal after \textit{t} time units.\\
	syntax TSiteId  ::= "Rtimer" // The most fundamental timed site	
  rule [Rtimer]:
    <k> handle(Rtimer(I:Int)) => timedHandle(I, Rtimer(0), signal) </k> 
		[structural]
	
	//@\textit{Atimer(t)} publishes a signal at time \textit{t}.\\
	//@ We write \textit{Atimer} in terms of \textit{Rtimer}
	syntax TSiteId  ::= "Atimer"
	rule [Atimer]:
    <k> handle(Atimer(T:Int)) => timedHandle(T -Int Clk, Atimer(0), signal) ...</k>
    <gVars>... "time.clock" |-> Clk:Int ...</gVars>
    when T >Int Clk 
    [structural]

endmodule