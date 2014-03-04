package config 
{
	/**
	 * ...
	 * @author IJUST
	 */
	public class vo 
	{
		public function vo() 
		{
			
		}
		//下面是所有方块类型，这里后面的数值是颜色  可以自己修改
		public static const Red:uint = 0xFF0000;
		public static const Blue:uint = 0x0000FF;
		public static const Green:uint = 0x00FF00;
		public static const Yellow:uint = 0xFFFF00;
		public static const Purple:uint = 0xFF00FF;
		public static const Orange:uint = 0xFF80C0;
		//所有以上方块类型放在一起后的数组
		public static const picArray:Array = [Red,Blue,Green,Yellow,Purple,Orange];
	}

}