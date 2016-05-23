// test using:
//krun35 test\test_robot1.orc --search --pattern "<gVars>... \"BotVars\" |-> M:Map ...</gVars>"
ChangeLane(b) := ((bot.rotateRight(b) >> bot.stepFwd(b) >> bot.rotateLeft(b)) | (bot.rotateLeft(b) >> bot.stepFwd(b) >> bot.rotateRight(b)))
SmartStep(b) :=  bot.scan(b) > isBlocked > (ifNot(isBlocked) >> bot.stepFwd(b) | if(isBlocked) >> ChangeLane(b))
SmartStep4Ever(b) :=  SmartStep(b) >> SmartStep4Ever(b)
// SmartStep(b) :=  bot.scan(b) > isBlocked > (if(isBlocked) >> ChangeLane(b) ; bot.stepFwd(b))
// bot.init() >> bot.stepFwd() >> bot.stepFwd() >> bot.rotateLeft() >> bot.stepFwd()
// bot.mapInit() >> bot.init("myCow") >> (bot.rotateRight("myCow") | bot.rotateLeft("myCow") | bot.stepFwd("myCow")) // WORKING! test with search. should give three solutions. one where the robot rotates right, one rotates left, one moves forward. tested with: --search --pattern "<gVars>... \"bot.myCow.direction\" |-> Dir </gVars>"
// bot.mapInit() >> (bot.init("myCow") | bot.init("yourCow")) > x > (bot.stepFwd(x)) // This is working as expected. run normally without search.
// bot.mapInit() >> (bot.init("myCow") | bot.init("yourCow")) > x > SmartStep(x) // Working. Both bots will move one step forward. Next, put blocks and see if 'if' works.
// bot.mapInit() >> bot.setObstacles(<1,5>) >> (bot.init("myCow") | bot.init("yourCow")) > x > bot.stepFwd(x) // this will initialize two bots but they both will be in the same position, the default position. They should both collide with the obstacle
// bot.mapInit() >> bot.setObstacles(<5,1>,<7,2>) >> (bot.init("myCow") | bot.init("yourCow",<5,0>,<0,1>)) > x > bot.stepFwd(x) // this will move both bots. yourCow will hit but mine won't.
// bot.mapInit() >> bot.setObstacles(<5,1>) >> (bot.init("myCow") | bot.init("yourCow",<5,0>,<0,1>)) > x > SmartStep(x) // working! yourCow will change lane. test with search to see it end up in two places, changing lane once to the left and once to the right. search currently running forever. maybe try 3.6 search because it's not maude. let's try a less complex version:
// bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> (bot.init("myCow",<0,3>,<1,0>) | bot.init("yourCow",<2,0>,<0,1>)) > x > (bot.rotateRight(x) | bot.rotateLeft(x)) // search working as expected with sequential delta.
// bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> bot.init("yourCow",<2,0>,<0,1>) > x > SmartStep(x) // search working. adding one more smart step:
// bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> bot.init("yourCow",<2,0>,<0,1>) > x > (SmartStep(x) >> SmartStep(x)) // search works but takes around 10 minutes
// bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> bot.init("yourCow",<2,0>,<0,1>) >> SmartStep("yourCow") >> SmartStep("yourCow") // search took exactly 9 minutes
// bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> bot.init("yourCow",<2,0>,<0,1>) >> SmartStep("yourCow") >> SmartStep("yourCow") >> SmartStep("yourCow") // search error after 22 minutes
// bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> (bot.init("myCow",<0,3>,<1,0>) | bot.init("yourCow",<2,0>,<0,1>)) > x > SmartStep(x) // still search is running forever
// bot.mapInit() >> (bot.init("myCow") | bot.init("yourCow")) > x > SmartStep4Ever(x) // here of course search takes forever as well

//=======================
// let't try ltlmc.
// krun35 test\test_robot1.orc --ltlmc "<>Ltl gVarEqTo(\"bot.yourCow.is_bumper_hit\",false)"
// bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> bot.init("yourCow",<2,0>,<0,1>) >> SmartStep("yourCow") >> SmartStep("yourCow") >> SmartStep("yourCow") // ltlmc returned true in seconds
// bot.mapInit() >> bot.setObstacles(<5,1>) >> (bot.init("myCow") | bot.init("yourCow",<5,0>,<0,1>)) > x > SmartStep(x) // ltlmc returns true in seconds
bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> bot.init("yourCow",<2,0>,<0,1>) > x > (SmartStep(x) >> SmartStep(x)) // ltlmc takes a matter of seconds, return true.

//======================