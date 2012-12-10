package com.mini;
import com.eclecticdesignstudio.motion.Actuate;
import com.mini.Msprite;
import com.mini.psd.PSD;
import com.mini.states.RoadsterState;
import com.mini.actions.Input;

class Cars extends PSD
{
	var sprite:Msprite;
	var speed:Float = .5;
	var current:Int;
	
	inline static var CABRIO:Int=0;
	inline static var ONE:Int=1;
	inline static var CLUBMAN:Int = 2;
	inline static var COUNTRYMAN:Int = 3;
	inline static var ROADSTER:Int = 4;
	
	public function new() 
	{
		super();
		load("ui", "cars.xml");
		sprite = get("cars");
	}
	
	public function changeCar(model:String):Void {
		switch(model) {
			case "cabrio":switchAnim(0);
			case "one":switchAnim(1);
			case "clubman":switchAnim(2);
			case "countryman":switchAnim(3);
			case "roadster":switchAnim(4);
		}
		
	}
	
	function switchAnim(f:Int):Void {
		if (sprite.frame == f) return;
		Actuate.tween(sprite, speed, { x:realWidth } ).onComplete(function() {
			sprite.setFrame(f);
			Actuate.tween(sprite, speed, { x:0 } );
		});
		current = f;
	}
	
	override public function update():Void
	{
		if (paused) return;
		if (Input.released()) {
			if (hitTestPoint(Input.mx, Input.my)) {
				switch (current) {
					case CABRIO:Main.fsm.enterState(new RoadsterState(), true);
					case ONE:Main.fsm.enterState(new RoadsterState(), true);
					case CLUBMAN:Main.fsm.enterState(new RoadsterState(), true);
					case COUNTRYMAN:Main.fsm.enterState(new RoadsterState(), true);
					case ROADSTER:Main.fsm.enterState(new RoadsterState(), true);
				}
			}
		}
		super.update();
	}
}