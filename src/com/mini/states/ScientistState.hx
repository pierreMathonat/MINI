package com.mini.states;
import com.ancientsheep.particles.ASConfig;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Bounce;
import com.eclecticdesignstudio.motion.easing.Sine;
import com.mini.actions.Action;
import com.mini.Msprite;
import nme.Assets;
import nme.geom.Point;
import nme.text.TextField;

class ScientistState extends MState
{
	var head:Msprite;
	var body:Msprite;
	var hands:Msprite;
	var suie:Msprite;
	var explosion:Msprite;
	var fire:Msprite;
	var title:Msprite;
	
	public function new() 
	{
		super();
	}
	
	override public function enter():Void 
	{	
		sound.load("scientist.xml");
		sound.play("ambiance", 0, -1);
		sound.play("voices", 0, -1);
		sound.play("start");
		
		scene.load("scientist","SCIENTIST.xml");
		body = scene.get("all_body");head = scene.get("head");hands = scene.get("hands");suie = scene.get("suie");explosion = scene.get("explosion");fire = scene.get("Fire");title = scene.get("title");
		
		title.alpha = suie.alpha =0;
		fire.visible = explosion.visible =false;
		fire.scale(1.5);
		fire.x = scene.rect.width / 2 - fire.width / 2;
		hands.addAnim("verse", [0, 1, 2, 3], 60, false);
		body.y = scene.bounds.height;
		
		Actuate.transform(Main.bg, 3).color(scene.bgColor, 1, 1);
		Actuate.transform(Main.frame, 3).color(scene.frameColor, 1, 1);
		Main.cars.changeCar("one");		
		
		Actuate.tween(body, 1, { y :(body.y - body.height) } ).ease(Bounce.easeOut).onComplete(setState, [1]);
		
		var A:Action = new TapAction(body, 2, 1);
		A.onAction = onFire;
		A.onActionOver = AnimEnd;
	}
	
	function onFire(a:Action):Void {
		hands.play("verse").onComplete = function() {
			sound.play("explosion" + a.times);
			Fx.flash(Main.bg, .1, 1, 0xFFFFFF);
			Fx.shake(Main.scene, .05, 5, 0, 20);
			Fx.flash(body, .3, 1, 0x000000);
			fire.visible = true;
			fire.play("default").onComplete = function():Void { fire.visible = false; };
			Actuate.timer(.1).onComplete(playExplosion);
			if (a.times == 1) Actuate.tween(suie, .2, { alpha:1 } ).delay(.2);
			hands.reverse();
		};
	}
	
	function playExplosion():Void {
		explosion.visible = true; explosion.play("default").onComplete = function() { explosion.visible = false; };
	}
	
	function AnimEnd(a:Action):Void {
		Actuate.tween(body, .5, { y:(scene.bounds.bottom) } ).ease(Sine.easeIn).delay(1.5);
		Actuate.tween(title, .5, { y: -title.height } ).ease(Sine.easeIn).delay(1.5);
		Actuate.tween(title, .5, { alpha:1 } );
		Actuate.timer(2.1).onComplete(function():Void { fsm.enterState(new PongState()); } );
	}
}