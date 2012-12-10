package com.mini.states;
import com.ancientsheep.particles.ASP;
import com.ancientsheep.particles.ASParticleSystem;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Linear;
import com.mini.actions.Action;
import com.mini.Fx;
import com.mini.actions.Input;
import com.mini.Msprite;
import nme.geom.Point;

class RoadsterState extends UiState
{

	var landscape:Msprite;
	var foreground:Msprite;
	var main:Msprite;
	var background:Msprite;
	
	var burger_light:Msprite;
	var welcome_light:Msprite;
	
	var sky:Msprite;
	
	var close:Msprite;
	
	
	public function new() 
	{
		super();
	}
	
	override public function enter():Void 
	{
		
		sound.load("roadster.xml");
		Actuate.timer(2).onComplete(sound.play,["voice"]); 
		sound.play("ambiance", 0, 300);
		
		scene.load("roadster", "ROADSTER.xml");
		landscape = scene.get("landscape");
		close = scene.get("close");
		foreground = scene.get("foreground");
		main = scene.get("main");
		background = scene.get("background");
		burger_light = scene.get("burger_light");
		welcome_light = scene.get("welcome_light");
		
		sky = new Msprite();
		sky.drawRect(scene.bgColor, 1, landscape.x, landscape.y, landscape.width, landscape.height);
		landscape.addChildAt(sky, 0);
		
		burger_light.alpha = welcome_light.alpha = 0;
		
		Actuate.transform(scene, 0).color(0x000000);
		Actuate.transform(scene, 3).color(0, 0).delay(.5);
		
		Actuate.tween(main, 50, { x:scene.bounds.width - main.width * .75 } ).ease(Linear.easeNone).delay(.5);
		Actuate.tween(background, 50, { x:scene.bounds.width - background.width * .6 } ).ease(Linear.easeNone).delay(.5);
		Actuate.tween(foreground, 50, { x:scene.bounds.width - foreground.width * .93 } ).ease(Linear.easeNone).delay(.5);
		Actuate.transform(sky, 20).color(0x101010).delay(15);
		Actuate.transform(landscape, 20).color(0x101030, .7).delay(15);
		Actuate.timer(25).onComplete(function() {
			welcome_light.alpha = burger_light.alpha = .5;
			Actuate.tween(welcome_light, 1, { alpha:1 } ).repeat().reflect();
			Actuate.tween(burger_light, 1, { alpha:1 } ).repeat().reflect();
		});
		Fx.Cinema(landscape, 3, landscape.height * .07);

		var emitter:ASParticleSystem = ASParticleSystem.particleWithFile("rain.plist", "particles/");
		emitter.x = -landscape.x+scene.bounds.right*.5;
		landscape.addChildAt(emitter, landscape.numChildren - 2);
		/*
		var fire:ASParticleSystem = ASParticleSystem.particleWithFile("Firework.plist","particles/",512,512);
		landscape.addChildAt(fire, landscape.numChildren - 2);
		fire.x = -landscape.x+scene.bounds.right / 2; fire.y = scene.bounds.height / 2;*/
		
		Actuate.timer(44).onComplete(end);
		
		var A = new TapAction(close);
		A.onAction = end;
	}
	
	function end(?a):Void {
		Fx.Cinema(landscape, 2, 0);
		Actuate.transform(landscape, 1.2).color(0x000000);
		Actuate.timer(1.3).onComplete(fsm.enterState, []);
	}
}