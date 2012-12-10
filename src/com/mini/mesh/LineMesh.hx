package com.mini.mesh;
import com.mini.Utils;
import nme.geom.Point;
import com.mini.mesh.Mesh;

class LPoint extends Mesh
{	
	var tickness:Float;
	
	public var next:LPoint = null;
	public var prev:LPoint = null;
	
	public var v0:Vertice;
	public var v1:Vertice;
	public var v2:Vertice;
	public var v3:Vertice;
	public var t0:Triangle;
	public var t1:Triangle;
	
	public var size:Float;
	public var angle:Float;
	
	public function new(buffer:BUFFER, _x:Float, _y:Float, _size:Float)
	{
		super(buffer);
		x = _x;
		y = _y;
		size = _size;
		buildGeom();
	}
	override private function buildGeom():Void 
	{
		addVert(v0 = new Vertice(- size, 0, 0, 1));
		addVert(v1 = new Vertice( size, 0, 1, 1));
		addVert(v2 = new Vertice(- size, 0, 0, 0));
		addVert(v3 = new Vertice( size, 0, 1, 0));	
	}
	
	public inline function build():Void
	{
		rotation = angle = Utils.angle(prev.x, prev.y, x, y) + 90;
		addTri(t0 = new Triangle(prev.v3, v0, prev.v2));
		addTri(t0 = new Triangle(prev.v3, v1, v0));
	}
}

class LineMesh
{
	
	public var buffer:BUFFER;
	public var points:LPoint=null;
	public var numPoints:Int;
	public var size:Float;
	
	public function new(_buffer:BUFFER)
	{
		buffer = _buffer;
		points = null;
		numPoints = 0;
		size = 10;
	}
	
	public function addPoint(_x:Float,_y:Float ):Void
	{
		var p = new LPoint(buffer,_x, _y, size);
		p.prev = points;
		if (points != null) {
			points.next = p;
			p.build();
		}
		points = p;
		numPoints++;
	}
	
	public function removePoint(v:LPoint):Void
	{
		var p = points;
		while (p!=null) {
			if (p == v) {
				if (p.next!=null) p.next.prev = p.prev;
				if (p.prev!=null) p.prev.next = p.next;
				p.clear();
				numPoints--;
			}
			p = p.prev;
		}
	}
	
	public function update():Void
	{
		var p = points;
		
		while (p != null) {	
			p.scaleX *= .8;
			if (p.scaleX < .1) removePoint(p);
			p = p.prev;
		}
	}
}