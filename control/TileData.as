package control 
{
	/**
	 * ...
	 * @author IJUST
	 */
	public class TileData 
	{
		//一个数据类型 存放方块的位置信息  相当于 point
		public var Row:uint;
		public var Col:uint;
		public function TileData(row:uint,col:uint) 
		{
			this.Row = row;
			this.Col = col;
		}
		
	}

}