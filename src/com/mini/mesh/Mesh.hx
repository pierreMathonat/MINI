package com.mini.mesh ;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.geom.ColorTransform;
import nme.Vector;

class BUFFER
{
	public var texture2D:BitmapData;
	var textureFx:BitmapData;
	
	var v_pos:Int=0;
	var t_pos:Int=0;
	
	#if (flash)	
	public var VERTEX_BUFF	:flash.Vector<Float>;
	public var TRIS_BUFF	:flash.Vector<Int>;
	public var UVS_BUFF		:flash.Vector<Float>;
	#else
	public var VERTEX_BUFF	:Array<Float>;
	public var TRIS_BUFF	:Array<Int>;
	public var UVS_BUFF		:Array<Float>;
	#end
	
	public var t_num:Int = 0;
	public var v_num:Int = 0;
	public var meshes		:Array<Mesh>;
	
	public function new(?tex:BitmapData)
	{
		texture2D 			= tex;
		meshes				= new Array<Mesh>();
		
		#if (flash)
		VERTEX_BUFF 		= new flash.Vector<Float>();
		UVS_BUFF 			= new flash.Vector<Float>();
		TRIS_BUFF			= new flash.Vector<Int>();				
		#else
		VERTEX_BUFF 		= new Array<Float>();
		UVS_BUFF 			= new Array<Float>();
		TRIS_BUFF			= new Array<Int>();	
		#end
	}
	
	inline function alloc3Int(a:Int, b:Int, c:Int):Void {
		TRIS_BUFF	[t_pos ++ ] = a;
		TRIS_BUFF	[t_pos ++ ] = b;
		TRIS_BUFF	[t_pos ++ ] = c;
	}
	
	inline function alloc4float(a:Float, b:Float, c:Float, d:Float):Void {
		v_pos += 2;
		VERTEX_BUFF	[v_pos - 2] = a;
		VERTEX_BUFF	[v_pos - 1] = b;
		UVS_BUFF	[v_pos - 2] = c;
		UVS_BUFF	[v_pos - 1] = d;
	}
	
	public inline function addMesh(m:Mesh):Void {
		meshes.push(m);
	}
	
	public inline function removeMesh(m:Mesh):Void {
		meshes.remove(m);
	}
	
	public inline function render(gfx:Graphics, smoothing:Bool=false, wireframe:Bool=false):Void
	{
		initBatch();
		
		for (m in meshes) {
			
			if (m.transformDirty) m.appendTransform();
			
			for (v in m.verts) {
				v.id = v_num++;
				alloc4float(v.tx, v.ty, v.uvx, v.uvy);
			}
			for (t in m.tris) {
				t_num++;
				alloc3Int(t.a.id, t.b.id, t.c.id);
			}
		}
		
		drawBatch(gfx,smoothing,wireframe);
	}
	
	inline function initBatch():Void
	{
		v_pos = t_pos = v_num = t_num = 0;
	}
	
	inline function drawBatch(gfx:Graphics, smoothing:Bool, wireframe:Bool):Void
	{
		var TRIS_TO_SPLICE = TRIS_BUFF.length - t_pos;
		var VERT_TO_SPLICE = VERTEX_BUFF.length - v_pos;
		
		if (TRIS_TO_SPLICE > 0) 
			TRIS_BUFF	.splice(t_pos, TRIS_TO_SPLICE);
		
		if (VERT_TO_SPLICE > 0)
			VERTEX_BUFF	.splice(v_pos, VERT_TO_SPLICE);
			UVS_BUFF	.splice(v_pos, VERT_TO_SPLICE);
		
		if (wireframe) gfx.lineStyle(1, 0xFFFFFF, .2);
		
		if (texture2D != null)
		{
			gfx.beginBitmapFill(texture2D, null, false, smoothing);
			gfx.drawTriangles(VERTEX_BUFF, TRIS_BUFF,UVS_BUFF);
		}
		else 
		{	
			gfx.drawTriangles(VERTEX_BUFF, TRIS_BUFF);
		}		
	}
}

class Vertice
{	
	public function new(X:Float, Y:Float, UVX:Float, UVY:Float) {
		
		x = X; 
		y = Y; 
		
		uvx = UVX; 
		uvy = UVY;
		
		tx = x;
		ty = y;
	}
	
	public var id:Int;
	public var x:Float;
	public var y:Float;
	public var uvx:Float;
	public var uvy:Float;
	
