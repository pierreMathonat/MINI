package com.mini.states;
import com.ancientsheep.particles.ASParticleSystem;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Bounce;
import com.eclecticdesignstudio.motion.easing.Linear;
import com.mini.actions.Action;
import com.mini.Fx;
import com.mini.MRbody;
import com.mini.Msprite;
import nme.geom.Point;

class KingState extends MState
{
	public function new() 
	{
		super();
	}
	
	var king:Msprite;
	var title:Msprite;
	var eyes:Msprite;
	var head:Msprite;
	var crown:Msprite;
	var blood:Msprite;
	var body:Msprite;
	
	override public function enter():Void 
	{
		scene.load("king", "KING.xml");
		
		king = scene.get("king"); title = scene.get("title"); eyes = scene.get("eyes"); head = scene.get("head"); crown = scene.get("crown"); blood = scene.get("blood"); body = scene.get("body");
		
		title.alpha = 0;
		eyes.cur_anim.loop = false; eyes.cur_anim.delay = 30;
		crown.anchor.x = 0;
		crown.anchor.y = crown.height;
		blood.alpha = 0;
		
		king.y = scene.bounds.height;
		Actuate.tween(king,1, { y:king.y - king.height*.9 } ).ease(Bounce.easeOut);

		Actuate.transform(Main.frame, 3).color(scene.frameColor);
		Actuate.transform(Main.bg, 3).color(scene.bgColor);
		
		var cutHead = new CutAction(head, 3, 180);
		cutHead.onActionOver = cutAnim;
	}
	
	function cutAnim(a) {
		Actuate.tween(head, .05, { y:head.y-head.height*.1 } );
		Actuate.tween(blood, .05, { alpha:1 } ).onComplete(Actuate.tween, [blood, 8, { alpha:0 } ]);
		Fx.flash(Main.bg, .05, 1, 0xFF0000);
		Fx.shake(king, .03, 2, 0,10);
		eyes.play();
		Actuate.tween(crown, .05, { angle:20, y:crown.y - crown.height * .3 } );
		Actuate.timer(1).onComplete(dieAnim);
	}
	
	function dieAnim() {
		var b = crown.localToGlobal(new Point(0, 0));
		b = scene.globalToLocal(b);
		crown.x = b.x; crown.y = b.y;
		scene.addChild(crown);
		
		
		Actuate.tween(head, 1.5, { y:scene.bounds.bottom } );
		
		var p = ASParticleSystem.particleWithFile("blood.plist", "particles/",128,200);
		p.position.x = body.width * .5;
		p.position.y = -20;
		body.addChild(p);
		
		Actuate.tween(title, .5, { alpha:1 } ).delay(1).repeat(1).reflect();
		Actuate.tween(king, 2, { y:scene.bounds.bottom } ).delay(2.5);
		Actuate.tween(crown, 2, { y:scene.bounds.top - crown.height } ).delay(2.5);
		
		Actuate.timer(4).onComplete(function() {
			fsm.enterState(new ZombieState());
		});
	}
}