package com.mini.actions;

import com.eclecticdesignstudio.motion.Actuate;
import com.mini.Msprite;
import com.mini.Utils;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Shape;
import nme.filters.BlurFilter;
import nme.filters.DropShadowFilter;
import nme.filters.GlowFilter;
import nme.geom.Point;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.Lib;


class Action extends Sprite
{
	public var Mtarget:Msprite;
	public var repeat:Int=1;
	public var times:Int = 0;
	
	public var timer:Int;
	public var delay:Float;
	
	public var LISTEN_MOUSE_OVER:Bool = true;
	public var LISTEN_MOUSE_OUT:Bool = true;
	public var LISTEN_MOUSE_DOWN:Bool = true;
	public var LISTEN_MOUSE_UP:Bool = true;
	public var LISTEN_MOUSE_MOVE:Bool = true;
	
	public function new(target:Msprite) 
	{
		Mtarget = target;
		
		super();
		
		Mtarget.addChild(this);
		
		activate();
		addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
	}
	
	public function onMouseDown(e):Void {  }
	public function onMouseUp(e):Void {  }
	public function onMouseOver(e):Void {  }
	public function onMouseOut(e):Void {  }
	public function onMouseMove(e):Void {  }
	
	public var onAction:Dynamic->Void;
	public var onActionOver:Dynamic->Void;
	
	function onActionCompleted():Void {
		times++;
		
		if (onAction != null) 
			onAction(this);
			
		if (times >= repeat) 
			actionOver();
		else if (delay > 0)
			applyDelay();
		
		timer = Lib.getTimer();
	}
	
	function applyDelay():Void {
		deactivate();
		Actuate.timer(delay).onComplete(activate);
	}
	
	function actionOver():Void {
		deleteAction();
		if (onActionOver != null) onActionOver(this);
	}
	
	public function reset():Void {
		times = 0;
	}
	
	public function removedFromStage(e):Void {
		removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		deactivate();
	}
	
	public function deleteAction(?e):Void {
		Mtarget.removeChild(this);
	}
	
	public function activate():Void {
		Input.registerAction(this);
	}
	
	public function deactivate():Void {
		Input.unregisterAction(this);
	}
}

class TapAction extends Action
{
	public var tapx:Float;
	public var tapy:Float;
	
	public function new(target:Msprite,_repeat:Int=1,_delay:Float=0) {
		super(target);
		repeat = _repeat;
		delay = _delay;
	}
	
	override public function onMouseDown(e):Void 
	{
		tapx = e.stageX;
		tapy = e.stageY;
		onActionCompleted();
	}
}

class CutAction extends Action
{
	var started:Bool = false;
	public var sx:Float; public var sy:Float; public var ex:Float; public var ey:Float;
	var minSpeed:Float;
	var angle:Float; var angle2:Float;
	public var cut_angle:Float;
	public function new(target:Msprite, _minSpeed:Float, _angle:Float, _repeat:Int=1,_delay=0) {
		super(target);
		repeat = _repeat;
		delay = _delay;
		sx = sy = ex = ey = 0;
		minSpeed = _minSpeed;
		angle = _angle;
		angle2 = _angle-180;
		if (angle2 >= 360) angle2 -= 360;
		if (angle2 <= -360) angle2 += 360;
	}
	
	var startTime:Int;
	function startCut(e):Void {
		started = true;
		sx = e.stageX;
		sy = e.stageY;
		startTime = Lib.getTimer();
	}
	
	function endCut(e):Void {
		started = false;
		ex = e.stageX;
		ey = e.stageY;
		
		cut_angle = Utils.angle(sx, sy, ex, ey);
		var d1 = Math.abs(cut_angle) - Math.abs(angle);
		var d2 = Math.abs(cut_angle) - Math.abs(angle2);
		var validateAngle = ( Math.abs(d1) < 20 || Math.abs(d2) < 20)?true:false;
		var dist = Utils.distance(sx, sy, ex, ey);
		var time = Lib.getTimer() - startTime;
		var s = dist / time;
		var validateSpeed = s > minSpeed;
		
		if (validateAngle && validateSpeed) onActionCompleted();
	}
	
	override public function onMouseOver(e):Void
	{
		if (e.buttonDown && !started)startCut(e);
	}
	override public function onMouseOut(e):Void 
	{
		if(e.buttonDown && started)endCut(e);
	}
}

