package com.mini.states;
import com.mini.actions.Action;
import com.mini.Fx;
import com.mini.Msprite;
import com.eclecticdesignstudio.motion.Actuate;

class GirlState extends MState
{

	public function new() 
	{
		super();
	}
	
	var girl:Msprite;
	var camera:Msprite;
	var title:Msprite;
	var eyes:Msprite;
	var mouth:Msprite;
	
	override public function enter():Void 
	{
		scene.load("girl", "GIRL.xml");
		girl = scene.get("girl"); camera = scene.get("camera"); title = scene.get("title"); eyes = scene.get("eyes"); mouth = scene.get("mouth");
		
		title.alpha = 0;
		mouth.anchor.x = mouth.width * .5; mouth.anchor.y = mouth.height * .5;
		
		Actuate.transform(Main.frame, 3).color(scene.frameColor);
		Actuate.transform(Main.bg, 3).color(scene.bgColor);
		
		var test:Action = new TapAction(girl,3,.5);
		test.onAction = Flash;
		test.onActionOver = End;
	}
	
	function Flash(a):Void {
		Fx.flash(Main.bg, .2, 1, 0xFFFFFF);
		Fx.flash(girl, .2, 1, 0xFFFFFF);
		Actuate.timer(.1).onComplete(function() {
			girl.nextFrame();
			Actuate.tween(eyes, .1, { sizeY:0.1 } ).repeat(3).reflect();
		});	
	}
	
	function End(a):Void {
		title.alpha = 1;
		Actuate.tween(mouth, 1, { sizeX:.6,sizeY:1.2 } );
		Actuate.tween(girl, 1, { y:scene.bounds.bottom } ).delay(2);
		Actuate.timer(3).onComplete(function() {
			fsm.enterState(new EggState());
		});
	}
}