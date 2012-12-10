package com.mini.states;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Bounce;
import com.eclecticdesignstudio.motion.easing.Sine;
import com.mini.Fx;
import com.mini.actions.Input;
import com.mini.Msprite;
import nme.Assets;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;

class PongState extends MState
{

	public function new() {super();}
	
	var all:Msprite;
	var pad:Msprite;
	var padBody:Msprite;
	var tv:Msprite;
	var startText:Msprite;
	var startScreen:Msprite;
	var bg:Msprite;
	var pong:Msprite;
	var player:Msprite;
	var ai:Msprite;
	var ball:Msprite;
	var score:TextField;
	var title2:Msprite;
	var title1:Msprite;
	
	var _bounds:Rectangle; 
	
	override public function enter():Void {
		
		sound.load("pong.xml");
		
		scene.load("pong","PONG2.xml");
		all = scene.get("all");
		pad = scene.get("pad");
		tv = scene.get("tv");
		padBody = scene.get("padBody");
		startText = scene.get("startText");
		startScreen = scene.get("startScreen");
		bg = scene.get("bg");
		pong = scene.get("pong");
		player = scene.get("player");
		ai = scene.get("ai");
		ball = scene.get("ball");
		title2 = scene.get("title2");
		title1 = scene.get("title1");
		
		scene.get("stars").play();
		
		score = new TextField();
		score.y = pong.height * .1;
		score.width = pong.width/2;
		score.embedFonts = true;
		var font = Assets.getFont("img/pong/pong.ttf");
		var format:TextFormat = new TextFormat(font.fontName, player.height / 2, 0xFFFFFF);
		format.align = TextFormatAlign.CENTER;
		score.defaultTextFormat = format;
		pong.addChild(score);
		
		title1.x = scene.bounds.right;
		title2.alpha = 0;
		pong.alpha = 0;
		all.y = -all.height;
		
		Actuate.tween(startText, .3, { alpha:0 } ).delay(.1).repeat().reflect();
		Actuate.tween(all, 4, { y:all.y + scene.bounds.height * .7 } );
		
		Actuate.transform(Main.bg, 3).color(scene.bgColor, 1, 1);
		Actuate.transform(Main.frame, 3).color(scene.frameColor, 1, 1);
		
		Main.cars.changeCar("countryman");
		setState(0);
	}
	
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	override public function update():Void {
		switch(state) {
			case 0:pressStart();
			case 1:startPong();
			case 2:playPong();
			case 3:End();
			case-1:return;
		}
	}
	
	function pressStart():Void {
		Main.cars.changeCar("one");
		if (Input.released()) {
			if (padBody.hitTestPoint(Input.mx, Input.my)) {
				sound.play("start");
				Actuate.timer(1.5).onComplete(function() {
					sound.play("music", 0, -1);
					sound.fadeIn("music",9);
				});
				Actuate.tween(title1, 1, { x:pad.x+padBody.x+padBody.width*1.05 } ).ease(Bounce.easeOut);
				Actuate.tween(all, 9, { y:scene.bounds.height*.04 } ).ease(Sine.easeOut).delay(2.4).onComplete(setState,[1]);
				Actuate.transform(Main.bg, 9).color(0x050505, 1, 1).delay(6.5).ease(Sine.easeIn);
				setState( -1);
			}
		}
	}
	
	function startPong():Void {
		if (Input.released()) {
			sound.play("start");
			sound.stop("music");
			startText.visible = false;
			Fx.flash(bg, .1, 2, 0xFFFFFF);
			Actuate.tween(startScreen, .5, { alpha:0 } ).delay(.4);
			
			initPong();
			Actuate.tween(pong, .5,{alpha:1}).delay(1).onComplete(setState, [2]);
		}
	}
	
	function endPong():Void {
		sound.play("endGame");
		ball.visible = false;
		Fx.flash(bg, .1, 2, 0xFFFFFF);
		Fx.shake(Main.scene, .1, 2, 0, 10);
		Actuate.tween(pong, .1, { alpha:0 } );
		
		Actuate.tween(title2, .1, { alpha:1 } ).onComplete(function():Void {
		Actuate.tween(title2, .5, { alpha:0 } ).delay(2).onComplete(setState,[3]);
		});
		setState( -1);
	}
	
	function End():Void {
		all.anchor = all.globalToLocal(bg.localToGlobal(bg.anchor));
		Actuate.tween(all, 5, { sizeX:3, sizeY:3 } );
		
		Actuate.timer(2).onComplete(function():Void { Fx.flash(scene, .02, 5, 0x808080);}  );
		Actuate.timer(3).onComplete(function():Void { Main.fsm.enterState(new SpaceState()); } );
		Actuate.tween(all, 1, { alpha:0 } ).delay(2);
		setState( -1);
	}
	
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	// PONG
	//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	var playerSpeed:Float;
	var ballSpeed:Float;
	var vx:Float;
	var vy:Float;
	var plScore:Int = 0;
	
	function initPong():Void {
		playerSpeed = ball.height * .3;
		ballSpeed = playerSpeed*.5;
		vx = 1;
		vy = .6;
		_bounds = new Rectangle(bg.width * .1, bg.height * .1, bg.width * .9, bg.height * .9);
	}
	
	function playPong():Void {
		_bounds.x = bg.width * .1;
		_bounds.y = bg.height * .1;
		_bounds.width = bg.width * .9;
		_bounds.height = bg.height * .9;
		if (Input.pressed()) {
			var y = player.globalToLocal(new Point(Input.mx, Input.my)).y-player.height/2;
			if(Math.abs(y)>playerSpeed)movePlayer(y>0?1:-1);
		}
		moveBall();
		moveAi();
		score.text = Std.string(plScore);
	}
	
	function movePlayer(y:Float):Void {
		player.y += y * playerSpeed;
		if (player.y < _bounds.y) player.y = _bounds.y;
		if (player.y + player.height > _bounds.height) player.y = _bounds.height - player.height;
	}
	
	function moveAi():Void {
		var y = ((ai.y+ai.height/2) - (ball.y+ball.height/2));
		if(Math.abs(y)>ai.height*.6)ai.y += (y>0?-1:1) * playerSpeed*.5;
		if (ai.y < _bounds.y) ai.y = _bounds.y;
		if (ai.y + ai.height > _bounds.height) ai.y = _bounds.height - ai.height;
	}
	
	function moveBall():Void {
		ball.x += vx*ballSpeed;
		ball.y += vy*ballSpeed;
		if (ball.y < _bounds.y) vy = -vy;
		if (ball.y + ball.height > _bounds.height) vy = -vy;
		
		if (ball.hitTestObject(ai)) {
			ball.x = ai.x - ball.width; vx = -vx;
			ballSpeed *=1.05;
			plScore++;
			sound.play("ai");
		}
		if (ball.hitTestObject(player)) {
			ball.x = player.x + player.width; vx = -vx;
			var dif = ((ball.y + ball.height*.5) - (player.y + player.height*.5))/(player.height*.5);
			if(Math.abs(dif)>.4)vy=dif;
			plScore++;
			playerSpeed *= 1.02;
			sound.play("player");
		}
		if (ball.x < player.x || ball.x>ai.x+ai.width) {
			endPong();
		}
	}
}