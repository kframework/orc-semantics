// This is a recursive program that does SmartStep until the specified time limit is reached. 
// Run the following to verify that the robot will never hit. In this case it certainly will.
// krun35 test\robot_demo_5.orc --ltlmc "[]Ltl gVarNeq(\"bot.Default.is_bumper_hit\",true)" -cTL=30 -cV=false -w none


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
SmartStep4Ever() :=  SmartStep() >> SmartStep4Ever()

bot.mapInit(<3,3>) >> 
bot.setObstacles(<1,1>,<2,2>) >> 
bot.init(<2,0>,<0,1>) >> 
SmartStep4Ever()
