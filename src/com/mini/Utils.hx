package com.mini;


/**
 * ...
 * @author pierre
 */

class Utils {

	inline public static function random(low:Float,high:Float) : Float
	{
		var this_number:Float = high - low;
		var ran_unrounded:Float = Math.random() * this_number;
		var ran_number:Float = Math.round(ran_unrounded); 
		ran_number += low;
		return ran_number;
	}
	
	inline public static function angle(sX:Float,sY:Float,eX:Float,eY:Float):Float {
		return Math.atan2(eY - sY, eX-sX) * 180 / Math.PI;
	}
	
	inline public static function distance(sX:Float,sY:Float, eX:Float, eY:Float):Float {
		return Math.sqrt((eX - sX) * (eX - sX) + (eY - sY) * (eY - sY));
	}
}