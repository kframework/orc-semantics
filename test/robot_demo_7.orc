/* 
 This is a recursive program that does CarefulStep until the specified time limit is reached. 
 This program is conceptually like the previous one. It is only more complex and takes more execution time.
 Increasing the time limit will increase the execution time significantly.
 On an HP Zbook G3, TL=30 took 10 minutes, and TL=50 took 43 minutes.
 Run the following to verify that it will never hit.
 krun35 test\robot_demo_7.orc --ltlmc "[]Ltl gVarNeq(\"bot.Default.is_bumper_hit\",true)" -cTL=30 -cV=false -w none
*/

CarefulStep() := 
  bot.scan() > isBlocked > ( 
    if(isBlocked) >> (bot.rotateRight() | bot.rotateLeft()) 
    | ifNot(isBlocked) >> bot.stepFwd() 
  )
CarefulStep4Ever() := CarefulStep() >> CarefulStep4Ever()

bot.mapInit(<10,10>) >> 
bot.setObstacles(<1,1>,<1,5>,<2,2>,<2,4>,<2,8>,<3,7>,<3,4>,<3,5>,<4,1>,<4,4>,<4,9>,<5,7>,<7,5>,<7,7>,<8,1>,<8,2>,<8,9>) >> 
bot.init(<2,0>,<0,1>) >> 
CarefulStep4Ever()
