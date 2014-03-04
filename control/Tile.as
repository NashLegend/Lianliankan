package control 
{
	import config.conf;
	import config.llkdata;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import MyEvent.llkEvent;
	
	/**
	 * ...
	 * @author IJUST
	 */
	public class Tile extends Sprite
	{
		public var seed:Number;//取一个随机数 用于将来打乱方块顺序
		//行和列以及类别  type不同则Tile的样式不同  具体由drawTile来实现
		public var Row:uint;
		public var Col:uint;
		public var Type:uint;
		public function Tile(type:uint) 
		{
			this.Type = type;
			seed = Math.random();
			drawTile(type);
			this.addEventListener(MouseEvent.CLICK, clickHandler);//处理点击事件
			this.addEventListener(Event.REMOVED_FROM_STAGE, removed);//处理被删除后的事件
		}
		private function drawTile(type:uint):void 
		{
			//画出边界  主要为了区分邻近的方块
			graphics.lineStyle(3,0x000000);
			graphics.beginFill(type);
			graphics.drawRect(0, 0, conf.TILE_WIDTH, conf.TILE_HEIGHT);
			graphics.endFill();
		}
		private function clickHandler(e:MouseEvent):void 
		{
			llkdata.CURRENT_TILE = this;//这个静态全局变量存储当前点击的方块
			llkEvent.GameEvent.dispatchEvent(new Event(llkEvent.TileClick));//用一个静态全局的事件来派发点击事件，以便可以在主函数中侦听到
		}
		private function removed(e:Event):void 
		{
			//删除侦听  释放内存
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(Event.REMOVED_FROM_STAGE, removed);
		}
	}

}