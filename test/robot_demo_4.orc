//krun35 test\robot_demo.orc
//krun35 test\robot_demo.orc --search --pattern "<gVars> M:Map </gVars>"
//krun35 test\robot_demo.orc --search --pattern "<gVars>... \"bot.Default.position\" |-> Pos </gVars>"
//krun35 test\robot_demo.orc --ltlmc "[]Ltl gVarNeq(\"bot.Default.is_bumper_hit\",true)"
// we don't check if is_bumper_hit is always false because in the initial state it is not even created and that is considered not equal to false.

// --ltlmc "[]Ltl (gVarEq(\"bot.Default.position\", <1,1>) \\/Ltl gVarEq(\"bot.Default.position\", <3,1>)) ->Ltl gVarLte(\"time.clock\", 6))"
// --ltlmc "[]Ltl ( gVarEq(\"time.clock\", 6) =>Ltl (gVarEq(\"bot.Default.position\", <1,1>) \\/Ltl gVarEq(\"bot.Default.position\", <3,1>)) )"
// --ltlmc "[]Ltl ( gVarEq(\"time.clock\", 6) =>Ltl (gVarEq(\"publishCount\", 7) \\/Ltl gVarEq(\"publishCount\", 8)) )"

ChangeLane() := 
	(
		(bot.rotateRight() >> bot.stepFwd() >> bot.rotateLeft())
		| (bot.rotateLeft() >> bot.stepFwd() >> bot.rotateRight())
	)
SmartStep() :=  
	bot.scan() > isBlocked > 
		(
			if(isBlocked) >> ChangeLane()
			| ifNot(isBlocked) >> bot.stepFwd()
		)

bot.mapInit() >> 
bot.setObstacles(<2,2>) >> 
bot.init(<2,1>,<0,1>) >> SmartStep()