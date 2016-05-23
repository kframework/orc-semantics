//krun35 test\robot_demo.orc
//krun35 test\robot_demo.orc --search --pattern "<gVars> M:Map </gVars>"
//krun35 test\robot_demo.orc --search --pattern "<gVars>... \"bot.Default.position\" |-> Pos </gVars>"
//krun35 test\robot_demo.orc --ltlmc "<>Ltl gVarEqTo(\"bot.Default.is_bumper_hit\",false)"
ChangeLane(b) := 
	(
		(bot.rotateRight(b) >> bot.stepFwd(b) >> bot.rotateLeft(b))
		| (bot.rotateLeft(b) >> bot.stepFwd(b) >> bot.rotateRight(b))
	)
SmartStep(b) :=  
	bot.scan(b) > isBlocked > 
		(
			if(isBlocked) >> ChangeLane(b)
			| ifNot(isBlocked) >> bot.stepFwd(b)
		)

bot.mapInit() >> 
bot.setObstacles(<2,2>) >> 
bot.init(<2,1>,<0,1>) > x > SmartStep(x)