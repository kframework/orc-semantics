// this example runs correctly, but search will run forever.
//Bot_Setup() := Bot_Init() >> Bot_SetObstacles([3,1],[4,1],[5,1])
Bot_FwdForever() := bot.stepFwd() >> Bot_FwdForever()
bot.mapInit() >> bot.init() >> Bot_FwdForever()
