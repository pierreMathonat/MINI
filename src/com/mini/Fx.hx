package com.mini;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.GenericActuator;
import com.eclecticdesignstudio.motion.easing.Back;
import com.eclecticdesignstudio.motion.easing.Bounce;
import com.eclecticdesignstudio.motion.easing.Elastic;
import com.eclecticdesignstudio.motion.easing.Sine;
import com.mini.display.Display;
import nme.display.DisplayObject;
import nme.display.Sprite;
import nme.Vector;


class Fx 
{

	public static function flash(o:Display, d:Float, times:Int, flashcolor:Int, strength:Float=1):IGenericActuator {
		return Actuate.transform(o, d/2).color(flashcolor,strength).repeat(times*2-1).reflect();
	}
	
	public static function shake(o:Display, d:Float, times:Int, shakeX:Float = 0, shakeY:Float = 0):IGenericActuator {
		return Actuate.tween(o, d/2, { x:o.x + shakeX,y:o.y+shakeY } ).ease(Sine.easeIn).repeat(times*2-1).reflect();
	}
	
	public static function Cinema(o:Display, d:Float, size:Float) {
		if (o.getChildByName("cinema_up") != null) {
			var up = o.getChildByName("cinema_up");
			var down = o.getChildByName("cinema_down");
			Actuate.tween(up, d, { y:-up.height } );
			Actuate.tween(down, d, { y:down.y+down.height } );
			Actuate.timer(d + .1).onComplete(function() {
				var up = o.getChildByName("cinema_up");
				var down = o.getChildByName("cinema_down");
				if(up!=null)o.removeChild(up);
				if(down!=null)o.removeChild(down);
			});
			return;
		}
		var cinema_up = new Msprite(); var cinema_down = new Msprite();
		cinema_up.drawRect(0x000000, 1, 0, 0, o.width, size*2);
		cinema_down.drawRect(0x000000, 1, 0, 0, o.width, size*2);
		cinema_up.y = -size*2; cinema_down.y = o.height;
		cinema_down.name = "cinema_down"; cinema_up.name = "cinema_up";
		o.addChild(cinema_up); o.addChild(cinema_down);
		Actuate.tween(cinema_up, d, { y:-size } );
		Actuate.tween(cinema_down, d, { y:cinema_down.y-cinema_down.height+size } );
	}
}