	public var tx:Float;
	public var ty:Float;
}


class Triangle
{
	
	public function new(A:Vertice,B:Vertice,C:Vertice) {
		a = A; 
		b = B; 
		c = C;
	}
	public var id:Int;
	public var a:Vertice;
	public var b:Vertice;
	public var c:Vertice;
}

class Trans2x2
{
	public var x:Float;
	public var y:Float;
	
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
	public static var PI180:Float = Math.PI/180;
	
	public function new():Void
	{
		x = y = 0;
		scale(1, 1);
		rotate(0);
	}
	
	public function scale(x:Float, y:Float):Void
	{
		a = x;
		d = y;
	}
	
	public function rotate(v:Float):Void
	{
		var f = v * PI180;
		b = Math.cos(f);
		c = Math.sin(f);
	}
	
	public inline function tranform(inV:Array<Vertice>):Void
	{
		for (v in inV) {
			var _x = v.x * a;
			var _y = v.y * d;
			v.tx = (_x * b - _y * c) + x;
			v.ty = (_x * c + _y * b) + y;
		}
	}
}

class Mesh
{
	public var transformDirty:Bool = true;
	
	var transform:Trans2x2;
	var _BUFFER:BUFFER;	
	
	public var verts:Array<Vertice>;
	public var tris:Array<Triangle>;
	
	public var x(default,setX):Float=0;
	public var y(default,setY):Float=0;
	public var scaleX(default,setScaleX):Float=1;
	public var scaleY(default,setScaleY):Float=1;
	public var rotation(default,setRotation):Float=0;
	
	public function new(buffer:BUFFER)
	{
		_BUFFER = buffer;
		buffer.addMesh(this);
		transform = new Trans2x2();
		
		verts = new Array<Vertice>();
		tris = new Array<Triangle>();
		
	}
	
	function buildGeom():Void
	{
		
	}
	
	public inline function addTri(t:Triangle):Triangle
	{
		tris.push(t);
		return t;
	}
	public inline function addVert(v:Vertice):Vertice
	{
		transformDirty = true;
		verts.push(v);
		return v;
	}
	public inline function delTri(t:Triangle):Triangle
	{
		tris.remove(t);
		return t;
	}
	public inline function delVert(v:Vertice):Vertice
	{
		transformDirty = true;
		verts.remove(v);
		return v;
	}
	public inline function clear():Void
	{
		_BUFFER.removeMesh(this);
		verts.splice(0, verts.length);
		tris.splice(0, tris.length);
	}
	
	//TRANSFORM
	//--------------------------------------------------
	inline function setX(v:Float):Float
	{
		transform.x = x = v;
		transformDirty = true;
		return x;
	}
	inline function setY(v:Float):Float
	{
		transform.y = y = v;
		transformDirty = true;
		return y;
	}
	inline function setRotation(v:Float):Float
	{
		if (v != rotation) {
			transform.rotate(v);
			transformDirty = true;
			rotation = v;			
		}
		return rotation;
	}
	inline function setScaleX(v:Float):Float
	{
		if (v != scaleX) {
			transform.a = scaleX = v;
			transformDirty = true;			
		}
		return scaleX;
	}
	inline function setScaleY(v:Float):Float
	{
		if (v != scaleY) {
			transform.d = scaleY = v;
			transformDirty = true;			
		}
		return scaleY;
	}
	
	public inline function appendTransform():Void
	{
		transform.tranform(verts);
		transformDirty = false;
	}
	
}

class Quad extends Mesh
{
	public var width:Float;
	public var height:Float;
	
	public var halfW:Float;
	public var halfH:Float;
	
	public function new(buffer:BUFFER,X:Float=0,Y:Float=0,Size:Float=64)
	{
		super(buffer);
		x = X; y = Y;
		width = height = Size;
		halfW = width * .5;
		halfH = height * .5;
		buildGeom();
	}
	
	override private function buildGeom():Void 
	{
		var v0 = addVert(new Vertice(-halfW, -halfH, 0, 0));
		var v1 = addVert(new Vertice(-halfW, halfH, 0, 1));
		var v2 = addVert(new Vertice(halfW, halfH, 1, 1));
		var v3 = addVert(new Vertice(halfW, -halfH, 1, 0));	
		var t1 = addTri(new Triangle(v0, v1, v2));
		var t2 = addTri(new Triangle(v2, v3, v0));
	}
}