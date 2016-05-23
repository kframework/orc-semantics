FwdForever(thisBot) := bot.moveFwd(thisBot) >> FwdForever(thisBot)
bot.mapInit(<10,10>) >> bot.setObstacles(<5,2>) >> (bot.init(<0,5>) | bot.init(<5,0>)) > myCow > FwdForever(myCow)
