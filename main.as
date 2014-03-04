package
{
	import config.conf;
	import config.llkdata;
	import config.vo;
	import control.Tile;
	import control.TileData;
	import control.TimerBar;
	import flash.display.Sprite;
	import flash.events.Event;
	import mission.Mission;
	import mission.MissionList;
	import MyEvent.llkEvent;
	
	/**
	 * ...
	 * @author IJUST
	 */
	public class main extends Sprite
	{
		//下面两个用来存放点击的要消除的两个方块
		public var preTile:Tile;//第一次点击的方块
		public var crtTile:Tile;//第二次点击的方块
		//棋盘
		public var board:Board;
		//倒计时
		public var bar:TimerBar;
		//点击数  用来判断方块为第一次还是第二次点击
		public var clicks:int = 0;
		//关卡信息   行数列数  方块种类数  倒计时时间  当前关卡级别
		public var rows:uint;
		public var cols:uint;
		public var numTypes:uint;
		public var time:uint;
		public var crtMission:uint = 0;
		//方块存放数组
		public var TileArray:Array = [];
		
		public function main()
		{
			//这里没有提供开始按钮  而是直接开始   若要添加开始按钮  点击按钮触发initMission即可
			initMission();
		}
		public function initMission():void
		{
			//添加侦听   均为全局侦听
			addListeners();
			//由关卡级别获得关卡信息  
			rows = (MissionList.MissionArray[crtMission] as Mission).rows;
			cols = (MissionList.MissionArray[crtMission] as Mission).cols;
			numTypes = (MissionList.MissionArray[crtMission] as Mission).numTypes;
			time = (MissionList.MissionArray[crtMission] as Mission).time;
			//初始化舞台
			initStage();
		}
		public function addListeners():void 
		{
			//添加侦听   均为全局侦听
			llkEvent.GameEvent.addEventListener(llkEvent.TileClick, TileClick);
			llkEvent.GameEvent.addEventListener(llkEvent.TimeOut, timeout);
		}
		public function initStage():void//初始化舞台
		{
			//添加倒计时和棋盘
			bar = new TimerBar(time);
			board = new Board(rows, cols);
			addChild(board);
			addChild(bar);
			bar.width = board.width;
			bar.x = board.x;
			bar.y = board.y + board.height;
			
			//初始化Tile数组  
			for (var i:int = 0; i < rows; i++)
			{
				var tmpArray:Array = new Array(cols);
				TileArray.push(tmpArray);
			}
			//添加方块
			addTiles();
		}
		public function addTiles():void
		{
			var pairs:uint = rows * cols / 2;//方块因为是成对出现的 所以 这里一次填充一对 填充次数为pairs;
			var tmpArray:Array = [];//临时存放方块的数组   此时数组是有序的  方块都相邻
			for (var i:int = 0; i < pairs; i++) 
			{
				//生成两个类型相同的Tile
				var type:uint = vo.picArray[int(Math.random()*numTypes)];
				var pair1:Tile = new Tile(type);
				var pair2:Tile = new Tile(type);
				tmpArray.push(pair1, pair2);
			}
			tmpArray.sortOn("seed");//因为Tile都有一个seed属性，为一个随机值   按seed排序即随机打乱顺序
			
			//将打乱顺序的数组填充到方块数组里
			for (var j:int = 0; j < tmpArray.length; j++) 
			{
				//从头开始填充 首先计算行和列 
				var ro:uint = j / cols;
				var co:uint = j % cols;
				var tmpTile:Tile = tmpArray[j];
				tmpTile.Row = ro;
				tmpTile.Col = co;
				tmpTile.x = co * conf.TILE_WIDTH;
				tmpTile.y = ro * conf.TILE_HEIGHT;
				board.addChild(tmpTile);
				board.DataArray[ro][co] = 1;
				TileArray[ro][co] = tmpTile;
			}
			tmpArray = [];
		}
		public function TileClick(e:Event):void 
		{
			//点击方块触发的事件 点击一次后clicks+1;
			clicks++;
			if (clicks%2==1)
			{
				//若为1则为第一个方块   存储为preTile
				preTile = llkdata.CURRENT_TILE;
			}
			else 
			{
				////若为0则为第二个方块   存储为crtTile，第二次点击后就要判断是否消除
				crtTile = llkdata.CURRENT_TILE;
				//首先将下面两个数据置为0，这样在judge函数里面容易进行判断
				board.DataArray[preTile.Row][preTile.Col] = 0;
				board.DataArray[crtTile.Row][crtTile.Col] = 0;
				
				if (judge()) 
				{
					//若符合删除条件  则删除
					removeTile();
				}
				else 
				{
					//否则将数据重新还原为1
					board.DataArray[preTile.Row][preTile.Col] = 1;
					board.DataArray[crtTile.Row][crtTile.Col] = 1;
				}
			}
		}
		//下面的这个函数用来判断是否符合消除条件
		public function judge():Boolean
		{
			//判断若再次点击的类型不同  直接返回false
			if (preTile.Type!=crtTile.Type) 
			{
				return false;
			}
			//判断若两次点击为同一个 直接返回false
			if (preTile.Row==crtTile.Row&&preTile.Col==crtTile.Col) 
			{
				return false;
			}
			
			//下面判断是否连通
			
			//若点击的两个方块都在边界上的话  则可以消除  返回true
			if (SameSide()) 
			{
				return true;
			}
			//若两个为同一行不同列  则取与两个方块同列的两列（包括自身）方块，遍历，每次取列中同行的A和B，若A和B能直接直线连通且A和B能与两个被点击的方块能分别直接直线连通 则表示被选中的两个方块相通
			//通过检测即返回true
			if (preTile.Row==crtTile.Row&&preTile.Col!=crtTile.Col) 
			{
				for (var i:int = 0; i < rows; i++) 
				{
					if (straightLink(new TileData(i,preTile.Col),new TileData (i,crtTile.Col))&&straightLink(new TileData(i,preTile.Col),new TileData(preTile.Row,preTile.Col))&&straightLink(new TileData(i,crtTile.Col),new TileData(crtTile.Row,crtTile.Col))) 
					{
						//都通过则连通
						return true;
					}
				}
			}
			//若两个为同一列不同行  则取与两个方块同行的两行（包括自身）方块，遍历，每次取列中同列的A和B，若A和B能直接直线连通且A和B能与两个被点击的方块能分别直接直线连通 则表示被选中的两个方块相通
			//通过检测即返回true
			if (preTile.Row!=crtTile.Row&&preTile.Col==crtTile.Col)
			{
				for (var j:int = 0; j < cols; j++) 
				{
					if (straightLink(new TileData(preTile.Row,j),new TileData(crtTile.Row,j))&&straightLink(new TileData(crtTile.Row,j),new TileData(crtTile.Row,crtTile.Col))&&straightLink(new TileData(preTile.Row,j),new TileData(preTile.Row,preTile.Col))) 
					{
						//都通过则连通
						return true;
					}
				}
			}
			//若行列都不同   取与两个同行的两行   与两个同列的两列 方块   即把上面两个判断联合起来判断 通过检测即返回true
			if (preTile.Row!=crtTile.Row&&preTile.Col!=crtTile.Col) 
			{
				for (var k:int = 0; k < rows; k++) 
				{
					if (straightLink(new TileData(k,preTile.Col),new TileData (k,crtTile.Col))&&straightLink(new TileData(k,preTile.Col),new TileData(preTile.Row,preTile.Col))&&straightLink(new TileData(k,crtTile.Col),new TileData(crtTile.Row,crtTile.Col))) 
					{
						//都通过则连通
						return true;
					}
				}
				
				for (var l:int = 0; l < cols; l++)
				{
					if (straightLink(new TileData(preTile.Row,l),new TileData(crtTile.Row,l))&&straightLink(new TileData(crtTile.Row,l),new TileData(crtTile.Row,crtTile.Col))&&straightLink(new TileData(preTile.Row,l),new TileData(preTile.Row,preTile.Col))) 
					{
						//都通过则连通
						return true;
					}
				}
			}
			//若上面均未通过则返回false
			return false;
		}
		public function SameSide():Boolean 
		{
			return ((crtTile.Row == preTile.Row) && (crtTile.Row == 0 || crtTile.Row == rows-1)) || ((crtTile.Col == preTile.Col) && (crtTile.Col == 0 || crtTile.Col == cols-1));
		}
		public function straightLink(tile1:TileData,tile2:TileData):Boolean
		{
			//检查两个位置是否可以直接相连  若从左到右  或者从上到下（包括起点和终点即tile1:TileData,tile2:TileData） board.DataArray[i][j]都等于0则表示在路径上没有方块 可以直线相连
			var beginIndex:uint = 0;//同一行或列的开始值
			var endIndex:uint = 0;//同一行或列的结束值
			if (tile1.Row==tile2.Row&&tile1.Col==tile2.Col) //若两者相等 即为同一个位置  直接返回true  其实可以直接if (tile1==tile2)
			{
				return true;
			}
			if (tile1.Row==tile2.Row) //若两个位置在同一行
			{
				//将较小的高为beginindex  较大的设置为endindex  然后遍历  
				if (tile1.Col<tile2.Col)
				{
					beginIndex = tile1.Col;
					endIndex = tile2.Col;
				}
				else 
				{
					endIndex = tile1.Col;
					beginIndex = tile2.Col;
				}
				for (var i:int = beginIndex; i <= endIndex ; i++) //遍历时包括要检测的两个点
				{
					if (board.DataArray[tile1.Row][i]!=0) //若其中有一个值不为0，即路径上有方块  则不通  返回false
					{
						return false;
					}
				}
			}
			else //否则即在同一列  同上
			{
				if (tile1.Row<tile2.Row) 
				{
					beginIndex = tile1.Row;
					endIndex = tile2.Row;
				}
				else 
				{
					endIndex = tile1.Row;
					beginIndex = tile2.Row;
				}
				for (var j:int = beginIndex; j <= endIndex ; j++)
				{
					if (board.DataArray[j][tile1.Col]!=0)
					{
						return false;
					}
				}
			}
			//若以上遍历都没有发现不通之处 表示可以直接连通 返回true
			return true;
		}
		public function removeTile():void
		{
			//删除选中的方块
			board.removeChild(TileArray[crtTile.Row][crtTile.Col]);
			board.removeChild(TileArray[preTile.Row][preTile.Col]);
			//删除数组数据
			board.DataArray[crtTile.Row][crtTile.Col] = 0;
			board.DataArray[preTile.Row][preTile.Col] = 0;
			TileArray[crtTile.Row][crtTile.Col] = null;
			TileArray[preTile.Row][preTile.Col] = null;
			//若已经完全清除所有方块
			if (isEmpty())
			{
				clearStage();
				nextMission();
			}
		}
		public function clearStage():void
		{
			//清除舞台上的元件  
			//若通关  则board.numChildren==0，若通关失败即超时  则board.numChildren不为0，所以要先删除元件
			while (board.numChildren)
			{
				board.removeChildAt(0);
			}
			//重置数组
			for (var i:int = 0; i < rows; i++) 
			{
				for (var j:int = 0; j < cols; j++) 
				{
					TileArray[i][j] = null;
				}
			}
			board.DataArray = [];
			TileArray = [];
			//删除倒计时
			removeChild(bar);
		}
		public function isEmpty():Boolean 
		{
			//检查是否数组已经为空  事实上可以通过计算清除次数而不是遍历数组这种笨办法来实现  
			for (var i:int = 0; i < rows; i++) 
			{
				for (var j:int = 0; j < cols; j++) 
				{
					if (board.DataArray[i][j]==1) //若有一个值为1则表示还没有完全清除   返回false
					{
						return false;
					}
				}
			}
			//通过检测  则返回true
			return true;
		}
		public function timeout(e:Event):void 
		{
			//超时后  清除舞台元件并结束游戏
			clearStage();
			endGame();
		}
		public function restartMission():void
		{
			//重新开始该关卡  这里并没有提供入口   可以自行添加重新开始按钮  点击后触发这个函数即可重新开始
			//清除可见元件
			clearStage();
			//初始化舞台（关卡数据已经初始化好 不必再次初始化）
			initStage();
		}
		public function nextMission():void
		{
			//准备进入下一关  关卡级别+1
			crtMission += 1;
			//如果已经达到最大关卡数量   游戏结束
			if (crtMission>=MissionList.MissionArray.length) 
			{
				endGame();
			}
			//否则进，初始化下一关
			else 
			{
				initMission();
			}
		}
		public function endGame():void 
		{
			//游戏结束，这里只做了一个简单处理 
			trace("End");
			return;
		}
		
	}

}