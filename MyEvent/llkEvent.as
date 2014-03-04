package MyEvent 
{
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author IJUST
	 */
	public class llkEvent 
	{
		public static const GameEvent:EventDispatcher = new EventDispatcher();//全局静态常量  派发事件  可被全局收听
		//下面是可能会被派发的事件  不过只用到了前两个
		public static const TileClick:String = "tileclick";
		public static const TimeOut:String = "timeout";
		
		public static const GameStart:String = "gamestart";
		public static const MissionPass:String = "missionpass";
		
	}

}