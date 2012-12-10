package com.mini.psd;
import com.mini.Application;
import nme.geom.Rectangle;
import nme.display.BitmapData;
import com.eclecticdesignstudio.motion.Actuate;
import nme.geom.Matrix;

class PSDscene extends PSD
{
	public var bounds:Camera;
	public var rect:Rectangle;
	public var resizeMode:Int;
	var pixelRatio:Float;
	
	public function new() {
		
		super();
		ListenForResize = true;
		resizeMode = ResizeMode.FIT_VERTICAL;	
	}
	
	override public function load(f:String, xml:String ):Void 
	{
		super.load(f, xml);
		rect = new Rectangle(0, 0, realWidth, realHeight);
		bounds = new Camera(this, 0, 0, realWidth, realHeight);
		bounds.updateRect();
		
		resize();
	}
	
	override public function update():Void {if(!paused)super.update();}
	
	function aspectRatio():Void {
		
		rect.height = realHeight;
		rect.width = realWidth;
		
		switch(resizeMode) {
			case ResizeMode.FIT_VERTICAL:
				var _width = rect.height * Screen.aspectRatio;
				var _x = (_width - rect.width) / 2;
				bounds.set( -_x, 0, _width, rect.height);
			case ResizeMode.FIT_HORIZONTAL:
				var _height = rect.width / Screen.aspectRatio;
				var _y = (_height - rect.height) / 2;
				bounds.set(0, -_y, rect.width, _height);
			case ResizeMode.FIT_DISTORT:
				bounds.set(0, 0, rect.width, rect.height);
		}
	}
	
	override public function resize():Void {
		
		if (numChildren < 1 || bounds == null) return;
		
		paused = true;

		switch(resizeMode) {
			case ResizeMode.FIT_VERTICAL:
				resizeAssets(Screen.screenW / originalW);
				aspectRatio();
				scaleX = scaleY = Screen.screenH / rect.height;
				
			case ResizeMode.FIT_HORIZONTAL:
				resizeAssets(Screen.screenW / originalW);
				aspectRatio();
				scaleX = scaleY = Screen.screenW / rect.width;
				
			case ResizeMode.FIT_DISTORT:
				resizeAssets(Screen.screenW / originalW);
				scaleX = Screen.screenW / rect.width;
				scaleY = Screen.screenH / rect.height;
				aspectRatio();
		}
		
		alignChildren();
		paused = false;
	}
	
	function alignChildren():Void {
		for (i in 0...numChildren) {
			var e = getChildAt(i);
			if (Std.is(e, Msprite)) {
				cast(e, Msprite).sceneAlign(bounds.x,bounds.right);
			}
		}
	}
	
	public function stopTweens():Void {
		for (e in elems) {
			Actuate.stop(e);
		}
		for (i in 0...numChildren) {
			var child = getChildAt(i);
			Actuate.stop(child);
		}
	}
	
	public function pauseTweens():Void {
		for (e in elems) {
			Actuate.pause(e);
		}
		for (i in 0...numChildren) {
			var child = getChildAt(i);
			Actuate.pause(child);
		}
	}
	
	public function resumeTweens():Void {
		for (e in elems) {
			Actuate.resume(e);
		}
		for (i in 0...numChildren) {
			var child = getChildAt(i);
			Actuate.resume(child);
		}
	}
	
	public function resizeAssets(pxRatio:Float) {
		
		if (pxRatio >= 1) pxRatio = 1;
		else if (pxRatio < 1) pxRatio = .5;
		if (pxRatio > 1 || pxRatio == cur_pxRatio) return;
		
		cur_pxRatio = pxRatio;
		
		freeMemory();
		loadAssets();
		//trace("resized : "+ folder + " || " +cur_pxRatio+";"+realWidth+";"+realHeight);
	}
	
	inline public function resizeBitmapData(src:BitmapData, pxRatio:Float):BitmapData {
		var w = Std.int(src.width * pxRatio);
		var h = Std.int(src.height * pxRatio);
		if (w < 1 || h < 1) return src
		else {
			var bmd:BitmapData = new BitmapData(w, h, true, 0x00000000);
			var m = new Matrix();
			m.scale(pxRatio, pxRatio);
			bmd.draw(src, m,null,null,null,true);
			src.dispose();
			return bmd;
		}
	}
	
	inline public function freeMemory():Void {
		for (e in elems) {
			var b = e.bitmap.getBounds(e);
			e.drawRect(0xFFFFFF, 1, b.x, b.y, b.width, b.height);
			e.clearFrames();
		}
	}
	
	inline public function loadAssets():Void {
		for (e in elems) {
			var b = e.getBounds(e);
			e.graphics.clear();
			for (url in e.paths) {
				if (cur_pxRatio == 1) {
					e.addFrame(getBitmapData(url));
				}else {
					e.addFrame(resizeBitmapData(getBitmapData(url), cur_pxRatio));
				}
			}
			if (cur_pxRatio != 1) {
				e.bitmap.width=b.width;
				e.bitmap.height=b.height;
			}else {
				e.bitmap.scaleX = e.bitmap.scaleY = 1;
			}
		}
		initAnchors();
	}

}

class ResizeMode {
	public inline static var FIT_VERTICAL:Int = 0;
	public inline static var FIT_HORIZONTAL:Int = 1;
	public inline static var FIT_DISTORT:Int = 2;
}