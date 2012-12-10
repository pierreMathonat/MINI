package com.engine.core ;

	import com.engine.core.tilesheet.TilesheetBatch;
	import nme.display.Bitmap;
	import nme.display.BitmapData;
	import nme.geom.Point;
	import nme.geom.Rectangle;
	import com.engine.utils.BMath;
	import nme.geom.Matrix;

	class Graphic implements Iobject
	{
		private var	_GUI:Bool;
		private var _flipped:Bool;

		private var _x:Int;
		private var _y:Int;
		private var _width:Int;
		private var	_height:Int;
		
		private var	_source:BitmapData;		
		private var _sourceW:Int;
		private var _sourceH:Int;
		private var	_Tcolumns:Int;
		private var	_Trows:Int;
		
		private var	_point:Point;
		private var	_copyRect:Rectangle;
		private var	_cam:Cam;
		
		private var batch:TilesheetBatch;
		private var tiles:Array<Int>;
		private var Id:Int;
		
		public var visible:Bool;
		
		public function new(x:Int=0,y:Int=0,width:Int=0,height:Int=0,GUI:Bool=false,_visible:Bool=true) 
		{			
			_x = x;
			_y = y;
			_width = width;
			_height = height;
			visible = _visible;
			_GUI = GUI;
			
			_point = new Point();
			_copyRect = new Rectangle();
			_cam = Engine.cam;
		}
		
		private function initBatch():Void {
			batch = BatchRender.add(_source);
		}
		
		private function updateBatch():Void {
			tiles = batch.autoSplice(_width, _height);
		}
		
		public function loadGraphic(pix:BitmapData, flipped:Bool = false):Void {
			_sourceW = pix.width;
			_sourceH = pix.height;
			_flipped = flipped;
						
			if (_flipped) loadFlipped(pix);
			else _source = pix;
			
			initBatch();
			
			resize(_sourceW, _sourceH);
			updateBatch();
		}
		
		private function loadFlipped(pix:BitmapData):Void {
/*			var key:String = Cache.getKey(pix) + "flipped";
			if (Cache.checkBitmap(key)) {
				_source = Cache.addBitmap(key);
				return;
			}
			var m:Matrix = new Matrix();
			var pix2:BitmapData=new BitmapData(pix.width*2,pix.height,true,0x000000);
			m.scale( -1, 1);
			m.translate(pix2.width, 0);
			pix2.draw(pix);
			pix2.draw(pix,m);
			_source = Cache.addBitmap(key, pix2);
			pix2.dispose();*/
		}
		
		public function update():Void {}
		public function draw(x:Int, y:Int):Void{
			if (onScreen(x, y)) render();
		}
		
		public function render():Void {}
		
		public inline function onScreen(x:Int, y:Int):Bool {	
			_point.x = (x + _x);
			_point.y = (y + _y);			
			if (!_GUI) {
				_point.x -= (_cam.scrollx);
				_point.y -= (_cam.scrolly);
			}
			return BMath.AABBtoAABB(Std.int(_point.x), Std.int(_point.y), _width, _height, 0, 0, _cam.Width, _cam.Height);
		}
		
		public inline function resize(width:Int, height:Int):Void {
			_width = width;
			_height = height;
			_copyRect.width=width;
			_copyRect.height = height;
			_Trows = Std.int(_sourceH/_height);
			_Tcolumns = Std.int(_sourceW/_width);
		}
	}