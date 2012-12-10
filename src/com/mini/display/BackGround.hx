package com.mini.display;
import com.mini.Application;
import com.mini.Screen;
import nme.display.Shape;


class BackGround extends Display
{

	public function new()
	{
		
		super();
		ListenForResize = true;
		Application.STAGE.addChildAt(this,0);
	}
	
	override private function init(e):Dynamic 
	{
		super.init(e);
		resize();
	}
	
	override public function resize():Void 
	{		
		graphics.clear();
		graphics.beginFill(0x000000);
		graphics.drawRect(0,0,Screen.screenW,Screen.screenH);
	}
}