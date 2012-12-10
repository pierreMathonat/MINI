package com.mini.states;
import com.eclecticdesignstudio.motion.Actuate;
import com.mini.actions.Action;
import com.mini.Msprite;
import flash.geom.Point;

class CigarState extends MState 
{

	var cigar:Msprite;
	var title:Msprite;
	
	public function new() 
	{
		super();
	}
	
	override public function enter():Void 
	{
		scene.load("cigar", "CIGAR.xml");
		cigar = scene.get("cigar"); title = scene.get("title");
		
		title.alpha = 0;
		cigar.y = scene.bounds.bottom;
		
		Actuate.tween(cigar, 1, { y:scene.bounds.bottom - cigar.height } );
		Actuate.transform(Main.bg, 1).color(scene.bgColor);
		Actuate.transform(Main.frame, 1).color(scene.frameColor);
		
		var A = new MaskCutAction(cigar, 3, 180);
		A.onAction = Cut;
		A.onActionOver = End;
	}
	
	function Cut(a):Void { 
		Actuate.tween(a.piece, 2, { y: -a.piece.height, angle:180 } );
	}
	function End(a):Void { 
		var p = scene.globalToLocal(new Point(a.ex, a.ey));
		title.y = p.y - title.height - 20;
		Actuate.tween(title, 1, { alpha:1 } );
		Actuate.timer(1.5).onComplete(animEnd);
	}
	
	function animEnd():Void {
		Actuate.tween(cigar, 1, { y:scene.bounds.bottom } );
		Actuate.tween(title, 1, { y: -title.height } );
		Actuate.timer(1).onComplete(fsm.enterState, [new GirlState()]);
	}
}