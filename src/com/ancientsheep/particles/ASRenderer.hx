package com.ancientsheep.particles;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BlendMode;
import nme.display.DisplayObject;
import nme.display.Shape;
import nme.display.Sprite;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.display.Graphics;
import nme.display.Tilesheet;
import nme.display.BitmapData;
import nme.geom.Point;
import nme.Lib;

class ASRenderer {
	
	public var rect:Rectangle;
	var add_blend:Bool;
	
	#if (flash)
	
	public var texture:BitmapData;
	public var m:Matrix;
	public var transform:ColorTransform;
	public var screen:Bitmap;
	public var owner:ASParticleSystem;
	var ox:Float;
	var oy:Float;
	var graphics:Graphics;
	
	
	inline public function new(bmd:BitmapData, asp:ASParticleSystem):Void {
		owner = asp;
		screen = new Bitmap(new BitmapData(asp.BUFFER_W,asp.BUFFER_H, true, 0x00000000));
		add_blend = asp.addBlendMode;
		asp.addChild(screen);
		
		graphics = asp.graphics;
		
		rect = new Rectangle(0, 0, bmd.width, bmd.height);
		screen.blendMode = add_blend?BlendMode.ADD:BlendMode.NORMAL;
		m = new Matrix();
		transform = new ColorTransform();
		texture = bmd;
	
	#else
	
	public var flags:Int; 
	public var drawList:Array<Float>;
	public var index:Int = 0;
	public var tilesheet:Tilesheet;
	public var screen:Graphics;
	
	inline public function new(bmd:BitmapData, asp:ASParticleSystem):Void {	
		screen = asp.graphics;
		add_blend = asp.addBlendMode;
		rect = new Rectangle(0, 0, bmd.width, bmd.height);
		flags = Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_ALPHA | Tilesheet.TILE_RGB | (add_blend?Tilesheet.TILE_BLEND_ADD:Tilesheet.TILE_BLEND_NORMAL);
		drawList = new Array<Float>();
		tilesheet = new Tilesheet(bmd);
		tilesheet.addTileRect(rect, new Point(bmd.width >> 1, bmd.height >> 1));
	
	#end
	
		
			
	}

	inline public function initRender():Void {
		
		#if (flash)
		
		ox = -(owner.bounds.x);
		oy = -(owner.bounds.y);
		screen.x = owner.bounds.x; screen.y = owner.bounds.y;
		
		screen.bitmapData.lock();
		screen.bitmapData.fillRect(screen.bitmapData.rect, 0x000000);
		
		#else
		
		index = 0;
		screen.clear();
		
		#end
	}
	
	inline public function renderParticles(particles:Array<ASParticle>):Void {
		
		initRender();
		var half = (rect.width * .5);
		
		for (particle in particles) {
			
		#if (flash)
		
		m.identity();
		transform.blueMultiplier = particle.color.b;
		transform.redMultiplier = particle.color.r;
		transform.greenMultiplier = particle.color.g;
		transform.alphaMultiplier = particle.color.a;
		var scale = (particle.scale / rect.width);
		m.translate(-half, -half);
		m.rotate(particle.rotation);m.scale(scale, scale);
		m.translate(particle.pos.x+ox, particle.pos.y+oy);
		
		//graphics.beginBitmapFill(texture, m, false);
		//graphics.drawRect(particle.pos.x-rect.width/2, particle.pos.y-rect.height/2, rect.width, rect.height);
		screen.bitmapData.draw(texture, m, transform, add_blend?BlendMode.ADD:BlendMode.NORMAL);
		//graphics.beginFill(transform.color, particle.color.a);
		//graphics.drawRect(particle.pos.x, particle.pos.y, particle.scale,particle.scale);
		}
		screen.bitmapData.unlock();
		//graphics.clear();
		//graphics.beginFill(0xFF0000, .5);
		//graphics.drawRect(owner.bounds.x, owner.bounds.y, owner.bounds.width, owner.bounds.height);
		
		#else
		
		drawList[index ++] = particle.pos.x;
		drawList[index ++] = particle.pos.y;
		drawList[index ++] = 0;
		drawList[index ++] = particle.scale/rect.width;
		drawList[index ++] = particle.rotation;
		drawList[index ++] = particle.color.r;
		drawList[index ++] = particle.color.g;
		drawList[index ++] = particle.color.b;
		drawList[index ++] = particle.color.a;	
		
		
		}
		
		var dif = drawList.length - index;
		if (dif != 0) drawList.splice(index, dif);
		tilesheet.drawTiles(screen, drawList, true, flags);
		
		#end
		
	}
	
	public function destroy():Void {
		#if (flash)
		screen.bitmapData.dispose();
		screen = null;
		#end
	}
}