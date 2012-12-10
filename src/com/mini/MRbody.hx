package com.mini;
import nme.events.Event;
import nme.Lib;

class MRbody extends Msprite
{
	public var vx:Float;
	public var vy:Float;
	public var gravity:Float=10;
	public var invMass:Float = 1;
	public var friction:Float = 1;
	public var speed:Float = .1;
	var decorated:Msprite;
	public function new(o:Msprite) 
	{
		super();
		decorated = o;
		vx = 0;
		vy = 0;
	}
	
	public function impulse(_x:Float, _y:Float):Void {
		vx += _x;
		vy += _y;
	}
	
	override public function update():Void 
	{
		vy += gravity;
		decorated.x += vx*invMass*speed;
		decorated.y += vy*invMass*speed;
		vx *= friction;
		vy *= friction;
	}
	
}