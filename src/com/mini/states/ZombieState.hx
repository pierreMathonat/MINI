package com.mini.states;
import com.eclecticdesignstudio.motion.Actuate;
import com.mini.actions.Input;
import com.mini.Msprite;
import nme.Assets;
import nme.display.Sprite;
import nme.geom.Rectangle;
import nme.media.Sound;


class ZombieState extends MState
{
	var zombie:Msprite;
	var head:Msprite;
	var eyes:Msprite;
	var top:Msprite;
	var blood:Msprite;
	var title:Msprite;
	var choc:Msprite;
	var _anchor:Msprite;
	var hands:Msprite;
	
	var hits:Int = 1;
	
	override public function enter():Void 
	{	
		sound.load("zombie.xml");
		sound.play("ambiance", 0, -1);
		sound.transform("ambiance", -1);
		sound.play("grogne2");
		
		scene.load("zombie","ZOMBIE.xml");
		head = scene.get("head");
		eyes = scene.get("eyes");
		zombie = scene.get("zombie");
		hands = scene.get("hands");
		top = scene.get("top");
		blood = scene.get("blood");
		title = scene.get("title");
		choc = scene.get("choc");
		_anchor = scene.get("anchor");
		
		eyes.addAnim("look", [0, 1, 2], 50,false);
		eyes.addAnim("ouch", [3, 4, 5, 2], 100, false);
		hands.addAnim("idle", [0, 1, 2, 3, 4], 100);
		hands.addAnim("take", [5, 6, 7, 8], 50, false);
		hands.play("idle");
		
		zombie.y = -zombie.height;
		head.y = scene.bounds.height;
		head.anchor.y = head.height;
		
		Actuate.tween(zombie, 2, { y:-zombie.height * .8 } );
		Actuate.tween(head, 2, { y:scene.bounds.height - head.height*1.1 } );
		
		blood.visible = false;
		choc.visible = false;
		title.alpha = 0;
		choc.cur_anim.loop = false;
		blood.cur_anim.loop = false;
		top.cur_anim.loop = false;
		
		Actuate.transform(Main.bg, 2).color(scene.bgColor);
		Actuate.transform(Main.frame, 2).color(scene.frameColor);
		Main.cars.changeCar("cabrio");
		setState(0);
	}
	
	override public function update():Void
	{		
		switch(state) {
			case 0:drag();
			case 1:cut_head();
			case 2:end();
			case -1:return;
		}
	}
	
	function drag():Void {
		
		if (Input.released()) zombie.stopDrag();
		if (Input.pressed()) {
			if (zombie.hitTestPoint(Input.mx, Input.my)) {
				sound.stop("grogne2");
				sound.play("grogne1");
				zombie.startDrag(false, new Rectangle(zombie.x, zombie.y-50, 0, 300));	
			}
		}	
		if ((zombie.y + zombie.height) > (head.y + _anchor.y)) {
			zombie.y = head.y + _anchor.y - zombie.height;
			hands.play("take");
			eyes.play("look");
			zombie.stopDrag();
			setState(1);
			return;
		}	
	}
	
	function cut_head():Void {		
		if (hits > 3) state = 2;
		
		if (Input.released()) {
			if ( Input.starty - Input.my > 20) {
				sound.play("choc"+hits,.8);
				choc.visible = true;
				choc.play("default").onComplete = function():Void { choc.visible = false; };
				eyes.play("ouch");
				hits++;
				Fx.shake(Main.scene,.1,3,0,10);
				Fx.flash(Main.bg, .2, 1, 0x900000);
				Actuate.tween(head, .1, { sizeY:1.2, sizeX:.9 } ).repeat(1).reflect();
				Actuate.tween(zombie, .1, { y:zombie.y - head.height * .2 } ).repeat(1).reflect();
			}
		}
	}
	
	function end():Void {
		eyes.play("ouch");
		blood.visible = true; blood.play();
		
		zombie.addChild(top); top.play(); 
		hands.pause("idle");
		top.centerX(); top.y = zombie.height-top.height*1.2;
		Actuate.tween(zombie, .2, { y: -zombie.height * .7 } ).onComplete(animEnd);
		state = -1;
	}
	
	function animEnd():Void {
		Actuate.tween(title, .2, { alpha:1 } ).onComplete(function():Void{
			Actuate.tween(title, .2, { alpha:0 } ).delay(2).onComplete(function() { fsm.enterState(new ScientistState()); } );
		});
		Actuate.tween(zombie, 1, { y: -zombie.height } ).delay(2);
		Actuate.tween(head, 1, { y:scene.bounds.height } ).delay(2);
	}
}