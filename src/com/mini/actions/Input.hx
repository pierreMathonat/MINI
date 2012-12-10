package com.mini.actions;
import haxe.FastList;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.display.Graphics;
import nme.display.CapsStyle;
import nme.geom.Rectangle;

class Input extends Sprite
{	
	var cacheX:Int;
	var cacheY:Int;
	public static var startx:Int;
	public static var starty:Int;
	public static var mx:Int;
	public static var my:Int;

	public static var state:Int;
	public static var moving:Bool;
	public static var m(getPoint,null):Point;
	
	public static var drawMoves:Bool;
	
	public inline static var PRESSED:Int = 2;
	public inline static var JUST_PRESSED:Int = 1;
	public inline static var RELEASED:Int = -1;
	
	static var ACTIONS_LIST:List<Action> = new List<Action>();
	
	public static function registerAction(a:Action):Void
	{
		ACTIONS_LIST.remove(a);
		ACTIONS_LIST.add(a);
	}
	
	public static function unregisterAction(a:Action):Void
	{
		ACTIONS_LIST.remove(a);
	}
	
	static function getPoint():Point {
		return new Point(mx, my);
	}
	
	public function new() 
	{
		super();
		state = 0;
		drawMoves = true;
		Touch.graphics = graphics;
		
		Application.STAGE.addEventListener(MouseEvent.MOUSE_DOWN, mDown);
		Application.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, mMove);
		Application.STAGE.addEventListener(MouseEvent.MOUSE_UP, mUp);
		Application.STAGE.addChild(this);
	}
	
	function mDown(e:MouseEvent):Void {
		state = JUST_PRESSED;
		mx = Std.int(e.stageX);
		my = Std.int(e.stageY);
		startx = mx;
		starty = my;
		cacheX = mx; cacheY = my;
	}
	
	function mMove(e:MouseEvent):Void {
		moving = true;
		mx = Std.int(e.stageX);
		my = Std.int(e.stageY);
	}
	
	function mUp(e:MouseEvent):Void {
		state = RELEASED;
		mx = Std.int(e.stageX);
		my = Std.int(e.stageY);	
	}

	public function update():Void {		

		for (a in ACTIONS_LIST) {
			
			var b:Rectangle = a.Mtarget.getBounds(this);
			var e = { stageX:mx, stageY:my, buttonDown:pressed() };

			var oldTest:Bool = b.contains(cacheX, cacheY);
			
			if (b.contains(mx, my)) {
				if (a.LISTEN_MOUSE_DOWN && state == JUST_PRESSED) a.onMouseDown(e);
				if (a.LISTEN_MOUSE_UP && state == RELEASED) a.onMouseUp(e);
				if (moving) {
					if (a.LISTEN_MOUSE_MOVE)a.onMouseMove(e);
					if (a.LISTEN_MOUSE_OVER && !oldTest) a.onMouseOver(e);
				}
			}else {
				if (a.LISTEN_MOUSE_OUT && oldTest) a.onMouseOut(e);
			}
		}
		
		//trace("INPUT::UPDATE");
		if (state == JUST_PRESSED) state = PRESSED;
		if (state == RELEASED) state = 0;
		
		
		Touch.update();
		if (pressed()) {
			Touch.touches.push(new Touch(cacheX, cacheY, mx, my, 10, 0xFFFFFF));
		}
		cacheX = mx; cacheY = my;
		
		if (moving) moving = false;
	}
	
	public static function pressed():Bool {return state > 0;}
	public static function justPressed():Bool {return state == 1;}
	public static function released():Bool {return state < 0;}
}


//--------------------------------------------------------------------------------------------------------


class Touch
{
	public static var touches:Array<Touch> = new Array<Touch>();
	
	public var sX:Int;
	public var sY:Int;
	public var eX:Int;
	public var eY:Int;
	public var lineSize:Float;
	public var color:Int;
	public static var graphics:Graphics;
		
	public function new(_sX:Int, _sY:Int, _eX:Int, _eY:Int, _lineSize:Float, _color:Int) {
		touches.push(this);
		sX = _sX;	eX = _eX;
		sY = _sY;	eY = _eY;
		
		lineSize = _lineSize;
		color = _color;
	}
	
	inline public function getAngle():Float {
		return Math.atan2(eY - sY, eX-sX) * 180 / Math.PI;
	}
	
	public static function update():Void {
		
		graphics.clear();
		if (touches.length < 1) return;
		
		var t = touches[0];
		graphics.moveTo(t.sX, t.sY);
				
		for (touch in touches) {			
			graphics.lineStyle(touch.lineSize, touch.color, 1, false);
			graphics.lineTo(touch.eX, touch.eY);
			touch.lineSize-=.5;
			
			if (touch.lineSize < 1) {
				touches.remove(touch);
			}
		}
	}
}