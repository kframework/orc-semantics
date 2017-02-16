/*
Semantics of the Orc Calculus.
*/
/*!
\setlength{\parindent}{1em}
\title{\K-Semantics of Orc}
\author{Omar al-Zuhaibi (\texttt{3omarz@gmail.com})}
\organization{King Fahd University of Petroleum and Minerals}
*/
/*

I tried to minimize the differences in this file that will make it compatible with 3.5. I list them here:
- import orc_time module.
- import k35fix module instead of k36fix.

*/
		
require "include/orc_syntax.k"
require "include/orc_ops.k"
require "include/orc_expdef.k"
require "include/orc_pub.k"
require "include/orc_time.k"
require "include/orc_timeseq.k"
require "include/orc_sitecall.k"
require "include/orc_isites.k"
require "include/orc_tsites.k"
require "include/orc_robot.k"
require "include/orc_math.k"
require "include/orc_ltl.k"
require "include/extras.k"
require "include/orc_predicates.k"
require "include/orc_varlookup.k"
require "include/k35fix.k"
require "include/k36fix.k"

module ORC
	imports ORC_SYNTAX
	imports ORC_OPS
	imports ORC_PUB
	imports ORC_SITECALL
	imports ORC_EXPDEF
	imports ORC_TIME
	// imports ORC_TIMESEQ
	imports ORC_ISITES
	imports ORC_TSITES 
	imports ORC_VARLOOKUP
	imports ORC_PREDICATES
	imports ORC_ROBOT
	imports ORC_MATH
	imports ORC_LTL // OK to import for 3.6
	imports EXTRAS
	
	//mutually-exclusive imports
	imports K35FIX
	// imports K36FIX
	
	//@ \section{Main Orc Module}
	/*@ \subsection{Configuration}
	A configuration in \K is simply a state. Here we define the structure of our 
	configuration. We call each XML-like element declared below a \textit{cell}. 
	We declare a cell \texttt{thread} with multiplicity *, that is zero, one, or more. 
	Enclosed in thread is the main cell \texttt{k}. \texttt{k} is the computation cell where we 
	execute our program. We handle Orc productions from inside the \texttt{k} cell as we 
	will see later.
	\begin{itemize}
		\item The \texttt{context} cell is for mapping variables to values. 
		\item The \texttt{publish} cell is for keeping published values of each thread, and \texttt{gPublish} is for globally published values.
		\item \texttt{props} holds thread management flags. 
		\item \texttt{varReqs} helps manage context sharing.
		\item \texttt{gVars} holds environment control and synchronization variables.
		\item The \texttt{in} and \texttt{out} cells are respectively the standard input and output streams. 
		\item \texttt{defs} holds the expressions defined at the beginning of the Orc program.
	\end{itemize}
	\par Each cell is declared with an initial value. The \texttt{\$PGM} 
	variable tells \K that this is where we want our program to go. So by 
	default, the first state would hold a single thread with the \texttt{k} cell holding 
	the whole Orc program as the \textit{Pgm} non-terminal defined in the syntax module.
	*/	
	configuration 	
		<T color="red">
			<threads color="OrangeRed">
				<thread multiplicity="*" color="Orange">
					<tid color="LightSkyBlue"> 0 </tid>
					<k color="Green"> $PGM:Pgm </k>	
					<context color="Maroon"> .Map </context>	
					<publish color="Mahogany"> .List </publish>	<br/> 
					<parentId color="Blue"> -1 </parentId>   // -1 is the parentId of the root/main thread which has no parent
					<props color="Magenta"> .Set </props> <br/>
					<varReqs color="VioletRed"> .List </varReqs>
				</thread>
			</threads> <br/>
			<defs color="MidnightBlue">
				<def multiplicity="*" color="Mulberry">
					<defId color="Orchid"> "" </defId>
					<defParams color="Peach"> .Params </defParams>
					<body color="YellowGreen"> .K </body>
				</def>
			</defs> <br/>
			<gPublish color="Yellow"> .List </gPublish>
			<gVars color="Salmon">
				// "time.zero" |-> 0 /Rat 1 // a constant
				"time.ticked" |-> (0)
				"time.clock" |-> (0)
				"time.MTE"   |-> $TL:Int // We initially want MTE to be infinity so we set to be the time limit.
        "time.limit" |-> $TL:Int
        "publishCount" |-> 0
				"count" |-> 0 // exclusively used by the site 'count'
				// the following 4 are for sequential delta
				// "threads_applied_delta" |-> 0  
				// "threads_executed_delta" |-> 0
				// "is_delta_applied" |-> false
				// "is_delta_executed" |-> false
			</gVars>
			<in color="OliveGreen" stream="stdin"> .List </in>
			<out color="Melon" stream="stdout"> .List </out>
			<verbose color="WildStrawberry"> $V:Bool </verbose>
		</T>
	
	
	
//=================Thread Management===================
	
	//@ This is an orphan rule whose only purpose is to delete threads marked as 'killed'. Only two rules in the whole definition kill threads, but I chose to centralize deletion of threads at this rule because it only deletes threads if 'verbose' is false. This is used for debugging. Sometimes I need to see all the threads that were created throughout the execution, so I make 'verbose' true.
	rule [Cleanup-Killed]:
		(<thread>
			...
			<k> killed(_) </k>
			...
		</thread> => .Bag)
		<verbose> false </verbose>
	[structural]
	
endmodule
