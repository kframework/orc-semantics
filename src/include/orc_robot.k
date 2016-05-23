	//@ \section{Bot Environment}
module ORC_ROBOT
	imports ORC_SYNTAX
	imports MY_BUILTINS
		
	// I need to make the expression (bot.rotateLeft | bot.rotateRight) go either left or right nondeterminisically.
	// ok how to do it: only the handle that has control will move the bot and publish signal. handle that has no control will become silent. handle finishing time, will release THE control.
	// maybe the robot should be one site and the command be its argument
	
	//@ Define a special category of sites that deals with locks
	syntax Arg ::= "bot_lock"
	syntax TSiteId ::= BotTSite 
	
	//@ \subsection{Internal Bot Sites}
	syntax ISiteId ::= "bot.mapInit"
	rule
		<k> handle(bot.mapInit(.Args)) => pubHandle(signal) ...</k> <br/>
		<gVars>... .Map => 
			("bot.map_size" |-> ListItem(5) ListItem(5))
			("bot.map_obstacles" |-> .List)
		</gVars>
	[structural]
	
	rule
		<k> handle(bot.mapInit(T:Tuple)) => pubHandle(signal) ...</k> <br/>
		<gVars>... .Map => 
			("bot.map_size" |-> tuple2Klist(T))
			("bot.map_obstacles" |-> .List)
		</gVars>
	[structural]
	
	syntax ISiteId ::= "bot.init"
	rule
		<k> handle(bot.init(.Args)) => handle(bot.init("Default")) ...</k> [macro]
	
	rule
		<k> handle(bot.init(S:String)) => pubHandle(S) ...</k> <br/>
		<gVars>... .Map =>
			(botStr(S,"position") |-> ListItem(1) ListItem(1))
			(botStr(S,"direction") |-> ListItem(0) ListItem(1))
			(botStr(S,"bot_lock") |-> false)
			(botStr(S,"is_bumper_hit") |-> false)
			(botStr(S,"wall_indicator") |-> ListItem(-1) ListItem(-1))
			(botStr(S,"block_indicator") |-> ListItem(-1) ListItem(-1))
		</gVars>
	[structural]
	
	// rule // this shouldn't be defined like this. 
		// bot.init(S:String, T1:Tuple, T2:Tuple) => bot.init(S) >> bot.setPosition(S,T1) >> bot.setDirection(S,T2) [macro]
	
	rule
		<k> handle(bot.init(T1:Tuple, T2:Tuple)) => handle(bot.init("Default", T1, T2)) ...</k> [macro]
	
	rule
		<k> handle(bot.init(S:String, T1:Tuple, T2:Tuple)) => pubHandle(S) ...</k>
		<gVars>... .Map =>
			(botStr(S,"position") |-> tuple2Klist(T1))
			(botStr(S,"direction") |-> tuple2Klist(T2))
			(botStr(S,"bot_lock") |-> false)
			(botStr(S,"is_bumper_hit") |-> false)
			(botStr(S,"wall_indicator") |-> ListItem(-1) ListItem(-1))
			(botStr(S,"block_indicator") |-> ListItem(-1) ListItem(-1))
		</gVars>
	[structural]
	
	syntax ISiteId ::= "bot.setPosition"
	rule
		<k> handle(bot.setPosition(S:String, T:Tuple)) => pubHandle(signal) ...</k>
		<gVars>...
			botStr(S,"position") |-> (_ => tuple2Klist(T))
		</gVars>
	[structural]
	
	syntax ISiteId ::= "bot.setDirection"
	rule
		<k> handle(bot.setDirection(S:String, T:Tuple)) => pubHandle(signal) ...</k>
		<gVars>... 
			botStr(S,"direction") |-> (_ => tuple2Klist(T))
		</gVars>
	[structural]
	
	
	syntax ISiteId ::= "bot.setObstacles"
	syntax KItem ::= addObstacle(Tuple)
	rule 
		<k> handle(bot.setObstacles(As:Args)) => handle(bot.addObstacles(As)) ...</k>
		<gVars>...
			"bot.map_obstacles" |-> (L:List => .List)
		</gVars>
	[structural]
	
	syntax ISiteId ::= "bot.addObstacles"
	rule 
		<k> handle(bot.addObstacles(T:Tuple, As:Args)) => addObstacle(T) ~> handle(bot.addObstacles(As)) ...</k>
	[structural]
	rule 
		<k> handle(bot.addObstacles(.Args)) => pubHandle(signal) ...</k>
	[structural]
	rule 
		<k> addObstacle(T:Tuple) => .K ...</k> <br/>
		<gVars>...
			"bot.map_obstacles" |-> L:List (.List => ListItem(tuple2Klist(T)))
		</gVars>
	[structural]
	
	// internal functions
	syntax KItem ::= botMoved(String, Bool) [function]
	rule 
		<k> botMoved(S, _) => signal </k> <br/>
		<gVars>...
			(Lock:String |-> (true => false))
			(Wall:String |-> (_:List => ListItem(-1) ListItem(-1)))
			(Block:String |-> (_:List => ListItem(-1) ListItem(-1)))
		</gVars>
		when Lock ==String botStr(S,"bot_lock")
			andBool Wall ==String botStr(S,"wall_indicator")
			andBool Block ==String botStr(S,"block_indicator")
		[structural]
	
	syntax String ::= botStr(String, String) [function]
	rule botStr(S1,S2) => "bot." +String S1 +String "." +String S2 [anywhere]
	
	//=============== Begin Timed Bot Sites ===================
	//@ \subsection{Timed Bot Sites}
	//@ Define scan site
	syntax BotTSite ::= "bot.scan"
	rule
		<k> handle(bot.scan(.Args)) => handle(bot.scan("Default")) ...</k> [macro]
	rule 
		<k> handle(bot.scan(S:String)) => timedHandle(1.0, bot.scan(S), bot_lock) ...</k>
			 // we don't need to lock the bot here, because it should be able to scan and start moving simultaneously. the arg "bot_lock" needs another name to remove confusion. TODO.
		[structural]
	rule
		<k> timedHandle(0.0, bot.scan(S), bot_lock) => timedHandle(0.0, bot.scan(S), (checkWall(vSub(vAdd(Pos,Dir),Dims)) orBool checkBlock(vAdd(Pos,Dir),Obs)) ) </k>
		<gVars>...
			("bot.map_size" |-> Dims:List)
			("bot.map_obstacles" |-> Obs:List)
			(PosStr |-> Pos:List)
			(DirStr |-> Dir:List)
		</gVars>
			when PosStr ==String botStr(S,"position")
			andBool DirStr ==String botStr(S,"direction")
		[structural]
	
	//@ Define step forward site
	syntax BotTSite ::= "bot.stepFwd"
	syntax Bool ::= checkWall(List) [function]
	syntax Bool ::= checkBlock(List,List) [function]
	
	
	// syntax BotTSite ::= CamelCaseId ".stepFwd" // leave this to show people at demo
	// This is not working. The problem is in matching the keys of the map. When you print the keys, they are showed correctly. but it looks like K is expecting to see exactly (CamelCaseId2String(S) +String ".bot_lock") in order to match it. I even tried a specific string from inside the orc program "myCow" +String ".bot_lock" for example and it still didn't work. Dwight said "+String is a function and thus does not support matching on itself.". So I did it like I did with time rules. I made the +String in the side conditions. Another problem appears when I use too many of those. I get "[Error] Critical: SDF failed to parse a rule by throwing: null". So I decided to pull on this rule and just go with sending the robot's name as a string as an argument.
	// rule 
		// <k> handle( S:CamelCaseId .stepFwd(.Args)) => timedHandle(3, S .stepFwd(.Args), bot_lock) </k>
		// <gVars> "BotVars" |-> (M:Map
			// S1 |-> (false => true)
			// S2 |-> (_ => false)
			// S3 |-> Pos:List
			// S4 |-> Dir:List
			// S5 |-> (_:List => vSub(vAdd(Pos,Dir),Dims))
			// S6 |-> (_:List => vAdd(Pos,Dir))
			// "bot.map_obstacles" |-> Obs:List
			// "bot.map_size" |-> Dims:List
			// )
		// ...</gVars>
		// when S1 ==String CamelCaseId2String(S) +String ".bot_lock"
			// andBool S2 ==String CamelCaseId2String(S) +String ".is_bumper_hit"
			// andBool S3 ==String CamelCaseId2String(S) +String ".position"
			// andBool S4 ==String CamelCaseId2String(S) +String ".direction"
			// andBool S5 ==String CamelCaseId2String(S) +String ".wall_indicator"
			// andBool S6 ==String CamelCaseId2String(S) +String ".block_indicator"
		// [transition]
		
	// This worked, but the varReq rule jumped in to look for the Id. So I replaced it with a string	
	// rule 
		// <k> handle(bot.stepFwd(S:CamelCaseId)) => timedHandle(3, bot.stepFwd(S), bot_lock) </k>
		// <gVars> "BotVars" |-> (M:Map
			// (S1 |-> (false => true))
			// (S2 |-> (_ => false))
			// (S3 |-> Pos:List)
			// (S4 |-> Dir:List)
			// (S5 |-> (_:List => vSub(vAdd(Pos,Dir),Dims)))
			// (S6 |-> (_:List => vAdd(Pos,Dir)))
			// ("bot.map_obstacles" |-> Obs:List)
			// ("bot.map_size" |-> Dims:List)
			// )
		// ...</gVars>
		// when S1 ==String ((CamelCaseId2String(S)) +String ".bot_lock")
			// andBool S2 ==String ((CamelCaseId2String(S)) +String ".is_bumper_hit")
			// andBool S3 ==String ((CamelCaseId2String(S)) +String ".position")
			// andBool S4 ==String ((CamelCaseId2String(S)) +String ".direction")
			// andBool S5 ==String ((CamelCaseId2String(S)) +String ".wall_indicator")
			// andBool S6 ==String ((CamelCaseId2String(S)) +String ".block_indicator")
		// [transition]
	
	rule
		<k> handle(bot.stepFwd(.Args)) => handle(bot.stepFwd("Default")) ...</k> [macro]
	rule [bot-stepFwd]:
		<k> handle(bot.stepFwd(S:String)) => timedHandle(3.0, bot.stepFwd(S), bot_lock) </k>
		<gVars>
			(Lock |-> (false => true))
			(Bumper |-> (_ => false))
			(PosStr |-> Pos:List)
			(DirStr |-> Dir:List)
			(Wall |-> (_:List => vSub(vAdd(Pos,Dir),Dims)))
			(Block |-> (_:List => vAdd(Pos,Dir)))
			("bot.map_obstacles" |-> Obs:List)
			("bot.map_size" |-> Dims:List)
		...</gVars>
		when Lock ==String botStr(S,"bot_lock")
			andBool Bumper ==String botStr(S,"is_bumper_hit")
			andBool PosStr ==String botStr(S,"position")
			andBool DirStr ==String botStr(S,"direction")
			andBool Wall ==String botStr(S,"wall_indicator")
			andBool Block ==String botStr(S,"block_indicator")
		[transition]
		
	rule checkWall(WI) => 1 in WI	[function, anywhere]
	rule checkBlock(BI,Obs) => BI in Obs [function, anywhere]
	
	//@ Stepped forward and not hit a wall or block
	rule [Step-Done-No-Hit]:
		<k> timedHandle(0.0, bot.stepFwd(S:String), _) => botMoved(S, true) </k>
		<gVars> 
			(PosStr |-> (Pos => vAdd(Pos,Dir)))
			(DirStr |-> Dir)
			("bot.map_obstacles" |-> Obs:List)
			(Wall |-> WL:List)
			(Block |-> BI:List)
		...</gVars>
		when (notBool 1 in WL andBool notBool BI in Obs)
			andBool (PosStr ==String botStr(S,"position"))
			andBool (DirStr ==String botStr(S,"direction"))
			andBool (Wall ==String botStr(S,"wall_indicator"))
			andBool (Block ==String botStr(S,"block_indicator"))
		[structural]
	
	//@ Tried to step forward but hit a wall or block
	rule [No-Step-Cause-Hit]:
		<k> timedHandle(0.0, bot.stepFwd(S:String), _) => botMoved(S, true) </k>
		<gVars>
			(Bumper |-> (_ => true))
			"bot.map_obstacles" |-> Obs:List
			Wall |-> WL:List
			Block |-> BI:List
		...</gVars>
		when (1 in WL orBool BI in Obs)
			andBool (Bumper ==String botStr(S,"is_bumper_hit"))
			andBool (Wall ==String botStr(S,"wall_indicator"))
			andBool (Block ==String botStr(S,"block_indicator"))
		[structural]

	//@ Rotate right (clockwise)
	syntax BotTSite ::= "bot.rotateRight"
	rule [bot-rotateRight]:
		<k> handle(bot.rotateRight(.Args)) => handle(bot.rotateRight("Default")) ...</k> [macro]
	rule 
		<k> handle(bot.rotateRight(S:String)) => timedHandle(1.0, bot.rotateRight(S), bot_lock) </k>
		<gVars> 
			Lock |-> (false => true)
		...</gVars>
		when Lock ==String botStr(S,"bot_lock")
		[transition]
	
	rule
		<k> timedHandle(0.0, bot.rotateRight(S:String),_) => botMoved(S, true) </k>
		<gVars> 
			(DirStr |-> (Direction => cw(Direction)))
			(Bumper |-> (_ => false))
		...</gVars>
			when (Bumper ==String botStr(S,"is_bumper_hit"))
			andBool (DirStr ==String botStr(S,"direction"))
		[structural]
	
	//@ Rotate left (counter-clockwise)
	syntax BotTSite ::= "bot.rotateLeft"
	rule [bot-rotateLeft]:
		<k> handle(bot.rotateLeft(.Args)) => handle(bot.rotateLeft("Default")) ...</k> [macro]
	rule 
		<k> handle(bot.rotateLeft(S:String)) => timedHandle(1.0,bot.rotateLeft(S), bot_lock) </k>
		<gVars> 
			Lock |-> (false => true)
		...</gVars>
		when Lock ==String botStr(S,"bot_lock")
		[transition]
	rule
		<k> timedHandle(0.0, bot.rotateLeft(S:String),_) => botMoved(S, true) </k>
		<gVars> 
			(DirStr |-> (Direction => ccw(Direction)))
			(Bumper |-> (_ => false))
		...</gVars>
			when (Bumper ==String botStr(S,"is_bumper_hit"))
			andBool (DirStr ==String botStr(S,"direction"))
	[structural]
	
	//@ Generic rule to stop execution if lock on robot
 	rule 
		<k> handle(Site:BotTSite(S:String)) => silentHandle(Site(S)) </k>
		<gVars> 
			Lock |-> true
		...</gVars>
		when Lock ==String botStr(S,"bot_lock")
		[structural]
	
	//@ Functions to process rotating the robot
	syntax List ::= cw(List) [function]
	rule cw(ListItem(-1) ListItem(0)) => ListItem(0) ListItem(1)	[function, anywhere]
	rule cw(ListItem(0) ListItem(-1)) => ListItem(-1) ListItem(0)	[function, anywhere]
	rule cw(ListItem(1) ListItem(0)) => ListItem(0) ListItem(-1)	[function, anywhere]
	rule cw(ListItem(0) ListItem(1)) => ListItem(1) ListItem(0)	[function, anywhere]
	syntax List ::= ccw(List) [function]
	rule ccw(ListItem(0) ListItem(1)) => ListItem(-1) ListItem(0)	[function, anywhere]
	rule ccw(ListItem(-1) ListItem(0)) => ListItem(0) ListItem(-1)	[function, anywhere]
	rule ccw(ListItem(0) ListItem(-1)) => ListItem(1) ListItem(0)	[function, anywhere]
	rule ccw(ListItem(1) ListItem(0)) => ListItem(0) ListItem(1)	[function, anywhere]


// Dwight's suggestion for 3.6 to work with looking up gVars map	
// syntax Map ::= processMap(Map, K) [function]

// syntax KItem ::= pair(K, K)
// rule processMap((Key |-> Val => .Map) _:Map, (.K => pair(Key, Val)))
// rule processMap(_, pair(Lock:String, true) => .K) (.Map => Lock |-> false)
       // requires Lock ==String "Car" +String "Lock"
// rule processMap(.Map, .K) => .Map
// rule processMap(_, pair(Lock:String, Value:K) => .K) (.Map => Lock |-> Value) [owise]
	
endmodule