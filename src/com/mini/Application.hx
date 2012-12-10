package com.mini;
import com.mini.actions.Input;
import com.mini.display.Display;
import haxe.FastList;
import nme.events.TimerEvent;
import nme.utils.Timer;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.StageQuality;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.Lib;

class AppEvent extends Event
{
	public static inline var RESIZE:String = "APP::RESIZED";
	public static inline var UPDATE:String = "APP::UPDATED";
	
	public function new (type:String, bubbles:Bool = false, cancelable:Bool = false)
	{
		super(type, bubbles, cancelable);
	}
	
}

class Application extends Sprite 
{
	public static var DEFAULT_FPS:Int = 60;
	public static var LOW_FPS:Int = 30;
	
	public static var CURRENT_FPS:Int;
	public static var STAGE:Stage;
	public static var CURRENT:Sprite;
		
	public static var input:Input;
	
	public static var debug:Bool = true;
	
	var fps:FPS;
	public static var TIMER:Timer;
	
	public static var UPDATE_LIST:List<Display> = new List<Display>();
	public static var RESIZE_LIST:List<Display> = new List<Display>();
	
	public static function registerForUpdate(display:Display):Void
	{
		UPDATE_LIST.remove(display);
		UPDATE_LIST.add(display);
	}
	
	public static function unregisterForUpdate(display:Display):Void
	{
		UPDATE_LIST.remove(display);
	}
	
	public static function registerForResize(display:Display):Void
	{
		RESIZE_LIST.remove(display);
		RESIZE_LIST.add(display);
	}
	
	public static function unregisterForResize(display:Display):Void
	{
		RESIZE_LIST.remove(display);
	}
	
	public function new() 
	{
		super();
		CURRENT = Lib.current;
		addEventListener(Event.ADDED_TO_STAGE, init);
		//trace("APP::CREATED");
	}
		
	function init(e):Void
	{
		//trace("APP::INIT");
		
		STAGE = Lib.current.stage;
				
		STAGE.addChild(input = new Input());
		
		CURRENT_FPS = DEFAULT_FPS;
		
		fps = new FPS();
		if (debug) STAGE.addChild(fps);
		
		STAGE.scaleMode = StageScaleMode.NO_SCALE;
		
		Screen.resize();
		
		if (Screen.device == Screen.DEV_COMPUTER) resize(null);
		
		STAGE.addEventListener(Event.RESIZE, resize);
		CURRENT.addEventListener(Event.ENTER_FRAME, update);
		CURRENT.addEventListener(Event.REMOVED_FROM_STAGE, dispose);

	}
	
	function initStageQuality():Void {
		if (Screen.bitmapSmoothing)
			STAGE.quality = StageQuality.MEDIUM;
		else
			STAGE.quality = StageQuality.LOW;
	}
	
	function updateStageQuality(Quality:StageQuality):Void {
		if (!Screen.bitmapSmoothing)
			STAGE.quality = StageQuality.LOW;
		else 
			STAGE.quality = Quality;
	}
	
	function updateFrameRate():Void {
		STAGE.frameRate = CURRENT_FPS;
		fps.reset();
	}
	
	function resize(e:Event):Void
	{
		if(e!=null)e.stopImmediatePropagation();
		
		Screen.resize();
		
		if (Screen.supportedAspectRatio)
			for (o in RESIZE_LIST) o.resize();
		
		if (!Screen.resizable)
			STAGE.removeEventListener(Event.RESIZE, resize);
	}
	
	function update(e:Event):Void
	{
		e.stopImmediatePropagation();
		
		fps.update();
		
		for (o in UPDATE_LIST) o.update();
		
		input.update();
		
		manageFPS();
	}
	
	function manageFPS():Void {
		if (CURRENT_FPS == DEFAULT_FPS && fps.fps < 25) {
			CURRENT_FPS = LOW_FPS;
			updateFrameRate();
			updateStageQuality(StageQuality.LOW);
		}else if(CURRENT_FPS==LOW_FPS && fps.maxFPS > 2) {
			CURRENT_FPS = DEFAULT_FPS;
			updateFrameRate();
			updateStageQuality(StageQuality.MEDIUM);
		}
	}
	
	function dispose(e):Void
	{
		CURRENT.removeEventListener(Event.ENTER_FRAME, update);
		CURRENT.removeEventListener(Event.REMOVED_FROM_STAGE, dispose);
		STAGE.removeEventListener(Event.RESIZE, resize);
	}
}