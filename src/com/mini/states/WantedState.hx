package com.mini.states;
import com.eclecticdesignstudio.motion.Actuate;
import com.font.MFont;
import com.mini.actions.Action;
import com.mini.mesh.Mesh;
import com.mini.Msprite;
import nme.Assets;


class WantedState extends MState
{

	public function new() 
	{
		super();
	}
	
	var top:Msprite;
	var bottom:Msprite;
	var center:Msprite;
	var wanted:Msprite;
	var title:Msprite;
	
	var buffer:BUFFER; 
	
	override public function enter():Void 
	{
		
		scene.load("wanted", "WANTED.xml");
		wanted = scene.get("wanted"); top = scene.get("top"); center = scene.get("center"); bottom = scene.get("bottom"); title = scene.get("title");
		
/*		var T:MFont = new MFont(Assets.getFont("fonts/MINI.ttf"),64);
		scene.addChild(T);
		T.x = T.y = 100;
		T.text = '<color>'+0xCCCCCC+'<color>ACTION/\nREACTION \nPROMISES <color>'+scene.frameColor+'<color>THE \nGUY WITH A \nVENGEANCE.';*/
		
		
		
		var A = new FlipAction(center);
		
		//var A = new Action(center);
		A.onActionOver = End;
		
		
		
		Actuate.transform(Main.bg, 1).color(scene.bgColor);
		Actuate.transform(Main.frame, 1).color(scene.frameColor);
	}
	
	function End(a):Void {
		Actuate.tween(center, 2, { x:scene.bounds.right, angle:50 } ).onComplete(function() { center.visible = false; } );
		Actuate.tween(wanted, 1, { x:scene.bounds.left - wanted.width*.5 } ).onComplete(fsm.enterState, [new CigarState()]).delay(2.5);
	}
}