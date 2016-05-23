// test using:
//krun35 test\test_robot1.orc --search --pattern "<gVars> M:Map </gVars>"
DummyExp(a,b) := Add(a,b)
bot.init() >> (bot.turnRight() | bot.turnLeft() | bot.moveFwd()) // WORKING! test with search. should give three solutions. one where the robot turns right, one turns left, one moves forward.

