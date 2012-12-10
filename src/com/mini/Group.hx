package com.mini;

class Group extends Msprite
{
	var objects:Array<Msprite>;
	
	public function new() 
	{
		super();
		objects = new Array<Msprite>();
	}
	
	public function add(v:Msprite):Void {
		objects.push(v);
		addChild(v);
	}
	
	public function remove(v:Msprite):Void {
		objects.remove(v);
		removeChild(v);
	}
	
	override public function update():Void {
		for (s in objects) s.update();
		super.update();
	}
	
	public function clear():Void {
		
		for (s in objects) {
			s.dispose();
		}
		objects.splice(0, objects.length);
	}
}