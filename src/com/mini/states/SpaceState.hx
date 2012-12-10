package com.mini.states;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Sine;
import com.eclecticdesignstudio.motion.easing.Back;
import com.eclecticdesignstudio.motion.easing.Linear;
import com.eclecticdesignstudio.motion.MotionPath;
import com.mini.Fx;
import com.mini.actions.Input;
import com.mini.Line;
import com.mini.Msprite;
import nme.Assets;
import nme.display.Graphics;
import nme.geom.Point;

class SpaceState extends MState
{
	var spaceman:Msprite;
	var man:Msprite;
	var title:Msprite;
	var stroke:Msprite;
	var w:Float;
	public function new() {super();}
	
	override public function enter():Void 
	{
		sound.load("space.xml");
		sound.play("ambiance", 0, -1);
		sound.play("voice7");
		
		scene.load("space", "SPACE.xml");
		spaceman = scene.get("spaceman"); man = scene.get("man"); title = scene.get("title");
		
		title.x = scene.bounds.x + title.width * .2;
		title.align.alignMode = SizeFormat.ALIGN_LEFT;
		
		spaceman.x = scene.bounds.right;
		
		stroke = new Msprite();
		scene.addChildAt(stroke,0);
		initPath();
		
		Actuate.tween(man, 10, { angle: -20 } ).delay(1).ease(Linear.easeNone).repeat().reflect();
		
		Actuate.timer(35).onComplete(function():Void {
			Actuate.transform(spaceman, 5).color(0x000000).ease(Sine.easeIn);
			Actuate.transform(stroke, 5).color(0x000000).ease(Sine.easeIn);
			Actuate.transform(Main.bg, 5.2).color(0x000000).ease(Sine.easeIn).onComplete(function() {
				fsm.enterState(new ZombieState());
			});
		});
		
		Actuate.transform(Main.frame, 10).color(scene.frameColor);
		Actuate.transform(Main.bg, 10).color(scene.bgColor);
		Main.cars.changeCar("clubman");
	}

	function initPath():Void {
		buildLine(6);
		var path = new MotionPath().bezier(scene.bounds.right * .22, -spaceman.height, scene.bounds.right * .5, scene.bounds.bottom * .5);
		Actuate.motionPath(spaceman, 50, { x:path.x, y:path.y } ).ease(Linear.easeNone);
	}
	
	var hits:Int = 1;
	override public function update():Void 
	{
		animateLine();
		drawLine();
		if (Input.released() && spaceman.hitTestPoint(Input.mx, Input.my)) {
			//sound.closeAll();
			//sound.play("ambiance", 0, 30);
			var toClose = hits==1?7:hits - 1;
			sound.stop("voice" + toClose);
			sound.play("voice"+hits);
			hits++;
			if (hits > 7) hits = 1;
		}
	}
	
	var line:Line;
	var points:Array<Point>;
	function buildLine(p:Int ):Void {
		line = new Line(1, 0xFFFFFF, 100);
		points = new Array<Point>();
		for (i in 0...p) {
			var p = new Point();
			points.push(p);
		}
	}

	var time:Float=1;
	function animateLine() {
		var startx = spaceman.x + spaceman.width / 2;
		var starty = spaceman.y + spaceman.height*.3;
		var endx = scene.bounds.right*1.3;
		var endy = scene.bounds.bottom * .5;
		
		var stepx = (endx - startx) / points.length;
		var stepy = (endy - starty) / points.length;
		
		var variation:Float = 100;
		
		for (i in 0...points.length) {
			var p = points[i];
			p.x = startx + stepx * i;
			p.y = starty + stepy * i;
			if (i == 0 || i == points.length ) continue;
			p.y += variation*time;
			variation = -variation;
		}
		time *= .999;
	}
	
	function drawLine():Void {
		line.setPoints(points);
		line.draw(stroke.graphics);
	}
}