package com.font;
import com.mini.Msprite;
import flash.geom.Point;
import haxe.FastList;
import nme.Assets;
import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;


class MFont extends Msprite
{
	var size:Float;
	var letterSpacing:Float;

	#if(flash)
	
	var _buffer:BitmapData;
	var _texture:Array<BitmapData>;
	
	#else
	
	var _tilesheet:Tilesheet;
	var _texture:BitmapData;
	var _drawData:Array<Float>;
	var _drawPos:Int = 0;
	
	#end
	
	var _rects:Array<Rectangle>;
	
	public var text(default,setText):String;
	
	var _field:TextField;
	var _format:TextFormat;
	
	var code:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890 /=;,.%&()<>$*-_";
	
	
	public function new(font:Font,_size:Float = 16) 
	{
		super();
		
		size = _size;
		letterSpacing = 10;
		
		_format = new TextFormat(font.fontName, size, 0xFFFFFF);

		
		_field = new TextField();
		_field.defaultTextFormat = _format;
		_field.embedFonts = true;
		
		pixelize(size);
		
	}
	
	
	public function pixelize(size:Float):Void {
		
		_format.size = size;
		_field.defaultTextFormat = _format;
		_field.text = code;

		_rects = new Array<Rectangle>();
		
		#if (flash)
			
			_texture = new Array<BitmapData>();
			
		#else
			_texture = new BitmapData(Std.int(_field.textWidth)+code.length*4, Std.int(size)+4, true, 0x00000000);
			_tilesheet = new Tilesheet(_texture);
			_drawData = new Array<Float>();
		#end
		
		
		var x:Float = 0;
		for (i in 0...code.length) {
			_field.text = code.charAt(i);
			var b = new Rectangle(x,0,Std.int(_field.textWidth)+4,size+4);
			_rects.push(b);
			
			#if (flash)
			
			var bm = new BitmapData(Std.int(b.width)+2, Std.int(b.height)+2, true, 0x00000000);
			bm.draw(_field);
			_texture.push(bm);
			
			#else
			
			_texture.draw(_field, new Matrix(1, 0, 0, 1, x));
			_tilesheet.addTileRect(b);
			
			#end
			
			x += b.width;
		}
	}
	
	function setText(_text:String):String {
		text = _text;
		_parsedText = new Array<Char>();
		
		
		var colors = text.split("<color>");
		var charColors:Array<Int> = new Array<Int>();
		
		var i = 1;
		text = "";
		while(i < colors.length) {
			var _color:Int = Std.parseInt(colors[i]);
			var _text:String = colors[i + 1];
			
			trace(_color);
			var D = _text.split("\n");
			
			for (data in D) {
				for (c in 0...data.length) {
					charColors.push(_color);
				}
			}
			
			text += colors[i + 1];
			i += 2;
		}
		
		var lines = text.split("\n");
		
		var x:Float = 0;
		var y:Float = 0;
		
		var bufferW:Float = 0;
		var bufferH:Float = 0;
		
		var i = 0;
		
		for (line in lines) {
			for (c in 0...line.length) {
				var id = code.indexOf(line.charAt(c));
				_parsedText.push(new Char(id, x, y, 1,charColors[i++])); 
				x += _rects[id].width;
			}
			if (x > bufferW) bufferW = x;
			x = 0;
			y += _rects[0].height;
		}
		
		if (y > bufferH) bufferH = y;
		
		#if (flash)
		prepareBuffer(bufferW, bufferH);
		#end
		
		trace("parsed");
		render();
		
		return _text;
	}
	
	var _parsedText:Array<Char>;

	function prepareBuffer(W:Float, H:Float):Void {
		#if(flash)
		if (W == 0 || H == 0) return;
		if (_buffer != null) {
			if (Std.int(W) <= _buffer.width && Std.int(H) <= _buffer.height) {
				return;
			}else {
				_buffer.dispose();
			}
		}
		_buffer = new BitmapData(Std.int(W), Std.int(H), true, 0x000000);
		bitmap.bitmapData = _buffer;
		#end
	}
	
	function render():Void {
		
		#if(flash)
		var m:Matrix = new Matrix();
		var ct:ColorTransform = new ColorTransform();
		
		#else
		
		_drawPos = 0;
		
		#end
		
		for ( c in _parsedText) {
			
			#if (flash)
			
			m.identity();
			m.tx = c.x; m.ty = c.y;
			m.scale(c.size, c.size);
			ct.redMultiplier = c.r/255;
			ct.greenMultiplier = c.g/255;
			ct.blueMultiplier = c.b/255;
			
			_buffer.draw(_texture[c.id], m, ct);
			
			#else
			
			_drawData[_drawPos++] = c.x;
			_drawData[_drawPos++] = c.y;
			_drawData[_drawPos++] = c.id;
			_drawData[_drawPos++] = c.size;
			_drawData[_drawPos++] = c.r/255;
			_drawData[_drawPos++] = c.g/255;
			_drawData[_drawPos++] = c.b/255;
			
			#end
		}
		
		#if (!flash)
		
		_drawData.splice(_drawPos, _drawData.length - _drawPos);
		_tilesheet.drawTiles(graphics, _drawData,true,Tilesheet.TILE_SCALE|Tilesheet.TILE_RGB);
		
		#end
	}
}

class Char
{
	public var x:Float;
	public var y:Float;
	public var size:Float;
	public var color:Int;
	public var id:Int;
	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;
	
	public function new(_id:Int, _x:Float, _y:Float, _size:Float, _color:Int = 0xFFFFFF) {
		id = _id; x = _x; y = _y; size = _size; color = _color;
		parseColor();
		
	}
	
	function parseColor():Void {
		r = (color >>16 & 0xFF);
		g = (color >>8 & 0xFF);
		b = (color & 0xFF);
	}
}