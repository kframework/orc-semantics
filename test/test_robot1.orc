// test using:
//krun35 test\test_robot1.orc --search --pattern "<gVars>... \"BotVars\" |-> M:Map ...</gVars>"
ChangeLane(b) := ((bot.rotateRight(b) >> bot.stepFwd(b) >> bot.rotateLeft(b)) | (bot.rotateLeft(b) >> bot.stepFwd(b) >> bot.rotateRight(b)))
SmartStep(b) :=  bot.scan(b) > isBlocked > (ifNot(isBlocked) >> bot.stepFwd(b) | if(isBlocked) >> ChangeLane(b))
SmartStep4Ever(b) :=  SmartStep(b) >> SmartStep4Ever(b)
StepFwd4Ever(b) :=  bot.stepFwd(b) >> StepFwd4Ever(b)
// SmartStep(b) :=  bot.scan(b) > isBlocked > (if(isBlocked) >> ChangeLane(b) ; bot.stepFwd(b))
CarefulStep(b) := bot.scan(x) > isBlocked > ( if(isBlocked) >> (bot.rotateRight(x) | bot.rotateLeft(x)) | ifNot(isBlocked) >> bot.stepFwd(x) )
CarefulStep4Ever(b) := CarefulStep(b) >> CarefulStep4Ever(b)
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
// krun35 test\test_robot1.orc --ltlmc "<>Ltl gVarEq(\"bot.yourCow.is_bumper_hit\",false)"
// bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> bot.init("yourCow",<2,0>,<0,1>) >> SmartStep("yourCow") >> SmartStep("yourCow") >> SmartStep("yourCow") // ltlmc returned true in seconds
// bot.mapInit() >> bot.setObstacles(<5,1>) >> (bot.init("myCow") | bot.init("yourCow",<5,0>,<0,1>)) > x > SmartStep(x) // ltlmc returns true in seconds
// bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> bot.init("yourCow",<2,0>,<0,1>) > x > (SmartStep(x) >> SmartStep(x)) // ltlmc takes a matter of seconds, return true.
//bot.mapInit(<6,6>) >> bot.setObstacles(<2,1>,<4,2>) >> bot.init("yourCow",<2,0>,<0,1>) > x > SmartStep4Ever(x)
// Instead of using recursion, since my program is always limited by time, I will avoid recursion for simpler analysis
// bot.mapInit(<6,6>) >> (
  // bot.setObstacles(<2,1>,<4,2>) >> (
    // bot.init("yourCow",<2,0>,<0,1>) > x > (
	  // CarefulStep(x) >> CarefulStep(x) >> CarefulStep(x) >> CarefulStep(x) >> CarefulStep(x) >> CarefulStep(x)
    // )
  // )
// )

// the following command works. use on the following three prgrams to verify that the program will never cause the bot to hit an obstacle.
//krun ..\test\test_robot1.orc -cTL=30 -cV=false -w none --ltlmc "[]Ltl (gVarExists(\"bot.yourCow.is_bumper_hit\") =>Ltl gVarEq(\"bot.yourCow.is_bumper_hit\", false))"
// on the following program it takes 7 minutes
// bot.mapInit(<3,3>) >> (
  // bot.setObstacles(<2,1>,<0,2>) >> (
    // bot.init("yourCow",<2,0>,<0,1>) > x > (
	  // CarefulStep(x) >> CarefulStep(x) >> CarefulStep(x) >> CarefulStep(x) >> CarefulStep(x) >> CarefulStep(x)
// )))

// For recursive programs like the following, if it never terminates, you need to follow the krun command with --debugger. In such a case, even when the state cannot possibly transition further, it is still not considered a terminal state by K but rather a deadlock state.
// bot.mapInit(<3,3>) >> (
  // bot.setObstacles(<1,1>,<2,2>) >> (
    // bot.init("yourCow",<2,0>,<0,1>) > x > (
      // SmartStep4Ever(x)
    // )
  // )
// )

// We see from the previous example that SmartStep4Ever hits. we verify using the same command for CarefulStep4Ever
// bot.mapInit(<3,3>) >> (
  // bot.setObstacles(<1,1>,<2,2>) >> (
    // bot.init("yourCow",<2,0>,<0,1>) > x > (
      // CarefulStep4Ever(x)
    // )
  // )
// )


// Try a bigger map. Works. for time limit 30, 10 minutes. TL=100, 2:30 hours then crash. TL=50. 43 minutes. on HP Zbook Studio G3.
bot.mapInit(<10,10>) >> (
  bot.setObstacles(<1,1>,<1,5>,<2,2>,<2,4>,<2,8>,<3,7>,<3,4>,<3,5>,<4,1>,<4,4>,<4,9>,<5,7>,<7,5>,<7,7>,<8,1>,<8,2>,<8,9>) >> (
    bot.init("yourCow",<2,0>,<0,1>) > x > (
      CarefulStep4Ever(x)
    )
  )
)




// Let's try two robots.. NOT WORKING. Maude crashes. I think my rules don't account for that.
// bot.mapInit(<10,10>) >> 
  // bot.setObstacles(<5,5>,<2,2>,<3,3>,<7,3>,<7,8>,<1,6>) >> (
    // bot.init("bot1", <5,1>,<0,1>) > x > SmartStep(x)
    // | bot.init("bot2", <1,5>,<1,0>) > y > SmartStep(y)
  // )


//======================