class MaskCutAction extends CutAction
{	
	public var piece:Msprite;
	var targetM:Shape;
	var pieceM:Shape;
	var targetCut:Shape;
	var pieceCut:Shape;
	
	public function new(target:Msprite,_minSpeed:Float, _angle:Float)
	{
		super(target, _minSpeed, _angle);
		
	}
	
	override public function onActionCompleted():Void 
	{
		if (Mtarget.mask != null) {
			targetM = cast (Mtarget.mask, Shape);
			targetM.graphics.clear();
		}else {
			targetM = new Shape();
			Mtarget.addChild(targetM);
			Mtarget.mask = targetM;
		}
		
		piece = new Msprite();
		piece.addFrame(Mtarget.bitmap.bitmapData);
		piece.addChild(pieceM = new Shape());
		Mtarget.parent.addChild(piece);
		piece.x = Mtarget.x; piece.y = Mtarget.y;
		
		piece.mask = pieceM;

		
		var s:Point;
		var e:Point;
		if (sx <= ex) {
			s = Mtarget.globalToLocal(new Point(sx, sy));
			e = Mtarget.globalToLocal(new Point(ex, ey));
		}else {
			s = Mtarget.globalToLocal(new Point(ex, ey));
			e = Mtarget.globalToLocal(new Point(sx, sy));
		}
		
		
		var b = Mtarget.getBounds(Lib.current.stage);
		s.x = 0;
		e.x = b.width;
		trace(Mtarget.width);
		
		targetM.graphics.beginFill(0xFFFFFF);
		targetM.graphics.moveTo(e.x, e.y);
		targetM.graphics.lineTo(e.x, b.height);
		targetM.graphics.lineTo(s.x, b.height);
		targetM.graphics.lineTo(s.x, s.y);
		targetM.graphics.lineTo(e.x, e.y);
		targetM.graphics.endFill();
		
		
		pieceM.graphics.beginFill(0xFFFFFF);
		pieceM.graphics.moveTo(s.x, s.y);
		pieceM.graphics.lineTo(e.x, e.y);
		pieceM.graphics.lineTo(e.x, 0);
		pieceM.graphics.lineTo(s.x, 0);
		pieceM.graphics.endFill();		
	
		super.onActionCompleted();
	}
}

class FlipAction extends Action
{
	var targetM:Msprite;
	var back:Msprite;
	var backM:Msprite;
	var shadow:Msprite;
	
	public function new(target:Msprite) {
		super(target);
		LISTEN_MOUSE_MOVE = false;
	}
	
	var initiated:Bool = false;
	
	function startFlip(e):Void {
		if (!initiated) init(e);
		LISTEN_MOUSE_MOVE = true;
	}
	
	function endFlip(e):Void {
		LISTEN_MOUSE_MOVE = false;
	}
	
	override public function onMouseDown(e):Void 
	{
		startFlip(e);
	}
	
	override public function onMouseUp(e):Void 
	{
		endFlip(e);
	}
	
	override public function onMouseMove(e):Void 
	{
		flip(e);
	}
	
	function flip(e):Void 
	{
		var p = new Point(e.stageX,e.stageY);
		p = Mtarget.globalToLocal(p);
		
		if (p.x < 0) p.x = 0;
		
		targetM.x = p.x * .5;
		backM.x = targetM.x;
		back.x = p.x;
				
		if (p.x > targetM.width*.8) {
			endFlip(e);
			onActionCompleted();
		}
	}
	
	function init(e):Void {
		
		initiated = true;
		
		Mtarget.addChild(back = new Msprite());
		Mtarget.addChild(backM = new Msprite());
		Mtarget.addChild(targetM = new Msprite());
			back.scaleX = -1;	
		back.addFrame(Mtarget.bitmap.bitmapData);
		
		#if(flash)
		back.filters = [new DropShadowFilter(0,0,0x000000,.5,20,0),new GlowFilter(0x000000,.5,60,0,1,1,true)];
		#end
		Actuate.transform(back).color(0x606060,.85);
		back.mask = backM;
		Mtarget.mask = targetM;
		
		backM.drawRect(0xFFFFFF,1,0, 0, back.width, back.height);
		targetM.drawRect(0xFFFFFF,1,0, 0, Mtarget.width, Mtarget.height);
	}
}