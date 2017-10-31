/* 
 This is a recursive program that does CarefulStep until the specified time limit is reached. 
 In the previous program, SmartStep caused the robot to hit. But with CarefulStep, it certainly will never hit.
 Run the following to verify that property.
 krun35 test\robot_demo_6.orc --ltlmc "[]Ltl gVarNeq(\"bot.Default.is_bumper_hit\",true)" -cTL=30 -cV=false -w none
*/

CarefulStep() := 
  bot.scan() > isBlocked > ( 
    if(isBlocked) >> (bot.rotateRight() | bot.rotateLeft()) 
    | ifNot(isBlocked) >> bot.stepFwd() 
  )
CarefulStep4Ever() := CarefulStep() >> CarefulStep4Ever()

bot.mapInit(<3,3>) >> 
bot.setObstacles(<1,1>,<2,2>) >> 
bot.init(<2,0>,<0,1>) >> 
CarefulStep4Ever()
