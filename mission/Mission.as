package mission
{
	/**
	 * ...
	 * @author IJUST
	 */
	public class Mission 
	{
		public var rows:uint;
		public var cols:uint;
		public var time:uint;
		public var numTypes:uint;
		//关卡数据  包含本关的行数 列数 最长时间  以及方块的种类数量
		public function Mission(row:uint,col:uint,time:uint,num:uint)
		{
			this.rows = row;
			this.cols = col;
			this.time = time;
			this.numTypes = num;
		}
		
	}

}