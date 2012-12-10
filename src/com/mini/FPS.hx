package com.mini;
import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;

/**
 * ...
 * @author pierre
 */

class FPS extends TextField
{

	public function new() 
	{
		super();
		x = 10;
		y = 10;
		defaultTextFormat = new TextFormat("Verdana", 12, 0xFFFFFF, true);
		reset();
	}
	
	public var fps:Int=0;
	var startTime:Int=-1;
	var currentFrame:Int=0;
	
	public function reset():Void {
		fps = Application.CURRENT_FPS-1;
		startTime = -1;
		currentFrame = 0;
		maxFPS = 0;
	}
	
	public var maxFPS:Int;
	
	public function update():Void {
		var t = Lib.getTimer();
		
		if (startTime == -1) startTime = t;
		
		currentFrame++;
		
		if (t - startTime >= 1000)
		{
			fps = currentFrame;
			if (fps >= Application.CURRENT_FPS - 1) {
				maxFPS++;
			}else {
				maxFPS = 0;
			}
			currentFrame = 0;
			startTime = t;
		}
		
		text = "FPS::"+fps+"/"+Application.CURRENT_FPS;
	}
	
}