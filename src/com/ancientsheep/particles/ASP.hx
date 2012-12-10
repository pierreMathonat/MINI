package com.ancientsheep.particles;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.events.Event;
import nme.Lib;

class ASP 
{
	#if (flash)
	public static var screen:Bitmap = new Bitmap(new BitmapData(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, true, 0x00000000));
	#else
	public static var screen:Shape = new Shape();
	#end
}