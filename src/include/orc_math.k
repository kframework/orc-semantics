//@\section{Math Sites}
module ORC_MATH
	imports ORC_SYNTAX
	syntax ISiteId ::= "Add"
	rule handle(Add(I1:Int, I2:Int)) => pubHandle(I1 +Int I2) //when randomRandom(100) >=Int 50 
	[structural]
	
	syntax ISiteId ::= "Incr"
	rule handle(Incr(I:Int)) => pubHandle(I +Int 1)
	[structural]
	
	syntax ISiteId ::= "Decr"
	rule handle(Decr(I:Int)) => pubHandle(I -Int 1)
	[structural]
	
	syntax ISiteId ::= "Sum"
	// rule handle(Sum(I1:Int, As:Args)) => handle(Sum(As), I1)	[macro]
	// rule handle(Sum(I1:Int, As:Args), I2:Int) => handle(Sum(As), I1 +Int I2)
	// rule handle(Sum(.Args), I:Int) => pubHandle(I) [structural]
	rule handle(Sum(I1:Int, I2:Int, As:Args)) => handle(Sum(I1 +Int I2, As)) [macro]
	rule handle(Sum(I:Int, .Args)) => pubHandle(I) [structural]
	
	syntax ISiteId ::= "Sqrt"
	rule handle(Sqrt(I1:Float)) => pubHandle(rootFloat(I1,2)) [structural]
	
	syntax ISiteId ::= "Root"
	rule handle(Root(I1:Float, I2:Int)) => pubHandle(rootFloat(I1,I2) 	) [structural]
	
	syntax ISiteId ::= "Mul"
	rule handle(Mul(I1:Int, I2:Int)) => pubHandle(I1 *Int I2	) [structural]
	
	syntax ISiteId ::= "Sub"
	rule handle(Sub(I1:Int, I2:Int)) => pubHandle(I1 -Int I2	) [structural]
	
	syntax ISiteId ::= "Div"
	rule handle(Div(I1:Int, I2:Int)) => pubHandle(I1 /Int I2) when I2 =/=K 0 [structural]
	
	syntax ISiteId ::= "Mod"
	rule handle(Mod(I1:Int, I2:Int)) => pubHandle(I1 %Int I2) when I2 =/=K 0	[structural]
	
	syntax ISiteId ::= "Floor"
	rule handle(Floor(V:Float)) => pubHandle(floorFloat(V)	) [structural]
	syntax ISiteId ::= "Ceil"
	rule handle(Ceil(V:Float)) => pubHandle(ceilFloat(V)	) [structural]
	syntax ISiteId ::= "Round"
	rule handle(Round(V:Float, I1:Int, I2:Int)) => pubHandle(roundFloat(V,I1,I2)	) [structural]
	syntax ISiteId ::= "Abs"
	rule handle(Abs(V:Float)) => pubHandle(absFloat(V)	) [structural]
	syntax ISiteId ::= "Exp"
	rule handle(Exp(V:Float)) => pubHandle(expFloat(V)	) [structural]
	syntax ISiteId ::= "LogFloat"
	rule handle(LogFloat(V:Float)) => pubHandle(logFloat(V)	) [structural]
	syntax ISiteId ::= "SinFloat"
	rule handle(SinFloat(V:Float)) => pubHandle(sinFloat(V)	) [structural]
	syntax ISiteId ::= "CosFloat"
	rule handle(CosFloat(V:Float)) => pubHandle(cosFloat(V)	) [structural]
	syntax ISiteId ::= "TanFloat"
	rule handle(TanFloat(V:Float)) => pubHandle(tanFloat(V)	) [structural]
	syntax ISiteId ::= "AsinFloat"
	rule handle(AsinFloat(V:Float)) => pubHandle(asinFloat(V)	) [structural]
	syntax ISiteId ::= "AcosFloat"
	rule handle(AcosFloat(V:Float)) => pubHandle(acosFloat(V)	) [structural]
	syntax ISiteId ::= "AtanFloat"
	rule handle(AtanFloat(V:Float)) => pubHandle(atanFloat(V)	) [structural]
	syntax ISiteId ::= "Atan2Float"
	rule handle(Atan2Float(V1:Float,V2:Float)) => pubHandle(atan2Float(V1,V2)	) [structural]
	syntax ISiteId ::= "MaxFloat"
	rule handle(MaxFloat(V1:Float,V2:Float)) => pubHandle(maxFloat(V1,V2)	) [structural]
	syntax ISiteId ::= "MinFloat"
	rule handle(MinFloat(V1:Float,V2:Float)) => pubHandle(minFloat(V1,V2)	) [structural]
		
	syntax ISiteId ::= "Equals"
	rule handle(Equals(I1:Int, I2:Int)) => pubHandle(I1 ==K I2	) [structural]	
	syntax ISiteId ::= "Gr"
	rule handle(Gr(I1:Int, I2:Int)) => pubHandle( I1 >Int I2	) [structural]
	syntax ISiteId ::= "GrEq"
	rule handle(GrEq(I1:Int, I2:Int)) => pubHandle( I1 >=Int I2	) [structural]
	syntax ISiteId ::= "Ls"
	rule handle(Ls(I1:Int, I2:Int)) => pubHandle( I1 <Int I2	) [structural]
	syntax ISiteId ::= "LsEq"
	rule handle(LsEq(I1:Int, I2:Int)) => pubHandle( I1 <=Int I2	) [structural]

endmodule