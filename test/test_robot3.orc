// tests nondeterminism in robot movement
Bot_2Fwd() := Bot_MoveFwd() >> Bot_MoveFwd()
Bot_FwdForever() := Bot_MoveFwd() >> Bot_FwdForever()
Bot_ChangeCourse() := (Bot_TurnLeft() | Bot_TurnRight()) >> Bot_MoveFwd() >> (Bot_TurnLeft() | Bot_TurnRight())
Bot_ManeuverAround() := Bot_TurnLeft() >> Bot_MoveFwd() >> Bot_TurnRight() | Bot_TurnRight() >> Bot_MoveFwd() >> Bot_TurnLeft()
Bot_Protocol() := Bot_Scan() >> (If(ObstacleAhead()) >> Bot_ManeuverAround() | If(Not(ObstacleAhead()))) >> Bot_MoveFwd() >> Bot_Protocol() 
//Bot_Setup() := Bot_Init() >> Bot_SetObstacles([2,5],[1,4],[1,6])

Bot_Init() >> Bot_Protocol()


/*
TODO in order
semantics for stop. DONE
semantics for walls. DONE
semantics for bumper IsHit. DONE
semantics for blocks.
use search to make sure all possibilities are shown
get model checking syntax from paper
try model checking.
  commands to play with
    krun
      search
        with pattern, depth, and bound
        graph used after search
      debugger (very useful)
      trace
      --statistics didn't give any stats
      --generate-tests
      --profile
      --ltlmc
      --prove
      
    kast (not pretty output even when using --pretty)
    
*/
