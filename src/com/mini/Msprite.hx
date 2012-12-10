package com.mini;

import com.mini.display.Display;
import nme.events.Event;
import nme.events.TimerEvent;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.geom.Rectangle;
import nme.geom.Point;
import flash.Lib;
import com.mini.Application;

typedef Callback  = Void->Void;

class Anim {
	public var name:String;
	public var frames:Array<Int>;
	public var delay:Int;
	public var loop:Bool;

	public function new(_name:String, _frames:Array<Int>, _delay:Int,_loop:Bool ) {
		name = _name; frames = _frames; delay = _delay; loop = _loop;
	}
}

class Msprite extends Display
{	
	public var frame:Int=0;
	public var lastFrameTime:Int;
	public var animCursor:Int;
	public var back:Bool = false;
	public var onComplete:Callback;
	
	public var frames:Array<BitmapData>;
	public var bitmap:Bitmap;
	
	public var anims:Hash<Anim>;
	public var cur_anim:Anim;
	
	public var paused:Bool;
	public var looped:Bool;
	
	public var align:SizeFormat;
	public var paths:Array<String>;
	
	public function new() 
	{
		super();
		
		paths = new Array<String>();
		align= new SizeFormat();
		frames = new Array<BitmapData>();
		anims = new Hash<Anim>();
		bitmap = new Bitmap();
		anchor = new Point(0, 0);
		addChild(bitmap);
		paused = false;
		looped = false;
		_angle = rotation;
	}
	
	public function addFrame(bmd:BitmapData) {
		frames.push(bmd);
		if (bitmap.bitmapData == null) {
			frame = 0;
			drawFrame();
		}
	}
	
	public function clearFrames():Void {
		if (bitmap.bitmapData != null)
			bitmap.bitmapData=null;
		for (s in frames) 
			if(s!=null)s.dispose();
		frames.splice(0, frames.length);
	}
	
	var frameDirty:Bool = true;
	
	public function setFrame(f:Int) {
		frameDirty = true;
		lastFrameTime = Lib.getTimer();
		frame = f;
	}
	
	inline function drawFrame():Void {
		var bmd = frames[frame];
		if (bmd != null) {
			bitmap.bitmapData = bmd;
			bitmap.smoothing = Screen.bitmapSmoothing;
		}
		frameDirty = false;
	}
	
	public function addAnim(name:String, frames:Array<Int>, delay:Int=40,loop=true):Void {
		anims.set(name, new Anim(name, frames, delay,loop));
	}
	
	public function setAnim(name:String,tick:Int=1):Void {
		if (anims.exists(name)) {
			cur_anim = anims.get(name);
			if (tick > 0) {
				back = false;
				animCursor = 0;
			}else {
				back = true;
				animCursor = cur_anim.frames.length - 1;
			}			
			setFrame(cur_anim.frames[animCursor]);
		}
	}
	
	override public function update():Void {
		if (frameDirty) drawFrame();
		if (paused) return;
		if (frames.length>1) {
			tick(back?-1:1);
		}
	}

	inline function tick(val:Int = 1):Void {
		if (cur_anim != null && Lib.getTimer() - lastFrameTime > cur_anim.delay) {
			var animlength = cur_anim.frames.length - 1;
			animCursor+=val;
			if (val>0 && animCursor > animlength) {
				looped = true;
				if (cur_anim.loop) {
					animCursor = 0;
				}else {
					animCursor = animlength;
				}
			}else if (val<0 && animCursor < 0) {
				looped = true;
				if (cur_anim.loop) {
					animCursor = animlength;
				}else {
					animCursor = 0;
				}
			}else {
				looped = false;
			}
			setFrame(cur_anim.frames[animCursor]);
			if (looped && onComplete != null) {
				onComplete();
				onComplete = null;
			}
		}
	}

	public function prevFrame():Void {if(frame>0)setFrame(frame-1);}
	public function nextFrame():Void {if(frame<frames.length-1)setFrame(frame+1);}
	
	public function play(?anim:String, tick:Int = 1):Msprite { 
		if (anim != null) setAnim(anim, tick); 
		paused = false;
		return this; 
	}
	public function pause(?anim:String, tick:Int = 1):Msprite { 
		if (anim != null && cur_anim.name != name) setAnim(anim, tick); 
		paused = true; 
		return this; 
	}
	public function reverse():Msprite { back = back?false:true; return this; }
	
	override public function dispose():Void {
		clear();
		super.dispose();
	}
	
	public inline function clear():Void
	{
		anims=null;
		clearFrames();
		while (numChildren > 0) {
			var s = removeChildAt(0);
			if (Std.is(s, Display)) cast(s, Display).dispose();
		}		
	}
	
	public function scale(v:Float):Void {
		scaleX = scaleY = v;
	}
	
	public function scaleAndCenter(v:Float):Void {
		scale(v);
		centerX();
	}
	
	public function centerX() {x = parent.width / 2 - width / 2;}
	public function centerY() {y = parent.height / 2 - height / 2;}
	public function alignLeft() {x = 0;}
	public function alignRight() {x = parent.width - width;}
	public function alignTop() {y = 0;}
	public function alignBottom() { y = parent.height - height; }	
	
	public function sceneAlign(left:Float, right:Float) {
		
		switch(align.alignMode) {
			case SizeFormat.ALIGN_NONE:return;
			case SizeFormat.ALIGN_LEFT:
				x = left+width*align.percentMargin;
			case SizeFormat.ALIGN_RIGHT:
				x = right - width - width*align.percentMargin;
		}
	}
}

class SizeFormat {
	public inline static var ALIGN_NONE:Int = 0;
	public inline static var ALIGN_LEFT:Int = 1;
	public inline static var ALIGN_RIGHT:Int = 2;
	public inline static var ALIGN_CENTER:Int = 3;
	
	public var alignMode:Int = ALIGN_NONE;
	public var percentMargin:Float = .2;
	public var tolerance:Float = 50;
	
	public var oldx:Float = 0;
	
	public function new() {}
}