RandomMove() := Bot_MoveFwd() | Bot_TurnLeft() >> Bot_MoveFwd() | Bot_TurnRight() >> Bot_MoveFwd()
Bot_Init() >> RandomMove() >> RandomMove()


