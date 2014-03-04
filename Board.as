package  
{
	import config.conf;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author IJUST
	 */
	public class Board extends Sprite 
	{
		//这个是棋盘  用来放置方块
		private var Rows:uint;
		private var Cols:uint;
		public var DataArray:Array = [];//二维数组  用来存储棋盘信息，DataArray[i][j]为0则表示i,j处无方块，为1则表示有
		public function Board(row:uint=2,col:uint=2) 
		{
			this.Rows = row;
			this.Cols = col;
			//先初始化数组  都设置为0
			for (var i:int = 0; i < row; i++)
			{
				var tmpArray:Array = [];
				for (var j:int = 0; j < col; j++)
				{
					tmpArray.push(0);
				}
				DataArray.push(tmpArray);
			}
			drawGrid();
		}
		private function drawGrid():void 
		{
			//对应画出空格子  以方便观测
			this.graphics.lineStyle(1);
			for (var i:int = 0; i <= Rows; i++) 
			{
				this.graphics.moveTo(0, conf.TILE_HEIGHT * i);
				this.graphics.lineTo(conf.TILE_WIDTH * Cols, conf.TILE_HEIGHT * i);
			}
			for (var j:int = 0; j <= Cols; j++) 
			{
				this.graphics.moveTo(conf.TILE_WIDTH * j, 0);
				this.graphics.lineTo(conf.TILE_WIDTH * j, conf.TILE_HEIGHT * Rows);;
			}
		}
		
	}

}