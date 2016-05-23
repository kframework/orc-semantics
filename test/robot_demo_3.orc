//krun35 test\robot_demo.orc
//krun35 test\robot_demo.orc --ltlmc "<>Ltl gVarEqTo(\"bot.Default.is_bumper_hit\",true)"
bot.mapInit() >> 
bot.setObstacles(<1,2>) >> 
bot.init() >> 
bot.stepFwd()