package com.mini.psd;
import nme.geom.Rectangle;

class Camera extends Rectangle {
	
	var dirty:Bool;
	var scene:PSDscene;
	var rect:Rectangle;
	
	public function new(s:PSDscene, a:Float,b:Float,c:Float,d:Float) {
		scene = s;
		super(a, b, c, d);
	}
	
	public function set(xa:Float, ya:Float, widtha:Float, heighta:Float):Void 
	{
		x = xa; y = ya;
		width = widtha;
		height = heighta;
		updateRect();
	}
	
	public function updateRect():Void {
		scene.scrollRect = this;
	}
}