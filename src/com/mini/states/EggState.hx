package com.mini.states;
import com.eclecticdesignstudio.motion.Actuate;
import com.mini.actions.Action;
import com.mini.Fx;
import com.mini.Msprite;
import com.mini.Utils;
import nme.display.Graphics;
import nme.display.Shape;
import nme.geom.Point;

class EggState extends MState
{

	public function new() 
	{
			super();
	}
	
	var egg:Msprite;
	var top:Msprite;
	var bottom:Msprite;
	var fissure:Msprite;
	var drop:Msprite;
	var drop1:Msprite;
	var title:Msprite;
	var mask:Msprite;
	
	override public function enter():Void 
	{
		scene.load("egg", "EGG.xml");
		egg = scene.get("egg"); top = scene.get("top"); bottom = scene.get("bottom"); fissure = scene.get("fissure"); drop = scene.get("drop"); drop1 = scene.get("drop1"); title = scene.get("title");
		
		title.alpha = drop.alpha = drop1.alpha = 0;
		
		drop1.cur_anim.loop = drop.cur_anim.loop = false;
		drop1.cur_anim.delay = drop.cur_anim.delay = 100;
		
		mask = new Msprite();	fissure.mask = mask; egg.addChild(mask);
		
		Actuate.transform(Main.frame, 3).color(scene.frameColor);
		Actuate.transform(Main.bg, 3).color(scene.bgColor);
		
		var A:Action = new TapAction(egg, 4, 0);
		A.onAction=EggBreak;
		A.onActionOver = animEnd;
	}
	
	override public function update():Void 
	{
		EggHit.draw(mask.graphics);
	}
	
	function EggBreak(a):Void {
		var p = mask.globalToLocal(new Point(a.tapx, a.tapy));
		EggHit.hits.push(new EggHit(p.x, p.y, Utils.random(30,70)));
		Fx.flash(egg, .1, 1, 0xFFFFFF);
		Fx.shake(scene, .1, 2, 10);
		if (a.times == 2) Fx.shake(egg, .1, 100, 2);
	}
	
	function animEnd(a):Void {
		Actuate.stop(egg);
		Actuate.tween(top, .4, { y:top.y-title.height*2.3, angle:20 } );
		fissure.alpha = 0;
		title.alpha = 1;
		Actuate.timer(.3).onComplete(function() {
			drop.alpha = 1; drop.play();
			drop1.alpha = 1; drop1.play();
		});
		Actuate.timer(1.5).onComplete(exitAnim);
	}
	
	function exitAnim():Void {
		top.visible = false;
		Actuate.tween(egg, 1, { y:scene.bounds.bottom } );
		Actuate.tween(title, 1, { y: -title.height } );
		Actuate.timer(1).onComplete(function() {
			fsm.enterState(new KingState());
		});
	}
}

class EggHit {
	
	var x:Float;
	var y:Float;
	var size:Float;
	var maxSize:Float;
	
	public static var hits:Array<EggHit> = new Array<EggHit>();
	
	public function new(_x:Float,_y:Float,_max:Float) {
		x = _x;
		y = _y;
		maxSize = _max;
		size = 20;
	}
	
	public static function draw(graphics:Graphics) {
		graphics.clear();
		graphics.beginFill(0x000000, 1);
		for (hit in hits) {
			graphics.drawCircle(hit.x, hit.y, hit.size);
			if (hit.size < hit.maxSize) hit.size += 2;
		}
	}
}