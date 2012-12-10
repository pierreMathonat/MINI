package com.mini.display;
import com.mini.Application;
import nme.events.Event;
import nme.geom.Point;


class Display extends nme.display.Sprite
{
	
	var ListenForResize:Bool=false;
	var ListenForUpdate:Bool=true;

	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
		addEventListener(Event.REMOVED_FROM_STAGE, remove);
	}
	
	function init(e)
	{
		if (ListenForUpdate) Application.registerForUpdate(this);
		if (ListenForResize) Application.registerForResize(this);
	}
	
	public function remove(e):Void 
	{	
		if (ListenForUpdate) Application.unregisterForUpdate(this);
		if (ListenForResize) Application.unregisterForResize(this);
	}
	
	public function dispose():Void
	{
		remove(null);
		removeEventListener(Event.REMOVED_FROM_STAGE, remove);
		removeEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	public function update():Void { }
	public function resize():Void { }

	
	
//----------------------------------------------------------------------------
// TRANSFORM HELPERS
//----------------------------------------------------------------------------
	
	var _angle:Float = 0;
	var _sizeX:Float = 1;
	var _sizeY:Float = 1;
	public var sizeX(getSizeX, setSizeX):Float;
	public var sizeY(getSizeY, setSizeY):Float;
	public var angle(getAngle, setAngle):Float;
	public var anchor:Point;
	
	//---------------------------------------------------------------
	
	function getAngle():Float {return rotation;}	
	function setAngle(v:Float):Float { 
		_angle = v; 	
		var a = _angle-rotation;
		var m = transform.matrix;
		var t = m.transformPoint(anchor);
		m.translate(-t.x, -t.y);
		m.rotate(a*(Math.PI/180));
		m.translate(t.x, t.y);
		transform.matrix = m;
		return _angle; 	
	}
	
	function getSizeX():Float { return _sizeX; }
	function setSizeX(v:Float):Float {
		_sizeX = v;
		var a = _sizeX / scaleX;
		updateSize(a, 1);
		return _sizeX;
	}
	function getSizeY():Float { return _sizeY; }
	function setSizeY(v:Float):Float {
		_sizeY = v;
		var a = _sizeY / scaleY;
		updateSize(1, a);
		return _sizeY;
	}
	
	inline function updateSize(x:Float,y:Float):Void {
		var m = transform.matrix;
		var t = m.transformPoint(anchor);
		m.translate( -t.x, -t.y);
		m.scale(x,y);
		m.translate(t.x, t.y);
		transform.matrix = m;
	}
	
	public function centerAnchor():Void
	{
		anchor.x = width * .5;
		anchor.y = height * .5;
	}
	
//----------------------------------------------------------------------------
// DRAWING HELPERS
//----------------------------------------------------------------------------	
	
	public function drawCircle(color:Int = 0xFFFFFF, alpha:Float = 1, a:Float, b:Float, c:Float):Void {
		graphics.beginFill(color, alpha);
		graphics.drawCircle(a,b,c);
		graphics.endFill();
	}
	
	public function drawRect(color:Int = 0xFFFFFF, alpha:Float = 1, a:Float, b:Float, c:Float, d:Float):Void {
		graphics.beginFill(color, alpha);
		graphics.drawRect(a, b, c, d);
		graphics.endFill();
	}
	
	public function fill(color:Int = 0xFFFFFF, alpha:Float = 1) {
		drawRect(color, alpha, 0, 0, width, height);
	}
}