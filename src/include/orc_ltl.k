  //====================LTL INTERFACE EXTENSION================
	//@ \section{LTL Model Checking}

require "builtins/model-checker.k"
module ORC_LTL
  imports LTL-HOOKS
	imports MODEL-CHECKER-HOOKS
	imports ORC_SYNTAX

  /*@
    An input program can be a LTL Formula 
    (this is needed for parsing purposes)
  */
  syntax Pgm ::= LtlFormula

  /*@ We extend Orc expressions with labeled expressions to be able to specify
   inside an Orc program, using LTL formulas, when an expressions is reached. 
  */

  syntax Exp ::= Id ":" Exp 

  /*@
    The imported module \texttt{MODEL-CHECKER-HOOKS} is a \K interface
    to the Maude module defining the syntax for the model-checker. 
    In addition to this interface, we have to define the atomic propositions.
    Here we define a small set of such propositions.
    The semantics for these propositions will be given in the next module.  
  */

  syntax Prop ::= Id
                // | "eqToSum" "(" Id "," Id ")"
                | "gVarEq" "(" String "," Val ")"
                | "gVarEq" "(" String "," Tuple ")"
                | "gVarEq" "(" String "," List ")"
                | "gVarNeq" "(" String "," Val ")" 
                | "gVarNeq" "(" String "," Tuple ")" 
                | "gVarNeq" "(" String "," List ")" 
                // | "logInv" "(" Id "," Id "," Id ")"
                | "gVarLt" "(" String "," Int ")" 
                | "gVarLeq" "(" String "," Int ")" 
                | "gVarGt" "(" String "," Int ")" 
                | "gVarGeq" "(" String "," Int ")" 
				| "gVarExists" "(" String ")"
                // |  "eq" "(" Id "," Id ")"
                | "isGPublished" "(" Int ")"

  /*@
    This module combines the semantics of Orc with an
    interface to the model-checker, given by the module \texttt{LTL-HOOKS}.
    The states of the transition system that will be be model-checked are given
    by the configurations of Orc programs, which are of sort \texttt{Bag}.
   */

  /*@
    Semantics of the labeled expressions:
  */

    rule [LTL-Labeled-Exp-1]: 
			L:Id : E:Exp => E  [transition]

  /*@
    In order to give semantics to the proposition \texttt{gVarEq}, we use 
    auxiliary functions like \texttt{gVarGet} that returns a certain value 
    from inside a given configuration: 
   */

  syntax Arg ::= "gVarGet" "(" Bag "," String ")" [function]
  rule [LTL-gVarGet]:
		gVarGet(
			<generatedTop>... 
				<T>...
          <gVars>... S:String |-> A:Arg ...</gVars> 
        ...</T> 
			...</generatedTop>
			, S
		) => A

  syntax Int ::= "gVarGetInt" "(" Bag "," String ")" [function]
  rule [LTL-gVarGetInt]:
		gVarGet(
			<generatedTop>... 
				<T>...
          <gVars>... S:String |-> I:Int ...</gVars> 
        ...</T> 
			...</generatedTop>
			, S
		) => I

  syntax List ::= "gPublishGet" "(" Bag ")" [function]
  rule [LTL-gPublishGet]:
		gPublishGet(
			<generatedTop>... 
				<T>...
          <gPublish> L:List </gPublish> 
        ...</T> 
			...</generatedTop>
		) => L

		
  syntax Set ::= "gVarKeys" "(" Bag ")" [function]
  rule [LTL-gVarKeys]:
    gVarKeys(
      <generatedTop>... 
        <T>...
          <gVars> M:Map </gVars> 
        ...</T> 
      ...</generatedTop>
    ) => keys(M)
	
  // Some additional domain functions:
 
  // syntax Int ::= "sumFirstN" "(" Int ")" [function]
  // rule [LTL-sumFirstN-1]: sumFirstN(0) => 0 [anywhere]
  // rule [LTL-sumFirstN-2]: sumFirstN(N:Int) => sumFirstN(N -Int 1) +Int N requires N >Int 0 [anywhere]

  // syntax Int ::= "pow" "(" Int "," Int ")" [function]
  // rule [LTL-pow-1]: pow(X:Int, 0) => 1 
  // rule [LTL-pow-2]: pow(X:Int, Y:Int) => X *Int pow(X, Y -Int 1) requires Y >Int 0

  /*@
    We are ready now to give the semantics for atomic propositions:
   */

  rule [LTL-gVarExists]: B:Bag |=Ltl gVarExists(S:String) => true requires S in gVarKeys(B) [ltl, anywhere]
  rule [LTL-gVarExistsNot]: _:Bag |=Ltl gVarExists(_:String) => false  [ltl, owise]
  rule [LTL-gVarEq]: B:Bag |=Ltl gVarEq(S:String, V:Val) => true requires gVarGet(B, S) ==K V [ltl, anywhere]
  rule [LTL-gVarEq]: gVarEq(S:String, T:Tuple) => gVarEq(S, tuple2Klist(T)) [macro]
  rule [LTL-gVarEq]: B:Bag |=Ltl gVarEq(S:String, L:List) => true requires gVarGet(B, S) ==K L [ltl, anywhere]
  rule [LTL-gVarNeq]: B:Bag |=Ltl gVarNeq(S:String, V:Val) => true requires gVarGet(B, S) =/=K V [ltl, anywhere]
  rule [LTL-gVarNeq]: gVarNeq(S:String, T:Tuple) => gVarNeq(S, tuple2Klist(T)) [macro]
  rule [LTL-gVarNeq]: B:Bag |=Ltl gVarNeq(S:String, L:List) => true requires gVarGet(B, S) =/=K L [ltl, anywhere]
  rule [LTL-isGPublished]: B:Bag |=Ltl isGPublished(I:Int) => true requires I in gPublishGet(B) [ltl, anywhere]

  rule [LTL-gVarLt]: B:Bag |=Ltl gVarLt(S:String, V:Int) => true requires gVarGetInt(B, S) <Int V [ltl, anywhere]
  rule [LTL-gVarLeq]: B:Bag |=Ltl gVarLeq(S:String, V:Int) => true requires gVarGetInt(B, S) <=Int V [ltl, anywhere]
  rule [LTL-gVarGt]: B:Bag |=Ltl gVarGt(S:String, V:Int) => true requires gVarGetInt(B, S) >Int V [ltl, anywhere]
  rule [LTL-gVarGeq]: B:Bag |=Ltl gVarGeq(S:String, V:Int) => true requires gVarGetInt(B, S) >=Int V [ltl, anywhere]

  // rule [LTL-neqTo]: B:Bag |=Ltl neqTo(X:Id, I:Int) => true requires gVarGet(B, X) =/=Int I [ltl, anywhere]
  // rule [LTL-lt]: B:Bag |=Ltl lt(X:Id, I:Int) => true requires gVarGet(B, X) <Int I [ltl, anywhere]
  // rule [LTL-leq]: B:Bag |=Ltl leq(X:Id, I:Int) => true requires gVarGet(B, X) <=Int I [ltl, anywhere]
  // rule [LTL-gt]: B:Bag |=Ltl gt(X:Id, I:Int) => true requires gVarGet(B, X) >Int I [ltl, anywhere]
  // rule [LTL-geq]: B:Bag |=Ltl geq(X:Id, I:Int) => true requires gVarGet(B, X) >=Int I [ltl, anywhere]
  // rule [LTL-eq]: B:Bag |=Ltl eq(X:Id, Y:Id) => true requires gVarGet(B, X) ==Int gVarGet(B, Y) [ltl, anywhere]

  rule [LTL-Label-evaluation]: 
		<generatedTop>...
			<T>...
				<threads>
					<thread>...
						<k> L:Id : E:Exp ...</k>
					...</thread>
				</threads>
			...</T>
		...</generatedTop>
		|=Ltl L
		=>
		true
	[anywhere]


  // rule [LTL-eqToSum]: 
		// B:Bag |=Ltl eqToSum(X:Id, Y:Id) => true
       // requires gVarGet(B, X) ==Int sumFirstN(gVarGet(B, Y))
       // [ltl, anywhere]

			 //this is duplicated
  // rule B:Bag |=Ltl eqTo(X:Id, I:Int) => true
       // requires gVarGet(B, X) ==Int I
       // [ltl, anywhere]

  // rule [LTL-logInv]: 
		// B:Bag |=Ltl logInv(A:Id, X:Id, K:Id) => true
       // requires (gVarGet(B, X) *Int pow(2, gVarGet(B, K)) <=Int gVarGet(B, A)) 
             // andBool (gVarGet(B, A) <Int (gVarGet(B, X) +Int 1) *Int pow(2, gVarGet(B, K)))
       // [ltl, anywhere]
   
endmodule

