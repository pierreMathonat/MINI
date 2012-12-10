package com.mini;
import nme.display.GradientType;
import nme.display.Graphics;
import nme.Vector;
import nme.geom.Point;

class Segment
{
	public var start:Point;
	public var end:Point;
	public var control:Point;
		
	public function new(start:Point, end:Point, control:Point = null) 
	{
		this.start = start;
		this.end = end;
		this.control = control;
	}
		
	public function subdivide(k:Float):Segment
	{
		var _end:Point;
		if (control!=null)
		{
			var k1:Float = 1.0 - k;
			
			var _control:Point = new Point(
				k * control.x + k1 * start.x,
				k * control.y + k1 * start.y);
			
			var temp:Point = new Point(
				k * end.x + k1 * control.x,
				k * end.y + k1 * control.y);
				
			_end = new Point(
				k * temp.x + k1 * _control.x,
				k * temp.y + k1 * _control.y);
			
			return new Segment(start, _end, _control);
		}
		else
		{
			_end = new Point(
				start.x + k * (end.x - start.x),
				start.y + k * (end.y - start.y));
			return new Segment(start, _end);
		}
	}
		
	public function length():Float
	{
		if (control!=null)
		{
			// code credit: The Algorithmist
			// http://algorithmist.wordpress.com/2009/01/05/quadratic-bezier-arc-length/
			
			var ax:Float = start.x - 2*control.x + end.x;
			var ay:Float = start.y - 2*control.y + end.y;
			var bx:Float = 2 * control.x - 2 * start.x;
			var by:Float = 2 * control.y - 2 * start.y;
			var a:Float = 4 * (ax * ax + ay * ay);
			var b:Float = 4 * (ax * bx + ay * by);
			var c:Float = bx * bx + by * by;

			var abc:Float = 2 * Math.sqrt(a + b + c);
			var a2:Float  = Math.sqrt(a);
			var a32:Float = 2 * a * a2;
			var c2:Float  = 2 * Math.sqrt(c);
			var ba:Float  = b / a2;
			return (a32 * abc + a2 * b * (abc - c2) + (4 * c * a - b * b) 
			  * Math.log((2 * a2 + ba + abc) / (ba + c2))) / (4 * a32);
		}
		else return end.subtract(start).length;
	}
}

class Line 
{
	
	public var points:Array<Point>;
	public var radius:Float;
	public var closePath:Bool;
	public var thickness:Float;
	public var color:Int;
	var path:Array<Segment>;
	var dirty:Bool = false;
	
	public function new(_thickness:Float, _color:Int, _radius:Float = 50, _closePath:Bool = false ) 
	{
		radius = _radius;
		closePath = _closePath;
		color = _color;
		thickness = _thickness;
		points = new Array<Point>();
		path = new Array<Segment>();
		dirty = true;
	}
	
	public function addPoint(p:Point):Point {
		points.push(p);
		dirty = true;
		return p;
	}
	
	public function removePoint(p:Point):Point {
		points.remove(p);
		dirty = true;
		return p;
	}
	
	public function removeAll():Array<Point> {
		var result = points;
		points.splice(0, points.length);
		dirty = true;
		return result;
	}
	
	public function setPoints(_points:Array<Point>):Void {
		points = _points;
		dirty = true;
	}
	
	function computeRoundedPath():Void
	{
		var result:Array<Segment> = new Array<Segment>();
		var count:Int = points.length;
		if (count < 2) {
			path = result; return;
		}
		if (closePath && count < 3) {
			path = result; return;
		}
		
		var p0:Point = points[0];
		var p1:Point = points[1];
		var p2:Point;
		var pp0:Point;
		var pp2:Point;
		
		var pos:Point=new Point();
		var last:Point=new Point();
		if (!closePath) 
		{
			pos = p0;
			last = points[count - 1];
		}
		
		var n:Int = (closePath) ? count + 1 : count - 1;
		
		for (i in 1...n) 
		{
			p2 = points[(i + 1) % count];
			
			var v0:Point = p0.subtract(p1);
			var v2:Point = p2.subtract(p1);
			var r:Float = Math.max(1, Math.min(radius, Math.min(v0.length / 2, v2.length / 2)));
			v0.normalize(r);
			v2.normalize(r);
			pp0 = p1.add(v0);
			pp2 = p1.add(v2);
				
			if (i == 1 && closePath) last = pp0;
			else result.push(new Segment(pos, pp0));
			pos = pp0;
			
			result.push(new Segment(pos, pp2, p1));
			pos = pp2;
			p0 = p1;
			p1 = p2;
		}
			
		if (closePath) result.unshift(new Segment(pos, last));
		else result.push(new Segment(pos, last));
		path=result;
	}
		
	public function getPathLength():Float
	{
		var len:Float = 0;
		for (seg in path) len += seg.length();
		return len;
	}
	
	public function draw(g:Graphics):Void
	{
		if (dirty) computeRoundedPath();		
		if (path.length == 0) return;

		var seg:Segment = path[0];
		g.clear();
		g.lineStyle(thickness, color);
		g.moveTo(seg.start.x, seg.start.y);
		for (seg in path)
		{
			if (seg.control!=null) g.curveTo(seg.control.x, seg.control.y, seg.end.x, seg.end.y);
			else g.lineTo(seg.end.x, seg.end.y);
		}
		g.lineStyle();
		g.endFill();
	}
}