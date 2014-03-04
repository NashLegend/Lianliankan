package mission 
{
	/**
	 * ...
	 * @author IJUST
	 */
	public class MissionList 
	{
		
		public function MissionList() 
		{
			
		}
		//这个数组用来存储关卡  第一个项即一个关卡数据
		public static const MissionArray:Array =
		[
			new Mission(4, 4, 20, 3),
			new Mission(6, 6, 60, 4),
		];
		
	}

}