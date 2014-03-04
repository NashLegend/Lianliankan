package control 
{
	import config.conf;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import MyEvent.llkEvent;
	
	/**
	 * ...
	 * @author IJUST
	 */
	public class TimerBar extends Sprite 
	{
		//这个是用做倒计时的  时间达到后游戏失败
		private var bar:Sprite = new Sprite();
		private var timer:Timer;
		public function TimerBar(tick:uint) 
		{
			timer = new Timer(1000, tick);
			timer.addEventListener(TimerEvent.TIMER, Tick);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, Timeout);
			addEventListener(Event.ADDED_TO_STAGE, startTimer);
			addEventListener(Event.REMOVED_FROM_STAGE, removed);//处理删除事件
			initbar();
		}
		
		private function initbar():void 
		{
			//画一个矩形以直观地观测时间  
			bar.graphics.beginFill(0xFFFF00);
			bar.graphics.drawRect(0, 0, 100, conf.TimerBarHeight);
			bar.graphics.endFill();
			addChild(bar);
		}
		private function startTimer(e:Event):void 
		{
			timer.start();
		}
		private function Tick(e:TimerEvent):void 
		{
			//随着时间的进行  矩形的长度不断变小  
			bar.scaleX = 1-(timer.currentCount / timer.repeatCount);
		}
		private function Timeout(e:TimerEvent):void
		{
			//当达到时间后，用一个全局静态常量llkEvent.GameEvent派发事件  ，派发的事件可以在主函数中侦听到
			llkEvent.GameEvent.dispatchEvent(new Event(llkEvent.TimeOut));
		}
		private function removed(e:Event):void 
		{
			//被从舞台删除后要停止计时器并删除侦听
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, Timeout);
			timer.removeEventListener(TimerEvent.TIMER, Tick);
			removeEventListener(Event.ADDED_TO_STAGE, startTimer);
			removeEventListener(Event.REMOVED_FROM_STAGE, removed);
		}
	}

}