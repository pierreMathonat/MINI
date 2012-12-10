package com.mini.states;
import com.mini.SoundManager;
import com.mini.states.Fsm;
import com.eclecticdesignstudio.motion.Actuate;
import com.mini.psd.PSDscene;

class MState extends State
{
	var scene:PSDscene;
	var state:Int = 0;
	var sound:SoundManager;
	public static var Debug:Bool = false;
	
	public function new() 
	{
		super();
		if(Debug)trace("created ::"+type);
		sound = new SoundManager();
		init();
	}
	
	function init():Void {
		scene = Main.scene;
	}
	
	override public function pause():Void 
	{
		//if(Debug)trace("pause ::"+type);
		Actuate.pauseAll();
		scene.paused = true;
		scene.freeMemory();
		sound.fadeOutAll(2);
	}
	
	override public function play():Void 
	{
		//if(Debug)trace("play ::"+type);
		Actuate.resumeAll();
		scene.paused = false;
		scene.loadAssets();
		sound.fadeInAll(2);
	}
	
	override public function exit():Void 
	{
		if (Debug) trace("exit ::" + type);
		scene.stopTweens();
		scene.clear();
		sound.fadeOutAll(2);
		Actuate.timer(2).onComplete(sound.closeAll);
	}
	
	function setState(v:Int):Void {state = v;}
}